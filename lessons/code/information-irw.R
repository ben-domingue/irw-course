# Information, precision and short forms with real data: a financial-literacy test
# (bialowolski_2024_financial_literacy) and the Perceptual Aberration scale of the
# Wisconsin Schizotypy Scales-Short Forms (christensen_2018_wsssf_5831), from the Item
# Response Warehouse. Runs as-is in R with the mirt package; no login or token.
# Adapted from ben-domingue/252: c4/info.R and problem set 6 (#3).

## ---- fetch-fl
library(mirt)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/) with a
# CSV download. This link is pinned to one version of the data.
fl_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_4:v7_0.bialowolski_2024_financial_literacy/rows?format=csv"
df <- read.csv(fl_url)
# resp is 1 for a correct answer and 0 otherwise ("don't know" included). Every
# respondent answered every item once; there are no waves.
long2wide <- function(df) {
  wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  as.data.frame(wide[, order(as.numeric(gsub("\\D", "", colnames(wide))))])
}
fl <- long2wide(df)
c(respondents = nrow(fl), items = ncol(fl), complete = sum(complete.cases(fl)))
round(range(colMeans(fl)), 2)   # proportion correct: the hardest and easiest items

## ---- fit-fl
# Rasch and 2PL. mirt writes the 2PL as a*theta + d; our difficulty is b = -d/a.
fl_r <- mirt(fl, 1, itemtype = "Rasch", verbose = FALSE)
fl_2 <- mirt(fl, 1, itemtype = "2PL", verbose = FALSE)
c(BIC_Rasch = round(extract.mirt(fl_r, "BIC")), BIC_2PL = round(extract.mirt(fl_2, "BIC")))
cf <- coef(fl_2, simplify = TRUE)$items
pars <- data.frame(a = cf[, "a1"], b = -cf[, "d"] / cf[, "a1"])
pars$info_at_peak <- pars$a^2 / 4   # a 2PL item's information at theta = b
round(pars[order(pars$b), ], 2)

## ---- info-fl
# Test information is the sum of the item informations; the conditional SEM is one
# over its square root. testinfo() and iteminfo() do the sums.
theta <- seq(-4, 4, by = 0.01)
I_fl <- testinfo(fl_2, matrix(theta))
at <- c(-2, -1, 0, 1, 2)
data.frame(theta = at, information = round(I_fl[match(at, theta)], 2),
           csem = round(1 / sqrt(I_fl[match(at, theta)]), 2))
c(peak_at = theta[which.max(I_fl)], peak_information = round(max(I_fl), 2),
  csem_at_peak = round(1 / sqrt(max(I_fl)), 2))
# The two flattest items, and what they add to the test information at its peak.
flat <- rownames(pars)[order(pars$a)[1:2]]
round(sapply(flat, function(i) iteminfo(extract.item(fl_2, i), theta[which.max(I_fl)])), 3)
# Information adds: the item informations at theta = 0 sum to the test information there.
all.equal(sum(sapply(colnames(fl), function(i) iteminfo(extract.item(fl_2, i), 0))),
          testinfo(fl_2, matrix(0)))

## ---- one-sem-fl
# The single-number summary: mirt's marginal reliability of the ability estimates,
# and the one SEM it implies on a scale whose ability SD is 1.
eap <- fscores(fl_2, full.scores.SE = TRUE)
rel <- empirical_rxx(eap)
c(reliability = round(unname(rel), 2), one_sem = round(sqrt(1 - unname(rel)), 2))
# The conditional SEM at the 2.5th and 97.5th percentiles of the respondents' estimates.
q <- quantile(eap[, "F1"], c(0.025, 0.975))
round(c(q, csem = 1 / sqrt(testinfo(fl_2, matrix(q)))), 2)

## ---- plot-fl
op <- par(mar = c(4, 4, 1, 4))
hist(eap[, "F1"], breaks = seq(-4, 4, 0.25), col = "#93c5fd", border = "white",
     main = "", xlab = "Financial literacy (theta)", ylab = "Respondents")
par(new = TRUE)
plot(theta, 1 / sqrt(I_fl), type = "l", lwd = 2.5, col = "#c2410c", ylim = c(0, 2),
     axes = FALSE, xlab = "", ylab = "")
axis(4, col.axis = "#c2410c"); mtext("Conditional SEM", side = 4, line = 2.5, col = "#c2410c")
par(op)

## ---- short-fl
# A five-item short form for decisions made near theta = -1: take the five items
# with the most information there. Compare it with the full test and with every
# possible five-item form (choose(18, 5) = 8,568 of them).
target <- -1
c(share_of_respondents_below_target = round(mean(eap[, "F1"] < target), 2))
item_info <- function(t) sapply(colnames(fl), function(i) iteminfo(extract.item(fl_2, i), t))
info_target <- item_info(target)
best5 <- names(sort(info_target, decreasing = TRUE))[1:5]
best5
forms <- combn(18, 5)
all5 <- apply(forms, 2, function(k) sum(info_target[k]))
c(full_test = round(sum(info_target), 2), best_five = round(sum(info_target[best5]), 2),
  median_five = round(median(all5), 2), five_90th_percentile = round(unname(quantile(all5, 0.9)), 2))
# What the targeted form gives up away from its target.
up <- 1.5
info_up <- item_info(up)
c(full_test = round(sum(info_up), 2), best_five = round(sum(info_up[best5]), 2),
  best_five_for_1.5 = round(sum(sort(info_up, decreasing = TRUE)[1:5]), 2))
round(1 / sqrt(c(best5_at_target = sum(info_target[best5]), best5_at_1.5 = sum(info_up[best5]))), 2)

## ---- fetch-wss
wss_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_5:v4_0.christensen_2018_wsssf_5831/rows?format=csv"
ws <- read.csv(wss_url)
ws <- as.data.frame(tapply(ws$resp, list(ws$id, ws$item), function(x) x[1]))
# Items are keyed so that 1 is the response scored toward schizotypy. The 60 items
# form four 15-item subscales (mi, pb, py, sa); their sum scores correlate like this:
sub <- sapply(c(mi = "mi", pb = "pb", py = "py", sa = "sa"),
              function(s) rowSums(ws[, startsWith(names(ws), s)]))
round(cor(sub), 2)
# We use one subscale, Perceptual Aberration (pb).
pb <- ws[, startsWith(names(ws), "pb")]
c(respondents = nrow(pb), items = ncol(pb))
round(range(colMeans(pb)), 2)   # proportion endorsing each item
sum(rowSums(pb) == 0)             # respondents who endorse no item
round(mean(rowSums(pb) == 0), 2)  # as a share of all respondents

## ---- fit-wss
pb_2 <- mirt(pb, 1, itemtype = "2PL", verbose = FALSE)
cfp <- coef(pb_2, simplify = TRUE)$items
round(c(min_b = min(-cfp[, "d"] / cfp[, "a1"]), max_b = max(-cfp[, "d"] / cfp[, "a1"]),
        min_a = min(cfp[, "a1"]), max_a = max(cfp[, "a1"])), 2)

## ---- info-wss
I_pb <- testinfo(pb_2, matrix(theta))
at <- c(-1, 0, 1, 2, 3)
data.frame(theta = at, information = round(I_pb[match(at, theta)], 2),
           csem = round(1 / sqrt(I_pb[match(at, theta)]), 2))
c(peak_at = theta[which.max(I_pb)], peak_information = round(max(I_pb), 2),
  csem_at_peak = round(1 / sqrt(max(I_pb)), 2))
# Where the respondents are: everyone who endorsed nothing gets the same estimate.
eap_pb <- fscores(pb_2)[, 1]
c(estimate_for_score_zero = round(unique(eap_pb[rowSums(pb) == 0]), 2),
  csem_there = round(1 / sqrt(testinfo(pb_2, matrix(unique(eap_pb[rowSums(pb) == 0])))), 2),
  share_with_csem_below_0.4 = round(mean(1 / sqrt(testinfo(pb_2, matrix(eap_pb))) < 0.4), 2))

## ---- plot-wss
op <- par(mar = c(4, 4, 1, 4))
hist(eap_pb, breaks = seq(-4, 4, 0.25), col = "#93c5fd", border = "white",
     main = "", xlab = "Perceptual aberration (theta)", ylab = "Respondents")
par(new = TRUE)
plot(theta, pmin(1 / sqrt(I_pb), 3), type = "l", lwd = 2.5, col = "#c2410c", ylim = c(0, 3),
     axes = FALSE, xlab = "", ylab = "")
axis(4, col.axis = "#c2410c"); mtext("Conditional SEM (capped at 3)", side = 4, line = 2.5, col = "#c2410c")
par(op)
