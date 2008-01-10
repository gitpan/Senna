use strict;
use Test::More (tests => 2);

BEGIN
{
    use_ok("Senna");
}

can_ok("Senna::DB", qw(create open close DESTROY));
