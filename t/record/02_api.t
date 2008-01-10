use strict;
use Test::More (tests => 2);

BEGIN
{
    use_ok("Senna::Record");
}

can_ok("Senna::Record", qw(new key score post section n_subrecs));
