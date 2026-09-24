# Exploratory factor analysis with real data: the BFI-2 (bfi2_zhang_2025) from the
# Item Response Warehouse. Needs the psych and GPArotation packages. No login or
# token needed.

## ---- fetch
library(psych)
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/)
# with a CSV download. This link is pinned to one version of the data.
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_2:v21_0.bfi2_zhang_2025/rows?format=csv"
df <- read.csv(url)
wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
num <- as.integer(sub("self_BFI_", "", colnames(wide)))
resp <- as.data.frame(wide[, order(num)])
c(respondents = nrow(resp), items = ncol(resp))
resp <- resp[complete.cases(resp), ]
nrow(resp)   # respondents who answered all 60 items

## ---- domains
# The BFI-2 cycles through its five domains: item 1 is Extraversion, item 2
# Agreeableness, item 3 Conscientiousness, item 4 Negative Emotionality, item 5
# Open-Mindedness, item 6 Extraversion again, and so on (Soto & John, 2017).
domain <- c("Extraversion", "Agreeableness", "Conscientiousness",
            "Negative Emotionality", "Open-Mindedness")[(seq_len(60) - 1) %% 5 + 1]
table(domain)

## ---- keying
# Are the reverse-worded items already reversed? If they weren't, many pairs of
# items from the same domain would correlate clearly negatively.
r <- cor(resp)
same <- outer(domain, domain, "==") & lower.tri(r)
round(range(r[same]), 3)   # Pearson correlations between items of the same domain

## ---- cormat
# Polychoric correlations treat each 1-5 response as a coarsened continuous one.
R <- polychoric(resp)$rho
by_domain <- order(domain)
image(1:60, 1:60, R[by_domain, rev(by_domain)], zlim = c(-1, 1), axes = FALSE,
      col = hcl.colors(41, "Blue-Red 3"), xlab = "Items, grouped by domain", ylab = "",
      main = "Polychoric correlations, BFI-2 items sorted by domain")
abline(v = seq(12.5, 48.5, 12), h = seq(12.5, 48.5, 12), col = "white", lwd = 2)
off <- lower.tri(R)
round(c(within_domain = median(R[off & outer(domain, domain, "==")]),
        between_domains = median(R[off & outer(domain, domain, "!=")])), 2)

## ---- parallel
set.seed(252)
pa <- fa.parallel(R, n.obs = nrow(resp), fa = "fa", n.iter = 20, plot = TRUE,
                  main = "Parallel analysis: BFI-2")
ev <- eigen(R)$values
c(parallel = pa$nfact,
  kaiser = sum(ev > 1))           # the "eigenvalue greater than one" rule, for comparison
round(ev[1] / ev[2], 2)           # ratio of the first to the second eigenvalue
# The same parallel analysis on Pearson correlations, for comparison:
set.seed(252)
fa.parallel(r, n.obs = nrow(resp), fa = "fa", n.iter = 20, plot = FALSE)$nfact

## ---- efa
# Five factors, minimum-residual estimation, oblique (oblimin) rotation.
f5 <- fa(R, nfactors = 5, n.obs = nrow(resp), rotate = "oblimin", fm = "minres")
L <- unclass(f5$loadings)
top <- apply(abs(L), 1, which.max)
# Name each factor after the domain whose items load on it most often.
names_f <- tapply(domain, factor(top, levels = 1:5), function(d) names(which.max(table(d))))
short <- c(Extraversion = "E", Agreeableness = "A", Conscientiousness = "C",
           "Negative Emotionality" = "N", "Open-Mindedness" = "O")[names_f]
colnames(L) <- dimnames(f5$Phi)[[1]] <- dimnames(f5$Phi)[[2]] <- short
table(domain, factor = short[top])
round(c(median_main_loading = median(apply(abs(L), 1, max)),
        median_largest_other = median(apply(abs(L), 1, function(x) sort(x, TRUE)[2]))), 2)
round(f5$Phi, 2)   # correlations among the rotated factors

## ---- loadings
# Loadings for the Extraversion items on the five factors.
round(L[domain == "Extraversion", ], 2)

## ---- varimax
# The same five factors with an orthogonal rotation: identical fit, different loadings.
f5v <- fa(R, nfactors = 5, n.obs = nrow(resp), rotate = "varimax", fm = "minres")
round(c(oblimin_rmsr = f5$rms, varimax_rmsr = f5v$rms), 4)
