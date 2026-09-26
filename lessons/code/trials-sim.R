# Trials as items, simulated: 50 respondents each meet four rotation angles
# (0, 50, 100, 150 degrees) ten times, in two sessions. Accuracy falls with angle
# by `slope_mean` logits per 50 degrees on average; respondents differ in overall
# accuracy (SD 1) and in how much angle costs them (SD `slope_sd`). We fit three
# accounts of the angles to session 1 with lme4, predict session 2, and ask two
# questions: which account predicts new trials best (the IMV), and how well does
# each respondent's own angle cost at session 1 predict it at session 2?
#
# nAGQ = 0 keeps each fit to a second or two in the browser; delete it in your own
# R session for the full Laplace fit. New for this course, after c9/mrot.R.
library(lme4)
set.seed(9)
np <- 50            # respondents
reps <- 10          # trials per angle per session
slope_mean <- -0.4  # average change in logits per 50 degrees
slope_sd <- 0.3     # SD across respondents of their own slope

theta <- rnorm(np, 1.5, 1)
slope <- rnorm(np, slope_mean, slope_sd)
session <- function(s) {
  d <- expand.grid(id = factor(1:np), angle = c(0, 50, 100, 150), rep = 1:reps)
  d$a50 <- d$angle / 50
  d$resp <- rbinom(nrow(d), 1, plogis(theta[d$id] + slope[d$id] * d$a50))
  d$session <- s
  d
}
s1 <- session(1); s2 <- session(2)

# The IMV (Domingue et al., 2024): the expected return of betting on new trials
# with the second model's predictions against someone holding the first's.
coin <- function(ll) if (ll <= log(0.5)) 0.5 else
  uniroot(function(w) w * log(w) + (1 - w) * log(1 - w) - ll, c(0.5, 1 - 1e-12))$root
imv <- function(y, p0, p1) {
  w <- sapply(list(p0, p1), function(p) coin(mean(y * log(p) + (1 - y) * log(1 - p))))
  (w[2] - w[1]) / w[1]
}

per_angle <- glmer(resp ~ factor(angle) + (1 | id), s1, binomial, nAGQ = 0)
linear    <- glmer(resp ~ a50 + (1 | id), s1, binomial, nAGQ = 0)
slopes    <- glmer(resp ~ a50 + (1 + a50 | id), s1, binomial, nAGQ = 0)
people    <- glmer(resp ~ 1 + (1 | id), s1, binomial, nAGQ = 0)
p <- lapply(list(people = people, per_angle = per_angle, linear = linear, slopes = slopes),
            predict, newdata = s2, type = "response")

cat(sprintf("Angle effect at session 1: %.2f logits per 50 degrees (true %.2f), z = %.1f\n",
            fixef(linear)["a50"], slope_mean, coef(summary(linear))["a50", "z value"]))
cat(sprintf("SD of respondents' slopes: true %.2f, estimated %.2f\n", slope_sd,
            attr(VarCorr(slopes)$id, "stddev")[2]))
cat("\nIMV for predicting session 2, each model against respondents only:\n")
print(round(sapply(p[-1], function(q) imv(s2$resp, p$people, q)), 4))

# Each respondent's own scores in each session: overall accuracy, and the angle
# cost (accuracy at 0 and 50 degrees minus accuracy at 100 and 150), the analogue
# of a Stroop effect. How well does session 1 predict session 2?
scores <- function(d) {
  small <- tapply(d$resp[d$angle < 75], d$id[d$angle < 75], mean)
  large <- tapply(d$resp[d$angle > 75], d$id[d$angle > 75], mean)
  cbind(accuracy = (small + large) / 2, cost = small - large)
}
a <- scores(s1); b <- scores(s2)
cat("\nSession 1 vs. session 2 correlation of each respondent's scores:\n")
print(round(c(accuracy = cor(a[, 1], b[, 1]), angle_cost = cor(a[, 2], b[, 2])), 2))
