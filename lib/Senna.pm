# $Id: /mirror/coderepos/lang/perl/Senna/trunk/lib/Senna.pm 38387 2008-01-10T08:09:02.619819Z daisuke  $
#
# Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package Senna;
use strict;
use warnings;
use vars qw($VERSION @ISA);
use 5.008;
use XSLoader;

BEGIN
{
    $VERSION = '0.60000';
    XSLoader::load(__PACKAGE__, $VERSION);
}

END
{
    cleanup();
}

use Senna::DB;
use Senna::Constants;
use Senna::Ctx;
use Senna::Encoding;
use Senna::Index;
use Senna::Query;
use Senna::RC;
use Senna::Snippet;
use Senna::Symbol;


1;

__END__

=head1 NAME

Senna - Perl Binding for Senna Full Text Search Engine

=head1 SYNOPSIS

  use Senna;

  my $index = Senna::Index->create(
    path => "...",
  );
  my $info = $index->info;

=head1 DESCRIPTION

This module provides a Perl binding to libsenna, an embeddable full-text search
engine.

While Senna remains a personal favorite to search for Japanese text, 
Senna (the API) is in a constant state of flux which makes things really hard
for binding development. This module tries hard to keep up with the changes,
but if you see breakage, PATCHES ARE ENCOURAGED. Please see L<CODE|CODE>

=head1 METHODS

=head2 info

=head2 cleanup

Performs C level cleanup for Senna. You do NOT need to use this method.
It's called automatically at END block.

=head1 CODE

Senna is graciously hosted by coderepos (http://coderepos.org/share)
For latest version, please grab from:

  http://svn.coderepos.org/share/lang/perl/Senna/trunk

=head1 AUTHOR

Copyright (c) 2005-2008 Daisuke Maki E<lt>daisuke@endeworks.jpE<gt>

=head1 CONTRIBUTORS

Jiro Nishiguchi

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
