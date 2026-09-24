<!-- Outlined 2026-09-24. New lesson (Ben's request, #86), built on the IRW competition standard: https://itemresponsewarehouse.org/comps_standard.html. Left for later (Ben, 09-24, S2): tidied 09-24 (#62) for stale statements only, no redesign. -->

# Competitions and paired comparisons: Bradley-Terry and Elo (`competitions`)

Module: beyond · Prereqs: rasch · Extension · Status: outline

## Core ideas

1. **Competition data: no items, only opponents.** Two agents meet and one wins (or they draw). Each "response" measures both agents, on one scale, and all a comparison can tell you about is the difference between them. The IRW stores these in its competition standard (`agent_a`, `agent_b`, `winner`, `date`, `homefield`, scores), fetched with `irw_fetch(name, source = "comp")`. Games and paired-comparison judgments ("which of these two risks is more harmful?") have the same shape. Sources: IRW comps standard; Glickman & Jones (2025), doi:10.1146/annurev-statistics-040722-061813.
2. **The Bradley-Terry model is a Rasch model in which the item is another person.** P(a beats b) = logistic(θ_a − θ_b). Only differences are identified, so one constraint (the mean, or one agent fixed at 0) sets the origin. It is a logistic regression with a +1/−1 design row per game (picks up `likelihood`). Estimates exist only when the comparison graph is connected and no agent wins, or loses, every game (Zermelo, 1929). *(major)* Sources: Zermelo (1929), doi:10.1007/BF01180541; Bradley & Terry (1952), doi:10.1093/biomet/39.3-4.324; Luce (1959), *Individual choice behavior* (Wiley; book, no DOI); Andrich (1978), doi:10.1177/014662167800200319, for Thurstone and Rasch compared; Turner & Firth (2012), `BradleyTerry2`, doi:10.18637/jss.v048.i09. Ford (1957) on existence of the MLE: *unverified*.
3. **Win percentage is to Bradley-Terry what the sum score is to Rasch.** Win percentage ignores who you played. Bradley-Terry adjusts for strength of schedule, as Rasch adjusts for the items taken (picks up `ctt-limits`). Extensions go in the linear predictor: a home advantage (an order effect in judgments) and ties. Sources: Glickman & Jones (2025); Davidson (1970) on ties: *unverified*.
4. **Elo is Bradley-Terry estimated one game at a time.** After each game, r ← r + K (y − expected); this is a stochastic-gradient step on the Bradley-Terry log-likelihood. K sets the tradeoff between following real change and chasing noise. Glicko adds each rating's uncertainty. *(major)* Sources: Elo (1978), *The rating of chessplayers, past and present* (Arco; book, no DOI); Aldous (2017), doi:10.1214/17-STS628; Glickman (1999), doi:10.1111/1467-9876.00159.
5. **Static or dynamic? Let prediction decide.** Bradley-Terry assumes each agent's strength is fixed. When strength drifts (rosters change), a pooled fit predicts the future poorly and Elo, which forgets, does better. Judge the two by out-of-sample log-likelihood, not by in-sample fit. *(major)* Sources: Aldous (2017); Glickman & Jones (2025).
6. **Paired comparisons as measurement.** Thurstone's law of comparative judgment scales stimuli, not people, from "which is more X?" judgments (the probit version of idea 2). The scale is only as meaningful as the question asked: change the criterion and the order changes. Source: Thurstone (1927), doi:10.1037/h0070288.

## Picks up

- The Rasch model, identification of the origin, sufficiency of the sum score (from `rasch`).
- Logistic regression and the likelihood (from `likelihood`).
- The sum score's dependence on which items were taken (from `ctt-limits`).
- The chess anchor: `likelihood` and `rasch` use chess data (`chess_lnirt`); Elo is where chess ratings come from.

## Promises / leaves open

- Elo as online ability estimation in adaptive learning systems: a pointer to ability-estimation and item-banks-cat, which don't follow this lesson (Pelánek (2016) on Elo in education: *unverified*). Out-of-sample prediction is restated here, not assumed from fit-prediction.
- Raters who disagree: Friedman (2019)'s point is that Americans react to the same risks differently; judge-level covariates or random effects → unpaid (explanatory-irt is a sibling, not downstream; problem 6).
- Intransitivity (a beats b beats c beats a) and multidimensional strength → unpaid.
- Glicko-2, TrueSkill and team-level ratings → unpaid (Going further).
- Draws modelled properly (Davidson; ordinal models) → unpaid (a pointer to polytomous only).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `nba_2012-2018` | main example (games over time) | 30 teams, 2012-13 to 2017-18. Home advantage of about 0.40 logits (home teams win 59%). Fit Bradley-Terry on the first five seasons and predict the last: the pooled fit predicts no better than a constant (mean log-likelihood −0.69 vs −0.68), while Elo with K ≈ 0.1 logits reaches −0.60. Teams change; a static model can't follow them. Season-by-season fits show it too (the top team moves from MIA to SA to GS to HOU). *Preliminary: computed before de-duplicating (see below); re-check when drafting.* | — |
| `friedman2019_risk_harm` | main example (judgments) | 100 public risks, 1,194 raters, "which is more harmful?". Bradley-Terry puts cancer, alcohol use and obesity at the top, asteroid collisions and extraterrestrials at the bottom. Split-half (by rater) correlation of the scale values is 0.97. | — |
| `friedman2019_risk_disaster` | contrast (same risks, another question) | Correlates only 0.63 with the harm scale. Nuclear war, asteroid collisions and biological terrorism move up the most; alcohol, smoking and obesity move down. The criterion defines the scale (idea 6). | — |

The two Friedman tables come from one study, so they count as one data source; the lesson says so. Friedman's study collects the same 100 risks on eight criteria (appropriate, disaster, fairness, harm, incidence, longterm, priority, worry); a problem can use a third.

Data notes, to state gently in the lesson:
- In `nba_2012-2018`, `agent_a` is always the home team. The 2016-17 and 2017-18 seasons each appear twice (2,460 rows for 1,230 games; the second copies are exact duplicates), so the lesson de-duplicates first.
- In the Friedman tables, `agent_a` is always the winner. The lesson randomizes which side is `a` before fitting, or the side would be confounded with the outcome.
- `nba_2012-2018` has no reference in IRW biblio (source: Kaggle, "NBA enhanced box score and standings", CC BY-SA 4.0), so its Data sources entry will say "No reference recorded".

## Widget / simulation / problem ideas

**Widgets**
- Bradley-Terry curve: sliders for θ_a, θ_b and home advantage; the curve is the Rasch ICC with the item replaced by an opponent (idea 2).
- Strength of schedule: a small league where one team plays only weak opponents. Win percentage ranks it first; Bradley-Terry doesn't (idea 3).
- The undefeated team: remove its only loss and watch its estimate run off to infinity; add one draw and it comes back (idea 2).
- Elo tracker: a true strength that jumps mid-season; choose K and watch Elo lag (small K) or jitter (large K) (idea 4).

**Predict-then-check:** a Bradley-Terry fit to five NBA seasons, or Elo run through them, to predict the sixth: which predicts better, and does either beat a constant with only the home advantage? Answered by the out-of-sample log-likelihoods.

**Simulate:** draw strengths for 30 agents and a random schedule; simulate games from Bradley-Terry; fit with `glm` and compare with the truth. Then let strengths drift and run Elo at several K. Seconds in the browser. `irw_simdata_comp()` in the `irw` package does the static part; whether `irw` runs in webR is to be checked, otherwise simulate by hand and point to it.

**Problems**
1. Derivation: show that the Elo update is a gradient step on the Bradley-Terry log-likelihood for one game, and find the step size.
2. Real data with a twist: add the home advantage to the NBA Bradley-Terry fit, then fit it separately for each season. Does home advantage change over time?
3. Judgment: a ranking of teachers from pairwise comparisons of their students' work (comparative judgment). What would you need to believe for the scale to be fair?
4. Design: you have 100 essays and budget for 1,000 comparisons. How would you choose the pairs? (connectivity; adaptive pairing)
5. Real data: pick a third Friedman criterion (e.g. `worry`). Which risks move the most relative to harm, and why might they?
6. Challenge (open): the Friedman raters disagree. Split raters by some feature, or fit a mixture. Is there one scale of harm, or several?

## Go deeper

- **Elo as stochastic gradient ascent.** The Elo update is the per-game gradient of the Bradley-Terry log-likelihood, so Elo is an online estimator with a fixed learning rate. Why: connects to `ability-estimation` and `item-banks-cat`. Length: half a page. (Extension lesson, so not a depth-pass candidate unless Ben wants it.)

## Open questions

- **Data access (digest A6; not yet answered).** Competition tables have no IRW landing page (`tables/<name>/` returns 404), so no tokenless CSV, which §5 requires, and `check_tables.R` can't cite them. *Default (A6):* publish teaching copies as standard IRW tables with landing pages; until then the lesson stays a stub.
- Direction of the Friedman scales: Claude checks each criterion's question wording in the source before drafting.

Settled (digest C20, C21, defaults): the lesson sits in Beyond as an extension; NBA is the main example, with `lichess` only if A6 produces a subsample.
