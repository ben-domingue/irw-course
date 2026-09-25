# Precomputed results for the lesson "Item banks and adaptive testing" (digest E12): a
# post-hoc CAT on the CMSCE (choi_2026_cmsce_2020_1) for 600 held-out respondents under
# five rules. It isn't a corpus deep dive, but it follows the same split (PROTOCOL §5):
# this script is run by hand and writes deepdives/item-banks-cat/results.rds, which is
# committed; the page only reads that file, and runs the first 50 respondents live.
#
# Run from the repository root (no token needed; the CSV is tokenless):
#   Rscript deepdives/item-banks-cat/compute.R
#
# The data, the calibration, the CAT engine and the 600 respondents come from the
# lesson's own code: this script runs lessons/code/item-banks-cat-irw.R up to its
# "bank-info-cm" chunk, so the page and this file can't drift apart.

PILOT <- FALSE   # TRUE: the first 60 respondents only, to check the pipeline.

t0 <- Sys.time()
src <- readLines(file.path("lessons", "code", "item-banks-cat-irw.R"))
eval(parse(text = src[seq_len(grep("^## ---- bank-info-cm", src) - 1)]))

## ---- rules
# The five rules. Every one starts at the prior mean and scores by EAP.
rules <- list(
  random20   = list(max_items = 20, select = "random"),     # a random 20-item form per respondent
  info20     = list(max_items = 20),                        # maximum information, 20 items
  info40     = list(max_items = 40),                        # maximum information, 40 items
  se0.3      = list(max_items = 100, se_stop = 0.3),        # to a posterior SD of 0.3, at most 100
  se0.3_top5 = list(max_items = 100, se_stop = 0.3, top = 5)  # the same, randomesque: one of the
)                                                           #   5 most informative, at random
who <- if (PILOT) 1:60 else seq_len(nrow(X_cm))

## ---- run
set.seed(20260925)
res <- lapply(rules, function(r) {
  out <- lapply(who, function(k) do.call(run_cat, c(list(x = X_cm[k, ], bank = bank_cm), r)))
  list(theta = sapply(out, `[[`, "theta"), se = sapply(out, `[[`, "se"),
       n = sapply(out, `[[`, "n"), used = lapply(out, `[[`, "used"))
})

## ---- summarise
target <- full_cm[who, "theta"]
summary <- do.call(rbind, lapply(names(res), function(k) {
  z <- res[[k]]
  expo <- tabulate(unlist(z$used), nbins = length(bank_items)) / length(who)
  data.frame(rule = k, mean_items = mean(z$n), median_items = median(z$n),
             r_full = cor(z$theta, target), rmse = sqrt(mean((z$theta - target)^2)),
             mean_se = mean(z$se), share_reached_0.3 = mean(z$se <= 0.3),
             max_exposure = max(expo), items_never_used = sum(expo == 0))
}))
band <- cut(target, c(-Inf, -1, 0, 1, 2, Inf))
by_band <- data.frame(band = levels(band), respondents = as.vector(table(band)),
                      mean_items = as.vector(tapply(res$se0.3$n, band, mean)),
                      share_at_cap = as.vector(tapply(res$se0.3$n == 100, band, mean)),
                      mean_se = as.vector(tapply(res$se0.3$se, band, mean)))
exposure <- sapply(res, function(z) tabulate(unlist(z$used), nbins = length(bank_items)) / length(who))
rownames(exposure) <- bank_items

results <- list(summary = summary, by_band = by_band, exposure = exposure,
                per_respondent = lapply(res, function(z) z[c("theta", "se", "n")]),
                full_theta = target, bank_items = bank_items, pars = pars[bank_items, ],
                rules = rules, n_respondents = length(who), pilot = PILOT,
                minutes = as.numeric(difftime(Sys.time(), t0, units = "mins")),
                date_run = Sys.Date(), session = sessionInfo())
saveRDS(results, file.path("deepdives", "item-banks-cat", "results.rds"))
print(summary, digits = 3)
print(by_band, digits = 3)
cat(sprintf("%.1f minutes\n", results$minutes))
