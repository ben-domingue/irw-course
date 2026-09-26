# The diffusion model with real data: lexical decision online (mturkddm_lexical),
# random-dot motion at five coherence levels (motion) and a licensure exam
# (credentialform_lnirt), all from the Item Response Warehouse. Needs lme4 (Bates,
# Maechler, Bolker & Walker, 2015) for the ability and speed estimates; EZ-diffusion
# (Wagenmakers, van der Maas & Grasman, 2007) is a few lines of base R.
# No login or token: every CSV link is pinned to one version of the IRW data.
# The licensure table is large (327,200 rows); reading it takes a minute.

## ---- ez
# EZ-diffusion: drift v, boundary separation alpha and non-decision time Ter from three
# numbers, the proportion correct and the mean and variance of correct response times.
# s is the SD of the within-trial noise; we use s = 1 (see the lesson).
ez <- function(pc, vrt, mrt, s = 1) {
  L <- qlogis(pc)
  x <- L * (L * pc^2 - L * pc + pc - 0.5) / vrt
  v <- sign(pc - 0.5) * s * x^(1/4)
  a <- s^2 * L / v
  y <- -v * a / s^2
  mdt <- (a / (2 * v)) * (1 - exp(y)) / (1 + exp(y))   # mean decision time
  c(v = v, alpha = a, ter = mrt - mdt)
}
# EZ for one set of trials. A perfect score has no logit, so it gets the usual
# edge correction (half an error); at exactly 0.5 accuracy EZ is undefined (NaN).
ez_trials <- function(resp, rt) {
  n <- length(resp); pc <- mean(resp)
  if (pc == 1) pc <- 1 - 1 / (2 * n)
  rc <- rt[resp == 1]
  c(n = n, pc = pc, ez(pc, var(rc), mean(rc)))
}
# Set aside responses under 0.3 s (fast guesses: accuracy is near chance below that
# in both speeded tables) and the slowest 1% of each table.
trim <- function(d) d[d$rt >= 0.3 & d$rt <= quantile(d$rt, 0.99), ]
# Error minus correct median time within each group of trials (a respondent, an item,
# a respondent at one condition), for groups with at least 5 errors.
within_gap <- function(d, by) {
  g <- sapply(split(d, by), function(x)
    if (sum(x$resp == 0) >= 5) median(x$rt[x$resp == 0]) - median(x$rt[x$resp == 1]) else NA)
  g[!is.na(g)]
}

## ---- fetch-lex
library(lme4)
options(digits = 7)  # R's default, in case a .Rprofile changes it
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.mturkddm_lexical/rows?format=csv"
lx <- read.csv(url)
# One row per trial; item is the letter string shown, resp is 1 for a correct
# word/nonword judgement, rt is in seconds. 136 invalid keypresses have no response.
lx <- lx[!is.na(lx$resp), ]
c(respondents = length(unique(lx$id)), strings = length(unique(lx$item)),
  trials_per_respondent = median(table(lx$id)))
round(c(accuracy = mean(lx$resp), median_s = median(lx$rt),
        share_under_0.3s = mean(lx$rt < 0.3), accuracy_under_0.3s = mean(lx$resp[lx$rt < 0.3]),
        slowest_1pct_from_s = unname(quantile(lx$rt, 0.99))), 3)
lx <- trim(lx)

## ---- errors-lex
# Are errors slower than correct responses? Pooled, and within each respondent.
gap_lx <- within_gap(lx, lx$id)
round(c(median_correct = median(lx$rt[lx$resp == 1]), median_error = median(lx$rt[lx$resp == 0]),
        within_respondent_gap = median(gap_lx), share_slower = mean(gap_lx > 0)), 3)

## ---- ez-lex
# EZ for each respondent, over all 480 of their trials (words and nonwords together).
pp <- as.data.frame(do.call(rbind, lapply(split(lx, lx$id), function(x) ez_trials(x$resp, x$rt))))
pp$id <- as.integer(names(split(lx, lx$id)))
round(sapply(pp[, c("pc", "v", "alpha", "ter")], quantile, c(0.1, 0.5, 0.9)), 2)

## ---- models-lex
# A Rasch-type ability (glmer with crossed random effects) and a speed (minus the
# respondent effect on log time, lmer), as in response-time. nAGQ = 0 skips glmer's
# slowest step.
m_acc <- glmer(resp ~ 1 + (1 | id) + (1 | item), lx, binomial, nAGQ = 0)
m_time <- lmer(log(rt) ~ 1 + (1 | id) + (1 | item), lx)
pp$theta <- ranef(m_acc)$id[as.character(pp$id), 1]
pp$speed <- -ranef(m_time)$id[as.character(pp$id), 1]
round(cor(pp[, c("v", "alpha", "ter", "theta", "speed")]), 2)

## ---- plot-lex
op <- par(mfrow = c(1, 2), mar = c(4, 4, 1, 1))
plot(pp$v, pp$theta, pch = 19, col = "#2780e3", xlab = "EZ drift v", ylab = "Ability (glmer)")
plot(pp$alpha, pp$speed, pch = 19, col = "#c2410c", xlab = "EZ boundary separation alpha", ylab = "Speed (lmer)")
par(op)

## ---- fetch-motion
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.motion/rows?format=csv"
mo <- read.csv(url)
# item is "<block> <coherence>": block 1-6 of the session, and the percentage of dots
# moving together (6, 12, 24, 48 or 100). Each respondent saw each item 10 times
# (trialnum), so 60 trials per coherence level. resp is 1 for the right direction.
mo$block <- as.integer(sub(" .*", "", mo$item))
mo$coherence <- as.integer(sub(".* ", "", mo$item))
c(respondents = length(unique(mo$id)), items = length(unique(mo$item)),
  trials_per_respondent = median(table(mo$id)))
round(c(accuracy = mean(mo$resp), median_s = median(mo$rt),
        share_under_0.3s = mean(mo$rt < 0.3), accuracy_under_0.3s = mean(mo$resp[mo$rt < 0.3]),
        slowest_1pct_from_s = unname(quantile(mo$rt, 0.99))), 3)
mo <- trim(mo)

## ---- ez-motion
# EZ for each respondent at each coherence level (about 60 trials), then the median
# across respondents. Alongside: accuracy, and median correct and error times.
cells <- split(mo, list(mo$id, mo$coherence))
pl <- as.data.frame(do.call(rbind, lapply(cells, function(x)
  c(id = x$id[1], coherence = x$coherence[1], ez_trials(x$resp, x$rt)))))
by_coh <- aggregate(cbind(pc, v, alpha, ter) ~ coherence, pl, median)
by_coh$median_correct <- tapply(mo$rt[mo$resp == 1], mo$coherence[mo$resp == 1], median)
by_coh$median_error <- tapply(mo$rt[mo$resp == 0], mo$coherence[mo$resp == 0], median)
round(by_coh, 2)

## ---- errors-motion
# Error minus correct median time within each respondent at each coherence level
# (cells with at least 5 errors), summarised by level.
mo$cell <- paste(mo$id, mo$coherence)
gap_mo <- within_gap(mo, mo$cell)
coh_of <- as.integer(sub(".* ", "", names(gap_mo)))
round(rbind(within_gap = tapply(gap_mo, coh_of, median),
            share_slower = tapply(gap_mo > 0, coh_of, mean),
            cells = tapply(gap_mo, coh_of, length)), 2)

## ---- plot-motion
op <- par(mfrow = c(1, 2), mar = c(4, 4, 1, 1))
lev <- factor(by_coh$coherence)
plot(seq_along(lev), by_coh$v, type = "b", pch = 19, col = "#2780e3", xaxt = "n",
     ylim = c(0, 3.2), xlab = "Coherence (%)", ylab = "EZ estimate (median)")
lines(seq_along(lev), by_coh$alpha, type = "b", pch = 17, col = "#c2410c")
axis(1, at = seq_along(lev), labels = levels(lev))
legend("topright", c("boundary alpha", "drift v"), col = c("#c2410c", "#2780e3"), pch = c(17, 19), bty = "n", horiz = TRUE)
plot(seq_along(lev), by_coh$median_error, type = "b", pch = 19, col = "#c2410c", xaxt = "n",
     ylim = c(0.8, 1.8), xlab = "Coherence (%)", ylab = "Median time (s)")
lines(seq_along(lev), by_coh$median_correct, type = "b", pch = 19, col = "#2780e3")
axis(1, at = seq_along(lev), labels = levels(lev))
legend("bottomleft", c("errors", "correct"), col = c("#c2410c", "#2780e3"), pch = 19, bty = "n")
par(op)

## ---- fetch-cf
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.credentialform_lnirt/rows?format=csv"
cf <- read.csv(url)
# As in response-time: the 170 scored items (171-200 are pilot items whose names
# depend on the pilot set), and times of 0 (under a second) set aside.
cf$inum <- as.integer(sub("iraw.", "", cf$item))
cf <- cf[cf$inum <= 170 & cf$rt > 0, ]
round(c(respondents = length(unique(cf$id)), accuracy = mean(cf$resp),
        median_s = median(cf$rt)), 2)

## ---- ez-cf
# EZ for each respondent over their 170 items: seconds, not fractions of a second.
pc_cf <- as.data.frame(do.call(rbind, lapply(split(cf, cf$id), function(x) ez_trials(x$resp, x$rt))))
round(c(median_v = median(pc_cf$v, na.rm = TRUE), median_alpha = median(pc_cf$alpha, na.rm = TRUE),
        median_ter_s = median(pc_cf$ter, na.rm = TRUE),
        share_ter_negative = mean(pc_cf$ter < 0, na.rm = TRUE),
        undefined_at_0.5 = sum(is.na(pc_cf$ter))), 3)
# Errors against correct responses, within each item.
gap_cf <- within_gap(cf, cf$item)
round(c(within_item_gap_s = median(gap_cf), share_slower = mean(gap_cf > 0)), 2)
