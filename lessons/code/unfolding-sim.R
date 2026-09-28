# Simulate agree/disagree responses from an ideal-point model, fit the 2PL and the
# ideal-point model, and compare. Then keep only the statements near the ends of the
# scale and fit both again. Needs the mirt package.
library(mirt)
set.seed(52)
np <- 500                                    # respondents (try 200, or 5000 locally)
ns <- 20                                     # statements
delta <- seq(-2.5, 2.5, length.out = ns)     # where each statement sits
a <- 1.5                                     # how sharply agreement falls away from it

# mirt's ideal-point item: P(agree) = exp(-0.5 * (a * (theta - delta))^2). Agreement
# peaks at theta = delta and falls off on both sides.
theta <- rnorm(np)
p <- sapply(delta, function(d) exp(-0.5 * (a * (theta - d))^2))
resp <- as.data.frame((matrix(runif(np * ns), np) < p) * 1)
names(resp) <- sprintf("s%02d", 1:ns)

# Fit both models and compare AIC (lower is better). Ideal-point fits can stop at a
# poor local maximum, so we start each statement near where its agreers sit: the mean
# 2PL score of the respondents who agreed with it. (mirt keeps d <= 0, so the start
# puts the sign in a1.)
aic <- function(dat) {
  f2 <- mirt(dat, 1, "2PL", verbose = FALSE)
  th2 <- fscores(f2)[, 1]
  g <- sapply(dat, function(x) mean(th2[x == 1]))
  sv <- mirt(dat, 1, "ideal", pars = "values")
  sv$value[sv$name == "a1"] <- sign(g)
  sv$value[sv$name == "d"] <- -abs(g)
  f <- list(`2PL` = f2, ideal = mirt(dat, 1, "ideal", pars = sv, verbose = FALSE))
  list(fits = f, AIC = round(sapply(f, extract.mirt, "AIC")))
}
all_st <- aic(resp)
cat("All", ns, "statements, AIC:\n"); print(all_st$AIC)

# Recovered locations. mirt writes the ideal-point item as exp(-0.5 * (a1 * theta + d)^2),
# so the peak is at -d / a1. The sign of theta is arbitrary; flip it if needed.
est <- coef(all_st$fits$ideal, simplify = TRUE)$items
peak <- -est[, "d"] / est[, "a1"]
if (cor(peak, delta) < 0) peak <- -peak
cat("Correlation of true and estimated locations:", round(cor(peak, delta), 3), "\n")

# Keep the four statements at each end: no statement sits in the middle.
ends <- c(1:4, (ns - 3):ns)
end_st <- aic(resp[, ends])
cat("Only the", length(ends), "end statements, AIC:\n"); print(end_st$AIC)
cat("2PL slopes for the end statements:\n")
print(round(coef(end_st$fits$`2PL`, simplify = TRUE)$items[, "a1"], 2))

# True and fitted curves for a statement in the middle (s10) and one at an end (s01).
th <- seq(-3, 3, length.out = 121)
trace <- function(f, i) probtrace(extract.item(f, i), matrix(th))[, 2]
op <- par(mfrow = c(1, 2), mar = c(4, 4, 2, 1))
for (i in c(10, 1)) {
  plot(th, exp(-0.5 * (a * (th - delta[i]))^2), type = "l", lwd = 3, col = "grey60",
       ylim = c(0, 1), xlab = expression(theta), ylab = "P(agree)",
       main = sprintf("s%02d (delta = %.2f)", i, delta[i]))
  lines(th, trace(all_st$fits$`2PL`, i), lwd = 2, col = "#2780e3")
  lines(th, trace(all_st$fits$ideal, i), lwd = 2, lty = 2, col = "#c2410c")
}
legend("right", c("true", "2PL", "ideal"), col = c("grey60", "#2780e3", "#c2410c"),
       lwd = c(3, 2, 2), lty = c(1, 1, 2), bty = "n")
par(op)
# If the fitted theta came out reversed, the fitted curves are mirror images of the
# truth: the scale's direction is not identified from the responses alone.
