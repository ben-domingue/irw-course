// Widget helpers for the lesson "Dimensionality and multidimensional IRT". Pure
// functions only; the plotting is in the lesson's OJS cells. Shared math comes from irt.js.
import {logistic, rng} from "./irt.js";

const logit = p => Math.log(p / (1 - p));

// Probability of a correct response to a two-dimensional item, in slope-difficulty
// form. Compensatory (the multidimensional 2PL): logistic(a1*t1 + a2*t2 - A*b), where
// A = sqrt(a1^2 + a2^2) is the item's multidimensional discrimination and b its
// multidimensional difficulty (Reckase, 1985); mirt's intercept is d = -A*b.
// Partially compensatory (Whitely, 1980): a product of one logistic per dimension,
// logistic(a1*(t1 - b)) * logistic(a2*(t2 - b)), so success needs enough of both.
export function p2d(t1, t2, a1, a2, b, model = "compensatory") {
  return model === "compensatory"
    ? logistic(a1 * t1 + a2 * t2 - Math.hypot(a1, a2) * b)
    : logistic(a1 * (t1 - b)) * logistic(a2 * (t2 - b));
}

// Cells of the response surface on a square grid of (theta1, theta2).
export function surface(a1, a2, b, model, lo = -3, hi = 3, n = 31) {
  const step = (hi - lo) / (n - 1), out = [];
  for (let i = 0; i < n; i++) for (let j = 0; j < n; j++) {
    const t1 = lo + i * step, t2 = lo + j * step;
    out.push({t1, t2, p: p2d(t1, t2, a1, a2, b, model)});
  }
  return out;
}

// Contour lines (probability = level) as points {t1, t2, level}, found by solving for
// theta2 along a grid of theta1 (or for theta1, when theta2 has no slope).
export function contours(a1, a2, b, model, levels = [0.2, 0.5, 0.8], lo = -3, hi = 3, n = 121) {
  const out = [], A = Math.hypot(a1, a2);
  for (const lev of levels) {
    for (let k = 0; k < n; k++) {
      const u = lo + (hi - lo) * k / (n - 1);
      let t1 = u, t2 = NaN;
      if (model === "compensatory") {
        if (a2 > 1e-9) t2 = (logit(lev) + A * b - a1 * u) / a2;
        else if (a1 > 1e-9) { t1 = (logit(lev) + A * b) / a1; t2 = u; }
      } else if (a2 > 1e-9) {
        const p1 = logistic(a1 * (u - b));
        if (lev / p1 < 1) t2 = b + logit(lev / p1) / a2;
      }
      if (Number.isFinite(t1) && Number.isFinite(t2) && t1 >= lo && t1 <= hi && t2 >= lo && t2 <= hi)
        out.push({t1, t2, level: `p = ${lev}`});
    }
  }
  return out;
}

// Reckase's (1985) summaries of a compensatory item: MDISC = length of the slope
// vector, and the direction it points (degrees from the theta1 axis).
export function reckase(a1, a2) {
  return {mdisc: Math.hypot(a1, a2), angle: Math.atan2(a2, a1) * 180 / Math.PI};
}

// A small fixed data set for the rotation widget: six compensatory items and 300
// respondents with uncorrelated abilities, simulated with a seeded generator.
export const rotItems = [
  {a: [1.6, 0.2], d: 0.3}, {a: [1.4, 0.0], d: -0.4}, {a: [1.2, 0.3], d: 0.8},
  {a: [0.2, 1.5], d: -0.2}, {a: [0.0, 1.3], d: 0.5}, {a: [0.3, 1.1], d: -0.7}
];
export function rotData(n = 300, seed = 43) {
  const r = rng(seed);
  const theta = Array.from({length: n}, () => [r.norm(), r.norm()]);
  const x = theta.map(t => rotItems.map(it => r.unif() < logistic(it.a[0] * t[0] + it.a[1] * t[1] + it.d) ? 1 : 0));
  return {theta, x};
}
// Rotate a 2-vector by an angle (degrees): v -> T'v with T the rotation matrix.
export function rot(v, deg) {
  const c = Math.cos(deg * Math.PI / 180), s = Math.sin(deg * Math.PI / 180);
  return [c * v[0] + s * v[1], -s * v[0] + c * v[1]];
}
// Log likelihood of the data with slopes rotated by `deg`, and abilities rotated by
// the same angle (both = true) or left as they were (both = false).
export function rotLoglik(data, deg, both = true) {
  let ll = 0;
  data.theta.forEach((t, j) => {
    const th = both ? rot(t, deg) : t;
    rotItems.forEach((it, i) => {
      const a = rot(it.a, deg), p = logistic(a[0] * th[0] + a[1] * th[1] + it.d);
      ll += data.x[j][i] ? Math.log(p) : Math.log(1 - p);
    });
  });
  return ll;
}

// Testlets: k testlets of m items. Item = lambda * theta + gamma * testlet + error,
// standardized. Returns alpha of the sum score, omega total (theta and testlets both
// counted as signal), omega hierarchical (theta only: the reliability of the sum as a
// measure of theta), and the residual correlation of two items in the same testlet
// once theta is accounted for.
export function testletCoefs(lambda, gamma, k = 4, m = 3) {
  const p = k * m;
  const g = Math.min(gamma, Math.sqrt(Math.max(0, 1 - lambda ** 2 - 1e-6)));
  let total = 0, diag = 0;
  for (let i = 0; i < p; i++) for (let j = 0; j < p; j++) {
    const same = Math.floor(i / m) === Math.floor(j / m);
    const v = i === j ? 1 : lambda ** 2 + (same ? g ** 2 : 0);
    total += v; if (i === j) diag += v;
  }
  const alpha = p / (p - 1) * (1 - diag / total);
  const theta = (p * lambda) ** 2, testlet = k * (m * g) ** 2;
  return {alpha, omegaT: (theta + testlet) / total, omegaH: theta / total,
          q3: g ** 2 / (1 - lambda ** 2), gamma: g};
}
