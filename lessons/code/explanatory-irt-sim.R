# Simulate responses from an LLTM whose items also have a residual of their own,
# then fit the Rasch model, the LLTM and the LLTM with random items with lme4.
# The items follow a design like the verbal aggression items: two modes, three
# behaviours, two situations, two items per cell.
#
# nAGQ = 0 makes glmer() skip its slowest step, so all three fits take seconds in
# the browser; the estimates barely move. In your own R session, delete
# ", nAGQ = 0" to get the full Laplace fit (about a minute here).
library(lme4)
set.seed(48)
np <- 300        # respondents
sd_item <- 0.3   # SD of the item residual; 0 means the design explains the items fully

items <- expand.grid(rep = 1:2, mode = c("do", "want"),
                     behav = c("curse", "scold", "shout"), situ = c("other", "self"))
items$item <- sprintf("i%02d", seq_len(nrow(items)))
X <- model.matrix(~ mode + behav + situ, items)
eta <- c(1, 0.7, -1, -2, -1)   # true intercept and design effects (on easiness)
items$easy <- drop(X %*% eta) + rnorm(nrow(items), 0, sd_item)

theta <- rnorm(np, 0, 1.3)
d <- merge(expand.grid(id = seq_len(np), item = items$item), items)
d$resp <- rbinom(nrow(d), 1, plogis(theta[d$id] + d$easy))

rasch  <- glmer(resp ~ 0 + item + (1 | id), d, binomial, nAGQ = 0)
lltm   <- glmer(resp ~ mode + behav + situ + (1 | id), d, binomial, nAGQ = 0)
lltm_r <- glmer(resp ~ mode + behav + situ + (1 | id) + (1 | item), d, binomial, nAGQ = 0)

cat("Design effects: truth and estimates\n")
print(round(cbind(true = eta, LLTM = fixef(lltm), "LLTM + residual" = fixef(lltm_r)), 2))

e <- fixef(rasch)[paste0("item", items$item)]
cat("\nShare of the Rasch easiness variance the design explains:",
    round(cor(e, drop(X %*% fixef(lltm)))^2, 2), "\n")

lr <- anova(lltm, rasch)
cat(sprintf("Likelihood-ratio test, LLTM against Rasch: chi-squared %.1f on %d df, p = %.3g\n",
            lr$Chisq[2], lr$Df[2], lr$`Pr(>Chisq)`[2]))
cat(sprintf("Item residual SD: true %.2f, estimated %.2f\n", sd_item,
            attr(VarCorr(lltm_r)$item, "stddev")))
