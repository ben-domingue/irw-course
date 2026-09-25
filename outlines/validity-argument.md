<!-- Outlined 2026-09-24 from EDUC 252 slides c3 (slides 2–22, validity) and c4 (slides 2–3, 16–17). Tidied 09-24 (#62): Ben's answers E1, F1–F3 applied. -->

# Validity as an argument (`validity-argument`)

Module: validity · Prereqs: constructs, ctt-reliability · Core · Status: drafted (#33)

## Core ideas

1. **We validate interpretations and uses, not tests.** Validity is "the degree to which evidence and theory support the interpretations of test scores for proposed uses of tests". The SAT example (slide 9, marked hypothetical): the same scores used for admission and for ranking schools need different evidence. Verdict (slide 8, Ben's words): "Thou shalt not speak of validated measures." *(major)* Sources: AERA, APA & NCME (2014), *Standards*, ch. 1 (open access at https://www.testingstandards.net/open-access-files.html; book, no DOI); Cook & Beckman (2006), doi:10.1016/j.amjmed.2005.10.036; Messick (1995), doi:10.1037/0003-066X.50.9.741.
2. **From types of validity to one construct validity.** Criterion, content and construct validity as separate "types"; the move, via Cronbach & Meehl, to construct validity as the whole, with internal and external components and a demand for evidence that could falsify the inference (slides 5–7). *(major)* Sources: Cronbach & Meehl (1955), doi:10.1037/h0040957; Messick (1989), "Validity", in R. L. Linn (Ed.), *Educational measurement* (3rd ed.), American Council on Education/Macmillan (book verified on Open Library; chapter pages 13–103 *unverified*; the ETS report version is Messick, 1987, doi:10.1002/j.2330-8516.1987.tb00244.x).
3. **The argument.** Kane's interpretation/use argument: a chain of inferences (scoring → generalization → extrapolation → decision), each with a warrant and backing, laid out before data collection so you know which evidence matters most (slide 18). The Standards' five sources of evidence (content, response processes, internal structure, relations to other variables, consequences) mapped onto the inferences with Cook & Beckman's Table 2 (slides 12–17). The idea closes on the three questions of slide 20: what is the proposed use; what evidence supports it; is it enough? *(major)* Sources: Kane (1992), doi:10.1037/0033-2909.112.3.527; Kane (2013), doi:10.1111/jedm.12000; Cook & Beckman (2006), Table 2.
4. **Reliability is necessary, not sufficient.** Three blood-pressure readings of 185/100, 80/40 and 140/70 in three minutes: you wouldn't average them (slide 11, from Cook & Beckman, p. 166.e8). Alpha = 0.81 in a sentence (slide 2): what does it license, and what doesn't it? A Recall of alpha from `ctt-reliability`, now a prerequisite (E1).
5. **A measure is never finished: uses evolve.** Campbell's law (slide 19). The validity paradox: the modern conception is demanding for good reasons, yet a complete argument can feel operationally impossible, and practice rarely supplies the studies a stated purpose implies (the CAASPP's four purposes, slide 21). This is the opening for Borsboom's narrower view (`validity-causal`). Sources: Campbell (1979), doi:10.1016/0149-7189(79)90048-X; Markus & Borsboom (2013), doi:10.4324/9780203501207. CAASPP purposes: quoted from the CDE *Parent Guide to Understanding* the score report (district copy at https://www.cusdk12.org/documents/Forms--Information/CAASPP-ParentGuide-Grade-11.pdf); finding the CDE original is Claude's to-do (digest D) before drafting.

For *Going further*: Hubley & Zumbo (2011), doi:10.1007/s11205-011-9843-4 (consequences). Crossref-checked 09-24 unless marked.

## Picks up

- Constructs as postulated attributes; the Cronbach–Meehl sentence (from `constructs`).
- Blueprints and domain sampling as the start of content evidence (from `constructs`).
- A measure should be insensitive to nonfocal attributes (from `measurement`; also → `dif`).
- Alpha and what reliability is (from `ctt-reliability`).

## Promises / leaves open

- Each source of evidence in practice: convergent/discriminant, criterion, classification, content → `validity-evidence`.
- The validity paradox; validity as causation → `validity-causal`.
- Nonfocal attributes and fairness at the item level → `dif`.
- The same scores, two uses: an outcome for evaluating an intervention vs. a measure of the construct → `invariance-experience`.
- Consequences as evidence (Campbell's law; score reports that are never studied) → unpaid.
- Decision inferences and cut scores: a pointer to `score-meaning`, which isn't a descendant (E2; no hook).

## Tables

| Table | Job | What it should turn up | Also used in |
|---|---|---|---|
| `silk_2019_inattentive` | main example | Parent-reported DSM-IV inattentive symptoms from the DISC-IV (Silk et al., 2019, doi:10.1371/journal.pone.0211053), 9 items, 355 children aged 6.4–8.7, with an ADHD indicator. Alpha 0.92. The count separates the groups almost perfectly (AUC 0.99): no child without ADHD has 6 or more symptoms. | — |
| `silk_2019_hyperactive` | contrast (the other half of the rule) | The 9 hyperactive/impulsive symptoms for the same children (alpha 0.88; AUC 0.93 alone). Together the tables show that the ADHD indicator is exactly "6 or more symptoms in either domain" (209 of 209 without, 146 of 146 with): the DSM-IV rule applied to these items. | — |

The finding: an AUC of 0.99 looks like strong extrapolation evidence, but here it is true by construction. The indicator is the decision rule applied to the items, so it backs the *scoring* and *decision* inferences and says nothing about *extrapolation* (that the count tracks impairment in the world). Framing (F2, settled): the study was designed for a network analysis of symptoms, not to validate a screener; the lesson says so as a fact about the design, not a flaw.

Diagnostic source: Shaffer et al. (2000), doi:10.1097/00004583-200001000-00014. Item text: the symptom labels in the item ids (`avoid`, `closeatt`, `fidget`, …), not DSM text. Table citations come from IRW biblio.

Sanity table: none. There is no model fit; the check is the cross-tabulation itself.

## Widget / simulation / problem ideas

**Widgets**
- Build an argument: pick a use (admission, school ranking, screening, research); the widget lays out Kane's four inferences and asks which evidence source backs each (ideas 1, 3).
- Blood pressure: three readings with adjustable error; how many before you'd trust the average? (idea 4)
- The contaminated criterion: a simulated screener and a "diagnosis" that mixes an independent criterion with the screener's own items; slide the mixing weight and watch the AUC rise while agreement with the independent criterion stays put (ideas 3, 4).

**Predict-then-check:** how well will the inattentive count separate children with and without ADHD? Answered by the cross-tabulation (AUC 0.99; none of the 209 without ADHD has 6+ symptoms), then by the "either domain" table, which shows why.

**Simulate** (F1, settled: kept, no §10 exception): the contaminated-criterion simulation in webR, with the AUC against the independent criterion and against the contaminated one. It is the real-data finding in miniature.

**Problems**
1. Derivation: a screener with sensitivity 0.9 and specificity 0.9 at 5% prevalence. What fraction of positives are true positives? (Meehl & Rosen, 1955, doi:10.1037/h0048070.)
2. Real data with a twist: redo the Silk cross-tab with a threshold of 5 inattentive symptoms. What changes, and which inference is that evidence about?
3. Judgment: write a four-step interpretation/use argument for the SAT as an admissions test, then as a tool for ranking schools (slide 9). Which inference is weakest in each?
4. Judgment: for the CAASPP's purpose 1 ("facilitate conversations between parents and teachers"), design the study that would back it. Why don't such studies appear in technical reports?
5. Design: a state requires dyslexia screening in K–2 and approves four screeners (slides 16–17; California Department of Education, news release 24-53, 17 Dec 2024). What evidence would you gather first? The problem carries Ben's slide-16 disclosure in one clause (he worked with two of the four screener groups; F3, settled).
6. Challenge (open): Campbell's law says a measure used for decisions corrupts what it measures. Can a validity argument ever be complete for a high-stakes use, or only for a moment in time?

## Go deeper

- None. (The argument is conceptual; the Meehl–Rosen base-rate calculation is problem 1.)

## Open questions

- None. (Settled 09-24: E1 prerequisite, F1 Simulate kept, F2 framing, F3 disclosure. The CDE original of the CAASPP purposes is Claude's to-do, digest D.)

## Drafting notes (#33, 09-25)

- The dog-ADHD alpha on slide 2 is Csibra, Bunford & Gácsi (2022), doi:10.3390/ani12070807 (sec. 3.2.1); it opens the lesson, paraphrased. The one quotation is the *Standards*' definition (p. 11), checked against the open-access PDF.
- Slide 8's "Thou shalt not speak of validated measures" became the lesson's first-person verdict (on how to describe a measure), after the two assumptions (validity of the test vs of an interpretation).
- Kane's fourth inference is called "decision" in the lesson, with a note that Cook, Brydges, Ginsburg & Hatala (2015), doi:10.1111/medu.12678, call it implications. The source-to-link mapping is presented as a guide, not attributed.
- Messick (1989) is not cited; Messick (1995) is, checked against the abstract of its ETS report version (doi:10.1002/j.2333-8504.1994.tb01618.x).
- Cook & Beckman's blood-pressure example is cited without a page (the page could not be checked; the text was checked from the slide's image of the paper).
- Digest D: the CDE original of the CAASPP parent guide was found (grade 11, 2015, p. 5) via the Wayback Machine: https://web.archive.org/web/20150905090008/http://www.cde.ca.gov/ta/tg/ca/documents/sbparentgde11.pdf. The CDE site itself is behind a captcha.
- Silk et al. (2019, Methods): three controls with six or more symptoms but insufficient impairment were excluded from the subsample, and the sample is screen-high vs screen-low on parent and teacher ratings (extreme groups). Both are stated in the lesson as design facts.
- The AUC is defined in one sentence; ROC and classification accuracy stay in `validity-evidence`.
