# $Id: /mirror/Senna-Perl/Makefile.PL 2725 2006-08-17T05:41:38.060980Z daisuke  $
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.
use strict;
use 5.006001;
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

my %INFO = (
    ABSTRACT     => 'Interface to Senna search engine',
    AUTHOR       => 'Daisuke Maki <dmaki@cpan.org>',
    NAME         => 'Senna',
    VERSION_FROM => 'lib/Senna.pm',
    OBJECT       => '$(O_FILES)',
    LIBS         => [ split(/\s+/, $config->{libs}) ],
    INC          => $config->{cflags},
    DEFINE       => join(" ",
        "-DSENNA_MAJOR_VERSION=$major",
        "-DSENNA_MINOR_VERSION=$minor",
        "-DSENNA_MICRO_VERSION=$micro",
        "-DSENNA_VERSION=$config->{version}"
    )
);
$INFO{OPTIMIZE} = '-g' if $debugging;

WriteMakefile(%INFO);


