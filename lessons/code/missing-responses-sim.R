# Missing responses: simulate Rasch data, delete responses by four mechanisms, and
# fit each data set twice, with the gaps left missing and with the gaps scored wrong.
# Runs as-is in R with the mirt package (about 10 seconds locally).
library(mirt)
set.seed(2026)
n <- 1000; k <- 20
b <- seq(-2, 2, length.out = k)                     # true difficulties
theta <- rnorm(n)                                   # true abilities
p <- plogis(outer(theta, b, "-"))
X <- (matrix(runif(n * k), n, k) < p) * 1          # complete Rasch data
colnames(X) <- paste0("i", 1:k)

# Four ways for about a fifth of the responses to go missing.
miss <- list()
# MCAR: every response has the same chance of being skipped.
miss$MCAR <- matrix(runif(n * k) < 0.2, n, k)
# MAR: a stopping rule. Respondents with 5 or fewer right on items 1-10 don't see
# items 11-20. Missingness depends only on responses we observe.
stop <- rowSums(X[, 1:10]) <= 5
miss$MAR <- matrix(FALSE, n, k); miss$MAR[stop, 11:20] <- TRUE
# MNAR (theta): a skip propensity correlated -0.6 with ability, so lower-ability
# respondents skip more. Missingness depends on something we don't observe.
xi <- -0.6 * theta + sqrt(1 - 0.6^2) * rnorm(n)
miss$MNAR_theta <- matrix(runif(n * k), n, k) < plogis(-1.8 + 1.2 * xi)
# MNAR (own answer): skip 40% of the items the respondent would get wrong.
miss$MNAR_own <- X == 0 & matrix(runif(n * k) < 0.4, n, k)

fit <- function(Y) {
  m <- mirt(as.data.frame(Y), 1, itemtype = "Rasch", verbose = FALSE)
  list(b = -coef(m, simplify = TRUE)$items[, "d"],   # mirt's d is an easiness: b = -d
       eap = fscores(m, method = "EAP")[, 1])
}
res <- do.call(rbind, lapply(names(miss), function(mech) {
  M <- miss[[mech]]
  heavy <- rowSums(M) >= quantile(rowSums(M), 0.9) & rowSums(M) > 0   # the heaviest skippers
  Y_missing <- X; Y_missing[M] <- NA                # choice 1: leave the gaps missing
  Y_wrong <- X; Y_wrong[M] <- 0                     # choice 2: score the gaps wrong
  do.call(rbind, lapply(c("missing", "wrong"), function(g) {
    f <- fit(if (g == "missing") Y_missing else Y_wrong)
    data.frame(mechanism = mech, share_missing = round(mean(M), 2), gaps = g,
               bias_b = round(mean(f$b - b), 2),               # average error in b
               max_err_b = round(max(abs(f$b - b)), 2),        # worst item
               bias_eap_heavy = round(mean(f$eap[heavy] - theta[heavy]), 2))
  }))
}))
print(res, row.names = FALSE)
