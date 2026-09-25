# Simulate responses from the partial credit model (PCM), fit the PCM and the graded
# response model (GRM), and compare them with the truth. Then collapse the categories
# to 0/1 and see what happens to the information. Needs the mirt package.
library(mirt)
set.seed(50)
np <- 1000                                  # respondents (try 200, or 5000 locally)
ni <- 6                                     # items, each scored 0, 1, 2, 3
# PCM step difficulties: row i holds item i's b1, b2, b3. Item 6 has a middle
# step below the first, so its category 1 is never the most likely response.
b <- rbind(c(-1.5, -0.5, 0.5), c(-1, 0, 1), c(-0.5, 0.5, 1.5),
           c(-1, -0.5, 2), c(0, 0.5, 1), c(0.5, -0.5, 1))[1:ni, , drop = FALSE]

# PCM: P(x = k) is proportional to exp(sum over v <= k of (theta - b_v)).
theta <- rnorm(np)
pcm_probs <- function(th, bi) {
  num <- exp(cumsum(c(0, th - bi)))
  num / sum(num)
}
resp <- sapply(1:ni, function(i) sapply(theta, function(t)
  sample(0:3, 1, prob = pcm_probs(t, b[i, ]))))
colnames(resp) <- paste0("item", 1:ni)
resp <- as.data.frame(resp)

# Fit both models. mirt's "Rasch" itemtype is the PCM for items with more than two
# categories: slopes fixed at 1, SD of theta estimated.
pcm <- mirt(resp, 1, itemtype = "Rasch", verbose = FALSE)
grm <- mirt(resp, 1, itemtype = "graded", verbose = FALSE)
b_hat <- coef(pcm, IRTpars = TRUE, simplify = TRUE)$items[, c("b1", "b2", "b3")]
cat("PCM steps, true and estimated:\n")
print(round(cbind(b, b_hat), 2))
cat("AIC: PCM", round(extract.mirt(pcm, "AIC")), " GRM", round(extract.mirt(grm, "AIC")), "\n")

# Category response functions for one item: the truth, the PCM fit, the GRM fit.
i <- ni
th <- matrix(seq(-3, 3, length.out = 121))
truth <- t(sapply(th, pcm_probs, bi = b[i, ]))
matplot(th, truth, type = "l", lty = 1, lwd = 3, col = "grey70",
        xlab = "θ", ylab = "P(x = k)", ylim = c(0, 1), las = 1)
matlines(th, probtrace(extract.item(pcm, i), th), lty = 2, lwd = 2, col = "#2780e3")
matlines(th, probtrace(extract.item(grm, i), th), lty = 3, lwd = 2, col = "#c2410c")
legend("top", c("truth", "PCM fit", "GRM fit"), lty = 1:3, lwd = 2,
       col = c("grey70", "#2780e3", "#c2410c"), bty = "n", horiz = TRUE)

# Collapse to 0/1 at x >= 2 and fit a 2PL. Information from the full categories
# (PCM fit) against the collapsed items.
bin <- as.data.frame(1 * (resp >= 2))
fit01 <- mirt(bin, 1, itemtype = "2PL", verbose = FALSE)
at <- matrix(c(-2, -1, 0, 1, 2))
print(round(data.frame(theta = at[, 1], four_categories = testinfo(pcm, at),
                       collapsed = testinfo(fit01, at)), 2))
