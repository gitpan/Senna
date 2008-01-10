/* $Id$
 *
 * Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
 * All rights reserved.
 */
#include "senna-perl.h"
#ifndef  __SENNA_INDEX_C__
#define  __SENNA_INDEX_C__

int
SennaPerl_Index_bootstrap()
{
    HV *stash;

    stash = gv_stashpv("Senna::Constants", 1);

    newCONSTSUB(stash, "SEN_INDEX_NORMALIZE", newSViv(SEN_INDEX_NORMALIZE));
    newCONSTSUB(stash, "SEN_INDEX_SPLIT_ALPHA", newSViv(SEN_INDEX_SPLIT_ALPHA));
    newCONSTSUB(stash, "SEN_INDEX_SPLIT_DIGIT", newSViv(SEN_INDEX_SPLIT_DIGIT));
    newCONSTSUB(stash, "SEN_INDEX_SPLIT_SYMBOL",
        newSViv(SEN_INDEX_SPLIT_SYMBOL));
    newCONSTSUB(stash, "SEN_INDEX_MORPH_ANALYSE",
        newSViv(SEN_INDEX_MORPH_ANALYSE));
    newCONSTSUB(stash, "SEN_INDEX_NGRAM", newSViv(SEN_INDEX_NGRAM));
    newCONSTSUB(stash, "SEN_INDEX_DELIMITED", newSViv(SEN_INDEX_DELIMITED));
    newCONSTSUB(stash, "SEN_INDEX_ENABLE_SUFFIX_SEARCH",
        newSViv(SEN_INDEX_ENABLE_SUFFIX_SEARCH));
    newCONSTSUB(stash, "SEN_INDEX_DISABLE_SUFFIX_SEARCH",
        newSViv(SEN_INDEX_DISABLE_SUFFIX_SEARCH));
    newCONSTSUB(stash, "SEN_INDEX_WITH_VACUUM", newSViv(SEN_INDEX_WITH_VACUUM));

    newCONSTSUB(stash, "SEN_SEL_OR", newSViv(sen_sel_or));
    newCONSTSUB(stash, "SEN_SEL_AND", newSViv(sen_sel_and));
    newCONSTSUB(stash, "SEN_SEL_BUT", newSViv(sen_sel_but));
    newCONSTSUB(stash, "SEN_SEL_ADJUST", newSViv(sen_sel_adjust));
    return 1;
}

SV *
SennaPerl_Index_new(pkg, index)
        char *pkg;
        sen_index *index;
{
    SennaPerl_Index *xs;
    SV *sv;

    Newz(1234, xs, 1, SennaPerl_Index);

    xs->index = index;
    xs->open  = TRUE;

    XS_STRUCT2OBJ(sv, pkg, xs);
    SvREADONLY_on(sv);
    return sv;
}

SV *
SennaPerl_Index_create(pkg, path, key_size, flags, initial_n_segments, encoding)
        char *pkg;
        char *path;
        int   key_size;
        int   flags;
        int   initial_n_segments;
        sen_encoding encoding;
{
    sen_index *index;
    SV        *sv;

    index = sen_index_create(path, key_size, flags, initial_n_segments, encoding);
    if (index == NULL) {
        croak("Failed to create senna index (sen_index_create() returned NULL) ");
    }

    return SennaPerl_Index_new(pkg, index);
}

SV *
SennaPerl_Index_open(pkg, path)
        char *pkg;
        char *path;
{
    sen_index *index;
    int        key_size;
    SV        *sv;

    index = sen_index_open(path);
    if (index == NULL) {
        croak("Failed to open senna index %s.", path);
    }

    sv = SennaPerl_Index_new(pkg, index);
    return sv;
}

SV *
SennaPerl_Index_info(index)
        SennaPerl_Index *index;
{
    int key_size = 0;
    int flags = 0;
    int initial_n_segments = 0;
    sen_encoding encoding;
    unsigned int nrecords_keys = 0;
    unsigned int file_size_keys = 0;
    unsigned int nrecords_lexicon = 0;
    unsigned int file_size_lexicon = 0;
    unsigned int inv_seg_size = 0;
    unsigned int inv_chunk_size = 0;
    sen_rc rc;

    rc = sen_index_info(index->index,
        &key_size, &flags, &initial_n_segments, &encoding,
        &nrecords_keys, &file_size_keys, &nrecords_lexicon,
        &file_size_lexicon, &inv_seg_size, &inv_chunk_size
    );
    
    if (rc != sen_success) {
        croak("Failed to call sen_index_info: %d", rc);
    } else {
        SV *sv;
        dSP;
        ENTER;
        SAVETMPS;

        PUSHMARK(SP);
        EXTEND(SP, 11);
        PUSHs(sv_2mortal(newSVpv("Senna::Index::Info", 18)));
        PUSHs(sv_2mortal(newSViv(key_size)));
        PUSHs(sv_2mortal(newSViv(flags)));
        PUSHs(sv_2mortal(newSViv(initial_n_segments)));
        PUSHs(sv_2mortal(newSViv(encoding)));
        PUSHs(sv_2mortal(newSViv(nrecords_keys)));
        PUSHs(sv_2mortal(newSViv(file_size_keys)));
        PUSHs(sv_2mortal(newSViv(nrecords_lexicon)));
        PUSHs(sv_2mortal(newSViv(file_size_lexicon)));
        PUSHs(sv_2mortal(newSViv(inv_seg_size)));
        PUSHs(sv_2mortal(newSViv(inv_chunk_size)));
        PUTBACK;

        if (call_method("Senna::Index::Info::_new", G_SCALAR) <= 0) {
            croak ("Senna::Index::Info::new did not return an object ");
        }
        SPAGAIN;
        sv = POPs;

        if (! SvROK(sv) || SvTYPE(SvRV(sv)) != SVt_PVHV ) {
            croak ("Senna::Index::Info::new did not return a proper object");
        }
        SvREFCNT_inc(sv);

        FREETMPS;
        LEAVE;
        return sv;
    }
}


SV *
SennaPerl_Index_remove(index)
        SennaPerl_Index *index;
{
    char       path[ SEN_MAX_PATH_SIZE ];

    if (! sen_index_path( index->index, path, SEN_MAX_PATH_SIZE) ) {
        croak("sen_index_path() did not return a proper path");
    }

    return sen_rc2obj( sen_index_remove( path ) );
}

SV *
SennaPerl_Index_close(index)
        SennaPerl_Index *index;
{
    if (index == NULL || ! index->open) {
        return SennaPerl_Global_sen_rc2obj( sen_other_error );
    } else {
        index->open = FALSE;
        return SennaPerl_Global_sen_rc2obj( sen_index_close(index->index) );
    }
}

void
SennaPerl_Index_DESTROY(index)
        SennaPerl_Index *index;
{
    SennaPerl_Index_close(index);
    Safefree(index);
}

SV *
SennaPerl_Index_path(index)
        SennaPerl_Index *index;
{
    char *buf;
    SV *sv;

    buf = malloc(sizeof(char) * SEN_MAX_PATH_SIZE);

    sen_index_path(index->index, buf, SEN_MAX_PATH_SIZE);
    sv = newSVpv( buf, strlen(buf) );
    free(buf);
    return sv;
}

SV *
SennaPerl_Index_update(index, key, oldvalue, newvalue)
        SennaPerl_Index *index;
        SV *key;
        SV *oldvalue;
        SV *newvalue;
{
    void *pkey = SennaPerl_Global_sv2key(key);
    char *oldc = NULL;
    char *newc = NULL;
    STRLEN oldl = 0;
    STRLEN newl = 0;

    /* XXX - Do we need to use SvPVbyte here? */
    if ( oldvalue != NULL && SvPOK(oldvalue)) {
        oldc = SvPVbyte(oldvalue, oldl);
    }

    if ( newvalue != NULL && SvPOK(newvalue)) {
        newc = SvPVbyte(newvalue, newl);
    }

    return sen_rc2obj( 
        sen_index_upd( index->index, pkey, oldc, oldl, newc, newl )
    );
}

SV *
SennaPerl_Index_insert(index, key, value)
        SennaPerl_Index *index;
        SV *key;
        SV *value;
{
    return SennaPerl_Index_update(index, key, NULL, value);
}

SV *
SennaPerl_Index_select(obj, query)
        SV *obj;
        SV *query;
{
    sen_rc rc;
    char *string;
    STRLEN string_len;
    sen_records *records = sen_records_open(sen_rec_document, sen_rec_none, 0);
    sen_sel_operator op = sen_sel_or;
    sen_select_optarg optarg;
    SennaPerl_Index *index = XS_STATE(SennaPerl_Index *, obj);

    optarg.mode = sen_sel_exact;
    optarg.vector_size = 0;
    optarg.weight_vector = NULL;
    optarg.func = NULL;
    optarg.func_arg = NULL;

    if (query == NULL || ! SvPOK(query)) {
        return &PL_sv_undef;
    }
    string = SvPV(query, string_len);

    rc = sen_index_select(
        index->index,
        string,
        string_len,
        records,
        op,
        &optarg
    );
    if (rc != sen_success) {
        sen_records_close(records);
        croak("sen_index_select() failed");
    }

    return SennaPerl_Records_new("Senna::Records", records);
}

#endif /*  __SENNA_INDEX_C__ */

