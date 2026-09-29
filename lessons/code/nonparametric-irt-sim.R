# Mokken scaling on simulated data: ten items from the 2PL, whose curves rise but
# cross, and one item whose curve rises and then falls. Loevinger's H, automated
# item selection, the rest-score check of monotonicity and the check of invariant
# item ordering come from the mokken package (van der Ark, 2007, 2012); the kernel
# smoother is written out by hand (Ramsay, 1991). Runs in a few seconds.
library(mokken)
set.seed(252)

n <- 1000                               # respondents
a <- seq(0.5, 2.5, length.out = 10)     # slopes; try a <- rep(1, 10) (Rasch)
b <- seq(-1.5, 1.5, length.out = 10)    # difficulties
theta <- rnorm(n)
P <- plogis(sweep(outer(theta, b, "-"), 2, a, "*"))
X <- matrix(rbinom(n * 10, 1, P), n, 10, dimnames = list(NULL, paste0("i", 1:10)))
# An eleventh item whose curve peaks at theta = 0.3 and falls on either side
p_bump <- 0.1 + 0.8 * exp(-(theta - 0.3)^2 / (2 * 0.7^2))
X <- cbind(X, bump = rbinom(n, 1, p_bump))

# Scalability: H for each item and for the scale
H <- coefH(X, se = FALSE, results = FALSE)
round(H$Hi, 2)
round(H$H, 2)

# Automated item selection at the lower bound c = 0.3 (0 = left out)
aisp(X, lowerbound = 0.3, verbose = FALSE)[, 1]

# Monotonicity in rest-score groups: #vi violations, #zsig significant ones
summary(check.monotonicity(X))[, c("ItemH", "#ac", "#vi", "maxvi", "#zsig")]

# Invariant item ordering among the ten 2PL items: which items the backward
# selection removes, and H^T for the items that remain
iio <- check.iio(X[, 1:10])
names(iio$items.removed)
round(iio$HT, 2)

# Kernel-smoothed item curves (Nadaraya-Watson, Gaussian kernel) against
# rank-based abilities: normal quantiles of the respondents' sum-score ranks
kernel_icc <- function(X, h = 1.06 * nrow(X)^(-1/5), at = seq(-2.5, 2.5, length.out = 51)) {
  th <- qnorm(rank(rowSums(X), ties.method = "first") / (nrow(X) + 1))
  W <- dnorm(outer(at, th, "-") / h)
  list(at = at, theta = th, P = apply(X, 2, function(y) as.vector(W %*% y / rowSums(W))))
}
k <- kernel_icc(X)
op <- par(mfrow = c(1, 2), mar = c(4, 4, 2, 1))
for (it in c("i10", "bump")) {
  fit <- glm(X[, it] ~ k$theta, family = binomial)   # a logistic curve on the same scale
  plot(k$at, k$P[, it], type = "l", lwd = 2.5, col = "#2780e3", ylim = c(0, 1),
       xlab = "Rank-based ability", ylab = "P(x = 1)", main = it)
  lines(k$at, plogis(coef(fit)[1] + coef(fit)[2] * k$at), lwd = 2, lty = 2, col = "#c2410c")
}
par(op)
