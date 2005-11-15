# $Id: Cursor.pm 40 2005-11-15 09:14:44Z daisuke $
#
# Daisuke Maki <dmak@cpan.org>
# All rights reserved.

package Senna::Cursor;
use strict;
use Senna::Result;
use vars qw($VERSION);
$VERSION = '0.01';

__END__

=head1 NAME

Senna::Cursor - A Senna Cursor Object

=head1 SYNOPSIS

  use Senna::Index;
  use Senna::Cursor;
  my $cursor = $index->search($query);

  print "got ", $cursor->hits, " hits\n";
  while (my $r = $cursor->next) {
     print "key = ", $r->key, ", score = ", $r->score, "\n";
  }

  $cursor->rewind();
  $cursor->close();

=head1 METHODS

=head2 as_list()

Returns the list of Senna::Result objects in the cursor.

=head2 close()

Closes the the cursor

=head2 currkey()

Returns the key of the current result object pointed by the cursor.

=head2 hits()

Returns the number of hits in the cursor.

=head2 new()

Creates a new cursor. Users shouldn't really need to worry about this method

=head2 next()

Returns the next Senna::Result object.

=head2 rewind()

Moves the cursor to point the first result.

=head2 score()

Returns the score of the current result object pointed by the cursor.

=head1 AUTHOR

Copyright (C) 2005 by Daisuke Maki <dmaki@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

Development funded by Brazil Ltd. E<lt>http://dev.razil.jp/project/senna/E<gt>

=head1 SEE ALSO

http://dev.razil.jp/project/senna - Senna Development Homepage

=cut
