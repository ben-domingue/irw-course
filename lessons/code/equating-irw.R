# Linking and equating with real data: TIMSS 2011 grade 4 mathematics in Austria
# (cdm_timss11) and one PIRLS 2011 reading booklet in four countries
# (pirlsmissing_sirt), from the Item Response Warehouse. Runs as-is in R with the
# mirt, equate and lme4 packages (equateIRT for one cross-check); no login or token.
# The position-effect model takes about a minute; everything else, seconds.
# Adapted from ben-domingue/252: c6/equate-obsscore.R, c6/equate-irt.R, c6/concurrent.R.

## ---- fetch-timss
library(mirt)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/)
# with a CSV download. This link is pinned to one version of the data.
timss_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0.cdm_timss11/rows?format=csv"
tm <- read.csv(timss_url)
# resp is 1 for a correct answer. Each student took one of 14 booklets.
long2wide <- function(df) {
  wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  as.data.frame(wide[, order(colnames(wide))])
}
booklet <- tapply(tm$booklet, tm$id, function(x) x[1])   # one booklet per student
score   <- tapply(tm$resp, tm$id, sum)                    # sum score on that booklet
ib <- table(tm$item, tm$booklet) > 0                      # item x booklet: is the item in it?
c(students = length(booklet), items = nrow(ib), booklets_per_item = unique(rowSums(ib)))
# Did every student answer every item in their booklet?
all(table(tm$id)[names(booklet)] == colSums(ib)[as.character(booklet)])
data.frame(booklet = 1:14, students = as.vector(table(booklet)), items = colSums(ib),
           mean_score = round(as.vector(tapply(score, booklet, mean)), 1))
# Items shared by each booklet and the next (booklet 14 and booklet 1 close the ring)
sapply(1:14, function(k) sum(ib[, k] & ib[, k %% 14 + 1]))

## ---- random-groups
library(equate)
# Booklets 11 and 13 share no items. Their groups are randomly equivalent, so
# observed-score equating needs no common items: match the score distributions.
x <- score[booklet == 11]; y <- score[booklet == 13]
round(c(n_11 = length(x), mean_11 = mean(x), sd_11 = sd(x),
        n_13 = length(y), mean_13 = mean(y), sd_13 = sd(y)), 1)
fx <- freqtab(x, scales = 0:26); fy <- freqtab(y, scales = 0:26)
eq_mean   <- equate(fx, fy, type = "mean")
eq_linear <- equate(fx, fy, type = "linear")
eq_equip  <- equate(fx, fy, type = "equipercentile")
# Equipercentile after log-linear presmoothing that keeps each distribution's
# first three moments (Holland & Thayer, 2000)
eq_smooth <- equate(fx, fy, type = "equipercentile", smoothmethod = "loglinear", degrees = list(3, 3))
conv <- data.frame(score_11 = 0:26, mean = eq_mean$concordance$yx, linear = eq_linear$concordance$yx,
                   equipercentile = eq_equip$concordance$yx, smoothed = eq_smooth$concordance$yx)
round(conv[conv$score_11 %in% c(2, 4, 8, 12, 16, 20, 24), ], 1)

## ---- concurrent
# One concurrent 2PL fit: all 14 booklets stacked, each student's unseen items
# missing by design. The common items put every booklet on one scale.
resp <- long2wide(tm)
fit2 <- mirt(resp, 1, itemtype = "2PL", verbose = FALSE)
cf <- coef(fit2, simplify = TRUE)$items          # mirt's a*theta + d; b = -d/a
tcc <- function(theta, items) sum(plogis(cf[items, "a1"] * theta + cf[items, "d"]))
# IRT true-score equating: find the theta whose expected score on booklet 11 is x,
# then report that theta's expected score on booklet 13.
items_11 <- rownames(ib)[ib[, "11"]]; items_13 <- rownames(ib)[ib[, "13"]]
true_score <- sapply(1:25, function(s) {
  th <- uniroot(function(t) tcc(t, items_11) - s, c(-15, 15))$root
  tcc(th, items_13)
})
compare <- data.frame(score_11 = 1:25, irt_true_score = true_score,
                      equipercentile = conv$smoothed[2:26])
compare$difference <- compare$irt_true_score - compare$equipercentile
round(compare[compare$score_11 %in% c(2, 4, 8, 12, 16, 20, 24), ], 1)
# Largest gap between the two methods where most students are (scores 6 to 18)
round(max(abs(compare$difference[compare$score_11 %in% 6:18])), 2)

## ---- ring
# Calibrate each booklet on its own (Rasch; mirt centres each group's abilities at 0),
# then link booklet k+1 to booklet k by mean-mean linking through their common block:
# the shift is the mean difficulty of the common items in k minus that in k+1.
calib <- lapply(1:14, function(k) {
  m <- mirt(long2wide(tm[tm$booklet == k, ]), 1, itemtype = "Rasch", verbose = FALSE)
  d <- coef(m, simplify = TRUE)$items[, "d"]
  -d                                               # Rasch: b = -d
})
shift <- sapply(1:14, function(k) {
  k2 <- k %% 14 + 1
  common <- intersect(names(calib[[k]]), names(calib[[k2]]))
  mean(calib[[k]][common]) - mean(calib[[k2]][common])
})
round(shift, 2)
# Go round the ring, 1 -> 2 -> ... -> 14 -> 1: booklet 1 should end where it started.
round(sum(shift), 2)    # the gap after 14 links
sum(shift > 0)          # how many links shift the same way

## ---- position
library(lme4)
# In booklet k the block shared with booklet k-1 comes first and the block shared
# with booklet k+1 second (TIMSS 2011 Assessment Frameworks, Exhibit 11). Mark each
# response by whether its block is the booklet's second mathematics block.
first_in <- apply(ib, 1, function(r) { w <- which(r); if (all(w == c(1, 14))) 1 else max(w) })
tm$second <- as.integer(tm$booklet != first_in[tm$item])
# Odd booklets put mathematics in part 1 (block positions 1-2), even booklets in
# part 2 (positions 3-4), after the break.
tm$position <- ifelse(tm$booklet %% 2 == 1, 1, 3) + tm$second
table(position = tm$position)
# A Rasch model as a mixed logistic regression: one fixed effect per item, a random
# effect per student, and a shift for the second block (Debeer & Janssen, 2013).
pos1 <- glmer(resp ~ 0 + item + second + (1 | id), data = tm, family = binomial, nAGQ = 0)
round(coef(summary(pos1))["second", 1:2], 3)
# The same with each position separately. Each item sits at positions 1 and 4, or 2
# and 3, so the model compares 4 with 1 and 2 with 3.
pos2 <- glmer(resp ~ 0 + item + factor(position) + (1 | id), data = tm, family = binomial, nAGQ = 0)
round(coef(summary(pos2))[c("factor(position)4", "factor(position)2"), 1:2], 3)

## ---- fetch-pirls
pirls_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0.pirlsmissing_sirt/rows?format=csv"
pr <- read.csv(pirls_url)
# resp is 1 for a correct answer; blank for missing by intention and not reached,
# which we leave missing (not wrong). wt is the student weight, unused here.
country <- tapply(pr$country, pr$id, function(x) x[1])
pw <- long2wide(pr)
ncol(pw)                         # items
round(mean(is.na(pr$resp)), 2)   # share of responses missing
data.frame(students = as.vector(table(country)),
           prop_correct = round(as.vector(tapply(rowMeans(pw, na.rm = TRUE), country, mean)), 2),
           row.names = names(table(country)))

## ---- link-pirls
# A separate 2PL for each country; each fit sets its own country's mean to 0 and SD to 1.
pfit <- lapply(c(AUT = "AUT", DEU = "DEU", FRA = "FRA", NLD = "NLD"),
               function(k) mirt(pw[country == k, ], 1, itemtype = "2PL", verbose = FALSE))
ab <- lapply(pfit, function(m) coef(m, IRTpars = TRUE, simplify = TRUE)$items[, c("a", "b")])
# Put form X (a country) on the scale of form Y (Austria): theta_Y = A theta_X + B,
# so b -> A b + B and a -> a / A.
grid_th <- seq(-4, 4, length.out = 81); w_th <- dnorm(grid_th)   # quadrature on Austria's scale
icc <- function(a, b) plogis(outer(grid_th, b, "-") * rep(a, each = length(grid_th)))
link <- function(X, Y, method) {
  aX <- X[, "a"]; bX <- X[, "b"]; aY <- Y[, "a"]; bY <- Y[, "b"]
  if (method == "mean-mean")  { A <- mean(aX) / mean(aY); return(c(A = A, B = mean(bY) - A * mean(bX))) }
  if (method == "mean-sigma") { A <- sd(bY) / sd(bX);     return(c(A = A, B = mean(bY) - A * mean(bX))) }
  PY <- icc(aY, bY)
  loss <- function(p) {
    PX <- icc(aX / p[1], p[1] * bX + p[2])
    if (method == "Haebara") sum(w_th * rowSums((PY - PX)^2))       # item by item
    else sum(w_th * (rowSums(PY) - rowSums(PX))^2)                   # Stocking-Lord: the sums
  }
  setNames(optim(c(1, 0), loss)$par, c("A", "B"))
}
methods <- c("mean-mean", "mean-sigma", "Haebara", "Stocking-Lord")
# B is each country's mean in Austrian SD units; A is its SD relative to Austria's.
B <- sapply(c("DEU", "FRA", "NLD"), function(k) sapply(methods, function(m) link(ab[[k]], ab$AUT, m)["B"]))
A <- sapply(c("DEU", "FRA", "NLD"), function(k) sapply(methods, function(m) link(ab[[k]], ab$AUT, m)["A"]))
rownames(B) <- rownames(A) <- methods
round(B, 2)
round(A, 2)
# Cross-check with the equateIRT package (Battauz, 2015): Stocking-Lord for Germany
library(equateIRT)
mods <- modIRT(coef = lapply(ab, function(x) cbind(b = x[, "b"], a = x[, "a"])),
               names = names(ab), ltparam = FALSE, display = FALSE)
round(unlist(direc(mods = mods, which = c("DEU", "AUT"), method = "Stocking-Lord")[c("A", "B")]), 2)

## ---- pirls-items
# After Stocking-Lord linking, how far does each item's difficulty in the Netherlands
# sit from its difficulty in Austria? Linking assumes these differences are noise.
item_gap <- function(k) {
  p <- link(ab[[k]], ab$AUT, "Stocking-Lord")
  (p["A"] * ab[[k]][, "b"] + p["B"]) - ab$AUT[, "b"]
}
gap_nld <- item_gap("NLD")
round(range(gap_nld), 2)
sapply(c(DEU = "DEU", FRA = "FRA", NLD = "NLD"), function(k) sum(abs(item_gap(k)) > 0.5))
# Drop the Dutch items more than 0.5 logits out and link again on the rest
keep <- names(gap_nld)[abs(gap_nld) <= 0.5]
round(link(ab$NLD[keep, ], ab$AUT[keep, ], "Stocking-Lord"), 2)
