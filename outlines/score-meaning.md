<!-- Outlined 2026-09-24. New material (not in EDUC 252), from the landscape analysis (notes/landscape-2026-09-24.md, gap 4; gap 8 folds SEM bands and difference scores in here) and the Standards (AERA, APA & NCME, 2014, ch. 5). -->

# What does a score mean? Norms, error bands, and cut scores (`score-meaning`)

Module: uses · Prereqs: ctt-reliability (proposed: add `information`; see Open questions) · Core · Status: outline

## Core ideas

1. **A raw score means nothing until you compare it with something.** Norm-referenced meaning (compared with people) and criterion-referenced meaning (compared with a domain or a standard). The Standards ask for both to be stated (Standard 5.1). *(major)* Sources: Glaser (1963) on criterion-referenced measurement, doi:10.1037/h0049294; Angoff (1971), "Scales, norms, and equivalent scores", in Thorndike (Ed.), *Educational Measurement* (2nd ed.), ACE (chapter; no DOI, *to verify*); AERA, APA & NCME (2014), *Standards for Educational and Psychological Testing*, ch. 5, https://www.testingstandards.net/open-access-files.html (checked 09-24).
2. **Norms: percentile ranks, z, T and normalized scores.** Percentile ranks are ordinal and need no interval claim; z and linear T scores keep the raw score's shape; normalized T scores force a normal shape. They part company when the raw distribution is skewed. A norm is only as good as its reference group: who, where, when (Standards 5.8, 5.9). *(major)* Sources: Angoff (1971); Kolen & Brennan (2014), *Test Equating, Scaling, and Linking* (3rd ed.), Springer, doi:10.1007/978-1-4939-0317-7, ch. 9 (scaling and norming; chapter number *to verify*); Kocalevent, Hinz & Brähler (2013), German PHQ-9 norms, doi:10.1016/j.genhosppsych.2013.04.006; Cella et al. (2010) on PROMIS T scores centred on a US general-population sample, doi:10.1016/j.jclinepi.2010.04.011.
3. **Error bands: one SEM, or a conditional one.** Pays off `ctt-reliability`'s "one SEM for everyone": a ±1.96 SEM band around an observed score, then the same band from the IRT conditional SEM, which is narrow in the middle and very wide at the floor. Report the SEM near each cut score (Standard 2.14). *(major)* Sources: Lord & Novick (1968), *Statistical theories of mental test scores* (book, *to verify*); Kolen, Zeng & Hanson (1996), doi:10.1111/j.1745-3984.1996.tb00485.x; Samejima (1977), doi:10.1177/014662167700100209 (cited in `information`).
4. **Difference scores and reliable change.** The reliability of a difference falls as the two scores correlate; the reliable change index asks whether a change exceeds $1.96\sqrt{2}\,\text{SEM}$. Lord's pessimism and Rogosa and Willett's reply: a difference is reliable when people really differ in how much they change. Standard 2.4 asks for standard errors of differences. Sources: Lord (1956), doi:10.1177/001316445601600401; Cronbach & Furby (1970), doi:10.1037/h0029382; Rogosa & Willett (1983), doi:10.1111/j.1745-3984.1983.tb00211.x; Jacobson & Truax (1991), doi:10.1037/0022-006x.59.1.12.
5. **Cut scores are decisions, not discoveries.** Two routes: empirical (the PHQ-9's 10 was chosen against diagnostic interviews, and neighbouring cuts do about as well) and judgmental (Angoff, bookmark). Either way the cut needs a documented rationale (Standards 5.21, 5.23), and classification near it is unreliable. A short treatment. *(major)* Sources: Kroenke, Spitzer & Williams (2001), doi:10.1046/j.1525-1497.2001.016009606.x; Manea, Gilbody & McMillan (2012), doi:10.1503/cmaj.110829; Levis, Benedetti & Thombs (2019), doi:10.1136/bmj.l1476; Angoff (1971); Cizek & Bunch (2007), *Standard Setting*, SAGE, doi:10.4135/9781412985918; Cizek (Ed.) (2012), *Setting Performance Standards* (2nd ed.), Routledge, doi:10.4324/9780203848203 (bookmark chapter by Lewis, Mitzel, Mercado & Schulz, *to verify*); Glass (1978), doi:10.1111/j.1745-3984.1978.tb00072.x (the critique); Livingston & Lewis (1995), doi:10.1111/j.1745-3984.1995.tb00462.x (classification consistency).
6. **Score reports.** What a report should carry: the score, its band, the norm group and its date, the cut and what it means, and what not to conclude. Which estimate to report for individuals, and why group statistics use plausible values instead (a paragraph, from `ability-estimation`). Sources: Goodman & Hambleton (2004), doi:10.1207/s15324818ame1702_3; Zenisky & Hambleton (2012), doi:10.1111/j.1745-3992.2012.00231.x; Mislevy, Beaton, Kaplan & Sheehan (1992), doi:10.1111/j.1745-3984.1992.tb00371.x; Wu (2005), doi:10.1016/j.stueduc.2005.05.005.

All DOIs above were checked on Crossref on 09-24 (Crossref gives Manea et al. online 2011, print 2012; Jacobson & Truax also appears as a 1992 book reprint, doi:10.1037/10109-042). The book DOIs (Kolen & Brennan, Cizek & Bunch, Cizek) were checked on Crossref, and the Standards on the AERA open-access page. Angoff (1971), Lord & Novick (1968) and the bookmark chapter have no DOI and are *not yet verified*.

## Picks up

- $X = T + E$, reliability, one SEM for everyone (thread from `ctt-reliability`).
- The conditional SEM, $1/\sqrt{I(\theta)}$; cut scores where information is low (from `information`; not a prerequisite yet, see Open questions).
- Choosing an estimator for reporting; shrinkage and group comparisons; plausible values in full here (from `ability-estimation`; not a prerequisite).
- Absolute error for decisions against a cut score (from `g-theory`, if taught first; not a prerequisite).
- Omega as the reliability of a model-implied sum score (from `fa-confirmatory`, if taught first; the SEM can use either coefficient).
- Whether a scale is interval changes group comparisons (from `measurement`): percentile ranks need only order; z and T scores assume more.
- Item-rest correlations and sum scores (from `irw-data`, `ctt-reliability`).

## Promises / leaves open

- Norms on a new form need the forms linked first → `equating`.
- Whether a unit means the same thing across the scale (does a 5-point gain at 20 equal one at 5?) → `scale-properties`.
- Conditional precision and adaptive stopping rules (precision where the cut is) → `item-banks-cat`.
- Cut scores judged against a criterion (sensitivity, specificity, a diagnosis) → `validity-evidence`.
- Fairness of cut scores across groups → `dif`; otherwise unpaid (predictive bias is `validity-evidence`'s, per landscape gap 7).
- Reliable change assumes the same construct at both waves → `invariance-experience`.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `c19prc_uk_mcbride_2021_phq9` | main example | PHQ-9 in the UK COVID-19 Psychological Research Consortium panel. Wave 1: 2,025 adults, a quota sample on age, sex and income (McBride et al., 2021, doi:10.1002/mpr.1861), mean 5.4, SD 6.2, median 3, skew 1.3. 22% score 10 or more; a 10 is the 79th percentile overall but the 65th for ages 18–34 and the 90th for 55+. A raw 20 gives a linear T of 73.5 and a normalized T of 68.6. Alpha 0.92, SEM 1.7; 42% of those at or above 10 have a 95% band that includes 10. The graded model puts the cut at θ = 0.86, SE 0.21; at θ = −2 the SE is 2.8 (floor). Waves 1–2 (1,406 adults): r = 0.70, so the reliability of the change score is 0.73, not Lord's near-zero; the RCI threshold is 4.8 points; 14% cross the cut between waves, and about a quarter of them (3.8% of the sample) change by less than the threshold. | — |
| `coroiu_2018_phq9` | contrast | The same nine items in a German general-population sample, 2,404 complete cases (Coroiu et al., 2018). Mean 2.3, SD 3.2; only 4.1% score 10 or more, so a 10 is the 96th percentile. Same score, same items, a different norm group: the 79th percentile against the 96th. The samples differ in country, year, language and mode as well as in timing (before and during the pandemic), so the lesson must not read the gap as a pandemic effect. | — |
| `c19prc_uk_mcbride_2021_phq9` (wave 1) | sanity | Shevlin et al. (2020), doi:10.1192/bjo.2020.109, report the wave-1 prevalence of PHQ-9 ≥ 10; we get 22%. The paper's exact figure still needs checking (I recall 22.1%). Also check alpha against the paper. | — |

Two tables. A third (`kohlmann_2016_phq9`, German cardiac patients: 18% ≥ 10, so a 10 is the 84th percentile) would add a clinical reference group; I'd hold it for a problem rather than the main line.

Keying: PHQ-9 items are 0–3, higher = more frequent symptoms; no reverse-keyed items. Item text: the PHQ-9 is free to reproduce (Pfizer's statement on phqscreeners.com, *to verify* under the #63 policy), so the lesson may show the items.

## Widget / simulation / problem ideas

**Widgets**
- Norm-group switcher: one PHQ-9 score slider, and its percentile rank, z, linear T and normalized T under three reference groups (UK 2020 overall, UK by age band, German general population) (ideas 1, 2).
- Error band: a score with its ±1.96 SEM band from CTT (constant) and from the graded model (conditional), drawn against the cut at 10 (idea 3).
- Reliable change: two waves, a correlation slider and a reliability slider; the reliability of the difference and the RCI band update; points outside the band light up (idea 4).
- Angoff table: five judges rate the probability that a borderline respondent answers each of ten Rasch items; the sum is the cut; judges' spread gives the cut's standard error; converts to θ through the test characteristic curve (idea 5).

**Predict-then-check:** a PHQ-9 score of 10 is the usual screening cut. In a general-population sample of UK adults in spring 2020, what percentile is a 10, and is it the same for 18–34-year-olds as for those 55 and over? Answered by the percentile table (79th overall; 65th and 90th).

**Simulate:** a population with a skewed trait (many at the floor), a nine-item graded-response test, a cut at a chosen θ; simulate two administrations; compare the proportion classified the same way twice with the CTT and IRT predictions (Livingston & Lewis, 1995; the IRT version by integrating over the posterior). Base R plus `mirt`, a few seconds.

**Problems**
1. Derivation: the reliability of a difference score, $\rho_{DD'} = (\sigma_1^2\rho_{11'} + \sigma_2^2\rho_{22'} - 2\rho_{12}\sigma_1\sigma_2)/(\sigma_1^2+\sigma_2^2-2\rho_{12}\sigma_1\sigma_2)$; when does it reach zero? (Lord, 1956.)
2. Real data with a twist: recompute the RCI with the wave-2 reliability and with test–retest instead of alpha. Which is the right SEM for change, and how many "reliable changers" move?
3. Judgment: a clinic uses the UK 2020 norms for a patient in 2026. What would you tell them (Standard 5.9)?
4. Design: a score report for one respondent (score, band, percentile with its norm group and date, cut). What would you leave out?
5. Real data: add the cardiac sample (`kohlmann_2016_phq9`). Which reference group should a cardiologist use?
6. Challenge (open): the cut of 10 was chosen for sensitivity and specificity in primary care. Should a population survey use the same cut to report "prevalence"? What would you need to know?

## Go deeper

- **Classification consistency at a cut.** From a model (CTT, following Livingston & Lewis, 1995; or IRT, integrating over each respondent's posterior), the probability that two parallel administrations agree about which side of the cut a respondent is on. Why: `item-banks-cat` (classification stopping rules), `validity-evidence` (classification accuracy), `g-theory` (absolute error). Length: about a page.
- **The reliability of a difference score** (as problem 1 or a callout). Why: `invariance-experience`, `scale-properties` (gains). Length: half a page.

## Open questions

- **Prerequisites.** `information` (the conditional SEM) and `ability-estimation` (which estimate to report; plausible values) both hand things to this lesson, but the only prerequisite is `ctt-reliability`. Proposed: add `information` as a prerequisite (both are core), and treat `ability-estimation` as optional. Without it, idea 3 teaches the conditional SEM from scratch.
- **Standard setting depth.** One core idea (5) and one widget (Angoff), with the bookmark method named but not taught. Enough for a first course, or should standard setting become its own optional lesson?
- **A screening scale as the main example.** The PHQ-9 gives real norms, a real cut and two waves, but it is a clinical screener. An achievement test would have scale scores and a judged cut; the IRW has no tokenless table I found with both norms and a published cut. Keep PHQ-9?
- **Dates and pandemic context.** The contrast (German pre-pandemic sample against the UK spring-2020 panel) differs in country, language, year and mode. The lesson should say plainly that the gap can't be attributed to the pandemic. Agree to show it anyway, as a lesson about reference groups?
- **Boundary with `validity-evidence`.** This lesson takes cut scores as decisions (norms, error near the cut, classification consistency); `validity-evidence` takes classification accuracy against a criterion. Proposed to course-bd on 09-24; not yet confirmed.
