# Simulate responses from a 2PL in one population, split the respondents three ways,
# fit the 2PL separately in each half, and compare with the true item parameters.
# Adapted from ben-domingue/252: c4 (slides 35-43, "Parameter invariance"). Needs mirt.
library(mirt)
set.seed(40)
np <- 2000    # respondents (try 10000 in your own R session)
ni <- 20      # items
a  <- exp(rnorm(ni, 0, 0.3))   # true slopes, around 1
b  <- rnorm(ni)                # true difficulties
th <- rnorm(np)                # true abilities: one population, mean 0, SD 1
resp <- as.data.frame(matrix(rbinom(np * ni, 1, plogis(sweep(outer(th, b, "-"), 2, a, "*"))), np, ni))
r <- rowSums(resp)

# Each fit puts theta on its own group's scale (mean 0, SD 1 in that group). If the
# group's true abilities have mean m and SD s, the 2PL it should recover is
# a* = a s and b* = (b - m) / s: the truth, re-expressed on the group's scale.
fit_group <- function(g) {
  cf <- coef(mirt(resp[g, ], 1, itemtype = "2PL", verbose = FALSE), simplify = TRUE, IRTpars = TRUE)$items
  m <- mean(th[g]); s <- sd(th[g])
  c(slope_r = cor(cf[, "a"], a * s), median_slope = median(cf[, "a"]), median_true = median(a * s),
    difficulty_r = cor(cf[, "b"], (b - m) / s))
}
splits <- list(random     = sample(c(TRUE, FALSE), np, replace = TRUE),
               true_theta = th > median(th),      # split on the ability itself
               sum_score  = r > median(r))        # split on the same items' sum score
out <- do.call(rbind, lapply(names(splits), function(s) {
  rbind(cbind(split = s, half = "upper", as.data.frame(t(fit_group(splits[[s]])))),
        cbind(split = s, half = "lower", as.data.frame(t(fit_group(!splits[[s]])))))
}))
print(format(out, digits = 2), row.names = FALSE)

# Within the upper half, how strongly do the items correlate with one another?
mean_r <- function(g) { R <- cor(resp[g, ]); mean(R[upper.tri(R)]) }
round(c(everyone = mean_r(rep(TRUE, np)), upper_by_theta = mean_r(splits$true_theta),
        upper_by_sum = mean_r(splits$sum_score)), 3)
