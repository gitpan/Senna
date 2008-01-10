use strict;
use Test::More (tests => 2);

BEGIN
{
    use_ok("Senna");
}

can_ok("Senna::Query", qw(open close DESTROY exec term snip rest));
