# Who gains more, low starters or high starters? Simulate children tested in the
# fall and the spring, every one of them gaining exactly the same amount on the
# true scale. Generate their responses from the Rasch model, then from a 2PL whose
# slopes peak in the middle of the test (as the letter-word items' do), fit the
# Rasch model to both, and compare gains by fall quartile. New for this course.
# Needs the mirt package.
library(mirt)
set.seed(66)
np    <- 1000   # children, each tested twice
ni    <- 30     # items
gain  <- 1      # every child's true fall-to-spring gain
peak  <- 1.0    # how much steeper the middle items are than the ends (0 = Rasch)

theta_fall <- rnorm(np)
theta <- c(theta_fall, theta_fall + gain)        # fall records, then spring records
b <- seq(-2.5, 3.5, length.out = ni)             # difficulties spanning both waves
a <- exp(peak * (1 - (b - 0.5)^2 / 4))           # slopes: 1 everywhere when peak = 0
simulate <- function(slopes) {
  p <- plogis(sweep(outer(theta, b, "-"), 2, slopes, "*"))
  as.data.frame(matrix(rbinom(length(p), 1, p), nrow(p)))
}
data_sets <- list(Rasch = simulate(rep(1, ni)), "2PL" = simulate(a))

# Under the Rasch model the sum score is sufficient, so the maximum-likelihood
# theta depends only on r: solve sum_i P(x_i = 1 | theta) = r once per sum score.
# (Scores of 0 and ni have no finite estimate; they are treated as 0.5 and ni - 0.5.)
theta_for_score <- function(b_hat) sapply(pmin(pmax(0:ni, 0.5), ni - 0.5), function(r)
  uniroot(function(t) sum(plogis(t - b_hat)) - r, c(-15, 15))$root)
quartile_gains <- function(resp) {
  m <- mirt(resp, 1, itemtype = "Rasch", verbose = FALSE)
  b_hat <- -coef(m, simplify = TRUE)$items[, "d"]   # mirt's d is an easiness: b = -d
  th <- theta_for_score(b_hat)[rowSums(resp) + 1]
  t1 <- th[1:np]; t3 <- th[np + 1:np]
  q <- cut(theta_fall, quantile(theta_fall, 0:4 / 4), include.lowest = TRUE,
           labels = paste0("Q", 1:4))              # quartiles of the TRUE fall theta
  round(tapply(t3 - t1, q, mean), 2)               # mean estimated gain, in logits
}
# Rows: the model that generated the data. Every child gained the same amount, so
# a flat row means the Rasch fit recovered that. For the Rasch data the row should
# sit near the true gain; for the 2PL data the Rasch unit differs, so read its shape.
t(sapply(data_sets, quartile_gains))
