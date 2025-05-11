
/* file handle stat keeper, prevents excessive calls to isatty */

#include "std-guts.h"
#include "file.h"

char __handle_stat[N_HANDLES];

