// Widget helpers for the lesson "What does a score mean?". Pure functions only; the
// plotting is in the lesson's OJS cells. Shared math comes from irt.js.
import {logistic, p2pl} from "./irt.js";

// Percentile rank of a score in a reference distribution given as counts by score
// (counts[s] = number of respondents scoring s): the percentage below, plus half the
// percentage at the score (the midpoint convention).
export function percentileRank(score, counts) {
  const n = counts.reduce((s, v) => s + v, 0);
  let below = 0;
  for (let s = 0; s < score; s++) below += counts[s] ?? 0;
  return 100 * (below + (counts[score] ?? 0) / 2) / n;
}

// Mean and SD of a distribution given as counts by score.
export function momentsFromCounts(counts) {
  const n = counts.reduce((s, v) => s + v, 0);
  const m = counts.reduce((s, v, k) => s + k * v, 0) / n;
  const v = counts.reduce((s, c, k) => s + c * (k - m) ** 2, 0) / (n - 1);
  return {n, mean: m, sd: Math.sqrt(v)};
}

// Standard normal quantile (Acklam's approximation, relative error below 1.2e-9).
export function qnorm(p) {
  const a = [-39.6968302866538, 220.946098424521, -275.928510446969, 138.357751867269, -30.6647980661472, 2.50662827745924];
  const b = [-54.4760987982241, 161.585836858041, -155.698979859887, 66.8013118877197, -13.2806815528857];
  const c = [-0.00778489400243029, -0.322396458041136, -2.40075827716184, -2.54973253934373, 4.37466414146497, 2.93816398269878];
  const d = [0.00778469570904146, 0.32246712907004, 2.445134137143, 3.75440866190742];
  const pl = 0.02425;
  if (p < pl) { const q = Math.sqrt(-2 * Math.log(p)); return (((((c[0]*q+c[1])*q+c[2])*q+c[3])*q+c[4])*q+c[5]) / ((((d[0]*q+d[1])*q+d[2])*q+d[3])*q+1); }
  if (p > 1 - pl) { const q = Math.sqrt(-2 * Math.log(1 - p)); return -(((((c[0]*q+c[1])*q+c[2])*q+c[3])*q+c[4])*q+c[5]) / ((((d[0]*q+d[1])*q+d[2])*q+d[3])*q+1); }
  const q = p - 0.5, r = q * q;
  return (((((a[0]*r+a[1])*r+a[2])*r+a[3])*r+a[4])*r+a[5])*q / (((((b[0]*r+b[1])*r+b[2])*r+b[3])*r+b[4])*r+1);
}

// Graded response model in mirt's intercept form: P(x >= k) = logistic(a theta + d_k)
// for k = 1..K, with d decreasing. Returns the K + 1 category probabilities.
export function gradedProbs(theta, a, d) {
  const star = [1, ...d.map(dk => logistic(a * theta + dk)), 0];
  return star.slice(0, -1).map((s, k) => s - star[k + 1]);
}

// Item information for a graded item: sum over categories of (dP_k / dtheta)^2 / P_k,
// where dP*/dtheta = a P*(1 - P*) for each boundary curve.
export function gradedInfo(theta, a, d) {
  const star = [1, ...d.map(dk => logistic(a * theta + dk)), 0];
  const dstar = star.map(s => a * s * (1 - s));
  let info = 0;
  for (let k = 0; k < star.length - 1; k++) {
    const p = star[k] - star[k + 1], dp = dstar[k] - dstar[k + 1];
    if (p > 1e-300) info += dp * dp / p;
  }
  return info;
}

// Test characteristic curve (expected sum score) and the SD of the sum score at theta,
// for items given as [{a, d: [d1, d2, d3]}, ...].
export function expectedScore(theta, items) {
  return items.reduce((s, it) => s + gradedProbs(theta, it.a, it.d).reduce((u, p, k) => u + k * p, 0), 0);
}
export function rawSem(theta, items) {
  let v = 0;
  for (const it of items) {
    const p = gradedProbs(theta, it.a, it.d);
    const m = p.reduce((u, q, k) => u + k * q, 0);
    v += p.reduce((u, q, k) => u + q * (k - m) ** 2, 0);
  }
  return Math.sqrt(v);
}
export const testInfoGraded = (theta, items) => items.reduce((s, it) => s + gradedInfo(theta, it.a, it.d), 0);

// Invert an increasing function f on [lo, hi] by bisection: the x where f(x) = y.
export function invert(f, y, lo = -8, hi = 8) {
  for (let k = 0; k < 80; k++) {
    const mid = (lo + hi) / 2;
    if (f(mid) < y) lo = mid; else hi = mid;
  }
  return (lo + hi) / 2;
}

// Angoff panel. Each judge pictures a borderline respondent at their own theta
// (the panel's borderline theta plus the judge's offset) and rates, for each Rasch
// item, the probability that this respondent answers correctly, with rating noise.
// Returns the ratings (judges x items), each judge's sum, the cut (mean of the sums),
// its standard error (SD of the sums over the square root of the number of judges)
// and the cut on the theta scale (through the test characteristic curve).
export function angoffPanel(bs, nJudges, borderline, spread, noise, r) {
  const judges = [];
  for (let j = 0; j < 15; j++) {       // draw 15 so that adding judges keeps the first ones
    const off = r.norm() * spread;
    const ratings = bs.map(b => Math.min(0.98, Math.max(0.02, p2pl(borderline + off, b) + noise * r.norm())));
    judges.push({judge: j + 1, ratings, sum: ratings.reduce((s, v) => s + v, 0)});
  }
  const panel = judges.slice(0, nJudges);
  const sums = panel.map(j => j.sum);
  const cut = sums.reduce((s, v) => s + v, 0) / nJudges;
  const sd = Math.sqrt(sums.reduce((s, v) => s + (v - cut) ** 2, 0) / (nJudges - 1));
  const tcc = t => bs.reduce((s, b) => s + p2pl(t, b), 0);
  return {panel, cut, se: sd / Math.sqrt(nJudges), thetaCut: invert(tcc, cut),
          thetaLo: invert(tcc, cut - 1.96 * sd / Math.sqrt(nJudges)),
          thetaHi: invert(tcc, cut + 1.96 * sd / Math.sqrt(nJudges))};
}

// Reliability of a difference score x2 - x1 with equal variances:
// ((rel1 + rel2) / 2 - r12) / (1 - r12).
export const diffReliability = (rel1, rel2, r12) => ((rel1 + rel2) / 2 - r12) / (1 - r12);

