# The Rasch model with real data: chess_lnirt and wirs from the Item Response
# Warehouse. Runs as-is in R; needs only the mirt package. No login or token.
# Adapted from ben-domingue/252: c3/rasch0.R and c3/rasch2.R.

## ---- fetch
library(mirt)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/)
# with a CSV download. This link is pinned to one version of the data.
chess_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v57_0.chess_lnirt/rows?format=csv"
df <- read.csv(chess_url)
head(df)

## ---- reshape
# IRW tables are long: one row per person-item response. mirt wants wide: one
# row per person, one column per item.
long2wide <- function(df) {
  wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  as.data.frame(wide[, order(as.numeric(gsub("\\D", "", colnames(wide))))])
}
resp <- long2wide(df)
# A few players have no responses at all (resp is NA for every item; the first
# rows of the table are one of them). They carry no information, so drop them.
resp <- resp[rowSums(!is.na(resp)) > 0, ]
dim(resp)

## ---- fit
m1 <- mirt(resp, 1, itemtype = "Rasch", verbose = FALSE)
# mirt writes the Rasch model as P(x = 1) = 1 / (1 + exp(-(theta + d))), so its
# "d" is an easiness. The difficulty in our notation is b = -d.
b <- -coef(m1, simplify = TRUE)$items[, "d"]
round(head(sort(b)), 2)   # the easiest items
round(tail(sort(b)), 2)   # the hardest items

## ---- pvalues
p <- colMeans(resp, na.rm = TRUE)
plot(p, b, xlab = "Proportion correct (p-value)", ylab = "Rasch difficulty (b)",
     pch = 19, col = "#2780e3")

## ---- wright
theta <- fscores(m1)[, 1]
br <- seq(floor(min(c(theta, b))), ceiling(max(c(theta, b))), by = 0.25)
h <- hist(theta, breaks = br, plot = FALSE)
op <- par(mar = c(4, 4, 2, 1))
plot(NULL, xlim = c(-max(h$counts), 12), ylim = range(br), xaxt = "n",
     xlab = "", ylab = "Logits", main = "Wright map: chess_lnirt")
rect(-h$counts, h$breaks[-length(h$breaks)], 0, h$breaks[-1], col = "#dbeafe", border = "white")
points(rep(1.5, length(b)) + (seq_along(b) %% 8), b, pch = 18, col = "#c2410c")
abline(v = 0)
axis(1, at = c(-max(h$counts) / 2, 5), labels = c("People", "Items"), tick = FALSE)
par(op)
c(mean_theta = mean(theta), mean_b = mean(b))

## ---- itemfit-chess
fit <- itemfit(m1, fit_stats = "infit")
head(fit[order(-abs(fit$z.outfit)), ], 5)   # the five worst-fitting items
itemfit(m1, empirical.plot = 13)

## ---- wirs
wirs_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v57_0.wirs/rows?format=csv"
resp_w <- long2wide(read.csv(wirs_url))
m2 <- mirt(resp_w, 1, itemtype = "Rasch", verbose = FALSE)
itemfit(m2, empirical.plot = 1)
