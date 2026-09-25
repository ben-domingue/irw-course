# From the 1PL to the 4PL with real data: the Reading the Mind in the Eyes Test
# (wilmer-rmet-normative-data-set-2022) and the Amsterdam Chess Test (chess_lnirt)
# from the Item Response Warehouse. Runs as-is in R with the mirt package; no login
# or token. The four RMET fits take a minute or two.
# Adapted from ben-domingue/252: c4/enem1.R and c4/enem3.R (there, on ENEM data).

## ---- fetch-rmet
library(mirt)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/)
# with a CSV download. This link is pinned to one version of the data.
rmet_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_2:v22_0.wilmer-rmet-normative-data-set-2022/rows?format=csv"
df <- read.csv(rmet_url)
# resp is 1 when the respondent chose the correct word of the four; resp_raw is the
# word they chose. Every respondent answered every item once, and there are no waves.
head(df[, c("id", "item", "resp", "resp_raw")], 3)
c(respondents = length(unique(df$id)), items = length(unique(df$item)),
  responses_per_respondent = unique(as.vector(table(df$id))),
  words_offered_per_item = unique(as.vector(tapply(df$resp_raw, df$item, function(x) length(unique(x))))))

# IRW tables are long (one row per response); mirt wants wide (one row per respondent).
long2wide <- function(df) {
  wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  as.data.frame(wide[, order(as.numeric(gsub("\\D", "", colnames(wide))))])
}
resp <- long2wide(df)
p <- colMeans(resp)
round(range(p), 2)     # proportion correct: the easiest and hardest items

## ---- fit-rmet
# Four models, from the Rasch model to the 4PL. To keep the fits to a minute or two
# we use a random 5,000 of the 17,680 respondents.
set.seed(252)
rs <- resp[sample(nrow(resp), 5000), ]
models <- c("Rasch", "2PL", "3PL", "4PL")
fits <- lapply(setNames(models, models), function(m) mirt(rs, 1, itemtype = m, verbose = FALSE))
data.frame(parameters = sapply(fits, extract.mirt, "nest"),
           BIC = round(sapply(fits, extract.mirt, "BIC")),
           converged = sapply(fits, extract.mirt, "converged"))

## ---- slopes-rmet
# mirt writes the 2PL as a*theta + d. In our notation the difficulty is b = -d/a.
cf2 <- coef(fits$`2PL`, simplify = TRUE)$items
a <- cf2[, "a1"]
b <- -cf2[, "d"] / a
round(c(min_a = min(a), median_a = median(a), max_a = max(a)), 2)
round(c(min_b = min(b), max_b = max(b)), 2)
# The spread of the slopes on the log scale (0 under the Rasch model), and the ratio
# of the 90th to the 10th percentile. "Across the IRW" puts these in context.
round(c(sd_log_a = sd(log(a)), ratio_90_10 = unname(quantile(a, 0.9) / quantile(a, 0.1))), 2)

## ---- guessing-rmet
# mirt calls the lower asymptote g; it is our c.
c_hat <- coef(fits$`3PL`, simplify = TRUE)$items[, "g"]
round(quantile(c_hat, c(0, 0.25, 0.5, 0.75, 1)), 2)
# How many respondents are down where the lower asymptote lives? Chance on 36
# four-option items is 9 correct.
r <- rowSums(resp)
c(at_or_below_9 = sum(r <= 9), share = round(mean(r <= 9), 4), median_sum_score = median(r))

## ---- abilities-rmet
# Ability estimates (EAP) from the four models, for the same 5,000 respondents.
theta <- sapply(fits, function(m) fscores(m)[, 1])
round(cor(theta), 3)

## ---- fetch-chess
chess_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v57_0.chess_lnirt/rows?format=csv"
chess <- long2wide(read.csv(chess_url))
chess <- chess[rowSums(!is.na(chess)) > 0, ]   # three players have no responses
dim(chess)

## ---- chess-2pl
m_r <- mirt(chess, 1, itemtype = "Rasch", verbose = FALSE)
m_2 <- mirt(chess, 1, itemtype = "2PL", verbose = FALSE)
cc <- coef(m_2, simplify = TRUE)$items
a_ch <- cc[, "a1"]
b_ch <- -cc[, "d"] / a_ch                     # b = -d/a
round(sort(a_ch)[c(1:3, 38:40)], 2)          # the flattest and steepest items
round(rbind(a = a_ch, b = b_ch)[, c("Y15", "Y29")], 2)
round(c(BIC_Rasch = extract.mirt(m_r, "BIC"), BIC_2PL = extract.mirt(m_2, "BIC")))

## ---- chess-cross
# The 2PL curves for Y15 and Y29, with the proportion solving each item among
# players grouped by their sum score on the other 38 items (thirds).
rest <- rowSums(chess[, setdiff(names(chess), c("Y15", "Y29"))], na.rm = TRUE)
grp <- cut(rest, quantile(rest, 0:3 / 3), include.lowest = TRUE,
           labels = c("bottom third", "middle third", "top third"))
obs <- sapply(chess[, c("Y15", "Y29")], function(x) tapply(x, grp, mean, na.rm = TRUE))
cbind(players = table(grp), round(obs, 2))
th_grp <- tapply(fscores(m_2)[, 1], grp, mean)   # mean 2PL ability in each group
th <- seq(-3, 3, length.out = 200)
icc <- function(i) plogis(a_ch[i] * (th - b_ch[i]))
op <- par(mar = c(4, 4, 1, 1))
plot(th, icc("Y29"), type = "l", lwd = 2, col = "#2780e3", ylim = c(0, 1),
     xlab = "Ability (2PL scale)", ylab = "P(solved)")
lines(th, icc("Y15"), lwd = 2, col = "#c2410c")
points(th_grp, obs[, "Y29"], pch = 19, col = "#2780e3")
points(th_grp, obs[, "Y15"], pch = 17, col = "#c2410c")
legend("topleft", c("Y29", "Y15"), col = c("#2780e3", "#c2410c"), lwd = 2, pch = c(19, 17), bty = "n")
par(op)
# Where the two curves cross: a29 (theta - b29) = a15 (theta - b15).
cross <- (a_ch["Y29"] * b_ch["Y29"] - a_ch["Y15"] * b_ch["Y15"]) / (a_ch["Y29"] - a_ch["Y15"])
round(c(crossing_theta = unname(cross), share_of_players_below = mean(fscores(m_2)[, 1] < cross)), 2)

## ---- chess-weighted
# Under the Rasch model, players with the same sum score get the same ability
# estimate. Under the 2PL, the weighted score sum(a_i x_i) takes its place.
th_r <- fscores(m_r)[, 1]
th_2 <- fscores(m_2)[, 1]
sum_score <- rowSums(chess, na.rm = TRUE)
complete <- rowSums(is.na(chess)) == 0        # the sum score compares only on complete rows
spread <- function(th) tapply(th[complete], sum_score[complete], function(x) diff(range(x)))
round(c(max_spread_Rasch = max(spread(th_r)), max_spread_2PL = max(spread(th_2))), 2)
# The players with a sum score of 20 (complete responses only), under both models.
s20 <- complete & sum_score == 20
tab20 <- data.frame(theta_Rasch = th_r[s20], theta_2PL = th_2[s20],
                    weighted_score = as.vector(as.matrix(chess[s20, ]) %*% a_ch))
round(tab20[order(tab20$weighted_score), ], 2)

## ---- chess-identify
# The Rasch fit fixes every slope at 1 and estimates the SD of ability. A "1PL"
# with one common slope instead fixes the SD of ability at 1 and estimates the slope.
m_1 <- mirt(chess, mirt.model("F = 1-40\nCONSTRAIN = (1-40, a1)"), itemtype = "2PL", verbose = FALSE)
round(c(SD_theta_Rasch = sqrt(coef(m_r, simplify = TRUE)$cov[1, 1]),
        common_slope_1PL = coef(m_1, simplify = TRUE)$items[1, "a1"]), 3)
round(c(logLik_Rasch = extract.mirt(m_r, "logLik"), logLik_1PL = extract.mirt(m_1, "logLik")), 2)
# The difficulties agree too, once both are on one scale: the Rasch b divided by the
# SD of ability is the 1PL's b = -d/a.
b_r <- -coef(m_r, simplify = TRUE)$items[, "d"] / sqrt(coef(m_r, simplify = TRUE)$cov[1, 1])
b_1 <- -coef(m_1, simplify = TRUE)$items[, "d"] / coef(m_1, simplify = TRUE)$items[, "a1"]
round(max(abs(b_r - b_1)), 3)
