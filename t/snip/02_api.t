use strict;
use Test::More (tests => 2);

BEGIN
{
    use_ok("Senna");
}

can_ok("Senna::Snippet", qw(new open close DESTROY exec add_cond));
