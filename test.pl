# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..11\n"; }
END {print "not ok 1\n" unless $loaded;}
#MIKE
use strict;
use Math::MatrixReal::Ext1;
#MIKE added 'main::' for use strict's benefit(s)
$main::loaded = 1;
print "ok 1\n";

######################### End of black magic.

# below we are basically checking the
# various ways that the new_from_* methods 
# are supposed to work--with strings, array refs,
# or Math::MatrixReal vectors.  They are also
# supposed to work for mixtures of those things,
# so we're checking that too.

my $matrix2 = Math::MatrixReal::Ext1->new_from_cols([[11,21], [12,22]]); 
print &check_matrix($matrix2) ? "ok 2\n" : "not ok 2\n";

my $col1 = $matrix2->column(1);
my $col2 = $matrix2->column(2);

my $matrix3 = Math::MatrixReal::Ext1->new_from_cols( [$col1, $col2]);

print &check_matrix($matrix3) ? "ok 3\n" : "not ok 3\n";

my $string1 = "[ 11 ]\n[ 21 ]\n[ 31 ]\n";
my $string2 = "[ 12 ]\n[ 22 ]\n[ 32 ]\n";
my $string3 = "[ 13 ]\n[ 23 ]\n[ 33 ]\n";

my $matrix4 = Math::MatrixReal::Ext1->new_from_cols( [$string1, $string2, $string3] );
print &check_matrix($matrix4) ? "ok 4\n" : "not ok 4\n";

my $col52 = $matrix4->column(2);
my $matrix5 = Math::MatrixReal::Ext1->new_from_cols( [$string1, $col52, [13,23,33]]);
print &check_matrix($matrix5) ? "ok 5\n" : "not ok 5\n";

my $matrix6 = Math::MatrixReal::Ext1->new_from_rows( [[11,12,13], [21,22,23], [31,32,33]]);
print &check_matrix($matrix6) ? "ok 6\n" : "not ok 6\n";


my $matrix7 = Math::MatrixReal::Ext1->new_from_rows( ["[ 11 12 13 ]\n", "[ 21 22 23 ]\n", "[ 31 32 33 ]\n"]);
print &check_matrix($matrix7) ? "ok 7\n" : "not ok 7\n";


my ($row81, $row82, $row83) = ($matrix4->row(1), $matrix4->row(2), $matrix4->row(3));
my $matrix8 = Math::MatrixReal::Ext1->new_from_rows( [$row81, $row82, $row83] );
print &check_matrix($matrix8) ? "ok 8\n" : "not ok 8\n";


my $matrix9 = Math::MatrixReal::Ext1->new_from_rows( ["[ 11 12 13 ]\n", $row82, $matrix8->row(3)] );
print &check_matrix($matrix9) ? "ok 9\n" : "not ok 9\n";

package Foo;

use base qw/Math::MatrixReal/;

package main;

my $foo_string = "[ 11 12 13 ]\n";
my $foo_matrix = Foo->new_from_string($foo_string);

my $matrix10 = Math::MatrixReal::Ext1->new_from_rows( [$foo_matrix, $row82, $matrix8->row(3)] );

print &check_matrix($matrix10) ? "ok 10\n" : "not ok 10\n";

# make sure it dies with our error message if you pass in a
# hash ref
eval{ Math::MatrixReal::Ext1->new_from_cols( [{ foo=> 'bar'}] ) };
if ($@ =~ /no clue/) {
    print "ok 11\n";
}
else {
    print "not ok 11\n";
}

# ok, the matrix we're making in every case is like
# this (or possibly a different-sized version):
#  
#  11  12  13
#  21  22  23
#  31  32  33
#
# so, all we have to do to check them is
# to make sure that 10 times the row plus
# the column of each given element is equal
# to the value of the element (they're
# floats, though, so check with tolerance)
#
sub check_matrix {
	my $matrix = shift;
	my ($rows, $cols) = $matrix->dim;
	my $success = 1;
	foreach my $row (1..$rows) {
		foreach my $col (1..$cols) {
			my $element = $matrix->element($row,$col) ;
			$success = 0 unless ( abs ( $element - (10*$row + $col) ) < .00001 ) ;
		}
	}
	return $success;
}
