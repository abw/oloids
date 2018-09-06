# Oloid STL Files

This directory contains sample STL files containing a single oloid model.

The filename indicates the radius of the construction circles in mm
(e.g. `R100`) and the number of sample points per quadrant (e.g. `S30`).
For example, `oloid-R100-S100.stl` has a radius of 100mm and 100 sample
points.

Note that the total length of the oloid will be 3x the radius value.
For example, `R33.333` indicates a radius of 33.333mm giving a total oloid
length of 100mm.  The total number of facets in the model will be 16x
the sample size, e.g. `S100` has 100 samples so 1600 facets.

More facets gives greater accuracy but might slow down your 3D modelling software.

I find that 30 samples is more than enough accuracy for models that ultimately will be 3d printed.
If there's not a size that you want here then you can, of course, scale up one of these models
in your 3d modeling software.  Or you can use the [oloid.pl](../scripts/oloid.pl) script in the [scripts](../scripts) directory to generate an STL file containing any combination of radius and sample size.

|File                  |Radius (mm)|Length (mm)|Samples|Facets|
|----------------------|-----------|-----------|-------|------|
|oloid-R1-S30.stl      |          1|          3|     30|   480|
|oloid-R100-S100.stl   |        100|        300|    100|  1600|
|oloid-R33.333-S10.stl |     33.333|        100|     10|   160|
|oloid-R33.333-S100.stl|     33.333|        100|    100|  1600|
|oloid-R33.333-S30.stl |     33.333|        100|     30|   480|
