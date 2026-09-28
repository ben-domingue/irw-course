# Simulate responses to 10 items from two correlated dimensions (items 1-5 measure
# the first, 6-10 the second), hold out a fifth of the responses, fit one- and
# two-dimensional 2PL models with mirt to the rest, and ask how much the second
# dimension improves predictions of the held-out responses (the IMV).
library(mirt)
set.seed(43)
np  <- 500     # respondents
rho <- 0.5     # correlation between the two dimensions (try 0, 0.8 or 0.85)
a   <- 1.5     # every item's slope on its own dimension
d   <- rep(seq(-1.5, 1.5, length.out = 5), 2)   # mirt's intercepts (b = -d / a)
dim <- rep(1:2, each = 5)

theta <- matrix(rnorm(np * 2), np) %*% chol(matrix(c(1, rho, rho, 1), 2))
P <- plogis(a * theta[, dim] + rep(d, each = np))
resp <- (matrix(runif(np * 10), np) < P) * 1
colnames(resp) <- paste0("x", 1:10)

# Hold out a fifth of the responses (cells, not respondents).
cells <- which(!is.na(resp), arr.ind = TRUE)
test  <- cells[sample(nrow(cells), nrow(cells) / 5), ]
train <- as.data.frame(resp); train[test] <- NA

m1 <- mirt(train, 1, itemtype = "2PL", verbose = FALSE)
m2 <- mirt(train, mirt.model("F1 = 1-5
                              F2 = 6-10
                              COV = F1*F2"),
           itemtype = "2PL", quadpts = 15, verbose = FALSE)   # 15 x 15 quadrature keeps it quick

# Predicted probabilities for the held-out cells: logistic(a1*theta1 + a2*theta2 + d).
predict_cells <- function(m, cells) {
  th <- fscores(m)
  cf <- coef(m, simplify = TRUE)$items
  A  <- cf[, grep("^a", colnames(cf)), drop = FALSE]
  plogis(rowSums(A[cells[, 2], , drop = FALSE] * th[cells[, 1], , drop = FALSE]) + cf[cells[, 2], "d"])
}
# The IMV (Domingue et al., 2024): turn each model's mean log likelihood into the
# weight of a coin, then take the expected return (w1 - w0) / w0.
coin <- function(ll) uniroot(function(w) w * log(w) + (1 - w) * log(1 - w) - ll,
                             c(0.5, 1 - 1e-12))$root
mean_ll <- function(y, p) mean(y * log(p) + (1 - y) * log(1 - p))
y  <- resp[test]
w1 <- coin(mean_ll(y, predict_cells(m1, test)))
w2 <- coin(mean_ll(y, predict_cells(m2, test)))

cat("estimated correlation:", round(coef(m2, simplify = TRUE)$cov[1, 2], 2), "(true", rho, ")\n")
print(anova(m1, m2)[, c("AIC", "BIC", "logLik")])
cat("IMV of 2D over 1D on held-out responses:", round((w2 - w1) / w1, 4), "\n")
