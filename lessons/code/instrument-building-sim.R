# A wording factor: ten four-point items, five worded forward and five reversed.
# Every item reflects one trait (self-esteem, say); the reversed items also share
# a second, "method" factor that has nothing to do with the trait. The responses are
# generated already keyed (higher = more of the trait). What do alpha, the
# correlation matrix and its eigenvalues show? Base R only. New for this course
# (EDUC 252 c2 describes the problem; the simulation is not in the 252 code).
set.seed(56)
n       <- 1000                 # respondents
lambda  <- 0.6                  # loading of every item on the trait
gamma   <- 0.6                  # loading of the reversed items on the wording factor (try 0)
gamma_f <- 0                    # a wording factor of the forward items' own (try 0.6)
rev     <- rep(c(FALSE, TRUE), each = 5)   # items 6 to 10 are reverse-worded

trait   <- rnorm(n)
wording <- rnorm(n)             # independent of the trait
wording_f <- rnorm(n)           # independent of both
# A continuous response for each item, with variance 1, cut into four categories.
latent  <- sapply(seq_along(rev), function(i) {
  g <- if (rev[i]) gamma else gamma_f
  w <- if (rev[i]) wording else wording_f
  lambda * trait + g * w + sqrt(1 - lambda^2 - g^2) * rnorm(n)
})
x <- apply(latent, 2, cut, breaks = c(-Inf, -1, 0, 1, Inf), labels = FALSE)
colnames(x) <- paste0(ifelse(rev, "R", "F"), c(1:5, 1:5))

alpha <- function(m) { k <- ncol(m); k / (k - 1) * (1 - sum(apply(m, 2, var)) / var(rowSums(m))) }
r <- cor(x)
same_fwd <- mean(r[!rev, !rev][upper.tri(diag(5))])
same_rev <- mean(r[rev, rev][upper.tri(diag(5))])
across   <- mean(r[!rev, rev])

round(r, 2)                                   # two blocks when gamma > 0
round(c(alpha = alpha(x),
        mean_r_forward = same_fwd, mean_r_reversed = same_rev, mean_r_across = across), 2)
round(eigen(r)$values[1:3], 2)                # a second eigenvalue above 1 when gamma is large
# How well does the sum score track the trait itself? Squared correlation,
# the share of the sum's variance the trait accounts for.
round(cor(rowSums(x), trait)^2, 2)
