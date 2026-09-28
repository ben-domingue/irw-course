# Scale properties with real data: Woodcock-Johnson III Letter-Word Identification
# in Project KIDS (project_kids_wj_lwid_wave), from the Item Response Warehouse.
# Who gains more in a school year, children who start low or children who start
# high, and does the answer survive a change of scale? Runs as-is in R with the
# mirt package; no login or token. The whole script takes about ten minutes.
# New for this course.

## ---- fetch
library(mirt)
set.seed(2014)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/) with
# a CSV download. This link is pinned to one version of the data.
lw_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v61_0.project_kids_wj_lwid_wave/rows?format=csv"
df <- read.csv(lw_url)
# Items are scored 1 (read correctly) or 0; higher = better word reading. Waves 1,
# 2 and 3 are the fall, winter and spring of one school year.
c(responses = nrow(df), children = length(unique(df$id)))
table(wave = df$wave[!duplicated(paste(df$id, df$wave))])   # children per wave

## ---- forms
# The WJ-III has two parallel forms, A and B, with different words at the same
# positions. Item names carry the form and the position: wj_lw_A_13s is form A's
# item 13. (IRW versions before 435 recorded only the position, pooling the two
# forms.) Responses with no recorded form, mostly project 3's spring, are named
# wj_lw_formunknown_<n>s and can't be assigned to an item; we set them aside.
df$form <- sub("^wj_lw_([^_]+)_.*", "\\1", df$item)
table(form = df$form, wave = df$wave)
df <- df[df$form %in% c("A", "B"), ]
df$pos <- as.integer(gsub("\\D", "", df$item))   # the item's position on the test
df$it <- sprintf("%s%02d", df$form, df$pos)
# Same position, different words: proportion correct at a few positions, grade 1
# fall (projects 5, 6 and 9 split their children between the forms).
g1 <- df[df$wave == 1 & df$cov_project %in% c(5, 6, 9) & df$pos %in% c(13, 25, 28), ]
round(tapply(g1$resp, list(position = g1$pos, form = g1$form), mean), 2)

## ---- design
# One row per child per wave (a "record"), one column per form-by-position item.
df$rec <- paste(df$id, df$wave)
wide <- tapply(df$resp, list(df$rec, df$it), function(x) x[1])
recs <- data.frame(rec = rownames(wide),
                   id = as.integer(sub(" .*", "", rownames(wide))),
                   wave = as.integer(sub(".* ", "", rownames(wide))))
# Items near the end of the test were reached by very few children; items read
# fewer than 100 times are dropped so every estimate rests on some data.
X <- as.data.frame(wide[, colSums(!is.na(wide)) >= 100])
c(records = nrow(X), items = ncol(X), dropped = ncol(wide) - ncol(X))
# How each record runs: it starts at position 1 or 2, goes up the test, and stops
# after a run of wrong answers (the ceiling rule). Items past the ceiling are
# missing by design.
first <- tapply(df$pos, df$rec, min); last <- tapply(df$pos, df$rec, max)
table(start = first)
summary(as.vector(last - first + 1))   # items per record
# Grade from project: kindergarten (projects 1, 2), grade 1 (3, 5, 6, 9), grade 2
# (7), grade 3 (8). In the fall of grade 3, the first 20 positions are almost never
# missed, consistent with items below a child's starting point being credited
# rather than read aloud.
grade_of <- c("1" = "K", "2" = "K", "3" = "1", "5" = "1", "6" = "1", "9" = "1", "7" = "2", "8" = "3")
df$grade <- factor(grade_of[as.character(df$cov_project)], levels = c("K", "1", "2", "3"))
early <- df[df$pos <= 20 & df$wave == 1, ]
round(tapply(early$resp, early$grade, mean), 3)

## ---- fit
# One Rasch calibration for all three waves: the same item has the same
# difficulty in fall and spring, which is what puts the waves on one scale.
m1 <- mirt(X, 1, itemtype = "Rasch", verbose = FALSE)
b <- -coef(m1, simplify = TRUE)$items[, "d"]   # mirt's d is an easiness: b = -d
# Weighted likelihood (Warm) estimates of theta: finite for every record, and not
# pulled toward the overall mean the way EAP estimates are.
recs$theta <- fscores(m1, method = "WLE", verbose = FALSE)[, 1]
round(c(sd_b = sd(b), sd_theta = sd(recs$theta)), 2)

## ---- gains
# Children with a fall and a spring score.
th <- reshape(recs[, c("id", "wave", "theta")], idvar = "id", timevar = "wave",
              direction = "wide")
names(th) <- c("id", "t1", "t2", "t3")
kids <- th[!is.na(th$t1) & !is.na(th$t3), ]
kids$project <- tapply(df$cov_project, df$id, function(x) x[1])[as.character(kids$id)]
kids$grade <- factor(grade_of[as.character(kids$project)], levels = c("K", "1", "2", "3"))
kids$gain <- kids$t3 - kids$t1
kids$q <- cut(kids$t1, quantile(kids$t1, 0:4 / 4), include.lowest = TRUE,
              labels = paste0("Q", 1:4))
sd1 <- sd(kids$t1)   # the fall SD: the unit for gains in SD terms
summ <- function(g) round(do.call(rbind, lapply(split(kids, g), function(d) c(
  n = nrow(d), fall_min = min(d$t1), fall_max = max(d$t1), fall = mean(d$t1),
  spring = mean(d$t3), gain = mean(d$gain), gain_sd_units = mean(d$gain) / sd1))), 2)
nrow(kids)
summ(kids$q)       # by fall quartile
summ(kids$grade)   # by grade: one test across four grades, a small vertical scale

## ---- rescale
# The order-preserving rescalings of the measurement lesson, applied to theta
# standardized on the fall: f_k(z) = (exp(k z) - 1) / k. Gains are in fall-SD units
# of the rescaled score.
f_k <- function(z, k) if (k == 0) z else (exp(k * z) - 1) / k
z1 <- (kids$t1 - mean(kids$t1)) / sd1
z3 <- (kids$t3 - mean(kids$t1)) / sd1
qgain <- function(k) tapply(f_k(z3, k) - f_k(z1, k), kids$q, mean) / sd(f_k(z1, k))
ks <- seq(-1, 1.5, by = 0.05)
G <- t(sapply(ks, qgain))
# The smallest k at which the top quartile's gain overtakes the bottom quartile's.
k_cross <- uniroot(function(k) diff(qgain(k)[c(1, 4)]), c(0.01, 1.5))$root
c(k_cross = round(k_cross, 2),
  unit_at_plus2_vs_minus2 = round(exp(4 * k_cross), 1))   # f_k'(2) / f_k'(-2)
round(rbind("k = 0" = qgain(0), "k = crossing" = qgain(k_cross), "k = 1" = qgain(1)), 2)
op <- par(mfrow = c(1, 2), mar = c(4.2, 4.2, 1, 1))
matplot(ks, G, type = "l", lty = 1, lwd = 2.5,
        col = c("#c2410c", "#e08a5a", "#93c5fd", "#2780e3"),
        xlab = "Rescaling k (positive stretches the top)", ylab = "Mean gain (fall SD units)")
abline(v = c(0, k_cross), lty = 2, col = "#999")
legend("topright", paste("fall", colnames(G)), lwd = 2.5, bty = "n",
       col = c("#c2410c", "#e08a5a", "#93c5fd", "#2780e3"))
plot(kids$t1, kids$t3, pch = 16, cex = 0.4, col = adjustcolor("#2780e3", 0.3),
     xlab = "Fall theta", ylab = "Spring theta")
abline(0, 1, lty = 2, col = "#999")
abline(v = tapply(kids$t1, kids$q, max)[1:3], col = "#c2410c", lty = 3)
par(op)

## ---- rtm
# Grouping on the fall score builds in regression to the mean: a fall score that
# is low partly by bad luck tends to be followed by a higher one. Group instead on
# the winter score, which shares no measurement error with fall or spring.
w2 <- kids[!is.na(kids$t2), ]
w2$q2 <- cut(w2$t2, quantile(w2$t2, 0:4 / 4), include.lowest = TRUE, labels = paste0("Q", 1:4))
round(rbind(fall_quartiles = tapply(w2$gain, w2$q, mean),
            winter_quartiles = tapply(w2$gain, w2$q2, mean)), 2)
nrow(w2)

## ---- treatment
# Projects 1, 2, 5 and 6 randomized classrooms or schools to Individualized
# Student Instruction (ISI) or business-as-usual reading instruction (van Dijk et
# al., 2022). In the IRW table treat = 1 is ISI there; children in project 5's third
# condition are coded missing and left out. Effect of ISI on the fall-to-spring gain,
# in fall-SD units, within project, under each rescaling. Randomization was by
# classroom or school, so these naive standard errors are too small: the point is
# the sign, not the p-value.
tr <- kids
tr$treat <- tapply(df$treat, df$id, function(x) x[1])[as.character(tr$id)]
tr <- tr[tr$project %in% c(1, 2, 5, 6) & tr$treat %in% c(0, 1), ]
table(project = tr$project, treat = tr$treat)
tz1 <- (tr$t1 - mean(kids$t1)) / sd1; tz3 <- (tr$t3 - mean(kids$t1)) / sd1
effect <- function(k) {
  g <- (f_k(tz3, k) - f_k(tz1, k)) / sd(f_k(z1, k))
  coef(summary(lm(g ~ tr$treat + factor(tr$project))))[2, 1:2]
}
round(t(sapply(c(-1, -0.5, 0, 0.5, 1, 1.5), function(k) c(k = k, effect(k)))), 3)

## ---- compare
# Does the Rasch model describe these items well enough to lend theta its unit?
# First, a 2PL, which lets every item have its own slope.
m2 <- mirt(X, 1, itemtype = "2PL", verbose = FALSE, technical = list(NCYCLES = 3000))
a <- coef(m2, simplify = TRUE)$items[, "a1"]
round(quantile(a, c(0.1, 0.5, 0.9)), 2)   # slopes, with the SD of theta fixed at 1
round(c(AIC_rasch = extract.mirt(m1, "AIC"), AIC_2pl = extract.mirt(m2, "AIC")))
# Second, outfit and infit (the rasch lesson), using the WLE thetas.
fit_real <- itemfit(m1, fit_stats = "infit", Theta = matrix(recs$theta))
fit_summary <- function(f) round(c(median_outfit = median(f$outfit),
  overfit = sum(f$outfit < 0.7), underfit = sum(f$outfit > 1.3), items = nrow(f)), 2)
fit_summary(fit_real)

## ---- simcopy
# The known answer. Simulate a copy of the table from the Rasch model itself, with
# the fitted difficulties and each record's theta, and give it the same design:
# the same form, the same starting position, and the ceiling rule (stop at the end
# of the eight-item page on which a child first misses six in a row). Then run the
# same checks. Whatever misfit the copy shows comes from the design, not the items.
fm <- substr(colnames(X), 1, 1); ps <- as.integer(substr(colnames(X), 2, 3))
rec_form <- substr(df$it, 1, 1)[match(rownames(X), df$rec)]
rec_start <- first[rownames(X)]
S <- matrix(NA_integer_, nrow(X), ncol(X), dimnames = dimnames(X))
for (i in seq_len(nrow(X))) {
  cols <- which(fm == rec_form[i] & ps >= rec_start[i])
  cols <- cols[order(ps[cols])]
  x <- rbinom(length(cols), 1, plogis(recs$theta[i] - b[cols]))
  run <- cumsum(x == 0) - cummax((x == 1) * cumsum(x == 0))   # current run of misses
  hit <- which(run >= 6)[1]
  stop <- if (is.na(hit)) length(cols) else
    max(which(ps[cols] <= ceiling(ps[cols[hit]] / 8) * 8))
  S[i, cols[seq_len(stop)]] <- x[seq_len(stop)]
}
S <- as.data.frame(S)
c(items_per_record_real = mean(rowSums(!is.na(X))), items_per_record_copy = mean(rowSums(!is.na(S))))
s1 <- mirt(S, 1, itemtype = "Rasch", verbose = FALSE)
s2 <- mirt(S, 1, itemtype = "2PL", verbose = FALSE, technical = list(NCYCLES = 3000))
theta_copy <- fscores(s1, method = "WLE", verbose = FALSE)[, 1]
fit_copy <- itemfit(s1, fit_stats = "infit", Theta = matrix(theta_copy))
lr <- function(r, t) 2 * (extract.mirt(t, "logLik") - extract.mirt(r, "logLik"))
rbind(real = c(AIC_rasch = extract.mirt(m1, "AIC"), AIC_2pl = extract.mirt(m2, "AIC"),
               LR = lr(m1, m2), fit_summary(fit_real)),
      copy = c(AIC_rasch = extract.mirt(s1, "AIC"), AIC_2pl = extract.mirt(s2, "AIC"),
               LR = lr(s1, s2), fit_summary(fit_copy)))

## ---- conjoint
# The cancellation conditions, tested with the ConjointChecks package (Domingue,
# 2014; install.packages("ConjointChecks")). It needs complete data, so we take a
# block that every record in it read: form A, positions 2 to 40, for the records
# whose run reached position 40, keeping items that between 2% and 98% of them
# read correctly. Rows are sum-score groups (at least 30 records each), columns
# the items. For each adjacent 3 x 3 submatrix the package draws proportions under
# the order restrictions (a Bayesian model, as in Karabatsos, 2001) and flags
# cells whose observed proportion falls outside the 95% credible interval. The
# summary is the average share of flagged cells.
library(ConjointChecks)
set.seed(2014)
blk <- which(fm == "A" & ps >= 2 & ps <= 40)
keep_rec <- rowSums(!is.na(X[, blk])) == length(blk)
B <- as.matrix(X[keep_rec, blk])
pc <- colMeans(B)
B <- B[, pc > 0.02 & pc < 0.98]
dim(B)   # records, items
# The known answer again: the same records and items simulated from the Rasch model.
Bc <- matrix(rbinom(length(B), 1, plogis(outer(recs$theta[keep_rec], b[colnames(B)], "-"))),
             nrow(B), dimnames = dimnames(B))
share_flagged <- function(R, single) {
  p <- PrepareChecks(R, ss.lower = 30)
  ConjointChecks(p$N, p$n, n.3mat = "adjacent", single = single)@means$unweighted
}
round(rbind(real = c(double = share_flagged(B, FALSE), single_and_double = share_flagged(B, TRUE)),
            copy = c(double = share_flagged(Bc, FALSE), single_and_double = share_flagged(Bc, TRUE))), 2)
