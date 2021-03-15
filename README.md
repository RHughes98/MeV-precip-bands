# MeV-precip-bands
Objective: Identify and predict MeV electron precipitation bands in the Earth's magnetosphere

## A quick tour

### SAMPEX Data
Downloaded and parsed telemetry data collected by the SAMPEX satellite, grouped by '[rate](http://www.srl.caltech.edu/sampex/DataCenter/docs/HILThires.html)' and '[attitude]()' data sets. The former represents SSD4 count rates of protons above ~5MeV and electrons above 1 MeV in 100ms time intervals, while the latter represents chronological, orbital, and environmental data collected by SAMPEX. 
[Data](http://www.srl.caltech.edu/sampex/DataCenter/data.html) courtesy of CalTech Space Physics Data Center (SPDF).

### MATLAB
The MATLAB functionality of this repository is concentrated in `dataProcessingScript.m`, with several helper functions to complement.

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

#### `mergedCritBands.m`
This helper function is yet another band-identification function, utilizing a logical `AND` operator to 'merge' criteria into one comprehensive logical array (1 for both criteria met, 0 for none/not all criteria met). This approach was taken to avoid relying on the 'starts' and 'ends' of potential bands for identification.

#### `percentCheck.m`
This helper function takes in a vector of logical criteria values and a minimum percentage (from 0 to 1.0 or 0 to 100), and returns whether or not that minimum percentage of criteria values are True.

#### `getPBInput.m`
This function handles user input, which is taken to check whether a certain precipitation band identification algorithm was effective in its analysis. User input must be Y/y or N/n. `getPBInput.m` is primarily invoked by `quickPlotCheck.m` and `curveFitting.m`.

#### `band_dummy.m`
Inactive - used to test reliability of an updated precipitation band identification algorithm (using given criteria). 

#### `combine_daily_data.m`
Inactive - used in pre-processing to combine state and attitude data into a more agreeable format for analysis.

#### Data structs
There are 4 major data struct variables in `dataProcessingScript.m` geared to its primary purposes. These are `VA` for Van Allen belt identification, `MB` for microbursts, and `PB` for precipitation bands. The final major data struct in `dataProcessingScript.m` is `PB2`, which was originally purposed for experimental methods to find precipitation bands - but Ryan probably needs to rename that variable.

However, there are also some peripheral data structs. These include structs containing rate and attitude data (both pre- and post-processing): `rate_raw`, `rate`, `att_raw`, and `att`. 

### Criteria

Numerous criteria have been tested to automate the identification of precipitation bands. These started with the original criteria as outlined in the [paper](https://github.com/RHughes98/MeV-precip-bands/blob/main/Blumetal2015_SAMPEXprecipHSSs.pdf) preceding this project:

1) <img src="https://render.githubusercontent.com/render/math?math=N_{100} > 4 \times B_{20}"> <img src="https://render.githubusercontent.com/render/math?math=\text{ for }"> <img src="https://render.githubusercontent.com/render/math?math=5 \text{s}">
2) <img src="https://render.githubusercontent.com/render/math?math=CC_{10}(N_{100},B_{20}) < .955">

    where <img src="https://render.githubusercontent.com/render/math?math=N_{100}"> is the 100-millisecond count rate, <img src="https://render.githubusercontent.com/render/math?math=B_{20}"> is the 10% baseline count rate over a moving 20-second window, and <img src="https://render.githubusercontent.com/render/math?math=CC_{10}(N_{100},B_{20})"> is the 10-second correlation coefficient between the two.
  
#### Criteria 1

Below is a list of criteria types used as the `crit1` parameter, in their general forms:

1) Count to baseline: <img src="https://render.githubusercontent.com/render/math?math=N_{100} > a \times B_{\%}">
2) Average to baseline: <img src="https://render.githubusercontent.com/render/math?math=A_{t} > a \times B_{\%}">
3) Average to longer-window average: <img src="https://render.githubusercontent.com/render/math?math=A_{t} > a \times A_{T}">
4) Average to standard deviation: <img src="https://render.githubusercontent.com/render/math?math=A_{t} > a \times \sigma_{t}">
5) Curve-fitting: <img src="https://render.githubusercontent.com/render/math?math=A_{t} > a \times N_{\text{Gauss}}">

#### Current criteria

The criteria currently being used (in between tests) to identify precipitation bands
