# Simulate responses from a 3PL with a lower asymptote of c = 0.25 on every item,
# fit the Rasch model, the 2PL and the 3PL, and see what each recovers.
# Adapted from ben-domingue/252: c4 (slide 61). Needs the mirt package.
library(mirt)
set.seed(1)
ni <- 20      # number of items
np <- 1000    # number of respondents (try 10000 in your own R session)
c_true <- 0.25

th <- rnorm(np)                  # true abilities
a  <- exp(rnorm(ni, 0, 0.3))     # true slopes, around 1
b  <- rnorm(ni)                  # true difficulties
pr <- c_true + (1 - c_true) * plogis(sweep(outer(th, b, "-"), 2, a, "*"))
resp <- as.data.frame(matrix(rbinom(np * ni, 1, pr), np, ni))

fits <- list(Rasch = mirt(resp, 1, itemtype = "Rasch", verbose = FALSE),
             `2PL` = mirt(resp, 1, itemtype = "2PL", verbose = FALSE),
             `3PL` = mirt(resp, 1, itemtype = "3PL", verbose = FALSE))

# mirt calls the lower asymptote g; in our notation it is c.
c_hat <- coef(fits$`3PL`, simplify = TRUE)$items[, "g"]
cat("Estimated c (truth 0.25): median", round(median(c_hat), 2),
    " range", round(min(c_hat), 2), "to", round(max(c_hat), 2), "\n")
cat("BIC:", paste(names(fits), round(sapply(fits, extract.mirt, "BIC")), collapse = "  "), "\n")

# Abilities: how well does each model recover the truth, and how much do they differ?
theta <- sapply(fits, function(m) fscores(m)[, 1])
print(round(cor(cbind(truth = th, theta)), 3))

plot(seq_len(ni), sort(c_hat), pch = 19, col = "#2780e3", ylim = c(0, 1),
     xlab = "Item (sorted by estimate)", ylab = "Estimated lower asymptote c",
     main = paste(np, "respondents,", ni, "items"))
abline(h = c_true, lty = 2)
