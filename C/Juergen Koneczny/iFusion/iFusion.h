#define	VERSION	"1.5b"

void	set_client_ip( int32	client_ip );

typedef struct	__if__
{
	CIB	Cib;
	int16	sock;
	int16	RcvSize;
	char	*Rcv;
}	IF;

#ifdef	DRACONIS
#include	"Draconis.h"
CFG_OPT *get_draconis_options( void );
#endif

#ifdef DEBUG
void	DebugMsg( char *Arg, ... );
void	DebugPuf( void *Puf, int32 len );
#endif
