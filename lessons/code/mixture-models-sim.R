# Simulate a content-free class on a balanced scale and look for it two ways: with a
# two-class mixture Rasch model, and with person-level screens. From the lesson
# "Mixture models: when respondents differ in kind". Needs mirt.
library(mirt)
set.seed(2026)
np <- 1000          # respondents
share_cf <- 0.2     # share of the content-free class
p_agree <- 0.8      # how often a content-free respondent agrees, whatever the item says
b <- c(-1, -0.5, 0, 0.5, 1, -1, -0.5, 0, 0.5, 1)   # items 1-5 forward, 6-10 reversed
reversed <- 6:10

cf <- runif(np) < share_cf                 # the true class
theta <- rnorm(np)
P <- plogis(outer(theta, b, "-"))          # engaged: the Rasch model on keyed items
keyed <- (matrix(runif(np * 10), np) < P) * 1
agree <- (matrix(runif(np * 10), np) < p_agree) * 1
# A content-free respondent's raw answer is agreement; keying flips the reversed items.
agree_keyed <- agree; agree_keyed[, reversed] <- 1 - agree[, reversed]
X <- keyed; X[cf, ] <- agree_keyed[cf, ]
colnames(X) <- c(paste0("F", 1:5), paste0("R", 1:5))
c(content_free = sum(cf), mean_sum_cf = mean(rowSums(X[cf, ])), mean_sum_engaged = mean(rowSums(X[!cf, ])))

# The Rasch model and a two-class mixture Rasch model.
m1 <- mirt(X, 1, itemtype = "Rasch", verbose = FALSE)
m2 <- multipleGroup(X, 1, itemtype = "Rasch", dentype = "mixture-2", verbose = FALSE)
c(BIC_one = extract.mirt(m1, "BIC"), BIC_two = extract.mirt(m2, "BIC"))
cfs <- coef(m2, simplify = TRUE)
# Name the classes by profile, not by number: the content-free class finds the
# forward items easy and the reversed ones hard.
gap <- sapply(cfs, function(g) mean(g$items[1:5, "d"]) - mean(g$items[6:10, "d"]))
k_cf <- which.max(gap)
round(cbind(true_b = b, sapply(cfs, function(g) -g$items[, "d"])), 2)   # b = -d
c(pi_hat_content_free = extract.mirt(m2, "pis")[k_cf], truth = mean(cf))
post <- fscores(m2, method = "classify", verbose = FALSE)
found <- post[, grep("^CLASS", colnames(post))][, k_cf] > 0.5
table(true_class = ifelse(cf, "content-free", "engaged"), assigned = ifelse(found, "content-free", "engaged"))

# Screens. A time per item for each respondent (content-free respondents are faster),
# the within-person SD of the raw answers, and the Mahalanobis distance.
raw <- X; raw[, reversed] <- 1 - X[, reversed]              # back to agree/disagree
time <- exp(rnorm(np, ifelse(cf, log(2), log(4)), 0.4))     # seconds per item
flags <- data.frame(fast = time < quantile(time, 0.1),
                    same = apply(raw, 1, sd) <= quantile(apply(raw, 1, sd), 0.1),
                    odd = mahalanobis(X, colMeans(X), cov(X)) >= quantile(mahalanobis(X, colMeans(X), cov(X)), 0.9),
                    mixture = found)
# Share of each true class flagged by each screen:
round(sapply(flags, function(f) tapply(f, ifelse(cf, "content-free", "engaged"), mean)), 2)
# Try p_agree <- 0.5 (random answering), share_cf <- 0.05, or make every item
# forward (reversed <- integer(0)) and watch the content-free class disappear into
# the trait. Change the seed and the class numbers may swap: that's label switching.
