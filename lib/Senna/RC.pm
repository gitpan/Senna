# $Id: /mirror/coderepos/lang/perl/Senna/trunk/lib/Senna/RC.pm 37708 2008-01-02T14:49:19.475826Z daisuke  $
#
# Copyright (c) 2005-2008 Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

package Senna::RC;
use strict;
use Senna::Constants;
use overload
    '""'       => \&value,
    '0+'       => \&value,
    'bool'     => \&_to_bool,
    'fallback' => 1
;

sub new
{
    my $class = shift;
    my $value = shift;
    return bless \$value, $class;
}

sub value   { ${$_[0]} }
sub _to_bool { ${$_[0]} == &Senna::Constants::SEN_RC_SUCCESS }

1;

__END__

=head1 NAME

Senna::RC - Wrapper for sen_rc

=head1 SYNOPSIS

  use Senna::RC;
  use Senna::Constants qw(SEN_SUCCESS);

  my $rc = Senna::RC->new(SEN_SUCCESS);
  if ($rc) {
     print "success!\n";
  }

  $rc->value;

=head1 DESCRIPTION

Senna::RC is a simple wrapper around sen_rc that allows you to evaluate
results from Senna functions in Perl-ish boolean context, like

  if ($index->insert($query)) {
    ...
  }

Or, you can choose to access the internal sen_rc value:

  my $rc = $index->insert($query);
  if ($rc->value == SEN_SUCCESS) {
    ...
  }

=head1 METHODS

=head2 new

Creates a new Senna::RC object

=head2 value

Returns the internal sen_rc value

=cut
