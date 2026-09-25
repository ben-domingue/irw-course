# Differential item functioning, simulated: two groups answer 20 items from a 2PL.
# The focal group sits `impact` SDs below the reference group, and `n_dif` items
# (from item 9 on) are harder for the focal group by `dif` logits at every theta (uniform DIF).
# Each replication runs the Mantel-Haenszel procedure on every item, matching on the
# total score and then on a purified total, and records which items are flagged.
# Base R only; runs in a few seconds.
set.seed(252)
n_ref <- 1000; n_foc <- 1000       # respondents per group
n_items <- 20
impact <- 1.0                      # reference mean minus focal mean, in SDs of theta
n_dif <- 2; dif <- 0.6             # how many DIF items, and how much harder for the focal group
slopes_vary <- TRUE                # FALSE: every slope 1 (the Rasch model)
reps <- 100

a <- if (slopes_vary) exp(seq(-0.5, 0.5, length.out = n_items)) else rep(1, n_items)
b <- seq(-1.5, 1.5, length.out = n_items)
dif_items <- seq_len(n_dif) + 8   # items 9, 10, ...: middling difficulty, slope near 1

# Mantel-Haenszel delta and its chi-square p-value for one item (g = 1 is focal).
mh <- function(y, g, score) {
  k <- score + 1; K <- max(k)
  A <- tabulate(k[y == 1 & g == 0], K); B <- tabulate(k[y == 0 & g == 0], K)
  C <- tabulate(k[y == 1 & g == 1], K); D <- tabulate(k[y == 0 & g == 1], K)
  n <- A + B + C + D; s <- n > 1
  A <- A[s]; B <- B[s]; C <- C[s]; D <- D[s]; n <- n[s]
  nR <- A + B; nF <- C + D; m1 <- A + C; m0 <- B + D
  chisq <- max(0, abs(sum(A) - sum(nR * m1 / n)) - 0.5)^2 / sum(nR * nF * m1 * m0 / (n^2 * (n - 1)))
  c(delta = -2.35 * log(sum(A * D / n) / sum(B * C / n)), p = pchisq(chisq, 1, lower.tail = FALSE))
}

one_rep <- function() {
  g <- rep(0:1, c(n_ref, n_foc))
  theta <- rnorm(n_ref + n_foc, mean = ifelse(g == 1, -impact, 0))
  bb <- matrix(b, length(g), n_items, byrow = TRUE)
  bb[g == 1, dif_items] <- bb[g == 1, dif_items] + dif
  p <- plogis(sweep(theta - bb, 2, a, "*"))
  X <- matrix(rbinom(length(p), 1, p), nrow = length(g))
  # Stage 1: match on the total. Stage 2: drop flagged items from the total
  # (each studied item stays in its own matching score) and run again.
  s1 <- sapply(1:n_items, function(i) mh(X[, i], g, rowSums(X)))
  flag <- which(s1["p", ] < 0.05 & abs(s1["delta", ]) >= 1)
  s2 <- sapply(1:n_items, function(i) mh(X[, i], g, rowSums(X[, union(setdiff(1:n_items, flag), i), drop = FALSE])))
  rbind(delta_total = s1["delta", ], sig_total = s1["p", ] < 0.05,
        delta_purified = s2["delta", ], sig_purified = s2["p", ] < 0.05)
}
out <- replicate(reps, one_rep())   # 4 x n_items x reps

clean <- setdiff(1:n_items, dif_items)
summary_table <- data.frame(
  matching = c("total", "purified"),
  mean_delta_dif_items = c(mean(out["delta_total", dif_items, ]), mean(out["delta_purified", dif_items, ])),
  power = c(mean(out["sig_total", dif_items, ]), mean(out["sig_purified", dif_items, ])),
  mean_delta_clean_items = c(mean(out["delta_total", clean, ]), mean(out["delta_purified", clean, ])),
  type_I_error = c(mean(out["sig_total", clean, ]), mean(out["sig_purified", clean, ])))
print(summary_table, digits = 2)
# The true DIF on the delta scale is -2.35 x the log odds ratio. For a 2PL item that is
# about -2.35 * a * dif near the middle of the scale.
round(-2.35 * a[dif_items] * dif, 2)

op <- par(mar = c(4, 4, 1, 1))
plot(1:n_items, rowMeans(out["delta_total", , ]), pch = 19, col = "#2780e3", ylim = c(-2.5, 1),
     xlab = "Item (DIF items from item 9 on)", ylab = "Mean MH delta over replications")
points(1:n_items, rowMeans(out["delta_purified", , ]), pch = 1, col = "#c2410c")
abline(h = c(-1, 0, 1), lty = c(3, 2, 3), col = "#999")
legend("bottomright", c("matched on total", "matched on purified total"),
       pch = c(19, 1), col = c("#2780e3", "#c2410c"), bty = "n")
par(op)
