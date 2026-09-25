# Constructs and construct maps: does a construct map written from the items' text
# order the items before we see any data? Nine number-series items from the
# Forecasting Proficiency Test (himmelstein-number_series-2025 in the Item Response
# Warehouse). Runs as-is in base R; no packages, login or token needed. New for this
# course (EDUC 252 c2 has no analysis of construct maps).

## ---- fetch
# The IRW table, from the CSV link on its landing page (pinned to one version).
ns_url <- "https://redivis.com/api/v1/tables/datapages.item_response_warehouse_2:v22_0.himmelstein-number_series-2025/rows?format=csv"
ns <- read.csv(ns_url)
head(ns[, c("id", "item", "resp", "rt", "wave")])

## ---- items
# The nine sequences, as shown to respondents, from the test's source code
# (forecastingresearch/fpt, materials/js/number_series_task.js), with the answer
# the scoring key accepts (data_cognitive_tasks/task_datasets/data_number_series.csv).
# `level` is the construct map in the lesson, written from the text alone:
#   1 the same step every time
#   2 the step changes by a simple pattern (it alternates, or grows by one)
#   3 the step changes by multiplication
#   4 two sequences interleaved in one
#   5 two sequences side by side, as fractions
items <- data.frame(
  item   = paste0("NS_", 1:9),
  series = c("10, 4, __, -8, -14, -20", "3, 6, 10, 15, 21, __", "121, 100, 81, __, 49",
             "3, 10, 16, 23, __, 36", "3/21, __, 13/11, 18/6, 23/1, 28/-4",
             "200, 198, 192, 174, __", "3, 2, 10, 4, 19, 6, 30, 8, __",
             "10000, 9000, __, 8890, 8889", "3/4, 4/6, 6/8, 8/12, __"),
  key    = c("-2", "28", "64", "29", "8/16", "165", "43", "8900", "12/16"),
  level  = c(1, 2, 2, 2, 5, 3, 4, 3, 5)
)
items[, c("item", "series", "level")]

## ---- design
# Waves 3 and 5 were the two cognitive-test waves; each respondent took the number
# series once, in whichever of the two waves it was randomly assigned to. Each item
# had a 30-second limit, and an item left unanswered is simply absent from the table.
table(wave = tapply(ns$wave, ns$id, function(w) paste(unique(w), collapse = "+")))
n_resp <- length(unique(ns$id))
n_resp
table(ns$resp)          # 1 = correct
answered <- table(factor(ns$item, levels = items$item))
answered                # respondents who answered each item (out of n_resp)

## ---- pcorrect
# Proportion correct among those who answered, and counting an unanswered item as
# incorrect, next to the level the map gives each item. Spearman's correlation
# compares the two orders: -1 would mean every higher level is harder.
items$answered <- as.vector(answered)
items$p <- as.vector(tapply(ns$resp, factor(ns$item, levels = items$item), mean))
items$p_all <- as.vector(tapply(ns$resp, factor(ns$item, levels = items$item), sum)) / n_resp
map <- items[order(items$level, -items$p), c("item", "series", "level", "answered", "p", "p_all")]
print(transform(map, p = round(p, 3), p_all = round(p_all, 3)), row.names = FALSE)
# Three versions: all nine items; counting unanswered as wrong; leaving out NS_6.
round(c(all_items = cor(items$level, items$p, method = "spearman"),
        unanswered_wrong = cor(items$level, items$p_all, method = "spearman"),
        without_NS_6 = cor(items$level[-6], items$p[-6], method = "spearman")), 2)

## ---- plot
# Items that share a level are spread a little sideways so their labels don't overlap.
x <- items$level + (ave(items$p, items$level, FUN = function(v) rank(-v)) - 1) * 0.3
par(mar = c(4.5, 4.5, 1, 1))
plot(x, items$p, pch = 19, col = "#2780e3", xlim = c(0.8, 5.8), ylim = c(0, 1),
     xlab = "Level on the construct map", ylab = "Proportion correct", xaxt = "n")
axis(1, at = 1:5)
text(x, items$p, items$item, pos = ifelse(items$item == "NS_3", 1, 3), cex = 0.8)

## ---- ns6
# What did respondents type for NS_6? The IRW table keeps only the 0/1 score, so we
# read the answers from the source data (pinned to one commit of the FPT repository)
# and keep the sessions that are in the IRW table.
src_url <- paste0("https://raw.githubusercontent.com/forecastingresearch/fpt/",
                  "fdbe605700cc172c03abe009bbd894a20f5cb69b/",
                  "data_cognitive_tasks/task_datasets/data_number_series.csv")
src <- read.csv(src_url, colClasses = "character")
ns6 <- src$ns_response[src$ns_id == "NS_6" & src$session_id %in% ns$cov_session_id]
ns6 <- ns6[!is.na(ns6) & ns6 != ""]
length(ns6)                                # respondents who answered NS_6
head(sort(table(ns6), decreasing = TRUE), 5) # the most common answers
c(answered_165 = sum(ns6 == "165"), answered_120 = sum(ns6 == "120"))
round(c(p_as_keyed = mean(ns6 == "165"), p_if_120_were_keyed = mean(ns6 == "120")), 3)
