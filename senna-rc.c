/* $Id$
 *
 * Copyright (c) 2005-2008 Daisuke Maki <daisuke@endeworks.jp>
 * All rights reserved.
 */
#include "senna-perl.h"
#ifndef __SENNA_RC_C__
#define __SENNA_RC_C__

int
SennaPerl_RC_bootstrap()
{
    HV *stash = gv_stashpv("Senna::Constants", 1);
    /* constants */
    newCONSTSUB(stash, "SEN_RC_SUCCESS",            newSViv(sen_success));
    newCONSTSUB(stash, "SEN_RC_MEMORY_EXHAUSTED",   newSViv(sen_memory_exhausted));
    newCONSTSUB(stash, "SEN_RC_INVALID_FORMAT",     newSViv(sen_invalid_format));
    newCONSTSUB(stash, "SEN_RC_FILE_OPERATION_ERR", newSViv(sen_file_operation_error));
    newCONSTSUB(stash, "SEN_RC_INVALID_ARG",        newSViv(sen_invalid_argument));
    newCONSTSUB(stash, "SEN_RC_OTHER",              newSViv(sen_other_error));

    return 1;
}

#endif /* __SENNA_RC_C__ */
