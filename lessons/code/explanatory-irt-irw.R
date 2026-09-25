# Explanatory item response models with real data: the verbal aggression items
# (verbagg), the TROG grammar test (trog_brinchmann_2019) and the hearts and
# flowers task (imps2025_hf), all from the Item Response Warehouse. Needs lme4
# (Bates, Maechler, Bolker & Walker, 2015); the one Go deeper chunk also uses mirt.
# No login or token: every CSV link is pinned to one version of the IRW data.
# Every model is fit with glmer(). The verbagg fits take a few seconds each, the
# hearts and flowers fits about half a minute, and the two TROG fits several
# minutes between them.
# Adapted from ben-domingue/252: ps6/hf.R (hearts and flowers) and the lme4
# formulation of De Boeck et al. (2011).

## ---- fetch-verbagg
library(lme4)
options(digits = 7)  # R's default, in case a .Rprofile changes it
# nloptwrap is much quicker than glmer's default optimizer when a model has many
# fixed effects, as the Rasch model (one per item) does. The other models have few
# fixed effects and use the default.
ctl <- glmerControl(optimizer = "nloptwrap")
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.verbagg/rows?format=csv"
va <- read.csv(url)
va$item <- tolower(va$item)   # one item is stored as S4wantCurse
# The item name carries the design: situation 1-4, want or do, and a behaviour.
va$behav <- factor(sub(".*(curse|scold|shout)$", "\\1", va$item))
va$mode  <- factor(ifelse(grepl("want", va$item), "want", "do"), levels = c("do", "want"))
va$situ  <- factor(ifelse(grepl("^s[12]", va$item), "other", "self"))  # who is to blame
items <- unique(va[, c("item", "situ", "mode", "behav")])
items <- items[order(items$item), ]
rownames(items) <- NULL
c(respondents = length(unique(va$id)), items = nrow(items), responses = nrow(va))
head(items, 6)

## ---- sanity
# Sanity check: the same data ship with lme4 (VerbAgg, with r2 = "Y" when the
# answer was perhaps or yes). If the item proportions agree, the models below
# can be checked against De Boeck et al. (2011), who fit them to VerbAgg.
p_irw <- tapply(va$resp, va$item, mean)
p_lme4 <- tapply(VerbAgg$r2 == "Y", tolower(VerbAgg$item), mean)
all.equal(p_irw, p_lme4[names(p_irw)], check.attributes = FALSE)

## ---- rasch
# The Rasch model as a mixed logistic regression: a fixed intercept for each item
# (its easiness, so b = -coefficient) and a random intercept for each respondent
# (theta, with mean 0 and an SD to estimate).
rasch <- glmer(resp ~ 0 + item + (1 | id), data = va, family = binomial, control = ctl)
easy <- fixef(rasch)
names(easy) <- sub("^item", "", names(easy))
round(head(sort(easy), 3), 2)   # the hardest items: all three about shouting
round(tail(sort(easy), 3), 2)   # the easiest
VarCorr(rasch)                  # SD of theta

## ---- lltm
# The LLTM: 24 easinesses replaced by an intercept and four design effects.
lltm <- glmer(resp ~ behav + situ + mode + (1 | id), data = va, family = binomial)
round(fixef(lltm), 2)
VarCorr(lltm)

## ---- lrtest
anova(lltm, rasch)

## ---- explained
# How much of the Rasch easiness does the design account for?
X <- model.matrix(~ behav + situ + mode, items)
pred <- drop(X %*% fixef(lltm))
e <- easy[items$item]
round(c(r = cor(e, pred), r_squared = cor(e, pred)^2), 2)
plot(pred, e, pch = 19, col = "#2780e3",
     xlab = "Easiness predicted by the design (LLTM)", ylab = "Easiness from the Rasch model")
abline(lm(e ~ pred), lty = 2)
far <- order(-abs(resid(lm(e ~ pred))))[1:3]
text(pred[far], e[far], items$item[far], pos = 4, cex = 0.8)

## ---- residual
# The LLTM with an item residual: items scatter around the design's prediction
# with an SD to estimate.
lltm_r <- glmer(resp ~ behav + situ + mode + (1 | id) + (1 | item), data = va,
                family = binomial)
round(fixef(lltm_r), 2)
VarCorr(lltm_r)
AIC(rasch, lltm, lltm_r)

## ---- interaction
# Is the gap between wanting and doing the same for every behaviour?
lltm_ri <- glmer(resp ~ behav * mode + situ + (1 | id) + (1 | item), data = va,
                 family = binomial)
round(coef(summary(lltm_ri))[, 1:2], 2)   # estimates and standard errors
VarCorr(lltm_ri)
anova(lltm_r, lltm_ri)

## ---- mirt-compare
# The same Rasch model fit by mirt (EM, integrating over theta by quadrature)
# against glmer (Laplace approximation). mirt's d is the easiness, like glmer's
# item coefficient. (mirt is not attached with library(): it has its own
# fixef(), which would mask lme4's.)
wide <- tapply(va$resp, list(va$id, va$item), function(x) x[1])
m_mirt <- mirt::mirt(as.data.frame(wide), 1, itemtype = "Rasch", verbose = FALSE)
d_mirt <- mirt::coef(m_mirt, simplify = TRUE)$items[, "d"]
round(c(max_abs_difference = max(abs(d_mirt[items$item] - easy[items$item])),
        sd_theta_mirt = sqrt(mirt::coef(m_mirt, simplify = TRUE)$cov[1, 1]),
        sd_theta_glmer = attr(VarCorr(rasch)$id, "stddev")), 3)

## ---- trog-fetch
url_trog <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_2:v24_0.trog_brinchmann_2019/rows?format=csv"
tr <- read.csv(url_trog)
# item_family numbers the 20 blocks of four items; the item names (a1 to t4) use letters.
tr$family <- factor(letters[tr$item_family], levels = letters[1:20])
c(children = length(unique(tr$id)), items = length(unique(tr$item)),
  families = nlevels(tr$family), missing = 210 * 80 - nrow(tr))
round(tapply(tr$resp, tr$family, mean), 2)   # proportion correct, block by block

## ---- trog-families
# Items and blocks both random: how much of item difficulty lies between blocks?
g1 <- glmer(resp ~ 1 + (1 | id) + (1 | family) + (1 | item), data = tr,
            family = binomial)
v1 <- as.data.frame(VarCorr(g1))
v1 <- setNames(v1$vcov, v1$grp)
round(v1, 2)
round(c(share_between_blocks = v1[["family"]] / (v1[["family"]] + v1[["item"]])), 2)

## ---- trog-dependence
# A child x block random effect: a child's standing can shift from block to
# block, so the four items of a block are not independent given theta.
g2 <- glmer(resp ~ 1 + (1 | id) + (1 | family) + (1 | item) + (1 | id:family),
            data = tr, family = binomial)
VarCorr(g2)
anova(g1, g2)

## ---- hf-fetch
url_hf <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_2:v24_0.imps2025_hf/rows?format=csv"
hf <- read.csv(url_hf)
# The mixed block of the grades 3-5 cohort: hearts and flowers in random order.
hf <- hf[hf$cohort == "plus" & hf$block == "mixed test", ]
c(trials = nrow(hf), children = length(unique(hf$id)))
table(grade = hf$cov_grade[!duplicated(hf$id)])
round(tapply(hf$resp, hf$item, mean), 2)   # the four "items": shape x side

## ---- hf-switch
# What came just before? Look up trial n - 1 in the same session and block.
key <- paste(hf$id, hf$time, hf$trial_num)
hf$prev <- hf$stim_shape[match(paste(hf$id, hf$time, hf$trial_num - 1), key)]
hf$switch <- as.integer(hf$stim_shape != hf$prev)
table(switch = hf$switch, useNA = "ifany")   # NA: the previous trial isn't in the table
round(tapply(hf$resp, list(shape = hf$stim_shape, switch = hf$switch), mean), 2)

## ---- hf-models
hs <- hf[!is.na(hf$switch), ]
hs$grade <- factor(hs$cov_grade)
h0 <- glmer(resp ~ 0 + item + (1 | id), data = hs, family = binomial)
h1 <- glmer(resp ~ 0 + item + switch + grade + (1 | id), data = hs, family = binomial)
round(fixef(h1), 2)
VarCorr(h1)
AIC(h0, h1)
