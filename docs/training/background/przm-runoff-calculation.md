# PRZM Runoff Calculation

## Purpose and scope

The Pesticide Root Zone Model (PRZM) is a one-dimensional, finite-difference model for simulating water movement and pesticide fate in a soil profile [1, 2]. Its runoff calculation is a **field-scale source calculation**: it estimates the volume of water leaving the lower edge of a conceptual field on each model day, and then determines how much pesticide is exported with that water and with eroded sediment. It is not a routing model for a catchment. A landscape model must therefore provide the receiving location and route the exported load separately.

This page describes the conceptual calculation used in PRZM 5 and the equations that are important when interpreting a runoff result. Exact option names and implementation details vary between PRZM releases and regulatory interfaces. Always check the manual for the executable version used in an assessment.

!!! note "Runoff is not the same as drainage"
    **Runoff** is lateral flow generated when rainfall or irrigation exceeds the soil surface's infiltration and storage capacity. **Drainage** is water that leaves the bottom of the modeled soil profile. The two fluxes have different timing, transport paths, and pesticide concentrations.

## Hydrologic sequence

PRZM advances the soil water balance at a daily time step. For a day $t$, the main inputs and outputs can be represented as:

$$
\Delta S_t = P_t + I_t - Q_t - D_t - E_t,
$$

where:

- $\Delta S_t$ is the change in soil-water storage,
- $P_t$ is precipitation,
- $I_t$ is irrigation,
- $Q_t$ is surface runoff,
- $D_t$ is drainage below the profile, and
- $E_t$ is evaporation and plant water use (evapotranspiration).

In the actual model, the profile is divided into finite-difference layers. The water balance is solved for the layers, while runoff is determined at the surface. A useful interpretation of the sequence is:

1. precipitation and irrigation are added to the surface water supply;
2. interception, evaporation, infiltration, and redistribution are evaluated;
3. water that cannot infiltrate or be held in surface storage becomes runoff;
4. the remaining infiltrated water moves through the soil profile, producing drainage and changing soil moisture;
5. pesticide dissolved in runoff water and pesticide associated with detached sediment are exported from the field.

The daily timestep means that a storm's sub-daily peak intensity is not normally represented as an explicit hydrograph. Storm intensity can nevertheless influence the result through the rainfall-runoff option and calibrated parameters. Daily runoff output should therefore be interpreted as a daily export volume, not as a peak discharge.

## SCS Curve Number runoff volume

The standard PRZM runoff formulation is based on the USDA Soil Conservation Service (SCS), now Natural Resources Conservation Service (NRCS), Curve Number method [1, 3]. The method converts event precipitation into direct runoff using a watershed or field Curve Number ($CN$). Define the potential maximum retention after runoff begins as:

$$
S = \frac{25400}{CN} - 254
$$

where $S$ is in millimetres and $CN$ is dimensionless. The associated initial abstraction is commonly written as:

$$
I_a = \lambda S,
$$

where $I_a$ is the water depth intercepted before runoff begins and $\lambda$ is the initial-abstraction ratio. The traditional SCS value is $\lambda = 0.20$. Some modern implementations use a different ratio, so the value actually configured in the PRZM parameterisation must be checked.

For precipitation depth $P$ during an event, direct runoff depth $Q$ is:

$$
Q =
\begin{cases}
0, & P \le I_a,\\[4pt]
\displaystyle\frac{(P-I_a)^2}{P-I_a+S}, & P > I_a.
\end{cases}
$$

The curve number summarises several controls that are important physically but are not solved from first principles by this equation: soil hydrologic group, land cover, treatment, surface condition, and antecedent wetness. A larger $CN$ produces a smaller $S$, a lower threshold for runoff, and more runoff for the same precipitation.

### Example

Suppose $CN=75$, $\lambda=0.20$, and the effective daily precipitation is $P=40\,\mathrm{mm}$. Then:

$$
S = \frac{25400}{75}-254 = 84.67\,\mathrm{mm},
$$

$$
I_a = 0.20 \times 84.67 = 16.93\,\mathrm{mm},
$$

and:

$$
Q = \frac{(40-16.93)^2}{40-16.93+84.67}
  \approx 4.26\,\mathrm{mm}.
$$

For a field area $A$, the corresponding runoff volume is:

$$
V_Q = Q A.
$$

If $Q$ is in millimetres and $A$ is in square metres, $V_Q$ in cubic metres is:

$$
V_Q\,[\mathrm{m^3}] = \frac{Q\,[\mathrm{mm}]\,A\,[\mathrm{m^2}]}{1000}.
$$

For example, one hectare with 4.26 mm of runoff produces approximately $42.6\,\mathrm{m^3}$.

## Antecedent moisture and changing Curve Number

A fixed Curve Number is a simplification. The soil's wetness before the event affects how much rainfall can be retained, so PRZM supports antecedent-moisture adjustments. Conceptually, the model classifies the antecedent condition as dry, average, or wet and converts a reference $CN$ to an adjusted value. The adjusted number is then used in the equations above.

The important consequences are:

- a dry antecedent condition generally lowers $CN$ and increases potential retention;
- a wet antecedent condition generally raises $CN$ and decreases potential retention;
- the same rainfall can therefore generate different runoff on different dates;
- the adjustment is a parameterisation choice, not an independent measurement of saturated hydraulic conductivity.

The three-class SCS adjustment is often expressed using empirical conversions such as:

$$
CN_{II} = \frac{CN_{I}}{2.281 - 0.01281CN_{I}},
$$

$$
CN_{III} = \frac{CN_{II}}{0.427 + 0.00573CN_{II}},
$$

where $CN_{II}$ is the reference, average-moisture number and $CN_I$, $CN_{III}$ are the dry and wet-condition equivalents. These relationships should be treated as the SCS empirical adjustment, not as a universal physical law. PRZM input conventions and the antecedent-moisture calculation should take precedence if they differ.

## Infiltration, surface storage, and runoff generation

The Curve Number equation estimates the event runoff depth. PRZM's soil-water calculation then determines how that water interacts with the surface and profile. Infiltration is limited by the surface boundary condition and by the hydraulic properties of the upper soil layer. Relevant properties include saturated hydraulic conductivity, water content at saturation, field capacity, wilting point, bulk density, layer thickness, and surface storage.

A useful physical upper bound for infiltration during a rainfall period is the Green-Ampt form:

$$
f(t) = K_s\left(1 + \frac{\psi_f\Delta\theta}{F(t)}\right),
$$

where $f(t)$ is infiltration capacity, $K_s$ is saturated hydraulic conductivity, $\psi_f$ is the wetting-front suction head, $\Delta\theta$ is the change in volumetric water content across the wetting front, and $F(t)$ is cumulative infiltration. PRZM's complete implementation is a layered numerical water-balance calculation rather than simply substituting this equation for every day. The equation is useful for understanding why infiltration capacity declines as the wetting front advances and why a wet or low-conductivity surface generates more excess water.

Depression storage delays the start of runoff and can return water to infiltration or evaporation. Once surface water exceeds the available storage and the runoff condition is met, the excess is exported as $Q$. Consequently, changing a Curve Number alone is not equivalent to changing hydraulic conductivity or surface storage: different parameter changes can produce similar runoff totals but different soil-water and pesticide histories.

## From runoff water to pesticide load

Runoff depth is a water quantity. Risk assessment normally needs a pesticide mass or concentration. For a pesticide $i$, a simplified dissolved export calculation is:

$$
M_{i,\mathrm{diss}} = C_{i,\mathrm{runoff}} V_Q,
$$

where $C_{i,\mathrm{runoff}}$ is the pesticide concentration in runoff water and $V_Q$ is the runoff volume. The concentration is not necessarily the average concentration in the soil profile. It depends on the pesticide mass and concentration near the surface at the time runoff occurs, sorption and desorption, degradation, mixing assumptions, and the timing of application relative to rainfall.

PRZM also represents pesticide transport attached to eroded sediment. In general form:

$$
M_{i,\mathrm{sed}} = C_{i,\mathrm{sed}} M_{\mathrm{sed}},
$$

where $C_{i,\mathrm{sed}}$ is the pesticide concentration on transported sediment and $M_{\mathrm{sed}}$ is the mass of sediment exported. The total exported pesticide mass is therefore:

$$
M_{i,\mathrm{total}} = M_{i,\mathrm{diss}} + M_{i,\mathrm{sed}}.
$$

This distinction matters for strongly sorbing compounds. A small dissolved concentration does not imply a small total runoff-associated load if erosion is substantial. Conversely, a large runoff volume does not automatically imply a large pesticide load when the surface soil is uncontaminated or the substance is strongly retained.

## Erosion and sediment-associated transport

Runoff and erosion are related but different outputs. Runoff is the water flux; erosion is the detachment and transport of soil particles. PRZM uses an erosion option based on the Universal Soil Loss Equation family. The event-scale conceptual form is:

$$
E = R K L S C P,
$$

where:

- $E$ is predicted soil loss,
- $R$ is rainfall erosivity,
- $K$ is soil erodibility,
- $L$ and $S$ describe slope length and steepness,
- $C$ is cover and management, and
- $P$ is supporting conservation practice.

The factors and units depend on the particular USLE or MUSLE implementation and PRZM option. Therefore this equation is a process map, not a licence to mix factor tables from different versions. Use the version-specific PRZM manual and input guidance when calculating sediment loads.

## Evaluation: advantages and limitations

### Advantages

The PRZM runoff approach has several important strengths for pesticide fate and regulatory screening:

- **Transparent and reproducible.** The Curve Number equations expose the main runoff assumptions. Given the same weather, area, Curve Number, antecedent condition, and model options, another analyst can reproduce the runoff-depth calculation [1, 3].
- **Efficient for long simulations.** A daily water-balance model is inexpensive enough for multi-year weather series, scenario comparisons, and repeated Monte Carlo runs. This is valuable when pesticide fate must be simulated for many application years.
- **Coupled water and chemical fate.** Runoff is calculated in the same soil-profile model that represents infiltration, storage, degradation, sorption, and transport. Runoff pesticide loads can therefore respond to application timing and surface-soil concentrations rather than being imposed as an independent concentration series [1, 2].
- **Compatible with standard data.** Soil properties, daily weather, crop information, Curve Numbers, and erosion factors are commonly available in regulatory workflows. The approach can be parameterised even when high-resolution rainfall-runoff observations are unavailable.
- **Useful separation of export pathways.** PRZM distinguishes surface runoff from drainage and can represent both dissolved and sediment-associated pesticide export. That distinction is essential for substances whose mobility is controlled by sorption.
- **Good as a source term.** For xOffFieldSoilRisk, PRZM can provide a consistent field-boundary export that a landscape model can route to off-field soils. The separation between source generation and landscape routing is conceptually clean.

### Limitations and risks

The same simplifications that make the method practical can limit its predictive meaning:

- **Curve Number is empirical and aggregated.** A single $CN$ compresses soil, cover, treatment, surface condition, and antecedent wetness into one parameter. It is not a direct measurement of infiltration capacity. Different combinations of soil and management can produce the same $CN$ while responding differently to storm timing and intensity [3].
- **Weak representation of event dynamics.** A daily timestep does not resolve rainfall intensity, sub-daily peak discharge, or the precise time at which runoff begins. Two storms with the same daily total can have different runoff responses in reality. PRZM runoff depth should not be interpreted as a hydrograph or peak flow.
- **Initial abstraction is uncertain.** The traditional $I_a = 0.2S$ assumption is convenient but not universal. Changing the initial-abstraction ratio can substantially change runoff from small and moderate events, especially near the runoff threshold.
- **Antecedent moisture is simplified.** Dry, average, or wet classifications are useful approximations, but they do not fully represent spatially varying soil moisture, preferential flow, macropores, frozen soil, crusting, or rapidly changing surface conditions.
- **One-dimensional field representation.** PRZM represents a conceptual soil column. It does not resolve within-field topography, concentrated flow paths, channel initiation, field-edge accumulation, or lateral redistribution between landscape positions. Those processes must be addressed by the receiving landscape model or by another hydrologic model.
- **Runoff and erosion are not interchangeable.** The runoff water calculation does not by itself predict sediment export. Erosion depends on rainfall erosivity, erodibility, slope, cover, and management factors, and the relevant USLE or MUSLE option must be parameterised consistently [1, 4].
- **Calibration can be non-unique.** A Curve Number, hydraulic conductivity, depression storage, and soil-water parameters can compensate for one another. A good match to total runoff does not prove that the model has the correct event timing or pesticide concentration.
- **Pesticide loads inherit hydrologic uncertainty.** Errors in runoff depth, timing, or surface mixing propagate into dissolved and sediment-associated pesticide loads. A fitted runoff volume can still give a biased chemical export if the surface pesticide mass or sorption assumptions are wrong.
- **No receiving-water or off-field fate by itself.** PRZM estimates export from the modeled field. It does not, on its own, simulate routing across a heterogeneous landscape, deposition in an off-field soil, dilution, connectivity, or exposure at a receptor. Treating the PRZM output as a receptor concentration would be a category error.

### Fitness for purpose

PRZM runoff is well suited to screening, comparative scenario analysis, and generating field-boundary pesticide source terms when the question concerns daily or seasonal export and the input data support a defensible Curve Number and soil profile. It is less suitable when the decision depends on sub-hourly peak flow, detailed channel routing, field-scale spatial patterns, or event-specific calibration.

For xOffFieldSoilRisk, the most defensible use is to propagate uncertainty rather than hide it. Report the Curve Number source, antecedent-moisture method, initial-abstraction ratio, timestep, soil and erosion options, and weather series. Evaluate at least runoff depth, runoff volume, dissolved mass, and sediment-associated mass separately. Sensitivity or scenario analysis over plausible hydrologic parameterisations is more informative than presenting a single unqualified runoff number.

## What controls a PRZM runoff result?

The highest-leverage controls are usually:

- precipitation and irrigation timing and amount;
- reference Curve Number and its antecedent-moisture adjustment;
- initial abstraction ratio and surface/depression storage;
- soil hydraulic properties and layer discretisation;
- crop cover, residue, slope, and erosion parameters;
- application timing, surface interception, sorption, and degradation; and
- the field area used to convert runoff depth to volume.

Sensitivity should be assessed by separating hydrology from chemical fate. First compare $Q$ and $V_Q$ under the same weather and soil conditions. Then compare dissolved and sediment-associated pesticide loads. This prevents a change in pesticide concentration from being misread as a change in runoff generation.

## Interpretation for xOffFieldSoilRisk

When PRZM is used as the runoff source component in a landscape model, the clean interface is:

1. PRZM calculates field runoff water and, where enabled, sediment and pesticide loads.
2. The component exports the daily volume or mass at the field boundary.
3. The landscape model maps that export to receiving off-field soil or another receiving compartment.
4. The receiving model accounts for spatial routing, dilution, deposition, and exposure metrics.

Do not add PRZM's field runoff volume to a receiving compartment as though it were already an off-field concentration. Preserve units and distinguish at least $\mathrm{mm}$ of runoff, $\mathrm{m^3}$ of water, $\mathrm{kg}$ of sediment, and $\mathrm{mg}$ or $\mathrm{g}$ of pesticide.

## Sources

1. Young, D. F. (2015). *PRZM-5, A Model for Predicting Pesticide Fate in the Crop Root Zone: User Manual*. U.S. Environmental Protection Agency. [EPA PRZM documentation archive](https://www.epa.gov/pesticide-science-and-assessing-pesticide-risks/pesticide-root-zone-model-przm).
2. Carsel, R. F., Mulkey, L. A., Lorraine, A. N., and others. (1984). *The Pesticide Root Zone Model (PRZM): A Procedure for Evaluating Pesticide Leaching Threats to Ground Water*. Ecological Modelling, 23, 241-255. [doi:10.1016/0304-3800(84)90034-3](https://doi.org/10.1016/0304-3800(84)90034-3).
3. USDA Natural Resources Conservation Service. (2004). *National Engineering Handbook, Part 630, Hydrology, Chapter 10: Estimation of Direct Runoff from Storm Rainfall*. [NRCS National Engineering Handbook](https://www.nrcs.usda.gov/resources/guides-and-instructions/national-engineering-handbook).
4. Wischmeier, W. H., and Smith, D. D. (1978). *Predicting Rainfall Erosion Losses: A Guide to Conservation Planning*. USDA Agriculture Handbook 537. [USDA National Agricultural Library record](https://www.nrcs.usda.gov/resources/guides-and-instructions/predicting-rainfall-erosion-losses).

The equations on this page are presented for explanation and dimensional checks. For a reproducible assessment, cite the exact PRZM release, input file, weather series, soil profile, Curve Number source, and option settings used to produce the result.
