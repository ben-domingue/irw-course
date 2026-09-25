# Impact without bias: two groups that differ on the construct, answering items
# that work the same way for both. Are the raw gaps bias? Does an invariance test
# object? Does a regression on the sum score predict a criterion equally well for
# both groups? Needs the mirt package. New for this course.
library(mirt)
set.seed(152)
n      <- 1000   # respondents per group
ni     <- 15     # items
impact <- 0.8    # how far the focal group's mean theta sits below the reference group's
shift_one <- 0   # bias in one item: item 8 is this much harder for the focal group
shift_all <- 0   # bias in every item: all items this much harder for the focal group

a <- round(runif(ni, 0.8, 2), 2)             # slopes
b <- round(seq(-1.5, 1.5, length.out = ni), 2) # difficulties
g <- rep(c("ref", "foc"), each = n)
theta <- rnorm(2 * n, mean = ifelse(g == "foc", -impact, 0))
b_foc <- b + shift_all + (seq_len(ni) == 8) * shift_one
bb <- t(sapply(g, function(k) if (k == "foc") b_foc else b))
p <- plogis(sweep(theta - bb, 2, a, "*"))
resp <- matrix(rbinom(length(p), 1, p), nrow(p), dimnames = list(NULL, paste0("item", 1:ni)))

# 1. The raw gaps. Every item is easier for the reference group, because its
#    respondents know more; none of the items is biased.
round(colMeans(resp[g == "foc", ]) - colMeans(resp[g == "ref", ]), 2)
s <- rowSums(resp)
cat("sum-score gap, focal minus reference, in SDs:", round((mean(s[g == "foc"]) - mean(s[g == "ref"])) / sd(s), 2), "\n")

# 2. Invariance at the scale level: every item's slope and intercept free in each
#    group (configural), against equal slopes and intercepts with the focal group's
#    mean and variance free (scalar). mirt writes the 2PL as a*theta + d.
G <- factor(g, levels = c("ref", "foc"))
configural <- multipleGroup(resp, 1, group = G, itemtype = "2PL", verbose = FALSE)
scalar <- multipleGroup(resp, 1, group = G, itemtype = "2PL", verbose = FALSE,
                        invariance = c("slopes", "intercepts", "free_means", "free_var"))
print(anova(scalar, configural))
cat("focal group's mean theta under the scalar model (impact plus shift_all:", -impact - shift_all, "):",
    round(coef(scalar, simplify = TRUE)$foc$means[1], 2), "\n")

# 3. Prediction. A criterion that depends on theta alone, the same way in both
#    groups: no predictive bias by construction. Regress it on the sum score.
y <- theta + rnorm(2 * n, sd = 0.5)
common <- lm(y ~ s)
cat("mean residual from the common line: reference", round(mean(resid(common)[g == "ref"]), 3),
    " focal", round(mean(resid(common)[g == "foc"]), 3), "\n")
round(coef(summary(lm(y ~ s + G)))["Gfoc", ], 3)   # the intercept difference, focal minus reference

plot(s + runif(2 * n, -0.3, 0.3), y, col = ifelse(g == "foc", "#c2410c", "#2780e3"), cex = 0.4,
     xlab = "Sum score (jittered)", ylab = "Criterion", main = paste("Impact", impact, ", no bias"))
for (k in c("ref", "foc")) abline(lm(y ~ s, subset = g == k), col = ifelse(k == "foc", "#c2410c", "#2780e3"), lwd = 2)
abline(common, lty = 2, lwd = 2)
legend("topleft", c("reference", "focal", "common line"), col = c("#2780e3", "#c2410c", "black"),
       lty = c(1, 1, 2), lwd = 2, bty = "n")
