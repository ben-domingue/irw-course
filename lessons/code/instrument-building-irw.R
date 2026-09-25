# From construct map to items: the pilot. The Rosenberg Self-Esteem Scale (RSES) as
# answered by 1,238 Chinese medical students (song_2023_rses in the Item Response
# Warehouse; Song et al., 2023, PLOS ONE, doi:10.1371/journal.pone.0284335). Runs
# as-is in base R; no packages, login or token needed. New for this course (EDUC 252
# c2 discusses reverse-worded items; this analysis is not in the 252 code).

## ---- fetch
# The IRW table, from the CSV link on its landing page (pinned to one version).
url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_3:v7_0.song_2023_rses/rows?format=csv"
df <- read.csv(url)
x <- tapply(df$resp, list(df$id, df$item), function(v) v[1])
x <- x[, paste0("RSES", 1:10)]         # items in the order of the published scale
c(respondents = nrow(x), complete = sum(complete.cases(x)))
table(df$resp)                         # 1 to 4
# Rosenberg's wording: items 3, 5, 8, 9 and 10 are worded against self-esteem.
neg <- paste0("RSES", c(3, 5, 8, 9, 10))

## ---- keying
alpha <- function(m) { k <- ncol(m); k / (k - 1) * (1 - sum(apply(m, 2, var)) / var(rowSums(m))) }
# Summed as stored, the table gives the mean, SD and alpha Song et al. report
# (29.92, 4.79 and 0.863), so what we have are the authors' scored responses.
s <- rowSums(x)
sprintf("mean %.2f, SD %.2f, alpha %.3f", mean(s), sd(s), alpha(x))
# If items 3, 5, 9 and 10 had *not* been reversed, alpha would be far lower:
flip <- function(m, items) { m[, items] <- 5 - m[, items]; m }
sprintf("alpha with items 3, 5, 9 and 10 un-reversed: %.3f", alpha(flip(x, paste0("RSES", c(3, 5, 9, 10)))))

## ---- itemrest
item_rest <- sapply(colnames(x), function(i) cor(x[, i], rowSums(x[, colnames(x) != i])))
data.frame(mean = round(colMeans(x), 2), item_rest = round(item_rest, 2),
           worded = ifelse(colnames(x) %in% neg, "against", "for"))

## ---- blocks
r <- cor(x)
pos  <- paste0("RSES", c(1, 2, 4, 6, 7))
neg4 <- paste0("RSES", c(3, 5, 9, 10))     # the negatively worded items other than 8
mean_r <- function(a, b) { v <- r[a, b]; if (identical(a, b)) mean(v[upper.tri(v)]) else mean(v) }
round(c(within_positive = mean_r(pos, pos), within_negative = mean_r(neg4, neg4),
        across = mean_r(pos, neg4)), 2)
round(range(r[pos, neg4]), 2)

## ---- heatmap
ord <- c(pos, "RSES8", neg4)
image(1:10, 1:10, r[ord, rev(ord)], zlim = c(0, 1), axes = FALSE, xlab = "", ylab = "",
      col = colorRampPalette(c("white", "#2780e3"))(50),
      main = "Inter-item correlations, RSES (song_2023_rses)")
axis(1, 1:10, sub("RSES", "", ord)); axis(2, 1:10, sub("RSES", "", rev(ord)), las = 1)
text(rep(1:10, 10), rep(1:10, each = 10), sprintf("%.2f", r[ord, rev(ord)]), cex = 0.6)
abline(v = c(5.5, 6.5), h = c(4.5, 5.5), lty = 2, col = "grey40")
round(eigen(r)$values[1:3], 2)

## ---- item8
# Item 8 was written against self-esteem. Where does it sit?
round(rbind(with_positive = range(r["RSES8", pos]), with_negative = range(r["RSES8", neg4])), 2)
table(x[, "RSES8"])                    # how the stored values are spread
# Reversing item 8 as stored would put it at odds with every other item:
sprintf("alpha as stored %.3f; with item 8 reversed %.3f", alpha(x), alpha(flip(x, "RSES8")))
