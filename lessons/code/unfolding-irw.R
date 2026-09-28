# Unfolding models with real data: ten immigration-policy statements put to 2,621 US
# respondents (Duck-Mayr & Montgomery, 2023), Andrich's (1988) eight capital-punishment
# statements (andrich_mudfold), European party activists' pick-2-of-6 choices
# (eurpar2_mudfold) and roll calls in the 118th U.S. Senate (rollcall_senate). Needs
# the mirt, GGUM and mudfold packages. No login or token needed. The whole file takes
# about five minutes in local R, most of it the held-out comparison, the GGUM fits and
# the Senate 2PL. Adapted from ben-domingue/252: ps9/unfold.R.

## ---- fetch-imm
library(mirt)
library(GGUM)
library(mudfold)
options(digits = 7)  # R's default, in case a .Rprofile changes it
set.seed(52)
# IRW tables are long (one row per response); reshape to one row per respondent.
long2wide <- function(df) {
  wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
  as.data.frame(wide)
}
# Interim copy: the table isn't public on the IRW yet, so the course keeps a copy
# (see data/duckmayr_2023_immigration.md). Outside the course repo, read it from GitHub.
imm_path <- "data/duckmayr_2023_immigration.csv"
if (!file.exists(imm_path))
  imm_path <- "https://raw.githubusercontent.com/ben-domingue/irw-course/main/lessons/data/duckmayr_2023_immigration.csv"
imm_long <- read.csv(imm_path)
imm <- long2wide(imm_long)[, paste0("IMM_", 1:10)]
# 0 = strongly disagree ... 4 = strongly agree, the same way for every statement.
# Nothing is reverse-keyed: which way a statement runs is the question.
c(respondents = nrow(imm), statements = ncol(imm), missing = sum(is.na(imm)))
# Self-placed ideology, 1 = very liberal, 4 = moderate, 7 = very conservative.
ideology <- tapply(imm_long$cov_ideology, imm_long$id, function(x) x[1])[rownames(imm)]
table(ideology, useNA = "ifany")

## ---- ideo-imm
# Share agreeing (somewhat or strongly, resp >= 3) with each statement, by ideology.
agree_by_ideo <- sapply(imm, function(x) tapply(x >= 3, ideology, mean, na.rm = TRUE))
round(t(agree_by_ideo), 2)

## ---- plot-imm
cols <- c(IMM_1 = "#c2410c", IMM_2 = "black", IMM_3 = "#2780e3")
matplot(1:7, agree_by_ideo[, names(cols)], type = "b", pch = 19, lty = 1, lwd = 2,
        col = cols, ylim = c(0, 1.3), xaxt = "n", yaxt = "n", xlab = "Self-placed ideology",
        ylab = "Share agreeing")
axis(2, at = seq(0, 1, 0.2))
axis(1, at = 1:7, labels = c("very\nliberal", "2", "3", "moderate", "5", "6", "very\nconservative"),
     padj = 0.5, cex.axis = 0.8)
legend("top", c("IMM_1 (all must return)", "IMM_2 (stay, with requirements)",
                "IMM_3 (no wall needed)"), col = cols, lwd = 2, pch = 19, bty = "n", cex = 0.85)

## ---- cor-imm
r_imm <- cor(imm, use = "pairwise.complete.obs")
round(r_imm["IMM_2", c("IMM_1", "IMM_3", "IMM_7")], 2)   # the middle against the ends
round(r_imm["IMM_1", "IMM_3"], 2)                         # the two ends

## ---- models-imm
# The GRM (dominance, slopes free to be negative) and the GGUM (ideal point), both in
# mirt. The GGUM likelihood has poor local maxima, so we start each statement's
# location at the mean GRM score of the respondents who agreed with it, oriented so
# that IMM_1 ("all must return") is on the positive side, as Duck-Mayr and
# Montgomery anchored it. mirt keeps the GGUM's discriminations positive.
fit_imm <- function(dat, types) {
  grm <- mirt(dat, 1, "graded", verbose = FALSE)
  th <- fscores(grm)[, 1]
  start <- sapply(dat, function(x) mean(th[!is.na(x) & x >= 3]))
  if (start["IMM_1"] < 0) start <- -start
  sv <- mirt(dat, 1, types, pars = "values")
  b1 <- sv$name == "b1"
  sv$value[b1] <- 2 * start[sv$item[b1]]
  mirt(dat, 1, types, pars = sv, verbose = FALSE)
}
# A third model gives an ideal-point curve only to the four statements that, read
# for their content, stake out a compromise (IMM_2, IMM_4, IMM_6, IMM_8), and a
# dominance curve to the rest.
compromise <- c("IMM_2", "IMM_4", "IMM_6", "IMM_8")
mixed_types <- ifelse(names(imm) %in% compromise, "ggum", "graded")
fits_imm <- list(GRM = mirt(imm, 1, "graded", verbose = FALSE),
                 GGUM = fit_imm(imm, "ggum"),
                 mixed = fit_imm(imm, mixed_types))
round(t(sapply(fits_imm, function(f) c(parameters = extract.mirt(f, "nest"),
                                       logLik = extract.mirt(f, "logLik"),
                                       AIC = extract.mirt(f, "AIC"),
                                       BIC = extract.mirt(f, "BIC")))), 1)
# GGUM locations (b1), from the "all must return" end to the "no wall" end.
round(sort(coef(fits_imm$GGUM, simplify = TRUE)$items[, "b1"], decreasing = TRUE), 2)
# How well each model's scores track self-placed ideology (the sign of the GRM's
# scale is arbitrary, so we look at the size).
round(sapply(fits_imm, function(f) abs(cor(fscores(f)[, 1], ideology, use = "complete.obs"))), 2)

## ---- heldout-imm
# Out of sample: hold out a random 10% of the responses, fit each model to the rest,
# and score the held-out responses with the log probability each model gave them.
M <- as.matrix(imm)
obs <- which(!is.na(M))
hold <- sample(obs, round(0.1 * length(obs)))
train <- M
train[hold] <- NA
train <- as.data.frame(train)
fits_train <- list(GRM = mirt(train, 1, "graded", verbose = FALSE),
                   GGUM = fit_imm(train, "ggum"),
                   mixed = fit_imm(train, mixed_types))
i_row <- row(M)[hold]
i_col <- col(M)[hold]
heldout_ll <- sapply(fits_train, function(f) {
  th <- fscores(f)[, 1]
  mapply(function(i, j) log(probtrace(extract.item(f, j), matrix(th[i]))[1, M[i, j] + 1]),
         i_row, i_col)
})
# Mean log probability per held-out response (closer to 0 is better). The baseline
# predicts each statement's category shares, ignoring the respondent.
shares <- apply(train, 2, function(x) prop.table(table(factor(x, levels = 0:4))))
round(c(baseline = mean(log(shares[cbind(M[hold] + 1, i_col)])), colMeans(heldout_ll)), 4)
# Differences from the GRM, with standard errors over the held-out responses.
d <- heldout_ll[, c("GGUM", "mixed")] - heldout_ll[, "GRM"]
round(rbind(mean = colMeans(d), se = apply(d, 2, sd) / sqrt(nrow(d))), 4)
# By statement: where does the GGUM predict better (positive) or worse than the GRM?
round(sort(tapply(d[, "GGUM"], colnames(M)[i_col], mean)), 3)

## ---- fetch-mud
mud_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.andrich_mudfold/rows?format=csv"
mud <- long2wide(read.csv(mud_url))
# 1 = agree, 0 = disagree. The statements come in Andrich's order, from most against
# capital punishment to most in favour.
statements <- c("HIDEOUS", "LIFESACRED", "INEFFECTIV", "DONTBELIEV",
                "WISHNOTNEC", "MUSTHAVEIT", "DETERRENT", "CRIMDESERV")
mud <- mud[, statements]
c(respondents = nrow(mud), statements = ncol(mud), missing = sum(is.na(mud)))
r_mud <- cor(mud)
round(r_mud["LIFESACRED", "CRIMDESERV"], 2)             # two ends
round(max(abs(r_mud["DONTBELIEV", -4])), 2)              # DONTBELIEV's largest |r|

## ---- runs-mud
# A pattern "unfolds" in an order if its agreements form one unbroken run
# (e.g. 0 1 1 1 0 0 0 0), which is what one ideal point per respondent predicts.
# A run starts wherever a 1 follows a 0 (or opens the pattern); one run = one start.
X <- as.matrix(mud)
n_runs <- function(order) {
  x <- X[, order]
  starts <- x[, 1] + rowSums(x[, -1] == 1 & x[, -ncol(x)] == 0)
  sum(starts == 1)
}
n_runs(statements)                    # in Andrich's order
# Every one of the 8! = 40,320 orders of the statements.
perms <- function(v) if (length(v) == 1) list(v) else
  do.call(c, lapply(seq_along(v), function(i) lapply(perms(v[-i]), function(p) c(v[i], p))))
runs_all <- vapply(perms(statements), n_runs, 0)
c(mean_over_all_orders = round(mean(runs_all), 1), best = max(runs_all))

## ---- models-mud
# Three models in mirt ("ideal" is mirt's ideal-point item,
# P(agree) = exp(-0.5 * (a * theta + d)^2)), and the GGUM with the GGUM package
# (C = 1: two response categories; capture.output() hides its progress bars).
fits_mud <- list(Rasch = mirt(mud, 1, "Rasch", verbose = FALSE),
                 `2PL` = mirt(mud, 1, "2PL", verbose = FALSE),
                 ideal = mirt(mud, 1, "ideal", verbose = FALSE))
invisible(capture.output(gg <- GGUM(as.matrix(mud), C = 1)))
round(rbind(t(sapply(fits_mud, function(f) c(parameters = extract.mirt(f, "nest"),
                                             logLik = extract.mirt(f, "logLik"),
                                             AIC = extract.mirt(f, "AIC"),
                                             BIC = extract.mirt(f, "BIC")))),
            GGUM = unlist(gg$InformationCrit[c("N.param", "log.L", "AIC", "BIC")])), 1)
# 2PL slopes: negative for the statements against, positive for those in favour.
# (The 2PL's EM stops at its iteration limit: CRIMDESERV's slope keeps growing.)
round(coef(fits_mud$`2PL`, IRTpars = TRUE, simplify = TRUE)$items[, "a"], 2)

## ---- fetch-eur
eur_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.eurpar2_mudfold/rows?format=csv"
eur <- long2wide(read.csv(eur_url))
parties <- c("communists", "socdemocr", "demprogres", "liberals", "christians", "conservat")
eur <- eur[, parties]
c(respondents = nrow(eur), missing = sum(is.na(eur)))
table(parties_picked = rowSums(eur))   # every activist picked exactly two
# How often each pair of parties was picked together.
pairs <- apply(eur, 1, function(x) paste(parties[x == 1], collapse = " + "))
sort(table(pairs), decreasing = TRUE)

## ---- mudfold-eur
# MUDFOLD (van Schuur, 1992; Balafas et al., 2020) looks for the longest order in
# which triples of parties behave as unfolding predicts. H = 1 - observed / expected
# errors in those triples.
mf_eur <- summary(mudfold(eur))
mf_eur$SCALE_STATS["H(scale)", ]
mf_eur$ITEM_STATS[, c("items", "H(items)")]   # the parties in MUDFOLD's order

## ---- fetch-senate
# Every roll call in the 118th Senate (2023-24): 1 = yea, 0 = nay; present and not
# voting are missing. Item ids are <congress>_<session>_<roll call>.
sen_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_6:v3_7.rollcall_senate/rows?format=csv"
sen_long <- read.csv(sen_url)
sen_long <- sen_long[startsWith(sen_long$item, "118_"), ]
sen <- long2wide(sen_long)
party <- tapply(sen_long$cov_party, sen_long$id, function(x) paste(unique(x), collapse = "/"))[rownames(sen)]
c(senators = nrow(sen), roll_calls = ncol(sen))
# Drop senators who cast fewer than 50 votes (two appointed in the last weeks) and
# near-unanimous votes (under 2.5% on the losing side), which say little about
# where anyone stands.
minority <- sapply(sen, function(x) min(mean(x, na.rm = TRUE), 1 - mean(x, na.rm = TRUE)))
sen <- sen[rowSums(!is.na(sen)) >= 50, minority >= 0.025]
party <- party[rownames(sen)]
c(senators = nrow(sen), roll_calls = ncol(sen), missing = round(mean(is.na(sen)), 3))
table(party)   # D/I: changed from Democrat to independent during the Congress
# The question for each vote, as the Senate recorded it (IRW item text).
txt_url <- "https://redivis.com/api/v1/tables/datapages.irw_text_3:v1_2.rollcall_senate__items/rows?format=csv"
txt <- read.csv(txt_url)
txt <- txt[txt$resp == 1, ]
question <- setNames(txt$item_text, txt$item)[names(sen)]

## ---- fit-senate
# A 2PL whose slopes may be negative. On a party-line vote the parties separate
# perfectly and the slope can grow without bound, so normal priors keep the slopes
# and intercepts finite (a Bayesian fit of the same model is Clinton, Jackman and
# Rivers's). Takes about 40 seconds.
J <- ncol(sen)
spec <- mirt.model(sprintf("F = 1-%d\nPRIOR = (1-%d, a1, norm, 0, 2), (1-%d, d, norm, 0, 4)", J, J, J))
fit_sen <- mirt(sen, spec, "2PL", quadpts = 31, verbose = FALSE)
theta <- fscores(fit_sen)[, 1]
slope <- coef(fit_sen, simplify = TRUE)$items[, "a1"]
# The direction of theta is arbitrary; point it so that Republicans are positive.
if (mean(theta[party == "R"]) < 0) { theta <- -theta; slope <- -slope }
round(t(sapply(split(theta, party), range)), 2)
# Nominations against everything else: which side is the yea on?
kind <- ifelse(grepl("PN[0-9]", question), "nomination", "other")
table(slope = ifelse(slope > 0, "yea to the right", "yea to the left"), kind)

## ---- screen-senate
# For each vote, a logistic regression on theta with and without a squared term,
# as in "Where CTT breaks". A vote whose curve rises and falls gets a negative
# squared term, a peak inside the range of theta, and a better AIC.
screen <- t(sapply(sen, function(y) {
  m1 <- suppressWarnings(glm(y ~ theta, binomial))
  m2 <- suppressWarnings(glm(y ~ theta + I(theta^2), binomial))
  b <- coef(m2)
  c(AIC_gain = AIC(m1) - AIC(m2), squared = unname(b[3]), peak = unname(-b[2] / (2 * b[3])))
}))
peaked <- screen[, "AIC_gain"] > 10 & screen[, "squared"] < 0 &
  screen[, "peak"] > min(theta) & screen[, "peak"] < max(theta)
sum(peaked)
top <- screen[peaked, ][order(-screen[peaked, "AIC_gain"]), ]
data.frame(round(top, 2), question = substr(question[rownames(top)], 1, 70))

## ---- plot-fisa
# Final passage of the FISA reauthorization, 19 April 2024: each senator's vote
# against theta, with the linear and squared logistic curves.
fisa <- "118_2_00150"
y <- sen[[fisa]]
table(party, vote = c("nay", "yea")[y + 1], useNA = "ifany")
# Median theta of each party's yeas and nays.
round(tapply(theta, list(party, vote = c("nay", "yea")[y + 1]), median), 2)
grid_th <- seq(min(theta), max(theta), length.out = 200)
m1 <- glm(y ~ theta, binomial)
m2 <- glm(y ~ theta + I(theta^2), binomial)
op <- par(mar = c(4, 4, 1, 1))
plot(theta, jitter(y, 0.15), pch = 19, las = 1, ylim = c(-0.1, 1.1),
     col = ifelse(party == "R", "#c2410c", ifelse(party == "D", "#2780e3", "black")),
     xlab = expression(theta ~ "(2PL, Republicans positive)"), ylab = "Voted yea")
lines(grid_th, predict(m1, data.frame(theta = grid_th), type = "response"), lwd = 2, lty = 2)
lines(grid_th, predict(m2, data.frame(theta = grid_th), type = "response"), lwd = 2)
legend(-1.3, 0.5, c("Democrat", "Republican", "independent", "linear", "with squared term"),
       col = c("#2780e3", "#c2410c", "black", "black", "black"), pch = c(19, 19, 19, NA, NA),
       lty = c(NA, NA, NA, 2, 1), lwd = 2, bty = "n", cex = 0.85)
par(op)
