# Trials as items with real data: brightness discrimination (rr98_accuracy),
# cross-modal mental rotation (mentalrotation_wolf_2024) and the Stroop task given
# twice (enkavi_2019_stroop), all from the Item Response Warehouse. Needs lme4
# (Bates, Maechler, Bolker & Walker, 2015). No login or token: every CSV link is
# pinned to one version of the IRW data, as on each table's landing page.
# The rr98 and Stroop fits take a few seconds each; the mental rotation
# cross-validation (60 small glmer fits) about half a minute.
# Adapted from ben-domingue/252: c9/mrot.R (angle as a predictor, compared out of
# sample with the IMV). The rr98 and Stroop analyses are new for this course.

## ---- helpers
library(lme4)
options(digits = 7)  # R's default, in case a .Rprofile changes it
# The IMV (Domingue et al., 2024): coin() turns a mean log likelihood into the
# weight w >= 0.5 of a coin with the same expected log likelihood per toss, and
# imv() is the expected return, (w1 - w0) / w0, of betting with the better coin.
coin <- function(ll) {
  if (ll <= log(0.5)) return(0.5)
  uniroot(function(w) w * log(w) + (1 - w) * log(1 - w) - ll, c(0.5, 1 - 1e-12), tol = 1e-12)$root
}
mean_ll <- function(y, p) mean(y * log(p) + (1 - y) * log(1 - p))
imv <- function(y, p0, p1) (coin(mean_ll(y, p1)) - coin(mean_ll(y, p0))) / coin(mean_ll(y, p0))
# k-fold cross-validation over trials. fit(formula, data) returns a model whose
# predict(type = "response") gives probabilities for held-out rows. Returns the
# IMV of each model over the first one, averaged over folds.
cv_imv <- function(d, formulas, fit, k = 10, seed = 1) {
  set.seed(seed)
  fold <- sample(rep(1:k, length.out = nrow(d)))
  P <- sapply(formulas, function(f) {
    p <- numeric(nrow(d))
    for (i in 1:k) p[fold == i] <- predict(fit(f, d[fold != i, ]), d[fold == i, ],
                                           type = "response", allow.new.levels = TRUE)
    p
  })
  sapply(names(formulas)[-1], function(m)
    round(mean(sapply(1:k, function(i) imv(d$resp[fold == i], P[fold == i, 1], P[fold == i, m]))), 4))
}

## ---- rr98-fetch
rr <- read.csv("https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.rr98_accuracy/rows?format=csv")
rr$level <- as.integer(sub("i ", "", rr$item))   # brightness, 0 (black) to 32 (white)
rr$observer <- sub(" .*", "", rr$id)             # "jf 2" is observer jf's second session
rr$dist <- abs(rr$level - 16)                    # distance from the middle level
c(trials = nrow(rr), observers = length(unique(rr$observer)), sessions = length(unique(rr$id)),
  levels = length(unique(rr$level)))

## ---- rr98-levels
p_level <- tapply(rr$resp, rr$level, mean)
round(p_level[c("0", "8", "15", "16", "17", "24", "32")], 2)
plot(as.integer(names(p_level)), p_level, pch = 19, col = "#2780e3", ylim = c(0.4, 1),
     xlab = "Brightness level (0 = all black, 32 = all white)", ylab = "Proportion correct")
abline(h = 0.5, lty = 2, col = "grey60")

## ---- rr98-models
# Observers and their sessions are crossed with the levels: every session meets
# every level many times. Three accounts of the levels:
#   per_level: one easiness for each of the 33 levels (the Rasch-style description)
#   symmetric: one for each distance from the middle (17)
#   distance:  a straight line in distance from the middle (2)
m_level <- glmer(resp ~ 0 + factor(level) + (1 | observer) + (1 | id), rr, binomial)
m_sym   <- glmer(resp ~ 0 + factor(dist) + (1 | observer) + (1 | id), rr, binomial)
m_dist  <- glmer(resp ~ dist + (1 | observer) + (1 | id), rr, binomial)
round(fixef(m_dist), 2)
anova(m_dist, m_sym, m_level)
# Share of the variance in the 33 level easinesses the straight line accounts for
e <- fixef(m_level)
pred <- fixef(m_dist)[1] + fixef(m_dist)[2] * abs(0:32 - 16)
round(cor(e, pred)^2, 2)

## ---- rr98-imv
# Out of sample: which account of the levels predicts held-out trials best?
# (glm, without the session effects, which are tiny; see below.)
cv_imv(rr, list(mean = resp ~ 1, distance = resp ~ dist, symmetric = resp ~ factor(dist),
                per_level = resp ~ factor(level)),
       function(f, d) glm(f, binomial, d))

## ---- rr98-people
VarCorr(m_level)
round(tapply(rr$resp, rr$observer, mean), 3)
round(range(tapply(rr$resp, rr$id, mean)), 2)   # the 30 sessions

## ---- mrot-fetch
mr <- read.csv("https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.mentalrotation_wolf_2024/rows?format=csv")
mr$angle50 <- mr$itemcov_angle / 50               # angle in steps of 50 degrees
c(trials = nrow(mr), respondents = length(unique(mr$id)), items = length(unique(mr$item)),
  trials_per_respondent = nrow(mr) / length(unique(mr$id)))
table(pairs_per_item = table(paste(mr$id, mr$item)))   # each respondent meets each item twice
round(tapply(mr$resp, mr$itemcov_angle, mean), 2)

## ---- mrot-angle
ctl <- glmerControl(optimizer = "bobyqa")
m_angle <- glmer(resp ~ angle50 + (1 | id), mr, binomial, control = ctl)
round(summary(m_angle)$coefficients, 3)

## ---- mrot-pair
# resp_raw is the answer given ("s" same, "d" different) and resp whether it was
# right, so together they say which kind of pair was on the table.
mr$pair <- ifelse(mr$resp == 1, mr$resp_raw, ifelse(mr$resp_raw == "s", "d", "s"))
mr$pair <- factor(ifelse(mr$pair == "s", "same", "different"), levels = c("same", "different"))
table(mr$pair)
round(tapply(mr$resp, list(angle = mr$itemcov_angle, pair = mr$pair), mean), 2)
m_pair <- glmer(resp ~ angle50 * pair + (1 | id), mr, binomial, control = ctl)
round(summary(m_pair)$coefficients, 3)

## ---- mrot-imv
# Each model's IMV over a model with respondents only, from 10-fold
# cross-validation over trials.
fit_glmer <- function(f, d) glmer(f, d, binomial, control = ctl)
cv_imv(mr, list(respondents = resp ~ 1 + (1 | id),
                angle = resp ~ angle50 + (1 | id),
                per_angle = resp ~ factor(itemcov_angle) + (1 | id),
                angle_shape = resp ~ angle50 + factor(itemcov_shape) + (1 | id),
                random_item = resp ~ 1 + (1 | item) + (1 | id),
                angle_by_pair = resp ~ angle50 * pair + (1 | id)),
       fit_glmer)

## ---- stroop-fetch
st <- read.csv("https://redivis.com/api/v1/tables/datapages.item_response_warehouse_3:v8_0.enkavi_2019_stroop/rows?format=csv")
st$inc <- as.integer(st$itemcov_condition == "incongruent")
table(item = st$item, condition = st$itemcov_condition)[, ]
c(respondents = length(unique(st$id)), retested = length(unique(st$id[st$wave == 2])))
round(tapply(st$resp, list(incongruent = st$inc, wave = st$wave), mean), 3)
# Response times of correct trials with a recorded time
ok <- st[st$resp == 1 & !is.na(st$rt), ]
summary(as.vector(table(ok$id[ok$wave == 1], ok$inc[ok$wave == 1])))   # trials per condition

## ---- stroop-effect
# Each respondent's mean RT per condition, and the effect (incongruent - congruent)
by_person <- function(d) {
  m <- tapply(d$rt, list(d$id, d$inc), mean)
  data.frame(id = rownames(m), congruent = m[, 1], incongruent = m[, 2],
             effect = m[, 2] - m[, 1], mean_rt = (m[, 1] + m[, 2]) / 2)
}
w1 <- by_person(ok[ok$wave == 1, ])
round(colMeans(w1[, -1]), 3)
round(c(sd_effect = sd(w1$effect), t = mean(w1$effect) / (sd(w1$effect) / sqrt(nrow(w1))),
        n = nrow(w1), positive = sum(w1$effect > 0)), 3)

## ---- stroop-model
# Where the variance lives, at wave 1: a random intercept (speed) and a random
# slope (the person's Stroop effect) for each respondent, and trial noise.
s1 <- lmer(rt ~ inc + (1 + inc | id), ok[ok$wave == 1, ], REML = FALSE)
round(fixef(s1), 3)
VarCorr(s1)
tau <- attr(VarCorr(s1)$id, "stddev"); sig <- sigma(s1); L <- 47
# Reliability of each respondent's observed effect and mean RT with L trials per
# condition (the Go deeper callout derives these)
round(c(effect = tau[[2]]^2 / (tau[[2]]^2 + 2 * sig^2 / L),
        mean_rt = tau[[1]]^2 / (tau[[1]]^2 + sig^2 / (2 * L))), 2)
# Trials per condition for a reliability of 0.9 in the effect
round(2 * sig^2 * 0.9 / (tau[[2]]^2 * (1 - 0.9)))

## ---- stroop-retest
w2 <- by_person(ok[ok$wave == 2, ])
b <- merge(w1, w2, by = "id", suffixes = c("_1", "_2"))
nrow(b)
round(c(effect = cor(b$effect_1, b$effect_2), mean_rt = cor(b$mean_rt_1, b$mean_rt_2),
        congruent = cor(b$congruent_1, b$congruent_2),
        incongruent = cor(b$incongruent_1, b$incongruent_2)), 2)
round(c(effect_positive_wave2 = mean(b$effect_2 > 0)), 2)

## ---- stroop-latent
# The same question inside the model: each respondent has a true speed and a true
# effect at each wave, and the model estimates how those correlate across waves,
# with trial noise set aside.
ok2 <- ok[ok$id %in% b$id, ]
ok2$w1 <- as.integer(ok2$wave == 1); ok2$w2 <- 1 - ok2$w1
s12 <- lmer(rt ~ 0 + factor(wave) + inc:factor(wave) + (0 + w1 + w2 | id) +
              (0 + w1:inc + w2:inc | id), ok2, REML = FALSE)
VarCorr(s12)
