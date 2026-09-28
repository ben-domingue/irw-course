# Estimating item parameters two ways, and what a wrong prior for theta costs.
# Part 1 simulates Rasch responses for 5, 10 and 40 items and estimates the
# difficulties by joint maximum likelihood (JML, written out below) and by marginal
# maximum likelihood (mirt's EM), then compares each with the truth.
# Part 2 draws abilities from a skewed distribution and fits a 2PL twice: with mirt's
# default normal prior for theta, and with the distribution estimated as a histogram.
# Needs the mirt package. Adapted from ben-domingue/252: slides c5 and PS5#1.
library(mirt)
set.seed(38)
np <- 1000   # respondents (try 250, then 5000)

# JML for the Rasch model: alternate a Newton step for every ability (items held
# fixed) with one for every difficulty (abilities held fixed). Respondents with a zero
# or perfect score have no finite ability, so they are set aside first.
jml <- function(X, tol = 1e-7, maxit = 500) {
  X <- X[rowSums(X) > 0 & rowSums(X) < ncol(X), ]
  r <- rowSums(X); s <- colSums(X)
  b <- -qlogis(colMeans(X)); b <- b - mean(b)
  th <- qlogis(r / ncol(X))
  for (it in 1:maxit) {
    P  <- plogis(outer(th, b, "-"))
    th <- th + (r - rowSums(P)) / rowSums(P * (1 - P))
    P  <- plogis(outer(th, b, "-"))
    step <- -(s - colSums(P)) / colSums(P * (1 - P))
    b <- b + step
    b <- b - mean(b)                      # fix the origin: difficulties sum to 0
    if (max(abs(step)) < tol) break
  }
  b
}

# Part 1. How far are the difficulties stretched? The slope of the (centred)
# estimates on the true difficulties is 1 for an estimator that is right on average.
cat("Part 1: slope of estimated on true difficulties\n")
for (ni in c(5, 10, 40)) {
  b  <- seq(-2, 2, length.out = ni)
  th <- rnorm(np)
  X  <- matrix(rbinom(np * ni, 1, plogis(outer(th, b, "-"))), np, ni)
  b_jml <- jml(X)
  m <- mirt(as.data.frame(X), 1, itemtype = "Rasch", verbose = FALSE)
  b_mml <- -coef(m, simplify = TRUE)$items[, "d"]   # mirt's d is an easiness: b = -d
  b_mml <- b_mml - mean(b_mml)                        # same origin as JML
  slope <- function(est) sum(est * b) / sum(b^2)      # through the origin
  cat(sprintf("  %2d items: JML %.3f   MML %.3f   I/(I-1) = %.3f   (JML dropped %d respondents)\n",
              ni, slope(b_jml), slope(b_mml), ni / (ni - 1),
              sum(rowSums(X) %in% c(0, ni))))
}

# Part 2. Abilities from a skewed distribution with mean 0 and SD 1: a chi-square with
# 2 degrees of freedom, standardized, so nobody is below -1 and a few are far above.
ni <- 10
a  <- rep(1.5, ni)                        # every slope is 1.5
b  <- seq(-2, 2, length.out = ni)
th <- (rchisq(np, df = 2) - 2) / 2
X  <- matrix(rbinom(np * ni, 1, plogis(a * outer(th, b, "-"))), np, ni)
m_norm <- mirt(as.data.frame(X), 1, itemtype = "2PL", verbose = FALSE)
m_eh   <- mirt(as.data.frame(X), 1, itemtype = "2PL", dentype = "EH", verbose = FALSE)
est <- function(m) {                      # slopes and difficulties, b = -d/a
  cf <- coef(m, simplify = TRUE)$items
  data.frame(a = cf[, "a1"], b = -cf[, "d"] / cf[, "a1"])
}
e_norm <- est(m_norm)
# The histogram's own mean and SD set its scale: put it on the truth's (mean 0, SD 1).
w <- extract.mirt(m_eh, "Prior")[[1]]; t <- m_eh@Model$Theta[, 1]
mu <- sum(w * t); s <- sqrt(sum(w * (t - mu)^2))
e_eh <- est(m_eh); e_eh$a <- e_eh$a * s; e_eh$b <- (e_eh$b - mu) / s
cat("\nPart 2: a 2PL with every slope 1.5, abilities skewed\n")
print(round(data.frame(true_b = b, b_normal = e_norm$b, b_histogram = e_eh$b,
                       a_normal = e_norm$a, a_histogram = e_eh$a), 2))
cat(sprintf("Largest error in b: %.2f with a normal prior, %.2f with the histogram\n",
            max(abs(e_norm$b - b)), max(abs(e_eh$b - b))))
cat(sprintf("Slopes run from %.2f to %.2f with a normal prior, %.2f to %.2f with the histogram\n",
            min(e_norm$a), max(e_norm$a), min(e_eh$a), max(e_eh$a)))
