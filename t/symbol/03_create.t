use strict;
use Test::More (tests => 6);
use File::Temp;

BEGIN
{
    use_ok("Senna");
}

{
    my $temp   = File::Temp->new( UNLINK => 1 );
    my $symbol = Senna::Symbol->create({ path => $temp->filename });
    ok( $symbol );
    isa_ok( $symbol, "Senna::Symbol" );

    is( $symbol->path, $temp->filename );

    my $info = $symbol->info;
    # XXX - TODO
    ok($info);
    ok( $symbol->close);
}
