# $Id: Senna.pm 39 2005-08-05 04:28:19Z daisuke $
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

package Senna;
use strict;
use vars qw($VERSION);

BEGIN
{
    $VERSION = '0.08';
    if ($] > 5.006) {
        require XSLoader;
        XSLoader::load('Senna', $VERSION);
    } else {
        require DynaLoader;
        @Senna::ISA = ('DynaLoader');
        __PACKAGE__->bootstrap();
    }
}

use Senna::Index;
use Senna::Cursor;
use Senna::Result;

1;

__END__

=head1 NAME

Senna - Perl Interface To Senna Fulltext Search Engine

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

Development funded by Brazil Ltd. E<lt>http://dev.razil.jp/project/senna/E<gt>

=head1 SEE ALSO

http://dev.razil.jp/project/senna - Senna Development Homepage

=cut
