/* $Id$
 *
 * Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
 * All rights reserved.
 */
#include "senna-perl.h"
#ifndef __SENNA_PERL_SYM_C__
#define __SENNA_PERL_SYM_C__

void
SennaPerl_Symbol_bootstrap()
{
    HV *stash;

    stash = gv_stashpv("Senna::Constants", 1);
    newCONSTSUB(stash, "SEN_SYM_MAX_KEY_SIZE", newSViv(SEN_SYM_MAX_KEY_SIZE));
    newCONSTSUB(stash, "SEN_SYM_WITH_SIS", newSViv(SEN_SYM_WITH_SIS));
    newCONSTSUB(stash, "SEN_SYM_NIL", newSViv(SEN_SYM_NIL));
}

SV*
SennaPerl_Symbol_create(pkg, path, key_size, flags, encoding)
        char *pkg;
        char *path;
        unsigned key_size;
        unsigned flags;
        sen_encoding encoding;
{
    SV *sv;
    sen_sym *sym;
    SennaPerl_Symbol *symbol;
    int len;

    sym = sen_sym_create(path, key_size, flags, encoding);
    if (sym == NULL) {
        croak("sen_sym_create() failed");
    }
    Newz(1234, symbol, 1, SennaPerl_Symbol);
    symbol->sym = sym;

    len = strlen(path);
    Newz(1234, symbol->path, len, char);
    Copy(path, symbol->path, len, char);

    XS_STRUCT2OBJ(sv, pkg, symbol);
    SvREADONLY_on(sv);
    return sv;
}

SV *
SennaPerl_Symbol_open(pkg, path)
        char *pkg;
        char *path;
{
    SV *sv;
    sen_sym *sym;
    SennaPerl_Symbol *symbol;
    int len;

    sym = sen_sym_open(path);
    if (sym == NULL) {
        croak("sen_sym_create() failed");
    }
    Newz(1234, symbol, 1, SennaPerl_Symbol);
    symbol->sym = sym;

    len = strlen(path);
    Newz(1234, symbol->path, len, char);
    Copy(path, symbol->path, len, char);

    XS_STRUCT2OBJ(sv, pkg, symbol);
    SvREADONLY_on(sv);
    return sv;
}

SV *
SennaPerl_Symbol_close(obj)
        SV *obj;
{
    sen_rc rc;
    SennaPerl_Symbol *symbol = XS_STATE(SennaPerl_Symbol *, obj);
    rc = sen_sym_close(symbol->sym);
    if (rc == sen_success) {
        symbol->sym = NULL;
    }
    return sen_rc2obj(rc);
}

void
SennaPerl_Symbol_DESTROY(obj)
        SV *obj;
{
    SennaPerl_Symbol *symbol = XS_STATE(SennaPerl_Symbol *, obj);
    SvREFCNT_dec(SennaPerl_Symbol_close(obj));
    Safefree(symbol->path);
    Safefree(symbol);
}
        
/* Lookup the sym table and find the id of the corresponding entry.
 * If no matches are found, create a new entry, and return that ID
 */
SV *
SennaPerl_Symbol_get(obj, key)
        SV *obj;
        SV *key;
{
    SennaPerl_Symbol *symbol;
    symbol = XS_STATE(SennaPerl_Symbol *, obj);

    return newSViv( sen_sym_get(symbol->sym, SvPV_nolen(key)) );
}

SV *
SennaPerl_Symbol_info(obj)
        SV *obj;
{
    SennaPerl_Symbol *symbol;
    sen_rc rc;
    int key_size = 0;
    unsigned flags = 0;
    sen_encoding encoding;
    unsigned nrecords = 0;
    unsigned file_size = 0;

    symbol = XS_STATE(SennaPerl_Symbol *, obj);
    rc = sen_sym_info(symbol->sym, &key_size, &flags, &encoding, &nrecords, &file_size);
    if (rc != sen_success) {
        croak("Failed to call sen_sym_info: %d", rc);
    } else {
        SV *sv;
        dSP;
        ENTER;
        SAVETMPS;

        PUSHMARK(SP);
        EXTEND(SP, 11);
        PUSHs(sv_2mortal(newSVpv("Senna::Symbol::Info", 18)));
        PUSHs(sv_2mortal(newSViv(key_size)));
        PUSHs(sv_2mortal(newSViv(flags)));
        PUSHs(sv_2mortal(newSViv(encoding)));
        PUSHs(sv_2mortal(newSViv(nrecords)));
        PUSHs(sv_2mortal(newSViv(file_size)));
        PUTBACK;

        if (call_method("Senna::Symbol::Info::_new", G_SCALAR) <= 0) {
            croak ("Senna::Symbol::Info::new did not return an object ");
        }
        SPAGAIN;
        sv = POPs;

        if (! SvROK(sv) || SvTYPE(SvRV(sv)) != SVt_PVHV ) {
            croak ("Senna::Symbol::Info::new did not return a proper object");
        }
        SvREFCNT_inc(sv);

        FREETMPS;
        LEAVE;
        return sv;
    }
}

SV *
SennaPerl_Symbol_remove(obj)
        SV *obj;
{
    SennaPerl_Symbol *symbol;
    sen_rc rc;
    symbol = XS_STATE(SennaPerl_Symbol *, obj);

    rc = sen_sym_remove(symbol->path);
    /* If this was successful, we need to clear out symbol->path,
     * so that DESTROY doesn't f*ck up on us
     */
    if (rc == sen_success) {
        Safefree(symbol->path);
    }
    return sen_rc2obj(rc);
}
    
SV *
SennaPerl_Symbol_path(obj)
        SV *obj;
{
    SennaPerl_Symbol *symbol;
    symbol = XS_STATE(SennaPerl_Symbol *, obj);
    return newSVpvf("%s", symbol->path);
}



#if 0

/* Lookup the sym table and find the id of the corresponding entry.
 * If no matches are found return SEN_SYM_NIL
 */
sen_id sen_sym_at(sen_sym *sym, const void *key);
sen_rc sen_sym_del(sen_sym *sym, const void *key);
unsigned int sen_sym_size(sen_sym *sym);
int sen_sym_key(sen_sym *sym, sen_id id, void *keybuf, int buf_size);
sen_set *sen_sym_prefix_search(sen_sym *sym, const void *key);
sen_set *sen_sym_suffix_search(sen_sym *sym, const void *key);
sen_id sen_sym_common_prefix_search(sen_sym *sym, const void *key);
int sen_sym_pocket_get(sen_sym *sym, sen_id id);
sen_rc sen_sym_pocket_set(sen_sym *sym, sen_id id, unsigned int value);
sen_id sen_sym_next(sen_sym *sym, sen_id id);
#endif

#endif /* ifndef __PERL_SENNA_SYM_C__ */