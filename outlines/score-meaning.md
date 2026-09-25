<!-- Outlined 2026-09-24. New material (not in EDUC 252), from the landscape analysis (notes/landscape-2026-09-24.md, gap 4; gap 8 folds SEM bands and difference scores in here) and the Standards (AERA, APA & NCME, 2014, ch. 5). Tidied 09-24 to one session: norms merged into idea 1, score reports cut to a short idea. -->

# What does a score mean? Norms, error bands, and cut scores (`score-meaning`)

Module: uses · Prereqs: ctt-reliability, information · Core · Status: drafted (#61)

## Core ideas

1. **A raw score means nothing until you compare it with something.** Norm-referenced (people) and criterion-referenced (a domain or a standard) meaning; the Standards ask for both to be stated (5.1). Percentile ranks are ordinal and need no interval claim; z and linear T scores keep the raw score's shape; normalized T scores force a normal shape, and they part company when the raw distribution is skewed. A norm is only as good as its reference group: who, where, when (5.8, 5.9). *(major)* Sources: Glaser (1963), doi:10.1037/h0049294; Angoff (1971), "Scales, norms, and equivalent scores", in Thorndike (Ed.), *Educational Measurement* (2nd ed.) (chapter, no DOI; *to verify*); AERA, APA & NCME (2014), ch. 5, https://www.testingstandards.net/open-access-files.html; Kolen & Brennan (2014), doi:10.1007/978-1-4939-0317-7 (scaling and norming chapter; number *to verify*); Kocalevent, Hinz & Brähler (2013), doi:10.1016/j.genhosppsych.2013.04.006; Cella et al. (2010), doi:10.1016/j.jclinepi.2010.04.011 (PROMIS T scores).
2. **Error bands: one SEM, or a conditional one.** Pays off `ctt-reliability`'s "one SEM for everyone": a ±1.96 SEM band around an observed score, then the band from the IRT conditional SEM (a Recall of `information`), narrow in the middle and very wide at the floor. Report the SEM near each cut (Standard 2.14). *(major)* Sources: Lord & Novick (1968) (book, *to verify*); Kolen, Zeng & Hanson (1996), doi:10.1111/j.1745-3984.1996.tb00485.x.
3. **Difference scores and reliable change.** The reliability of a difference falls as the two scores correlate; the reliable change index asks whether a change exceeds $1.96\sqrt{2}\,\text{SEM}$. Lord's pessimism and Rogosa and Willett's reply: a difference is reliable when people really differ in how much they change (Standard 2.4). Sources: Lord (1956), doi:10.1177/001316445601600401; Cronbach & Furby (1970), doi:10.1037/h0029382; Rogosa & Willett (1983), doi:10.1111/j.1745-3984.1983.tb00211.x; Jacobson & Truax (1991), doi:10.1037/0022-006x.59.1.12.
4. **Cut scores are decisions, not discoveries.** Empirical cuts (the PHQ-9's 10 was chosen against diagnostic interviews, and neighbouring cuts do about as well) and judgmental ones (Angoff, taught with a widget; the bookmark method named only, F14). Either way the cut needs a documented rationale (Standards 5.21, 5.23), and classification near it is unreliable. *(major)* Sources: Kroenke, Spitzer & Williams (2001), doi:10.1046/j.1525-1497.2001.016009606.x; Manea, Gilbody & McMillan (2012), doi:10.1503/cmaj.110829; Levis, Benedetti & Thombs (2019), doi:10.1136/bmj.l1476; Cizek & Bunch (2007), doi:10.4135/9781412985918; Cizek (Ed.) (2012), doi:10.4324/9780203848203 (bookmark chapter by Lewis et al., *to verify*); Glass (1978), doi:10.1111/j.1745-3984.1978.tb00072.x; Livingston & Lewis (1995), doi:10.1111/j.1745-3984.1995.tb00462.x.
5. **Score reports.** What a report carries: the score, its band, the norm group and its date, the cut and what it means, and what not to conclude. Which estimate to report for individuals, and why group statistics use plausible values instead (C12: one paragraph in `ability-estimation`, the fuller treatment here). Sources: Goodman & Hambleton (2004), doi:10.1207/s15324818ame1702_3; Zenisky & Hambleton (2012), doi:10.1111/j.1745-3992.2012.00231.x; Mislevy, Beaton, Kaplan & Sheehan (1992), doi:10.1111/j.1745-3984.1992.tb00371.x; Wu (2005), doi:10.1016/j.stueduc.2005.05.005.

DOIs checked on Crossref on 09-24; the Standards on the AERA open-access page. Angoff (1971), Lord & Novick (1968) and the bookmark chapter have no DOI and are *not yet verified*.

Boundary (settled 09-24): this lesson takes cut scores as decisions (norms, error near the cut, classification consistency); `validity-evidence` takes classification accuracy against a criterion.

## Picks up

- $X = T + E$, reliability, one SEM for everyone (thread from `ctt-reliability`).
- The conditional SEM, $1/\sqrt{I(\theta)}$; cut scores where information is low (from `information`).
- Whether a scale is interval changes group comparisons (from `measurement`): percentile ranks need only order; z and T scores assume more.
- Item-rest correlations and sum scores (from `irw-data`, `ctt-reliability`).
- Decision inferences, cut scores and consequences (from `validity-argument`, not an ancestor: E2).
- Classification accuracy against a criterion (from `validity-evidence`, not an ancestor: E2).
- Choosing an estimator for reporting; shrinkage; plausible values (from `ability-estimation`, not a prerequisite, E10: an "if you've done" Recall).
- Absolute error for decisions against a cut score (from `g-theory`, not an ancestor: E2).
- Omega as the reliability of a model-implied sum score (from `fa-confirmatory`, not an ancestor: E2; the SEM can use either coefficient).

## Promises / leaves open

- Norms on a new form need the forms linked first → `equating`.
- Whether a unit means the same across the scale (does a 5-point gain at 20 equal one at 5?) → `scale-properties`.
- Conditional precision at a cut; adaptive and classification stopping rules → `item-banks-cat`.
- Reliable change assumes the same construct at both waves → `invariance-experience`.
- Fairness of cut scores across groups (item-level DIF is `dif`'s; predictive bias `validity-evidence`'s; neither treats cuts) → unpaid.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `c19prc_uk_mcbride_2021_phq9` | main example | PHQ-9 in the UK COVID-19 Psychological Research Consortium panel. Wave 1: 2,025 adults, a quota sample on age, sex and income (McBride et al., 2021, doi:10.1002/mpr.1861), mean 5.4, SD 6.2, skew 1.3. 22% score 10 or more; a 10 is the 79th percentile overall, the 65th for ages 18–34 and the 90th for 55+. A raw 20 gives a linear T of 73.5 and a normalized T of 68.6. Alpha 0.92, SEM 1.7; 42% of those at or above 10 have a 95% band that includes 10. The graded model puts the cut at θ = 0.86, SE 0.21; at θ = −2 the SE is 2.8. Waves 1–2 (1,406 adults): r = 0.70, change-score reliability 0.73; RCI threshold 4.8 points; 14% cross the cut between waves, and about a quarter of them (3.8% of the sample) change by less than the threshold. | — |
| `coroiu_2018_phq9` | contrast | The same items in a German general-population sample, 2,404 complete (Coroiu et al., 2018). Mean 2.3, SD 3.2; 4.1% score 10 or more, so a 10 is the 96th percentile. The samples differ in country, year, language and mode as well as timing, so the lesson says plainly that the gap can't be put down to the pandemic: a lesson about reference groups (F16). | — |
| `c19prc_uk_mcbride_2021_phq9` (wave 1) | sanity | Shevlin et al. (2020), doi:10.1192/bjo.2020.109, report the wave-1 prevalence of PHQ-9 ≥ 10; we get 22% (the paper's figure and alpha to check). | — |

The PHQ-9 is the main example (F15): real norms, a real cut and two waves; no tokenless achievement table has norms and a published cut. `kohlmann_2016_phq9` (German cardiac patients: a 10 is the 84th percentile) is held for problem 5, not the main line. Keying: items 0–3, higher = more frequent symptoms, none reversed. Item text: the PHQ-9 is free to reproduce (Pfizer's statement, *to verify* under A5).

## Widget / simulation / problem ideas

**Widgets**
- Norm-group switcher: one PHQ-9 score and its percentile rank, z, linear T and normalized T under three reference groups (UK overall, UK by age band, German) (idea 1).
- Error band: ±1.96 SEM from CTT (constant) and from the graded model (conditional), against the cut at 10 (idea 2).
- Reliable change: correlation and reliability sliders; the difference's reliability and the RCI band update (idea 3).
- Angoff table: five judges rate the probability that a borderline respondent answers each of ten Rasch items; the sum is the cut, the judges' spread its standard error; converted to θ through the test characteristic curve (idea 4).

**Predict-then-check:** a PHQ-9 score of 10 is the usual screening cut. In UK adults in spring 2020, what percentile is a 10, and is it the same for 18–34-year-olds as for those 55 and over? Answered by the percentile table (79th overall; 65th and 90th).

**Simulate:** a skewed trait, a nine-item graded test, a cut at a chosen θ; two administrations; the proportion classified the same way twice against the CTT and IRT predictions (Livingston & Lewis, 1995). Base R plus `mirt`, a few seconds.

**Problems**
1. Derivation: the reliability of a difference score; when does it reach zero? (Lord, 1956.)
2. Real data with a twist: the RCI with the wave-2 reliability and with test–retest instead of alpha. Which SEM is right for change, and how many "reliable changers" move?
3. Judgment: a clinic uses the UK 2020 norms for a patient in 2026. What would you tell them (Standard 5.9)?
4. Design: a score report for one respondent (score, band, percentile with norm group and date, cut). What would you leave out?
5. Real data: add the cardiac sample (`kohlmann_2016_phq9`). Which reference group should a cardiologist use?
6. Challenge (open): the cut of 10 was chosen for sensitivity and specificity in primary care. Should a population survey use it to report "prevalence"?

## Go deeper

- **Classification consistency at a cut.** From CTT (Livingston & Lewis, 1995) or IRT (integrating over each respondent's posterior), the probability that two parallel administrations agree about the side of the cut. Why: `item-banks-cat`, `validity-evidence`, `g-theory`. Length: about a page.

The reliability of a difference score stays problem 1, not a callout.

## Open questions

- None. Settled 09-24: prerequisites (E10); standard setting as one idea with an Angoff widget (F14); the PHQ-9 (F15); the German contrast as a lesson about reference groups (F16); the boundary with `validity-evidence` (B).

## Changes in drafting (#61, 09-25)

- **Sanity check verified:** Shevlin et al. (2020) report 22.1% (95% CI 20.3–23.9) at PHQ-9 ≥ 10 and alpha 0.92 in wave 1; the page reproduces 22.1% and 0.921.
- **German sample:** collected in 2012 by face-to-face household interviews (Coroiu et al., 2018, Methods); UK wave 1 online, 23–28 March 2020 (Shevlin et al., 2020). The page says the gap can't be put down to the pandemic, and cites Kocalevent et al. (2013) for an earlier German figure (5.6% at ≥ 10).
- **Cut on θ:** where the test characteristic curve reaches 10 (0.86). Error bands are compared on the raw scale too: the model's SEM at 10 is 2.36 against CTT's 1.74, which carries the verdict.
- **Simulate:** compares the model's consistency prediction with CTT's normal approximation (Livingston–Lewis is described in the Go deeper callout, not coded).
- **Sources:** Glass (1978) dropped (couldn't verify what it argues beyond a reply's summary); the bookmark chapter is cited from Cizek & Bunch (2007, ch. 10, doi:10.4135/9781412985918.n10) instead of Cizek (Ed.) (2012). Angoff (1971) verified against Open Library (the volume) and a citing reference list (pages 508–600). Added Lord & Wingersky (1984) and Lee (2010, doi:10.1111/j.1745-3984.2009.00096.x) for the callout.
- **PHQ-9 reuse (A5):** the instruction manual (p. 8) says the PHQ measures are in the public domain and need no permission; phqscreeners.com/select-screener says the same. The page quotes only item 1.
- **`ability-estimation`** was a stub on the base branch, so there is no Recall of it; plausible values get their full treatment here (C12).

## Revisions after Ben's review (#137, 09-25)

- The *Standards* now link to the open-access full text (PDF, with `#page=` anchors for Standards 2.4, 2.14, 5.1, 5.8, 5.9, 5.21, 5.23 and 6.10) and are in Going further.
- "One score, four reference groups": the table stays; the single-group chart is replaced by four stacked panels on a shared axis with a movable cut line and each group's share at or above it (at 10: 36.9%, 22.1%, 10.5%, 4.1%).
- Error-band widget: the bars are bands in PHQ-9 score points (the spread of the sum at a given θ), which narrow near the floor and ceiling because the expected-score curve flattens there, while the CSEM on θ grows. Axis and legend now name the scale; the text explains it, and the `raw-csem` chunk prints the curve's slope and shows score-point SEM ÷ slope ≈ θ-scale CSEM (0.44 vs 0.41 at a score of 1; 0.21 vs 0.21 at 10).
