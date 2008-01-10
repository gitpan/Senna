#include "senna-perl.h"
#ifndef  __SENNA_CTX_C__
#define  __SENNA_CTX_C__

int
SennaPerl_Ctx_bootstrap()
{
    HV *stash;

    stash = gv_stashpv("Senna::Constants", 1);

    newCONSTSUB(stash, "SEN_CTX_USEQL", newSViv(SEN_CTX_USEQL));
    newCONSTSUB(stash, "SEN_CTX_BATCHMODE", newSViv(SEN_CTX_BATCHMODE));
    newCONSTSUB(stash, "SEN_CTX_MORE", newSViv(SEN_CTX_MORE));
    return 1;
}

SV *
SennaPerl_Ctx_new(pkg, ctx)
        char *pkg;
        sen_ctx *ctx;
{
    SennaPerl_Ctx *xs;
    SV *sv;

    Newz(1234, xs, 1, SennaPerl_Ctx);

    xs->ctx  = ctx;
    xs->open = TRUE;

    XS_STRUCT2OBJ(sv, pkg, xs);
    SvREADONLY_on(sv);
    return sv;
}

SV *
SennaPerl_Ctx_connect(pkg, host, port, flags)
        char *pkg;
        char *host;
        int port;
        int flags;
{
    sen_ctx *ctx;
    SV      *sv;

    ctx = sen_ctx_connect(host, port, flags);
    if (ctx == NULL) {
        croak("Failed to connect host %s:%d.", host, port);
    }

    sv = SennaPerl_Ctx_new(pkg, ctx);
    return sv;
}

SV *
SennaPerl_Ctx_open(pkg, db, flags)
        char *pkg;
        SennaPerl_DB *db;
        int flags;
{
    sen_ctx *ctx;
    SV      *sv;

    ctx = sen_ctx_open(db->db, flags);
    if (ctx == NULL) {
        croak("Failed to open ctx.");
    }

    sv = SennaPerl_Ctx_new(pkg, ctx);
    return sv;
}

SV *
SennaPerl_Ctx_close(ctx)
        SennaPerl_Ctx *ctx;
{
    if (ctx == NULL || ! ctx->open) {
        return SennaPerl_Global_sen_rc2obj( sen_other_error );
    } else {
        ctx->open = FALSE;
        return SennaPerl_Global_sen_rc2obj( sen_ctx_close(ctx->ctx) );
    }
}

void
SennaPerl_Ctx_DESTROY(ctx)
        SennaPerl_Ctx *ctx;
{
    SennaPerl_Ctx_close(ctx);
    Safefree(ctx);
}

SV *
SennaPerl_Ctx_send(self, str, flags)
        SennaPerl_Ctx *self;
        SV *str;
        int flags;
{
    sen_rc rc;
    char *string;
    STRLEN string_len;

    if (str == NULL || ! SvPOK(str)) {
        return &PL_sv_undef;
    }
    string = SvPV(str, string_len);

    rc = sen_ctx_send(
        self->ctx,
        string,
        string_len,
        flags
    );
    if (rc != sen_success) {
        croak("sen_ctx_send() failed");
    }

    return SennaPerl_Global_sen_rc2obj(rc);
}

SV *
SennaPerl_Ctx_load(self, path)
        SennaPerl_Ctx *self;
        char *path;
{
    sen_rc rc;

    rc = sen_ctx_load(self->ctx, path);
    if (rc != sen_success) {
        croak("sen_ctx_load() failed");
    }

    return SennaPerl_Global_sen_rc2obj(rc);
}

SV *
SennaPerl_Ctx_recv(self)
        SennaPerl_Ctx *self;
{
    sen_rc rc;
    char *str;
    int str_len;
    int flags;
    SV *retval = newSVpv("", 0);

    do {
        if (sen_ctx_recv(self->ctx, &str, &str_len, &flags)) {
            croak("sen_ctx_recv() failed");
        }
        if (str != NULL)
            sv_catpvn(retval, str, str_len);
    } while ((flags & SEN_CTX_MORE));

    return retval;
}

SV *
SennaPerl_Ctx_info_get(self)
        SennaPerl_Ctx *self;
{
    sen_rc rc;
    sen_ctx_info info;

    rc = sen_ctx_info_get(self->ctx, &info);
    if (rc != sen_success) {
        croak("sen_ctx_info_get() failed");
    } else {
        SV *sv;
        dSP;
        ENTER;
        SAVETMPS;

        PUSHMARK(SP);
        EXTEND(SP, 4);
        PUSHs(sv_2mortal(newSVpv("Senna::Ctx::Info", 16)));
        PUSHs(sv_2mortal(newSViv(info.fd)));
        PUSHs(sv_2mortal(newSViv(info.com_status)));
        PUSHs(sv_2mortal(newSViv(info.com_info)));
        PUTBACK;

        if (call_method("Senna::Ctx::Info::_new", G_SCALAR) <= 0) {
            croak ("Senna::Ctx::Info::new did not return an object ");
        }
        SPAGAIN;
        sv = POPs;

        if (! SvROK(sv) || SvTYPE(SvRV(sv)) != SVt_PVHV ) {
            croak ("Senna::Ctx::Info::new did not return a proper object");
        }
        SvREFCNT_inc(sv);

        FREETMPS;
        LEAVE;
        return sv;
    }
}

#endif /*  __SENNA_CTX_C__ */

