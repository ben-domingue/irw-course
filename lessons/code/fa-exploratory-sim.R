# Simulate a questionnaire with a known factor structure, then see whether
# exploratory factor analysis recovers it. Change the settings and run again.
# Needs the psych and GPArotation packages.
library(psych)
set.seed(7)
np <- 400          # people
n_factors <- 2     # true number of factors (try 3)
per_factor <- 5    # items per factor
loading <- 0.6     # how strongly each item reflects its factor (try 0.4)
phi <- 0.3         # correlation between the factors (try 0 and 0.7)

# True loadings: simple structure, each item loads on one factor only.
p <- n_factors * per_factor
Lambda <- matrix(0, p, n_factors)
for (k in 1:n_factors) Lambda[(k - 1) * per_factor + 1:per_factor, k] <- loading
Phi <- matrix(phi, n_factors, n_factors); diag(Phi) <- 1

# Data: factor scores times loadings, plus unique noise scaled so items have variance 1.
f <- matrix(rnorm(np * n_factors), np) %*% chol(Phi)
uniq <- sqrt(1 - rowSums((Lambda %*% Phi) * Lambda))
X <- f %*% t(Lambda) + matrix(rnorm(np * p), np) %*% diag(uniq)

# How many factors? Parallel analysis compares eigenvalues with those of random data.
pa <- fa.parallel(X, fa = "fa", n.iter = 20, plot = TRUE)

# Fit the true number of factors with an oblique rotation and compare to the truth.
efa <- fa(X, nfactors = n_factors, rotate = "oblimin", fm = "minres")
print(round(unclass(efa$loadings), 2))
cat("estimated factor correlation(s):", round(efa$Phi[lower.tri(efa$Phi)], 2), " true:", phi, "\n")
