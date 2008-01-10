/* $Id$
 *
 * Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
 * All rights reserved.
 */
#include "senna-perl.h"
#ifndef  __SENNA_GLOBAL_C__
#define  __SENNA_GLOBAL_C__

int
SennaPerl_Global_bootstrap()
{
    HV *stash;
    sen_rc rc;

    rc = sen_init();
    if (rc != sen_success) {
        croak("Failed to call sen_init(). sen_init() returned %d", rc);
    }

    stash = gv_stashpv("Senna::Constants", 1);

    newCONSTSUB(stash, "LIBSENNA_VERSION",
        newSVpvf("%d.%d.%d", 
            SENNA_MAJOR_VERSION,
            SENNA_MINOR_VERSION,
            SENNA_MICRO_VERSION
        )
    );
    newCONSTSUB(stash, "LIBSENNA_MAJOR_VERSION", newSViv(SENNA_MAJOR_VERSION));
    newCONSTSUB(stash, "LIBSENNA_MINOR_VERSION", newSViv(SENNA_MINOR_VERSION));
    newCONSTSUB(stash, "LIBSENNA_MICRO_VERSION", newSViv(SENNA_MICRO_VERSION));

    SennaPerl_Index_bootstrap();
    SennaPerl_Encoding_bootstrap();
    SennaPerl_RC_bootstrap();
    SennaPerl_Records_bootstrap();
    SennaPerl_Symbol_bootstrap();
    SennaPerl_Ctx_bootstrap();

    return 1;
}

SV *
SennaPerl_Global_sen_rc2obj(rc)
        sen_rc rc;
{
    SV *sv;

    if (GIMME_V == G_VOID) {
        sv = &PL_sv_undef;
    } else {
        dSP;
        ENTER;
        SAVETMPS;
        PUSHMARK(SP);
        XPUSHs(sv_2mortal(newSVpv("Senna::RC", 9)));
        XPUSHs(sv_2mortal(newSViv(rc)));
        PUTBACK;

        if (call_method("Senna::RC::new", G_SCALAR) <= 0) {
            croak("Senna::RC::new did not return a proper object");
        }

        SPAGAIN;
        sv = POPs;

        if (! sv_isobject(sv) || ! sv_isa(sv, "Senna::RC")) {
            croak("Senna::RC::new did not return a proper object");
        }

        sv = newSVsv(sv);

        FREETMPS;
        LEAVE;
    }
    return sv;
}

void *
SennaPerl_Global_sv2key(sv)
        SV *sv;
{
    STRLEN len;
    char *key = SvPV(sv, len);

    return (void *) key;
}

HV *
SennaPerl_Global_info()
{
    HV *hv;
    char *version;
    char *config_opts;
    char *config_path;
    sen_encoding default_encoding;
    unsigned int initial_n_segments;
    unsigned int partial_match_threshold;

    sen_info(&version, &config_opts, &config_path,
        &default_encoding, &initial_n_segments, &partial_match_threshold);

    hv = newHV();

    hv_store(hv, "version", 7, newSVpv(version, strlen(version)), 0);
    hv_store(hv, "configure_options", 17, newSVpv(config_opts, strlen(config_opts)), 0);
    hv_store(hv, "config_path", 11, newSVpv(config_path, strlen(config_path)), 0);
    hv_store(hv, "default_encoding", 16, newSViv(default_encoding), 0);
    hv_store(hv, "initial_n_segments", 18, newSViv(initial_n_segments), 0);
    hv_store(hv, "partial_match_threshold", 24, newSViv(partial_match_threshold), 0);

    return hv;
}

#endif /*  __SENNA_GLOBAL_C__ */

