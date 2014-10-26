#!perl
#
# $Id: 03-ngram.t 32 2005-06-24 00:38:36Z daisuke $
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

my $index_name = 'test-ngram.db';
my $path       = File::Spec->catfile('t', $index_name);
my $index      = Senna::Index->create($path, SEN_VARCHAR_KEY, SEN_INDEX_NGRAM);
my ($r, $c);

ok($index, 'create()');

$r = $index->put("file1", "�ޤ������ܸ����");
#ok($r, 'put()');

$c = $index->search("���ܸ�");
ok($c, 'search() 1');
is($c->hits, 1, 'hits() 1');

$c = $index->search("�ܸ�");
ok($c, 'search() 2');
is($c->hits, 1, 'hits() 2');	# n-gram �ʤ�ҥåȤ���Ϥ�

ok($index->remove(), 'remove()');
