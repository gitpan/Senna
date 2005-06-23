# $Id: Cursor.pm 30 2005-06-23 02:23:48Z daisuke $
#
# Daisuke Maki <dmak@cpan.org>
# All rights reserved.

package Senna::Cursor;
use strict;
use Senna::Result;
use vars qw($VERSION);
$VERSION = '0.01';

sub new
{
    my $class = shift;
    my $self  = bless {}, $class;
    $self->_alloc_cursor_state();
    return $self;
}

sub as_list
{
    my $self = shift;
    return wantarray ? @{$self->_as_list} : $self->_as_list;
}

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

=head1 AUTHOR

Copyright (C) 2005 by Daisuke Maki <dmaki@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

Development funded by Brazil Ltd. E<lt>http://dev.razil.jp/project/senna/E<gt>

=head1 SEE ALSO

http://dev.razil.jp/project/senna - Senna Development Homepage

=cut
