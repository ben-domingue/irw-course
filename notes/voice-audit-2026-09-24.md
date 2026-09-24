# Voice audit of the three pilots (issue #3)

First pass by Claude against the domingue-voice skill. Each flag gives the line, the
problem, and a suggested rewrite. Ben marks each one ✓ (a real problem), ✗ (sounds like
me), or edits the rewrite. The confirmed flags become rules in PROTOCOL.md.

Overall: the pilots are close. The prose is plain and verdict-first in most places, and
several lines already sound like Ben ("That last assumption is doing the real work";
"more than 90% of what it does is its own business"; "It is a fine question, but it is
about something else"). The drift falls into six patterns.

## Pattern A: no first-person judgment where Ben has one

Only the factor-analysis lesson says "I" ("the one I would reach for first", "My default
is oblique"). The Rasch and CTT lessons take no position, even on the two most contested
questions they raise.

- **rasch.qmd:273.** "This is why partisans of the Rasch model feel so strongly about
  it..." This describes other people's views and never gives Ben's. Given the IMV work
  on 1PL vs. 2PL, Ben has a view.
  *Suggest:* keep the fair setup, then add the landing. "...is what classical measurement
  in the physical sciences looks like. My view is that equal slopes are rarely plausible
  for test data that was not built to the Rasch model, and the IRW evidence bears this
  out: [vignette]. That is a statement about the data, not a criticism of the model."
- **ctt-reliability.qmd:95 and 297–301.** No verdict on alpha, though the lesson cites
  Sijtsma's "very limited usefulness". The student can't tell whether Ben would report
  alpha.
  *Suggest:* open "Limitations worth remembering" with the verdict. "I still report alpha,
  mostly because readers expect it, but I would not make a decision on it alone. There
  are three problems. First... Second... Finally..."

**Candidate rule:** every lesson gives at least one first-person verdict on the choice a
practitioner actually faces (which model, which coefficient, which rotation). Put it
first, then the rationale.

## Pattern B: enthusiasm words instead of graded adverbs

- rasch.qmd:24. "That parsimony buys some remarkable properties". *Suggest:* "some
  unusual properties" or just "two properties the other models lack".
- ctt-reliability.qmd:49. "Something special has happened:". *Suggest:* "Note what has
  happened:".
- ctt-reliability.qmd:88 (quiz). "That's the magic of the parallel-forms trick".
  *Suggest:* "That is the point of the parallel-forms trick".
- ctt-reliability.qmd:95. "The beauty of Cronbach's alpha is that...". *Suggest:* "The
  appeal of alpha is that...". This matters more given the verdict in Pattern A.
- ctt-reliability.qmd:299. "For a vivid example". *Suggest:* "For a clear example".
  ("robust experimental effects" on the same line is the term of art, so leave it.)
- fa-exploratory.qmd:47. "the model makes a striking prediction". *Suggest:* "a strong
  prediction", or just "a testable prediction".
- fa-exploratory.qmd:278. "it is a tribute to the care that went into building the
  BFI-2". *Suggest:* see Pattern E.

**Candidate rule:** no *remarkable, beautiful, magic, special, striking, vivid*. Size
claims with *fairly, quite, rather, somewhat, not especially*.

## Pattern C: a stock narrator line instead of a question pivot

- rasch.qmd:92. "Here is a fact that surprises people."
- fa-exploratory.qmd:150. "Here is a fact that bothers people when they first meet it."
  The same move twice across three lessons, so it is becoming a template tic.
  *Suggest:* rasch: "Where is zero on this scale? Nowhere in particular." fa: "Which set
  of loadings is the right one? The data cannot say."
- rasch.qmd:76 "A few things are worth noticing." and fa-exploratory.qmd:74 "Two things
  to notice." These are fine once, but they should be "Note a few things" or dropped.

**Candidate rule:** a section turns on a short question that the text then answers. No
"Here is a fact that...".

## Pattern D: withheld or coy verdicts

- **rasch.qmd:76.** "The answer, roughly 1.7, has a long history." This is a tease with no
  payoff. *Suggest:* say it. "The answer is roughly 1.7, the scaling constant D that
  older IRT papers carry around so that logistic and normal-ogive parameters can be
  compared."
- **rasch.qmd:373.** "Compare this plot with the chess one." The lesson never says what
  the comparison shows. *Suggest:* state the result first. "The Rasch model describes
  wirs [better/worse] than chess: ... Whether it is a reasonable description is something
  to check item by item..."
- **ctt-reliability.qmd:301.** "We will see ... why that is incomplete." A weak ending for
  the lesson's main limitation. *Suggest:* close with a one-line aphorism. For example:
  "CTT gives everyone the same error bar, and nobody has the same error."

**Candidate rule:** never ask the reader to compare without saying what they should see.
Each lesson may end its core argument with one aphorism.

## Pattern E: a claim with no stated baseline

- **fa-exploratory.qmd:278.** "about as clean a result as exploratory factor analysis
  produces on real data". Against what comparison set? The IRW dimensionality vignette
  could supply one. *Suggest:* "Every one of the 60 items loads most strongly on its own
  domain. Against the IRW's [N] multi-scale tables, that is unusual: [x]% ..." Or drop
  the claim.
- rasch.qmd:331. "a wide spread of difficulty". Wide compared with what? The diffsim
  vignette (cited at line 395) gives the typical spread across IRW tables.

**Candidate rule:** say what an evaluative size word (wide, clean, high, typical) is being
compared against. The IRW usually supplies the baseline, and pointing to it is part of
the course's purpose.

## Pattern F: words from the "do not" list, and hedges that soften a verdict

- **fa-exploratory.qmd:269.** "but it is worth being honest that the choice is ours". This
  uses *honest* and softens a verdict already given. *Suggest:* "The five-domain
  structure is the one the instrument is built to score, so that is what we fit. The
  choice is ours; the data inform it but do not make it."
- "worth ___" appears nine times across the three lessons (worth noticing, worth
  remembering, worth seeing, worth being honest...). Individually each is fine; together
  they are a crutch. *Suggest:* use "merits" once, "Note that" elsewhere, or cut.

**Candidate rule:** no *honest(ly), genuinely, truly*. At most one "worth [verb]ing" per
lesson.

## Things to keep (already in voice)

- Verdict-first openings in "What this is for" (CTT especially: "Every score contains
  error.").
- The fair-setup, blunt-landing move in ctt-reliability.qmd:133: "The gap is fairly small
  ... part of why alpha has survived. But it only ever goes one way."
- "merits comment" (ctt:261) and "merits emphasis" (rasch:301).
- Wry asides, at most one per lesson, and each lesson has about one: rasch "made with
  feeling" (392), ctt "It is a fine question, but it is about something else" (293), fa
  "its own business" (88).
- A concrete anchor in each lesson: chess, the Mach IV, the reading RCT, the BFI-2.

## Small fixes that are not about voice

- rasch.qmd:186. "This is easiest to see than to state." Should be "easier".
