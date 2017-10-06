#ifndef __DEBUG__
#define __DEBUG__

#include "types.h"

WORD DB_printf(BYTE *fmt, ...);

void DB_setpath(BYTE *path);

#endif
