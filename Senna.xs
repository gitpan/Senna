/* $Id$
 *
 * Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
 * All rights reserved.
 */
#include "senna-perl.h"

MODULE = Senna    PACKAGE = Senna  PREFIX = SennaPerl_Global_

PROTOTYPES: DISABLE

BOOT:
    SennaPerl_Global_bootstrap();

SV *
SennaPerl_Global_cleanup()
    CODE:
        sen_fin();

HV *
SennaPerl_Global_info()


MODULE = Senna    PACKAGE = Senna::Index   PREFIX = SennaPerl_Index_

PROTOTYPES: DISABLE

SV *
SennaPerl_Index__XS_create(pkg, path, key_size = SEN_VARCHAR_KEY, flags = 0, initial_n_segments = 0, encoding = sen_enc_default)
        char *pkg;
        char *path;
        int   key_size;
        int   flags;
        int   initial_n_segments;
        sen_encoding encoding;
    CODE:
        RETVAL = SennaPerl_Index_create(pkg, path, key_size, flags, initial_n_segments, encoding);
    OUTPUT:
        RETVAL

SV *
SennaPerl_Index__XS_open(pkg, path)
        char *pkg;
        char *path;
    CODE:
        RETVAL = SennaPerl_Index_open(pkg, path);
    OUTPUT:
        RETVAL

SV *
SennaPerl_Index__XS_info(self)
        SennaPerl_Index *self;
    CODE:
        RETVAL = SennaPerl_Index_info(self);
    OUTPUT:
        RETVAL

SV *
SennaPerl_Index_path(self)
        SennaPerl_Index *self;

SV *
SennaPerl_Index_remove(self)
        SennaPerl_Index *self;

SV *
SennaPerl_Index_close(self)
        SennaPerl_Index *self;

SV *
SennaPerl_Index_update(self, key, oldvalue, newvalue)
        SennaPerl_Index *self;
        SV *key;
        SV *oldvalue;
        SV *newvalue;

SV *
SennaPerl_Index__XS_insert(self, key, newvalue)
        SennaPerl_Index *self;
        SV *key;
        SV *newvalue;
    CODE:
        RETVAL = SennaPerl_Index_insert(self, key, newvalue);
    OUTPUT:
        RETVAL

SV *
SennaPerl_Index__XS_select(self, query)
        SV *self;
        SV *query;
    CODE:
        RETVAL = SennaPerl_Index_select(self, query);
    OUTPUT:
        RETVAL

void
SennaPerl_Index_DESTROY(self)
        SennaPerl_Index *self;

MODULE = Senna     PACKAGE = Senna::Encoding    PREFIX = SennaPerl_Encoding_

PROTOTYPES: DISABLE

SV *
SennaPerl_Encoding_enc2str(enc)
        sen_encoding enc;

MODULE = Senna     PACKAGE = Senna::Records    PREFIX = SennaPerl_Records_

PROTOTYPES: DISABLE

SV *
SennaPerl_Records_open(pkg, record_unit, subrec_unit, max_n_subrecs)
        char *pkg;
        sen_rec_unit record_unit;
        sen_rec_unit subrec_unit;
        unsigned int max_n_subrecs;

SV *
SennaPerl_Records__XS_next(self)
        SennaPerl_Records *self;
    CODE:
        RETVAL = SennaPerl_Records_next(self);
    OUTPUT:
        RETVAL

SV *
SennaPerl_Records_nhits(self)
        SennaPerl_Records *self;

SV *
SennaPerl_Records_curr_key(self)
        SennaPerl_Records *self;

SV *
SennaPerl_Records_sort(self, limit = 10, optarg = NULL)
        SennaPerl_Records *self;
        int limit;
        HV *optarg;

void
SennaPerl_Records_DESTROY(self)
        SennaPerl_Records *self;

sen_rc
SennaPerl_Records_close(self)
        SennaPerl_Records *self;

MODULE = Senna     PACKAGE = Senna::Symbol    PREFIX = SennaPerl_Symbol_

PROTOTYPES: DISABLE

SV *
SennaPerl_Symbol__XS_create(pkg, path, key_size, flags, encoding)
        char *pkg;
        char *path;
        unsigned key_size;
        unsigned flags;
        sen_encoding encoding;
    CODE:
        RETVAL = SennaPerl_Symbol_create(pkg, path, key_size, flags, encoding);
    OUTPUT:
        RETVAL

SV *
SennaPerl_Symbol_path(obj)
        SV *obj;

SV *
SennaPerl_Symbol_close(obj)
        SV *obj;

SV *
SennaPerl_Symbol_get(obj, key)
        SV *obj;
        SV *key;
        
SV *
SennaPerl_Symbol_info(obj)
        SV *obj;

SV *
SennaPerl_Symbol_remove(obj)
        SV *obj;

void
SennaPerl_Symbol_DESTROY(obj)
        SV *obj;

MODULE = Senna     PACKAGE = Senna::Query    PREFIX = SennaPerl_Query_

PROTOTYPES: DISABLE

SV *
SennaPerl_Query__XS_open(pkg, str, default_op, max_exprs, encoding)
        char *pkg;
        char *str;
        sen_sel_operator default_op;
        int max_exprs;
        sen_encoding encoding;
    CODE:
        RETVAL = SennaPerl_Query_open(pkg, str, default_op, max_exprs, encoding);
    OUTPUT:
        RETVAL

sen_rc
SennaPerl_Query_close(obj)
        SennaPerl_Query *obj;

void
SennaPerl_Query_DESTROY(obj)
        SennaPerl_Query *obj;

sen_rc
SennaPerl_Query__XS_exec(obj, index, records, op)
        SennaPerl_Query *obj;
        SennaPerl_Index *index;
        SennaPerl_Records *records;
        sen_sel_operator op
    CODE:
        RETVAL = SennaPerl_Query_exec(obj, index, records, op);
    OUTPUT:
        RETVAL

SV *
SennaPerl_Query_snip(query, flags, width, max_results, tags, mapping)
        SennaPerl_Query *query;
        int flags;
        unsigned int width;
        unsigned int max_results;
        AV *tags;
        sen_snip_mapping *mapping;

SV *
SennaPerl_Query_rest(query)
        SennaPerl_Query *query;

void
SennaPerl_Query_term(query, callback)
        SennaPerl_Query *query;
        SV *callback;

MODULE = Senna     PACKAGE = Senna::Snippet    PREFIX = SennaPerl_Snippet_

PROTOTYPES: DISABLE

SV *
SennaPerl_Snippet__XS_open(pkg, encoding, flags, width, max_results, tags)
        char *pkg;
        sen_encoding encoding;
        int flags;
        unsigned int width;
        unsigned int max_results;
        AV *tags;
    CODE:
        RETVAL = SennaPerl_Snippet_open(pkg, encoding, flags, width, max_results, tags);
    OUTPUT:
        RETVAL

sen_rc
SennaPerl_Snippet_close(obj)
        SennaPerl_Snippet *obj;

void
SennaPerl_Snippet_DESTROY(obj)
        SennaPerl_Snippet *obj;

sen_rc
SennaPerl_Snippet__XS_add_cond(obj, keyword_sv, tags)
        SennaPerl_Snippet *obj;
        SV *keyword_sv;
        AV *tags;
    CODE:
        RETVAL = SennaPerl_Snippet_add_cond(obj, keyword_sv, tags);
    OUTPUT:
        RETVAL

sen_rc
SennaPerl_Snippet__XS_exec(obj, string_sv)
        SennaPerl_Snippet *obj;
        SV *string_sv;
    CODE:
        RETVAL = SennaPerl_Snippet_exec(obj, string_sv);
    OUTPUT:
        RETVAL

SV *
SennaPerl_Snippet_get_result(obj, index)
        SennaPerl_Snippet *obj;
        unsigned int index;

SV *
SennaPerl_Snippet_next(obj)
        SennaPerl_Snippet *obj;
    CODE:
        if (! XS_2SENSNIP_EXECUTED(obj) || XS_2SENSNIP_NRESULTS(obj) <= XS_2SENSNIP_CURRENT_INDEX(obj)) {
            XSRETURN_EMPTY;
        }

        RETVAL = SennaPerl_Snippet_get_result(obj, XS_2SENSNIP_CURRENT_INDEX(obj));
        XS_2SENSNIP_CURRENT_INDEX(obj)++;
    OUTPUT:
        RETVAL

void
SennaPerl_Snippet_rewind(obj)
        SennaPerl_Snippet *obj;
    CODE:
        XS_2SENSNIP_CURRENT_INDEX(obj) = 0;


MODULE = Senna     PACKAGE = Senna::DB    PREFIX = SennaPerl_DB_

PROTOTYPES: DISABLE

SV *
SennaPerl_DB__XS_create(pkg, path, flags, encoding)
        char *pkg;
        char *path;
        int  flags;
        sen_encoding encoding;
    CODE:
        RETVAL = SennaPerl_DB_create(pkg, path, flags, encoding);
    OUTPUT:
        RETVAL

SV *
SennaPerl_DB__XS_open(pkg, path)
        char *pkg;
        char *path;
    CODE:
        RETVAL = SennaPerl_DB_open(pkg, path);
    OUTPUT:
        RETVAL

SV *
SennaPerl_DB_close(self)
        SennaPerl_DB *self;

void
SennaPerl_DB_DESTROY(self)
        SennaPerl_DB *self;


MODULE = Senna     PACKAGE = Senna::Ctx    PREFIX = SennaPerl_Ctx_

PROTOTYPES: DISABLE

SV *
SennaPerl_Ctx__XS_connect(pkg, host, port, flags)
        char *pkg;
        char *host;
        int  port;
        int  flags;
    CODE:
        RETVAL = SennaPerl_Ctx_connect(pkg, host, port, flags);
    OUTPUT:
        RETVAL

SV *
SennaPerl_Ctx__XS_open(pkg, db, flags)
        char *pkg;
        SennaPerl_DB *db;
        int flags;
    CODE:
        RETVAL = SennaPerl_Ctx_open(pkg, db, flags);
    OUTPUT:
        RETVAL

SV *
SennaPerl_Ctx_close(self)
        SennaPerl_Ctx *self;

SV *
SennaPerl_Ctx__XS_load(self, path)
        SennaPerl_Ctx *self;
        char *path;
    CODE:
        RETVAL = SennaPerl_Ctx_load(self, path);
    OUTPUT:
        RETVAL

SV *
SennaPerl_Ctx__XS_send(self, str, flags = 0)
        SennaPerl_Ctx *self;
        SV *str;
        int flags;
    CODE:
        RETVAL = SennaPerl_Ctx_send(self, str, flags);
    OUTPUT:
        RETVAL

SV *
SennaPerl_Ctx_recv(self)
        SennaPerl_Ctx *self;

SV *
SennaPerl_Ctx__XS_info_get(self)
        SennaPerl_Ctx *self;
    CODE:
        RETVAL = SennaPerl_Ctx_info_get(self);
    OUTPUT:
        RETVAL

void
SennaPerl_Ctx_DESTROY(self)
        SennaPerl_Ctx *self;

