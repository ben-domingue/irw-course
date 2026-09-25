// Widget helpers for the lesson "What is an item? Explanatory item response models".
// Pure functions only; colours and the seeded rng come from irt.js. Import with:
//   import {designItems, lltmWorld, formulaFor} from "./widgets/explanatory-irt.js"
import {rng, logistic} from "./irt.js";

// The 24 verbal aggression items as a design: situation (other, self; two of each),
// mode (do, want) and behaviour (curse, scold, shout). Columns of X: intercept,
// scold, shout, self, want (the LLTM of the lesson).
export function designItems() {
  const out = [];
  for (const s of [1, 2, 3, 4]) for (const mode of ["do", "want"]) for (const behav of ["curse", "scold", "shout"]) {
    const situ = s <= 2 ? "other" : "self";
    out.push({name: `S${s}${mode === "do" ? "Do" : "Want"}${behav[0].toUpperCase()}${behav.slice(1)}`, situ, mode, behav,
      x: [1, behav === "scold" ? 1 : 0, behav === "shout" ? 1 : 0, situ === "self" ? 1 : 0, mode === "want" ? 1 : 0]});
  }
  return out;
}

// Least-squares projection of y on the columns of X (normal equations, Gauss-Jordan).
function project(X, y) {
  const k = X[0].length, A = Array.from({length: k}, () => Array(k + 1).fill(0));
  X.forEach((row, i) => { for (let a = 0; a < k; a++) { for (let b = 0; b < k; b++) A[a][b] += row[a] * row[b]; A[a][k] += row[a] * y[i]; } });
  for (let c = 0; c < k; c++) {
    let p = c; for (let r = c + 1; r < k; r++) if (Math.abs(A[r][c]) > Math.abs(A[p][c])) p = r;
    [A[c], A[p]] = [A[p], A[c]];
    for (let r = 0; r < k; r++) if (r !== c) { const f = A[r][c] / A[c][c]; for (let j = c; j <= k; j++) A[r][j] -= f * A[c][j]; }
  }
  const beta = A.map((row, c) => row[k] / row[c]);
  return X.map(row => row.reduce((s, v, j) => s + v * beta[j], 0));
}

// Fisher information about one item's easiness from np respondents with theta ~ N(0, sdTheta):
// np times the average of p(1 - p), by a simple quadrature over theta.
function itemInfo(easy, np, sdTheta) {
  let s = 0, w = 0;
  for (let z = -4; z <= 4; z += 0.1) { const d = Math.exp(-z * z / 2), p = logistic(sdTheta * z + easy); s += d * p * (1 - p); w += d; }
  return np * s / w;
}

// A world in which the LLTM's design effects (eta) hold up to an item residual with
// SD sdResid. Returns each item's true easiness, the design's least-squares prediction,
// the share of easiness variance the design explains, and the approximate expected
// likelihood-ratio statistic for the LLTM against the Rasch model with np respondents:
// df + sum of (residual^2 x information), the mean of its noncentral chi-squared.
export function lltmWorld(sdResid, np, seed = 48, eta = [1.07, -1.06, -2.04, -1.03, 0.67], sdTheta = 1.37) {
  const r = rng(seed), items = designItems();
  const z = items.map(() => r.norm());
  const easy = items.map((it, i) => it.x.reduce((s, v, j) => s + v * eta[j], 0) + sdResid * z[i]);
  const pred = project(items.map(it => it.x), easy);
  const mean = easy.reduce((a, b) => a + b, 0) / easy.length;
  const ssTot = easy.reduce((s, e) => s + (e - mean) ** 2, 0);
  const ssRes = easy.reduce((s, e, i) => s + (e - pred[i]) ** 2, 0);
  const df = items.length - eta.length;
  const lambda = easy.reduce((s, e, i) => s + (e - pred[i]) ** 2 * itemInfo(e, np, sdTheta), 0);
  return {
    items: items.map((it, i) => ({...it, easy: easy[i], pred: pred[i]})),
    r2: 1 - ssRes / ssTot, df, chisq: df + lambda
  };
}

// Upper-tail probability of a chi-squared statistic with even or odd df (series).
export function pchisqUpper(x, df) {
  // Regularized upper incomplete gamma Q(df/2, x/2) by continued fraction / series.
  const a = df / 2, xx = x / 2;
  if (xx <= 0) return 1;
  const lgam = (s) => { const c = [76.18009172947146, -86.50532032941677, 24.01409824083091, -1.231739572450155, 0.1208650973866179e-2, -0.5395239384953e-5];
    let y = s, t = s + 5.5; t -= (s + 0.5) * Math.log(t); let ser = 1.000000000190015; for (const cj of c) ser += cj / ++y; return -t + Math.log(2.5066282746310005 * ser / s); };
  if (xx < a + 1) { let sum = 1 / a, del = sum, ap = a; for (let n = 0; n < 500; n++) { ap += 1; del *= xx / ap; sum += del; if (Math.abs(del) < Math.abs(sum) * 1e-12) break; }
    return 1 - sum * Math.exp(-xx + a * Math.log(xx) - lgam(a)); }
  let b = xx + 1 - a, c = 1e300, d = 1 / b, h = d;
  for (let i = 1; i < 500; i++) { const an = -i * (i - a); b += 2; d = an * d + b; if (Math.abs(d) < 1e-300) d = 1e-300; c = b + an / c; if (Math.abs(c) < 1e-300) c = 1e-300; d = 1 / d; const del = d * c; h *= del; if (Math.abs(del - 1) < 1e-12) break; }
  return Math.exp(-xx + a * Math.log(xx) - lgam(a)) * h;
}

// The glmer formula and parameter count for a choice of terms, on the verbal
// aggression design (24 items, 4 design effects plus an intercept) with one
// respondent covariate. Returns {formula, params, note, columns}.
export function formulaFor({itemEffects, design, residual, personCov}) {
  const terms = [];
  let params = 1, note = "";                  // the SD of theta is always there
  const columns = [];
  if (itemEffects && design) note = "Item effects and design predictors together are not identified: 24 item intercepts already absorb anything that is constant within an item. Drop one.";
  if (itemEffects) { terms.push("0 + item"); params += 24; columns.push("item 1", "item 2", "…", "item 24"); }
  if (design) { terms.push(itemEffects ? "behav + situ + mode" : "1 + behav + situ + mode"); params += itemEffects ? 4 : 5;
    if (!itemEffects) columns.push("intercept"); columns.push("scold", "shout", "self", "want"); }
  if (!itemEffects && !design) { terms.push("1"); params += 1; columns.push("intercept"); }
  if (personCov) { terms.push("anger"); params += 1; columns.push("anger"); }
  terms.push("(1 | id)");
  if (residual) {
    terms.push("(1 | item)"); params += 1;
    if (itemEffects) note = note || "An item residual on top of 24 fixed item effects has nothing left to explain: its variance goes to zero.";
  }
  return {formula: `resp ~ ${terms.join(" + ")}`, params, note, columns};
}
