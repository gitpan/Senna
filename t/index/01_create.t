use strict;
use Test::More (tests => 5);
use File::Temp;

BEGIN
{
    use_ok("Senna");
}

{
    my $temp  = File::Temp->new( UNLINK => 1 );
    my $index = Senna::Index->create({ path => $temp->filename });
    ok( $index );
    isa_ok( $index, "Senna::Index" );
    is( $index->path, $temp->filename );
    ok( $index->close);
}
