# AI and psychometrics with real data: can an item's text predict its difficulty
# (himmelstein-impossible_question-2025), and what do items written by a language
# model look like once people answer them (gpt4mcq_young_2025, written by GPT-4;
# genpsych_russell_2024_gpt4o, written by GPT-4o)? Tables from the Item Response
# Warehouse; item text from the studies' own public materials (GitHub and OSF).
# Runs as-is in R with lme4, mirt and haven; no login or token. The three glmer fits
# take about a minute. Adapted from ben-domingue/252: c10/model.R (there, difficulty
# predicted from reading-passage features).

## ---- fetch-iq
suppressPackageStartupMessages(library(lme4))
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/) with a
# CSV download. This link is pinned to one version of the data.
iq_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_2:v24_0.himmelstein-impossible_question-2025/rows?format=csv"
iq <- read.csv(iq_url)
c(respondents = length(unique(iq$id)), items = length(unique(iq$item)),
  max_per_person_item = max(table(iq$id, iq$item)))
# Two waves: each respondent took 30 items in wave 3 and 30 in wave 5.
table(wave = iq$wave)
summary(as.vector(table(iq$id)))

## ---- items-iq
# The questions, from the study's own data file (pinned to one commit of the FPT
# repository): the IRW item code is the file's `id`. `aig_version` says which form an
# item was on: the anchor form, which every respondent took, or one of two forms
# built for automatic item generation (A and B). Impossible questions have ids IQ_*.
src_url <- paste0("https://raw.githubusercontent.com/forecastingresearch/fpt/",
                  "fdbe605700cc172c03abe009bbd894a20f5cb69b/",
                  "data_cognitive_tasks/task_datasets/data_impossible_question.csv")
src <- read.csv(src_url)
items <- unique(src[, c("id", "question_text", "answer_1", "answer_2", "question_type", "aig_version")])
names(items)[1] <- "item"
table(type = items$question_type, form = items$aig_version)
# Which form did each respondent take in which wave? The anchor form in one wave and
# one generated form in the other, so pooling the waves counts each person once per item.
iq$form <- items$aig_version[match(iq$item, items$item)]
table(wave = iq$wave, form = iq$form)

# Two text features, as in the IRW vignette on item language and difficulty: word
# count, and mean word length in characters with punctuation removed.
text_features <- function(txt) {
  words <- strsplit(trimws(gsub("[[:punct:]]", " ", txt)), "\\s+")
  words <- lapply(words, function(w) w[nchar(w) > 0])
  data.frame(word_count = lengths(strsplit(trimws(txt), "\\s+")),
             mean_word_length = vapply(words, function(w) if (length(w)) mean(nchar(w)) else NA_real_, 0))
}
items <- cbind(items, text_features(items$question_text))
items$impossible <- as.integer(items$question_type == "IQ")
# Proportion correct among those who answered, and its logit. (An opt-out is scored
# correct on an impossible question and wrong on an answerable one.)
items$p <- as.vector(tapply(iq$resp, iq$item, mean)[items$item])
items$n <- as.vector(table(iq$item)[items$item])
items$logit_p <- qlogis((items$p * items$n + 0.5) / (items$n + 1))
head(items[order(items$p), c("item", "question_text", "p")], 4)

## ---- words
# Word count against logit proportion correct: all 90 items, the 72 answerable ones,
# and mean word length for comparison.
ans <- items$impossible == 0
round(c(words_all = cor(items$word_count, items$logit_p),
        words_answerable = cor(items$word_count[ans], items$logit_p[ans]),
        word_length_all = cor(items$mean_word_length, items$logit_p)), 2)
# What the text says: the impossible flag.
aggregate(cbind(p, word_count) ~ question_type, data = items, FUN = function(v) round(mean(v), 2))
round(c(r2_impossible_flag = summary(lm(logit_p ~ impossible, data = items))$r.squared,
        r2_word_count = summary(lm(logit_p ~ word_count, data = items))$r.squared), 2)

## ---- lltm-iq
# The LLTM with an item residual (from "What is an item?"), with text features as the
# item predictors: logit P(correct) = theta_j + beta_0 + features + epsilon_i. The item
# residual's variance, with and without the features, says how much of the variation
# in difficulty they explain. nAGQ = 0 keeps each fit to seconds.
d <- merge(iq, items[, c("item", "word_count", "impossible")], by = "item")
d$words_z <- (d$word_count - mean(items$word_count)) / sd(items$word_count)
m0 <- glmer(resp ~ 1 + (1 | id) + (1 | item), family = binomial, data = d, nAGQ = 0)
m1 <- glmer(resp ~ words_z + (1 | id) + (1 | item), family = binomial, data = d, nAGQ = 0)
m2 <- glmer(resp ~ words_z + impossible + (1 | id) + (1 | item), family = binomial, data = d, nAGQ = 0)
sds <- sapply(list(none = m0, word_count = m1, word_count_and_flag = m2), function(m) {
  v <- as.data.frame(VarCorr(m)); setNames(v$sdcor, v$grp)[c("item", "id")] })
round(rbind(sds, share_of_item_variance_explained = 1 - sds["item", ]^2 / sds["item", "none"]^2), 3)
round(fixef(m2), 2)

## ---- worth-iq
# What is each prediction worth, in respondents? One respondent carries E[p(1 - p)]
# units of information about an item's location (Rasch model, theta ~ N(0, sd_theta));
# a prediction with error SD sigma is as good as a calibration on
# n* = 1 / (sigma^2 * E[p(1 - p)]) respondents. E[p(1 - p)] is averaged over items at
# the locations each model predicts.
epq <- function(loc, sd_theta) integrate(function(t)
  plogis(loc + t) * (1 - plogis(loc + t)) * dnorm(t, 0, sd_theta), -Inf, Inf)$value
worth <- function(m) {
  v <- as.data.frame(VarCorr(m)); sigma <- v$sdcor[v$grp == "item"]; sd_theta <- v$sdcor[v$grp == "id"]
  loc <- unique(model.matrix(m) %*% fixef(m))
  info <- mean(sapply(loc, epq, sd_theta = sd_theta))
  c(sigma = sigma, info_per_respondent = info, respondents_worth = 1 / (sigma^2 * info))
}
round(sapply(list(none = m0, word_count = m1, word_count_and_flag = m2), worth), 2)

## ---- chatgpt-iq
# Six impossible questions are from the original item bank (the anchor form); the
# twelve on the two generated forms were written by ChatGPT for this study.
iqs <- items[items$impossible == 1, ]
iqs$written_by <- ifelse(iqs$aig_version == "anchor", "original bank", "ChatGPT")
aggregate(cbind(p, word_count) ~ written_by, data = iqs, FUN = function(v) round(mean(v), 2))
iqs[order(iqs$written_by, iqs$p), c("item", "written_by", "question_text", "p")]

## ---- fetch-mcq
library(haven)
suppressPackageStartupMessages(library(mirt))
mcq_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.gpt4mcq_young_2025/rows?format=csv"
mcq <- read.csv(mcq_url)
# resp is the option chosen, 1 to 4; option 1 is the key on every item.
wide <- tapply(mcq$resp, list(mcq$id, mcq$item), function(v) v[1])[, paste0("AIQ", 1:20)]
c(respondents = nrow(wide), missing = sum(is.na(wide)))
# The items, from the SPSS labels in the authors' OSF deposit (osf.io/zq4eg, file
# version 1): stems in the variable labels, options in the value labels.
sav_file <- tempfile(fileext = ".sav")
download.file("https://osf.io/download/bj3gc/?version=1", sav_file, mode = "wb", quiet = TRUE)
sav <- read_sav(sav_file)
stem <- sapply(colnames(wide), function(v) attr(sav[[v]], "label"))
opts <- lapply(colnames(wide), function(v) { l <- attr(sav[[v]], "labels"); names(l)[order(l)] })
key_len <- sapply(opts, function(o) nchar(o[1])); dis_len <- sapply(opts, function(o) max(nchar(o[-1])))

## ---- items-mcq
key <- (wide == 1) * 1
mcq_items <- data.frame(item = colnames(wide), stem = unname(stem), key = sapply(opts, `[`, 1),
                        p = round(colMeans(key), 3), key_is_longest = key_len > dis_len)
knitr::kable(mcq_items[, c("item", "stem", "key", "p")], row.names = FALSE)
c(median_p = median(mcq_items$p), key_longest = sum(mcq_items$key_is_longest))

## ---- distractors-mcq
# Share of respondents choosing each option; rows 2-4 are the distractors.
shares <- sapply(1:20, function(i) prop.table(table(factor(wide[, i], levels = 1:4))))
colnames(shares) <- colnames(wide)
round(shares[, c("AIQ1", "AIQ14", "AIQ19")], 3)
dis <- shares[2:4, ]
c(distractors = length(dis), chosen_by_under_5_percent = sum(dis < 0.05), chosen_by_nobody = sum(dis == 0))
opts[[19]]

## ---- scores-mcq
# Reliability and item parameters. Alpha as in "Classical test theory"; then the 2PL,
# with mirt's intercept d converted to a difficulty, b = -d / a.
alpha <- function(x) { k <- ncol(x); k / (k - 1) * (1 - sum(apply(x, 2, var)) / var(rowSums(x))) }
table(sum_score = rowSums(key))
set.seed(55)
fit2 <- mirt(as.data.frame(key), 1, itemtype = "2PL", verbose = FALSE)
cf <- coef(fit2, simplify = TRUE)$items
b <- -cf[, "d"] / cf[, "a1"]
round(c(alpha = alpha(key), median_b = median(b), min_b = min(b), max_b = max(b)), 2)

## ---- fetch-big5
b5_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.genpsych_russell_2024_gpt4o/rows?format=csv"
b5 <- read.csv(b5_url)
# resp runs from 1 (strongly disagree) to 5 (strongly agree). The items, and the trait
# each was written for, from the authors' OSF deposit (osf.io/zcytb, file version 1),
# in the same order as items_1 to items_35.
b5_items <- read.csv("https://osf.io/download/k7e5t/?version=1")
b5_items$item <- paste0("items_", seq_len(nrow(b5_items)))
w5 <- tapply(b5$resp, list(b5$id, b5$item), function(v) v[1])[, b5_items$item]
c(respondents = nrow(w5), complete = sum(complete.cases(w5)))
w5 <- w5[complete.cases(w5), ]
table(trait = b5_items$characteristic)

## ---- itemrest-big5
# Does each item go with the trait it was written for? Correlate it with the sum of
# the other items of each trait (its own trait's sum leaves it out).
trait <- b5_items$characteristic
traits <- unique(trait)
ir <- t(sapply(seq_len(ncol(w5)), function(i) sapply(traits, function(t) {
  cols <- setdiff(which(trait == t), i); cor(w5[, i], rowSums(w5[, cols, drop = FALSE])) })))
own <- ir[cbind(seq_along(trait), match(trait, traits))]
other <- sapply(seq_along(trait), function(i) max(ir[i, traits != trait[i]]))
c(items_closest_to_own_trait = sum(own > other), items = length(own))
round(c(median_own = median(own), median_best_other = median(other)), 2)
b5_items[which.min(own - other), c("item", "characteristic", "item_content")]
round(ir[which.min(own - other), ], 2)

## ---- alpha-big5
# Alpha for each trait's items, and the mean correlation among them.
t(sapply(traits, function(t) { x <- w5[, trait == t]; r <- cor(x)
  round(c(items = ncol(x), alpha = alpha(x), mean_r = mean(r[upper.tri(r)])), 2) }))
b5_items$item_content[b5_items$characteristic == "neuroticism"]
