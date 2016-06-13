/* ****** Debug Code fÅr STune (Header) ****** */

#ifndef DEBUGGING

#define DEBUGGING 1

#if DEBUGGING

#include <stdio.h>
#define Dprintf(errinf) { printf("%s:%d: ",__FILE__,__LINE__); printf errinf ; fflush(stdout); }

#else
#define Dprintf(errinf)

#endif


#define DBprnt Dprintf


#endif
