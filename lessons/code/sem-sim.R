# Simulate a latent predictor X and a latent outcome Y with a known standardized
# path, each measured by five items with error. Compare the regression on sum
# scores with the SEM estimate of the path, at three levels of item quality.
# Needs the lavaan package.
library(lavaan)
set.seed(64)
np    <- 500                  # respondents (try 200, or 5000 locally)
beta  <- 0.5                  # true standardized path from X to Y
loads <- c(0.4, 0.6, 0.8)     # one loading for every item, per scenario
k     <- 5                    # items per factor

model <- "X =~ x1 + x2 + x3 + x4 + x5
          Y =~ y1 + y2 + y3 + y4 + y5
          Y ~ X"
rows <- lapply(loads, function(l) {
  X <- rnorm(np)
  Y <- beta * X + sqrt(1 - beta^2) * rnorm(np)
  items <- function(eta, name) {
    m <- sapply(1:k, function(i) l * eta + sqrt(1 - l^2) * rnorm(np))
    colnames(m) <- paste0(name, 1:k); m
  }
  dat <- as.data.frame(cbind(items(X, "x"), items(Y, "y")))
  sx <- rowSums(dat[1:k]); sy <- rowSums(dat[k + 1:k])
  fit <- sem(model, data = dat, std.lv = TRUE)
  ss <- standardizedSolution(fit)
  # Reliability of a sum of k items with equal loadings l (omega = alpha here).
  rel <- (k * l)^2 / ((k * l)^2 + k * (1 - l^2))
  data.frame(loading = l, reliability = round(rel, 2), true_path = beta,
             sum_score_slope = round(cor(sx, sy), 2),       # standardized slope = correlation
             predicted_by_spearman = round(beta * rel, 2),  # beta * sqrt(rel_x * rel_y)
             sem_path = round(ss$est.std[ss$op == "~"], 2))
})
print(do.call(rbind, rows))
