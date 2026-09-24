# Exploratory factor analysis with real data: the BFI-2 (bfi2_zhang_2025) from the
# Item Response Warehouse. Needs the psych and GPArotation packages. No login or
# token needed.

## ---- fetch
library(psych)
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_2:v21_0.bfi2_zhang_2025/rows?format=csv"
df <- read.csv(url)
wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
num <- as.integer(sub("self_BFI_", "", colnames(wide)))
resp <- as.data.frame(wide[, order(num)])
resp <- resp[complete.cases(resp), ]
dim(resp)   # people who answered all 60 items

## ---- domains
# The BFI-2 cycles through its five domains: item 1 is Extraversion, item 2
# Agreeableness, item 3 Conscientiousness, item 4 Negative Emotionality, item 5
# Open-Mindedness, item 6 Extraversion again, and so on (Soto & John, 2017).
domain <- c("Extraversion", "Agreeableness", "Conscientiousness",
            "Negative Emotionality", "Open-Mindedness")[(seq_len(60) - 1) %% 5 + 1]
table(domain)

## ---- cormat
# Polychoric correlations treat each 1-5 response as a coarsened continuous one.
R <- polychoric(resp)$rho
by_domain <- order(domain)
image(1:60, 1:60, R[by_domain, rev(by_domain)], zlim = c(-1, 1), axes = FALSE,
      col = hcl.colors(41, "Blue-Red 3"), xlab = "Items, grouped by domain", ylab = "",
      main = "Polychoric correlations, BFI-2 items sorted by domain")
abline(v = seq(12.5, 48.5, 12), h = seq(12.5, 48.5, 12), col = "white", lwd = 2)

## ---- parallel
set.seed(252)
pa <- fa.parallel(R, n.obs = nrow(resp), fa = "fa", n.iter = 20, plot = TRUE,
                  main = "Parallel analysis: BFI-2")
pa$nfact
sum(eigen(R)$values > 1)   # the "eigenvalue greater than one" rule, for comparison

## ---- efa
f5 <- fa(R, nfactors = 5, n.obs = nrow(resp), rotate = "oblimin", fm = "minres")
L <- unclass(f5$loadings)
top <- apply(abs(L), 1, which.max)
table(domain, factor = colnames(L)[top])
round(f5$Phi, 2)   # correlations among the rotated factors

## ---- loadings
# Loadings for the Extraversion items on the five factors. (All are positive: the
# BFI-2's reverse-worded items arrive already reverse-keyed in these data.)
round(L[domain == "Extraversion", ], 2)

## ---- varimax
# The same five factors with an orthogonal rotation: identical fit, different loadings.
f5v <- fa(R, nfactors = 5, n.obs = nrow(resp), rotate = "varimax", fm = "minres")
c(oblimin_rmsr = f5$rms, varimax_rmsr = f5v$rms)
