use strict;
use File::Temp;
use Test::More (tests => 13);

BEGIN
{
    use_ok("Senna");
    use_ok("Senna::Constants", qw(SEN_RC_SUCCESS SEN_ENC_UTF8 SEN_CTX_USEQL
            SEN_CTX_BATCHMODE SEN_CTX_MORE));
}

my $temp = File::Temp->new(UNLINK => 1);

{
    my $db = Senna::DB->create({
        path     => $temp->filename,
        flags    => 0,
        encoding => SEN_ENC_UTF8,
    });
    isa_ok($db, 'Senna::DB');

    my $ctx = Senna::Ctx->open({
        db    => $db,
        flags => SEN_CTX_USEQL,
    });
    isa_ok($ctx, 'Senna::Ctx');

    # just test for lisp interpreter
    my $rc = $ctx->send(<<'    END_QL');
    (+ 1 1)
    END_QL
    is($rc, SEN_RC_SUCCESS);

    my $data = $ctx->recv;
    ok($data);
    chomp $data;
    is($data, '2');

    $rc = $ctx->send(<<'    END_QL');
    (car '(a b c))
    END_QL
    is($rc, SEN_RC_SUCCESS);

    $data = $ctx->recv;
    chomp $data;
    is($data, 'a');

    my $info = $ctx->info_get;
    isa_ok($info, 'Senna::Ctx::Info');
    ok($info->fd);
    ok($info->com_status >= 0);
    ok($info->com_info >= 0);
}

