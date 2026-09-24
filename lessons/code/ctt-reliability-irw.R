# Classical test theory with real data: item analysis, alpha, and split halves
# for gilbert_meta_1, and reverse keying for the Mach IV (lessR_Mach4). Runs as-is
# in base R; no packages, login or token needed.
# Adapted from ben-domingue/252: c2/alpha.R, ps2/itemanalysis.R, ps2/parallel_tests.R.

## ---- helpers
# IRW tables are long (one row per response); reshape to one row per person.
long2wide <- function(df) {
  wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  as.data.frame(wide[, order(colnames(wide))])
}
# Cronbach's alpha (KR-20 when items are 0/1).
alpha <- function(resp) {
  resp <- resp[complete.cases(resp), ]
  k <- ncol(resp)
  (k / (k - 1)) * (1 - sum(apply(resp, 2, var)) / var(rowSums(resp)))
}
# Correlation of each item with the sum of the *other* items.
item_rest <- function(resp) {
  tot <- rowSums(resp)
  sapply(names(resp), function(i) cor(resp[[i]], tot - resp[[i]], use = "complete.obs"))
}

## ---- fetch
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v57_0.gilbert_meta_1/rows?format=csv"
df <- read.csv(url)
resp <- long2wide(df)
resp <- resp[complete.cases(resp), ]
dim(resp)

## ---- itemanalysis
ia <- data.frame(p = colMeans(resp), r_rest = item_rest(resp))
round(ia[order(ia$r_rest), ], 2)[1:6, ]   # the six weakest items
plot(ia$p, ia$r_rest, pch = 19, col = "#2780e3", xlim = c(0, 1),
     xlab = "Proportion correct (p)", ylab = "Item-rest correlation")
text(ia$p, ia$r_rest, rownames(ia), pos = 3, cex = 0.6)

## ---- alpha
alpha(resp)

## ---- splithalf
set.seed(252)
split_half <- function(resp) {
  k <- ncol(resp)
  h <- sample(k, k / 2)
  r <- cor(rowSums(resp[, h]), rowSums(resp[, -h]))
  c(raw = r, spearman_brown = 2 * r / (1 + r))
}
halves <- t(replicate(1000, split_half(resp)))
plot(density(halves[, "spearman_brown"]), lwd = 2, xlim = range(halves),
     main = "1,000 random split halves of gilbert_meta_1", xlab = "Reliability estimate")
lines(density(halves[, "raw"]), col = "#c2410c", lwd = 2)
abline(v = alpha(resp), lty = 2)
legend("topleft", c("Split-half correlation", "Spearman-Brown adjusted", "Alpha"),
       col = c("#c2410c", "black", "black"), lty = c(1, 1, 2), lwd = 2, bty = "n")
c(mean_adjusted = mean(halves[, "spearman_brown"]), alpha = alpha(resp))

## ---- mach-raw
mach <- long2wide(read.csv(
  "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v57_0.lessR_Mach4/rows?format=csv"))
dim(mach)          # 351 people, 20 items, responses 0 (strongly disagree) to 5
alpha(mach)
round(item_rest(mach), 2)

## ---- mach-keyed
# The published key (Christie & Geis, 1970): these ten items are worded so that
# agreeing is the *less* Machiavellian answer, so we reverse them.
reversed <- sprintf("m%02d", c(3, 4, 6, 7, 9, 10, 11, 14, 16, 17))
mach_keyed <- mach
mach_keyed[reversed] <- 5 - mach_keyed[reversed]
alpha(mach_keyed)
round(sort(item_rest(mach_keyed)), 2)
