// Widget helpers for the lesson "Rater models: many-facet Rasch and beyond".
// Pure functions only; colours and the seeded rng come from irt.js. Import with:
//   import {rsmProbs, harshRater, ratingDist, hrmSE, drift} from "./widgets/rater-models.js"
import {rng} from "./irt.js";

// Category probabilities (0..K) under the rating scale model with a rater facet:
// the log-odds of k over k - 1 is theta - loc - spread * tau_k, where loc is the
// task difficulty plus the rater's severity and spread stretches the rater's steps
// (spread > 1: a central rater; spread < 1: an extreme one).
export function rsmProbs(theta, loc, taus, spread = 1) {
  let s = 0;
  const eta = [0, ...taus.map(t => (s += theta - loc - spread * t))];
  const m = Math.max(...eta), e = eta.map(v => Math.exp(v - m)), z = e.reduce((u, v) => u + v, 0);
  return e.map(v => v / z);
}

const CLEVER_TAUS = [-2.9, -0.6, 0.8, 2.7];   // roughly the cleverness ratings' steps

function drawCat(p, u) {
  let c = 0;
  for (let k = 0; k < p.length; k++) { c += p[k]; if (u < c) return k; }
  return p.length - 1;
}

// Posterior mode of theta given ratings [{loc, x}], with known steps and a normal
// prior (sd), by Newton's method. The prior keeps all-0 and all-4 patterns finite.
function mapTheta(ratings, taus, sd) {
  let th = 0;
  for (let it = 0; it < 50; it++) {
    let g = -th / (sd * sd), h = -1 / (sd * sd);
    ratings.forEach(({loc, x}) => {
      const p = rsmProbs(th, loc, taus);
      const m = p.reduce((u, v, k) => u + k * v, 0);
      const v2 = p.reduce((u, v, k) => u + k * k * v, 0) - m * m;
      g += x - m; h -= v2;
    });
    const step = g / h;
    th -= step;
    if (Math.abs(step) < 1e-8) break;
  }
  return th;
}

const mean = a => a.reduce((u, v) => u + v, 0) / a.length;
const sdev = a => { const m = mean(a); return Math.sqrt(a.reduce((u, v) => u + (v - m) ** 2, 0) / (a.length - 1)); };
// Mean residual of y on x (least squares) among the flagged points, in SDs of y.
function flaggedGap(x, y, flag) {
  const mx = mean(x), my = mean(y);
  let sxy = 0, sxx = 0;
  x.forEach((v, i) => { sxy += (v - mx) * (y[i] - my); sxx += (v - mx) ** 2; });
  const b1 = sxy / sxx, b0 = my - b1 * mx;
  const res = y.map((v, i) => v - b0 - b1 * x[i]).filter((_, i) => flag[i]);
  return res.length ? mean(res) / sdev(y) : 0;
}

// n respondents, 3 tasks, 5 raters; rater 5 is harsher by `harsh` logits. Each
// respondent draws `per` raters at random. Returns each respondent's true theta,
// raw mean rating (1-5 scale) and the model's estimate (severities known), and how
// far those who drew the harsh rater sit below others with the same theta.
export function harshRater({seed = 150, n = 200, harsh = 1, per = 2}) {
  const r = rng(seed), delta = [-0.2, 0, 0.2], sev = [0, 0, 0, 0, harsh];
  const pts = [];
  for (let j = 0; j < n; j++) {
    const theta = 1.2 * r.norm();
    const order = [0, 1, 2, 3, 4].map(k => ({k, u: r.unif()})).sort((a, b) => a.u - b.u).map(d => d.k);
    const raters = order.slice(0, per);
    const ratings = [];
    raters.forEach(k => delta.forEach(d => {
      const loc = d + sev[k];
      ratings.push({loc, x: drawCat(rsmProbs(theta, loc, CLEVER_TAUS), r.unif())});
    }));
    pts.push({theta, raw: 1 + mean(ratings.map(d => d.x)), est: mapTheta(ratings, CLEVER_TAUS, 1.2),
              drew: raters.includes(4) ? "drew the harsh rater" : "did not"});
  }
  const th = pts.map(d => d.theta), flag = pts.map(d => d.drew !== "did not");
  return {pts, gapRaw: flaggedGap(th, pts.map(d => d.raw), flag),
          gapEst: flaggedGap(th, pts.map(d => d.est), flag), nHarsh: flag.filter(Boolean).length};
}

// Distribution of one rater's ratings (1-5) over a normal population of respondents
// (mean 0, SD 1.2), for a typical rater and for one with the given severity and
// spread, with each distribution's mean and SD.
export function ratingDist({sev = 0, spread = 1}) {
  const nodes = Array.from({length: 81}, (_, i) => -4 + i * 0.1);
  const w = nodes.map(z => Math.exp(-z * z / 2)), wz = w.reduce((u, v) => u + v, 0);
  const dist = (s, sp) => {
    const p = [0, 0, 0, 0, 0];
    nodes.forEach((z, i) => rsmProbs(1.2 * z, s, CLEVER_TAUS, sp).forEach((v, k) => p[k] += v * w[i] / wz));
    const m = p.reduce((u, v, k) => u + (k + 1) * v, 0);
    const sd = Math.sqrt(p.reduce((u, v, k) => u + (k + 1 - m) ** 2 * v, 0));
    return {p, m, sd};
  };
  const typical = dist(0, 1), me = dist(sev, spread);
  const rows = [];
  for (let k = 0; k < 5; k++) {
    rows.push({rating: k + 1, rater: "typical rater", p: typical.p[k]});
    rows.push({rating: k + 1, rater: "this rater", p: me.p[k]});
  }
  return {rows, typical, me};
}

// Standard error of theta at theta = 0 for nItems items, each response rated by R
// raters, in a binary version of the two models. Hierarchical rater model: each
// response has an ideal rating (a Rasch item at difficulty 0), and each rater reports
// it correctly with probability acc. Local independence (many-facet model): the R
// ratings are treated as R separate observations of theta with the same marginal
// probability. Information comes from the exact distribution of the number of raters
// who say 1. Returns rows for R = 1..maxR and the floor set by the ideal ratings.
export function hrmSE({acc = 0.8, nItems = 10, maxR = 20}) {
  const p = 0.5, dp = 0.25, e = 1 - acc;   // P(ideal = 1) and its derivative at theta = 0
  const choose = (n, k) => { let c = 1; for (let i = 1; i <= k; i++) c = c * (n - k + i) / i; return c; };
  const rows = [];
  for (let R = 1; R <= maxR; R++) {
    let infoH = 0;
    for (let k = 0; k <= R; k++) {
      const b1 = choose(R, k) * acc ** k * e ** (R - k), b0 = choose(R, k) * e ** k * acc ** (R - k);
      const P = p * b1 + (1 - p) * b0, dP = dp * (b1 - b0);
      if (P > 0) infoH += dP * dP / P;
    }
    const q = e + (acc - e) * p, dq = (acc - e) * dp;
    const infoL = R * dq * dq / (q * (1 - q));
    rows.push({R, se: 1 / Math.sqrt(nItems * infoH), model: "hierarchical rater model"});
    rows.push({R, se: 1 / Math.sqrt(nItems * infoL), model: "local independence (many-facet)"});
  }
  return {rows, floor: 1 / Math.sqrt(nItems * p * (1 - p))};
}

// nr raters score for `days` days. Each starts at a severity drawn with SD 0.3 and
// moves by its own amount per day: the common drift plus a rater-specific part with
// SD `spread`. Returns one row per rater and day, and the SD across raters by day.
export function drift({seed = 2015, nr = 8, days = 30, common = 0, spread = 0.02}) {
  const r = rng(seed), rows = [], sds = [];
  const start = Array.from({length: nr}, () => 0.3 * r.norm());
  const slope = Array.from({length: nr}, () => common + spread * r.norm());
  for (let t = 1; t <= days; t++) {
    const s = start.map((v, k) => v + slope[k] * (t - 1));
    s.forEach((v, k) => rows.push({day: t, rater: `rater ${k + 1}`, severity: v}));
    sds.push({day: t, sd: sdev(s), mean: mean(s)});
  }
  return {rows, sds};
}
