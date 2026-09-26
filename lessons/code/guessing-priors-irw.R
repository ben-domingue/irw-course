# Guessing and priors with real data: roar_lexical (a lexical decision task from the
# Rapid Online Assessment of Reading) and vocabulary_iq (the Open Psychometrics
# Vocabulary IQ Test) from the Item Response Warehouse. Runs as-is in R with the
# mirt package; no login or token. The cross-validation and the repeated
# subsamples take a few minutes each.
# Adapted from ben-domingue/252: ps4/guessing.R (PS4#3) and ps4/priors.R (PS4#4).

## ---- fetch-roar
library(mirt)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/) with
# a CSV download. This link is pinned to one version of the data.
roar_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.roar_lexical/rows?format=csv"
roar <- read.csv(roar_url)
# One row per response. resp is 1 when the respondent classified the string
# correctly (real word or made-up word); rt is the response time in seconds;
# realpseudo says which kind of string it was. One response per respondent per
# item, and no waves.
c(responses = nrow(roar), respondents = length(unique(roar$id)),
  items = length(unique(roar$item)), missing = sum(is.na(roar$resp)))
table(roar$realpseudo)
round(c(accuracy = mean(roar$resp), tapply(roar$resp, roar$realpseudo, mean)), 2)

# IRW tables are long (one row per response); mirt wants wide (one row per respondent).
long2wide <- function(df) as.data.frame(tapply(df$resp, list(df$id, df$item), function(x) x[1]))
resp_roar <- long2wide(roar)
round(quantile(colMeans(resp_roar), c(0, 0.1, 0.5, 1)), 2)   # proportion correct by item

## ---- fit-roar
# The Rasch model, and the Rasch model with every lower asymptote fixed at 0.5
# (two choices, so chance is one in two). guess = 0.5 fixes mirt's g, our c; it is
# not estimated, so both models have the same number of parameters.
set.seed(252)
rasch <- mirt(resp_roar, 1, itemtype = "Rasch", verbose = FALSE)
fixed <- mirt(resp_roar, 1, itemtype = "Rasch", guess = 0.5, verbose = FALSE)
b_rasch <- -coef(rasch, simplify = TRUE)$items[, "d"]   # mirt's d is an easiness: b = -d
b_fixed <- -coef(fixed, simplify = TRUE)$items[, "d"]
th_rasch <- fscores(rasch)[, 1]
th_fixed <- fscores(fixed)[, 1]
data.frame(parameters = c(extract.mirt(rasch, "nest"), extract.mirt(fixed, "nest")),
           logLik = round(c(extract.mirt(rasch, "logLik"), extract.mirt(fixed, "logLik"))),
           sd_ability = round(sqrt(c(coef(rasch)$GroupPars[2], coef(fixed)$GroupPars[2])), 2),
           sd_difficulty = round(c(sd(b_rasch), sd(b_fixed)), 2),
           row.names = c("Rasch", "Rasch, c = 0.5"))
round(c(cor_abilities = cor(th_rasch, th_fixed), cor_difficulties = cor(b_rasch, b_fixed)), 2)

## ---- items-roar
# Where do the two models disagree about an item? Difficulty against proportion
# correct: with c = 0.5, an item that 60% get right is only just above chance.
p_roar <- colMeans(resp_roar)
plot(p_roar, b_rasch, pch = 19, col = "#93c5fd", ylim = range(c(b_rasch, b_fixed)),
     xlab = "Proportion correct", ylab = "Difficulty b")
points(p_roar, b_fixed, pch = 19, col = "#2780e3")
legend("topright", c("Rasch", "Rasch, c = 0.5"), pch = 19, col = c("#93c5fd", "#2780e3"), bty = "n")
# Items answered correctly by fewer than half the respondents: below chance. Are
# they real words or made-up ones?
kind <- tapply(roar$realpseudo, roar$item, function(x) x[1])[names(p_roar)]
table(kind[p_roar < 0.5])
# The five hardest items under each model
hardest <- order(p_roar)[1:5]
data.frame(p = round(p_roar[hardest], 2), b_rasch = round(b_rasch[hardest], 2),
           b_fixed = round(b_fixed[hardest], 2))

## ---- cv-roar
# Does fixing c help on responses the models never saw? Five-fold cross-validation
# over responses, scored by the IMV (as in the lesson "Model fit and out-of-sample
# prediction").
coin <- function(ll) {
  if (ll <= log(0.5)) return(0.5)
  uniroot(function(w) w * log(w) + (1 - w) * log(1 - w) - ll, c(0.5, 1 - 1e-12), tol = 1e-12)$root
}
mean_ll <- function(y, p) mean(y * log(p) + (1 - y) * log(1 - p))
imv <- function(y, p0, p1) {
  w0 <- coin(mean_ll(y, p0)); w1 <- coin(mean_ll(y, p1))
  (w1 - w0) / w0
}
# Predicted probabilities for cells (row, column) from a fitted model, in mirt's
# form g + (u - g) * logistic(a * theta + d), with EAP abilities.
predict_cells <- function(m, cells) {
  th <- fscores(m)[, 1]
  cf <- coef(m, simplify = TRUE)$items
  i <- cells[, 2]
  cf[i, "g"] + (cf[i, "u"] - cf[i, "g"]) * plogis(cf[i, "a1"] * th[cells[, 1]] + cf[i, "d"])
}
set.seed(1)
X <- as.matrix(resp_roar)
cells <- which(!is.na(X), arr.ind = TRUE)
fold <- sample(rep(1:5, length.out = nrow(cells)))
cv <- do.call(rbind, lapply(1:5, function(f) {
  test <- cells[fold == f, , drop = FALSE]
  train <- X; train[test] <- NA; train <- as.data.frame(train)
  data.frame(fold = f, row = test[, 1], col = test[, 2], y = X[test],
             rasch = predict_cells(mirt(train, 1, itemtype = "Rasch", verbose = FALSE), test),
             fixed = predict_cells(mirt(train, 1, itemtype = "Rasch", guess = 0.5, verbose = FALSE), test))
}))
imv_folds <- sapply(split(cv, cv$fold), function(d) imv(d$y, d$rasch, d$fixed))
round(c(imv_folds, mean = mean(imv_folds)), 4)
# Where does the gain come from? The same IMV among held-out responses from the
# quarter of respondents with the lowest accuracy, and from everyone else.
acc <- rowMeans(X)
low <- acc[cv$row] <= quantile(acc, 0.25)
round(c(lowest_quarter = imv(cv$y[low], cv$rasch[low], cv$fixed[low]),
        other_three_quarters = imv(cv$y[!low], cv$rasch[!low], cv$fixed[!low])), 4)

## ---- rt-roar
# Response times. A response faster than 0.3 seconds leaves little time to read
# the string; how many are there, and how accurate are they?
fast <- roar$rt < 0.3
round(c(share_under_0.3s = mean(fast), accuracy_under_0.3s = mean(roar$resp[fast]),
        accuracy_otherwise = mean(roar$resp[!fast])), 3)
# Rapid responses by respondent: are they spread thinly, or concentrated?
by_id <- data.frame(share_fast = tapply(fast, roar$id, mean), accuracy = tapply(roar$resp, roar$id, mean))
c(respondents = nrow(by_id), with_any_fast = sum(by_id$share_fast > 0),
  with_over_10pct_fast = sum(by_id$share_fast > 0.1))
round(head(by_id[order(-by_id$share_fast), ], 6), 2)
round(cor(by_id$share_fast, by_id$accuracy, method = "spearman"), 2)

## ---- mixture-roar
# Guessing as a property of respondents: a two-class mixture (Xiao et al., 2026).
# Engaged respondents follow the Rasch model, theta ~ normal(0, sd^2); guessing
# respondents answer every item correctly with probability g = 0.5. pi is the
# share of engaged respondents. mirt has no ready-made version, so we fit it by EM
# on a grid of abilities: the E step gives each respondent's posterior over
# (class, ability); the M step updates the difficulties (Newton steps), the SD
# and pi. Takes a few seconds.
fit_mixture <- function(X, g = 0.5, Q = 41, maxit = 1000, tol = 1e-6) {
  pl <- function(x) pmin(pmax(plogis(x), 1e-10), 1 - 1e-10)
  z <- seq(-5, 5, length.out = Q); wz <- dnorm(z) / sum(dnorm(z))
  b <- -qlogis(pmin(pmax(colMeans(X), 0.01), 0.99)); s <- 1; pi <- 0.9
  ll_guess <- rowSums(X) * log(g) + rowSums(1 - X) * log(1 - g)
  old <- -Inf
  for (it in 1:maxit) {
    P <- pl(outer(s * z, b, "-"))                                    # nodes x items
    a <- X %*% t(log(P)) + (1 - X) %*% t(log(1 - P)) + rep(log(wz), each = nrow(X))
    m <- apply(a, 1, max); ll_engaged <- m + log(rowSums(exp(a - m)))
    both <- cbind(log(pi) + ll_engaged, log(1 - pi) + ll_guess)
    mm <- apply(both, 1, max); ll_i <- mm + log(rowSums(exp(both - mm)))
    ll <- sum(ll_i)
    p_engaged <- exp(log(pi) + ll_engaged - ll_i)
    W <- exp(a - ll_engaged) * p_engaged                            # respondents x nodes
    nq <- colSums(W); r <- t(W) %*% X
    pi <- mean(p_engaged)
    for (k in 1:5) {
      P <- pl(outer(s * z, b, "-"))
      step <- colSums(nq * P - r) / colSums(nq * P * (1 - P))
      b <- b + pmax(pmin(step, 1), -1)
    }
    s <- exp(optimize(function(ls) {
      P <- pl(outer(exp(ls) * z, b, "-")); -sum(r * log(P) + (nq - r) * log(1 - P))
    }, c(-2, 1.5))$minimum)
    if (abs(ll - old) < tol) break
    old <- ll
  }
  list(b = b, sd = s, pi = pi, loglik = ll, p_guess = 1 - p_engaged)
}
mix <- fit_mixture(X)
data.frame(pi_hat = round(mix$pi, 2), loglik_mixture = round(mix$loglik),
           gain_over_rasch = round(mix$loglik - extract.mirt(rasch, "logLik")),
           gain_fixed_floor = round(extract.mirt(fixed, "logLik") - extract.mirt(rasch, "logLik")))
# Who lands in the guessing class? Compare with the rapid responders found above.
guesser <- mix$p_guess > 0.5
high_rapid <- by_id[rownames(X), "share_fast"] > 0.1
table(over_10pct_rapid = high_rapid, guessing_class = guesser)
round(range(rowMeans(X)[guesser]), 2)   # accuracy of the guessing class

## ---- fetch-viqt
viqt_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.vocabulary_iq/rows?format=csv"
viqt <- read.csv(viqt_url)
# Items 1-45 are the vocabulary questions (pick the two words of five that mean
# the same). Items 46-75 are an optional personality survey bundled into the same
# table, which we drop. resp is 1 for the correct pair and 0 otherwise; choosing
# "don't know" is missing. No waves.
viqt <- viqt[viqt$item <= 45, ]
round(c(correct = mean(viqt$resp == 1, na.rm = TRUE), dont_know = mean(is.na(viqt$resp))), 3)
resp_all <- long2wide(viqt)
resp_all <- resp_all[, order(as.numeric(colnames(resp_all)))]
names(resp_all) <- paste0("Q", names(resp_all))
# We keep the respondents who never chose "don't know", so every response is scored.
resp_cc <- resp_all[complete.cases(resp_all), ]
c(respondents = nrow(resp_all), never_dont_know = nrow(resp_cc))
# Sum scores at the bottom. A random pair is right 1 time in 10, so random answers
# to all 45 items would score about 4.5.
score <- rowSums(resp_cc)
table(score)[as.character(0:6)]
# The source file codes a question left unanswered as 0, apart from "don't know"
# (-1); the IRW table scores 0 as a wrong pair. How many of the low scorers left
# questions blank? The IRW id is the row number in the source file.
zipf <- tempfile(fileext = ".zip")
download.file("http://openpsychometrics.org/_rawdata/VIQT_data.zip", zipf, quiet = TRUE, mode = "wb")
raw <- read.delim(unz(zipf, "VIQT_data/VIQT_data.csv"))
blanks <- rowSums(raw[as.numeric(rownames(resp_cc)), paste0("Q", 1:45)] == 0)
c(score_0 = sum(score == 0), score_0_all_blank = sum(score == 0 & blanks == 45),
  score_1_to_4 = sum(score >= 1 & score <= 4), score_4_or_less_any_blank = sum(score <= 4 & blanks > 0))
# A score of 0 on 45 answered items
# is very unlikely (0.9^45 = 0.009 for a respondent choosing pairs at random), so
# these low scores mostly record blanks. We set aside everyone scoring 4 or less.
resp_viqt <- resp_cc[score > 4, ]
c(set_aside = sum(score <= 4), kept = nrow(resp_viqt))
round(quantile(colMeans(resp_viqt), c(0, 0.25, 0.5, 0.75, 1)), 2)   # proportion correct by item

## ---- full-viqt
# The 3PL on everyone kept, as a reference, without priors and with them; and,
# for comparison, without priors on the sample that still includes the low scorers.
# Priors in mirt's syntax: log a ~ normal(0, 1), and c ~ beta(2, 18). mirt stores
# c (its g) on the logit scale, and "expbeta" puts the beta prior on plogis() of
# that value, the probability. mirt maximizes the posterior, so with little
# information c settles near the prior's mode, (2 - 1)/(2 + 18 - 2) = 0.056
# (its mean is 0.1, the chance rate).
ni <- ncol(resp_viqt)
spec <- mirt.model(paste0("F = 1-", ni, "\n",
  "PRIOR = (1-", ni, ", a1, lnorm, 0, 1), (1-", ni, ", g, expbeta, 2, 18)"))
set.seed(252)
ref <- mirt(resp_viqt, 1, itemtype = "3PL", verbose = FALSE, technical = list(NCYCLES = 5000))
ref_prior <- mirt(resp_viqt, spec, itemtype = "3PL", verbose = FALSE, technical = list(NCYCLES = 5000))
ref_with_low <- mirt(resp_cc, 1, itemtype = "3PL", verbose = FALSE, technical = list(NCYCLES = 5000))
cf_ref <- coef(ref, simplify = TRUE, IRTpars = TRUE)$items         # a, b, g (our c)
cf_ref_prior <- coef(ref_prior, simplify = TRUE, IRTpars = TRUE)$items
cf_with_low <- coef(ref_with_low, simplify = TRUE, IRTpars = TRUE)$items
round(rbind(c_with_low_scorers = quantile(cf_with_low[, "g"], c(0, 0.5, 1)),
            c_no_prior = quantile(cf_ref[, "g"], c(0, 0.5, 1)),
            c_with_prior = quantile(cf_ref_prior[, "g"], c(0, 0.5, 1)),
            a_with_low_scorers = quantile(cf_with_low[, "a"], c(0, 0.5, 1)),
            a_no_prior = quantile(cf_ref[, "a"], c(0, 0.5, 1))), 3)

## ---- beta-viqt
# A trap: "beta" in place of "expbeta" puts the beta prior on the logit of c
# itself. Logits below 0 have zero prior density, so every logit is pushed into
# (0, 1) and every c to at least 0.5.
spec_beta <- mirt.model(paste0("F = 1-", ni, "\n",
  "PRIOR = (1-", ni, ", a1, lnorm, 0, 1), (1-", ni, ", g, beta, 2, 18)"))
wrong <- mirt(resp_viqt, spec_beta, itemtype = "3PL", verbose = FALSE, technical = list(NCYCLES = 5000))
round(quantile(coef(wrong, simplify = TRUE, IRTpars = TRUE)$items[, "g"], c(0, 0.5, 1)), 3)

## ---- sub-viqt
# Now pretend we had only 300 respondents. Fit the 3PL to a random 300, without
# and with the priors, and compare each with the full-sample reference.
rmse <- function(x, y) sqrt(mean((x - y)^2))
compare <- function(seed) {
  set.seed(seed)
  # Redraw if some item has no wrong answers in the subsample (it can't be fitted).
  repeat {
    sub <- resp_viqt[sample(nrow(resp_viqt), 300), ]
    if (all(colMeans(sub) < 1)) break
  }
  # Without priors, EM may still be crawling after 2,000 cycles (a warning says
  # so); that slow drift of slopes toward large values is part of the finding.
  none <- coef(mirt(sub, 1, itemtype = "3PL", verbose = FALSE, technical = list(NCYCLES = 2000)),
               simplify = TRUE, IRTpars = TRUE)$items
  prior <- coef(mirt(sub, spec, itemtype = "3PL", verbose = FALSE, technical = list(NCYCLES = 2000)),
                simplify = TRUE, IRTpars = TRUE)$items
  list(none = none, prior = prior,
       summary = c(sd_a_none = sd(none[, "a"]), sd_a_prior = sd(prior[, "a"]),
                   a_over_5_none = sum(none[, "a"] > 5), a_over_5_prior = sum(prior[, "a"] > 5),
                   rmse_a_none = rmse(none[, "a"], cf_ref[, "a"]), rmse_a_prior = rmse(prior[, "a"], cf_ref[, "a"]),
                   rmse_b_none = rmse(none[, "b"], cf_ref[, "b"]), rmse_b_prior = rmse(prior[, "b"], cf_ref[, "b"])))
}
one <- compare(1)
round(one$summary, 2)
plot(cf_ref[, "a"], one$none[, "a"], pch = 19, col = "#c2410c", log = "xy",
     ylim = range(c(one$none[, "a"], one$prior[, "a"])),
     xlab = "Slope from the full sample", ylab = "Slope from 300")
points(cf_ref[, "a"], one$prior[, "a"], pch = 19, col = "#2780e3")
abline(0, 1, lty = 2)
legend("topleft", c("No priors", "Priors"), pch = 19, col = c("#c2410c", "#2780e3"), bty = "n")

## ---- repeat-viqt
# One subsample could be lucky. Five more, summarized by the median across them.
many <- sapply(2:6, function(s) compare(s)$summary)
round(apply(many, 1, median), 2)
