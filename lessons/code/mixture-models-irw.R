# Mixture models with real data: kay_2025_antonyms (a survey of antonym pairs given on
# three online platforms), su_2024_pss14 and su_2024_phq9 (a stress scale and a
# depression scale answered by the same students, with response times), and
# test_taking_much_2025_mr (a matrix reasoning test with response times), from the
# Item Response Warehouse. Runs as-is in R with mirt and psych; no login or token.
# The whole file takes about five minutes. Two slower analyses (held-out
# comparisons on the Kay data and mixed partial credit models on the stress scale)
# are in code/mixture-models-precompute.R and code/mixture-models-pcm.R.

## ---- fetch-kay
library(mirt)
long2wide <- function(df) as.data.frame(tapply(df$resp, list(df$id, df$item), function(x) x[1]))
kay_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_5:v5_0.kay_2025_antonyms/rows?format=csv"
kay <- read.csv(kay_url)
# resp is the raw rating from -3 (strongly disagree) to +3 (strongly agree). Items
# come in pairs; the _x/_r suffix only marks the first and second member of a pair,
# not the direction of any trait, so we key items from their wording. No waves.
W <- long2wide(kay)
person <- kay[!duplicated(kay$id), ]
person <- person[match(rownames(W), person$id), ]
platform <- ifelse(grepl("MTurk", person$cov_source), "MTurk", "Connect/Prolific")
checks_failed <- person$cov_att_chk        # instructed-response items failed, of 4
table(source = person$cov_source, checks_failed)
# The last pair: "I am an extravert" / "I am an introvert". Their raw correlation:
pair_r <- function(ix) round(cor(W$extr_057_x[ix], W$extr_058_r[ix]), 2)
c(connect_prolific = pair_r(platform != "MTurk"),
  mturk_failed_at_most_one = pair_r(platform == "MTurk" & checks_failed <= 1))

# Ten extraversion items, five worded each way. Agreeing (slightly or more) with a
# forward item, or not agreeing with a reversed one, scores 1: higher = more
# extraverted.
forward  <- c("tlk1_001_x", "tlk2_003_x", "cntr_006_r", "frnd_031_x", "extr_057_x")
reversed <- c("tlk1_002_r", "tlk2_004_r", "cntr_005_x", "frnd_032_r", "extr_058_r")
agree <- (W[, c(forward, reversed)] >= 1) * 1
X <- cbind(agree[, forward], 1 - agree[, reversed])
colnames(X) <- c(paste0("F", 1:5), paste0("R", 1:5))
round(colMeans(X), 2)
# In the whole sample, the average correlation of a keyed forward item with a keyed
# reversed one (they should correlate positively):
round(mean(cor(X)[1:5, 6:10]), 2)

## ---- fit-kay
# One class (the Rasch model), then two and three classes, each with its own item
# difficulties, mean and variance of theta, and a share pi_k. mirt fits mixtures
# with multipleGroup(..., dentype = "mixture-K"). Each fit starts from random values;
# code/mixture-models-precompute.R refits from ten starts and always reaches the
# same maximum. About a minute and a half.
set.seed(1)
kay1 <- mirt(X, 1, itemtype = "Rasch", verbose = FALSE)
kay2 <- multipleGroup(X, 1, itemtype = "Rasch", dentype = "mixture-2", verbose = FALSE,
                      technical = list(NCYCLES = 3000))
kay3 <- multipleGroup(X, 1, itemtype = "Rasch", dentype = "mixture-3", verbose = FALSE,
                      technical = list(NCYCLES = 3000))
fits <- list(one = kay1, two = kay2, three = kay3)
data.frame(classes = 1:3,
           logLik = round(sapply(fits, extract.mirt, "logLik")),
           parameters = sapply(fits, extract.mirt, "nest"),
           BIC = round(sapply(fits, extract.mirt, "BIC")))
# The two classes' profiles. mirt's d is an easiness, so b = -d. Which class is
# "first" depends on the start (label switching), so we name them by profile: the
# class whose theta barely varies is the one in which content doesn't matter.
cf <- coef(kay2, simplify = TRUE)
theta_var <- sapply(cf, function(g) g$cov[1, 1])
cfree <- which.min(theta_var)
profiles <- sapply(cf, function(g) -g$items[, "d"])
colnames(profiles) <- ifelse(seq_along(cf) == cfree, "content_free", "engaged")
round(profiles, 1)
round(c(share_content_free = unname(extract.mirt(kay2, "pis")[cfree]),
        theta_var_content_free = unname(theta_var[cfree]), theta_var_engaged = unname(theta_var[-cfree])), 3)
post <- fscores(kay2, method = "classify", verbose = FALSE)
p_cf <- post[, grep("^CLASS", colnames(post))][, cfree]   # posterior of the content-free class
in_cf <- p_cf > 0.5
c(assigned = sum(in_cf), share_sure = round(mean(p_cf > 0.9 | p_cf < 0.1), 2))

## ---- check-kay
# Outside evidence the model never saw. By platform:
table(platform, content_free = in_cf)
# By instructed-response items passed (all four) or not:
round(prop.table(table(passed_all_four = checks_failed == 0, content_free = in_cf), 1), 2)
round(tapply(in_cf[checks_failed == 0], platform[checks_failed == 0], mean), 2)
# Agreement (slightly or more) with either gibberish item ("I am ffhjhl", "I am sqnmmp"):
gibberish <- W$gibb_045_x >= 1 | W$gibb_046_r >= 1
round(tapply(gibberish, ifelse(in_cf, "content_free", "engaged"), mean), 2)
# The raw correlation of each antonym pair outside the scale (leaving out the
# extraversion pairs, the gibberish pair, and three pairs that aren't opposites:
# blue, pets, sick), within each class. Opposites should correlate negatively.
pairs <- setdiff(unique(sub("_\\d+_[xr]$", "", names(W))),
                 c("tlk1", "tlk2", "cntr", "frnd", "extr", "gibb", "blue", "pets", "sick"))
pair_cor <- sapply(pairs, function(p) {
  cols <- grep(paste0("^", p, "_"), names(W))
  c(content_free = cor(W[in_cf, cols[1]], W[in_cf, cols[2]]),
    engaged = cor(W[!in_cf, cols[1]], W[!in_cf, cols[2]]))
})
c(pairs = length(pairs), round(apply(pair_cor, 1, median), 2))
# The keyed sum score in each class:
round(tapply(rowSums(X), ifelse(in_cf, "content_free", "engaged"), mean), 2)

## ---- cv-kay
# Held-out responses (five folds over responses): the IMV of each model over another,
# from code/mixture-models-precompute.R (about 15 minutes), with BIC for four classes.
kay_cv <- read.csv("data/mixture-models-kay.csv")
print(format(kay_cv[, c("comparison", "value")], scientific = FALSE, drop0trailing = TRUE), right = FALSE)

## ---- fetch-su
# Su et al. (2024): a mental-health screening of students at a medical university,
# with a response time (seconds) for every item. Items were given in a fixed order.
su_pss <- read.csv("https://redivis.com/api/v1/tables/datapages.item_response_warehouse_5:v5_0.su_2024_pss14/rows?format=csv")
su_phq <- read.csv("https://redivis.com/api/v1/tables/datapages.item_response_warehouse_5:v5_0.su_2024_phq9/rows?format=csv")
wide <- function(df, v) {
  num <- as.integer(sub(".*_", "", df$item))
  m <- tapply(df[[v]], list(df$id, num), function(x) x[1])
  m[order(as.numeric(rownames(m))), ]
}
P  <- wide(su_pss, "resp"); PT <- wide(su_pss, "rt")
Q  <- wide(su_phq, "resp"); QT <- wide(su_phq, "rt")
Q  <- Q[rownames(P), ]; QT <- QT[rownames(P), ]
c(respondents = nrow(P), complete = sum(complete.cases(P)), phq_matched = sum(complete.cases(Q)))
# PSS codes are 1-5 and arrive already keyed (higher = more stress): the deposit's
# total equals the sum of (code - 1) for every respondent. The seven positively
# worded items are 4, 5, 6, 7, 9, 10 and 13. PHQ-9 codes are 0-3, all worded forward.
positive <- c(4, 5, 6, 7, 9, 10, 13)
# Each respondent's median time per item on the PSS:
med_t <- apply(PT, 1, median)
round(quantile(med_t, c(0.1, 0.17, 0.25, 0.5, 0.75)), 2)
fast <- med_t < 1
c(fast = sum(fast), share = round(mean(fast), 2))

## ---- fast-su
# The most common pattern in the fast group, in keyed codes:
pattern <- apply(P, 1, paste, collapse = "")
top <- names(sort(table(pattern[fast]), decreasing = TRUE))[1]
c(pattern = top, share_of_fast = round(mean(pattern[fast] == top), 2),
  keyed_score = sum(as.integer(strsplit(top, "")[[1]]) - 1))
# Un-keying the positive items gives what was clicked: the same option on every screen.
screen <- P; screen[, positive] <- 6 - screen[, positive]
screen[which(pattern == top)[1], ]
alpha <- function(M) psych::alpha(M, check.keys = FALSE, warnings = FALSE)$total$raw_alpha
# Alpha of each scale among fast and slower respondents, and all together:
round(rbind(PSS_balanced = c(fast = alpha(P[fast, ]), slower = alpha(P[!fast, ]), all = alpha(P)),
            PHQ9_forward = c(fast = alpha(Q[fast, ]), slower = alpha(Q[!fast, ]), all = alpha(Q))), 2)
# The fast group on the PHQ-9: all nine answered "not at all" (0)?
round(tapply(rowSums(Q) == 0, ifelse(fast, "fast", "slower"), mean), 2)
# The PSS's largest eigenvalues, with and without the fast group:
round(rbind(everyone = eigen(cor(P))$values[1:3],
            without_fast = eigen(cor(P[!fast, ]))$values[1:3]), 1)
# Respondents who are fast on one scale are fast on the other:
round(cor(log(med_t), log(apply(QT, 1, median))), 2)

## ---- screens-su
# Five person-level screens on a random 5,000, each flagging its worst 5%.
set.seed(5)
ix <- sample(nrow(P), 5000)
Ps <- P[ix, ]; Ss <- screen[ix, ]; ts <- med_t[ix]
long_string <- apply(Ss, 1, function(r) max(rle(r)$lengths))   # in the order shown
person_sd   <- apply(Ss, 1, sd)
# Inconsistency: split each subscale's items into alternate halves and add the
# absolute differences between the halves' means.
stress <- setdiff(1:14, positive)
halves <- function(r, s) abs(mean(r[s[c(TRUE, FALSE)]]) - mean(r[s[c(FALSE, TRUE)]]))
even_odd <- apply(Ps, 1, function(r) halves(r, stress) + halves(r, positive))
mahal <- mahalanobis(Ps, colMeans(Ps), cov(Ps))
# Person fit: Z_h (l_z) under a graded response model, at EAP estimates.
grm <- mirt(as.data.frame(Ps - 1), 1, itemtype = "graded", verbose = FALSE)
zh <- personfit(grm)$Zh
flags <- data.frame(speed = ts <= quantile(ts, 0.05),
                    long_string = long_string >= quantile(long_string, 0.95),
                    even_odd = even_odd >= quantile(even_odd, 0.95),
                    mahalanobis = mahal >= quantile(mahal, 0.95),
                    Zh = zh <= quantile(zh, 0.05))
# How many respondents each pair of screens both flag (the diagonal: each screen's
# own count; ties at the cut let some screens flag more than 5%):
crossprod(as.matrix(flags) * 1)
round(cor(data.frame(slowness = log(ts), long_string, even_odd, mahal, minus_Zh = -zh),
          method = "spearman"), 2)
# Respondents who gave one option on every screen, against everyone:
round(c(all_same_n = sum(person_sd == 0), all_same_Zh = median(zh[person_sd == 0]),
        everyone_Zh = median(zh)), 2)

## ---- pcm-su
# Mixed partial credit models (1-3 classes) on two samples of 2,000 PSS
# respondents, from code/mixture-models-pcm.R (about 20 minutes). ends = share of
# responses in the two end categories, middle = in the middle one; mean_sum is the
# keyed sum (0-56); median_rt in seconds per item.
pcm <- read.csv("data/mixture-models-pcm.csv")
fits <- unique(pcm[, c("sample", "K", "logLik", "npar", "BIC")])
fits[, c("logLik", "BIC")] <- round(fits[, c("logLik", "BIC")])
fits
# Each class: its share, how it uses the five categories (0 = least stress), and more.
cbind(pcm[pcm$K > 1, c("sample", "K", "class")],
      round(pcm[pcm$K > 1, c("share", "cat0", "cat1", "cat2", "cat3", "cat4", "ends",
                             "mean_sum", "alpha", "median_rt")], 2))

## ---- much
# Much et al. (2025): 20 constructed-response matrix items (1 = correct), with
# times in seconds. Items Y_MRm01 and Y_MRt01-06 are practice items, dropped.
much <- read.csv("https://redivis.com/api/v1/tables/datapages.item_response_warehouse_2:v25_0.test_taking_much_2025_mr/rows?format=csv")
much <- much[grepl("^Y_MR[0-9]", much$item), ]
M  <- as.matrix(long2wide(much))
ML <- log(tapply(much$rt, list(much$id, much$item), function(x) x[1]))[rownames(M), colnames(M)]
info <- much[!duplicated(much$id), ]; info <- info[match(rownames(M), info$id), ]
score <- rowSums(M, na.rm = TRUE)
c(respondents = nrow(M), score_zero = sum(score == 0))
mean_logt <- rowMeans(ML, na.rm = TRUE)   # each respondent's mean log time per item

# Two classes: engaged respondents follow the Rasch model (theta ~ normal(0, s^2));
# disengaged respondents answer every item correctly with one common probability g.
# With use_time = TRUE each class also has its own normal distribution of mean log
# time. EM on a grid of abilities, extending fit_mixture() from the lesson on
# guessing and priors. A few seconds.
fit_rt_mixture <- function(X, logt, use_time, Q = 41, maxit = 2000, tol = 1e-7) {
  pl <- function(x) pmin(pmax(plogis(x), 1e-10), 1 - 1e-10)
  obs <- !is.na(X); X0 <- ifelse(obs, X, 0)
  z <- seq(-5, 5, length.out = Q); wz <- dnorm(z) / sum(dnorm(z))
  b <- -qlogis(pmin(pmax(colMeans(X, na.rm = TRUE), 0.01), 0.99)); s <- 1; pi <- 0.8; g <- 0.05
  mu <- c(mean(logt), mean(logt) - 0.5); sdv <- c(sd(logt), sd(logt)); old <- -Inf
  for (it in 1:maxit) {
    P <- pl(outer(s * z, b, "-"))
    a <- X0 %*% t(log(P)) + (obs * (1 - X0)) %*% t(log(1 - P)) + rep(log(wz), each = nrow(X))
    mx <- apply(a, 1, max); llR <- mx + log(rowSums(exp(a - mx))); llE <- llR
    llD <- rowSums(X0) * log(g) + rowSums(obs * (1 - X0)) * log(1 - g)
    if (use_time) {
      llE <- llE + dnorm(logt, mu[1], sdv[1], log = TRUE)
      llD <- llD + dnorm(logt, mu[2], sdv[2], log = TRUE)
    }
    both <- cbind(log(pi) + llE, log(1 - pi) + llD)
    mm <- apply(both, 1, max); lli <- mm + log(rowSums(exp(both - mm))); ll <- sum(lli)
    pE <- exp(both[, 1] - lli); pD <- 1 - pE
    Wt <- exp(a - llR) * pE                     # posterior over the grid, engaged class
    nq <- t(Wt) %*% obs; r <- t(Wt) %*% X0
    pi <- mean(pE); g <- sum(pD * rowSums(X0)) / sum(pD * rowSums(obs))
    for (k in 1:5) {
      P <- pl(outer(s * z, b, "-"))
      b <- b + pmax(pmin(colSums(nq * P - r) / colSums(nq * P * (1 - P)), 1), -1)
    }
    s <- exp(optimize(function(ls) { P <- pl(outer(exp(ls) * z, b, "-"))
      -sum(r * log(P) + (nq - r) * log(1 - P)) }, c(-2, 1.5))$minimum)
    if (use_time) {
      mu  <- c(sum(pE * logt) / sum(pE), sum(pD * logt) / sum(pD))
      sdv <- sqrt(c(sum(pE * (logt - mu[1])^2) / sum(pE), sum(pD * (logt - mu[2])^2) / sum(pD)))
    }
    if (abs(ll - old) < tol) break
    old <- ll
  }
  list(pi = pi, g = g, p_disengaged = pD, seconds = exp(mu), loglik = ll)
}
resp_only <- fit_rt_mixture(M, mean_logt, use_time = FALSE)
with_time <- fit_rt_mixture(M, mean_logt, use_time = TRUE)
d0 <- resp_only$p_disengaged > 0.5; d1 <- with_time$p_disengaged > 0.5
round(rbind(responses_only = c(pi = resp_only$pi, g = resp_only$g, n_disengaged = sum(d0)),
            with_times = c(pi = with_time$pi, g = with_time$g, n_disengaged = sum(d1))), 3)
table(score_zero = score == 0, disengaged_with_times = d1)
# Median seconds per item in each class (with times):
round(tapply(exp(mean_logt), ifelse(d1, "disengaged", "engaged"), median))
# Outside evidence: self-reported lack of understanding, and attention checks passed.
no_understanding <- grepl("lack of understanding", info$cov_disruptions)
round(tapply(no_understanding, ifelse(d1, "disengaged", "engaged"), mean), 2)
round(tapply(d1, info$cov_ac, mean), 2)
