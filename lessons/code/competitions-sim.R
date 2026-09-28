# Bradley-Terry and Elo, simulated. Part 1: 30 agents with fixed strengths play a
# lopsided schedule; we fit Bradley-Terry with glm() and compare the estimates, and
# win percentage, with the truth. Part 2: the strengths drift over time; we run Elo at several step
# sizes K and ask which K predicts the next game best. Base R only; a few seconds.
# New for this course. The irw package's irw_simdata_comp() simulates part 1 too.
set.seed(86)
n_agents <- 30
n_games  <- 1200       # try 300, then 5000
h        <- 0.4        # home advantage, in logits

# ---- Part 1: fixed strengths ----
theta <- rnorm(n_agents, 0, 0.8)
theta <- theta - mean(theta)          # the model only sees differences; centre the truth
# A lopsided schedule: three divisions of 10, formed by strength, and a share
# `within` of each agent's games is against its own division.
within <- 0.8          # try 0.1 (close to a random schedule)
division <- ceiling(rank(theta) / 10)
home <- sample(n_agents, n_games, replace = TRUE)
away <- sapply(home, function(j) {
  pool <- if (runif(1) < within) which(division == division[j]) else which(division != division[j])
  sample(setdiff(pool, j), 1)
})
y <- rbinom(n_games, 1, plogis(h + theta[home] - theta[away]))

X <- matrix(0, n_games, n_agents)
X[cbind(seq_len(n_games), home)] <- 1
X[cbind(seq_len(n_games), away)] <- -1
m <- glm(y ~ X[, -1], family = binomial)     # agent 1 fixed at 0, then re-centred
est <- c(0, coef(m)[-1])
est <- est - mean(est)
round(c(home_advantage = unname(coef(m)[1]), correlation = cor(est, theta),
        rmse = sqrt(mean((est - theta)^2))), 3)
plot(theta, est, xlab = "True strength", ylab = "Bradley-Terry estimate", pch = 19)
abline(0, 1, lty = 2)

# Win percentage ignores who you played. How closely does it track the truth?
wins  <- tabulate(home[y == 1], n_agents) + tabulate(away[y == 0], n_agents)
games <- tabulate(home, n_agents) + tabulate(away, n_agents)
round(c(cor_winpct_truth = cor(wins / games, theta), cor_bt_truth = cor(est, theta)), 3)

# ---- Part 2: drifting strengths and Elo ----
# Each agent's strength takes a small random step after every round of games
# (drift_sd per round). Elo predicts each game before it is played, so its log
# likelihood is out of sample by construction.
drift_sd <- 0.05       # try 0, then 0.15
rounds <- 100
theta_t <- matrix(0, rounds, n_agents)
theta_t[1, ] <- rnorm(n_agents, 0, 0.8)
for (t in 2:rounds) theta_t[t, ] <- theta_t[t - 1, ] + rnorm(n_agents, 0, drift_sd)
games <- do.call(rbind, lapply(seq_len(rounds), function(t) {
  pairs <- matrix(sample(n_agents), ncol = 2)        # everyone plays once per round
  data.frame(round = t, a = pairs[, 1], b = pairs[, 2])
}))
games$y <- rbinom(nrow(games), 1,
                  plogis(h + theta_t[cbind(games$round, games$a)] - theta_t[cbind(games$round, games$b)]))

elo <- function(K) {
  r <- rep(0, n_agents)
  ll <- numeric(nrow(games))
  for (g in seq_len(nrow(games))) {
    a <- games$a[g]; b <- games$b[g]
    p <- plogis(h + r[a] - r[b])
    ll[g] <- games$y[g] * log(p) + (1 - games$y[g]) * log(1 - p)
    r[a] <- r[a] + K * (games$y[g] - p)
    r[b] <- r[b] - K * (games$y[g] - p)
  }
  mean(ll[games$round > 20])                         # skip a burn-in
}
Ks <- c(0.01, 0.03, 0.05, 0.1, 0.2, 0.4, 0.8)
round(setNames(sapply(Ks, elo), Ks), 4)              # mean log likelihood per game
