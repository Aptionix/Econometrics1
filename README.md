# Replication in R

R implementation of Anna Bindler and Randi Hjalmarsson (2021), **The Impact of
the First Professional Police Forces on Crime**, *Journal of the European
Economic Association*, 19(6), 3063-3103, DOI: 10.1093/jeea/jvab011.

The original Stata script and all supplied data remain unchanged. R reads the
`.dta` files directly; Stata and a Stata licence are not required.

## Start here

1. Install R and, optionally, RStudio. These scripts work on Windows and macOS.
2. Open `Econometrics1.Rproj` in RStudio. This sets the project folder correctly.
3. In the R console, install the required packages once:

   ```r
   source("setup.R")
   ```

4. Run the complete replication:

   ```r
   source("run_replication.R")
   ```

The required packages are `haven`, `dplyr`, `tidyr`, `ggplot2`, and `patchwork`.
Installation needs an internet connection; the replication itself uses only the
supplied local data. R 4.1 or newer is recommended. The initial validation run
used R 4.4.1; every run records exact package versions in `output/r/sessionInfo.txt`.

If using VS Code, open this folder and run the following in its terminal:

```sh
Rscript setup.R
Rscript run_replication.R
```

`Rscript` must be available on the terminal's PATH. In RStudio, use the R-console
instructions instead. Do not paste shell commands into the R console.

## Run one part

The names match the switches at the beginning of the author's `.do` file:

```r
sections <- c("table3", "figure4")
source("run_replication.R")
```

Or run a group:

```r
sections <- "main"       # Main-text figures and tables
source("run_replication.R")

sections <- "appendix"   # Appendix A and B
source("run_replication.R")

sections <- "footnotes"  # Additional specifications described in the text
source("run_replication.R")

sections <- "all"        # Restore the full selection
source("run_replication.R")
```

Equivalent terminal command:

```sh
Rscript run_replication.R table3 figure4
```

Bootstrap sections use the author's `reps = 1000` and `seed = 1234`. To change them
in an interactive session, define `bootstrap_reps` and `bootstrap_seed` before
sourcing the runner. Smaller repetition counts are for development, not the
final replication.

## Files and outputs

| File | Purpose |
| --- | --- |
| `run_replication.R` | Select and run the replication; results stay in `results` in an interactive session |
| `R/data.R` | Read data and construct the monthly, weekly, distance-band, daily, and county samples |
| `R/tables.R` | Descriptive statistics, regressions, equality tests, and bootstrap analyses |
| `R/figures.R` | All supplied figure specifications and combined multipanel figures |
| `R/helpers.R` | Estimation, robust covariance calculations, bootstrap, and file exports |
| `R/validate.R` | Compare main regression results against published table values |
| `tests/check_replication.R` | Numerical regression checks and independent bootstrap verification |

Generated files go to `output/r/`, which is ignored by Git:

- `figures/`: PDF and PNG files, with the original figure/panel numbers.
- `tables/`: CSV files of full regression results and descriptive statistics.
- `models/`: RDS files retaining fitted models, estimation samples, and covariance matrices.
- `data/`: Constructed panels and the numbers used in the figures.
- `checks/paper_comparison.csv`: Published values, reproduced values, and comparison status.
- `checks/completed_modules.csv`: Modules completed in the latest run.
- `sessionInfo.txt`: R and package versions.

Regression CSVs include fixed-effect coefficients as well as the coefficients
of interest. `model` identifies the paper panel/column, for example `robbery_c1`
in Table 3 or `A_c2` in Table 5. Poisson estimates and standard errors are reported
as incidence rate ratios; `log_estimate` and `log_std.error` retain their log-scale
values. Model RDS files can be explored without rerunning the analysis:

```r
table3 <- readRDS("output/r/models/table3.rds")
table3$robbery_c1$tidy
summary(table3$robbery_c1$fit) # Base R summary uses conventional, not robust, SEs
table3$robbery_c1$covariance  # Robust covariance used by this replication
```

## Coverage

All 35 switches in the supplied Stata program have an R counterpart:

| Group | Modules |
| --- | --- |
| Main figures | `figure1`, `figure3`, `figure4`, `figure5` |
| Main tables | `table1` through `table7` |
| Appendix A figures | `figureA1` through `figureA5` |
| Appendix A tables | `tableA1`, `tableA3` through `tableA7` |
| Appendix B figures | `figureB1`, `figureB2` |
| Appendix B tables | `tableB1`, `tableB3` through `tableB7` |
| Text/footnotes | `fn13`, `fn22`, `fn28`, `fn33`, `ref1` |

Figure 2 has no code in the original package and requires external map material,
including proprietary shapefiles. Appendix Tables A2 and B2 are source
transcriptions, not statistical analyses. These limitations are documented in
the original `ab_rh_police_and_crime_jeea_data/readme.pdf`.

The footnote blocks that originally printed instructions now execute the
corresponding alternative specifications: an 8-mile uncertainty radius,
two-year event-study bins, inclusion of the Thames office, per-capita county
outcomes, and exclusion of the later cholera-epidemic months.

## Statistical equivalence and documented differences

- OLS uses Stata's HC1 adjustment, `N / (N - rank)`; county/office-clustered
  models use CR1, `G / (G - 1) * (N - 1) / (N - rank)`, with `G - 1` degrees of freedom.
- Fixed-effect Poisson uses `glm(..., family = poisson())` with unit indicators.
  Its unit-score sandwich has no finite-sample adjustment, matching `xtpqml`;
  inference uses the normal distribution. All-zero units are excluded.
- The crime panels reproduce the author's Cartesian zero filling and area
  definitions. Weekly bins start on Sunday and include week 0, not ISO weeks.
  London event years run September-August, with the author's final bins pooled.
- Figure 3 uses Stata's variance-one Epanechnikov kernel, bandwidth formula,
  type-2 quartiles, and 300-point evaluation grid. Figure 5 uses the supplied
  polygon coordinates, so no GIS download or spatial package is required.
- Bootstrap follows `cgmwildboot`'s **unrestricted**, Rademacher cluster
  bootstrap-t, doubled sign-specific tail probabilities, and percentile
  coefficient intervals. The requested repetition count includes the observed
  sample, following that command. R and Stata use different random-number
  streams, so bootstrap results are not expected to match draw for draw.
  `cgm_equivalent_se` is the command's artificial SE inferred from its p-value,
  using `N - rank` degrees of freedom; it is not an ordinary estimated SE.
- Tables 3, 5, 6, and 7 contain **346 checked coefficients and standard errors**,
  all matching the paper to its three-decimal precision. An additional 173
  sample-size checks include 20 documented differences: the paper prints a
  common N row, but two records (10 February 1830, offices `l` and `u`) have
  missing offence-specific informations/charges. Applicable regressions use
  1,614 rather than 1,616 observations, or 3,230 rather than 3,232. These rows
  remain marked `passed = FALSE, known_difference = TRUE`; they are not imputed.
- Table 5/A6/A7 references to stolen-property variables are resolved using the
  original names; the supplied do-file renames them and then uses the old name.
  The malformed Table B7 switch is executable in R.
- Table B7 column 5 in the do-file assigns a constant instead of an above-median
  acreage indicator. `tableB7` records the resulting baseline-equivalent specification;
  `tableB7_median_split` separately exports the intended median-split trend.
- Event-study annotations are computed from the baseline regressions. This
  corrects the supplied Figure 4 robbery SE annotation (`.129` versus the
  estimated `.219`) and the sign errors in Figure B2 baseline annotations.
- Plot fonts, colours, and layout follow R conventions; these are numerical
  replications, not pixel-identical copies. Tables are analysis-ready CSVs,
  rather than replicas of journal typesetting. Appendix and footnote models
  are runnable, but have not all been checked cell by cell against the paper.

After running the full replication, run:

```r
source("tests/check_replication.R")
```

The runner stops on an unexpected main-table mismatch. The documented
sample-count differences above do not stop execution.

## Method references

- [Stata kernel-density formulas](https://www.stata.com/manuals/rkdensity.pdf)
- [Stata twoway density plotting defaults](https://www.stata.com/manuals/g-2graphtwowaykdensity.pdf)
- [Tim Simcoe's `xtpqml` implementation](https://people.bu.edu/tsimcoe/code/xtpqml.txt)
- [Judson Caskey's `cgmwildboot` source](https://github.com/jacaskey/Stata-code/blob/main/Estimating-Equations/cgmwildboot.ado)
- [Caskey's `cgmreg` source](https://github.com/jacaskey/Stata-code/blob/main/Estimating-Equations/cgmreg.ado)
