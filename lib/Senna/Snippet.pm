# $Id: /mirror/Senna-Perl/lib/Senna/Snippet.pm 2738 2006-08-17T19:02:18.939501Z daisuke  $
#
# Copyright (c) 2005-2006 Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

package Senna::Snippet;
use strict;

*new = \&open;
sub open
{
    my $class = shift;
    my %args  = @_;
    $class->xs_open(@args{qw(encoding flags width max_results defaultopentag defaultclosetag mapping)});
 
}

sub add_cond
{
    my $self = shift;
    my %args = @_;
    $self->xs_add_cond(@args{qw(keyword opentag closetag)});
}

sub exec
{
    my $self = shift;
    my %args = @_;
    $self->xs_exec(@args{qw(string)});
}

1;

__END__

=head1 NAME

Senna::Snippet - Wrapper Around sen_snip

=head1 METHODS

=head2 new
=head2 open
=head2 add_cond
=head2 exec
=head2 close

=head1 AUTHOR

Copyright (C) 2005 - 2006 by Daisuke Maki <dmaki@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

Development funded by Brazil Ltd. E<lt>http://dev.razil.jp/project/senna/E<gt>

=cut
