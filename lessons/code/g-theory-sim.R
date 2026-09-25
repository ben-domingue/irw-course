# Simulate a persons x tasks x raters G study with known variance components,
# estimate them with lme4, and compare. Runs in the browser in about ten seconds.
library(lme4)
set.seed(57)

np <- 150   # persons
nt <- 3     # tasks
nr <- 3     # raters

# True variance components (these add to 1, so each is also a share of the total).
truth <- c(p = 0.30, t = 0.02, r = 0.03, pt = 0.30, pr = 0.05, tr = 0.01, ptr = 0.29)

d <- expand.grid(p = factor(1:np), t = factor(1:nt), r = factor(1:nr))
eff <- function(f, v) rnorm(nlevels(f), 0, sqrt(v))[f]
d$y <- 3 +
  eff(d$p, truth["p"]) + eff(d$t, truth["t"]) + eff(d$r, truth["r"]) +
  eff(interaction(d$p, d$t), truth["pt"]) +
  eff(interaction(d$p, d$r), truth["pr"]) +
  eff(interaction(d$t, d$r), truth["tr"]) +
  rnorm(nrow(d), 0, sqrt(truth["ptr"]))

# One random intercept per facet and per interaction; the residual is p x t x r.
fit <- lmer(y ~ 1 + (1 | p) + (1 | t) + (1 | r) + (1 | p:t) + (1 | p:r) + (1 | t:r),
            data = d)
vc <- as.data.frame(VarCorr(fit))
est <- setNames(vc$vcov, c(p = "p", t = "t", r = "r", "p:t" = "pt", "p:r" = "pr",
                           "t:r" = "tr", Residual = "ptr")[vc$grp])[names(truth)]
print(round(cbind(true = truth, estimated = est), 3))

# G coefficients for a D study with n_t tasks and n_r raters.
g_coef <- function(v, n_t, n_r) {
  rel <- v["pt"] / n_t + v["pr"] / n_r + v["ptr"] / (n_t * n_r)
  abs <- rel + v["t"] / n_t + v["r"] / n_r + v["tr"] / (n_t * n_r)
  c(relative = unname(v["p"] / (v["p"] + rel)), absolute = unname(v["p"] / (v["p"] + abs)))
}
cat("\nG coefficients with", nt, "tasks and", nr, "raters\n")
print(round(rbind(true = g_coef(truth, nt, nr), estimated = g_coef(est, nt, nr)), 3))
