# MeV-precip-bands
Objective: Identify and predict MeV electron precipitation bands in the Earth's magnetosphere

## A quick tour
The functionality of this repository is concentrated in `dataProcessingScript.m`, with several helper functions to complement.

#### `dataProcessingScript.m`
This is the central script of the program. It reads in, parses, and processes SAMPEX data before finding Van Allen belts, microbursts, and precipitation bands. All active helper functions are invoked from this script.

#### `plotFunc.m`
This is the plotting helper function. It takes in specific data vectors for plotting, and the input parameters can be varied to plot features found via different methods and criteria. The parameter structure is mostly for convenient swapping between criteria to plot for observation.

#### `quickPlotCheck.m`
Used for plotting all identified precipitation bands in order for users to individually identify true and false positives.

#### `curveFitting.m`
This function is used to apply a 2<sup>nd</sup> term Gaussian curve fit to Van Allen belts. They are plotted one-by-one with the curve fit overlaid. This function invokes the `beltBands.m` helper function to find precipitation bands that occurred as the satellite was passing through the Van Allen belts.

#### `PBands.m`
The original precipitation band finder function, this helper function is formatted to find precipitation bands over full days' data sets. `PBands.m` takes in criteria, count rate data, and a target time window for band duration. It returns the start and end indices of precipitation bands, as well as the indices of data points that met the first criteria (for later plotting and analysis, this output is often omitted in `dataProcessingScript.m`).

#### `beltBands.m`
A close relative of `PBands.m`. `beltBands.m` is modified to take in smaller data partitions (that may only have one precipitation band) for band identification. It takes in the same parameters as `PBands.m` and returns start/end indices of identified precipitation bands.

#### `getPBInput.m`
This function handles user input, which is taken to check whether a certain precipitation band identification algorithm was effective in its analysis. User input must be Y/y or N/n. `getPBInput.m` is primarily invoked by `quickPlotCheck.m` and `curveFitting.m`.

#### `band_dummy.m`
Inactive - used to test reliability of an updated precipitation band identification algorithm (using given criteria). 

#### `combine_daily_data.m`
Inactive - used in pre-processing to combine state and attitude data into a more agreeable format for analysis.
## Data structs
There are 3 major data struct variables in `dataProcessingScript.m` geared to its primary purposes. These are `VA` for Van Allen belt identification, `MB` for microbursts, and `PB` for precipitation bands.
