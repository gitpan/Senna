use strict;
use Test::More (tests => 5);

BEGIN
{
    use_ok("Senna");
    use_ok("Senna::Encoding", "enc2str");
    use_ok("Senna::Constants", qw(SEN_ENC_DEFAULT SEN_ENC_EUCJP));
}

is(enc2str(SEN_ENC_DEFAULT), "DEFAULT");
is(enc2str(SEN_ENC_EUCJP), "EUC-JP");
