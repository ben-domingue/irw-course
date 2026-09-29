// Widget helpers for the lesson "Mixture models: when respondents differ in kind".
// Pure functions only; colours and the seeded rng come from irt.js. Import with:
//   import {patternPosterior, screenGrid, contentFreeScale, categoryUse} from "./widgets/mixture-models.js"
import {rng, logistic, corMatrix, eigenSym} from "./irt.js";

const mean = a => a.reduce((u, v) => u + v, 0) / a.length;
const variance = a => { const m = mean(a); return a.reduce((u, v) => u + (v - m) ** 2, 0) / (a.length - 1); };
const alphaOf = X => {
  const k = X[0].length;
  const iv = Array.from({length: k}, (_, j) => variance(X.map(r => r[j])));
  const tot = X.map(r => r.reduce((u, v) => u + v, 0));
  return (k / (k - 1)) * (1 - iv.reduce((u, v) => u + v, 0) / variance(tot));
};

// Ten balanced items, keyed 0/1 (items 0-4 forward, 5-9 reversed), difficulties b.
// Engaged class: the Rasch model with theta ~ normal(0, 1), integrated on a grid.
// Content-free class: agrees with any item with probability pAgree, so a keyed
// forward item scores 1 with probability pAgree and a keyed reversed item with
// probability 1 - pAgree. Returns each class's likelihood of the pattern and the
// posterior probability of the content-free class, given its share piCF.
export function patternPosterior({x, b, piCF = 0.5, pAgree = 0.8}) {
  let lE = 0;
  const Q = 61;
  let wsum = 0;
  for (let q = 0; q < Q; q++) {
    const t = -5 + 10 * q / (Q - 1), w = Math.exp(-t * t / 2);
    let l = 1;
    for (let i = 0; i < x.length; i++) { const p = logistic(t - b[i]); l *= x[i] ? p : 1 - p; }
    lE += w * l; wsum += w;
  }
  lE /= wsum;
  let lC = 1;
  for (let i = 0; i < x.length; i++) {
    const p = i < 5 ? pAgree : 1 - pAgree;
    lC *= x[i] ? p : 1 - p;
  }
  const post = piCF * lC / (piCF * lC + (1 - piCF) * lE);
  return {lE, lC, post, sum: x.reduce((u, v) => u + v, 0)};
}

// Ten five-point items (1-5), items 0-4 forward and 5-9 reversed, for three kinds of
// respondent beside engaged ones: random answering, one option on every screen
// (a straight line), and engaged but fast. Each kind is `share` of the sample.
// Engaged responses: keyed = cut(0.7 theta + noise) into five categories. Times are
// lognormal, median 4 s per item for engaged respondents and 1.2 s for the others.
// Screens flag the worst 5% of the whole sample (speed: below `timeCut` seconds).
// Returns, for each kind, the share each screen flags.
export function screenGrid({seed = 3, n = 2000, share = 0.05, timeCut = 1.5}) {
  const r = rng(seed), cut5 = z => (z < -1.2 ? 1 : z < -0.4 ? 2 : z < 0.4 ? 3 : z < 1.2 ? 4 : 5);
  const kinds = ["engaged", "random", "straight line", "fast but reading"];
  const rows = [];
  for (let j = 0; j < n; j++) {
    const u = r.unif();
    const kind = u < share ? 1 : u < 2 * share ? 2 : u < 3 * share ? 3 : 0;
    const theta = r.norm();
    let raw;
    if (kind === 1) raw = Array.from({length: 10}, () => 1 + Math.floor(5 * r.unif()));
    else if (kind === 2) { const o = 1 + Math.floor(5 * r.unif()); raw = Array(10).fill(o); }
    else raw = Array.from({length: 10}, (_, i) => {
      const k = cut5(0.7 * theta + 0.71 * r.norm());
      return i < 5 ? k : 6 - k;
    });
    const keyed = raw.map((v, i) => (i < 5 ? v : 6 - v));
    const time = Math.exp(Math.log(kind === 0 ? 4 : 1.2) + 0.35 * r.norm());
    rows.push({kind, raw, keyed, time});
  }
  // Screens
  const sd = rows.map(d => Math.sqrt(variance(d.raw)));
  const half = (k, s) => Math.abs(mean(s.filter((_, i) => i % 2 === 0).map(i => k[i])) - mean(s.filter((_, i) => i % 2 === 1).map(i => k[i])));
  const F = [0, 1, 2, 3, 4], R = [5, 6, 7, 8, 9];
  const eo = rows.map(d => half(d.keyed, F) + half(d.keyed, R));
  // Mahalanobis distance on the keyed responses
  const X = rows.map(d => d.keyed), p = 10;
  const m = Array.from({length: p}, (_, j) => mean(X.map(x => x[j])));
  const S = Array.from({length: p}, (_, a) => Array.from({length: p}, (_, c) =>
    X.reduce((u, x) => u + (x[a] - m[a]) * (x[c] - m[c]), 0) / (n - 1)));
  const Si = invert(S);
  const md = X.map(x => { const d = x.map((v, j) => v - m[j]);
    let s = 0; for (let a = 0; a < p; a++) for (let c = 0; c < p; c++) s += d[a] * Si[a][c] * d[c]; return s; });
  const q = (arr, pr) => { const s = arr.slice().sort((a, b) => a - b); return s[Math.floor(pr * (s.length - 1))]; };
  const sdCut = q(sd, 0.05), eoCut = q(eo, 0.95), mdCut = q(md, 0.95);
  const flags = rows.map((d, j) => ({
    kind: d.kind,
    "Speed": d.time < timeCut,
    "Sameness (SD)": sd[j] <= sdCut,
    "Even–odd": eo[j] >= eoCut,
    "Mahalanobis": md[j] >= mdCut
  }));
  const screens = ["Speed", "Sameness (SD)", "Even–odd", "Mahalanobis"];
  const out = [];
  for (let k = 0; k < 4; k++) {
    const f = flags.filter(d => d.kind === k);
    for (const s of screens) out.push({kind: kinds[k], screen: s, rate: f.length ? mean(f.map(d => (d[s] ? 1 : 0))) : 0, n: f.length});
  }
  return {grid: out, screens, kinds, speedEngaged: mean(flags.filter(d => d.kind === 0).map(d => (d["Speed"] ? 1 : 0)))};
}

// Gauss-Jordan inverse of a small symmetric positive definite matrix.
function invert(A) {
  const n = A.length, M = A.map((r, i) => r.concat(Array.from({length: n}, (_, j) => (i === j ? 1 : 0))));
  for (let c = 0; c < n; c++) {
    let piv = c; for (let r = c + 1; r < n; r++) if (Math.abs(M[r][c]) > Math.abs(M[piv][c])) piv = r;
    [M[c], M[piv]] = [M[piv], M[c]];
    const d = M[c][c]; for (let j = 0; j < 2 * n; j++) M[c][j] /= d;
    for (let r = 0; r < n; r++) if (r !== c) { const f = M[r][c]; for (let j = 0; j < 2 * n; j++) M[r][j] -= f * M[c][j]; }
  }
  return M.map(r => r.slice(n));
}

// A content-free class on a ten-item five-point scale, balanced (five reversed items,
// then keyed) or all forward. Engaged respondents: keyed = cut(0.7 theta + noise).
// The class either gives one option on every item (a straight line, the option drawn
// per respondent) or agrees with everything (4 or 5 on every raw item). Returns alpha
// with and without the class, alpha within the class, the second eigenvalue, and the
// keyed sums by class.
export function contentFreeScale({seed = 9, n = 800, share = 0.15, balanced = true, kind = "straight"}) {
  const r = rng(seed), cut5 = z => (z < -1.2 ? 1 : z < -0.4 ? 2 : z < 0.4 ? 3 : z < 1.2 ? 4 : 5);
  const X = [], cls = [];
  for (let j = 0; j < n; j++) {
    const cf = r.unif() < share, theta = r.norm();
    let raw;
    if (cf) {
      if (kind === "straight") { const o = 1 + Math.floor(5 * r.unif()); raw = Array(10).fill(o); }
      else raw = Array.from({length: 10}, () => (r.unif() < 0.5 ? 4 : 5));
    } else {
      raw = Array.from({length: 10}, (_, i) => {
        const k = cut5(0.7 * theta + 0.71 * r.norm());
        return balanced && i >= 5 ? 6 - k : k;
      });
    }
    X.push(raw.map((v, i) => (balanced && i >= 5 ? 6 - v : v)));
    cls.push(cf);
  }
  const Xc = X.filter((_, j) => cls[j]), Xe = X.filter((_, j) => !cls[j]);
  const sums = X.map((x, j) => ({sum: x.reduce((u, v) => u + v, 0), cls: cls[j] ? "Content-free" : "Engaged"}));
  const safeAlpha = M => (M.length > 2 ? alphaOf(M) : NaN);
  return {
    alphaAll: alphaOf(X), alphaEngaged: alphaOf(Xe), alphaClass: safeAlpha(Xc),
    eig2: eigenSym(corMatrix(X))[1], eig2Engaged: eigenSym(corMatrix(Xe))[1],
    sums, meanClass: mean(Xc.map(x => x.reduce((u, v) => u + v, 0))),
    sdClass: Math.sqrt(variance(Xc.map(x => x.reduce((u, v) => u + v, 0)))),
    nClass: Xc.length
  };
}

// Category use (0-4) under the partial credit model for one item with steps b,
// averaged over theta ~ normal(mu, 1). Returns the five probabilities.
export function categoryUse(b, mu = 0) {
  const Q = 61, out = [0, 0, 0, 0, 0];
  let wsum = 0;
  for (let q = 0; q < Q; q++) {
    const t = mu - 5 + 10 * q / (Q - 1), w = Math.exp(-((t - mu) ** 2) / 2);
    const num = [1]; let s = 0;
    for (let k = 0; k < b.length; k++) { s += t - b[k]; num.push(Math.exp(s)); }
    const tot = num.reduce((u, v) => u + v, 0);
    for (let k = 0; k < 5; k++) out[k] += w * num[k] / tot;
    wsum += w;
  }
  return out.map(v => v / wsum);
}
