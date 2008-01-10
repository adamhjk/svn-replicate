package SVN::Replicate;

use warnings;
use strict;

use Moose;
use Cwd;

has 'local_path' => ( is => 'rw', isa => 'Str', );
has 'rsync_path' => ( is => 'rw', isa => 'Str', );
has 'ssh_identity' => ( is => 'rw', isa => 'Str', );

=head1 NAME

SVN::Replicate - Replicate an SVN repository

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Mirrors an SVN repository to a remote host via rsync.

  my $sr = SVN::Replicate->new(
    local_path => "/srv/local-svn-repo" # Local SVN repo path
    rsync_path => "remotehost:/srv/remote-svn-repo" # Rsync path for remote SVN
    ssh_identity => "/someuser/.ssh/id_rsa" # SSH identity for the transfer
  );
  $sr->replicate;

=head1 FUNCTIONS

=head2 replicate

Actually replicate a given SVN repository.

=cut

sub replicate {
  my $self = shift;
  
  my $rsync_cmd = $self->_find_command_path("rsync");
  $rsync_cmd .= " -e \"ssh -i " . $self->ssh_identity . "\"";
  $rsync_cmd .= " -aR";
  
  my $origpath = getcwd;
  chdir($self->local_path) or die "Cannot chdir to " . $self->local_path . "!";
  
  # First, copy db/current
  my $current_cmd = $rsync_cmd . " db/current " . $self->rsync_path;
  $self->_execute($current_cmd);
  
  # Second, copy the rest
  my $all_cmd = $rsync_cmd . " --exclude db/current --exclude db/transactions/* --exclude db/log.* . " . $self->rsync_path;
  $self->_execute($all_cmd);
  chdir($origpath);
  return 1;
}

sub _find_command_path {
  my $self = shift;
  my $command = shift;
  
  my $cmd_path = `which $command`;
  chomp($cmd_path);
  die "Cannot find $command, returned '$cmd_path'!" unless -X $cmd_path;
  return $cmd_path;
}

sub _execute {
  my $self = shift;
  my $cmd = shift;
  
  print "Executing $cmd\n";
  system($cmd);
  my $result = $?;
  
  if ( $result == -1 ) {
    die "Cannot execute $cmd - $!";
  } elsif ( $result & 127) {
    die "Child $cmd died with signal " . ( $result & 127 );
  } elsif ( $result ) {
    die "$cmd died with value " . ( $result >> 8 );
  }
  return $result; 
}

=head1 AUTHOR

Adam Jacob, C<< <adam at hjksolutions.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-svn-replicate at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=SVN-Replicate>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc SVN::Replicate


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=SVN-Replicate>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/SVN-Replicate>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/SVN-Replicate>

=item * Search CPAN

L<http://search.cpan.org/dist/SVN-Replicate>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Adam Jacob, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of SVN::Replicate
