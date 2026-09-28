# Bradley-Terry and Elo with real data: nba_2012-2018, friedman2019_risk_harm and
# friedman2019_risk_disaster from the Item Response Warehouse (competition tables,
# irw_competitions v3.2). Runs as-is in base R; no packages, login or token needed.
# New for this course.

## ---- fetch-nba
# Competition tables have no items. Each row is one game: agent_a, agent_b, the
# winner ("agent_a", "agent_b" or "draw"), the date (seconds since 1970) and the
# scores. In this table agent_a is always the home team (hometeam == "agent_a").
nba_url <- "https://redivis.com/api/v1/tables/datapages.irw_competitions:v3_2.nba_2012-2018/rows?format=csv"
nba <- read.csv(nba_url)
head(nba)
nrow(nba)

## ---- dedupe
# The 2016-17 and 2017-18 seasons appear twice (the source files overlap), so we
# keep one copy of each game. A season runs from October to April.
nba <- nba[!duplicated(nba), ]
nba$day <- as.Date(as.POSIXct(nba$date, origin = "1970-01-01", tz = "UTC"))
nba$season <- as.integer(format(nba$day, "%Y")) - (as.integer(format(nba$day, "%m")) < 8)
nba <- nba[order(nba$date), ]
nba$y <- as.integer(nba$winner == "agent_a")     # 1 if the home team won; no draws
table(season = nba$season)
teams <- sort(unique(c(nba$agent_a, nba$agent_b)))
c(games = nrow(nba), teams = length(teams), home_win_rate = round(mean(nba$y), 3))

## ---- bt-nba
# Bradley-Terry as a logistic regression: one row per game, a column per team,
# +1 for the home team, -1 for the visitors. The intercept is the home advantage h.
# Only differences are identified, so we drop the first team's column (its strength
# is fixed at 0) and then re-centre the strengths to mean 0.
design <- function(d) {
  X <- matrix(0, nrow(d), length(teams), dimnames = list(NULL, teams))
  X[cbind(seq_len(nrow(d)), match(d$agent_a, teams))] <- 1
  X[cbind(seq_len(nrow(d)), match(d$agent_b, teams))] <- -1
  X
}
fit_bt <- function(d) {
  X <- design(d)
  m <- glm(d$y ~ X[, -1], family = binomial)
  theta <- c(0, coef(m)[-1])
  names(theta) <- teams
  list(h = unname(coef(m)[1]), theta = theta - mean(theta), model = m)
}
bt_all <- fit_bt(nba)
round(c(home_advantage = bt_all$h, se = summary(bt_all$model)$coefficients[1, 2]), 3)
round(sort(bt_all$theta, decreasing = TRUE)[1:5], 2)

## ---- winpct
# Win percentage against the Bradley-Terry strength, over all six seasons.
win_pct <- sapply(teams, function(t) mean(c(nba$y[nba$agent_a == t], 1 - nba$y[nba$agent_b == t])))
round(c(correlation = cor(win_pct, bt_all$theta),
        rank_correlation = cor(win_pct, bt_all$theta, method = "spearman")), 4)
# At the maximum, each team's expected wins equal its actual wins:
p_hat <- fitted(bt_all$model)
exp_wins <- sapply(teams, function(t) sum(p_hat[nba$agent_a == t]) + sum(1 - p_hat[nba$agent_b == t]))
act_wins <- sapply(teams, function(t) sum(nba$y[nba$agent_a == t]) + sum(1 - nba$y[nba$agent_b == t]))
round(head(cbind(actual = act_wins, expected = exp_wins)), 2)

## ---- seasons
# One Bradley-Terry fit per season: who is strongest, and how far apart are teams?
by_season <- t(sapply(sort(unique(nba$season)), function(s) {
  b <- fit_bt(nba[nba$season == s, ])
  c(season = s, home_adv = round(b$h, 2), sd_theta = round(sd(b$theta), 2),
    top_theta = round(max(b$theta), 2))
}))
data.frame(by_season, top_team = sapply(sort(unique(nba$season)), function(s)
  names(which.max(fit_bt(nba[nba$season == s, ])$theta))))

## ---- predict
# Fit on 2012-13 to 2016-17, predict every game of 2017-18. The score is the mean
# log likelihood per game (closer to 0 is better; always guessing 0.5 gives -0.693).
train <- nba[nba$season < 2017, ]
test  <- nba[nba$season == 2017, ]
mean_ll <- function(p, y) mean(y * log(p) + (1 - y) * log(1 - p))
bt5 <- fit_bt(train)                                  # all five seasons pooled
bt1 <- fit_bt(nba[nba$season == 2016, ])              # the last season only
p_const <- rep(mean(train$y), nrow(test))             # home advantage, nothing else
p_bt5 <- plogis(bt5$h + design(test) %*% bt5$theta)
p_bt1 <- plogis(bt1$h + design(test) %*% bt1$theta)

# Elo on the logit scale: before each game, predict from the current ratings; after
# it, move both ratings by K times the surprise. Ratings start at 0 and carry over
# from season to season. The home advantage is the five-season estimate.
elo <- function(d, K, h) {
  r <- setNames(rep(0, length(teams)), teams)
  p <- numeric(nrow(d))
  for (g in seq_len(nrow(d))) {
    a <- d$agent_a[g]; b <- d$agent_b[g]
    p[g] <- plogis(h + r[a] - r[b])
    r[a] <- r[a] + K * (d$y[g] - p[g])
    r[b] <- r[b] - K * (d$y[g] - p[g])
  }
  list(p = p, ratings = r)
}
# Choose K on the training seasons only. Elo's predictions are made before each
# game, so they are already out of sample; 2012-13 is a burn-in.
Ks <- c(0.01, 0.02, 0.05, 0.075, 0.1, 0.15, 0.2, 0.3, 0.5)
tune <- sapply(Ks, function(K) {
  e <- elo(train, K, bt5$h)
  mean_ll(e$p[train$season > 2012], train$y[train$season > 2012])
})
round(setNames(tune, Ks), 4)
K <- Ks[which.max(tune)]
p_elo <- elo(nba, K, bt5$h)$p[nba$season == 2017]

scores <- c(constant = mean_ll(p_const, test$y), bt_five_seasons = mean_ll(p_bt5, test$y),
            bt_last_season = mean_ll(p_bt1, test$y), elo = mean_ll(p_elo, test$y))
round(scores, 3)
# Is Elo's edge over the pooled fit more than noise? A paired standard error over games.
d_ll <- (test$y * log(p_elo) + (1 - test$y) * log(1 - p_elo)) -
        (test$y * log(p_bt5) + (1 - test$y) * log(1 - p_bt5))
round(c(K = K, difference = mean(d_ll), se = sd(d_ll) / sqrt(length(d_ll))), 3)
# How much did the teams change? Strengths from the pooled fit against 2017-18 alone.
round(cor(bt5$theta, fit_bt(test)$theta), 2)

## ---- fetch-friedman
# 100 public risks. Each rater saw pairs and picked one: for harm, the risk that
# caused more harm in the past year; for disaster, the one with more potential for
# disaster (Friedman, 2019, codebook). agent_a is always the risk the rater picked.
harm_url <- "https://redivis.com/api/v1/tables/datapages.irw_competitions:v3_2.friedman2019_risk_harm/rows?format=csv"
dis_url  <- "https://redivis.com/api/v1/tables/datapages.irw_competitions:v3_2.friedman2019_risk_disaster/rows?format=csv"
harm <- read.csv(harm_url)
disaster <- read.csv(dis_url)
head(harm, 3)
c(judgments = nrow(harm), raters = length(unique(harm$rater)),
  risks = length(unique(c(harm$agent_a, harm$agent_b))), picked_a = mean(harm$winner == "agent_a"),
  median_per_rater = median(table(harm$rater)))

## ---- bt-harm
# The table records the chosen risk as agent_a, so we can't estimate an order
# effect. We flip a coin for which risk is written first, so that the outcome
# varies; with no intercept the fit is the same either way.
fit_judgments <- function(d, seed = 1) {
  risks <- sort(unique(c(d$agent_a, d$agent_b)))
  set.seed(seed)
  flip <- rbinom(nrow(d), 1, 0.5) == 1
  first <- ifelse(flip, d$agent_b, d$agent_a)
  second <- ifelse(flip, d$agent_a, d$agent_b)
  y <- as.integer(!flip)                              # 1 if the first risk was picked
  X <- matrix(0, nrow(d), length(risks), dimnames = list(NULL, risks))
  X[cbind(seq_len(nrow(d)), match(first, risks))] <- 1
  X[cbind(seq_len(nrow(d)), match(second, risks))] <- -1
  m <- glm(y ~ 0 + X[, -1], family = binomial)
  theta <- c(0, coef(m))
  names(theta) <- risks
  theta - mean(theta)
}
harm_theta <- fit_judgments(harm)
round(sort(harm_theta, decreasing = TRUE)[1:6], 2)
round(sort(harm_theta)[1:6], 2)

## ---- split-half
# Split the raters at random into two halves and fit each half separately.
set.seed(2)
raters <- unique(harm$rater)
half <- sample(raters, length(raters) / 2)
th1 <- fit_judgments(harm[harm$rater %in% half, ])
th2 <- fit_judgments(harm[!harm$rater %in% half, ])
round(cor(th1, th2), 2)

## ---- disaster
# The same 100 risks, judged for their potential for disaster.
dis_theta <- fit_judgments(disaster)
round(cor(harm_theta, dis_theta), 2)
shift <- dis_theta - harm_theta
round(sort(shift, decreasing = TRUE)[1:5], 2)   # rise most on disaster
round(sort(shift)[1:5], 2)                      # fall most
