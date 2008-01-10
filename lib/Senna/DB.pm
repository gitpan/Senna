package Senna::DB;
use strict;
use warnings;

sub create {
    my $class = shift;

    my @fields = qw(path flags encoding);
    my $count = scalar @_;
    if ($count == 1) {
        if (ref $_[0] eq 'HASH') {
            @_ = map { $_[0]->{$_} } @fields;
        }
    } elsif ($count != 3) {
        my %args  = @_;
        @_ = @args{ @fields };
    }

    $_[1] ||= 0;
    pop @_ while @_ && ! defined $_[-1];
    $class->_XS_create(@_);
}

sub open {
    my $class = shift;
    if (@_ == 1) {
        if(ref $_[0] eq 'HASH') {
            @_ = ($_[0]->{path});
        }
    } elsif (@_ > 1) {
        my %args  = @_;
        @_ = ($args{path});
    }

    $class->_XS_open(@_);
}

1;

__END__

=head1 NAME

Senna::DB - Senna DB

=head1 METHODS

=head2 create

=head2 open

=head2 close

=cut
