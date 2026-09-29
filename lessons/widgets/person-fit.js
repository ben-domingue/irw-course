// Widget helpers for the lesson "Person fit: does a respondent's pattern fit the
// model?". Pure functions only; the plotting is in the lesson's OJS cells. Shared
// math comes from irt.js. Everything is for dichotomous items under the 2PL (the
// Rasch model is every slope a = 1), with the item parameters known.
import {logistic, rng} from "./irt.js";

// Ten items for the first two widgets, easiest first, and slopes for the 2PL option.
// Unevenly spaced, so that under the Rasch model two patterns with the same number of
// Guttman errors can still differ in l_z.
export const gtB = [-2.4, -1.9, -1.2, -0.9, -0.4, 0.1, 0.5, 1.3, 1.6, 2.4];
export const gtA = [1.6, 0.6, 1.2, 2.0, 0.8, 1.4, 0.5, 1.8, 1.0, 0.7];

const probs = (theta, a, b) => b.map((bi, i) => logistic(a[i] * (theta - bi)));

// Maximum likelihood theta: the root of sum_i a_i (x_i - P_i), which falls as theta
// rises. +/-Infinity for a perfect or zero score.
export function mle(x, a, b, lo = -10, hi = 10) {
  const r = x.reduce((s, v) => s + v, 0);
  if (r === 0) return -Infinity;
  if (r === x.length) return Infinity;
  const f = t => b.reduce((s, bi, i) => s + a[i] * (x[i] - logistic(a[i] * (t - bi))), 0);
  for (let k = 0; k < 60; k++) {
    const mid = (lo + hi) / 2;
    if (f(mid) > 0) lo = mid; else hi = mid;
  }
  return (lo + hi) / 2;
}

// Person-fit statistics for one pattern x at ability theta.
// l0: log likelihood; El, Vl: its mean and variance if theta were the true value;
// lz = (l0 - El) / sqrt(Vl); lzstar: Snijders's correction for an ML theta;
// outfit and infit: mean squared standardized residual, unweighted and weighted.
export function fitStats(x, a, b, theta) {
  const P = probs(theta, a, b);
  let l0 = 0, El = 0, Vl = 0, num = 0, pqwa = 0, pqaa = 0, z2 = 0, sq = 0, pq = 0;
  P.forEach((p, i) => {
    const q = 1 - p, w = Math.log(p / q);
    l0 += x[i] ? Math.log(p) : Math.log(q);
    El += p * Math.log(p) + q * Math.log(q);
    Vl += p * q * w * w;
    num += (x[i] - p) * w;
    pqwa += p * q * w * a[i];
    pqaa += p * q * a[i] * a[i];
    z2 += (x[i] - p) ** 2 / (p * q);
    sq += (x[i] - p) ** 2;
    pq += p * q;
  });
  const cn = pqwa / pqaa;
  let numS = 0, vS = 0;
  P.forEach((p, i) => {
    const q = 1 - p, wt = Math.log(p / q) - cn * a[i];
    numS += (x[i] - p) * wt;
    vS += p * q * wt * wt;
  });
  return {l0, El, Vl, lz: num / Math.sqrt(Vl), lzstar: numS / Math.sqrt(vS),
          outfit: z2 / x.length, infit: sq / pq};
}

// Guttman errors for a pattern whose items are ordered easiest first: pairs in
// which the easier item is wrong and the harder one right. G* divides by the most
// there could be, r (n - r).
export function guttman(x) {
  let wrong = 0, errors = 0;
  for (const v of x) { if (v) errors += wrong; else wrong++; }
  const r = x.reduce((s, v) => s + v, 0), n = x.length;
  return {errors, gstar: r > 0 && r < n ? errors / (r * (n - r)) : NaN};
}

// Every pattern of n items with sum score s, as 0/1 arrays.
export function patterns(n, s) {
  const out = [];
  for (let m = 0; m < 1 << n; m++) {
    const x = Array.from({length: n}, (_, i) => (m >> i) & 1);
    if (x.reduce((u, v) => u + v, 0) === s) out.push(x);
  }
  return out;
}

// Items for the simulation widgets: slopes lognormal(0, 0.3), difficulties
// standard normal, sorted easiest first; a fixed seed per test length.
export function simItems(nItems, seed = 7) {
  const r = rng(seed + nItems);
  const a = Array.from({length: nItems}, () => Math.exp(0.3 * r.norm()));
  const b = Array.from({length: nItems}, () => r.norm());
  const order = b.map((_, i) => i).sort((i, j) => b[i] - b[j]);
  return {a: order.map(i => a[i]), b: order.map(i => b[i])};
}

// The null distribution: nResp respondents answer under the 2PL. For each, l_z at
// the true theta, l_z at the ML estimate, and l_z* at the ML estimate. Perfect and
// zero scores are counted and dropped.
export function simNull(nItems, nResp = 2000, seed = 11) {
  const {a, b} = simItems(nItems);
  const r = rng(seed);
  const out = {lzTrue: [], lzHat: [], lzStar: [], dropped: 0};
  for (let j = 0; j < nResp; j++) {
    const t = r.norm();
    const x = b.map((bi, i) => (r.unif() < logistic(a[i] * (t - bi)) ? 1 : 0));
    const th = mle(x, a, b);
    if (!Number.isFinite(th)) { out.dropped++; continue; }
    out.lzTrue.push(fitStats(x, a, b, t).lz);
    const s = fitStats(x, a, b, th);
    out.lzHat.push(s.lz);
    out.lzStar.push(s.lzstar);
  }
  return out;
}

// One simulated sample with some aberrant respondents. kind is "random" (every
// answer a 1-in-4 guess), "preknowledge" (the k hardest items right), "guessing"
// (respondents below theta = -0.5 guess, 1 in 4, whenever the item is beyond them)
// or "shift" (k items answered from a second, unrelated trait). Returns l_z*, G*
// and outfit for every respondent with a finite ML theta, and who was aberrant.
function simSample(nItems, k, kind, share, nResp, seed) {
  const {a, b} = simItems(nItems);
  const r = rng(seed);
  const rows = [];
  for (let j = 0; j < nResp; j++) {
    const t = r.norm(), t2 = r.norm();
    const isBad = kind !== "none" && r.unif() < share && (kind !== "guessing" || t < -0.5);
    const x = b.map((bi, i) => {
      let p = logistic(a[i] * (t - bi));
      if (isBad) {
        if (kind === "random") p = 0.25;
        if (kind === "preknowledge" && i >= nItems - k) p = 1;
        if (kind === "guessing") p = 0.25 + 0.75 * p;
        if (kind === "shift" && i >= nItems - k) p = logistic(a[i] * (t2 - bi));
      }
      return r.unif() < p ? 1 : 0;
    });
    const th = mle(x, a, b);
    if (!Number.isFinite(th)) continue;
    const s = fitStats(x, a, b, th);
    rows.push({bad: isBad, lzstar: s.lzstar, outfit: s.outfit, gstar: guttman(x).gstar});
  }
  return rows;
}

// Power at a 5% false-alarm rate. Cutoffs come from a clean sample simulated from
// the same model (low l_z*, high G*, high outfit), the way PerFit sets cutoffs by
// simulation. Returns, for each statistic, the share flagged among clean and among
// aberrant respondents of a second sample.
export function power(nItems, k, kind, share = 0.1, nResp = 3000) {
  const ref = simSample(nItems, k, "none", 0, nResp, 101);
  const q = (v, p) => { const s = [...v].sort((u, w) => u - w); return s[Math.floor(p * (s.length - 1))]; };
  const cut = {lzstar: q(ref.map(d => d.lzstar), 0.05), gstar: q(ref.map(d => d.gstar), 0.95),
               outfit: q(ref.map(d => d.outfit), 0.95)};
  const rows = simSample(nItems, k, kind, share, nResp, 202);
  const flag = {lzstar: d => d.lzstar < cut.lzstar, gstar: d => d.gstar > cut.gstar,
                outfit: d => d.outfit > cut.outfit};
  const bad = rows.filter(d => d.bad), good = rows.filter(d => !d.bad);
  const rate = (set, f) => (set.length ? set.filter(f).length / set.length : NaN);
  return {nBad: bad.length, nGood: good.length, cut,
          rows: ["lzstar", "gstar", "outfit"].map(s => ({stat: s,
            clean: rate(good, flag[s]), aberrant: rate(bad, flag[s])}))};
}
