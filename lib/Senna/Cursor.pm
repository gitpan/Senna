# $Id: Cursor.pm 9 2005-05-30 06:43:26Z daisuke $
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

=cut
