<!-- Outlined 2026-09-24 from EDUC 252 c9 (slides 13–14), PS9#3, PS2#5c (recalled on c9 slide 13; now in `ctt-limits`) and ps9/unfold.R. Tidied 09-24 (#62). -->

# Unfolding models (`unfolding`)

Module: beyond · Prereqs: polytomous · Extension · Status: draft (#52)

## Core ideas

1. **Dominance vs. ideal point.** Every model so far is a dominance model. For many attitude statements agreement peaks where the statement sits: "I think capital punishment is necessary but I wish it were not" is rejected from both sides, for opposite reasons (c9 slide 13). *(major)* Sources: Thurstone (1928), doi:10.1086/214483; Coombs (1964), *A theory of data* (Wiley; Open Library); Drasgow, Chernyshenko & Stark (2010), doi:10.1111/j.1754-9434.2010.01273.x.
2. **What unfolding leaves in the data.** Ordered along the continuum, each respondent's agreements form a contiguous run (a parallelogram, not a Guttman triangle); the ends correlate negatively; middle statements correlate with nothing. *(major)* Sources: van Schuur (1992), doi:10.1093/pan/4.1.41; Andrich (1988), doi:10.1177/014662168801200105.
3. **Parametric and nonparametric ideal-point models.** The hyperbolic cosine model (a PCM with the two "disagree" categories folded, c9 slide 14) and the GGUM; `mirt`'s `ideal` item type as the simple case; MUDFOLD's order and $H$ as the nonparametric counterpart of Mokken scaling. *(major)* Sources: Andrich & Luo (1993), doi:10.1177/014662169301700307; Roberts, Donoghue & Laughlin (2000), doi:10.1177/01466216000241001; Tendeiro & Castro-Alvarez (2019), `GGUM`, doi:10.1177/0146621618772290; Balafas, Krijnen, Post & Wit (2020), `mudfold`, doi:10.32614/rj-2020-002.
4. **Choosing between them is hard (PS9#3).** With statements near the ends, a 2PL with negative slopes on the "anti" statements mimics an ideal-point model; the two separate only on middle statements, with enough respondents there. The lesson's verdict is on hold (see Open questions). Sources: Stark, Chernyshenko, Drasgow & Williams (2006), doi:10.1037/0021-9010.91.1.25; Brown (2016), doi:10.1007/s11336-014-9434-9.

References checked on Crossref (09-24) unless marked. Claude's checks before drafting (digest D): which Andrich "Handbook" chapter c9 slide 14 means (likely Andrich, 1997, doi:10.1007/978-1-4757-2691-6_23); the cosh formula against Andrich & Luo (1993); `GGUM` and `mudfold` in webR.

## Picks up

- Items that don't rise with the sum score, shown on `andrich_mudfold` (from `ctt-limits`). Deliberate table reuse, recorded under `reuses:`.
- The PCM and adjacent-category splits (from `polytomous`).
- Monotonicity and local independence as assumptions (from `rasch`).
- Negative slopes and keying (from `1pl-to-4pl`, and the reverse-keying thread from `ctt-reliability`).

## Promises / leaves open

- Ideal-point models for personality items (Stark et al., 2006) → unpaid; a problem only.
- Rankings and paired comparisons as unfolding data (`franco_2024_unfolding`) → unpaid; a problem only. The competitions lesson is not downstream of this one, so no hook.
- Multidimensional unfolding → unpaid.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `andrich_mudfold` | main example | Eight capital-punishment statements, 54 respondents. In GGUM order, 40 of 54 patterns are a single run of agreements (random orders give 5 on average). LIFESACRED vs. CRIMDESERV r = −0.84; DONTBELIEV correlates with nothing (\|r\| ≤ 0.18). MUDFOLD keeps all eight ($H$ = 0.64). Yet the 2PL has the lowest AIC (Rasch 595, ideal 437, 2PL 422), and no single ideal-point item lowers it. With 54 people the data can't tell the models apart item by item. Several GGUM discriminations sit at the bound (10). | `ctt-limits` (recorded under `reuses:`) |
| `eurpar2_mudfold` | contrast (pick 2 of 6) | 1,786 activists each pick 2 of 6 parties; sum scores are useless, the information is in the pairs. Commonest pairs are neighbours. MUDFOLD orders five parties left to right ($H$ = 0.79) and leaves out the democratic progressives. | — |
| simulated GGUM data | sanity | GGUM recovers known locations; the `andrich_mudfold` order should match Andrich's (1988) scale values (to check). | — |

**Item text (digest F31).** Quote the eight statements in full, cited. They are published in Andrich (1988); the licence check is against that publication (SAGE), not the IRW table's GPL-3.0. Claude confirms the quotation terms before drafting.

## Widget / simulation / problem ideas

**Widgets**
- Dominance vs. ideal point: one statement, a θ slider, the 2PL and single-peaked curves (idea 1).
- The parallelogram: toggle "order statements by δ" and the runs appear (idea 2).
- Folding the PCM: three categories collapse to two; the cosh curve forms (idea 3).
- Mimicry: end-only vs. spread statements; a free-sign 2PL fitted to ideal-point curves (idea 4).

**Predict-then-check:** "I do not believe in capital punishment but I am not sure it is not necessary." Does agreeing with it go with the abolitionist statements, the retentionist ones, or neither? (All \|r\| ≤ 0.18; GGUM location −0.11.)

**Simulate:** ideal-point responses for 20 statements across θ; fit the 2PL and the ideal-point model; compare AIC and curves. Keep only end statements and refit: the 2PL wins. Seconds in `mirt`.

**Problems**
1. Derivation: fold the three-category PCM into the hyperbolic cosine model; agreement peaks at θ = δ.
2. Real data with a twist (PS9#3): read each statement and say which model you'd fit before looking. Then check.
3. Judgment: with 54 respondents, what could change your mind about DONTBELIEV?
4. Design: eight statements on a policy so that unfolding and dominance can be told apart. Where must they sit?
5. Real data (`eurpar2_mudfold`): recover the left–right order from the pair counts alone; compare with MUDFOLD.
6. Challenge (open): are some personality items ideal-point (Stark et al., 2006)? How would you find out on an IRW table? Or: model `franco_2024_unfolding`'s rankings.

## Go deeper

- **The hyperbolic cosine model is a folded PCM.** Derive $\Pr(\text{agree}) = e^{\lambda} / (e^{\lambda} + 2\cosh(\theta - \delta))$ (form to check against Andrich & Luo, 1993). Why: `polytomous`, `rasch`, `nominal`. Half a page.

## Open questions

- **Verdict (F32, on hold with Ben).** Candidate: "if the statements weren't written to span the middle, the dominance model is enough" (Claude's reading of PS9#3 and the AIC result). *Default while on hold:* the draft carries the candidate in a hidden TODO, not on the page, and the lesson's first-person verdict waits for Ben.

## Drafting notes (09-25, #52)

What the draft changed or dropped, against the plan above:

- **Runs.** The GGUM places the three "against" statements within 0.02 of each other, so "GGUM order" isn't one order. The lesson counts runs in Andrich's order (39 of 54) and over all 40,320 orders (mean 5.4, best 40, which is Andrich's order with neighbours swapped).
- **AIC.** Recomputed: Rasch 594.6, ideal 436.5, 2PL 422.0 (EM stops at its limit: CRIMDESERV's slope grows without bound), GGUM (GGUM package) 422.1 with 24 parameters. BIC prefers the 2PL. One ideal-point item at a time: none below 422.0 (closest DETERRENT 422.5, WISHNOTNEC 422.6).
- **GGUM in webR.** The `GGUM` package isn't on the webR repo (it imports `xlsx`), and `mirt`'s `ggum` itemtype fails on these dichotomous data (NaN gradient). So the GGUM is fitted only in the real-data section at render time (about 30 s); Simulate uses `mirt`'s `ideal` item. The ideal-point fit in Simulate needs data-based starting values (default starts land on a poor local maximum; recorded in the code). `mirt`'s `hcm` works but took about 50 s and didn't converge on the simulated data, so it isn't used.
- **Simulate result.** With a correct start, the ideal-point model still edges the 2PL on end statements only in large samples; with 500 respondents the two tie (AIC 2,296 vs 2,297), and the ideal model wins by about 1,400 points with all 20 statements.
- **Notation.** Statement location is $b$ (notation.md) and the HCM's unit parameter is written $\tau$, to keep $\lambda$ for loadings. Proposed for notation.md in the PR.
- **Negative slopes pick-up.** `1pl-to-4pl` as drafted doesn't discuss negative slopes, so there is no Recall for it; the lesson states the point directly.
- **Andrich's (1988) scale values.** Not checked (article paywalled); the lesson compares the data's order with the order the statements come in.
- **Item text (F31).** All eight statements quoted in one table, from the `mudfold` help page, cited to Andrich (1988); within SAGE's pre-approved reuse (≤ 200 words from one article). Not checked against the printed article.
- **Verdict (F32).** Hidden TODO in the page at the end of the capital-punishment analysis.

## Rebuild with Duck-Mayr & Montgomery (2023) (09-25, Ben)

- **Main example is now `duckmayr_2023_immigration`**: ten immigration statements, 2,621 respondents, 0–4. It's an interim local copy in `lessons/data/` until the IRW landing page is live, so it isn't in `tables:` yet. IMM_2 is single-peaked by self-placed ideology in the raw data (0.44 … 0.59 … 0.51) and correlates about 0 with the ends. In sample: GRM AIC 73,068, GGUM 72,774, mixed (GGUM for IMM_2/4/6/8, GRM for the rest) 72,500. On a 10% held-out split: GRM −1.3606, GGUM −1.3718, mixed −1.3487. The GGUM needs data-based starts in `mirt`.
- **`andrich_mudfold` is cut to a short section**: correlations, runs, and AIC for Rasch, 2PL, ideal and GGUM. Dropped: the statement table (only WISHNOTNEC is quoted now), the MUDFOLD fit, the parameter and curve chunks, and the one-at-a-time mixed models.
- **`eurpar2_mudfold`** is shortened.
- **Verdict (F32)**: the hidden TODO candidate now has two halves, one for each data set.
