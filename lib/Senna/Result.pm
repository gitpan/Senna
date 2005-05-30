# $Id: Result.pm 10 2005-05-30 08:02:12Z daisuke $
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

package Senna::Result;
use strict;

sub new
{
    my $class = shift;
    my %args  = @_;

    my %hash;
    foreach my $k qw(key score) {
        $hash{$k} = $args{$k};
    }
    my $self = bless \%hash, $class;
    return $self;
}

sub _elem
{
    my $self  = shift;
    my $field = shift;
    my $old  = $self->{$field};
    if (@_) {
        $self->{$field} = shift @_;
    }
    return $old;
}

sub key   { shift->_elem('key', @_) }
sub score { shift->_elem('score', @_) }

1;