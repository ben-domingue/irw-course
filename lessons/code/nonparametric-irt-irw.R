# Mokken scaling with real data: mcmi_mokken and balance_mokken from the Item
# Response Warehouse. Runs as-is in R with the mokken and mirt packages; no login
# or token. The kernel smoother is written out by hand; it matches KernSmoothIRT's
# ksIRT() with its defaults (Gaussian kernel, bandwidth 1.06 n^(-1/5)).

## ---- helpers
library(mokken)   # van der Ark (2007, 2012)
library(mirt)     # Chalmers (2012), for the parametric comparison
# IRW tables are long (one row per respondent-item response); mokken wants one row
# per respondent and one column per item.
long2wide <- function(df) as.data.frame(tapply(df$resp, list(df$id, df$item), function(x) x[1]))
# Kernel-smoothed item curves (Ramsay, 1991): rank the sum scores (ties by order),
# turn the ranks into standard normal quantiles, and take a Gaussian-weighted
# average of each item's responses around each evaluation point.
kernel_icc <- function(X, h = 1.06 * nrow(X)^(-1/5), npoints = 51) {
  n <- nrow(X)
  th <- qnorm(rank(rowSums(X), ties.method = "first") / (n + 1))
  at <- seq(qnorm(1 / (n + 1)), qnorm(n / (n + 1)), length.out = npoints)
  W <- dnorm(outer(at, th, "-") / h)
  list(at = at, theta = th, h = h,
       P = sapply(X, function(y) as.vector(W %*% y / rowSums(W))))
}

## ---- fetch-mcmi
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/)
# with a CSV download. This link is pinned to one version of the data.
mcmi_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v64_0.mcmi_mokken/rows?format=csv"
mcmi <- long2wide(read.csv(mcmi_url))
mcmi <- mcmi[, order(as.integer(sub("item.", "", names(mcmi), fixed = TRUE)))]
c(respondents = nrow(mcmi), items = ncol(mcmi), missing = sum(is.na(mcmi)))
summary(colMeans(mcmi))   # proportion endorsing each item

## ---- h-mcmi
H <- coefH(mcmi, se = FALSE, results = FALSE)
round(c(scale_H = H$H, min_Hi = min(H$Hi), max_Hi = max(H$Hi),
        min_Hij = min(H$Hij[upper.tri(H$Hij)]), max_Hij = max(H$Hij[upper.tri(H$Hij)])), 2)
round(sort(H$Hi)[1:3], 2)   # the three least scalable items

## ---- aisp-mcmi
# Automated item selection at three lower bounds. Each column gives each item's
# scale (1, 2, ...), 0 meaning unscalable. Tabulated: how many items in each.
sel <- aisp(mcmi, lowerbound = c(0.3, 0.4, 0.5), verbose = FALSE)
lapply(as.data.frame(sel), table)

## ---- mono-mcmi
# Rest-score groups of at least N/10 respondents; a violation is a drop of more
# than 0.03 between two groups, #zsig counts the significant ones.
mono <- summary(check.monotonicity(mcmi))
colSums(mono[, c("#ac", "#vi", "#zsig")])

## ---- iio-mcmi
# Invariant item ordering (Ligtvoet et al., 2010): H^T for all 44 items, then the
# backward selection that removes items until no significant crossing remains.
round(check.iio(mcmi, item.selection = FALSE)$HT, 2)
iio <- check.iio(mcmi)
c(items_removed = length(iio$items.removed), items_left = ncol(mcmi) - length(iio$items.removed))
round(iio$HT, 2)   # H^T for the items that remain
# The same data through a 2PL: which slopes did the selection remove?
m2 <- mirt(mcmi, 1, itemtype = "2PL", verbose = FALSE)
a <- coef(m2, simplify = TRUE)$items[, "a1"]
removed <- names(iio$items.removed)
round(rbind(removed = range(a[removed]), kept = range(a[setdiff(names(a), removed)])), 2)

## ---- kernel-mcmi
k <- kernel_icc(mcmi)
m1 <- mirt(mcmi, 1, itemtype = "Rasch", verbose = FALSE)
# The kernel curves are on a scale with SD 1; mirt's Rasch fit estimates the SD of
# theta instead, so its curves are evaluated at at * SD to share the scale.
sd_rasch <- sqrt(coef(m1, simplify = TRUE)$cov[1, 1])
curve_at <- function(m, i, th) probtrace(extract.item(m, i), matrix(th))[, 2]
P1 <- sapply(seq_along(mcmi), function(i) curve_at(m1, i, k$at * sd_rasch))
P2 <- sapply(seq_along(mcmi), function(i) curve_at(m2, i, k$at))
mid <- abs(k$at) < qnorm(0.975)   # the middle 95% of respondents
gap <- function(P) apply(abs(k$P - P)[mid, ], 2, max)
round(rbind(Rasch = summary(gap(P1)), `2PL` = summary(gap(P2))), 2)
op <- par(mfrow = c(1, 2), mar = c(4, 4, 2, 1))
for (it in c("item.12", "item.39")) {
  i <- which(names(mcmi) == it)
  plot(k$at, k$P[, i], type = "l", lwd = 3, col = "#2780e3", ylim = c(0, 1),
       xlab = "Rank-based ability", ylab = "P(endorse)",
       main = sprintf("%s (2PL slope %.1f)", it, a[i]))
  lines(k$at, P1[, i], lwd = 2, lty = 2, col = "#c2410c")
  lines(k$at, P2[, i], lwd = 2, lty = 3, col = "black")
  legend("topleft", c("kernel", "Rasch", "2PL"), lty = 1:3, lwd = 2,
         col = c("#2780e3", "#c2410c", "black"), bty = "n")
}
par(op)
at_show <- c(-1.9, -1.3, -0.6, 0, 0.6, 1.3)
idx <- sapply(at_show, function(t) which.min(abs(k$at - t)))
round(rbind(ability = k$at[idx], item12_kernel = k$P[idx, "item.12"], item12_Rasch = P1[idx, 12],
            item12_2PL = P2[idx, 12], item39_kernel = k$P[idx, "item.39"]), 2)
round(colMeans(mcmi)[c("item.12", "item.39")], 2)   # proportion endorsing overall

## ---- fetch-balance
balance_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v64_0.balance_mokken/rows?format=csv"
balance <- long2wide(read.csv(balance_url))
types <- c(W = "weight", D = "distance", CW = "conflict-weight",
           CD = "conflict-distance", CB = "conflict-balance")
balance <- balance[, paste0(rep(names(types), each = 5), 1:5)]   # grouped by type
c(respondents = nrow(balance), items = ncol(balance), missing = sum(is.na(balance)))
round(tapply(colMeans(balance), rep(types, each = 5), mean)[types], 2)   # p-value by type

## ---- h-balance
Hb <- coefH(balance, se = FALSE, results = FALSE)
round(Hb$H, 2)
round(matrix(Hb$Hi, 5, dimnames = list(1:5, names(types))), 2)   # H_i, one column per type

## ---- rest-cw1
monob <- check.monotonicity(balance)
round(monob$results[[which(monob$I.labels == "CW1")]][[2]][, c("Lo Score", "Hi Score", "N", "Mean")], 2)

## ---- mono-balance
sb <- summary(monob)
sb[sb[, "#vi"] > 0, c("ItemH", "#ac", "#vi", "maxvi", "#zsig")]

## ---- aisp-balance
selb <- aisp(balance, lowerbound = 0.3, verbose = FALSE)
split(rownames(selb), selb[, 1])   # scale 0 = unscalable

## ---- kernel-balance
kb <- kernel_icc(balance)
mb <- mirt(balance, 1, itemtype = "2PL", verbose = FALSE)
round(coef(mb, IRTpars = TRUE, simplify = TRUE)$items[c("W1", "D1", "CW1"), c("a", "b")], 2)
P2b <- sapply(seq_along(balance), function(i) curve_at(mb, i, kb$at))
colnames(P2b) <- names(balance)
op <- par(mfrow = c(1, 3), mar = c(4, 4, 2, 1))
for (it in c("D1", "W1", "CW1")) {
  plot(kb$at, kb$P[, it], type = "l", lwd = 3, col = "#2780e3", ylim = c(0, 1),
       xlab = "Rank-based ability", ylab = "P(correct)", main = it)
  lines(kb$at, P2b[, it], lwd = 2, lty = 3, col = "black")
  rug(kb$theta[balance[[it]] == 1], col = "#93c5fd")
}
legend("topright", c("kernel", "2PL"), lty = c(1, 3), lwd = 2, col = c("#2780e3", "black"), bty = "n")
par(op)
idx <- sapply(c(-2.3, -1.7, -0.6, 0, 0.6, 1.1, 1.7), function(t) which.min(abs(kb$at - t)))
round(rbind(ability = kb$at[idx], CW1_kernel = kb$P[idx, "CW1"], CW1_2PL = P2b[idx, "CW1"],
            W1_kernel = kb$P[idx, "W1"], W1_2PL = P2b[idx, "W1"]), 2)
# How many children sit beyond -2 and 2 on the rank-based scale? (The rug marks
# the children who answered each problem correctly.)
c(below_minus_2 = sum(kb$theta < -2), above_2 = sum(kb$theta > 2))
