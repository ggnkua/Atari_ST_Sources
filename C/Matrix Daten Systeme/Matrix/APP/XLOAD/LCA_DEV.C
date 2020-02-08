/* lca_dev.c / MATRIX / WA / 28.6.93 */

/* Device dependent access functions to LCA load port */

/* <<< Matdigif - version >>> */


# include <stdio.h>
# include <string.h>
/*
# include "d:\pc\app\xload\mfports.h"
*/

# include "d:\pc\app\matdigi.f\mdf_addr.h"

# include "d:\pc\app\xload\global.h"
# include "d:\pc\app\xload\lca_dev.h"

# define outportb(ofs,d)	*(MATDIGIFaddress+ofs) = d
# define inportb(ofs)		(*(MATDIGIFaddress+ofs))

# define LCAdnpMsk		0x01
# define LCAnresetMsk	0x02
# define LCAninitMsk	0x02
# define LCAreadyMsk	0x02

# define _DefineGetBit(bit)	BOOL Get##bit ( unsigned port )	\
					{ return ( inportb ( LCActrlOffset ) & bit##Msk ) != 0 ; }

_DefineGetBit ( LCAdnp )
_DefineGetBit ( LCAready )
# if 0	/* not used	*/
_DefineGetBit ( LCAnreset )
# else
BOOL GetLCAnreset ( unsigned port ) { return 0 ; }
# endif
_DefineGetBit ( LCAninit )

void PutLCAdata ( unsigned port, unsigned char data )
	{ outportb ( LCAdataOffset, data ) ; }

void SetLCAreset ( unsigned port ) /* clear nreset, set dnp */
	{  }
void ClrLCAreset ( unsigned port ) /* set nreset | dnp */
	{ outportb ( LCActrlOffset, LCAnresetMsk | LCAdnpMsk ) ; }
void SetLCAreprog ( unsigned port ) /* clear dnp */
	{ outportb ( LCActrlOffset, 0 ) ; }
void ClrLCAreprog ( unsigned port ) /* set dnp */
	{  }

# if 0
  Undefined symbol: 'GetLCAdnp'
  Undefined symbol: 'GetLCAready'
# endif

/*------------------------------------ DelayLoop ---------- */
long DelayLoop ( long n )
{
	long dummy = 0 ;

	while ( n-- > 0 )
		/* wait */ dummy += n ;	/* optimizer hidden empty loop */
	return dummy ;
}

