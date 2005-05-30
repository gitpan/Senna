/* $Id: Senna.xs 10 2005-05-30 08:02:12Z daisuke $ 
 *
 * Daisuke Maki <dmaki@cpan.org> 
 * All rights reserved.
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <senna/senna.h>

#define MAX_INDEX_PATH_LEN 512
#define SENNA_MAX_KEY_LEN 8024

/* Senna's XS modules
 *
 * Senna::Index  <-> sen_index
 * Senna::Cursor <-> sen_records
 *
 */

struct psenna_index {
    sen_index *index;
    char      *filename;
};

typedef struct psenna_index SENNA_INDEX_STATE;

struct psenna_cursor {
    sen_records *cursor;
};

typedef struct psenna_cursor SENNA_CURSOR_STATE;


static SENNA_INDEX_STATE*
get_index_state_iv(pTHX_ SV *sv)
{
    SENNA_INDEX_STATE *p = INT2PTR(SENNA_INDEX_STATE *, SvIV(sv));
    return p;
}

static SENNA_INDEX_STATE*
get_index_state_hv(pTHX_ SV *sv)
{
    HV *hv;
    SV **svp;

    sv = SvRV(sv);
    if (!sv || SvTYPE(sv) != SVt_PVHV)
        croak("Not a reference to a hash");

    hv = (HV *) sv;
    svp = hv_fetch(hv, "_xs_state", 17, 0);
    if (svp) {
        if (SvROK(*svp))
            return get_index_state_iv(aTHX_ SvRV(*svp));
        else
            croak("_xs_state element is not a reference");
    }
    croak("Can't find '_xs_state' element in Senna::Index hash");
    return NULL;
}

static int
magic_free_senna_index_state(pTHX_ SV *sv, MAGIC *mg)
{
    return 1;
}

MGVTBL vtbl_free_senna_index_state = { 0, 0, 0, 0, MEMBER_TO_FPTR(magic_free_senna_index_state) };

static SENNA_CURSOR_STATE*
get_cursor_state_iv(pTHX_ SV *sv)
{
    SENNA_CURSOR_STATE *p = INT2PTR(SENNA_CURSOR_STATE *, SvIV(sv));
    return p;
}

static SENNA_CURSOR_STATE*
get_cursor_state_hv(pTHX_ SV *sv)
{
    HV *hv;
    SV **svp;

    sv = SvRV(sv);
    if (!sv || SvTYPE(sv) != SVt_PVHV)
        croak("Not a reference to a hash");

    hv = (HV *) sv;
    svp = hv_fetch(hv, "_xs_state", 17, 0);
    if (svp) {
        if (SvROK(*svp))
            return get_cursor_state_iv(aTHX_ SvRV(*svp));
        else
            croak("_xs_state element is not a reference");
    }
    croak("Can't find '_xs_state' element in Senna::Index hash");
    return NULL;
}

static int
magic_free_senna_cursor_state(pTHX_ SV *sv, MAGIC *mg)
{
    return 1;
}

MGVTBL vtbl_free_senna_cursor_state = { 0, 0, 0, 0, MEMBER_TO_FPTR(magic_free_senna_cursor_state) };

MODULE = Senna      PACKAGE = Senna

PROTOTYPES: ENABLE

SV *
SEN_INDEX_NORMALIZE()
    CODE:
       RETVAL = newSViv(SEN_INDEX_NORMALIZE);
    OUTPUT:
        RETVAL

SV *
SEN_INDEX_SPLIT_ALPHA()
    CODE:
       RETVAL = newSViv(SEN_INDEX_SPLIT_ALPHA);
    OUTPUT:
        RETVAL

SV *
SEN_INDEX_SPLIT_DIGIT()
    CODE:
       RETVAL = newSViv(SEN_INDEX_SPLIT_DIGIT);
    OUTPUT:
        RETVAL

SV *
SEN_INDEX_SPLIT_SYMBOL()
    CODE:
       RETVAL = newSViv(SEN_INDEX_SPLIT_SYMBOL);
    OUTPUT:
        RETVAL

SV *
SEN_INDEX_NGRAM()
    CODE:
       RETVAL = newSViv(SEN_INDEX_NGRAM);
    OUTPUT:
        RETVAL

SV *
sen_init()
    CODE:
        RETVAL = newSViv(sen_init());
    OUTPUT:
        RETVAL




MODULE = Senna		PACKAGE = Senna::Index		

PROTOTYPES: ENABLE

void
_alloc_senna_state(self)
    SV *self
    PREINIT:
        SENNA_INDEX_STATE *state;
        SV *sv;
        HV *hv;
        MAGIC *mg;
    CODE:
/* _alloc_senna_state
 *
 * Allocate C struct for Senna::Index object.
 */
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }
        hv = (HV *) sv;

        Newz(1234, state, 1, SENNA_INDEX_STATE);
        state->index  = NULL;
        state->filename = NULL;

        sv = newSViv(PTR2IV(state));
        sv_magic(sv, 0, '~', 0, 0);
        mg = mg_find(sv, '~');
        assert(mg);
        mg->mg_virtual = &vtbl_free_senna_index_state;
        SvREADONLY_on(sv);

        hv_store(hv, "_xs_state", 17, newRV_noinc(sv), 0);


SV *
_create(self, path, flags = NULL, n_segment = NULL, encoding = sen_enc_default)
        SV *self;
        SV *path;
        SV *n_segment;
        SV *flags;
        SV *encoding;
    PREINIT:
        char        *index_path;
        uint8_t      index_n_segment;
        uint8_t      index_flags;
        sen_encoding index_encoding;
        SV          *sv;
        SENNA_INDEX_STATE *state = get_index_state_hv(self);
    CODE:
/* _create
 *
 * Create a new set of Senna index
 */
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        if (!SvOK(path)) {
            croak("Path to an index is required");
        }

        /* XXX - Got to think about exportin sen_enc_* enum */
        /* XXX - beef up parameter check? */
        /* XXX - Where does the error go? */
        index_path      = SvPV_nolen(path);
        index_flags     = flags && SvOK(flags)     ? SvUV(flags)     : 0;
        index_n_segment = flags && SvOK(n_segment) ? SvUV(n_segment) : 0;
        index_encoding  = flags && SvOK(encoding)  ? SvUV(encoding)  : sen_enc_default;
        state->index    = sen_index_create(index_path, 0, index_flags,
                                            index_n_segment, index_encoding);
        state->filename = index_path;
        if (state->index) {
            RETVAL = &PL_sv_yes;
        } else {
            RETVAL = &PL_sv_undef;
        }
    OUTPUT:
        RETVAL

SV *
_open(self, path, ...)
        SV *self;
        SV *path;
    PREINIT:
        char        *index_path;
        uint8_t      index_n_segment;
        uint8_t      index_flags;
        SV          *sv;
        SENNA_INDEX_STATE *state = get_index_state_hv(self);
    CODE:
        dSP;

        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        if (!SvOK(path)) {
            croak("_open_index requires path to the index");
        }

        index_path   = SvPV_nolen(path);
        state->index = sen_index_open(index_path);
        state->filename = index_path;

        if (state->index != NULL) {
            RETVAL = &PL_sv_yes;
        }
        else {
            RETVAL = &PL_sv_undef;
        }

    OUTPUT:
        RETVAL

SV *
close(self)
        SV *self;
    PREINIT:
        SV          *sv;
        SENNA_INDEX_STATE *state;
    CODE:
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        state = get_index_state_hv(self);
        if (state->index == NULL) {
            RETVAL = &PL_sv_undef;
        } else {
            sen_index_close(state->index);
            state->index = NULL;
            RETVAL = newSVuv((uint8_t) 1);
        }
    OUTPUT:
        RETVAL

SV *
remove(self)
        SV *self;
    PREINIT:
        SV          *sv;
        SENNA_INDEX_STATE *state;
        STRLEN len;
        sen_rc rc;
    CODE:
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        state = get_index_state_hv(self);
        if (state->index == NULL) {
            RETVAL = &PL_sv_undef;
        } else {
            rc = sen_index_remove((const char *) state->filename);
            state->index = NULL;
            state->filename = NULL;
            RETVAL = newSVuv((uint8_t) rc == sen_success);
        }
    OUTPUT:
        RETVAL

SV *
put(self, key, value)
        SV *self;
        SV *key;
        SV *value;
    PREINIT:
        SV *sv;
        SENNA_INDEX_STATE *state;
        char *index_key;
        char *index_value;
        STRLEN len;
    CODE:
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        index_key   = SvPV(key, len);
        if (len >= SENNA_MAX_KEY_LEN) {
            croak("key length must be less than SENNA_MAX_KEY_LEN bytes");
        }
        index_value = SvPV(value, len);

        state = get_index_state_hv(self);
        RETVAL = newSVuv(sen_index_upd(state->index, (const char *) index_key,
                                       NULL, (const char *) index_value));
    OUTPUT:
        RETVAL

SV *
del(self, key, value)
        SV *self;
        SV *key;
        SV *value;
    PREINIT:
        SV *sv;
        SENNA_INDEX_STATE *state;
        char *index_key;
        char *index_value;
        STRLEN len;
    CODE:
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        index_key   = SvPV(key, len);
        if (len >= SENNA_MAX_KEY_LEN) {
            croak("key length must be less than SENNA_MAX_KEY_LEN bytes");
        }
        index_value = SvPV(value, len);

        state = get_index_state_hv(self);
        RETVAL = newSVuv(sen_index_upd(state->index, (const char *) index_key, (const char *) index_value, NULL));
    OUTPUT:
        RETVAL

SV *
replace(self, key, old, new)
        SV *self;
        SV *key;
        SV *old;
        SV *new;
    PREINIT:
        SV *sv;
        SENNA_INDEX_STATE *state;
        STRLEN len;
        char *key_value;
        char *old_value;
        char *new_value;
    CODE:
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        key_value = SvPV(key, len);
        if (len >= SENNA_MAX_KEY_LEN) {
            croak("key length must be less than SENNA_MAX_KEY_LEN bytes");
        }
        old_value = SvPV(old, len);
        new_value = SvPV(new, len);

        state = get_index_state_hv(self);
        RETVAL = newSVuv(sen_index_upd(state->index, (const char *) key_value,
                       (const char*) old_value, (const char *) new_value));
    OUTPUT:
        RETVAL

SV *
search(self, query)
        SV *self;
        SV *query;
    PREINIT:
        SV *sv;
        HV *hv;
        HV *stash;
        SENNA_INDEX_STATE *state;
        SENNA_CURSOR_STATE *srecords;
        char *index_query;
        STRLEN len;
        sen_records *result;
    CODE:
        dSP;

        state = get_index_state_hv(self);
        index_query = SvPV(query, len);
        result = sen_index_sel(state->index, index_query);

        /* create an object Senna::Cursor by calling the constructor */
        ENTER;
        SAVETMPS;
        PUSHMARK(SP);
        XPUSHs(sv_2mortal(newSVpv("Senna::Cursor", 13)));
        PUTBACK;
        if (call_method("Senna::Cursor::new", G_SCALAR) <= 0) {
            croak ("Senna::Cursor::new did not return a proper object");
        }

        sv = POPs;
        if (! SvROK(sv) || SvTYPE(SvRV(sv)) != SVt_PVHV ) {
            croak ("Senna::Cursor::new did not return a proper object");
        }
        sv = newSVsv(sv);
            
        FREETMPS;
        LEAVE;

        /* okay, now set the state->cursor variable */
        srecords = get_cursor_state_hv(sv);
        srecords->cursor = result;

        RETVAL = sv;
    OUTPUT:
        RETVAL

MODULE = Senna		PACKAGE = Senna::Cursor

PROTOTYPES: ENABLE

void
_alloc_cursor_state(self)
        SV *self;
    PREINIT:
        SENNA_CURSOR_STATE *state;
        SV *sv;
        HV *hv;
        MAGIC *mg;
    CODE:
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }
        hv = (HV *) sv;

        Newz(1234, state, 1, SENNA_CURSOR_STATE);
        state->cursor  = NULL;

        sv = newSViv(PTR2IV(state));
        sv_magic(sv, 0, '~', 0, 0);
        mg = mg_find(sv, '~');
        assert(mg);
        mg->mg_virtual = &vtbl_free_senna_cursor_state;
        SvREADONLY_on(sv);

        hv_store(hv, "_xs_state", 17, newRV_noinc(sv), 0);

SV *
hits(self)
        SV *self;
    PREINIT:
        SENNA_CURSOR_STATE *state;
    CODE:
        state = get_cursor_state_hv(self);
        RETVAL = newSVuv(sen_records_nhits(state->cursor));
    OUTPUT:
        RETVAL

SV *
next(self)
        SV *self;
    PREINIT:
        SV *sv;
        STRLEN len;
        char *next;
        SENNA_CURSOR_STATE *state;
    CODE:
        dSP;

        RETVAL = &PL_sv_undef;

        state = get_cursor_state_hv(self);
        if (next = (char *) sen_records_next(state->cursor)) {
            /* Create a result object */
            ENTER;
            SAVETMPS;
            PUSHMARK(SP);
            XPUSHs(sv_2mortal(newSVpv("Senna::Result", 13)));
            XPUSHs(sv_2mortal(newSVpv("key", 3)));
            XPUSHs(sv_2mortal(newSVpv(next, strlen(next))));
            XPUSHs(sv_2mortal(newSVpv("score", 5)));
            XPUSHs(sv_2mortal(newSVuv(sen_records_curr_score(state->cursor))));
            PUTBACK;
            if (call_method("Senna::Result::new", G_SCALAR) <= 0) {
                croak ("Senna::Result::new did not return a proper object (1)");
            }

            SPAGAIN;
            sv = POPs;
/*
            fprintf(stderr, "SvROK = %d, SvTYPE = %d, SVt_PVHV = %d\n", SvROK(sv), SvTYPE(SvRV(sv)), SVt_PVHV);
            if (! SvROK(sv) || SvTYPE(SvRV(sv)) != SVt_PVHV ) {
                croak ("Senna::Result::new did not return a proper object (2)");
            }
            */
            sv = newSVsv(sv);
            
            FREETMPS;
            LEAVE;

            RETVAL = sv;
        }
    OUTPUT:
        RETVAL

SV *
rewind(self)
        SV *self;
    PREINIT:
        char *prev;
        SENNA_CURSOR_STATE *state;
    CODE:
        RETVAL = &PL_sv_undef;

        state = get_cursor_state_hv(self);
        sen_records_rewind(state->cursor);
        RETVAL = newSVnv(1);
    OUTPUT:
        RETVAL

SV *
close(self)
        SV *self;
    PREINIT:
        SENNA_CURSOR_STATE *state;
    CODE:
        RETVAL = &PL_sv_undef;

        state = get_cursor_state_hv(self);
        sen_records_close(state->cursor);
        RETVAL = newSVnv(1);
    OUTPUT:
        RETVAL

SV *
score(self)
        SV *self;
    PREINIT:
        SENNA_CURSOR_STATE *state;
    CODE:
        state = get_cursor_state_hv(self);
        RETVAL = newSVuv(sen_records_curr_score(state->cursor));
    OUTPUT:
        RETVAL

SV *
currkey(self)
        SV *self;
    PREINIT:
        char *key;
        SENNA_CURSOR_STATE *state;
    CODE:
        state = get_cursor_state_hv(self);
        key = (char *) sen_records_curr_key(state->cursor) ;
        fprintf(stderr, "key = %s\n", key);
        if (key) {
            RETVAL = newSVpv(key, strlen(key));
        } else {
            RETVAL = &PL_sv_undef;
        }
    OUTPUT:
        RETVAL
