# Latent classes and cognitive diagnosis with real data: the Examination for the
# Certificate of Proficiency in English (cdm_ecpe) and Tatsuoka's fraction subtraction
# items (frac20), both from the Item Response Warehouse. Needs poLCA (Linzer & Lewis,
# 2011), GDINA (Ma & de la Torre, 2020) and mirt (Chalmers, 2012).
# No login or token: every CSV link is pinned to one version of the IRW data.
# The latent class fits take a minute or two; everything else, seconds.
# Adapted from ben-domingue/252: c7/3_cdm.R and ps7/cdm.R.

## ---- fetch-ecpe
suppressPackageStartupMessages({library(poLCA); library(GDINA); library(mirt)})
options(digits = 7)  # R's default, in case a .Rprofile changes it
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.cdm_ecpe/rows?format=csv"
ecpe <- read.csv(url)
# One row per response; the Q-matrix travels in the Qmatrix__ columns.
wide <- reshape(ecpe[, c("id", "item", "resp")], idvar = "id", timevar = "item",
                direction = "wide")
wide <- wide[order(wide$id), ]
e_items <- paste0("E", 1:28)
Xe <- as.matrix(wide[, paste0("resp.", e_items)])
colnames(Xe) <- e_items
Qe <- unique(ecpe[, c("item", "Qmatrix__skill1", "Qmatrix__skill2", "Qmatrix__skill3")])
Qe <- as.matrix(Qe[match(e_items, Qe$item), -1])
colnames(Qe) <- c("morphosyntactic", "cohesive", "lexical")
cat(nrow(Xe), "respondents,", ncol(Xe), "items,", sum(is.na(Xe)), "missing responses\n")
cat("Proportion correct: from", min(round(colMeans(Xe), 2)), "to", max(round(colMeans(Xe), 2)), "\n")
# The same data ship with GDINA; check that the copies agree.
data(realdata_ECPE, package = "GDINA")
cat("Same responses as GDINA's copy:", all(Xe == as.matrix(realdata_ECPE$dat)),
    "  Same Q-matrix:", all(Qe == as.matrix(realdata_ECPE$Q)), "\n")

## ---- lca-ecpe
# poLCA wants categories coded 1, 2, ...; nrep = 5 starts each fit from five random
# places and keeps the best, since EM can stop on a local maximum.
d <- as.data.frame(Xe + 1)
f <- as.formula(paste("cbind(", paste(e_items, collapse = ","), ") ~ 1"))
set.seed(252)
lca <- lapply(1:5, function(k)
  poLCA(f, d, nclass = k, nrep = if (k == 1) 1 else 5, maxiter = 3000, verbose = FALSE))
rasch_e <- mirt(Xe, 1, "Rasch", verbose = FALSE)
twopl_e <- mirt(Xe, 1, "2PL", verbose = FALSE)
fits <- data.frame(
  model = c(paste(1:5, "classes"), "Rasch", "2PL"),
  logLik = round(c(sapply(lca, `[[`, "llik"), extract.mirt(rasch_e, "logLik"),
                   extract.mirt(twopl_e, "logLik")), 1),
  parameters = c(sapply(lca, `[[`, "npar"), extract.mirt(rasch_e, "nest"),
                 extract.mirt(twopl_e, "nest")),
  AIC = round(c(sapply(lca, `[[`, "aic"), extract.mirt(rasch_e, "AIC"),
                extract.mirt(twopl_e, "AIC"))),
  BIC = round(c(sapply(lca, `[[`, "bic"), extract.mirt(rasch_e, "BIC"),
                extract.mirt(twopl_e, "BIC"))))
print(fits, row.names = FALSE)

## ---- lca-order
# Put each solution's classes in order of their average proportion correct, then
# count the items on which a higher class does worse than the class below it.
class_probs <- function(fit) {
  P <- sapply(fit$probs, function(p) p[, 2])   # classes x items: P(correct)
  o <- order(rowMeans(P))
  list(P = P[o, , drop = FALSE], share = fit$P[o])
}
for (k in 2:5) {
  cp <- class_probs(lca[[k]])
  out_of_order <- sum(apply(cp$P, 2, function(v) any(diff(v) < 0)))
  cat(sprintf("%d classes: shares %s; mean P(correct) %s; items out of order: %d\n", k,
              paste(sprintf("%.2f", cp$share), collapse = " "),
              paste(sprintf("%.2f", rowMeans(cp$P)), collapse = " "), out_of_order))
}

## ---- lca-five
# The five-class solution, with its items grouped by the attributes the ECPE's
# Q-matrix says they need (1 = needed; order: morphosyntactic, cohesive, lexical).
cp5 <- class_probs(lca[[5]])
pattern <- apply(Qe, 1, paste, collapse = "")
tab5 <- aggregate(t(cp5$P), list(Q_row = pattern), mean)
names(tab5)[-1] <- paste0("class", 1:5)
tab5$items <- as.vector(table(pattern)[tab5$Q_row])
print(cbind(tab5[, 1, drop = FALSE], round(tab5[, 2:6], 2), items = tab5$items), row.names = FALSE)

## ---- fetch-frac
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.frac20/rows?format=csv"
frac <- read.csv(url)
wide <- reshape(frac[, c("id", "item", "resp")], idvar = "id", timevar = "item",
                direction = "wide")
wide <- wide[order(wide$id), ]
f_items <- paste0("item_", 1:20)
Xf <- as.matrix(wide[, paste0("resp.", f_items)])
colnames(Xf) <- f_items
Qf <- unique(frac[, c("item", paste0("Qmatrix__", 1:8))])
Qf <- as.matrix(Qf[match(f_items, Qf$item), -1])
colnames(Qf) <- paste0("A", 1:8)
cat(nrow(Xf), "respondents,", ncol(Xf), "items,", sum(is.na(Xf)), "missing responses\n")
data(realdata_Tatsuoka1990, package = "GDINA")
cat("Same responses as GDINA's copy:", all(Xf == as.matrix(realdata_Tatsuoka1990$dat)),
    "  Same Q-matrix:", all(Qf == as.matrix(realdata_Tatsuoka1990$Q)), "\n")
cat("Attributes per item:", rowSums(Qf), "\n")
cat("Items needing each attribute:", colSums(Qf), "\n")

## ---- dina-frac
dina_f <- GDINA(Xf, Qf, model = "DINA", verbose = 0)
gs <- coef(dina_f, "gs")
print(round(t(gs[, c("guessing", "slip")]), 2))
cat(sprintf("Items with slip at most 0.25: %d of 20. Largest guess: %.2f (item %d)\n",
            sum(gs[, "slip"] <= 0.25), max(gs[, "guessing"]), which.max(gs[, "guessing"])))
cat("Log likelihood", round(logLik(dina_f), 1), "with", npar(dina_f)$`No. of parameters`,
    "parameters\n")

## ---- mastery-frac
prev <- extract(dina_f, "prevalence")$all[, "Level1"]
cat("Proportion mastering each attribute:", round(prev, 2), "\n")
att_f <- personparm(dina_f, "EAP")   # attribute mastered if its posterior probability > 0.5
n_att <- rowSums(att_f)
cat("Respondents with all eight:", sum(n_att == 8), sprintf("(%.1f%%)", 100 * mean(n_att == 8)),
    "  Distinct profiles among", nrow(att_f), "respondents:",
    length(unique(apply(att_f, 1, paste, collapse = ""))), "\n")

## ---- sumscore-frac
r <- rowSums(Xf)
profile <- apply(att_f, 1, paste, collapse = "")
by_r <- data.frame(sum_score = sort(unique(r)),
                   respondents = as.vector(table(r)),
                   profiles = as.vector(tapply(profile, r, function(p) length(unique(p)))),
                   fewest_attributes = as.vector(tapply(n_att, r, min)),
                   most_attributes = as.vector(tapply(n_att, r, max)))
print(by_r[by_r$sum_score %in% c(0, 5, 10, 15, 20), ], row.names = FALSE)
cat("\nThe 16 respondents with 10 correct, by profile (A1 ... A8):\n")
print(sort(table(profile[r == 10]), decreasing = TRUE))
rasch_f <- mirt(Xf, 1, "Rasch", verbose = FALSE)
theta_f <- fscores(rasch_f)[, 1]
cat("\nCorrelation of attributes mastered with the sum score:", round(cor(n_att, r), 2),
    "; with Rasch theta:", round(cor(n_att, theta_f), 2), "\n")

## ---- compare-frac
gdina_f <- GDINA(Xf, Qf, model = "GDINA", verbose = 0)
ho_f <- GDINA(Xf, Qf, model = "DINA", att.dist = "higher.order", verbose = 0)
twopl_f <- mirt(Xf, 1, "2PL", verbose = FALSE)
cdm_row <- function(name, m) data.frame(model = name, logLik = round(as.numeric(logLik(m)), 1),
  parameters = npar(m)$`No. of parameters`, AIC = round(AIC(m)), BIC = round(BIC(m)))
irt_row <- function(name, m) data.frame(model = name, logLik = round(extract.mirt(m, "logLik"), 1),
  parameters = extract.mirt(m, "nest"), AIC = round(extract.mirt(m, "AIC")),
  BIC = round(extract.mirt(m, "BIC")))
print(rbind(cdm_row("DINA", dina_f), cdm_row("G-DINA", gdina_f),
            cdm_row("higher-order DINA", ho_f), irt_row("Rasch", rasch_f),
            irt_row("2PL", twopl_f)), row.names = FALSE)
# The higher-order model: each attribute is a Rasch-type item on one theta (slope
# fixed at 1, GDINA's default), so its profile distribution has 8 parameters, not 255.
cat("\nHigher-order DINA, attribute intercepts:", round(coef(ho_f, "lambda")[, "intercept"], 2),
    "; slopes:", unique(coef(ho_f, "lambda")[, "slope"]), "\n")
# A Q-matrix with no thought behind it: redraw the entries for attributes 5 to 8 at
# random, keeping each attribute's share of items (as in 252's c7/3_cdm.R).
set.seed(10103101)
Q_random <- Qf
for (k in 5:8) Q_random[, k] <- rbinom(20, 1, mean(Qf[, k]))
dina_random <- GDINA(Xf, Q_random, model = "DINA", verbose = 0)
cat("\nDINA with attributes 5-8 of the Q-matrix redrawn at random: AIC", round(AIC(dina_random)), "\n")

## ---- qval-frac
# Empirical Q-matrix validation by the proportion of variance accounted for (PVAF;
# de la Torre & Chiu, 2016), starting from the DINA fit and from the G-DINA fit.
# For each suggestion, refit the same model with the suggested Q-matrix.
for (m in list(list("DINA", dina_f), list("GDINA", gdina_f))) {
  Q_sug <- extract(Qval(m[[2]], method = "PVAF", eps = 0.95), "sug.Q")
  changed <- which(rowSums(Q_sug != Qf) > 0)
  refit <- GDINA(Xf, Q_sug, model = m[[1]], verbose = 0)
  cat(sprintf("From %s: changes suggested to %d items (%s). AIC %.0f with the original Q, %.0f with the suggested one.\n",
              m[[1]], length(changed), paste(changed, collapse = ", "), AIC(m[[2]]), AIC(refit)))
}

## ---- gdina-ecpe
gdina_e <- GDINA(Xe, Qe, model = "GDINA", verbose = 0)
shares <- extract(gdina_e, "posterior.prob")[1, ]
print(round(sort(shares, decreasing = TRUE), 3))
cat("Four largest profiles together:", round(sum(sort(shares, decreasing = TRUE)[1:4]), 3), "\n")

## ---- compare-ecpe
dina_e <- GDINA(Xe, Qe, model = "DINA", verbose = 0)
# G-DINA allowed only the four profiles of a chain: none, lexical, lexical + cohesive, all
chain <- matrix(c(0, 0, 0,  0, 0, 1,  0, 1, 1,  1, 1, 1), ncol = 3, byrow = TRUE)
gdina_chain <- GDINA(Xe, Qe, model = "GDINA", att.str = chain, verbose = 0)
print(rbind(cdm_row("DINA", dina_e), cdm_row("G-DINA", gdina_e),
            cdm_row("G-DINA, four-profile chain", gdina_chain),
            irt_row("Rasch", rasch_e), irt_row("2PL", twopl_e)), row.names = FALSE)
