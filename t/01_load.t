use strict;
use Test::More (tests => 1);

BEGIN
{
    use_ok("Senna");
}

print STDERR "You're using senna version ", &Senna::Constants::LIBSENNA_VERSION, "\n";
