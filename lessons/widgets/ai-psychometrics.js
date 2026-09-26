// Widget helpers for the lesson "AI and psychometrics". Pure functions only; colours
// and the seeded rng come from irt.js. Import with:
//   import {scoringWorld, worthInRespondents, simulatedRespondents, optionCurves} from "./widgets/ai-psychometrics.js"
import {rng, logistic, cor} from "./irt.js";

// Agreement between two sets of scores on 1..K: the K x K table of counts, exact
// agreement, Cohen's kappa and quadratic weighted kappa (QWK). With weights
// w_ij = (i - j)^2, QWK = 1 - sum(w * observed) / sum(w * expected), the expected
// counts coming from the two margins as if the raters were independent (Cohen, 1968).
export function agreement(x, y, K = 4) {
  const n = x.length;
  const tab = Array.from({length: K}, () => Array(K).fill(0));
  x.forEach((xi, j) => { tab[xi - 1][y[j] - 1] += 1; });
  const row = tab.map(r => r.reduce((a, b) => a + b, 0));
  const col = tab[0].map((_, c) => tab.reduce((a, r) => a + r[c], 0));
  let po = 0, pe = 0, wo = 0, we = 0;
  for (let i = 0; i < K; i++) for (let k = 0; k < K; k++) {
    const e = row[i] * col[k] / n, w = (i - k) ** 2;
    if (i === k) { po += tab[i][k]; pe += e; }
    wo += w * tab[i][k]; we += w * e;
  }
  po /= n; pe /= n;
  return {table: tab, exact: po, kappa: (po - pe) / (1 - pe), qwk: 1 - wo / we,
          meanX: x.reduce((a, b) => a + b, 0) / n, meanY: y.reduce((a, b) => a + b, 0) / n};
}

// Cut a continuous score into 1..4 at fixed thresholds.
const cut4 = (v) => (v < -0.8 ? 1 : v < 0.2 ? 2 : v < 1.2 ? 3 : 4);

// A scoring session. n essays have a true quality T ~ N(0, 1). Two human raters score
// T plus their own noise (SD humanNoise); an engine scores compress * T + shift plus
// noise (SD machineNoise). Each is cut to a 1-4 scale at the same thresholds.
// Returns the agreement of human 1 with human 2, and of human 1 with the engine.
export function scoringWorld({seed = 7, n = 500, humanNoise = 0.55, machineNoise = 0.4,
                              shift = 0, compress = 1} = {}) {
  const r = rng(seed);
  const T = Array.from({length: n}, () => r.norm());
  const e1 = T.map(() => r.norm()), e2 = T.map(() => r.norm()), em = T.map(() => r.norm());
  const h1 = T.map((t, j) => cut4(t + humanNoise * e1[j]));
  const h2 = T.map((t, j) => cut4(t + humanNoise * e2[j]));
  const m = T.map((t, j) => cut4(compress * t + shift + machineNoise * em[j]));
  return {human: agreement(h1, h2), machine: agreement(h1, m)};
}

// Expected p(1 - p) for an item of difficulty b answered by respondents with
// theta ~ N(mu, sd): the Fisher information about b that one respondent carries,
// under the Rasch model. Simple quadrature over theta.
export function expectedPQ(b, mu = 0, sd = 1) {
  let s = 0, w = 0;
  for (let z = -5; z <= 5; z += 0.05) {
    const d = Math.exp(-z * z / 2), p = logistic(mu + sd * z - b);
    s += d * p * (1 - p); w += d;
  }
  return s / w;
}

// What a difficulty prediction is worth. A calibration on n respondents estimates b
// with a standard error of about 1 / sqrt(n * E[p(1 - p)]); a prediction whose errors
// have SD sigma is as precise as a calibration on n* = 1 / (sigma^2 * E[p(1 - p)]).
// sigma comes from the correlation r between predicted and true difficulty and the
// SD of the true difficulties, sigma = sdB * sqrt(1 - r^2), unless it is given directly.
export function worthInRespondents({r = 0.77, sdB = 0.92, b = 0, sdTheta = 1, sigma = null} = {}) {
  if (sigma === null) sigma = sdB * Math.sqrt(1 - r * r);
  const pq = expectedPQ(b, 0, sdTheta);
  const nStar = sigma > 0 ? 1 / (sigma * sigma * pq) : Infinity;
  const curve = [];
  for (let n = 5; n <= 1000; n = Math.round(n * 1.08) + 1) curve.push({n, se: 1 / Math.sqrt(n * pq)});
  return {sigma, pq, nStar, curve};
}

// Simulated respondents. nItems items have true difficulties b ~ N(0, 1). A language
// model answers as nSim "students" whose abilities have SD spread (humans: SD 1), and
// it finds each item easier or harder than people do by an item-specific amount with
// SD itemBias (what the model knows is not what students know). Difficulties are
// read from the simulated responses as -logit(proportion correct), rescaled to the
// true difficulties' mean and SD. Returns the items and the correlation with the truth.
export function simulatedRespondents({seed = 11, nItems = 30, nSim = 200, spread = 0.4,
                                      itemBias = 0.5} = {}) {
  const r = rng(seed);
  const b = Array.from({length: nItems}, () => r.norm());
  const bias = b.map(() => r.norm());
  const theta = Array.from({length: nSim}, () => spread * r.norm());
  const raw = b.map((bi, i) => {
    let k = 0;
    for (const t of theta) if (r.unif() < logistic(t - (bi + itemBias * bias[i]))) k++;
    const p = (k + 0.5) / (nSim + 1);
    return -Math.log(p / (1 - p));
  });
  const m = (v) => v.reduce((a, c) => a + c, 0) / v.length;
  const sd = (v) => Math.sqrt(v.reduce((a, c) => a + (c - m(v)) ** 2, 0) / (v.length - 1));
  const implied = raw.map(v => m(b) + sd(b) * (v - m(raw)) / (sd(raw) || 1));
  return {items: b.map((bi, i) => ({truth: bi, implied: implied[i]})), r: cor(b, implied),
          rmse: Math.sqrt(m(b.map((bi, i) => (bi - implied[i]) ** 2)))};
}

// Option curves for a four-option item under a nominal-type model: the key's
// log-odds rise with theta (slope keySlope, intercept keyEasy), each distractor's are
// flat at its own "pull". At very low theta the distractors share the choices in
// proportion to exp(pull); a distractor with a low pull is a dead one.
const OPTIONS = ["Key", "Distractor A", "Distractor B", "Distractor C"];
function optionProbs(theta, pulls, keyEasy, keySlope) {
  const e = [Math.exp(keySlope * theta + keyEasy), ...pulls.map(Math.exp)];
  const s = e.reduce((a, b) => a + b, 0);
  return e.map(v => v / s);
}
export function optionCurves(pulls, keyEasy, thetas, keySlope = 1.5) {
  return thetas.flatMap(t => optionProbs(t, pulls, keyEasy, keySlope).map((p, k) => ({theta: t, p, option: OPTIONS[k]})));
}
// The share of a group with theta ~ N(0, 1) choosing each option: what a distractor
// analysis of real data reports.
export function optionShares(pulls, keyEasy, keySlope = 1.5) {
  const tot = [0, 0, 0, 0]; let w = 0;
  for (let z = -5; z <= 5; z += 0.05) {
    const d = Math.exp(-z * z / 2);
    optionProbs(z, pulls, keyEasy, keySlope).forEach((p, k) => { tot[k] += d * p; });
    w += d;
  }
  return tot.map((v, k) => ({option: OPTIONS[k], share: v / w}));
}
