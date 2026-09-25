# Fairness with real data: one vocabulary checklist, two groupings. Do older and
# younger respondents differ in vocabulary, or does the checklist work differently
# for them? And for native and non-native speakers of English? The Open-Source
# Psychometrics Project's vocabulary checklist, as given with the Generic
# Conspiracist Beliefs Scale (IRW table gcbs_brotherton_2013_vcl). Runs as-is in R
# with the mirt package; no login or token. New for this course.

## ---- fetch
library(mirt)
# The CSV link on the table's landing page, pinned to one version of the data.
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v59_0.gcbs_brotherton_2013_vcl/rows?format=csv"
df <- read.csv(url)
c(rows = nrow(df), respondents = length(unique(df$id)), missing = sum(is.na(df$resp)))

## ---- wide
# One row per respondent. A 1 means the respondent checked the word as one whose
# definition they are sure they know. VCL6, VCL9 and VCL12 are not English words
# (the source's validity check), so the score uses the other 13.
X <- tapply(df$resp, list(df$id, df$item), function(v) v[1])
cv <- df[!duplicated(df$id), ]
cv <- cv[match(rownames(X), cv$id), ]
words <- c(VCL1 = "boat", VCL2 = "incoherent", VCL3 = "pallid", VCL4 = "robot", VCL5 = "audible",
           VCL7 = "paucity", VCL8 = "epistemology", VCL10 = "decide", VCL11 = "pastiche",
           VCL13 = "abysmal", VCL14 = "lucid", VCL15 = "betray", VCL16 = "funny")
Y <- X[, names(words)]
colnames(Y) <- words
round(sort(colMeans(Y)), 2)   # the share checking each word

## ---- groups
# Two groupings. Age: under 25 against 40 and over (the middle is left out, to
# make two clearly different groups). Language: "Is English your native
# language?" (1 = yes, 2 = no; 0 means no answer).
age <- ifelse(cv$cov_age < 25, "young", ifelse(cv$cov_age >= 40, "older", NA))
lang <- ifelse(cv$cov_engnat == 1, "native", ifelse(cv$cov_engnat == 2, "nonnative", NA))
r <- rowSums(Y)
gap <- function(g, ref) {
  m <- tapply(r, g, mean)
  c(n = table(g), mean = round(m, 2), gap_in_SD = round((m[names(m) != ref] - m[ref]) / sd(r[!is.na(g)]), 2))
}
gap(age, "young")
gap(lang, "native")

## ---- invariance-fn
# Configural: a 2PL for each group, every slope and intercept free. Scalar: the
# same slopes and intercepts in both groups, with the second group's mean and
# variance free (the first group's are fixed at 0 and 1 to set the scale).
# Partial: scalar, except that the words in `free` get their own slope and
# intercept in each group. mirt writes the 2PL as a*theta + d.
invariance <- function(Y, g, ref, free = character()) {
  keep <- !is.na(g)
  G <- factor(g[keep], levels = c(ref, setdiff(unique(g[keep]), ref)))
  fit <- function(inv) multipleGroup(Y[keep, ], 1, group = G, itemtype = "2PL",
                                     invariance = inv, verbose = FALSE)
  eq <- c("free_means", "free_var")
  out <- list(configural = fit(character()),
              scalar = fit(c("slopes", "intercepts", eq)))
  if (length(free)) out$partial <- fit(c(setdiff(colnames(Y), free), eq))
  out
}
latent_gap <- function(m) round(coef(m, simplify = TRUE)[[2]]$means[1], 2)
# The likelihood-ratio test and information criteria, one model against the configural.
compare <- function(fits, what = "scalar") {
  out <- anova(fits[[what]], fits$configural)
  rownames(out) <- c(what, "configural")
  round(out, 1)
}

## ---- sanity
# A known answer first: split the respondents at random, ten times. The halves
# differ only by chance, so this shows how big the likelihood-ratio statistic gets
# when nothing differs, for these words and this many respondents.
splits <- t(sapply(1:10, function(s) {
  set.seed(s)
  f <- invariance(Y, sample(c("A", "B"), nrow(Y), replace = TRUE), "A")
  a <- anova(f$scalar, f$configural)
  c(X2 = a$X2[2], p = a$p[2], BIC_scalar_minus_configural = a$BIC[1] - a$BIC[2],
    latent_gap = latent_gap(f$scalar))
}))
round(splits, 3)

## ---- age
fits_age <- invariance(Y, age, "young", free = c("paucity", "epistemology"))
compare(fits_age)
dif_age <- DIF(fits_age$scalar, which.par = c("a1", "d"), scheme = "drop", verbose = FALSE)
head(dif_age[order(-dif_age$X2), c("X2", "df", "p")], 3)
c(sum_score_gap = unname(gap(age, "young")["gap_in_SD.older"]),
  latent_gap_scalar = latent_gap(fits_age$scalar), latent_gap_partial = latent_gap(fits_age$partial))

## ---- lang
fits_lang <- invariance(Y, lang, "native", free = c("epistemology", "abysmal", "pastiche"))
compare(fits_lang)
# Which words? Drop each word's equality constraints in turn and test the change.
dif_words <- DIF(fits_lang$scalar, which.par = c("a1", "d"), scheme = "drop", verbose = FALSE)
head(dif_words[order(-dif_words$X2), c("X2", "df", "p")], 4)

## ---- words
# The share checking each of the three words, by group, next to the whole
# checklist (as a share of the 13 words).
round(rbind(sapply(split(as.data.frame(Y[, c("epistemology", "pastiche", "abysmal")]), lang), colMeans),
            all_13_words = tapply(r / 13, lang, mean)), 2)

## ---- partial
# Free the three words and keep the other ten equal: they now anchor the scale.
compare(fits_lang, "partial")
c(latent_gap_scalar = latent_gap(fits_lang$scalar), latent_gap_partial = latent_gap(fits_lang$partial))
