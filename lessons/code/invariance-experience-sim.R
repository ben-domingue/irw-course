# Simulate a randomized trial whose outcome items respond unequally to treatment
# (item-level heterogeneous treatment effects, IL-HTE), then fit a sum-score model,
# a constant-effect item response model and the IL-HTE model with lme4, and compare
# each with the truth. There is no person-level heterogeneity: the treatment raises
# every respondent's theta by the same amount. Runs in the browser in well under a minute.
library(lme4)
set.seed(3)

n <- 800            # respondents, half treated
I <- 20             # items
beta1 <- 0.5        # average treatment effect on theta (theta has SD 1 within arm)
sigma_zeta <- 0.8   # SD of the item-specific departures zeta_i from beta1
rho <- -0.8         # correlation of item difficulty b_i with zeta_i (negative: easier items move more)

# Respondents: a standardized pretest, and theta built from it plus noise. The
# treatment adds beta1 to everyone, whatever their pretest.
treat <- rep(0:1, each = n / 2)
pre <- rnorm(n)
theta <- 0.7 * pre + sqrt(1 - 0.7^2) * rnorm(n) + beta1 * treat

# Items: difficulties b_i spread evenly (normal quantiles, SD about 1) and departures
# zeta_i with SD sigma_zeta and correlation rho with b_i. Building them exactly (rather
# than drawing them) keeps the item sample from adding its own noise: the zeta_i
# average exactly 0, so beta1 is the effect on these items too.
b <- qnorm((1:I - 0.5) / I)
z1 <- (b - mean(b)) / sd(b)
w <- resid(lm(rnorm(I) ~ z1)); w <- w / sd(w)
zeta <- sigma_zeta * (rho * z1 + sqrt(1 - rho^2) * w)

# Responses: logit P(x_ij = 1) = theta_j - b_i + zeta_i T_j.
d <- expand.grid(id = 1:n, item = 1:I)
d$treat <- treat[d$id]
d$pre <- pre[d$id]
d$resp <- rbinom(nrow(d), 1, plogis(theta[d$id] - b[d$item] + zeta[d$item] * d$treat))

# 1. The sum score, standardized, regressed on treatment, pretest and their product.
s <- tapply(d$resp, d$id, sum)
m_sum <- lm(scale(s) ~ treat * pre)

# 2. A constant effect for every item (the Rasch model as a mixed model).
# nAGQ = 0 uses a faster, slightly rougher approximation to the likelihood, which
# keeps the browser run to seconds; drop it locally for the default Laplace fit.
m_const <- glmer(resp ~ treat * pre + (1 | id) + (1 | item), d, family = binomial, nAGQ = 0)

# 3. The IL-HTE model: each item gets its own treatment effect. lme4's item intercept
#    is an easiness (-b_i), so the correlation it reports is -rho.
m_ilhte <- glmer(resp ~ treat * pre + (1 | id) + (treat | item), d, family = binomial, nAGQ = 0)
vc <- VarCorr(m_ilhte)$item

round(rbind(
  truth           = c(effect = beta1, sigma_zeta = sigma_zeta, rho = rho, interaction = 0),
  sum_score       = c(coef(m_sum)["treat"], NA, NA, coef(m_sum)["treat:pre"]),
  constant_effect = c(fixef(m_const)["treat"], NA, NA, fixef(m_const)["treat:pre"]),
  ilhte           = c(fixef(m_ilhte)["treat"], sqrt(vc[2, 2]), -attr(vc, "correlation")[1, 2],
                      fixef(m_ilhte)["treat:pre"])), 2)
# (The sum-score row is in SDs of the sum score, the others in logits.)

# Standard errors of the interaction: the constant-effect model against IL-HTE.
round(c(constant_effect = summary(m_const)$coef["treat:pre", 2],
        ilhte = summary(m_ilhte)$coef["treat:pre", 2]), 3)

# How well does the IL-HTE model recover each item's effect?
est <- fixef(m_ilhte)["treat"] + ranef(m_ilhte)$item[, "treat"]
round(c(correlation_with_truth = cor(est, beta1 + zeta)), 2)
