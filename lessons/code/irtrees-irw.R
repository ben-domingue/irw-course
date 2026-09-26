# IRTree models with real data: the ten IPIP conscientiousness markers
# (bfi_goldberg_1992_conscientiousness) and eight IPIP extraversion markers with
# response times (introversion_extroversion), from the Item Response Warehouse.
# Needs lme4 (Bates, Maechler, Bolker & Walker, 2015) and mirt (Chalmers, 2012).
# No login or token: every CSV link is pinned to one version of the IRW data.
# The glmer fits take from a few seconds to about a minute; the mirt fit of the
# three-node tree takes one to two minutes.
# Adapted from ben-domingue/252: c8/irtree.R, c8/irtree2.R and ps8/fast.R.

## ---- fetch-csn
library(lme4)
options(digits = 7)  # R's default, in case a .Rprofile changes it
set.seed(51)
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.bfi_goldberg_1992_conscientiousness/rows?format=csv"
df <- read.csv(url)
df <- df[!is.na(df$resp), ]
wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
wide <- wide[complete.cases(wide), paste0("C", 1:10)]
c(respondents = nrow(wide), items = ncol(wide))
# The responses arrive as given: 1 = disagree, 3 = neutral, 5 = agree. C2, C4, C6
# and C8 are worded against conscientiousness. Before keying, their correlations
# with C1 ("I am always prepared") are negative:
round(cor(wide)[1, ], 2)
# Key them (reversing maps k to 6 - k), so that higher = more conscientious.
reversed <- paste0("C", c(2, 4, 6, 8))
wide[, reversed] <- 6 - wide[, reversed]
round(cor(wide)[1, ], 2)
# A random 3,000 respondents keep the fits quick.
x <- wide[sample(nrow(wide), 3000), ]
round(prop.table(table(x)), 3)   # share of responses in each category

## ---- recode
# One row per node a response reaches. Node 1: took a side (1) or chose 3 (0).
# Given a side, node 2: the agree side, 4 or 5 (1), or the disagree side (0); and
# node 3: an extreme response, 1 or 5 (1), or a moderate one (0).
long <- data.frame(id = rep(seq_len(nrow(x)), ncol(x)),
                   item = rep(colnames(x), each = nrow(x)), x = c(x))
sided <- long[long$x != 3, ]
tree <- rbind(
  data.frame(long,  node = "side",      resp = as.integer(long$x != 3)),
  data.frame(sided, node = "direction", resp = as.integer(sided$x > 3)),
  data.frame(sided, node = "extreme",   resp = as.integer(sided$x %in% c(1, 5))))
tree$node <- factor(tree$node, levels = c("side", "direction", "extreme"))  # a factor, not text
tree$item <- factor(tree$item, levels = colnames(x))
# Respondent 1's answers to C1 and C2, and the pseudo-items they become:
x[1, 1:2]
tree[tree$id == 1 & tree$item %in% c("C1", "C2"), c("item", "x", "node", "resp")]
table(tree$node)   # rows per node: every response reaches node 1

## ---- fit-trees
# The same tree with one theta for all three nodes, and with a theta per node.
# Each item has its own easiness at each node (item:node); b = -easiness.
# nAGQ = 0 skips glmer's slowest step; the estimates barely move.
one <- glmer(resp ~ 0 + item:node + (1 | id), data = tree, family = binomial, nAGQ = 0)
per <- glmer(resp ~ 0 + item:node + (0 + node | id), data = tree, family = binomial, nAGQ = 0)
AIC(one, per)

## ---- node-cor
VarCorr(per)   # SDs of the three node thetas and their correlations

## ---- sums
# What do the styles do to the sum score? theta estimates (conditional modes) for
# each respondent, split by where they stand on conscientiousness.
th <- ranef(per)$id
r <- rowSums(x)
high <- th$nodedirection > 1
low <- th$nodedirection < -1
round(c(sum_with_content = cor(r, th$nodedirection),
        sum_with_extreme_if_high = cor(r[high], th$nodeextreme[high]),
        sum_with_extreme_if_low = cor(r[low], th$nodeextreme[low])), 2)
c(high = sum(high), low = sum(low))

## ---- aic-mirt
# Can the tree's AIC be compared with the GRM's? Fit both by the same method: mirt,
# which integrates over theta by quadrature. The tree becomes 30 pseudo-items (NA
# where a response doesn't reach a node), each loading on its node's dimension with
# a slope fixed at 1; the three dimensions have free variances and correlations.
pseudo <- data.frame(ifelse(x == 3, 0, 1),
                     ifelse(x == 3, NA, 1 * (x > 3)),
                     ifelse(x == 3, NA, 1 * (x == 1 | x == 5)))
names(pseudo) <- paste0(rep(c("side_", "dir_", "ext_"), each = 10), colnames(x))
spec <- mirt::mirt.model("side = 1-10\n dir = 11-20\n ext = 21-30\n COV = side*dir*ext")
tree_mirt <- mirt::mirt(pseudo, spec, itemtype = "Rasch", verbose = FALSE)
tree_mirt1 <- mirt::mirt(pseudo, 1, itemtype = "Rasch", verbose = FALSE)  # one theta
grm <- mirt::mirt(as.data.frame(x), 1, itemtype = "graded", verbose = FALSE)
fits <- list(tree_mirt1, tree_mirt, grm)
data.frame(parameters = c(attr(logLik(one), "df"), attr(logLik(per), "df"),
                          sapply(fits, mirt::extract.mirt, "nest")),
           logLik = round(c(logLik(one), logLik(per), sapply(fits, mirt::extract.mirt, "logLik"))),
           AIC = round(c(AIC(one), AIC(per), sapply(fits, mirt::extract.mirt, "AIC"))),
           row.names = c("tree, one theta, glmer", "tree, theta per node, glmer",
                         "tree, one theta, mirt", "tree, theta per node, mirt", "GRM, mirt"))

## ---- fetch-ie
url_ie <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse:v60_0.introversion_extroversion/rows?format=csv"
ie <- read.csv(url_ie)
c(respondents = length(unique(ie$id)), items = length(unique(ie$item)))
round(quantile(ie$rt, c(0.1, 0.5, 0.9)), 1)   # seconds per item, all 91 items
# Items 81-85 and 89-91 are eight of the ten IPIP extraversion markers. 81-85 are
# worded toward introversion, so we key them: higher = more extraverted.
e <- ie[ie$item %in% c(81:85, 89:91), ]
e$x <- ifelse(e$item %in% 81:85, 6 - e$resp, e$resp)
e$fast <- as.integer(e$rt < 2)
round(c(share_fast = mean(e$fast),
        median_rt = median(e$rt)), 2)
round(tapply(e$x == 3, e$fast, mean), 3)   # share choosing 3, slow (0) and fast (1)

## ---- speed-tree
# Two nodes, after ps8/fast.R: was the response fast (under 2 seconds)? If not,
# was it on the extraverted side (keyed 4 or 5)? Fast responses stop at node 1.
ids <- sample(unique(e$id), 1500)
s <- e[e$id %in% ids, ]
slow <- s[s$fast == 0, ]
st <- rbind(data.frame(id = s$id, item = s$item, node = "fast", resp = s$fast),
            data.frame(id = slow$id, item = slow$item, node = "trait",
                       resp = as.integer(slow$x >= 4)))
st$node <- factor(st$node, levels = c("fast", "trait"))
st$item <- factor(st$item)
speed <- glmer(resp ~ 0 + item:node + (0 + node | id), data = st, family = binomial, nAGQ = 0)
VarCorr(speed)

## ---- fast-consistent
# Do fast responses carry the trait? Each respondent's mean keyed response on their
# fast items against the mean on their slow items.
m_fast <- tapply(e$x[e$fast == 1], e$id[e$fast == 1], mean)
m_slow <- tapply(e$x[e$fast == 0], e$id[e$fast == 0], mean)
both <- intersect(names(m_fast), names(m_slow))
c(respondents_with_both = length(both), r = round(cor(m_fast[both], m_slow[both]), 2))
