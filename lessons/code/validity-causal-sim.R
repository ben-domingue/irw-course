# A cause without an individual attribute. Every simulated respondent is slowed by
# conflict (the Stroop manipulation), by mu seconds on average; respondents differ in
# that slowing with SD tau, and in their overall speed with SD 0.45 s. Each respondent
# does the task twice, with `trials` trials per condition each time, and every trial
# adds noise with SD sigma. For several values of tau and trials we ask two questions:
# is the group effect clear (t at session 1), and does each respondent's effect at
# session 1 predict their effect at session 2 (the retest correlation)? Base R only.
# New for this course.
set.seed(34)
n     <- 250    # respondents
mu    <- 0.11   # average conflict effect (s)
sigma <- 0.8    # trial-to-trial SD of RT (s), about what the IRW Stroop table shows

one_run <- function(tau, trials) {
  speed  <- rnorm(n, 1.6, 0.45)           # each respondent's congruent RT
  effect <- rnorm(n, mu, tau)             # each respondent's true conflict effect
  session <- function() {
    cong   <- speed + rnorm(n, 0, sigma / sqrt(trials))           # mean of `trials` trials
    incong <- speed + effect + rnorm(n, 0, sigma / sqrt(trials))
    data.frame(cong = cong, eff = incong - cong)
  }
  s1 <- session(); s2 <- session()
  c(tau = tau, trials = trials,
    t_session1   = mean(s1$eff) / (sd(s1$eff) / sqrt(n)),
    share_pos    = mean(s1$eff > 0),
    r_effect     = cor(s1$eff, s2$eff),
    r_congruent  = cor(s1$cong, s2$cong),
    reliability  = tau^2 / (tau^2 + 2 * sigma^2 / trials))   # what r_effect estimates
}

grid <- expand.grid(tau = c(0, 0.1, 0.2), trials = c(25, 240))
res <- t(mapply(one_run, grid$tau, grid$trials))
round(res, 2)
