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

## ---- fetch-viqt
viqt_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.vocabulary_iq/rows?format=csv"
viqt <- read.csv(viqt_url)
# Items 1-45 are the vocabulary questions (pick the two words of five that mean
# the same). Items 46-75 are an optional personality survey bundled into the same
# table, which we drop. resp is 1 for the correct pair and 0 for a wrong pair or no
# answer; choosing "don't know" is missing. No waves.
viqt <- viqt[viqt$item <= 45, ]
round(c(correct = mean(viqt$resp == 1, na.rm = TRUE), dont_know = mean(is.na(viqt$resp))), 3)
resp_all <- long2wide(viqt)
resp_all <- resp_all[, order(as.numeric(colnames(resp_all)))]
names(resp_all) <- paste0("Q", names(resp_all))
# We keep the respondents who never chose "don't know", so every response is an answer.
resp_viqt <- resp_all[complete.cases(resp_all), ]
c(respondents = nrow(resp_all), answered_every_item = nrow(resp_viqt))
round(quantile(colMeans(resp_viqt), c(0, 0.25, 0.5, 0.75, 1)), 2)   # proportion correct by item

## ---- full-viqt
# The 3PL on all 2,802, as a reference, without priors and with them. Priors in
# mirt's syntax: log a ~ normal(0, 1), and c ~ beta(2, 18), with mean 0.1 (ten
# possible pairs, so chance is one in ten) and worth about 20 responses.
ni <- ncol(resp_viqt)
spec <- mirt.model(paste0("F = 1-", ni, "\n",
  "PRIOR = (1-", ni, ", a1, lnorm, 0, 1), (1-", ni, ", g, expbeta, 2, 18)"))
set.seed(252)
ref <- mirt(resp_viqt, 1, itemtype = "3PL", verbose = FALSE, technical = list(NCYCLES = 5000))
ref_prior <- mirt(resp_viqt, spec, itemtype = "3PL", verbose = FALSE, technical = list(NCYCLES = 5000))
cf_ref <- coef(ref, simplify = TRUE, IRTpars = TRUE)$items         # a, b, g (our c)
cf_ref_prior <- coef(ref_prior, simplify = TRUE, IRTpars = TRUE)$items
round(rbind(c_no_prior = quantile(cf_ref[, "g"], c(0, 0.5, 1)),
            c_with_prior = quantile(cf_ref_prior[, "g"], c(0, 0.5, 1)),
            a_no_prior = quantile(cf_ref[, "a"], c(0, 0.5, 1))), 3)

## ---- sub-viqt
# Now pretend we had only 300 respondents. Fit the 3PL to a random 300, without
# and with the priors, and compare each with the full-sample reference.
rmse <- function(x, y) sqrt(mean((x - y)^2))
compare <- function(seed) {
  set.seed(seed)
  sub <- resp_viqt[sample(nrow(resp_viqt), 300), ]
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
     xlab = "Slope from all 2,802 respondents", ylab = "Slope from 300")
points(cf_ref[, "a"], one$prior[, "a"], pch = 19, col = "#2780e3")
abline(0, 1, lty = 2)
legend("topleft", c("No priors", "Priors"), pch = 19, col = c("#c2410c", "#2780e3"), bty = "n")

## ---- repeat-viqt
# One subsample could be lucky. Five more, summarized by the median across them.
many <- sapply(2:6, function(s) compare(s)$summary)
round(apply(many, 1, median), 2)
