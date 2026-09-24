# Prose rules

**DRAFT 2026-09-24.** Rules 1–3 are Ben's. Rules 4–6 are proposed by Claude and
marked **[proposed]** until Ben accepts, edits or drops them. More may be added.

`PROTOCOL.md` governs a lesson's structure and §6 there governs voice. This file
governs what the prose may say and borrow. Each rule has a statement, what it allows,
and how to screen a page for it. The screens find candidates; a person (or a
reviewing session) decides each hit.

---

## 1. Quote very sparingly

**Rule.** The default is no quotations. Say it in our own words and cite the source.
A lesson may carry **at most one** quotation, of **25 words or fewer**, and only when
the exact wording is the point: a definition whose wording is itself at issue, or a
claim the lesson goes on to test.

- No epigraphs, no quotations as decoration, no "as X famously put it".
- No block quotations.
- Don't quote a source to lend weight to a verdict. If the verdict needs support, show
  it with output or cite the argument.

**Not counted as quotations** (but rule 2 still applies where marked):

- Item wording from an instrument the lesson analyses. This is data, and it is the
  usual reason to put words in quotation marks. Quote only the items the discussion
  needs (two or three at most), and cite the instrument (rule 2).
- Titles of works in a reference list.
- Scare quotes around a term, and coined terms such as the "elbow" of a scree plot.
- Invented speech in problems and quizzes ("A colleague says...").

**Screen.** Block quotes (lines starting `>` outside code); any passage of more than
about eight words inside quotation marks in the prose; the phrases *put it*, *wrote*,
*in the words of*, *famously*.

## 2. Cite every quotation where it appears

**Rule.** Every quotation, including item wording, is cited **in the sentence where it
appears**: author, year and, for a published text, page or section, with a link (DOI
where there is one). A citation only in *Going further* or *For instructors* doesn't
count.

- Item wording cites the instrument's source (e.g. Christie & Geis, 1970, for the
  Mach IV) as well as the IRW table.
- Quotations are checked word for word against the source, never written from memory.
  A quotation that can't be checked is paraphrased instead.
- Item text carries no licence to reproduce an instrument (PROTOCOL §7), so quote only
  what the discussion needs.

**Screen.** For every hit from rule 1's screen, look for a citation in the same
sentence or the one before it.

## 3. Don't disparage techniques

**Rule.** Describe what a technique assumes, where it does its job, and where it gives a
different answer from an alternative, and **show** the difference (a widget, a
simulation, IRW output). Don't pass judgement on the technique itself. This extends the
existing rules on data ("Gentle about the data") and on other researchers' models
(PROTOCOL §2) to methods: sum scores, alpha, the Kaiser rule, varimax, the Rasch model,
CTT as a whole.

- **Allowed:** "The Kaiser rule keeps more factors than the simulation built in", shown
  with the widget. "I report alpha, but I wouldn't make a decision on it alone" (a
  first-person verdict on the practitioner's choice, PROTOCOL §6 rule A). Stating a
  limitation plainly, with its evidence.
- **Not allowed:** evaluative adjectives about a method (*flawed, naive, crude,
  outdated, obsolete, useless, misguided, strange, dangerous, bad*); "should never";
  framing a technique as something competent people have moved past; ranking
  techniques in general rather than for a stated purpose.
- A cited source may be critical. Describe what it argues, not how sharply it argues
  (not "a sharp critique" but "argues that alpha is rarely the right coefficient and
  proposes the glb").
- Every technique the lesson discusses gets at least one sentence on when it is a
  reasonable choice.

**Screen.** The adjectives above, plus *wrong, mistake, poor, problematic, misleading,
misuse, abuse, critique, sharp, fails*, then read each hit. A hit about a *specific
result* ("parallel analysis gets the number wrong in small samples") is usually fine;
a hit about a *method in general* is not.

## 4. Write fresh prose [proposed]

**Rule.** Don't lift or closely paraphrase sentences from the EDUC 252 slides, papers,
IRW vignettes or package documentation. Take the idea, cite it (PROTOCOL §2), and write
the sentence new. A borrowed example (a figure, a worked problem, a dataset) is fine
when cited; its wording is not.

**Why.** Lessons are drafted by Claude from sources. Close paraphrase is the usual way
quotation problems enter unannounced, and it is harder to spot than a quote.

**Screen.** For each lesson, compare its prose against its listed sources (the slide
deck named in *For instructors*, the vignettes it links): any run of about eight or
more words shared with a source is a hit.

## 5. Don't characterise what "people" think [proposed]

**Rule.** No unsourced claims about what researchers, practitioners or students
believe or do: *a common misreading*, *people often assume*, *many researchers*, *most
textbooks*, *partisans of*. Either cite evidence that the belief is common, or state
the point directly ("alpha is not a test of unidimensionality").

**Why.** These claims can't be checked, and they set the lesson against an unnamed
group, which sits badly with rule 3 and with PROTOCOL §2.

**Screen.** *common, commonly, often, many (researchers|people|users|analysts), most
(people|researchers|textbooks), people (think|assume|believe), partisans, camp*.

## 6. Present disagreements as questions about assumptions [proposed]

**Rule.** Where the field disagrees (Rasch vs. 2PL, alpha vs. omega, how many factors),
set out what each side assumes and let the data answer the question the lesson can
answer. Don't name sides by who holds them, and don't narrate the dispute's history
for its own sake. The lesson's own verdict (PROTOCOL §6 rule A) comes after the
assumptions are on the table.

**Screen.** Read every first-person verdict and check that the assumptions it rests
on are stated before it.

---

## First screen of the drafted lessons (2026-09-24)

A trial run of the screens over `likelihood`, `ctt-reliability`, `rasch` and
`fa-exploratory`, to test the rules rather than to finish the audit. Each hit needs
Ben's call or a fix in that lesson's PR.

| Rule | Where | Hit |
|---|---|---|
| 2 | `ctt-reliability.qmd:274, 286` | Two Mach IV items quoted; Christie & Geis (1970) is cited only in *Going further*. Needs an inline citation. |
| 3 | `ctt-reliability.qmd:321` | Sijtsma (2009) described as "A sharp critique". Describe what it argues. |
| 3 | `rasch.qmd:24` | Sum scores' equal weighting called "a strange assumption". Say what the assumption is and what it misses. |
| 5 | `ctt-reliability.qmd:164` | "a common misreading" (quiz feedback), unsourced. |
| 3 | `fa-exploratory.qmd:94, 134, 142` | "the Kaiser rule over-extracts": the widget shows it, so this is the allowed kind. Check that the lesson says when the rule is still a reasonable first look. |

No block quotations or attributed quotations turned up in the four lessons.

---

## Checklist items (for PROTOCOL §9 once adopted)

- [ ] At most one quotation (items under analysis, titles and invented speech
      excepted), 25 words or fewer, and only where the wording is the point.
- [ ] Every quotation and every piece of quoted item wording is cited inline,
      and checked word for word against its source.
- [ ] No evaluative judgement of a technique; each technique discussed gets a sentence
      on when it is a reasonable choice; limitations are shown, not asserted.
- [ ] [proposed] No run of about eight or more words shared with a source.
- [ ] [proposed] No unsourced claims about what people commonly think or do.
- [ ] [proposed] Disagreements set out as assumptions before any verdict.
