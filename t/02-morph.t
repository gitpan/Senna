#!perl
#
# $Id: 02-morph.t 40 2005-11-15 09:14:44Z daisuke $
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

use strict;
use Test::More qw(no_plan); #(tests => 5);
use File::Spec;

BEGIN
{
    use_ok("Senna::Index", ':all');
}

my $index_name = 'test-morph.db';
my $path       = File::Spec->catfile('t', $index_name);
my $index      = Senna::Index->create($path, SEN_VARCHAR_KEY);
my ($r, $c);

ok($index, 'create()');

$r = $index->put("file1", "東京都");

$c = $index->search("東京");
ok($c, 'search() 1');
is($c->hits, 1, 'hits() 1');

$c = $index->search("京都");
ok($c, 'search() 2');
is($c->hits, 0, 'hits() 2');	# 形態素解析ではヒットしないはず

ok($index->remove(), 'remove()');
