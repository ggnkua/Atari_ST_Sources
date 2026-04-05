/* The actual implementation for all floating point sizes is in strtod.c.
   These macros tell it to produce the `float' version, `strtof'.  */

#define FLOAT   float
#define STRTOF  strtof

#include "strtod.c"
