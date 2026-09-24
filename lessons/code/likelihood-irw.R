# Logistic regression by likelihood, with real data: chess_lnirt from the Item
# Response Warehouse. Runs as-is in base R; no packages, login or token needed.
# Adapted from ben-domingue/252: c1/likelihood.R and ps1/ps1-chess.R (PS1#2).

## ---- fetch
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/)
# with a CSV download. This link is pinned to one version of the data.
chess_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v57_0.chess_lnirt/rows?format=csv"
df <- read.csv(chess_url)
df <- df[!is.na(df$resp), ]          # drop the rows with no response
head(df[, c("id", "item", "resp", "cov_elo")])
c(responses = nrow(df), players = length(unique(df$id)), problems = length(unique(df$item)))

## ---- elo
# cov_elo is the player's Elo rating, standardized (mean 0, SD 1 across players).
elo <- tapply(df$cov_elo, df$id, function(x) x[1])
round(c(mean = mean(elo), sd = sd(elo)), 2)

## ---- pooled
# One logistic regression for all 10,240 responses: does Elo predict success?
m0 <- glm(resp ~ cov_elo, family = binomial, data = df)
round(summary(m0)$coefficients, 3)

## ---- surface
# The same slope by brute force: the log likelihood as a function of b1, with the
# intercept held at its estimate, and the maximum found by optim().
loglik <- function(b, x, y) {
  p <- plogis(b[1] + b[2] * x)
  sum(y * log(p) + (1 - y) * log(1 - p))
}
b1_grid <- seq(-0.5, 1.5, length.out = 201)
ll <- sapply(b1_grid, function(b1) loglik(c(coef(m0)[1], b1), df$cov_elo, df$resp))
plot(b1_grid, ll, type = "l", lwd = 2, col = "#2780e3",
     xlab = "Candidate slope (beta1)", ylab = "Log likelihood")
abline(v = coef(m0)[2], lty = 2, col = "#999")
opt <- optim(c(0, 0), function(b) -loglik(b, df$cov_elo, df$resp))
round(rbind(optim = opt$par, glm = coef(m0)), 3)

## ---- items
# Chess problems differ a lot in difficulty. Give each its own intercept.
m1 <- glm(resp ~ cov_elo + factor(item), family = binomial, data = df)
round(c(pooled = coef(m0)[["cov_elo"]], with_item_intercepts = coef(m1)[["cov_elo"]]), 2)

## ---- peritem
# Finally, a separate logistic regression for each problem.
slopes <- sapply(split(df, df$item), function(d)
  coef(glm(resp ~ cov_elo, family = binomial, data = d))[["cov_elo"]])
slopes <- sort(slopes)
round(c(head(slopes, 3), tail(slopes, 3)), 2)
# Proportion of players solving the problems discussed in the text.
round(tapply(df$resp, df$item, mean)[c("Y31", "Y15", "Y29")], 2)
op <- par(mar = c(4, 4, 1, 1))
plot(slopes, seq_along(slopes), pch = 19, col = "#2780e3", yaxt = "n",
     xlab = "Slope on Elo (logit per SD of Elo)", ylab = "")
axis(2, at = seq_along(slopes), labels = names(slopes), las = 1, cex.axis = 0.6)
abline(v = coef(m1)[["cov_elo"]], lty = 2, col = "#999")
par(op)
