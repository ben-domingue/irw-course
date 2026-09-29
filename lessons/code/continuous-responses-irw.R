# Continuous responses with real data: five impulsivity items marked on a 112 mm line
# (estcrm_epia; Ferrando, 2002) and six climate-risk items rated on a 0-100 slider
# (karlsson_2023_climate_risk; Karlsson, Asutay & Vastfjall, 2023), from the Item
# Response Warehouse. Needs mirt; the optional checks use EstCRM and glmmTMB. No login
# or token needed. Every chunk runs in seconds except the ordered beta fit (about
# 30 seconds).

## ---- fetch-epia
library(mirt)
set.seed(252)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/) with a
# CSV download. This link is pinned to one version of the data.
epia_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v64_0.estcrm_epia/rows?format=csv"
df <- read.csv(epia_url)
X <- as.matrix(unstack(df[order(df$id), ], resp ~ item))   # 1,033 x 5, rows = respondents
colnames(X) <- paste0("item", 1:5)
M <- 112          # the line is 112 mm; marks are scored 1-111 mm
c(respondents = nrow(X), min = min(X), max = max(X))
c(at_1 = mean(X == 1), at_111 = mean(X == 111))           # marks at the ends
# Heaping: evenly spread marks would put 1 in 5 on a multiple of 5, 1 in 10 on 10.
c(mult5 = mean(X %% 5 == 0), mult10 = mean(X %% 10 == 0))
round(cor(X), 2)
kurt <- function(v) mean((v - mean(v))^4) / mean((v - mean(v))^2)^2   # normal: 3
round(apply(X, 2, kurt), 1)

## ---- fit-epia
# The linear model: a one-factor model fitted by ML to the raw marks.
# Samejima's model: the same model fitted to the logits z = log(x / (M - x)).
Z <- log(X / (M - X))
f_lin <- factanal(X, 1, scores = "regression")
f_crm <- factanal(Z, 1, scores = "regression")
l_lin <- f_lin$loadings[, 1]; l_crm <- f_crm$loadings[, 1]
round(rbind(linear = l_lin, samejima = l_crm), 2)          # standardized loadings
# Item information about theta (variance 1) is lambda^2 / psi, psi = 1 - lambda^2;
# test information is the sum, the same at every theta.
info <- function(l) sum(l^2 / (1 - l^2))
I_lin <- info(l_lin); I_crm <- info(l_crm)
c(info_linear = I_lin, info_samejima = I_crm)
c(reliability_linear = I_lin / (1 + I_lin), reliability_samejima = I_crm / (1 + I_crm))
cor(f_lin$scores[, 1], f_crm$scores[, 1])                   # the two sets of scores

## ---- estcrm-epia
# Check: EstCRM fits Samejima's model by EM (Wang & Zeng, 1998; Zopluoglu, 2012).
# Its a is the logit slope over the residual SD, which is l / sqrt(1 - l^2) in
# standardized terms; its b is -(mean logit) / (logit slope).
if (requireNamespace("EstCRM", quietly = TRUE)) {
  crm <- EstCRM::EstCRMitem(as.data.frame(X), max.item = rep(M, 5), min.item = rep(0, 5),
                            max.EMCycle = 500, converge = 0.001)
  slope <- l_crm * apply(Z, 2, sd)
  print(round(cbind(EstCRM_a = crm$param[, "a"], factanal_a = l_crm / sqrt(1 - l_crm^2),
                    EstCRM_b = crm$param[, "b"], factanal_b = -colMeans(Z) / slope), 2))
}

## ---- bins-epia
# Cut each line into K equal-width bins and fit the graded response model.
cut_line <- function(X, K, M) apply(X, 2, function(v)
  cut(v, breaks = seq(0, M, length.out = K + 1), labels = FALSE, include.lowest = TRUE) - 1)
bins <- t(sapply(c(2, 3, 5, 7, 21), function(K) {
  g <- mirt(as.data.frame(cut_line(X, K, M)), 1, itemtype = "graded", verbose = FALSE)
  c(K = K, marginal_rel = marginal_rxx(g),
    info = setNames(testinfo(g, Theta = matrix(c(-2, 0, 2))), c("at_-2", "at_0", "at_2")))
}))
round(bins, 2)

## ---- simcheck-epia
# Does the graded model inflate information by itself? Simulate responses from the
# fitted linear model (true test information I_lin), put them on a line, cut into
# 21 bins as above, and fit the graded model.
set.seed(252)
th <- rnorm(nrow(X))
S <- sapply(l_lin, function(l) l * th + rnorm(nrow(X), 0, sqrt(1 - l^2)))
S <- apply(S, 2, function(v) (v - min(v)) / (max(v) - min(v)) * M)
g_sim <- mirt(as.data.frame(cut_line(S, 21, M)), 1, itemtype = "graded", verbose = FALSE)
c(true_info = I_lin, graded_info_at_0 = testinfo(g_sim, Theta = matrix(0)))

## ---- halves-epia
# A check that doesn't trust either model: split the five items into two halves (a
# pair and a triple; 10 ways) and correlate the halves' sums. More information in
# the items means halves that agree more. Compare the observed agreement with what
# each fitted model implies.
splits <- combn(5, 2, simplify = FALSE)
halves <- function(Y) mean(sapply(splits, function(A) {
  B <- setdiff(1:5, A); cor(rowSums(scale(Y[, A])), rowSums(scale(Y[, B])))
}))
R_lin <- tcrossprod(l_lin); diag(R_lin) <- 1           # correlations the linear model implies
implied_lin <- mean(sapply(splits, function(A) {
  B <- setdiff(1:5, A); sum(R_lin[A, B]) / sqrt(sum(R_lin[A, A]) * sum(R_lin[B, B]))
}))
set.seed(252)
g21 <- mirt(as.data.frame(cut_line(X, 21, M)), 1, itemtype = "graded", verbose = FALSE)
implied_grm <- halves(simdata(model = g21, N = 20000))  # a large sample from the fitted GRM
round(c(observed_lines = halves(X), observed_21_bins = halves(cut_line(X, 21, M)),
        linear_implies = implied_lin, graded_21_implies = implied_grm), 2)

## ---- fetch-karl
# Wave 1 only: the ratings before the imagery manipulation (wave 2 is after it).
karl_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_6:v3_8.karlsson_2023_climate_risk/rows?format=csv"
dk <- read.csv(karl_url)
dk1 <- subset(dk, wave == 1)
W <- as.matrix(unstack(dk1[order(dk1$id), ], resp ~ item))  # 1,001 x 6, 0-100
W <- W[, sort(colnames(W))]
c(respondents = nrow(W), complete = sum(complete.cases(W)))
round(rbind(at_0 = colMeans(W == 0), at_100 = colMeans(W == 100)), 2)
c(at_0 = mean(W == 0), at_100 = mean(W == 100), all_six_at_100 = mean(rowSums(W == 100) == 6))
c(mult5 = mean(W %% 5 == 0), mult10 = mean(W %% 10 == 0))
round(cor(W), 2)

## ---- squeeze-karl
# Samejima's model needs finite logits, so the ends are pulled in by a squeeze
# constant nu (in scale points) before taking logits. The choice moves the fit.
info_W <- function(Y) info(factanal(Y, 1)$loadings[, 1])
sq <- sapply(c(0.5, 0.05, 0.005), function(nu) info_W(log((W + nu) / (100 - W + nu))))
round(c(linear = info_W(W), samejima = setNames(sq, paste0("nu=", c(0.5, 0.05, 0.005)))), 1)

## ---- beta-karl
# Beta and ordered beta regressions with item fixed effects and a random intercept
# per respondent (a Rasch-like model for a bounded response), fitted with glmmTMB
# (Brooks et al., 2017). The beta needs the ends squeezed in (Smithson & Verkuilen,
# 2006); the ordered beta (Kubinec, 2023) gives 0 and 1 their own probabilities.
if (requireNamespace("glmmTMB", quietly = TRUE)) {
  long <- data.frame(id = factor(rep(seq_len(nrow(W)), 6)), item = factor(rep(colnames(W), each = nrow(W))),
                     y = as.vector(W) / 100)
  n <- nrow(long)
  long$y_sq <- (long$y * (n - 1) + 0.5) / n
  m_beta <- glmmTMB::glmmTMB(y_sq ~ 0 + item + (1 | id), family = glmmTMB::beta_family(), data = long)
  m_ob <- glmmTMB::glmmTMB(y ~ 0 + item + (1 | id), family = glmmTMB::ordbeta(), data = long)
  set.seed(252)
  sim_beta <- unlist(simulate(m_beta, nsim = 20)); sim_ob <- unlist(simulate(m_ob, nsim = 20))
  print(round(rbind(observed = c(at_0 = mean(long$y == 0), at_1 = mean(long$y == 1)),
                    beta = c(mean(sim_beta < 0.005), mean(sim_beta > 0.995)),
                    ordered_beta = c(mean(sim_ob == 0), mean(sim_ob == 1))), 3))
}

## ---- bins-karl
binsK <- t(sapply(c(2, 3, 5, 7, 21), function(K) {
  g <- mirt(as.data.frame(cut_line(W, K, 100)), 1, itemtype = "graded", verbose = FALSE)
  c(K = K, marginal_rel = marginal_rxx(g),
    info = setNames(testinfo(g, Theta = matrix(c(-2, 0, 2))), c("at_-2", "at_0", "at_2")))
}))
round(binsK, 2)
