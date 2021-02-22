# MeV-precip-bands
Objective: Identify and predict MeV electron precipitation bands in the Earth's magnetosphere

## A quick tour
The functionality of this repository is concentrated in `dataProcessingScript.m`, with several helper functions to complement.

#### `dataProcessingScript.m`
This is the central script of the program. It reads in, parses, and processes SAMPEX data before finding Van Allen belts, microbursts, and precipitation bands. All active helper functions are invoked from this script.

#### `plotFunc.m`
This is the plotting helper function. It takes in specific data vectors for plotting, and the input parameters can be varied to plot features found via different methods and criteria. The parameter structure is mostly for convenient swapping between criteria to plot for observation.

#### `curveFitting.m`
This function is used to apply a 2<sup>nd</sup> term Gaussian curve fit to Van Allen belts. They are plotted one-by-one with the curve fit overlaid. This function invokes the `beltBands.m` helper function to find precipitation bands that occurred as the satellite was passing through the Van Allen belts.

## Data structs
There are 3 major data struct variables in `dataProcessingScript.m` geared to its primary purposes. These are `VA` for Van Allen belt identification, `MB` for microbursts, and `PB` for precipitation bands.
