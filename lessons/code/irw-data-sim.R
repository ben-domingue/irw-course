# Simulate item responses in IRW format, reshape them, and take a first look.
# Each respondent has a propensity to say yes; each item has its own popularity.
# With a spread of propensities, items hang together; with none, they don't.
# Base R only. Adapted from ben-domingue/252: c1/irw_data_exploration.R.
set.seed(252)
n_resp  <- 500    # respondents
n_items <- 10     # items
spread  <- 1      # SD of the respondents' propensities (try 0, then 2)

propensity <- rnorm(n_resp, 0, spread)
popularity <- seq(-1.5, 1.5, length.out = n_items)   # easy-to-endorse items at the top

# Long format, as the IRW stores it: one row per response.
df <- expand.grid(id = 1:n_resp, item = sprintf("item%02d", 1:n_items), stringsAsFactors = FALSE)
p  <- plogis(propensity[df$id] + popularity[match(df$item, sprintf("item%02d", 1:n_items))])
df$resp <- rbinom(nrow(df), 1, p)
df <- df[sample(nrow(df)), ]                       # row order carries no information
head(df)

# Delete 5% of responses at random: in long format, a missing response is a missing row.
df <- df[runif(nrow(df)) > 0.05, ]

# Wide format: one row per respondent. The deleted rows reappear as NA cells.
wide <- tapply(df$resp, list(df$id, df$item), function(x) x[1])
wide <- as.data.frame(wide[, order(colnames(wide))])
cat("long rows:", nrow(df), "  wide:", nrow(wide), "x", ncol(wide),
    "  empty cells:", sum(is.na(wide)), "\n")

# The first look: missingness, item means, sum scores, item-rest correlations.
# (With missing cells, the sum counts only the items a respondent answered.)
tot <- rowSums(wide, na.rm = TRUE)
look <- data.frame(
  missing   = colMeans(is.na(wide)),
  mean      = colMeans(wide, na.rm = TRUE),
  item_rest = sapply(names(wide), function(i)
    cor(wide[[i]], tot - ifelse(is.na(wide[[i]]), 0, wide[[i]]), use = "complete.obs")))
print(round(look, 2))
hist(tot, breaks = seq(-0.5, n_items + 0.5, 1), col = "#2780e3", border = "white",
     main = paste("Sum scores, spread =", spread), xlab = "Number of yes responses")
cat("median item-rest correlation:", round(median(look$item_rest), 2), "\n")
