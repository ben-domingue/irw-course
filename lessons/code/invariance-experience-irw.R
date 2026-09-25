# Measurement invariance under treatment: item-level treatment effects in two
# randomized trials from the Item Response Warehouse.
#   gilbert_meta_20: a fractions intervention for struggling fifth graders
#     (Jayanthi et al., 2021), with a pretest (wave 0) and a posttest (wave 1).
#     Treatment DIF at the pretest is a placebo; at the posttest it is caused by the
#     intervention.
#   gilbert_meta_37: health knowledge ten months after an entertainment-education
#     programme in India (Carpena, 2024).
# Logistic-regression DIF as in the lesson "Differential item functioning"
# (Swaminathan & Rogers, 1990; Jodoin & Gierl, 2001), then the item-level
# heterogeneous treatment effects (IL-HTE) model of Gilbert, Kim & Miratrix (2023)
# fitted with lme4 (Bates et al., 2015). Runs as-is in R with lme4 installed; no
# login or token needed. The model fits take about a minute.
# Source: EDUC 252 problem sets 5 (#4, code ps5/rctdif.R) and 7 (#1, code ps7/ilhte.R).

## ---- fetch20
# The IRW table, from the CSV link on its landing page (pinned to one version).
url20 <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.gilbert_meta_20/rows?format=csv"
f20 <- read.csv(url20)
f20 <- f20[!is.na(f20$resp), ]
# Waves: 0 = pretest, 1 = posttest. How many items and students in each?
t(sapply(split(f20, f20$wave), function(x) c(items = length(unique(x$item)),
                                            students = length(unique(x$id)))))
pre_items <- unique(f20$item[f20$wave == 0])
post_items <- unique(f20$item[f20$wave == 1])
c(pretest_items_also_at_posttest = sum(pre_items %in% post_items))
# Items come in four blocks (by the prefix of their names):
table(wave = f20$wave[!duplicated(f20[, c("wave", "item")])],
      block = sub("_+q.*$", "", f20$item[!duplicated(f20[, c("wave", "item")])]))
kids20 <- f20[!duplicated(f20$id), c("id", "treat")]
table(treat = kids20$treat)

## ---- dif-fn
# One wide matrix per wave: a row per student, a column per item (1 = correct).
wide <- function(long, items) {
  x <- long[long$item %in% items, ]
  A <- tapply(x$resp, list(x$id, x$item), function(v) v[1])
  A <- A[complete.cases(A), items]
  list(X = A, treat = kids20$treat[match(rownames(A), kids20$id)])
}
# Logistic-regression DIF for one item, matching on the total score, as in the DIF
# lesson but for uniform DIF only, the kind a shift in one item's treatment effect
# produces: the 1-df likelihood-ratio test of M0 (total) against M1 (total and
# treatment), and the change in Nagelkerke's R^2 between them.
nagelkerke <- function(m, ll0, n) {
  cs <- 1 - exp(2 * (ll0 - as.numeric(logLik(m))) / n)
  cs / (1 - exp(2 * ll0 / n))
}
lr_item <- function(y, g, total) {
  d <- data.frame(y = y, g = g, total = total)
  ll0 <- as.numeric(logLik(glm(y ~ 1, binomial, d)))
  m0 <- glm(y ~ total, binomial, d)
  m1 <- glm(y ~ total + g, binomial, d)
  c(beta_treat = unname(coef(m1)["g"]),
    p = anova(m0, m1, test = "LRT")[2, "Pr(>Chi)"],
    dR2 = nagelkerke(m1, ll0, nrow(d)) - nagelkerke(m0, ll0, nrow(d)))
}
# Every item; p-values also after the Benjamini-Hochberg false-discovery-rate
# correction; Jodoin-Gierl categories (A below .035, B to .07, C above, and A
# whenever the test is not significant).
treatment_dif <- function(W) {
  tot <- rowSums(W$X)
  out <- as.data.frame(t(sapply(colnames(W$X), function(i) lr_item(W$X[, i], W$treat, tot))))
  out$p_BH <- p.adjust(out$p, "BH")
  out$jg <- ifelse(out$p >= 0.05 | out$dR2 < 0.035, "A", ifelse(out$dR2 < 0.07, "B", "C"))
  out
}
count_flags <- function(r) c(items = nrow(r), p_below_05 = sum(r$p < 0.05),
                             expected_by_chance = round(0.05 * nrow(r), 1),
                             after_BH = sum(r$p_BH < 0.05), B = sum(r$jg == "B"), C = sum(r$jg == "C"))

## ---- dif-waves
W0 <- wide(f20[f20$wave == 0, ], pre_items)    # pretest: before any instruction
W1 <- wide(f20[f20$wave == 1, ], post_items)   # posttest: all 93 items
W1s <- wide(f20[f20$wave == 1, ], pre_items)   # posttest, the pretest's 37 items only
dif0 <- treatment_dif(W0); dif1 <- treatment_dif(W1); dif1s <- treatment_dif(W1s)
rbind(pretest = count_flags(dif0), posttest = count_flags(dif1),
      "posttest, same 37 items" = count_flags(dif1s))

## ---- dif-post-items
# The posttest items in B or C, largest first. beta_treat > 0: easier for treated
# students with the same total.
d1 <- dif1[dif1$jg != "A", ]
d1$p_control <- colMeans(W1$X[W1$treat == 0, rownames(d1)])
d1$p_treated <- colMeans(W1$X[W1$treat == 1, rownames(d1)])
round(d1[order(-d1$dR2), c("beta_treat", "p", "dR2", "p_control", "p_treated")], 3)
table(block = sub("_+q.*$", "", rownames(d1)), sign = ifelse(d1$beta_treat > 0, "favours treated", "favours control"))

## ---- ilhte-fn
suppressPackageStartupMessages(library(lme4))
# The IL-HTE model (Gilbert, Kim & Miratrix, 2023), in lme4's parameterization:
#   logit P(x_ij = 1) = beta0 + beta1 T_j + theta_j + e_i + zeta_i T_j,
# with theta_j ~ N(0, s_theta^2) and (e_i, zeta_i) bivariate normal. lme4's item
# intercept e_i is an easiness, the negative of the lesson's difficulty b_i, so the
# correlation it reports has the opposite sign to rho in the lesson; we flip it.
# Following the IRW vignette, effects are standardized by s_theta from the model with
# a constant effect, and sigma_zeta is tested by a likelihood-ratio test against
# that model, halving the p-value because a variance of zero sits on the boundary
# (Self & Liang, 1987).
ilhte <- function(long) {
  m0 <- glmer(resp ~ treat + (1 | id) + (1 | item), long, family = binomial)
  m1 <- glmer(resp ~ treat + (1 | id) + (treat | item), long, family = binomial)
  s_theta <- sqrt(VarCorr(m0)$id[1])
  vc <- VarCorr(m1)$item
  lr <- as.numeric(2 * (logLik(m1) - logLik(m0)))
  list(m0 = m0, m1 = m1, s_theta = s_theta,
       summary = c(students = length(unique(long$id)), items = length(unique(long$item)),
                   effect_constant_SD = unname(fixef(m0)["treat"]) / s_theta,
                   effect_average_SD = unname(fixef(m1)["treat"]) / s_theta,
                   sigma_zeta_SD = sqrt(vc[2, 2]) / s_theta,
                   rho_difficulty = -attr(vc, "correlation")[1, 2],
                   LR = lr, p = 0.5 * pchisq(lr, 2, lower.tail = FALSE)))
}

## ---- ilhte20
fit0 <- ilhte(f20[f20$wave == 0, ])
fit1 <- ilhte(f20[f20$wave == 1, ])
fit1s <- ilhte(f20[f20$wave == 1 & f20$item %in% pre_items, ])
tab <- rbind(pretest = fit0$summary, posttest = fit1$summary,
             "posttest, same 37 items" = fit1s$summary)
data.frame(round(tab[, 1:7], 2), p = sprintf("%.2g", tab[, "p"]))
# sigma_zeta in logits, and the SD of theta it is divided by:
round(sapply(list(pretest = fit0, posttest = fit1), function(f)
  c(sigma_zeta_logits = sqrt(VarCorr(f$m1)$item[2, 2]), s_theta = f$s_theta)), 2)

## ---- sum-vs-theta
# The same posttest effect three ways, each in within-arm SDs: the sum score, and
# theta from the constant-effect and IL-HTE models.
tot1 <- rowSums(W1$X)
gap <- mean(tot1[W1$treat == 1]) - mean(tot1[W1$treat == 0])
sd_within <- sqrt(mean(tapply(tot1, W1$treat, var)))   # pooled within-arm SD, like s_theta
sum_effect <- gap / sd_within
round(c(sum_score = sum_effect, theta_constant = unname(fit1$summary["effect_constant_SD"]),
        theta_ilhte = unname(fit1$summary["effect_average_SD"])), 2)
# Item-specific effects (beta1 + zeta_i, in SDs of theta), by block.
eff1 <- (fixef(fit1$m1)["treat"] + ranef(fit1$m1)$item[, "treat"]) / fit1$s_theta
names(eff1) <- rownames(ranef(fit1$m1)$item)
round(t(sapply(split(eff1, sub("_+q.*$", "", names(eff1))), function(e)
  c(items = length(e), mean = mean(e), min = min(e), max = max(e)))), 2)

## ---- fetch37
url37 <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.gilbert_meta_37/rows?format=csv"
f37 <- read.csv(url37)
p37 <- f37[!duplicated(f37$id), ]
c(respondents = nrow(p37), items = length(unique(f37$item)), missing = sum(is.na(f37$resp)))
table(treat = p37$treat)

## ---- ilhte37
fit37 <- ilhte(f37)
data.frame(t(round(fit37$summary[1:7], 2)), p = sprintf("%.2g", fit37$summary[["p"]]))
# Item-specific effects in logits (beta1 + zeta_i), with the proportion correct in
# each arm, largest effect first.
re <- ranef(fit37$m1)$item
items37 <- data.frame(effect_logits = fixef(fit37$m1)["treat"] + re[, "treat"],
                      p_control = tapply(f37$resp[f37$treat == 0], f37$item[f37$treat == 0], mean)[rownames(re)],
                      p_treated = tapply(f37$resp[f37$treat == 1], f37$item[f37$treat == 1], mean)[rownames(re)],
                      row.names = rownames(re))
round(items37[order(-items37$effect_logits), ], 2)

## ---- interaction37
# Who gains most? The treatment-by-baseline interaction, with a constant effect for
# every item and with IL-HTE (std_baseline: the IRW's standardized baseline score).
mB <- glmer(resp ~ treat * std_baseline + (1 | item) + (1 | id), f37, family = binomial)
mC <- glmer(resp ~ treat * std_baseline + (treat | item) + (1 | id), f37, family = binomial)
round(rbind(constant_items = summary(mB)$coef["treat:std_baseline", 1:2],
            ilhte = summary(mC)$coef["treat:std_baseline", 1:2]), 3)
