# $Id: Index.pm 42 2006-04-02 12:29:52Z daisuke $
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
            SEN_INDEX_DELIMITED
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

Senna::Index is an interface to the index struct in Senna (http://dev.razil.jp/project/senna).

=head1 METHODS

=head2 create($path[, $key_size, $flags, $n_segment, $encoding)

Creates a new senna index in a file specified by $path.

$key_size specifies the key size of the index. Currently Senna::Index only
supports 

  SEN_VARCHAR_KEY
  SEN_INT_KEY

default is SEN_VARCHAR_KEY. Once you create an index with one, you must keep
supplying that type for the key. The default VARCHAR key will actually allow
you to specify any type of strigify-able variable as the key, but if generally
INT keys are slightlly faster.

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

=head2 key_size()

Returns the interger size of the underlying senna index.

=head2 search($query)

Performs a fulltext search on the opened index. Returns a Senna::Cursor

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

Development funded by Brazil Ltd. E<lt>http://dev.razil.jp/project/senna/E<gt>

=head1 SEE ALSO

http://dev.razil.jp/project/senna - Senna Development Homepage

=cut