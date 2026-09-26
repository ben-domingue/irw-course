# Response time and accuracy with real data: a licensure exam (credentialform_lnirt),
# a lexical decision task (roar_lexical) and Raven's Advanced Progressive Matrices,
# timed and untimed (rapm_poulton_2022_timed, rapm_poulton_2022_untimed), all from
# the Item Response Warehouse. Needs lme4 (Bates, Maechler, Bolker & Walker, 2015).
# No login or token: every CSV link is pinned to one version of the IRW data.
# The licensure fits take about a minute each, the others seconds.
# Adapted from ben-domingue/252: ps9/sat.R (PS9#1).

## ---- fetch-cf
library(lme4)
options(digits = 7)  # R's default, in case a .Rprofile changes it
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.credentialform_lnirt/rows?format=csv"
cf <- read.csv(url)
# One row per response; resp is 1 for a correct answer, rt the time on the item in
# whole seconds. Items iraw.1-170 are the scored items, which everyone answered.
# iraw.171-200 hold pilot items, and which pilot items sit under a name depends on
# the respondent's pilot set (Pretest), so we keep the scored items only.
cf$inum <- as.integer(sub("iraw.", "", cf$item))
cf <- cf[cf$inum <= 170, ]
c(respondents = length(unique(cf$id)), items = length(unique(cf$item)),
  missing = sum(is.na(cf$resp)), time_zero = sum(cf$rt == 0))
# A time of 0 means under a second; log(0) is undefined, so those rows are set aside.
cf <- cf[cf$rt > 0, ]
cf$lrt <- log(cf$rt)
round(c(accuracy = mean(cf$resp), median_s = median(cf$rt), mean_s = mean(cf$rt),
        max_s = max(cf$rt)), 2)

## ---- hist-cf
op <- par(mfrow = c(1, 2), mar = c(4, 4, 1, 1))
hist(cf$rt, breaks = 100, col = "#93c5fd", border = NA, main = "",
     xlab = "Seconds on an item", xlim = c(0, 400))
hist(cf$lrt, breaks = 60, col = "#2780e3", border = NA, main = "",
     xlab = "log seconds")
par(op)

## ---- time-cf
# The lognormal model with crossed random effects: log t = beta_i - tau_j + e.
# lme4 writes it as an intercept plus an item effect (time intensity) and a
# respondent effect (minus speed).
m_time <- lmer(lrt ~ 1 + (1 | id) + (1 | item), cf)
vc <- as.data.frame(VarCorr(m_time))
data.frame(component = vc$grp, variance = round(vc$vcov, 3),
           share = round(vc$vcov / sum(vc$vcov), 2))
round(exp(fixef(m_time)), 1)   # the typical time on a typical item, in seconds

## ---- acc-cf
# The Rasch model as a GLMM with random items (explanatory-irt). nAGQ = 0 skips
# glmer's slowest step; the estimates barely move.
m_acc <- glmer(resp ~ 1 + (1 | id) + (1 | item), cf, binomial, nAGQ = 0)
# Person and item estimates from the two models. Speed is minus the respondent effect
# on log time; difficulty b is minus the item effect on the logit.
person_item <- function(m_time, m_acc) {
  tau <- setNames(-ranef(m_time)$id[, 1], rownames(ranef(m_time)$id))
  theta <- setNames(ranef(m_acc)$id[, 1], rownames(ranef(m_acc)$id))
  beta <- setNames(ranef(m_time)$item[, 1], rownames(ranef(m_time)$item))
  b <- setNames(-ranef(m_acc)$item[, 1], rownames(ranef(m_acc)$item))
  list(tau = tau[names(theta)], theta = theta, beta = beta[names(b)], b = b)
}
pi_cf <- person_item(m_time, m_acc)
round(c(r_theta_speed = cor(pi_cf$theta, pi_cf$tau), r_b_beta = cor(pi_cf$b, pi_cf$beta)), 2)

## ---- caf-cf
# The conditional accuracy function. The residual of the time model is how much
# slower (positive) or faster (negative) than expected a response was, for this
# respondent on this item. Under conditional independence, accuracy doesn't depend on it.
caf <- function(d, m_time) {
  d$res <- residuals(m_time)
  d$decile <- cut(d$res, quantile(d$res, 0:10 / 10), include.lowest = TRUE, labels = FALSE)
  m <- glmer(resp ~ res + (1 | id) + (1 | item), d, binomial, nAGQ = 0)
  list(by_decile = round(tapply(d$resp, d$decile, mean), 2),
       slope = round(unname(fixef(m)["res"]), 2), se = round(sqrt(diag(vcov(m)))[2], 2))
}
caf_cf <- caf(cf, m_time)
caf_cf
plot(1:10, caf_cf$by_decile, type = "b", pch = 19, col = "#2780e3", ylim = c(0.5, 0.9),
     xlab = "Decile of residual log time (1 = much faster than expected)",
     ylab = "Proportion correct")
abline(h = mean(cf$resp), lty = 2, col = "#999")

## ---- halves-cf
# One speed per respondent? Give each respondent a speed on items 1-85 and another
# on items 86-170, and let the model estimate their correlation.
cf$half <- factor(ifelse(cf$inum <= 85, "items 1-85", "items 86-170"))
m_half <- lmer(lrt ~ half + (0 + half | id) + (1 | item), cf)
round(attr(VarCorr(m_half)$id, "correlation")[1, 2], 2)

## ---- fetch-roar
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.roar_lexical/rows?format=csv"
roar <- read.csv(url)
# One response per respondent per item; resp is 1 for a correct classification of
# the string (real word or made-up word); rt in seconds. No waves.
roar$lrt <- log(roar$rt)
round(c(respondents = length(unique(roar$id)), items = length(unique(roar$item)),
        accuracy = mean(roar$resp), median_s = median(roar$rt),
        share_under_0.3s = mean(roar$rt < 0.3),
        accuracy_under_0.3s = mean(roar$resp[roar$rt < 0.3])), 3)

## ---- models-roar
t_roar <- lmer(lrt ~ 1 + (1 | id) + (1 | item), roar)
a_roar <- glmer(resp ~ 1 + (1 | id) + (1 | item), roar, binomial, nAGQ = 0)
pi_roar <- person_item(t_roar, a_roar)
round(c(r_theta_speed = cor(pi_roar$theta, pi_roar$tau), r_b_beta = cor(pi_roar$b, pi_roar$beta)), 2)
caf_roar <- caf(roar, t_roar)
caf_roar
# One speed for real words and made-up words?
m_kind <- lmer(lrt ~ realpseudo + (0 + realpseudo | id) + (1 | item), roar)
round(attr(VarCorr(m_kind)$id, "correlation")[1, 2], 2)

## ---- fetch-raven
# Two studies (Poulton et al., 2022), each with a retest (wave 2) for some
# respondents. We keep the first administration. rt is in seconds; the timed version
# stopped each item at 60 s.
get_raven <- function(table) {
  url <- sprintf("https://redivis.com/api/v1/tables/datapages.item_response_warehouse_2:v24_0.%s/rows?format=csv", table)
  d <- read.csv(url)
  d <- d[d$wave == 1 & !is.na(d$resp), ]
  d$item <- factor(d$item, levels = paste0("RAPM_", 1:12))
  d
}
timed <- get_raven("rapm_poulton_2022_timed")
untimed <- get_raven("rapm_poulton_2022_untimed")
rbind(timed = c(respondents = length(unique(timed$id)), accuracy = round(mean(timed$resp), 2),
                median_s = median(timed$rt, na.rm = TRUE), time_missing = sum(is.na(timed$rt))),
      untimed = c(length(unique(untimed$id)), round(mean(untimed$resp), 2),
                  median(untimed$rt, na.rm = TRUE), sum(is.na(untimed$rt))))
# How often did the clock run out, and how accurate were those responses?
at_limit <- timed$rt >= 59.9
round(c(share_at_limit = mean(at_limit), accuracy_at_limit = mean(timed$resp[at_limit]),
        untimed_share_over_60s = mean(untimed$rt > 60, na.rm = TRUE)), 2)
# Accuracy item by item: which items lose most under the clock?
round(rbind(untimed = tapply(untimed$resp, untimed$item, mean),
            timed = tapply(timed$resp, timed$item, mean)), 2)

## ---- models-raven
# Responses without a time (and two timed responses under 0.5 s) are set aside.
timed <- timed[!is.na(timed$rt) & timed$rt >= 0.5, ]
untimed <- untimed[!is.na(untimed$rt), ]
timed$lrt <- log(timed$rt); untimed$lrt <- log(untimed$rt)
fits <- lapply(list(timed = timed, untimed = untimed), function(d) {
  mt <- lmer(lrt ~ 1 + (1 | id) + (1 | item), d)
  ma <- glmer(resp ~ 1 + (1 | id) + (1 | item), d, binomial, nAGQ = 0)
  p <- person_item(mt, ma)
  list(r = round(c(r_theta_speed = cor(p$theta, p$tau), r_b_beta = cor(p$b, p$beta)), 2),
       caf = caf(d, mt))
})
fits

## ---- compare
tab <- data.frame(
  table = c("licensure exam", "lexical decision", "Raven's, timed", "Raven's, untimed"),
  median_s = c(median(cf$rt), median(roar$rt), median(timed$rt), median(untimed$rt)),
  r_theta_speed = c(cor(pi_cf$theta, pi_cf$tau), cor(pi_roar$theta, pi_roar$tau),
                    fits$timed$r[1], fits$untimed$r[1]),
  fastest = c(caf_cf$by_decile[1], caf_roar$by_decile[1], fits$timed$caf$by_decile[1],
              fits$untimed$caf$by_decile[1]),
  middle = c(mean(caf_cf$by_decile[5:6]), mean(caf_roar$by_decile[5:6]),
             mean(fits$timed$caf$by_decile[5:6]), mean(fits$untimed$caf$by_decile[5:6])),
  slowest = c(caf_cf$by_decile[10], caf_roar$by_decile[10], fits$timed$caf$by_decile[10],
              fits$untimed$caf$by_decile[10]),
  slope = c(caf_cf$slope, caf_roar$slope, fits$timed$caf$slope, fits$untimed$caf$slope))
tab[, -1] <- round(tab[, -1], 2)
tab
cols <- c("#2780e3", "#c2410c", "#1a1a1a", "#93c5fd")
all_caf <- rbind(caf_cf$by_decile, caf_roar$by_decile, fits$timed$caf$by_decile,
                 fits$untimed$caf$by_decile)
matplot(1:10, t(all_caf), type = "b", pch = 19, lty = 1, col = cols, ylim = c(0.3, 0.95),
        xlab = "Decile of residual log time (1 = much faster than expected)",
        ylab = "Proportion correct")
legend("bottomleft", tab$table, col = cols, pch = 19, lty = 1, bty = "n")
