<!-- Outlined 2026-09-24 from EDUC 252 slides c3 (slides 35–42) and c4 (slide 49), PS3#1, PS4#1 (e–g), PS6#3 and c4/info.R. Tidied 09-24 (#62): Ben's answers applied (B: after `1pl-to-4pl`; C13); pick-ups checked against the drafted `likelihood` and `rasch`. -->

# Information, precision, and short forms (`information`)

Module: irt · Prereqs: 1pl-to-4pl · Core · Status: drafted (#36)

## Core ideas

1. **Information is the curvature of a respondent's likelihood.** A Recall, not a re-teach: `likelihood` already showed that a sharper peak means a smaller standard error, that the negative curvature is the Fisher information, and that observations with $p$ near 0 or 1 add almost nothing. Here the parameter is $\theta$ and the observations are one respondent's items. *(major)* Sources: Birnbaum (1968), in Lord & Novick, *Statistical theories of mental test scores* (book, no DOI; see `1pl-to-4pl`); Lord (1980), doi:10.4324/9780203056615.
2. **Item information for the Rasch model, the 2PL and the 3PL.** Rasch: $p(1-p)$, the variance of a Bernoulli, largest at $\theta = b$ (PS3#1). 2PL: $a^2p(1-p)$, so steep items carry more, in a narrower band. 3PL: lowered at the bottom and peaked above $b$, because a correct answer there may be a guess. *(major)* Sources: Birnbaum (1968); Lord (1980).
3. **Information adds; precision follows.** Test information is the sum of item information (under local independence); the conditional SEM is $1/\sqrt{I(\theta)}$. Unlike CTT's single SEM, it varies with $\theta$, and it is largest where there are few items, not necessarily at the extremes. *(major)* Sources: Samejima (1977), doi:10.1177/014662167700100209; Kolen, Zeng & Hanson (1996), doi:10.1111/j.1745-3984.1996.tb00485.x.
4. **Targeting.** A test is precise where its items are. `rasch`'s Wright map, now with error bars: the test information curve read against the distribution of respondents. Sources: Lord (1977), doi:10.1111/j.1745-3984.1977.tb00032.x (building tests from information curves); Samejima (1977).
5. **Short forms.** Choosing items to maximize information where it matters: random five-item forms vs. a form targeted at a region of $\theta$ (PS6#3), and what a short form gives up. *(major)* Sources: Samejima (1977); Smith, McCarthy & Anderson (2000), doi:10.1037/1040-3590.12.1.102.

DOIs Crossref-checked 09-24.

**Verdict (voice rule A):** when a short form is good enough, verdict first (e.g. "if you know where the decisions are made, five targeted items beat eighteen untargeted ones there").

## Picks up

- Curvature ↔ standard error, Fisher information, and the $p(1-p)$ terms that vanish near 0 or 1 (from `likelihood`: the curvature section and its Go deeper).
- The Wright map; "precision depends on where you are on the scale", which `rasch` hands here by name (from `rasch`).
- Local independence as a model assumption (from `rasch`); it is what lets information add.
- The 2PL and 3PL: slopes and lower asymptotes (from `1pl-to-4pl`), so information is taught for all three models.
- One SEM for everyone (thread from `ctt-reliability`), and "one error variance for everyone fails" (from `ctt-limits`).
- Measures calibrated to the task, precise quickly (from `measurement`).
- Items and people on one scale (from `constructs`, via `rasch`).

## Promises / leaves open

- Guessing lowers information at the bottom of the scale; fixing $c$ or using priors → `guessing-priors`.
- SE of an ability estimate = $1/\sqrt{I}$ at the estimate; what happens at perfect scores → `ability-estimation`.
- Choosing the next item by information → `item-banks-cat`.
- Error bands on reported scores; cut scores where information is low → `score-meaning`.
- Information from polytomous items → `polytomous`.
- Information from distractors, below the item's difficulty → `nominal`.
- Local dependence inflates information (items that share a passage): named here, unpaid in this chain. `dimensionality` and `explanatory-irt` treat local dependence itself, but neither has this lesson as an ancestor (E2).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `bialowolski_2024_financial_literacy` | main example | 18 financial-literacy items, 4,389 complete cases; Rasch difficulties spread from −3.8 to 2.0 (mean −0.56). Test information is fairly flat, peaking at 3.3 near $\theta = -0.7$ (CSEM 0.55) and falling to 1.6 at $\theta = 2$ (CSEM 0.79). The best five items for $\theta = -1$ give information 1.2 there, against a median of 0.93 for random five-item forms and 3.3 for the full test. | — |
| `christensen_2018_wsssf_5831` | contrast | Wisconsin Schizotypy Scales, short forms: 60 items, 5,831 respondents. Every item is endorsed by few people (difficulties 0.8 to 3.6), so information peaks at $\theta = 2.3$ (13, CSEM 0.28) while the median respondent sits near 0 (CSEM 0.42) and respondents at $\theta = -2$ get CSEM 0.97. The scale is precise at the high end it was built to screen. | — |

Instrument sources: Winterstein, Silvia, Kwapil, Kaufman, Reiter-Palmon & Wigert (2011), doi:10.1016/j.paid.2011.07.027 (WSS short forms); Lusardi & Mitchell (2014), *Journal of Economic Literature* 52(1), 5–44, doi:10.1257/jel.52.1.5. Table citations from IRW biblio.

**Decisions (Ben, 09-24):** this lesson follows `1pl-to-4pl` (B), so 2PL and 3PL information are taught here, not previewed. The schizotypy scale stays as the contrast (C13), framed gently: it is about where the test is aimed, not about the people who took it.

## Widget / simulation / problem ideas

**Widgets**
- Likelihood sharpness for $\theta$: pick a response pattern; the log likelihood and its curvature at the peak; add items (idea 1; the `likelihood` widget, now for a respondent).
- Item information: an ICC with its information curve underneath; sliders for $b$, $a$ and $c$ (idea 2).
- Build a test: add items by difficulty; test information, CSEM, and a respondent distribution overlaid (ideas 3, 4).
- Short-form picker: choose 5 of the 18 financial-literacy items; information at a target $\theta$ against the full test and random forms (idea 5).

**Predict-then-check:** for the schizotypy scale, where will the standard error be smallest: near the average respondent, or far above? Answered by the CSEM curve (smallest at $\theta \approx 2.3$).

**Simulate:** Rasch data from a test with a chosen difficulty profile; estimate abilities; compare the empirical SD of $\hat\theta - \theta$ within bins of $\theta$ with $1/\sqrt{I(\theta)}$.

**Problems**
1. Derivation (PS3#1): derive $p(1-p)$ from the second derivative of the Rasch log likelihood, then $a^2p(1-p)$ for the 2PL. When is a Bernoulli variance largest?
2. Derivation (PS4#1): three items with $b = -1, 0, 1.5$; write and plot the test information; where is it maximized?
3. Real data with a twist: in the financial-literacy test, which three items could you drop with the least loss of information below $\theta = 0$?
4. Design (PS6#3): ten items with given difficulties; the best five-item form for $\theta = -1$, against ten random forms.
5. Judgment: the schizotypy scale is imprecise for most respondents. Is that a flaw? Say for which uses it is and isn't.
6. Challenge (open): information assumes the model is right. How would you check whether a CSEM curve is accurate in real data?

## Go deeper

- **Item information from the second derivative, and why test information adds.** $p(1-p)$, then $a^2p(1-p)$, under local independence. Why: `ability-estimation`, `item-banks-cat`, `score-meaning`, `polytomous`. Length: half a page (or it stays as problem 1).

## Open questions

- None.

## Changes made while drafting (#36, 09-24)

- **Contrast table: one subscale, not all 60 items.** The four WSS-SF subscales form two groups whose sum scores barely correlate (Perceptual Aberration–Magical Ideation 0.59, the two anhedonia scales 0.31, across groups −0.06 to 0.19), so one information curve for all 60 items would assume a single θ the data don't support. The lesson uses Perceptual Aberration (15 items): endorsement 4%–16%, 59% of respondents endorse none; 2PL information peaks at 18.22 at θ = 1.83 (CSEM 0.23); CSEM 0.88 at θ = 0, 2.27 at θ = −1, 1.49 at the estimate shared by zero scorers (−0.55); 16% of respondents have a CSEM below 0.4. Framed as a screening scale spending its precision where a screen decides (C13).
- **Main table fitted with the 2PL** (BIC 80,012 vs Rasch 81,439), since the lesson teaches 2PL information. Recomputed: information peaks at 7.45 at θ = −0.77 (CSEM 0.37), 1.01 at θ = 2 (CSEM 1.00); marginal reliability 0.81 (one SEM 0.44) against a CSEM curve from 0.37 to 0.81 over the middle 95% of respondents. Two near-flat items (FL_2, a = 0.14; FL_9, a = 0.36) add under half a percent of the peak information. Best five for θ = −1: 4.18 (full test 7.25; median random five-item form 1.99, 90th percentile 2.88); the same five give 0.20 at θ = 1.5.
- **Keying and waves checked.** Financial literacy: 0/1 correctness, "don't know" scored 0, three wordings (grammatical gender) pooled by the IRW table; no waves. WSS-SF: keyed toward schizotypy (Christensen et al., 2018, p. 2537); no waves.
- **Go deeper (revised 09-25, Ben's review):** one callout, "The information function in general", at the top of Core ideas: Fisher information as the expected negative second derivative = variance of the score; the general dichotomous-item form $P'^2/[P(1-P)]$; test information adds under local independence; Rasch, 2PL and 3PL as special cases (observed = expected for Rasch/2PL). It replaces the earlier derivation callout, so the lesson has one Go deeper. The main text points to it in one sentence. Problem 1 fills in the 3PL algebra and finds its peak.
- **Simulate** uses base R (difficulties known, ML by the score equation) rather than `mirt`, so it runs in a second; it shows the CSEM matching in the middle and the zero/perfect-score dropout at the ends (hand-off to `ability-estimation`).
- **Verdict** (voice rule A): "When I know where the decisions are made, I build the short form from the items most informative there and report its CSEM at that point, not its reliability." For Ben to confirm.
- Unverified: none of the cited DOIs; Winterstein et al. (2011) and Chapman et al. (1978) are cited only for what their titles and the Christensen et al. (2018) text establish.

