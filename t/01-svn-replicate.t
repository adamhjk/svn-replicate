use Test::More qw(no_plan);
use FindBin;
use lib "$FindBin::Bin/../lib";

use strict;
use warnings;

BEGIN {
	use_ok( 'SVN::Replicate' );
}

my $sr = SVN::Replicate->new(
  local_path => "$FindBin::Bin/svnrepo",
  rsync_path => "localhost:$FindBin::Bin/svnrepo-mirror",
  ssh_identity => "/Users/adam/.ssh/id_rsa",
);

isa_ok( $sr, 'SVN::Replicate' );
ok($sr->replicate, 'Replicate was successful');
ok(-d "$FindBin::Bin/svnrepo-mirror", "svn mirror exists");
ok(-f "$FindBin::Bin/svnrepo-mirror/db/current", "db/current exists");
