# Classical test theory with real data: item analysis, alpha, and split halves
# for gilbert_meta_1, and reverse keying for the Mach IV (lessR_Mach4). Runs as-is
# in base R; no packages, login or token needed. Both CSV links are pinned to one
# version of the IRW data.
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
# Treatment was assigned by school: each school (cluster_id) has one value of treat.
c(students = length(unique(df$id)), schools = length(unique(df$cluster_id)),
  schools_with_one_arm = sum(tapply(df$treat, df$cluster_id, function(x) length(unique(x))) == 1))
resp <- long2wide(df)
resp <- resp[complete.cases(resp), ]   # keep students who answered all 30 items
dim(resp)

## ---- itemanalysis
ia <- data.frame(p = colMeans(resp), r_rest = item_rest(resp))
round(ia[order(ia$r_rest), ], 2)[1:6, ]   # the six weakest items
round(quantile(ia$r_rest, c(0.1, 0.5, 0.9)), 2)   # the spread across all 30
sum(ia$r_rest >= 0.4)                       # items at 0.40 or above
plot(ia$p, ia$r_rest, pch = 19, col = "#2780e3", xlim = c(0, 1),
     xlab = "Proportion correct (p)", ylab = "Item-rest correlation")
text(ia$p, ia$r_rest, rownames(ia), pos = 3, cex = 0.6)

## ---- alpha
sprintf("%.3f", alpha(resp))

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
print(c(mean_adjusted = mean(halves[, "spearman_brown"]), alpha = alpha(resp),
        lowest = min(halves[, "spearman_brown"]), highest = max(halves[, "spearman_brown"]),
        share_below_alpha = mean(halves[, "spearman_brown"] < alpha(resp))), digits = 3)

## ---- mach-raw
mach <- long2wide(read.csv(
  "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v57_0.lessR_Mach4/rows?format=csv"))
dim(mach)          # 351 respondents, 20 items, responses 0 (strongly disagree) to 5 (strongly agree)
sprintf("%.2f", alpha(mach))
round(item_rest(mach), 2)
sum(item_rest(mach) > 0)   # how many are positive

## ---- mach-keyed
# The published key (Christie & Geis, 1970): these ten items are worded so that
# agreeing is the *less* Machiavellian answer, so we reverse them.
reversed <- sprintf("m%02d", c(3, 4, 6, 7, 9, 10, 11, 14, 16, 17))
mach_keyed <- mach
mach_keyed[reversed] <- 5 - mach_keyed[reversed]
sprintf("%.2f", alpha(mach_keyed))
round(sort(item_rest(mach_keyed)), 2)

## ---- mach-auto
# Can the data find the key? Automated keying (e.g. psych::alpha(check.keys = TRUE))
# splits the items by the sign of their loading on the first principal component.
pc1 <- prcomp(mach)$rotation[, 1]
auto <- names(pc1)[sign(pc1) != sign(pc1["m01"])]  # items pointing away from m01
auto
setdiff(auto, reversed)   # flipped by the data but not by the published key
setdiff(reversed, auto)   # flipped by the published key but not by the data
# m19 is weak whichever way it is keyed.
mach_alt <- mach_keyed
mach_alt$m19 <- 5 - mach_alt$m19
round(c(m19_as_published = item_rest(mach_keyed)[["m19"]],
        m19_reversed = item_rest(mach_alt)[["m19"]],
        alpha_m19_reversed = alpha(mach_alt)), 2)
