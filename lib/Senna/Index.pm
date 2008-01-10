# $Id: /mirror/coderepos/lang/perl/Senna/trunk/lib/Senna/Index.pm 37708 2008-01-02T14:49:19.475826Z daisuke  $
#
# Copyright (c) 2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package Senna::Index;
use strict;
use warnings;
use Senna::Index::Info;
use Senna::Records;
use Senna::Record;

sub create
{
    my $class = shift;

    my @fields = qw(path key_size flags initial_n_segments encoding);
    my $count = scalar @_;
    if ($count == 1) {
        if (ref $_[0] eq 'HASH') {
            @_ = map { $_[0]->{$_} } @fields;
        }
    } elsif ($count != 5) {
        my %args  = @_;
        @_ = @args{ @fields };
    }

    $_[1] ||= 0;
    pop @_ while @_ && ! defined $_[-1];
    $class->_XS_create(@_);
}

sub open
{
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

sub info
{
    my $self = shift;
    my $info = $self->_XS_info();
    if ( wantarray ) {
        my @fields = qw(key_size flags initial_n_segments encoding nrecords_keys file_size_keys nrecords_lexicon file_size_lexicon inv_seg_size inv_chunk_size);
        return map { $info->$_ } @fields;
    }
    return $info;
}

sub insert
{
    my $self = shift;
    if (@_ == 1 && ref $_[0] eq 'HASH') {
        @_ = ($_[0]->{key}, $_[0]->{value});
    } elsif (@_ > 2) {
        my %args = @_;
        @_ = ($args{key}, $args{value});
    }
    $self->_XS_insert(@_);
}

sub select
{
    my $self = shift;
    if (@_ == 1 && ref $_[0] eq 'HASH') {
        @_ = map { $_[0]->{$_} } qw(query records op optarg);
    } elsif (@_ > 1) {
        my %args = @_;
        @_ = @args{qw(query records op optarg)};
    }

    $self->_XS_select(@_);
}

1;

__END__

=head1 NAME

Senna::Index - Senna Index Object

=head1 SYNOPSIS

  use Senna;

  my $index = Senna::Index->create();
  my $index = Senna::Index->open($path);

  $index->insert($key, $value);
  $index->select($query);

=head1 METHODS

=head2 create

Creates a new index.

  my $index = Senna::Index->create(
    $path, $key_size, $flags, $initial_n_segments, $encoding
  );
  my $index = Senna::Index->create({
    path               => $path,
    key_size           => $key_size, 
    flags              => $flags,
    initial_n_segments => $initial_n_segments,
    encoding           => $encoding
  });

For backwards compatibility, if given anything other than 1 or 5 arguments,
create() assumes that you've been given a key value pair like so:

  my $index = Senna::Index->create(
    path               => $path,
    key_size           => $key_size, 
    flags              => $flags,
    initial_n_segments => $initial_n_segments,
    encoding           => $encoding
  );

However, note that this form is DEPRECATED. Use the HASHREF form instead

=head2 open

Opens an existing index.

  my $index = Senna::Index->open($path);
  my $index = Senna::Index->open({ path => $path });

For backwards compatibility, if given more than one argument, open() assumes
that you've been given a key value pair like so:

  my $index = Senna::Index->open(path => $path);

However, note that this form is DEPRECATED. Use the HASHREF form instead

=head2 info

In scalar context, returns a Senna::Index::Info object.

  $info = $index->info;
  $info->key_size();

In list context, returns the same informtion as a list:

  ($key_size, $flags, $initial_n_segments, $encoding, $nrecords_keys,
    $file_size_keys, $nrecords_lexicon, $file_size_lexicon, $inv_seg_size,
      $inv_chunk_size) = $index->info

=head2 path

Returns the path to the senna index.

=head2 close

=head2 remove

=head2 update

=head2 insert

Inserts a new entry in the index.

  $index->insert($key, $value);
  $index->insert({ key => $key, value => $value });

For backwards compatibility if given more than 2 arguments, insert() assumes 
that you've been given a key/value pair like so:

  $index->insert(key => $key, value => $value);

However, note that this form is DEPRECATED. Use the HASHREF form instead

=head2 select

Performs a select on the given index.

  $index->select( $query );
  $index->select({ query => $query });

=cut
