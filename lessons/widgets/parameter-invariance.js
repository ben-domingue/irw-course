// Helpers for the parameter-invariance widgets. Pure functions; shared maths from irt.js.
import {logistic, logisticFit, rng, corMatrix} from "./irt.js";

// Abilities spread evenly over [lo, hi] (n of them), each answering one 2PL item
// (slope a, difficulty b). r is a generator from rng(). Returns {theta, y}.
export function sampleRange(r, n, lo, hi, a, b) {
  const theta = Array.from({length: n}, () => lo + (hi - lo) * r.unif());
  const y = theta.map(t => (r.unif() < logistic(a * (t - b)) ? 1 : 0));
  return {theta, y};
}

// Fit the item's curve by logistic regression on the (known) abilities, and report it
// in slope-difficulty form. Returns {a, b}, or null when every response is the same
// (or the fit runs off, as it does when a narrow range separates 0s from 1s).
export function fitItem(theta, y) {
  const s = y.reduce((u, v) => u + v, 0);
  if (s === 0 || s === y.length) return null;
  const {b0, b1} = logisticFit(theta, y);
  if (!Number.isFinite(b0) || !Number.isFinite(b1) || Math.abs(b1) > 50) return null;
  return {a: b1, b: -b0 / b1};
}

// Observed proportions correct in bins of ability, for plotting points under a curve.
export function binned(theta, y, width = 0.25) {
  const bins = new Map();
  theta.forEach((t, k) => {
    const lo = Math.floor(t / width) * width;
    const d = bins.get(lo) || {n: 0, s: 0};
    d.n++; d.s += y[k]; bins.set(lo, d);
  });
  return [...bins].map(([lo, d]) => ({theta: lo + width / 2, p: d.s / d.n, n: d.n}));
}

// Repeat the one-item fit reps times on fresh samples; returns the slope estimates that
// could be computed and how many samples gave none.
export function slopeSpread(seed, reps, n, lo, hi, a, b) {
  const r = rng(seed), slopes = [];
  let failed = 0;
  for (let k = 0; k < reps; k++) {
    const {theta, y} = sampleRange(r, n, lo, hi, a, b);
    const f = fitItem(theta, y);
    if (f) slopes.push(f.a); else failed++;
  }
  return {slopes, failed};
}

// n respondents from N(0, 1) answer k 2PL items (common slope a, difficulties spread
// evenly over [-1.5, 1.5]). Returns the mean inter-item correlation in everyone, and in
// the upper and lower halves split on the true ability or on the sum score.
export function selectionCorrelations(seed, n, k, a) {
  const r = rng(seed);
  const bs = Array.from({length: k}, (_, i) => (k === 1 ? 0 : -1.5 + 3 * i / (k - 1)));
  const theta = Array.from({length: n}, () => r.norm());
  const X = theta.map(t => bs.map(b => (r.unif() < logistic(a * (t - b)) ? 1 : 0)));
  const sum = X.map(x => x.reduce((u, v) => u + v, 0));
  const meanR = rows => {
    const R = corMatrix(rows);
    let s = 0, m = 0;
    for (let i = 0; i < k; i++) for (let j = i + 1; j < k; j++) if (Number.isFinite(R[i][j])) { s += R[i][j]; m++; }
    return m ? s / m : NaN;
  };
  const median = v => { const w = v.slice().sort((p, q) => p - q); return (w[Math.floor((w.length - 1) / 2)] + w[Math.ceil((w.length - 1) / 2)]) / 2; };
  const mt = median(theta), ms = median(sum);
  return [
    {group: "Everyone", split: "none", r: meanR(X)},
    {group: "Upper half by ability", split: "ability", r: meanR(X.filter((_, j) => theta[j] > mt))},
    {group: "Lower half by ability", split: "ability", r: meanR(X.filter((_, j) => theta[j] <= mt))},
    {group: "Upper half by sum score", split: "sum score", r: meanR(X.filter((_, j) => sum[j] > ms))},
    {group: "Lower half by sum score", split: "sum score", r: meanR(X.filter((_, j) => sum[j] <= ms))}
  ];
}
