# Differential item functioning: which items in a first-grade vocabulary test work
# differently for groups of children matched on their total score? The Mantel-Haenszel
# procedure with the ETS A/B/C categories and logistic regression, on gilbert_meta_11
# from the Item Response Warehouse, then robust scaling (Halpin, 2024). Runs as-is in
# base R (no login or token needed), except the last chunk, which needs the mirt and
# robustDIF packages; one chunk also checks the result against difR if installed.
# Source: EDUC 252 class 5 (slides c5) and problem set 5 (#3, code ps5/dif_itemtext.R).
# The first two chunks are the lesson's opening example, the Dutch Author Recognition
# Test (slides c5; code c5/art.R).

## ---- dart
# The Dutch Author Recognition Test (Brysbaert, Sui, Dirix & Hintz, 2020): 132 names,
# "is this person an author?". 42 names are made-up foils (the paper's Appendix A);
# in the IRW table a checked name scores 1 whether or not it is a real author, so we
# drop the foils and keep the 90 authors. 1 = recognized.
dart_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0.DART_Brysbaert_2020_1/rows?format=csv"
dart <- read.csv(dart_url)
dart$name <- sub("^Is de volgende persoon een auteur- \\[(.*)\\]$", "\\1", dart$item)
foils <- c("Andrée Oudin", "Chiara Ricci", "E.L. Wilford", "E. Buxton", "Elizabeth Wigelsworth",
  "Emily Oldani", "Emmanuelle Duvernay", "Eric Ferey", "Georges Roudaut", "H. M. van der Grinten",
  "Hans Ulfsson", "Hendrik van Weenen", "1ne Jessup", "John Kestley", "John Punnett",
  "Jorge Eudoro Remache", "Judith L. Schecter", "Kathryn Lightner", "Kelly Weaver",
  "Kettil Christoffersen", "Kim Wassing", "Konstantin Ryschkov", "Kyra Appels", "Ludwig Lorenz",
  "Mahmoud Abdellah", "Marcus Fernandes", "Mark Robin", "Martijn van der Worp",
  "Mathijs L. van Bueren", "Melanie Marrero Morales", "Pablo Daniel Gonzalez", "Pim Duijster",
  "Richard Grigley", "Robert Teesdale", "Roberto Borsani", "Roy Leeman", "Sara Lakin",
  "Theresa Ziegler", "Tim Singler", "Tomas Arensman", "Yasushi Sugawara", "Zofia Kwiatkowski")
c(foils_found = sum(foils %in% dart$name), names = length(unique(dart$name)))
# (The IRW labels "1ne Jessup", "1ne Austen" and "1mes Patterson" stand for Jane and James.)
aut <- dart[!dart$name %in% foils, ]
A <- tapply(aut$resp, list(aut$id, aut$name), function(x) x[1])
sex <- tapply(aut$cov_gender, aut$id, function(x) x[1])[rownames(A)]
table(sex)
women <- as.integer(sex == "Vrouw")
total <- rowSums(A)
c(authors = ncol(A), respondents = nrow(A), missing = sum(is.na(A)))
round(tapply(total, sex, mean), 1)   # mean number of the 90 authors recognized
# For each author: the difference between women and men in the proportion who
# recognize the author, first raw, then at the same total (women's totals as
# weights: the standardization approach of Dorans & Kulick, 1986), and a
# Mantel-Haenszel test of no difference at the same total.
std_gap <- function(y) {
  pw <- tapply(y[women == 1], total[women == 1], mean)
  pm <- tapply(y[women == 0], total[women == 0], mean)
  k <- intersect(names(pw), names(pm))
  wt <- table(total[women == 1])[k]
  sum(wt * (pw[k] - pm[k])) / sum(wt)
}
mh_p <- function(y) {
  keep <- total %in% as.numeric(names(which(table(total) > 1)))
  tab <- table(factor(y[keep], 0:1), factor(women[keep], 0:1), total[keep])
  mantelhaen.test(tab)$p.value
}
dres <- data.frame(raw_gap = colMeans(A[women == 1, ]) - colMeans(A[women == 0, ]),
                   matched_gap = sapply(colnames(A), function(a) std_gap(A[, a])),
                   p = sapply(colnames(A), function(a) mh_p(A[, a])))
dres$p_holm <- p.adjust(dres$p, "holm")
round(dres[order(dres$matched_gap), ][c(1:4, 87:90), ], 3)
c(p_below_05 = sum(dres$p < 0.05), holm_below_05 = sum(dres$p_holm < 0.05))

## ---- dart-plot
# Recognition of four authors by total (in four bands), women and men.
band <- cut(total, quantile(total, 0:4 / 4), include.lowest = TRUE)
op <- par(mfrow = c(1, 4), mar = c(4, 3, 2, 0.5))
for (a in c("Tom Clancy", "J.R.R. Tolkien", "1ne Austen", "Emily Brontë")) {
  pr <- tapply(A[, a], list(band, women), mean)
  plot(1:4, pr[, "0"], type = "b", pch = 19, col = "#999", ylim = c(0, 1), xaxt = "n",
       xlab = "Total (quartile)", ylab = "", main = sub("1ne", "Jane", a), cex.main = 0.9)
  lines(1:4, pr[, "1"], type = "b", pch = 19, col = "#2780e3")
  axis(1, 1:4)
}
legend("bottomright", c("men", "women"), col = c("#999", "#2780e3"), pch = 19, bty = "n")
par(op)

## ---- fetch
# The IRW table, from the CSV link on its landing page (pinned to one version).
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0.gilbert_meta_11/rows?format=csv"
long <- read.csv(url)
head(long[, c("id", "item", "resp", "treat", "cov_male", "cov_lep")], 3)

## ---- wide
# One row per child: the 24 items (12 science, 12 social studies; 1 = correct) and
# the child's covariates. We keep the children who answered all 24 items.
items <- c(paste0("sci", 1:12), paste0("ss", 1:12))
w <- reshape(long[, c("id", "item", "resp")], idvar = "id", timevar = "item", direction = "wide")
names(w) <- sub("^resp\\.", "", names(w))
kids <- long[!duplicated(long$id), c("id", "treat", grep("^cov_", names(long), value = TRUE))]
w <- merge(w, kids, by = "id")
c(children = nrow(w), complete = sum(complete.cases(w[, items])))
w <- w[complete.cases(w[, items]), ]
X <- as.matrix(w[, items])

## ---- groupings
# Each grouping is a focal group (coded 1) against a reference group (coded 0);
# children in neither are left out (NA). A positive delta favours the focal group.
race <- function(g) ifelse(w[[g]] == 1, 1, ifelse(w$cov_white == 1, 0, NA))
groups <- list(
  "girls vs. boys"              = 1 - w$cov_male,
  "Black vs. White"             = race("cov_black"),
  "Hispanic vs. White"          = race("cov_hispanic"),
  "Asian vs. White"             = race("cov_asian"),
  "English learners vs. not"    = w$cov_lep,
  "IEP vs. not"                 = w$cov_iep,
  "low income vs. not"          = w$cov_ses_low,
  "treated vs. control"         = w$treat)
t(sapply(groups, function(g) c(focal = sum(g == 1, na.rm = TRUE), reference = sum(g == 0, na.rm = TRUE))))

## ---- mh
# The Mantel-Haenszel procedure for one item. Children are matched on a score (by
# default the total on all 24 items, the studied item included); within each score
# level k we have a 2 x 2 table of group by right/wrong. The common odds ratio pools
# the tables; delta = -2.35 ln(alpha) puts it on the ETS delta scale (Holland &
# Thayer, 1986). SE: Robins, Breslow & Greenland (1986). Chi-square: with the
# continuity correction, as ETS computes it (Zwick, 2012, eq. 3).
mh <- function(y, g, score) {
  ok <- !is.na(g)
  y <- y[ok]; g <- g[ok]; s <- score[ok]
  A <- tapply(y == 1 & g == 0, s, sum)   # reference, right
  B <- tapply(y == 0 & g == 0, s, sum)   # reference, wrong
  C <- tapply(y == 1 & g == 1, s, sum)   # focal, right
  D <- tapply(y == 0 & g == 1, s, sum)   # focal, wrong
  n <- A + B + C + D
  keep <- n > 1
  A <- A[keep]; B <- B[keep]; C <- C[keep]; D <- D[keep]; n <- n[keep]
  R <- A * D / n; S <- B * C / n
  alpha <- sum(R) / sum(S)
  P <- (A + D) / n; Q <- (B + C) / n
  var_log <- sum(P * R) / (2 * sum(R)^2) + sum(P * S + Q * R) / (2 * sum(R) * sum(S)) +
             sum(Q * S) / (2 * sum(S)^2)
  nR <- A + B; nF <- C + D; m1 <- A + C; m0 <- B + D
  chisq <- max(0, abs(sum(A) - sum(nR * m1 / n)) - 0.5)^2 / sum(nR * nF * m1 * m0 / (n^2 * (n - 1)))
  c(delta = -2.35 * log(alpha), se = 2.35 * sqrt(var_log), chisq = chisq,
    p = pchisq(chisq, 1, lower.tail = FALSE))
}
# The ETS categories (Zwick, 2012, pp. 3-4). A: not significant at .05, or |delta| < 1.
# C: |delta| >= 1.5 and |delta| significantly greater than 1. B: everything else.
ets <- function(delta, se, p) {
  ifelse(p >= 0.05 | abs(delta) < 1, "A",
         ifelse(abs(delta) >= 1.5 & (abs(delta) - 1) / se > qnorm(0.95), "C", "B"))
}
mh_all <- function(g, score = rowSums(X), cols = items) {
  out <- as.data.frame(t(sapply(cols, function(i) mh(X[, i], g, score))))
  out$ets <- ets(out$delta, out$se, out$p)
  out
}
summarise_mh <- function(r) c(significant = sum(r$p < 0.05), A = sum(r$ets == "A"),
                              B = sum(r$ets == "B"), C = sum(r$ets == "C"),
                              largest = round(max(abs(r$delta)), 2))

## ---- random
# The sanity check: random halves of the same children. Nothing but chance can make
# an item "work differently" for them, so these counts are the baseline.
set.seed(44)
rand <- t(replicate(20, summarise_mh(mh_all(rbinom(nrow(X), 1, 0.5)))))
round(colMeans(rand), 2)
max(rand[, "largest"])

## ---- abc
res <- lapply(groups, mh_all)
abc <- t(sapply(res, summarise_mh))
abc

## ---- difr-check
# The same numbers from the difR package (Magis et al., 2010), if installed: its
# difMH matches on the total score and reports alpha; delta = -2.35 ln(alpha).
if (requireNamespace("difR", quietly = TRUE)) {
  d <- difR::difMH(Data = X, group = w$treat, focal.name = 1)
  max(abs(-2.35 * log(d$alphaMH) - res[["treated vs. control"]]$delta))
}

## ---- demographic
# The B items among the demographic groupings, with the proportion correct in each group.
dem <- do.call(rbind, lapply(names(groups)[1:7], function(nm) {
  r <- res[[nm]]; g <- groups[[nm]]
  b <- rownames(r)[r$ets != "A"]
  if (!length(b)) return(NULL)
  data.frame(grouping = nm, item = b, delta = round(r[b, "delta"], 2),
             p_focal = round(colMeans(X[g %in% 1, b, drop = FALSE]), 2),
             p_reference = round(colMeans(X[g %in% 0, b, drop = FALSE]), 2))
}))
rownames(dem) <- NULL
dem

## ---- treatment
# Items by their treatment DIF. Each item asks the child to pick the two of four
# words that go with a target word; a few target words, from the IRW item text
# (reconstructed from the study's materials), label the items discussed in the text.
words <- c(ss2 = "expedition", ss7 = "indigenous", ss6 = "obstacle",
           sci5 = "behavior", ss8 = "celebrate", sci10 = "habitat", ss11 = "community")
tr <- res[["treated vs. control"]]
tr$p_control <- colMeans(X[w$treat == 0, ])
tr$p_treated <- colMeans(X[w$treat == 1, ])
tr$word <- ifelse(rownames(tr) %in% names(words), words[rownames(tr)], "")
tr <- tr[order(-tr$delta), ]
print(data.frame(word = tr$word, delta = round(tr$delta, 2), se = round(tr$se, 2),
                 ets = tr$ets, p_control = round(tr$p_control, 2),
                 p_treated = round(tr$p_treated, 2), row.names = rownames(tr)))
# The raw treatment difference in the total score is the sum of the items'
# differences in proportion correct. How much of it is expedition's?
gap <- tr$p_treated - tr$p_control
round(c(total_gap = sum(gap), expedition = gap[rownames(tr) == "ss2"],
        share = gap[rownames(tr) == "ss2"] / sum(gap)), 2)

## ---- expedition
# Expedition, matched: the proportion correct by total score, in each arm.
tot <- rowSums(X)
band <- cut(tot, c(-1, 8, 12, 16, 20, 24), labels = c("0-8", "9-12", "13-16", "17-20", "21-24"))
round(tapply(X[, "ss2"], list(total = band, arm = ifelse(w$treat == 1, "treated", "control")), mean), 2)
op <- par(mar = c(4, 4, 1, 1))
pc <- tapply(X[, "ss2"], list(tot, w$treat), mean)
nn <- table(tot, w$treat)
pc[nn < 10] <- NA   # hide score levels with fewer than 10 children in an arm
plot(as.numeric(rownames(pc)), pc[, "0"], type = "b", pch = 19, col = "#999", ylim = c(0, 1),
     xlab = "Total score (24 items)", ylab = "Proportion correct on 'expedition'")
lines(as.numeric(rownames(pc)), pc[, "1"], type = "b", pch = 19, col = "#2780e3")
legend("topleft", c("control", "treated"), col = c("#999", "#2780e3"), pch = 19, bty = "n")
par(op)

## ---- logistic
# Logistic regression DIF (Swaminathan & Rogers, 1990): three nested models per item,
#   M0: total score;  M1: + group (uniform DIF);  M2: + group x total (non-uniform DIF).
# Likelihood-ratio tests compare them. The effect size is the change in Nagelkerke's
# R^2 from M0 to M2, classified as Jodoin & Gierl (2001) do in difR: below .035
# negligible (A), .035 to .07 moderate (B), above .07 large (C).
nagelkerke <- function(m, ll0, n) {
  cs <- 1 - exp(2 * (ll0 - as.numeric(logLik(m))) / n)
  cs / (1 - exp(2 * ll0 / n))
}
lr_item <- function(y, g, total) {
  d <- data.frame(y = y, g = g, total = total)[!is.na(g), ]
  ll0 <- as.numeric(logLik(glm(y ~ 1, binomial, d)))
  m0 <- glm(y ~ total, binomial, d)
  m1 <- glm(y ~ total + g, binomial, d)
  m2 <- glm(y ~ total * g, binomial, d)
  c(beta_group = unname(coef(m1)["g"]),
    p_uniform = anova(m0, m1, test = "LRT")[2, "Pr(>Chi)"],
    p_nonuniform = anova(m1, m2, test = "LRT")[2, "Pr(>Chi)"],
    p_both = anova(m0, m2, test = "LRT")[2, "Pr(>Chi)"],
    dR2 = nagelkerke(m2, ll0, nrow(d)) - nagelkerke(m0, ll0, nrow(d)))
}
lr_all <- function(g) {
  out <- as.data.frame(t(sapply(items, function(i) lr_item(X[, i], g, rowSums(X)))))
  out$jg <- ifelse(out$p_both >= 0.05 | out$dR2 < 0.035, "A", ifelse(out$dR2 < 0.07, "B", "C"))
  out
}
lr <- lapply(groups, lr_all)
# Side by side with Mantel-Haenszel: items significant (2-df test), and the Jodoin &
# Gierl categories.
t(sapply(lr, function(r) c(significant = sum(r$p_both < 0.05), A = sum(r$jg == "A"),
                           B = sum(r$jg == "B"), C = sum(r$jg == "C"),
                           largest_dR2 = round(max(r$dR2), 3))))

## ---- logistic-treat
# Treatment, item by item: the group coefficient (a log odds ratio at a fixed total;
# 2.35 times it is on the MH delta scale), the non-uniform test, and the effect size.
lt <- lr[["treated vs. control"]]
lt <- data.frame(word = tr[rownames(lt), "word"], beta_group = round(lt$beta_group, 2),
                 odds_ratio = round(exp(lt$beta_group), 2),
                 lr_delta = round(2.35 * lt$beta_group, 2),
                 mh_delta = round(tr[rownames(lt), "delta"], 2),
                 p_nonuniform = signif(lt$p_nonuniform, 2), dR2 = round(lt$dR2, 3),
                 jg = lt$jg, mh_ets = tr[rownames(lt), "ets"], row.names = rownames(lt))
lt[order(-lt$dR2), ][1:8, ]
round(cor(lt$lr_delta, lt$mh_delta), 4)
sum(lr[["treated vs. control"]]$p_nonuniform < 0.05)

## ---- purify
# Purification: drop the C items from the matching score (each studied item stays
# in its own score), then run the procedure again (Holland & Thayer, 1986).
flag <- rownames(res[["treated vs. control"]])[res[["treated vs. control"]]$ets == "C"]
flag
pur <- as.data.frame(t(sapply(items, function(i) {
  anchor <- union(setdiff(items, flag), i)
  mh(X[, i], w$treat, rowSums(X[, anchor]))
})))
pur$ets <- ets(pur$delta, pur$se, pur$p)
cmp <- data.frame(total = round(res[["treated vs. control"]]$delta, 2),
                  purified = round(pur$delta, 2),
                  ets_total = res[["treated vs. control"]]$ets, ets_purified = pur$ets,
                  row.names = items)
cmp[order(-cmp$total), ]
table(total = cmp$ets_total, purified = cmp$ets_purified)
round(c(mean_total = mean(cmp$total), mean_purified = mean(cmp$purified)), 2)

## ---- robust
# Robust scaling (Halpin, 2024; robustDIF package): fit a 2PL in each arm, then
# estimate the difference between the arms on theta while down-weighting items whose
# item-level estimates of that difference are outliers. No anchor is chosen in
# advance. Needs the mirt and robustDIF packages; skipped if they are missing.
if (requireNamespace("mirt", quietly = TRUE) && requireNamespace("robustDIF", quietly = TRUE)) {
  fits <- lapply(0:1, function(k) mirt::mirt(as.data.frame(X[w$treat == k, ]), 1,
                                              itemtype = "2PL", SE = TRUE, verbose = FALSE))
  rob <- robustDIF::rdif(mle = robustDIF::get_model_parms(fits), fun = "d_fun3", alpha = 0.05)
  rt <- rob$dif.test
  rownames(rt) <- items   # the package labels items by position
  print(data.frame(word = tr[items, "word"], delta = round(rt$delta, 2), z = round(rt$z.test, 1),
                   weight = round(rob$weights, 2), row.names = items)[order(-abs(rt$delta)), ][1:8, ])
  print(c(flagged = sum(rt$p.val < 0.05), zero_weight = sum(rob$weights == 0)))
  # Treatment effect on theta (in SDs): all items weighted equally vs. robust.
  print(robustDIF::delta_test(rob)[, c("naive.est", "rdif.est", "delta", "z.test", "p.val")], digits = 3)
}
