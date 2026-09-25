# What does a score mean? Norms, error bands, change and cut scores for the PHQ-9,
# with real data from the Item Response Warehouse: a UK panel in spring 2020
# (c19prc_uk_mcbride_2021_phq9) and a German general-population survey from 2012
# (coroiu_2018_phq9). Runs as-is in R with the mirt package; no login or token.

## ---- fetch
library(mirt)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/) with a
# CSV download. These links are pinned to one version of the data.
uk_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_4:v7_0.c19prc_uk_mcbride_2021_phq9/rows?format=csv"
de_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_6:v3_4.coroiu_2018_phq9/rows?format=csv"
uk <- read.csv(uk_url)
# Keying: every item is 0 (not at all) to 3 (nearly every day); higher = more
# frequent symptoms, and none is reversed. The panel has six waves; wave 1 is the
# March 2020 baseline and wave 2 the follow-up a month later.
table(uk$wave[!duplicated(paste(uk$id, uk$wave))])     # respondents per wave
long2wide <- function(df) {
  wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  as.data.frame(wide[, order(colnames(wide))])
}
w1 <- long2wide(uk[uk$wave == 1, ])
age <- tapply(uk$cov_age, uk$id, function(x) x[1])[rownames(w1)]
c(respondents = nrow(w1), complete = sum(complete.cases(w1)))

## ---- sanity
# Check the pipeline against the published figures for wave 1 (Shevlin et al., 2020).
x <- rowSums(w1)
alpha <- function(X) { k <- ncol(X); k / (k - 1) * (1 - sum(apply(X, 2, var)) / var(rowSums(X))) }
skew <- function(v) mean((v - mean(v))^3) / sd(v)^3
round(c(mean = mean(x), sd = sd(x), skew = skew(x), share_zero = mean(x == 0),
        share_10_plus = mean(x >= 10), alpha = alpha(w1)), 3)

## ---- norms
# Percentile rank: the percentage scoring below, plus half of those scoring exactly
# the same (the midpoint convention). It uses only the order of the scores.
pr <- function(score, ref) 100 * (mean(ref < score) + mean(ref == score) / 2)
band <- cut(age, c(17, 34, 54, Inf), labels = c("18-34", "35-54", "55+"))
groups <- c(list("UK, all" = x), split(x, band))
round(t(sapply(groups, function(g) c(n = length(g), mean = mean(g),
  share_10_plus = mean(g >= 10), pr_of_10 = pr(10, g)))), 2)

## ---- german
de <- read.csv(de_url)
wde <- long2wide(de)
xde <- rowSums(wde[complete.cases(wde), ])    # 43 respondents skipped an item
round(c(n = length(xde), mean = mean(xde), sd = sd(xde),
        share_10_plus = mean(xde >= 10), pr_of_10 = pr(10, xde)), 3)

## ---- tscores
# A linear T keeps the raw distribution's shape; a normalized T forces it to be normal.
linear_T     <- function(score, ref) 50 + 10 * (score - mean(ref)) / sd(ref)
normalized_T <- function(score, ref) 50 + 10 * qnorm(pr(score, ref) / 100)
round(sapply(c(0, 5, 10, 20), function(s)
  c(raw = s, pr = pr(s, x), linear_T = linear_T(s, x), normalized_T = normalized_T(s, x))), 1)

## ---- ctt-band
# One SEM for everyone, and a 95% band of 1.96 SEM either side of each score.
sem <- sd(x) * sqrt(1 - alpha(w1))
pos <- x >= 10                                     # screened positive
round(c(sem = sem, half_width = 1.96 * sem,
        positives = sum(pos), band_reaches_cut = mean(x[pos] - 1.96 * sem <= 10)), 3)

## ---- grm
# The graded response model: one slope per item and a boundary between each pair of
# adjacent categories. mirt writes each boundary as a*theta + d_k.
set.seed(61)
grm <- mirt(w1, 1, itemtype = "graded", verbose = FALSE)
round(coef(grm, simplify = TRUE)$items, 2)
# The cut on the theta scale: where the expected PHQ-9 score (the test characteristic
# curve) reaches 10.
tcc <- function(t) expected.test(grm, matrix(t))
theta_cut <- uniroot(function(t) tcc(t) - 10, c(-4, 4))$root
csem <- function(t) 1 / sqrt(testinfo(grm, matrix(t)))
round(c(theta_cut = theta_cut, csem_at_cut = csem(theta_cut),
        csem_at_0 = csem(0), csem_at_minus_1 = csem(-1), csem_at_minus_2 = csem(-2)), 2)

## ---- raw-csem
# The same precision on the raw-score scale: the SD of the PHQ-9 sum for respondents
# at a given theta, from the model's category probabilities.
raw_csem <- function(t) {
  v <- sapply(1:9, function(i) {
    p <- probtrace(extract.item(grm, i), matrix(t))
    sum((0:3)^2 * p) - sum((0:3) * p)^2
  })
  sqrt(sum(v))
}
at <- sapply(c(1, 3, 5, 10, 15, 20, 25), function(s) uniroot(function(t) tcc(t) - s, c(-6, 6))$root)
# The two scales are linked by the slope of the test characteristic curve: an error of
# SE points in the score is an error of about SE / slope on theta. Where the curve is
# flat (near the floor and the ceiling), a small band in points is a wide band in theta.
slope <- sapply(at, function(t) (tcc(t + 0.001) - tcc(t - 0.001)) / 0.002)
round(rbind(raw = c(1, 3, 5, 10, 15, 20, 25), theta = at,
            model_sem_raw = sapply(at, raw_csem), ctt_sem_raw = sem,
            tcc_slope = slope, sem_raw_over_slope = sapply(at, raw_csem) / slope,
            csem_theta = sapply(at, csem)), 2)

## ---- irt-band
# Bands on the theta scale: each respondent's estimate (EAP, mirt's default) plus or
# minus 1.96 conditional SEMs. How many positives have a band that reaches the cut?
th <- fscores(grm, verbose = FALSE)[, 1]
round(c(band_reaches_cut = mean(th[pos] - 1.96 * csem(th[pos]) <= theta_cut)), 3)

## ---- change
w2 <- long2wide(uk[uk$wave == 2, ])
both <- intersect(rownames(w1), rownames(w2))
x1 <- rowSums(w1[both, ]); x2 <- rowSums(w2[both, ])
r12 <- cor(x1, x2); a1 <- alpha(w1[both, ]); a2 <- alpha(w2[both, ])
# Reliability of the difference x2 - x1 (true-score variance of the difference over
# its observed variance)
rel_diff <- (a1 * var(x1) + a2 * var(x2) - 2 * cov(x1, x2)) / var(x2 - x1)
rci <- 1.96 * sqrt(2) * sem              # reliable change: |x2 - x1| at least this
dx <- x2 - x1
crossed <- (x1 >= 10) != (x2 >= 10)
round(c(n = length(both), r = r12, alpha_1 = a1, alpha_2 = a2, rel_diff = rel_diff,
        rci_threshold = rci, reliable_change = mean(abs(dx) >= rci),
        crossed_cut = mean(crossed), crossed_by_less = mean(crossed & abs(dx) < rci)), 3)

## ---- pv
# Estimates versus plausible values. EAPs are pulled toward the mean; plausible values
# are draws from each respondent's posterior, so across respondents they keep the
# spread of the population.
set.seed(61)
pv <- fscores(grm, plausible.draws = 20, verbose = FALSE)
round(c(sd_eap = sd(th), sd_pv = mean(sapply(pv, function(p) sd(p[, 1]))),
        above_cut_eap = mean(th >= theta_cut),
        above_cut_pv = mean(sapply(pv, function(p) mean(p[, 1] >= theta_cut))),
        observed_10_plus = mean(x >= 10)), 3)
