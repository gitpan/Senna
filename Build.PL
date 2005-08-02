#!perl
# $Id: Build.PL 36 2005-08-02 11:16:47Z daisuke $
#
# Copyright (c) 2005 Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

use strict;
use Module::Build;
use vars qw(%MyArgs);

my $config = require "check_version.pl";

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

my $build = Module::Build->new(%args);
$build->create_build_script;