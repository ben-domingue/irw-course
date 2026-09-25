# Simulate a five-option multiple-choice test from the 3PL (every lower asymptote
# c = 0.2, chance for five options), then fit it three ways: the 2PL, the 3PL with
# nothing but the data, and the 3PL with priors on the slopes and lower asymptotes.
# Compare each with the truth. Adapted from ben-domingue/252: ps4/priors.R.
# Needs the mirt package.
library(mirt)
set.seed(42)
ni <- 20      # items
np <- 300     # respondents (try 3000 in your own R session)
c_true <- 0.2

th <- rnorm(np)                  # true abilities
a  <- exp(rnorm(ni, 0, 0.3))     # true slopes, around 1
b  <- rnorm(ni)                  # true difficulties
pr <- c_true + (1 - c_true) * plogis(sweep(outer(th, b, "-"), 2, a, "*"))
resp <- as.data.frame(matrix(rbinom(np * ni, 1, pr), np, ni))

# Priors, in mirt's syntax: a lognormal on each slope (log a ~ normal(0, 1)) and a
# beta(4, 16) on each lower asymptote (mean 0.2, worth about 20 responses). mirt
# calls the lower asymptote g; in our notation it is c.
spec <- mirt.model(paste0("F = 1-", ni, "\n",
  "PRIOR = (1-", ni, ", a1, lnorm, 0, 1), (1-", ni, ", g, expbeta, 4, 16)"))
fits <- list(`2PL` = mirt(resp, 1, itemtype = "2PL", verbose = FALSE),
             `3PL` = mirt(resp, 1, itemtype = "3PL", verbose = FALSE,
                          technical = list(NCYCLES = 2000)),
             `3PL + priors` = mirt(resp, spec, itemtype = "3PL", verbose = FALSE,
                                   technical = list(NCYCLES = 2000)))

# IRTpars = TRUE reports b = -d/a directly, alongside a and g (our c).
est <- lapply(fits, function(m) coef(m, simplify = TRUE, IRTpars = TRUE)$items)
rmse <- function(x, y) sqrt(mean((x - y)^2))
tab <- t(sapply(est, function(e) c(
  rmse_a = rmse(e[, "a"], a), rmse_b = rmse(e[, "b"], b), rmse_c = rmse(e[, "g"], c_true),
  largest_a = max(e[, "a"]), median_c = median(e[, "g"]))))
theta <- sapply(fits, function(m) fscores(m)[, 1])
print(round(cbind(tab, cor_theta_truth = cor(theta, th)[, 1]), 2))

# Each item's slope, estimated three ways, against the truth
plot(a, est$`3PL`[, "a"], pch = 19, col = "#c2410c", log = "xy",
     xlab = "True slope a", ylab = "Estimated slope",
     ylim = range(c(a, sapply(est, function(e) e[, "a"]))))
points(a, est$`3PL + priors`[, "a"], pch = 19, col = "#2780e3")
points(a, est$`2PL`[, "a"], pch = 1)
abline(0, 1, lty = 2)
legend("topleft", c("3PL", "3PL + priors", "2PL"), pch = c(19, 19, 1),
       col = c("#c2410c", "#2780e3", "black"), bty = "n")
