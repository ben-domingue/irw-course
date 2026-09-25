# Deep dive #23, for the lesson "Dimensionality and multidimensional IRT": across the
# IRW, how much does a second dimension improve predictions of held-out responses?
# The IRW's dimensionality vignette asks the question with parallel analysis
# (https://itemresponsewarehouse.org/vignettes/dimensionality.html); this asks it with
# the lesson's own tool, the IMV of a two-dimensional model over a one-dimensional one.
#
# Run by hand from the repository root (it needs a Redivis token for irw_fetch, and a
# full run takes days: every table is fitted 10 times, half of them in two dimensions):
#   Rscript deepdives/dimensionality/compute.R
# It writes deepdives/dimensionality/results.rds, which is committed. The lesson page
# only reads that file, so the page renders without a token.
#
# For each table: dichotomize (below), split the responses at random into 5 folds; for
# each fold, fit a one-dimensional 2PL and an exploratory two-dimensional 2PL with mirt
# (marginal ML, EM, no priors) to the other folds, and predict the fold's responses.
# The IMV (Domingue et al., 2024, Psychometrika, doi:10.1007/s11336-024-09977-2) of the
# 2D model over the 1D model is averaged over folds. Predictions use unrotated
# abilities (fscores(rotate = "none")), in the same frame as the unrotated slopes.
# Also recorded: the ratio of the first two eigenvalues of the item correlations (the
# vignette's index; larger means closer to one dimension).
#
# One cache file per table (deepdives/dimensionality/fits/<table>.rds, gitignored), so
# an interrupted run resumes where it stopped. A table that fails is logged in `failed`
# and dropped.

PILOT <- TRUE   # TRUE: 2 known-good tables plus a random top-up of 3. FALSE: every candidate.

suppressPackageStartupMessages({
  library(irw)
  library(mirt)
})
set.seed(20260925)
dir <- file.path("deepdives", "dimensionality")
fit_dir <- file.path(dir, "fits")
dir.create(fit_dir, showWarnings = FALSE, recursive = TRUE)

## ---- candidates
candidate_tables <- suppressMessages(irw_filter(
  n_categories   = c(2, 7),       # dichotomous and Likert-type items; more categories are
                                  #   usually ratings or counts, which the split below fits badly
  n_participants = c(500, Inf),   # a second dimension's slopes need several hundred respondents
  n_items        = c(6, 40),      # at least 3 items per dimension; at most 40, the
                                  #   vignette's ceiling, which also keeps a 2D fit to minutes
  density        = c(0.8, 1)      # nearly complete matrices: sparse designs (forms,
                                  #   adaptive tests) need a linking design the plain fit lacks
))
n_all_candidates <- length(candidate_tables)

# Known-good tables for the pilot: psychtools_bfi, 25 items written for five traits
# (a second dimension should help clearly), and gilbert_meta_2, a 20-item reading test
# from fit-prediction (one dimension should do nearly all the work).
known_good <- c("psychtools_bfi", "gilbert_meta_2")
if (PILOT) {
  others <- setdiff(candidate_tables, known_good)
  run_tables <- c(intersect(known_good, candidate_tables), sample(others, 3))
} else {
  run_tables <- candidate_tables
}

## ---- reshape
# Long IRW table -> wide 0/1 matrix, one row per respondent. Keeps the most frequent
# wave (if any) and the first response to each item; drops respondents with no
# responses; samples at most 1,000 respondents to keep ten fits per table to minutes.
# Polytomous items are split at the cut closest to half the responses (1 = above the
# cut), as the lesson dichotomizes grit and mindset; items without variation are dropped.
split_item <- function(x) {
  v <- sort(unique(x[!is.na(x)]))
  if (length(v) <= 2) return(as.integer(x == v[length(v)]))
  share <- sapply(v[-length(v)], function(cut) mean(x > cut, na.rm = TRUE))
  as.integer(x > v[which.min(abs(share - 0.5))])
}
to_wide <- function(df, max_n = 1000) {
  df <- df[!is.na(df$resp), ]
  if ("wave" %in% names(df)) {
    w <- names(which.max(table(df$wave)))
    df <- df[as.character(df$wave) == w, ]
  }
  if ("date" %in% names(df)) df <- df[order(df$date), ]
  df <- df[!duplicated(df[, c("id", "item")]), ]
  ids <- unique(df$id)
  if (length(ids) > max_n) df <- df[df$id %in% sample(ids, max_n), ]
  wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  wide <- wide[rowSums(!is.na(wide)) > 0, , drop = FALSE]
  wide <- apply(wide, 2, split_item)
  keep <- apply(wide, 2, function(x) length(unique(x[!is.na(x)])) == 2)
  as.data.frame(wide[, keep, drop = FALSE])
}

## ---- imv
# The same functions as lessons/code/dimensionality-irw.R.
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
  th <- fscores(m, rotate = "none")
  th[is.na(th)] <- 0
  cf <- coef(m, simplify = TRUE)$items
  A <- cf[, grep("^a", colnames(cf)), drop = FALSE]
  i <- cells[, 2]
  p <- plogis(rowSums(A[i, , drop = FALSE] * th[cells[, 1], , drop = FALSE]) + cf[i, "d"])
  pmin(pmax(p, 1e-4), 1 - 1e-4)
}

## ---- fit-one
fit_table <- function(tab, k = 5) {
  cache <- file.path(fit_dir, paste0(tab, ".rds"))
  if (file.exists(cache)) return(readRDS(cache))
  t0 <- Sys.time()
  X <- as.matrix(to_wide(irw_fetch(tab)))
  if (ncol(X) < 6) stop("fewer than 6 items with variation")
  ev <- eigen(cor(X, use = "pairwise.complete.obs"), symmetric = TRUE, only.values = TRUE)$values
  cells <- which(!is.na(X), arr.ind = TRUE)
  fold <- sample(rep(1:k, length.out = nrow(cells)))
  per_fold <- sapply(1:k, function(f) {
    test <- cells[fold == f, , drop = FALSE]
    train <- as.data.frame(X); train[test] <- NA
    p1 <- predict_cells(mirt(train, 1, itemtype = "2PL", verbose = FALSE), test)
    p2 <- predict_cells(mirt(train, 2, itemtype = "2PL", verbose = FALSE), test)
    imv(X[test], p1, p2)
  })
  out <- list(table = tab, n_resp = nrow(X), n_items = ncol(X),
              eig_ratio = ev[1] / ev[2], per_fold = per_fold,
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
summary <- do.call(rbind, lapply(fits, function(f)
  data.frame(table = f$table, n_resp = f$n_resp, n_items = f$n_items,
             eig_ratio = f$eig_ratio, imv_2d = mean(f$per_fold),
             imv_2d_sd = sd(f$per_fold), seconds = f$seconds)))
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
