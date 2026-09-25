// Widget helpers for the lesson "Estimating item parameters: JML and EM". Pure
// functions only; the plotting is in the lesson's OJS cells. Shared math comes from
// irt.js. The widgets follow Ben Domingue's interactive EM walkthrough (five panels:
// theta as missing data, MML vs. EM, the E step, the M step, convergence), rewritten
// here to the course's notation: item i, respondent (or response pattern) j, node q.
import {logistic, dnorm, grid, rng, logisticFit} from "./irt.js";

// The five 2PL items the EM widgets simulate from, ordered by difficulty.
export const demoA = [1.3, 0.9, 1.6, 1.1, 1.4];
export const demoB = [-1.2, -0.4, 0.2, 0.9, 1.5];

// Q equally spaced nodes t_q on [lo, hi], with normal(0, 1) prior weights that sum to 1.
export function quadrature(Q = 15, lo = -3.5, hi = 3.5) {
  const nodes = grid(lo, hi, Q);
  const d = nodes.map(t => dnorm(t));
  const s = d.reduce((u, v) => u + v, 0);
  return {nodes, w: d.map(v => v / s)};
}

const P2 = (t, a, b) => logistic(a * (t - b));

// n respondents with normal(0, 1) abilities answering 2PL items (a, b). Seeded.
export function simulate2pl(n, a, b, seed = 38) {
  const r = rng(seed);
  const theta = [], X = [];
  for (let j = 0; j < n; j++) {
    const t = r.norm();
    theta.push(t);
    X.push(b.map((bi, i) => (r.unif() < P2(t, a[i], bi) ? 1 : 0)));
  }
  return {theta, X};
}

// Distinct response patterns with their counts, ordered by sum score, then pattern.
export function tabulate(X) {
  const m = new Map();
  for (const x of X) { const k = x.join(""); m.set(k, (m.get(k) || 0) + 1); }
  return [...m.entries()].map(([k, n]) => ({key: k, x: k.split("").map(Number), n,
    r: k.split("").reduce((u, v) => u + Number(v), 0)}))
    .sort((p, q) => p.r - q.r || (p.key < q.key ? 1 : -1));
}

// Log of prior weight x likelihood at every node, for one pattern x.
function logJoint(x, a, b, quad) {
  return quad.nodes.map((t, q) => {
    let l = Math.log(quad.w[q]);
    for (let i = 0; i < x.length; i++) {
      const p = P2(t, a[i], b[i]);
      l += x[i] ? Math.log(p) : Math.log(1 - p);
    }
    return l;
  });
}

// Posterior weights W_q for one pattern (they sum to 1), and the log of the pattern's
// marginal probability, log sum_q w_q L(x | t_q).
export function posterior(x, a, b, quad) {
  const lj = logJoint(x, a, b, quad);
  const top = Math.max(...lj);
  const e = lj.map(v => Math.exp(v - top));
  const s = e.reduce((u, v) => u + v, 0);
  return {W: e.map(v => v / s), logm: top + Math.log(s)};
}

// The E step. From the current item parameters, every pattern's posterior weights,
// then the expected number of respondents at each node, f_q = sum_j n_j W_jq, and the
// expected number correct on item i at node q, r_iq = sum_j n_j W_jq x_ji. Also the
// marginal log likelihood at these parameters.
export function eStep(pats, a, b, quad) {
  const Q = quad.nodes.length, I = a.length;
  const f = Array(Q).fill(0), r = Array.from({length: I}, () => Array(Q).fill(0));
  let ll = 0;
  for (const p of pats) {
    const {W, logm} = posterior(p.x, a, b, quad);
    ll += p.n * logm;
    for (let q = 0; q < Q; q++) {
      f[q] += p.n * W[q];
      for (let i = 0; i < I; i++) if (p.x[i]) r[i][q] += p.n * W[q];
    }
  }
  return {f, r, ll};
}

// The M step for one item: a logistic regression of the proportions r_iq / f_q on the
// nodes t_q, weighted by f_q (fractional counts). Returns the 2PL's a and b.
export function mStepItem(ri, f, quad) {
  const keep = f.map(v => v > 1e-9);
  const t = quad.nodes.filter((_, q) => keep[q]);
  const y = ri.filter((_, q) => keep[q]).map((v, k) => v / f.filter((_, q) => keep[q])[k]);
  const n = f.filter((_, q) => keep[q]);
  const {b0, b1} = logisticFit(t, y, n);
  return {a: b1, b: -b0 / b1};
}

// EM from a start, for a number of cycles. Returns the history: item parameters and
// marginal log likelihood (at the parameters the cycle started from) for each cycle.
export function runEM(pats, quad, cycles, start = null) {
  const I = pats[0].x.length;
  let a = start ? start.a.slice() : Array(I).fill(1), b = start ? start.b.slice() : Array(I).fill(0);
  const hist = [{cycle: 0, a: a.slice(), b: b.slice(), ll: eStep(pats, a, b, quad).ll}];
  for (let c = 1; c <= cycles; c++) {
    const {f, r} = eStep(pats, a, b, quad);
    const upd = r.map(ri => mStepItem(ri, f, quad));
    a = upd.map(u => u.a); b = upd.map(u => u.b);
    hist.push({cycle: c, a: a.slice(), b: b.slice(), ll: eStep(pats, a, b, quad).ll});
  }
  return hist;
}

// Cycles until the marginal log likelihood rises by less than tol in one cycle.
export function cyclesToConverge(pats, quad, tol = 1e-3, maxc = 3000) {
  const I = pats[0].x.length;
  let a = Array(I).fill(1), b = Array(I).fill(0), prev = eStep(pats, a, b, quad).ll;
  for (let c = 1; c <= maxc; c++) {
    const {f, r} = eStep(pats, a, b, quad);
    const upd = r.map(ri => mStepItem(ri, f, quad));
    a = upd.map(u => u.a); b = upd.map(u => u.b);
    const ll = eStep(pats, a, b, quad).ll;
    if (ll - prev < tol) return {cycles: c, a, b, ll};
    prev = ll;
  }
  return {cycles: Infinity, a, b, ll: prev};
}

// Gradient of the fitted objective with respect to each b_i, given r and f:
// d/db_i sum_q [r_iq log P_iq + (f_q - r_iq) log(1 - P_iq)] = -a_i sum_q (r_iq - f_q P_iq).
// With r and f recomputed at the current parameters this is the gradient of the
// marginal log likelihood itself (direct MML); with r and f frozen at the start of the
// cycle it is the gradient EM's M step climbs.
export function gradB(r, f, a, b, quad) {
  return a.map((ai, i) => -ai * quad.nodes.reduce((s, t, q) => s + r[i][q] - f[q] * P2(t, ai, b[i]), 0));
}

// ---- Joint maximum likelihood for the Rasch model ----

// Rasch responses: n respondents with normal(0, 1) abilities, items b. Seeded.
export function simulateRasch(n, b, seed = 7) {
  const g = rng(seed);
  return Array.from({length: n}, () => {
    const t = g.norm();
    return b.map(bi => (g.unif() < logistic(t - bi) ? 1 : 0));
  });
}

// JML: alternate one Newton step for every theta_j (items fixed) and one for every b_i
// (abilities fixed), centring the b's, until the b's stop moving. Respondents with a
// zero or perfect score have no finite theta and are set aside first.
export function jmlRasch(X, maxit = 500, tol = 1e-7) {
  const I = X[0].length;
  const keep = X.filter(x => { const s = x.reduce((u, v) => u + v, 0); return s > 0 && s < I; });
  const rsum = keep.map(x => x.reduce((u, v) => u + v, 0));
  const csum = Array(I).fill(0);
  for (const x of keep) for (let i = 0; i < I; i++) csum[i] += x[i];
  let b = csum.map(s => Math.log((keep.length - s + 0.5) / (s + 0.5)));
  const mb = b.reduce((u, v) => u + v, 0) / I; b = b.map(v => v - mb);
  let th = rsum.map(s => Math.log(s / (I - s)));
  for (let it = 0; it < maxit; it++) {
    th = th.map((t, j) => {
      let e = 0, v = 0;
      for (const bi of b) { const p = logistic(t - bi); e += p; v += p * (1 - p); }
      return t + (rsum[j] - e) / v;
    });
    const e = Array(I).fill(0), v = Array(I).fill(0);
    for (const t of th) for (let i = 0; i < I; i++) { const p = logistic(t - b[i]); e[i] += p; v[i] += p * (1 - p); }
    const step = b.map((_, i) => -(csum[i] - e[i]) / v[i]);
    b = b.map((bi, i) => bi + step[i]);
    const m = b.reduce((u, v) => u + v, 0) / I; b = b.map(v => v - m);
    if (Math.max(...step.map(Math.abs)) < tol) break;
  }
  return {b, kept: keep.length, dropped: X.length - keep.length};
}

// Slope of y on x through the origin (both already centred).
export const slopeThroughOrigin = (x, y) =>
  x.reduce((s, v, i) => s + v * y[i], 0) / x.reduce((s, v) => s + v * v, 0);
