# What is measurement? Rescaling a treatment effect, with real data: gilbert_meta_12
# and gilbert_meta_15 from the Item Response Warehouse. Runs as-is in base R; no
# packages, login or token needed. New for this course (EDUC 252 c1 poses the
# question; the analysis is not in the 252 code).

## ---- fetch
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/)
# with a CSV download. These links are pinned to one version of the data.
vocab_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0.gilbert_meta_12/rows?format=csv"
raven_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0.gilbert_meta_15/rows?format=csv"
vocab_long <- read.csv(vocab_url)
raven_long <- read.csv(raven_url)
head(vocab_long[, c("id", "cluster_id", "item", "resp", "treat")])

## ---- helpers
# One row per respondent: the sum score and the treatment indicator, for the
# respondents who answered every item (responses are 0/1, 1 = correct).
sum_scores <- function(df) {
  df <- df[!is.na(df$resp) & !is.na(df$treat), ]
  n_items <- length(unique(df$item))
  answered <- tapply(df$resp, df$id, length)
  df <- df[df$id %in% names(answered)[answered == n_items], ]
  data.frame(score = as.vector(tapply(df$resp, df$id, sum)),
             treat = as.vector(tapply(df$treat, df$id, function(x) x[1])))
}
# An order-preserving rescaling: f_k(z) = (exp(k z) - 1) / k, and f_0(z) = z.
# k < 0 compresses the top of the scale and stretches the bottom; k > 0 does the
# opposite. Every f_k is strictly increasing, so it keeps everyone's rank.
rescale <- function(z, k) if (k == 0) z else (exp(k * z) - 1) / k
# The treatment effect in SD units: standardize the scores (whole sample),
# then take the treated-minus-control difference in means.
effect <- function(y, treat) {
  y <- (y - mean(y)) / sd(y)
  mean(y[treat == 1]) - mean(y[treat == 0])
}
# For each score s, the share of treated respondents scoring s or more, minus the
# share of control respondents scoring s or more.
share_gap <- function(d) {
  s <- sort(unique(d$score))
  setNames(sapply(s, function(x) mean(d$score[d$treat == 1] >= x) - mean(d$score[d$treat == 0] >= x)), s)
}

## ---- vocab
# 24 vocabulary items: 12 science (sci1-sci12) and 12 social studies (ss1-ss12).
# Some respondents have responses to only one of the two subtests.
answered <- tapply(vocab_long$resp, vocab_long$id, length)
arm <- tapply(vocab_long$treat, vocab_long$id, function(x) x[1])
table(items_answered = answered, treat = arm)
vocab <- sum_scores(vocab_long)
c(respondents = nrow(vocab), control = sum(vocab$treat == 0), treated = sum(vocab$treat == 1))
print(round(tapply(vocab$score, vocab$treat, mean), 1), digits = 6)

## ---- vocab-effect
round(effect(vocab$score, vocab$treat), 2)

## ---- vocab-rescale
z <- (vocab$score - mean(vocab$score)) / sd(vocab$score)
ks <- seq(-4, 4, by = 0.5)
vocab_eff <- sapply(ks, function(k) effect(rescale(z, k), vocab$treat))
round(rbind(k = ks, effect = vocab_eff), 2)
round(range(vocab_eff), 2)
op <- par(mfrow = c(1, 2), mar = c(4, 4, 2, 1))
plot(ks, vocab_eff, type = "b", pch = 19, col = "#2780e3", ylim = c(0, 0.8),
     xlab = "k (negative compresses the top)", ylab = "Treatment effect (SD units)",
     main = "Effect under each rescaling", cex.main = 0.9)
abline(h = 0, col = "#999", lty = 2)
tab <- table(factor(vocab$score, levels = 0:24), vocab$treat)
barplot(t(prop.table(tab, 2)), beside = TRUE, col = c("#999", "#2780e3"), border = NA,
        names.arg = 0:24, las = 2, cex.names = 0.6, xlab = "Sum score", ylab = "Share of group",
        main = "Scores (grey: control; blue: treated)", cex.main = 0.9)
par(op)

## ---- vocab-dominance
vocab_gap <- share_gap(vocab)
round(vocab_gap, 2)
# Look closely at the bottom of the scale: one respondent in each group scored 0.
table(score = vocab$score, treat = vocab$treat)[1:3, ]
signif(vocab_gap[c("1", "24")], 2)
# Smallest and largest difference over scores 2 to 24.
signif(range(vocab_gap[as.character(2:24)]), 2)
# How much would the step from 0 to 1 correct have to count for to reverse the
# sign? Add M points to every score of 1 or more.
raw <- diff(tapply(vocab$score, vocab$treat, mean))
print(c(raw_difference = round(raw[[1]], 2), M_to_reverse = round(raw[[1]] / -vocab_gap[["1"]], -3)), digits = 6)

## ---- raven
# 10 Raven's matrices items. 129 respondents have no treatment status recorded.
c(respondents_in_table = length(unique(raven_long$id)),
  no_treatment_status = length(unique(raven_long$id[is.na(raven_long$treat)])))
raven <- sum_scores(raven_long)
c(respondents = nrow(raven), control = sum(raven$treat == 0), treated = sum(raven$treat == 1))
round(effect(raven$score, raven$treat), 3)
raven_gap <- share_gap(raven)
round(raven_gap, 3)

## ---- raven-top
# The crossing: the share scoring 9 or more in each group, the difference, and
# its standard error.
top <- tapply(raven$score >= 9, raven$treat, mean)
n <- table(raven$treat)
se <- sqrt(sum(top * (1 - top) / n))
round(c(control = top[["0"]], treated = top[["1"]], difference = top[["1"]] - top[["0"]], se = se), 3)

## ---- raven-flip
# A rescaling that stretches the step from 8 to 9 correct: add M points to every
# score of 9 or more. It is strictly increasing for any M > 0.
Ms <- c(0, 5, 10, 20, 50, 100)
round(rbind(M = Ms, effect = sapply(Ms, function(M) effect(raven$score + M * (raven$score >= 9), raven$treat))), 3)
# The smooth rescalings from the vocabulary analysis never reverse it.
round(range(sapply(ks, function(k) effect(rescale((raven$score - mean(raven$score)) / sd(raven$score), k), raven$treat))), 3)
