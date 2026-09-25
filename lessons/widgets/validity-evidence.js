// Widget helpers for the lesson "Gathering validity evidence". Pure functions only;
// colours and the seeded rng come from irt.js. Import with:
//   import {mtmm, restrictSample, caseII, binormal} from "./widgets/validity-evidence.js"
import {rng, pnorm, cor} from "./irt.js";

// The multitrait-multimethod matrix implied by a simple model: three traits, two
// methods (self-report and a colleague's rating). Each score is
//   X = lambda_m * T_t + gamma_m * M_m + e,   variance 1,
// with reliability `rel` for every score, a share `s_m` of each score's reliable
// variance coming from its method, traits 1 and 2 correlating `phi12`, the other
// trait pairs `phi`, and methods uncorrelated with traits and with each other.
export function mtmm({rel = 0.8, phi = 0.2, phi12 = 0.2, s1 = 0.1, s2 = 0.1} = {}) {
  const lam = [Math.sqrt(rel * (1 - s1)), Math.sqrt(rel * (1 - s2))];
  const gam = [Math.sqrt(rel * s1), Math.sqrt(rel * s2)];
  const tcor = (i, j) => (i === j ? 1 : (i + j === 1 ? phi12 : phi)); // traits 0 and 1 are "1 and 2"
  const R = [];
  for (let a = 0; a < 6; a++) {
    const row = [];
    for (let b = 0; b < 6; b++) {
      const ma = Math.floor(a / 3), mb = Math.floor(b / 3), ta = a % 3, tb = b % 3;
      if (a === b) row.push(1);
      else row.push(lam[ma] * lam[mb] * tcor(ta, tb) + (ma === mb ? gam[ma] * gam[mb] : 0));
    }
    R.push(row);
  }
  // Campbell and Fiske's comparisons for each trait.
  const checks = [0, 1, 2].map(t => {
    const v = R[t][t + 3];
    const hthm = [0, 1, 2].filter(u => u !== t).flatMap(u => [R[t][u + 3], R[u][t + 3]]);
    const htmm = [0, 1, 2].filter(u => u !== t).flatMap(u => [R[t][u], R[t + 3][u + 3]]);
    return {trait: t + 1, validity: v, maxHTHM: Math.max(...hthm), maxHTMM: Math.max(...htmm),
            beatsHTHM: hthm.every(x => v > x), beatsHTMM: htmm.every(x => v > x)};
  });
  return {R, checks};
}

// Case II correction for direct selection on the predictor: r is the correlation in
// the selected group, u the ratio of the full group's predictor SD to the selected SD.
export const caseII = (r, u) => r * u / Math.sqrt(1 - r * r + r * r * u * u);

const sd = (v) => {
  const m = v.reduce((a, b) => a + b, 0) / v.length;
  return Math.sqrt(v.reduce((a, b) => a + (b - m) ** 2, 0) / (v.length - 1));
};

// A sample of applicants with predictor x and criterion y correlating rho; the top
// share `keep` on x is selected. With `ceiling`, the criterion is capped at 0.6 (in SD
// units), as a grade scale stops at its top grade.
export function restrictSample({seed = 12, n = 800, rho = 0.5, keep = 0.5, ceiling = false} = {}) {
  const r = rng(seed), pts = [];
  for (let i = 0; i < n; i++) {
    const x = r.norm();
    let y = rho * x + Math.sqrt(1 - rho * rho) * r.norm();
    if (ceiling) y = Math.min(y, 0.6);
    pts.push({x, y});
  }
  const xs = pts.map(p => p.x).sort((a, b) => a - b);
  const cutX = xs[Math.min(n - 1, Math.floor((1 - keep) * n))];
  pts.forEach(p => { p.sel = keep >= 1 ? true : p.x >= cutX; });
  const S = pts.filter(p => p.sel);
  const rAll = cor(pts.map(p => p.x), pts.map(p => p.y));
  const rSel = cor(S.map(p => p.x), S.map(p => p.y));
  const u = sd(pts.map(p => p.x)) / sd(S.map(p => p.x));
  const ys = pts.map(p => p.y).sort((a, b) => a - b), medY = (ys[n / 2 - 1] + ys[n / 2]) / 2;
  const above = S.filter(p => p.y > medY).length / S.length; // share of the selected above the pool's median criterion
  return {pts, cutX, rAll, rSel, u, corrected: caseII(rSel, u), nSel: S.length, above};
}

// Equal-variance binormal screener: non-cases score N(0, 1), cases N(d, 1); everyone
// at or above `cut` is flagged. Returns the accuracy indices at base rate `prev`.
export function binormal({d = 2, cut = 1, prev = 0.1} = {}) {
  const sens = 1 - pnorm(cut - d), spec = pnorm(cut);
  const ppv = sens * prev / (sens * prev + (1 - spec) * (1 - prev));
  const npv = spec * (1 - prev) / (spec * (1 - prev) + (1 - sens) * prev);
  return {sens, spec, ppv, npv, youden: sens + spec - 1, auc: pnorm(d / Math.SQRT2),
          flagged: sens * prev + (1 - spec) * (1 - prev)};
}

// The ROC curve for the same screener, traced by moving the cut from high to low.
export function rocCurve(d = 2, n = 121) {
  return Array.from({length: n}, (_, i) => {
    const c = 5 - (10 * i) / (n - 1);
    return {fpr: 1 - pnorm(c), tpr: 1 - pnorm(c - d)};
  });
}
