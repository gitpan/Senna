# $Id: Makefile.PL 36 2005-08-02 11:16:47Z daisuke $
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.
use strict;
use 5.006001;
use ExtUtils::MakeMaker;

use vars qw(%MyArgs);

my $config = do "check_version.pl";

my %INFO = (
    ABSTRACT     => 'Interface to Senna search engine',
    AUTHOR       => 'Daisuke Maki <dmaki@cpan.org>',
    NAME         => 'Senna',
    VERSION_FROM => 'lib/Senna.pm',
    OBJECT       => '$(O_FILES)',
    DEFINE       => "-DHAVE_UTF8",
);

WriteMakefile(
    %INFO,
    (map { (
        $_ => ref($config->{$_}) eq 'ARRAY' ?
            join(" ", @{$config->{$_}}) : $config->{$_}
    ) } keys %$config),
    %MyArgs
);


