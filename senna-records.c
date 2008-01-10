/* $Id$
 * 
 * Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
 * All rights reserved.
 */
#include "senna-perl.h"
#ifndef __SENNA_RECORDS_C__
#define __SENNA_RECORDS_C__

void
SennaPerl_Records_bootstrap()
{
    HV *stash;

    stash = gv_stashpv("Senna::Constants", 1);

    newCONSTSUB(stash, "SEN_SORT_ASCENDING", newSViv(sen_sort_ascending));
    newCONSTSUB(stash, "SEN_SORT_DESCENDING", newSViv(sen_sort_descending));
}

SV *
SennaPerl_Records_new(pkg, records)
        char *pkg;
        sen_records *records;
{
    SV *sv;
    XS_STRUCT2OBJ(sv, pkg, records);
    SvREADONLY_on(sv);
    return sv;
}

SV *
SennaPerl_Records_open(pkg, record_unit, subrec_unit, max_n_subrecs)
        char *pkg;
        sen_rec_unit record_unit;
        sen_rec_unit subrec_unit;
        unsigned int max_n_subrecs;
{
    SV *sv;
    sen_records *records;

    records = sen_records_open(record_unit, subrec_unit, max_n_subrecs);
    return SennaPerl_Records_new(pkg, records);
}

SV *
SennaPerl_Records_next(records)
        SennaPerl_Records *records;
{
    SV *sv;
    char keybuf[SEN_MAX_KEY_SIZE];
    int score;

    if (sen_records_next(XS_2SENRECORDS(records), &keybuf, SEN_MAX_KEY_SIZE, &score)) {
        dSP;
        ENTER;
        SAVETMPS;
        PUSHMARK(SP);

        XPUSHs(sv_2mortal(newSVpv("Senna::Record", 13)));
        XPUSHs(sv_2mortal(newSVpv("key", 3)));
        XPUSHs(sv_2mortal(newSVpvf("%s", keybuf)));
        XPUSHs(sv_2mortal(newSVpv("score", 5)));
        XPUSHs(sv_2mortal(newSViv(score)));
        PUTBACK;
        if (call_method("Senna::Record::new", G_SCALAR) <= 0) {
            croak ("Senna::Record::new did not return an object ");
        }
        SPAGAIN;
        sv = POPs;

        if (! SvROK(sv) || SvTYPE(SvRV(sv)) != SVt_PVHV ) {
            croak ("Senna::Record::new did not return a proper object");
        }
        SvREFCNT_inc(sv);

        FREETMPS;
        LEAVE;

        return sv;
    }
    return &PL_sv_undef;
}

SV *
SennaPerl_Records_nhits(records)
        SennaPerl_Records *records;
{
    return newSViv( sen_records_nhits( XS_2SENRECORDS(records)) );
}

sen_rc
SennaPerl_Records_close(records)
        SennaPerl_Records *records;
{
    return sen_records_close(XS_2SENRECORDS(records));
}

void
SennaPerl_Records_DESTROY(records)
        SennaPerl_Records *records;
{
    if (XS_2SENRECORDS(records)) {
        sen_records_close(XS_2SENRECORDS(records));
    }
}

SV *
SennaPerl_Records_curr_key(records)
        SennaPerl_Records *records;
{
    char keybuf[SEN_MAX_KEY_SIZE];
    if (sen_records_curr_key(XS_2SENRECORDS(records), keybuf, SEN_MAX_KEY_SIZE)) {
        return newSVpvf("%s", keybuf);
    }
    return &PL_sv_undef;
}

SV *
SennaPerl_Records_sort(records, limit, optarg)
        SennaPerl_Records *records;
        int limit;
        HV *optarg;
{
    SV *sv;
    sen_sort_optarg *o = NULL;
    if (optarg != NULL) {
        SV **svr;

        Newz(1234, o, 1, sen_sort_optarg);
        svr = hv_fetch(optarg, "mode", 4, 0);
        if (svr != NULL) {
            SV *mode = *svr;
            o->mode = SvIV( mode );
            o->compar = NULL;
            o->compar_arg = NULL;
        }
    }

    sv = sen_rc2obj(sen_records_sort(XS_2SENRECORDS(records), limit, o));

    if (o) {
        Safefree(o);
    }

    return sv;
}

#endif /* __SENNA_RECORDS_C__ */
