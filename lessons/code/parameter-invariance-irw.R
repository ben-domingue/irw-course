# Parameter invariance with real data: the Multiracial Reading the Mind in the Eyes
# Test (wilmer-mrmet-normative-data-set-2022) from the Item Response Warehouse. Runs
# as-is in R with the mirt and psychotools packages; no login or token. The sixteen
# fits take a minute or two.
# Adapted from ben-domingue/252: c4 (slides 35-43) and c4/enem2.R (there, on ENEM data).

## ---- fetch
library(mirt)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/)
# with a CSV download. This link is pinned to one version of the data.
mrmet_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_2:v24_0.wilmer-mrmet-normative-data-set-2022/rows?format=csv"
df <- read.csv(mrmet_url)
# resp is 1 when the respondent chose the correct word; resp_raw is the word chosen
# ("none" when no word was chosen, scored 0). The table is marked longitudinal because
# respondents took the test on different dates, but each took it once:
c(respondents = length(unique(df$id)), items = length(unique(df$item)),
  responses_per_respondent = unique(as.vector(table(df$id))),
  dates_per_respondent = max(tapply(df$date, df$id, function(x) length(unique(x)))))

long2wide <- function(df) {
  wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  as.data.frame(wide[, order(as.numeric(gsub("\\D", "", colnames(wide))))])
}
resp <- long2wide(df)
person <- df[!duplicated(df$id), c("id", "cov_gender", "cov_age", "cov_country")]
person <- person[match(rownames(resp), person$id), ]
r <- rowSums(resp)
round(range(colMeans(resp)), 2)          # proportion correct: easiest and hardest items
table(person$cov_gender)
# How strongly do the items go together? The mean correlation between pairs of items:
mean_r <- function(d) { R <- cor(d); mean(R[upper.tri(R)]) }
round(mean_r(resp), 3)

## ---- compare
# Fit the Rasch model and the 2PL separately in two groups, and compare each item's
# estimates across the groups. IRTpars = TRUE converts mirt's intercept d to our
# difficulty, b = -d/a (for the Rasch model, b = -d).
fit_pars <- function(d, type) {
  coef(mirt(d, 1, itemtype = type, verbose = FALSE), simplify = TRUE, IRTpars = TRUE)$items[, c("a", "b")]
}
compare <- function(d, g, split, groups) {
  r1 <- fit_pars(d[g, ], "Rasch"); r2 <- fit_pars(d[!g, ], "Rasch")
  t1 <- fit_pars(d[g, ], "2PL");   t2 <- fit_pars(d[!g, ], "2PL")
  list(split = split, groups = groups, n = c(sum(g), sum(!g)), rasch = list(r1, r2), twopl = list(t1, t2),
       summary = data.frame(split = split, n1 = sum(g), n2 = sum(!g),
                            rasch_b_r = cor(r1[, "b"], r2[, "b"]),
                            rasch_shift = mean(r1[, "b"] - r2[, "b"]),
                            twopl_b_r = cor(t1[, "b"], t2[, "b"]),
                            twopl_a_r = cor(t1[, "a"], t2[, "a"]),
                            median_a_1 = median(t1[, "a"]), median_a_2 = median(t2[, "a"]),
                            mean_r_1 = mean_r(d[g, ]), mean_r_2 = mean_r(d[!g, ])))
}
set.seed(40)
random <- compare(resp, sample(c(TRUE, FALSE), nrow(resp), replace = TRUE), "random halves", c("half 1", "half 2"))
mf <- person$cov_gender %in% c("female", "male")
gender <- compare(resp[mf, ], person$cov_gender[mf] == "female", "women vs. men", c("women", "men"))
score  <- compare(resp, r > median(r), "high vs. low sum score", c("high", "low"))
odd <- seq(1, ncol(resp), by = 2); even <- seq(2, ncol(resp), by = 2)
r_odd <- rowSums(resp[, odd])
oddsplit <- compare(resp[, even], r_odd > median(r_odd), "even items, split on odd-item score",
                    c("high on odd items", "low on odd items"))
comps <- list(random, gender, score, oddsplit)
res <- do.call(rbind, lapply(comps, `[[`, "summary"))
print(format(res, digits = 2), row.names = FALSE)

## ---- plot
# Each item's difficulty in one group against the other. Grey line: identity.
# Top row, the Rasch model; bottom row, the 2PL.
op <- par(mfrow = c(2, 4), mar = c(4, 4, 2.5, 1), cex = 0.7)
for (model in c("rasch", "twopl")) for (cc in comps) {
  x <- cc[[model]][[2]][, "b"]; y <- cc[[model]][[1]][, "b"]
  keep <- abs(x) < 8 & abs(y) < 8   # a slope near 0 sends b = -d/a off the page
  plot(x[keep], y[keep], pch = 19, col = "#2780e3", xlab = cc$groups[2], ylab = cc$groups[1],
       main = paste(if (model == "rasch") "Rasch:" else "2PL:", sub(", split on odd-item score", " (odd split)", cc$split)),
       cex.main = 0.85)
  abline(0, 1, col = "grey60")
}
par(op)

## ---- slopes-score
# In the high and low halves by sum score, the 2PL slopes:
round(rbind(high = quantile(score$twopl[[1]][, "a"], c(0, .25, .5, .75, 1)),
            low  = quantile(score$twopl[[2]][, "a"], c(0, .25, .5, .75, 1))), 2)
# The same items in everyone, for comparison:
full_2pl <- fit_pars(resp, "2PL")
round(quantile(full_2pl[, "a"], c(0, .25, .5, .75, 1)), 2)

## ---- cml
# Conditional maximum likelihood (psychotools::raschmodel) conditions on the sum
# score, so selecting respondents by that same sum score leaves its likelihood intact.
# Splitting there is Andersen's (1973) test of the Rasch model.
library(psychotools)
cml <- function(d) { m <- raschmodel(d); list(b = itempar(m), ll = logLik(m)) }
hi <- cml(resp[r > median(r), ]); lo <- cml(resp[r <= median(r), ]); all <- cml(resp)
round(cor(hi$b, lo$b), 3)
# Andersen's likelihood-ratio statistic, on (items - 1) degrees of freedom:
c(LR = round(2 * (as.numeric(hi$ll) + as.numeric(lo$ll) - as.numeric(all$ll))), df = ncol(resp) - 1)
# Which items move between the halves? Compare with each item's 2PL slope in everyone.
moved <- (hi$b - mean(hi$b)) - (lo$b - mean(lo$b))
round(cor(moved, full_2pl[, "a"]), 2)
