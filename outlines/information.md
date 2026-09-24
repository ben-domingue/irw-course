<!-- Outlined 2026-09-24 from EDUC 252 slides c3 (slides 35–42) and c4 (slide 49), PS3#1, PS4#1 (e–g), PS6#3 and c4/info.R. -->

# Information, precision, and short forms (`information`)

Module: irt · Prereqs: 1pl-to-4pl · Core · Status: outline

## Core ideas

1. **Information is the curvature of the likelihood.** A sharp peak means a precise estimate and a flat one a noisy estimate; Fisher information measures the sharpness. *(major)* Sources: Birnbaum (1968), in Lord & Novick, *Statistical theories of mental test scores*, chs. 17–20 (book; to verify); Lord (1980), *Applications of item response theory to practical testing problems*, doi:10.4324/9780203056615.
2. **Rasch item information is $p(1-p)$.** An item is most informative where $p = 0.5$, that is at $\theta = b$; it is the variance of a Bernoulli (PS3#1). *(major)* Source: Lord (1980).
3. **Information adds; precision follows.** Test information is the sum of item information; the conditional standard error of measurement is $1/\sqrt{I(\theta)}$. Unlike the single SEM of CTT, it varies with $\theta$, and it is largest where there are few items, not necessarily at the extremes. *(major)* Sources: Samejima (1977), doi:10.1177/014662167700100209; Kolen, Zeng & Hanson (1996) on conditional SEMs, doi:10.1111/j.1745-3984.1996.tb00485.x.
4. **Targeting.** A test is precise where its items are. Reading a test information curve against the distribution of people (the Wright map, now with error bars).
5. **Short forms.** Choosing items to maximize information where it matters: random 5-item forms vs. a form targeted at a region of $\theta$ (PS6#3). *(major)* Source: Samejima (1977).

## Picks up

- Curvature of the likelihood ↔ standard error (from `likelihood`; its Go deeper on the score equation and curvature).
- The Rasch model, ICCs, the Wright map, targeting (from `rasch`).
- One SEM for everyone (thread from `ctt-reliability`), and "one error variance for everyone fails" (from `ctt-limits`).
- Measures calibrated to the task, precise quickly (from `measurement`, Ben's desiderata).
- The 2PL and 3PL: slopes and lower asymptotes (from `1pl-to-4pl`), so information is taught for all three models, not only previewed.
- Items and people on one scale (from `constructs`, via `rasch`).

## Promises / leaves open

- Guessing lowers information at the bottom of the scale; fixing $c$ or using priors → `guessing-priors`.
- SE of an ability estimate = $1/\sqrt{I}$ at the estimate; what happens at perfect scores → `ability-estimation`.
- Choosing the next item by information → `item-banks-cat`.
- Error bands on reported scores; cut scores where information is low → `score-meaning`.
- Information from polytomous items → `polytomous`.
- Local dependence inflates information (items that share a passage) → `dimensionality`, `explanatory-irt`.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `bialowolski_2024_financial_literacy` | main example | 18 financial-literacy items, 4,389 complete cases; Rasch difficulties spread from −3.8 to 2.0 (mean −0.56). Test information is fairly flat, peaking at 3.3 near $\theta = -0.7$ (CSEM 0.55) and falling to 1.6 at $\theta = 2$ (CSEM 0.79). The best five items for $\theta = -1$ give information 1.2 there, against a median of 0.93 for random five-item forms and 3.3 for the full test. | — |
| `christensen_2018_wsssf_5831` | contrast | Wisconsin Schizotypy Scales, short forms: 60 items, 5,831 people. Every item is endorsed by few people (difficulties 0.8 to 3.6), so information peaks at $\theta = 2.3$ (13, CSEM 0.28) while the median person sits near 0 (CSEM 0.42) and people at $\theta = -2$ get CSEM 0.97. The scale is precise at the high end it was built to detect. | — |

Instrument sources: Winterstein, Silvia, Kwapil, Kaufman, Reiter-Palmon & Wigert (2011), doi:10.1016/j.paid.2011.07.027 (WSS short forms); Lusardi & Mitchell (2014) on financial literacy (NBER version, doi:10.3386/w18952; journal version to verify). Table citations from IRW biblio.

## Widget / simulation / problem ideas

**Widgets**
- Likelihood sharpness: pick a response pattern; watch the log likelihood and its curvature at the peak; add items (idea 1).
- Item information: an ICC with its information curve underneath, $b$ slider (idea 2).
- Build a test: add Rasch items by difficulty; test information, CSEM, and a person distribution overlaid (ideas 3, 4).
- Short-form picker: choose 5 of the 18 financial-literacy items; information at a target $\theta$ against the full test and random forms (idea 5).

**Predict-then-check:** for the schizotypy scale, where will the standard error be smallest: near the average person, or far above? Answered by the CSEM curve (smallest at $\theta \approx 2.3$).

**Simulate:** simulate Rasch data from a test with a chosen difficulty profile; estimate abilities; compare the empirical SD of $\hat\theta - \theta$ within bins of $\theta$ with $1/\sqrt{I(\theta)}$.

**Problems**
1. Derivation (PS3#1): derive the Rasch item information $p(1-p)$ from the second derivative of the log likelihood. When is a Bernoulli variance largest, and what does that say?
2. Derivation (PS4#1): three items with $b = -1, 0, 1.5$; write and plot the test information; where is it maximized?
3. Real data with a twist: in the financial-literacy test, which three items could you drop with the least loss of information for people below $\theta = 0$?
4. Design (PS6#3): ten items with the given difficulties; the best five-item form for $\theta = -1$, against ten random forms.
5. Judgment: the schizotypy scale is imprecise for most people. Is that a flaw? It depends on the use: say for which uses it is and isn't.
6. Challenge (open): information assumes the model is right. How would you check whether the CSEM curve is honest in real data?

## Go deeper

- **Rasch item information is $p(1-p)$, and test information adds.** From the second derivative of the log likelihood, under local independence. Why: `ability-estimation`, `item-banks-cat`, `score-meaning`, `1pl-to-4pl`. Length: half a page. (A candidate in `notes/protocol-decisions.md`; it may stay as problem 1 instead.)

## Open questions

- The prerequisite is `rasch` only, so 2PL/3PL information is a preview here and paid off in `1pl-to-4pl`. Keep that split, or move this lesson after `1pl-to-4pl`?
- The contrast table is a clinical screening scale. Ben's slides use an easy-test example; is a schizotypy scale the right tone for a first course, or should the contrast be an easy achievement test?
- The Lusardi & Mitchell (2014) journal version (*Journal of Economic Literature*) is still to verify.
