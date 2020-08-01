#ifndef __XMINT
#define  __XMINT

#if !defined( __TOS )
#include <tos.h>
#endif

int CreateThread(int (*ThreadProc)(void *param), void *param) ;


#endif
