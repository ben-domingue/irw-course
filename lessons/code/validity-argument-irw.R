# Validity as an argument: what does a near-perfect separation of children with
# and without ADHD tell us about a symptom count? Parent-reported DSM-IV symptoms
# from the Children's Attention Project (Silk et al., 2019), in two IRW tables:
# silk_2019_inattentive and silk_2019_hyperactive. Runs as-is in base R; no
# packages, login or token needed. New for this course (EDUC 252 c3 has no data
# analysis of validity).

## ---- fetch
# The two IRW tables, from the CSV links on their landing pages (pinned to one version).
base <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_4:v7_0."
ina  <- read.csv(paste0(base, "silk_2019_inattentive/rows?format=csv"))
hyp  <- read.csv(paste0(base, "silk_2019_hyperactive/rows?format=csv"))
head(ina[, c("id", "item", "resp", "cov_ADHD", "cov_age")], 3)
c(rows_inattentive = nrow(ina), rows_hyperactive = nrow(hyp),
  children = length(unique(ina$id)), missing = sum(is.na(ina$resp)) + sum(is.na(hyp$resp)))

## ---- wide
# One row per child. Both tables were built from the same rows of the study's data
# file, so `id` matches across them; the check below confirms that the covariates
# agree child by child. resp is 1 when the parent reported the symptom.
wide <- function(d) {
  w <- reshape(d[, c("id", "item", "resp")], idvar = "id", timevar = "item", direction = "wide")
  names(w) <- sub("^resp\\.", "", names(w))
  w[order(w$id), ]
}
wi <- wide(ina); wh <- wide(hyp)
kids <- unique(ina[, c("id", "cov_ADHD", "cov_age", "cov_male")])
kids <- kids[order(kids$id), ]
kids_h <- unique(hyp[, c("id", "cov_ADHD", "cov_age", "cov_male")])
all.equal(kids, kids_h[order(kids_h$id), ], check.attributes = FALSE)
items_i <- setdiff(names(wi), "id"); items_h <- setdiff(names(wh), "id")
kids$inattentive <- rowSums(wi[, items_i])
kids$hyperactive <- rowSums(wh[, items_h])
table(ADHD = kids$cov_ADHD)
round(range(kids$cov_age), 1)

## ---- alpha
# Alpha for each nine-item count (the function from the reliability lesson).
alpha <- function(x) {
  k <- ncol(x)
  k / (k - 1) * (1 - sum(apply(x, 2, var)) / var(rowSums(x)))
}
round(c(inattentive = alpha(wi[, items_i]), hyperactive = alpha(wh[, items_h])), 2)

## ---- separate
# How well does each count separate the two groups? The AUC is the chance that a
# randomly chosen child with ADHD has a higher count than a randomly chosen child
# without, counting ties as half: 0.5 is no separation, 1 is perfect.
auc <- function(score, group) {
  r <- rank(score); n1 <- sum(group == 1); n0 <- sum(group == 0)
  (sum(r[group == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}
table(inattentive_count = kids$inattentive, ADHD = kids$cov_ADHD)
with(kids, c(without_ADHD_6plus = sum(inattentive >= 6 & cov_ADHD == 0),
             with_ADHD_6plus    = sum(inattentive >= 6 & cov_ADHD == 1)))
round(c(inattentive = auc(kids$inattentive, kids$cov_ADHD),
        hyperactive = auc(kids$hyperactive, kids$cov_ADHD)), 2)

## ---- rule
# The DSM-IV symptom rule: six or more of the nine symptoms in either domain.
kids$rule <- kids$inattentive >= 6 | kids$hyperactive >= 6
table(six_or_more_in_either = kids$rule, ADHD = kids$cov_ADHD)
# Which domain(s) meet the rule, among the children with ADHD.
with(kids[kids$cov_ADHD == 1, ],
     table(inattentive_6plus = inattentive >= 6, hyperactive_6plus = hyperactive >= 6))
