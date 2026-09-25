# Generalizability theory with real data: variance components and D studies for
# cleverness ratings of alternate-uses responses (persons x tasks x raters, fully
# crossed) and for teachers' ratings of student essays (essays x criteria x raters,
# sparse). Needs lme4 (Bates, Maechler, Bolker & Walker, 2015); no login or token.
# Both CSV links are pinned to one version of the IRW data. The essay fit takes
# about half a minute.

## ---- helpers
library(lme4)
options(digits = 7)  # R's default, in case a .Rprofile changes it
# Variance components from a crossed random-effects fit, with their shares of the
# total. `labels` renames lme4's grouping factors (id, item, rater and their
# interactions) to the facets of the design.
components <- function(fit, labels) {
  vc <- as.data.frame(VarCorr(fit))
  v <- setNames(vc$vcov, labels[vc$grp])[labels]
  data.frame(variance = round(v, 3), percent = round(100 * v / sum(v), 1))
}
# G coefficients for a D study that averages over n_i levels of the first facet
# (tasks, or criteria) and n_r raters. v holds the seven components in the order
# p, i, r, pi, pr, ir, residual.
g_coef <- function(v, n_i, n_r) {
  rel <- v[4] / n_i + v[5] / n_r + v[7] / (n_i * n_r)
  abs <- rel + v[2] / n_i + v[3] / n_r + v[6] / (n_i * n_r)
  c(relative = v[1] / (v[1] + rel), absolute = v[1] / (v[1] + abs))
}
labels <- c(id = "person", item = "task", rater = "rater", "id:item" = "person x task",
            "id:rater" = "person x rater", "item:rater" = "task x rater",
            Residual = "residual (p x t x r, e)")
form <- resp ~ 1 + (1 | id) + (1 | item) + (1 | rater) +
  (1 | id:item) + (1 | id:rater) + (1 | item:rater)

## ---- fetch-clever
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_2:v22_0.Forthmann-2024-cleverness_ratings/rows?format=csv"
cl <- read.csv(url)[, c("id", "item", "rater", "resp")]
c(respondents = length(unique(cl$id)), tasks = length(unique(cl$item)),
  raters = length(unique(cl$rater)), ratings = nrow(cl),
  missing = length(unique(cl$id)) * 3 * 5 - nrow(cl))
table(cl$resp)   # cleverness, 1 to 5; higher = cleverer

## ---- fit-clever
fit_cl <- lmer(form, data = cl)
vc_cl <- components(fit_cl, labels)
vc_cl

## ---- dstudy-clever
v_cl <- vc_cl$variance
round(g_coef(v_cl, 3, 5), 2)     # the design as run: 3 tasks, 5 raters
round(g_coef(v_cl, 3, 1), 2)     # 3 tasks, 1 rater
round(g_coef(v_cl, 6, 1), 2)     # 6 tasks, 1 rater
round(g_coef(v_cl, 3, 1e6), 2)   # 3 tasks, as many raters as you like
d_grid <- expand.grid(tasks = 1:10, raters = c(1, 2, 5))
d_grid$relative <- mapply(function(t, r) g_coef(v_cl, t, r)[1], d_grid$tasks, d_grid$raters)

## ---- plot-clever
cols <- c("1" = "#93c5fd", "2" = "#2780e3", "5" = "#c2410c")
plot(NULL, xlim = c(1, 10), ylim = c(0, 1), xlab = "Tasks averaged over",
     ylab = "Relative G coefficient", las = 1, main = "Cleverness ratings: a D study")
for (r in c(1, 2, 5)) with(d_grid[d_grid$raters == r, ],
                           lines(tasks, relative, type = "b", pch = 19, lwd = 2, col = cols[as.character(r)]))
abline(h = 0.8, col = "#999", lty = 2)
legend("bottomright", paste(c(1, 2, 5), c("rater", "raters", "raters")), col = cols,
       lwd = 2, pch = 19, bty = "n")

## ---- fetch-essays
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_4:v7_0.teacherjudgements_lohmann_2026_essayratings/rows?format=csv"
es <- read.csv(url)
# The table also holds an expert benchmark score for every essay and criterion;
# the G study is about the teachers, so set it aside.
es <- es[es$rater != "expert_benchmark", c("id", "item", "rater", "resp")]
c(essays = length(unique(es$id)), criteria = length(unique(es$item)),
  teachers = length(unique(es$rater)), ratings = nrow(es))
table(es$resp)   # 1 (very low quality) to 7 (very high quality)
pairs <- unique(es[, c("id", "rater")])
table(table(pairs$rater))   # essays per teacher
table(table(pairs$id))      # teachers per essay

## ---- fit-essays
# The default optimizer stops just short of lme4's convergence tolerance on this
# fit; bobyqa converges and gives the same estimates to three decimals.
fit_es <- lmer(form, data = es, control = lmerControl(optimizer = "bobyqa"))
vc_es <- components(fit_es, sub("t x r", "c x r", sub("task", "criterion", labels)))
vc_es

## ---- dstudy-essays
v_es <- vc_es$variance
sapply(c(1, 2, 3, 5), function(r) round(g_coef(v_es, 4, r), 2))   # 4 criteria, 1-5 raters
round(g_coef(v_es, 1e6, 1), 2)    # one rater, as many criteria as you like
round(sqrt(v_es[c(1, 3)]), 2)     # SD of essays' universe scores; SD of teachers' severity

## ---- ptask
# The one-facet design. Average each person's five ratings of a task, which leaves
# a persons x tasks table with one score per cell (201 respondents rated on all three).
pt <- tapply(cl$resp, list(cl$id, cl$item), mean)
pt <- pt[complete.cases(pt), ]
n_p <- nrow(pt); n_i <- ncol(pt)
long <- data.frame(y = c(pt), p = factor(rep(rownames(pt), n_i)), i = factor(rep(colnames(pt), each = n_p)))
ms <- anova(lm(y ~ p + i, data = long))[["Mean Sq"]]   # persons, tasks, residual
names(ms) <- c("persons", "tasks", "residual")
round(ms, 4)
s2_p <- (ms["persons"] - ms["residual"]) / n_i          # sigma^2_p from the EMS
s2_pi <- ms["residual"]                                  # sigma^2_pi,e
anova_route <- c(s2_p, s2_pi, s2_p / (s2_p + s2_pi / n_i))
alpha <- (n_i / (n_i - 1)) * (1 - sum(apply(pt, 2, var)) / var(rowSums(pt)))
fit_pt <- lmer(y ~ 1 + (1 | p) + (1 | i), data = long)
v <- as.data.frame(VarCorr(fit_pt))
lme4_route <- c(v$vcov[v$grp == "p"], v$vcov[v$grp == "Residual"])
routes <- rbind(anova = anova_route, lme4 = c(lme4_route, lme4_route[1] / (lme4_route[1] + lme4_route[2] / n_i)))
colnames(routes) <- c("person", "residual (p x t, e)", "G coefficient")
round(routes, 4)
round(c(alpha = alpha), 4)
