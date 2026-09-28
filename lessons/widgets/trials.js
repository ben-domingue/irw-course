// Widget helpers for the lesson "Trials as items". Pure functions only; colours and
// the logistic helpers come from irt.js. Import with:
//   import {RR98, psychFit, varianceParts, shotWorld} from "./widgets/trials.js"
import {logistic, logisticFit} from "./irt.js";

// rr98_accuracy (IRW, item_response_warehouse v60.0), pooled over the three
// observers' 30 sessions: for each brightness level 0..32, the number of trials
// (n) and of correct responses (k). Printed by the lesson's code (chunk
// rr98-levels) from the same table.
export const RR98 = {
  n: [110, 84, 103, 139, 196, 184, 282, 328, 396, 470, 496, 566, 536, 639, 639, 690, 688,
      659, 623, 596, 557, 510, 546, 378, 413, 355, 258, 247, 162, 128, 94, 96, 37],
  k: [104, 78, 100, 134, 189, 168, 242, 300, 340, 388, 370, 402, 356, 391, 323, 345, 355,
      340, 358, 393, 392, 360, 451, 316, 368, 315, 217, 228, 145, 122, 92, 94, 35]
};

const binLL = (k, n, p) => k * Math.log(p) + (n - k) * Math.log(1 - p);

// Fit one of three accounts of the 33 levels to the grouped counts by maximum
// likelihood (no observer or session effects):
//   "line": logit P = b0 + b1 * |level - mid|             (2 parameters)
//   "dist": one P per distinct value of |level - mid|    (one per distance)
//   "level": one P per level                              (33)
// Returns the fitted P for each level, the log likelihood, the parameter count
// and the AIC.
export function psychFit(model, mid = 16, data = RR98) {
  const levels = data.n.map((_, i) => i);
  let p, npar;
  if (model === "level") {
    p = data.k.map((k, i) => k / data.n[i]);
    npar = levels.length;
  } else if (model === "dist") {
    const key = (l) => Math.abs(l - mid).toFixed(2);
    const agg = new Map();
    levels.forEach(l => {
      const a = agg.get(key(l)) || {n: 0, k: 0};
      a.n += data.n[l]; a.k += data.k[l]; agg.set(key(l), a);
    });
    p = levels.map(l => { const a = agg.get(key(l)); return a.k / a.n; });
    npar = agg.size;
  } else {
    const x = levels.map(l => Math.abs(l - mid));
    const y = data.k.map((k, i) => k / data.n[i]);
    const {b0, b1} = logisticFit(x, y, data.n);
    p = x.map(v => logistic(b0 + b1 * v));
    npar = 2;
  }
  const ll = levels.reduce((s, l) => s + binLL(data.k[l], data.n[l], p[l]), 0);
  return {p, ll, npar, aic: -2 * ll + 2 * npar};
}

// Where the variance lives in a two-condition task. Each respondent has a true
// mean RT (SD tauMean) and a true effect (SD tauEffect, mean delta); every trial
// adds noise with SD sigma; there are L trials per condition and N respondents.
// Returns the true and noise variance of each respondent's observed effect and
// mean RT, the reliability of each, and the t statistic for the group effect.
export function varianceParts({delta, tauEffect, tauMean = 0.10, sigma = 0.17, L, N = 150}) {
  const effTrue = tauEffect ** 2, effNoise = 2 * sigma ** 2 / L;
  const meanTrue = tauMean ** 2, meanNoise = sigma ** 2 / (2 * L);
  return {
    effTrue, effNoise, meanTrue, meanNoise,
    relEffect: effTrue / (effTrue + effNoise),
    relMean: meanTrue / (meanTrue + meanNoise),
    t: delta / Math.sqrt((effTrue + effNoise) / N)
  };
}

// Logistic regression by Newton's method for grouped data: rows of a small design
// matrix X, proportions y and group sizes n. Returns the coefficients and SEs.
function logitNewton(X, y, n) {
  const p = X[0].length;
  let beta = new Array(p).fill(0);
  let H = null;
  for (let it = 0; it < 50; it++) {
    const g = new Array(p).fill(0);
    H = Array.from({length: p}, () => new Array(p).fill(0));
    for (let r = 0; r < X.length; r++) {
      const eta = X[r].reduce((s, v, j) => s + v * beta[j], 0), pr = logistic(eta), w = n[r] * pr * (1 - pr);
      for (let a = 0; a < p; a++) {
        g[a] += n[r] * (y[r] - pr) * X[r][a];
        for (let b = 0; b < p; b++) H[a][b] += w * X[r][a] * X[r][b];
      }
    }
    const step = solve(H, g);
    beta = beta.map((v, j) => v + step[j]);
    if (step.reduce((s, v) => s + Math.abs(v), 0) < 1e-10) break;
  }
  const Hinv = invert(H);
  return {beta, se: beta.map((_, j) => Math.sqrt(Hinv[j][j]))};
}

function solve(A, b) {
  const n = b.length, M = A.map((row, i) => [...row, b[i]]);
  for (let c = 0; c < n; c++) {
    let piv = c;
    for (let r = c + 1; r < n; r++) if (Math.abs(M[r][c]) > Math.abs(M[piv][c])) piv = r;
    [M[c], M[piv]] = [M[piv], M[c]];
    for (let r = 0; r < n; r++) if (r !== c) {
      const f = M[r][c] / M[c][c];
      for (let k = c; k <= n; k++) M[r][k] -= f * M[c][k];
    }
  }
  return M.map((row, i) => row[n] / row[i]);
}

function invert(A) {
  const n = A.length, inv = Array.from({length: n}, () => new Array(n).fill(0));
  for (let j = 0; j < n; j++) solve(A, A.map((_, i) => (i === j ? 1 : 0))).forEach((v, i) => { inv[i][j] = v; });
  return inv;
}

// Two shooters take `shots` three-point attempts each. A shot is open or
// contested; a contested shot is harder by `hardCost` logits. Shooter A's skill
// is 0 and B's is `skillGap` logits; A takes a share `hardA` of contested shots and
// B a share `hardB`. For shooter A an open three goes in with probability `pOpen`.
// No simulation: each shooter makes the expected number of each kind of shot, so
// the picture shows the bias and not sampling noise; the SEs say how large the
// noise would be with this many shots. Returns each shooter's percentage and the
// skill gap (B minus A, logits) estimated with and without shot type in the model.
export function shotWorld({hardA = 0.3, hardB = 0.7, skillGap = 0, shots = 2000,
                           hardCost = 0.8, pOpen = 0.40}) {
  const b0 = Math.log(pOpen / (1 - pOpen));
  const cells = [];
  for (const [isB, skill, share] of [[0, 0, hardA], [1, skillGap, hardB]])
    for (const isHard of [0, 1])
      cells.push({isB, isHard, n: shots * (isHard ? share : 1 - share),
                  p: logistic(b0 + skill - hardCost * isHard)});
  const use = cells.filter(c => c.n > 0);
  const adj = logitNewton(use.map(c => [1, c.isB, c.isHard]), use.map(c => c.p), use.map(c => c.n));
  // Without shot type, each shooter is one group with their overall percentage.
  const pct = [0, 1].map(b => {
    const cs = cells.filter(c => c.isB === b);
    return cs.reduce((s, c) => s + c.n * c.p, 0) / shots;
  });
  const raw = logitNewton([[1, 0], [1, 1]], pct, [shots, shots]);
  return {pctA: pct[0], pctB: pct[1], rawGap: raw.beta[1], rawSE: raw.se[1],
          adjGap: adj.beta[1], adjSE: adj.se[1]};
}
