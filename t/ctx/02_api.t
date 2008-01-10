use strict;
use Test::More (tests => 2);

BEGIN
{
    use_ok("Senna");
}

can_ok("Senna::Ctx", qw(open connect close DESTROY load send recv));
