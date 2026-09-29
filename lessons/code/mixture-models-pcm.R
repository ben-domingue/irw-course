# Response styles as latent classes: mixed partial credit models (Rost, 1991) on the
# Perceived Stress Scale from su_2024_pss14, for the lesson "Mixture models: when
# respondents differ in kind". Too slow for the page (a dozen mixture fits, about
# 15-20 minutes in local R), so it was run by hand when the page was built and its
# summary saved to data/mixture-models-pcm.csv, which the page reads. Run from
# lessons/. Needs mirt and psych.

## ---- pcm-compute
suppressMessages({library(mirt); library(psych)})
pss_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_5:v5_0.su_2024_pss14/rows?format=csv"
pss <- read.csv(pss_url)
pss$it <- as.integer(sub("PSS_", "", pss$item))
X  <- tapply(pss$resp, list(pss$id, pss$it), function(x) x[1])   # codes 1-5, already keyed
RT <- tapply(pss$rt,   list(pss$id, pss$it), function(x) x[1])   # seconds
X  <- X[complete.cases(X), ]; RT <- RT[rownames(X), ]
medrt <- apply(RT, 1, median)
Y <- X - 1                                   # 0-4 for mirt; higher = more stress

# Two samples of 2,000: respondents who took at least a second per item (median), and
# respondents drawn from everyone. mirt's partial credit model is itemtype "Rasch" on
# polytomous items; dentype "mixture-K" gives each of K classes its own thresholds, its
# own mean and variance of theta, and a share. nruns = 3 random starts; the best is kept.
fit_set <- function(ix, sample_name) {
  D <- Y[ix, ]
  set.seed(2026)
  fits <- list(mirt(D, 1, itemtype = "Rasch", verbose = FALSE))
  for (K in 2:3)
    fits[[K]] <- multipleGroup(D, 1, itemtype = "Rasch", dentype = paste0("mixture-", K),
                               nruns = 3, verbose = FALSE, technical = list(NCYCLES = 1500))
  rows <- list()
  for (K in 1:3) {
    m <- fits[[K]]
    cl <- if (K == 1) rep(1, nrow(D)) else {
      pc <- as.matrix(fscores(m, method = "classify", verbose = FALSE))
      pc <- pc[, grep("^CLASS", colnames(pc)), drop = FALSE]
      max.col(pc)
    }
    sure <- if (K == 1) 1 else mean(apply(pc, 1, max) > 0.9)
    for (k in sort(unique(cl))) {
      S <- D[cl == k, , drop = FALSE]
      use <- prop.table(table(factor(S, 0:4)))
      rows[[length(rows) + 1]] <- data.frame(
        sample = sample_name, K = K, logLik = extract.mirt(m, "logLik"),
        npar = extract.mirt(m, "nest"), BIC = extract.mirt(m, "BIC"), sure = sure,
        class = k, n = nrow(S), share = nrow(S) / nrow(D),
        cat0 = use[["0"]], cat1 = use[["1"]], cat2 = use[["2"]], cat3 = use[["3"]], cat4 = use[["4"]],
        ends = mean(S == 0 | S == 4), middle = mean(S == 2),
        mean_sum = mean(rowSums(S)), sd_sum = sd(rowSums(S)),
        alpha = if (nrow(S) > 2 && all(apply(S, 2, var) > 0))
          psych::alpha(S, check.keys = FALSE, warnings = FALSE)$total$raw_alpha else NA,
        median_rt = median(medrt[ix][cl == k]),
        all_same = mean(apply(S, 1, function(r) length(unique(r)) == 1)))
    }
  }
  do.call(rbind, rows)
}
set.seed(11); slow_ix <- sample(which(medrt >= 1), 2000)
set.seed(12); all_ix  <- sample(nrow(Y), 2000)
t0 <- Sys.time()
res <- rbind(fit_set(slow_ix, "slower"), fit_set(all_ix, "everyone"))
res$minutes <- round(as.numeric(difftime(Sys.time(), t0, units = "mins")), 1)
res$date_run <- as.character(Sys.Date())
res$mirt <- as.character(packageVersion("mirt"))
write.csv(res, "data/mixture-models-pcm.csv", row.names = FALSE)
print(res, digits = 3)
