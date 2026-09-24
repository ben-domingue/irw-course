<!-- Outlined 2026-09-24 from EDUC 252 slides c3 (slides 2–22, validity) and c4 (slides 2–3, 16–17). -->

# Validity as an argument (`validity-argument`)

Module: validity · Prereqs: constructs · Core · Status: outline

## Core ideas

1. **We validate interpretations and uses, not tests.** The consensus definition: validity is "the degree to which evidence and theory support the interpretations of test scores for proposed uses of tests". "Thou shalt not speak of validated measures" (slide 8). The SAT example (slide 9, marked hypothetical): the same scores used for college admission and for ranking schools need different evidence. *(major)* Sources: AERA, APA & NCME (2014), *Standards for Educational and Psychological Testing*, ch. 1 (open access at https://www.testingstandards.net/open-access-files.html; book, no DOI); Cook & Beckman (2006), doi:10.1016/j.amjmed.2005.10.036 (the "carefully structured argument" definition on slide 3); Messick (1995), doi:10.1037/0003-066X.50.9.741; Hubley & Zumbo (2011), doi:10.1007/s11205-011-9843-4.
2. **From types of validity to one construct validity.** Criterion, content and construct validity as separate "types"; the move, via Cronbach & Meehl, to construct validity as the whole, with internal (structure) and external (relations, consequences) components and a demand for evidence that could falsify the inference (slides 5–7). *(major)* Sources: Cronbach & Meehl (1955), doi:10.1037/h0040957; Messick (1989), "Validity", in R. L. Linn (Ed.), *Educational measurement* (3rd ed., pp. 13–103) (book chapter, no DOI; **details unverified**); Messick (1995) above.
3. **The argument.** Kane's interpretation/use argument: a chain of inferences (scoring → generalization → extrapolation → decision), each with a warrant and backing, laid out before data collection so you know which evidence matters most (slide 18). Five sources of evidence in the Standards (content, response processes, internal structure, relations to other variables, consequences), with Cook & Beckman's Table 2 as a worked map from inference to evidence (slides 12–17). *(major)* Sources: Kane (1992), doi:10.1037/0033-2909.112.3.527; Kane (2013), doi:10.1111/jedm.12000; Standards (2014), ch. 1; Cook & Beckman (2006), Table 2.
4. **Reliability is necessary, not sufficient.** Three blood-pressure readings of 185/100, 80/40 and 140/70 in three minutes: you wouldn't average them (slide 11, from Cook & Beckman). Alpha = 0.81 in a sentence (slide 2): what does it license, and what doesn't it? Sources: Cook & Beckman (2006), p. 166.e8; Recall `ctt-reliability`.
5. **A measure is never finished: uses evolve.** Campbell's law (slide 19). The validity paradox: the modern conception is demanding for good reasons, yet a complete argument can feel operationally impossible, and practice rarely supplies the studies a stated purpose implies (the CAASPP's four purposes, slide 21). This is the opening for Borsboom's narrower view (`validity-causal`). Sources: Campbell (1979), doi:10.1016/0149-7189(79)90048-X; California Department of Education, CAASPP purposes (the slide's wording appears in the CDE *Parent Guide to Understanding* the score report, e.g. a district copy at https://www.cusdk12.org/documents/Forms--Information/CAASPP-ParentGuide-Grade-11.pdf; **the CDE original is still to locate**); Markus & Borsboom (2013), doi:10.4324/9780203501207.
6. **What to ask whenever validity comes up** (slide 20): what is the proposed use or inference; what evidence supports it; is that evidence sufficient?

Crossref-checked 09-24 unless marked.

## Picks up

- Constructs as postulated attributes; the Cronbach–Meehl sentence (from `constructs`).
- Blueprints and domain sampling as the start of content evidence (from `constructs`).
- A measure should be insensitive to nonfocal attributes (from `measurement`; also → `dif`).
- Alpha and what reliability is (from `ctt-reliability`, which is *not* a prerequisite here: see Open questions).

## Promises / leaves open

- Each source of evidence in practice: convergent/discriminant, criterion, classification, content → `validity-evidence`.
- The validity paradox; validity as causation → `validity-causal`.
- Nonfocal attributes and fairness at the item level → `dif`.
- Consequences as evidence (Campbell's law, score reports that are never studied) → unpaid; `score-meaning` touches score reports.
- Decision inferences and cut scores → `score-meaning`.
- The same scores, two uses: an outcome for evaluating an intervention vs. a measure of the construct → `invariance-experience`.

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `silk_2019_inattentive` | main example | Parent-reported DSM-IV inattentive symptoms from the DISC-IV interview (Silk et al., 2019, doi:10.1371/journal.pone.0211053), 9 items, 355 children aged 6.4–8.7, with an ADHD indicator. Alpha 0.92. The symptom count separates the ADHD and non-ADHD groups almost perfectly (AUC 0.99): no child without ADHD has 6 or more symptoms. | — |
| `silk_2019_hyperactive` | contrast (the other half of the rule) | The 9 hyperactive/impulsive symptoms for the same children (alpha 0.88; AUC 0.93 alone). Together the two tables show that the ADHD indicator is exactly "6 or more symptoms in either domain" (209 of 209 without, 146 of 146 with): the DSM-IV rule applied to these same items. | — |

The finding the section is built around: an AUC of 0.99 looks like strong extrapolation evidence, but here it is true by construction. The indicator is the decision rule applied to the items, so it backs the *scoring* and *decision* inferences (the count is computed as DSM says) and says nothing about the *extrapolation* inference (that the count tracks impairment in the world). Which inference a piece of evidence supports is the point of laying out the argument. The study was designed for a network analysis of symptoms, not to validate a screener, and the lesson says so plainly: this is a fact about the design, not a flaw. Silk et al. themselves discuss the 6-symptom threshold (their Introduction).

Diagnostic source: Shaffer et al. (2000), NIMH DISC-IV, doi:10.1097/00004583-200001000-00014. Item text: the nine DSM-IV symptom labels are short paraphrases already in the item ids (`avoid`, `closeatt`, `fidget`, `interrupt`, …); the lesson uses those labels, not DSM text. Table citations come from IRW biblio.

Sanity table: none. There is no model fit; the check is the cross-tabulation itself.

## Widget / simulation / problem ideas

**Widgets**
- Build an argument: pick a use (admission, school ranking, screening, research) for one set of scores; the widget lays out Kane's four inferences and asks which of Cook & Beckman's evidence sources backs each (ideas 1, 3).
- Blood pressure: three readings with adjustable error; how many readings before you'd trust the average? (idea 4)
- The contaminated criterion: a simulated screener and a "diagnosis" that mixes an independent criterion with the screener's own items; slide the mixing weight and watch the AUC rise while agreement with the independent criterion stays put (ideas 3, 4).

**Predict-then-check:** in the Silk data, how well will the inattentive count separate children with and without ADHD? Most readers will guess "well, not perfectly". Answered by the cross-tabulation (AUC 0.99; none of the 209 without ADHD has 6+ symptoms), then by the "either domain" table, which shows why.

**Simulate:** conceptual lesson. Proposed: the contaminated-criterion simulation above, run in webR, with the AUC against the independent criterion and against the contaminated one (see Open questions).

**Problems**
1. Derivation: a screener with sensitivity 0.9 and specificity 0.9 in a population with 5% prevalence. What fraction of positives are true positives? (Meehl & Rosen, 1955, doi:10.1037/h0048070.) What does this add to the decision inference?
2. Real data with a twist: redo the Silk cross-tab with a threshold of 5 inattentive symptoms. What changes, and which inference is that evidence about?
3. Judgment: write the Cronbach–Meehl sentence and a four-step interpretation/use argument for the SAT as an admissions test, then as a tool for ranking schools (slide 9). Which inference is weakest in each?
4. Judgment: the CAASPP lists four purposes (slide 21). For purpose 1 ("facilitate conversations between parents and teachers"), design the study that would back it. Why don't such studies appear in technical reports?
5. Design: a state requires dyslexia screening in K–2 and approves four screeners (slides 16–17; California Department of Education, news release 24-53, 17 Dec 2024). If you were asked for a validity study, what evidence would you gather first, and why?
6. Challenge (open): Campbell's law says a measure used for decisions corrupts what it measures. Can a validity argument ever be complete for a high-stakes use, or only for a moment in time?

## Go deeper

- None. (The argument structure is conceptual; the Meehl–Rosen base-rate calculation is a problem.)

## Open questions

- **Prerequisites.** Core idea 4 recalls alpha, but `ctt-reliability` isn't a prerequisite of `validity-argument` (only `constructs` is). In the first-course path it comes before, so a Recall works for path readers. Add `ctt-reliability` as a prereq, or keep idea 4 self-contained?
- **Simulate in a conceptual lesson.** The contaminated-criterion simulation is proposed. Keep it, or record an agreed exception (PROTOCOL §10) for this lesson's Simulate section?
- **The CAASPP purposes (slide 21).** The slide is a screenshot. The same wording is in the CDE parent guide to the score report (found only as a district copy so far). OK to quote the four purposes with that citation?
- **Tone of the finding.** The Silk example turns on the ADHD indicator being the DSM rule applied to the same items. I've framed it as a property of the study design (built for a network analysis). Happy with that, and with Ben's disclosure on slide 16 (worked with two of the four screener groups) carrying over into problem 5?
