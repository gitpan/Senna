use strict;
use Test::More (tests => 10);
use File::Temp;

BEGIN
{
    use_ok("Senna");
    use_ok("Senna::Constants", qw(SEN_ENC_DEFAULT));
}

{
    my $temp  = File::Temp->new( UNLINK => 1 );
    my $index = Senna::Index->create({ path => $temp->filename });
    ok( $index );
    isa_ok( $index, "Senna::Index" );
    is( $index->path, $temp->filename );

    my $info = $index->info;
    ok($info);
    is($info->flags, 0);

    ok( $index->close);

    $index = Senna::Index->open( path => $temp->filename );
    isa_ok( $index, "Senna::Index" );
    is( $index->path, $temp->filename );
}
