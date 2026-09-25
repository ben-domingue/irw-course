# Simulate ratings from a many-facet Rasch model with one harsh rater and one
# central rater, fit the model with TAM (Robitzsch, Kiefer & Wu), and compare the
# estimates with the truth. Then give each respondent only some of the raters and
# see what adjusting for severity buys over the raw mean.
library(TAM)
set.seed(150)
np  <- 200                          # respondents
nt  <- 3                            # tasks
per <- 2                            # raters per respondent (5 = fully crossed)
theta <- rnorm(np, 0, 1.2)          # respondents' levels, in logits
delta <- c(-0.2, 0, 0.2)            # task difficulties
sev   <- c(-0.3, -0.2, 0, -0.1, 0.6)  # rater severities: rater 5 is harsh
tau   <- c(-2.8, -0.7, 0.8, 2.7)    # steps between categories 0-1, ..., 3-4
spread <- c(1, 1, 1, 1.6, 1)        # rater 4 stretches the steps apart: central

# Rating scale model with a rater facet: the log-odds of category k over k - 1
# is theta - delta - severity - tau_k (rater 4's taus are stretched).
rate <- function(th, d, r) {
  eta <- cumsum(th - d - sev[r] - tau * spread[r])
  p <- exp(c(0, eta)); sample(0:4, 1, prob = p / sum(p))
}
rows <- do.call(rbind, lapply(1:np, function(j) {
  raters <- sort(sample(1:5, per))
  t(sapply(raters, function(r) c(id = j, rater = r, sapply(1:nt, function(i) rate(theta[j], delta[i], r)))))
}))
d <- as.data.frame(rows)
names(d)[3:(2 + nt)] <- paste0("task", 1:nt)
resp <- d[, 3:(2 + nt)]

# Many-facet Rasch model: task + rater + common steps. TAM reports severities that
# sum to zero, so compare them with the centred truth.
# (TAM warns about row names when it builds the design matrices; the warnings are harmless.)
fit <- suppressWarnings(tam.mml.mfr(resp, facets = d["rater"], pid = d$id,
                                    formulaA = ~ item + rater + step, verbose = FALSE))
est <- fit$xsi.facets
round(cbind(true = sev - mean(sev), estimate = est$xsi[est$facet == "rater"],
            se = est$se.xsi[est$facet == "rater"]), 2)

# Rater-specific steps: a central rater's outer steps sit further out.
fit2 <- suppressWarnings(tam.mml.mfr(resp, facets = d["rater"], pid = d$id,
                                     formulaA = ~ item + rater + step + rater:step, verbose = FALSE))
x2 <- fit2$xsi.facets
dev <- x2[x2$facet == "step:rater", ]
step_of <- as.integer(sub("step(\\d):.*", "\\1", dev$parameter))
rater_of <- sub(".*:rater", "", dev$parameter)
common <- setNames(x2$xsi[x2$facet == "step"], 1:4)
# Distance from each rater's first step to their last: wider = more central.
span <- tapply(dev$xsi[step_of == 4], rater_of[step_of == 4], sum) -
        tapply(dev$xsi[step_of == 1], rater_of[step_of == 1], sum) + common[4] - common[1]
round(span, 2)
round(c(common_steps_AIC = fit$ic$AIC, rater_steps_AIC = fit2$ic$AIC))

# Scores: the raw mean of each respondent's ratings against the model's estimate
# (weighted likelihood), each correlated with the true theta.
wle <- tam.wle(fit, progress = FALSE)
raw <- tapply(rowMeans(resp), d$id, mean)
drew_harsh <- tapply(d$rater == 5, d$id, any)
round(c(raw = cor(raw, theta), model = cor(wle$theta, theta)), 3)
# How far respondents who drew the harsh rater sit below others with the same true
# theta, in SDs of each score (raw means are in rating points, estimates in logits):
gap <- function(s) mean(resid(lm(s ~ theta))[drew_harsh]) / sd(s)
round(c(raw = gap(raw), model = gap(wle$theta)), 2)
