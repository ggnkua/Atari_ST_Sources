/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							AUTOTACC.PRG								*/
/*																		*/
/*		M O D U L E		:	SIMULATE.C									*/
/*																		*/
/*																		*/
/*		Author			:	JÅrgen Lietzow fÅr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	27.04.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/


/*
	Wird nur zum Debuggen benîtigt: dazu muû auch in AUTOSTAR.S der erst
	Kommentar aufgehoben werden 
*/

#include <tos.h>
#include <string.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

#include "..\transfer.h"

#define	MAX_BLOCKS	20

#define	SysGEM		(*(int	volatile		(**)(int, long))	0x88)
#define	SysGEMDOS	(*(long	volatile cdecl	(**)(int, ...))		0x84)
#define	SysBIOS		(*(long	volatile cdecl	(**)(int, ...))		0xB4)
#define	SysXBIOS	(*(long	volatile cdecl	(**)(int, ...))		0xB8)
#define	Sys200HZ	(*(void	volatile		(**)(void))			0x114)
#define	SysVSYNC	(*(void	volatile		(**)(void))			0x70)
#define	SysKEYBD	(*(void	volatile		(**)(void))			0x118)

#define	_drvbits	(*(long *) 0x4c2)
#define	_nflops		(*(int *) 0x4a6)
#define	phystop		(*(char **) 0x42e)
#define	_memtop		(*(void **) 0x436)
#define	MAGIC		'TAcc'

#if !defined (NULL)
#define NULL	((void *) 0L)
#endif

extern	SYS		sys;
extern	SYS		 *s;
extern	long	_PasPag;
extern	long	_PgmSize;
extern	long	_ResStart[];

extern	void	*ResetSpooler( void );
extern	long	InstCookie( long c_name, long c_cook );
extern	long	*GetCookie( long cookie );

extern	long	cdecl	__NewMediach( int drive );
extern	long	cdecl	__NewRW( int rwflag, void *buff, int cnt, int recnr,
					  int dev, long lrecno );
extern	long	cdecl	__NewBPB( int drive );

extern	void	ciFlush( void );

typedef struct
{
	BPB		bpb;
	long	numRec;
	int		mediach;
	long	recOff;
	unsigned long	*list;
} SD;

SD		sd1 = { 512, 2, 1024, 5, 1, 1 + 1, 1 + 1 + 1 + 5, 254, 1,
				1 + 1 + 1 + 5 + 254 * 2,
				0,
				0L,
				NULL };
SD		sd2 = { 1024, 4, 4096, 5, 65, 65 + 1, 65 + 65 + 1 + 5, (int) (32634L / 4L), 1,
				1 + 65 + 65 + 5 + 32634L,
				0,
				0L,
				NULL };
SD		sd3 = { 2048, 4, 8192, 5, 132, 132 + 1 + 4, 132 + 132 + 1 + 4 + 5, (int) (67560L / 4L), 1,
				1 + 4 + 132 + 132 + 67560L,
				0,
				0L,
				NULL };
				
char	buf[2048 * 10 + 4];	
unsigned long	rList[13000];


void	*_Malloc( long len )
{
	RES_MEM	*ptr;
	
	ptr = Malloc( len + sizeof( RES_MEM ) );
	
	if ( !ptr )
		return ( ptr );
	
	ptr->rmDataStart = ptr + 1;
	ptr->rmDataSize = len;
	ptr->rmHeadLen = sizeof( RES_MEM );	
	return ( ptr );
}


void	BSet( unsigned long *list, long num )
{
	unsigned long	m = 0x80000000L;
	
	list += (num >> 5);
	
	num %= 32;
	
	m >>= num;
	
	*list |= m;
}

void	BClr( unsigned long *list, long num )
{
	unsigned long	m = 0x80000000L;
	
	list += (num >> 5);
	
	num %= 32;
	
	m >>= num;
	
	*list &= ~m;
}

int	BGet( unsigned long *list, long num )
{
	unsigned long	m = 0x80000000L;
	
	list += (num >> 5);
	
	num %= 32;
	
	m >>= num;
	
	return ( ( *list & m ) != 0UL );
}	

long	cdecl	S_Mediach( int drv )
{
	long 	m;
	
	if ( drv == 0 )
		m = sd1.mediach;
	else if ( drv == 4 )
		m = sd2.mediach;
	else if ( drv == 15 )
		m = sd3.mediach;
	else
		return ( 0 );
	return ( m );
}
long	cdecl	S_BPB( int drv )
{
	BPB		*b;
	
	if ( drv == 0 )
	{
		sd1.mediach = 0;
		b = &(sd1.bpb);
	}
	else if ( drv == 4 )
	{
		sd2.mediach = 0;
		b = &(sd2.bpb);
	}
	else if ( drv == 15 )
	{
		sd3.mediach = 0;
		b = &(sd3.bpb);
	}
	else
		b = NULL;
	return ( (long) b );
}

int	CheckRec( SD *sd, long recno, char *buf )
{
	int		i;
	int		n;
	long	l;
	
	recno += sd->recOff;

	n = sd->bpb.recsiz >> 9;
	for ( i = 0; i < n; i++, buf += 512 )
	{
		l = (unsigned char) buf[0];
		l <<= 8;
		l |= (unsigned char)buf[1];
		l <<= 8;
		l |= (unsigned char)buf[2];
		l <<= 8;
		l |= (unsigned char)buf[3];
		if ( l != recno	)
			return( 1 );
		l = (unsigned char)buf[508];
		l <<= 8;
		l |= (unsigned char)buf[509];
		l <<= 8;
		l |= (unsigned char)buf[510];
		l <<= 8;
		l |= (unsigned char)buf[511];
		if ( l != recno	)
			return( 2 );
	}
	return ( 0 );
}
			
void	SetRec( SD *sd, long recno, char *buf )
{
	int		i;
	int		n;
	
	recno += sd->recOff;

	n = sd->bpb.recsiz >> 9;
	for ( i = 0; i < n; i++, buf += 512 )
	{
		buf[3] = buf[511] = (char) recno;
		buf[2] = buf[510] = (char) (recno >> 8);
		buf[1] = buf[509] = (char) (recno >> 16);
		buf[0] = buf[508] = (char) (recno >> 24);
	}
}
			
			
			
void	error( int num )
{
	switch ( num )
	{
		case	1:	fprintf( stderr, "UngÅltige Sectornummer\n" );
					break;
		case	2:	fprintf( stderr, "UngÅltige Laufwerksnummer\n" );
					break;
		case	3:	fprintf( stderr, "Sektorschreibzugriff ohne Grund\n" );
					break;
		case	4:	fprintf( stderr, "Falsche Sektordaten zu schreiben\n" );
					break;
		case	5:	fprintf( stderr, "Lesen von dirty Sektor\n" );
					break;
		case	6:	fprintf( stderr, "Fehlermeldung von Rwabs()\n" );
					break;
		case	7:	fprintf( stderr, "Falsche Sektordaten gelesen\n" );
					break;
		case	8:	fprintf( stderr, "Nach Delay immernoch dirty Sektoren\n" );
					break;
		case	9:	fprintf( stderr, "Media Flag sollte 0 sein\n" );
					break;
		case	10:	fprintf( stderr, "liefert keinen BPB\n" );
					break;
		default:	break;
	}
}

long	cdecl	S_RW( int rwflag, char *buff, int cnt, int recno,
					  int dev, long lrecno )
{
	SD	*sd;
	
	if ( recno != -1 )
	{
		if ( recno < 0 )
		{
			error ( 1 );
			return ( -1 );
		}
		lrecno = recno;
	}
	switch ( dev )
	{
		case	0:		sd = &sd1;	break;
		case	4:		sd = &sd2;	break;
		case	15:		sd = &sd3;	break;
		default:		error( 2 );
						return ( -1 );
						
	}
	if ( recno + (long) cnt > sd->numRec )
	{
		return ( -31 );
	}
	
	if ( rwflag & 1 )
	{
		while ( cnt-- )
		{
			if ( !BGet( sd->list, lrecno ) )
			{
				error( 3 );
				return ( -1 );
			}
			BClr( sd->list, lrecno );
			if ( CheckRec( sd, lrecno, buff ) )
			{
				error( 4 );
				return ( -1 );
			}
			lrecno++;
			buff += sd->bpb.recsiz;
		}
	}
	else
	{
/*		if ( !random( 400 ) )
		{
			fprintf( stderr, "Forcierter Lesefehler\n" );
			return ( -29 );
		}
*/		while ( cnt-- )
		{
			if ( BGet( sd->list, lrecno ) )
			{
				error( 5 );
				return ( -1 );
			}
			SetRec( sd, lrecno, buff );
			lrecno++;
			buff += sd->bpb.recsiz;
		}
	}
	return ( 0 );
}


int		rwflag, cnt, drv;
long	lrecno;
char	*buff;
SD		*sd;
long	nLoops = 0L;

extern void	_InputChar( int c );
void	Simulate( void )
{
long	t;
	
	sys.tai.spOn = 1;
	for( t = 0; t < 3000; t++ )
		_InputChar( (int) t );
	
	sd2.recOff = sd1.recOff + sd1.numRec;
	sd3.recOff = sd2.recOff + sd2.numRec;
	
	sd1.list = &rList[0];
	sd2.list = &rList[(sd2.recOff + 32) >> 5];
	sd3.list = &rList[(sd3.recOff + 32) >> 5];	
	
	sys.rdOn = 0;
	sys.tai.ciOn = 1;
	sys.di[0].diRead = 1;
	sys.di[4].diRead = 1;
	sys.di[15].diRead = 1;
	
	sys.di[0].diWrite = 1;
	sys.di[4].diWrite = 1;
	sys.di[15].diWrite = 1;

	sys.ahdiFlag = 1;
	do
	{
		nLoops++;
		drv = random( 3 );
		switch ( drv )
		{
			case	0:	sd = &sd1; break;
			case	1:	drv = 4; sd = &sd2; break;
			case	2:	drv = 15; sd = &sd3; break;
			default: break;
		}
		if ( !random( 5 ) )
			buff = &buf[1];
		else
			buff = buf;
		cnt = random( 6 );
		if ( cnt )
			cnt = 1;
		else
			cnt = random( 9 ) + 1;
			
		rwflag = random(4);
		if ( rwflag )
			rwflag = 0;
		else
			rwflag = 1;

		if ( drv == 0 )
		{
			lrecno = random( 10 );
		}
		else
		{
			t = sd->numRec % 500;
			
			lrecno = random( (int) (sd->numRec / 500) + 1 );
			lrecno *= t;
		if ( lrecno + cnt > sd->numRec )
			lrecno = sd->numRec - cnt;
		}
		
		if ( rwflag )
		{
			if ( lrecno + (long) cnt <= sd->numRec )
				for ( t = 0L; t < (long) cnt; t++ )
				{
					SetRec( sd, lrecno + t, buff + t * sd->bpb.recsiz );
					BSet( sd->list, lrecno + t );
				}
		fprintf( stderr, "%4ld  WRITE Sector #%6ld   count: %2d   drv: %d\n",
				nLoops, lrecno, cnt, drv );
		}
		else
		fprintf( stderr, "%4ld  READ  Sector #%6ld   count: %2d   drv: %d\n",
				nLoops, lrecno, cnt, drv );
		if ( lrecno <= INT_MAX )
			t = __NewRW( rwflag, buff, cnt, (int) lrecno, drv, lrecno );
		else
			t = __NewRW( rwflag, buff, cnt, -1, drv, lrecno );
	
		if ( t )
		{
			if ( t == -14 )
			{
				fprintf( stderr, "Sector not known\n" );
				if ( __NewMediach( drv ) )
					error( 9 );
				if ( !__NewBPB( drv ) )
					error( 10 );
			}
			else if ( t == -29 )
			{
				fprintf( stderr, "Fehler bestÑtigt\n" );
			}
			else if ( t == -31 )
			{
				fprintf( stderr, "Sektornummerfehler signalisiert\n" );
			}
			else
				error( 6 );
		}
		else if ( !rwflag )
		{
			for ( t = 0L; t < (long) cnt; t++ )
			{
				if ( CheckRec( sd, lrecno + t, buff + t * sd->bpb.recsiz ) )
					error( 7 );
			}
		}
			
		if ( !random( 200 ) )
		{
			fprintf( stderr, "Delayed updating\n" );
			if ( !random( 4 ) )
			{
				__NewBPB( drv );
			}
			else
			{
				ciFlush();
			}
			lrecno = ( sd->numRec + 31 ) >> 5;
			for ( t = 0L; t < lrecno; t++ )
				if ( sd->list[t] )
					error( 8 );
		}
	} while ( !( Kbshift( -1 ) & 1 ) );
}
void	Simulate1( void )
{
	long	t;
	
	t = __NewRW( 0, buf, 1, 8, 15, 0L );
	t = __NewRW( 0, buf, 1, 18, 15, 0L );
	t = __NewRW( 1, buf, 1, 18, 15, 0L );
	t = __NewRW( 0, buf, 1, 19, 0, 0L );
	t = __NewRW( 1, buf, 1, 19, 0, 0L );

}
