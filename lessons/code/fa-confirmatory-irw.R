# Confirmatory factor analysis with real data: the Grit-O (grit) and the DASS-21
# (neurodegenerative_huizinga_2019_dass) from the Item Response Warehouse. Needs the
# lavaan and mirt packages. No login or token needed. Every chunk runs in a few
# seconds except the two-dimensional graded model (under a minute).

## ---- fetch-grit
library(lavaan)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/)
# with a CSV download. This link is pinned to one version of the data.
grit_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0.grit/rows?format=csv"
df <- read.csv(grit_url)
wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
grit <- as.data.frame(wide[, paste0("item_", 1:12)])
names(grit) <- paste0("g", 1:12)
c(respondents = nrow(grit), complete = sum(complete.cases(grit)))
grit <- grit[complete.cases(grit), ]
# Keying. The source (Open Psychometrics) coded 1 = "Very much like me" to
# 5 = "Not like me at all", and the IRW processing script reversed the six
# consistency-of-interest items (2, 3, 5, 7, 8, 11), which are worded against grit.
# So every item in the table runs toward LESS grit. Reversing all twelve makes
# higher = more grit, the same as reversing the perseverance items in the raw data.
grit <- 6 - grit
per <- paste0("g", c(1, 4, 6, 9, 10, 12))   # perseverance of effort
con <- paste0("g", c(2, 3, 5, 7, 8, 11))    # consistency of interest
round(range(cor(grit)[lower.tri(diag(12))]), 2)   # no negative correlations left

## ---- grit-fit
# lavaan syntax: "=~" reads "is measured by". Items not listed under a factor have
# a loading fixed at zero. By default lavaan fixes each factor's first loading to 1.
one <- "grit =~ g1 + g2 + g3 + g4 + g5 + g6 + g7 + g8 + g9 + g10 + g11 + g12"
two <- "per =~ g1 + g4 + g6 + g9 + g10 + g12
        con =~ g2 + g3 + g5 + g7 + g8 + g11"
f1 <- cfa(one, data = grit)
f2 <- cfa(two, data = grit)
idx <- c("chisq", "df", "cfi", "tli", "rmsea", "srmr")
round(rbind(one_factor = fitMeasures(f1, idx), two_factors = fitMeasures(f2, idx)), 3)
lavTestLRT(f1, f2)   # the one-factor model is the two-factor model with the correlation fixed at 1
lavInspect(f2, "cor.lv")

## ---- grit-identify
# Two ways to set the scale of each factor: fix the first loading to 1 (lavaan's
# default) or fix the factor's variance to 1 (std.lv = TRUE). Same fit, different
# numbers for the loadings.
f2_var <- cfa(two, data = grit, std.lv = TRUE)
rbind(first_loading_1 = fitMeasures(f2, c("chisq", "df")),
      variance_1      = fitMeasures(f2_var, c("chisq", "df")))
round(cbind(first_loading_1 = coef(f2)[1:6], variance_1 = coef(f2_var)[1:6]), 2)

## ---- grit-omega
# Omega for each facet from the two-factor model: (sum of loadings)^2 over the
# model-implied variance of the facet's sum score. Alpha from its usual formula.
est <- lavInspect(f2_var, "est")
omega <- function(items, factor) {
  l <- est$lambda[items, factor]; th <- est$theta[items, items]
  sum(l)^2 / (sum(l)^2 + sum(th))
}
alpha <- function(x) { k <- ncol(x); k / (k - 1) * (1 - sum(apply(x, 2, var)) / var(rowSums(x))) }
round(rbind(omega = c(perseverance = omega(per, "per"), consistency = omega(con, "con")),
            alpha = c(alpha(grit[per]), alpha(grit[con]))), 3)
round(est$lambda[per, "per"], 2)   # unequal loadings: the items aren't tau-equivalent

## ---- grit-ordinal
# The same two-factor model with the items declared ordered: lavaan then fits the
# polychoric correlations (estimator WLSMV). Loadings are for the latent responses.
f2_ord <- cfa(two, data = grit, ordered = TRUE, std.lv = TRUE)
idx_s <- c("chisq.scaled", "df.scaled", "cfi.scaled", "rmsea.scaled", "srmr")
round(fitMeasures(f2_ord, idx_s), 3)
lam <- lavInspect(f2_ord, "std")$lambda
lam <- rowSums(lam)[c(per, con)]          # each item's one nonzero loading
tau <- matrix(lavInspect(f2_ord, "est")$tau, ncol = 4, byrow = TRUE,
              dimnames = list(rownames(lavInspect(f2_ord, "est")$lambda), NULL))[c(per, con), ]
# Convert: normal-ogive slope lambda / sqrt(1 - lambda^2), times 1.702 for the
# logistic metric; difficulty (category boundary) b = tau / lambda.
a_from_cfa <- 1.702 * lam / sqrt(1 - lam^2)
b_from_cfa <- tau / lam

## ---- grit-mirt
library(mirt)
spec <- mirt.model("per = 1, 4, 6, 9, 10, 12
                    con = 2, 3, 5, 7, 8, 11
                    COV = per*con")
grm <- mirt(grit, spec, itemtype = "graded", verbose = FALSE)
cf <- coef(grm, simplify = TRUE)
a_mirt <- rowSums(cf$items[, c("a1", "a2")])[c(per, con)]
# mirt writes each boundary as a*theta + d; the difficulty is b = -d/a.
b_mirt <- -cf$items[c(per, con), c("d1", "d2", "d3", "d4")] / a_mirt
round(cbind(loading = lam, a_from_cfa, a_mirt), 2)
round(c(cor_a = cor(a_from_cfa, a_mirt), cor_b = cor(as.vector(b_from_cfa), as.vector(b_mirt)),
        largest_b_gap = max(abs(b_from_cfa - b_mirt)),
        factor_cor_lavaan = lavInspect(f2_ord, "cor.lv")[1, 2],
        factor_cor_mirt = cf$cov[1, 2]), 2)

## ---- fetch-dass
dass_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0.neurodegenerative_huizinga_2019_dass/rows?format=csv"
df <- read.csv(dass_url)
df$resp <- suppressWarnings(as.numeric(df$resp))   # missing responses arrive as text
wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
dass <- as.data.frame(wide[, paste0("DASS.", 1:21)])
names(dass) <- paste0("d", 1:21)
dass$sex <- df$cov_sex[match(rownames(dass), df$id)]
c(respondents = nrow(dass), complete = sum(complete.cases(dass)))
dass <- dass[complete.cases(dass), ]
table(sex = dass$sex)
# 0 = did not apply to me at all ... 3 = applied to me very much. Every item is
# worded toward more distress, so no keying is needed.
table(response = unlist(dass[1:21]))
# Scales from the DASS scoring template (Lovibond & Lovibond, 1995).
dep <- paste0("d", c(3, 5, 10, 13, 16, 17, 21))
anx <- paste0("d", c(2, 4, 7, 9, 15, 19, 20))
stress <- paste0("d", c(1, 6, 8, 11, 12, 14, 18))
m3 <- paste("dep =~", paste(dep, collapse = " + "), "\n",
            "anx =~", paste(anx, collapse = " + "), "\n",
            "str =~", paste(stress, collapse = " + "))
m1 <- paste("distress =~", paste(c(dep, anx, stress), collapse = " + "))
mbi <- paste(m1, "\n", m3)   # bifactor: every item on the general factor and on its scale

## ---- dass-three
# Four categories with most responses at 0: fit the polychoric correlations.
d3 <- cfa(m3, data = dass[1:21], ordered = TRUE, std.lv = TRUE)
round(lavInspect(d3, "cor.lv"), 2)

## ---- dass-compare
d1 <- cfa(m1, data = dass[1:21], ordered = TRUE, std.lv = TRUE)
dbi <- cfa(mbi, data = dass[1:21], ordered = TRUE, std.lv = TRUE, orthogonal = TRUE)
round(rbind(one_factor = fitMeasures(d1, idx_s), three_factors = fitMeasures(d3, idx_s),
            bifactor = fitMeasures(dbi, idx_s)), 3)

## ---- dass-omega
# Omega for the sum score needs a model of the scored responses, so here the items
# are treated as numbers (MLR: maximum likelihood with robust standard errors).
bi <- cfa(mbi, data = dass[1:21], estimator = "MLR", std.lv = TRUE, orthogonal = TRUE)
L <- lavInspect(bi, "est")$lambda
th <- diag(lavInspect(bi, "est")$theta)
total_var <- sum(colSums(L)^2) + sum(th)
omega_h_sub <- c(dep = sum(L[dep, "dep"])^2 / (sum(colSums(L[dep, ])^2) + sum(th[dep])),
                 anx = sum(L[anx, "anx"])^2 / (sum(colSums(L[anx, ])^2) + sum(th[anx])),
                 str = sum(L[stress, "str"])^2 / (sum(colSums(L[stress, ])^2) + sum(th[stress])))
round(c(omega_total = sum(colSums(L)^2) / total_var,
        omega_hierarchical = sum(L[, "distress"])^2 / total_var,
        alpha = alpha(dass[1:21])), 3)
round(omega_h_sub, 3)   # share of each scale's sum-score variance that is specific to it

## ---- dass-invariance
# Multigroup CFA by cov_sex, three-factor model, items treated as numbers (MLR).
# Configural: same pattern in both groups. Metric: loadings equal. Scalar: loadings
# and intercepts equal; lavaan then frees group 2's factor means.
cfg <- cfa(m3, data = dass, group = "sex", estimator = "MLR")
met <- cfa(m3, data = dass, group = "sex", estimator = "MLR", group.equal = "loadings")
sca <- cfa(m3, data = dass, group = "sex", estimator = "MLR",
           group.equal = c("loadings", "intercepts"))
idx_r <- c("chisq.scaled", "df", "cfi.robust", "rmsea.robust", "srmr")
round(rbind(configural = fitMeasures(cfg, idx_r), metric = fitMeasures(met, idx_r),
            scalar = fitMeasures(sca, idx_r)), 3)
lavTestLRT(cfg, met, sca)   # scaled (Satorra-Bentler) differences

## ---- dass-constraints
# Which equality constraint strains most? One score test per constraint.
st <- lavTestScore(sca)$uni
pt <- parTable(sca)
st$constraint <- sapply(st$lhs, function(l) with(pt[pt$plabel == l, ], paste(lhs, op, rhs)))
st <- st[order(-st$X2.scaled), c("constraint", "X2.scaled", "df", "p.value.scaled")]
nrow(st)
head(st, 3)

## ---- dass-means
# Group 2's factor means under scalar invariance, in units of group 1's factor SD.
pe <- parameterEstimates(sca)
mu2 <- pe[pe$op == "~1" & pe$lhs %in% c("dep", "anx", "str") & pe$group == 2, c("lhs", "est", "se")]
sd1 <- sqrt(diag(lavInspect(sca, "est")[[1]]$psi))
data.frame(factor = mu2$lhs, mean_diff = round(mu2$est, 2), se = round(mu2$se, 2),
           in_group1_SDs = round(mu2$est / sd1[mu2$lhs], 2))

## ---- dass-ordinal-check
# The same ladder with the items as ordered categories: the thresholds play the
# intercepts' part. Only the fit indices are shown; see the text. (lavaan may warn
# about the parameters' covariance matrix: some top categories hold one response.)
cfg_o <- cfa(m3, data = dass, group = "sex", ordered = TRUE)
met_o <- cfa(m3, data = dass, group = "sex", ordered = TRUE, group.equal = "loadings")
sca_o <- cfa(m3, data = dass, group = "sex", ordered = TRUE,
             group.equal = c("loadings", "thresholds", "intercepts"))
idx_o <- c("cfi.scaled", "rmsea.scaled", "srmr")
round(rbind(configural = fitMeasures(cfg_o, idx_o), metric = fitMeasures(met_o, idx_o),
            scalar = fitMeasures(sca_o, idx_o)), 3)
