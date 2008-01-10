# $Id: /mirror/coderepos/lang/perl/Senna/trunk/lib/Senna/Record.pm 37672 2008-01-01T23:20:54.940158Z daisuke  $
#
# Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package Senna::Record;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors($_) for qw(key score post section n_subrecs);

sub new
{
    my $class = shift;
    $class->SUPER::new({ @_ });
}

1;

__END__

=head1 NAME

Senna::Record - A Single Record

=head1 METHODS

=head2 new

=head2 key

=head2 score

=head2 post

=head2 section

=head2 n_subrecs

=cut