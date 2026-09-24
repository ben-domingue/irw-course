# Simulate data from a logistic regression, trace the log likelihood over the
# slope, and check that optim() and glm() find the same maximum. Base R only.
# Adapted from ben-domingue/252: c1/likelihood.R and ps1/ll_logreg.R.
set.seed(252)
n  <- 500    # number of observations (try 50, then 5000)
b0 <- 0      # true intercept
b1 <- 0.5    # true slope

x <- rnorm(n)
y <- rbinom(n, 1, plogis(b0 + b1 * x))

loglik <- function(b, x, y) {
  p <- plogis(b[1] + b[2] * x)
  sum(y * log(p) + (1 - y) * log(1 - p))
}

# The log likelihood over a grid of slopes (intercept fixed at its true value,
# so the surface is a curve we can draw).
grid <- seq(-1, 2, length.out = 301)
ll <- sapply(grid, function(s) loglik(c(b0, s), x, y))
plot(grid, ll, type = "l", lwd = 2, col = "#2780e3",
     xlab = "Candidate slope", ylab = "Log likelihood", main = paste("n =", n))
abline(v = b1, lty = 2, col = "#999")

# Two routes to the maximum likelihood estimate.
opt <- optim(c(0, 0), function(b) -loglik(b, x, y))
fit <- glm(y ~ x, family = binomial)
round(rbind(optim = opt$par, glm = coef(fit), truth = c(b0, b1)), 3)
cat("glm standard error of the slope:", round(summary(fit)$coefficients[2, 2], 3), "\n")
