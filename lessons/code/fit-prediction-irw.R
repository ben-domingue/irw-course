# Model fit and out-of-sample prediction with real data: gilbert_meta_2 (a reading
# comprehension test from a randomized trial) and gilbert_meta_14 (a mathematics test
# from another trial) from the Item Response Warehouse. Runs as-is in R with the mirt
# package; no login or token. The cross-validation chunks refit each model five times
# and take a few minutes in all.
# Adapted from ben-domingue/252: ps3/fit.R (PS3#3) and ps4/prediction.R (PS4#2).

## ---- fetch-gm2
library(mirt)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/) with
# a CSV download. This link is pinned to one version of the data.
gm2_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0.gilbert_meta_2/rows?format=csv"
df2 <- read.csv(gm2_url)
# resp is 1 for a correct answer. One response per student per item; no waves.
c(responses = nrow(df2), students = length(unique(df2$id)), items = length(unique(df2$item)),
  missing = sum(is.na(df2$resp)))

# IRW tables are long (one row per response); mirt wants wide (one row per respondent).
long2wide <- function(df) {
  wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  ord <- order(as.numeric(gsub("\\D", "", colnames(wide))), colnames(wide))
  as.data.frame(wide[, ord])
}
resp2 <- long2wide(df2)
names(resp2) <- paste0("item", names(resp2))
round(range(colMeans(resp2)), 2)   # proportion correct: hardest and easiest items

## ---- outfit-gm2
set.seed(252)
rasch2 <- mirt(resp2, 1, itemtype = "Rasch", verbose = FALSE)
fit2 <- itemfit(rasch2, fit_stats = "infit")   # outfit and infit, with z statistics
# How much would outfit vary if the Rasch model were true? For one response,
# z^2 = (x - p)^2 / (p(1 - p)) has variance 1/(p(1 - p)) - 4 (see the Go deeper
# callout), so an item's outfit, the mean of n of them, has the SD below. We plug in
# the fitted model's probabilities. sqrt(2/n) is the familiar rough version.
theta <- fscores(rasch2)[, 1]
b <- -coef(rasch2, simplify = TRUE)$items[, "d"]   # mirt's d is an easiness: b = -d
P <- plogis(outer(theta, b, "-"))
null_sd <- sqrt(colSums(1 / (P * (1 - P)) - 4)) / nrow(resp2)
# itemfit() computes residuals from EAP abilities by default; method = "ML" uses each
# respondent's maximum-likelihood ability instead (the 20 students with 0 or 20
# correct have none and drop out).
fit2_ml <- itemfit(rasch2, fit_stats = "infit", method = "ML")
out <- data.frame(item = fit2$item, p = round(colMeans(resp2), 2), outfit = round(fit2$outfit, 2),
                  z = round(fit2$z.outfit, 1), null_sd = round(null_sd, 3),
                  outfit_ML = round(fit2_ml$outfit, 2), z_ML = round(fit2_ml$z.outfit, 1))
out[order(out$outfit), ]
round(c(rough_null_sd = sqrt(2 / nrow(resp2)), observed_sd_of_outfit = sd(fit2$outfit),
        median_outfit = median(fit2$outfit), median_outfit_ML = median(fit2_ml$outfit)), 3)
# How many items misfit by z, and how many sit inside 0.8-1.2?
c(below_1 = sum(fit2$outfit < 1), abs_z_over_2 = sum(abs(fit2$z.outfit) > 2),
  inside_0.8_1.2 = sum(fit2$outfit >= 0.8 & fit2$outfit <= 1.2),
  inside_0.8_1.2_ML = sum(fit2_ml$outfit >= 0.8 & fit2_ml$outfit <= 1.2))

## ---- slopes-gm2
twopl2 <- mirt(resp2, 1, itemtype = "2PL", verbose = FALSE)
a2 <- coef(twopl2, simplify = TRUE)$items[, "a1"]
# The three most overfitting items, and the range of 2PL slopes
round(a2[order(fit2$outfit)[1:3]], 2)
round(range(a2), 2)
round(cor(a2, fit2$outfit, method = "spearman"), 2)   # slope against outfit

## ---- global-gm2
threepl2 <- mirt(resp2, 1, itemtype = "3PL", verbose = FALSE)
# Likelihood-ratio tests, AIC and BIC for nested models (smaller AIC/BIC is better).
anova(rasch2, twopl2)
anova(twopl2, threepl2)
c(threepl_converged = extract.mirt(threepl2, "converged"))
# Limited-information fit of the whole model: M2 and its RMSEA.
rbind(Rasch = M2(rasch2), `2PL` = M2(twopl2))[, c("M2", "df", "p", "RMSEA")]

## ---- andersen-gm2
# Andersen's (1973) likelihood-ratio test, from conditional maximum likelihood.
# esf() gives the elementary symmetric functions gamma_0, ..., gamma_I of the item
# easinesses exp(-b); cml() maximizes the conditional likelihood of the patterns
# given the sum scores (difficulties sum to 0), dropping sum scores of 0 and I,
# which carry no information about the items.
esf <- function(eps) {
  g <- 1
  for (e in eps) g <- c(g, 0) + c(0, g) * e
  g
}
cml <- function(X) {
  X <- as.matrix(X); I <- ncol(X); r <- rowSums(X)
  X <- X[r > 0 & r < I, , drop = FALSE]; r <- rowSums(X)
  s <- colSums(X); n_r <- tabulate(r, I - 1)
  negll <- function(par) {
    b <- c(par, -sum(par))
    sum(s * b) + sum(n_r * log(esf(exp(-b))[2:I]))
  }
  o <- optim(rep(0, I - 1), negll, method = "BFGS", control = list(maxit = 1000, reltol = 1e-12))
  list(b = c(o$par, -sum(o$par)), loglik = -o$value, n = nrow(X))
}
# Split respondents at the median sum score, estimate the difficulties separately in
# each half, and compare with one set of difficulties for everyone.
r2 <- rowSums(resp2)
high <- r2 > median(r2)
full <- cml(resp2); lo <- cml(resp2[!high, ]); hi <- cml(resp2[high, ])
LR <- 2 * (lo$loglik + hi$loglik - full$loglik)
df_LR <- ncol(resp2) - 1
c(LR = round(LR, 1), df = df_LR, p = signif(pchisq(LR, df_LR, lower.tail = FALSE), 2))
# Difficulty among high scorers minus difficulty among low scorers, by item
round(sort(setNames(hi$b - lo$b, names(resp2))), 2)

## ---- imv-functions
# The IMV (Domingue et al., 2024, 2025). coin() turns a mean log likelihood into the
# weight w >= 0.5 of a coin with the same expected log likelihood per toss;
# imv() is the expected return, (w1 - w0) / w0, on a bet placed with the better coin.
coin <- function(ll) {
  if (ll <= log(0.5)) return(0.5)
  uniroot(function(w) w * log(w) + (1 - w) * log(1 - w) - ll, c(0.5, 1 - 1e-12), tol = 1e-12)$root
}
mean_ll <- function(y, p) mean(y * log(p) + (1 - y) * log(1 - p))
imv <- function(y, p0, p1) {
  w0 <- coin(mean_ll(y, p0)); w1 <- coin(mean_ll(y, p1))
  (w1 - w0) / w0
}
# Predicted probabilities for the cells cells[, 1:2] (row, column) from a fitted model:
# mirt's form g + (u - g) * logistic(a * theta + d), with EAP abilities.
predict_cells <- function(m, cells) {
  th <- fscores(m)[, 1]
  # A respondent whose every response was held out has no ability estimate; the
  # prior mean, 0, is what EAP gives with no data.
  th[is.na(th)] <- 0
  cf <- coef(m, simplify = TRUE)$items
  i <- cells[, 2]
  cf[i, "g"] + (cf[i, "u"] - cf[i, "g"]) * plogis(cf[i, "a1"] * th[cells[, 1]] + cf[i, "d"])
}
# k-fold cross-validation over responses: each response goes into one of k folds.
# For each fold, blank out its responses, fit every model to the rest, and predict
# the blanked-out responses. Each respondent and item keeps most of its responses,
# so every held-out response has an ability and an item to be predicted from.
cv_predict <- function(resp, models, k = 5, seed = 1) {
  set.seed(seed)
  X <- as.matrix(resp)
  cells <- which(!is.na(X), arr.ind = TRUE)
  fold <- sample(rep(1:k, length.out = nrow(cells)))
  do.call(rbind, lapply(1:k, function(f) {
    test <- cells[fold == f, , drop = FALSE]
    train <- X; train[test] <- NA
    preds <- sapply(models, function(m)
      predict_cells(mirt(as.data.frame(train), 1, itemtype = m, verbose = FALSE), test))
    data.frame(fold = f, item = test[, 2], y = X[test],
               p_value = colMeans(train, na.rm = TRUE)[test[, 2]], preds, check.names = FALSE)
  }))
}
# The IMV of each model over the one before it, fold by fold, then averaged.
imv_table <- function(pred, models) {
  base <- c("p_value", models)
  res <- sapply(split(pred, pred$fold), function(d)
    sapply(2:length(base), function(j) imv(d$y, d[[base[j - 1]]], d[[base[j]]])))
  res <- matrix(res, nrow = length(base) - 1)
  data.frame(comparison = paste(base[-length(base)], "->", base[-1]), IMV = round(rowMeans(res), 4))
}

## ---- cv-gm2
models <- c("Rasch", "2PL", "3PL")
pred2 <- cv_predict(resp2, models)
imv_table(pred2, models)
# The RMSE of the same predictions barely moves:
round(sapply(pred2[, models], function(p) sqrt(mean((pred2$y - p)^2))), 3)

## ---- insample-gm2
# The same comparisons in-sample: predict the responses the models were fitted to.
cells <- which(!is.na(as.matrix(resp2)), arr.ind = TRUE)
ins <- data.frame(fold = 1, item = cells[, 2], y = as.matrix(resp2)[cells],
                  p_value = colMeans(resp2)[cells[, 2]],
                  Rasch = predict_cells(rasch2, cells), `2PL` = predict_cells(twopl2, cells),
                  `3PL` = predict_cells(threepl2, cells), check.names = FALSE)
imv_table(ins, models)

## ---- fetch-gm14
gm14_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0.gilbert_meta_14/rows?format=csv"
df14 <- read.csv(gm14_url)
# Two waves: 0 is the baseline test, 1 a later one, with partly different items
# under shared codes. We keep the baseline only.
table(wave = df14$wave)
df14 <- df14[df14$wave == 0, ]
resp14 <- long2wide(df14)
c(students = nrow(resp14), items = ncol(resp14), missing = sum(is.na(resp14)))
p14 <- colMeans(resp14)
round(range(p14), 3)
c(items_below_0.1 = sum(p14 < 0.1), items_between_0.2_and_0.8 = sum(p14 > 0.2 & p14 < 0.8))

## ---- slopes-gm14
twopl14 <- mirt(resp14, 1, itemtype = "2PL", verbose = FALSE)
a14 <- coef(twopl14, simplify = TRUE)$items[, "a1"]
round(range(a14), 2)
round(c(sd_log_a_gm14 = sd(log(a14)), sd_log_a_gm2 = sd(log(a2))), 2)

## ---- cv-gm14
models14 <- c("Rasch", "2PL")
pred14 <- cv_predict(resp14, models14)
imv_table(pred14, models14)
# Where is there anything left to predict? The IMV of the 2PL over the Rasch model
# among held-out responses to items most students miss, and to the rest.
hard <- p14[pred14$item] < 0.1
round(c(items_below_0.1 = imv(pred14$y[hard], pred14$Rasch[hard], pred14$`2PL`[hard]),
        other_items = imv(pred14$y[!hard], pred14$Rasch[!hard], pred14$`2PL`[!hard])), 4)
