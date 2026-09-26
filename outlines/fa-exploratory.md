<!-- Outlined backwards from lessons/fa-exploratory.qmd (draft), 2026-09-24. Not in EDUC 252; added after the landscape analysis (EFA in 8 of 11 first-course syllabi). Updated 2026-09-24 (#11) to match the retrofitted page. -->

# Factor analysis I: exploring dimensionality (`fa-exploratory`)

Module: fa · Prereqs: instrument-building · Core · Status: draft (retrofitted to the protocol, #11)

## Core ideas

1. **A model for correlations.** The common factor model; with one factor, $\text{cor}(x_i,x_j) = \lambda_i\lambda_j$; tetrads; communality and uniqueness; a one-factor model is what "unidimensional" means here. *(major)* Sources: Spearman (1904), doi:10.2307/1412107; Spearman & Holzinger (1924), doi:10.1111/j.2044-8295.1924.tb00158.x (sampling error of tetrads); Thurstone (1931), doi:10.1037/h0069792; Thurstone (1947), *Multiple-factor analysis* (book; confirmed via Cattell's 1948 *Psychometrika* review, doi:10.1007/bf02289082).
2. **How many factors?** Eigenvalues, the Kaiser rule, the scree plot, and parallel analysis; the number of factors is an estimate. Verdict: parallel analysis first among the simple methods. *(major)* Sources: Guttman (1954), doi:10.1007/BF02289162; Kaiser (1960), doi:10.1177/001316446002000116; Cattell (1966), doi:10.1207/s15327906mbr0102_10; Horn (1965), doi:10.1007/bf02289447.
3. **Rotation.** Loadings aren't unique; rotation picks an interpretable solution with the same fit. Simple structure; orthogonal vs. oblique; verdict: my default is oblique. *(major)* Sources: Thurstone (1947, simple structure); Kaiser (1958), doi:10.1007/bf02289233 (varimax); Jennrich & Sampson (1966), doi:10.1007/bf02289465 (direct quartimin, R's default oblimin); Hendrickson & White (1964), doi:10.1111/j.2044-8317.1964.tb00244.x (promax); Browne (2001), doi:10.1207/s15327906mbr3601_05 (overview).
4. **Two practical notes.** Polychoric correlations for Likert items; factor analysis is not PCA. Sources: Olsson (1979), doi:10.1007/bf02296207; Pearson (1901), doi:10.1080/14786440109462720; Hotelling (1933), doi:10.1037/h0071325; Velicer & Jackson (1990), doi:10.1207/s15327906mbr2501_1; Fabrigar, Wegener, MacCallum & Strahan (1999), doi:10.1037/1082-989x.4.3.272.

Software: `psych` (Revelle, 2026, <https://CRAN.R-project.org/package=psych>); `GPArotation` (Bernaards & Jennrich, 2005, doi:10.1177/0013164404272507); minres (Harman & Jones, 1966, doi:10.1007/BF02289468). Real-data sources: Soto & John (2017), doi:10.1037/pspp0000096; Zhang, Huang, Sun & Savalei (2025), doi:10.1080/00223891.2025.2531187; Garrido, Abad & Ponsoda (2013), doi:10.1037/a0030005.

All references checked on Crossref (09-24, #11). Two claims were dropped rather than cited, because the source's text couldn't be checked: a Zwick & Velicer (1986) comparison of retention rules, and the IRW dimensionality vignette's reading of Garrido et al. (2013) as showing that parallel analysis on polychorics over-extracts (the paper's abstract recommends polychorics). The lesson cites Garrido et al. only for that recommendation.

## Picks up

- Alpha is not unidimensionality; tau-equivalence (from `ctt-reliability`): Recall callout in idea 1; problem 2.
- Reverse keying (from `ctt-reliability`): Recall callout where the BFI-2's keying is checked.
- Wording direction as a second dimension (from `instrument-building`; thread `wording-direction`): Recall in *What this is for*, updated in the Recall pass (#11) to what that lesson found (the Rosenberg scale's two blocks, 0.71 and 0.61 within, 0.23 across; second eigenvalue 2.32). *With real data* now checks the BFI-2 for the same pattern (chunk `wording`, key from Soto & John, 2017): within domains, same- and opposite-direction pairs both have median correlation 0.35, so the BFI-2 shows at most a trace of a wording dimension.
- Constructs; unidimensionality as a property of a construct map (from `constructs`): not recalled explicitly; the lesson defines unidimensionality in factor terms.

## Promises / leaves open

- Confirmatory models, fit indices, omega → `fa-confirmatory` (named in *What this is for*); multigroup invariance → `measurement-invariance` (problem 4 points there; split from `fa-confirmatory` 09-25, #58).
- Ordered categories as a coarsened continuous variable (polychorics) → `fa-confirmatory` (ordinal FA ≡ GRM), `polytomous`.
- Rotational indeterminacy → `fa-confirmatory` (identification), `dimensionality` (rotation in MIRT). The Go deeper callout also makes a brief "if you've done it" link to `rasch` (the scale has no origin), which isn't an ancestor, so it isn't a thread.
- Dimensionality in IRT → `dimensionality`; deep dive #23 (how often unidimensionality holds) stays with `dimensionality` unless #4 says otherwise. This lesson uses the vignette only as a baseline.
- Response formats as an experiment (problem 4) → `invariance-experience`, as a Recall there (digest E4: no table reuse).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `bfi2_zhang_2025` | main example | BFI-2, 60 items, 1,335 students (1,199 complete), four randomly assigned formats. Keyed on arrival (lowest within-domain Pearson correlation −0.005). Five blocks (median within-domain polychoric 0.35, between 0.04). Parallel analysis says 9 (Pearson too), Kaiser 12, against a 5-domain design; eigenvalue ratio 1.7. All 60 items load most strongly on their own domain (median main loading 0.57, largest other 0.16); largest factor correlation −0.22 (N–C); item 26 loads 0.27, item 6 has −0.33 on Agreeableness. Orthogonal and oblique RMSR both 0.031. | — |

**Baseline (voice rule E; digest D), from the IRW [dimensionality vignette](https://itemresponsewarehouse.org/vignettes/dimensionality.html):** parallel analysis finds exactly one factor in 3% of 810 tables; `psychtools_bfi` (25 items, 5 traits) gets 6; personality tables' median eigenvalue ratio is 3.26 (57 tables), `psychtools_bfi`'s 1.91. The page's old "unusually clean" had no baseline and is not restored as such: the vignette has no loading-level baseline. "Clean" is now defined against the design (main vs. other loadings), and the IRW baseline is used for the factor count and the eigenvalue ratio.

**Sanity table:** none needed separately: the sim recovers a known structure, and `psychtools_bfi` in the vignette is the known-answer check for the pipeline.

**Processing notes:** the IRW processing script (`ben-domingue/irw`, `data/bfi2_zhang_2025.R`) only reshapes the OSF file to long; it doesn't reverse-key. 212 responses are missing, scattered; no waves.

## Widget / simulation / problem ideas

**Widgets**
- Correlations from one factor (idea 1).
- Eigenvalues and parallel analysis: loadings, factors, sample size (idea 2). Prose checked against the widget code in node (09-24).
- Rotating two factors: angle slider, loadings move, fit doesn't (idea 3).

**Quick checks:** three, after ideas 1–3.

**Predict-then-check:** how many factors will parallel analysis find in a five-domain inventory? Answered by the parallel analysis (9).

**Simulate:** two correlated factors, five items each; parallel analysis and oblique EFA; compare with the truth (`psych`). Estimated factor correlation 0.18 vs. 0.3 with the seed as written.

**Problems**
1. Derivation: $\lambda_i\lambda_j$ and the tetrad constraints.
2. Derivation / thread: the sum score's correlation with the factor; tau-equivalence in terms of loadings (links to the alpha proof).
3. Design: plan a pilot's sample size so parallel analysis recovers three factors (was "when parallel analysis fails"; recast as design so the mix has one).
4. Real data with a twist: formats; loadings by format (Zhang et al., 2025); hook to `measurement-invariance` and `invariance-experience`.
5. Judgment: the three lowest-communality items; drop them? (wording in Soto & John, 2017).
6. Challenge: PCA vs. FA loadings; open part on when the difference stops mattering.

Solutions: `solutions/fa-exploratory.qmd` (held back).

## Go deeper

- **Rotational indeterminacy** (in the page, collapsible): $\Lambda T (\Lambda T)^\top = \Lambda\Lambda^\top$ for orthogonal $T$, and the oblique version with $\Phi$. Why: `fa-confirmatory` (identification), `dimensionality`, `rasch` (scale indeterminacy).

## Dropped or changed (#11)

- The "unusually clean" claim: not restored; see Baseline above.
- "Typical of large samples with well-developed instruments" (unsourced): replaced by the vignette baseline.
- "Anxious people tend to be less extraverted, strong readers tend to be strong at math" (unsourced examples in the rotation section): replaced by a pointer to the BFI-2's printed factor correlations.
- The widget prose on parallel analysis was corrected to what the widget shows.

## Open questions

- None for Ben. Proposed threads are in the PR (#11).
