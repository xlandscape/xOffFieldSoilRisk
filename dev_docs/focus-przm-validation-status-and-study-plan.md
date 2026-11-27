# FOCUS-surfacewater PRZM: validation status and plan for new field studies

**Prepared:** 27 November 2026  
**Scope:** FOCUS PRZM_SW as a field-edge runoff/erosion source model, and the xOffFieldSoilRisk `RunOffPrzm` component that adds landscape routing and filtering.  
**Status at a glance:** **historically field-evaluated and regulatorily established as a FOCUS source model, but not fully validated as the present xOffField landscape model.**

## Executive summary

PRZM has a credible, documented history in pesticide fate and runoff modelling. The evidence is sufficient to say that:

1. **PRZM is an established regulatory model**, selected for the FOCUS surface-water framework to estimate field-edge runoff and erosion and maintained under FOCUS version control.
2. **PRZM 3.12 showed useful predictive performance in historical field studies.** In a comparison with nine runoff field studies, predicted chemical runoff at the field edge was generally within one order of magnitude of observations when representative input choices were used; agreement was better for larger events and cumulative study-period loads.
3. **The FOCUS scenario framework is maintained and tested as a standardised regulatory system**, but software regression tests and scenario repairs are not the same as independent validation against contemporary field trials.
4. **The exact xOffFieldSoilRisk implementation has not been shown, in the repository, to have been validated against paired field-trial data.** It couples a PRZM-based source term with DEM-based routing, curve-number or VfsMOD filtering, and spatial deposition. That full chain needs its own end-to-end evaluation.

The defensible conclusion is therefore:

> **Use PRZM as a well-supported field-edge source model for scenario comparison, with uncertainty. Do not interpret the present xOffField spatial output as field-validated until the source, routing and filtering chain has been evaluated against independent observations.**

New field trials can close the gap if they are designed as a **locked, hierarchical validation programme** rather than as a calibration exercise. The recommended plan is to preserve an uncalibrated baseline, reserve whole sites or site-seasons for blind evaluation, measure water/sediment/pesticide mass at several points in the pathway, propagate input and measurement uncertainty, and state the intended use of the model before examining the hold-out results.

## 1. What is being validated?

Validation claims must be attached to a specific model and output. Four related levels should not be conflated.

| Level | Model/output | Evidence status | Appropriate claim |
| --- | --- | --- | --- |
| A. Core FOCUS/PRZM source | Daily field-edge runoff and erosion; dissolved and sediment-associated pesticide export | Historical comparisons exist, but for older PRZM releases and selected datasets | Supported as a field-source modelling approach, with material event-scale uncertainty |
| B. FOCUS surface-water scenarios | Standardised scenario inputs and PRZM/MACRO/TOXSWA assessment chain | Established through EU regulatory development, repair actions and version control | Approved and maintained for the intended regulatory workflow |
| C. xOffField PRZM component | `PRZM_Runoff` executable and component input/output contract | Sample runs and implementation history demonstrate integration; no paired field validation was identified in this repository | Technically integrated and smoke-tested; not demonstrated field-accurate |
| D. xOffField landscape output | Routed deposition after flow-grid transfer and optional filtering | No paired spatial field dataset was identified in this repository | Requires end-to-end field validation |

This distinction is essential because:

- PRZM represents a one-dimensional conceptual soil profile, not native two-dimensional overland flow.
- xOffField routing and filtering are additional model components.
- A correct field-edge load does not prove a correct off-field footprint, and a correct runoff volume does not prove a correct pesticide load.

## 2. Evidence supporting FOCUS PRZM_SW

### 2.1 Regulatory development and maintenance

The European Commission/JRC FOCUS site describes PRZM_SW as a one-dimensional finite-difference model combining hydrology and pesticide fate. It uses:

- daily capacity-based water movement;
- the SCS Curve Number approach for runoff;
- a Universal Soil Loss Equation-based erosion approach;
- pesticide transport, sorption, degradation, crop interception, washoff and volatilisation; and
- up to a parent compound and two transformation products in the documented FOCUS lineage.

FOCUS selected PRZM to represent runoff and erosion and combined it with the other models in the FOCUS Step 3 surface-water suite. The FOCUS website is also the definitive source for currently approved models and scenarios, and its Version Control Group publishes notices, test results and release-dependent guidance [1, 2].

This is evidence of **regulatory fitness, standardisation, version control and software maintenance for the intended scenario framework**. It is not, by itself, evidence that every PRZM release predicts each new field study accurately.

### 2.2 Historical field comparison

Singh and Jones compared PRZM 3.12 runoff predictions against measured data from nine field studies [3]. The study reports:

- reasonable estimates of chemical runoff at the field edge;
- predictions generally within a factor of ten of observations when representative, non-conservative input choices were used; and
- better agreement for larger events and cumulative losses than for small individual events.

The JRC model description also states that PRZM 3.12 was used in the FIFRA Environmental Model Validation Task Force comparison of model predictions with runoff and leaching field studies [1].

These results support the model concept, but the scope should not be overstated:

- the comparison concerns PRZM 3.12, not necessarily today's official FOCUS release or the bundled xOffField executables;
- “within a factor of ten” is useful for screening but is not precision validation;
- event-level accuracy, especially for small runoff events, is weaker than cumulative accuracy;
- field-edge runoff is evaluated, not the additional xOffField spatial-routing result;
- input selection is influential, and representative “best” inputs are not a blind prediction from independently available regulatory defaults.

### 2.3 FOCUS scenario repair and current maintenance

The EFSA 2020 FOCUS surface-water repair action introduced a 20-year assessment, a warm-up period, revised application-date rules and multiple process/input updates. It also changed irrigation, crop interception, foliar washoff, temporal percentile interpretation and selected permanent-crop runoff curve numbers [4].

This is important for validation because it shows:

- the system is actively corrected when new data or internal review identifies questionable assumptions;
- a standardised regulatory framework can remain fit for purpose through controlled change;
- evaluation results and acceptance criteria must always name the exact executable, scenario data and option set.

It also means that old field-validation conclusions should be transferred across versions only after a documented version-impact review, not assumed automatically.

## 3. Status of the xOffFieldSoilRisk implementation

The repository shows the following architecture:

1. `RunOffPrzm` prepares weather, application, crop, substance and soil-profile inputs.
2. `PRZM_Runoff` calculates field-scale runoff and pesticide export.
3. `HydroFilter_Runoff` combines field results and routes exposure through the landscape flow grid.
4. Filtering can be represented with the configured curve-number method or VfsMOD lookup tables.

Current repository evidence:

- `RunOffPrzm` component version 2.1.3;
- `PRZM_Runoff` module version 1.47;
- the README and release history document integration changes, input checks and bug fixes;
- sample/testrun outputs show that the component can execute and produce grids;
- the repository contains no paired field observations, validation protocol or reported goodness-of-fit study for the full xOffField pathway.

Therefore, the implementation status is best described as:

| Question | Status |
| --- | --- |
| Can the component create PRZM inputs and run? | Demonstrated in included runs |
| Are input/output units and spatial contracts documented? | Partly/operationally documented |
| Has the field-edge source model been historically evaluated? | Yes, principally for PRZM 3.12 |
| Has the exact PRZM_Runoff 1.47/xOffField wrapper been independently field-evaluated? | Not evidenced in the repository |
| Has landscape routing/filtering and deposition been field-validated end to end? | Not evidenced in the repository |
| Is the model suitable to compare scenarios and identify sensitive assumptions? | Yes, with the model-version and conceptual limitations stated |
| Is it defensible to claim absolute spatial prediction accuracy without new evaluation? | No |

### 3.1 Known version-specific risk

The official PRZM_SW notice board reported on 26 November 2026 that certain incorporated parent applications with metabolites can overestimate metabolite soil residues and downstream runoff/erosion loads (CAM 4, 5 or 6 with a zero-depth metabolite entry), and documented workarounds pending a future release [1].

This notice must be screened for applicability to any executable and input file used in a study. If relevant:

- keep parent and metabolite results separate;
- add a targeted regression case before any broader validation;
- use and document an approved workaround; and
- include the affected input combination in the permanent benchmark suite.

Similarly, the SWASH 5.3 November 2026 notice concerning canopy half-life/washoff transfer is relevant to SWASH-generated regulatory inputs. It may not apply to direct xOffField input generation, but that must be checked rather than assumed [2].

## 4. Main validation gaps

The new studies should prioritise the uncertainties that determine model usefulness.

1. **Transfer across model versions and parameter formats.** Historical PRZM comparisons do not automatically validate `PRZM_Runoff` 1.47 or a later FOCUS build.
2. **Small and high-intensity events.** A daily model and the Curve Number concept can aggregate or miss sub-daily timing and rainfall intensity effects.
3. **Antecedent condition and surface state.** Crusting, residues, frozen ground, interception, macropores and rapidly changing moisture can be poorly captured.
4. **Sediment and sorbed pesticide export.** Runoff, erosion and pesticide concentration are separate endpoints. A total-water fit can hide errors in sediment and strongly sorbing compounds.
5. **Application-to-event interval.** Residue availability on foliage and in the mixing layer controls export and depends on timing.
6. **Landscape routing and transfer.** DEM-derived flow paths, concentrated flow, field-edge heterogeneity and the selected grid resolution require spatial evaluation.
7. **Filtering and mitigation.** Curve-number filtering and VfsMOD-based filtering must be evaluated against measurements, not selected only by availability.
8. **Uncertainty and detection limits.** Small pesticide loads are often censored; naive substitution of zero or half the detection limit can create artificial bias.
9. **Transformation products.** Parents and metabolites can have different sorption, degradation, timing and export paths and need separate validation.
10. **Rare but consequential conditions.** Severe storms, long dry intervals and wet antecedent conditions are usually underrepresented unless deliberately captured.

## 5. Recommended validation-study programme

### 5.1 Intended-use statement

Before data are analysed, define which of the following claims the work should support:

- **S1 — Field-edge source screening:** predict daily/seasonal runoff, sediment and pesticide load from a treated field.
- **S2 — Off-field deposition mapping:** predict the spatial footprint of water and pesticide deposition after routing/filtering.
- **S3 — Mitigation assessment:** predict the relative reduction due to buffers, margins or filtering.
- **S4 — Regulatory-scenario use:** test whether the xOffField configuration reproduces/extends an approved FOCUS assessment.

Passing S1 does not imply S2; passing S2 does not automatically grant regulatory status. The evaluation plan should state the target claim and stop level in advance.

### 5.2 Tier 0: technical and benchmark validation

Complete this before interpreting field trials.

1. Freeze the exact code, executable hashes, input schemas, model options, weather series and geospatial transformations.
2. Archive an immutable copy of every input and output.
3. Test units and mass balance for water, sediment, parent pesticide and each transformation product.
4. Verify that no negative or residual exposure is produced on zero-runoff days/cells where it should be impossible.
5. Run canonical synthetic cases:
   - no rain;
   - rain below/above the runoff threshold;
   - dry versus wet antecedent state;
   - bare versus covered soil;
   - no erosion versus non-zero erosion;
   - soluble versus strongly sorbing substance;
   - no application, soil application and foliar application;
   - filtration enabled and disabled.
6. Establish official or project regression fixtures. Review changes against previous outputs and require justification for any consequential change.
7. Add a CAM 4/5/6 plus metabolite case if the affected implementation applies.

### 5.3 Tier 1: field-edge source evaluation

Use new trials primarily to answer the source-term question.

**Design target**

- at least three contrasting field contexts (soil texture/runoff vulnerability, slope and crop/cover), unless the intended use is narrower;
- preferably at least two seasons per context or an equivalent set of independent site-seasons;
- at least three replicated plots or fields for a core treatment, where practical;
- a retained spread of small, moderate and large runoff events rather than one simulated storm only;
- both natural-rain and controlled-rainfall evidence where possible: natural rain protects external relevance; rainfall simulators help isolate processes;
- representative vulnerable, intermediate and less-vulnerable pesticide mobility/sorption cases;
- untreated or low-exposure controls for analytical/background checks.

A practical portfolio target is **6-10 independent site-season blocks and at least 20 qualifying runoff events**, including several sediment-producing events and different antecedent moisture states. Fewer trials should be labelled a pilot/diagnostic study rather than broad model validation.

**Required measurements**

At a field-edge collection point, measure for each event:

- rainfall intensity and cumulative depth at the site;
- start/end time and continuous or sufficiently frequent runoff hydrograph;
- runoff volume/depth;
- suspended sediment mass and grain-size information where feasible;
- dissolved pesticide concentration/load;
- pesticide mass attached to sediment;
- transformation-product concentration/load;
- detection limits, recovery corrections, duplicates/blanks and analytical uncertainty;
- boundary inflow/outflow and any storage or bypass.

Record co-drivers:

- high-resolution DEM/microtopography, slope and contributing area;
- soil horizons, texture, bulk density, organic carbon/matter, infiltration or saturated conductivity, aggregate stability and initial soil moisture;
- crop stage/BBCH, cover, residue, root distribution and management;
- spray product, formulation, application rate, incorporation method, drift losses and application uniformity;
- surface-soil pesticide residues at application and, where possible, before events;
- evapotranspiration/weather variables at the model's required timestep;
- Curve Number assumptions and source;
- erosion and VfsMOD parameters.

### 5.4 Tier 2: routing, filtering and off-field deposition

Once the field-edge source is measured, add the spatial validation chain.

- Instrument the field outlet and transects through the in-field margin/buffer/off-field area.
- Sample water and sediment at intermediate compartments, not only at a distant receptor.
- Measure buffer width, vegetation density, roughness, soil condition, convergence lines and preferential flow paths.
- Map deposition of water, sediment and pesticide on a grid compatible with the model but independently surveyed.
- Test one factor at a time where possible: routing, source mass and filtering.
- Evaluate both model resolutions/settings used in real assessments.
- Compare:
  - source generation;
  - routed water/particle mass;
  - retained mass;
  - dissolved/sediment-bound fractions; and
  - spatial footprint and hotspot location.

VfsMOD and curve-number filtering should be tested as distinct alternatives. One should not be calibrated into agreement with a dataset and then presented as an independent validator of the same dataset.

### 5.5 Tier 3: transferability and uncertainty

The final programme should establish whether the model transfers to data it has not seen.

- Reserve one or more whole sites, and ideally a full site-season, as a blind hold-out.
- Perform no parameter fitting after hold-out predictions are generated.
- If calibration is required, split each trial into:
  - **development:** process hypotheses and parameter screening;
  - **calibration:** pre-specified adjustable parameters; and
  - **validation:** completely withheld sites/site-seasons.
- Propagate plausible ranges in rainfall, soil, substance, application and measurement data.
- Report posterior or sensitivity-based prediction intervals, not only the best-fit result.
- Perform a grouped sensitivity analysis to distinguish model structure from uncertain inputs.
- Repeat the validation using both available/default input choices and any calibrated choices so transfer dependence is visible.

### 5.6 Data governance

Create a study protocol and data dictionary before simulation:

1. unique event, plot, site and sample identifiers;
2. pre-registered primary endpoints and acceptance criteria;
3. raw and quality-controlled data with clear non-detect coding;
4. measurement units, timezone and coordinate reference system;
5. complete input-to-model conversion history;
6. code/executable hashes and container/configuration information;
7. documented exclusions before analysis;
8. an audit trail for manual interventions; and
9. prediction files generated before the hold-out observations are supplied to model evaluators.

## 6. Evaluation metrics and proposed acceptance gates

### 6.1 Metrics

Report endpoint-specific metrics; do not rely on a single coefficient.

| Endpoint | Primary comparisons | Supporting diagnostics |
| --- | --- | --- |
| Runoff depth/volume | observed-predicted plot; bias/PBIAS; log bias | event occurrence, seasonal total, uncertainty coverage, NSE/RSR if event variability is adequate |
| Sediment mass | event/season load bias; factor-of-agreement | grain-size, zero/non-zero classification, enrichment |
| Dissolved pesticide | log RMSE; median predicted/observed ratio; seasonal mass bias | concentration and volume errors separated |
| Sediment-bound pesticide | log RMSE; mass bias; fraction of total | sediment mass and sorbed-concentration errors separated |
| Total pesticide | factor-of-agreement and cumulative export bias | parent/product, dissolved/sorbed decomposition |
| Routed/off-field deposition | mass retention; uncertainty coverage; spatial overlap/IoU above threshold | footprint length/width, distance to hotspot, grid-resolution sensitivity |

Use:

- prediction/observation ratios on log scale because pesticide loads span orders of magnitude;
- PBIAS and RMSE/MAE alongside time-series or scatter plots;
- event-level occurrence (hit/miss/false-positive) for runoff and pesticide export;
- censored-data methods for values below quantification limits;
- bootstrap confidence intervals clustered by site and event;
- hierarchical analysis where repeated events are nested within fields and sites.

Do not use R² alone, and do not aggregate water, sediment and pesticides into one score.

### 6.2 Proposed gates

These are **project proposal criteria, not official FOCUS or regulatory thresholds**. They should be finalised by the data owners, model developers and intended regulatory/scientific users before hold-out evaluation.

| Gate | Proposed criterion | Consequence |
| --- | --- | --- |
| G0 — technical integrity | Water/pesticide/sediment mass closure within 1% for synthetic cases, after accounting for defined losses; no unexplained negative export; reproducible outputs | Stop field interpretation until corrected |
| G1 — benchmark stability | Key outputs reproduce the frozen version baseline; unexplained differences from the approved fixture are resolved rather than accepted silently | Investigate and version explicitly |
| G2 — event-scale field source | At least 90% of quantifiable hold-out events within a factor of ten; median absolute log10 error no worse than 0.5 (factor 3) for water, sediment and total pesticide endpoints; report false-positive/negative events separately | Pass supports screening use; failure triggers process/input diagnosis |
| G3 — seasonal field source | Absolute cumulative-load PBIAS ≤50% for runoff, sediment and total pesticide on independent site-seasons, unless wider limits are justified in the preregistered protocol | Pass supports comparative seasonal source estimates |
| G4 — pathway | At least 80% of independent measured pathway endpoints fall within the stated 90% prediction interval; model-observation residuals show no systematic bias by soil, slope, sorption or event-size class | Pass supports bounded uncertainty statements |
| G5 — spatial transfer | The model captures the observed off-field mass/retention and hotspot location without site-specific routing calibration; sensitivity to a reasonable flow-grid/DEM change remains within the preregistered decision tolerance | Pass supports spatial deposition use |
| G6 — mitigation | Predicted relative retention effect has the same direction and a credible magnitude as the trial effect, with confidence intervals overlapping the experimentally estimated effect | Pass supports scenario-based mitigation comparison |

If these gates are too stringent for sparse trials, keep the gates and reduce the claim (for example, “diagnostic pilot” rather than “validated”), or set justified wider limits **before** the results are viewed.

## 7. Decision and reporting plan

### 7.1 Analysis sequence

1. **Freeze protocol and model.**
2. Generate Tier 0 synthetic benchmarks and document any failures.
3. Run a pre-observation/default-parameter baseline.
4. Inspect measurement quality without comparing against predictions.
5. Lock and disclose any corrections/exclusions.
6. Generate blind hold-out predictions.
7. Compare outputs using the preregistered endpoints.
8. Diagnose failures without moving observations between split or redefining gates.
9. If calibration is necessary, generate a new versioned parameter set and repeat on a still-unseen test set.
10. Report the intended-use claim that each tier supports.

### 7.2 Failure diagnosis

Classify failures instead of simply retuning the Curve Number:

1. **observation/data error;**
2. **weather/application input error;**
3. **soil or crop parameter uncertainty;**
4. **runoff occurrence/timing failure;**
5. **runoff-volume failure;**
6. **erosion failure;**
7. **dissolved concentration failure;**
8. **sediment-sorbed concentration/fraction failure;**
9. **routing/filtering failure;** or
10. **model-structure incompatibility.**

Only diagnose a pesticide-fate problem after the water and sediment source terms have been checked. Otherwise a hydrological error can be mistaken for a sorption/degradation problem.

### 7.3 Required outputs

The validation package should contain:

- a model/version provenance record and executable hashes;
- a field-trial protocol and data dictionary;
- raw, quality-controlled and analysis-ready datasets;
- all uncalibrated and calibrated prediction files;
- an event ledger linking observed events, samples and model days;
- endpoint-specific tables, residual plots and uncertainty intervals;
- mass-balance and regression benchmark results;
- a list of deviations and excluded data;
- a signed decision matrix for S1-S4; and
- release-specific model limitations and user guidance.

## 8. Recommended workplan

| Phase | Main work | Exit product |
| --- | --- | --- |
| 0. Readiness (2-4 weeks once protocols/data are available) | Define claims, freeze versions, inspect trial data, create data mapping and benchmark suite | Approved protocol, data contract and G0/G1 report |
| 1. Baseline (2-3 weeks) | Uncalibrated simulation using independently sourced/default parameters; event matching and measurement-QA only | Locked baseline predictions |
| 2. Tier 1 evaluation (3-5 weeks) | Field-edge blind analysis, sensitivity and uncertainty, failure classification | S1 validation report |
| 3. Tier 2 evaluation (4-6 weeks) | Routing and filtration chain; spatial footprint and retention | S2/S3 validation report |
| 4. Reproducibility release (2-4 weeks) | Address confirmed implementation defects, rerun affected tiers, archive data/code/report | Versioned validation package and user guidance |

Timelines depend on trial metadata quality, event count and whether model defects need release cycles. Trials that do not include field-edge measurements should be treated as partial integration studies because upstream model error cannot be separated from routing/filtering error.

## 9. Overall recommendation

If only legacy evidence is used:

- state **historical PRZM field validation**;
- state **FOCUS regulatory acceptance/maintenance**; and
- do **not** state that the xOffField landscape output is validated.

If new trial data become available:

1. begin with Tier 0 and a locked protocol;
2. preserve an uncalibrated field-edge baseline;
3. reserve whole sites/site-seasons for blind evaluation;
4. measure source, dissolved/sediment pesticide and the routed/filtering pathway separately;
5. propagate uncertainty and report endpoint-specific error;
6. promote the model only to the claim that the evidence supports.

This approach can move the status from **historically supported field-source model plus technically integrated landscape wrapper** to **independently evaluated xOffField field-to-off-field model**, without making validation dependent on post-hoc tuning.

## References

1. European Commission, Joint Research Centre / European Soil Data Centre. **PRZM_SW: FOCUS Surface Water PRZM model**, including model description, version downloads, test results and notice board. https://esdac.jrc.ec.europa.eu/projects/przmsw (accessed 27 November 2026).
2. European Commission, Joint Research Centre / European Soil Data Centre. **FOCUS DG SANTE**, approved FOCUS scenarios/models, version-control process and workgroup reports. https://esdac.jrc.ec.europa.eu/projects/focus-dg-sante (accessed 27 November 2026).
3. Singh, P. and Jones, R. L. (2002). **Comparison of pesticide root zone model 3.12: runoff predictions with field data.** *Environmental Toxicology and Chemistry*, 21(8), 1545-1551. https://doi.org/10.1002/etc.5620210803.
4. EFSA (2020). **Scientific report of EFSA on the “repair action” of the FOCUS surface water scenarios.** *EFSA Journal*, 18(6), e06119. https://doi.org/10.2903/j.efsa.2020.6119.
5. FOCUS (2001). **FOCUS Surface Water Scenarios in the EU Evaluation Process under 91/414/EEC.** Report of the FOCUS Working Group on Surface Water Scenarios, EC Document Reference SANCO/4802/2001-rev.2.
6. Moriasi, D. N. et al. (2007). **Model Evaluation Guidelines for Systematic Quantification of Accuracy in Watershed Simulations.** *Transactions of the ASABE*, 50(3), 885-900. https://doi.org/10.13031/2013.23153.
7. xOffFieldSoilRisk repository documentation: `model/variant/RunOffPrzm/README.md`, `model/variant/RunOffPrzm/CHANGELOG.md`, `Release 1.4/Changelog.txt`, and the PRZM background/training documents under `docs/training/background/` (repository state on 27 November 2026).

