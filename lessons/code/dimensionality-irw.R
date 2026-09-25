# Multidimensional IRT with real data: grit (florida_twins_grit) and implicit theories
# of intelligence, or "mindset" (florida_twins_dweck), answered by the same young
# people in the Florida Twin Project, from the Item Response Warehouse. Needs the mirt
# and psych packages. No login or token needed. The two-dimensional graded models take
# about half a minute each; the cross-validation refits 1D and 2D models five times
# (a minute or two).
# Adapted from ben-domingue/252: ps6/personality.R (PS6#1) and c6/enem_imv.R.

## ---- fetch
library(mirt)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/) with
# a CSV download. These links are pinned to one version of the data.
base <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0."
gr <- read.csv(paste0(base, "florida_twins_grit/rows?format=csv"))
dw <- read.csv(paste0(base, "florida_twins_dweck/rows?format=csv"))
table(grit = gr$wave)       # grit was asked in wave 2 only
table(mindset = dw$wave)    # mindset in waves 2 and 3; we keep wave 2
dw <- dw[dw$wave == 2, ]
to_wide <- function(df) {
  w <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  w[, order(as.numeric(gsub("\\D", "", colnames(w))))]
}
G <- to_wide(gr); M <- to_wide(dw)
both <- intersect(rownames(G), rownames(M))   # respondents who answered both scales
X <- data.frame(G[both, ], M[both, ])
c(respondents = nrow(X), complete = sum(complete.cases(X)), missing_responses = sum(is.na(X)))
# Twins: the processing script stacks the two twins of each family (twin 0 and twin 1),
# so an id is the family number times 100 plus 0 or 1. There is no separate family column.
fam <- as.numeric(rownames(X)) %/% 100
table(twins_in_sample = table(fam))

## ---- keying
# Both tables arrive as answered. Grit: 1 = "Very much like me" ... 5 = "Not like me
# at all". The six perseverance items (1, 4, 6, 9, 10, 12) are worded toward grit, so we
# reverse them; the six consistency items are worded against it and stay as they are.
# Mindset: 1 = "Strongly agree" ... 6 = "Strongly disagree". Items 1, 2, 4 and 6 state
# an entity theory (intelligence is fixed) and stay; items 3, 5, 7 and 8 state an
# incremental theory (it can change) and are reversed. Now higher = more grit, and
# higher = more of an incremental ("growth") view of intelligence.
per <- paste0("qgrit", c(1, 4, 6, 9, 10, 12))
inc <- paste0("qdweckt", c(3, 5, 7, 8))
X[per] <- 6 - X[per]
X[inc] <- 7 - X[inc]
grit <- names(X)[1:12]; mind <- names(X)[13:20]
R <- cor(X, use = "pairwise.complete.obs")
low <- function(r) round(range(r[lower.tri(r)]), 2)
rbind(grit = low(R[grit, grit]), mindset = low(R[mind, mind]))
round(R["qgrit11", grit[grit != "qgrit11"]], 2)   # the one grit item that runs the other way

## ---- sums
# Sum scores (respondents with every item of a scale) and their correlation.
s_grit <- rowSums(X[grit]); s_mind <- rowSums(X[mind])
round(cor(s_grit, s_mind, use = "complete.obs"), 2)
# Item-rest correlations for grit: each item against the sum of the other eleven.
round(sapply(grit, function(i) cor(X[[i]], rowSums(X[setdiff(grit, i)]), use = "complete.obs")), 2)

## ---- confirmatory
# Graded response models (mirt handles the missing responses). One dimension for all
# 20 items, then two correlated dimensions with each item on its own scale's dimension.
set.seed(43)
m1 <- mirt(X, 1, itemtype = "graded", verbose = FALSE)
spec <- mirt.model("GRIT = 1-12
                    MIND = 13-20
                    COV = GRIT*MIND")
m2 <- mirt(X, spec, itemtype = "graded", verbose = FALSE)
anova(m1, m2)
round(coef(m2, simplify = TRUE)$cov, 2)   # latent correlation between grit and mindset

## ---- loadings
# A graded model is an ordinal factor model: summary() reports standardized loadings,
# lambda = (a / 1.702) / sqrt(1 + sum of (a_k / 1.702)^2) on the normal-ogive scale.
a <- coef(m2, simplify = TRUE)$items[, c("a1", "a2")]
lam <- (a / 1.702) / sqrt(1 + rowSums((a / 1.702)^2))
round(cbind(from_slopes = rowSums(lam), summary = rowSums(summary(m2, verbose = FALSE)$rotF)), 2)[c(1:3, 11, 13:14), ]

## ---- exploratory
# Every item may load on both dimensions. mirt estimates the unrotated solution, then
# rotates it for display (oblimin, which lets the factors correlate).
m2e <- mirt(X, 2, itemtype = "graded", verbose = FALSE)
anova(m2, m2e)
ex <- summary(m2e, rotate = "oblimin", verbose = FALSE)
round(ex$rotF, 2)
round(ex$fcor[1, 2], 2)
# Rotation changes the loadings, not the fit: the same model under varimax.
vx <- summary(m2e, rotate = "varimax", verbose = FALSE)
round(vx$rotF[c("qgrit9", "qdweckt2"), ], 2)
c(logLik = extract.mirt(m2e, "logLik"))   # one fitted model, whatever the rotation
# To pin the frame for estimation, mirt fixes one slope at 0 (here the last item's
# second slope); the rotations above are applied afterwards.
v <- mod2values(m2e)
v[v$name %in% c("a1", "a2") & !v$est, c("item", "name", "value")]
# fscores() rotates an exploratory model's abilities too (oblimin by default), while
# coef() reports unrotated slopes. The two sets of abilities are different frames:
th_rot <- fscores(m2e); th_raw <- fscores(m2e, rotate = "none")
round(cor(th_rot, th_raw, use = "complete.obs"), 2)

## ---- imv-functions
# The IMV (Domingue et al., 2024, 2025), as in the lesson on model fit and prediction.
coin <- function(ll) {
  if (ll <= log(0.5)) return(0.5)
  uniroot(function(w) w * log(w) + (1 - w) * log(1 - w) - ll, c(0.5, 1 - 1e-12), tol = 1e-12)$root
}
mean_ll <- function(y, p) mean(y * log(p) + (1 - y) * log(1 - p))
imv <- function(y, p0, p1) {
  w0 <- coin(mean_ll(y, p0)); w1 <- coin(mean_ll(y, p1))
  (w1 - w0) / w0
}
# Predictions for held-out cells from a (multidimensional) 2PL. Abilities must be in the
# same frame as the slopes: coef() gives unrotated slopes, so ask fscores() for
# unrotated abilities (for an exploratory model it rotates them by default).
predict_cells <- function(m, cells) {
  th <- fscores(m, rotate = "none")
  th[is.na(th)] <- 0   # a respondent with every response held out: the prior mean
  cf <- coef(m, simplify = TRUE)$items
  A <- cf[, grep("^a", colnames(cf)), drop = FALSE]
  i <- cells[, 2]
  plogis(rowSums(A[i, , drop = FALSE] * th[cells[, 1], , drop = FALSE]) + cf[i, "d"])
}
# Five-fold cross-validation over responses (cells), as in fit-prediction.
cv_imv <- function(resp, base, better, k = 5, seed = 1) {
  set.seed(seed)
  Xm <- as.matrix(resp)
  cells <- which(!is.na(Xm), arr.ind = TRUE)
  fold <- sample(rep(1:k, length.out = nrow(cells)))
  sapply(1:k, function(f) {
    test <- cells[fold == f, , drop = FALSE]
    train <- as.data.frame(Xm); train[test] <- NA
    p0 <- predict_cells(mirt(train, base, itemtype = "2PL", verbose = FALSE), test)
    p1 <- predict_cells(mirt(train, better, itemtype = "2PL", verbose = FALSE), test)
    imv(Xm[test], p0, p1)
  })
}

## ---- imv
# Dichotomize as in PS6#1: grit 1 = at least "Somewhat like me" in the gritty direction
# (keyed 3-5); mindset 1 = on the incremental side of the scale (keyed 4-6).
B <- X
B[grit] <- 1 * (X[grit] >= 3)
B[mind] <- 1 * (X[mind] >= 4)
round(range(colMeans(B, na.rm = TRUE)), 2)   # proportion coded 1, lowest and highest item
imv_conf <- cv_imv(B, 1, spec)   # confirmatory 2D over 1D
imv_expl <- cv_imv(B, 1, 2)      # exploratory 2D over 1D
round(rbind(confirmatory = imv_conf, exploratory = imv_expl), 4)
round(c(confirmatory = mean(imv_conf), exploratory = mean(imv_expl)), 4)

## ---- q3
# Local dependence: Yen's Q3, the correlation between two items' residuals after the
# two-dimensional model has accounted for grit and mindset. The eight largest in size:
q3 <- residuals(m2, type = "Q3", verbose = FALSE)
q3[upper.tri(q3, diag = TRUE)] <- NA
top <- order(abs(q3), decreasing = TRUE)[1:8]
data.frame(item1 = rownames(q3)[row(q3)[top]], item2 = colnames(q3)[col(q3)[top]],
           Q3 = round(q3[top], 2))

## ---- method
# Wording direction in the mindset scale. Two correlated dimensions, one per wording:
Mi <- X[mind]
g1 <- mirt(Mi, 1, itemtype = "graded", verbose = FALSE)
g2 <- mirt(Mi, mirt.model("ENTITY = 1, 2, 4, 6
                           INCREMENTAL = 3, 5, 7, 8
                           COV = ENTITY*INCREMENTAL"), itemtype = "graded", verbose = FALSE)
anova(g1, g2)
round(coef(g2, simplify = TRUE)$cov[1, 2], 2)
# A method factor: one general mindset dimension for all eight items, plus a factor for
# the four incremental-worded items only, uncorrelated with it (a bifactor model).
bf <- bfactor(Mi, c(NA, NA, 1, NA, 1, NA, 1, 1), itemtype = "graded", verbose = FALSE)
L <- summary(bf, verbose = FALSE)$rotF
round(L, 2)
# Omega from the standardized loadings (normal-ogive scale).
gen <- sum(L[, 1])^2; meth <- sum(L[, 2])^2; uniq <- sum(1 - rowSums(L^2))
round(c(omega_total = (gen + meth) / (gen + meth + uniq),
        omega_h = gen / (gen + meth + uniq),
        alpha = psych::alpha(Mi, warnings = FALSE)$total$raw_alpha), 2)
