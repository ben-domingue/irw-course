// Helpers for the scale-properties widgets. Pure functions; plotting happens in the
// lesson's OJS cells. Shared math (p2pl, rescaleExp, ...) comes from ./irt.js.

// Checks the cancellation conditions of additive conjoint measurement on a table of
// probabilities. P[r][c]: rows are persons in increasing theta, columns are items in
// increasing easiness (hardest first). Returns
//   orderChecks / orderViolations: person-by-item-pair checks, and how many put the
//     harder item ahead (single cancellation for items: every person should order
//     the items the same way);
//   doubleTested / doubleViolations: 3 x 3 submatrices whose double-cancellation
//     premises hold (in either direction), and how many fail the conclusion.
export function cancellation(P) {
  const R = P.length, C = P[0].length, eps = 1e-12;
  let orderChecks = 0, orderViolations = 0, doubleTested = 0, doubleViolations = 0;
  for (let c1 = 0; c1 < C; c1++) for (let c2 = c1 + 1; c2 < C; c2++)
    for (let r = 0; r < R; r++) { orderChecks++; if (P[r][c1] > P[r][c2] + eps) orderViolations++; }
  for (let a = 0; a < R; a++) for (let b = a + 1; b < R; b++) for (let c = b + 1; c < R; c++)
    for (let x = 0; x < C; x++) for (let y = x + 1; y < C; y++) for (let z = y + 1; z < C; z++) {
      if (P[b][x] >= P[a][y] && P[c][y] >= P[b][z]) { doubleTested++; if (P[c][x] < P[a][z] - eps) doubleViolations++; }
      if (P[b][x] <= P[a][y] && P[c][y] <= P[b][z]) { doubleTested++; if (P[c][x] > P[a][z] + eps) doubleViolations++; }
    }
  return {orderChecks, orderViolations, doubleTested, doubleViolations};
}

// Mean and variance of f_k(X) = (exp(kX) - 1)/k for X ~ normal(mu, sd), in closed form
// (X itself at k = 0). exp(kX) is lognormal, so no simulation is needed.
export function rescaledNormal(mu, sd, k) {
  if (k === 0) return {mean: mu, variance: sd * sd};
  const m = Math.exp(k * mu + k * k * sd * sd / 2);
  return {mean: (m - 1) / k, variance: (Math.exp(k * k * sd * sd) - 1) * m * m / (k * k)};
}

// Two groups, each normal with SD 1, tested twice. Returns each group's mean gain on
// the rescaled scale, in units of the SD of the pooled fall scores (also rescaled).
export function rescaledGains(fallLow, gainLow, fallHigh, gainHigh, k) {
  const f = (mu) => rescaledNormal(mu, 1, k);
  const lo1 = f(fallLow), lo3 = f(fallLow + gainLow), hi1 = f(fallHigh), hi3 = f(fallHigh + gainHigh);
  const pooledMean = (lo1.mean + hi1.mean) / 2;
  const pooledVar = (lo1.variance + hi1.variance) / 2 +
    ((lo1.mean - pooledMean) ** 2 + (hi1.mean - pooledMean) ** 2) / 2;
  const sd = Math.sqrt(pooledVar);
  return {low: (lo3.mean - lo1.mean) / sd, high: (hi3.mean - hi1.mean) / sd};
}

// The theta at which a 2PL item's probability equals p (for the ICC widget).
export const thetaAtP = (p, b, a = 1) => b + Math.log(p / (1 - p)) / a;
