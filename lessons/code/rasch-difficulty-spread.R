# How wide is a "wide" spread of item difficulties? A baseline for the chess result in
# the Rasch lesson. Samples dichotomous IRW tables (10-60 items, 300-5,000 respondents,
# density > 0.9), fits the Rasch model to each and records the SD and range of the
# difficulties. Run once, 2026-09-24 (IRW v414); results in data/rasch-difficulty-spread.csv.
# Needs the irw package with a Redivis login (for irw_metadata); run from lessons/.
suppressMessages({library(irw); library(mirt)}); source("_course.R")
m <- suppressWarnings(irw_metadata())
c <- subset(m, n_categories==2 & n_items>=10 & n_items<=60 & n_participants>=300 & n_participants<=5000 & density>0.9 & n_responses<1.5e6)
set.seed(1); c <- c[sample(nrow(c), min(60,nrow(c))),]
out <- list()
for (t in c$table) {
  u <- irw_csv_url(t); if (is.na(u)) next
  d <- tryCatch(read.csv(u), error=function(e) NULL); if (is.null(d) || !all(c("id","item","resp") %in% names(d))) next
  if ("wave" %in% names(d)) d <- d[d$wave==min(d$wave,na.rm=TRUE),]
  d <- d[!is.na(d$resp),c("id","item","resp")]; d <- d[!duplicated(d[,c("id","item")]),]
  w <- reshape(d, idvar="id", timevar="item", direction="wide")[,-1]
  w <- w[, colMeans(!is.na(w))>0.5 & apply(w,2,function(x) length(unique(na.omit(x))))==2, drop=FALSE]
  if (ncol(w)<10) next
  f <- tryCatch(mirt(w,1,"Rasch",verbose=FALSE), error=function(e) NULL); if (is.null(f)) next
  b <- -coef(f,simplify=TRUE)$items[,"d"]
  out[[t]] <- data.frame(table=t, items=ncol(w), sd=sd(b), range=diff(range(b)))
  if (length(out)>=40) break
}
r <- do.call(rbind,out); write.csv(r, "data/rasch-difficulty-spread.csv", row.names=FALSE)
cat("tables", nrow(r), "\n"); print(round(quantile(r$sd, c(.1,.25,.5,.75,.9)),2)); print(round(quantile(r$range, c(.1,.25,.5,.75,.9)),2))
d <- irw_csv("chess_lnirt"); d<-d[!is.na(d$resp),]; w <- reshape(d[,c("id","item","resp")], idvar="id", timevar="item", direction="wide")[,-1]; w<-w[rowSums(!is.na(w))>0,]
b <- -coef(mirt(w,1,"Rasch",verbose=FALSE),simplify=TRUE)$items[,"d"]; cat("chess sd", round(sd(b),2), "range", round(diff(range(b)),2), " pct rank sd", round(mean(r$sd<sd(b))*100), " range", round(mean(r$range<diff(range(b)))*100), "\n")
