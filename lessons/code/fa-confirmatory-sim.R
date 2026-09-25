# Simulate ordinal responses from a two-factor model, fit a confirmatory factor
# analysis with lavaan and a graded response model with mirt, and compare both
# with the truth on the IRT scale. Needs the lavaan and mirt packages.
library(lavaan)
library(mirt)
set.seed(59)
np  <- 1000                                   # respondents (try 300, or 5000 locally)
lam <- c(0.8, 0.7, 0.6, 0.5, 0.8, 0.7, 0.6, 0.5)   # loadings: items 1-4 on F1, 5-8 on F2
phi <- 0.4                                    # correlation between the factors
tau <- c(-1, 0, 1)                            # thresholds that cut y* into 0, 1, 2, 3

# Latent responses y* = loading * factor + error, with var(y*) = 1; then cut.
eta <- matrix(rnorm(np * 2), np) %*% chol(matrix(c(1, phi, phi, 1), 2))
f   <- rep(1:2, each = 4)
ystar <- sapply(1:8, function(i) lam[i] * eta[, f[i]] + sqrt(1 - lam[i]^2) * rnorm(np))
resp <- as.data.frame(apply(ystar, 2, function(y) findInterval(y, tau)))
names(resp) <- paste0("x", 1:8)

# The CFA, on polychoric correlations (items declared ordered).
fit <- cfa("F1 =~ x1 + x2 + x3 + x4
            F2 =~ x5 + x6 + x7 + x8", data = resp, ordered = TRUE, std.lv = TRUE)
lam_hat <- rowSums(lavInspect(fit, "std")$lambda)

# The graded response model in mirt, one factor at a time. Each item loads on one
# factor, so this estimates the same slopes as a two-dimensional fit, which takes
# minutes in the browser (change it to mirt.model("F1 = 1-4 / F2 = 5-8 / COV = F1*F2",
# on three lines, to try it locally).
a_mirt <- c(coef(mirt(resp[1:4], 1, itemtype = "graded", verbose = FALSE), simplify = TRUE)$items[, "a1"],
            coef(mirt(resp[5:8], 1, itemtype = "graded", verbose = FALSE), simplify = TRUE)$items[, "a1"])

# On the logistic IRT scale: a = 1.702 * lambda / sqrt(1 - lambda^2).
to_a <- function(l) 1.702 * l / sqrt(1 - l^2)
print(round(data.frame(true_loading = lam, cfa_loading = lam_hat,
                       true_a = to_a(lam), a_from_cfa = to_a(lam_hat), a_mirt = a_mirt), 2))
cat("factor correlation: true", phi, " lavaan", round(lavInspect(fit, "cor.lv")[1, 2], 2), "\n")
print(round(fitMeasures(fit, c("chisq.scaled", "df", "cfi.scaled", "rmsea.scaled")), 3))
