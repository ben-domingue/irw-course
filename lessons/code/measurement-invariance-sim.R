# Simulate two groups answering six items that measure one factor, with one item
# that works differently in group B. Climb the invariance ladder with lavaan, find
# the item, and compare group B's estimated factor mean with the truth, with and
# without partial invariance. Needs the lavaan package.
library(lavaan)
set.seed(58)
n     <- 500                              # respondents per group (try 150, or 3000 locally)
lam   <- c(0.8, 0.7, 0.7, 0.6, 0.6, 0.5)  # loadings, the same in both groups
kappa <- 0.3                              # group B's factor mean (group A: 0), in SDs
shift <- 0.4                              # item 6's intercept in group B minus group A

# Responses x = intercept + loading * factor + error, with var(x) = 1 in group A.
sim <- function(n, mu, nu) {
  eta <- rnorm(n, mu)
  sapply(1:6, function(i) nu[i] + lam[i] * eta + sqrt(1 - lam[i]^2) * rnorm(n))
}
d <- as.data.frame(rbind(sim(n, 0, rep(0, 6)), sim(n, kappa, c(0, 0, 0, 0, 0, shift))))
names(d) <- paste0("x", 1:6)
d$group <- rep(c("A", "B"), each = n)

# The ladder: configural, metric (equal loadings), scalar (equal intercepts too).
model <- "F =~ x1 + x2 + x3 + x4 + x5 + x6"
cfg <- cfa(model, data = d, group = "group")
met <- cfa(model, data = d, group = "group", group.equal = "loadings")
sca <- cfa(model, data = d, group = "group", group.equal = c("loadings", "intercepts"))
print(lavTestLRT(cfg, met, sca))

# Which equality constraint strains most in the scalar model?
st <- lavTestScore(sca)$uni
pt <- parTable(sca)
st$constraint <- sapply(st$lhs, function(l) with(pt[pt$plabel == l, ], paste(lhs, op, rhs)))
print(head(st[order(-st$X2), c("constraint", "X2", "p.value")], 3))

# Partial invariance: free item 6's intercept. Group B's factor mean, in units of
# group A's factor SD, with and without it, against the truth.
par <- cfa(model, data = d, group = "group", group.equal = c("loadings", "intercepts"),
           group.partial = "x6 ~ 1")
mean_B <- function(fit) {
  pe <- parameterEstimates(fit)
  pe$est[pe$lhs == "F" & pe$op == "~1" & pe$group == 2] / sqrt(lavInspect(fit, "est")[[1]]$psi[1, 1])
}
print(round(c(truth = kappa, full_scalar = mean_B(sca), partial = mean_B(par)), 3))
