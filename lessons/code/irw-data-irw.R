# A first look at three IRW tables: verbagg (0/1), manolika_2021_mini_ipip
# (1-5 Likert) and rr98_accuracy (0/1 with response times, repeated trials).
# Runs as-is in base R; no packages, login or token needed.
# Adapted from ben-domingue/252: c1/irw_data_exploration.R (and PS1#3).

## ---- helpers
# Every IRW table has a landing page, itemresponsewarehouse.org/tables/<name>/,
# with a "Download CSV" link that needs no account. The link names the version
# of the data (e.g. v59_0), so reading it off the page gets the current release.
irw_csv_url <- function(table) {
  page <- readLines(paste0("https://itemresponsewarehouse.org/tables/", tolower(table), "/"),
                    warn = FALSE)
  hit <- regmatches(page, regexpr('https://redivis\\.com/api/v1/tables/[^"]+format=csv', page))
  hit[[1]]
}
irw_csv <- function(table) read.csv(irw_csv_url(table))

# Long (one row per response) to wide (one row per respondent, one column per
# item). A respondent-item pair with no row becomes an empty (NA) cell.
long2wide <- function(df) {
  wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  as.data.frame(wide[, order(colnames(wide))])
}
# Correlation of each item with the sum of the *other* items.
item_rest <- function(resp) {
  tot <- rowSums(resp)
  sapply(names(resp), function(i) cor(resp[[i]], tot - resp[[i]], use = "complete.obs"))
}

## ---- verbagg-fetch
irw_csv_url("verbagg")        # the version-pinned link on the landing page
va <- irw_csv("verbagg")
head(va)
c(rows = nrow(va), respondents = length(unique(va$id)), items = length(unique(va$item)))

## ---- verbagg-wide
va_w <- long2wide(va)
dim(va_w)                     # one row per respondent, one column per item
va_w[1:4, 1:5]
sum(is.na(va_w))              # empty cells: respondent-item pairs with no row

## ---- verbagg-look
# 1. Missingness and categories, item by item
table(missing = colSums(is.na(va_w)), categories = sapply(va_w, function(x) length(unique(na.omit(x)))))
# 2. Item means (for 0/1 items, the proportion who said yes)
p <- sort(colMeans(va_w, na.rm = TRUE))
round(c(head(p, 3), tail(p, 3)), 2)
# 3. The sum-score distribution
r <- rowSums(va_w)
round(c(mean = mean(r), sd = sd(r), min = min(r), max = max(r)), 1)
c(at_0 = sum(r == 0), at_24 = sum(r == 24))   # respondents at the floor and the ceiling
# 4. Item-rest correlations
ir <- item_rest(va_w)
round(c(min = min(ir), median = median(ir), max = max(ir)), 2)
op <- par(mfrow = c(1, 3), mar = c(4, 4, 2, 1))
hist(p, breaks = seq(0, 1, 0.1), col = "#2780e3", border = "white",
     main = "Item means", xlab = "Proportion saying yes")
hist(r, breaks = seq(-0.5, 24.5, 1), col = "#2780e3", border = "white",
     main = "Sum scores", xlab = "Number of yes responses (of 24)")
hist(ir, breaks = seq(0, 1, 0.05), col = "#2780e3", border = "white",
     main = "Item-rest correlations", xlab = "Correlation")
par(op)

## ---- verbagg-design
# Item names encode the design: situation (S1-S4), want or do, and the behaviour.
# One item is spelled S4wantCurse, so match the mode ignoring case.
mode <- ifelse(grepl("want", names(p), ignore.case = TRUE), "want", "do")
behaviour <- sub(".*(Curse|Scold|Shout)$", "\\1", names(p))
round(tapply(p, mode, mean), 2)
round(tapply(p, behaviour, mean), 2)
round(tapply(p, list(behaviour, mode), mean), 2)

## ---- ipip-fetch
ip <- irw_csv("manolika_2021_mini_ipip")
head(ip)
c(rows = nrow(ip), respondents = length(unique(ip$id)), items = length(unique(ip$item)))
table(ip$resp)
ip_w <- long2wide(ip)
round(sort(colMeans(ip_w)), 1)

## ---- ipip-keying
# The Mini-IPIP's scoring key (Donnellan et al., 2006): four items per trait,
# two worded each way. Items whose names end in R are the reverse-worded ones.
traits <- list(
  Extraversion      = c("IPIP_01", "IPIP_06R", "IPIP_11", "IPIP_16R"),
  Agreeableness     = c("IPIP_02", "IPIP_07R", "IPIP_12", "IPIP_17R"),
  Conscientiousness = c("IPIP_03", "IPIP_08R", "IPIP_13", "IPIP_18R"),
  Neuroticism       = c("IPIP_04", "IPIP_09R", "IPIP_14", "IPIP_19R"),
  Intellect         = c("IPIP_05", "IPIP_10R", "IPIP_15R", "IPIP_20R"))
# If the R items were stored as answered, each would correlate negatively with
# the forward items of its own trait. Are any within-trait correlations negative?
within <- unlist(lapply(traits, function(t) {
  R <- cor(ip_w[, t]); R[upper.tri(R)]
}))
round(range(within), 2)
# Item-rest correlations within each trait, as stored
round(unlist(lapply(traits, function(t) item_rest(ip_w[, t]))), 2)

## ---- ipip-sums
# One sum score per trait (4 items each, so 4 to 20), not one for all 20 items.
sums <- sapply(traits, function(t) rowSums(ip_w[, t]))
round(apply(sums, 2, function(s) c(mean = mean(s), sd = sd(s))), 1)
# Covariates ride along in every row; one value per respondent.
cov <- ip[!duplicated(ip$id), c("id", "cov_gender", "cov_age")]
table(cov$cov_gender, useNA = "ifany")
summary(cov$cov_age)

## ---- rr98-fetch
rr <- irw_csv("rr98_accuracy")
head(rr)
c(rows = nrow(rr), respondents = length(unique(rr$id)), items = length(unique(rr$item)))
# id is observer plus session ("jf 2" is observer jf's session 2)
table(observer = sub(" .*", "", unique(rr$id)))
# Each respondent meets each item many times: rows per id-item pair
summary(as.vector(table(rr$id, rr$item)))
# block and trialnum say which meeting a row is: no id-item-block-trial repeats
sum(duplicated(rr[, c("id", "item", "block", "trialnum")]))

## ---- rr98-accuracy
level <- as.numeric(sub("i ", "", rr$item))     # brightness level, 0 to 32
acc <- tapply(rr$resp, level, mean)
round(acc[c("0", "1", "15", "16", "31", "32")], 2)
round(tapply(rr$resp, sub(" .*", "", rr$id), mean), 2)   # by observer
plot(as.numeric(names(acc)), acc, pch = 19, col = "#2780e3", ylim = c(0.4, 1),
     xlab = "Brightness level (proportion of white pixels x 32)", ylab = "Proportion correct")
abline(h = 0.5, lty = 2, col = "#999")

## ---- rr98-rt
# Response time in seconds. The distribution has a long right tail, so compare medians.
round(quantile(rr$rt, c(0.5, 0.99, 1)), 2)
# Ratcliff and Rouder set aside responses faster than 0.2 s or slower than 2.5 s
# (rtdists documentation); the IRW table keeps every response.
mean(rr$rt < 0.2 | rr$rt > 2.5)
round(tapply(rr$rt, factor(rr$resp, labels = c("error", "correct")), median), 2)

## ---- rr98-bylevel
# The same comparison within each brightness level
med <- sapply(split(rr, level), function(d)
  c(error = median(d$rt[d$resp == 0]), correct = median(d$rt[d$resp == 1]),
    n_error = sum(d$resp == 0)))
gap <- med["error", ] - med["correct", ]
sum(gap > 0)                                         # levels where errors are slower
round(weighted.mean(gap, med["n_error", ]), 2)       # average gap, weighted by errors
round(cor(1 - acc, tapply(rr$rt, level, median)), 2) # harder levels are slower
plot(as.numeric(colnames(med)), med["correct", ], type = "b", pch = 19, col = "#2780e3",
     ylim = range(med[1:2, ]), xlab = "Brightness level", ylab = "Median response time (s)")
lines(as.numeric(colnames(med)), med["error", ], type = "b", pch = 17, col = "#c2410c")
legend("topright", c("Correct", "Error"), col = c("#2780e3", "#c2410c"), pch = c(19, 17), lty = 1, bty = "n")
