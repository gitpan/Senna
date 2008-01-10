/* $Id$
 * 
 * Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
 * All rights reserved.
 */
#include "senna-perl.h"
#ifndef  __SENNA_QUERY_C__
#define  __SENNA_QUERY_C__

void
SennaPerl_Query_bootstrap()
{
    HV *stash;

    stash = gv_stashpv("Senna::Constants", 1);
    newCONSTSUB(stash, "SEN_SEL_OR", newSViv(sen_sel_or));
    newCONSTSUB(stash, "SEN_SEL_AND", newSViv(sen_sel_and));
    newCONSTSUB(stash, "SEN_SEL_BUT", newSViv(sen_sel_but));
    newCONSTSUB(stash, "SEN_SEL_ADJUST", newSViv(sen_sel_adjust));
}

SV *
SennaPerl_Query_open(pkg, str, default_op, max_exprs, encoding)
        char *pkg;
        char *str;
        sen_sel_operator default_op;
        int max_exprs;
        sen_encoding encoding;
{
    SV *sv;
    sen_query *query;
    SennaPerl_Query *xs;

    query = sen_query_open(str, strlen(str), default_op, max_exprs, encoding);
    if (query == NULL) {
        croak("sen_query_create() failed");
    }
    XS_STRUCT2OBJ(sv, pkg, query);
    SvREADONLY_on(sv);
    return sv;
}

sen_rc
SennaPerl_Query_close(query)
        SennaPerl_Query *query;
{
    return sen_query_close(XS_2SENQUERY(query));
}

void
SennaPerl_Query_DESTROY(query)
        SennaPerl_Query *query;
{
    sen_query_close(XS_2SENQUERY(query));
    Safefree(query);
}

sen_rc
SennaPerl_Query_exec(query, index, records, op)
        SennaPerl_Query *query;
        SennaPerl_Index *index;
        SennaPerl_Records *records;
        sen_sel_operator op;
{
    return sen_query_exec(XS_2SENINDEX(index), XS_2SENQUERY(query), XS_2SENRECORDS(records), op);
}

SV *
SennaPerl_Query_snip(query, flags, width, max_results, tags, mapping)
        SennaPerl_Query *query;
        int flags;
        unsigned int width;
        unsigned int max_results;
        AV *tags;
        sen_snip_mapping *mapping;
{
    sen_snip *snip;
    SV **svr;
    unsigned int tags_av_len;
    
    STRLEN tag_len;
    char **opentags = NULL;
    unsigned int *opentag_lens = NULL;
    char **closetags = NULL;
    unsigned int *closetag_lens = NULL;

    
    tags_av_len = tags != NULL ? av_len(tags) : 0;
    if (tags_av_len > 0) {
        I32 i;
        SV **svr;
        AV *tag_pair;

        Newz(1234, opentags, tags_av_len, char *);
        Newz(1234, opentag_lens, tags_av_len, unsigned int);
        Newz(1234, closetags, tags_av_len, char *);
        Newz(1234, closetag_lens, tags_av_len, unsigned int);
        
        for(i = 0; i < tags_av_len; i++) {
            /* each array element contains another array, which should
             * contain two elements [ 'opentag', 'closetag' ]
             */
            svr = av_fetch(tags, i, 0);
            if (svr == NULL || ! SvOK(*svr) || ! SvROK(*svr) ||
                SvTYPE(*svr) != SVt_PVAV )
            {
                croak("tags must contain arrayref(s)");
            }

            tag_pair = (AV *) SvRV(*svr);
            svr = av_fetch(tag_pair, 0, 0);
            if (svr == NULL || ! SvOK(*svr)) {
                croak("each element in tags must contain a tag string");
            }

            opentags[i] = SvPV(*svr, tag_len);
            opentag_lens[i] = tag_len;

            tag_pair = (AV *) SvRV(*svr);
            svr = av_fetch(tag_pair, 1, 0);
            if (svr == NULL || ! SvOK(*svr)) {
                croak("each element in tags must contain a tag string");
            }

            closetags[i] = SvPV(*svr, tag_len);
            closetag_lens[i] = tag_len;
        }
    }

    snip = sen_query_snip(XS_2SENQUERY(query),
        flags,
        width,
        max_results,
        tags_av_len,
        (const char **) opentags,
        opentag_lens,
        (const char **) closetags,
        closetag_lens,
        mapping
    );

    if (opentags != NULL) Safefree(opentags);
    if (opentag_lens != NULL) Safefree(opentag_lens);
    if (closetags != NULL) Safefree(closetags);
    if (closetag_lens != NULL) Safefree(closetag_lens);

    return SennaPerl_Snippet_new("Senna::Snippet", snip);
}

SV *
SennaPerl_Query_rest(query)
        SennaPerl_Query *query;
{
    char *rest;
    unsigned int len;

    len = sen_query_rest(XS_2SENQUERY(query), (const char **) &rest);
    return newSVpv(rest, len);
}

/* sen_query_term needs a callback. This C callback is a bridge that
 * calls a Perl subroutine from within that callback. The first argument
 * in C<args> is the ref to sub
 */
int
SennaPerl_Query_Term_CallbackBridge(const char *value, unsigned int len, void *args)
{
    SV *sv;
    SV *callback;
    dSP;

    ENTER;
    SAVETMPS;

    PUSHMARK(SP);
    EXTEND(SP, 1);
    PUSHs(sv_2mortal(newSVpv(value, len)));
    PUTBACK;

    call_sv((SV *) args, G_DISCARD|G_VOID);

    SPAGAIN;
    sv = POPs;

    FREETMPS;
    LEAVE;

    return SvIV(sv);
}

void
SennaPerl_Query_term(query, callback)
        SennaPerl_Query *query;
        SV *callback;
{
    if (callback == NULL || !SvOK(callback) || ! SvROK(callback) ||
        SvTYPE( SvRV( callback ) ) != SVt_PVCV )
    {
        croak("Senna::Query->term needs a coderef");
    }

    sen_query_term( XS_2SENQUERY(query), 
        SennaPerl_Query_Term_CallbackBridge,
        (void *) callback
    );
}

#if 0
/* Not documented as of 2008/01/03 */
sen_rc sen_query_scan(sen_query *q, const char **strs, unsigned int *str_lens,
                      unsigned int nstrs, int flags, int *found, int *score);

#endif

#endif /* ifndef  __SENNA_QUERY_C__ */
