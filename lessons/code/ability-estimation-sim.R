# Four ways to estimate a respondent's ability from Rasch responses, with the item
# difficulties treated as known: maximum likelihood (MLE), weighted likelihood (WLE),
# the posterior mode (MAP) and the posterior mean (EAP), the last two with a
# normal(0, 1) prior. Compare each with the true abilities: bias and root mean squared
# error (RMSE) along the scale, the spread of the estimates, and a group difference.
# Base R only; runs in a second or two. Adapted from ben-domingue/252: ps5/eap_versus_mle.R.
set.seed(37)
np <- 5000                          # respondents
b  <- seq(-2, 2, length.out = 10)   # item difficulties: try 20 or 40 items
g  <- rep(0:1, each = np / 2)       # two groups whose true means differ by 1
th <- rnorm(np, -0.5 + g, sqrt(0.75))   # overall mean 0, SD 1: the prior is right

p    <- plogis(outer(th, b, "-"))
resp <- matrix(rbinom(length(p), 1, p), np, length(b))
r    <- rowSums(resp)
n    <- length(b)

# Under the Rasch model every estimator depends on the responses only through the
# sum score r, so we need one estimate per possible score, 0 to n.
P    <- function(t) plogis(t - b)
info <- function(t) sum(P(t) * (1 - P(t)))
solve <- function(f) uniroot(f, c(-12, 12))$root
mle <- sapply(0:n, function(s) if (s == 0) -Inf else if (s == n) Inf else
  solve(function(t) s - sum(P(t))))                           # score equation
wle <- sapply(0:n, function(s)                                 # Warm's correction
  solve(function(t) s - sum(P(t)) + sum(P(t) * (1 - P(t)) * (1 - 2 * P(t))) / (2 * info(t))))
map <- sapply(0:n, function(s) solve(function(t) s - sum(P(t)) - t))   # prior N(0, 1)
nodes <- seq(-6, 6, length.out = 121)                          # EAP by quadrature
eap <- sapply(0:n, function(s) {
  post <- dnorm(nodes) * sapply(nodes, function(t) exp(s * t) / prod(1 + exp(t - b)))
  sum(nodes * post) / sum(post)
})
est <- data.frame(MLE = mle[r + 1], WLE = wle[r + 1], MAP = map[r + 1], EAP = eap[r + 1])
cat("Respondents with no finite MLE:", sum(!is.finite(est$MLE)), "of", np, "\n")
# A bounded optimizer doesn't say so: for a perfect score it returns the bound.
cat("optimize() on a perfect score:",
    round(optimize(function(t) sum(log(P(t))), c(-10, 10), maximum = TRUE)$maximum, 2), "\n\n")

# Bias and RMSE within bins of true ability (MLE: finite estimates only).
bins <- cut(th, c(-Inf, -2, -1, 0, 1, 2, Inf))
summ <- function(f) sapply(est, function(e) tapply(seq_along(th), bins, function(k) {
  ok <- k[is.finite(e[k])]; round(f(e[ok] - th[ok]), 2) }))
cat("Bias (estimate - truth) by true ability:\n"); print(summ(mean))
cat("\nRMSE by true ability:\n");                  print(summ(function(d) sqrt(mean(d^2))))

# Overall RMSE, the spread of the estimates, and the difference between the two
# groups' mean estimates (true: 1). The MLE column leaves out the respondents it has
# no estimate for; the other three include everyone.
fin <- is.finite(est$MLE)
cat("\nSD of true abilities:", round(sd(th), 2), "\n")
print(round(rbind(
  RMSE = sapply(est, function(e) sqrt(mean((e - th)[is.finite(e)]^2))),
  SD = sapply(est, function(e) sd(e[is.finite(e)])),
  group_difference = sapply(est, function(e) { k <- is.finite(e); mean(e[k & g == 1]) - mean(e[k & g == 0]) })), 2))

plot(th, est$EAP, pch = ".", col = "#2780e3", xlab = "True ability", ylab = "Estimate",
     ylim = c(-4, 4), main = paste(n, "items"))
points(th[fin], est$MLE[fin], pch = ".", col = "#c2410c")
abline(0, 1, lty = 2)
legend("topleft", c("EAP", "MLE"), pch = 19, col = c("#2780e3", "#c2410c"), bty = "n")
