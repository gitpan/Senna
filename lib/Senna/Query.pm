# $Id: /mirror/coderepos/lang/perl/Senna/trunk/lib/Senna/Query.pm 37744 2008-01-04T01:19:42.543660Z daisuke  $
#
# Copyright (c) 2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package Senna::Query;
use strict;
use warnings;
use Senna::Constants qw(SEN_SEL_OR SEN_ENC_DEFAULT);

sub open
{
    my $class = shift;
    my $len = scalar @_;
    if ($len == 1) {
        if (ref $_[0] eq 'HASH') {
            @_ = map { $_[0]->{$_} } qw(query default_op max_exprs encoding)
        }
    }  else {
        my %args = @_;
        if (my $query = delete $args{str}) {
            $args{query} = $query;
        }
        @_ = @args{ qw(query default_op max_exprs encoding) };
    }

    $_[1] ||= SEN_SEL_OR;
    $_[2] ||= 256;
    $_[3] ||= SEN_ENC_DEFAULT;
    $class->_XS_open(@_);
}

*new = \&open;

sub exec
{
    my $self = shift;
    my $len = scalar @_;
    if ($len == 1) {
        if (ref $_[0] eq 'HASH') {
            @_ = map { $_[0]->{$_} } qw(index records operator)
        }
    }  else {
        my %args = @_;
        @_ = @args{ qw(index records operator) };
    }

    $_[2] ||= SEN_ENC_DEFAULT;
    $self->_XS_exec(@_);
}

1;

=head1 NAME

Senna::Query - Senna Query (sen_query)

=head1 METHODS

=head2 open

=head2 new

Creates a new Senna::Query instance.

  my $query = Senna::Query->new({
    query      => "...",
    default_op => SEN_SEL_OR,
    max_exprs  => 256,
    encpding   => SEN_ENC_DEFAULT
 });

C<new()> is a synonym for C<open()>.

=head2 close

=head2 exec

  my $index   = Senna::Index->open(...);
  my $query   = Senna::Query->open(...);
  my $records = Senna::Records->open(...);
  my $rc      = $query->exec({
    index    => $index,
    records  => $records,
    operator => SEN_SEL_OR
  });

=head2 rest

=head2 snip

  my $snip = $query->snip({
    flags        => $flags,
    width        => $width,
    max_results  => $max_results,
    tags         => [ [ '<foo>', '</foo>' ] ],
    snip_mapping => ???
  });

WARNING: This method hasn't been prorperly tested. Use at your own peril.

=head2 term

WARNING: This method has been reported broken as of libsenna 1.0.9 (see
mailing list thread). It has been reported as "fixed", but no official
release confirms this as of yet.

=cut