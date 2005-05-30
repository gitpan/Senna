# $Id: Makefile.PL 9 2005-05-30 06:43:26Z daisuke $
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

use 5.006001;
use Config;
use ExtUtils::MakeMaker;

my %INFO = (
    ABSTRACT     => 'Interface to Senna search engine',
    AUTHOR       => 'Daisuke Maki <dmaki@cpan.org>',
    NAME         => 'Senna',
    VERSION_FROM => 'lib/Senna.pm',
    OBJECT       => '$(O_FILES)',
);

# read extra configurations from the command line
while ($_ = shift) {
    my($key, $val) = split(/=/, $_, 2);
    $config{$key} = $val;
}

$config{DEFINE} .= " -DHAVE_UTF8";
$config{LIBS}   .= " -lsenna";

WriteMakefile(
    %INFO,
    %config
);
