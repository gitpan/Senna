use strict;
use Test::More (tests => 3);

BEGIN
{
    use_ok("Senna");
}

my $h = Senna::info();
isa_ok($h, 'HASH');
ok( exists $h->{version}, "version is $h->{version}" );

