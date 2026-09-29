// Widget helpers for the lesson "Nonparametric IRT: Mokken scaling". Pure functions
// only; the plotting is in the lesson's OJS cells. Shared math comes from irt.js.
import {logistic, pnorm, rng} from "./irt.js";

// Standard normal quantile (Acklam's approximation, as inside irt.js's normalQuantiles).
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

// Item curve shapes used by the widgets: a 2PL curve, a flat line, and a curve that
// rises and then falls (a bump centred at `peak`).
export function curve(shape, theta, {a = 1.5, b = 0, peak = 0.3, width = 0.7, level = 0.5} = {}) {
  if (shape === "flat") return level;
  if (shape === "bump") return 0.1 + 0.8 * Math.exp(-((theta - peak) ** 2) / (2 * width * width));
  return logistic(a * (theta - b));
}

// Simulate n respondents: theta ~ N(0, 1), `k` 2PL items with slope a and difficulties
// spread evenly over [-1.5, 1.5], plus one target item with the given curve.
// Returns {theta, X (n rows of k items), y (the target item)}.
export function simWithTarget(seed, n, k, shape, opts = {}, a = 1.5) {
  const r = rng(seed);
  const bs = Array.from({length: k}, (_, i) => -1.5 + 3 * i / (k - 1));
  const theta = [], X = [], y = [];
  for (let j = 0; j < n; j++) {
    const t = r.norm();
    theta.push(t);
    X.push(bs.map(b => (r.unif() < logistic(a * (t - b)) ? 1 : 0)));
    y.push(r.unif() < curve(shape, t, opts) ? 1 : 0);
  }
  return {theta, X, y};
}

// Pool adjacent rest scores, lowest first, until each group has at least `minsize`
// respondents; a last group that is too small joins the one before it. Returns
// [{lo, hi, n, k (number positive), prop}].
export function restGroups(rest, y, minsize) {
  const maxR = Math.max(...rest);
  const n = Array(maxR + 1).fill(0), k = Array(maxR + 1).fill(0);
  rest.forEach((s, j) => { n[s] += 1; k[s] += y[j]; });
  const groups = [];
  let cur = null;
  for (let s = 0; s <= maxR; s++) {
    if (n[s] === 0) continue;
    if (!cur) cur = {lo: s, hi: s, n: 0, k: 0};
    cur.hi = s; cur.n += n[s]; cur.k += k[s];
    if (cur.n >= minsize) { groups.push(cur); cur = null; }
  }
  if (cur) {
    if (groups.length) { const g = groups[groups.length - 1]; g.hi = cur.hi; g.n += cur.n; g.k += cur.k; }
    else groups.push(cur);
  }
  return groups.map(g => ({...g, prop: g.k / g.n}));
}

// Every pair of groups (lower rest scores first): a violation is a drop in the
// proportion larger than minvi; it is flagged when a one-sided two-proportion z test
// rejects at alpha = 0.05 (z > 1.645).
export function violations(groups, minvi = 0.03) {
  const out = [];
  for (let g = 0; g < groups.length; g++) for (let h = g + 1; h < groups.length; h++) {
    const lo = groups[g], hi = groups[h], drop = lo.prop - hi.prop;
    if (drop <= minvi) continue;
    const pbar = (lo.k + hi.k) / (lo.n + hi.n);
    const z = drop / Math.sqrt(pbar * (1 - pbar) * (1 / lo.n + 1 / hi.n));
    out.push({from: g, to: h, drop, z, sig: z > 1.645});
  }
  return out;
}

// Two items as a 2 x 2 table, with Guttman errors and Loevinger's H_ij. The "harder"
// item is the one with the smaller proportion positive; a Guttman error is a
// respondent who gets the harder item right and the easier one wrong.
export function pairH(x1, x2) {
  const n = x1.length;
  let n11 = 0, n10 = 0, n01 = 0, n00 = 0;
  for (let j = 0; j < n; j++) {
    if (x1[j] && x2[j]) n11++; else if (x1[j]) n10++; else if (x2[j]) n01++; else n00++;
  }
  const p1 = (n11 + n10) / n, p2 = (n11 + n01) / n;
  const hard = p1 <= p2 ? 1 : 2;
  const pHard = Math.min(p1, p2), pEasy = Math.max(p1, p2);
  const observed = hard === 1 ? n10 : n01;            // harder right, easier wrong
  const expected = n * pHard * (1 - pEasy);
  const cov = n11 / n - p1 * p2, covMax = pHard * (1 - pEasy);
  return {n, n11, n10, n01, n00, p1, p2, hard, observed, expected,
          H: 1 - observed / expected, cov, covMax, Hcov: cov / covMax};
}

// Rank-based abilities, as in Ramsay (1991) and KernSmoothIRT: rank the sum scores
// (ties broken by order), then take normal quantiles of rank / (n + 1).
export function rankTheta(sums) {
  const n = sums.length;
  const idx = sums.map((s, j) => [s, j]).sort((u, v) => u[0] - v[0] || u[1] - v[1]);
  const th = Array(n);
  idx.forEach(([, j], r) => { th[j] = qnorm((r + 1) / (n + 1)); });
  return th;
}

// Nadaraya-Watson estimate of P(y = 1) at each point of `at`, Gaussian kernel with
// bandwidth h.
export function kernelCurve(theta, y, at, h) {
  return at.map(t => {
    let num = 0, den = 0;
    for (let j = 0; j < theta.length; j++) {
      const w = Math.exp(-0.5 * ((t - theta[j]) / h) ** 2);
      num += w * y[j]; den += w;
    }
    return num / den;
  });
}

// The population share (theta ~ N(0, 1)) for whom two 2PL items come in the opposite
// order to the one the whole population shows. Returns {cross, share, easier}: the
// crossing point (null for equal slopes), the share, and which item is easier
// overall (1 or 2).
export function reversedShare(a1, b1, a2, b2) {
  // marginal proportions by a simple quadrature over N(0, 1)
  const ts = Array.from({length: 401}, (_, i) => -5 + i * 0.025);
  const dens = ts.map(t => Math.exp(-t * t / 2));
  const tot = dens.reduce((u, v) => u + v, 0);
  const m1 = ts.reduce((u, t, i) => u + dens[i] * logistic(a1 * (t - b1)), 0) / tot;
  const m2 = ts.reduce((u, t, i) => u + dens[i] * logistic(a2 * (t - b2)), 0) / tot;
  const easier = m1 >= m2 ? 1 : 2;
  if (Math.abs(a1 - a2) < 1e-9) return {cross: null, share: 0, easier, m1, m2};
  const cross = (a1 * b1 - a2 * b2) / (a1 - a2);
  // just below the crossing, which item is higher?
  const t0 = cross - 1e-3;
  const firstBelow = logistic(a1 * (t0 - b1)) > logistic(a2 * (t0 - b2)) ? 1 : 2;
  const share = firstBelow === easier ? 1 - pnorm(cross) : pnorm(cross);
  return {cross, share, easier, m1, m2, reversedBelow: firstBelow !== easier};
}
