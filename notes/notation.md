# Notation and terminology

Ben agreed these on 2026-09-24 (digest A3). Every lesson uses them, whichever session
drafts it. PROTOCOL.md §5 points here. If a lesson needs something not listed, add it
here first, in the same PR.

## Symbols

| Quantity | Symbol | Notes |
|---|---|---|
| Respondent ability / latent trait | $\theta$ (person $j$: $\theta_j$) | "ability" for cognitive tests, "trait" or "level" otherwise |
| Item difficulty (location) | $b$ (item $i$: $b_i$) | |
| Item slope | $a$ | "discrimination" in prose, "slope" in formulas and code |
| Lower asymptote (guessing) | $c$ | `mirt` calls it `g` |
| Upper asymptote (slipping) | $u$ | `mirt` calls it `u`; not $d$, to avoid `mirt`'s intercept |
| Response | $x_{ij}$ | |
| Sum score | $r$ (or $X$ in CTT lessons) | CTT keeps $X = T + E$ |
| Regression coefficients | $\beta_0, \beta_1, \dots$ | never $b$, which is item difficulty (Ben, 09-24). Includes the easiness $\beta_i = -b_i$ of explanatory models (`explanatory-irt`, `trials`), a coefficient on item indicators (Ben, 09-26) |
| Factor loading | $\lambda$ | factor $\eta$ in CFA/SEM; $f$ in EFA |
| Item time intensity | $\kappa_i$ | log-time scale; van der Linden writes $\beta_i$, and `response-time` says so once (Ben, 09-26) |
| Respondent speed | $\tau_j$ | `response-time`; $\rho$ is the correlation of speed and ability across respondents, $\rho_I$ of time intensity and difficulty across items |
| Information | $I(\theta)$ | test information is the sum of item information |
| Standard error | $SE(\hat\theta) = 1/\sqrt{I(\theta)}$ | "conditional SEM" (CSEM) in prose |

## Model form

- Formulas use the slope–difficulty form on the logistic metric: $\Pr(x_{ij}=1) =
  c_i + (u_i - c_i)\,\frac{\exp(a_i(\theta_j - b_i))}{1+\exp(a_i(\theta_j - b_i))}$.
  The 1PL/Rasch has $a = 1$, $c = 0$, $u = 1$.
- No $D$ in formulas. $D \approx 1.7$ appears only in the Camilli aside (`rasch`) and the
  factor-analysis ↔ IRT conversion (`fa-confirmatory`).
- Multidimensional (compensatory) items, as in `dimensionality`: $\Pr(x_{ij}=1) = \text{logistic}\big(\sum_k a_{ik}\theta_{jk} - A_i b_i\big)$ with $A_i = \sqrt{\sum_k a_{ik}^2}$ (the item's multidimensional discrimination) and $b_i$ its multidimensional difficulty; $\theta_{jk}$ is respondent $j$'s ability on dimension $k$. In vector form $\mathbf{a}_i^\top\boldsymbol\theta_j + d_i$ appears only where the code or a derivation needs it (09-25, from `dimensionality`).
- `mirt`'s intercept form $a\theta + d$ appears only in code. Wherever code converts,
  state $b = -d/a$ (for the Rasch model, $b = -d$).

## Words

- **Respondent**, not examinee, test-taker or subject (many IRW tables aren't tests).
  "Person" is fine in formulas and model descriptions.
- **Item** throughout; "probe" only in `measurement`, where it is introduced.
- **Item-rest correlation** (the item against the sum of the *other* items). Say
  "item-total" only when the point is the inflation from including the item.
- **Keying:** responses are coded so that higher = more of the construct. Each lesson
  states its keying once, where the data are introduced.
- **Logit** for the $\theta$ scale's unit when a unit is needed.

## Lesson-local symbols

Symbols used in one lesson (or a pair), recorded so that later lessons don't reuse them
with another meaning. Where a symbol already means something else in the table above, the
clash is noted; each lesson defines its symbols where they first appear.

| Lesson | Symbol | Meaning | Clash |
|---|---|---|---|
| `nominal` | $a_{ik}$, $\gamma_{ik}$ | slope and intercept of option $k$ (Bock's nominal model) | |
| `nominal` | $\delta_k$ | share of "don't know" respondents choosing option $k$ (Thissen–Steinberg multiple-choice model) | $\delta_k$ in `cdm` |
| `cdm` | $\alpha_{jk}$, $q_{ik}$ | respondent $j$'s mastery of attribute $k$; Q-matrix entry | $\alpha$ in `rt-process-models`, `guessing-priors` |
| `cdm` | $\eta_{ij}$ | DINA's ideal response (1 if every required attribute is mastered) | $\eta$ is the CFA factor |
| `cdm` | $s_i$, $g_i$ | slip and guess | $g_i$ is $c$ elsewhere; DINA's own names kept |
| `cdm` | $\pi_c$, $p_{ic}$ | class proportions; class-conditional item probabilities | |
| `cdm` | $\lambda$, $\delta_k$ | higher-order model: slope and attribute threshold on $\theta$ | $\lambda$ is the loading; $\delta_k$ in `nominal` |
| `explanatory-irt` | $\eta_k$ | LLTM weight of item feature $k$ | $\eta$ is the CFA factor |
| `response-time` | $\sigma$ | residual SD of log time | |
| `rt-process-models` | $\alpha$, $v$, $z$, $T_{er}$, $s$ | boundary separation, drift rate, starting point, non-decision time, within-trial noise | $\alpha$ in `cdm`, `guessing-priors` |
| `rt-process-models` | $\eta$ | across-trial SD of the drift | $\eta$ is the CFA factor |
| `trials` | $i(t)$ | the item that trial $t$ belongs to (a function from trials to items) | |
| `trials` | $\delta$, $\gamma_j$, $c_t$ | average experimental effect, respondent $j$'s departure from it, indicator of an incongruent trial | |
| `trials` | $\tau^2_\theta$, $\tau^2_\gamma$ | between-respondent variances in the RT model | $\tau_j$ is speed in `response-time` |
| `guessing-priors` | $\alpha$, $\gamma_i$ | 1PL-AG: how guessing rises with ability; item guessing intercept | $\alpha$ also names beta-prior parameters there |
| `guessing-priors` | $\pi$ | share of engaged respondents in the two-class mixture | |

**Open (for Ben):** $\eta$ carries four meanings (CFA factor, DINA ideal response, LLTM
weight, drift SD) and $\alpha$ three. Each is defined where used and none meet in one
lesson, so the default is to leave them lesson-local. The one pair that could meet is
`trials` ($\tau^2$ as variances) and `response-time` ($\tau_j$ as speed), which a reader
may take in sequence.

