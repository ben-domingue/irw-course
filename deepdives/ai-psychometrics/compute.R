# Deep dive #25 for the lesson "AI and psychometrics": can the text of an item alone
# predict how hard it is? Across the IRW's English cognitive tables with item text,
# how strongly do two simple text features (word count and mean word length) track
# item difficulty *within* each table?
#
# Run by hand from the repository root (it needs a Redivis token for irw_fetch and
# irw_itemtext):
#   Rscript deepdives/ai-psychometrics/compute.R
# It writes deepdives/ai-psychometrics/results.rds, which is committed. The lesson
# page only reads that file, so the page renders without a token.
#
# For each table: proportion correct per item (among respondents who answered it),
# joined to the item's text; then, within the table, the correlation of each feature
# with the logit of proportion correct. Pooling items across tables would confound
# item length with which test an item came from, so the summary is the distribution
# of within-table correlations. No language-model feature (Ben, 09-24: punted).
#
# One cache file per table (deepdives/ai-psychometrics/fits/<table>.rds, gitignored),
# so an interrupted run resumes. A table that fails is logged in `failed` and dropped.
# Adapted from the IRW vignette "Does item language predict difficulty?"
# (https://itemresponsewarehouse.org/vignettes/item_text_difficulty.html).

PILOT <- TRUE   # TRUE: 3 known-good tables plus a random top-up of 3. FALSE: every candidate.

suppressPackageStartupMessages(library(irw))
options(irw.itemtext_disclaimer = FALSE)
set.seed(20260925)
dir <- file.path("deepdives", "ai-psychometrics")
fit_dir <- file.path(dir, "fits")
dir.create(fit_dir, showWarnings = FALSE, recursive = TRUE)

## ---- candidates
meta <- suppressWarnings(suppressMessages(irw_filter(
  construct_type     = "Cognitive/educational",  # items with a right answer, so difficulty
                                                  #   is proportion correct
  n_categories       = 2,                         # dichotomous: 1 = correct
  n_participants     = c(200, Inf),               # proportions correct precise to about
                                                  #   +/- 0.07 or better
  primary_language_s_ = "eng"                     # word counts and word lengths are only
                                                  #   comparable within one language
)))
candidate_tables <- sort(intersect(meta, irw_list_itemtext_tables()))  # item text needed
n_all_candidates <- length(candidate_tables)

# Known-good tables for the pilot. himmelstein-number_series-2025: the pipeline must
# reproduce the proportions correct in the lesson "Constructs and construct maps"
# (NS_2 0.839, NS_6 0.015). himmelstein-impossible_question-2025: the lesson's own
# table (word count and logit proportion correct, r = -0.11). preschool_sel_box: the
# IRW vignette's strongest negative correlation (-0.63 on the raw proportion).
known_good <- c("himmelstein-number_series-2025", "himmelstein-impossible_question-2025",
                "preschool_sel_box")
if (PILOT) {
  others <- setdiff(candidate_tables, known_good)
  run_tables <- c(intersect(known_good, candidate_tables), sample(others, 3))
} else {
  run_tables <- candidate_tables
}

## ---- features
# Word count, and mean word length in characters with punctuation removed (as in the
# vignette). Blanks such as "___" count as a word with no letters and are dropped.
text_features <- function(txt) {
  words <- strsplit(trimws(gsub("[[:punct:]]", " ", txt)), "\\s+")
  words <- lapply(words, function(w) w[nchar(w) > 0])
  data.frame(word_count = lengths(strsplit(trimws(txt), "\\s+")),
             mean_word_length = vapply(words, function(w) if (length(w)) mean(nchar(w)) else NA_real_, 0))
}

## ---- one-table
one_table <- function(tab) {
  cache <- file.path(fit_dir, paste0(tab, ".rds"))
  if (file.exists(cache)) return(readRDS(cache))
  t0 <- Sys.time()
  df <- irw_fetch(tab)
  df <- df[!is.na(df$resp), ]
  vals <- sort(unique(df$resp))
  if (length(vals) != 2) stop("responses are not dichotomous: ", paste(vals, collapse = ", "))
  df$resp <- as.integer(df$resp == vals[2])
  # Proportion correct among those who answered. Every wave is kept: a table whose
  # respondents took the same item twice would count them twice, so we record it.
  p <- tapply(df$resp, df$item, mean)
  n <- tapply(df$resp, df$item, length)
  it <- as.data.frame(irw_itemtext(tab))
  it <- it[!duplicated(it$item) & !is.na(it$item_text) & nzchar(it$item_text), c("item", "item_text")]
  items <- merge(data.frame(item = names(p), p = as.vector(p), n = as.vector(n)), it, by = "item")
  if (nrow(items) < 5) stop("fewer than 5 items with both responses and text")
  items <- cbind(table = tab, items, text_features(items$item_text))
  # Logit of proportion correct, with items everyone (or no one) got right pulled in
  # by half a response so the logit is finite.
  items$logit_p <- qlogis((items$p * items$n + 0.5) / (items$n + 1))
  out <- list(table = tab, items = items,
              repeated = any(duplicated(df[, c("id", "item")])),
              seconds = as.numeric(difftime(Sys.time(), t0, units = "secs")))
  saveRDS(out, cache)
  out
}

## ---- run
failed <- data.frame(table = character(), error = character())
fits <- list()
for (tab in run_tables) {
  cat(sprintf("[%d/%d] %s ... ", match(tab, run_tables), length(run_tables), tab))
  res <- tryCatch(one_table(tab), error = function(e) e)
  if (inherits(res, "error")) {
    failed <- rbind(failed, data.frame(table = tab, error = conditionMessage(res)))
    cat("FAILED:", conditionMessage(res), "\n")
  } else {
    fits[[tab]] <- res
    cat(sprintf("%d items, %.0f s\n", nrow(res$items), res$seconds))
  }
}

## ---- summarise
# Within-table correlations. A feature with no variation in a table (every item the
# same length) gives NA there.
safe_cor <- function(x, y) if (sd(x, na.rm = TRUE) > 0) cor(x, y, use = "complete.obs") else NA_real_
items <- do.call(rbind, lapply(fits, `[[`, "items"))
rownames(items) <- NULL
summary <- do.call(rbind, lapply(fits, function(f) {
  d <- f$items
  data.frame(table = f$table, n_items = nrow(d), median_p = median(d$p),
             median_words = median(d$word_count),
             r_word_count = safe_cor(d$word_count, d$logit_p),
             r_word_length = safe_cor(d$mean_word_length, d$logit_p),
             repeated_responses = f$repeated, seconds = f$seconds)
}))
rownames(summary) <- NULL

results <- list(
  summary = summary,
  items = items,
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
print(summary[, c("table", "n_items", "r_word_count", "r_word_length")], digits = 2)
cat(sprintf("\n%d tables, %d failed\n", nrow(summary), nrow(failed)))
