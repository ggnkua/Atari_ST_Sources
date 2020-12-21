#ifndef __SPATTERN_H
#define __SPATTERN_H

#include <stddef.h>

#define SPT_BIN           1 /* pattern is hex data */
#define SPT_STRINGCASE    2 /* pattern is a string, case sensitive */
#define SPT_STRINGNOCASE  3 /* pattern is a string, case insensitive */

/* For string search, make sure data is NULL terminated even if NULL termination is not part of the data */
long find_pattern(int type, void* data, size_t size, void* pattern, size_t pattern_size, long* sresults, long nsresults) ;

#endif
