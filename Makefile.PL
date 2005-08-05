# $Id: Makefile.PL 38 2005-08-05 04:27:58Z daisuke $
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.
use strict;
use 5.006001;
use ExtUtils::MakeMaker;

use vars qw(%MyArgs);

my $debugging = 0;
for(my $i = 0; $i < @ARGV; $i++) {
    if ($ARGV[$i] =~ /^--debugging$/) {
        splice(@ARGV, $i, 1);
        $debugging = 1;
        $i--;
    }
}

my $config = do "check_version.pl";

my %INFO = (
    ABSTRACT     => 'Interface to Senna search engine',
    AUTHOR       => 'Daisuke Maki <dmaki@cpan.org>',
    NAME         => 'Senna',
    VERSION_FROM => 'lib/Senna.pm',
    OBJECT       => '$(O_FILES)',
    DEFINE       => "-DHAVE_UTF8",
);
$INFO{OPTIMIZE} = '-g' if $debugging;

WriteMakefile(
    %INFO,
    (map { (
        $_ => ref($config->{$_}) eq 'ARRAY' ?
            join(" ", @{$config->{$_}}) : $config->{$_}
    ) } keys %$config),
    %MyArgs
);


