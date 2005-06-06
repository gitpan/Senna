# $Id: Result.pm 22 2005-06-06 06:23:35Z daisuke $
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

__END__

=head1 NAME

Senna::Result - Senna Search Result 

=head1 SYNOPSIS

  my $r = $cursor->next;
  $r->key;
  $r->score;

=head1 DESCRIPTION

Senna::Result represents a single Senna search result.

=head1 METHODS

=head2 new

Create a new Senna::Result object. You normally do not need to call this
yourself, as a result object will be returned from a Senna::Cursor.

=head2 key

Returns the key value of the search hit.

=head2 score

Returns the score of the search hist.

=head1 AUTHOR

Copyright (C) 2005 by Daisuke Maki <dmaki@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

Development funded by Brazil Ltd. E<lt>http://dev.razil.jp/projects/senna/E<gt>

=head1 SEE ALSO

http://dev.razil.jp/projects/senna - Senna Development Homepage

=cut