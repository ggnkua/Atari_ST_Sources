/* Functions to turn a record into a IEEE style reference */

#if !defined(IEEE_H)
#define IEEE_H

#include "record.h"
#include "harvard.h"

char * ieee_body (struct record * rec);
char * ieee_names (struct name * rec);

#endif
