# Rater models with real data: many-facet Rasch and hierarchical rater models for
# cleverness ratings of alternate-uses responses (persons x tasks x raters, fully
# crossed), and teachers' leniency, halo and agreement with an expert benchmark
# in ratings of student essays. Needs TAM (Robitzsch, Kiefer & Wu), sirt
# (Robitzsch) and lme4 (Bates, Maechler, Bolker & Walker, 2015); no login or token.
# Both CSV links are pinned to the IRW versions the g-theory lesson used. The
# hierarchical rater model takes one to two minutes; everything else, seconds.

## ---- helpers
suppressPackageStartupMessages({library(TAM); library(sirt); library(lme4)})
options(digits = 7)  # R's default, in case a .Rprofile changes it
# TAM's many-facet fits warn about row names while building design matrices; the
# warnings are harmless, so each fit goes through this wrapper.
mfr <- function(...) suppressWarnings(tam.mml.mfr(..., verbose = FALSE))
# Rater-specific steps from a rater:step fit: each rater's distance from their
# first step to their last, in logits. Wider means ratings squeezed toward the middle.
step_span <- function(fit) {
  x <- fit$xsi.facets
  dev <- x[x$facet %in% c("rater:step", "step:rater"), ]
  k <- as.integer(sub(".*step(\\d).*", "\\1", dev$parameter))
  r <- sub(".*(rater\\d+).*", "\\1", sub("raterrater", "rater", dev$parameter))
  common <- x$xsi[x$facet == "step"]
  if (!length(common)) common <- tapply(x$xsi[x$facet == "item:step"],
    as.integer(sub(".*step", "", x$parameter[x$facet == "item:step"])), mean)
  K <- max(k)
  tapply(dev$xsi[k == K], r[k == K], sum) - tapply(dev$xsi[k == 1], r[k == 1], sum) +
    common[K] - common[1]
}

## ---- fetch-clever
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_2:v22_0.Forthmann-2024-cleverness_ratings/rows?format=csv"
cl <- read.csv(url)[, c("id", "item", "rater", "resp")]
tasks <- c("paperclip", "garbagebag", "rope")
# One row per respondent x rater, one column per task, categories 0-4 for TAM
w <- reshape(cl, idvar = c("id", "rater"), timevar = "item", direction = "wide")
names(w) <- sub("resp.", "", names(w), fixed = TRUE)
w <- w[order(w$id, w$rater), ]
resp <- w[, tasks] - 1
dim(resp)
round(tapply(cl$resp, cl$rater, mean), 2)   # raw mean rating by rater, on 1-5

## ---- mfrm-clever
fit_cl <- mfr(resp, facets = w["rater"], pid = w$id, formulaA = ~ item + rater + step)
xs <- fit_cl$xsi.facets
sev <- xs[xs$facet == "rater", c("parameter", "xsi", "se.xsi")]
sev$parameter <- sub("raterrater", "rater", sev$parameter)
data.frame(rater = sev$parameter, severity = round(sev$xsi, 2), se = round(sev$se.xsi, 3))  # higher = harsher
round(c(sd_severity = sd(sev$xsi), sd_persons = sqrt(fit_cl$variance[1, 1])), 2)

## ---- wright-clever
wle_cl <- tam.wle(fit_cl, progress = FALSE)
steps <- xs$xsi[xs$facet == "step"]; items <- xs[xs$facet == "item", ]
h <- hist(wle_cl$theta, breaks = seq(-5, 5, 0.25), plot = FALSE)
plot(NULL, xlim = c(-45, 42), ylim = c(-4.5, 4.5), xaxt = "n", xlab = "", ylab = "Logits",
     las = 1, main = "Cleverness ratings: a Wright map with a rater column")
rect(-h$counts, h$breaks[-length(h$breaks)], 0, h$breaks[-1], col = "#93c5fd", border = "white")
# Each task and rater gets its own column, so the labels don't overlap
points(c(5, 9, 13), items$xsi, pch = 18, cex = 1.6, col = "#c2410c")
text(c(5, 9, 13), items$xsi, c("clip", "bag", "rope"), pos = 3, cex = 0.7)
points(seq(20, 36, 4), sev$xsi, pch = 15, cex = 1.3, col = "#2780e3")
text(seq(20, 36, 4), sev$xsi, sub("rater", "", sev$parameter), pos = 3, cex = 0.7)
abline(v = 0); mtext(c("Respondents", "Tasks", "Raters"), side = 1, at = c(-22, 9, 28), line = 1)

## ---- adjust-clever
# Fully crossed: every respondent had every rater, so severity shifts everyone alike.
raw_cl <- tapply(cl$resp, cl$id, mean)[wle_cl$pid]
round(cor(raw_cl, wle_cl$theta), 3)
# Now pretend each respondent had only two of the five raters, drawn at random, and
# compare each score with the full-data estimate.
set.seed(150)
keep <- unlist(lapply(unique(w$id), function(i) paste(i, sample(unique(w$rater), 2))))
sub2 <- paste(w$id, w$rater) %in% keep
fit_2 <- mfr(resp[sub2, ], facets = w[sub2, "rater", drop = FALSE], pid = w$id[sub2],
             formulaA = ~ item + rater + step)
wle_2 <- tam.wle(fit_2, progress = FALSE)
raw_2 <- tapply(rowMeans(resp[sub2, ], na.rm = TRUE), w$id[sub2], mean)[wle_2$pid]
full <- setNames(wle_cl$theta, wle_cl$pid)[wle_2$pid]
round(c(raw_mean = cor(raw_2, full), mfrm = cor(wle_2$theta, full)), 3)

## ---- central-clever
fit_cs <- mfr(resp, facets = w["rater"], pid = w$id, formulaA = ~ item + rater + step + rater:step)
round(rbind(step_span = step_span(fit_cs), raw_sd = tapply(cl$resp, cl$rater, sd)), 2)
c(common_steps = fit_cl$ic$Npars, rater_steps = fit_cs$ic$Npars)      # parameters
round(c(common_steps = fit_cl$ic$AIC, rater_steps = fit_cs$ic$AIC))   # AIC
round(c(common_steps = fit_cl$ic$BIC, rater_steps = fit_cs$ic$BIC))   # BIC

## ---- hrm-clever
# The hierarchical rater model with a signal-detection rater level (DeCarlo, Kim &
# Johnson, 2011): each response has an ideal rating; each rater has a precision d
# and thresholds c. sirt's rm.facets fits the many-facet model on the same footing.
# (Both functions print their progress; capture.output keeps it off the page.)
invisible(capture.output(
  hrm <- rm.sdt(resp, pid = w$id, rater = w$rater, est.c.rater = "r", est.d.rater = "r",
                maxiter = 500),
  fac <- rm.facets(resp, pid = w$id, rater = w$rater)))
round(c(facets_reliability = fac$EAP.rel, hrm_reliability = hrm$EAP.rel), 2)
round(c(facets_AIC = fac$ic$AIC, hrm_AIC = hrm$ic$AIC))
# Rater precision d (higher = sharper), the same for every task in this fit
round(tapply(hrm$rater$d, sub(".*-", "", hrm$rater$item.rater), mean), 2)
round(cor(hrm$person$EAP, fac$person$EAP), 3)        # the two models' person estimates

## ---- fetch-essays
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_4:v7_0.teacherjudgements_lohmann_2026_essayratings/rows?format=csv"
es <- read.csv(url)[, c("id", "item", "rater", "resp")]
crit <- c("language_quality", "structure", "content", "holistic")
bench <- es[es$rater == "expert_benchmark", ]
tch <- es[es$rater != "expert_benchmark", ]
c(benchmark_rows = nrow(bench), teacher_rows = nrow(tch),
  teachers = length(unique(tch$rater)), essays = length(unique(bench$id)))
# The benchmark for the same essay and criterion, next to each teacher's rating
tch$bench <- bench$resp[match(paste(tch$id, tch$item), paste(bench$id, bench$item))]
round(c(teacher_minus_benchmark = mean(tch$resp - tch$bench)), 2)
round(tapply(tch$resp - tch$bench, tch$item, mean)[crit], 2)

## ---- lenient-essays
# Teachers as random effects: each has a leniency, drawn from a common distribution.
fit_es <- lmer(resp ~ item + (1 | id) + (1 | rater) + (1 | id:rater), data = tch)
vc <- as.data.frame(VarCorr(fit_es))
setNames(round(vc$sdcor, 2), c("essay x teacher", "essay", "teacher", "residual"))
len <- setNames(ranef(fit_es)$rater[, 1], rownames(ranef(fit_es)$rater))
round(quantile(len, c(0.1, 0.9)), 2)      # 10th and 90th percentiles of leniency
# A direct estimate that uses the benchmark as the anchor: each teacher's mean
# distance from it over their 20 ratings. The model never saw the benchmark.
direct <- tapply(tch$resp - tch$bench, tch$rater, mean)[names(len)]
round(cor(len, direct), 2)

## ---- adjust-essays
tch$adjusted <- tch$resp - len[tch$rater]
round(c(raw = cor(tch$resp, tch$bench), adjusted = cor(tch$adjusted, tch$bench)), 2)
round(c(raw = sqrt(mean((tch$resp - tch$bench)^2)),
        adjusted = sqrt(mean((tch$adjusted - mean(len) - tch$bench)^2))), 2)

## ---- halo-essays
# One row per teacher x essay (four criteria), and the benchmark for the same essays
tw <- reshape(tch[, c("id", "rater", "item", "resp")], idvar = c("id", "rater"),
              timevar = "item", direction = "wide")
names(tw) <- sub("resp.", "", names(tw), fixed = TRUE)
bw <- reshape(bench[, c("id", "item", "resp")], idvar = "id", timevar = "item", direction = "wide")
names(bw) <- sub("resp.", "", names(bw), fixed = TRUE)
bm <- bw[match(tw$id, bw$id), crit]
off <- function(R) mean(R[lower.tri(R)])       # mean correlation between criteria
round(cor(tw[, crit]), 2)
round(cor(bm), 2)
# Remove each teacher's own mean first, so leniency can't create the correlation
within <- function(x) sapply(crit, function(k) x[[k]] - ave(x[[k]], tw$rater))
round(c(teachers = off(cor(tw[, crit])), benchmark = off(cor(bm)),
        teachers_within = off(cor(within(tw))), benchmark_within = off(cor(within(bm)))), 2)

## ---- central-essays
# Centrality: does a teacher spread their 20 ratings less than the benchmark does
# on the same essays and criteria?
sd_t <- tapply(tch$resp, tch$rater, sd); sd_b <- tapply(tch$bench, tch$rater, sd)
c(narrower = sum(sd_t < sd_b), teachers = length(sd_t))
