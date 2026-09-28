# Fitting propensity of the bifactor model, in miniature: simulate 1,000 respondents
# answering 12 items from two correlated factors (items 1-6 and 7-12, correlation 0.3)
# with NO general factor, then fit the true model, one factor, and a bifactor model
# with a general factor on all 12 items and a specific factor on items 7-12. Continuous
# items and lavaan, so it runs in about a second. Needs lavaan.

## ---- bifactor-sim
library(lavaan)
set.seed(43)
np <- 1000; rho <- 0.3; lam <- 0.7
f <- matrix(rnorm(np * 2), np) %*% chol(matrix(c(1, rho, rho, 1), 2))
X <- as.data.frame(sapply(1:12, function(i) lam * f[, (i > 6) + 1] + sqrt(1 - lam^2) * rnorm(np)))
names(X) <- paste0("x", 1:12)
models <- c(
  correlated = "A =~ x1 + x2 + x3 + x4 + x5 + x6
                B =~ x7 + x8 + x9 + x10 + x11 + x12",
  one_factor = "G =~ x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10 + x11 + x12",
  bifactor   = "G =~ x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10 + x11 + x12
                S =~ x7 + x8 + x9 + x10 + x11 + x12")
fits <- lapply(models, cfa, data = X, std.lv = TRUE, orthogonal = TRUE)
fits$correlated <- cfa(models[["correlated"]], data = X, std.lv = TRUE)   # A and B may correlate
round(t(sapply(fits, fitMeasures, c("chisq", "df", "cfi", "rmsea", "aic"))), 3)
# The bifactor model's "general factor", in data generated without one:
L <- inspect(fits$bifactor, "std")$lambda
round(range(L[, "G"]), 2)
gen <- sum(L[, "G"])^2; spec <- sum(L[, "S"])^2; uniq <- sum(1 - rowSums(L^2))
round(c(omega_h = gen / (gen + spec + uniq)), 2)
