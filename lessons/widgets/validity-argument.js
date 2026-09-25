// Widget helpers for the lesson "Validity as an argument". Pure functions only;
// colours and the seeded rng come from irt.js. Import with:
//   import {simCriterion, auc} from "./widgets/validity-argument.js"
import {logistic, rng} from "./irt.js";

// The AUC: the chance that a randomly chosen member of group 1 scores higher than a
// randomly chosen member of group 0, ties counting half. Integer-valued scores
// (a symptom count) are handled exactly by tallying each value.
export function auc(score, group) {
  const c1 = new Map(), c0 = new Map();
  score.forEach((s, i) => { const m = group[i] ? c1 : c0; m.set(s, (m.get(s) || 0) + 1); });
  const vals = [...new Set(score)].sort((a, b) => a - b);
  let below0 = 0, num = 0, n1 = 0, n0 = 0;
  for (const v of vals) {
    const a1 = c1.get(v) || 0, a0 = c0.get(v) || 0;
    num += a1 * (below0 + a0 / 2);
    below0 += a0; n1 += a1; n0 += a0;
  }
  return n1 && n0 ? num / (n1 * n0) : NaN;
}

const zs = (v) => {
  const n = v.length, m = v.reduce((u, x) => u + x, 0) / n;
  const sd = Math.sqrt(v.reduce((u, x) => u + (x - m) ** 2, 0) / (n - 1));
  return v.map(x => (x - m) / sd);
};

// The share-`prev` cut of a numeric array: flag values above the (1 - prev) quantile.
function flagTop(s, prev) {
  const sorted = [...s].sort((a, b) => a - b);
  const q = sorted[Math.floor((1 - prev) * (s.length - 1))];
  return s.map(x => (x > q ? 1 : 0));
}

// The contaminated-criterion simulation (the widget version of the lesson's webR
// code). n children with theta ~ N(0, 1); nine items with slope 2 and difficulties
// spread from 0.2 to 1.8; an independent criterion whose latent variable correlates
// rho with theta, flagging the top `prev`; and a diagnosis that mixes the criterion's
// latent variable (weight 1 - w) with the screener's own count (weight w).
export function simCriterion({seed = 33, n = 1500, rho = 0.6, prev = 0.15} = {}) {
  const r = rng(seed), b = Array.from({length: 9}, (_, i) => 0.2 + 0.2 * i);
  const count = [], zc = [];
  for (let j = 0; j < n; j++) {
    const t = r.norm();
    let s = 0;
    for (const bi of b) s += r.unif() < logistic(2 * (t - bi)) ? 1 : 0;
    count.push(s);
    zc.push(rho * t + Math.sqrt(1 - rho * rho) * r.norm());
  }
  const crit = flagTop(zc, prev), zCount = zs(count), zCrit = zs(zc);
  const diagnose = (w) => flagTop(zCrit.map((v, j) => (1 - w) * v + w * zCount[j]), prev);
  const at = (w) => {
    const d = diagnose(w);
    return {w, d, aucDiag: auc(count, d), aucCrit: auc(count, crit),
            agree: d.reduce((u, v, j) => u + (v === crit[j] ? 1 : 0), 0) / n,
            flagged: d.reduce((u, v) => u + v, 0) / n};
  };
  return {count, crit, at};
}
