# Simulate responses from the DINA model, fit it with GDINA (Ma & de la Torre, 2020),
# and compare the estimates and classifications with the truth. Then misstate one
# entry of the Q-matrix and see where the misfit goes.
library(GDINA)
set.seed(49)

n <- 1000   # respondents
# Ten items, three attributes. Each attribute has an item that needs it alone.
Q <- matrix(c(1,0,0,  0,1,0,  0,0,1,  1,1,0,  1,0,1,
              0,1,1,  1,1,1,  1,0,0,  0,1,0,  0,0,1), ncol = 3, byrow = TRUE,
            dimnames = list(paste0("item", 1:10), paste0("A", 1:3)))
profiles <- as.matrix(expand.grid(A1 = 0:1, A2 = 0:1, A3 = 0:1))   # all 2^3 = 8
share <- rep(1 / 8, 8)                                              # how common each is
guess <- runif(10, 0.05, 0.25)
slip  <- runif(10, 0.05, 0.25)

alpha <- profiles[sample(8, n, replace = TRUE, prob = share), ]
# eta = 1 when a respondent has every attribute the item needs
eta <- (alpha %*% t(Q)) == matrix(rowSums(Q), n, 10, byrow = TRUE)
p <- ifelse(eta, 1 - matrix(slip, n, 10, byrow = TRUE), matrix(guess, n, 10, byrow = TRUE))
X <- matrix(rbinom(n * 10, 1, p), n, 10, dimnames = list(NULL, rownames(Q)))

fit <- GDINA(X, Q, model = "DINA", verbose = 0)
gs <- coef(fit, "gs")
print(round(cbind(guess_true = guess, guess_est = gs[, "guessing"],
                  slip_true = slip, slip_est = gs[, "slip"]), 2))

# Classification: each respondent's most probable profile
map <- personparm(fit, "MAP")[, 1:3]
cat("\nAttribute-by-attribute agreement with the truth:", round(colMeans(map == alpha), 3), "\n")
cat("Whole profile right:", round(mean(rowSums(map == alpha) == 3), 3), "\n")

# The saturated G-DINA model frees every combination of an item's attributes
fit_g <- GDINA(X, Q, model = "GDINA", verbose = 0)
cat("\nAIC: DINA", round(AIC(fit)), " G-DINA", round(AIC(fit_g)), "\n")

# Misstate one entry: tell the model item 4 needs only A1 (it needs A1 and A2)
Q_wrong <- Q
Q_wrong[4, "A2"] <- 0
fit_w <- GDINA(X, Q_wrong, model = "DINA", verbose = 0)
cat("\nItem 4, true Q:  guess", round(gs[4, "guessing"], 2), " slip", round(gs[4, "slip"], 2), "\n")
gw <- coef(fit_w, "gs")
cat("Item 4, wrong Q: guess", round(gw[4, "guessing"], 2), " slip", round(gw[4, "slip"], 2), "\n")
cat("AIC: true Q", round(AIC(fit)), " wrong Q", round(AIC(fit_w)), "\n")
