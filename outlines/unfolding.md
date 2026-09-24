<!-- Outlined 2026-09-24 from EDUC 252 slides c9 (slides 13–14: the capital-punishment statement, dominance vs. ideal point, the hyperbolic cosine model, "Chapter 21 from Andrich in 'Handbook'"), PS9#3 (dominant or unfolding? a bonus), PS2#5c (recalled on c9 slide 13: item proportions against sum scores on `andrich_mudfold`, now in `ctt-limits`), and the code ps9/unfold.R. -->

# Unfolding models (`unfolding`)

Module: beyond · Prereqs: polytomous · Optional · Status: outline

## Core ideas

1. **Dominance vs. ideal point.** Every model so far is a dominance model: the more θ, the more likely a "yes". For many attitude statements agreement peaks where the statement sits and falls off on both sides: "I think capital punishment is necessary but I wish it were not" is rejected by abolitionists and by enthusiasts, for opposite reasons (c9 slide 13). *(major)* Sources: Thurstone (1928), doi:10.1086/214483; Coombs (1964), *A theory of data* (Wiley; checked in the Open Library catalogue); Drasgow, Chernyshenko & Stark (2010), doi:10.1111/j.1754-9434.2010.01273.x, with Reise's (2010) reply, doi:10.1111/j.1754-9434.2010.01276.x.
2. **What unfolding leaves in the data.** Order the statements along the continuum and each respondent's agreements form a contiguous run (a "parallelogram" pattern rather than a Guttman triangle); correlations between the two ends are negative; middle statements correlate with nothing. *(major)* Sources: Coombs (1964); van Schuur (1992), doi:10.1093/pan/4.1.41; Andrich (1988), doi:10.1177/014662168801200105.
3. **Parametric ideal-point models.** The hyperbolic cosine model (the PCM with the two "disagree" categories folded together, c9 slide 14) and the GGUM (the generalized graded unfolding model): item location δ, person location θ, and a probability that depends on θ − δ in both directions. `mirt`'s `ideal` item type is a simpler single-peaked curve. *(major)* Sources: Andrich & Luo (1993), doi:10.1177/014662169301700307; Andrich (1997), in *Handbook of modern item response theory*, doi:10.1007/978-1-4757-2691-6_23 (the likely referent of c9 slide 14's "Chapter 21 from Andrich in 'Handbook'"; to confirm); Roberts, Donoghue & Laughlin (2000), doi:10.1177/01466216000241001; Maydeu-Olivares, Hernández & McDonald (2006), doi:10.1207/s15327906mbr4104_2; `GGUM`: Tendeiro & Castro-Alvarez (2019), doi:10.1177/0146621618772290.
4. **Nonparametric unfolding.** MUDFOLD finds the item order and a scalability coefficient $H$ without a response function, as Mokken scaling does for dominance data. Sources: van Schuur (1992); Balafas, Krijnen, Post & Wit (2020), doi:10.32614/rj-2020-002.
5. **Choosing between them is hard (PS9#3).** When the statements sit near the ends of the continuum, a 2PL with negative slopes for the "anti" statements mimics an ideal-point model; the two separate only on the middle statements, and only with enough respondents there. My verdict, to be confirmed: ask whether the statements were written to span the middle; if not, the dominance model is enough. Sources: Stark, Chernyshenko, Drasgow & Williams (2006), doi:10.1037/0021-9010.91.1.25; Andrich (1988); Brown (2016), doi:10.1007/s11336-014-9434-9 (linked from c9 slides 13–14; dominance and ideal-point processes in one framework).

References checked on Crossref (09-24) unless marked.

## Picks up

- Items that don't rise with the sum score, shown on `andrich_mudfold` (from `ctt-limits`; its promise: unfolding response processes → `unfolding`). Deliberate table reuse, agreed by Ben 09-24.
- The PCM and adjacent-category splits (from `polytomous`; the hyperbolic cosine model is a PCM with folded categories).
- Monotonicity and local independence as model assumptions (from `rasch`).
- Negative slopes and keying (from `1pl-to-4pl` and the reverse-keying thread from `ctt-reliability`).
- Nominal responses were once in this lesson (`unfolding-nominal`); they now have their own lesson, `nominal`, and `polytomous`'s promise ("Nominal responses and unfolding → `unfolding-nominal`") should be split into `unfolding` and `nominal` there.

## Promises / leaves open

- Ideal-point models for personality items (Stark et al., 2006) → unpaid; a problem only.
- Rankings and paired comparisons as unfolding data (`franco_2024_unfolding`) → unpaid; `competitions` (Bradley–Terry) is the nearest lesson and could Recall it.
- Multidimensional unfolding (ideal points in a space: political scaling) → unpaid.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `andrich_mudfold` | main example | Eight capital-punishment statements (Andrich, 1988), 54 respondents, agree/disagree; item text in the IRW matches the item ids. Ordered by the GGUM locations (HIDEOUS −2.30, LIFESACRED −2.31, INEFFECTIV −2.32, DONTBELIEV −0.11, WISHNOTNEC 0.85, MUSTHAVEIT 0.92, CRIMDESERV 2.37, DETERRENT 2.54), 40 of 54 response patterns are a single run of agreements; random item orders give 5 on average (the best of 2,000 gives 37). The ends correlate negatively (LIFESACRED with CRIMDESERV −0.84); DONTBELIEV correlates with nothing (|r| ≤ 0.18). MUDFOLD keeps all eight with $H$ = 0.64. Yet the 2PL, with negative slopes on the "anti" statements, has the lowest AIC (Rasch 595, ideal 437, 2PL 422), and making any single item an ideal-point item never lowers it (422–437). With 54 people, the data can't tell the models apart item by item, which is Ben's caveat in PS9#3. Several GGUM discriminations sit at the estimation bound (10), another sign of a small sample. | `ctt-limits` (deliberate thread; `reuses:` recorded here) |
| `eurpar2_mudfold` | contrast (pick 2 of 6) | Party activists each pick the 2 of 6 parties they prefer (van Schuur, 1984; the `mudfold` package data): 1,786 respondents. Every respondent picks exactly 2, so sum scores are useless and a dominance model makes no sense; the information is in which pairs are chosen. The commonest pairs are neighbours: conservatives + christian democrats 437, social democrats + communists 341, liberals + christian democrats 217, liberals + social democrats 202. MUDFOLD orders five parties communists → social democrats → liberals → christian democrats → conservatives with $H$ = 0.79 and leaves out the democratic progressives. | — |
| sanity: simulated GGUM data | sanity | GGUM fitted to data simulated from known locations recovers their order; the order found on `andrich_mudfold` should also match Andrich's (1988) scale values (to check against the paper). | — |

`franco_2024_unfolding` (137 respondents ranking 6 objects; Franco & Carvalho, 2023, doi:10.31234/osf.io/5hnkz) is a third option, but rankings need a different likelihood (a ranking model, not agree/disagree), so it is left for a problem.

## Widget / simulation / problem ideas

**Widgets**
- Dominance vs. ideal point: one statement, its location δ and a slider for θ; the 2PL curve and the single-peaked curve side by side (idea 1).
- The parallelogram: a person × statement matrix of simulated responses; toggle "order statements by δ" and the contiguous runs appear (idea 2).
- Folding the PCM: three categories (disagree-below, agree, disagree-above) collapse to two; watch the hyperbolic cosine curve form (idea 3).
- Mimicry: statements only at the ends vs. statements across the middle; a 2PL with free-sign slopes fitted to the ideal-point curves, and the gap between them (idea 5).

**Predict-then-check:** "I do not believe in capital punishment but I am not sure it is not necessary." Will agreeing with it go with agreeing with the abolitionist statements, the retentionist ones, or neither? Answered by its correlations (all |r| ≤ 0.18) and its middle GGUM location (−0.11).

**Simulate:** Generate ideal-point responses (GGUM or `mirt`'s `ideal`) for 20 statements spread across θ; fit the 2PL and the ideal-point model; compare AIC and item curves. Then keep only statements near the ends and refit: the 2PL wins. Seconds in `mirt`; `GGUM` in webR to check.

**Problems**
1. Derivation: fold the three-category PCM into the hyperbolic cosine model; show that agreement peaks at θ = δ.
2. Real data with a twist (PS9#3): for each `andrich_mudfold` statement, read the text and say which model you would fit before looking at the fit. Then check.
3. Judgment: with 54 respondents, what could change your mind about DONTBELIEV?
4. Design: write eight statements about a policy of your choice so that an unfolding model could be told apart from a dominance model. Where must the statements sit?
5. Real data (`eurpar2_mudfold`): recover the left–right order from the pair counts alone, then compare with MUDFOLD.
6. Challenge (open): personality items such as "I am the life of the party" are usually treated as dominance items. Stark et al. (2006) argue some are ideal-point. How would you find out on an IRW personality table?

## Go deeper

- **The hyperbolic cosine model is a folded PCM.** From the three-category Rasch (PCM) model with the two outer categories combined, derive $\Pr(\text{agree}) = e^{\lambda} / (e^{\lambda} + 2\cosh(\theta - \delta))$ (form to check against Andrich & Luo, 1993, before drafting). Why: `polytomous` (PCM), `rasch`, `nominal` (categories whose order is not given). Length: half a page.

## Open questions

- Show the eight capital-punishment statements in full? *Default:* yes: they are short, published in Andrich (1988), and the IRW table is GPL-3.0; cite them. (Item-text rule, A5 in the digest.)
- The verdict in idea 5 ("if the statements weren't written to span the middle, the dominance model is enough") is my reading of PS9#3 and the `andrich_mudfold` result. *Default:* use it unless you'd put it differently.
- `franco_2024_unfolding` (rankings) is left to a problem. *Default:* keep it out of the lesson.
