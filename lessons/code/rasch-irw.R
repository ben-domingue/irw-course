# The Rasch model with real data: chess_lnirt and wirs from the Item Response
# Warehouse. Runs as-is in R with the mirt package; no login or token. The one
# baseline chunk ("spread") also uses the irw package if it is installed.
# Adapted from ben-domingue/252: c3/rasch0.R and c3/rasch2.R.

## ---- fetch
library(mirt)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/)
# with a CSV download. This link is pinned to one version of the data.
chess_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v57_0.chess_lnirt/rows?format=csv"
df <- read.csv(chess_url)
head(df[, c("id", "item", "resp")])

## ---- reshape
# IRW tables are long: one row per person-item response. mirt wants wide: one
# row per person, one column per item.
long2wide <- function(df) {
  wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  as.data.frame(wide[, order(as.numeric(gsub("\\D", "", colnames(wide))))])
}
resp <- long2wide(df)
# A few players have no responses at all (resp is NA for every item; the first
# rows of the table are one of them). They carry no information, so drop them.
c(players_in_table = nrow(resp), with_no_responses = sum(rowSums(!is.na(resp)) == 0))
resp <- resp[rowSums(!is.na(resp)) > 0, ]
dim(resp)

## ---- fit
m1 <- mirt(resp, 1, itemtype = "Rasch", verbose = FALSE)
# mirt writes the Rasch model as P(x = 1) = 1 / (1 + exp(-(theta + d))), so its
# "d" is an easiness. The difficulty in our notation is b = -d.
b <- -coef(m1, simplify = TRUE)$items[, "d"]
round(head(sort(b)), 2)   # the easiest items
round(tail(sort(b)), 2)   # the hardest items

## ---- spread
# How wide is wide? The IRW's difficulty pool (the diffsim vignette) holds
# difficulty estimates for 145 IRW tables and ships with the irw package.
round(c(sd_b = sd(b), range_b = diff(range(b))), 2)   # chess, from our fit
if (requireNamespace("irw", quietly = TRUE)) {
  data("diff_long", package = "irw")
  pool_sd <- tapply(diff_long$difficulty, diff_long$dataset, sd)
  print(c(tables = length(pool_sd), round(quantile(pool_sd, c(.25, .5, .75)), 2)))
  # chess_lnirt is in the pool. Compare its entry with the rest of the pool:
  cat(sprintf("chess_lnirt in the pool: SD %.2f, wider than %.0f%% of the %d tables\n",
              pool_sd[["chess_lnirt"]], 100 * mean(pool_sd < pool_sd[["chess_lnirt"]]),
              length(pool_sd)))
  # The pool's chess SD is ours divided by the SD of ability in our fit: the pool
  # puts ability on a scale with SD 1, while mirt's Rasch fit estimates it.
  sd_theta <- sqrt(coef(m1, simplify = TRUE)$cov[1, 1])
  cat(sprintf("SD of ability in our fit %.2f; our SD of b divided by it: %.2f\n",
              sd_theta, sd(b) / sd_theta))
}

## ---- pvalues
p <- colMeans(resp, na.rm = TRUE)
plot(p, b, xlab = "Proportion correct (p-value)", ylab = "Rasch difficulty (b)",
     pch = 19, col = "#2780e3")
sprintf("%.4f", cor(p, b, method = "spearman"))   # rank correlation of p and b

## ---- wright
theta <- fscores(m1)[, 1]
br <- seq(floor(min(c(theta, b))), ceiling(max(c(theta, b))), by = 0.25)
h <- hist(theta, breaks = br, plot = FALSE)
op <- par(mar = c(4, 4, 2, 1))
plot(NULL, xlim = c(-max(h$counts), 12), ylim = range(br), xaxt = "n",
     xlab = "", ylab = "Logits", main = "Wright map: chess_lnirt")
rect(-h$counts, h$breaks[-length(h$breaks)], 0, h$breaks[-1], col = "#dbeafe", border = "white")
points(rep(1.5, length(b)) + (seq_along(b) %% 8), b, pch = 18, col = "#c2410c")
abline(v = 0)
axis(1, at = c(-max(h$counts) / 2, 5), labels = c("People", "Items"), tick = FALSE)
par(op)
round(c(mean_theta = mean(theta), mean_b = mean(b)), 2)
# mirt fixes the mean of the ability distribution at 0. Any other origin fits
# exactly as well: add 1 to every theta and every b, and no probability moves.
all.equal(plogis(outer(theta + 1, b + 1, "-")), plogis(outer(theta, b, "-")))

## ---- itemfit-chess
fit <- itemfit(m1, fit_stats = "infit")
head(fit[order(-abs(fit$z.outfit)), ], 5)   # the five worst-fitting items, by |z|
fit[which.max(fit$outfit), ]                # the largest outfit of all 40 items
itemfit(m1, empirical.plot = 15)            # Y15: observed vs. model

## ---- wirs
wirs_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v57_0.wirs/rows?format=csv"
resp_w <- long2wide(read.csv(wirs_url))
dim(resp_w)
m2 <- mirt(resp_w, 1, itemtype = "Rasch", verbose = FALSE)
b_w <- -coef(m2, simplify = TRUE)$items[, "d"]
# Because the sum score r is sufficient, the Rasch model predicts the proportion
# endorsing item i among respondents with sum score r without reference to theta:
#   P(x_i = 1 | r) = eps_i * gamma_(r-1)(items other than i) / gamma_r(all items),
# with eps = exp(-b) and gamma_r the elementary symmetric functions (see the
# Go deeper callout in the lesson).
esf <- function(eps) {               # gamma_0, gamma_1, ..., gamma_n
  g <- 1
  for (e in eps) g <- c(g, 0) + c(0, g) * e
  g
}
p_given_r <- function(b, i) {        # P(x_i = 1 | r) for r = 0, ..., n
  eps <- exp(-b); g <- esf(eps); g_i <- esf(eps[-i]); r <- seq_along(b)
  c(0, eps[i] * g_i[r] / g[r + 1])
}
r_w <- factor(rowSums(resp_w), levels = 0:6)
tab <- data.frame(r = 0:6, n = as.vector(table(r_w)),
  item1_observed = as.vector(tapply(resp_w[, 1], r_w, mean)),
  item1_rasch    = p_given_r(b_w, 1),
  item3_observed = as.vector(tapply(resp_w[, 3], r_w, mean)),
  item3_rasch    = p_given_r(b_w, 3))
round(tab, 2)
