# A continuum or latent classes? Simulate item responses from a construct map
# (respondents on a continuum, items at five levels) and from four latent classes
# built to have the same item means, then compare what we could see in the data.
# Base R only. New for this course (EDUC 252 c2 raises the question; the
# simulation is not in the 252 code).
set.seed(30)
n     <- 2000                               # respondents
b     <- rep(c(-2, -1, 0, 1, 2), each = 2)  # item locations: two items at each of five levels
share <- c(0.2, 0.3, 0.3, 0.2)              # sizes of the four classes
sep   <- 1                                  # distance between neighbouring classes (try 3)

# Model 1, a continuum: theta ~ N(0, 1) and a logistic item curve,
# P(x = 1) = exp(theta - b) / (1 + exp(theta - b)).
theta  <- rnorm(n)
x_cont <- sapply(b, function(bi) rbinom(n, 1, plogis(theta - bi)))

# Model 2, four ordered latent classes, `sep` apart and centred at 0. Within a
# class, everyone has the same chance of success on an item.
loc <- (seq_along(share) - mean(seq_along(share))) * sep
# Each item's expected proportion correct under model 1 ...
target <- sapply(b, function(bi) integrate(function(t) plogis(t - bi) * dnorm(t), -Inf, Inf)$value)
# ... and the item location that gives the classes that same proportion.
b_cls <- sapply(target, function(m) uniroot(function(bb) sum(share * plogis(loc - bb)) - m, c(-10, 10))$root)
cls   <- sample(seq_along(share), n, replace = TRUE, prob = share)
x_cls <- sapply(b_cls, function(bi) rbinom(n, 1, plogis(loc[cls] - bi)))

# What could we see? Item means, item-rest correlations, the sum-score distribution.
item_rest <- function(x) sapply(seq_len(ncol(x)), function(i) cor(x[, i], rowSums(x[, -i])))
round(rbind(mean_continuum     = colMeans(x_cont), mean_classes     = colMeans(x_cls),
            itemrest_continuum = item_rest(x_cont), itemrest_classes = item_rest(x_cls)), 2)
sums <- rbind(continuum = tabulate(rowSums(x_cont) + 1, 11),
              classes   = tabulate(rowSums(x_cls) + 1, 11))
colnames(sums) <- 0:10
sums
round(c(sd_continuum = sd(rowSums(x_cont)), sd_classes = sd(rowSums(x_cls))), 2)
barplot(sums, beside = TRUE, col = c("#2780e3", "#c2410c"), border = NA,
        xlab = "Sum score", ylab = "Respondents", legend.text = c("continuum", "four classes"))
