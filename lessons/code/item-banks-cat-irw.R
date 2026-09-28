# Item banks and adaptive testing with real data: Korea's Clinical Medical Science
# Comprehensive Examination, 2020, part 1 (choi_2026_cmsce_2020_1), and the PROMIS wave 1
# depression items (promis1wave1_depression), from the Item Response Warehouse. Runs
# as-is in R with the mirt package; no login or token. The CAT engine is written out in
# base R below so that every step can be read. The 600-respondent CAT is precomputed
# by deepdives/item-banks-cat/compute.R, which runs the first four chunks of this file.
# New for this course: EDUC 252 had no code for adaptive testing.

## ---- fetch-cm
library(mirt)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/) with a
# CSV download. This link is pinned to one version of the data.
cm_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_4:v8_0.choi_2026_cmsce_2020_1/rows?format=csv"
df <- read.csv(cm_url)
# resp is 1 for a correct answer and 0 otherwise. One sitting per respondent: no waves.
cm <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
c(respondents = nrow(cm), items = ncol(cm), missing = sum(is.na(cm)),
  mean_correct = round(mean(cm), 2))

## ---- calibrate-cm
# Calibrate on a random half; the other half is kept back to take the adaptive test.
# mirt writes the 2PL as a*theta + d; our difficulty is b = -d/a (IRTpars = TRUE).
set.seed(2020)
cal <- sort(sample(nrow(cm), nrow(cm) %/% 2))
m_cm <- mirt(as.data.frame(cm[cal, ]), 1, itemtype = "2PL", verbose = FALSE)
pars <- coef(m_cm, IRTpars = TRUE, simplify = TRUE)$items[, c("a", "b")]
# Items with slopes below 0.3 say little about theta anywhere (information a^2/4 at
# most 0.02); they stay out of the bank.
bank_items <- rownames(pars)[pars[, "a"] >= 0.3]
c(calibration = length(cal), items = nrow(pars), low_slope = sum(pars[, "a"] < 0.3),
  of_which_negative = sum(pars[, "a"] < 0), bank = length(bank_items))
round(quantile(pars[bank_items, "b"], c(0, 0.1, 0.5, 0.9, 1)), 2)   # bank difficulties
round(quantile(pars[bank_items, "a"], c(0, 0.5, 1)), 2)             # bank slopes

## ---- engine
# A CAT in base R, for any unidimensional model mirt fits. Every quantity lives on a
# grid of nodes: the prior, each item's response probabilities and its information.
nodes <- seq(-6, 6, length.out = 121)
prior <- dnorm(nodes)   # mirt's calibration fixes the mean at 0 and the SD at 1
make_bank <- function(model, items) {
  it <- lapply(items, function(i) extract.item(model, i))
  list(items = items,
       logp = lapply(it, function(e) log(probtrace(e, nodes))),  # nodes x categories
       info = sapply(it, function(e) iteminfo(e, nodes)))         # nodes x items
}
# EAP and posterior SD from the log likelihood on the nodes
eap <- function(ll) {
  w <- exp(ll - max(ll)) * prior
  w <- w / sum(w)
  th <- sum(nodes * w)
  c(theta = th, se = sqrt(sum((nodes - th)^2 * w)))
}
# Each available item's information at theta, interpolated between nodes
info_at <- function(bank, th, avail) {
  k <- findInterval(th, nodes, all.inside = TRUE)
  f <- (th - nodes[k]) / (nodes[k + 1] - nodes[k])
  (1 - f) * bank$info[k, avail] + f * bank$info[k + 1, avail]
}
# One respondent. x holds their responses (0, 1, ...) to the bank items, in bank order.
# Start at the prior mean; give the most informative item at the current EAP (or pick
# at random among the `top` most informative, or at random from the whole bank); update;
# stop at max_items or when the posterior SD reaches se_stop.
run_cat <- function(x, bank, max_items = 20, se_stop = 0, select = "info", top = 1) {
  ll <- numeric(length(nodes))
  used <- integer(0)
  est <- eap(ll)
  while (length(used) < max_items && est[["se"]] > se_stop) {
    avail <- setdiff(seq_along(bank$items), used)
    if (select == "random") {
      j <- avail[sample.int(length(avail), 1)]
    } else {
      best <- avail[order(info_at(bank, est[["theta"]], avail), decreasing = TRUE)]
      best <- best[seq_len(min(top, length(best)))]
      j <- best[sample.int(length(best), 1)]
    }
    ll <- ll + bank$logp[[j]][, x[j] + 1]
    used <- c(used, j)
    est <- eap(ll)
  }
  list(theta = est[["theta"]], se = est[["se"]], n = length(used), used = used)
}
bank_cm <- make_bank(m_cm, bank_items)

## ---- holdout-cm
# The respondents who take the CAT: 600 drawn from the held-out half (the precomputed
# run uses all 600; the page runs the first 50 live).
held <- setdiff(seq_len(nrow(cm)), cal)
set.seed(2021)
cat_ids <- sample(held, 600)
X_cm <- cm[cat_ids, bank_items]
# Everyone's full-bank EAP: the target a CAT is trying to reach with fewer items
full_cm <- t(apply(X_cm, 1, function(x) unlist(run_cat(x, bank_cm, max_items = length(bank_items))[1:3])))

## ---- bank-info-cm
# Where is the bank informative? Test information and CSEM along the scale.
th <- seq(-4, 4, by = 0.01)
I_bank <- rowSums(sapply(bank_items, function(i) iteminfo(extract.item(m_cm, i), th)))
c(peak_at = th[which.max(I_bank)], peak_info = round(max(I_bank), 1),
  csem_at_peak = round(1 / sqrt(max(I_bank)), 2))
round(sapply(c(-3, -2, -1, 0, 1, 2, 3), function(t) 1 / sqrt(I_bank[abs(th - t) < 1e-9])), 2)
c(items_above_2 = sum(pars[bank_items, "b"] > 2), items_below_minus2 = sum(pars[bank_items, "b"] < -2))

## ---- sanity-cm
# A known answer first: a "CAT" that gives the whole bank must reproduce mirt's own
# full-test EAP for every respondent (same nodes, same prior). Non-bank items are NA.
pat <- cm[cat_ids, colnames(cm)]
pat[, setdiff(colnames(cm), bank_items)] <- NA
mirt_eap <- fscores(m_cm, method = "EAP", response.pattern = pat, quadpts = 121,
                    theta_lim = c(-6, 6))
c(largest_difference = signif(max(abs(mirt_eap[, "F1"] - full_cm[, "theta"])), 2))

## ---- cat-live-cm
# The first 50 CAT respondents, three rules: 20 items chosen by information, 20 chosen
# at random, and information until the posterior SD reaches 0.3 (at most 100 items).
set.seed(50)
live <- 1:50
rules <- list(info20 = list(max_items = 20), random20 = list(max_items = 20, select = "random"),
              se0.3 = list(max_items = 100, se_stop = 0.3))
live_res <- lapply(rules, function(r) t(sapply(live, function(k)
  unlist(do.call(run_cat, c(list(x = X_cm[k, ], bank = bank_cm), r))[1:3]))))
t(sapply(live_res, function(z) c(
  mean_items = mean(z[, "n"]), r_full = round(cor(z[, "theta"], full_cm[live, "theta"]), 3),
  rmse = round(sqrt(mean((z[, "theta"] - full_cm[live, "theta"])^2)), 2))))

## ---- first-steps-cm
# The first few steps for one respondent: after one or two right answers there is no
# maximum-likelihood estimate, but the EAP moves up and its SD falls.
one <- run_cat(X_cm[1, ], bank_cm, max_items = 6)
steps <- t(sapply(1:6, function(s) {
  ll <- Reduce(`+`, lapply(one$used[1:s], function(j) bank_cm$logp[[j]][, X_cm[1, j] + 1]))
  e <- eap(ll)
  c(item = s, a = round(pars[bank_items[one$used[s]], "a"], 2),
    b = round(pars[bank_items[one$used[s]], "b"], 2), x = X_cm[1, one$used[s]],
    eap = round(e[["theta"]], 2), post_sd = round(e[["se"]], 2))
}))
steps

## ---- fetch-dep
# PROMIS wave 1 depression: 56 candidate items, each on five frequency categories, 1
# (never) to 5 (always), so higher means more symptoms; none needs reversing. Recoded 0-4.
dep_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.promis1wave1_depression/rows?format=csv"
dd <- read.csv(dep_url)
dep <- tapply(dd$resp - 1, list(dd$id, dd$item), function(x) x[1])
dep <- dep[, order(colnames(dep))]
n_answered <- rowSums(!is.na(dep))
c(respondents = nrow(dep), items = ncol(dep), answered_7 = sum(n_answered == 7),
  answered_all_56 = sum(n_answered == 56))
round(mean(dep == 0, na.rm = TRUE), 2)   # share of responses that are "never"

## ---- calibrate-dep
# 300 of the respondents who answered all 56 items take the CAT; the graded response
# model (PROMIS's own choice) is calibrated on everyone else, with the missing blocks
# left missing.
set.seed(56)
dep_cat <- sample(which(n_answered == 56), 300)
m_dep <- mirt(as.data.frame(dep[-dep_cat, ]), 1, itemtype = "graded", verbose = FALSE)
bank_dep <- make_bank(m_dep, colnames(dep))
X_dep <- dep[dep_cat, ]
I_dep <- rowSums(sapply(colnames(dep), function(i) iteminfo(extract.item(m_dep, i), th)))
c(peak_at = th[which.max(I_dep)], peak_info = round(max(I_dep), 1))
round(sapply(c(-2, -1, -0.5, 0, 1, 2, 3), function(t) 1 / sqrt(I_dep[abs(th - t) < 1e-9])), 2)
b_dep <- coef(m_dep, IRTpars = TRUE, simplify = TRUE)$items
round(quantile(b_dep[, "b1"], c(0, 0.5, 1)), 2)   # the lowest boundary, never vs. rarely

## ---- cat-dep
# Post-hoc CAT to a posterior SD of 0.3 (no cap beyond the 56 items), against each
# respondent's full-bank EAP.
full_dep <- t(apply(X_dep, 1, function(x) unlist(run_cat(x, bank_dep, max_items = 56)[1:3])))
set.seed(57)
cat_dep <- t(apply(X_dep, 1, function(x) unlist(run_cat(x, bank_dep, max_items = 56, se_stop = 0.3)[1:3])))
c(median_items = median(cat_dep[, "n"]), mean_items = round(mean(cat_dep[, "n"]), 1),
  r_full = round(cor(cat_dep[, "theta"], full_dep[, "theta"]), 3),
  reached_0.3 = round(mean(cat_dep[, "se"] <= 0.3), 2))
band <- cut(full_dep[, "theta"], c(-Inf, -0.5, 0.5, 1.5, Inf))
data.frame(respondents = as.vector(table(band)),
           mean_items = round(tapply(cat_dep[, "n"], band, mean), 1),
           mean_post_sd = round(tapply(cat_dep[, "se"], band, mean), 2))
c(at_floor = sum(rowSums(X_dep) == 0), floor_eap = round(unique(full_dep[rowSums(X_dep) == 0, "theta"]), 2))
