# $Id: /mirror/coderepos/lang/perl/Senna/trunk/lib/Senna/Index/Info.pm 37708 2008-01-02T14:49:19.475826Z daisuke  $
#
# Copyright (c) 2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package Senna::Index::Info;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors($_) for (
    qw(key_size flags initial_n_segments encoding nrecords_keys),
    qw(file_size_keys nrecords_lexicon file_size_lexicon),
    qw(inv_seg_size inv_chunk_size)
);

# XXX - new() is still visible. yikes.
sub _new
{
    my $class = shift;
    my %args;
    @args{ qw(
        key_size flags initial_n_segments encoding nrecords_keys
        file_size_keys nrecords_lexicon file_size_lexicon
        inv_seg_size inv_chunk_size
    ) } = @_;
    
    $class->SUPER::new( \%args );
}

1;

__END__

=head1 NAME

Senna::Index::Info - Abstraction For Values Returned From sen_index_info()

=head1 SYNOPSIS

  use Senna;
  my $index = Senna::Index->open({ path => $path });
  my $info  = $index->info;

=head1 METHODS

=head2 encoding

=head2 file_size_keys

=head2 file_size_lexicon

=head2 flags

=head2 initial_n_segments

=head2 inv_chunk_size

=head2 inv_seg_size

=head2 key_size

=head2 nrecords_keys

=head2 nrecords_lexicon

=cut
