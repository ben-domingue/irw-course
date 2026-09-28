# The simulation from the lesson "Dimensionality and multidimensional IRT", repeated
# across correlations between the two dimensions: 5 simulated data sets per
# correlation, each with a fifth of its responses held out. Too slow for the browser
# (35 two-dimensional fits); it runs in about two minutes in local R. Needs mirt.

## ---- sweep
library(mirt)
one_run <- function(rho, np = 500, a = 1.5) {
  d <- rep(seq(-1.5, 1.5, length.out = 5), 2); dim <- rep(1:2, each = 5)
  theta <- matrix(rnorm(np * 2), np) %*% chol(matrix(c(1, rho, rho, 1), 2))
  resp <- (matrix(runif(np * 10), np) < plogis(a * theta[, dim] + rep(d, each = np))) * 1
  colnames(resp) <- paste0("x", 1:10)
  cells <- which(!is.na(resp), arr.ind = TRUE)
  test <- cells[sample(nrow(cells), nrow(cells) / 5), ]
  train <- as.data.frame(resp); train[test] <- NA
  m1 <- mirt(train, 1, itemtype = "2PL", verbose = FALSE)
  m2 <- mirt(train, mirt.model("F1 = 1-5
                                F2 = 6-10
                                COV = F1*F2"), itemtype = "2PL", quadpts = 15, verbose = FALSE)
  pr <- function(m) {
    th <- fscores(m); cf <- coef(m, simplify = TRUE)$items
    A <- cf[, grep("^a", colnames(cf)), drop = FALSE]
    plogis(rowSums(A[test[, 2], , drop = FALSE] * th[test[, 1], , drop = FALSE]) + cf[test[, 2], "d"])
  }
  coin <- function(ll) uniroot(function(w) w * log(w) + (1 - w) * log(1 - w) - ll, c(0.5, 1 - 1e-12))$root
  mll <- function(p) mean(resp[test] * log(p) + (1 - resp[test]) * log(1 - p))
  w1 <- coin(mll(pr(m1))); w2 <- coin(mll(pr(m2)))
  c(imv = (w2 - w1) / w1, dAIC = extract.mirt(m1, "AIC") - extract.mirt(m2, "AIC"))
}
set.seed(4343)
rhos <- c(0, 0.2, 0.4, 0.6, 0.7, 0.8, 0.85)
# Near a correlation of 1 the two-dimensional fit can fail (the estimated covariance
# matrix becomes singular); a failed run is recorded as NA and counted below.
safe_run <- function(r) tryCatch(suppressWarnings(one_run(r)), error = function(e) c(imv = NA, dAIC = NA))
runs <- do.call(rbind, lapply(rhos, function(r) data.frame(rho = r, t(replicate(5, safe_run(r))))))
c(failed_runs = sum(is.na(runs$imv)))
sweep <- aggregate(cbind(imv, dAIC) ~ rho, runs, mean)
sweep$aic_prefers_2d <- aggregate(dAIC ~ rho, runs, function(x) sum(x > 0))$dAIC
print(transform(sweep, imv = round(imv, 4), dAIC = round(dAIC, 1)), row.names = FALSE)
plot(runs$rho, runs$imv, pch = 19, col = "#93c5fd", las = 1,
     xlab = "Correlation between the two dimensions", ylab = "IMV of 2D over 1D (held out)")
lines(sweep$rho, sweep$imv, lwd = 2, col = "#2780e3")
abline(h = 0, lty = 2, col = "#999")
