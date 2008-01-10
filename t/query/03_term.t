use strict;
use Test::More;
use Senna;

BEGIN
{
    if (&Senna::Constants::LIBSENNA_MAJOR_VERSION <= 1 &&
        &Senna::Constants::LIBSENNA_MINOR_VERSION <= 1 &&
        &Senna::Constants::LIBSENNA_MINOR_VERSION < 10)
    {
        plan(skip_all => "Requires libsenna > 1.0.10");
    } else {
        plan(tests => 5);
    }
}

my $query = Senna::Query->new({
    query => "*D+E-7W1:2,2:5,3:10,4:40 foo bar baz"
});
ok($query);

my $callback_count = 0;
my $callback = sub {
print STDERR "@_\n";
    my $v = shift;
    like($v, qr/(?:foo|bar|baz)/);
    $callback_count++;
};
$query->term($callback);
is($callback_count, 3);