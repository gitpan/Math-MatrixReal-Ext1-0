package Math::MatrixReal::Ext1;

use strict;
use Math::MatrixReal;
use Carp;


use base qw/Math::MatrixReal/;

our $VERSION = '0.05';

sub new_from_cols {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $ref_to_cols = shift;
	my @cols = @{$ref_to_cols};

	my $cols = scalar( @cols );

	my $matrix = 0;
	my $rows = 0;

	# each arg is a column, but we don't know what form they're
	# in yet

	my $col_index = 0;
	foreach my $col (@cols) {
		# it's one-based
		$col_index ++;
		my $ref = ref( $col ) ;

		if ( $ref eq '' ) {
			# we hope this is a string
			$col = $class->new_from_string( $col );
		}
		elsif ( $ref eq 'ARRAY' ) {
			my @array = @$col;
			my $length = scalar( @array );
			$col = $class->new_from_string( '[ '. join( " ]\n[ ", @array) ." ]\n" );
		}
		elsif ( $ref ne 'HASH' and $col->isa('Math::MatrixReal') ) {
			# it's already a Math::MatrixReal something,
            # we don't need to do anything, it will all
            # work out--but we need this branch so we don't hit the 
            # error else below
		}
		else {
			# we have no idea, error time!
			croak __PACKAGE__."::new_from_cols(): sorry, I have no clue what you sent me!  I only know how to deal with array refs, strings, and things that inherit from Math::MatrixReal\n";
		}
		my ($length, $one) = $col->dim;
		croak __PACKAGE__."::new_from_cols(): This isn't a column vector"
			  unless ($one == 1) ;

		# if we already have a height, check that this is the same
		if ($rows) {
			croak __PACKAGE__."::new_from_cols(): This column vector has $length elements and an earlier one had $rows"
			  unless ($length == $rows) ;
		}
		# else, we have a new height FIXME maybe this should check for zero
		else {
			$rows = $length;
		}

		# create the matrix the first time through
		unless ($matrix) {
			$matrix = $class->new($rows, $cols);
		}

		foreach my $row_index (1..$rows){
			my $value = $col->element($row_index, 1);
			$matrix->assign($row_index, $col_index, $value);
		}

	}
	return $matrix;
}

sub new_from_rows {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $ref_to_rows = shift;
	my @rows = @{$ref_to_rows};

	my $rows = scalar( @rows );

	my $matrix = 0;
	my $cols = 0;

	# each arg is a column, but we don't know what form they're
	# in yet

	my $row_index = 0;
	foreach my $row (@rows) {
		# it's one-based
		$row_index ++;
		my $ref = ref( $row ) ;

		if ( $ref eq '' ) {
			# we hope this is a string
			$row = $class->new_from_string( $row );
		}
		elsif ( $ref eq 'ARRAY' ) {
			my @array = @$row;
			my $length = scalar( @array );
			$row = $class->new_from_string( '[ '. join( " ", @array) ." ]\n" );
		}
		elsif ( $ref ne 'HASH' and $row->isa('Math::MatrixReal') ) {
			# it's already a Math::MatrixReal something,
            # we don't need to do anything, it will all
            # work out
		}
		else {
			# we have no idea, error time!
			croak __PACKAGE__."::new_from_rows(): sorry, I have no clue what you sent me!  I only know how to deal with array refs, strings, and things that inherit from Math::MatrixReal\n";
		}
		my ($one, $length) = $row->dim;
		croak __PACKAGE__."::new_from_rows(): This isn't a column vector"
			  unless ($one == 1) ;

		# if we already have a height, check that this is the same
		if ($cols) {
			croak __PACKAGE__."::new_from_rows(): This column vector has $length elements and an earlier one had $cols"
			  unless ($length == $cols) ;
		}
		# else, we have a new width  FIXME maybe this should check for zero
		else {
			$cols = $length;
		}

		# create the matrix the first time through
		unless ($matrix) {
			$matrix = $class->new($rows, $cols);
		}

		foreach my $col_index (1..$cols){
			my $value = $row->element(1, $col_index);
			$matrix->assign($row_index, $col_index, $value);
		}

	}
	return $matrix;
}


1;
__END__
=head1 NAME

Math::MatrixReal::Ext1 - Minor extensions to Math::MatrixReal

=head1 SYNOPSIS

  use Math::MatrixReal::Ext1;

  $ident3x3 = Math::MatrixReal::Ext1->new_from_cols( [ [1,0,0],[0,1,0],[0,0,1] ] );
  $upper_tri = Math::MatrixReal::Ext1->new_from_rows( [ [1,1,1],[0,1,1],[0,0,1] ] );

  $col1 = Math::MatrixReal->new_from_string("[ 1 ]\n[ 3 ]\n[ 5 ]\n");
  $col2 = Math::MatrixReal->new_from_string("[ 2 ]\n[ 4 ]\n[ 6 ]\n");

  $mat = Math::MatrixReal::Ext1->new_from_cols( [ $col1, $col2 ] );

=head1 DOWNLOADING

The latest version might be at

	http://fulcrum.org/personal/msouth/code/

but I would bet on CPAN if I were you.

=head1 DESCRIPTION

Just scratching a couple of itches for functionality in Math::MatrixReal.

[At the time I wrote this (2001) Math::MatrixReal was abandoned, but 
someone has since adopted it.  My recent (2005) updates will also
hopefully go into Math::MatrixReal, but for now I'm putting them
here because I just can't stand having this stuff out there
uncorrected.  Once the most recent changes are in the main 
line, I will deprecate this module and then it will completely
disappear, probably some time in 2006.]

=over 4

=item C<new_from_cols>

C<new_from_cols( [ $column_vector|$array_ref|$string, ... ] )>

Creates a new matrix given a reference to an array of any of the following:

=over 4

=item * column vectors ( n by 1 Math::MatrixReal matrices )

=item * references to arrays

=item * strings properly formatted to create a column with Math::MatrixReal's 
C<new_from_string> command

=back

You may mix and match these as you wish.  However, all must be of the 
same dimension--no padding happens automatically.  This could possibly
change in a future version.

=item C<new_from_rows>

C<new_from_rows( [ $row_vector|$array_ref|$string, ... ] )>

Creates a new matrix given a reference to an array of any of the following:

=over 4

=item *	row vectors ( 1 by n Math::MatrixReal matrices )

=item *	references to arrays

=item *	strings properly formatted to create a row with Math::MatrixReal's C<new_from_string> command

=back

You may mix and match these as you wish.  However, all must be of the 
same dimension--no padding happens automatically.  This could possibly
change in a future version.

=back

=head1 BUGS

Error handling could be more descriptive in some cases.

It has been suggested that use of Math::MatrixReal (and thus, by extension,
extending it) is pointless in light of the powerful Math::Pari.  From the
documentation for Math::Pari:

=over 4

Package Math::Pari is a Perl interface to famous library PARI for
numerical/scientific/number-theoretic calculations.  It allows use of
most PARI functions (>500) as Perl functions, and (almost) seamless merging
of PARI and Perl data. 

=back 

So, if you're thinking of using this, you may want to look at Math::Pari instead.


=head1 AUTHOR

msouth@fulcrum.org (see http://fulcrum.org )

=head1 SEE ALSO

Math::MatrixReal(3).

=cut
