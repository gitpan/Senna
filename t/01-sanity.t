#!perl
#
# $Id$
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

use strict;
use Test::More (tests => 31);
use File::Spec;

BEGIN
{
    use_ok("Senna::Index", ':all');
}

ok(SEN_INDEX_NORMALIZE);
ok(SEN_INDEX_SPLIT_ALPHA);
ok(SEN_INDEX_SPLIT_DIGIT);
ok(SEN_INDEX_SPLIT_SYMBOL);
ok(SEN_INDEX_NGRAM);

is(SEN_ENC_DEFAULT, 0);
ok(SEN_ENC_NONE);
ok(SEN_ENC_EUCJP);
ok(SEN_ENC_UTF8);
ok(SEN_ENC_SJIS);

my $index_name = 'test.db';
my $path       = File::Spec->catfile('t', $index_name);
my $index      = Senna::Index->create($path);

is($index->key_size, 0);
is($index->encoding, SEN_ENC_EUCJP);

$index->put("���ܸ�", "���ܸ�Ȥ��ǿ����񤭤ޤ���");

my $c = $index->search("���ܸ�");
ok($c);
isa_ok($c, 'Senna::Cursor');
is($c->hits, 1);

my $r = $c->next;
isa_ok($r, 'Senna::Result');
ok($c->rewind);

# now check when there are no hits
$c = $index->search("�����������ޤ���");
ok($c);
isa_ok($c, 'Senna::Cursor');
is($c->hits, 0);
ok(! $c->next);
ok(! $c->rewind);

$index->del("���ܸ�", "���ܸ�Ȥ��ǿ����񤭤ޤ���");
$c = $index->search("���ܸ�");
ok($c);
isa_ok($c, 'Senna::Cursor');
is($c->hits, 0);

# Now check for integer keys
$index->put(1, "���ͷ��Υ���");
$c = $index->search("���ͷ�");
ok($c);
isa_ok($c, 'Senna::Cursor');
is($c->hits, 1);
ok($index->del(1, "���ͷ��Υ���"));

ok($index->remove());
