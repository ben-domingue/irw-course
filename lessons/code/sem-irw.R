# Structural equation modeling with real data: grit (florida_twins_grit) and
# positive and negative affect (florida_twins_panas), from the same children and
# adolescents in the Florida Twin Project, via the Item Response Warehouse. Needs
# the lavaan package. No login or token needed. Each fit takes a few seconds.

## ---- fetch
library(lavaan)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/)
# with a CSV download. These links are pinned to one version of the data.
base <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0."
grit_long  <- read.csv(paste0(base, "florida_twins_grit/rows?format=csv"))
panas_long <- read.csv(paste0(base, "florida_twins_panas/rows?format=csv"))
table(grit = grit_long$wave[!duplicated(grit_long$id)])     # grit was asked in wave 2 only
panas_long <- panas_long[panas_long$wave == 2, ]            # so we use PANAS from wave 2

wide <- function(df, items) {
  w <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  as.data.frame(w[, items])
}
grit  <- wide(grit_long, paste0("qgrit", 1:12));      names(grit)  <- paste0("g", 1:12)
panas <- wide(panas_long, paste0("panas", 1:20, "t")); names(panas) <- paste0("p", 1:20)

# Keying. Grit runs 1 = "Very much like me" to 5 = "Not like me at all" (the IRW's
# option text). The consistency-of-interest items are worded against grit ("My
# interests change..."), so "not like me" already means more grit; the six
# perseverance items are reversed. Higher = more grit on every item.
per <- paste0("g", c(1, 4, 6, 9, 10, 12))   # perseverance of effort
con <- paste0("g", c(2, 3, 5, 7, 8, 11))    # consistency of interest
grit[per] <- 6 - grit[per]
# PANAS: 1 = "very slightly or not at all" to 5 = "extremely"; no keying needed.
# Scales as in Watson, Clark & Tellegen (1988).
pa <- paste0("p", c(1, 3, 5, 9, 10, 12, 14, 16, 17, 19))   # positive affect
na <- paste0("p", c(2, 4, 6, 7, 8, 11, 13, 15, 18, 20))    # negative affect

d <- merge(grit, panas, by = "row.names")
d$id <- as.numeric(d$Row.names)
# Twins: IRW ids come in pairs ending 00 and 01 (31700, 31701), so id %/% 100 is
# the family. Inferred from the id pattern, not from a codebook.
d$family <- d$id %/% 100
d$age <- tapply(grit_long$cov_age, grit_long$id, function(x) x[1])[as.character(d$id)]
c(both_tables = nrow(d), complete = sum(complete.cases(d[c(per, con, pa, na)])))
d <- d[complete.cases(d[c(per, con, pa, na)]), ]
table(twins_in_family = table(d$family))
r <- cor(d[c(per, con)])
round(r[per, c("g3", "g11")], 2)   # the two items that don't line up with the rest

## ---- measurement
# Step 1: the measurement model alone. Four factors, each item on one, all four
# factors correlated. MLR: maximum likelihood with standard errors and a test
# statistic that are robust to non-normal responses; cluster = "family" makes them
# robust to twins' responses being correlated as well.
mm <- paste0("per =~ ", paste(per, collapse = " + "), "\n",
             "con =~ ", paste(con, collapse = " + "), "\n",
             "pa  =~ ", paste(pa,  collapse = " + "), "\n",
             "na  =~ ", paste(na,  collapse = " + "))
cat(mm)
m1 <- cfa(mm, data = d, estimator = "MLR", cluster = "family")
idx <- c("chisq.scaled", "df", "cfi.robust", "rmsea.robust", "srmr")
round(fitMeasures(m1, idx), 3)
round(lavInspect(m1, "cor.lv"), 2)
std <- standardizedSolution(m1)
std <- std[std$op == "=~", ]
round(tapply(std$est.std, std$lhs, range)[c("per", "con", "pa", "na")] |> do.call(what = rbind), 2)
std[std$est.std < 0.4, c("lhs", "rhs", "est.std")]

## ---- misfit
# Where does the measurement model strain? The largest modification indices: the
# drop in chi-square if one fixed parameter were freed.
mi <- modindices(m1, sort. = TRUE)
head(mi[, c("lhs", "op", "rhs", "mi")], 6)

## ---- structural
# Step 2: replace the four factor correlations with regressions. "~" reads "is
# regressed on"; lavaan correlates the two outcomes' residuals by default.
sm <- paste(mm, "
  pa ~ per + con
  na ~ per + con")
s1 <- sem(sm, data = d, estimator = "MLR", cluster = "family")
round(rbind(measurement = fitMeasures(m1, idx), structural = fitMeasures(s1, idx)), 3)
paths <- standardizedSolution(s1)
paths <- paths[paths$op == "~", c("lhs", "rhs", "est.std", "se", "pvalue")]
paths$est.std <- round(paths$est.std, 2); paths$se <- round(paths$se, 3); paths$pvalue <- round(paths$pvalue, 3)
paths

## ---- sumscores
# The same regressions on mean scores, all standardized so the coefficients are on
# the same footing as the standardized latent paths.
alpha <- function(x) { k <- ncol(x); k / (k - 1) * (1 - sum(apply(x, 2, var)) / var(rowSums(x))) }
round(c(per = alpha(d[per]), con = alpha(d[con]), pa = alpha(d[pa]), na = alpha(d[na])), 2)
sc <- as.data.frame(scale(sapply(list(per = per, con = con, pa = pa, na = na),
                                 function(v) rowMeans(d[v]))))
ols <- rbind(coef(lm(pa ~ per + con, sc))[-1], coef(lm(na ~ per + con, sc))[-1])
cbind(paths[, c("lhs", "rhs")], sum_scores = round(as.vector(t(ols)), 2),
      latent = paths$est.std)

## ---- clusters
# What the family clustering does to the standard errors of the paths (unstandardized).
s0 <- sem(sm, data = d, estimator = "MLR")
pe1 <- parameterEstimates(s1); pe0 <- parameterEstimates(s0)
data.frame(pe1[pe1$op == "~", c("lhs", "rhs")], est = round(pe1$est[pe1$op == "~"], 2),
           se_ignoring_families = round(pe0$se[pe0$op == "~"], 3),
           se_clustered = round(pe1$se[pe1$op == "~"], 3))

## ---- ordinal
# A check: the items as ordered categories (WLSMV, polychoric correlations).
# Negative-affect items pile up at 1, which is where the two routes could part.
table(negative_affect = unlist(d[na]))
s_ord <- sem(sm, data = d, ordered = TRUE)
po <- standardizedSolution(s_ord)
round(setNames(po$est.std[po$op == "~"], paste(po$lhs, "~", po$rhs)[po$op == "~"]), 2)

## ---- multigroup
# Does the structural model hold for children and for adolescents? Multigroup SEM:
# configural (same model in both), metric (loadings equal), then the four paths equal.
d$ages <- ifelse(d$age < 14, "9-13", "14-18")
table(d$ages, useNA = "ifany")   # one respondent has no age and sits this out
dg <- d[!is.na(d$ages), ]
g_cfg <- sem(sm, data = dg, group = "ages", estimator = "MLR", cluster = "family")
g_met <- sem(sm, data = dg, group = "ages", estimator = "MLR", cluster = "family",
             group.equal = "loadings")
g_pth <- sem(sm, data = dg, group = "ages", estimator = "MLR", cluster = "family",
             group.equal = c("loadings", "regressions"))
round(rbind(configural = fitMeasures(g_cfg, idx), metric = fitMeasures(g_met, idx),
            equal_paths = fitMeasures(g_pth, idx)), 3)
lavTestLRT(g_cfg, g_met, g_pth)

## ---- partial
# Which equal loading strains most? One score test per equality constraint.
st <- lavTestScore(g_met)$uni
pt <- parTable(g_met)
st$constraint <- sapply(st$lhs, function(l) with(pt[pt$plabel == l, ], paste(lhs, op, rhs)))
st <- st[order(-st$X2), c("constraint", "X2", "df", "p.value")]
head(st, 3)
# The paths, by age group (unstandardized, under equal loadings).
pg <- parameterEstimates(g_met)
pg <- pg[pg$op == "~", ]
data.frame(path = paste(pg$lhs, "~", pg$rhs), ages = lavInspect(g_met, "group.label")[pg$group],
           est = round(pg$est, 2), se = round(pg$se, 2))
