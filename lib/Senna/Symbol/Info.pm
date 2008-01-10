# $Id: /mirror/coderepos/lang/perl/Senna/trunk/lib/Senna/Symbol/Info.pm 37707 2008-01-02T14:44:33.268964Z daisuke  $
#
# Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package Senna::Symbol::Info;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors($_) for qw(key_size flags encoding nrecords file_size);

sub _new
{
    my $class = shift;
    my %args;
    @args{ qw(key_size flags encoding nrecords file_size) } = @_;
    return $class->SUPER::new(\%args);
}

1;

__END__

=head1 NAME

Senna::Symbol::Info - Abstraction For Values Returned From sen_sym_info()

=head1 SYNOPSIS

  use Senna;
  my $symbol = Senna::Symbol->open({ path => $path });
  my $info   = $symbol->info;

=head1 METHODS

=head2 key_size

=head2 flags

=head2 encoding

=head2 nrecords

=head2 file_size

=cut
