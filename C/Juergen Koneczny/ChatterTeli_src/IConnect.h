#ifndef	__ICONNECT__
#define	__ICONNECT__

#include	"Window.h"

#define	ICONNECT_START			0x0001
#define	ICONNECT_CONNECT		0x0002
#define	ICONNECT_DISCONNECT	0x0004
#define	ICONNECT_LAST			0x0008

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
WORD	HandleIConnect( EVNT *Events, WORD Global[15] );

#endif