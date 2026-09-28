// Widget helpers for the lesson "Process models for response time".
// Pure functions only; colours and the seeded rng come from irt.js. Import with:
//   import {diffusionTrials, bins, satCurves, diffusionIRT} from "./widgets/rt-process-models.js"
import {rng, logistic, grid} from "./irt.js";

const median = (x) => { if (!x.length) return NaN;
  const s = [...x].sort((a, b) => a - b), n = s.length;
  return n % 2 ? s[(n - 1) / 2] : (s[n / 2 - 1] + s[n / 2]) / 2; };

// One diffusion trial by Euler steps (s = 1): evidence starts at z and moves by
// v * dt plus N(0, dt) noise until it reaches a (correct) or 0 (error). Returns the
// decision time, the response and, if keep is true, the path every 5 steps.
function walk(r, v, a, z, keep = false, dt = 0.002, maxt = 8) {
  let x = z, t = 0, k = 0;
  const sd = Math.sqrt(dt), path = keep ? [{t: 0, x}] : null;
  while (x > 0 && x < a && t < maxt) {
    x += v * dt + sd * r.norm(); t += dt; k++;
    if (keep && k % 5 === 0) path.push({t, x: Math.min(Math.max(x, 0), a)});
  }
  if (keep) path.push({t, x: x >= a ? a : (x <= 0 ? 0 : x)});
  return {t, resp: x >= a ? 1 : 0, path};
}

// n trials from the diffusion model with drift v, boundary separation a, starting point
// zFrac * a, non-decision time ter, across-trial SD of drift eta, and across-trial
// range of the starting point szFrac * a (uniform). Returns the first nPaths paths,
// every trial's rt and response, accuracy and the median correct and error times.
export function diffusionTrials(v, a, zFrac, ter, eta = 0, szFrac = 0, n = 1500, seed = 65, nPaths = 12) {
  const r = rng(seed), rows = [], paths = [];
  for (let i = 0; i < n; i++) {
    const vi = v + eta * r.norm();
    const zi = a * (zFrac + szFrac * (r.unif() - 0.5));
    const w = walk(r, vi, a, zi, i < nPaths);
    rows.push({rt: ter + w.t, resp: w.resp});
    if (i < nPaths) for (const p of w.path) paths.push({trial: i, t: ter + p.t, x: p.x, resp: w.resp});
  }
  const rc = rows.filter(d => d.resp === 1).map(d => d.rt), re = rows.filter(d => d.resp === 0).map(d => d.rt);
  return {rows, paths, acc: rc.length / n, medCorrect: median(rc), medError: median(re), nError: re.length};
}

// Histogram counts on fixed bins, so correct and error responses share an axis.
export function bins(values, lo, hi, nb = 40) {
  const w = (hi - lo) / nb, out = Array.from({length: nb}, (_, k) => ({x1: lo + k * w, x2: lo + (k + 1) * w, count: 0}));
  for (const v of values) { const k = Math.floor((v - lo) / w); if (k >= 0 && k < nb) out[k].count++; }
  return out;
}

// Accuracy and mean decision time with an unbiased start (z = a/2), s = 1:
// P(correct) = logistic(a v), mean decision time = (a / 2v) tanh(a v / 2).
export function diffusionMeans(v, a) {
  const mdt = Math.abs(v) < 1e-6 ? a * a / 4 : (a / (2 * v)) * Math.tanh(a * v / 2);
  return {p: logistic(a * v), mdt};
}

// The speed-accuracy picture: the path traced by changing the boundary at this drift,
// and the path traced by changing the drift at this boundary, plus the current point.
export function satCurves(v, a, ter = 0.3) {
  const byBoundary = grid(0.3, 3, 100).map(aa => { const m = diffusionMeans(v, aa); return {rt: ter + m.mdt, p: m.p, which: "change the boundary"}; });
  const byDrift = grid(0, 4, 100).map(vv => { const m = diffusionMeans(vv, a); return {rt: ter + m.mdt, p: m.p, which: "change the drift"}; });
  const m = diffusionMeans(v, a);
  return {curves: byBoundary.concat(byDrift), point: {rt: ter + m.mdt, p: m.p}};
}

// The diffusion model as an item response model: drift = theta - b. Curves of
// P(correct) and mean decision time against theta for two boundary separations,
// and simulated proportions correct (200 walks at each of 9 abilities) for the first.
export function diffusionIRT(b, a1, a2, seed = 11) {
  const curves = [], r = rng(seed), dots = [];
  for (const [a, lab] of [[a1, `boundary ${a1.toFixed(1)}`], [a2, `boundary ${a2.toFixed(1)}`]])
    for (const th of grid(-3, 3, 121)) {
      const m = diffusionMeans(th - b, a);
      curves.push({theta: th, p: m.p, mdt: m.mdt, curve: lab});
    }
  for (const th of grid(-2.5, 2.5, 9)) {
    let k = 0;
    for (let i = 0; i < 200; i++) k += walk(r, th - b, a1, a1 / 2).resp;
    dots.push({theta: th, p: k / 200});
  }
  return {curves, dots};
}
