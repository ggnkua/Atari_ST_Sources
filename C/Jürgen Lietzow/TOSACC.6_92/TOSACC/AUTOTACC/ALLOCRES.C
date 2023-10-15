/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							AUTOTACC.PRG								*/
/*																		*/
/*		M O D U L E		:	ALLOCRES.C									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	27.04.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <tos.h>
#include <stdlib.h>
#include <string.h>

#if !defined (NULL)

#define	NULL	((void *) 0L)

#endif

#include	"..\allocres.h"

#define		MAX_BLOCKS		20

#define _phystop	(*(void **)			0x42e)
#define _resvector	(*(long *)			0x42A)
#define	_resvalid	(*(long *)			0x426)
#define RESMAGIC	0x31415926L


extern		RES_MEM		_ResStart;
extern		long		_xbra_magic;
extern		char		resLenTxt[];

RES_MEM	*AllocResMem( long size, long magic )
{
	RES_MEM		*rm;
	long		max;
	char		*buf = NULL;
	int			i;
	long		len;
	char		*ptrs[MAX_BLOCKS];
	long		stack;
	long		*src, *dest;

	rm = &_ResStart;
	_xbra_magic = magic;
	_ResStart.rmMagic = magic;
	_ResStart.rmDataSize = size;
	
	size += _ResStart.rmHeadLen;

	/*	alloc the first biggest memory blocks and keep the one with
		the highest	address */
	
	for ( i = 0; i < MAX_BLOCKS; i++ )
	{
		if ( ( max = (long) Malloc( -1L ) ) < ( size + 10L + 512L ) )
			break;
		if ( ( ptrs[i] = Malloc( max ) ) == NULL )
			break;
		if ( ptrs[i] > buf )
		{
			buf = ptrs[i];
			len = max;
		}
	}

	if ( !i )
		return ( NULL );				/* Out of memory */

	/*	shrink not needed memory of the highest memory block */
	
	Mshrink( 0, buf, len - ( size + 512L + 10L ) );
	
	/*	get the memory block higher than the one shrinked */
	
	rm = Malloc( size + 512L );

	/*	free all others */

		
	while ( i-- )
		Mfree( ptrs[i] );
		
	if ( !rm )
		return ( NULL );			/* Illegal memory organisation */

	/*	is this one really higher ? */
	
	if ( (long) rm < (long) buf )
	{
		Mfree( rm );
		return ( NULL );			/* Illegal memory organisation */
	}

	/*	allign resident memory to 512 bytes boarder */

/*
	(long) rm += 0x1ffL;
	(long) rm &= 0xfffffe00L;		PC-Bug
*/
	
	rm = (void *) (((long) rm + 0x1ffL ) & 0xfffffe00L);

	ltoa( size, resLenTxt, 10 );
	resLenTxt[strlen(resLenTxt)] = ' ';
	
	/*	copy master header to rm */
	
	len = _ResStart.rmHeadLen >> 2;
	
	dest = (long *) rm;
	src = (long *) &_ResStart;
	
	do
	{
		*dest++ = *src++;
	} while ( --len );

	stack = Super( 0 );

	/*	rm is now our new phystop */

	if (  (long) _phystop >= (long) rm )
		_phystop = rm;

	/*	install reset handler, which does install the memory page and
		all other stuff */
		
	rm->reserved2[0] = _resvector;
	rm->reserved2[1] = _resvalid;
	_resvalid = RESMAGIC;
	_resvector = (long) (rm + 1);
	
	Super( (void *) stack );	
	
	(long) rm->rmDataStart += (long) rm;
	
	return ( rm );
}
