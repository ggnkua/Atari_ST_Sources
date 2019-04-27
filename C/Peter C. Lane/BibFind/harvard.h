/* Functions to turn a record into a Harvard style reference */

#if !defined(HARVARD_H)
#define HARVARD_H

#include "record.h"

char * harvard_body (struct record * rec);
char * harvard_names (struct name * rec);

#endif
