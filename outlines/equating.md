<!-- Outlined 2026-09-24 from EDUC 252 slides c6 (slides 33–47), PS6#4, and the code c6/equate-obsscore.R, c6/equate-irt.R, c6/concurrent.R, ps6/equating.R, ps6/equating_simstudy.R. -->

# Linking and equating (`equating`)

Module: uses · Prereqs: 1pl-to-4pl · Core · Status: outline

## Core ideas

1. **Two scenarios, one problem.** Last year's form and this year's (equating); a grade-3 test and a grade-4 test with some items in common (vertical scaling). Equating makes scores on forms built to the same blueprint interchangeable; linking is the looser family it belongs to. *(major)* Sources: c6 slides 33–36; Kolen & Brennan (2014), *Test Equating, Scaling, and Linking* (3rd ed.), Springer, doi:10.1007/978-1-4939-0317-7 (the definition on slide 35); Linn (1993), doi:10.1207/s15324818ame0601_5 (Crossref lists the author as "Lim"); Dorans, Pommerich & Holland (Eds.) (2007), *Linking and Aligning Scores and Scales*, Springer, doi:10.1007/978-0-387-49771-6.
2. **What equating demands, and why design comes first.** Symmetry (not regression), equity (a respondent should be indifferent to the form), population invariance. "Equating is impossible if you didn't design things so that a solution exists": random groups, single group with counterbalancing, common-item nonequivalent groups (NEAT). *(major)* Sources: c6 slides 38–41; Lord (1980), doi:10.4324/9780203056615 (equity); Dorans & Holland (2000), doi:10.1111/j.1745-3984.2000.tb01088.x (population invariance).
3. **Observed-score equating.** With randomly equivalent groups you need no common items: mean, linear and equipercentile equating, and why equipercentile needs smoothing. Sources: c6 slide 42, `c6/equate-obsscore.R`; Kolen & Brennan (2014), chs. 2–3; von Davier, Holland & Thayer (2004), *The Kernel Method of Test Equating*, Springer, doi:10.1007/b97446; Albano (2016), the `equate` package, doi:10.18637/jss.v074.i08.
4. **IRT linking through common items.** Each calibration sits on its own scale (the scale has no origin, and in the 2PL no unit): find $A$, $B$ with $\theta^* = A\theta + B$. Mean-mean and mean-sigma, then the characteristic-curve methods of Haebara and Stocking–Lord; then IRT true-score equating. *(major)* Sources: c6 slides 43–45, `c6/equate-irt.R`; Marco (1977), doi:10.1111/j.1745-3984.1977.tb00033.x; Loyd & Hoover (1980), doi:10.1111/j.1745-3984.1980.tb00825.x; Haebara (1980), doi:10.4992/psycholres1954.22.144; Stocking & Lord (1983), doi:10.1177/014662168300700208; Lord (1980); Battauz (2015), the `equateIRT` package, doi:10.18637/jss.v068.i07.
5. **Concurrent calibration.** Missing responses by design are no problem for IRT: stack the forms and fit once. Separate or concurrent, and what each assumes. Sources: c6 slide 46, `c6/concurrent.R`; Kim & Cohen (1998), doi:10.1177/01466216980222003; Hanson & Béguin (2002), doi:10.1177/0146621602026001001; Mislevy, Beaton, Kaplan & Sheehan (1992), doi:10.1111/j.1745-3984.1992.tb00371.x (matrix sampling).
6. **How linking breaks.** Common items that don't behave the same in both forms: position and context effects, drift, translation. Linking error accumulates along a chain. *(major)* Sources: c6 slide 47 ("how could you break this?"); Leary & Dorans (1985), doi:10.2307/1170392; Debeer & Janssen (2013), doi:10.1111/jedm.12009; Michaelides (2010), doi:10.3389/fpsyg.2010.00167; Haberman (2009), doi:10.1002/j.2333-8504.2009.tb02197.x (linking many groups at once).

All DOIs above were checked on Crossref on 09-24 (book DOIs included). Holland & Dorans (2006), "Linking and equating", in Brennan (Ed.), *Educational Measurement* (4th ed.), a chapter with no DOI, is *not yet verified*; I'd cite it in *Going further*.

## Picks up

- The scale has no origin; compare across studies with care (thread from `rasch`).
- Linking estimates from different groups or forms; the linear indeterminacy of 2PL estimates across groups (from `parameter-invariance`, optional; if not taught, idea 4 says it in two sentences).
- Invariance of person parameters across item sets (from `parameter-invariance`, optional).
- Missing responses by design (from `irw-data`).
- Many-item sparse designs; EM with missing blocks (from `item-estimation`, optional; `mirt` does it for now).
- Whether a scale is interval changes group comparisons (from `measurement`): here only as the reason to link on $\theta$ rather than raw scores; growth and vertical scales are handed to `scale-properties`.
- The 2PL and 3PL, slopes and test characteristic curves (from `1pl-to-4pl`).
- Norms on a new form (from `score-meaning`, if taught first; not a prerequisite).

## Promises / leaves open

- Vertical scales and what growth on them means → `scale-properties`.
- Items that function differently across groups (drifting anchors are DIF by another name) → `dif`.
- Item banks: new items calibrated onto the bank's scale (fixed-parameter calibration) → `item-banks-cat`.
- Position effects as an explanatory item model (item × position) → `explanatory-irt`.
- Linking across languages and countries; alignment → unpaid (mention Haberman 2009 and the PIRLS contrast only).
- Kernel equating, equating standard errors → unpaid (Going further).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `cdm_timss11` | main example | TIMSS 2011 grade 4 mathematics, Austria: 4,668 students, 174 items, 14 booklets. Each item appears in two booklets, and each booklet shares one block (9–14 items) with the next, round a ring (Mullis et al., 2009, *TIMSS 2011 Assessment Frameworks*, Exhibit 11). Booklets were spiralled, so the groups are randomly equivalent (about 330 each). **(a)** Random groups, no common items: booklets 11 and 13 (26 items each, means 11.7 and 15.0); equipercentile equating sends 12 on booklet 11 to 15.5 on booklet 13. **(b)** IRT true-score equating through the common items gives 15.2, within 0.3 of the equipercentile result for raw scores 4–13, drifting up to 0.8 apart at the top, where respondents are few. **(c)** The ring doesn't close. Chaining 14 separate Rasch calibrations by mean-mean linking, from booklet 1 round to booklet 1, is off by 1.1 logits. Every link carries the same small bias: an item is 0.08 logits harder in the second of a booklet's two mathematics blocks than in the first (0.080, SE 0.022, across 174 items; a person-and-item model gives −0.077 logits, SE 0.014), and 14 links add it up. | — |
| `pirlsmissing_sirt` | contrast | PIRLS 2011, one reading booklet (the "PIRLS reader"), four countries (AUT, DEU, FRA, NLD), 3,480 students, 35 items: nonequivalent groups with every item in common, across three languages. Separate 2PL calibrations linked to Austria: Germany sits 0.44 above by mean-mean and mean-sigma but 0.34–0.36 by Haebara and Stocking–Lord; the Netherlands 0.26–0.32, with an SD 0.73–0.81 of Austria's; France within 0.09 of Austria by every method. After Stocking–Lord, NLD–AUT differences in item difficulty run from −1.2 to +0.9 logits; dropping the 10 items that differ by more than 0.5 leaves the NLD mean at 0.27. The method matters more than the trimming here. | — |
| `cdm_timss03` | sanity | A complete table (757 × 23). Random halves take items 1–15 and 9–23 (7 common); linking must return $A = 1$, $B = 0$. Over 20 random splits, Stocking–Lord gives $A$ = 1.04 (SD 0.10), $B$ = 0.03 (SD 0.09). Any one split can miss by 0.3, which is worth saying in the lesson. | — |

**TIMSS or ENEM.** Ben decided (A4, #15) that `equating` may use ENEM as a subsample stored in the course repo if it is clearly better. I'd use TIMSS. ENEM's four booklets per area hold the same items in different orders, so booklet-to-booklet linking is really a test of position effects, and ENEM has no common items across years. TIMSS has a designed common-item ring with randomly equivalent groups, which teaches both designs on one table and turns up a real position effect. Its limits: groups of only about 330, and a short 9–14-item anchor per link.

Data notes (from the CDM and sirt documentation and the IRW landing pages; `get_processing_notes` was not available in this session): 26 of the 174 TIMSS items are parts of constructed-response items (suffixes A, B, C), which are scored separately and are likely locally dependent. PIRLS's "missing by intention and not reached" responses (9 in the source) are NA in the IRW (about 9% of responses); the lesson treats them as missing, not wrong, and says so.

## Widget / simulation / problem ideas

**Widgets**
- Equipercentile by hand: two score distributions (one form harder); drag a score on form X and see its percentile rank and the form-Y score at that rank; toggle linear equating (idea 3).
- Regression is not equating: predict Y from X and X from Y and watch the two lines disagree; the equating line is symmetric (idea 2).
- Stocking–Lord: common-item TCCs from two calibrations; sliders for $A$ and $B$ and the area between the curves; the optimum marked (idea 4).
- The ring: 14 booklets in a circle; a per-link bias slider (default 0.08) and a noise slider; the accumulated gap after going round (idea 6).

**Predict-then-check:** TIMSS booklets were spiralled, so every group is equivalent. If we calibrate each booklet on its own and link round the ring of 14, back to booklet 1, how far off will we be? Answered by the chained shifts: 1.1 logits, with every link biased in the same direction.

**Simulate:** from `ps6/equating_simstudy.R` (PS6#4). 50 Rasch items, $N$ respondents, 15 items each, three designs (eight overlapping forms; five forms with bigger overlaps; a random 15 for every respondent); concurrent calibration; correlation of estimated with true difficulties. Add a fourth design with a position effect on the common items. Seconds at $N = 150$.

**Problems**
1. Derivation: show that mean-mean linking for the 2PL gives $A = \bar a_1/\bar a_2$ and $B = \bar b_2 - A\bar b_1$ (under the chosen direction), and why regression of one form's scores on the other's is not symmetric.
2. Real data with a twist (from `c6/equate-irt.R`'s "devious" split): link two TIMSS booklets after restricting one group to its top 70% of scorers. What happens to $B$? Does IRT linking through the common items recover the right answer, and does random-groups equipercentile equating? (Not yet run: the solution must check.)
3. Judgment: the ring is off by 1.1 logits. Concurrent calibration hides the gap. Is that better or worse than separate calibration, which shows it?
4. Design (PS6#4): with 1,500 respondents and 15 items each for a 50-item bank, which design gives the best difficulties? What changes when blocks are two items, or one?
5. Real data: link PIRLS Germany to Austria (both German-language forms) and France to Austria. Which link would you trust more, and what would you check first?
6. Challenge (open, PS6#4 bonus): common-item designs need the anchors to behave the same in both forms. Design a study that would tell a position effect from a change in the population.

## Go deeper

- **Why the characteristic-curve methods beat mean-mean.** Moment methods weight every common item equally, including items whose parameters are poorly estimated; Stocking–Lord matches what respondents actually see (expected scores). A short derivation of the criterion and its gradient. Why: `item-banks-cat` (fixed-parameter calibration), `dif` (anchors), `scale-properties` (vertical scales). Length: half a page to a page.

## Open questions

- **TIMSS over ENEM** (see Tables): agree? If Ben wants ENEM anyway, the subsample spec would be two ENEM years in one area (e.g. mathematics 2014 and 2015), 5,000 respondents per booklet colour, but there are no common items across years, so it would support only random-groups equating within a year.
- **Scope of "linking".** The lesson covers equating and IRT linking and names vertical scaling; concordance (linking different tests, e.g. SAT–ACT) gets a sentence. Enough?
- **The position-effect finding** makes the lesson partly about how linking fails. It fits idea 6 and c6 slide 47, but it adds weight. Keep it as the predict-then-check, or move it to a problem and keep the main line on the equating functions?
- **Cross-language linking** (PIRLS) edges into DIF and alignment (Asparouhov & Muthén 2014, *not verified*). Keep PIRLS as the contrast, or use a same-language nonequivalent-groups design if one turns up?
