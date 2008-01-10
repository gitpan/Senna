use strict;
use File::Temp;
use Test::More (tests => 6);

BEGIN
{
    use_ok("Senna");
    use_ok("Senna::Constants", qw(SEN_RC_SUCCESS SEN_ENC_UTF8));
}

my $temp = File::Temp->new(UNLINK => 1);

{
    my $db = Senna::DB->create({
        path     => $temp->filename,
        encoding => SEN_ENC_UTF8,
    });
    isa_ok($db, 'Senna::DB');

    my $rc = $db->close;
    is($rc, SEN_RC_SUCCESS);

    $db = Senna::DB->open({
        path => $temp->filename
    });
    isa_ok($db, 'Senna::DB');

    $rc = $db->close;
    is($rc, SEN_RC_SUCCESS);
}

