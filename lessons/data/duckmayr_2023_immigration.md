# duckmayr_2023_immigration (interim local copy)

- **What:** ten immigration-policy statements (IMM_1 to IMM_10), each answered on a five-point scale (0 = strongly disagree to 4 = strongly agree), by 2,621 US respondents to a Lucid survey. Covariates: `cov_ideology` (1 = very liberal to 7 = very conservative; 5 blank), `cov_party_id` (ANES-style 7-point), `cov_age_band`, `cov_gender`. Long format: one row per response, 26,202 rows.
- **Source:** Duck-Mayr, J., & Montgomery, J. (2023). Ends against the middle: Measuring latent traits when opposites respond the same way for antithetical reasons. *Political Analysis*, 31(4), 606–625. <https://doi.org/10.1017/pan.2022.33>. Replication data: <https://doi.org/10.7910/DVN/HXORK9> (Harvard Dataverse, file `lucid_data.tab`).
- **Licence:** CC0 1.0 (the deposit's licence, per the Dataverse API).
- **Built by:** the IRW processing script `data/duckmayr_2023_immigration.R` (ben-domingue/irw PR #2442). The sample is the authors' analysis sample: all three attention checks passed, and the authors' straight-lining rule applied (3,282 → 2,801 → 2,621). No item is reverse-keyed. Identifying fields were dropped; `id` is a new sequential integer.
- **File:** the CSV Ben downloaded from Redivis before the table was public (`duckmayr_2023_immigration.csv`, 26,202 rows), copied here unchanged on 2026-09-25.
- **IRW version:** pending (not yet public on the IRW; no landing page).
- **To do:** switch to the IRW URL when the landing page is live: load it with a version-pinned CSV URL in `code/unfolding-irw.R`, add the table to `tables:` in `lessons.yml`, run `Rscript check_tables.R`, and delete this copy.
