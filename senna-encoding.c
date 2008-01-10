/* $Id$
 *
 * Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
 * All rights reserved.
 */
#include "senna-perl.h"
#ifndef  __SENNA_ENCODING_C__
#define  __SENNA_ENCODING_C__

int
SennaPerl_Encoding_bootstrap()
{
    HV *stash;

    stash = gv_stashpv("Senna::Constants", 1);

    newCONSTSUB(stash, "SEN_ENC_DEFAULT", newSViv(sen_enc_default));
    newCONSTSUB(stash, "SEN_ENC_NONE",    newSViv(sen_enc_none));
    newCONSTSUB(stash, "SEN_ENC_EUCJP",   newSViv(sen_enc_euc_jp));
    newCONSTSUB(stash, "SEN_ENC_UTF8",    newSViv(sen_enc_utf8));
    newCONSTSUB(stash, "SEN_ENC_SJIS",    newSViv(sen_enc_sjis));
    newCONSTSUB(stash, "SEN_ENC_LATIN1",  newSViv(sen_enc_latin1));
    newCONSTSUB(stash, "SEN_ENC_KOI8R",   newSViv(sen_enc_koi8r));

    return 1;
}

SV *
SennaPerl_Encoding_enc2str(enc)
        sen_encoding enc;
{
    SV *sv;

    switch(enc) {
    case sen_enc_default:
        sv = newSVpv("DEFAULT", 7);
        break;
    case sen_enc_none:
        sv = newSVpv("NONE", 4);
        break;
    case sen_enc_euc_jp:
        sv = newSVpv("EUC-JP", 6);
        break;
    case sen_enc_utf8:
        sv = newSVpv("UTF8", 4);
        break;
    }
    return sv;
}

#endif /* ifndef  __SENNA_ENCODING_C__ */
