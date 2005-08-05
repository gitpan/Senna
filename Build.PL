#!perl
# $Id: Build.PL 38 2005-08-05 04:27:58Z daisuke $
#
# Copyright (c) 2005 Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

use strict;
use Module::Build;
use vars qw(%MyArgs);

my $debugging = 0;
foreach (@ARGV) {
    /^--debugging$/ and $debugging = 1;
}

my $config = require "check_version.pl";

$config->{INC} ||= [];
push @{$config->{INC}}, '-g' if $debugging;

my %args = (
    dist_name => 'Senna',
    dist_version_from => 'lib/Senna.pm',
    license => 'lgpl',
    c_source => '.',
    xs_files => {
        'Senna.xs' => 'lib/Senna.xs'
    },
    extra_compiler_flags => $config->{INC},
    extra_linker_flags => $config->{LIBS}
);

my $class = Module::Build->subclass(code => <<'EOSUB');
    sub ACTION_build {
        my $self = shift;
        unlink 'lib/Senna.c' if -f 'lib/Senna.c';
        $self->SUPER::ACTION_build(@_);
    }
EOSUB
my $build = $class->new(%args);
$build->create_build_script;