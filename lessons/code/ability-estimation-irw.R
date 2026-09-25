# Estimating abilities with real data: the Wordsum vocabulary test, as given to UK
# adults in wave 6 of the COVID-19 Psychological Research Consortium study
# (c19prc_uk_mcbride_2021_wordsum), from the Item Response Warehouse. Runs as-is in
# R with the mirt package; no login or token.
# Adapted from ben-domingue/252: ps3/1_abilities.R and ps5/eap_versus_mle.R.

## ---- fetch-ws
library(mirt)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/) with a
# CSV download. This link is pinned to one version of the data.
ws_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_4:v7_0.c19prc_uk_mcbride_2021_wordsum/rows?format=csv"
df <- read.csv(ws_url)
table(df$wave)   # one wave (6), so one response per respondent and item
# resp is 1 when the respondent chose the listed word closest in meaning to the target
# word, and 0 for any other choice, including "don't know".
wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
wide <- as.data.frame(wide[, order(as.numeric(gsub("\\D", "", colnames(wide))))])
c(respondents = nrow(wide), items = ncol(wide), complete = sum(complete.cases(wide)))
round(colMeans(wide), 2)   # proportion correct, item by item
r <- rowSums(wide)          # sum score, 0 to 10
table(r)

## ---- fit-ws
# The Rasch model. mirt fixes every slope at 1 and the mean ability at 0, and
# estimates the SD of ability; its d is an easiness, so our difficulty is b = -d.
m <- mirt(wide, 1, itemtype = "Rasch", verbose = FALSE)
b <- -coef(m, simplify = TRUE)$items[, "d"]
round(sort(b), 2)
c(sd_theta = round(sqrt(coef(m)$GroupPars[, "COV_11"]), 2))

## ---- nomle-ws
# How many respondents have no finite maximum-likelihood estimate?
ml <- fscores(m, method = "ML", full.scores.SE = TRUE)
data.frame(zero = sum(r == 0), perfect = sum(r == 10), no_mle = sum(r %in% c(0, 10)),
           share = round(mean(r %in% c(0, 10)), 3))
table(ml[, "F1"][r %in% c(0, 10)])   # mirt reports them as -Inf and Inf

## ---- estimators-ws
# Four estimators. Under the Rasch model each is a function of the sum score alone,
# so one row per score says everything (the last line checks it).
meth <- c("ML", "WLE", "MAP", "EAP")
est <- lapply(meth, function(k) fscores(m, method = k, full.scores.SE = TRUE))
names(est) <- meth
by_r <- function(col) sapply(est, function(e) tapply(e[, col], r, function(z) z[1]))
tab <- data.frame(score = 0:10, n = as.vector(table(r)), round(by_r("F1"), 2),
                  SE = round(by_r("SE_F1"), 2), check.names = FALSE)
print(tab, row.names = FALSE)
c(largest_spread_within_a_score = round(max(sapply(est, function(e)
  max(tapply(e[, "F1"], r, function(z) diff(range(z))), na.rm = TRUE))), 4))

## ---- se-ws
# The ML standard error is 1 / sqrt(test information) at the estimate.
fin <- is.finite(ml[, "F1"])
all.equal(unname(ml[fin, "SE_F1"]), 1 / sqrt(testinfo(m, ml[fin, "F1", drop = FALSE])),
          tolerance = 1e-4)

## ---- shrink-ws
# EAPs are pulled toward the mean: their SD is below the model's SD of ability.
# The posterior variances make up the difference.
eap <- est$EAP
sd_model <- sqrt(coef(m)$GroupPars[, "COV_11"])
round(c(sd_model = sd_model, sd_eap = sd(eap[, "F1"]), sd_wle = sd(est$WLE[, "F1"])), 2)
round(c(var_model = sd_model^2, var_eap = var(eap[, "F1"]),
        mean_posterior_var = mean(eap[, "SE_F1"]^2),
        sum = var(eap[, "F1"]) + mean(eap[, "SE_F1"]^2)), 2)

## ---- twopl-ws
# The 2PL. Now the weighted score sum(a * x) carries the information about theta,
# so respondents with the same sum score can get different estimates.
m2 <- mirt(wide, 1, itemtype = "2PL", verbose = FALSE)
c(BIC_Rasch = round(extract.mirt(m, "BIC")), BIC_2PL = round(extract.mirt(m2, "BIC")))
a <- coef(m2, simplify = TRUE)$items[, "a1"]
round(a, 2)
eap2 <- fscores(m2, method = "EAP")[, "F1"]
five <- r == 5
w <- as.matrix(wide) %*% a   # weighted score
data.frame(respondents = sum(five),
  patterns = nrow(unique(wide[five, ])),
  weighted_scores = length(unique(round(w[five], 6))),
  EAPs = length(unique(round(eap2[five], 6))),
  lowest = round(min(eap2[five]), 2), highest = round(max(eap2[five]), 2),
  rank_cor = round(cor(w[five], eap2[five], method = "spearman"), 3))
