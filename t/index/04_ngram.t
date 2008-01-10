# $Id$
#
# Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

use strict;
use Test::More (tests => 32);
use File::Spec;
use File::Temp;
use Encode();

BEGIN
{
    use_ok("Senna");
    use_ok("Senna::Constants", qw(SEN_RC_SUCCESS SEN_INDEX_NGRAM));
}

my $temp = File::Temp->new(UNLINK => 1);
my $rv;

{
    my $index = Senna::Index->create(
        path  => $temp->filename,
        flags => SEN_INDEX_NGRAM 
    );

    my $info = $index->info;
    is($info->flags, SEN_INDEX_NGRAM, "flags is NGRAM");

    my $string = "まずは日本語の値";
    ok( $index->insert( "key", $string ), "insert ok" );

    my $length = do {
        length( Encode::decode('utf-8', $string ) );
    };
    my $result;
    for my $i (0..$length - 2) {
        SKIP: {
            skip("XXX - TODO: Things don't work for these strings", 4) if
                ($i == 1 || $i == 3 || $i == 5);
            my $substr = do {
                Encode::encode('utf-8',
                    substr( Encode::decode('utf-8', $string), $i, 2 ) );
            };
            
            $result = $index->select( $substr );

            ok($result);
            isa_ok($result, "Senna::Records");
            is($result->nhits, 1, "1 match found for query '$substr'");
            my $record = $result->next;
            is($record ? $record->key : '', "key");
        };
    }
}