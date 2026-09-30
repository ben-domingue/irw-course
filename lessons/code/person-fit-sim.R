# Simulate 2PL responses, make some respondents aberrant, fit the 2PL with mirt,
# and see how often l_z and l_z* flag clean and aberrant respondents.
# l_z* (Snijders, 2001) is computed by hand; mirt's personfit() gives l_z.
# Change `kind`, `share` and `n_items` and run it again. Needs the mirt package.
library(mirt)
set.seed(20260928)
n_resp  <- 1000
n_items <- 20
share   <- 0.05          # share of respondents made aberrant
kind    <- "random"      # "random", "preknowledge", "guessing" or "none"

a  <- rlnorm(n_items, 0, 0.3)            # slopes
b  <- sort(rnorm(n_items))               # difficulties, easiest first
th <- rnorm(n_resp)
P  <- plogis(sweep(outer(th, b, "-"), 2, a, "*"))
X  <- (matrix(runif(n_resp * n_items), n_resp) < P) * 1

# Aberrant respondents
bad <- if (kind == "none") integer(0) else sample(n_resp, round(share * n_resp))
hard <- (n_items - 3):n_items            # the four hardest items
if (kind == "random")       X[bad, ] <- rbinom(length(bad) * n_items, 1, 0.25)
if (kind == "preknowledge") X[bad, hard] <- 1
if (kind == "guessing") {                # guess (1 in 4) on items above one's level
  Pg <- 0.25 + 0.75 * P[bad, ]
  X[bad, ] <- (matrix(runif(length(bad) * n_items), length(bad)) < Pg) * 1
}
colnames(X) <- paste0("item", 1:n_items)

# Fit the 2PL and score everyone by maximum likelihood; perfect patterns
# (all right or all wrong) have no ML estimate and no person-fit statistic.
m  <- mirt(X, 1, itemtype = "2PL", verbose = FALSE)
ip <- coef(m, simplify = TRUE, IRTpars = TRUE)$items
ok <- rowSums(X) > 0 & rowSums(X) < n_items
th_ml <- fscores(m, method = "ML", max_theta = 10)[, 1]

# l_z by hand: l_0 - E(l_0) = sum (x - P) w, with w = log(P / (1 - P))
Ph <- plogis(sweep(outer(th_ml[ok], ip[, "b"], "-"), 2, ip[, "a"], "*"))
Qh <- 1 - Ph
w  <- log(Ph / Qh)
lz <- rowSums((X[ok, ] - Ph) * w) / sqrt(rowSums(Ph * Qh * w^2))
# Same as mirt's Zh:
all.equal(unname(lz), personfit(m, Theta = matrix(th_ml))$Zh[ok])

# l_z*: take out the part of w along the slopes (the ML score equation has
# already set sum a (x - P) to zero), then standardize what is left.
A  <- matrix(ip[, "a"], sum(ok), n_items, byrow = TRUE)
cn <- rowSums(Ph * Qh * w * A) / rowSums(Ph * Qh * A^2)
wt <- w - cn * A
lzs <- rowSums((X[ok, ] - Ph) * wt) / sqrt(rowSums(Ph * Qh * wt^2))

is_bad <- seq_len(n_resp)[ok] %in% bad
data.frame(
  statistic = c("l_z", "l_z*"),
  SD_clean = round(c(sd(lz[!is_bad]), sd(lzs[!is_bad])), 2),
  flagged_clean = round(c(mean(lz[!is_bad] < -1.645), mean(lzs[!is_bad] < -1.645)), 3),
  flagged_aberrant = if (any(is_bad))
    round(c(mean(lz[is_bad] < -1.645), mean(lzs[is_bad] < -1.645)), 3) else NA)
cat(sum(!ok), "respondents with a perfect or zero score have no statistic;",
    sum(bad %in% which(!ok)), "of them are aberrant.\n")

hist(lzs[!is_bad], breaks = 40, freq = FALSE, col = "#93c5fd", border = NA,
     main = paste0(kind, ": l_z* for clean (blue) and aberrant (orange) respondents"),
     xlab = "l_z*", xlim = c(-6, 4))
if (any(is_bad)) rug(lzs[is_bad], col = "#c2410c", lwd = 2)
curve(dnorm(x), add = TRUE, lwd = 2)
abline(v = -1.645, lty = 2, col = "#999")
