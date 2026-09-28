# Estimating item parameters with real data: eleven true-or-false science statements
# answered by US adults (enders_2022_science_literacy), from the Item Response
# Warehouse. Joint, conditional and marginal maximum likelihood for the Rasch model,
# then a check on the marginal model's normal prior. Runs as-is in R with the mirt
# package; no login or token. Adapted from ben-domingue/252: slides c5 and PS5#1.

## ---- fetch-sl
library(mirt)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/) with a
# CSV download. This link is pinned to one version of the data.
sl_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_6:v3_5.enders_2022_science_literacy/rows?format=csv"
df <- read.csv(sl_url)
"wave" %in% names(df)   # no wave column: one administration
wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
wide <- wide[, order(as.numeric(gsub("\\D", "", colnames(wide))))]
colnames(wide) <- paste0("S", 1:11)
c(respondents = nrow(wide), complete = sum(complete.cases(wide)))
X <- wide[complete.cases(wide), ]   # the 2,040 who answered all eleven
round(colMeans(X), 2)                # proportion coded 1, statement by statement

## ---- keying-sl
# Statements 2, 5, 7, 8 and 11 are false and the other six true (Enders et al., 2022,
# S1 file). Correlations between statements, as coded in the table, within and
# between those two groups: their mean, and how many are negative.
false_statements <- c(2, 5, 7, 8, 11)
true_statements <- setdiff(1:11, false_statements)
R <- cor(X)
block <- function(g, h) {
  v <- if (identical(g, h)) R[g, g][upper.tri(R[g, g])] else R[g, h]
  c(mean = round(mean(v), 2), negative = sum(v < 0), of = length(v))
}
rbind(true_with_true = block(true_statements, true_statements),
      false_with_false = block(false_statements, false_statements),
      true_with_false = block(true_statements, false_statements))
# So a 1 records a "true" answer, which is wrong for the five false statements.
# Recode them so that 1 = correct.
X[, false_statements] <- 1 - X[, false_statements]
item_rest <- sapply(1:11, function(i) cor(X[, i], rowSums(X[, -i])))
round(c(min = min(item_rest), max = max(item_rest)), 2)
r <- rowSums(X)
table(r)
I <- ncol(X)

## ---- mml-sl
# Marginal ML by EM: mirt fixes the mean of a normal theta distribution at 0 and
# estimates its SD. Its d is an easiness, so b = -d.
m <- mirt(as.data.frame(X), 1, itemtype = "Rasch", verbose = FALSE)
b_mml <- -coef(m, simplify = TRUE)$items[, "d"]
c(EM_cycles = extract.mirt(m, "iterations"),
  sd_theta = round(sqrt(coef(m)$GroupPars[, "COV_11"]), 2))

## ---- jml-sl
# Joint ML by hand: alternate a Newton step for every theta (items fixed) with one for
# every b (abilities fixed), with the b's summing to 0. Respondents with a perfect
# score have no finite theta and are set aside first (nobody here scores 0).
jml <- function(X, tol = 1e-8, maxit = 500) {
  X <- X[rowSums(X) > 0 & rowSums(X) < ncol(X), ]
  r <- rowSums(X); s <- colSums(X)
  b <- -qlogis(colMeans(X)); b <- b - mean(b)
  th <- qlogis(r / ncol(X))
  for (it in 1:maxit) {
    P  <- plogis(outer(th, b, "-"))
    th <- th + (r - rowSums(P)) / rowSums(P * (1 - P))
    P  <- plogis(outer(th, b, "-"))
    step <- -(s - colSums(P)) / colSums(P * (1 - P))
    b <- b + step; b <- b - mean(b)
    if (max(abs(step)) < tol) break
  }
  list(b = b, kept = nrow(X), cycles = it)
}
J <- jml(X)
c(kept = J$kept, set_aside = nrow(X) - J$kept, cycles = J$cycles)

## ---- cml-sl
# Conditional ML by hand. Given the sum score r, a pattern's probability is
# prod(eps^x) / gamma_r(eps), with eps = exp(-b) and gamma_r the elementary symmetric
# function of order r (the Rasch lesson's Go deeper callout); theta has cancelled.
esf <- function(eps) {           # gamma_0, ..., gamma_I, one item at a time
  g <- 1
  for (e in eps) g <- c(g, 0) + c(0, g * e)
  g
}
cml_negll <- function(b_free) {
  b <- c(b_free, -sum(b_free))   # difficulties sum to 0
  -(sum(X %*% (-b)) - sum(log(esf(exp(-b))[r + 1])))
}
fit <- optim(rep(0, I - 1), cml_negll, method = "BFGS",
             control = list(reltol = 1e-12, maxit = 1000))
b_cml <- c(fit$par, -sum(fit$par))

## ---- compare-sl
# Put all three on one origin (difficulties summing to 0) and compare.
b_m <- b_mml - mean(b_mml)
tab <- data.frame(proportion_correct = colMeans(X), CML = b_cml, MML = b_m, JML = J$b,
                  JML_corrected = J$b * (I - 1) / I)
round(tab, 2)
slope <- function(y, x) sum(x * y) / sum(x^2)   # through the origin
round(c(JML_on_MML = slope(J$b, b_m), JML_on_CML = slope(J$b, b_cml),
        MML_on_CML = slope(b_m, b_cml), I_over_I_minus_1 = I / (I - 1)), 3)
round(c(max_JML_minus_MML = max(abs(J$b - b_m)),
        max_corrected_JML_minus_MML = max(abs(J$b * (I - 1) / I - b_m)),
        max_CML_minus_MML = max(abs(b_cml - b_m))), 3)

## ---- eh-sl
# The price of marginal ML is a distribution for theta. Refit with the distribution
# estimated as a histogram over the quadrature nodes instead of assumed normal.
m_eh <- mirt(as.data.frame(X), 1, itemtype = "Rasch", dentype = "EH", verbose = FALSE)
b_eh <- -coef(m_eh, simplify = TRUE)$items[, "d"]
w <- extract.mirt(m_eh, "Prior")[[1]]; t <- m_eh@Model$Theta[, 1]
mu <- sum(w * t)
round(c(histogram_mean = mu, histogram_sd = sqrt(sum(w * (t - mu)^2)),
        skewness = sum(w * (t - mu)^3) / sum(w * (t - mu)^2)^1.5), 2)
# Difficulties on the same origin (summing to 0): how far does the prior move them?
round(max(abs((b_eh - mean(b_eh)) - b_m)), 3)
plot(t, w, type = "h", lwd = 3, col = "#2780e3", xlab = "Ability (quadrature node)",
     ylab = "Estimated share of respondents", xlim = c(-3, 3))
lines(t, dnorm(t, 0, sqrt(coef(m)$GroupPars[, "COV_11"])) * diff(t[1:2]), lty = 2)
