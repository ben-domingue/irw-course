# Simulate item responses from the Rasch model, fit the model, and compare the
# estimates to the truth. Change ni and np and run it again.
# Adapted from ben-domingue/252: c3/rasch1.R. Needs the mirt package.
library(mirt)
set.seed(12311)
ni <- 10    # number of items
np <- 500   # number of people (try 50, then 2000)

th <- rnorm(np)                    # true abilities: one per person
b  <- rnorm(ni)                    # true difficulties: one per item
pr <- plogis(outer(th, b, "-"))    # P(correct) for every person-item pair
resp <- as.data.frame(matrix(rbinom(np * ni, 1, pr), np, ni))

m <- mirt(resp, 1, itemtype = "Rasch", verbose = FALSE)
b_hat <- -coef(m, simplify = TRUE)$items[, "d"]   # mirt's d is an easiness: b = -d

plot(b, b_hat, pch = 19, col = "#2780e3", xlab = "True difficulty",
     ylab = "Estimated difficulty", main = paste(np, "people,", ni, "items"))
abline(0, 1, lty = 2)
cat("correlation of true and estimated b:", round(cor(b, b_hat), 3), "\n")
cat("root mean squared error:", round(sqrt(mean((b - b_hat)^2)), 3), "\n")
