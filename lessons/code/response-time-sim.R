# Simulate responses and response times from the hierarchical model: a Rasch model
# for accuracy, the lognormal model for time, correlated person parameters (theta,
# speed) and correlated item parameters (difficulty, time intensity). Then fit the
# two halves with lme4 and ask what the data say about speed and accuracy.
#
# delta is a within-person speed-accuracy tradeoff: the change in the log odds of a
# correct response when a response takes one unit of log time longer than expected.
# The hierarchical model has delta = 0 (conditional independence).
#
# nAGQ = 0 makes glmer() skip its slowest step, so the fits take seconds in the
# browser. In your own R session, delete ", nAGQ = 0" and raise np and ni.
library(lme4)
set.seed(53)
np <- 200      # respondents
ni <- 20       # items
rho <- 0.4     # correlation of theta and speed across respondents
delta <- 0     # within-person effect of taking longer than expected (log odds)

# Person parameters: theta (SD 1) and speed tau (SD 0.3), correlated rho.
z1 <- rnorm(np); z2 <- rnorm(np)
theta <- z1
tau <- 0.3 * (rho * z1 + sqrt(1 - rho^2) * z2)
# Item parameters: difficulty b and time intensity beta (log seconds), correlated 0.5.
w1 <- rnorm(ni); w2 <- rnorm(ni)
b <- w1
beta <- log(30) + 0.3 * (0.5 * w1 + sqrt(1 - 0.5^2) * w2)

d <- expand.grid(id = factor(1:np), item = factor(1:ni))
e <- rnorm(nrow(d), 0, 0.5)                          # residual log time
d$lrt <- beta[d$item] - tau[d$id] + e
d$resp <- rbinom(nrow(d), 1, plogis(theta[d$id] - b[d$item] + delta * e))

m_time <- lmer(lrt ~ 1 + (1 | id) + (1 | item), d)
m_acc <- glmer(resp ~ 1 + (1 | id) + (1 | item), d, binomial, nAGQ = 0)
tau_hat <- -ranef(m_time)$id[, 1]
theta_hat <- ranef(m_acc)$id[, 1]
cat(sprintf("Correlation of theta and speed: true %.2f, estimates %.2f\n",
            rho, cor(theta_hat, tau_hat)))
cat(sprintf("Correlation of b and time intensity: in these items %.2f, estimates %.2f\n",
            cor(b, beta), cor(-ranef(m_acc)$item[, 1], ranef(m_time)$item[, 1])))

# Pooled: accuracy on raw log time, ignoring who and what.
pooled <- glm(resp ~ lrt, binomial, d)
# Within: accuracy on residual log time, with person and item effects.
d$res <- residuals(m_time)
within <- glmer(resp ~ res + (1 | id) + (1 | item), d, binomial, nAGQ = 0)
cat(sprintf("Pooled slope on log time: %.2f\n", coef(pooled)["lrt"]))
cat(sprintf("Within-person slope on residual log time: %.2f (SE %.2f); true delta %.2f\n",
            fixef(within)["res"], sqrt(vcov(within)[2, 2]), delta))
d$decile <- cut(d$res, quantile(d$res, 0:10 / 10), include.lowest = TRUE, labels = FALSE)
cat("Proportion correct by decile of residual log time:\n")
print(round(tapply(d$resp, d$decile, mean), 2))
