# Where CTT breaks, with real data: item curves against the sum score for a
# fourth-grade mathematics test (4thgrade_math_sirt), and statements about capital
# punishment that don't all rise with the score (andrich_mudfold). Runs as-is in
# base R; no packages, login or token needed. Both CSV links are pinned to one
# version of the IRW data.
# Adapted from ben-domingue/252: ps2/towards_irt.R (PS2#5).

## ---- helpers
# IRW tables are long (one row per response); reshape to one row per respondent.
long2wide <- function(df) {
  wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  as.data.frame(wide[, order(colnames(wide))])
}
# KR-20 (Cronbach's alpha for 0/1 items).
kr20 <- function(resp) {
  k <- ncol(resp)
  (k / (k - 1)) * (1 - sum(apply(resp, 2, var)) / var(rowSums(resp)))
}
# Correlation of each item with the sum of the *other* items.
item_rest <- function(resp) {
  tot <- rowSums(resp)
  sapply(names(resp), function(i) cor(resp[[i]], tot - resp[[i]]))
}

## ---- fetch-math
math_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0.4thgrade_math_sirt/rows?format=csv"
df <- read.csv(math_url)
head(df)
resp <- long2wide(df)
c(students = nrow(resp), items = ncol(resp), missing = sum(is.na(resp)))
# Each item belongs to one domain; most belong to a testlet of 2-4 items.
items <- unique(df[, c("item", "domain", "testlet")])
table(items$domain)

## ---- pvalues
p <- colMeans(resp)
round(range(p), 2)
round(sort(p)[c(1, 30)], 2)          # the hardest and the easiest item
sprintf("KR-20 = %.2f", kr20(resp))

## ---- curves
# For every sum score r, the proportion of students with that score who got each
# item right: a nonparametric item curve.
r <- rowSums(resp)
table(r)[c(1, length(table(r)))]      # the lowest and highest scores, and how many
prop <- aggregate(resp, by = list(r = r), FUN = mean)
n_r <- as.vector(table(r))
show <- c("MA1", "MD2", "MA3", "MG4", "MI3")   # five items from easy to hard
op <- par(mar = c(5, 4, 1, 9), xpd = NA)   # room on the right for the legend
plot(NULL, xlim = c(0, 30), ylim = c(0, 1), xlab = "Sum score (of 30)",
     ylab = "Proportion correct")
for (i in names(resp)) lines(prop$r, prop[[i]], col = "grey85")
cols <- colorRampPalette(c("#93c5fd", "#2780e3", "#c2410c"))(length(show))
for (k in seq_along(show)) lines(prop$r, prop[[show[k]]], col = cols[k], lwd = 2.5)
legend(31.5, 1, sprintf("%s (p = %.2f)", show, p[show]), col = cols, lwd = 2.5, bty = "n")
par(op)
# At the top score every item is right, by construction: the sum contains the item.
round(unlist(prop[prop$r == 30, show]), 2)

## ---- logistic
# Logistic regression of each item on the sum score, centred at the mean score so
# that the intercept is the log odds of success for a student of average score.
rc <- r - mean(r)
fits <- t(sapply(names(resp), function(i) coef(glm(resp[[i]] ~ rc, family = binomial))))
colnames(fits) <- c("intercept", "slope")
fits <- data.frame(p = p, round(fits, 2))
fits[order(fits$p), ][c(1:3, 28:30), ]            # the three hardest and three easiest
sprintf("cor(intercept, log odds of p) = %.2f", cor(fits$intercept, qlogis(p)))
fits[c(which.min(fits$slope), which.max(fits$slope)), ]   # flattest and steepest

## ---- straight
# The same items with a straight line instead: predictions at the lowest and highest
# possible sum scores.
straight <- sapply(c("MA1", "MB4"), function(i)
  predict(lm(resp[[i]] ~ r), data.frame(r = c(1, 30))))
rownames(straight) <- c("r = 1", "r = 30")
round(straight, 2)

## ---- halves
# The sum score depends on which items were taken. Split the test into its 15
# easiest and 15 hardest items and score each half.
easy <- names(sort(p, decreasing = TRUE))[1:15]
hard <- setdiff(names(resp), easy)
r_easy <- rowSums(resp[easy]); r_hard <- rowSums(resp[hard])
round(c(mean_easy = mean(r_easy), mean_hard = mean(r_hard)), 2)
mean(r_easy > r_hard)                 # share of students who score higher on the easy half
hard_given_easy <- tapply(r_hard, r_easy, mean)
plot(jitter(r_easy), jitter(r_hard), pch = 16, col = rgb(0.15, 0.5, 0.89, 0.25),
     xlab = "Score on the 15 easiest items", ylab = "Score on the 15 hardest items",
     xlim = c(0, 15), ylim = c(0, 15))
abline(0, 1, lty = 2, col = "grey50")
lines(as.numeric(names(hard_given_easy)), hard_given_easy, col = "#c2410c", lwd = 2.5)
round(hard_given_easy[c("5", "10", "15")], 1)

## ---- fetch-mud
mud_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0.andrich_mudfold/rows?format=csv"
mud <- long2wide(read.csv(mud_url))
# Andrich's order of the statements, from most against capital punishment to most in favour.
statements <- c("HIDEOUS", "LIFESACRED", "INEFFECTIV", "DONTBELIEV",
                "WISHNOTNEC", "MUSTHAVEIT", "DETERRENT", "CRIMDESERV")
mud <- mud[, statements]
c(respondents = nrow(mud), statements = ncol(mud), missing = sum(is.na(mud)))
round(colMeans(mud), 2)               # proportion agreeing with each statement

## ---- mud-raw
# Agreement counted as it comes: 1 = agree.
sprintf("KR-20 = %.2f", kr20(mud))
round(item_rest(mud), 2)

## ---- mud-keyed
# Key so that higher = more in favour: reverse the three statements against.
against <- c("HIDEOUS", "LIFESACRED", "INEFFECTIV")
keyed <- mud
keyed[against] <- 1 - keyed[against]
sprintf("KR-20 = %.2f", kr20(keyed))
round(item_rest(keyed), 2)
flip <- keyed; flip$DONTBELIEV <- 1 - flip$DONTBELIEV
round(item_rest(flip)["DONTBELIEV"], 2)   # DONTBELIEV keyed the other way

## ---- mud-curves
# Score respondents on the six end statements only (0 = against on all six,
# 6 = in favour on all six) and see how the two middle statements behave.
ends <- setdiff(statements, c("DONTBELIEV", "WISHNOTNEC"))
s <- rowSums(keyed[ends])
table(s)
g <- cut(s, c(-1, 0, 1, 3, 4, 6), labels = c("0", "1", "2-3", "4", "5-6"))   # pool thin cells
rbind(n = table(g), round(sapply(split(mud[c("DONTBELIEV", "WISHNOTNEC")], g), colMeans), 2))
# A quadratic term in a logistic regression lets the curve turn over.
round(summary(glm(mud$WISHNOTNEC ~ s + I(s^2), family = binomial))$coefficients, 2)
