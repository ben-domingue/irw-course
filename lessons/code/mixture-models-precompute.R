# How many classes for the Kay extraversion items? Held-out comparisons (the IMV;
# Domingue et al., 2024) of the Rasch model, the 2PL and mixture Rasch models with
# two and three classes, plus BIC up to four classes and a check that ten random
# starts reach the same maximum. For the lesson "Mixture models: when respondents
# differ in kind". Too slow for the page (about 15-20 minutes), so it was run by
# hand when the page was built; the page reads data/mixture-models-kay.csv. Run
# from lessons/. Needs mirt.

## ---- kay-precompute
suppressMessages(library(mirt))
kay <- read.csv("https://redivis.com/api/v1/tables/datapages.item_response_warehouse_5:v5_0.kay_2025_antonyms/rows?format=csv")
W <- as.data.frame(tapply(kay$resp, list(kay$id, kay$item), function(x) x[1]))
forward  <- c("tlk1_001_x", "tlk2_003_x", "cntr_006_r", "frnd_031_x", "extr_057_x")
reversed <- c("tlk1_002_r", "tlk2_004_r", "cntr_005_x", "frnd_032_r", "extr_058_r")
agree <- (W[, c(forward, reversed)] >= 1) * 1
X <- cbind(agree[, forward], 1 - agree[, reversed])
colnames(X) <- c(paste0("F", 1:5), paste0("R", 1:5))

mix <- function(D, K) multipleGroup(D, 1, itemtype = "Rasch", dentype = paste0("mixture-", K),
                                    verbose = FALSE, technical = list(NCYCLES = 3000))
# Ten random starts for two and three classes: do they reach the same maximum?
starts <- sapply(2:3, function(K) sapply(1:10, function(s) { set.seed(s)
  tryCatch(extract.mirt(mix(X, K), "logLik"), error = function(e) NA) }))
set.seed(4); four <- mix(X, 4)

# Held-out predictions: five folds over responses (not respondents). Each model is
# fitted with a fold's responses set to missing; each held-out response is predicted
# from the respondent's other responses, averaging over the classes and over theta.
imv <- function(y, p0, p1) {
  ll <- function(p) mean(y * log(p) + (1 - y) * log(1 - p))
  coin <- function(v) uniroot(function(w) w * log(w) + (1 - w) * log(1 - w) - v, c(0.5, 0.99999))$root
  w0 <- coin(ll(p0)); w1 <- coin(ll(p1)); (w1 - w0) / w0
}
predict_cells <- function(fit, Xm, Q = 61) {
  z <- seq(-6, 6, length.out = Q)
  groups <- if (inherits(fit, c("MixtureClass", "MultipleGroupClass"))) coef(fit) else list(coef(fit))
  pis <- if (inherits(fit, c("MixtureClass", "MultipleGroupClass"))) extract.mirt(fit, "pis") else 1
  obs <- !is.na(Xm); X0 <- ifelse(obs, Xm, 0)
  num <- matrix(0, nrow(Xm), ncol(Xm)); den <- rep(0, nrow(Xm))
  for (k in seq_along(groups)) {
    g <- groups[[k]]
    a <- sapply(g[1:ncol(Xm)], function(p) p[1, "a1"]); d <- sapply(g[1:ncol(Xm)], function(p) p[1, "d"])
    mu <- g$GroupPars[1, 1]; s2 <- g$GroupPars[1, 2]
    th <- if (s2 < 1e-4) mu else mu + sqrt(s2) * z
    w  <- if (s2 < 1e-4) 1 else dnorm(z) / sum(dnorm(z))
    P <- pmin(pmax(plogis(outer(th, a) + matrix(d, length(th), ncol(Xm), byrow = TRUE)), 1e-8), 1 - 1e-8)
    lik <- exp(X0 %*% t(log(P)) + (obs * (1 - X0)) %*% t(log(1 - P)))
    Wt <- sweep(lik, 2, w * pis[k], "*")
    num <- num + Wt %*% P; den <- den + rowSums(Wt)
  }
  num / den
}
fitters <- list(rasch = function(D) mirt(D, 1, itemtype = "Rasch", verbose = FALSE),
                twopl = function(D) mirt(D, 1, itemtype = "2PL", verbose = FALSE),
                mix2 = function(D) mix(D, 2), mix3 = function(D) mix(D, 3))
set.seed(1)
Xm <- as.matrix(X)
fold <- matrix(sample(1:5, length(Xm), replace = TRUE), nrow(Xm))
held <- do.call(rbind, lapply(1:5, function(f) {
  tr <- Xm; tr[fold == f] <- NA
  pr <- sapply(fitters, function(ff) predict_cells(ff(as.data.frame(tr)), tr)[fold == f])
  data.frame(y = Xm[fold == f], pr)
}))
out <- data.frame(
  comparison = c("2 classes over Rasch", "3 classes over 2", "2PL over Rasch", "2 classes over 2PL",
                 "BIC, 4 classes", "10 starts, 2 classes: distinct maxima", "10 starts, 3 classes: distinct maxima"),
  value = c(imv(held$y, held$rasch, held$mix2), imv(held$y, held$mix2, held$mix3),
            imv(held$y, held$rasch, held$twopl), imv(held$y, held$twopl, held$mix2),
            extract.mirt(four, "BIC"),
            length(unique(round(na.omit(starts[, 1]), 1))), length(unique(round(na.omit(starts[, 2]), 1)))))
out$value <- signif(out$value, 4)
out$date_run <- as.character(Sys.Date())
write.csv(out, "data/mixture-models-kay.csv", row.names = FALSE)
print(out)
# The keyed items' correlations in the whole sample (forward with reversed):
R <- cor(X); round(mean(R[1:5, 6:10]), 2)
