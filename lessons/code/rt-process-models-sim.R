# Simulate two-choice decisions from the diffusion model and recover its parameters
# with EZ-diffusion (Wagenmakers, van der Maas & Grasman, 2007).
#
# Each respondent j has a drift theta_j (their ability: the drift on an item of
# difficulty 0), a boundary separation alpha_j (caution) and a non-decision time ter_j.
# Every trial is a random walk that starts halfway between 0 and alpha_j and moves by
# v * dt plus Gaussian noise with SD sqrt(dt) (so s = 1) until it crosses a boundary.
# eta is the across-trial SD of drift: 0 is the simple model; try eta <- 1.
#
# Base R only. The walk takes a second or two in the browser; raise np and ntr as
# you like in your own R session. (rtdists::rdiffusion samples the same model
# without the small error from the size of the steps.)
set.seed(65)
np  <- 100     # respondents
ntr <- 200     # trials per respondent
eta <- 0       # across-trial SD of drift

theta <- rnorm(np, 1.5, 0.5)       # drift
bound <- runif(np, 0.8, 1.8)       # boundary separation
ter   <- runif(np, 0.3, 0.5)       # non-decision time (s)

walk <- function(v, a, ter, dt = 0.001, maxt = 10) {
  n <- length(v); x <- a / 2; t <- numeric(n); resp <- rep(NA_integer_, n)
  live <- seq_len(n)
  while (length(live) && t[live[1]] < maxt) {
    x[live] <- x[live] + v[live] * dt + sqrt(dt) * rnorm(length(live))
    t[live] <- t[live] + dt
    up <- x[live] >= a[live]; lo <- x[live] <= 0
    resp[live[up]] <- 1L; resp[live[lo]] <- 0L
    live <- live[!(up | lo)]
  }
  data.frame(rt = ter + t, resp = resp)
}

d <- data.frame(id = rep(1:np, each = ntr))
d$v <- theta[d$id] + eta * rnorm(nrow(d))      # this trial's drift
d <- cbind(d, walk(d$v, bound[d$id], ter[d$id]))

# EZ-diffusion from the proportion correct and the mean and variance of correct RTs.
ez <- function(pc, vrt, mrt, s = 1) {
  L <- qlogis(pc)
  x <- L * (L * pc^2 - L * pc + pc - 0.5) / vrt
  v <- sign(pc - 0.5) * s * x^(1/4)
  a <- s^2 * L / v
  y <- -v * a / s^2
  mdt <- (a / (2 * v)) * (1 - exp(y)) / (1 + exp(y))
  c(v = v, alpha = a, ter = mrt - mdt)
}
est <- as.data.frame(t(sapply(split(d, d$id), function(x) {
  pc <- mean(x$resp); if (pc == 1) pc <- 1 - 1 / (2 * nrow(x))
  rc <- x$rt[x$resp == 1]
  c(pc = pc, ez(pc, var(rc), mean(rc)))
})))

# Everyone takes the same trials, so the sum score is sufficient and the logit of the
# proportion correct orders respondents as a Rasch ability estimate would.
acc_ability <- qlogis(est$pc)

round(c(accuracy = mean(d$resp),
        median_correct = median(d$rt[d$resp == 1]), median_error = median(d$rt[d$resp == 0])), 2)
round(rbind(truth = c(v = mean(theta), alpha = mean(bound), ter = mean(ter)),
            EZ = colMeans(est[, c("v", "alpha", "ter")]),
            r = c(cor(est$v, theta), cor(est$alpha, bound), cor(est$ter, ter))), 2)
round(c(r_accuracy_drift = cor(acc_ability, theta), r_accuracy_boundary = cor(acc_ability, bound)), 2)

op <- par(mfrow = c(1, 2), mar = c(4, 4, 1, 1))
plot(theta, est$v, pch = 19, col = "#2780e3", xlab = "True drift", ylab = "EZ drift")
abline(0, 1, lty = 2, col = "#999999")
plot(bound, acc_ability, pch = 19, col = "#c2410c",
     xlab = "True boundary separation", ylab = "Logit of proportion correct")
par(op)
