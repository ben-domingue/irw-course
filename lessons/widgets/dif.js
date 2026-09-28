// Widget helpers for the lesson "Differential item functioning". Pure functions only;
// the plotting is in the lesson's OJS cells. Shared math comes from irt.js.
import {logistic, rng, pnorm, scores, mhItem} from "./irt.js";

// Simulate two groups answering nItems 2PL items. g = 0 is the reference group,
// g = 1 the focal group, whose mean theta is -impact. dif is a list of
// {item, db, a} objects: for the focal group that item's difficulty is shifted by
// db and (optionally) its slope replaced by a. Returns {X, g} with X a list of
// 0/1 response rows.
export function simGroups({seed = 1, nPer = 1000, nItems = 10, impact = 0, b = null,
                           a = null, dif = []}) {
  const r = rng(seed);
  const bb = b || Array.from({length: nItems}, (_, i) => -1.5 + 3 * i / Math.max(1, nItems - 1));
  const aa = a || Array(nItems).fill(1);
  const X = [], g = [];
  for (let grp = 0; grp < 2; grp++) {
    const bF = bb.slice(), aF = aa.slice();
    if (grp === 1) for (const d of dif) { bF[d.item] += d.db || 0; if (d.a != null) aF[d.item] = d.a; }
    for (let j = 0; j < nPer; j++) {
      const th = r.norm() - (grp === 1 ? impact : 0);
      X.push(bF.map((bi, i) => (r.unif() < logistic(aF[i] * (th - bi)) ? 1 : 0)));
      g.push(grp);
    }
  }
  return {X, g};
}

// ETS category from delta, its SE and the MH p-value (Zwick, 2012).
export function etsCategory({delta, se, p}) {
  const ad = Math.abs(delta);
  if (p >= 0.05 || ad < 1) return "A";
  if (ad >= 1.5 && (ad - 1) / se > 1.645) return "C";
  return "B";
}

// MH for every item, matching on the total over `anchor` columns plus the studied
// item (the full total when anchor is null).
export function mhAll(X, g, anchor = null) {
  const nI = X[0].length;
  return Array.from({length: nI}, (_, i) => {
    const cols = anchor ? Array.from(new Set([...anchor, i])) : null;
    const res = mhItem(X.map(r => r[i]), g, scores(X, cols));
    return {item: i, ...res, ets: etsCategory(res)};
  });
}

// Two-stage purification: flag items that are significant with |delta| >= 1, drop
// them from the matching score, and run MH again.
export function mhPurified(X, g) {
  const first = mhAll(X, g);
  const keep = first.filter(d => !(d.p < 0.05 && Math.abs(d.delta) >= 1)).map(d => d.item);
  return {first, second: mhAll(X, g, keep), dropped: X[0].length - keep.length};
}

// Logistic regression by Newton's method for a small design matrix (rows of
// covariates, intercept included by the caller). Returns the coefficients.
export function logitFit(Z, y, iters = 40) {
  const p = Z[0].length;
  let beta = Array(p).fill(0);
  for (let it = 0; it < iters; it++) {
    const grad = Array(p).fill(0), H = Array.from({length: p}, () => Array(p).fill(0));
    for (let j = 0; j < y.length; j++) {
      const z = Z[j];
      let eta = 0; for (let k = 0; k < p; k++) eta += beta[k] * z[k];
      const mu = logistic(eta), w = mu * (1 - mu);
      for (let k = 0; k < p; k++) {
        grad[k] += (y[j] - mu) * z[k];
        for (let l = 0; l < p; l++) H[k][l] += w * z[k] * z[l];
      }
    }
    const step = solve(H, grad);
    beta = beta.map((b, k) => b + step[k]);
    if (step.reduce((s, v) => s + Math.abs(v), 0) < 1e-9) break;
  }
  return beta;
}

// Solve H x = v by Gaussian elimination with partial pivoting.
function solve(H, v) {
  const n = v.length, M = H.map((row, i) => [...row, v[i]]);
  for (let c = 0; c < n; c++) {
    let piv = c;
    for (let r = c + 1; r < n; r++) if (Math.abs(M[r][c]) > Math.abs(M[piv][c])) piv = r;
    [M[c], M[piv]] = [M[piv], M[c]];
    for (let r = c + 1; r < n; r++) {
      const f = M[r][c] / M[c][c];
      for (let k = c; k <= n; k++) M[r][k] -= f * M[c][k];
    }
  }
  const x = Array(n).fill(0);
  for (let r = n - 1; r >= 0; r--) {
    let s = M[r][n];
    for (let k = r + 1; k < n; k++) s -= M[r][k] * x[k];
    x[r] = s / M[r][r];
  }
  return x;
}

// Logistic-regression DIF for item i: y ~ total (centred) + group + group x total.
// Returns {b0, b1, group, interaction}.
export function logisticDIF(X, g, i) {
  const s = scores(X), m = s.reduce((u, v) => u + v, 0) / s.length;
  const Z = s.map((t, j) => [1, t - m, g[j], g[j] * (t - m)]);
  const [b0, b1, group, interaction] = logitFit(Z, X.map(r => r[i]));
  return {b0, b1, group, interaction};
}
