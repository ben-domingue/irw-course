# A contaminated criterion. Simulate a nine-item symptom screener and two ways of
# deciding who "has the condition": an independent criterion that shares no items
# with the screener, and a "diagnosis" that borrows some of its information from
# the screener's own items. Then ask how well the screener's count separates the
# groups under each. Base R only. New for this course (EDUC 252 c3 discusses
# criterion evidence; the simulation is not in the 252 code).
set.seed(33)
n    <- 5000                     # children
rho  <- 0.6                      # how strongly the criterion's latent variable tracks theta
prev <- 0.15                     # share of children the criterion (and the diagnosis) flags
w    <- c(0, 0.25, 0.5, 0.75, 1) # how much the diagnosis borrows from the screener's items

# The trait the screener targets, and nine items with a logistic curve,
# P(x = 1) = exp(a (theta - b)) / (1 + exp(a (theta - b))).
theta <- rnorm(n)
a <- 2
b <- seq(0.2, 1.8, length.out = 9)
x <- sapply(b, function(bi) rbinom(n, 1, plogis(a * (theta - bi))))
count <- rowSums(x)              # the screener: a symptom count, 0 to 9

# The independent criterion: something the screener's construct predicts, but
# imperfectly (say, impairment judged by a clinician who never sees the screener).
z_crit <- rho * theta + sqrt(1 - rho^2) * rnorm(n)
crit   <- as.numeric(z_crit > quantile(z_crit, 1 - prev))

# The contaminated diagnosis: a weighted mix of the criterion's information and the
# screener's own count, cut to flag about the same share of children. At w = 1 it
# is a rule applied to the screener's items and nothing else: a count above a cut.
z <- function(v) (v - mean(v)) / sd(v)
diagnose <- function(wt) {
  s <- (1 - wt) * z(z_crit) + wt * z(count)
  as.numeric(s > quantile(s, 1 - prev))
}

# The AUC: the chance that a randomly chosen flagged child has a higher count than
# a randomly chosen unflagged one, counting ties as half.
auc <- function(score, group) {
  r <- rank(score); n1 <- sum(group == 1); n0 <- sum(group == 0)
  (sum(r[group == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}

res <- t(sapply(w, function(wt) {
  d <- diagnose(wt)
  c(w        = wt,
    auc_diag = auc(count, d),     # what a study against the diagnosis would report
    auc_crit = auc(count, crit),  # what we want to know; w can't change it
    flagged  = mean(d),           # share the diagnosis flags
    agree    = mean(d == crit))   # how often the diagnosis matches the criterion
}))
round(res, 3)
