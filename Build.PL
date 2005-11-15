#!perl
# $Id: Build.PL 40 2005-11-15 09:14:44Z daisuke $
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

        my $copy_mtime = (stat('lib/Senna.xs'))[9];
        my $orig_mtime = (stat('Senna.xs'))[9];
        if (defined $copy_mtime && $copy_mtime <= $orig_mtime) {
            unlink 'lib/Senna.c' if -f 'lib/Senna.c';
        }
        $self->SUPER::ACTION_build(@_);
    }

    sub ACTION_disttest
    {
        my $self = shift;
        local $ENV{PERL_TESTPOD} = 1;
        $self->SUPER::ACTION_disttest(@_);
    }

    sub find_test_files
    {
        my $self  = shift;
        my $tests = $self->SUPER::find_test_files(@_);

        return $tests if $ENV{PERL_TESTPOD};
        return [ grep { $_ !~ /\bpod.*\.t\z/ } @$tests ];
    }
EOSUB
my $build = $class->new(%args);
$build->create_build_script;