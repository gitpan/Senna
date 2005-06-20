# $Id: Index.pm 25 2005-06-20 01:39:16Z daisuke $
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

package Senna::Index;
use strict;
use base qw(Exporter);
our $VERSION = '0.03';
our(@EXPORT_OK, %EXPORT_TAGS);

our @ISA = qw(Exporter);
BEGIN
{
    my %tags = (
        key_size => [ qw(
            SEN_VARCHAR_KEY
            SEN_INT_KEY
        ) ],
        flags => [ qw(
            SEN_INDEX_NORMALIZE
            SEN_INDEX_SPLIT_ALPHA
            SEN_INDEX_SPLIT_DIGIT
            SEN_INDEX_SPLIT_SYMBOL
            SEN_INDEX_NGRAM
        ) ],
        encoding => [ qw(
            SEN_ENC_DEFAULT
            SEN_ENC_NONE
            SEN_ENC_EUCJP
            SEN_ENC_UTF8
            SEN_ENC_SJIS
        ) ]
    );
    $EXPORT_TAGS{all} = [];
    while (my($tag, $symbols) = each %tags) {
        $EXPORT_TAGS{$tag} = $symbols;
        push @{$EXPORT_TAGS{all}}, @$symbols;
    }
    Exporter::export_ok_tags('all', keys %tags);
}
use Senna;
use Senna::Cursor;

sub _new
{
    my $class = shift;

    my $self  = bless {}, $class;
    $self->_alloc_senna_state();
    return $self;
}

sub create
{
    my $class = shift;
    my $obj   = $class->_new();
    if ($obj->_create(@_)) {
        return $obj;
    } else {
        return undef;
    }
}

sub open
{
    my $class = shift;
    my $obj   = $class->_new();
    if ($obj->_open(@_)) {
        return $obj;
    } else {
        return undef;
    }
}

__END__

=head1 NAME

Senna::Index - Interface to Senna's Index

=head1 SYNOPSIS

  use Senna::Index;
  # Export SEN_INDEX_* constants
  use Senna::Index qw(:flags);

  my $index = Senna::Index->open($path);
  # or
  my $index = Senna::Index->create($path, $flags, $n_segment, $encoding);

  $index->close();
  $index->put($key, $value);
  $index->del($key, $value);
  $index->replace($key, $old_value, $new_value);

  my $cursor = $index->search($query);
  while (my $result = $cursor->fetch_next()) {
     $result->key();
     $result->score();
  }

  while ($cursor->next) { # or $cursor->rewind
     my $key = $cursor->key;
     my $score = $cursor->score;
  }

  $index->remove();

=head1 DESCRIPTION

Senna::Index is an interface to the index struct in Senna (http://dev.razil.jp/projects/senna).

=head1 METHODS

=head2 create($path[, $key_size, $flags, $n_segment, $encoding)

Creates a new senna index in a file specified by $path.

$key_size specifies the key size of the index. Currently Senna::Index only
supports 

  SEN_VARCHAR_KEY
  SEN_INT_KEY

default is SEN_VARCHAR_KEY.

$flags is a bit mask, which can be a combination of 

  SEN_INDEX_NORMALIZE
  SEN_INDEX_NGRAM
  SEN_INDEX_SPLIT_ALPHA
  SEN_INDEX_SPLIT_DIGIT
  SEN_INDEX_SPLIT_SYMBOL

$encoding can be one of 

  SEN_ENC_DEFAULT
  SEN_ENC_NONE
  SEN_ENC_EUCJP
  SEN_ENC_UTF8
  SEN_ENC_SJIS

These constants are available from Senna::Index. See L<CONSTANTS|CONSTANTS>.

Note that senna actually creates several files for a given index. Given an
index filename "senna", it will create the following files:

  senna.SEN
  senna.SEN.i
  senna.SEN.i.c
  senna.SEN.l

Refer to the senna documentation for details.

=head2 open($path)

Opens an existing senna index file.

=head2 close

Closes the current senna index files. Returns true on success, false
otherwise.

=head2 put($key, $value)

Adds a new entry into the senna index file. Returns true on success,
false otherwise.

=head2 del($key, $value)

Removes an existing entry from the senna index file. Returns true on 
success, false otherwise. Note that you need to give the previous value of
the key for the index to correctly recoginize the changes.

=head2 replace($key, $oldval, $newval)

Replaces the index that $key is pointing to from $oldval to $newval.
Note that you need to give the previous value of the key for the index to
correctly recoginize the changes.

=head2 remove()

Removes the index file opened in the current index.

=head2 filename(), keys_size(), flags(), initial_n_segments(), encoding()

Retrieves the index's filename, key_size, flags, initial_n_segments, encoding,
respectively

=head1 CONSTANTS

Constants can are available by importing them:

  use Senna::Index qw(:key_size);
  use Senna::Index qw(:flags);
  use Senna::Index qw(:encoding);
  use Senna::Index qw(:all);

C<:key_size> exports SEN_VARCHAR_KEY and SEN_INT_KEY.

C<:flags> exports SEN_INDEX_NORMALIZE, SEN_INDEX_NGRAM, SEN_INDEX_SPLIT_ALPHA,
SEN_INDEX_SPLIT_DIGIT, SEN_INDEX_SPLIT_SYMBOL.

C<:encoding> exports SEN_ENC_DEFAULT, SEN_ENC_NONE, SEN_ENC_EUCJP, SEN_ENC_UTF8,
SEN_ENC_SJIS.

=head1 AUTHOR

Copyright (C) 2005 by Daisuke Maki <dmaki@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

Development funded by Brazil Ltd. E<lt>http://dev.razil.jp/projects/senna/E<gt>

=head1 SEE ALSO

http://dev.razil.jp/projects/senna - Senna Development Homepage

=cut