// Widget helpers for the lesson "Measurement invariance". Pure functions only; the
// plotting is in the lesson's OJS cells.

// Regularized lower incomplete gamma P(a, x) (series for x < a + 1, continued
// fraction otherwise; Numerical Recipes, 6.2).
function lnGamma(z) {
  const c = [76.18009172947146, -86.50532032941677, 24.01409824083091,
    -1.231739572450155, 0.1208650973866179e-2, -0.5395239384953e-5];
  let x = z, y = z, tmp = x + 5.5;
  tmp -= (x + 0.5) * Math.log(tmp);
  let ser = 1.000000000190015;
  for (const cj of c) ser += cj / ++y;
  return -tmp + Math.log(2.5066282746310005 * ser / x);
}
function gammaP(a, x) {
  if (x <= 0) return 0;
  if (x < a + 1) {
    let sum = 1 / a, del = sum, ap = a;
    for (let n = 0; n < 500; n++) { ap += 1; del *= x / ap; sum += del; if (Math.abs(del) < Math.abs(sum) * 1e-12) break; }
    return sum * Math.exp(-x + a * Math.log(x) - lnGamma(a));
  }
  let b = x + 1 - a, c = 1e300, d = 1 / b, h = d;
  for (let i = 1; i < 500; i++) {
    const an = -i * (i - a); b += 2;
    d = an * d + b; if (Math.abs(d) < 1e-300) d = 1e-300;
    c = b + an / c; if (Math.abs(c) < 1e-300) c = 1e-300;
    d = 1 / d; const del = d * c; h *= del;
    if (Math.abs(del - 1) < 1e-12) break;
  }
  return 1 - Math.exp(-x + a * Math.log(x) - lnGamma(a)) * h;
}

// Chi-square distribution function, central and noncentral (a Poisson mixture of
// central chi-squares), and the central upper quantile by bisection.
export const pchisq = (x, df) => gammaP(df / 2, x / 2);
export function pchisqNC(x, df, ncp) {
  if (ncp <= 0) return pchisq(x, df);
  const lam = ncp / 2, jmax = Math.ceil(lam + 12 * Math.sqrt(lam) + 60);
  let s = 0;
  for (let j = 0; j <= jmax; j++) s += Math.exp(-lam + j * Math.log(lam) - lnGamma(j + 1)) * pchisq(x, df + 2 * j);
  return s;
}
export function qchisq(p, df) {
  let lo = 0, hi = df + 100 * Math.sqrt(2 * df) + 100;
  for (let i = 0; i < 200; i++) { const mid = (lo + hi) / 2; if (pchisq(mid, df) < p) lo = mid; else hi = mid; }
  return (lo + hi) / 2;
}

// Two groups of n respondents answer k items measuring one factor, every loading
// lam and every unique variance 1 - lam^2 in both groups. Group B's factor mean is
// kappa (group A: 0, both factor variances 1), and item k's intercept is higher by
// delta in group B. With population moments, the scalar model's ML estimate of
// kappa (loadings and unique variances at their true values, which the covariances
// fit exactly) is lam' S^-1 dm / lam' S^-1 lam, where dm is the difference in item
// means and S the common covariance matrix; the minimum of the mean part gives the
// noncentrality of the scalar-versus-metric difference test, (n / 2) * Q, on k - 1 df.
export function scalarStep({k, lam = 0.7, kappa, delta, n, alpha = 0.05}) {
  const psi = 1 - lam * lam;
  const s = k * lam * lam / psi;                 // lam' Psi^-1 lam
  // S^-1 = Psi^-1 - Psi^-1 lam lam' Psi^-1 / (1 + s); all loadings equal.
  const Sinv = (i, j) => (i === j ? 1 / psi : 0) - (lam / psi) * (lam / psi) / (1 + s);
  const dm = Array.from({length: k}, (_, i) => lam * kappa + (i === k - 1 ? delta : 0));
  const lamS = Array.from({length: k}, (_, j) => Array.from({length: k}, (_, i) => lam * Sinv(i, j)).reduce((a, b) => a + b, 0));
  const lSl = lamS.reduce((a, v) => a + v * lam, 0);
  const lSd = lamS.reduce((a, v, i) => a + v * dm[i], 0);
  let dSd = 0;
  for (let i = 0; i < k; i++) for (let j = 0; j < k; j++) dSd += dm[i] * Sinv(i, j) * dm[j];
  const kappaHat = lSd / lSl;
  const Q = Math.max(0, dSd - lSd * lSd / lSl);
  const df = k - 1, crit = qchisq(1 - alpha, df);
  const powerAt = m => 1 - pchisqNC(crit, df, (m / 2) * Q);
  return {kappaHat, kappaPartial: kappa, ncp: (n / 2) * Q, df, crit, power: powerAt(n), powerAt};
}
