# Models for polytomous responses with real data: seven PROMIS pain-interference items
# (promis1wave1_pain) and four attitudes-to-science items from the 1992 Euro-Barometer
# (science_ltm), from the Item Response Warehouse. Needs the mirt package, and psych
# for the polychoric factor analysis. No login or token needed; every chunk runs in
# a few seconds. Adapted from ben-domingue/252: c8/basic_polytomous_analysis.R,
# c9/polyexample.R and ps8/polytomous_estimates.R.

## ---- fetch-pain
library(mirt)
set.seed(8)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/) with a
# CSV download. This link is pinned to one version of the data.
pain_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0.promis1wave1_pain/rows?format=csv"
df <- read.csv(pain_url)
c(respondents = length(unique(df$id)), items = length(unique(df$item)))
wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
# The bank was given in blocks, so each respondent answered only some items. Seven
# interference items (PAININ36-PAININ42) were often given together. Responses run
# from 1 (never, or not at all) to 5 (always, or very much): higher = more
# interference, so no item needs reversing. We recode to 0-4.
items <- paste0("PAININ", 36:42)
pain <- as.data.frame(wide[complete.cases(wide[, items]), items]) - 1
nrow(pain)                                    # respondents who answered all seven
round(prop.table(table(unlist(pain))), 2)     # share of responses in each category
mean(rowSums(pain) == 0)                      # share who chose 0 on every item

## ---- fit-pain
# Four models. mirt's "Rasch" itemtype is the partial credit model when items have
# more than two categories; it fixes every slope at 1 and estimates the SD of theta.
models <- c(PCM = "Rasch", GPCM = "gpcm", GRM = "graded", sequential = "sequential")
fits <- lapply(models, function(m) mirt(pain, 1, itemtype = m, verbose = FALSE))
t(sapply(fits, function(f) c(parameters = extract.mirt(f, "nest"),
                             logLik = round(extract.mirt(f, "logLik")),
                             AIC = round(extract.mirt(f, "AIC")),
                             BIC = round(extract.mirt(f, "BIC")))))
# GRM slopes and category boundaries. mirt writes the GRM as P(x >= k) =
# logistic(a * theta + d_k); IRTpars = TRUE converts to our b_k = -d_k / a.
round(coef(fits$GRM, IRTpars = TRUE, simplify = TRUE)$items, 2)

## ---- scores-pain
# Each respondent's expected a posteriori (EAP) score under each model.
theta <- sapply(fits, function(f) fscores(f, method = "EAP")[, 1])
round(cor(theta), 3)

## ---- crf-pain
# Category response functions for one item under three models. (The PCM is left out:
# it estimates the SD of theta rather than fixing it at 1, so its theta is on a
# different scale.)
th <- matrix(seq(-2, 4, length.out = 241))
item <- "PAININ40"
cols <- c(GPCM = "#c2410c", GRM = "#2780e3", sequential = "black")
op <- par(mar = c(4, 4, 1, 1))
plot(NA, xlim = range(th), ylim = c(0, 1), xlab = "Pain interference θ",
     ylab = "Probability of each category", las = 1)
for (m in names(cols)) {
  p <- probtrace(extract.item(fits[[m]], which(items == item)), th)
  matlines(th, p, lty = 1, lwd = 2, col = cols[m])
}
legend("right", names(cols), col = cols, lwd = 2, bty = "n")
par(op)

## ---- steps-pain
# GPCM step difficulties: b_k is where categories k - 1 and k are equally likely.
# When b_2 < b_1, category 1 ("rarely", or "a little bit") is never the most
# likely response.
gpcm_b <- coef(fits$GPCM, IRTpars = TRUE, simplify = TRUE)$items
round(gpcm_b, 2)
rownames(gpcm_b)[gpcm_b[, "b2"] < gpcm_b[, "b1"]]    # items with disordered steps
round(sapply(pain, function(x) prop.table(table(factor(x, 0:4)))), 2)
# Is category 1 ever the most likely response, anywhere on the scale? Under the
# GPCM and under the GRM, which cannot have disordered boundaries:
th_all <- matrix(seq(-4, 5, length.out = 901))
sapply(c("GPCM", "GRM"), function(m) sapply(setNames(seq_along(items), items), function(i)
  any(apply(probtrace(extract.item(fits[[m]], i), th_all), 1, which.max) == 2)))

## ---- sufficiency-pain
# Under the PCM the sum score is sufficient: equal sum scores, equal estimates.
# Under the GRM they can differ. Largest spread of EAP scores within a sum score:
r <- rowSums(pain)
sapply(c("PCM", "GRM"), function(m) round(max(tapply(theta[, m], r, function(v) diff(range(v)))), 2))

## ---- info-pain
# Test information from the GRM, and from a 2PL fitted to the same items
# dichotomized at "any interference" (x >= 1). Each fit sets the SD of theta in
# these respondents to 1, so the two curves are on comparable scales.
pain01 <- as.data.frame(1 * (pain >= 1))
fit01 <- mirt(pain01, 1, itemtype = "2PL", verbose = FALSE)
at <- matrix(c(-1, 0, 1, 2, 3))
round(data.frame(theta = at[, 1], GRM = testinfo(fits$GRM, at), dichotomized = testinfo(fit01, at)), 1)
# Where the respondents are: the share of GRM scores below 0, and the score shared
# by everyone who answered 0 to all seven items.
round(c(below_0 = mean(theta[, "GRM"] < 0), floor_score = unique(theta[r == 0, "GRM"])), 2)

## ---- info-plot-pain
grid_th <- matrix(seq(-3, 4, length.out = 281))
op <- par(mar = c(4, 4, 1, 1))
hist(theta[, "GRM"], breaks = seq(-3, 4, 0.25), freq = FALSE, col = "#93c5fd", border = "white",
     xlim = c(-3, 4), ylim = c(0, 1), main = "", xlab = "Pain interference θ",
     ylab = "Score density (bars); information / 40", las = 1)
lines(grid_th, testinfo(fits$GRM, grid_th) / 40, lwd = 2.5, col = "#2780e3")
lines(grid_th, testinfo(fit01, grid_th) / 40, lwd = 2.5, col = "#c2410c", lty = 2)
legend("topright", c("GRM, five categories", "2PL, any interference"), col = c("#2780e3", "#c2410c"),
       lwd = 2.5, lty = c(1, 2), bty = "n")
par(op)

## ---- fetch-sci
sci_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0.science_ltm/rows?format=csv"
ds <- read.csv(sci_url)
sci <- as.data.frame(tapply(ds$resp, list(ds$id, ds$item), function(x) x[1]))
c(respondents = nrow(sci), complete = sum(complete.cases(sci)))
# Keying. resp_raw carries the labels from the ltm package, which say 4 = strongly
# agree for every item:
table(ds$resp, ds$resp_raw)
# Industry is worded against science (research does not matter to industrial
# development). Read with those labels, 85% of respondents would agree with it:
round(prop.table(table(sci$Industry)), 2)

## ---- clusters-sci
# Rank correlations between the four items worded for science and the three worded
# against it, then a two-factor analysis of the polychoric correlations.
pos <- c("Comfort", "Work", "Future", "Benefit")
neg <- c("Environment", "Technology", "Industry")
round(range(cor(sci, method = "spearman")[pos, neg]), 2)
efa <- psych::fa(sci, nfactors = 2, cor = "poly", rotate = "oblimin")
print(efa$loadings, cutoff = 0.3)
round(efa$Phi[1, 2], 2)                       # the correlation between the factors

## ---- fit-sci
sci4 <- sci[, pos] - 1                        # the four items worded for science, 0-3
round(sapply(sci4, function(x) prop.table(table(factor(x, 0:3)))), 2)
fits4 <- lapply(models, function(m) mirt(sci4, 1, itemtype = m, verbose = FALSE))
t(sapply(fits4, function(f) c(parameters = extract.mirt(f, "nest"),
                              AIC = round(extract.mirt(f, "AIC")),
                              BIC = round(extract.mirt(f, "BIC")))))
round(coef(fits4$GRM, IRTpars = TRUE, simplify = TRUE)$items, 2)
round(cor(sapply(fits4, function(f) fscores(f, method = "EAP")[, 1])), 2)
