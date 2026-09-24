# Where CTT breaks: a recipe that respects the classical model for the total
# score, X = T + E, and nothing more. It sets the true reliability, then hands out
# each respondent's correct answers across items at random (weighted so that some
# items are easier than others). Base R only.
# Adapted from ben-domingue/252: ps2/ctt_failures.R.
set.seed(252)
n_items <- 50
n_ppl <- 500
n_reps <- 5                                  # data sets per setting

kr20 <- function(resp) {                     # KR-20: alpha for 0/1 items
  k <- ncol(resp)
  p <- colMeans(resp)
  (k / (k - 1)) * (1 - sum(p * (1 - p)) / var(rowSums(resp)))
}

sim_ctt <- function(n_items, n_ppl, s2_true, s2_error) {
  T <- round(rnorm(n_ppl, mean = n_items / 2, sd = sqrt(s2_true)))   # true scores
  E <- round(rnorm(n_ppl, mean = 0, sd = sqrt(s2_error)))            # errors
  X <- pmin(pmax(T + E, 0), n_items)         # observed sum scores, kept in 0..n_items
  pr <- runif(n_items, 0.25, 0.85)           # how often each item gets picked
  resp <- matrix(0, n_ppl, n_items)
  for (j in 1:n_ppl)                         # respondent j gets X[j] items right,
    if (X[j] > 0)                            # chosen at random, easier items more often
      resp[j, sample(n_items, X[j], prob = pr)] <- 1
  c(true_rel = cor(T, X)^2, kr20 = kr20(resp),
    var_X = var(X), sum_pq = sum(colMeans(resp) * (1 - colMeans(resp))))
}

# Nine settings: true-score and error variances as shares of the number of items.
settings <- expand.grid(s2_true = n_items * c(0.1, 0.5, 0.9),
                        s2_error = n_items * c(0.1, 0.25, 0.5))
out <- do.call(rbind, lapply(seq_len(nrow(settings)), function(s)
  t(replicate(n_reps, sim_ctt(n_items, n_ppl, settings$s2_true[s], settings$s2_error[s])))))
out <- data.frame(settings[rep(seq_len(nrow(settings)), each = n_reps), ], out)

# One row per setting: the reliability we built in, and what KR-20 reports.
print(aggregate(cbind(true_rel, kr20, var_X, sum_pq) ~ s2_true + s2_error, data = out,
                FUN = function(x) round(mean(x), 2)))

cols <- c("#2780e3", "#93c5fd", "#c2410c")  # one colour per error variance
err <- factor(out$s2_error)
plot(out$true_rel, out$kr20, xlim = c(0, 1), ylim = c(-0.2, 1), pch = 19,
     col = cols[err], xlab = "True reliability, cor(T, X)^2",
     ylab = "KR-20", main = "Built-in reliability vs. KR-20")
abline(0, 1, lty = 2, col = "grey50")        # where KR-20 would equal reliability
legend("bottomright", paste("error variance", levels(err)), col = cols, pch = 19, bty = "n")
