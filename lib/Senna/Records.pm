# $Id: /mirror/coderepos/lang/perl/Senna/trunk/lib/Senna/Records.pm 37742 2008-01-04T01:18:00.636616Z daisuke  $
#
# Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package Senna::Records;
use strict;
use warnings;

sub next
{
    my $self = shift;
    my $record = $self->_XS_next;
    if ($record && wantarray) {
        return ($record->key, $record->score);
    }
    return $record;
}

1;

__END__

=head1 NAME

Senna::Records - A Collection Of Records (sen_records)

=head1 METHODS

=head2 open

=head2 close

=head2 next

=head2 curr_key

=head2 nhits

=head2 sort

Sorts the records, discarding results if the total number of records
exceed C<limit>.

  $records->sort($limit);

If you want to control the sort order (ascending/descending), specify a
second argument which can be a HASHREF

  $records->sort($limit, { mode => SEN_SORT_ASCENDING });
  $records->sort($limit, { mode => SEN_SORT_DESCENDING });

Beware, though, that according to the senna documentation, by specifying
not sort options the results are sorted by I<score> (descending), and if you
specify the mode (without any compar args), the results are sorted by the
I<key>s.

Please note that the custom comparison operator is currently not supported.
Patched welcome!

=cut
