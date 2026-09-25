# Deep dive #26 for the lesson "Measurement invariance under treatment and life
# events": how much do treatment effects vary from item to item across the randomized
# trials in the IRW?
#
# Run by hand from the repository root (it needs a Redivis token for irw_fetch, and a
# full run takes hours):
#   Rscript deepdives/invariance-experience/compute.R
# It writes deepdives/invariance-experience/results.rds, which is committed. The
# lesson page only reads that file, so the page renders without a token.
#
# For each table, fit the IL-HTE model of the lesson (Gilbert, Kim & Miratrix, 2023;
# Gilbert, Himmelsbach, Soland, Joshi & Domingue, 2025) with lme4:
#   m0: resp ~ treat + (1 | id) + (1 | item)       (one effect for every item)
#   m1: resp ~ treat + (1 | id) + (treat | item)   (item-specific effects)
# and report the average effect and sigma_zeta in SDs of theta (s_theta from m0), rho
# on the lesson's difficulty scale (lme4's item intercept is an easiness, so its
# correlation is negated), and a likelihood-ratio test of m1 against m0 with the
# p-value halved for the boundary (Self & Liang, 1987).
#
# Follows the IRW's IL-HTE vignette
# (https://itemresponsewarehouse.org/vignettes/il_hte.html) in its model, its
# standardization, its test and its cap of 5,000 respondents. It differs in two ways:
#   - Waves (course decision F10, 09-24). The vignette uses "wave 1". Here the outcome
#     is the first post-randomization wave, read from the table's processing notes
#     where they have been checked (`wave_notes` below), and otherwise by a rule:
#     a wave coded 0 is a pretest and the outcome is the smallest positive wave;
#     with no 0, the outcome is the smallest wave. Which rule chose the wave is
#     recorded per table, so a full run can be audited. Any wave before the outcome
#     wave is fitted too, as a placebo: before treatment, sigma_zeta should be
#     indistinguishable from zero.
#   - No density filter: longitudinal tables have more than one response per
#     respondent-item pair across waves, so their density exceeds 1 and irw_filter's
#     default (0.5 to 1) would drop them.
#
# One cache file per table (deepdives/invariance-experience/fits/<table>.rds,
# gitignored), so an interrupted run resumes where it stopped. A table that fails is
# logged in `failed`.

PILOT <- TRUE   # TRUE: 2 known-good tables plus a random top-up of 3. FALSE: every candidate.

suppressPackageStartupMessages({library(irw); library(lme4)})
set.seed(20260925)
dir <- file.path("deepdives", "invariance-experience")
fit_dir <- file.path(dir, "fits")
dir.create(fit_dir, showWarnings = FALSE, recursive = TRUE)

## ---- candidates
candidate_tables <- sort(suppressMessages(irw_filter(
  var            = "treat",       # a recorded treatment indicator
  n_participants = c(100, Inf),   # the vignette's floor: enough respondents per arm to
                                  #   estimate an average effect with some precision
  density        = NULL)))        # keep longitudinal tables (density > 1; see above)
n_all_candidates <- length(candidate_tables)

# Waves checked against the processing notes (pre = pretest waves, post = outcome).
wave_notes <- list(
  gilbert_meta_20 = list(pre = 0, post = 1),   # 0 = pretest (37 items), 1 = posttest (93)
  gilbert_meta_74 = list(pre = NULL, post = 1) # waves 1 and 2 both follow randomization
)

# Known-good tables for the pilot, whose answers the lesson shows: the fractions
# trial (a clear effect with large item-level variation, and a pretest placebo) and
# the health-knowledge trial (a moderate effect, night-blindness items moving most).
known_good <- c("gilbert_meta_20", "gilbert_meta_37")
if (PILOT) {
  others <- setdiff(candidate_tables, known_good)
  run_tables <- c(intersect(known_good, candidate_tables), sample(others, 3))
} else {
  run_tables <- candidate_tables
}

## ---- prepare
# Long IRW table -> one long data frame per wave to fit: dichotomous items only (exactly
# two response values, recoded 0/1), treat coded 0/1, at least 3 items, at most 5,000
# respondents (sampled, as in the vignette).
prepare <- function(df, tab, max_n = 5000) {
  df <- df[!is.na(df$resp) & !is.na(df$treat), ]
  if (!all(df$treat %in% c(0, 1))) stop("treat is not coded 0/1")
  two <- tapply(df$resp, df$item, function(x) length(unique(x)) == 2)
  df <- df[df$item %in% names(two)[two], ]
  df$resp <- ave(df$resp, df$item, FUN = function(x) as.integer(x == max(x)))
  if (length(unique(df$item)) < 3) stop("fewer than 3 dichotomous items")
  if ("wave" %in% names(df)) {
    waves <- sort(unique(df$wave))
    if (!is.null(wave_notes[[tab]])) {
      post <- wave_notes[[tab]]$post; pre <- wave_notes[[tab]]$pre; rule <- "processing notes"
    } else if (0 %in% waves && any(waves > 0)) {
      post <- min(waves[waves > 0]); pre <- 0; rule <- "wave 0 is a pretest"
    } else {
      post <- min(waves); pre <- NULL; rule <- "smallest wave"
    }
  } else {
    post <- NA; pre <- NULL; rule <- "no waves"
  }
  ids <- unique(df$id)
  if (length(ids) > max_n) df <- df[df$id %in% sample(ids, max_n), ]
  pick <- function(w) if (is.na(w)) df else df[df$wave == w, ]
  list(post = pick(post), pre = lapply(setNames(pre, pre), pick),
       post_wave = post, rule = rule)
}

## ---- ilhte
ilhte <- function(d) {
  d$item <- factor(d$item); d$id <- factor(d$id)
  if (length(unique(d$treat)) < 2) stop("only one arm in this wave")
  m0 <- glmer(resp ~ treat + (1 | id) + (1 | item), d, family = binomial)
  m1 <- glmer(resp ~ treat + (1 | id) + (treat | item), d, family = binomial)
  s_theta <- sqrt(VarCorr(m0)$id[1])
  vc <- VarCorr(m1)$item
  lr <- max(0, as.numeric(2 * (logLik(m1) - logLik(m0))))
  re <- ranef(m1)$item
  list(summary = data.frame(n_persons = nlevels(d$id), n_items = nlevels(d$item),
                            ate_sd = unname(fixef(m1)["treat"]) / s_theta,
                            sigma_zeta_sd = sqrt(vc[2, 2]) / s_theta,
                            rho = -attr(vc, "correlation")[1, 2],
                            lr = lr, p = 0.5 * pchisq(lr, 2, lower.tail = FALSE)),
       items = data.frame(item = rownames(re),
                          effect_sd = (fixef(m1)["treat"] + re[, "treat"]) / s_theta))
}

## ---- fit-one
fit_table <- function(tab) {
  cache <- file.path(fit_dir, paste0(tab, ".rds"))
  if (file.exists(cache)) return(readRDS(cache))
  t0 <- Sys.time()
  p <- prepare(as.data.frame(irw_fetch(tab)), tab)
  post <- ilhte(p$post)
  placebo <- lapply(p$pre, function(d) tryCatch(ilhte(d)$summary, error = function(e) NULL))
  out <- list(table = tab, summary = cbind(table = tab, wave = p$post_wave, wave_rule = p$rule,
                                           post$summary),
              items = cbind(table = tab, post$items),
              placebo = if (length(placebo)) do.call(rbind, Map(function(s, w)
                if (!is.null(s)) cbind(table = tab, wave = w, s), placebo, names(placebo))) else NULL,
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
    cat(sprintf("%d items, %.0f s\n", res$summary$n_items, res$seconds))
  }
}

## ---- summarise
summary <- do.call(rbind, lapply(fits, function(f) cbind(f$summary, seconds = f$seconds)))
rownames(summary) <- NULL
items <- do.call(rbind, lapply(fits, `[[`, "items"))
rownames(items) <- NULL
placebo <- do.call(rbind, lapply(fits, `[[`, "placebo"))

results <- list(
  summary = summary,
  items = items,
  placebo = placebo,
  candidate_tables = candidate_tables,
  run_tables = run_tables,
  n_all_candidates = n_all_candidates,
  failed = failed,
  pilot = PILOT,
  date_run = Sys.Date(),
  irw_version = tryCatch(irw_get_version(), error = function(e) NULL),
  session = sessionInfo())
saveRDS(results, file.path(dir, "results.rds"))
cat(sprintf("\n%d tables fitted, %d failed; %d with significant IL-HTE at .05\n",
            nrow(summary), nrow(failed), sum(summary$p < 0.05)))
