/* $Id: Senna.xs 31 2005-06-24 00:35:04Z daisuke $ 
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
#define SEN_VARCHAR_KEY 0
#define SEN_INT_KEY     4

/* Senna's XS modules
 *
 * Senna::Index  <-> sen_index
 * Senna::Cursor <-> sen_records
 *
 */

struct psenna_index {
    sen_index *index;
    char      filename[MAX_INDEX_PATH_LEN];
    int       key_size;
};

typedef struct psenna_index SENNA_INDEX_STATE;

struct psenna_cursor {
    sen_records *cursor;
    int          key_size;
};

typedef struct psenna_cursor SENNA_CURSOR_STATE;

static void *
sv2senna_key(SENNA_INDEX_STATE *state, SV *key)
{
    long *int_key;
    char *char_key;
    STRLEN len;

    /* key_size determines the type of key */
    if (state->key_size == SEN_INT_KEY) {
        if (! SvIOK(key)) {
            croak("index is created with integer keys, but was passed a non-integer key");
        }

        int_key = &(SvIVX(key));
        return int_key;
    } else {
        char_key = SvPV(key, len);
        if (len >= SENNA_MAX_KEY_LEN) {
            croak("key length must be less than SENNA_MAX_KEY_LEN bytes");
        }
        return char_key;
    }
}

static SV *
put(SENNA_INDEX_STATE *state, void *key, char *value)
{
    sen_rc rc;

    rc = sen_index_upd(state->index, (const void *)key,
                                       NULL, (const char *) value);
    return (rc == sen_success) ? &PL_sv_yes : &PL_sv_undef;
}

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
sen_init()
    CODE:
        RETVAL = newSViv(sen_init());
    OUTPUT:
        RETVAL

MODULE = Senna		PACKAGE = Senna::Index		

PROTOTYPES: ENABLE

SV *
SEN_VARCHAR_KEY()
    CODE:
       RETVAL = newSViv(SEN_VARCHAR_KEY);
    OUTPUT:
       RETVAL

SV *
SEN_INT_KEY()
    CODE:
       RETVAL = newSViv(SEN_INT_KEY);
    OUTPUT:
       RETVAL

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
SEN_ENC_DEFAULT()
    CODE:
        RETVAL = newSViv(sen_enc_default);
    OUTPUT:
        RETVAL

SV *
SEN_ENC_NONE()
    CODE:
        RETVAL = newSViv(sen_enc_none);
    OUTPUT:
        RETVAL

SV *
SEN_ENC_EUCJP()
    CODE:
        RETVAL = newSViv(sen_enc_euc_jp);
    OUTPUT:
        RETVAL

SV *
SEN_ENC_UTF8()
    CODE:
        RETVAL = newSViv(sen_enc_utf8);
    OUTPUT:
        RETVAL

SV *
SEN_ENC_SJIS()
    CODE:
        RETVAL = newSViv(sen_enc_sjis);
    OUTPUT:
        RETVAL

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
        state->filename[0] = '\0';

        sv = newSViv(PTR2IV(state));
        sv_magic(sv, 0, '~', 0, 0);
        mg = mg_find(sv, '~');
        assert(mg);
        mg->mg_virtual = &vtbl_free_senna_index_state;
        SvREADONLY_on(sv);

        hv_store(hv, "_xs_state", 17, newRV_noinc(sv), 0);


SV *
_create(self, path, key_size = SEN_VARCHAR_KEY, flags = NULL, n_segment = NULL, encoding = sen_enc_default)
        SV *self;
        SV *path;
        SV *key_size;
        SV *n_segment;
        SV *flags;
        SV *encoding;
    PREINIT:
        char        *index_path;
        uint8_t      index_key_size;
        uint8_t      index_n_segment;
        uint8_t      index_flags;
        sen_encoding index_encoding;
        SV          *sv;
        SENNA_INDEX_STATE *state = get_index_state_hv(aTHX_ self);
    CODE:
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        if (!SvOK(path)) {
            croak("Path to an index is required");
        }

        index_path      = SvPV_nolen(path);
        index_key_size  = key_size && SvOK(key_size)   ? SvUV(key_size)  : 0;
        index_flags     = flags && SvOK(flags)         ? SvUV(flags)     : 0;
        index_n_segment = n_segment && SvOK(n_segment) ? SvUV(n_segment) : 0;
        index_encoding  = encoding && SvOK(encoding)   ? SvUV(encoding)  : sen_enc_default;

        if (index_key_size != SEN_VARCHAR_KEY &&
                index_key_size != SEN_INT_KEY) {
            croak("Senna::Index does not support key_size other than 0 or 4");
        }

        state->index    = sen_index_create(index_path, index_key_size, index_flags,
                                            index_n_segment, index_encoding);
        state->key_size  = index_key_size;
        strcpy(state->filename, index_path);
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
        int          key_size;
        SV          *sv;
        SENNA_INDEX_STATE *state = get_index_state_hv(aTHX_ self);
    CODE:
        dSP;

        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        if (!SvOK(path)) {
            croak("_open requires path to the index");
        }

        index_path   = SvPV_nolen(path);
        state->index = sen_index_open(index_path);

        if (state->index != NULL) {
            /* Make sure that state->index does not have some unsupported
             * key_size
             */
            sen_index_info(state->index, &key_size, NULL, NULL, NULL);
            if (key_size != SEN_VARCHAR_KEY &&
                    key_size != SEN_INT_KEY) {
                croak("Senna::Index does not support key_size other than 0 or 4");
            }
            state->key_size = key_size;
            strcpy(state->filename, index_path);
            RETVAL = &PL_sv_yes;
        }
        else {
            RETVAL = &PL_sv_undef;
        }

    OUTPUT:
        RETVAL

SV *
filename(self)
        SV *self;
    PREINIT:
        SV *sv;
        SENNA_INDEX_STATE *state;
    CODE:
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        state = get_index_state_hv(aTHX_ self);
        RETVAL = &PL_sv_undef;
        if (state && state->filename) {
            RETVAL = newSVpv(state->filename, strlen(state->filename));
        }
    OUTPUT:
        RETVAL

SV *
key_size(self)
        SV *self;
    PREINIT:
        SV *sv;
        SENNA_INDEX_STATE *state;
        int key_size;
        sen_rc rc;
    CODE:
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        state = get_index_state_hv(aTHX_ self);
        RETVAL = &PL_sv_undef;
        if (state && state->index) {
            rc = sen_index_info(state->index, &key_size, NULL, NULL, NULL);
            if (rc == sen_success) {
                RETVAL = newSViv(key_size);
            }
        }
    OUTPUT:
        RETVAL

SV *
flags(self)
        SV *self;
    PREINIT:
        SV *sv;
        SENNA_INDEX_STATE *state;
        int flags;
        sen_rc rc;
    CODE:
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        state = get_index_state_hv(aTHX_ self);
        RETVAL = &PL_sv_undef;
        if (state && state->index) {
            rc = sen_index_info(state->index, NULL, &flags, NULL, NULL);
            if (rc == sen_success) {
                RETVAL = newSViv(flags);
            }
        }
    OUTPUT:
        RETVAL

SV *
initial_n_segments(self)
        SV *self;
    PREINIT:
        SV *sv;
        SENNA_INDEX_STATE *state;
        int n_segments;
        sen_rc rc;
    CODE:
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        state = get_index_state_hv(aTHX_ self);
        RETVAL = &PL_sv_undef;
        if (state && state->index) {
            rc = sen_index_info(state->index, NULL, NULL, &n_segments, NULL);
            if (rc == sen_success) {
                RETVAL = newSViv(n_segments);
            }
        }
    OUTPUT:
        RETVAL

SV *
encoding(self)
        SV *self;
    PREINIT:
        SV *sv;
        SENNA_INDEX_STATE *state;
        sen_encoding encoding;
        sen_rc rc;
    CODE:
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        state = get_index_state_hv(aTHX_ self);
        RETVAL = &PL_sv_undef;
        if (state && state->index) {
            rc = sen_index_info(state->index, NULL, NULL, NULL, &encoding);
            if (rc == sen_success) {
                RETVAL = newSViv(encoding);
            }
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

        state = get_index_state_hv(aTHX_ self);
        RETVAL = &PL_sv_undef;
        if (state && state->index) {
            sen_index_close(state->index);
            state->index = NULL;
            RETVAL = &PL_sv_yes;
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

        state = get_index_state_hv(aTHX_ self);
        RETVAL = &PL_sv_undef;
        if (state && state->index) {
            rc = sen_index_remove((const char *) state->filename);
            state->index = NULL;
            state->filename[0] = '\0';
            RETVAL = (rc == sen_success) ? &PL_sv_yes : &PL_sv_undef;
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
        void *index_key;
        char *index_value;
        STRLEN len;
        sen_rc rc;
    CODE:
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        state = get_index_state_hv(aTHX_ self);
        index_key   = sv2senna_key(state, key);
        index_value = SvPV_nolen(value);
        rc = sen_index_upd(state->index, (const void *) index_key,
                                       NULL, (const char *) index_value);
        RETVAL = (rc == sen_success) ? &PL_sv_yes : &PL_sv_undef;
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
        void *index_key;
        char *index_value;
        STRLEN len;
        sen_rc rc;
    CODE:
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        state = get_index_state_hv(aTHX_ self);
        index_key   = sv2senna_key(state, key);
        index_value = SvPV(value, len);
        rc = sen_index_upd(state->index, (const void *) index_key,
                                        (const char *) index_value, NULL);
        RETVAL = (rc == sen_success) ? &PL_sv_yes : &PL_sv_undef;
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
        sen_rc rc;
    CODE:
        sv = SvRV(self);
        if (!sv || SvTYPE(sv) != SVt_PVHV) {
            croak("Not a reference to a hash");
        }

        state = get_index_state_hv(aTHX_ self);
        key_value = sv2senna_key(state, key);
        old_value = SvPV(old, len);
        new_value = SvPV(new, len);
        rc = sen_index_upd(state->index, (const void *) key_value,
                       (const char*) old_value, (const char *) new_value);
        RETVAL = (rc == sen_success) ? &PL_sv_yes : &PL_sv_undef;
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

        state = get_index_state_hv(aTHX_ self);
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
        srecords->key_size = state->key_size;

        RETVAL = sv;
    OUTPUT:
        RETVAL

void
DESTROY(self)
        SV *self;
    PREINIT:
        SENNA_CURSOR_STATE *state = get_cursor_state_hv(aTHX_ self);
    CODE:
        Safefree(state);


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

AV *
_as_list(self)
        SV *self;
    PREINIT:
        SENNA_CURSOR_STATE *state;
        void *next;
        AV *list;
        SV *sv;
        void *oldkey;
    CODE:
        dSP;

        state = get_cursor_state_hv(aTHX_ self);
        list = newAV();
        if (state && state->cursor) {
            /* Remember current location, so that we can rewind the cursor
             * back to where it was before as_list() was called
             */
            oldkey = (void *) sen_records_curr_key(state->cursor);
            sen_records_rewind(state->cursor);

            while (next = (void *) sen_records_next(state->cursor)) {
                ENTER;
                SAVETMPS;
                PUSHMARK(SP);
                XPUSHs(sv_2mortal(newSVpv("Senna::Result", 13)));
                XPUSHs(sv_2mortal(newSVpv("key", 3)));

                /* depending on what type of key the index contains, we need
                 * to change the SV created here
                 */
                if (state->key_size == SEN_INT_KEY) {
                    XPUSHs(sv_2mortal(newSViv(*((int *)next))));
                } else {
                    XPUSHs(sv_2mortal(newSVpv((char *) next, strlen((char *) next))));
                }
                XPUSHs(sv_2mortal(newSVpv("score", 5)));
                XPUSHs(sv_2mortal(newSVuv(sen_records_curr_score(state->cursor))));
                PUTBACK;
                if (call_method("Senna::Result::new", G_SCALAR) <= 0) {
                    croak ("Senna::Result::new did not return a proper object");
                }
    
                SPAGAIN;
                sv = POPs;
                if (! SvROK(sv) || SvTYPE(SvRV(sv)) != SVt_PVHV ) {
                    croak ("Senna::Result::new did not return a proper object");
                }
                sv = newSVsv(sv);
            
                FREETMPS;
                LEAVE;

                av_push(list, sv);
            }

            for (sen_records_rewind(state->cursor);
                oldkey != sen_records_curr_key(state->cursor);
                sen_records_next(state->cursor))
            ; /* no op */
        }
        RETVAL = list;
    OUTPUT:
        RETVAL

SV *
hits(self)
        SV *self;
    PREINIT:
        SENNA_CURSOR_STATE *state;
    CODE:
        state = get_cursor_state_hv(aTHX_ self);
        if (state && state->cursor)
            RETVAL = newSVuv(sen_records_nhits(state->cursor));
        else
            RETVAL = newSVuv(0);
    OUTPUT:
        RETVAL

SV *
next(self)
        SV *self;
    PREINIT:
        SV *sv;
        STRLEN len;
        void *next;
        SENNA_CURSOR_STATE *state;
    CODE:
        dSP;

        RETVAL = &PL_sv_undef;

        state = get_cursor_state_hv(aTHX_ self);
        if (state && state->cursor) {
            if (next = (void *) sen_records_next(state->cursor)) {
                ENTER;
                SAVETMPS;
                PUSHMARK(SP);
                XPUSHs(sv_2mortal(newSVpv("Senna::Result", 13)));
                XPUSHs(sv_2mortal(newSVpv("key", 3)));

                /* depending on what type of key the index contains, we need
                 * to change the SV created here
                 */
                if (state->key_size == SEN_INT_KEY) {
                    XPUSHs(sv_2mortal(newSViv(*((int *)next))));
                } else {
                    XPUSHs(sv_2mortal(newSVpv((char *) next, strlen((char *) next))));
                }
                XPUSHs(sv_2mortal(newSVpv("score", 5)));
                XPUSHs(sv_2mortal(newSVuv(sen_records_curr_score(state->cursor))));
                PUTBACK;
                if (call_method("Senna::Result::new", G_SCALAR) <= 0) {
                    croak ("Senna::Result::new did not return a proper object");
                }
    
                SPAGAIN;
                sv = POPs;
                if (! SvROK(sv) || SvTYPE(SvRV(sv)) != SVt_PVHV ) {
                    croak ("Senna::Result::new did not return a proper object");
                }
                sv = newSVsv(sv);
            
                FREETMPS;
                LEAVE;
    
                RETVAL = sv;
            }
        }
    OUTPUT:
        RETVAL

SV *
rewind(self)
        SV *self;
    PREINIT:
        char *prev;
        SENNA_CURSOR_STATE *state;
        sen_rc rc;
    CODE:
        RETVAL = &PL_sv_undef;

        state = get_cursor_state_hv(aTHX_ self);
        if (state && state->cursor) {
            rc = sen_records_rewind(state->cursor);
            RETVAL = (rc == sen_success) ? &PL_sv_yes : &PL_sv_undef;
        }
    OUTPUT:
        RETVAL

SV *
close(self)
        SV *self;
    PREINIT:
        SENNA_CURSOR_STATE *state;
        sen_rc rc;
    CODE:
        RETVAL = &PL_sv_undef;

        state = get_cursor_state_hv(aTHX_ self);
        if (state && state->cursor)  {
            rc = sen_records_close(state->cursor);
            RETVAL = (rc == sen_success) ? &PL_sv_yes : &PL_sv_undef;
        }
    OUTPUT:
        RETVAL

SV *
score(self)
        SV *self;
    PREINIT:
        SENNA_CURSOR_STATE *state;
    CODE:
        RETVAL = &PL_sv_undef;
        state = get_cursor_state_hv(aTHX_ self);
        if (state && state->cursor) {
            RETVAL = newSVuv(sen_records_curr_score(state->cursor));
        }
    OUTPUT:
        RETVAL

SV *
currkey(self)
        SV *self;
    PREINIT:
        char *char_key;
        int  *int_key;
        SENNA_CURSOR_STATE *state;
    CODE:
        RETVAL = &PL_sv_undef;
        state = get_cursor_state_hv(aTHX_ self);
        if (state && state->cursor) {
            if (state->key_size == SEN_INT_KEY) {
                int_key = (int *) sen_records_curr_key(state->cursor);
                if (int_key) {
                    RETVAL = newSViv(*int_key);
                }
            } else {
                char_key = (char *) sen_records_curr_key(state->cursor) ;
                if (char_key) {
                    RETVAL = newSVpv(char_key, strlen(char_key));
                }
            }
        }
    OUTPUT:
        RETVAL

void
DESTROY(self)
        SV *self;
    PREINIT:
        SENNA_INDEX_STATE *state = get_index_state_hv(aTHX_ self);
    CODE:
        Safefree(state);

