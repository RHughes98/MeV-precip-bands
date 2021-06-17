# MeV-precip-bands
Objective: Identify and predict MeV electron precipitation bands in the Earth's magnetosphere

## A quick tour

### SAMPEX Data
Downloaded and parsed telemetry data collected by the SAMPEX satellite, grouped by '[rate](http://www.srl.caltech.edu/sampex/DataCenter/docs/HILThires.html)' and '[attitude]()' data sets. The former represents SSD4 count rates of protons above ~5MeV and electrons above 1 MeV in 100ms time intervals, while the latter represents chronological, orbital, and environmental data collected by SAMPEX. 
[Data](http://www.srl.caltech.edu/sampex/DataCenter/data.html) courtesy of CalTech Space Physics Data Center (SPDF).

### MATLAB

#### `dataProcessingScript.m`
The central data parsing and analysis script of the program. It reads in, parses, and processes SAMPEX data before finding Van Allen belts, microbursts, and precipitation bands. Most active helper functions are invoked from this script. Its most pertinent use is saving daily data into a format conducive to neural network training. Numerous approaches to precipiation band criteria are employed here, and this can be seen at times where there are 3 repetitions of seemingly the same line of code - commented with the style of criteria: original, average-based, and standard deviation-based. The user should leave at most one of these 3 lines uncommented at any time and ensure consistency wherever these lines occur (don't mix criteria types!).

#### `bidir_LSTMnet.m`
The center of the machine learning portion of this project. Takes in as input `.mat` files containing train and test data, then trains and tests a neural network before reporting high-level results.

#### `replace_test_data.m`
Used to re-define test data and re-test an existing neural network model on new test days. Same output as `bidir_LSTMnet.m`.

#### `plotFunc.m`
Plotting helper function, takes in specific data vectors for plotting. Input parameters can be varied to plot features found via different methods and criteria. The parameter structure is mostly for convenient swapping between criteria to plot for observation.

#### `quickPlotCheck.m`
Used for plotting all identified precipitation bands in order for users to individually identify true and false positives.

#### `brush_PB_data.m`
Displays data in half-hour chunks for the user to manually highlight observed precipitation bands. The output is a logical time array representing presence of bands for the whole day, used as input for neural networks.

#### `curveFitting.m`
Applies a 2<sup>nd</sup> term Gaussian curve fit to Van Allen belts. They are plotted one-by-one with the curve fit overlaid. This function invokes the `beltBands.m` helper function to find precipitation bands that occurred as the satellite was passing through the Van Allen belts.

#### `PBands.m`
The original precipitation band finder function, this helper function is formatted to find precipitation bands over full days' data sets. `PBands.m` takes in criteria, count rate data, and a target time window for band duration. It returns the start and end indices of precipitation bands, as well as the indices of data points that met the first criteria (for later plotting and analysis, this output is often omitted in `dataProcessingScript.m`).

#### `beltBands.m`
A close relative of `PBands.m`. `beltBands.m` is modified to take in smaller data partitions (that may only have one precipitation band) for band identification. It takes in the same parameters as `PBands.m` and returns start/end indices of identified precipitation bands.

#### `mergedCritBands.m`
Another band-identification function, this time utilizing a logical `AND` operator to 'merge' criteria into one comprehensive logical array (1 for both criteria met, 0 for none/not all criteria met). This approach was taken to avoid relying on the 'starts' and 'ends' of potential bands for identification.

#### `percentCheck.m`
Takes in a vector of logical criteria values and a minimum percentage (from 0 to 1.0 or 0 to 100), and returns whether or not that minimum percentage of criteria values are True.

#### `getPBInput.m`
Handles user input, which is taken to check whether a certain precipitation band identification algorithm was effective in its analysis. User input must be Y/y or N/n. `getPBInput.m` is primarily invoked by `quickPlotCheck.m` and `curveFitting.m`.

#### `read_days.m`
Takes as input an array of numerical days of the year 2005, then sorts feature data for those day into a cell array.   

#### `var_checker.m`
Takes day numbers as input, then calculates and displays the variance of each day's data set.

#### `band_dummy.m`
**Inactive** - used to test reliability of an updated precipitation band identification algorithm (using given criteria). 

#### `combine_daily_data.m`
**Inactive** - used in pre-processing to combine state and attitude data into a more agreeable format for analysis.

#### `brush_test.m`
**Inactive** - used in determin

#### `neuralNetTraining.m`
**Inactive** Trains and tests an autoencoder, currently doesn't work as intended but kept for posterity and possible future use.


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

## Data

#### Rate
<!--(time, count rate)-->
Name | Description
------ | ------
`time` | time of day [sec]
`rate` | 100-millisecond count rate

#### Attitude
<!--(year, day, seconds, longitude, latitude, altitude, L-shell, various magnetic field (_B_) magnitudes, MLT, invariant latitude, Loss Cones 1 and 2, South Atlantic Anomaly flag, pitch angle, attitude flag)-->
Name | Description
------ | ------
`year` | year of data collection
`day` | day of year, numeric
`sec` | seconds of day 
`long` | longitude in geographic coordinates [deg]
`lat` | latitude in geographic coordinates [deg]
`alt` | altitude in geographic coordinates [km]
`Lshell` | L-shell parameter [Earth radii]
`Bmag` | Model magnetic field magnitude [Gauss]
`LC1`, `LC2` | Loss Cones 1 and 2 (particle precipitation half-angle)
`eqB` | magnetic field magnitude at Earth's equator [Gauss]
`N100B` | magnetic field magnitude at North 100km [Gauss]
`SAA` | South Atlantic Anomaly flag


## Criteria

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

## Nomenclature

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

## Machine Learning

Various machine learning techniques were explored to identify and/or predict precipitation bands. The most successful in Ryan's time here was a bidirectional Long Short Term Memory (LSTM) neural network with 100 hidden units. Variations of this model (by number of epochs) can be found in the `models` subdirectory.

#### Machine Learning Resources

Listed below are some articles, publications, and other resources Ryan referred to during his time at LASP. Consider using any of these resources as a starting point or additional research for relevant machine learning techniques:
* [Recurrent Neural Networks for Time Series Forecasting](https://export.arxiv.org/pdf/1901.00069)
* [Anomaly Detection with LSTM in Keras](https://towardsdatascience.com/anomaly-detection-with-lstm-in-keras-8d8d7e50ab1b)
* [Multi-Sensor Data Analysis Demo](https://github.com/ajayarunachalam/msda/blob/main/demo.ipynb)
* [Satellite Telemetry Anomaly Detection](https://github.com/sapols/satellite-telemetry-anomaly-detection)
* [ARIMA fundamentals](https://www.machinelearningplus.com/arima-model-time-series-forecasting-python/) and [ARIMA Parameters Guide](https://people.duke.edu/~rnau/arimrule.htm)

## Future Work

This project is far from complete, and whoever takes it up next has their work more or less cut out for them. Here are some things Ryan didn't get around to during his tenure at LASP:
* Automate the process of reading SAMPEX data and organizing it into `.mat` files for neural network training and testing
* Use `.fig` files in `PB-plots` subdirectory to compare various trials between models (plot new model's identified PB's over existing figure)
* Feature reduction to create a more concise model
* For an unidentified reason MATLAB's `trainNetwork` function doesn't like the current configuration of responses to the training model. Fixing this error should (hopefully) enable the model to run on brushed data (currently contained in the appropriate `.mat` files, but feel free to re-brush) without further changes. See the relevant section of [MATLAB's `trainNetwork` documentation](https://www.mathworks.com/help/deeplearning/ref/trainnetwork.html#mw_d0b3a2e4-09a0-42f9-a273-2bb25956fe66) for more info.
* Run neural network models on a more powerful CPU than Ryan's personal laptop, using significantly more data
* Compare the effects of modifying the interpretation of what 'defines' a precipitation band (e.g. active time, magnitude)
* Plot user-brushed bands from `brush_PB_data.m` over bands determined from criteria, do the same with ML model results based on each
* Employ random dropout of neural network nodes to ensure that model isn't overfitting

## Getting Started

To orient themself with the project, the next developer would be advised to begin with `dataProcessingScript.m`. As most helper functions are called from this script, some crafty debugging can yield examples of input and output parameters. When doing this, it's advised that the user comments out the `Self-Check` section of the script (somewhere around line 340) so as to skip the manual check of precipitation bands. Later, of course, this could be un-commented for further inspection of band criteria. Good luck!
