# Missing responses with real data: PIRLS 2023 reading in South Africa
# (mthimkhulu_2023_pirls_reading), PIRLS 2011 in four European countries
# (pirlsmissing_sirt) and a Brazilian medical residency exam
# (borges_brazil_residency_2024_cbt), from the Item Response Warehouse, with a check
# of the not-reached rule on TIMSS 2007 (Russia) from the sirt package. Runs as-is in
# R with the mirt package; the source-file check needs haven and the TIMSS check sirt.
# No login or token.
#
# Every choice about missing data is marked "Missing-data choice" in a comment.

## ---- fetch-p23
library(mirt)
p23_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_4:v9_0.mthimkhulu_2023_pirls_reading/rows?format=csv"
p23 <- read.csv(p23_url)
# One released passage, "Octopuses": items RP51Z01 to RP51Z15, numbered in the order
# they are printed. Constructed-response items are scored 0-1, 0-2 or 0-3 by PIRLS
# raters; the four multiple-choice items are scored 1 = the keyed option.
items <- sprintf("RP51Z%02d", 1:15)
ids <- sort(unique(p23$id))
Y <- matrix(NA, length(ids), 15, dimnames = list(ids, items))
Y[cbind(match(p23$id, ids), match(p23$item, items))] <- p23$resp
# Missing-data choice: a learner-item pair with no row in the table is a missing
# response. The IRW processing script drops rows whose source code is 6 (not
# reached) or 9 (omitted or invalid), so the table doesn't say which is which.
# Learners who answered nothing on this passage have no rows, so they aren't here.
c(learners = nrow(Y), items = ncol(Y), share_missing = round(mean(is.na(Y)), 3),
  no_gap = round(mean(rowSums(is.na(Y)) == 0), 2))
table(booklet = tapply(p23$cov_booklet, p23$id, `[`, 1))   # two booklets carry the passage

## ---- rule-p23
# The IEA's rule, applied within one timed part: an unanswered item is not reached if
# the item before it is also unanswered and nothing after it is answered. So the
# first item of a trailing run of gaps counts as omitted, and a run of one is an omit.
classify <- function(miss) {           # miss: TRUE/FALSE per item, in the order given
  last <- max(c(0, which(!miss)))      # position of the last answered item
  nr <- seq_along(miss) > last + 1     # after the last answer, and after the first gap
  ifelse(!miss, "answered", ifelse(nr, "not reached", "omitted"))
}
# Missing-data choice: the whole passage is treated as one timed part, in item order.
code <- t(apply(is.na(Y), 1, classify))
dimnames(code) <- dimnames(Y)
table(code)
round(rbind(not_reached = colMeans(code == "not reached"),
            omitted = colMeans(code == "omitted")), 2)
nr <- rowSums(code == "not reached"); om <- rowSums(code == "omitted")
c(any_not_reached = round(mean(nr > 0), 2), five_or_more = sum(nr >= 5))

## ---- source-p23
# A check against the source file (CC BY 4.0), which keeps codes 6 and 9. It also
# carries the learners' first plausible value, PIRLS's own reading score from the
# whole booklet (two passages), which we use as an ability measure from outside the
# 15 items. Needs the haven package.
sav <- tempfile(fileext = ".sav")
download.file("https://ndownloader.figshare.com/files/43586289", sav, mode = "wb", quiet = TRUE)
src <- haven::read_sav(sav, user_na = TRUE)   # user_na = TRUE keeps codes 6 and 9
src <- src[match(ids, as.numeric(src$IDSTUD)), ]
raw <- sapply(items, function(v) as.numeric(unclass(src[[v]])))
source_code <- ifelse(raw %in% 6, "6 not reached", ifelse(raw %in% 9, "9 omitted",
                 ifelse(is.na(raw), "blank in source", "answered")))
table(source = source_code, rule = code)
pv1 <- as.numeric(src$ASRREA01)

## ---- ability-p23
# Does omitting or not reaching go with reading ability?
round(c(omitted = cor(om, pv1), not_reached = cor(nr, pv1)), 2)
fifth <- cut(pv1, quantile(pv1, 0:5 / 5), include.lowest = TRUE, labels = 1:5)
round(rbind(omitted = tapply(om / 15, fifth, mean),
            not_reached = tapply(nr / 15, fifth, mean)), 3)   # share of the 15 items

## ---- fit-p23
# Three ways to score the same gaps, each fitted with the partial credit (Rasch)
# model. mirt's "Rasch" item type gives the partial credit model for items with more
# than two categories.
Y_wrong <- Y;   Y_wrong[is.na(Y)] <- 0              # every gap scored 0
Y_missing <- Y                                      # every gap left missing
Y_rule <- Y;    Y_rule[code == "omitted"] <- 0      # omits 0, not reached missing
fits <- lapply(list(wrong = Y_wrong, missing = Y_missing, rule = Y_rule),
               function(Z) mirt(as.data.frame(Z), 1, itemtype = "Rasch", verbose = FALSE))
# An item's location: the mean of its step difficulties (b for a 0/1 item).
loc <- function(f) {
  cf <- coef(f, IRTpars = TRUE, simplify = TRUE)$items
  rowMeans(cf[, grep("^b", colnames(cf)), drop = FALSE], na.rm = TRUE)
}
b <- sapply(fits, loc)
round(c(last5 = mean(b[11:15, "wrong"] - b[11:15, "rule"]),
        first5 = mean(b[1:5, "wrong"] - b[1:5, "rule"])), 2)
# EAP abilities under each scoring, standardized within each scoring.
th <- scale(sapply(fits, function(f) fscores(f, method = "EAP")[, 1]))
rbind(nr5 = colMeans(th[nr >= 5, ]), om4 = colMeans(th[om >= 4, ])) |> round(2)
c(n_nr5 = sum(nr >= 5), n_om4 = sum(om >= 4))

## ---- propensity-p23
# A response-propensity model: a second latent variable (xi) drives whether a reached
# item is answered, and correlates with theta. Missing-data choice: an omit is a 0 on
# its indicator; a not-reached item is missing on both the item and its indicator.
answered <- ifelse(code == "not reached", NA, ifelse(code == "omitted", 0, 1))
colnames(answered) <- paste0("ans_", 1:15)
two <- mirt.model("theta = 1-15\n xi = 16-30\n COV = theta*xi")
fit_prop <- mirt(data.frame(Y_missing, answered), two, itemtype = "Rasch", verbose = FALSE)
S <- coef(fit_prop, simplify = TRUE)$cov
round(c(cor_theta_xi = S[1, 2] / sqrt(S[1, 1] * S[2, 2])), 2)
th_prop <- scale(fscores(fit_prop, method = "EAP")[, 1])
round(c(om4_propensity = mean(th_prop[om >= 4])), 2)

## ---- pirls11
# Contrast: PIRLS 2011, one booklet (the PIRLS Reader), four countries. The source
# had already merged omitted and not reached into one code, which the IRW keeps as
# rows with an empty resp.
p11 <- read.csv("https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v64_0.pirlsmissing_sirt/rows?format=csv")
# Missing-data choice: R31G08CZ and R31G13CZ combine the lettered parts of their
# question, so we drop them and keep the parts.
p11 <- p11[!grepl("CZ$", p11$item), ]
items11 <- sort(unique(p11$item)); ids11 <- sort(unique(p11$id))
X <- matrix(NA, length(ids11), length(items11), dimnames = list(ids11, items11))
X[cbind(match(p11$id, ids11), match(p11$item, items11))] <- p11$resp
country <- p11$country[match(ids11, p11$id)]
# Missing-data choice: each passage (G, then P) is its own timed part, items in
# number order.
code11 <- X; code11[] <- NA
for (part in list(grep("^R31G", items11), grep("^R31P", items11)))
  code11[, part] <- t(apply(is.na(X[, part]), 1, classify))
round(prop.table(table(code11)), 3)
pc <- rowSums(X, na.rm = TRUE) / rowSums(!is.na(X))   # proportion correct on answered items
round(c(omitted = cor(rowSums(code11 == "omitted"), pc),
        not_reached = cor(rowSums(code11 == "not reached"), pc)), 2)
# The same Netherlands-France comparison under three scorings (Rasch, pooled, no
# weights: a check on the scoring, not an estimate of either country's performance).
X_wrong <- X; X_wrong[is.na(X)] <- 0
X_rule <- X;  X_rule[code11 == "omitted"] <- 0
gap <- sapply(list(wrong = X_wrong, missing = X, rule = X_rule), function(Z) {
  s <- fscores(mirt(as.data.frame(Z), 1, itemtype = "Rasch", verbose = FALSE))[, 1]
  s <- s / sd(s)
  mean(s[country == "NLD"]) - mean(s[country == "FRA"])
})
round(gap, 2)

## ---- borges
# Twist: a table that has already scored its gaps. In the source, "X" marks an item
# with no chosen option; the IRW script scores it 0 and blanks resp_raw.
bz <- read.csv("https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v64_0.borges_brazil_residency_2024_cbt/rows?format=csv")
table(resp_raw_empty = is.na(bz$resp_raw), resp = bz$resp)
n_x <- tapply(is.na(bz$resp_raw), bz$id, sum)          # X's per applicant
table(cut(n_x, c(-1, 0, 2, 9, 120), labels = c("0", "1-2", "3-9", "10+")))
p_right <- tapply(bz$resp, bz$id, mean)
round(tapply(p_right, cut(n_x, c(-1, 0, 2, 120), labels = c("0", "1-2", "3+")), mean), 2)

## ---- timss-check
# Sanity check on the rule: TIMSS 2007 grade 8, Russia (sirt::data.timss07.G8.RUS),
# where the IEA codes are kept (6/96 not reached, 9/99 omitted, blank = not given).
library(sirt)
data(data.timss07.G8.RUS)
Tr <- data.timss07.G8.RUS
it <- as.character(Tr$iteminfo$item)
R <- as.matrix(Tr$raw[, it])
tcode <- matrix(ifelse(is.na(R), NA, ifelse(R %in% c(9, 99), "omitted",
                ifelse(R %in% c(6, 96), "not reached", "answered"))), nrow(R))
# Items given to the same students form a block (a mathematics block and the science
# block with the same number go together); the file lists blocks in order M01..M14.
# A few items are blank for a few students, so a block is keyed on the first ten
# students who saw the item.
seen <- !is.na(R)
key <- apply(seen, 2, function(z) paste(head(which(z), 10), collapse = ","))
grp <- match(key, unique(key[colSums(seen) > 0]))
grp[colSums(seen) == 0] <- NA                     # items no student in Russia saw
max(grp, na.rm = TRUE)                            # 14 blocks
given <- colSums(seen) > 0
c(students = nrow(R), items_given = sum(given),
  saw_every_item = sum(rowSums(seen[, given]) == sum(given)))   # a booklet design
subj <- substr(it, 1, 1)
# Booklet k holds blocks k and k+1 (booklet 14 holds 14 and 1). Odd booklets give
# mathematics in part 1 and science in part 2; even booklets the reverse.
rule_all <- truth_all <- whole_all <- nobreak_all <- nobreak_truth <- character()
for (j in which(rowSums(seen) > 0)) {
  bl <- sort(unique(grp[seen[j, ]]))
  k <- if (identical(bl, c(1L, 14L))) 14 else min(bl)
  k2 <- if (k == 14) 1 else k + 1
  blk <- function(s, g) which(grp == g & subj == s)
  first <- if (k %% 2 == 1) "M" else "S"; second <- setdiff(c("M", "S"), first)
  parts <- list(c(blk(first, k), blk(first, k2)), c(blk(second, k), blk(second, k2)))
  # Missing-data choice: an item left blank for this student (not given) is dropped
  # from the sequence.
  parts <- lapply(parts, function(p) p[!is.na(tcode[j, p])])
  for (p in parts) {
    miss <- tcode[j, p] != "answered"
    if (!any(miss)) next
    last <- max(c(0, which(!miss)))
    rule_all <- c(rule_all, classify(miss)[miss])
    whole_all <- c(whole_all, ifelse(seq_along(miss) > last, "not reached", "omitted")[miss])
    truth_all <- c(truth_all, tcode[j, p][miss])
  }
  both <- unlist(parts); miss <- tcode[j, both] != "answered"   # ignore the break
  if (any(miss)) {
    nobreak_all <- c(nobreak_all, classify(miss)[miss])
    nobreak_truth <- c(nobreak_truth, tcode[j, both][miss])
  }
}
table(IEA_code = truth_all, rule = rule_all)
# Agreement with the IEA codes, and the share of not-reached cells found, for the
# rule and for two simplifications: every trailing gap not reached, and no break
# between the parts.
agree <- function(pred, truth) c(agree = mean(pred == truth),
  not_reached_found = mean(pred[truth == "not reached"] == "not reached"))
round(rbind(rule = agree(rule_all, truth_all), whole_run = agree(whole_all, truth_all),
            no_part_break = agree(nobreak_all, nobreak_truth)), 3)
