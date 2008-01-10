#!perl 

use Test::More tests => 1;
use FindBin;
use lib "$FindBin::Bin/../lib";

BEGIN {
	use_ok( 'SVN::Replicate' );
}

diag( "Testing SVN::Replicate $SVN::Replicate::VERSION, Perl $], $^X" );
