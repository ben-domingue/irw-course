# Deep dive #19 for the lesson "Differential item functioning": how common is DIF by
# gender or sex across the IRW, by the ETS A/B/C categories?
#
# Run by hand from the repository root (it needs a Redivis token for irw_fetch, and a
# full run takes hours):
#   Rscript deepdives/dif/compute.R
# It writes deepdives/dif/results.rds, which is committed. The lesson page only
# reads that file, so the page renders without a token.
#
# For each table: take the gender/sex covariate, keep its two most common values
# (the reference group is the larger), and run a Mantel-Haenszel-type analysis on
# every item, matching on the total score (studied item included):
#   - dichotomous items: the Mantel-Haenszel common odds ratio, delta = -2.35 ln(alpha),
#     and the ETS A/B/C rule (Zwick, 2012), exactly as in the lesson;
#   - polytomous items: the Liu-Agresti common cumulative odds ratio (Liu & Agresti,
#     1996; Penfield & Algina, 2003), which reduces to the MH odds ratio for two
#     categories, on the same delta scale, with the generalized Mantel chi-square
#     for significance. A/B/C are applied by analogy: A if not significant or
#     |delta| < 1, C if |delta| >= 1.5, B otherwise (no SE is computed, so the C rule
#     drops its "significantly greater than 1" part).
# The summary per table is the share of items in B and in C. Direction is not
# summarised: which code is women is rarely documented in the tables.
#
# Follows the IRW's gender DIF vignette
# (https://itemresponsewarehouse.org/vignettes/gender_dif.html) in its corpus filter
# and its cap of 5,000 respondents; it differs in the polytomous statistic and in
# also taking tables whose covariate is cov_male or cov_female.
#
# One cache file per table (deepdives/dif/fits/<table>.rds, gitignored), so an
# interrupted run resumes where it stopped. A table that fails is logged in `failed`.

PILOT <- TRUE   # TRUE: 2 known-good tables plus a random top-up of 4. FALSE: every candidate.

suppressPackageStartupMessages(library(irw))
set.seed(20260925)
dir <- file.path("deepdives", "dif")
fit_dir <- file.path(dir, "fits")
dir.create(fit_dir, showWarnings = FALSE, recursive = TRUE)

## ---- candidates
gender_vars <- c("cov_gender", "cov_sex", "cov_male", "cov_female")
candidate_tables <- sort(unique(unlist(lapply(gender_vars, function(v) suppressMessages(irw_filter(
  var          = v,            # a recorded gender or sex covariate
  n_items      = c(6, Inf),    # at least 6 items, so the total score can match respondents
  n_categories = c(2, 10),     # dichotomous or ordinal items; more than 10 categories are
                               #   closer to continuous ratings than to item responses
  density      = c(0.5, 1)))))))  # the vignette's default: mostly complete matrices
n_all_candidates <- length(candidate_tables)

# Known-good tables for the pilot, whose answers the lesson shows: the CES-D, where
# the crying item is flagged by sex in the paper and in the lesson's problem 3, and
# the first-grade vocabulary test, where the lesson finds no C item by gender.
known_good <- c("alexandrowicz_2018_cesd", "gilbert_meta_11")
if (PILOT) {
  others <- setdiff(candidate_tables, known_good)
  run_tables <- c(intersect(known_good, candidate_tables), sample(others, 4))
} else {
  run_tables <- candidate_tables
}

## ---- prepare
# Long IRW table -> list(X = wide matrix of integer responses, g = 0/1 group).
# Keeps the most frequent wave (if any) and the first response to each item; drops
# items answered by fewer than 80% of respondents, then respondents with any missing
# response; recodes each item's responses to 0, 1, ... in their original order;
# reverses any item whose correlation with the rest score is negative (a crude
# keying check, so that the total score runs one way); samples at most 5,000
# respondents.
prepare <- function(df, max_n = 5000) {
  v <- intersect(gender_vars, names(df))[1]
  df <- df[!is.na(df$resp) & !is.na(df[[v]]), ]
  if ("wave" %in% names(df)) {
    wv <- names(which.max(table(df$wave)))
    df <- df[as.character(df$wave) == wv, ]
  }
  df <- df[!duplicated(df[, c("id", "item")]), ]
  person <- df[!duplicated(df$id), c("id", v)]
  top <- names(sort(table(person[[v]]), decreasing = TRUE))[1:2]
  if (anyNA(top)) stop("fewer than two values of ", v)
  person <- person[as.character(person[[v]]) %in% top, ]
  if (nrow(person) > max_n) person <- person[sample(nrow(person), max_n), ]
  df <- df[df$id %in% person$id, ]
  wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  wide <- wide[, colMeans(!is.na(wide)) >= 0.8, drop = FALSE]
  wide <- wide[complete.cases(wide), , drop = FALSE]
  ids <- rownames(wide)
  wide <- apply(wide, 2, function(x) as.integer(factor(x, levels = sort(unique(x)))) - 1L)
  rownames(wide) <- ids
  wide <- wide[, apply(wide, 2, function(x) length(unique(x)) > 1), drop = FALSE]
  if (ncol(wide) < 6) stop("fewer than 6 items after cleaning")
  tot <- rowSums(wide)
  flip <- sapply(seq_len(ncol(wide)), function(i) cor(wide[, i], tot - wide[, i]) < 0)
  wide[, flip] <- sweep(-wide[, flip, drop = FALSE], 2, apply(wide[, flip, drop = FALSE], 2, max), "+")
  grp <- person[[v]][match(rownames(wide), as.character(person$id))]
  g <- as.integer(as.character(grp) == top[2])   # 0 = larger group (reference)
  if (min(table(factor(g, 0:1))) < 50) stop("fewer than 50 respondents in a group")
  list(X = wide, g = g, var = v, reference = top[1], focal = top[2], n_flipped = sum(flip))
}

## ---- statistics
# Liu-Agresti common cumulative odds ratio on the delta scale, plus the generalized
# Mantel chi-square (for dichotomous items: the MH odds ratio and MH chi-square with
# continuity correction, and the Robins-Breslow-Greenland SE for the ETS C rule).
dif_item <- function(y, g, s) {
  strata <- split(seq_along(y), s)
  strata <- strata[lengths(strata) > 1]
  cats <- sort(unique(y)); cuts <- cats[-length(cats)]
  num <- den <- 0; dF <- eF <- vF <- 0
  R <- S <- PR <- PSQR <- QS <- 0
  for (k in strata) {
    yk <- y[k]; gk <- g[k]; n <- length(k)
    for (j in cuts) {   # reference above the cut x focal at or below, and the reverse
      num <- num + sum(gk == 0 & yk > j) * sum(gk == 1 & yk <= j) / n
      den <- den + sum(gk == 0 & yk <= j) * sum(gk == 1 & yk > j) / n
    }
    nF <- sum(gk == 1); nR <- n - nF
    dF <- dF + sum(yk[gk == 1]); eF <- eF + nF * mean(yk)
    vF <- vF + nR * nF * (n * sum(yk^2) - sum(yk)^2) / (n^2 * (n - 1))
    if (length(cats) == 2) {
      A <- sum(gk == 0 & yk == cats[2]); B <- nR - A
      C <- sum(gk == 1 & yk == cats[2]); D <- nF - C
      r <- A * D / n; sq <- B * C / n; P <- (A + D) / n; Q <- (B + C) / n
      R <- R + r; S <- S + sq; PR <- PR + P * r; PSQR <- PSQR + P * sq + Q * r; QS <- QS + Q * sq
    }
  }
  corr <- if (length(cats) == 2) 0.5 else 0
  chisq <- max(0, abs(dF - eF) - corr)^2 / vF
  se <- if (length(cats) == 2) 2.35 * sqrt(PR / (2 * R^2) + PSQR / (2 * R * S) + QS / (2 * S^2)) else NA
  c(delta = -2.35 * log(num / den), se = se, p = pchisq(chisq, 1, lower.tail = FALSE))
}
ets <- function(delta, se, p) {
  big <- ifelse(is.na(se), abs(delta) >= 1.5, abs(delta) >= 1.5 & (abs(delta) - 1) / se > qnorm(0.95))
  ifelse(!is.finite(delta) | p >= 0.05 | abs(delta) < 1, "A", ifelse(big, "C", "B"))
}

## ---- fit-one
fit_table <- function(tab) {
  cache <- file.path(fit_dir, paste0(tab, ".rds"))
  if (file.exists(cache)) return(readRDS(cache))
  t0 <- Sys.time()
  d <- prepare(as.data.frame(irw_fetch(tab)))
  tot <- rowSums(d$X)
  st <- t(sapply(seq_len(ncol(d$X)), function(i) dif_item(d$X[, i], d$g, tot)))
  items <- data.frame(table = tab, item = colnames(d$X), n_cat = apply(d$X, 2, max) + 1,
                      st, ets = ets(st[, "delta"], st[, "se"], st[, "p"]))
  out <- list(table = tab, items = items, var = d$var, reference = d$reference, focal = d$focal,
              n_ref = sum(d$g == 0), n_foc = sum(d$g == 1), n_items = ncol(d$X),
              polytomous = any(items$n_cat > 2), n_flipped = d$n_flipped,
              seconds = as.numeric(difftime(Sys.time(), t0, units = "secs")))
  saveRDS(out, cache)
  out
}

## ---- run
failed <- data.frame(table = character(), error = character())
fits <- list()
for (tab in run_tables) {
  cat(sprintf("[%d/%d] %s ... ", match(tab, run_tables), length(run_tables), tab))
  res <- tryCatch(fit_table(tab), error = function(e) e)
  if (inherits(res, "error")) {
    failed <- rbind(failed, data.frame(table = tab, error = conditionMessage(res)))
    cat("FAILED:", conditionMessage(res), "\n")
  } else {
    fits[[tab]] <- res
    cat(sprintf("%d items, %.0f s\n", res$n_items, res$seconds))
  }
}

## ---- summarise
items <- do.call(rbind, lapply(fits, `[[`, "items"))
rownames(items) <- NULL
summary <- do.call(rbind, lapply(fits, function(f) data.frame(
  table = f$table, variable = f$var, n_ref = f$n_ref, n_foc = f$n_foc, n_items = f$n_items,
  polytomous = f$polytomous, n_flipped = f$n_flipped,
  significant = mean(f$items$p < 0.05), share_B = mean(f$items$ets == "B"),
  share_C = mean(f$items$ets == "C"), max_abs_delta = max(abs(f$items$delta[is.finite(f$items$delta)])),
  seconds = f$seconds)))
rownames(summary) <- NULL

results <- list(
  summary = summary,
  items = items,
  candidate_tables = candidate_tables,
  run_tables = run_tables,
  n_all_candidates = n_all_candidates,
  failed = failed,
  pilot = PILOT,
  date_run = Sys.Date(),
  irw_version = tryCatch(irw_get_version(), error = function(e) NULL),
  session = sessionInfo())
saveRDS(results, file.path(dir, "results.rds"))
cat(sprintf("\n%d tables fitted, %d failed; median %.0f s per table\n",
            nrow(summary), nrow(failed), median(summary$seconds)))
