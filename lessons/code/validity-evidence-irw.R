# Gathering validity evidence: convergent and discriminant evidence from a
# multitrait-multimethod matrix (HEXACO self- and colleague ratings, de Vries et al.,
# 2022), then criterion evidence, incremental validity and range restriction (a
# writing-attitudes survey with course grades and SAT scores, ETS IES Writing
# Achievement Study). Three IRW tables: de_vries_2022_hexaco_self,
# de_vries_2022_hexaco_other and ieswriting_molloy_2022. Runs as-is in base R; no
# packages, login or token needed. New for this course (not in EDUC 252).

## ---- fetch
# The CSV links on the tables' landing pages (pinned to one version).
base4 <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_4:v7_0."
self  <- read.csv(paste0(base4, "de_vries_2022_hexaco_self/rows?format=csv"))
other <- read.csv(paste0(base4, "de_vries_2022_hexaco_other/rows?format=csv"))
head(other, 3)
c(self_rows = nrow(self), self_targets = length(unique(self$id)),
  other_rows = nrow(other), other_targets = length(unique(other$id)))
table(rater = other$rater[!duplicated(other[, c("id", "rater")])])

## ---- key
# Item codes are P + trait letter (H, E, X, A, C, O) + facet + number. The 96 items
# are the HEXACO-100 without its four Altruism items, and they arrive unkeyed. These
# 48 are reverse-keyed in the published scoring key for the 100-item version
# (hexaco.org, ScoringKeys_100.pdf, items 1R, 6R, 9R, ..., 96R, matched to codes by
# the item order of the authors' data file, which also carries a reversed copy of
# exactly these 48 items).
reversed <- c("POaesa1", "PHsinc1", "PAgent4", "PXsocb2", "PHfair1", "POcrea2",
  "PAflex1", "PXsoci2", "POunco2", "PCprud2", "PApati2", "POaesa3", "PEfear4",
  "PEanxi4", "PHfair4", "PCperf2", "PEdepe6", "PHgree4", "PCprud3", "PCorga6",
  "PAforg7", "PXsses5", "PHsinc5", "POinqu6", "PCdili5", "PEanxi6", "PAflex7",
  "PHgree5", "PXlive4", "PHmode6", "PCorga8", "PAforg8", "PXsses8", "PEfear8",
  "POinqu8", "PCdili6", "PXsocb8", "PHfair8", "POcrea8", "PAflex8", "PEdepe8",
  "PHgree7", "POunco8", "PCprud8", "PApati6", "PXlive7", "PEsent7", "PHmode8")
keyit <- function(d) { d$resp <- ifelse(d$item %in% reversed, 6 - d$resp, d$resp); d }
self <- keyit(self); other <- keyit(other)
traits <- c(H = "Honesty-Humility", E = "Emotionality", X = "Extraversion",
            A = "Agreeableness", C = "Conscientiousness", O = "Openness")
wide <- function(d) {
  w <- reshape(d[, c("id", "item", "resp")], idvar = "id", timevar = "item", direction = "wide")
  names(w) <- sub("^resp\\.", "", names(w))
  w[order(w$id), ]
}
ws  <- wide(self)
wc1 <- wide(other[other$rater == "colleague1", ])   # the first colleague for each target
items <- setdiff(names(ws), "id")
trait_of <- substr(items, 2, 2)
# Keying check: each keyed item against the rest of its trait's 16 items.
item_rest <- function(w) sapply(items, function(i) {
  rest <- setdiff(items[trait_of == substr(i, 2, 2)], i)
  cor(w[[i]], rowSums(w[, rest]))
})
round(rbind(self = range(item_rest(ws)), colleague = range(item_rest(wc1))), 2)

## ---- scores
alpha <- function(x) {
  k <- ncol(x)
  k / (k - 1) * (1 - sum(apply(x, 2, var)) / var(rowSums(x)))
}
score <- function(w) sapply(names(traits), function(t) rowMeans(w[, items[trait_of == t]]))
S <- data.frame(id = ws$id, score(ws)); C1 <- data.frame(id = wc1$id, score(wc1))
rel <- rbind(self      = sapply(names(traits), function(t) alpha(ws[, items[trait_of == t]])),
             colleague = sapply(names(traits), function(t) alpha(wc1[, items[trait_of == t]])))
round(rel, 2)
m <- merge(S, C1, by = "id", suffixes = c(".self", ".coll"))
nrow(m)   # targets with a self-report and a first colleague's rating

## ---- mtmm
R <- cor(m[, -1])   # the full matrix is drawn in the next chunk
Rs <- R[1:6, 1:6]; Rc <- R[7:12, 7:12]; Rsc <- R[1:6, 7:12]
off <- row(Rsc) != col(Rsc)
c(validity_min = min(diag(Rsc)), validity_max = max(diag(Rsc)),
  hetero_hetero = mean(abs(Rsc[off])),                                  # different trait, different method
  hetero_mono = mean(abs(c(Rs[upper.tri(Rs)], Rc[upper.tri(Rc)]))))     # different trait, same method

## ---- heatmap
op <- par(mar = c(1, 5.5, 5.5, 1))
lab <- c(paste(names(traits), "self"), paste(names(traits), "coll"))
image(1:12, 1:12, t(R[12:1, ]), zlim = c(-1, 1), axes = FALSE, xlab = "", ylab = "",
      col = hcl.colors(41, "Blue-Red 3", rev = TRUE))
axis(3, 1:12, lab, las = 2, tick = FALSE); axis(2, 1:12, rev(lab), las = 1, tick = FALSE)
text(rep(1:12, 12), rep(12:1, each = 12), sprintf("%.2f", R), cex = 0.6)
abline(v = 6.5, h = 6.5, lwd = 2)
par(op)

## ---- campbell-fiske
# Campbell and Fiske's comparisons, trait by trait. Each validity value (same trait,
# different method) should beat the 10 different-trait correlations in its row and
# column of the self-colleague block, and the 10 different-trait correlations that
# involve the trait within each method.
cf <- t(sapply(1:6, function(i) {
  hh <- abs(c(Rsc[i, -i], Rsc[-i, i])); hm <- abs(c(Rs[i, -i], Rc[i, -i]))
  c(validity = Rsc[i, i],
    beats_hetero_hetero = sum(Rsc[i, i] > hh), largest_hetero_hetero = max(hh),
    beats_hetero_mono = sum(Rsc[i, i] > hm), largest_hetero_mono = max(hm))
}))
rownames(cf) <- traits
round(cf, 2)
round(c(self_HA = Rs["H.self", "A.self"], colleague_HA = Rc["H.coll", "A.coll"]), 2)
# Is the pattern of trait correlations the same within each method?
round(cor(Rs[lower.tri(Rs)], Rc[lower.tri(Rc)]), 2)

## ---- disattenuate
# Correct each validity value for unreliability in both ratings, using alpha.
corrected <- diag(Rsc) / sqrt(rel["self", ] * rel["colleague", ])
round(rbind(observed = diag(Rsc), corrected = corrected), 2)
# The colleagues' Honesty-Humility-Agreeableness correlation, corrected the same way.
round(Rc["H.coll", "A.coll"] / sqrt(rel["colleague", "H"] * rel["colleague", "A"]), 2)

## ---- raters
# Sanity check on the pipeline: two colleagues rating the same target.
wc2 <- wide(other[other$rater == "colleague2", ])
C2 <- data.frame(id = wc2$id, score(wc2))
m12 <- merge(C1, C2, by = "id", suffixes = c(".c1", ".c2"))
c(targets = nrow(m12))
round(sapply(names(traits), function(t) cor(m12[[paste0(t, ".c1")]], m12[[paste0(t, ".c2")]])), 2)

## ---- ies-fetch
base <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0."
ies <- read.csv(paste0(base, "ieswriting_molloy_2022/rows?format=csv"))
c(rows = nrow(ies), students = length(unique(ies$id)))
# Part 2 of the survey (items Q2.1 to Q2.22): confidence about writing tasks, 0 to 10.
conf <- ies[grepl("^Q2\\.", ies$item), ]
wconf <- wide(conf)
round(alpha(wconf[, -1]), 2)
st <- unique(ies[, c("id", "cov_participating_course_grade", "cov_sat_total", "cov_cum_GPA")])
names(st) <- c("id", "grade", "sat", "gpa")
st$confidence <- rowMeans(wconf[match(st$id, wconf$id), -1])
st <- na.omit(st)
nrow(st)

## ---- sat-values
# The most common SAT values. One value stands out.
head(sort(table(st$sat), decreasing = TRUE), 3)
imputed <- abs(st$sat - 1036.86) < 0.01
c(students_at_1036.86 = sum(imputed), mean_of_the_rest = round(mean(st$sat[!imputed]), 2))
round(c(r_with_them = cor(st$sat, st$grade), r_without = cor(st$sat[!imputed], st$grade[!imputed])), 2)
k <- st[!imputed, ]
nrow(k)

## ---- criterion
round(cor(k[, c("grade", "gpa", "sat", "confidence")]), 2)
m_sat  <- lm(grade ~ sat, data = k)
m_both <- lm(grade ~ sat + confidence, data = k)
round(c(R2_sat = summary(m_sat)$r.squared, R2_sat_confidence = summary(m_both)$r.squared,
        p_added = anova(m_sat, m_both)[2, "Pr(>F)"]), 2)

## ---- restrict
# Keep only students above the median SAT, as if the college had admitted them alone.
top <- k[k$sat > median(k$sat), ]
u <- sd(k$sat) / sd(top$sat)          # how much wider SAT is in the full group
case2 <- function(r, u) r * u / sqrt(1 - r^2 + r^2 * u^2)
r_top <- cor(top$sat, top$grade)
round(c(n_top = nrow(top), r_all = cor(k$sat, k$grade), r_top = r_top, u = u,
        case_II = case2(r_top, u)), 2)

## ---- restrict-why
# Case II assumes the regression of grade on SAT is linear with the same spread of
# residuals everywhere. Compare the two halves.
bottom <- k[k$sat <= median(k$sat), ]
fit_half <- function(d) { f <- lm(grade ~ I(sat / 100), data = d); c(slope_per_100 = coef(f)[[2]], resid_sd = sigma(f)) }
round(rbind(bottom = fit_half(bottom), top = fit_half(top)), 2)
round(c(share_grade_4_top = mean(top$grade == 4), share_grade_4_bottom = mean(bottom$grade == 4)), 2)
