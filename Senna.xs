/* $Id: Senna.xs 37 2005-08-02 12:04:23Z daisuke $ 
 *
 * Daisuke Maki <dmaki@cpan.org> 
 * All rights reserved.
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define NEED_newCONSTSUB
#define NEED_newRV_noinc
#define NEED_sv_2pv_nolen
#include "ppport.h"

#include <senna/senna.h>

#define MAX_INDEX_PATH_LEN 512
#define SENNA_MAX_KEY_LEN 8024
#define SEN_VARCHAR_KEY 0
#define SEN_INT_KEY     4

#define XS_STATE(type, x) \
    INT2PTR(type, SvROK(x) ? SvIV(SvRV(x)) : SvIV(x))

#define SEN_INDEX_OK(x) \
    (x != NULL && x->index != NULL)

#define SEN_CURSOR_OK(x) \
    (x != NULL)

#define allocSENNA_ARGS \
        SENNA_INDEX_STATE *state; \
        SV *sv; \
        HV *hv; \
        MAGIC *mg;

#define allocSENNA \
        Newz(1234, state, 1, SENNA_INDEX_STATE); \
\
        state->index  = NULL; \
        *(state->filename) = '\0'; \
 \
        sv = newSViv(PTR2IV(state)); \
        sv_magic(sv, 0, '~', 0, 0); \
        mg = mg_find(sv, '~'); \
        assert(mg); \
        mg->mg_virtual = &vtbl_free_SENNA_INDEX_STATE; \
 \
        sv = newRV_noinc(sv); \
        sv_bless(sv, gv_stashpv(SvPV_nolen(class), 1)); \
 \
        SvREADONLY_on(sv);

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

static int
magic_free_SENNA_INDEX_STATE(pTHX_ SV *sv, MAGIC *mg)
{
    return 1;
}

MGVTBL vtbl_free_SENNA_INDEX_STATE = { 0, 0, 0, 0, MEMBER_TO_FPTR(magic_free_SENNA_INDEX_STATE) };

static int
magic_free_SENNA_CURSOR_STATE(pTHX_ SV *sv, MAGIC *mg)
{
    return 1;
}

MGVTBL vtbl_free_SENNA_CURSOR_STATE = { 0, 0, 0, 0, MEMBER_TO_FPTR(magic_free_SENNA_CURSOR_STATE) };

static void
bootinit()
{
    HV *stash;
    sen_rc rc;

    rc = sen_init();
    if(rc != sen_success)
        croak("Failed to call sen_init(). sen_init returned %d", rc);

    stash = gv_stashpv("Senna::Index", 1);
    newCONSTSUB(stash, "SEN_VARCHAR_KEY", newSViv(SEN_VARCHAR_KEY));
    newCONSTSUB(stash, "SEN_INT_KEY", newSViv(SEN_INT_KEY));
    newCONSTSUB(stash, "SEN_INDEX_NORMALIZE", newSViv(SEN_INDEX_NORMALIZE));
    newCONSTSUB(stash, "SEN_INDEX_SPLIT_ALPHA", newSViv(SEN_INDEX_SPLIT_ALPHA));
    newCONSTSUB(stash, "SEN_INDEX_SPLIT_DIGIT", newSViv(SEN_INDEX_SPLIT_DIGIT));
    newCONSTSUB(stash, "SEN_INDEX_SPLIT_SYMBOL", newSViv(SEN_INDEX_SPLIT_SYMBOL));
    newCONSTSUB(stash, "SEN_INDEX_NGRAM", newSViv(SEN_INDEX_NGRAM));
    newCONSTSUB(stash, "SEN_ENC_DEFAULT", newSViv(sen_enc_default));
    newCONSTSUB(stash, "SEN_ENC_NONE", newSViv(sen_enc_none));
    newCONSTSUB(stash, "SEN_ENC_EUCJP", newSViv(sen_enc_euc_jp));
    newCONSTSUB(stash, "SEN_ENC_UTF8", newSViv(sen_enc_utf8));
    newCONSTSUB(stash, "SEN_ENC_SJIS", newSViv(sen_enc_sjis));
}

MODULE = Senna      PACKAGE = Senna

PROTOTYPES: ENABLE

BOOT:
    bootinit();

MODULE = Senna		PACKAGE = Senna::Index		

PROTOTYPES: ENABLE

SV *
new(class)
        SV *class
    PREINIT:
        allocSENNA_ARGS;
    CODE:
        allocSENNA;
        SvREADONLY_on(sv);

        RETVAL = sv;
    OUTPUT:
        RETVAL


SV *
create(class, path, key_size = SEN_VARCHAR_KEY, flags = NULL, n_segment = NULL, encoding = sen_enc_default)
        SV *class;
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
        allocSENNA_ARGS;
    CODE:
        if (SvROK(class))
            croak("Cannot call create() on a reference");

        allocSENNA;

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
        if (! SEN_INDEX_OK(state))
            XSRETURN_UNDEF;

        state->key_size  = index_key_size;
        strcpy(state->filename, index_path);
        RETVAL = sv;
    OUTPUT:
        RETVAL

SV *
open(class, path, ...)
        SV *class;
        SV *path;
    PREINIT:
        char        *index_path;
        int          key_size;
        int          dummy;
        sen_encoding dummy_enc;
        allocSENNA_ARGS;
    CODE:
        if (SvROK(class))
            croak("Cannot call create() on a reference");

        allocSENNA;
        if (!SvOK(path)) {
            croak("open requires path to the index");
        }

        index_path   = SvPV_nolen(path);
        state->index = sen_index_open(index_path);

        /* Make sure that state->index does not have some unsupported
         * key_size
         */
        sen_index_info(state->index, &key_size, &dummy, &dummy, &dummy_enc);
        if (key_size != SEN_VARCHAR_KEY && key_size != SEN_INT_KEY)
            croak("Senna::Index does not support key_size other than 0 or 4");

        state->key_size = key_size;
        strcpy(state->filename, index_path);
        RETVAL = sv;
    OUTPUT:
        RETVAL

SV *
filename(self)
        SV *self;
    PREINIT:
        SV *sv;
        SENNA_INDEX_STATE *state;
    CODE:
        state = XS_STATE(SENNA_INDEX_STATE *, self);
        if (! SEN_INDEX_OK(state))
            croak("No index associated with Senna::Index");

        RETVAL = newSVpv(state->filename, strlen(state->filename));
    OUTPUT:
        RETVAL

SV *
key_size(self)
        SV *self;
    PREINIT:
        SV *sv;
        SENNA_INDEX_STATE *state;
        int key_size;
        int dummy;
        sen_encoding dummy_enc;
        sen_rc rc;
    CODE:
        state = XS_STATE(SENNA_INDEX_STATE *, self);
        if (! SEN_INDEX_OK(state))
            croak("No index associated with Senna::Index");
        rc = sen_index_info(state->index, &key_size, &dummy, &dummy, &dummy_enc);
        if (rc == sen_success)
            RETVAL = newSViv(key_size);
        else
            croak("sen_index_info returned %d", rc);
    OUTPUT:
        RETVAL

SV *
flags(self)
        SV *self;
    PREINIT:
        SV *sv;
        SENNA_INDEX_STATE *state;
        int flags;
        int dummy;
        sen_encoding dummy_enc;
        sen_rc rc;
    CODE:
        state = XS_STATE(SENNA_INDEX_STATE *, self);
        if (! SEN_INDEX_OK(state))
            croak("No index associated with Senna::Index");

        rc = sen_index_info(state->index, &dummy, &flags, &dummy, &dummy_enc);
        if (rc == sen_success) 
            RETVAL = newSViv(flags);
        else
            croak("sen_index_info returned %d", rc);
    OUTPUT:
        RETVAL

SV *
initial_n_segments(self)
        SV *self;
    PREINIT:
        SV *sv;
        SENNA_INDEX_STATE *state;
        int n_segments;
        int dummy;
        sen_encoding dummy_enc;
        sen_rc rc;
    CODE:
        state = XS_STATE(SENNA_INDEX_STATE *, self);
        if (! SEN_INDEX_OK(state))
            croak("No index associated with Senna::Index");

        rc = sen_index_info(state->index, &dummy, &dummy, &n_segments, &dummy_enc);
        if (rc == sen_success)
            RETVAL = newSViv(n_segments);
        else
            croak("sen_index_info returned %d", rc);
    OUTPUT:
        RETVAL

SV *
encoding(self)
        SV *self;
    PREINIT:
        SV *sv;
        SENNA_INDEX_STATE *state;
        sen_encoding encoding;
        int dummy;
        sen_rc rc;
    CODE:
        state = XS_STATE(SENNA_INDEX_STATE *, self);
        if (! SEN_INDEX_OK(state))
            croak("No index associated with Senna::Index");

        rc = sen_index_info(state->index, &dummy, &dummy, &dummy, &encoding);
        if (rc == sen_success)
            RETVAL = newSViv(encoding);
        else
            croak("sen_index_info returned %d", rc);
    OUTPUT:
        RETVAL

SV *
close(self)
        SV *self;
    PREINIT:
        SV          *sv;
        SENNA_INDEX_STATE *state;
        sen_rc rc;
    CODE:
        state = XS_STATE(SENNA_INDEX_STATE *, self);
        if (! SEN_INDEX_OK(state))
            croak("No index associated with Senna::Index");

        rc = sen_index_close(state->index);
        if (rc != sen_success)
            croak("sen_index_close() returned %d", rc);

        state->index = NULL;
        *(state->filename) = '\0';
        RETVAL = &PL_sv_yes;
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
        state = XS_STATE(SENNA_INDEX_STATE *, self);
        if (! SEN_INDEX_OK(state))
            croak("No index associated with Senna::Index");
        rc = sen_index_remove((const char *) state->filename);
        if (rc != sen_success)
            croak("sen_index_close() returned %d", rc);

        state->index = NULL;
        *(state->filename) = '\0';
        RETVAL = &PL_sv_yes;
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
        state = XS_STATE(SENNA_INDEX_STATE *, self);
        if (! SEN_INDEX_OK(state))
            croak("No index associated with Senna::Index");

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
        if (! SEN_INDEX_OK(state))
            croak("No index associated with Senna::Index");

        state = XS_STATE(SENNA_INDEX_STATE *, self);
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
        state = XS_STATE(SENNA_INDEX_STATE *, self);
        if (! SEN_INDEX_OK(state))
            croak("No index associated with Senna::Index");

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

        state = XS_STATE(SENNA_INDEX_STATE *, self);
        if (! SEN_INDEX_OK(state))
            croak("No index associated with Senna::Index");

        index_query = SvPV(query, len);
        result = sen_index_sel(state->index, index_query);

        /* create an object Senna::Cursor by calling the constructor */
        ENTER;
        SAVETMPS;
        PUSHMARK(SP);
        XPUSHs(sv_2mortal(newSVpv("Senna::Cursor", 13)));
        PUTBACK;
        if (call_method("Senna::Cursor::new", G_SCALAR) <= 0) {
            croak ("Senna::Cursor::new did not return object ");
        }

        sv = POPs;
        if (! SvROK(sv) || SvTYPE(SvRV(sv)) != SVt_PVMG) {
            croak ("Senna::Cursor::new did not return a proper object");
        }
        sv = newSVsv(sv);
        SPAGAIN;
            
        FREETMPS;
        LEAVE;

        /* okay, now set the state->cursor variable */
        srecords = XS_STATE(SENNA_CURSOR_STATE *, sv);
        srecords->cursor = result;
        srecords->key_size = state->key_size;

        RETVAL = sv;
    OUTPUT:
        RETVAL

void
DESTROY(self)
        SV *self;
    PREINIT:
        SENNA_CURSOR_STATE *state = XS_STATE(SENNA_CURSOR_STATE *, self);
    CODE:
        Safefree(state);


MODULE = Senna		PACKAGE = Senna::Cursor

PROTOTYPES: ENABLE

SV *
new(class)
        SV *class;
    PREINIT:
        SENNA_CURSOR_STATE *state;
        SV *sv;
        HV *hv;
        MAGIC *mg;
    CODE:
        Newz(1234, state, 1, SENNA_CURSOR_STATE);
        state->cursor  = NULL;
        state->key_size = -1;

        sv = newSViv(PTR2IV(state));
        sv_magic(sv, 0, '~', 0, 0);
        mg = mg_find(sv, '~');
        assert(mg);
        mg->mg_virtual = &vtbl_free_SENNA_CURSOR_STATE;
        sv = newRV_noinc(sv);
        sv_bless(sv, gv_stashpv(SvPV_nolen(class), 1));
        SvREADONLY_on(sv);

        RETVAL = sv;
    OUTPUT:
        RETVAL

void
as_list(self)
        SV *self;
    PREINIT:
        SENNA_CURSOR_STATE *state;
        void *next;
        AV *list;
        SV *sv;
        void *oldkey;
        int idx;
    PPCODE:
        state = XS_STATE(SENNA_CURSOR_STATE *, self);
        if (! SEN_CURSOR_OK(state))
            croak("Cursor not initialized!");

        list = newAV();

        /* Remember current location, so that we can rewind the cursor
         * back to where it was before as_list() was called
         */
        oldkey = (void *) sen_records_curr_key(state->cursor);
        sen_records_rewind(state->cursor);

        while (next = (void *) sen_records_next(state->cursor)) {
            dSP;

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
                croak ("Senna::Result::new did not return object");
            }
    
            SPAGAIN;
            sv = POPs;
            if (! SvROK(sv) || SvTYPE(SvRV(sv)) != SVt_PVHV ) {
                croak ("Senna::Result::new did not return a proper object");
            }
            sv = newSVsv(sv);
            
            PUTBACK;
            FREETMPS;
            LEAVE;

            av_push(list, sv);
        }

        for (sen_records_rewind(state->cursor);
            oldkey != sen_records_curr_key(state->cursor);
            sen_records_next(state->cursor))
            ; /* no op */

        if (GIMME_V == G_ARRAY) {
            EXTEND(SP, av_len(list) + 1);
            for(idx = 0; idx <= av_len(list); idx++)
                PUSHs(*av_fetch(list, idx, 1));
        } else {
            XPUSHs(newRV_noinc((SV *) list));
        }

SV *
hits(self)
        SV *self;
    PREINIT:
        SENNA_CURSOR_STATE *state;
    CODE:
        state = XS_STATE(SENNA_CURSOR_STATE *, self);
        if (! SEN_CURSOR_OK(state)) 
            croak("Cursor not initialized!");

        if (state->cursor == NULL)
            RETVAL = newSViv(0);
        else 
            RETVAL = newSViv(sen_records_nhits(state->cursor));
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

        state = XS_STATE(SENNA_CURSOR_STATE *, self);
        if (! SEN_CURSOR_OK(state))
            croak("Cursor not initialized!");

        if (state->cursor == NULL)
            XSRETURN_UNDEF;

        next = (void *) sen_records_next(state->cursor);
        if (next == NULL)
            XSRETURN_UNDEF;

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

        SPAGAIN;
        FREETMPS;
        LEAVE;
    
        RETVAL = sv;
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
        state = XS_STATE(SENNA_CURSOR_STATE *, self);
        if (! SEN_CURSOR_OK(state))
            croak("Cursor not initialized!");
        if (state->cursor == NULL)
            XSRETURN_UNDEF;

        rc = sen_records_rewind(state->cursor);
        RETVAL = (rc == sen_success) ? &PL_sv_yes : &PL_sv_undef;
    OUTPUT:
        RETVAL

SV *
close(self)
        SV *self;
    PREINIT:
        SENNA_CURSOR_STATE *state;
        sen_rc rc;
    CODE:
        state = XS_STATE(SENNA_CURSOR_STATE *, self);
        if (! SEN_CURSOR_OK(state))
            croak("Cursor not initialized!");

        if (state->cursor == NULL)
            XSRETURN_YES;

        rc = sen_records_close(state->cursor);
        RETVAL = (rc == sen_success) ? &PL_sv_yes : &PL_sv_undef;
    OUTPUT:
        RETVAL

SV *
score(self)
        SV *self;
    PREINIT:
        SENNA_CURSOR_STATE *state;
    CODE:
        state = XS_STATE(SENNA_CURSOR_STATE *, self);
        if (! SEN_CURSOR_OK(state))
            croak("Cursor not initialized!");

        if (state->cursor == NULL)
            XSRETURN_UNDEF;

        RETVAL = newSVuv(sen_records_curr_score(state->cursor));
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
        state = XS_STATE(SENNA_CURSOR_STATE *, self);
        if (! SEN_CURSOR_OK(state))
            croak("Cursor not initialized!");

        if (state->cursor == NULL)
            XSRETURN_UNDEF;

        if (state->key_size == SEN_INT_KEY) {
            int_key = (int *) sen_records_curr_key(state->cursor);
            if (int_key == NULL)
                croak("sen_records_curr_key() returned NULL!");
            RETVAL = newSViv(*int_key);
        } else {
            char_key = (char *) sen_records_curr_key(state->cursor) ;
            if (char_key == NULL)
                croak("sen_records_curr_key() returned NULL!");
            RETVAL = newSVpv(char_key, strlen(char_key));
        }
    OUTPUT:
        RETVAL

void
DESTROY(self)
        SV *self;
    PREINIT:
        SENNA_INDEX_STATE *state = XS_STATE(SENNA_INDEX_STATE *, self);
    CODE:
        Safefree(state);

