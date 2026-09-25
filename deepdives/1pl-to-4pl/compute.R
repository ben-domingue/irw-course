# Deep dive #21 for the lesson "From the 1PL to the 4PL": how much do 2PL slopes
# vary across the IRW's dichotomous tables?
#
# Run by hand from the repository root (it needs a Redivis token for irw_fetch, and
# a full run takes hours):
#   Rscript deepdives/1pl-to-4pl/compute.R
# It writes deepdives/1pl-to-4pl/results.rds, which is committed. The lesson page
# only reads that file, so the page renders without a token.
#
# For each table: fit the Rasch model and the 2PL with mirt (marginal ML, EM; the
# same fits the lesson uses, with no priors), and summarise how much the 2PL slopes
# vary within the table. The key summary is the SD of log(a): it doesn't depend on
# the unit of theta (rescaling theta multiplies every slope by the same constant,
# which only shifts log(a)), so it can be compared across tables. The Rasch model
# says it is 0.
#
# One cache file per table (deepdives/1pl-to-4pl/fits/<table>.rds, gitignored), so
# an interrupted run resumes where it stopped. A table that fails is logged in
# `failed` and dropped.

PILOT <- TRUE   # TRUE: 2 known-good tables plus a random top-up of 4. FALSE: every candidate.

suppressPackageStartupMessages({
  library(irw)
  library(mirt)
})
set.seed(20260924)
dir <- file.path("deepdives", "1pl-to-4pl")
fit_dir <- file.path(dir, "fits")
dir.create(fit_dir, showWarnings = FALSE, recursive = TRUE)

## ---- candidates
candidate_tables <- suppressMessages(irw_filter(
  n_categories   = 2,             # dichotomous items: the 2PL is a model for binary responses
  n_participants = c(250, Inf),   # slopes need a few hundred respondents; chess (256) is the
                                  #   smallest table the lesson itself fits
  n_items        = c(5, 200),     # at least 5 items to define theta; at most 200 to keep each
                                  #   fit to minutes
  density        = c(0.8, 1)      # nearly complete matrices: sparse designs (forms, adaptive
                                  #   tests) need a linking design the plain fit doesn't have
))
n_all_candidates <- length(candidate_tables)

# Known-good tables for the pilot: the lesson's own two tables, whose answers the
# lesson shows (chess slopes from 0.02 to 3.8; RMET slopes from 0.21 to 1.1).
known_good <- c("chess_lnirt", "wilmer-rmet-normative-data-set-2022")
if (PILOT) {
  others <- setdiff(candidate_tables, known_good)
  run_tables <- c(intersect(known_good, candidate_tables), sample(others, 4))
} else {
  run_tables <- candidate_tables
}

## ---- reshape
# Long IRW table -> wide 0/1 matrix, one row per respondent. Keeps the most frequent
# wave (if any) and the first response to each item; recodes the two response values
# to 0/1; drops respondents with no responses and items with no variation; samples
# at most 5,000 respondents to keep the fits to minutes.
to_wide <- function(df, max_n = 5000) {
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

## ---- fit-one
fit_table <- function(tab) {
  cache <- file.path(fit_dir, paste0(tab, ".rds"))
  if (file.exists(cache)) return(readRDS(cache))
  t0 <- Sys.time()
  wide <- to_wide(irw_fetch(tab))
  if (ncol(wide) < 5) stop("fewer than 5 items with variation")
  tech <- list(NCYCLES = 2000)
  m1 <- mirt(wide, 1, itemtype = "Rasch", verbose = FALSE, technical = tech)
  m2 <- mirt(wide, 1, itemtype = "2PL", verbose = FALSE, technical = tech)
  # mirt's slope-intercept form a*theta + d; difficulty b = -d/a.
  cf <- coef(m2, simplify = TRUE)$items
  a <- cf[, "a1"]
  out <- list(
    table = tab,
    items = data.frame(table = tab, item = rownames(cf), a = a, b = -cf[, "d"] / a,
                       p = colMeans(wide, na.rm = TRUE)),
    n_resp = nrow(wide), n_items = ncol(wide),
    converged = extract.mirt(m1, "converged") && extract.mirt(m2, "converged"),
    bic_rasch = extract.mirt(m1, "BIC"), bic_2pl = extract.mirt(m2, "BIC"),
    sd_theta_rasch = sqrt(coef(m1, simplify = TRUE)$cov[1, 1]),
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
summary <- do.call(rbind, lapply(fits, function(f) {
  a <- f$items$a
  pos <- a[a > 0]
  data.frame(
    table = f$table, n_resp = f$n_resp, n_items = f$n_items, converged = f$converged,
    median_a = median(a), min_a = min(a), max_a = max(a),
    sd_log_a = if (length(pos) > 2) sd(log(pos)) else NA_real_,   # spread; 0 under Rasch
    ratio_90_10 = if (length(pos) > 2) unname(quantile(pos, 0.9) / quantile(pos, 0.1)) else NA_real_,
    n_negative = sum(a < 0),
    bic_rasch = f$bic_rasch, bic_2pl = f$bic_2pl,
    prefers_2pl = f$bic_2pl < f$bic_rasch,
    seconds = f$seconds)
}))
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
