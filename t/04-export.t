use strict;
use Test::More (tests => 2);

BEGIN
{
    use_ok("Senna", ":all");
}

eval "SEN_ENC_UTF8";
ok(!$@);

1;