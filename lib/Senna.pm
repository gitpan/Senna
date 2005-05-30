# $Id: Senna.pm 9 2005-05-30 06:43:26Z daisuke $
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

package Senna;
use 5.006001;
use strict;
use warnings;
our $VERSION = '0.02';

require XSLoader;
XSLoader::load('Senna', $VERSION);

Senna::sen_init();

use Senna::Index;
use Senna::Cursor;
use Senna::Result;

1;

__END__

=head1 NAME

Senna - Perl Interrface To Senna Fulltext Search Engine

=head1 SYNOPSIS

  use Senna;
  my $index = Senna::Index->create(...);
  # or $index = Senna::Index->open(...);
  #
  my $cursor = $index->search($query);

  while (my $key = $cursor->next) {
      print $key, " score = ", $cursor->score, "\n";
  }

=head1 AUTHOR

Copyright (C) 2005 by Daisuke Maki <dmaki@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

Development funded by Brazil Ltd. E<lt>http://dev.razil.jp/projects/senna/E<gt>

=head1 SEE ALSO

http://dev.razil.jp/projects/senna - Senna Development Homepage

=cut
