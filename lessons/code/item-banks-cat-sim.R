# Item banks and adaptive testing: simulate a 2PL bank, give each simulated respondent
# a CAT (EAP scoring, maximum information, stop when the posterior SD reaches 0.3), and
# compare it with one fixed 20-item form from the same bank. Base R; runs in seconds.
set.seed(252)
n_items  <- 200     # items in the bank
n_people <- 200     # respondents
se_stop  <- 0.3     # stop when the posterior SD reaches this...
max_len  <- 60      # ...or after this many items
form_len <- 20      # length of the fixed form

# The bank: difficulties N(0, 1), slopes lognormal around 1.2. Known, as if calibrated.
b <- rnorm(n_items, 0, 1)
a <- exp(rnorm(n_items, log(1.2), 0.3))
theta <- rnorm(n_people)
# Every respondent's answer to every item, generated once: a CAT only reveals some.
P <- plogis(outer(theta, b, "-") * matrix(a, n_people, n_items, byrow = TRUE))
X <- (matrix(runif(n_people * n_items), n_people) < P) * 1

nodes <- seq(-5, 5, length.out = 101)
prior <- dnorm(nodes)
eap <- function(ll) {
  w <- exp(ll - max(ll)) * prior; w <- w / sum(w)
  th <- sum(nodes * w)
  c(theta = th, se = sqrt(sum((nodes - th)^2 * w)))
}
loglik_item <- function(j, x) {   # log P(x | node) for item j
  p <- plogis(a[j] * (nodes - b[j]))
  if (x == 1) log(p) else log(1 - p)
}
info <- function(th, j) { p <- plogis(a[j] * (th - b[j])); a[j]^2 * p * (1 - p) }

cat_one <- function(x) {
  ll <- numeric(length(nodes)); used <- integer(0); est <- eap(ll)
  while (length(used) < max_len && est[["se"]] > se_stop) {
    avail <- setdiff(seq_len(n_items), used)
    j <- avail[which.max(info(est[["theta"]], avail))]   # most informative at the EAP
    ll <- ll + loglik_item(j, x[j])
    used <- c(used, j); est <- eap(ll)
  }
  c(est, n = length(used))
}
cat_res <- t(apply(X, 1, cat_one))

# The fixed form: the 20 items most informative at theta = 0, scored by EAP.
form <- order(info(0, seq_len(n_items)), decreasing = TRUE)[1:form_len]
fixed_res <- t(apply(X, 1, function(x)
  eap(Reduce(`+`, lapply(form, function(j) loglik_item(j, x[j]))))))

rmse <- function(est, keep = TRUE) sqrt(mean((est[keep] - theta[keep])^2))
band <- cut(theta, c(-Inf, -1.5, -0.5, 0.5, 1.5, Inf))
round(data.frame(
  respondents     = as.vector(table(band)),
  cat_items       = tapply(cat_res[, "n"], band, mean),
  cat_rmse        = sapply(levels(band), function(l) rmse(cat_res[, "theta"], band == l)),
  fixed20_rmse    = sapply(levels(band), function(l) rmse(fixed_res[, "theta"], band == l)),
  row.names = levels(band)), 2)
c(cat_mean_items = mean(cat_res[, "n"]), cat_rmse = round(rmse(cat_res[, "theta"]), 3),
  fixed20_rmse = round(rmse(fixed_res[, "theta"]), 3))

plot(theta, cat_res[, "n"], pch = 16, col = "#2780e3", xlab = "True theta",
     ylab = "Items given", main = "Items the CAT needed to reach a posterior SD of 0.3")
abline(h = form_len, lty = 2, col = "#999999")
