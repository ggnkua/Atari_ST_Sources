/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							AUTOTACC.PRG								*/
/*																		*/
/*		M O D U L E		:	RDINST.C									*/
/*																		*/
/*																		*/
/*		Author			:	JÅrgen Lietzow fÅr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	26.02.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <tos.h>
#include <string.h>

#include "transfer.h"

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
extern	PHYS_HEAD physstart;
extern	long	_PasPag;
extern	long	_PgmSize;
extern	long	Cookies[];

extern	void	*ResetSpooler( void );
extern	PHYS_HEAD *GetTopHead( void );
extern	long	InstCookie( long c_name, long c_cook );
extern	long	*GetCookie( long cookie );

		int		errno;			/* FÅr die Standard-Bibliothek */
static	char	fname[] = "A:\\" SAVE_FILE;

static	char	*mes[] = {

			"\r\n"
			"*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*\r\n"
			"*                                     *\r\n"
			"*   TOS - Accessory                   *\r\n"
			"*   ===============                   *\r\n"
			"*                                     *\r\n"
			"*   Residenter Programmteil           *\r\n"
			"*   installiert !                     *\r\n"
			"*                                     *\r\n"
			"*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*\r\n"
			,
			"\r\n\b"
			"TOS-Accessory: Programmteil\r\n"
			"ist bereits permanent installiert !\r\n"
			,
			"\r\n\b"
			"TOS-Accessory: Info-Datei <<TOSACC.INF>>\r\n"
			"nicht gefunden !\r\n"
			,
			"\r\n\b"
			"TOS-Accessory: RAM-Disk findet keine\r\n"
			"freie Laufwerksnummer\r\n"
			,
			"\r\n\b"
			"TOS-Accessory: Nicht genÅgend Speicher\r\n"
			"oder illegale Speicherverteilung\r\n"

		};
	



	
	
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
	bpb->rdlen = 4;			/* VerzeichnislÑnge */
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

int		AllocPH( int kbsiz, PHYS_HEAD **ph, int drive )
{
	long		max;
	long		len;
	char		*buf;
	char		*phbuf;
	long		size;
	long		stack;
	long		*src, *dest;
	char		*ptrs[MAX_BLOCKS];
	int			i;

	physstart.hd_maxsec = SetBPB( kbsiz, &physstart.hd_bpb );
	size = (long) kbsiz * 1024L + physstart.code_len;

	size += ( 3 * sizeof (CH_BLOCK) );
	size += (long) (MAX_DBLOCKS / 16) * 2L;
	
	buf = NULL;
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
		return ( 1 );				/* Out of memory */

	Mshrink( 0, buf, len - ( size + 512L + 10L ) );
	phbuf = Malloc( size + 512L );

	while ( i-- )
		Mfree( ptrs[i] );
		
	if ( !phbuf )
		return ( 2 );				/* Illegal memory organisation */

	if ( phbuf < buf )
	{
		Mfree( phbuf );
		return ( 2 );				/* Illegal memory organisation */
	}

/*
	(long) phbuf += 0x1ffL;
	(long) phbuf &= 0xfffffe00L;		PC-Bug
*/
	phbuf = (void *) (((long) phbuf + 0x1ffL ) & 0xfffffe00L);

	stack = Super( 0 );
	phystop = phbuf;
	Super( (void *) stack );	

	*ph = (PHYS_HEAD *) phbuf;

	physstart.hd_size = kbsiz;
	if ( kbsiz )
	{
		physstart.drive_on = 1;
		physstart.drive = drive;
	}
	else
	{
		physstart.drive_on = 0;
	}

	max = physstart.code_len >> 2;
	
	dest = (long *) phbuf;
	src = (long *) &physstart;
	
	do
	{
		*dest++ = *src++;
	} while ( --max );

	return ( 0 );
}

void		LinkSYS( PHYS_HEAD *ph, int drive )
{
	long	stack;
		
	stack = Super( 0L );

	ph->resvec = _resvector;
	ph->resmag = _resvalid;
	
	_resvector = (void (*)(void)) (ph+1);
	_resvalid = RESMAGIC;

		
	sys.ph_head = ph;
	sys.rd_bpb = &(ph->hd_bpb);
	sys.rd_maxsec = ph->hd_maxsec;
	sys.rd_size = ph->hd_size;
	sys.rd_data = ResetSpooler();

	if ( _sysbase->os_version >= 0x102 )
	{
		*(sys.OldBcostat0) = _bcostat0vec;
		*(sys.OldBconout0) = _bconout0vec;
		_bcostat0vec = sys.NewBcostat0;
		_bconout0vec = sys.NewBconout0;
		sys.OSVers = 1;
	}
	else
		sys.OSVers = 0;

	*(sys.OldGEMDOS) = SysGEMDOS;			
	SysGEMDOS = *(sys.NewGEMDOS);

	*(sys.OldBIOS) = SysBIOS;
	SysBIOS = *(sys.NewBIOS);

	*(sys.OldXBIOS) = SysXBIOS;
	SysXBIOS = *(sys.NewXBIOS);

	sys.rd_drive = drive;
	if ( drive >= 2 )
	{
		sys.rd_installed = 1;

		*(sys.OldMediach) = *hdv_mediach;
		*(sys.OldRW) = *hdv_rw;
		*(sys.OldBPB) = *hdv_bpb;
		
		*hdv_mediach = sys.NewMediach;
		*hdv_rw = sys.NewRW;
		*hdv_bpb = sys.NewBPB;
	}
	else
	{
		sys.rd_installed = 0;
	}

	*(sys.OldKEYBD) = SysKEYBD;
	*(sys.Old200HZ) = Sys200HZ;
		
	SysKEYBD = sys.NewKEYBD;
	Sys200HZ = sys.New200HZ;
	
	Super( (void *) stack );
}

int		ReadInf( TACC_INF *taccInf )
{
	int		handle;
	
	fname[0] += Dgetdrv();

	if ( ( handle = Fopen( fname, FO_READ ) ) < 6 ||
		 Fread( handle, sizeof (TACC_INF), taccInf ) != sizeof (TACC_INF)
		 || strcmp( taccInf->version, VERSION ) )
	{
		taccInf->onFlag = 0;
		taccInf->size = 0;
	}
	Fclose( handle );
	return ( 0 );
}


int		main( void )
{
	PHYS_HEAD	*ph;
	TACC_INF	taccInf;
	int			drive;
	int			flag = 0;
	char		params[62];
	long		len;
	
	if ( GetCookie( 'TAcc' ) )
	{
		Cconws( mes[1] );
		return ( 0 );
	}
	
	if ( ReadInf( &taccInf ) )
	{
		Cconws( mes[2] );
		return ( 0 );
	}

	if ( taccInf.onFlag && ( drive = MarkDrv( taccInf.drive ) ) < 2 )
	{
		Cconws( mes[3] );
		return ( 0 );
	}

	if ( ( ph = GetTopHead() ) == NULL || ph->magic != 'TAcc' )
	{
		if ( !taccInf.onFlag )
			taccInf.size = 0;
		if ( AllocPH( taccInf.size, &ph, drive ) )
		{
			Cconws( mes[4] );
			FreeDrv( drive );
			return ( 0 );
		}
	}
	else
		flag = 1;
		
	LinkSYS( ph, drive );
	
	if ( !flag )
		memset( sys.rd_data, 0, (long) sys.rd_bpb->datrec * 512L );

	len = InstCookie( 'TAcc', (long) &sys );
	if ( len )
		ph->our_cookie = 1;
	else
		ph->our_cookie = 0;
	
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

	Cconws( mes[0] );
	
	len += (long) Cookies;
	len -= (long) _BasPag;

	Ptermres( len, 0 );
	return ( 0 );
}