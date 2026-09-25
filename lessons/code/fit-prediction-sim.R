# Part 1: how much does outfit vary when the Rasch model is true? Simulate Rasch
# data, fit the model, compute outfit for every item, and compare the spread of the
# outfits with the rough rule sqrt(2/n). Part 2: generate data from a normal-ogive
# (probit) curve instead of a logistic one, fit the Rasch model anyway, and see what
# the fit statistics notice.
# Adapted from ben-domingue/252: ps3/fit.R (PS3#3) and ps3/different-links.R (PS3#4).
# Needs the mirt package.
library(mirt)
set.seed(3)
ni   <- 20                  # items
ns   <- c(100, 400, 1600)   # respondents (try adding 6400 in your own R session)
reps <- 2                   # datasets per sample size (more gives a steadier answer)

sim_rasch <- function(np, b, link = plogis) {
  th <- rnorm(np)
  pr <- link(outer(th, b, "-"))
  as.data.frame(matrix(rbinom(length(pr), 1, pr), np, length(b)))
}
# Outfit from mirt's default (EAP) abilities and from maximum-likelihood abilities
outfits <- function(resp) {
  m <- mirt(resp, 1, itemtype = "Rasch", verbose = FALSE)
  c(itemfit(m, fit_stats = "infit")$outfit, itemfit(m, fit_stats = "infit", method = "ML")$outfit)
}

b <- rnorm(ni)
res <- t(sapply(ns, function(np) {
  o <- replicate(reps, outfits(sim_rasch(np, b)))
  eap <- o[1:ni, ]; ml <- o[-(1:ni), ]
  c(n = np, mean_EAP = mean(eap), mean_ML = mean(ml), sd_EAP = sd(eap), sd_ML = sd(ml),
    sqrt_2_over_n = sqrt(2 / np))
}))
print(round(res, 3))

# Part 2: the true curve is the normal CDF, pnorm(theta - b), not the logistic.
resp <- sim_rasch(1000, b, link = pnorm)
m <- mirt(resp, 1, itemtype = "Rasch", verbose = FALSE)
b_hat <- -coef(m, simplify = TRUE)$items[, "d"]     # mirt's d is an easiness: b = -d
fit <- itemfit(m, fit_stats = "infit", method = "ML")   # ML abilities, as above
cat("slope of estimated on true difficulties:", round(coef(lm(b_hat ~ b))[2], 2), "\n")
cat("outfit ranges from", round(min(fit$outfit), 2), "to", round(max(fit$outfit), 2),
    "; largest |z|:", round(max(abs(fit$z.outfit)), 1), "\n")

plot(b, b_hat, pch = 19, col = "#2780e3", xlab = "True difficulty (probit scale)",
     ylab = "Estimated Rasch difficulty", main = "Probit data, logistic model")
abline(0, 1, lty = 2)
abline(0, 1.7, col = "#c2410c")   # the scaling constant D = 1.7 (Camilli, 1994)
