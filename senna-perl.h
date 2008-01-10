/* $Id$
 *
 * Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
 * All rights reserved.
 *
 */

#ifndef  __SENNA_PERL_H__
#define  __SENNA_PERL_H__

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#define  NEED_newCONSTSUB
#define  NEED_newRV_noinc
#include "ppport.h"
#include <senna/senna.h>

#define SP_DEBUG_ENABLE 0

#if SP_DEBUG_ENABLE >= 1
#define SP_DEBUG(str) \
    PerlIO_printf(PerlIO_stderr(), "%s\n", str);
#else
#define SP_DEBUG(str) 
#endif

/* This is defeined in senna's sym.h/snip.h, and is not exported.
 * Define your own, if my default doesn't work
 */
#ifndef SEN_SYM_MAX_KEY_LENGTH
#define SEN_SYM_MAX_KEY_LENGTH 0xffff
#endif

#ifndef MAX_SNIP_RESULT_COUNT
#define MAX_SNIP_RESULT_COUNT 8U
#endif

/* These are only for the perl binding */
#define SEN_INT_KEY       sizeof(int)
#define SEN_VARCHAR_KEY   0
#define SEN_MAX_KEY_SIZE  8192
#define SEN_MAX_PATH_SIZE 1024

/* XS tools for me */
#define XS_STATE(type, x) \
    INT2PTR(type, SvROK(x) ? SvIV(SvRV(x)) : SvIV(x))

#define XS_STRUCT2OBJ(sv, pkg, obj) \
    sv = newSViv(PTR2IV(obj)); \
    sv = newRV_noinc(sv); \
    sv_bless(sv, gv_stashpv(pkg, 1)); \
    SvREADONLY_on(sv);

#define sen_rc2obj(rc) SennaPerl_Global_sen_rc2obj(rc)

#define DEBUG_printf(x) \
    PerlIO_printf(PerlIO_stderr(), "[DEBUG] %s\n", x);

/* Internal C Structs */
typedef struct {
    sen_index *index;
    bool       open;
} SennaPerl_Index ;

#define XS_2SENINDEX(x) x->index
#define XS_2SENINDEX_OPEN(x) x->open

typedef sen_records SennaPerl_Records;
#define XS_2SENRECORDS(x) x

typedef struct {
    sen_sym *sym;
    char *path;
} SennaPerl_Symbol;
#define XS_2SENSYM(x) x->sym
#define XS_2SENSYM_PATH(x) x->path

typedef sen_query SennaPerl_Query;
#define XS_2SENQUERY(x) x

typedef struct {
    sen_snip    *snip;
    bool         executed;
    unsigned int nresults;
    unsigned int max_tagged_len;
    unsigned int current;
} SennaPerl_Snippet;
#define XS_2SENSNIP(x) x->snip
#define XS_2SENSNIP_EXECUTED(x) x->executed
#define XS_2SENSNIP_NRESULTS(x) x->nresults
#define XS_2SENSNIP_MAX_TAGGED_LEN(x) x->max_tagged_len
#define XS_2SENSNIP_CURRENT_INDEX(x) x->current

typedef struct {
    sen_db *db;
    bool    open;
} SennaPerl_DB;
#define XS_2SENDB(x) x->db
#define XS_2SENDB_OPEN(x) x->open

typedef struct {
    sen_ctx *ctx;
    bool     open;
} SennaPerl_Ctx;
#define XS_2SENCTX(x) x->ctx
#define XS_2SENCTX_OPEN(x) x->open

/* SennaPerl_Global */
int SennaPerl_Global_bootstrap();
int SennaPerl_Global_cleanup();
HV *SennaPerl_Global_info();
SV *SennaPerl_Global_sen_rc2obj(sen_rc rc);
void *SennaPerl_Global_sv2key(SV *sv);

/* SennaPerl_Encoding */
SV *SennaPerl_Encoding_enc2str(sen_encoding enc);

/* SennaPerl_Index */
SV *SennaPerl_Index_create( char *pkg, char *path, int key_size, int flags, int initial_n_segments, sen_encoding encoding);
SV *SennaPerl_Index_open( char *pkg, char *path );
SV *SennaPerl_Index_remove(SennaPerl_Index *index);
SV *SennaPerl_Index_info(SennaPerl_Index *index);
SV *SennaPerl_Index_update(SennaPerl_Index *index, SV *key, SV *oldvalue, SV *newvalue);
SV *SennaPerl_Index_path(SennaPerl_Index *self);
SV *SennaPerl_Index_close(SennaPerl_Index *self);
SV *SennaPerl_Index_rename(SV *self, char *from, char *to);
SV *SennaPerl_Index_insert(SennaPerl_Index *self, SV *key, SV *value);
SV *SennaPerl_Index_select(SV *self, SV *query);
void SennaPerl_Index_DESTROY(SennaPerl_Index *self);

/* SennaPerl_Records */
void SennaPerl_Records_bootstrap();
SV *SennaPerl_Records_new(char *pkg, sen_records *records);
SV *SennaPerl_Records_open(char *pkg, sen_rec_unit record_unit, sen_rec_unit subrec_unit, unsigned int max_n_subrecs);
SV *SennaPerl_Records_next(SennaPerl_Records *self);
SV *SennaPerl_Records_nhits(SennaPerl_Records *self);
SV *SennaPerl_Records_curr_key(SennaPerl_Records *self);
SV *SennaPerl_Records_sort(SennaPerl_Records *self, int limit, HV *optarg);
sen_rc SennaPerl_Records_close(SennaPerl_Records *self);
void SennaPerl_Records_DESTROY(SennaPerl_Records *self);

/* SennaPerl_Symbol */
SV *SennaPerl_Symbol_create(char *pkg, char *path, unsigned key_size, unsigned flags, sen_encoding encoding);
void SennaPerl_Symbol_DESTROY(SV *obj);
SV *SennaPerl_Symbol_close(SV *obj);
SV *SennaPerl_Symbol_get(SV *obj, SV *key);
SV *SennaPerl_Symbol_info(SV *obj);
SV *SennaPerl_Symbol_remove(SV *obj);
SV *SennaPerl_Symbol_path(SV *obj);

/* SennaPerl_Query */
SV *SennaPerl_Query_open(char *pkg, char *str, sen_sel_operator default_op, int max_exprs, sen_encoding encoding);
sen_rc SennaPerl_Query_close(SennaPerl_Query *obj);
void SennaPerl_Query_DESTROY(SennaPerl_Query *obj);
sen_rc SennaPerl_Query_exec(SennaPerl_Query *obj, SennaPerl_Index *index, SennaPerl_Records *records, sen_sel_operator op);
SV *SennaPerl_Query_snip( SennaPerl_Query *query, int flags, unsigned int width, unsigned int max_results, AV *tags, sen_snip_mapping *mapping);
void SennaPerl_Query_term(SennaPerl_Query *obj, SV *callback);
SV * SennaPerl_Query_rest(SennaPerl_Query *query);

/* SennaPerl_Snippet */
SV *SennaPerl_Snippet_new(char *pkg, sen_snip *snip);
SV *SennaPerl_Snippet_open(char *pkg, sen_encoding encoding, int flags, unsigned int width, unsigned int max_results, AV *tags);
SV *SennaPerl_Snippet_get_result(SennaPerl_Snippet *obj, unsigned int index);
SV *SennaPerl_Snippet_next(SennaPerl_Snippet *obj);
void SennaPerl_Snippet_rewind(SennaPerl_Snippet *obj);
void SennaPerl_Snippet_DESTROY(SennaPerl_Snippet *obj);
sen_rc SennaPerl_Snippet_close(SennaPerl_Snippet *obj);

/* SennaPerl DB */
SV *SennaPerl_DB_new(char *pkg, sen_db *db);
SV *SennaPerl_DB_create(char *pkg, char *path, int flags, sen_encoding encoding);
SV *SennaPerl_DB_open(char *pkg, char *path);
SV *SennaPerl_DB_close(SennaPerl_DB *obj);
void SennaPerl_DB_DESTROY(SennaPerl_DB *obj);

/* SennaPerl Ctx */
SV *SennaPerl_Ctx_new(char *pkg, sen_ctx *ctx);
SV *SennaPerl_Ctx_open(char *pkg, SennaPerl_DB *db, int flags);
SV *SennaPerl_Ctx_connect(char *pkg, char *host, int port, int flags);
SV *SennaPerl_Ctx_close(SennaPerl_Ctx *obj);
SV *SennaPerl_Ctx_load(SennaPerl_Ctx *obj, char *path);
SV *SennaPerl_Ctx_send(SennaPerl_Ctx *obj, SV *str, int flags);
SV *SennaPerl_Ctx_recv(SennaPerl_Ctx *obj);
SV *SennaPerl_Ctx_info_get(SennaPerl_Ctx *obj);
void SennaPerl_Ctx_DESTROY(SennaPerl_Ctx *obj);

#endif /* ifndef __SENNA_PERL_H__ */
