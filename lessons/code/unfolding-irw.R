# Unfolding models with real data: Andrich's (1988) eight capital-punishment
# statements (andrich_mudfold) and European party activists' pick-2-of-6 choices
# (eurpar2_mudfold), from the Item Response Warehouse. Needs the mirt, GGUM and
# mudfold packages. No login or token needed. The GGUM fit takes about 30 seconds;
# every other chunk runs in a few seconds. Adapted from ben-domingue/252: ps9/unfold.R.

## ---- fetch-mud
library(mirt)
library(GGUM)
library(mudfold)
set.seed(52)
# IRW tables are long (one row per response); reshape to one row per respondent.
long2wide <- function(df) {
  wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  as.data.frame(wide)
}
# Each IRW table has a landing page (itemresponsewarehouse.org/tables/<name>/) with a
# CSV download. This link is pinned to one version of the data.
mud_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.andrich_mudfold/rows?format=csv"
mud <- long2wide(read.csv(mud_url))
# 1 = agree, 0 = disagree. The statements come in Andrich's order, from most against
# capital punishment to most in favour. No keying: agreement is the response.
statements <- c("HIDEOUS", "LIFESACRED", "INEFFECTIV", "DONTBELIEV",
                "WISHNOTNEC", "MUSTHAVEIT", "DETERRENT", "CRIMDESERV")
mud <- mud[, statements]
c(respondents = nrow(mud), statements = ncol(mud), missing = sum(is.na(mud)))
round(colMeans(mud), 2)               # proportion agreeing with each statement
table(agreements = rowSums(mud))      # how many statements each respondent agreed with

## ---- cor-mud
r <- cor(mud)
round(r, 2)
# DONTBELIEV against the other seven: its largest correlation in absolute value.
round(max(abs(r["DONTBELIEV", -4])), 2)

## ---- runs-mud
# A pattern "unfolds" in an order if its agreements form one unbroken run
# (e.g. 0 1 1 1 0 0 0 0), which is what one ideal point per respondent predicts.
# A run starts wherever a 1 follows a 0 (or opens the pattern); one run = one start.
M <- as.matrix(mud)
n_runs <- function(order) {
  x <- M[, order]
  starts <- x[, 1] + rowSums(x[, -1] == 1 & x[, -ncol(x)] == 0)
  sum(starts == 1)
}
n_runs(statements)                    # in Andrich's order
# Every one of the 8! = 40,320 orders of the statements.
perms <- function(v) if (length(v) == 1) list(v) else
  do.call(c, lapply(seq_along(v), function(i) lapply(perms(v[-i]), function(p) c(v[i], p))))
all_orders <- perms(statements)
runs_all <- vapply(all_orders, n_runs, 0)
c(mean_over_all_orders = round(mean(runs_all), 1), best = max(runs_all))
# The best orders (an order and its reverse count as one).
best <- all_orders[runs_all == max(runs_all)]
unique(t(sapply(best, function(o) if (match("HIDEOUS", o) > 4) rev(o) else o)))

## ---- mudfold-mud
# MUDFOLD (Post, 1992; Balafas et al., 2020) searches for the longest order in which
# triples of statements behave as unfolding predicts, and reports H, the scalability
# coefficient: 1 minus observed over expected errors in those triples.
mf <- mudfold(mud)
s <- summary(mf)
s$SCALE_STATS[c("H(scale)", "O(scale)", "EO(scale)"), ]   # H = 1 - observed / expected errors
s$ITEM_STATS[, c("items", "H(items)")]   # the statements in MUDFOLD's order

## ---- models-mud
# Three models in mirt. "ideal" is mirt's ideal-point item,
# P(agree) = exp(-0.5 * (a * theta + d)^2), which peaks at theta = -d / a.
fits <- list(Rasch = mirt(mud, 1, "Rasch", verbose = FALSE),
             `2PL` = mirt(mud, 1, "2PL", verbose = FALSE),
             ideal = mirt(mud, 1, "ideal", verbose = FALSE))
# The GGUM (Roberts, Donoghue & Laughlin, 2000) with the GGUM package; C = 1 means
# two response categories. capture.output() hides its progress bars.
invisible(capture.output(gg <- GGUM(as.matrix(mud), C = 1)))
comp <- rbind(t(sapply(fits, function(f) c(parameters = extract.mirt(f, "nest"),
                                           logLik = extract.mirt(f, "logLik"),
                                           AIC = extract.mirt(f, "AIC"),
                                           BIC = extract.mirt(f, "BIC")))),
              GGUM = unlist(gg$InformationCrit[c("N.param", "log.L", "AIC", "BIC")]))
round(comp, 1)
# The 2PL's EM stopped at its iteration limit: one slope keeps growing (see below).
sapply(fits, extract.mirt, "converged")

## ---- params-mud
# 2PL slopes a and difficulties b (IRTpars = TRUE converts mirt's d to b = -d / a).
round(coef(fits$`2PL`, IRTpars = TRUE, simplify = TRUE)$items[, c("a", "b")], 2)
# GGUM discriminations and locations; the package caps discriminations at 10.
round(data.frame(alpha = gg$alpha, delta = gg$delta, row.names = statements), 2)
# The ideal-point model's peak, -d / a, for each statement.
ip <- coef(fits$ideal, simplify = TRUE)$items
round(-ip[, "d"] / ip[, "a1"], 2)

## ---- curves-mud
# Each statement's curve under the 2PL, mirt's ideal-point model and the GGUM.
th <- seq(-4, 4, length.out = 201)
p_mirt <- function(f, i) probtrace(extract.item(f, i), matrix(th))[, 2]
p_ggum <- function(i) probs.GGUM(gg$alpha, gg$delta, gg$taus, th, C = 1)[, i, 2]
op <- par(mfrow = c(2, 4), mar = c(3, 3, 2, 1), mgp = c(1.8, 0.6, 0))
for (i in seq_along(statements)) {
  plot(th, p_mirt(fits$`2PL`, i), type = "l", lwd = 2, col = "#2780e3", ylim = c(0, 1),
       xlab = expression(theta), ylab = "P(agree)", main = statements[i], cex.main = 0.9)
  lines(th, p_mirt(fits$ideal, i), lwd = 2, col = "#c2410c")
  lines(th, p_ggum(i), lwd = 2, lty = 2, col = "black")
}
legend("right", c("2PL", "ideal", "GGUM"), col = c("#2780e3", "#c2410c", "black"),
       lty = c(1, 1, 2), lwd = 2, bty = "n", cex = 0.8)
par(op)

## ---- mixed-mud
# The 2PL for seven statements and the ideal-point model for one, each in turn.
mixed <- sapply(seq_along(statements), function(i) {
  types <- rep("2PL", 8); types[i] <- "ideal"
  extract.mirt(mirt(mud, 1, types, verbose = FALSE), "AIC")
})
round(c(all_2PL = extract.mirt(fits$`2PL`, "AIC"), setNames(mixed, statements)), 1)
# How closely do the two models order the respondents?
round(cor(fscores(fits$`2PL`)[, 1], fscores(fits$ideal)[, 1]), 2)

## ---- fetch-eur
eur_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.eurpar2_mudfold/rows?format=csv"
eur <- long2wide(read.csv(eur_url))
parties <- c("communists", "socdemocr", "demprogres", "liberals", "christians", "conservat")
eur <- eur[, parties]
c(respondents = nrow(eur), missing = sum(is.na(eur)))
table(parties_picked = rowSums(eur))   # every activist picked exactly two
colSums(eur)                           # how often each party was picked

## ---- pairs-eur
# How often each pair of parties was picked together.
pairs <- apply(eur, 1, function(x) paste(parties[x == 1], collapse = " + "))
sort(table(pairs), decreasing = TRUE)

## ---- mudfold-eur
mf_eur <- summary(mudfold(eur))
mf_eur$SCALE_STATS["H(scale)", ]
mf_eur$ITEM_STATS[, c("items", "H(items)")]
