# Classification consistency at a cut score: simulate two administrations of a
# nine-item graded test, count how often a respondent lands on the same side of
# the cut twice, and compare with what the model and CTT predict from one
# administration. Base R only. Part of the IRW course lesson "What does a score
# mean?".
set.seed(61)
n   <- 5000                       # respondents
cut <- 10                         # screen positive at a sum score of cut or more
a   <- c(3.2, 3.6, 2.2, 2.7, 2.6, 3.4, 3.5, 3.1, 3.4)   # slopes, close to the PHQ-9 fit
d   <- rbind(c(-0.6, -3.2, -5.6), c(-0.3, -3.7, -5.9), c( 0.1, -2.1, -3.7),
             c( 0.1, -2.6, -4.2), c(-1.3, -3.1, -4.9), c(-1.9, -3.8, -6.0),
             c(-1.5, -3.9, -6.1), c(-3.3, -4.7, -6.8), c(-3.4, -5.0, -6.9))
# mirt's graded model: P(x >= k) = 1 / (1 + exp(-(a * theta + d_k))), k = 1, 2, 3

# Category probabilities (0, 1, 2, 3) for one item at each theta
cat_probs <- function(theta, a, d) {
  star <- cbind(1, matrix(sapply(d, function(dk) plogis(a * theta + dk)), ncol = 3), 0)
  star[, 1:4] - star[, 2:5]
}
# One administration: nine responses per respondent, returned as sum scores
administer <- function(theta) {
  x <- sapply(1:9, function(i) {
    p <- cat_probs(theta, a[i], d[i, ])
    u <- runif(length(theta))
    rowSums(u > t(apply(p, 1, cumsum)))    # 0..3
  })
  list(items = x, sum = rowSums(x))
}
# The distribution of the sum score given theta (Lord & Wingersky, 1984)
sum_dist <- function(theta) {
  f <- 1
  for (i in 1:9) {
    p <- cat_probs(theta, a[i], d[i, ])
    g <- numeric(length(f) + 3)
    for (k in 0:3) g[(1:length(f)) + k] <- g[(1:length(f)) + k] + f * p[k + 1]
    f <- g
  }
  f                                       # f[s + 1] = P(sum = s | theta)
}

theta  <- rnorm(n)
first  <- administer(theta)
second <- administer(theta)               # same respondents, fresh errors

# 1. Observed: same side of the cut on both administrations
observed <- mean((first$sum >= cut) == (second$sum >= cut))

# 2. The model's prediction, from each respondent's theta:
#    P(same side) = p^2 + (1 - p)^2, where p = P(sum >= cut | theta)
p_pos <- sapply(theta, function(t) sum(sum_dist(t)[(cut:27) + 1]))
irt   <- mean(p_pos^2 + (1 - p_pos)^2)

# 3. CTT's prediction, from one administration: two normal scores with the
#    first administration's mean and SD, correlated at alpha
alpha <- function(X) { k <- ncol(X); k / (k - 1) * (1 - sum(apply(X, 2, var)) / var(rowSums(X))) }
rel   <- alpha(first$items)
z1    <- rnorm(1e5); z2 <- rel * z1 + sqrt(1 - rel^2) * rnorm(1e5)
m <- mean(first$sum); s <- sd(first$sum)
ctt   <- mean(((m + s * z1) >= cut - 0.5) == ((m + s * z2) >= cut - 0.5))

round(c(positive_first = mean(first$sum >= cut), alpha = rel,
        observed = observed, irt = irt, ctt = ctt), 3)

# Near the cut: respondents whose chance of screening positive is between 0.2 and 0.8
near <- p_pos > 0.2 & p_pos < 0.8
round(c(share_near = mean(near),
        observed_near = mean(((first$sum >= cut) == (second$sum >= cut))[near])), 3)
