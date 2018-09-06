# Oloids
This project contains the scripts, STL files and other media relating
to a YouTube video I'm making about subject of
[Oloids](https://en.wikipedia.org/wiki/Oloid), inspired
by Angus Deveson's [Weird Wobblers and Odd Oloids](https://www.youtube.com/watch?v=fRqwYsfiME8)
video on the Maker's Muse channel.

The [scripts](scripts) directory contains a Perl script that will
generate an STL file containing an Oloid.  See the comments in the
code for information on how to install the required modules and then
run the script.

You can specify the circle radius and the number of samples points as
command line arguments or enter the values when prompted.  Note that the
length of the Oloid will be 3 times the circle radius.  The default
radius of 33.333mm gives a 100mm Oloid.  The default number of samples
is 30.  The number of facets generated will be 12 times this value,
e.g. 12 x 30 = 480.

The [models](models) directory contains some example STL files generated
by the script.  You should be able to import these directly into your
3d modelling software for further manipulation.
