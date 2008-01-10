# $Id: /mirror/coderepos/lang/perl/Senna/trunk/Makefile.PL 37675 2008-01-02T01:45:20.932525Z daisuke  $
#
# Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.
use strict;
use 5.008;
use ExtUtils::MakeMaker;

my $interactive = -t STDIN && (-t STDOUT || !(-f STDOUT || -c STDOUT)) ;
if ($ExtUtils::MakeMaker::VERSION < 6.25) {
    print <<EOM;
Versions of ExtUtils::MakeMaker < 6.25 (you have $ExtUtils::MakeMaker::VERSION)  executes
Build.PL if it finds one in the same directory.
I can circumvent this by removing Build.PL from the this tree and
deleting it from MANIFEST. 

Would you like me to proceed? [y]
EOM

    if ($interactive) {
        my $input = <STDIN>;
        chomp $input;
        if ($input !~ /^y(?:es)?$/i) {
            exit 1;
        }
    }

    unlink 'Build.PL';
    {
        local @ARGV = qw(MANIFEST);
        local $^I   = '';
        while (<>) {
            /^Build\.PL$/ and next;
            print;
        }
    }
}
    

my $debugging = 0;
for(my $i = 0; $i < @ARGV; $i++) {
    if ($ARGV[$i] =~ /^--debugging$/) {
        splice(@ARGV, $i, 1);
        $debugging = 1;
        $i--;
    }
}

my $config = do "tools/prompt.pl";

my($major, $minor, $micro) = split(/\./, $config->{version});
# Oh the hackery... this code is fragile.
my $n_version = $major + $minor / 100 + $micro / 100000;
if ($n_version < 1.00009) {
    print <<EOM;

You have senna version $config->{version}

Senna Perl binding requires at least senna version 1.0.9. Please install
the appropriate version before proceeding.

EOM
    exit 1;
}

link('typemap', 'lib/typemap');
link('lib/Senna.xs', 'Senna.xs');

my %INFO = (
    ABSTRACT     => 'Interface to Senna search engine',
    AUTHOR       => 'Daisuke Maki <daisuke@endeworks.jp>',
    NAME         => 'Senna',
    VERSION_FROM => 'lib/Senna.pm',
    PREREQ_PM    => {
        'Class::Accessor::Fast' => 0,
        'Encode'                => 0,
    },
    OBJECT       => '$(O_FILES)',
    LIBS         => [ $config->{libs} ],
    INC          => $config->{cflags} . " -Isrc",
    DEFINE       => join(" ",
        "-DSENNA_MAJOR_VERSION=$major",
        "-DSENNA_MINOR_VERSION=$minor",
        "-DSENNA_MICRO_VERSION=$micro",
        "-DSENNA_VERSION=$config->{version}"
    ),
    clean        => {
        FILES => "lib/typemap Senna.xs"
    },
    test         => {
        TESTS        => 't/*.t t/*/*.t'
    }
);
$INFO{OPTIMIZE} = '-g' if $debugging;

WriteMakefile(%INFO);


