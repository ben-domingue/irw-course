# Nominal response and multiple-choice models with real data: the Reading the Mind in
# the Eyes Test (wilmer-rmet-normative-data-set-2022) and a paper-based medical
# residency exam from Brazil (borges_brazil_residency_2024_pbt), from the Item
# Response Warehouse. Runs as-is in R with the mirt package; no login or token. The
# fits take a minute or two.
# Adapted from ben-domingue/252: c9/nominal.R (there, on preference_inventory).

## ---- fetch-rmet
library(mirt)
# The same pinned version as in the 1PL-to-4PL lesson. resp is 1 when the respondent
# chose the correct word; resp_raw is the word they chose.
rmet_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_2:v22_0.wilmer-rmet-normative-data-set-2022/rows?format=csv"
df <- read.csv(rmet_url)
df$item_n <- as.numeric(gsub("\\D", "", df$item))
items <- sort(unique(df$item_n))
ids <- sort(unique(df$id))
# The keyed word for each item is the one scored 1.
key <- tapply(df$resp_raw[df$resp == 1], df$item_n[df$resp == 1], unique)
# Order each item's four words with the key last: mirt's nominal model fixes the
# scoring of the first and last categories, and putting the key last points theta
# the right way.
words <- lapply(items, function(i) {
  w <- sort(unique(df$resp_raw[df$item_n == i]))
  c(setdiff(w, key[[as.character(i)]]), key[[as.character(i)]])
})
names(words) <- paste0("item_", items)
# Two wide matrices: the option chosen (1-4, key = 4) and the 0/1 score.
opt <- x01 <- matrix(NA, length(ids), length(items), dimnames = list(NULL, names(words)))
for (j in seq_along(items)) {
  d <- df[df$item_n == items[j], ]
  r <- match(d$id, ids)
  opt[r, j] <- match(d$resp_raw, words[[j]])
  x01[r, j] <- d$resp
}
c(respondents = nrow(opt), items = ncol(opt), missing = sum(is.na(opt)))
words$item_14          # the three distractors, then the key

## ---- fit-rmet
# A random 4,000 respondents keep the fits to seconds.
set.seed(252)
s <- sample(nrow(opt), 4000)
rmet_opt <- as.data.frame(opt[s, ])
rmet_01 <- as.data.frame(x01[s, ])
fit_2pl <- mirt(rmet_01, 1, itemtype = "2PL", verbose = FALSE)
fit_nom <- mirt(rmet_opt, 1, itemtype = "nominal", verbose = FALSE)
# theta from the nominal model runs the same way as the number correct:
round(cor(fscores(fit_nom)[, 1], rowSums(rmet_01)), 2)
# Option curves: each word's probability at theta = -3, 0 and 3, and where it peaks.
g <- seq(-3, 3, by = 0.05)
curves <- do.call(rbind, lapply(seq_along(words), function(j) {
  P <- probtrace(extract.item(fit_nom, j), g)
  data.frame(item = j, word = words[[j]], key = c(FALSE, FALSE, FALSE, TRUE),
             p_lo = P[1, ], p_mid = P[g == 0, ], p_hi = P[nrow(P), ],
             peak = g[apply(P, 2, which.max)])
}))
dis <- curves[!curves$key, ]
c(distractors = nrow(dis), peak_inside = sum(dis$peak > -3 & dis$peak < 3),
  falling = sum(dis$peak == -3), rising = sum(dis$peak == 3))
# The distractors most chosen by the ablest respondents (theta = 3):
dis_hi <- dis[order(-dis$p_hi), c("item", "word", "p_lo", "p_mid", "p_hi", "peak")]
rnd <- function(d) transform(d, p_lo = round(p_lo, 2), p_mid = round(p_mid, 2), p_hi = round(p_hi, 2))
head(rnd(dis_hi), 3)
# Item 14, keyed "accusing":
rnd(curves[curves$item == 14, c("word", "p_lo", "p_mid", "p_hi", "peak")])

## ---- curves-rmet
# Option curves for two items: 14 (keyed "accusing") and 25 (keyed "interested").
op <- par(mfrow = c(1, 2), mar = c(4, 4, 2, 1))
cols <- c("#c2410c", "#7c3aed", "#6b7280", "#2780e3")
for (j in c(14, 25)) {
  P <- probtrace(extract.item(fit_nom, j), g)
  matplot(g, P, type = "l", lty = 1, lwd = 2, col = cols, ylim = c(0, 1),
          xlab = "θ", ylab = "P(word chosen)", main = paste("Item", j), las = 1)
  legend("right", words[[j]], col = cols, lwd = 2, bty = "n", cex = 0.8)
}
par(op)

## ---- info-rmet
# Test information from the nominal model and from the 2PL on the same 0/1 scores.
# Each fit sets its own scale (theta standard normal), so the comparison is close,
# not exact.
at <- matrix(c(-3, -2, -1, 0, 1, 2))
round(data.frame(theta = at[, 1], nominal = testinfo(fit_nom, at),
                 two_pl = testinfo(fit_2pl, at)), 1)

## ---- floor-rmet
# Respondents at or below chance (9 of 36) in the full sample: which words did they
# choose? If they picked at random, each of the four would draw a quarter.
low <- rowSums(x01) <= 9
share <- function(rows) {
  t(sapply(seq_along(words), function(j) {
    tab <- tabulate(opt[rows, j], 4) / sum(rows)
    c(key = tab[4], top_distractor = max(tab[1:3]), bottom_distractor = min(tab[1:3]))
  }))
}
c(respondents_at_or_below_chance = sum(low))
round(apply(share(low), 2, median), 2)            # medians over the 36 items
# The same for everyone's wrong answers: the most popular distractor's share of them.
wrong_top <- sapply(seq_along(words), function(j) {
  w <- opt[x01[, j] == 0, j]
  max(tabulate(w, 4)[1:3]) / length(w)
})
round(quantile(wrong_top, c(0, 0.5, 1)), 2)

## ---- nrm-rmet
# The nested logit model (Suh & Bolt, 2010): a 2PL for the key and, among wrong
# answers, a nominal model for which distractor. mirt needs the key (here, 4).
fit_nrm <- mirt(rmet_opt, 1, itemtype = "2PLNRM", key = rep(4, ncol(rmet_opt)), verbose = FALSE)
sapply(list(nominal = fit_nom, nested_logit = fit_nrm),
       function(f) round(c(parameters = extract.mirt(f, "nest"), AIC = extract.mirt(f, "AIC"),
                           BIC = extract.mirt(f, "BIC"))))
# Its keyed curve is a 2PL: how far is it from the 2PL fitted to the 0/1 scores?
key_gap <- sapply(seq_along(words), function(j)
  max(abs(probtrace(extract.item(fit_nrm, j), g)[, 4] - probtrace(extract.item(fit_2pl, j), g)[, 2])))
round(max(key_gap), 3)
round(data.frame(theta = at[, 1], nested_logit = testinfo(fit_nrm, at)), 1)

## ---- fetch-borges
# resp is 1 for the keyed option; text is the option marked (A-D). A few responses
# are "_" or "X" (no single option recorded), scored 0 in resp.
borges_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.borges_brazil_residency_2024_pbt/rows?format=csv"
bz <- read.csv(borges_url)
blank <- !bz$text %in% c("A", "B", "C", "D")
c(blank_responses = sum(blank), candidates_with_a_blank = length(unique(bz$id[blank])))
bz <- bz[!bz$id %in% unique(bz$id[blank]), ]        # keep complete candidates
bkey <- tapply(bz$text[bz$resp == 1], bz$item[bz$resp == 1], unique)
bitems <- sort(unique(bz$item))
bids <- sort(unique(bz$id))
blev <- lapply(bitems, function(i) c(setdiff(LETTERS[1:4], bkey[[as.character(i)]]), bkey[[as.character(i)]]))
bopt <- b01 <- matrix(NA, length(bids), length(bitems), dimnames = list(NULL, paste0("Q", bitems)))
for (j in seq_along(bitems)) {
  d <- bz[bz$item == bitems[j], ]
  r <- match(d$id, bids)
  bopt[r, j] <- match(d$text, blev[[j]])
  b01[r, j] <- d$resp
}
bopt <- as.data.frame(bopt); b01 <- as.data.frame(b01)
c(candidates = nrow(b01), items = ncol(b01))
# Item-rest correlations: each item against the sum of the other 99.
tot <- rowSums(b01)
ir <- sapply(b01, function(x) cor(x, tot - x))
c(below_0.1 = sum(ir < 0.1), below_0 = sum(ir < 0))
round(sort(ir)[1:4], 3)

## ---- fit-borges
fitb_2pl <- mirt(b01, 1, itemtype = "2PL", verbose = FALSE)
fitb_nom <- mirt(bopt, 1, itemtype = "nominal", verbose = FALSE, technical = list(NCYCLES = 2000))
round(cor(fscores(fitb_nom)[, 1], tot), 2)
round(data.frame(theta = at[, 1], nominal = testinfo(fitb_nom, at),
                 two_pl = testinfo(fitb_2pl, at)), 1)

## ---- item21-borges
# Distractors that rise with theta: at least 0.2 more likely at theta = 3 than at -3.
bcurves <- do.call(rbind, lapply(seq_along(bitems), function(j) {
  P <- probtrace(extract.item(fitb_nom, j), g)
  data.frame(item = bitems[j], option = blev[[j]], key = c(FALSE, FALSE, FALSE, TRUE),
             p_lo = P[1, ], p_hi = P[nrow(P), ])
}))
rising <- bcurves[!bcurves$key & bcurves$p_hi > bcurves$p_lo + 0.2, ]
rising$item_rest <- ir[paste0("Q", rising$item)]
transform(rising[, c("item", "option", "p_lo", "p_hi", "item_rest")],
          p_lo = round(p_lo, 2), p_hi = round(p_hi, 2), item_rest = round(item_rest, 3))
# Item 21: who chose what, and the option curves (key A).
table(bz$text[bz$item == 21])
j21 <- which(bitems == 21)
P21 <- probtrace(extract.item(fitb_nom, j21), g)
op <- par(mar = c(4, 4, 1, 1))
matplot(g, P21, type = "l", lty = 1, lwd = 2, col = cols, ylim = c(0, 1),
        xlab = "θ", ylab = "P(option chosen)", las = 1)
legend("top", paste(blev[[j21]], c("", "", "", "(key)")), col = cols, lwd = 2, bty = "n", horiz = TRUE)
par(op)
# The nominal parameters behind the curves. mirt writes each option's slope as a1
# times a scoring value ak, and its intercept as d; B is the reference (0, 0).
cf <- coef(fitb_nom, simplify = TRUE)$items[j21, ]
round(rbind(slope = cf["a1"] * cf[paste0("ak", 0:3)], intercept = cf[paste0("d", 0:3)]), 2) |>
  `colnames<-`(blev[[j21]])
