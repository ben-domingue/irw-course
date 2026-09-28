# Measurement invariance with real data: the DASS-21 by sex
# (neurodegenerative_huizinga_2019_dass), where the ladder holds, and the CES-D by
# sex (alexandrowicz_2018_cesd), where one item breaks it. Both from the Item
# Response Warehouse. Needs the lavaan package. No login or token needed. The
# whole script runs in about a minute.

## ---- fetch-dass
library(lavaan)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/)
# with a CSV download. This link is pinned to one version of the data.
dass_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0.neurodegenerative_huizinga_2019_dass/rows?format=csv"
df <- read.csv(dass_url)
df$resp <- suppressWarnings(as.numeric(df$resp))   # missing responses arrive as text
wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
dass <- as.data.frame(wide[, paste0("DASS.", 1:21)])
names(dass) <- paste0("d", 1:21)
dass$sex <- df$cov_sex[match(rownames(dass), df$id)]
table(sex = dass$sex)                  # all 1,461 respondents
dass <- dass[complete.cases(dass), ]   # 215 respondents skipped all 21 items; no one skipped some
table(sex = dass$sex)                  # the 1,246 who answered
# 0 = did not apply to me at all ... 3 = applied to me very much. Every item is
# worded toward more distress, so no keying is needed. Scales from the DASS
# scoring template (Lovibond & Lovibond, 1995).
dep <- paste0("d", c(3, 5, 10, 13, 16, 17, 21))
anx <- paste0("d", c(2, 4, 7, 9, 15, 19, 20))
stress <- paste0("d", c(1, 6, 8, 11, 12, 14, 18))
m3 <- paste("dep =~", paste(dep, collapse = " + "), "\n",
            "anx =~", paste(anx, collapse = " + "), "\n",
            "str =~", paste(stress, collapse = " + "))

## ---- dass-categories
# The estimator choice, group by group: with ordered items, every category of
# every item needs responses in each group, since each group gets thresholds.
top <- sapply(split(dass[1:21], dass$sex), function(g) sapply(g, function(x) sum(x == 3)))
table(responses_at_3 = top)            # items by how many responses sit in the top category
colSums(top == 0 | top == 1)           # items per group with 0 or 1 responses at 3

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
score_tests <- function(fit) {
  st <- lavTestScore(fit)$uni
  pt <- parTable(fit)
  st$constraint <- sapply(st$lhs, function(l) with(pt[pt$plabel == l, ], paste(lhs, op, rhs)))
  st[order(-st$X2.scaled), c("constraint", "X2.scaled", "df", "p.value.scaled")]
}
st <- score_tests(sca)
nrow(st)
head(st, 3)

## ---- dass-means
# Group 2's factor means under scalar invariance, in units of group 1's factor SD.
latent_means <- function(fit, factors) {
  pe <- parameterEstimates(fit)
  mu2 <- pe[pe$op == "~1" & pe$lhs %in% factors & pe$group == 2, c("lhs", "est", "se")]
  sd1 <- sqrt(diag(lavInspect(fit, "est")[[1]]$psi))
  data.frame(factor = mu2$lhs, mean_diff = round(mu2$est, 3), se = round(mu2$se, 3),
             in_group1_SDs = round(mu2$est / sd1[mu2$lhs], 2))
}
latent_means(sca, c("dep", "anx", "str"))

## ---- dass-ordinal-check
# The same ladder with the items as ordered categories (WLSMV): the thresholds play
# the intercepts' part. (lavaan may warn about the parameters' covariance matrix:
# some top categories hold one response in a group.)
cfg_o <- cfa(m3, data = dass, group = "sex", ordered = TRUE)
met_o <- cfa(m3, data = dass, group = "sex", ordered = TRUE, group.equal = "loadings")
sca_o <- cfa(m3, data = dass, group = "sex", ordered = TRUE,
             group.equal = c("loadings", "thresholds", "intercepts"))
idx_o <- c("df", "cfi.scaled", "rmsea.scaled", "srmr")
round(rbind(configural = fitMeasures(cfg_o, idx_o), metric = fitMeasures(met_o, idx_o),
            scalar = fitMeasures(sca_o, idx_o)), 3)
# Are these three models nested? Count what each one frees beyond the loadings and
# thresholds: the default scalar model frees 21 scale factors and 3 factor means
# that the default metric model fixes, so it is not the metric model plus constraints.
sapply(list(configural = cfg_o, metric = met_o, scalar = sca_o), function(f) {
  pt <- parTable(f)
  c(free_scale_factors = sum(pt$op == "~*~" & pt$free > 0),
    free_factor_means = sum(pt$op == "~1" & pt$lhs %in% c("dep", "anx", "str") & pt$free > 0))
})

## ---- fetch-cesd
cesd_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_4:v8_0.alexandrowicz_2018_cesd/rows?format=csv"
df <- read.csv(cesd_url)
wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
items <- c(sprintf("ces_%02d", c(1, 2, 3, 5, 6, 7, 9, 10, 11, 13, 14, 15, 17, 18, 19, 20)),
           sprintf("cesr%02d", c(4, 8, 12, 16)))
cesd <- as.data.frame(wide[, items])
cesd$sex <- df$cov_sex[match(rownames(cesd), df$id)]
table(sex = cesd$sex)                  # all 514 respondents
table(items_skipped = rowSums(is.na(cesd[items])))
cesd <- cesd[complete.cases(cesd), ]
table(sex = cesd$sex)                  # complete cases
# 0 = rarely or none of the time ... 3 = most or all of the time. The four positively
# worded items (cesr04, cesr08, cesr12, cesr16) arrive reversed, so higher = more
# depressive symptoms on every item: they correlate positively with the rest.
round(range(cor(cesd[items])[lower.tri(diag(20))]), 2)
top <- sapply(split(cesd[items], cesd$sex), function(g) sapply(g, function(x) sum(x == 3)))
colSums(top <= 1)   # items per group with 0 or 1 responses in the top category
# Two factors: the 16 symptom items, and Radloff's positive-affect items.
pos <- sprintf("cesr%02d", c(4, 8, 12, 16))
m2 <- paste("dep =~", paste(setdiff(items, pos), collapse = " + "), "\n",
            "pa =~", paste(pos, collapse = " + "))

## ---- cesd-ladder
cfg_c <- cfa(m2, data = cesd, group = "sex", estimator = "MLR")
met_c <- cfa(m2, data = cesd, group = "sex", estimator = "MLR", group.equal = "loadings")
sca_c <- cfa(m2, data = cesd, group = "sex", estimator = "MLR",
             group.equal = c("loadings", "intercepts"))
round(rbind(configural = fitMeasures(cfg_c, idx_r), metric = fitMeasures(met_c, idx_r),
            scalar = fitMeasures(sca_c, idx_r)), 3)
lavTestLRT(cfg_c, met_c, sca_c)

## ---- cesd-constraints
st_met <- score_tests(met_c)   # at the metric step: which loading?
nrow(st_met)
head(st_met, 3)

## ---- cesd-partial
# Partial invariance: free the crying item's loading (metric), then its intercept too
# (scalar), keeping every other constraint.
met_p <- cfa(m2, data = cesd, group = "sex", estimator = "MLR", group.equal = "loadings",
             group.partial = "dep =~ ces_17")
sca_p1 <- cfa(m2, data = cesd, group = "sex", estimator = "MLR",
              group.equal = c("loadings", "intercepts"), group.partial = "dep =~ ces_17")
head(score_tests(sca_p1), 2)   # at the scalar step, with the loading already free
sca_p <- cfa(m2, data = cesd, group = "sex", estimator = "MLR",
             group.equal = c("loadings", "intercepts"),
             group.partial = c("dep =~ ces_17", "ces_17 ~ 1"))
lavTestLRT(cfg_c, met_p)
lavTestLRT(met_p, sca_p)
round(rbind(partial_metric = fitMeasures(met_p, idx_r), partial_scalar = fitMeasures(sca_p, idx_r)), 3)

## ---- cesd-means
rbind(full_scalar = latent_means(sca_c, c("dep", "pa")), partial = latent_means(sca_p, c("dep", "pa")))
# The crying item's loading and intercept in each group (partial model):
pe <- parameterEstimates(sca_p)
pe[(pe$op == "=~" & pe$rhs == "ces_17") | (pe$op == "~1" & pe$lhs == "ces_17"),
   c("lhs", "op", "rhs", "group", "est", "se")]

## ---- cesd-ordinal-check
# As a check with an ordinal estimator: the top categories are too sparse to keep, so
# each item is scored as any symptom (1-3) against none (0), and the scalar model is
# fitted with WLSMV. Which constraints strain most?
cesd_bin <- cesd
cesd_bin[items] <- lapply(cesd_bin[items], function(x) as.integer(x > 0))
# With binary items, the theta parameterization fixes each latent response's
# residual variance at 1 in both groups, which keeps the scalar model identified
# (Wu & Estabrook, 2016); the group-2 factor means are free.
sca_b <- cfa(m2, data = cesd_bin, group = "sex", ordered = TRUE, parameterization = "theta",
             group.equal = c("loadings", "thresholds", "intercepts"))
st_b <- lavTestScore(sca_b)$uni
pt <- parTable(sca_b)
st_b$constraint <- sapply(st_b$lhs, function(l) with(pt[pt$plabel == l, ], paste(lhs, op, rhs)))
head(st_b[order(-st_b$X2), c("constraint", "X2", "df", "p.value")], 3)
