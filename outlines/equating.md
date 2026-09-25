<!-- Outlined 2026-09-24 from EDUC 252 slides c6 (slides 33–47), PS6#4, and the code c6/equate-obsscore.R, c6/equate-irt.R, c6/concurrent.R, ps6/equating.R, ps6/equating_simstudy.R. Tidied 09-24 to one session: concurrent calibration folded into IRT linking. -->

# Linking and equating (`equating`)

Module: uses · Prereqs: 1pl-to-4pl · Core · Status: drafted (see *Drafting notes* at the end)

Scope (F20): equating and IRT linking in full; vertical scaling named, with growth handed to `scale-properties` (E11); concordance (e.g. SAT–ACT) in one sentence.

## Core ideas

1. **Two scenarios, one problem.** Last year's form and this year's (equating); a grade-3 and a grade-4 test with some items in common (vertical scaling, named only). Equating makes scores on forms built to one blueprint interchangeable; linking is the looser family it belongs to. *(major)* Sources: c6 slides 33–36; Kolen & Brennan (2014), doi:10.1007/978-1-4939-0317-7; Linn (1993), doi:10.1207/s15324818ame0601_5 (Crossref lists the author as "Lim"); Dorans, Pommerich & Holland (Eds.) (2007), doi:10.1007/978-0-387-49771-6.
2. **What equating demands, and why design comes first.** Symmetry (not regression), equity (a respondent should be indifferent to the form), population invariance. "Equating is impossible if you didn't design things so that a solution exists": random groups, single group with counterbalancing, common-item nonequivalent groups (NEAT). *(major)* Sources: c6 slides 38–41; Lord (1980), doi:10.4324/9780203056615; Dorans & Holland (2000), doi:10.1111/j.1745-3984.2000.tb01088.x.
3. **Observed-score equating.** With randomly equivalent groups you need no common items: mean, linear and equipercentile equating, and why equipercentile needs smoothing. Sources: c6 slide 42; Kolen & Brennan (2014), chs. 2–3; Albano (2016), `equate`, doi:10.18637/jss.v074.i08.
4. **IRT linking through common items, or one concurrent fit.** Each calibration sits on its own scale: find $A$, $B$ with $\theta^* = A\theta + B$ (mean-mean, mean-sigma, then Haebara and Stocking–Lord), then IRT true-score equating. Or, since missing-by-design responses are no problem for IRT, stack the forms and fit once; what each route assumes. *(major)* Sources: c6 slides 43–46; Marco (1977), doi:10.1111/j.1745-3984.1977.tb00033.x; Loyd & Hoover (1980), doi:10.1111/j.1745-3984.1980.tb00825.x; Haebara (1980), doi:10.4992/psycholres1954.22.144; Stocking & Lord (1983), doi:10.1177/014662168300700208; Battauz (2015), `equateIRT`, doi:10.18637/jss.v068.i07; Kim & Cohen (1998), doi:10.1177/01466216980222003; Hanson & Béguin (2002), doi:10.1177/0146621602026001001.
5. **How linking breaks.** Common items that don't behave the same in both forms: position and context effects, drift, translation. Linking error accumulates along a chain. *(major)* Sources: c6 slide 47; Leary & Dorans (1985), doi:10.2307/1170392; Debeer & Janssen (2013), doi:10.1111/jedm.12009; Michaelides (2010), doi:10.3389/fpsyg.2010.00167; Haberman (2009), doi:10.1002/j.2333-8504.2009.tb02197.x.

DOIs checked on Crossref on 09-24. Holland & Dorans (2006), "Linking and equating", in Brennan (Ed.), *Educational Measurement* (4th ed.), has no DOI and is *not yet verified* (for *Going further*). Kernel equating (von Davier, Holland & Thayer, 2004, doi:10.1007/b97446) goes to *Going further*.

## Picks up

- The scale has no origin; compare across studies with care (thread from `rasch`).
- The 2PL and 3PL, slopes and test characteristic curves (from `1pl-to-4pl`).
- Missing responses by design (from `irw-data`).
- Whether a scale is interval changes group comparisons (from `measurement`): here only as the reason to link on $\theta$ rather than raw scores.
- Items that function differently across groups; drifting anchors are DIF by another name (from `dif`, not an ancestor: E2).
- Norms on a new form (from `score-meaning`, not an ancestor: E2).
- The linear indeterminacy of 2PL estimates across groups; invariance of person parameters across item sets (from `parameter-invariance`, extension: E2; otherwise idea 4 says it in two sentences).
- Many-item sparse designs; EM with missing blocks (from `item-estimation`, extension: E2; `mirt` does it for now).

## Promises / leaves open

- Vertical scales and what growth on them means → `scale-properties`.
- Item banks: new items calibrated onto the bank's scale (fixed-parameter calibration) → `item-banks-cat`.
- Position effects as an explanatory item model (item × position) → `explanatory-irt`.
- Linking across languages and countries; alignment → unpaid (Haberman 2009 and the PIRLS contrast only; Asparouhov & Muthén, 2014, *not verified*).
- Kernel equating, equating standard errors → unpaid (Going further).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `cdm_timss11` | main example | TIMSS 2011 grade 4 mathematics, Austria: 4,668 students, 174 items, 14 booklets. Each item appears in two booklets; each booklet shares one block (9–14 items) with the next, round a ring (Mullis et al., 2009, *TIMSS 2011 Assessment Frameworks*, Exhibit 11). Booklets were spiralled, so groups (about 330 each) are randomly equivalent. **(a)** Random groups, booklets 11 and 13 (means 11.7 and 15.0): equipercentile equating sends 12 on booklet 11 to 15.5 on booklet 13. **(b)** IRT true-score equating through the common items gives 15.2, within 0.3 of equipercentile for raw scores 4–13, up to 0.8 apart at the top, where respondents are few. **(c)** The ring doesn't close: chaining 14 separate Rasch calibrations by mean-mean linking back to booklet 1 is off by 1.1 logits. An item is 0.08 logits harder in the second of a booklet's two mathematics blocks (0.080, SE 0.022; a person-and-item model gives −0.077, SE 0.014), and 14 links add it up. | — |
| `pirlsmissing_sirt` | contrast | PIRLS 2011 reader booklet, four countries (AUT, DEU, FRA, NLD), 3,480 students, 35 items: nonequivalent groups, every item in common, three languages. Linked to Austria: Germany 0.44 above by mean-mean and mean-sigma, 0.34–0.36 by Haebara and Stocking–Lord; the Netherlands 0.26–0.32 (SD 0.73–0.81 of Austria's); France within 0.09. After Stocking–Lord, NLD–AUT item differences run from −1.2 to +0.9 logits; dropping the 10 beyond 0.5 leaves the NLD mean at 0.27. The method matters more than the trimming. It edges into DIF and alignment: the lesson says so and points to `dif` (F19). | — |
| `cdm_timss03` | sanity | A complete table (757 × 23). Random halves take items 1–15 and 9–23 (7 common); linking must return $A = 1$, $B = 0$. Over 20 splits, Stocking–Lord gives $A$ = 1.04 (SD 0.10), $B$ = 0.03 (SD 0.09); any one split can miss by 0.3. | — |

TIMSS, not ENEM (F17): ENEM's booklets hold the same items reordered, with no common items across years; TIMSS teaches both designs on one table and turns up a real position effect. Its limits: groups of about 330 and a 9–14-item anchor per link.

Data notes: 26 of the 174 TIMSS items are parts of constructed-response items, scored separately and likely locally dependent. PIRLS's "missing by intention and not reached" responses are NA in the IRW (about 9%); the lesson treats them as missing, not wrong. Processing notes still to read (D).

## Widget / simulation / problem ideas

**Widgets**
- Equipercentile by hand: two score distributions; drag a form-X score to its percentile rank and the form-Y score at that rank; toggle linear equating (idea 3).
- Regression is not equating: predict Y from X and X from Y; the two lines disagree, the equating line is symmetric (idea 2).
- Stocking–Lord: common-item TCCs from two calibrations; sliders for $A$ and $B$ and the area between the curves (idea 4).
- The ring: 14 booklets in a circle; per-link bias (default 0.08) and noise sliders; the gap after going round (idea 5).

**Predict-then-check (F18):** TIMSS booklets were spiralled, so every group is equivalent. Calibrate each booklet alone and link round the ring of 14 back to booklet 1: how far off will we be? Answered by the chained shifts: 1.1 logits, every link biased the same way.

**Simulate:** from `ps6/equating_simstudy.R` (PS6#4): 50 Rasch items, 15 per respondent, three designs; concurrent calibration; correlation of estimated with true difficulties; a fourth design with a position effect on the common items. Seconds at $N = 150$.

**Problems**
1. Derivation: mean-mean linking for the 2PL gives $A = \bar a_1/\bar a_2$ and $B = \bar b_2 - A\bar b_1$; why regression of one form's scores on the other's is not symmetric.
2. Real data with a twist (`c6/equate-irt.R`'s "devious" split): link two TIMSS booklets after restricting one group to its top 70%. What happens to $B$, under IRT linking and under random-groups equipercentile? (Not yet run: the solution must check.)
3. Judgment: concurrent calibration hides the ring's 1.1-logit gap. Better or worse than separate calibration, which shows it?
4. Design (PS6#4): 1,500 respondents, 15 items each, a 50-item bank. Which design gives the best difficulties? What if blocks are two items, or one?
5. Real data: link PIRLS Germany and France to Austria. Which link would you trust more, and what would you check first?
6. Challenge (open, PS6#4 bonus): design a study that would tell a position effect from a change in the population.

## Go deeper

- **Why the characteristic-curve methods beat mean-mean.** Moment methods weight every common item equally, including poorly estimated ones; Stocking–Lord matches expected scores. The criterion and its gradient. Why: `item-banks-cat`, `dif` (anchors), `scale-properties`. Length: half a page to a page.

## Open questions

- None. Settled 09-24: TIMSS over ENEM (F17); the position effect as the predict-then-check (F18); PIRLS with a pointer to `dif` (F19); scope (F20); core (S4).

## Drafting notes (09-24, PR for #47)

- All five core ideas taught. Numbers recomputed at the v59 pin: booklet 11 mean 11.6 (not 11.7); ring gap 1.08 (9 of 14 links positive); position effect −0.077 (SE 0.014), concentrated in position 4 vs 1 (−0.120, SE 0.034) rather than 2 vs 3 (−0.035, SE 0.034). IRT true-score (concurrent 2PL) vs smoothed equipercentile: within 0.65 from scores 6–18, 2.3 apart at a score of 2 (the outline's "0.3 for 4–13" came from a different fit).
- Sanity table `cdm_timss03` run outside the lesson: 20 random splits, Stocking–Lord A = 1.02 (SD 0.10), B = 0.00 (SD 0.11).
- Simulate found that concurrent calibration carries a position effect along a chain (first five items −0.42, last five +0.65 at N = 600), so the text says so.
- Widgets: regression vs equating; equipercentile by hand; Stocking–Lord by hand; the ring. Problem 3 reframed (the verdict answers the outline's version). Linking across languages/alignment and kernel equating stay unpaid.
