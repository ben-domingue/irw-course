# Does 1/sqrt(I(theta)) describe how far ability estimates really fall from the truth?
# Simulate Rasch responses from a test with a chosen difficulty profile, estimate each
# respondent's theta by maximum likelihood (item difficulties treated as known), and
# compare the spread of the errors within bins of true theta with the conditional SEM.
# Base R only; runs in a second or two.
set.seed(36)
np <- 4000                        # respondents
b  <- seq(-2, 2, length.out = 20) # item difficulties: try rep(1, 20), or seq(-2, 2, length.out = 5)
th <- runif(np, -3, 3)            # true abilities, spread evenly so every bin has respondents

p    <- plogis(outer(th, b, "-"))
resp <- matrix(rbinom(length(p), 1, p), np, length(b))
r    <- rowSums(resp)

# Test information under the Rasch model: the sum over items of p(1 - p).
info <- function(t) sapply(t, function(x) sum(plogis(x - b) * (1 - plogis(x - b))))

# Maximum-likelihood theta for one respondent. The Rasch score equation says the
# expected sum score equals the observed one; solve it. A respondent with every item
# right (or wrong) has no finite estimate: we set those aside and count them.
ml <- function(score) uniroot(function(t) sum(plogis(t - b)) - score, c(-10, 10))$root
finite <- r > 0 & r < length(b)
th_hat <- rep(NA, np)
th_hat[finite] <- sapply(r[finite], ml)

bins <- cut(th, seq(-3, 3, by = 0.5))
mid  <- seq(-2.75, 2.75, by = 0.5)
out <- data.frame(
  theta = mid,
  n_no_estimate = as.vector(tapply(!finite, bins, sum)),
  empirical_sd  = round(as.vector(tapply(th_hat - th, bins, sd, na.rm = TRUE)), 2),
  csem          = round(1 / sqrt(info(mid)), 2))
print(out, row.names = FALSE)

plot(mid, out$csem, type = "l", lwd = 2, col = "#2780e3", ylim = c(0, 1.5),
     xlab = "True ability theta (bin midpoint)", ylab = "Standard error",
     main = paste(length(b), "items"))
points(mid, out$empirical_sd, pch = 19, col = "#c2410c")
legend("top", c("1 / sqrt(I(theta))", "SD of estimate - truth"), lwd = c(2, NA),
       pch = c(NA, 19), col = c("#2780e3", "#c2410c"), bty = "n")
