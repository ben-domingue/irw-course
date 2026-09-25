// Widget helpers for the lesson "Many sources of error: generalizability theory".
// Pure functions only; colours and the seeded rng come from irt.js. Import with:
//   import {gCoef, errorParts, twoRaters, icc} from "./widgets/g-theory.js"
import {rng, cor} from "./irt.js";

// Relative and absolute error variances, and the two G coefficients, for a D study
// that averages over nt tasks and nr raters. v = {p, t, r, pt, pr, tr, res}, the
// seven variance components of a persons x tasks x raters design (res is the
// three-way interaction confounded with everything else).
export function gCoef(v, nt, nr) {
  const rel = v.pt / nt + v.pr / nr + v.res / (nt * nr);
  const abs = rel + v.t / nt + v.r / nr + v.tr / (nt * nr);
  return {rel, abs, erho2: v.p / (v.p + rel), phi: v.p / (v.p + abs)};
}

// Each component's contribution to the variance of an average over nt tasks and nr
// raters, labelled by the role it plays: universe score, error for relative
// decisions (which also counts for absolute ones), or error for absolute decisions only.
export function errorParts(v, nt, nr) {
  return [
    {name: "person", value: v.p, role: "universe score"},
    {name: "person × task", value: v.pt / nt, role: "relative and absolute error"},
    {name: "person × rater", value: v.pr / nr, role: "relative and absolute error"},
    {name: "residual", value: v.res / (nt * nr), role: "relative and absolute error"},
    {name: "task", value: v.t / nt, role: "absolute error only"},
    {name: "rater", value: v.r / nr, role: "absolute error only"},
    {name: "task × rater", value: v.tr / (nt * nr), role: "absolute error only"}
  ];
}

// Single-rating intraclass correlations for an n x k matrix of ratings (rows are
// respondents, columns raters), from the two-way ANOVA mean squares (McGraw & Wong,
// 1996): consistency, ICC(C,1), and absolute agreement, ICC(A,1).
export function icc(Y) {
  const n = Y.length, k = Y[0].length;
  const grand = Y.flat().reduce((u, v) => u + v, 0) / (n * k);
  const rowM = Y.map(r => r.reduce((u, v) => u + v, 0) / k);
  const colM = Array.from({length: k}, (_, j) => Y.reduce((u, r) => u + r[j], 0) / n);
  let ssr = 0, ssc = 0, sse = 0;
  rowM.forEach(m => ssr += k * (m - grand) ** 2);
  colM.forEach(m => ssc += n * (m - grand) ** 2);
  Y.forEach((r, i) => r.forEach((y, j) => sse += (y - rowM[i] - colM[j] + grand) ** 2));
  const msr = ssr / (n - 1), msc = ssc / (k - 1), mse = sse / ((n - 1) * (k - 1));
  return {
    consistency: (msr - mse) / (msr + (k - 1) * mse),
    agreement: (msr - mse) / (msr + (k - 1) * mse + k * (msc - mse) / n)
  };
}

// Two raters score the same n respondents. Rater A gives true score + noise; rater B
// gives true score + noise - harshness. Seeded, so only the sliders move the picture.
export function twoRaters({seed = 1, n = 40, harsh = 0, noise = 0.5}) {
  const r = rng(seed), pts = [];
  for (let i = 0; i < n; i++) {
    const t = r.norm(), ea = r.norm(), eb = r.norm();
    pts.push({a: t + noise * ea, b: t + noise * eb - harsh});
  }
  const Y = pts.map(d => [d.a, d.b]);
  return {pts, ...icc(Y), r: cor(pts.map(d => d.a), pts.map(d => d.b)),
          meanGap: pts.reduce((u, d) => u + d.a - d.b, 0) / n};
}
