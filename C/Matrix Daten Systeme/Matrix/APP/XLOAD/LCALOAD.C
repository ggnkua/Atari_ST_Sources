/* lcaload.c / MATRIX / WA / 1.4.93 */

# include <stdio.h>
# include <string.h>
# include <global.h>

# include "d:\pc\app\xload\global.h"
# include "d:\pc\app\xload\lca.h"
# include "d:\pc\app\xload\lca_dev.h"

# include "d:\pc\app\xload\lcaload.h"

# define  PRINTmessages 0

# if 0
/*----------------------------------- LoadLcaDataBlock ------------*/
int LoadLcaDataBlock ( unsigned port )
{
	return LoadLCA ( lca_data.number, port, lca_data.Buffer, lca_data.bytes ) ;
}
# endif

/*----------------------------------- ResetLCA ------------*/
void ResetLCA ( unsigned port )
{
	SetLCAreset  ( port ) ;
	SetLCAreprog ( port ) ;
	DelayLoop ( 1000 ) ;		/*  > 6 usec */
	ClrLCAreset  ( port ) ;
	ClrLCAreprog ( port ) ;
	DelayLoop ( 1000 ) ;		/*  > 6 usec */
}


/*----------------------------------- LoadLCA ------------*/
int LoadLCA ( unsigned number, unsigned port, unsigned char *buffer, unsigned bytes )
{
	unsigned n, t ;
	BYTE *data ;

	if ( buffer != NULL )
	{
		data = buffer ;
		if ( verbose )
			printf ( "load LCA-%d, %u bytes to port 0x%03x\n", number, bytes, port ) ;
		else
			DelayLoop ( 1000 ) ;		/*  > ? usec */
		if ( GetLCAdnp ( port ) )
			ResetLCA ( port ) ;

		if ( ! GetLCAdnp ( port ) )
		{
			for ( n = 0 ; n < bytes ; n++ )
			{
				for ( t = 9999 ; ( t > 0 ) && ! ( GetLCAready ( port ) ) ; t-- )
					/* loop */ ;
				if ( t <= 0 )
					return LCAbusyTimeOut ;
				if ( GetLCAdnp ( port ) )
					return LCAsignalsDone ;
				PutLCAdata ( port, *data++ ) ;
			}
			if ( verbose )
				printf ( "%u bytes loaded\n", n ) ;
			else
				DelayLoop ( 1000 ) ;		/*  > ? usec */
			if ( ! GetLCAdnp ( port ) )
				return LCAnoDoneSignal ;
		}
		else
			return LCAearlyDoneSignal ;
	}
	else
		return LCAbufferEmpty ;
	return LOADok ;
}


