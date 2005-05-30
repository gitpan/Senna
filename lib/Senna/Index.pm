# $Id: Index.pm 10 2005-05-30 08:02:12Z daisuke $
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

package Senna::Index;
use strict;
use base qw(Exporter);
our $VERSION = '0.02';
our(@EXPORT_OK, %EXPORT_TAGS);

our @ISA = qw(Exporter);
BEGIN
{
    my %tags = (
        flags => [ qw(
            SEN_INDEX_NORMALIZE
            SEN_INDEX_SPLIT_ALPHA
            SEN_INDEX_SPLIT_DIGIT
            SEN_INDEX_SPLIT_SYMBOL
            SEN_INDEX_NGRAM
        ) ],
    );
    while (my($tag, $symbols) = each %tags) {
        $EXPORT_TAGS{$tag} = $symbols;
    }
    Exporter::export_ok_tags(keys %tags);
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

=cut