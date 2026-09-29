// Widget helpers for the missing-responses lesson. Pure functions; plotting happens in
// the lesson's OJS cells. Import with:
//   import {simMissing, posteriorGaps, propensityStudy, classifyGaps} from "./widgets/missing-responses.js"
import {logistic, rng, grid} from "./irt.js";

// Simulate Rasch responses and delete some by one of four mechanisms.
// mech: "MCAR" | "MAR" | "MNAR-theta" | "MNAR-own". share: target share missing.
// Returns {theta, b, X (full 0/1), M (true = missing)}.
export function simMissing(mech, share, n = 2000, k = 12, seed = 11) {
  const r = rng(seed);
  const b = Array.from({length: k}, (_, i) => -2 + 4 * i / (k - 1));
  const theta = Array.from({length: n}, () => r.norm());
  const X = theta.map(t => b.map(bi => (r.unif() < logistic(t - bi) ? 1 : 0)));
  const u = theta.map(() => b.map(() => r.unif()));   // one uniform per cell, shared
  let M;
  if (mech === "MCAR") {
    M = u.map(row => row.map(v => v < share));
  } else if (mech === "MAR") {
    // Stopping rule: the fewer right on the first half, the likelier to stop there.
    const half = Math.floor(k / 2);
    const score = X.map(x => x.slice(0, half).reduce((s, v) => s + v, 0));
    // choose the cut so that about `share` of all cells go missing
    const sorted = [...score].sort((a, c) => a - c);
    const nStop = Math.round(Math.min(1, 2 * share) * n);
    const cut = nStop > 0 ? sorted[nStop - 1] : -1;
    M = X.map((x, j) => x.map((_, i) => i >= half && score[j] <= cut));
  } else if (mech === "MNAR-theta") {
    // skip propensity falls with ability (correlation about -0.7)
    const lo = Math.log(share / (1 - share));
    M = u.map((row, j) => row.map(v => v < logistic(lo - 1.4 * theta[j])));
  } else {
    // skip only items the respondent would get wrong
    const pWrong = X.flat().filter(v => v === 0).length / (n * k);
    const q = Math.min(1, share / pWrong);
    M = u.map((row, j) => row.map((v, i) => X[j][i] === 0 && v < q));
  }
  return {theta, b, X, M};
}

// Posterior for one respondent's theta (Rasch items b known, normal prior), with the
// omitted items scored "wrong" or left "missing". x: 0/1 per item; om: true = omitted.
export function posteriorGaps(x, om, b, how, sd = 1, nodes = grid(-5, 5, 201)) {
  const ll = nodes.map(t => b.reduce((s, bi, i) => {
    if (om[i] && how === "missing") return s;
    const y = om[i] ? 0 : x[i];
    const p = logistic(t - bi);
    return s + (y ? Math.log(p) : Math.log(1 - p));
  }, 0));
  const lp = ll.map((l, q) => l - 0.5 * (nodes[q] / sd) ** 2);
  const m = Math.max(...lp);
  const w = lp.map(v => Math.exp(v - m));
  const tot = w.reduce((s, v) => s + v, 0);
  const post = w.map(v => v / tot);
  const eap = nodes.reduce((s, t, q) => s + t * post[q], 0);
  const psd = Math.sqrt(nodes.reduce((s, t, q) => s + (t - eap) ** 2 * post[q], 0));
  // MLE on the grid: finite only if the counted responses are neither all 1 nor all 0
  const counted = b.map((_, i) => (om[i] && how === "missing") ? null : (om[i] ? 0 : x[i])).filter(v => v !== null);
  const sum = counted.reduce((s, v) => s + v, 0);
  const finite = counted.length > 0 && sum > 0 && sum < counted.length;
  const lmax = Math.max(...ll);
  const mle = finite ? nodes[ll.indexOf(lmax)] : (counted.length === 0 ? NaN : (sum === 0 ? -Infinity : Infinity));
  return {nodes, post, like: ll.map(l => Math.exp(l - lmax)), eap, psd, mle, nCounted: counted.length};
}

// Response-propensity study: theta and xi bivariate normal with correlation rho; each
// item is answered with probability logistic(xi + 1.5) (about a fifth omitted on average)
// and, if answered, correct with the Rasch probability. Scores every respondent three
// ways with the true parameters known: omits wrong, omits missing, and the
// two-dimensional propensity model. Returns the mean error (EAP - theta) for the
// quarter of respondents who omit most, and the RMSE for everyone.
export function propensityStudy(rho, n = 400, k = 16, seed = 5) {
  const r = rng(seed);
  const b = Array.from({length: k}, (_, i) => -2 + 4 * i / (k - 1));
  const g = grid(-4, 4, 33);
  const prior2 = g.map(t => g.map(s => Math.exp(-(t * t - 2 * rho * t * s + s * s) / (2 * (1 - rho * rho)))));
  const people = Array.from({length: n}, () => {
    const z1 = r.norm(), z2 = r.norm();
    const theta = z1, xi = rho * z1 + Math.sqrt(1 - rho * rho) * z2;
    const om = b.map(() => r.unif() >= logistic(xi + 1.5));
    const x = b.map(bi => (r.unif() < logistic(theta - bi) ? 1 : 0));
    return {theta, om, x};
  });
  const pC = g.map(t => b.map(bi => logistic(t - bi)));
  const pA = g.map(s => logistic(s + 1.5));
  const est = people.map(pp => {
    const nOm = pp.om.filter(Boolean).length;
    const lik = (i, how) => g.map((t, q) => b.reduce((acc, _, m) => {
      if (pp.om[m] && how === "missing") return acc;
      const y = pp.om[m] ? 0 : pp.x[m];
      return acc * (y ? pC[q][m] : 1 - pC[q][m]);
    }, 1));
    const eap1 = how => {
      const L = lik(0, how);
      let num = 0, den = 0;
      g.forEach((t, q) => { const w = L[q] * Math.exp(-t * t / 2); num += t * w; den += w; });
      return num / den;
    };
    const Lm = lik(0, "missing");
    let num = 0, den = 0;
    g.forEach((t, q) => g.forEach((s, v) => {
      const w = Lm[q] * prior2[q][v] * pA[v] ** (k - nOm) * (1 - pA[v]) ** nOm;
      num += t * w; den += w;
    }));
    return {theta: pp.theta, nOm, wrong: eap1("wrong"), missing: eap1("missing"), propensity: num / den};
  });
  const sorted = [...est].sort((a, c) => c.nOm - a.nOm);
  const heavy = sorted.slice(0, Math.round(n / 4));
  const ways = ["wrong", "missing", "propensity"];
  const mean = arr => arr.reduce((s, v) => s + v, 0) / arr.length;
  return ways.map(w => ({
    scoring: w === "wrong" ? "Omits scored wrong" : w === "missing" ? "Omits left missing" : "Propensity model",
    heavyError: mean(heavy.map(e => e[w] - e.theta)),
    rmse: Math.sqrt(mean(est.map(e => (e[w] - e.theta) ** 2)))
  }));
}

// Classify the gaps in one respondent's row (true = answered), in presentation order.
// rule: "omit" (every gap omitted), "trailing" (every gap after the last answer not
// reached), "iea" (as trailing, except the first gap of the run is omitted).
export function classifyGaps(ans, rule) {
  const last = ans.lastIndexOf(true);
  return ans.map((a, i) => {
    if (a) return "answered";
    if (rule === "omit") return "omitted";
    if (rule === "trailing") return i > last ? "not reached" : "omitted";
    return i > last + 1 ? "not reached" : "omitted";
  });
}
