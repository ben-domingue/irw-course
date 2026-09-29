# Simulate continuous responses on a 0-100 line from Samejima's model, then fit the
# linear model (factanal on the raw responses), Samejima's model (factanal on the
# logits) and the graded response model on the line cut into K bins (mirt).
# Compare each with the true test information.
library(mirt)
set.seed(252)
np <- 500                    # respondents
lam <- c(0.5, 0.6, 0.6, 0.7, 0.7, 0.8)   # standardized loadings on the logit scale
b <- c(-1, -0.5, 0, 0, 0.5, 1)           # where each item's median response is 50
ends <- 0                    # share of responses pushed to each end (try 0.1)
round_to <- 0                # round every response to a multiple of this (try 10)
K <- 5                       # bins for the graded model (try 3 or 21)

theta <- rnorm(np)
# Samejima's model: the logit of the response is linear in theta with normal error.
# Each logit is 2 times a standardized latent response with loading lam[i] (the
# factor of 2 spreads responses over the line; it doesn't change the information).
z <- sapply(seq_along(lam), function(i)
  2 * (lam[i] * (theta - b[i]) + rnorm(np, 0, sqrt(1 - lam[i]^2))))
x <- 100 / (1 + exp(-z))
if (ends > 0) {              # a share of responses at each end, more often for high/low theta
  u <- matrix(runif(length(x)), np)
  x[u < ends * 2 * pnorm(-theta)] <- 0
  x[u > 1 - ends * 2 * pnorm(theta)] <- 100
}
if (round_to > 0) x <- round(x / round_to) * round_to
x <- pmin(pmax(x, 0), 100)
colnames(x) <- paste0("item", seq_along(lam))

info <- function(l) sum(l^2 / (1 - l^2))   # test information at every theta
nu <- 0.5                                  # squeeze constant for the logits
zfit <- log((x + nu) / (100 - x + nu))
l_lin <- factanal(x, 1)$loadings[, 1]
l_crm <- factanal(zfit, 1)$loadings[, 1]
bins <- apply(x, 2, function(v) cut(v, seq(0, 100, length.out = K + 1),
                                    labels = FALSE, include.lowest = TRUE) - 1)
grm <- mirt(as.data.frame(bins), 1, itemtype = "graded", verbose = FALSE)

round(rbind(true = lam, linear = l_lin, samejima = l_crm), 2)
round(c(true = info(lam), linear = info(l_lin), samejima = info(l_crm),
        graded_at_minus2 = testinfo(grm, matrix(-2)), graded_at_0 = testinfo(grm, matrix(0)),
        graded_at_2 = testinfo(grm, matrix(2))), 2)
hist(x[, 1], breaks = 50, main = "Item 1", xlab = "Response (0-100)")
