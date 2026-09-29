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

// A weighted sum of residuals, sum_i (x_i - P_i) w_i, standardized as if theta were
// the true value (z) and with Snijders's correction for an ML theta (zStar): take out
// the part of w along the slopes, which the score equation has already set to zero.
function wsum(x, P, a, w) {
  let num = 0, v = 0, pqwa = 0, pqaa = 0;
  P.forEach((p, i) => {
    const pq = p * (1 - p);
    num += (x[i] - p) * w[i]; v += pq * w[i] * w[i];
    pqwa += pq * a[i] * w[i]; pqaa += pq * a[i] * a[i];
  });
  const c = pqwa / pqaa;
  let vS = 0;
  P.forEach((p, i) => { vS += p * (1 - p) * (w[i] - c * a[i]) ** 2; });
  return {z: num / Math.sqrt(v), zStar: num / Math.sqrt(vS)};
}

// Person-fit statistics for one pattern x at ability theta.
// l0: log likelihood; El, Vl: its mean and variance if theta were the true value;
// lz = (l0 - El) / sqrt(Vl); lzstar: Snijders's correction for an ML theta;
// outfit and infit: mean squared standardized residual, unweighted and weighted.
// For 0/1 responses (x - P)^2 = PQ + (1 - 2P)(x - P), so outfit - 1 and infit - 1 are
// weighted sums of residuals too, with weights (1 - 2P)/PQ and (1 - 2P): zOut, zIn
// standardize them, and zOutStar, zInStar apply the same correction (Magis, Beland
// & Raiche, 2014). For these, positive is underfit.
export function fitStats(x, a, b, theta) {
  const P = probs(theta, a, b);
  let l0 = 0, El = 0, z2 = 0, sq = 0, pq = 0;
  P.forEach((p, i) => {
    const q = 1 - p;
    l0 += x[i] ? Math.log(p) : Math.log(q);
    El += p * Math.log(p) + q * Math.log(q);
    z2 += (x[i] - p) ** 2 / (p * q);
    sq += (x[i] - p) ** 2;
    pq += p * q;
  });
  const L = wsum(x, P, a, P.map(p => Math.log(p / (1 - p))));
  const O = wsum(x, P, a, P.map(p => (1 - 2 * p) / (p * (1 - p))));
  const I = wsum(x, P, a, P.map(p => 1 - 2 * p));
  const Vl = P.reduce((s, p) => s + p * (1 - p) * Math.log(p / (1 - p)) ** 2, 0);
  return {l0, El, Vl, lz: L.z, lzstar: L.zStar, outfit: z2 / x.length, infit: sq / pq,
          zOut: O.z, zOutStar: O.zStar, zIn: I.z, zInStar: I.zStar};
}

// Expected proportion correct for each Rasch item in a population with theta
// standard normal (a grid sum). The Guttman widget orders items by these, as a
// group-based statistic orders them by the proportions correct in a sample.
export function propCorrect(b) {
  const g = Array.from({length: 121}, (_, k) => -6 + 0.1 * k);
  const phi = g.map(t => Math.exp(-t * t / 2));
  const tot = phi.reduce((s, v) => s + v, 0);
  return b.map(bi => g.reduce((s, t, k) => s + phi[k] * logistic(t - bi), 0) / tot);
}

// Sijtsma's H^T for every row of a 0/1 matrix X (rows respondents, no row all 0 or
// all 1): Loevinger's H with respondents in the part of items. The numerator is the
// covariance, over items, of a respondent's responses with the others' summed
// responses; the denominator is the largest that covariance could be given the
// respondents' proportions correct, sum over others of min(p_n, p_m) - p_n p_m.
// Matches PerFit::Ht.
export function ht(X) {
  const N = X.length, n = X[0].length;
  const col = Array(n).fill(0);
  for (const x of X) x.forEach((v, i) => { col[i] += v; });
  const p = X.map(x => x.reduce((s, v) => s + v, 0) / n);
  const order = p.map((_, j) => j).sort((i, j) => p[i] - p[j]);
  const sorted = order.map(j => p[j]);
  const cum = [0]; sorted.forEach(v => cum.push(cum[cum.length - 1] + v));
  const total = cum[N];
  // sum over m != n of min(p_n, p_m): the p_m below p_n, plus p_n for each at or above
  const lowerBound = v => { let lo = 0, hi = N; while (lo < hi) { const mid = (lo + hi) >> 1; if (sorted[mid] < v) lo = mid + 1; else hi = mid; } return lo; };
  return X.map((x, j) => {
    const pn = p[j], k = lowerBound(pn);
    const sumMin = cum[k] + pn * (N - k - 1);
    const den = sumMin - pn * (total - pn);
    const others = col.map((c, i) => c - x[i]);
    const mo = others.reduce((s, v) => s + v, 0) / n;
    const num = x.reduce((s, v, i) => s + (v - pn) * (others[i] - mo), 0) / n;
    return num / den;
  });
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

// The null distribution: nResp respondents answer under the 2PL. For each, three
// statistics (l_z, standardized outfit, standardized infit) at the true theta, at
// the ML estimate, and with Snijders's correction at the ML estimate, plus the true
// theta and the estimate. Perfect and zero scores are counted and dropped.
export function simNull(nItems, nResp = 2000, seed = 11) {
  const {a, b} = simItems(nItems);
  const r = rng(seed);
  const out = {rows: [], dropped: 0};
  for (let j = 0; j < nResp; j++) {
    const t = r.norm();
    const x = b.map((bi, i) => (r.unif() < logistic(a[i] * (t - bi)) ? 1 : 0));
    const th = mle(x, a, b);
    if (!Number.isFinite(th)) { out.dropped++; continue; }
    const s0 = fitStats(x, a, b, t), s = fitStats(x, a, b, th);
    out.rows.push({theta: t, thetaHat: th,
      lz: {true: s0.lz, hat: s.lz, star: s.lzstar},
      outfit: {true: s0.zOut, hat: s.zOut, star: s.zOutStar},
      infit: {true: s0.zIn, hat: s.zIn, star: s.zInStar}});
  }
  return out;
}

// One simulated sample with some aberrant respondents. kind is "random" (every
// answer a 1-in-4 guess), "preknowledge" (the k hardest items right), "guessing"
// (respondents below theta = -0.5 guess, 1 in 4, whenever the item is beyond them)
// or "shift" (k items answered from a second, unrelated trait). Returns l_z*, G*,
// outfit and H^T for every respondent with a finite ML theta, and who was aberrant.
// G* orders the items by proportion correct in this sample, and H^T compares each
// respondent with the others in it: both are group-based.
function simSample(nItems, k, kind, share, nResp, seed) {
  const {a, b} = simItems(nItems);
  const r = rng(seed);
  const rows = [], X = [];
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
    rows.push({bad: isBad, lzstar: s.lzstar, outfit: s.outfit});
    X.push(x);
  }
  const pc = X[0].map((_, i) => X.reduce((u, x) => u + x[i], 0));
  const ord = pc.map((_, i) => i).sort((i, j) => pc[j] - pc[i]);
  const h = ht(X);
  rows.forEach((d, j) => { d.gstar = guttman(ord.map(i => X[j][i])).gstar; d.ht = h[j]; });
  return rows;
}

// Power at a 5% false-alarm rate. Cutoffs come from a clean sample simulated from
// the same model (low l_z*, high G*, high outfit, low H^T), the way PerFit sets cutoffs by
// simulation. Returns, for each statistic, the share flagged among clean and among
// aberrant respondents of a second sample.
export function power(nItems, k, kind, share = 0.1, nResp = 3000) {
  const ref = simSample(nItems, k, "none", 0, nResp, 101);
  const q = (v, p) => { const s = [...v].sort((u, w) => u - w); return s[Math.floor(p * (s.length - 1))]; };
  const cut = {lzstar: q(ref.map(d => d.lzstar), 0.05), gstar: q(ref.map(d => d.gstar), 0.95),
               outfit: q(ref.map(d => d.outfit), 0.95), ht: q(ref.map(d => d.ht), 0.05)};
  const rows = simSample(nItems, k, kind, share, nResp, 202);
  const flag = {lzstar: d => d.lzstar < cut.lzstar, gstar: d => d.gstar > cut.gstar,
                outfit: d => d.outfit > cut.outfit, ht: d => d.ht < cut.ht};
  const bad = rows.filter(d => d.bad), good = rows.filter(d => !d.bad);
  const rate = (set, f) => (set.length ? set.filter(f).length / set.length : NaN);
  return {nBad: bad.length, nGood: good.length, cut,
          rows: ["lzstar", "outfit", "gstar", "ht"].map(s => ({stat: s,
            clean: rate(good, flag[s]), aberrant: rate(bad, flag[s])}))};
}
