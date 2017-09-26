#ifndef	__MAIN__
#define	__MAIN__
#include	<VDICOL.H>

/*#define	DEBUG*/

#ifdef	IRC_CLIENT
#define	VERSION	"1.11"
#define	PRGNAME		"CHATTER"
#define	APPNAME		"Chatter"
#define	UPDATENAME	"Chatter"
#define	FILEPRGNAME	"Chatter.app"
#define	RSCNAME		"Chatter.rsc"
#define	HELPNAME		"Chatter.bgh"
#define	ST_GUIDE		"*:\\Chatter.hyp"
#define	INFNAME		"Chatter.inf"
#define	RSCHEADER	"Chatter.h"
#define	EDITOBJ
#ifdef	DEBUG
#define	DEBUGNAME	"Chatter.dbg"
#endif
#endif
#ifdef	TELNET_CLIENT
#define	VERSION	"1.15"
#define	PRGNAME		"TELI"
#define	APPNAME		"Teli"
#define	UPDATENAME	"Teli"
#define	FILEPRGNAME	"Teli.app"
#define	RSCNAME		"Teli.rsc"
#define	HELPNAME		"Teli.bgh"
#define	ST_GUIDE		"*:\\Teli.hyp"
#define	INFNAME		"Teli.inf"
#define	RSCHEADER	"Teli.h"
#ifdef	DEBUG
#define	DEBUGNAME	"Teli.dbg"
#endif
#endif


#define RAM_MALLOC -1	/* "Pseudo"-Mode: Statt Mxalloc Malloc nehmen */
#define RAM_ST 0
#define RAM_TT 1
#define RAM_BETTER_ST 2
#define RAM_BETTER_TT 3

#define RAM_PRIVATE  0x00
#define RAM_GLOBAL   0x10
#define RAM_SUPER    0x20
#define RAM_READABLE 0x30

#define	Con(a) Cconws(a)
#define	crlf Con("\r\n")
#define	MemErr(a)	Con( "insufficient memory: " ); Con( a ); crlf

typedef struct
{
	LONG	id;
	LONG	value;
}	COOKIE;

#ifndef	_XY_
#define	_XY_
	typedef	struct
	{
		long	x;
		long	y;
	}	XY;
#endif

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
void	*SearchCookie( LONG Id );
void	*Xmalloc(long len, int mode);
WORD	OpenScreenWk( WORD AesHandle, WORD *WorkOut );
int16	OpenBitmap( WORD Width, WORD Height, WORD AesHandle, MFDB *Bitmap );
WORD	isMonospaceFont( WORD FontId );
void	SortXy( XY *A, XY *B );
BYTE	*Decimal( ULONG Z, BYTE *Puf );

#ifdef	DEBUG
void	DebugMsg( WORD Global[15], BYTE *Arg, ... );
#endif

#endif