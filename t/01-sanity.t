#!perl
#
# $Id$
#
# Daisuke Maki <dmaki@cpan.org>
# All rights reserved.

use strict;
use Test::More (tests => 39);
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

is(SEN_VARCHAR_KEY, 0);
ok(SEN_INT_KEY);

my $index_name = 'test.db';
my $path       = File::Spec->catfile('t', $index_name);
my $index      = Senna::Index->create($path);
my $c;

is($index->key_size, 0);
is($index->encoding, SEN_ENC_EUCJP);

$index->put("日本語", "日本語とかで色々書きますと");

ok($c = $index->search("日本語"));
isa_ok($c, 'Senna::Cursor');
is($c->hits, 1);

my $r = $c->next;
isa_ok($r, 'Senna::Result');
ok($c->rewind);

# now check when there are no hits
ok($c = $index->search("これは当たりません"));
isa_ok($c, 'Senna::Cursor');
is($c->hits, 0);
ok(! $c->next);
ok(! $c->rewind);

ok($index->del("日本語", "日本語とかで色々書きますと"));
ok($c = $index->search("日本語"));
isa_ok($c, 'Senna::Cursor');
is($c->hits, 0);

ok($index->remove());

# Now check for integer keys
$index = Senna::Index->create($path, SEN_INT_KEY);
$index->put(1, "数値型のキー");
ok($c = $index->search("数値型"));
isa_ok($c, 'Senna::Cursor');
is($c->hits, 1);
ok($index->del(1, "数値型のキー"));

ok(!eval { $index->put("文字列", "数値型のキーのはず") });

ok($index->replace(1, "数値型のキー", "数値型のキーを新しくしてみる"));
ok($c = $index->search("新しく"));
is($c->hits, 1);

ok($index->remove());
