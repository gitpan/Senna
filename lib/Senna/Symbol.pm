# $Id: /mirror/coderepos/lang/perl/Senna/trunk/lib/Senna/Symbol.pm 37709 2008-01-02T14:54:25.157242Z daisuke  $
#
# Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package Senna::Symbol;
use strict;
use warnings;
use Senna::Symbol::Info;
use Senna::Constants qw(SEN_ENC_DEFAULT);

sub create
{
    my $class = shift;

    my @fields = qw(path key_size flags encoding);
    my $count = scalar @_;
    if ($count == 1) {
        if (ref $_[0] eq 'HASH') {
            @_ = map { $_[0]->{$_} } @fields;
        }
    } elsif ($count != 4) {
        my %args  = @_;
        @_ = @args{ @fields };
    }

    $_[1] ||= 0;
    $_[2] ||= 0;
    $_[3] ||= SEN_ENC_DEFAULT;
    $class->_XS_create(@_);
}

1;

__END__

=head1 NAME

Senna::Symbol - Senna Symbol Object (sen_sym)

=head1 SYNOPSIS

  use Senna;

  my $index = Senna::Index->create();
  my $index = Senna::Index->open($path);

  $index->insert($key, $value);
  $index->select($query);

=head1 METHODS

=head2 create

Creates a new sen_sym.

  my $index = Senna::Symbol->create(
    $path, $key_size, $flags, $encoding
  );
  my $index = Senna::Symbol->create({
    path               => $path,
    key_size           => $key_size, 
    flags              => $flags,
    encoding           => $encoding
  });

For backwards compatibility, if given anything other than 1 or 4 arguments,
create() assumes that you've been given a key value pair like so:

  my $index = Senna::Symbol->create(
    path               => $path,
    key_size           => $key_size, 
    flags              => $flags,
    encoding           => $encoding
  );

However, note that this form is DEPRECATED. Use the HASHREF form instead

=head2 path

=head2 info

  my $info = $symbol->info();

=head2 get

=head2 remove

=head2 close

=cut
