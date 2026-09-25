# Two groups on a latent scale, reported through several order-preserving
# rescalings. Does the gap between them keep its size? Its sign? Base R only.
# New for this course; the idea follows Bond & Lang (2013).
set.seed(27)
n     <- 2000   # respondents per group
shift <- 0.3    # how far the treated group's mean sits above the control group's
ratio <- 1.0    # treated SD / control SD (try 1.5: the distributions now cross)

control <- rnorm(n, 0, 1)
treated <- rnorm(n, shift, ratio)
score <- c(control, treated)
treat <- rep(0:1, each = n)

# Order-preserving rescalings: each keeps every respondent's rank.
rescalings <- list(
  "as simulated"         = function(z) z,
  "compress the top"     = function(z) -exp(-z),       # concave
  "stretch the top"      = function(z) exp(z),         # convex
  "squash both ends"     = function(z) plogis(2 * z),  # a floor and a ceiling
  "stretch the far top"  = function(z) z + 10 * (z > 2) # one big step near the top
)
effect <- function(y) {
  y <- (y - mean(y)) / sd(y)
  mean(y[treat == 1]) - mean(y[treat == 0])
}
round(sapply(rescalings, function(f) effect(f(score))), 3)

# Does one group sit above the other everywhere? For each cut point s, the share
# of treated respondents at or above s minus the share of control respondents.
cuts <- quantile(score, seq(0.01, 0.99, by = 0.01))
gap <- sapply(cuts, function(s) mean(treated >= s) - mean(control >= s))
cat("Smallest difference in shares above a cut point:", round(min(gap), 3), "\n")
plot(cuts, gap, type = "l", lwd = 2, col = "#2780e3",
     xlab = "Cut point (latent scale)", ylab = "Share treated above - share control above")
abline(h = 0, lty = 2, col = "#999")
