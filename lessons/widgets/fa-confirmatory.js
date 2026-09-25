// Widget helpers for the lesson "Factor analysis II". Pure functions only; the
// plotting is in the lesson's OJS cells. Shared math comes from irt.js.
import {pnorm, logistic} from "./irt.js";

// Small dense-matrix tools (the widgets use at most 9 x 9).
export const zeros = (n, m = n) => Array.from({length: n}, () => Array(m).fill(0));
export const matmul = (A, B) => A.map(r => B[0].map((_, j) => r.reduce((s, v, k) => s + v * B[k][j], 0)));
export const transpose = A => A[0].map((_, j) => A.map(r => r[j]));

// Inverse and log-determinant of a symmetric positive-definite matrix, by Cholesky.
export function cholesky(A) {
  const n = A.length, L = zeros(n);
  for (let i = 0; i < n; i++) for (let j = 0; j <= i; j++) {
    let s = A[i][j];
    for (let k = 0; k < j; k++) s -= L[i][k] * L[j][k];
    if (i === j) { if (s <= 0) return null; L[i][i] = Math.sqrt(s); } else L[i][j] = s / L[j][j];
  }
  return L;
}
export function invLogdet(A) {
  const n = A.length, L = cholesky(A);
  if (!L) return null;
  const Li = zeros(n);
  for (let i = 0; i < n; i++) {
    Li[i][i] = 1 / L[i][i];
    for (let j = 0; j < i; j++) {
      let s = 0;
      for (let k = j; k < i; k++) s -= L[i][k] * Li[k][j];
      Li[i][j] = s / L[i][i];
    }
  }
  return {inv: matmul(transpose(Li), Li), logdet: 2 * L.reduce((s, r, i) => s + Math.log(r[i]), 0)};
}

// Model-implied covariance matrix: Lambda Phi Lambda' + Theta.
export function implied(Lambda, Phi, Theta) {
  const LP = matmul(Lambda, Phi);
  return matmul(LP, transpose(Lambda)).map((r, i) => r.map((v, j) => v + Theta[i][j]));
}

// Maximum-likelihood fit of a confirmatory factor model to a covariance matrix S.
// `pattern[i][k]` is true where item i loads on factor k (all other loadings are
// fixed at 0); factor variances are fixed at 1, factor correlations are free,
// unique variances are diagonal. Gradient descent on the ML discrepancy
// F = log|Sigma| + tr(S Sigma^-1) - log|S| - p, with backtracking.
export function fitCFA(S, pattern, iters = 3000) {
  const p = S.length, m = pattern[0].length;
  let L = pattern.map(r => r.map(on => (on ? 0.6 : 0)));
  let P = zeros(m).map((r, i) => r.map((_, j) => (i === j ? 1 : 0.3)));
  let psi = Array(p).fill(0.5);
  const Sld = invLogdet(S).logdet;
  const disc = (L, P, psi) => {
    const Sig = implied(L, P, zeros(p).map((r, i) => r.map((_, j) => (i === j ? psi[i] : 0))));
    const il = invLogdet(Sig);
    if (!il || psi.some(v => v <= 1e-4) || P.some((r, i) => r.some((v, j) => i !== j && Math.abs(v) >= 0.999))) return {F: Infinity};
    let tr = 0;
    for (let i = 0; i < p; i++) for (let j = 0; j < p; j++) tr += S[i][j] * il.inv[j][i];
    return {F: il.logdet + tr - Sld - p, Sig, inv: il.inv};
  };
  let cur = disc(L, P, psi), step = 0.2;
  for (let t = 0; t < iters; t++) {
    // G = Sigma^-1 (Sigma - S) Sigma^-1
    const D = cur.Sig.map((r, i) => r.map((v, j) => v - S[i][j]));
    const G = matmul(matmul(cur.inv, D), cur.inv);
    const GLP = matmul(matmul(G, L), P);
    const gL = GLP.map((r, i) => r.map((v, k) => (pattern[i][k] ? 2 * v : 0)));
    const LGL = matmul(matmul(transpose(L), G), L);
    const gP = LGL.map((r, i) => r.map((v, j) => (i === j ? 0 : 2 * v)));
    const gpsi = G.map((r, i) => r[i]);
    const gnorm = Math.sqrt([...gL.flat(), ...gP.flat(), ...gpsi].reduce((s, v) => s + v * v, 0));
    if (gnorm < 1e-7) break;
    let next;
    for (let h = 0; h < 30; h++) {
      const L2 = L.map((r, i) => r.map((v, k) => v - step * gL[i][k]));
      const P2 = P.map((r, i) => r.map((v, j) => (i === j ? 1 : v - step * gP[i][j] / 2)));
      const psi2 = psi.map((v, i) => v - step * gpsi[i]);
      next = disc(L2, P2, psi2);
      if (next.F < cur.F) { L = L2; P = P2; psi = psi2; break; }
      step /= 2;
    }
    if (!(next.F < Infinity) || next.F >= cur.F - 1e-14) { cur = disc(L, P, psi); if (step < 1e-10) break; continue; }
    cur = next; step *= 1.5;
  }
  return {Lambda: L, Phi: P, psi, Sigma: cur.Sig, F: cur.F};
}

// Fit indices when S is a population matrix, as in the widgets. With misfit F0 per
// respondent, the chi-square is noncentral with expected value df + (N - 1) F0, so
// that is what we report; RMSEA sqrt(F0 / df) and CFI 1 - F0 / F0(baseline) are the
// population values the sample indices estimate, and don't depend on N. `nFree`
// counts the free parameters; the baseline model has only the p variances.
export function fitIndices(S, fit, nFree, N) {
  const p = S.length, df = p * (p + 1) / 2 - nFree;
  const F = Math.max(fit.F, 0);
  const F0 = -invLogdet(S).logdet + S.reduce((s, r, i) => s + Math.log(r[i]), 0);
  let ss = 0, n = 0;
  for (let i = 0; i < p; i++) for (let j = 0; j <= i; j++) {
    const r = (S[i][j] - fit.Sigma[i][j]) / Math.sqrt(S[i][i] * S[j][j]);
    ss += r * r; n++;
  }
  return {chisq: df + (N - 1) * F, df, cfi: 1 - F / F0, rmsea: Math.sqrt(F / df), srmr: Math.sqrt(ss / n)};
}

// Omega total, omega hierarchical and alpha for a bifactor structure with
// standardized items: general loadings g[i], specific loadings s[i] on group grp[i].
export function omegas(g, s, grp) {
  const p = g.length, groups = [...new Set(grp)];
  const uniq = g.map((v, i) => 1 - v * v - s[i] * s[i]);
  const sumG = g.reduce((a, v) => a + v, 0);
  const specSq = groups.map(k => s.reduce((a, v, i) => a + (grp[i] === k ? v : 0), 0) ** 2);
  const varX = sumG ** 2 + specSq.reduce((a, v) => a + v, 0) + uniq.reduce((a, v) => a + v, 0);
  // Every item has variance 1, so alpha = p/(p-1) * (1 - p/varX).
  return {omegaT: (sumG ** 2 + specSq.reduce((a, v) => a + v, 0)) / varX,
          omegaH: sumG ** 2 / varX,
          alpha: p / (p - 1) * (1 - p / varX)};
}

// A dichotomous item as a cut latent response: y* = lambda * eta + error, var(y*) = 1,
// x = 1 when y* > tau. Pr(x = 1 | eta) is a normal ogive.
export const pOgive = (eta, lambda, tau) => pnorm((lambda * eta - tau) / Math.sqrt(1 - lambda * lambda));

// Its IRT parameters: normal-ogive slope and difficulty, and the logistic 2PL with
// the 1.702 scaling (Camilli, 1994).
export function ogiveToIRT(lambda, tau) {
  const aN = lambda / Math.sqrt(1 - lambda * lambda);
  return {aNormal: aN, a: 1.702 * aN, b: tau / lambda};
}
export const p2plAB = (eta, a, b) => logistic(a * (eta - b));
