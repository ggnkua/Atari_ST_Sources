/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 3/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							AUTOTACC.PRG								*/
/*																		*/
/*		M O D U L E		:	RDINST.C									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	31.01.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <tos.h>
#include <string.h>

#include "transver.h"

#define		_drvbits		(*(long *) 0x4c2)
#define		phystop			(*(void **) 0x42e)
#define		_memtop			(*(void **) 0x436)
#define		MAGIC1			'TAcc'
#define		MAGIC2			'TARD'

extern	SYS		sys;
extern	RD_HEAD	*GetOldRD( void );
extern	RES_HEAD ResMaster;

		int		errno;			/* Fr die Standard-Bibliothek */
static	char	fname[] = "A:\\" SAVE_FILE;

int		SetBPB( int kbsiz, BPB *bpb )
{
	int		nsecs;

	nsecs = kbsiz * 2;

	bpb->recsiz = 512;
	bpb->clsiz = 2;
	bpb->clsizb = 1024;
	bpb->bflags = 1;
	bpb->fsiz = ( nsecs + 512 ) / ( 2 * ( 512 / 2 ) );
	bpb->fatrec = 1 + bpb->fsiz;
	bpb->rdlen = 4;			/* Verzeichnisl„nge */
	bpb->datrec = bpb->fatrec + bpb->fsiz + bpb->rdlen;
	
	if ( bpb->datrec & 1 )
	{
		bpb->datrec++;
		bpb->rdlen++;
	}
	
	bpb->numcl = ( nsecs - bpb->datrec ) / bpb->clsiz;
	return ( nsecs );
}

int		MarkDrv( int drv )
{
	long	stack;
	long	map;
	
	stack = Super( 0L );
	map = _drvbits;

	do
	{
		if ( !( ( 1L << drv ) & map ) ) 
		{
			_drvbits |= 1L << drv;
			Super( (void *) stack );
			return ( drv );
		}
		drv++;
	} while ( drv <= 15 );

	Super( (void *) stack );

	return ( -1 );						/* No drive */	
}

void	FreeDrv( int drv )
{
	long	stack;
	
	stack = Super( 0L );
	_drvbits &= ~(1L << drv);
	Super( (void *) stack );

}

int		InstRD( int kbsiz, RD_HEAD **hd )
{
	long		max;
	char		*buf;
	char		*rdbuf;
	long		size;
	BPB			bpb;
	RD_HEAD		*head;
	int			secs;
	RES_HEAD	*res;
	int			i;
	int			sum;
	int			*ptr;
	long		stack;
	
	secs =	SetBPB( kbsiz, &bpb );
	size = (long) kbsiz * 1024L + sizeof (RD_HEAD);
	
	max = (long) Malloc( -1L );
	buf = Malloc( max );
	
	if ( max < size + 1024L + 10L + 512L )
	{
		Mfree( buf );
		return ( 3 );				/* Out of memory */
	}

	Mshrink( 0, buf, max - ( size + 1024 + 512L  + 10L ) );
	rdbuf = Malloc( size + 1024L + 512L );
	Mfree( buf );
	
	if ( !rdbuf )
	{
		return ( 2 );					/* Illegal memory organisation */
	}

	if ( rdbuf < buf )
	{
		Mfree( rdbuf );
		return ( 2 );					/* Illegal memory organisation */
	}

/*
	(long) rdbuf += 0x1ffL;
	(long) rdbuf &= 0xfffffe00L;		PC-Bug
*/
	rdbuf = (void *) (((long) rdbuf + 0x1ffL ) & 0xfffffe00L);

	res = (RES_HEAD *) rdbuf;
	rdbuf = (void *) ((long) rdbuf + 512L);

	stack = Super( 0 );
/*
	phystop = res;
*/
	phystop = rdbuf;
	Super( (void *) stack );	
	memset( rdbuf, 0, size );
	
	
	head = (RD_HEAD *) rdbuf;
	head->magic1 = MAGIC1;
	head->magic2 = MAGIC2;
	head->hd_selfe = head;
	head->hd_size = kbsiz;
	head->hd_bpb = bpb;
	head->hd_maxsec = secs;

	*hd = head;
/*
	memset( res, 0, 512L );
	*res = ResMaster;
	res->selfe = res;
	res->head = head;
	ptr = (int *) res;
	sum = 0;
	
	for ( i = 0; i < 256; i++ )
		sum += *ptr++;
	
	res->chksum = 0x5678 - sum;
*/
	return ( 0 );
}
/*
int		InstRD( int kbsiz, RD_HEAD **hd )
{
	char	*screen, *end;
	long	max;
	char	*buf;
	char	*rdbuf;
	long	size;
	BPB		bpb;
	RD_HEAD	*head;
	int		secs;
	
		
	secs =	SetBPB( kbsiz, &bpb );
	size = (long) kbsiz * 1024L + sizeof (RD_HEAD);
	
	end = phystop;
	
	max = (long) Malloc( -1L );
	buf = Malloc( max );
	screen = Physbase();
	
	if ( max < size + 256L + 2L )
	{
		Mfree( buf );
		return ( 3 );				/* Out of memory */
	}
	
	Mshrink( 0, buf, max - ( size + 256L + 64L ) );
	rdbuf = Malloc( size + 256L + 2L );
	Mfree( buf );
	
	if ( !rdbuf )
		return ( 2 );					/* Illegal memory organisation */

	if ( rdbuf < buf )
	{
		Mfree( rdbuf );
		return ( 2 );					/* Illegal memory organisation */
	}

	phystop = (void *) ( ( (long) rdbuf + 2L ) & 0xfffffffcL );

	sys.rd_newscreen = (void *) ( ( (long) screen - size - 10000L ) & 0xffffff00L );
	sys.rd_total = size;
	sys.rd_oldtop = end;

	sys.rd_valsav = _resvalid;
	sys.rd_vecsav = _resvector;
	_resvalid = RESMAGIC;
	_resvector = RDCopy;
	
	head = (RD_HEAD *) phystop;
	head->magic1 = MAGIC1;
	head->magic2 = MAGIC2;
	head->hd_selfe = head;
	head->hd_size = kbsiz;
	head->hd_bpb = bpb;
	head->hd_maxsec = secs;

	*hd = head;
	return ( 0 );
}
*/
void		LinkRD( RD_HEAD	*head, int drive )
{
	long	stack;
	
	stack = Super( 0L );
	
	sys.rd_drive = drive;
	sys.rd_installed = 1;
	sys.rd_head = head;
	sys.rd_bpb = &(head->hd_bpb);
	sys.rd_maxsec = head->hd_maxsec;
	sys.rd_size = head->hd_size;

	*(sys.OldMediach) = *hdv_mediach;
	*(sys.OldRW) = *hdv_rw;
	*(sys.OldBPB) = *hdv_bpb;
	
	*hdv_mediach = sys.NewMediach;
	*hdv_rw = sys.NewRW;
	*hdv_bpb = sys.NewBPB;
	
	Super( (void *) stack );
}

int		ReadInf( TACC_INF *taccInf )
{
	int		handle;
	
	fname[0] += Dgetdrv();

	if ( ( handle = Fopen( fname, FO_READ ) ) < 6 )
		return ( 0 );

	if ( Fread( handle, sizeof (TACC_INF), taccInf ) != sizeof (TACC_INF)
		 || strcmp( taccInf->version, VERSION ) )
	{
		Fclose( handle );
		return ( 0 );
	}
	Fclose( handle );
	return ( taccInf->onFlag );
}

int		DoRD( void )
{
	RD_HEAD		*head;
	TACC_INF	taccInf;
	int			drive;
	int			ret;
	int			flag = 0;
	long		stack;
	char		params[62];
			
	sys.rd_installed = 0;

	if ( !ReadInf( &taccInf ) )
		return ( 1 );
		
	stack = Super( 0L );
	head = GetOldRD();
	Super ( (void *) stack );
	
	if ( ( drive = MarkDrv( taccInf.drive ) ) < 2 )
		return ( 1 );

	if ( !head )
	{
		if ( ( ret = InstRD( taccInf.size, &head ) ) != 0 )
		{
			FreeDrv( drive );
			return ( ret );
		}
	}
	else
		flag = 1;
			
	LinkRD( head, drive );

	if ( taccInf.fname[0] )
		if ( !flag || taccInf.execFlag )
		{
			if ( taccInf.fname[3] )
			{
				strcpy( params + 1, taccInf.params );
				params[0] = (char) strlen( params + 1 );
				Pexec( 0, taccInf.fname, params, (void *) 0L );
			}
		}
		
	return ( 0 );
}