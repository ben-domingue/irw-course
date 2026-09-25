// Item response math and colours shared by the lesson widgets. Pure functions only: the
// plotting happens in each lesson's OJS cells, where Observable Plot is in scope.
// Import with:  import {p2pl, loglik} from "./widgets/irt.js"

// Colours for every widget: use these names, never a hex literal in a lesson.
// main is the site's primary blue; contrast marks the comparison or the reference.
export const palette = {
  main: "#2780e3",
  contrast: "#c2410c",
  light: "#93c5fd",
  white: "#ffffff",
  rule: "#ccc",   // solid reference line
  guide: "#999",  // dashed reference line
  ink: "black"
};

export const logistic = (x) => 1 / (1 + Math.exp(-x));

// Probability of a correct response. With a = 1 this is the Rasch model.
export const p2pl = (theta, b, a = 1) => logistic(a * (theta - b));

// Standard normal CDF (Abramowitz & Stegun 7.1.26; error below 1e-7).
export function pnorm(x) {
  const t = 1 / (1 + 0.3275911 * Math.abs(x) / Math.SQRT2);
  const y = 1 - (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t
    - 0.284496736) * t + 0.254829592) * t * Math.exp(-(x * x) / 2);
  return x >= 0 ? (1 + y) / 2 : (1 - y) / 2;
}

export const dnorm = (x, mu = 0, sd = 1) =>
  Math.exp(-0.5 * ((x - mu) / sd) ** 2) / (sd * Math.sqrt(2 * Math.PI));

// Evenly spaced grid, inclusive of both ends.
export const grid = (lo, hi, n = 241) =>
  Array.from({ length: n }, (_, i) => lo + (i * (hi - lo)) / (n - 1));

// Log-likelihood of a response pattern x (0/1 array) at theta, given item
// difficulties b and (optional) slopes a.
export function loglik(theta, x, b, a = null) {
  let ll = 0;
  for (let i = 0; i < x.length; i++) {
    const p = p2pl(theta, b[i], a ? a[i] : 1);
    ll += x[i] ? Math.log(p) : Math.log(1 - p);
  }
  return ll;
}

// Maximum-likelihood theta by grid search. Returns +/-Infinity for all-correct
// or all-incorrect patterns, where no finite maximum exists.
export function mle(x, b, a = null, lo = -6, hi = 6) {
  const s = x.reduce((u, v) => u + v, 0);
  if (s === 0) return -Infinity;
  if (s === x.length) return Infinity;
  let best = lo, bestll = -Infinity;
  for (const t of grid(lo, hi, 2401)) {
    const ll = loglik(t, x, b, a);
    if (ll > bestll) { bestll = ll; best = t; }
  }
  return best;
}

// All 0/1 patterns of length n with sum s.
export function patternsWithSum(n, s) {
  const out = [];
  for (let m = 0; m < 2 ** n; m++) {
    const x = Array.from({ length: n }, (_, i) => (m >> i) & 1);
    if (x.reduce((u, v) => u + v, 0) === s) out.push(x);
  }
  return out;
}

// Expected proportion correct for a normal(mu, sd) population on items b.
export function expectedPropCorrect(b, mu = 0, sd = 1) {
  const g = grid(mu - 5 * sd, mu + 5 * sd, 401);
  const w = g.map((t) => dnorm(t, mu, sd));
  const wsum = w.reduce((u, v) => u + v, 0);
  let e = 0;
  for (let k = 0; k < g.length; k++)
    e += w[k] * b.reduce((u, bi) => u + p2pl(g[k], bi), 0) / b.length;
  return e / wsum;
}

// n values evenly spread (as quantiles) from a normal(mu, sd): a deterministic
// stand-in for a sample, so widgets don't jitter as sliders move.
export function normalQuantiles(n, mu = 0, sd = 1) {
  const qnorm = (p) => { // Acklam's approximation
    const a = [-39.6968302866538, 220.946098424521, -275.928510446969, 138.357751867269, -30.6647980661472, 2.50662827745924];
    const b = [-54.4760987982241, 161.585836858041, -155.698979859887, 66.8013118877197, -13.2806815528857];
    const c = [-0.00778489400243029, -0.322396458041136, -2.40075827716184, -2.54973253934373, 4.37466414146497, 2.93816398269878];
    const d = [0.00778469570904146, 0.32246712907004, 2.445134137143, 3.75440866190742];
    const pl = 0.02425;
    if (p < pl) { const q = Math.sqrt(-2 * Math.log(p)); return (((((c[0]*q+c[1])*q+c[2])*q+c[3])*q+c[4])*q+c[5]) / ((((d[0]*q+d[1])*q+d[2])*q+d[3])*q+1); }
    if (p > 1 - pl) { const q = Math.sqrt(-2 * Math.log(1 - p)); return -(((((c[0]*q+c[1])*q+c[2])*q+c[3])*q+c[4])*q+c[5]) / ((((d[0]*q+d[1])*q+d[2])*q+d[3])*q+1); }
    const q = p - 0.5, r = q * q;
    return (((((a[0]*r+a[1])*r+a[2])*r+a[3])*r+a[4])*r+a[5])*q / (((((b[0]*r+b[1])*r+b[2])*r+b[3])*r+b[4])*r+1);
  };
  return Array.from({ length: n }, (_, i) => mu + sd * qnorm((i + 0.5) / n));
}

// Seeded random numbers, so a widget's simulated sample is the same every time
// the page loads and only changes when a slider does.
export function rng(seed = 1) {
  let a = seed >>> 0;
  const unif = () => {
    a = (a + 0x6D2B79F5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
  const norm = () => { // Box-Muller
    let u = 0; while (u === 0) u = unif();
    return Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * unif());
  };
  return { unif, norm };
}

export const cor = (x, y) => {
  const n = x.length, mx = x.reduce((u, v) => u + v, 0) / n, my = y.reduce((u, v) => u + v, 0) / n;
  let sxy = 0, sxx = 0, syy = 0;
  for (let i = 0; i < n; i++) { sxy += (x[i] - mx) * (y[i] - my); sxx += (x[i] - mx) ** 2; syy += (y[i] - my) ** 2; }
  return sxy / Math.sqrt(sxx * syy);
};

// Eigenvalues of a symmetric matrix (cyclic Jacobi), largest first. Fine for the
// small correlation matrices the widgets use (a few dozen items at most).
export function eigenSym(A) {
  const n = A.length, a = A.map(r => r.slice());
  for (let sweep = 0; sweep < 100; sweep++) {
    let off = 0;
    for (let p = 0; p < n; p++) for (let q = p + 1; q < n; q++) off += a[p][q] ** 2;
    if (off < 1e-12) break;
    for (let p = 0; p < n; p++) for (let q = p + 1; q < n; q++) {
      if (Math.abs(a[p][q]) < 1e-15) continue;
      const th = (a[q][q] - a[p][p]) / (2 * a[p][q]);
      const t = Math.sign(th || 1) / (Math.abs(th) + Math.sqrt(th * th + 1));
      const c = 1 / Math.sqrt(t * t + 1), s = t * c;
      for (let k = 0; k < n; k++) {
        const akp = a[k][p], akq = a[k][q];
        a[k][p] = c * akp - s * akq; a[k][q] = s * akp + c * akq;
      }
      for (let k = 0; k < n; k++) {
        const apk = a[p][k], aqk = a[q][k];
        a[p][k] = c * apk - s * aqk; a[q][k] = s * apk + c * aqk;
      }
    }
  }
  return a.map((r, i) => r[i]).sort((x, y) => y - x);
}

// Correlation matrix of the columns of X (an array of rows).
export function corMatrix(X) {
  const n = X.length, p = X[0].length, m = Array(p).fill(0), s = Array(p).fill(0);
  for (const r of X) for (let j = 0; j < p; j++) m[j] += r[j] / n;
  for (const r of X) for (let j = 0; j < p; j++) s[j] += (r[j] - m[j]) ** 2;
  const R = Array.from({length: p}, () => Array(p).fill(0));
  for (let j = 0; j < p; j++) for (let k = j; k < p; k++) {
    let c = 0; for (const r of X) c += (r[j] - m[j]) * (r[k] - m[k]);
    R[j][k] = R[k][j] = c / Math.sqrt(s[j] * s[k]);
  }
  return R;
}

// An order-preserving rescaling: (exp(k z) - 1) / k, and z itself at k = 0.
// k < 0 compresses the top of the scale and stretches the bottom; k > 0 the reverse.
export const rescaleExp = (z, k) => (k === 0 ? z : (Math.exp(k * z) - 1) / k);

// Standardized mean difference between two samples, using the SD of the two
// pooled together (as when scores are standardized on the whole sample).
export function stdGap(treated, control) {
  const all = treated.concat(control), n = all.length;
  const m = all.reduce((u, v) => u + v, 0) / n;
  const sd = Math.sqrt(all.reduce((u, v) => u + (v - m) ** 2, 0) / (n - 1));
  const mean = (x) => x.reduce((u, v) => u + v, 0) / x.length;
  return (mean(treated) - mean(control)) / sd;
}

// KR-20 (Cronbach's alpha for 0/1 items). X is an array of respondents' 0/1 rows.
// Uses n - 1 variances throughout, like R's var().
export function kr20(X) {
  const n = X.length, k = X[0].length, p = Array(k).fill(0), tot = X.map(r => r.reduce((u, v) => u + v, 0));
  for (const r of X) for (let i = 0; i < k; i++) p[i] += r[i] / n;
  const sumVar = p.reduce((u, pi) => u + pi * (1 - pi), 0) * n / (n - 1);
  const mt = tot.reduce((u, v) => u + v, 0) / n;
  const varT = tot.reduce((u, v) => u + (v - mt) ** 2, 0) / (n - 1);
  return (k / (k - 1)) * (1 - sumVar / varT);
}

// m distinct indices from 0..w.length-1, each draw proportional to w among the
// indices not yet drawn (what R's sample(..., prob = w) does without replacement).
// r is a generator from rng().
export function sampleWeighted(r, w, m) {
  const left = w.slice(), out = [];
  let total = left.reduce((u, v) => u + v, 0);
  for (let d = 0; d < m; d++) {
    let u = r.unif() * total, i = 0;
    while (i < left.length - 1 && (u >= left[i] || left[i] === 0)) { u -= left[i]; i++; }
    out.push(i); total -= left[i]; left[i] = 0;
  }
  return out;
}

// Logistic regression of y on x by Newton's method. For grouped data, y holds
// proportions and n the group sizes (default 1 each). Returns {b0, b1}, the MLE.
export function logisticFit(x, y, n = null) {
  let b0 = 0, b1 = 0;
  for (let it = 0; it < 50; it++) {
    let g0 = 0, g1 = 0, h00 = 0, h01 = 0, h11 = 0;
    for (let j = 0; j < x.length; j++) {
      const w = n ? n[j] : 1, p = logistic(b0 + b1 * x[j]), v = w * p * (1 - p);
      g0 += w * (y[j] - p); g1 += w * (y[j] - p) * x[j];
      h00 += v; h01 += v * x[j]; h11 += v * x[j] * x[j];
    }
    const det = h00 * h11 - h01 * h01;
    const d0 = (h11 * g0 - h01 * g1) / det, d1 = (h00 * g1 - h01 * g0) / det;
    b0 += d0; b1 += d1;
    if (Math.abs(d0) + Math.abs(d1) < 1e-10) break;
  }
  return {b0, b1};
}
