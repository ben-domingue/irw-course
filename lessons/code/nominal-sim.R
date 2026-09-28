# Simulate multiple-choice responses from the nominal response model: 20 four-option
# items, each with one distractor that draws respondents with partial knowledge.
# Fit the 2PL to the 0/1 scores and the nominal model to the options chosen, and
# compare how well each recovers theta, overall and at the low end. Needs mirt.
library(mirt)
set.seed(80)
np <- 1000                     # respondents (try 300, or 5000 locally)
ni <- 20                       # items, each with options 1-4; option 4 is the key
theta <- rnorm(np)
# Option slopes: two distractors fall with theta (-1), the partial-knowledge one
# is flat (0), the key rises (1). Try setting the partial-knowledge slope to -1:
# then every distractor is alike and the options add nothing.
partial <- 0
slopes <- outer(runif(ni, 0.8, 1.6), c(-1, -1, partial, 1))
ints <- cbind(0, runif(ni, -1, 0), runif(ni, 0, 1), runif(ni, -0.5, 1.5))
nominal_probs <- function(th, a, d) { z <- exp(a * th + d); z / sum(z) }
resp <- sapply(1:ni, function(i) sapply(theta, function(t)
  sample(1:4, 1, prob = nominal_probs(t, slopes[i, ], ints[i, ]))))
colnames(resp) <- paste0("item", 1:ni)
x01 <- as.data.frame(1 * (resp == 4))
resp <- as.data.frame(resp)

fit_2pl <- mirt(x01, 1, itemtype = "2PL", verbose = FALSE)
fit_nom <- mirt(resp, 1, itemtype = "nominal", verbose = FALSE)
th_2pl <- fscores(fit_2pl)[, 1]
th_nom <- fscores(fit_nom)[, 1]
low <- theta < quantile(theta, 1/3)   # the bottom third of true theta
rmse <- function(est, keep) sqrt(mean((est[keep] - theta[keep])^2))
res <- rbind(
  "2PL (0/1)"         = c(cor_all = cor(th_2pl, theta), cor_bottom_third = cor(th_2pl[low], theta[low]),
                          rmse_bottom_third = rmse(th_2pl, low), rmse_top_third = rmse(th_2pl, theta > quantile(theta, 2/3))),
  "nominal (options)" = c(cor(th_nom, theta), cor(th_nom[low], theta[low]),
                          rmse(th_nom, low), rmse(th_nom, theta > quantile(theta, 2/3))))
print(round(res, 3))

# Test information from each fit.
at <- matrix(c(-2, -1, 0, 1, 2))
print(round(data.frame(theta = at[, 1], nominal = testinfo(fit_nom, at), two_pl = testinfo(fit_2pl, at)), 1))

# True and estimated option slopes for item 1 (the estimate is on mirt's scale:
# a1 times the scoring values ak, with option 1 as the reference at 0).
cf <- coef(fit_nom, simplify = TRUE)$items[1, ]
print(round(rbind(true = slopes[1, ] - slopes[1, 1], estimated = cf["a1"] * cf[paste0("ak", 0:3)]), 2))
