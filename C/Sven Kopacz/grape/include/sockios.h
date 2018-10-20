#if !defined(__SOCKIOS__)
#define __SOCKIOS__
#include <types.h>

extern int cdecl select(int nfds, fd_set	*readlist,  fd_set *writelist, fd_set *exceptlist, timeval *TimeOut);

#endif