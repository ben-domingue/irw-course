# Person fit with real data: a licensure exam (credentialform_lnirt), the
# Eysenck Personality Inventory (psychtools_epi) and a matrix reasoning test
# (test_taking_much_2025_mr), all from the Item Response Warehouse. Needs mirt
# (Chalmers, 2012); the last chunk also uses PerFit (Tendeiro, Meijer & Niessen,
# 2016) to check the hand-computed statistics. No login or token: every CSV link
# is pinned to one version of the IRW data. The licensure fit takes about a
# minute, the others seconds.

## ---- functions
library(mirt)
options(digits = 7)  # R's default, in case a .Rprofile changes it

# l_z and Snijders's l_z* for the 2PL, from a response matrix X, item slopes a
# and difficulties b, and each respondent's maximum-likelihood theta.
# l_0 - E(l_0) is the sum over items of (x - P) * w, with w = log(P / (1 - P)).
# l_z* replaces w by its residual after taking out the part along the slopes
# (the direction the ML score equation has already set to zero). Outfit - 1 is
# also a weighted sum of residuals, with w = (1 - 2P) / (P (1 - P)), since for 0/1
# responses (x - P)^2 = P (1 - P) + (1 - 2P) (x - P); zout and zout_star are its
# standardized and corrected versions (positive = underfit).
lz_stats <- function(X, a, b, theta) {
  P <- plogis(sweep(outer(theta, b, "-"), 2, a, "*"))
  Q <- 1 - P
  A <- matrix(a, nrow(X), length(a), byrow = TRUE)
  wsum <- function(w) {
    cn <- rowSums(P * Q * w * A) / rowSums(P * Q * A^2)
    wt <- w - cn * A
    num <- rowSums((X - P) * w)
    cbind(num / sqrt(rowSums(P * Q * w^2)), num / sqrt(rowSums(P * Q * wt^2)))
  }
  L <- wsum(log(P / Q)); O <- wsum((1 - 2 * P) / (P * Q))
  data.frame(lz = L[, 1], lzstar = L[, 2], zout = O[, 1], zout_star = O[, 2])
}

# Normalized Guttman errors G*: order the items from easiest to hardest by
# proportion correct, count the pairs in which the easier item is wrong and the
# harder one right, and divide by the most there could be, r * (n - r).
gstar <- function(X) {
  X <- X[, order(-colMeans(X))]
  n <- ncol(X); r <- rowSums(X)
  errors <- apply(X, 1, function(x) sum(x * c(0, head(cumsum(1 - x), -1))))
  errors / (r * (n - r))
}

# Sijtsma's H^T: Loevinger's H with respondents in place of items. For each
# respondent, the covariance over items between their responses and everyone
# else's summed responses, over the most it could be given the respondents'
# proportions correct p: the sum over the others of min(p_n, p_m) - p_n p_m.
# For rows that are neither all 0 nor all 1.
ht <- function(X) {
  p <- rowMeans(X)
  others <- sweep(-X, 2, colSums(X), "+")
  num <- rowMeans((X - p) * (others - rowMeans(others)))
  ps <- sort(p)
  below <- findInterval(p, ps, left.open = TRUE)   # respondents with a lower p
  sum_min <- c(0, cumsum(ps))[below + 1] + p * (length(p) - below - 1)
  num / (sum_min - p * (sum(p) - p))
}

# Fit a 2PL, score every respondent with a sum score strictly between 0 and n by
# maximum likelihood, and compute every person-fit statistic in the lesson.
person_fit <- function(X) {
  set.seed(1)
  m <- mirt(X, 1, itemtype = "2PL", verbose = FALSE)
  ip <- coef(m, simplify = TRUE, IRTpars = TRUE)$items
  ok <- rowSums(X) > 0 & rowSums(X) < ncol(X)
  th <- fscores(m, method = "ML", max_theta = 10)[, 1]
  pf <- personfit(m, Theta = matrix(th))   # mirt's outfit, infit and Zh (= l_z)
  s <- lz_stats(X[ok, ], ip[, "a"], ip[, "b"], th[ok])
  list(model = m, ip = ip, ok = ok,
       res = data.frame(r = rowSums(X)[ok], theta = th[ok], s,
                        outfit = pf$outfit[ok], infit = pf$infit[ok], zh = pf$Zh[ok],
                        G = gstar(X[ok, ]), Ht = ht(X[ok, ])))
}
share_below <- function(z) round(mean(z < -1.645), 3)

## ---- fetch-cf
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v64_0.credentialform_lnirt/rows?format=csv"
cf <- read.csv(url)
# Items iraw.1-170 are the scored items. iraw.171-200 hold pilot items, and which
# pilot item sits under a name depends on the respondent's pilot set, so we keep
# the scored items only.
cf <- cf[cf$item %in% paste0("iraw.", 1:170), ]
X_cf <- xtabs(resp ~ id + item, cf)
X_cf <- unclass(X_cf)[, paste0("iraw.", 1:170)]
people_cf <- cf[!duplicated(cf$id), c("id", "Flagged", "Attempt", "Country")]
people_cf <- people_cf[match(rownames(X_cf), people_cf$id), ]
c(respondents = nrow(X_cf), items = ncol(X_cf), missing = sum(is.na(cf$resp)),
  flagged = sum(people_cf$Flagged), perfect_or_zero = sum(rowSums(X_cf) %in% c(0, 170)))

## ---- fit-cf
pf_cf <- person_fit(X_cf)
res_cf <- pf_cf$res
# l_z by hand matches mirt's Zh
all.equal(res_cf$lz, res_cf$zh)
round(c(sd_lz = sd(res_cf$lz), below_lz = share_below(res_cf$lz),
        sd_lzstar = sd(res_cf$lzstar), below_lzstar = share_below(res_cf$lzstar),
        above_lzstar = round(mean(res_cf$lzstar > 1.645), 3)), 3)

## ---- hist-cf
op <- par(mar = c(4, 4, 1, 1))
hist(res_cf$lzstar, breaks = 50, col = "#93c5fd", border = NA, freq = FALSE,
     main = "", xlab = "l_z* (licensure exam, 170 items)", xlim = c(-6, 5))
curve(dnorm(x), add = TRUE, lwd = 2, col = "#c2410c")
abline(v = -1.645, lty = 2, col = "#999")
par(op)

## ---- cor-cf
round(cor(res_cf[, c("lzstar", "lz", "infit", "outfit", "zout_star", "G", "Ht", "r")],
          method = "spearman")["lzstar", ], 2)

## ---- band-cf
# The statistics by sum-score band (fifths of the respondents): the SD of l_z and
# l_z*, the share of each below -1.645, and the mean of G* and H^T.
band5 <- cut(res_cf$r, quantile(res_cf$r, 0:5 / 5), include.lowest = TRUE)
with(res_cf, data.frame(
  n = as.vector(table(band5)),
  sd_lz = round(tapply(lz, band5, sd), 2), sd_lzstar = round(tapply(lzstar, band5, sd), 2),
  below_lz = round(tapply(lz < -1.645, band5, mean), 3),
  below_lzstar = round(tapply(lzstar < -1.645, band5, mean), 3),
  mean_G = round(tapply(G, band5, mean), 3), mean_Ht = round(tapply(Ht, band5, mean), 3)))

## ---- flagged-cf
flag <- people_cf$Flagged[pf_cf$ok]
data.frame(flagged = c(0, 1), n = as.vector(table(flag)),
           mean_score = round(tapply(res_cf$r, flag, mean), 1),
           mean_lzstar = round(tapply(res_cf$lzstar, flag, mean), 2),
           below = as.vector(tapply(res_cf$lzstar < -1.645, flag, sum)),
           share_below = round(tapply(res_cf$lzstar < -1.645, flag, mean), 3))

## ---- groups-cf
grp <- people_cf[pf_cf$ok, ]
grp$where <- ifelse(grp$Country %in% c("USA", "India", "Philippines"), grp$Country, "Other")
grp$attempt <- ifelse(grp$Attempt == "1", "first", "repeat")
summarize <- function(g) data.frame(
  n = as.vector(table(g)), mean_score = round(tapply(res_cf$r, g, mean), 1),
  mean_lzstar = round(tapply(res_cf$lzstar, g, mean), 2),
  above_1.645 = round(tapply(res_cf$lzstar > 1.645, g, mean), 3),
  below_1.645 = round(tapply(res_cf$lzstar < -1.645, g, mean), 3))
summarize(grp$where)
summarize(grp$attempt)
# Is it only the lower scores? Within score bands:
band <- cut(res_cf$r, c(0, 110, 125, 170))
round(tapply(res_cf$lzstar > 1.645, list(band, usa = grp$where == "USA"), mean), 3)

## ---- fetch-epi
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v64_0.psychtools_epi/rows?format=csv"
epi <- read.csv(url)
X_epi <- xtabs(resp ~ id + item, epi, addNA = TRUE, na.action = na.pass)
X_epi <- unclass(X_epi)
X_epi[unclass(xtabs(is.na(resp) ~ id + item, epi)) > 0] <- NA
# psychTools codes 1 = yes and 2 = no; the IRW table subtracts 1, so there 1 means
# "no". We turn it around once, here: from now on 1 = yes.
X_epi <- 1 - X_epi
# Scoring keys from psychTools (epi.keys). Every neuroticism item is keyed the same
# way; the Lie scale has three items keyed yes and six keyed no.
N_items <- paste0("V", c(2, 4, 7, 9, 11, 14, 16, 19, 21, 23, 26, 28, 31, 33, 35, 38,
                         40, 43, 45, 47, 50, 52, 55, 57))
L_yes <- paste0("V", c(6, 24, 36)); L_no <- paste0("V", c(12, 18, 30, 42, 48, 54))
lie <- rowSums(X_epi[, L_yes]) + rowSums(1 - X_epi[, L_no])
XN <- X_epi[, N_items]
complete <- rowSums(is.na(XN)) == 0 & !is.na(lie)
c(respondents = nrow(XN), complete = sum(complete), missing_responses = sum(is.na(epi$resp)))
XN <- XN[complete, ]; lie <- lie[complete]
table(score = cut(rowSums(XN), c(-1, 0, 23, 24), labels = c("0", "1-23", "24")))

## ---- fit-epi
pf_epi <- person_fit(XN)
res_epi <- pf_epi$res
res_epi$lie <- lie[pf_epi$ok]
round(c(n = nrow(res_epi), sd_lz = sd(res_epi$lz), below_lz = share_below(res_epi$lz),
        sd_lzstar = sd(res_epi$lzstar), below_lzstar = share_below(res_epi$lzstar)), 3)

## ---- lie-epi
lie_band <- cut(res_epi$lie, c(-1, 2, 4, 9), labels = c("Lie 0-2", "Lie 3-4", "Lie 5-9"))
data.frame(n = as.vector(table(lie_band)),
           mean_N_score = round(tapply(res_epi$r, lie_band, mean), 1),
           mean_lzstar = round(tapply(res_epi$lzstar, lie_band, mean), 2),
           share_below = round(tapply(res_epi$lzstar < -1.645, lie_band, mean), 3))
# The same gradient is not a score effect: the share flagged by neuroticism score band
score_band <- cut(res_epi$r, c(0, 6, 12, 18, 23))
round(tapply(res_epi$lzstar < -1.645, score_band, mean), 3)
round(tapply(res_epi$lzstar < -1.645, list(score_band, lie_band), mean), 3)

## ---- fetch-mr
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_2:v25_0.test_taking_much_2025_mr/rows?format=csv"
mr <- read.csv(url)
# Y_MRm01 and Y_MRt01-t06 are the tutorial and training items; the 20 test items
# come in two blocks of ten (suffixes _01 and _02), one answered under an
# instruction to be accurate and one under an instruction to be fast.
mr <- mr[grepl("^Y_MR[0-9]", mr$item), ]
X_mr <- unclass(xtabs(resp ~ id + item, mr))
X_mr[unclass(xtabs(~ id + item, mr)) == 0] <- NA
people_mr <- mr[!duplicated(mr$id), c("id", "cov_ac", "cov_disruptions")]
people_mr <- people_mr[match(rownames(X_mr), people_mr$id), ]
complete <- rowSums(is.na(X_mr)) == 0
X_mr <- X_mr[complete, ]; people_mr <- people_mr[complete, ]
r_mr <- rowSums(X_mr)
c(respondents = nrow(X_mr), score_0 = sum(r_mr == 0), share_0 = round(mean(r_mr == 0), 3),
  score_20 = sum(r_mr == 20))

## ---- zeros-mr
# The study coded what respondents reported at the end into categories
# (cov_disruptions). Scores of 0 by category:
tab <- table(people_mr$cov_disruptions, zero = r_mr == 0)
tab[order(-tab[, "TRUE"]), ]

## ---- fit-mr
pf_mr <- person_fit(X_mr)
res_mr <- pf_mr$res
res_mr$report <- people_mr$cov_disruptions[pf_mr$ok]
res_mr$checks <- people_mr$cov_ac[pf_mr$ok]
round(c(n = nrow(res_mr), sd_lzstar = sd(res_mr$lzstar),
        below_lzstar = share_below(res_mr$lzstar)), 3)
rep_group <- ifelse(res_mr$report == "no issues", "no issues",
             ifelse(grepl("understanding", res_mr$report), "lack of understanding", "other issues"))
data.frame(n = as.vector(table(rep_group)),
           mean_score = round(tapply(res_mr$r, rep_group, mean), 1),
           mean_lzstar = round(tapply(res_mr$lzstar, rep_group, mean), 2),
           share_below = round(tapply(res_mr$lzstar < -1.645, rep_group, mean), 3))
data.frame(checks_passed = sort(unique(res_mr$checks)),
           n = as.vector(table(res_mr$checks)),
           mean_lzstar = round(tapply(res_mr$lzstar, res_mr$checks, mean), 2))

## ---- perfit-cf
# The same statistics from PerFit, given mirt's item parameters and abilities.
library(PerFit)
ok <- pf_cf$ok
ip3 <- cbind(pf_cf$ip[, "a"], pf_cf$ip[, "b"], 0)   # PerFit wants a, b and c columns
pf_lzs <- lzstar(X_cf[ok, ], IP = ip3, IRT.PModel = "2PL",
                 Ability = res_cf$theta, Ability.PModel = "ML")$PFscores$PFscores
pf_G <- Gnormed(X_cf[ok, ])$PFscores$PFscores
pf_Ht <- Ht(X_cf[ok, ])$PFscores$PFscores
round(c(max_diff_lzstar = max(abs(pf_lzs - res_cf$lzstar)),
        max_diff_G = max(abs(pf_G - res_cf$G)),
        max_diff_Ht = max(abs(pf_Ht - res_cf$Ht))), 4)
