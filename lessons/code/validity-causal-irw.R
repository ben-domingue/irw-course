# Validity as causation: does a theory of how respondents answer predict what the
# data show, and do people differ stably in the attribute a task is said to measure?
# Two IRW tables: oREV, a German receptive vocabulary task for children aged 3 to 8
# (Bohn et al., 2022), and a timed Stroop task given twice to undergraduates
# (Robison et al., 2026). Runs as-is in base R; no packages, login or token needed.
# New for this course (EDUC 252 c4 has no data analysis).

## ---- orev-fetch
# The IRW table, from the CSV link on its landing page (pinned to one version).
orev <- read.csv(paste0("https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.",
                        "vocab_assessment_3_to_8_year_old_children/rows?format=csv"))
c(rows = nrow(orev), children = length(unique(orev$id)), words = length(unique(orev$targetword)),
  missing = sum(is.na(orev$resp)))
# `item` is the trial position, and the two presentation orders put different
# words at the same position, so the word itself (`targetword`) is the item here.
unique(orev[orev$item == 1, c("item", "itemcov_order", "targetword")])
round(range(tapply(orev$cov_age, orev$id, mean)), 1)

## ---- orev-words
# resp is 1 when the child picked the pictured target. One row per word: its
# proportion correct and its rated age of acquisition (in years).
words <- data.frame(p   = tapply(orev$resp, orev$targetword, mean),
                    aoa = tapply(orev$itemcov_aoa_german_comb, orev$targetword, unique))
# Difficulty on the logit scale: the log odds of a wrong answer. Words that every
# child answered correctly have no finite logit and are set aside.
words$logit <- qlogis(1 - words$p)
fin <- words[words$p < 1, ]
c(words_all_correct = sum(words$p == 1), words_used = nrow(fin))
round(c(r_aoa_logit = cor(fin$aoa, fin$logit),
        rank_r_aoa_p_all_words = cor(words$aoa, words$p, method = "spearman")), 2)
head(words[order(words$aoa), c("aoa", "p")], 4)
tail(words[order(words$aoa), c("aoa", "p")], 4)

## ---- orev-plot
plot(fin$aoa, fin$logit, pch = 19, col = "#2780e3",
     xlab = "Rated age of acquisition (years)", ylab = "Difficulty (log odds of a wrong answer)")
abline(lm(logit ~ aoa, data = fin), lty = 2, col = "#999999")

## ---- orev-order
# The task's two orders were built so that later trials have later-acquired words.
# If words late in the task are harder because children tire, position would do the
# work we credit to age of acquisition. Each word sits at different positions in the
# two orders, so compare.
pos <- aggregate(cbind(position = item, p = resp) ~ targetword + itemcov_order, data = orev, FUN = mean)
round(cor(pos$position, words[pos$targetword, "aoa"]), 2)   # position vs AoA, by design
wa <- pos[pos$itemcov_order == "orderA", ]; wb <- pos[pos$itemcov_order == "orderB", ]
both <- merge(wa, wb, by = "targetword", suffixes = c("_A", "_B"))
# Does a word placed later get answered correctly less often?
round(cor(both$position_A - both$position_B, both$p_A - both$p_B), 2)
# The AoA-difficulty correlation within each order separately:
sapply(split(pos, pos$itemcov_order), function(d) {
  d <- d[d$p < 1, ]
  round(cor(words[d$targetword, "aoa"], qlogis(1 - d$p)), 2)
})

## ---- orev-children
# The same theory says older children know more words.
kids <- data.frame(age   = tapply(orev$cov_age, orev$id, mean),
                   score = tapply(orev$resp, orev$id, sum))
round(cor(kids$age, kids$score), 2)

## ---- orev-wrong
# A second prediction. If a child who doesn't know a word guesses at random, wrong
# answers should spread evenly over the three other pictures. The distractor types
# are coded dist1, dist2, dist3; the chosen words show which is which (ruin ->
# fortress is semantic; Gazelle -> Libelle, "dragonfly", is phonological).
unique(orev[orev$targetword %in% c("ruin", "gazelle") & orev$chosencategory != "target",
            c("targetword", "chosencategory", "chosenword")])
wrong <- orev$chosencategory[orev$resp == 0]
wrong <- factor(wrong, levels = c("dist1", "dist2", "dist3"),
                labels = c("semantic", "phonological", "unrelated"))
round(prop.table(table(wrong)), 2)
chisq.test(table(wrong))$p.value < 0.001

## ---- stroop-fetch
stroop <- read.csv(paste0("https://redivis.com/api/v1/tables/datapages.item_response_warehouse_5:v5_0.",
                          "robison_2026_retesting_stroop/rows?format=csv"))
table(item = stroop$item, conflict = stroop$itemcov_conflict)
c(respondents = length(unique(stroop$id)), trials = nrow(stroop))
table(wave = stroop$wave)
# Trials per respondent in each session (the timed block lasts 90 s).
round(tapply(stroop$id, stroop$wave, length) / tapply(stroop$id, stroop$wave, function(x) length(unique(x))))

## ---- stroop-score
# Sanity check: the task's own score (correct minus incorrect responses in the timed
# block) should rank people about as consistently as Robison et al. report.
sc <- aggregate(resp ~ id + wave, data = stroop, FUN = function(x) sum(x == 1) - sum(x == 0))
sc <- reshape(sc, idvar = "id", timevar = "wave", direction = "wide")
round(cor(sc$resp.1, sc$resp.2, use = "complete.obs"), 2)

## ---- stroop-effect
# The Stroop effect for each respondent and session: mean RT (seconds) on correct
# incongruent trials minus mean RT on correct congruent trials. Trials faster than
# 0.2 s or slower than 5 s are set aside (about 1% of correct trials).
ok <- stroop$resp == 1 & stroop$rt > 0.2 & stroop$rt < 5
round(mean(!ok[stroop$resp == 1]), 3)         # share of correct trials set aside
m <- aggregate(rt ~ id + wave + itemcov_conflict, data = stroop[ok, ], FUN = mean)
m <- reshape(m, idvar = c("id", "wave"), timevar = "itemcov_conflict", direction = "wide")
m$effect <- m$rt.incongruent - m$rt.congruent
s1 <- m[m$wave == 1, ]
n_trials <- aggregate(rt ~ id + wave + itemcov_conflict, data = stroop[ok, ], FUN = length)
median(n_trials$rt)                            # correct trials per condition and session
round(c(n = nrow(s1), mean_effect = mean(s1$effect), sd_effect = sd(s1$effect),
        d_z = mean(s1$effect) / sd(s1$effect),
        t = mean(s1$effect) / (sd(s1$effect) / sqrt(nrow(s1))),
        share_positive = mean(s1$effect > 0)), 2)

## ---- stroop-retest
# Retest: the same respondents, about two weeks later.
b <- merge(m[m$wave == 1, ], m[m$wave == 2, ], by = "id", suffixes = c("_1", "_2"))
round(c(n_both = nrow(b),
        r_effect      = cor(b$effect_1, b$effect_2),
        r_congruent   = cor(b$rt.congruent_1, b$rt.congruent_2),
        r_incongruent = cor(b$rt.incongruent_1, b$rt.incongruent_2)), 2)
round(mean(m$effect[m$wave == 2]), 2)          # the group effect at session 2
