use strict;
use Test::More (tests => 2);

BEGIN
{
    use_ok("Senna");
}

can_ok("Senna::Snippet", "open");