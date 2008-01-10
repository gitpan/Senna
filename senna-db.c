#include "senna-perl.h"
#ifndef  __SENNA_DB_C__
#define  __SENNA_DB_C__

SV *
SennaPerl_DB_new(pkg, db)
        char *pkg;
        sen_db *db;
{
    SennaPerl_DB *xs;
    SV *sv;

    Newz(1234, xs, 1, SennaPerl_DB);

    xs->db   = db;
    xs->open = TRUE;

    XS_STRUCT2OBJ(sv, pkg, xs);
    SvREADONLY_on(sv);
    return sv;
}

SV *
SennaPerl_DB_create(pkg, path, flags, encoding)
        char *pkg;
        char *path;
        int flags;
        sen_encoding encoding;
{
    sen_db *db;
    SV     *sv;

    db = sen_db_create(path, flags, encoding);
    if (db == NULL) {
        croak("Failed to create db %s", path);
    }

    sv = SennaPerl_DB_new(pkg, db);
    return sv;
}

SV *
SennaPerl_DB_open(pkg, path)
        char *pkg;
        char *path;
{
    sen_db *db;
    SV     *sv;

    db = sen_db_open(path);
    if (db == NULL) {
        croak("Failed to open db %s", path);
    }

    sv = SennaPerl_DB_new(pkg, db);
    return sv;
}

SV *
SennaPerl_DB_close(db)
        SennaPerl_DB *db;
{
    if (db == NULL || ! db->open) {
        return SennaPerl_Global_sen_rc2obj( sen_other_error );
    } else {
        db->open = FALSE;
        return SennaPerl_Global_sen_rc2obj( sen_db_close(db->db) );
    }
}

void
SennaPerl_DB_DESTROY(db)
        SennaPerl_DB *db;
{
    SennaPerl_DB_close(db);
    Safefree(db);
}


#endif /*  __SENNA_DB_C__ */

