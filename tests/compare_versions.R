# =============================================================================
# trapDetect version comparison: v0.3.0 vs v1.0.0
# =============================================================================
#
# PURPOSE
# -------
# This script verifies that v1.0.0 is statistically equivalent to v0.3.0 and
# benchmarks the performance gain.
#
# HOW TO USE
# ----------
# Step 1 – install v0.3.0 (master branch) and run:
#     source("tests/compare_versions.R")
#     # A file 'tests/v030_reference.rds' will be written.
#
# Step 2 – install v1.0.0 and run the same script again.
#     The script detects the reference file and runs the comparison.
#
# The comparison checks:
#   1. Output structure is unchanged (names, dimensions, types)
#   2. Mean detection probabilities are statistically equivalent
#      (two-sample t-test on per-replication final detection probs)
#   3. Wall-clock speedup
# =============================================================================

library(trapDetect)
library(terra)

# ---- Shared scenario --------------------------------------------------------

BBOX     <- c(-400, -400, 400, 400)
CELL_RES <- 10
N_REP    <- 50
TIME     <- 10
SET_SEED <- 8472
G0       <- 0.1
LAM      <- 1 / 100

# Corner traps only: individual starts at (0,0) so traps are far away,
# keeping per-step detection low enough to avoid trivial saturation.
SURV_PTS <- data.frame(
  x = c(-350, -350,  350,  350),
  y = c(-350,  350, -350,  350)
)
INIT_DAT <- data.frame(x = 0, y = 0, Fate = 1, Age = 1, sdm = 0.7, dens = 1)

# ---- Version-specific scenario runners (called inside subprocesses) ---------

# v0.3.0 uses the raster package.
# Note: library(matrixStats) is a workaround — the NAMESPACE on master is stale
# and doesn't import rowProds, so it must be on the search path explicitly.
run_v030 <- function(bbox, cell_res, surv_pts, init, n_rep, time, seed, g0, lam) {
  library(raster)
  library(matrixStats)
  sdm    <- raster::raster(xmn = bbox[1], xmx = bbox[3],
                            ymn = bbox[2], ymx = bbox[4],
                            resolution = c(cell_res, cell_res))
  sdm[]  <- 0.7
  set.seed(seed)
  t0 <- proc.time()
  res <- trapDetect::calc_escape_prob(
    init_dat = init, surv_locs = surv_pts, sdm = sdm,
    Time = time, num_replications = n_rep,
    rand.walk = TRUE, step_size_ad = 30, step_size_os = 20,
    offspr_mu = 1, K = 500, PLOT.IT = FALSE, return_all_prob = TRUE,
    g0 = g0, lam = lam
  )
  list(version = as.character(utils::packageVersion("trapDetect")),
       elapsed = (proc.time() - t0)[["elapsed"]],
       probs = res$probs, mean_prob = res$mean_prob)
}

# v1.0.0 uses the terra package
run_v100 <- function(bbox, cell_res, surv_pts, init, n_rep, time, seed, g0, lam) {
  library(terra)
  sdm <- terra::rast(xmin = bbox[1], xmax = bbox[3],
                      ymin = bbox[2], ymax = bbox[4],
                      resolution = cell_res)
  terra::values(sdm) <- 0.7
  set.seed(seed)
  t0 <- proc.time()
  res <- trapDetect::calc_escape_prob(
    init_dat = init, surv_locs = surv_pts, sdm = sdm,
    Time = time, num_replications = n_rep,
    rand.walk = TRUE, step_size_ad = 30, step_size_os = 20,
    offspr_mu = 1, K = 500, PLOT.IT = FALSE, return_all_prob = TRUE,
    g0 = g0, lam = lam, parallel = FALSE
  )
  list(version = as.character(utils::packageVersion("trapDetect")),
       elapsed = (proc.time() - t0)[["elapsed"]],
       probs = res$probs, mean_prob = res$mean_prob)
}

# ---- Run both versions in isolated subprocesses -----------------------------

pkg_path <- tryCatch(
  normalizePath(file.path(dirname(sys.frame(1)$ofile), "..")),
  error = function(e) "."
)
ref_path <- file.path(pkg_path, "tests", "v030_reference.rds")

args <- list(bbox = BBOX, cell_res = CELL_RES, surv_pts = SURV_PTS,
             init = INIT_DAT, n_rep = N_REP, time = TIME, seed = SET_SEED,
             g0 = G0, lam = LAM)

cat("\n=== trapDetect version comparison ===\n\n")

# v0.3.0
cat("Running v0.3.0 (master branch) in isolated subprocess...\n")
ref <- callr::r(
  function(args, run_v030) {
    remotes::install_github("pest-risk-science/trapDetect@master",
                             quiet = TRUE, upgrade = "never")
    do.call(run_v030, args)
  },
  args = list(args = args, run_v030 = run_v030),
  timeout = 600
)
saveRDS(ref, ref_path)
cat(sprintf("  v%s completed in %.1f s\n", ref$version, ref$elapsed))

# v1.0.0
cat("\nRunning v1.0.0 (local) in isolated subprocess...\n")
curr <- callr::r(
  function(pkg_path, args, run_v100) {
    remotes::install_local(pkg_path, quiet = TRUE, upgrade = "never",
                            force = TRUE)
    do.call(run_v100, args)
  },
  args = list(pkg_path = pkg_path, args = args, run_v100 = run_v100),
  timeout = 600
)
cat(sprintf("  v%s completed in %.1f s\n", curr$version, curr$elapsed))

# ---- Report -----------------------------------------------------------------

cat(sprintf(
  "\n=== Comparing v%s (reference) vs v%s (current) ===\n",
  ref$version, curr$version
))

# 1. Structure
cat("\n--- Structure ---\n")
cat(sprintf("  Probs matrix dimensions match : %s  (%s vs %s)\n",
            identical(dim(curr$probs), dim(ref$probs)),
            paste(dim(ref$probs), collapse = "x"),
            paste(dim(curr$probs), collapse = "x")))
cat(sprintf("  mean_prob length match         : %s\n",
            length(curr$mean_prob) == length(ref$mean_prob)))

# 2. Statistical equivalence
cat("\n--- Statistical equivalence (final time-step detection prob) ---\n")
ref_final  <- ref$probs[, ncol(ref$probs)]
curr_final <- curr$probs[, ncol(curr$probs)]
tt <- t.test(curr_final, ref_final)
cat(sprintf("  v%s mean : %.4f\n", ref$version,  mean(ref_final)))
cat(sprintf("  v%s mean : %.4f\n", curr$version, mean(curr_final)))
cat(sprintf("  t-test p-value : %.4f  %s\n",
            tt$p.value,
            ifelse(tt$p.value > 0.05,
                   "(no significant difference - PASS)",
                   "(significant difference - INVESTIGATE)")))
mad_val <- max(abs(curr$mean_prob - ref$mean_prob))
cat(sprintf("  Max |delta| mean_prob over time : %.4f\n", mad_val))

# 3. Performance
cat("\n--- Performance ---\n")
cat(sprintf("  v%s : %.1f s\n", ref$version,  ref$elapsed))
cat(sprintf("  v%s : %.1f s\n", curr$version, curr$elapsed))
speedup <- ref$elapsed / curr$elapsed
cat(sprintf("  Speedup : %.2fx\n", speedup))

cat("\nDone.\n\n")
