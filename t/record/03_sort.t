# $Id$
#
# Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

use strict;
use Test::More (tests => 854);
use File::Spec;
use File::Temp;

BEGIN
{
    use_ok("Senna");
    use_ok("Senna::Constants", qw(SEN_RC_SUCCESS SEN_INDEX_MORPH_ANALYSE SEN_INDEX_NORMALIZE SEN_SORT_ASCENDING SEN_SORT_DESCENDING));
}

my $temp = File::Temp->new(UNLINK => 1);
my $file = File::Spec->catfile('t', 'shikkaku.txt');
my $rv;

{
    my $index = Senna::Index->create({
        path               => $temp->filename,
        key_size           => 0,
        initial_n_segments => 256,
        flags              => SEN_INDEX_MORPH_ANALYSE | SEN_INDEX_NORMALIZE
    });

    open(my $fh, '<', $file) or
        die "Could not open $file: $!";
    while( my $ln = <$fh> ) {
        chomp $ln;
        next unless $ln;
        my $rc = $index->insert($., $ln);
        is($rc, SEN_RC_SUCCESS, "insert for $ln");
    }
    $temp->flush();

    my $result;

    {
        $result  = $index->select("人間");
        ok($result);
        isa_ok($result, "Senna::Records");
        ok($result->nhits > 0, sprintf("There are %d hits\n", $result->nhits));

        # Hopefully nhits > 2
        my $limit = int($result->nhits / 2);
        $result->sort($limit);

        my $prev = undef;
        my $count = 0;
        while (my $rec = $result->next) {
            ok($rec->key, sprintf("got key (%s)", $rec->key));
            ok(! defined $prev || $prev >= $rec->score, sprintf("current score (%d) is lesser or equal to previous (%d)", $rec->score, $prev || 0) );
            $prev = $rec->score;
            $count++;
        }
        is($count, $limit, "records->next returned exact $limit records");
    }

    {
        $result  = $index->select("人間");
        ok($result);
        isa_ok($result, "Senna::Records");
        ok($result->nhits > 0, sprintf("There are %d hits\n", $result->nhits));

        # Hopefully nhits > 2
        my $limit = int($result->nhits / 2);
        $result->sort($limit, { mode => SEN_SORT_DESCENDING });

        my $prev = undef;
        my $count = 0;
        while (my $rec = $result->next) {
            ok($rec->key, sprintf("got key (%s)", $rec->key));
            ok(! defined $prev || $prev >= $rec->key, sprintf("current key (%d) is lesser or equal to previous (%d)", $rec->key, $prev || 0) );
            $prev = $rec->key;
            $count++;
        }
        is($count, $limit, "records->next returned exact $limit records");
    }

    {
        $result  = $index->select("人間");
        ok($result);
        isa_ok($result, "Senna::Records");
        ok($result->nhits > 0, sprintf("There are %d hits\n", $result->nhits));

        # Hopefully nhits > 2
        my $limit = int($result->nhits / 2);
        $result->sort($limit, { mode => SEN_SORT_ASCENDING });

        my $prev = undef;
        my $count = 0;
        while (my $rec = $result->next) {
            ok($rec->key, sprintf("got key (%s)", $rec->key));
            ok(! defined $prev || $prev <= $rec->key, sprintf("current key (%d) is greater or equal to previous (%d)", $rec->key, $prev || 0) );
            $prev = $rec->key;
            $count++;
        }
        is($count, $limit, "records->next returned exact $limit records");
    }
}