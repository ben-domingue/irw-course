# A bank of 50 Rasch items; each respondent sees only 15 of them. Three ways of
# handing out the items, then a fourth: the first design with a position effect.
# Every design is fit once, concurrently, with mirt (missing by design is fine).
# Adapted from ben-domingue/252: ps6/equating_simstudy.R (PS6#4). Needs mirt.
library(mirt)
set.seed(47)
np    <- 600   # respondents (try 150, and 3000 in your own R session)
ni    <- 50    # items in the bank
delta <- 0.3   # design 4: extra difficulty for an item in the last third of a form

b  <- rnorm(ni, 0, 0.7)                       # true difficulties
th <- rnorm(np)                               # true abilities
full <- matrix(rbinom(np * ni, 1, plogis(outer(th, b, "-"))), np, ni)

# Design 1: a chain of 8 forms, each overlapping the next by 10 items (1-15, 6-20, ...)
forms1 <- lapply(0:7, function(k) 5 * k + 1:15)
# Design 2: 5 forms with 5-item links, the last one looping back to the first
forms2 <- list(1:15, 11:25, 21:35, 31:45, c(1:5, 41:50))
# Design 3: every respondent gets their own random 15 items
forms3 <- lapply(1:np, function(i) sample(ni, 15))

give <- function(forms, resp, delta = 0) {
  g <- if (length(forms) == np) 1:np else sample(length(forms), np, replace = TRUE)
  out <- matrix(NA, np, ni)
  for (j in 1:np) {
    it <- forms[[g[j]]]
    late <- seq_along(it) > 10                     # positions 11-15 of the form
    if (delta == 0) out[j, it] <- resp[j, it]
    else out[j, it] <- rbinom(15, 1, plogis(th[j] - b[it] - delta * late))
  }
  as.data.frame(out)
}
designs <- list(chain = give(forms1, full), loop = give(forms2, full),
                random = give(forms3, full), chain_position = give(forms1, full, delta))

est <- sapply(designs, function(d) {
  m <- mirt(d, 1, itemtype = "Rasch", verbose = FALSE)
  -coef(m, simplify = TRUE)$items[, "d"]          # mirt's d is an easiness: b = -d
})
# How well does each design recover the bank? (Both centred, since the origin is arbitrary.)
err <- scale(est, scale = FALSE) - (b - mean(b))
round(rbind(correlation = cor(est, b)[, 1], rmse = sqrt(colMeans(err^2))), 3)
# Design 4: where along the chain does the error go?
round(c(first_5_items = mean(err[1:5, "chain_position"]), last_5_items = mean(err[46:50, "chain_position"])), 2)

matplot(b, est, pch = c(1, 2, 3, 19), col = c("#999999", "#999999", "#999999", "#c2410c"),
        xlab = "True difficulty", ylab = "Estimated difficulty")
abline(0, 1, lty = 2)
legend("topleft", bty = "n", pch = c(1, 2, 3, 19), col = c("#999999", "#999999", "#999999", "#c2410c"),
       legend = names(designs))
