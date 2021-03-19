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
There are several major data struct variables in `dataProcessingScript.m` geared to its primary purposes. These are listed below:
Struct | Purpose
------- | -------
`rate_raw`,`att_raw` | unprocessed rate and attitude data, respectively
`rate`,`att` | processed rate and attitude data, respectively
`VA` | Van Allen Belt identification, plotting, and processing 
`MB` | microburst identification and plotting
`PB1` | original criteria for precipitation band identification and plotting
`PB2` | experimental criteria for precipitation band identification and plotting
`PB` | currently used criteria for precipitation band identification and plotting

<!--
`VA` for Van Allen belt identification, 
`MB` for microbursts, and 
`PB` for precipitation bands. The final major data struct in `dataProcessingScript.m` is `PB2`, which is purposed for experimental methods to find precipitation bands.
However, there are also some peripheral data structs. These include structs containing rate and attitude data (both pre- and post-processing): `rate_raw`, `rate`, `att_raw`, and `att`. -->

### Data

#### Rate
<!--(year, day, seconds, longitude, latitude, altitude, L-shell, various magnetic field (_B_) magnitudes, MLT, invariant latitude, Loss Cones 1 and 2, South Atlantic Anomaly flag, pitch angle, attitude flag)-->
Name | Description
------ | ------
`year` | 
`day` | 
`sec` |
`long` | 
`lat` | 
`alt` | 
`Lshell` | 
`Bmag` | 
`LC1` | 
`LC2` | 
`eqB` | 
`N100B` | 
`SAA` | 


#### Attitude
<!--(time, count rate)-->
Name | Description
------ | ------
`time` | 
`rate5` | 

### Criteria

Numerous criteria have been tested to automate the identification of precipitation bands. These started with the original criteria as outlined in the [paper](https://github.com/RHughes98/MeV-precip-bands/blob/main/Blumetal2015_SAMPEXprecipHSSs.pdf) preceding this project:

1) <img src="https://render.githubusercontent.com/render/math?math=N_{100} > 4 \times B_{20}"> <img src="https://render.githubusercontent.com/render/math?math=\text{ for }"> <img src="https://render.githubusercontent.com/render/math?math=5 \text{s}">
2) <img src="https://render.githubusercontent.com/render/math?math=CC_{10}(N_{100},B_{20}) < .955">

\* _Nomenclature is listed later in this subsection._

<!--     where <img src="https://render.githubusercontent.com/render/math?math=N_{100}"> is the 100-millisecond count rate, <img src="https://render.githubusercontent.com/render/math?math=B_{20}"> is the 10% baseline count rate over a moving 20-second window, and <img src="https://render.githubusercontent.com/render/math?math=CC_{10}(N_{100},B_{20})"> is the 10-second correlation coefficient between the two. -->
  
#### Criteria 1

Below is a list of criteria types used for the `crit1` parameter, in their general forms:

* Count to baseline: <img src="https://render.githubusercontent.com/render/math?math=N_{100} > a \times B_{p}">
* Average to baseline: <img src="https://render.githubusercontent.com/render/math?math=A_{t} > a \times B_{p}">
* Average to long-window average: <img src="https://render.githubusercontent.com/render/math?math=A_{t} > a \times A_{T}">
* Average to standard deviation: <img src="https://render.githubusercontent.com/render/math?math=A_{t} > a \times \sigma_{t}">
* Curve-fitting: <img src="https://render.githubusercontent.com/render/math?math=A_{t} > a \times N_{\text{Gauss}}">

All of these criteria were required to be true, or mostly true, for a time window of a designated duration - usually 5 seconds.

#### Criteria 2

The criteria used for the `crit2` parameter were mostly based on moving correlation coefficients between some two data arrays:

* Count to baseline: <img src="https://render.githubusercontent.com/render/math?math=CC_t(N_{100},B_p)">
* Average to baseline: <img src="https://render.githubusercontent.com/render/math?math=CC_t(A_t,B_p)">
* Average to long-window average: <img src="https://render.githubusercontent.com/render/math?math=CC_t(A_t,A_T)">
* Count to average: <img src="https://render.githubusercontent.com/render/math?math=CC_t(N_{100},A_T)">
* Average to curve fit: <img src="https://render.githubusercontent.com/render/math?math=CC_t(A_t,N_{\text{Gauss}})">

The correlation coefficient values were restricted to be below a maximum threshold to find where a shorter-term metric, such as a short-window average, diverged from the longer-term metric, such as a long-window average or curve fit. This maximum correlation coefficient value was normally .955, but varied between tests.

#### Current criteria

The criteria currently being used (in between tests) to identify precipitation bands are:

1) <img src="https://render.githubusercontent.com/render/math?math=A_{2} > 1.2 \times A_{20}">
2) <img src="https://render.githubusercontent.com/render/math?math=CC_t(A_t,A_T)">

#### Nomenclature

Term | Definition
------------ | ------------
<img src="https://render.githubusercontent.com/render/math?math=N_{100}"> | 100-millisecond count rate
<img src="https://render.githubusercontent.com/render/math?math=B_{p}"> | _p_% baseline count rate over a moving 20-second window*
<img src="https://render.githubusercontent.com/render/math?math=CC_{t}(N_{100},B_{p})"> | _t_-second correlation coefficient between <img src="https://render.githubusercontent.com/render/math?math=N_{100}"> and <img src="https://render.githubusercontent.com/render/math?math=B_{p}">
<img src="https://render.githubusercontent.com/render/math?math=A_t"> | short-window moving average with a window of _t_ seconds
<img src="https://render.githubusercontent.com/render/math?math=A_T"> | long-window moving average with a window of _T_ seconds
<img src="https://render.githubusercontent.com/render/math?math=\sigma_t"> | moving standard deviation with a window of _t_ seconds
<img src="https://render.githubusercontent.com/render/math?math=N_{Gauss}"> | Gaussian curve fit of 100-millisecond count rate at Van Allen Belts
<img src="https://render.githubusercontent.com/render/math?math=a,t"> | scalar factors; these can and do vary between base variables


\* _The preceding [paper](https://github.com/RHughes98/MeV-precip-bands/blob/main/Blumetal2015_SAMPEXprecipHSSs.pdf) uses the subscript 
                 to denote the time window of the 10th percentile baseline rather than the percentile taken for the baseline._
