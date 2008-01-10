# $Id$
#
# Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

use strict;
use Test::More (tests => 829);
use File::Spec;
use File::Temp;

BEGIN
{
    use_ok("Senna");
    use_ok("Senna::Constants", qw(SEN_RC_SUCCESS SEN_INDEX_MORPH_ANALYSE SEN_INDEX_NORMALIZE));
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

    my $result = $index->select("人間");
    ok($result);
    isa_ok($result, "Senna::Records");
    ok($result->nhits > 0, sprintf("There are %d hits\n", $result->nhits));

    while (my $rec = $result->next) {
        ok($rec->key);
    }
}