package Senna::Ctx;
use strict;
use warnings;

use Senna::DB;
use Senna::Ctx::Info;

sub connect {
    my $class = shift;

    my @fields = qw(host port flags);
    my $count = scalar @_;
    if ($count == 1) {
        if (ref $_[0] eq 'HASH') {
            @_ = map { $_[0]->{$_} } @fields;
        }
    } elsif ($count != 3) {
        my %args  = @_;
        @_ = @args{ @fields };
    }

    $_[2] ||= 0;
    pop @_ while @_ && ! defined $_[-1];
    $class->_XS_connect(@_);
}

sub open {
    my $class = shift;

    my @fields = qw(db flags);
    my $count = scalar @_;
    if ($count == 1) {
        if (ref $_[0] eq 'HASH') {
            @_ = map { $_[0]->{$_} } @fields;
        }
    } elsif ($count != 2) {
        my %args  = @_;
        @_ = @args{ @fields };
    }

    $_[1] ||= 0;
    pop @_ while @_ && ! defined $_[-1];
    $class->_XS_open(@_);
}

sub load {
    my $self = shift;
    if (@_ == 1) {
        if(ref $_[0] eq 'HASH') {
            @_ = ($_[0]->{path});
        }
    } elsif (@_ > 1) {
        my %args  = @_;
        @_ = ($args{path});
    }

    $self->_XS_load(@_);
}

sub send {
    my $self = shift;

    my @fields = qw(str flags);
    if (@_ == 1) {
        if(ref $_[0] eq 'HASH') {
            @_ = ($_[0]->{path});
        }
    } elsif (@_ != 2) {
        my %args  = @_;
        @_ = @args{ @fields };
    }

    $self->_XS_send(@_);
}

sub info_get {
    my $self = shift;
    my $info = $self->_XS_info_get();
    if ( wantarray ) {
        my @fields = qw(fd com_status com_info);
        return map { $info->$_ } @fields;
    }
    return $info;
}

1;

__END__

=head1 NAME

Senna::Ctx - Senna Ctx

=head1 METHODS

=head2 open

=head2 connect

=head2 load

=head2 send

=head2 close

=head2 info_get

=head2 recv

=cut
