# Range restriction and base rates. Part 1 draws a predictor x and a criterion y
# with a known correlation, selects on x (direct restriction) or on a third
# variable z related to both (indirect restriction), and compares the observed,
# case II corrected and true correlations. Part 2 draws a screener and an
# independent criterion and asks how many flagged respondents are cases at two
# base rates. Base R only. New for this course (not in EDUC 252).
set.seed(60)
n     <- 20000   # applicants
rho   <- 0.5     # true correlation between x and y in the applicant pool
keep  <- 0.5     # share selected
rho_z <- 0.7     # for indirect selection: z's correlation with x (and with y's residual)

x <- rnorm(n)
y <- rho * x + sqrt(1 - rho^2) * rnorm(n)
# z is related to x and also to the part of y that x doesn't predict (say, motivation).
z <- rho_z * x + 0.4 * (y - rho * x) / sqrt(1 - rho^2) + sqrt(1 - rho_z^2 - 0.16) * rnorm(n)

# Case II (Thorndike, 1949): u is the ratio of the pool's SD of x to the selected SD.
case2 <- function(r, u) r * u / sqrt(1 - r^2 + r^2 * u^2)
summarize <- function(sel) {
  r <- cor(x[sel], y[sel]); u <- sd(x) / sd(x[sel])
  c(pool = cor(x, y), selected = r, corrected = case2(r, u), u = u)
}
direct   <- x > quantile(x, 1 - keep)
indirect <- z > quantile(z, 1 - keep)
round(rbind(direct = summarize(direct), indirect = summarize(indirect)), 3)

# Part 2: a screener whose scores differ by d SDs between cases and non-cases, with
# a cut at `cut`. Sensitivity and specificity don't depend on the base rate; the
# share of flagged respondents who are cases (the positive predictive value) does.
d   <- 2
cut <- 1.2
screen <- function(prev, n = 100000) {
  case  <- rbinom(n, 1, prev)
  score <- rnorm(n, mean = d * case)
  flag  <- score > cut
  c(prevalence = prev,
    sensitivity = mean(flag[case == 1]), specificity = mean(!flag[case == 0]),
    PPV = mean(case[flag] == 1), flagged = mean(flag))
}
round(rbind(screen(0.03), screen(0.30)), 3)
