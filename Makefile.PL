# $Id: Makefile.PL 30 2005-06-23 02:23:48Z daisuke $
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.
use strict;
use 5.006001;
use Config;
use ExtUtils::MakeMaker;
use File::Spec;

my %INFO = (
    ABSTRACT     => 'Interface to Senna search engine',
    AUTHOR       => 'Daisuke Maki <dmaki@cpan.org>',
    NAME         => 'Senna',
    VERSION_FROM => 'lib/Senna.pm',
    OBJECT       => '$(O_FILES)',
);

my @BLACKLIST = (
    [0,0,0]
);

my %config;

# read extra configurations from the command line
while ($_ = shift) {
    my($key, $val) = split(/=/, $_, 2);
    $config{$key} = $val;
}

my $DEBUG = delete $config{DEBUG};
my $DEVNULL = '/dev/null';

# Look for senna-cfg. We do NOT support senna that doesn't have a senna-cfg
# (which was the norm)
my $senna_cfg;
my @dirs = qw(/usr/local /usr /opt);
foreach my $path (map { File::Spec->catfile($_, 'senna-cfg') } @dirs) {
    if (-x $path) {
        $senna_cfg = $path;
        last;
    }
}

if (!$senna_cfg) {
    my $path = prompt("Could not find senna-cfg in known locations.\nPlease specify the location of your senna-cfg:");
    if (!$path) {
        die "no senna-cfg. aborting";
    }

    if (! -x $path) {
        die "$path is not executable!";
    }
    $senna_cfg = $path;
}

eval {
    try_libconfig($senna_cfg, \%config, @BLACKLIST);
};
if ($@) {
    if ($@ =~ /^VERSION/) {
        die << '        EOMSG';
        The installed version of senna is not known to work.
        EOMSG
    } elsif ($@ =~ /^UNTESted/) {
        warn << '        EOMSG';
        The installed version of senna was not tested with this version of Senna.

        Senna may fail to build ro some tests may not pass.
        EOMSG
    }

    if (! defined $config{LIBS} && ! defined $config{INC}) {
        $config{LIBS} = '-L/usr/local/lib -L/usr/lib -lsenna';
        $config{INC}  = '-I/usr/local/include -I/usr/include';
        warn "using fallback values for LIBS and INC\n\n" .
        "options:\n" .
        "  LIBS='$config{LIBS}'\n" .
        "  INC='$config{INC}'\n" .
        "If this is wrong, Re-run as:\n" .
        "  \$ $^X Makefile.PL LIBS='-L/path/to/lib -lsenna' INC='-I/path/to/include'"
    }
}
$config{DEFINE} .= " -DHAVE_UTF8";
$config{LIBS}   .= " -lsenna";

WriteMakefile(
    %INFO,
    %config
);


# Things below here are ripped right out of XML::LibXML Makefile.PL

sub backtick {
    my $command = shift;
    if ($DEBUG) {
        print $command, "\n";
        my $results = `$command`;
        chomp $results;
        if ($? != 0) {
            die "backticks call to '$command' failed";
        }
        return $results;
    }
    open(OLDOUT, ">&STDOUT");
    open(OLDERR, ">&STDERR");
    open(STDOUT, ">$DEVNULL");
    open(STDERR, ">$DEVNULL");
    my $results = `$command`;
    my $retval = $?;
    open(STDOUT, ">&OLDOUT");
    open(STDERR, ">&OLDERR");
    if ($retval != 0) {
        die "backticks call to '$command' failed";
    }
    chomp $results;
    return $results;
}

sub try_libconfig {
    my $cfgscript = shift;
    my $config = shift;
    my @bl = @_;

    my $state = undef; # there are three possible states:
                       # 1     : works
                       # 0     : works not
                       # undef : not yet tested

    my $ver = backtick("$cfgscript --version");
    if ( defined $ver ) {
        my ( $major, $minor, $point) = $ver =~ /(\d+).(\d+)\.(\d+)/g;
        foreach ( @bl ) {
            $state = $_->[3];
            last if $major <  $_->[0];
            next if $major >  $_->[0];
            last if $minor <  $_->[1];
            next if $minor >  $_->[1];
            last if $point <= $_->[2];
            $state = undef;
        }
        if ( defined $state and $state == 0 ) {
            print "failed\n";
            die "VERSION $ver";
        }

        $config->{LIBS} = backtick("$cfgscript --libs");
        $config->{INC}  = backtick("$cfgscript --cflags");

        unless ( defined $state ) {
            print "untested\n";
            die "UNTESTED $ver";
        }

        print "ok\n";
    }
    else {
        print "failed\n";
        die "FAILED\n"; # strange error
    }
}
