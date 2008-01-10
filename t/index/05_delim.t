# $Id$
#
# Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

use strict;
use Test::More (tests => 25);
use File::Spec;
use File::Temp;

BEGIN
{
    use_ok("Senna");
    use_ok("Senna::Constants", qw(SEN_RC_SUCCESS SEN_INDEX_DELIMITED));
}

my $temp = File::Temp->new(UNLINK => 1);
my $rv;

{
    my $index = Senna::Index->create(
        path  => $temp->filename,
        flags => SEN_INDEX_DELIMITED
    );

    my $info = $index->info;
    is($info->flags, SEN_INDEX_DELIMITED, "flags is NGRAM");

    my $string = "英語 TOEIC 970";
    ok( $index->insert( "key", $string ), "insert ok" );

    my $result;
    {
        foreach my $substr (split / /, $string) {
            $result = $index->select( $substr );

            ok($result);
            isa_ok($result, "Senna::Records");
            is($result->nhits, 1, "1 match found for query '$substr'");
            my $record = $result->next;
            is($record ? $record->key : '', "key");
        };
    }

    {
        # This should not match
        foreach my $substr qw(日本 TOE 9) {
            $result = $index->select( $substr );
            ok($result);
            isa_ok($result, "Senna::Records");
            is($result->nhits, 0, "0 match found for query '$substr'");
        }
    }
}