# Deep dive #21, the out-of-sample half, for the lesson "Model fit and out-of-sample
# prediction": across the IRW's dichotomous tables, how much do the 2PL and the 3PL
# improve predictions of held-out responses? (The other half, how much 2PL slopes
# vary, is deepdives/1pl-to-4pl/compute.R.)
#
# Run by hand from the repository root (it needs a Redivis token for irw_fetch, and
# a full run takes many hours: every table is fitted 15 times):
#   Rscript deepdives/fit-prediction/compute.R
# It writes deepdives/fit-prediction/results.rds, which is committed. The lesson page
# only reads that file, so the page renders without a token.
#
# For each table: split the responses at random into 5 folds; for each fold, fit the
# Rasch model, the 2PL and the 3PL with mirt (marginal ML, EM, no priors: the fits
# the lesson uses) to the other folds, and predict the fold's responses. The IMV
# (Domingue et al., 2024, Psychometrika, doi:10.1007/s11336-024-09977-2) of each
# model over the one before it is averaged over folds. The first comparison is the
# Rasch model over each item's proportion correct in the training folds.
#
# One cache file per table (deepdives/fit-prediction/fits/<table>.rds, gitignored),
# so an interrupted run resumes where it stopped. A table that fails is logged in
# `failed` and dropped.

PILOT <- TRUE   # TRUE: 2 known-good tables plus a random top-up of 3. FALSE: every candidate.

suppressPackageStartupMessages({
  library(irw)
  library(mirt)
})
set.seed(20260924)
dir <- file.path("deepdives", "fit-prediction")
fit_dir <- file.path(dir, "fits")
dir.create(fit_dir, showWarnings = FALSE, recursive = TRUE)

## ---- candidates
# The same filter as deepdives/1pl-to-4pl/compute.R, so the two halves describe the
# same tables.
candidate_tables <- suppressMessages(irw_filter(
  n_categories   = 2,             # dichotomous items: the models are for binary responses
  n_participants = c(250, Inf),   # slopes need a few hundred respondents
  n_items        = c(5, 200),     # at least 5 items to define theta; at most 200 to keep
                                  #   each fit to minutes
  density        = c(0.8, 1)      # nearly complete matrices: sparse designs (forms,
                                  #   adaptive tests) need a linking design the plain fit
                                  #   doesn't have
))
n_all_candidates <- length(candidate_tables)

# Known-good tables for the pilot: gilbert_meta_2, whose answer the lesson shows
# (IMV of the 2PL over the Rasch model about 0.012, of the 3PL over the 2PL about
# 0.0001), and chess_lnirt, whose slopes run from 0.02 to 3.8 (1pl-to-4pl).
known_good <- c("gilbert_meta_2", "chess_lnirt")
if (PILOT) {
  others <- setdiff(candidate_tables, known_good)
  run_tables <- c(intersect(known_good, candidate_tables), sample(others, 3))
} else {
  run_tables <- candidate_tables
}

## ---- reshape
# Long IRW table -> wide 0/1 matrix, one row per respondent. Keeps the most frequent
# wave (if any) and the first response to each item; recodes the two response values
# to 0/1; drops respondents with no responses and items with no variation; samples
# at most 2,000 respondents to keep the fifteen fits per table to minutes.
to_wide <- function(df, max_n = 2000) {
  df <- df[!is.na(df$resp), ]
  if ("wave" %in% names(df)) {
    w <- names(which.max(table(df$wave)))
    df <- df[as.character(df$wave) == w, ]
  }
  if ("date" %in% names(df)) df <- df[order(df$date), ]
  vals <- sort(unique(df$resp))
  if (length(vals) != 2) stop("responses are not dichotomous: ", paste(vals, collapse = ", "))
  df$resp <- as.integer(df$resp == vals[2])
  df <- df[!duplicated(df[, c("id", "item")]), ]
  ids <- unique(df$id)
  if (length(ids) > max_n) df <- df[df$id %in% sample(ids, max_n), ]
  wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  wide <- wide[rowSums(!is.na(wide)) > 0, , drop = FALSE]
  keep <- apply(wide, 2, function(x) length(unique(x[!is.na(x)])) == 2)
  as.data.frame(wide[, keep, drop = FALSE])
}

## ---- imv
# The same functions as lessons/code/fit-prediction-irw.R.
coin <- function(ll) {
  if (ll <= log(0.5)) return(0.5)
  uniroot(function(w) w * log(w) + (1 - w) * log(1 - w) - ll, c(0.5, 1 - 1e-12), tol = 1e-12)$root
}
mean_ll <- function(y, p) mean(y * log(p) + (1 - y) * log(1 - p))
imv <- function(y, p0, p1) {
  w0 <- coin(mean_ll(y, p0)); w1 <- coin(mean_ll(y, p1))
  (w1 - w0) / w0
}
predict_cells <- function(m, cells) {
  th <- fscores(m)[, 1]
  # A respondent whose every response was held out has no ability estimate; the
  # prior mean, 0, is what EAP gives with no data.
  th[is.na(th)] <- 0
  cf <- coef(m, simplify = TRUE)$items
  i <- cells[, 2]
  cf[i, "g"] + (cf[i, "u"] - cf[i, "g"]) * plogis(cf[i, "a1"] * th[cells[, 1]] + cf[i, "d"])
}

## ---- fit-one
models <- c("Rasch", "2PL", "3PL")
fit_table <- function(tab, k = 5) {
  cache <- file.path(fit_dir, paste0(tab, ".rds"))
  if (file.exists(cache)) return(readRDS(cache))
  t0 <- Sys.time()
  X <- as.matrix(to_wide(irw_fetch(tab)))
  if (ncol(X) < 5) stop("fewer than 5 items with variation")
  cells <- which(!is.na(X), arr.ind = TRUE)
  fold <- sample(rep(1:k, length.out = nrow(cells)))
  per_fold <- t(sapply(1:k, function(f) {
    test <- cells[fold == f, , drop = FALSE]
    train <- X; train[test] <- NA
    y <- X[test]
    p <- cbind(p_value = colMeans(train, na.rm = TRUE)[test[, 2]],
               sapply(models, function(m) predict_cells(
                 mirt(as.data.frame(train), 1, itemtype = m, verbose = FALSE), test)))
    p <- pmin(pmax(p, 1e-4), 1 - 1e-4)
    c(imv_rasch = imv(y, p[, "p_value"], p[, "Rasch"]),
      imv_2pl   = imv(y, p[, "Rasch"], p[, "2PL"]),
      imv_3pl   = imv(y, p[, "2PL"], p[, "3PL"]))
  }))
  out <- list(table = tab, n_resp = nrow(X), n_items = ncol(X),
              mean_p = mean(X, na.rm = TRUE),
              mean_dist_half = mean(abs(colMeans(X, na.rm = TRUE) - 0.5)),
              per_fold = per_fold,
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
summary <- do.call(rbind, lapply(fits, function(f) {
  m <- colMeans(f$per_fold)
  data.frame(table = f$table, n_resp = f$n_resp, n_items = f$n_items,
             mean_p = f$mean_p, mean_dist_half = f$mean_dist_half,
             imv_rasch = m[["imv_rasch"]], imv_2pl = m[["imv_2pl"]], imv_3pl = m[["imv_3pl"]],
             seconds = f$seconds)
}))
rownames(summary) <- NULL

results <- list(
  summary = summary,
  candidate_tables = candidate_tables,
  run_tables = run_tables,
  n_all_candidates = n_all_candidates,
  known_good = known_good,
  failed = failed,
  pilot = PILOT,
  date_run = Sys.Date(),
  irw_version = tryCatch(irw_get_version(), error = function(e) NULL),
  session = sessionInfo())
saveRDS(results, file.path(dir, "results.rds"))
cat(sprintf("\n%d tables fitted, %d failed; median %.0f s per table\n",
            nrow(summary), nrow(failed), median(summary$seconds)))
