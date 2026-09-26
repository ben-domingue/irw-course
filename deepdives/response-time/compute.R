# Deep dive #24 for the lesson "Response time and the speed-accuracy tradeoff": how
# are speed and accuracy related across the IRW's timed tables with 0/1 responses?
#
# Run by hand from the repository root (it needs a Redivis token for irw_fetch):
#   Rscript deepdives/response-time/compute.R
# It writes deepdives/response-time/results.rds, which is committed. The lesson page
# only reads that file, so the page renders without a token.
#
# For each table, the lesson's own analysis (lme4; Bates, Maechler, Bolker & Walker,
# 2015):
#   - log time:  lmer(log(rt) ~ 1 + (1 | id) + (1 | item)); person speed tau is minus
#     the respondent effect, item time intensity beta the item effect;
#   - accuracy:  glmer(resp ~ 1 + (1 | id) + (1 | item), binomial); theta is the
#     respondent effect, difficulty b minus the item effect;
#   - the correlations of the estimates: theta with tau, b with beta;
#   - the conditional accuracy function: accuracy by decile of residual log time
#     (log time minus the person and item effects), and the slope of accuracy on
#     that residual with person and item effects in the model;
#   - the IMV (Domingue et al., 2024) of adding log time, centred within item, to the
#     accuracy model, linear and as a B-spline with 4 df, on held-out responses
#     (5 folds). This is the comparison of the IRW's rt_imv vignette.
#
# One cache file per table (deepdives/response-time/fits/<table>.rds, not committed),
# so an interrupted run resumes where it stopped. A table that fails is logged in
# `failed` and dropped.

PILOT <- TRUE   # TRUE: 2 known-good tables plus a random top-up of 2. FALSE: every candidate.

suppressPackageStartupMessages({
  library(irw)
  library(lme4)
  library(splines)
})
set.seed(20260925)
dir <- file.path("deepdives", "response-time")
fit_dir <- file.path(dir, "fits")
dir.create(fit_dir, showWarnings = FALSE, recursive = TRUE)

## ---- candidates
candidate_tables <- suppressMessages(irw_filter(
  var            = "rt",          # response times recorded beside the responses
  n_categories   = 2,             # 0/1 responses: one accuracy model (the Rasch model as a GLMM)
  n_participants = c(150, Inf)    # 150 respondents for stable crossed random effects, as in
                                  #   the rt_imv vignette
))
n_all_candidates <- length(candidate_tables)

# Known-good tables for the pilot: the lesson's main table, whose answers the lesson
# shows (theta-speed r = 0.30, b-beta r = 0.48, accuracy falling from 0.83 to 0.56
# across deciles of residual time), and the chess test from earlier lessons.
known_good <- c("credentialform_lnirt", "chess_lnirt")
if (PILOT) {
  others <- setdiff(candidate_tables, known_good)
  run_tables <- c(intersect(known_good, candidate_tables), sample(others, 2))
} else {
  run_tables <- candidate_tables
}

## ---- prepare
# Keep 0/1 responses with a positive, finite time (in seconds); the most frequent wave (if any);
# the first response of a respondent to an item; at most 2,000 respondents.
prepare <- function(df, tab, max_n = 2000) {
  df$rt <- suppressWarnings(as.numeric(df$rt))   # some tables store rt as text
  # credentialform_lnirt: items 171-200 are pilot items, and which item sits under a
  # name depends on the respondent's pilot set, so keep the 170 scored items (as the
  # lesson does).
  if (tab == "credentialform_lnirt")
    df <- df[as.integer(sub("iraw.", "", df$item)) <= 170, ]
  df <- df[!is.na(df$resp) & !is.na(df$rt) & df$rt > 0 & is.finite(df$rt), ]
  if ("wave" %in% names(df)) {
    w <- names(which.max(table(df$wave)))
    df <- df[as.character(df$wave) == w, ]
  }
  vals <- sort(unique(df$resp))
  if (length(vals) != 2) stop("responses are not dichotomous: ", paste(vals, collapse = ", "))
  df$resp <- as.integer(df$resp == vals[2])
  df <- df[!duplicated(df[, c("id", "item")]), ]
  ids <- unique(df$id)
  if (length(ids) > max_n) df <- df[df$id %in% sample(ids, max_n), ]
  df$id <- factor(df$id); df$item <- factor(df$item)
  df$lrt <- log(df$rt)
  df$rt_cwi <- df$lrt - ave(df$lrt, df$item)   # log time centred within item
  df
}

## ---- fit-one
coin <- function(ll) { f <- function(p) p * log(p) + (1 - p) * log(1 - p) - ll
  uniroot(f, c(0.5, 0.999999))$root }
mean_ll <- function(y, p) mean(y * log(p) + (1 - y) * log(1 - p))
imv <- function(y, p0, p1) { w0 <- coin(mean_ll(y, p0)); w1 <- coin(mean_ll(y, p1)); (w1 - w0) / w0 }

fit_table <- function(tab) {
  cache <- file.path(fit_dir, paste0(tab, ".rds"))
  if (file.exists(cache)) return(readRDS(cache))
  t0 <- Sys.time()
  d <- prepare(irw_fetch(tab), tab)
  if (nlevels(d$item) < 5) stop("fewer than 5 items")
  m_t <- lmer(lrt ~ 1 + (1 | id) + (1 | item), d)
  m_a <- glmer(resp ~ 1 + (1 | id) + (1 | item), d, binomial, nAGQ = 0)
  tau <- -ranef(m_t)$id[, 1]; names(tau) <- rownames(ranef(m_t)$id)
  th <- ranef(m_a)$id[, 1]; names(th) <- rownames(ranef(m_a)$id)
  beta <- ranef(m_t)$item[, 1]; names(beta) <- rownames(ranef(m_t)$item)
  b <- -ranef(m_a)$item[, 1]; names(b) <- rownames(ranef(m_a)$item)
  d$res <- residuals(m_t)
  dec <- cut(d$res, quantile(d$res, 0:10 / 10), include.lowest = TRUE, labels = FALSE)
  m_c <- glmer(resp ~ res + (1 | id) + (1 | item), d, binomial, nAGQ = 0)
  # IMV on held-out responses: 5 folds of responses.
  S <- bs(d$rt_cwi, df = 4); colnames(S) <- paste0("spl", 1:4); d <- cbind(d, S)
  fold <- sample(rep(1:5, length.out = nrow(d)))
  imvs <- t(sapply(1:5, function(k) {
    tr <- d[fold != k, ]; te <- d[fold == k, ]
    f0 <- glmer(resp ~ 1 + (1 | id) + (1 | item), tr, binomial, nAGQ = 0)
    f1 <- glmer(resp ~ rt_cwi + (1 | id) + (1 | item), tr, binomial, nAGQ = 0)
    f2 <- glmer(resp ~ spl1 + spl2 + spl3 + spl4 + (1 | id) + (1 | item), tr, binomial, nAGQ = 0)
    p <- lapply(list(f0, f1, f2), predict, newdata = te, type = "response", allow.new.levels = TRUE)
    c(linear = imv(te$resp, p[[1]], p[[2]]), spline = imv(te$resp, p[[1]], p[[3]]))
  }))
  out <- list(
    table = tab, n_resp = nlevels(d$id), n_items = nlevels(d$item), n_obs = nrow(d),
    median_rt = median(d$rt), accuracy = mean(d$resp),
    r_theta_speed = cor(th, tau[names(th)]), r_b_beta = cor(b, beta[names(b)]),
    sd_speed = attr(VarCorr(m_t)$id, "stddev"), sd_theta = attr(VarCorr(m_a)$id, "stddev"),
    caf = as.numeric(tapply(d$resp, dec, mean)),
    caf_slope = unname(fixef(m_c)["res"]),
    imv_linear = mean(imvs[, "linear"]), imv_spline = mean(imvs[, "spline"]),
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
    cat(sprintf("%d respondents, %d items, %.0f s\n", res$n_resp, res$n_items, res$seconds))
  }
}

## ---- summarise
summary <- do.call(rbind, lapply(fits, function(f) data.frame(
  table = f$table, n_resp = f$n_resp, n_items = f$n_items, n_obs = f$n_obs,
  median_rt = f$median_rt, accuracy = f$accuracy,
  r_theta_speed = f$r_theta_speed, r_b_beta = f$r_b_beta,
  caf_fastest = f$caf[1], caf_middle = mean(f$caf[5:6]), caf_slowest = f$caf[10],
  caf_slope = f$caf_slope, imv_linear = f$imv_linear, imv_spline = f$imv_spline,
  seconds = f$seconds)))
rownames(summary) <- NULL
caf <- do.call(rbind, lapply(fits, function(f) data.frame(table = f$table, decile = 1:10, accuracy = f$caf)))

results <- list(
  summary = summary,
  caf = caf,
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
