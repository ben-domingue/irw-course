// Widget helpers for the lesson "Nominal response and multiple-choice models". Pure
// functions only; the plotting is in the lesson's OJS cells.
// An item has options k = 0..K-1, each with a slope a[k] and an intercept c[k].

// Bock's nominal response model: P(option k) is proportional to exp(a_k theta + c_k).
// Computed on the log scale for stability.
export function nominalProbs(theta, a, c) {
  const z = a.map((ak, k) => ak * theta + c[k]);
  const m = Math.max(...z);
  const e = z.map(v => Math.exp(v - m));
  const s = e.reduce((u, v) => u + v, 0);
  return e.map(v => v / s);
}

// Information in one nominal item: the variance of the option slopes over the option
// probabilities at theta.
export function nominalInfo(theta, a, c) {
  const p = nominalProbs(theta, a, c);
  const mean = p.reduce((s, pk, k) => s + pk * a[k], 0);
  return p.reduce((s, pk, k) => s + pk * (a[k] - mean) ** 2, 0);
}

// Information in the same item scored 0/1 (key against the rest): (P')^2 / (P (1 - P))
// for the key's probability P, which is P (1 - P) (a_key - mean distractor slope)^2.
export function keyedInfo(theta, a, c, key) {
  const p = nominalProbs(theta, a, c);
  const pk = p[key];
  const rest = 1 - pk;
  if (rest < 1e-12 || pk < 1e-12) return 0;
  const meanD = p.reduce((s, q, k) => (k === key ? s : s + q * a[k]), 0) / rest;
  return pk * rest * (a[key] - meanD) ** 2;
}

// Thissen and Steinberg's multiple-choice model. A latent "don't know" category (index
// 0 of aDK/cDK) with the lowest slope is spread over the observed options in
// proportions d (summing to 1):
//   P(k) = [exp(a_k theta + c_k) + d_k exp(a_DK theta + c_DK)] / sum over all K + 1.
export function mcProbs(theta, a, c, aDK, cDK, d) {
  const z = [aDK * theta + cDK, ...a.map((ak, k) => ak * theta + c[k])];
  const m = Math.max(...z);
  const e = z.map(v => Math.exp(v - m));
  const s = e.reduce((u, v) => u + v, 0);
  return a.map((_, k) => (e[k + 1] + d[k] * e[0]) / s);
}
