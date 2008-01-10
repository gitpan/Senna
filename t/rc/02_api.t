use strict;
use Test::More (tests => 5);

BEGIN
{
    use_ok("Senna");
    use_ok("Senna::Constants", qw(SEN_RC_SUCCESS));
}

my $rc = Senna::RC->new(SEN_RC_SUCCESS);
isa_ok($rc, "Senna::RC");
ok($rc);
is($rc . "", SEN_RC_SUCCESS);

