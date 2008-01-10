/* $Id$
 *
 * Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
 * All rights reserved.
 */
#include "senna-perl.h"
#ifndef  __SENNA_SNIP_C__
#define  __SENNA_SNIP_C__

#define TAGS(tags, opentag, opentag_len, closetag, closetag_len) \
    { \
        SV **svr; \
        if (av_len(tags) != 2) { \
            croak("tags must contain tag pair"); \
        } \
    \
        svr = av_fetch(tags, 0, 0); \
        if (svr == NULL || ! SvOK(*svr)) { \
            croak("each element in tags must contain a tag string"); \
        } \
    \
        opentag = SvPV(*svr, opentag_len); \
        opentag_len = opentag_len; \
    \
        svr = av_fetch(tags, 1, 0); \
        if (svr == NULL || ! SvOK(*svr)) { \
            croak("each element in tags must contain a tag string"); \
        } \
    \
        closetag = SvPV(*svr, closetag_len); \
        closetag_len = closetag_len; \
    }

SV *
SennaPerl_Snippet_new(pkg, snip)
        char *pkg;
        sen_snip *snip;
{
    SennaPerl_Snippet *xs;
    SV *sv;

    Newz(1234, xs, 1, SennaPerl_Snippet);
    XS_2SENSNIP(xs) = snip;
    XS_2SENSNIP_EXECUTED(xs) = 0;
    XS_2SENSNIP_NRESULTS(xs) = 0;
    XS_2SENSNIP_MAX_TAGGED_LEN(xs) = 0;
    XS_2SENSNIP_CURRENT_INDEX(xs) = 0;

    XS_STRUCT2OBJ(sv, pkg, xs);
    SvREADONLY_on(sv);
    return sv;
}

SV *
SennaPerl_Snippet_open(pkg, encoding, flags, width, max_results, tags)
        char *pkg;
        sen_encoding encoding;
        int flags;
        unsigned int width;
        unsigned int max_results;
        AV *tags;
{
    char *opentag;
    char *closetag;
    STRLEN opentag_len;
    STRLEN closetag_len;
    sen_snip *snip;

    TAGS(tags, opentag, opentag_len, closetag, closetag_len);

    snip = sen_snip_open(encoding, flags, width, max_results,
        opentag, opentag_len, closetag, closetag_len, 
        /* XXX I have NO idea what this is */
        (sen_snip_mapping *) -1
    );

    return SennaPerl_Snippet_new(pkg, snip);
}

sen_rc
SennaPerl_Snippet_close(snip)
        SennaPerl_Snippet *snip;
{
    return sen_snip_close(XS_2SENSNIP(snip));
}

void
SennaPerl_Snippet_DESTROY(snip)
        SennaPerl_Snippet *snip;
{
    sen_snip_close(XS_2SENSNIP(snip));
}

sen_rc
SennaPerl_Snippet_add_cond(snip, keyword_sv, tags)
        SennaPerl_Snippet *snip;
        SV *keyword_sv;
        AV *tags;
{
    char *opentag;
    char *closetag;
    char *keyword;
    STRLEN opentag_len;
    STRLEN closetag_len;
    STRLEN keyword_len;

    TAGS(tags, opentag, opentag_len, closetag, closetag_len);

    keyword = SvPV(keyword_sv, keyword_len);

    return sen_snip_add_cond(XS_2SENSNIP(snip), 
        keyword, keyword_len,
        opentag, opentag_len,
        closetag, closetag_len
    );
}

sen_rc
SennaPerl_Snippet_exec(snip, string_sv)
        SennaPerl_Snippet *snip;
        SV *string_sv;
{
    char *string;
    STRLEN string_len;
    unsigned int nresults;
    unsigned int max_tagged_len;
    sen_rc rc;

    string = SvPV(string_sv, string_len);

    rc = sen_snip_exec(XS_2SENSNIP(snip),
        string, string_len, &nresults, &max_tagged_len);

    XS_2SENSNIP_NRESULTS(snip) = nresults;
    XS_2SENSNIP_MAX_TAGGED_LEN(snip) = max_tagged_len;
    XS_2SENSNIP_EXECUTED(snip) = 1;

    return rc;
}

SV *
SennaPerl_Snippet_get_result(snip, index)
        SennaPerl_Snippet *snip;
        unsigned int index;
{
    char *result;
    unsigned int result_len;
    SV *sv;

    Newz(1234, result, XS_2SENSNIP_MAX_TAGGED_LEN(snip), char);
    sen_snip_get_result(XS_2SENSNIP(snip), index, result, &result_len);

    sv = newSVpv(result, result_len);
    Safefree(result);

    return sv;
}

#endif /* __SENNA_SNIP_C__ */

