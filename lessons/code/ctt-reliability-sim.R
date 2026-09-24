# Is alpha a lower bound on reliability? Simulate a test from the classical model,
# where we know the true scores, and compare. Change `loadings` and run again.
# Base R only.
set.seed(1)
np <- 1000                               # people
loadings <- c(1, 1, 1, 1, 1, 1)          # equal: "tau-equivalent" items
# loadings <- c(0.3, 0.6, 1, 1, 1.5, 2)  # unequal: try this line instead
err_sd <- 1                              # error SD for every item

true <- rnorm(np)
items <- sapply(loadings, function(l) l * true + rnorm(np, sd = err_sd))
X <- rowSums(items)                      # observed sum score
T <- sum(loadings) * true                # its true score

alpha <- function(x) { k <- ncol(x); k / (k - 1) * (1 - sum(apply(x, 2, var)) / var(rowSums(x))) }
cat("true reliability, cor(X, T)^2:", round(cor(X, T)^2, 3), "\n")
cat("Cronbach's alpha:             ", round(alpha(items), 3), "\n")

plot(T, X, pch = 16, col = rgb(0.15, 0.5, 0.89, 0.3),
     xlab = "True score T", ylab = "Observed score X",
     main = paste("reliability", round(cor(X, T)^2, 2), "| alpha", round(alpha(items), 2)))
