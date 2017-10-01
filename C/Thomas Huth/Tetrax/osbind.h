/* ******* OSBIND.H for Pure-C ******* */

#ifdef __TURBOC__

#include <tos.h>

#define Mshrink(a,b) Mshrink(0,a,b)

#else

#error "This include file is for Pure-C/Turbo-C only!"

#endif
