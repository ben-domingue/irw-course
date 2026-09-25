// Widget helpers for the lesson "Structural equation modeling with lavaan". Pure
// functions only; the drawing is in the lesson's OJS cells.

// Two correlated latent predictors (variances 1, correlation phi) with true
// standardized paths b1, b2 to a latent outcome. Each is measured by a sum score
// with reliability rel1, rel2, relY. Returns the standardized coefficients of the
// regression of the outcome's sum score on the two predictors' sum scores.
export function observedPaths(b1, b2, phi, rel1, rel2, relY) {
  const explained = b1 * b1 + b2 * b2 + 2 * b1 * b2 * phi;   // var of Y explained by X1, X2
  if (explained >= 1) return null;                            // not a valid population
  // Observed covariances: var(X*) = 1 / rel, cov(X1*, X2*) = phi, cov(X*, Y*) = Phi b.
  const s11 = 1 / rel1, s22 = 1 / rel2, s12 = phi;
  const c1 = b1 + phi * b2, c2 = phi * b1 + b2;
  const det = s11 * s22 - s12 * s12;
  const u1 = (s22 * c1 - s12 * c2) / det, u2 = (s11 * c2 - s12 * c1) / det;
  // Standardize: multiply by sd(X*) / sd(Y*) = sqrt(relY / rel).
  return {b1: u1 * Math.sqrt(relY / rel1), b2: u2 * Math.sqrt(relY / rel2), explained};
}

// Four three-variable path models for X, M, Y fitted by maximum likelihood to a
// correlation matrix. Each recursive model's likelihood factors into one
// regression per variable, so the only misfit is the one independence the model
// asserts: F = -log(1 - rho^2), with rho the (partial) correlation it sets to 0.
export function pathModel(rXM, rMY, rXY, model, n) {
  const det = 1 - rXM * rXM - rMY * rMY - rXY * rXY + 2 * rXM * rMY * rXY;
  if (det <= 0) return null;                                  // not a correlation matrix
  let rho, implied, paths;
  if (model === "collider") {                                 // X -> M <- Y, X and Y independent
    rho = rXY; implied = 0;
    const d = 1 - rXY * rXY;
    paths = {XM: (rXM - rMY * rXY) / d, YM: (rMY - rXM * rXY) / d};
  } else {                                                    // chain, reversed chain, fork
    rho = (rXY - rXM * rMY) / Math.sqrt((1 - rXM * rXM) * (1 - rMY * rMY));
    implied = rXM * rMY;
    paths = {XM: rXM, MY: rMY};
  }
  const F = -Math.log(1 - rho * rho);
  return {chisq: n * F, df: 1, implied, paths};   // lavaan reports N times F
}

// Counting rule for the structural part of a model among four factors whose
// correlations the measurement model already estimates (6 of them). Structural
// parameters: the correlation of the two predictors, each path, and a residual
// covariance. A negative count means not identified; zero or more is necessary,
// not sufficient.
export function structuralDf(nPaths, residCov) {
  return 6 - (1 + nPaths + (residCov ? 1 : 0));
}
