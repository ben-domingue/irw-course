# What is a difficulty prediction worth? Simulate items whose difficulties depend on
# two text features plus an item-specific part the features miss, predict the
# difficulties of new items from the features, and convert the prediction error into
# the number of respondents a field test would need to do as well. Base R only; runs
# in a second or two. New for this course (EDUC 252 c10 poses the question).
set.seed(55)
n_items  <- 200    # items written, with known text features
n_train  <- 150    # items already calibrated; the other 50 are new
sd_resid <- 0.6    # SD of what the features miss (try 0.2 and 1)
n_field  <- 25     # respondents in a small field test of the new items

# Two standardized text features (think: word count, and a rating of how rare the
# words are), and difficulties that follow them up to an item residual.
f1 <- rnorm(n_items); f2 <- rnorm(n_items)
b  <- 0.3 * f1 + 0.5 * f2 + rnorm(n_items, 0, sd_resid)

# Fit the feature model on the calibrated items; predict the new ones.
train <- 1:n_train; test <- (n_train + 1):n_items
fit  <- lm(b ~ f1 + f2, data = data.frame(b, f1, f2)[train, ])
pred <- predict(fit, newdata = data.frame(f1, f2)[test, ])
c(cor_new_items = cor(pred, b[test]), rmse_prediction = sqrt(mean((pred - b[test])^2)))

# How many respondents is that worth? One respondent with theta ~ N(0, 1) carries
# E[p(1 - p)] units of information about an item's difficulty (Rasch model), so a
# calibration on n respondents has SE about 1 / sqrt(n * E[p(1 - p)]). A prediction
# with error SD sigma matches n* = 1 / (sigma^2 * E[p(1 - p)]).
epq <- function(bi) integrate(function(t) plogis(t - bi) * (1 - plogis(t - bi)) * dnorm(t), -Inf, Inf)$value
info  <- mean(sapply(b[test], epq))
sigma <- sqrt(mean((pred - b[test])^2))
c(information_per_respondent = info, respondents_worth = 1 / (sigma^2 * info))

# Check against an actual field test: n_field respondents answer the new items, and we
# estimate each difficulty by maximum likelihood from their responses alone, taking
# their abilities as known (as if linked through items already in the bank). The
# search is bounded at +/- 6 logits, for items everyone got right or wrong.
theta <- rnorm(n_field)
x <- sapply(b[test], function(bi) rbinom(n_field, 1, plogis(theta - bi)))
b_field <- apply(x, 2, function(xi)
  optimize(function(bb) -sum(dbinom(xi, 1, plogis(theta - bb), log = TRUE)), c(-6, 6))$minimum)
c(rmse_field_test = sqrt(mean((b_field - b[test])^2)), rmse_prediction = sigma,
  field_test_rmse_expected = 1 / sqrt(n_field * info))
