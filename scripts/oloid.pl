#!/usr/bin/env perl
#============================================================= -*-perl-*-
#
# oloid.pl
#
# Perl script to generate coordinates for an oloid.
# https://en.wikipedia.org/wiki/Oloid
#
# Uses a variant of the parametric form described here:
# http://www.heldermann-verlag.de/jgg/jgg01_05/jgg0113.pdf
#
#  A = (sin(t), -0.5 - cos(t), 0)
#  B = (0, 0.5 - (cos(t) / (1 + cos(t)), sqrt(1 + (2 * cos(t)) / (1 + cos(t))
#
# Here t is theta, the angle from -120 to +120 degrees tracing around
# the circle A with corresponding points on the circle B.  The problem
# with this is that it gives a linear spacing of points on A but the
# points on B get more widely spaced as it approaches the limit at
# (0, 1.5, 0).
#
# So instead I'm using the above to generate coordinates for the
# first quadrant (0 - 90 degrees) and then relying on symmetry to
# generate the remaining points.
#
# If you have Perl installed (e.g. Mac and Linux users) then you
# should also have 'cpan' installed.  Run the folling command in a
# terminal to install the additional modules required:
#
#     cpan CAD::Format::STL Math::Trig
#
# Then you should be able to run this script either using perl:
#
#     perl oloid.pl
#
# Or if you have the executable bit set then like so:
#
#    ./oloid.pl
#
# If you're on Windows then you will first need to install Strawberry
# Perl, see http://strawberryperl.com/
#
# If you're a programmer then you should be able to translate the basic
# algorithm to your language of choice.
#
# Written by Andy Wardley, August 2018
#
#========================================================================

use strict;
use warnings;
# set this to 1 for debugging
use constant DEBUG => 0;

# Math::Trig is (I think) part of the Perl core.  You'll need to
# install CAD::Format::STL from CPAN.  e.g. if you have the cpan module
# installed then "cpan CAD::Format::STL" from the command line should
# do it.
use Math::Trig qw( deg2rad rad2deg pi );
use CAD::Format::STL;

# read radius and number of samples from command line, prompt user
# if not supplied or use defaults
my $radius = shift
    || prompt("Radius in mm", 1);

my $n_samples = shift
    || prompt("Number of samples", 30);

my (@a, @b);

# loop around a set of sample points...
for (my $s = 0; $s < $n_samples; $s++) {
    # theta is the angle from 0 to 90 degrees (pi/2 radians)
    my $theta = (pi * $s) / ($n_samples * 2);
    my $sint  = sin($theta);
    my $cost  = cos($theta);
    my $by    = $cost / (1 + $cost);
    my $bz    = sqrt(1 + 2 * $cost) / (1 + $cost);

    # Fill @a with pairs of (x,y) coordinates equally spaced around the
    # first 90 degrees of the "source" circle lying in the XY plane
    # centred at (0, -0.5, 0) with a radius of 1.
    push(@a, [$sint, $cost]);

    # Fill @b with corresponding (y, z) coordinates that are in the
    # first 30 degrees of the "target" circle in the YZ plane centred
    # at (0, 0.5, 0) also having a radius of 1
    push(@b, [$by, $bz]);

    printf(
        "%3i  %12.7f:  %12.7f  %12.7f  %12.7f  %12.7f\n",
        rad2deg($theta), $theta, $sint, $cost, $by, $bz
    ) if DEBUG;

}

# Using the parametric form described above for all 120 degrees results
# in an asymmetry.  The source points (A) are uniformly distributed but
# the target points (B) become sparse as they approach (0, 1.5, 0).
# This results in one end of the oloid being smooth but the other
# being rather angular.
#
# So instead we only generate the first 90 degrees and then rely on the
# symmetry to provide us with the points for the last 30 degrees.  In
# effect, we tack the results of B that we generated above onto the end
# of A in reverse order and with the coordinates suitably transformed.
# We do the same for B, adding the transformed coordinates from A
# onto the end of it.
#
# This is really hard to describe in a code comment, and I'm sure it's
# even harder to visualise...

my @a_samples = (
    (map { [$_->[0], -0.5 - $_->[1], 0] } @a),
    ([1, -0.5, 0]),
    (map { [$_->[1], -0.5 + $_->[0], 0] } reverse @b),
);

my @b_samples = (
    (map { [0, 0.5 - $_->[0], $_->[1]] } @b),
    ([0, 0.5, 1]),
    (map { [0, 0.5 + $_->[1], $_->[0]] } reverse @a),
);

# Now we can generate facets from the coordinates.  We take
# successive pairs (i.e. 4 points) and map them into 2 triangles.
my @facets;
my $max = scalar @a_samples;

# Loop through the samples starting at n=1 so that we can utilise the
# previous sample in n-1. With the 4 sample points (previous and current
# pair in both A and B) we generate 2 triangles to mesh the strip.

for (my $n = 1; $n < $max; $n++) {
    my $a1_point = $a_samples[$n-1];
    my $a2_point = $a_samples[$n];
    my $b1_point = $b_samples[$n-1];
    my $b2_point = $b_samples[$n];

    # scale all points by the radius
    my ($ax1, $ay1, $az1) = map { $_ * $radius } @$a1_point;
    my ($ax2, $ay2, $az2) = map { $_ * $radius } @$a2_point;
    my ($bx1, $by1, $bz1) = map { $_ * $radius } @$b1_point;
    my ($bx2, $by2, $bz2) = map { $_ * $radius } @$b2_point;

    push(
        @facets,
        # first the quadrant in +x, +z
        [[ $ax1, $ay1, $az1], [ $bx1, $by1, $bz1], [ $ax2, $ay2, $az2]],
        [[ $bx1, $by1, $bz1], [ $ax2, $ay2, $az2], [ $bx2, $by2, $bz2]],
        # then mirror it in x for the -x, +z quadrant
        [[-$ax1, $ay1, $az1], [-$bx1, $by1, $bz1], [-$ax2, $ay2, $az2]],
        [[-$bx1, $by1, $bz1], [-$ax2, $ay2, $az2], [-$bx2, $by2, $bz2]],
        # then mirror in z for +x, -z
        [[ $ax1, $ay1, -$az1], [ $bx1, $by1, -$bz1], [ $ax2, $ay2, -$az2]],
        [[ $bx1, $by1, -$bz1], [ $ax2, $ay2, -$az2], [ $bx2, $by2, -$bz2]],
        # once more in both x and z for -x, -z
        [[-$ax1, $ay1, -$az1], [-$bx1, $by1, -$bz1], [-$ax2, $ay2, -$az2]],
        [[-$bx1, $by1, -$bz1], [-$ax2, $ay2, -$az2], [-$bx2, $by2, -$bz2]],
    );
}

# Create an STL object, a part and add the facets to it
my $stl = CAD::Format::STL->new;
my $part = $stl->add_part("oloid");
$part->add_facets(@facets);

# Write the data to an STL file
my $filename = "oloid-R$radius-S$n_samples.stl";
$stl->save($filename);
print "Wrote $filename\n";


# utility function to prompt user and provide default.
sub prompt {
    my ($prompt, $default) = @_;
    my $ans;

    # print prompt and default value
    print $prompt, " (default: $default): ";
    # read answer and remove newline/carriage return
    chomp($ans = <STDIN>);
    # remove any leading/trailing whitespace
    for ($ans) {
        s/^\s+//;
        s/\s+$//;
    }
    # return answer given or default value
    return length $ans
        ? $ans
        : $default;
}
