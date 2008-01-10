# $Id: /mirror/coderepos/lang/perl/Senna/trunk/lib/Senna/Snippet.pm 38386 2008-01-10T08:02:17.639836Z daisuke  $
#
# Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package Senna::Snippet;
use strict;
use warnings;

sub open
{
    my $class = shift;
    if ($_[0] eq 'HASH') {
        my $args = $_[0];
        @_ = map { $args->{$_} } qw(encoding flags width max_results tags);
    } else {
        my %args = @_;
        @_ = map { $args{$_} } qw(encoding flags width max_results tags);
    }

    $class->_XS_open(@_);
}

*new = \&open;

sub add_cond
{
    my $self = shift;
    if ($_[0] eq 'HASH') {
        my $args = $_[0];
        @_ = map { $args->{$_} } qw(keyword tags);
    } else {
        my %args = @_;
        @_ = map { $args{$_} } qw(keyword tags);
    }

    $self->_XS_add_cond(@_);
}

sub exec
{
    my $self = shift;
    if ($_[0] eq 'HASH') {
        my $args = $_[0];
        @_ = map { $args->{$_} } qw(string);
    } else {
        my %args = @_;
        @_ = map { $args{$_} } qw(string);
    }

    $self->_XS_exec(@_);
}

1;

__END__

=head1 NAME

Senna::Snippet - Wrapper for sen_snip

=head1 SYNOPSIS

  my $snippet = Senna::Snippet->new({
    encoding    => $encoding
    flags       => $flags
    width       => $width,
    max_results => $max_results,
    tags        => [ $opentag, $closetag ]
  });

  $snippet->exec({ string => $string });
  while (my $snip = $snippet->next) {
     ...
  }

=head1 METHODS

=head2 add_cond

=head2 close

=head2 exec

=head2 get_result

=head2 new

=head2 next

=head2 open

=head2 rewind

=cut
