/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/92  <<<<<<<<<<<<<		*/
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
/*		Last Update		:	27.04.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <tos.h>
#include <string.h>

#include "transfer.h"

/*
#define	DEBUG
*/

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

#ifdef DEBUG

extern	RES_MEM	*_Malloc( long len );

#define	AllocResMem(a,b)	_Malloc( a )

extern	long	cdecl	S_Mediach( int drive );
extern	long	cdecl	S_RW( int rwflag, void *buff, int cnt, int recnr,
					  int dev, long lrecno );
extern	long	cdecl	S_BPB( int drive );

extern	void	Simulate( void );
extern	void	Simulate1( void );
#endif

extern	SYS		sys;
SYS		 *s;
extern	long	_PasPag;
extern	long	_PgmSize;
extern	long	_ResStart[];

extern	void	*ResetSpooler( void );
extern	long	InstCookie( long c_name, long c_cook );
extern	long	*GetCookie( long cookie );

		int		errno;			/* FÅr die Standard-Bibliothek */

static	char	*mes[] = {

			"\r\n\x1Bp"
			"                                       \r\n"
			"    TOS - Accessory             v" _VERSION "  \r\n"
			"                                       \r\n"
			"                    (c) by ICP-Verlag  \r\n"
			"                           J. Lietzow  \r\n"
			"                             27.04.92  \r\n"
			"                                       \r\n"
			"\r\n\x1Bq"
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
	

void	SetBPB( BPB *bpb, int nblk, int recsiz )
{
	bpb->recsiz = recsiz;
	bpb->clsiz = 2;
	bpb->clsizb = 2 * recsiz;
	bpb->bflags = 1;
	bpb->fsiz = ( nblk / ( recsiz / 2 ) ) + 1;
	bpb->fatrec = 1 + bpb->fsiz;
	bpb->rdlen = 6;			/* VerzeichnislÑnge */
	bpb->datrec = bpb->fatrec + bpb->fsiz + bpb->rdlen;
	bpb->numcl = ( nblk - bpb->datrec ) / bpb->clsiz;
}

PUN_INFO	*GetPun( void )
{
	PUN_INFO	*p;
	long		stack;
	
	stack = Super( 0L );
	p = *((PUN_INFO **) 0x516);
	Super( (void *) stack);
	
	if ( p && p->P_cookie == 'AHDI' && p->P_cookptr == &(p->P_cookie ) &&
		 p->P_version >= 0x0300 )
		return ( p );
	return ( NULL );
}

long	SetSYS1( int kbsiz, int recsiz )
{
	long	len = 0L;
	long	nblk;
	long	fatsiz;

	sys.absRecSiz = recsiz;
	sys.recSiz = recsiz / 512;
	sys.blkSiz = recsiz + (int) sizeof (RECINF);
	sys.kbSiz = kbsiz;
	
	nblk = sys.rdMaxRec = ( (long) kbsiz * 1024L ) / recsiz;
	
	SetBPB( &(sys.rdBpb), (int) nblk, recsiz );

	fatsiz = sys.rdBpb.fsiz;
		
	sys.blkNum = (int)(nblk = nblk + 5 - fatsiz);

	len = 2L * (long) recsiz;
	len += (long) nblk * ( (long) recsiz + sizeof (RECINF) );
	len += (long) sys.rdMaxRec * sizeof (SECTOR *);
	len += sizeof (RESINF);
		
	return ( len );
}
	
void	SetSYS2a( RESINF *res )
{
	void	*ptr = res + 1;
	long	*lp;
	long	blksiz;
	long	recsiz;
	long	n;
	int		i;
	int		fsiz;
	
	recsiz = sys.absRecSiz;
	fsiz = sys.rdBpb.fsiz;
	n = sys.blkNum;
	blksiz = sys.blkSiz;

	sys.ciBlkNum = 0;
	sys.rdBlkNum = 1 + 6 + fsiz;
	sys.spBlkNum = 1;
	
	memset( ptr, 0, (long) sys.rdMaxRec * sizeof (long *) );
	sys.rdRecPtrs = (void *) lp = ptr;
	(long *) ptr += (long) sys.rdMaxRec;

	sys.copyBlk = ptr;
	(char *) ptr += 2L * recsiz;
	
	memset( ptr, 0,  n * blksiz );
	sys.blkArr = ptr;
	
	*lp++ = (long) ptr;					/* Boot-Sektor */
	(char *) ptr += blksiz;
	n--;
	
	for ( i = 0; i < fsiz; i++ )
		*lp++ = (long) ptr + (long) ( i * recsiz );
	for ( i = 0; i < fsiz + 6; i++ )
	{
		*lp++ = (long) ptr + (i * recsiz);
		n--;
	}
	(char *) ptr += blksiz * ( fsiz + 6 );
	
	sys.spInBlk = sys.spOutBlk = ptr;
	(char *) ptr += blksiz;
	n--;
	
	sys.ciNewest.riOlder = &sys.ciOldest;
	sys.ciOldest.riNewer = &sys.ciNewest;
	
	sys.blkFrees = ptr;
	sys.blkFreeNum = (int) n;
	
	while ( --n )
	{
		*(long *)ptr = (long) ptr + blksiz;
		(char *) ptr += blksiz;
	}
	*(long *)ptr = 0L;
}
	
void		*GetNextFree( void *last_blk )
{
	int		i;
	long	*ptr;
	long	b = (long) last_blk;
	long	max;
	long	s = sys.blkSiz;
	
	max = sys.blkNum * s + (long) sys.blkArr;
	
	do
	{
		b += s;
		ptr = (long *) sys.rdRecPtrs;
		for ( i = (int) sys.rdMaxRec + 1; --i; )
			if ( *ptr++ == b )
				break;
		if ( !i )
			break;
	} while ( b < max );
		
	if ( b >= max )
		return ( NULL );
	else
		return ( (void *) b );
}

void	SetSYS2b( RESINF *res )
{
	void	*ptr = res + 1;
	long	n;
	int		fsiz;
	long	*temp;
	long	blksiz;

	fsiz = sys.rdBpb.fsiz;
	n = sys.blkNum;
	blksiz = sys.blkSiz;

	sys.ciBlkNum = 0;
	sys.spBlkNum = 1;

	sys.rdRecPtrs = ptr;
	(long *) ptr += (long) sys.rdMaxRec;

	sys.copyBlk = ptr;
	(char *) ptr += 2L * sys.absRecSiz;
	
	sys.blkArr = ptr;

	n -= ( 6 + 1 + fsiz );	
	
	(char *) ptr += ( ( 6 + fsiz ) * blksiz );
	
	ptr = GetNextFree( ptr );
	sys.spInBlk = sys.spOutBlk = ptr;

	sys.ciNewest.riOlder = &sys.ciOldest;
	sys.ciOldest.riNewer = &sys.ciNewest;
	
	ptr = GetNextFree( ptr );
	sys.blkFrees = ptr;
	n = 0L;
	do
	{
		if ( ptr )
		{
			n++;
			temp = ptr;
		}
		else
			break;
		ptr = GetNextFree( ptr );
		*temp = (long) ptr;
	} while ( 1 );

	sys.blkFreeNum = (int) n;
	sys.rdBlkNum = sys.blkNum - ( (int) n + 1 );
}

void	SetRest( int *drvInf )
{
	int			i;
	DRIVEINF	*di = &sys.di[0];
	
	for ( i = 0; i < 16; i++, di++ )
	{
		di->diFirst.riNext = &(di->diLast);
		di->diFirst.riLast = &(di->diFirst);
		di->diFirst.riRecno = -1;
		di->diLast.riLast = &(di->diFirst);
		di->diLast.riNext = &(di->diLast);
		di->diLast.riRecno = 0x7ffffffeL;
		di->diValid = 1;
		if ( drvInf[i] & ( D_READ | D_WRITE ) )
		{
			di->diRead = 1;
			if ( drvInf[i] & D_WRITE )
				di->diWrite = 1;
		}
		if ( drvInf[i] & D_LOCKED )
			di->diLocked = 1;
	}
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

void		LinkSYS( void )
{
	long	stack;
		
	stack = Super( 0L );

	sys.OSVers = _sysbase->os_beg->os_version;
#ifndef DEBUG

	if ( sys.OSVers >= 0x102 )
	{
		*(sys._OldBcostat0) = _bcostat0vec;
		(sys_vec) *(sys._OldBconout0) = (sys_vec) _bconout0vec;
		(sys_vec) _bcostat0vec = (sys_vec) sys._NewBcostat0;
		(sys_vec) _bconout0vec = (sys_vec) sys._NewBconout0;
	}
#endif
/*
	(sys_vec) *(sys._OldGEMDOS) = Setexc( 33, (sys_vec) *(sys._NewGEMDOS) );
*/
#ifdef DEBUG

	(sys_vec) *(sys._OldMediach) = (sys_vec) S_Mediach;
	(sys_vec) *(sys._OldRW) = (sys_vec) S_RW;
	(sys_vec) *(sys._OldBPB) = (sys_vec) S_BPB;

#else
	(sys_vec) *(sys._OldBIOS) = Setexc( 45, (sys_vec) *(sys._NewBIOS) );
	(sys_vec) *(sys._OldXBIOS) = Setexc( 46, (sys_vec) *(sys._NewXBIOS) );

	*(sys._OldMediach) = *hdv_mediach;
	*hdv_mediach = sys._NewMediach;

	*(sys._OldRW) = *hdv_rw;
	*hdv_rw = sys._NewRW;

	*(sys._OldBPB) = *hdv_bpb;
	*hdv_bpb = sys._NewBPB;
#endif

	sys.scOutTime = sys.tai.scTime * 10 + sys.tsecCount;
	
	*(sys._OldKEYBD) = SysKEYBD;
	SysKEYBD = sys._NewKEYBD;

	*(sys._Old200HZ) = Sys200HZ;
	Sys200HZ = sys._New200HZ;
	
	Super( (void *) stack );
}

int		ReadInf( void )
{
	int		handle;
	DTA		*dta_sav, dta;
	char	vers[sizeof(VERSION)];
	
	dta_sav = Fgetdta();
	Fsetdta( &dta );
	
	sys.saveFile[0] += Dgetdrv();

	if ( ( handle = Fopen( sys.saveFile, FO_READ ) ) >= 6 )
	{
		if ( Fread( handle, sizeof (VERSION), vers ) != sizeof (VERSION) ||
		 	 strcmp( vers, VERSION ) ||
			 Fread( handle, sizeof (TACC_INF) - sizeof (VERSION),
			 		sys.tai.version + sizeof (VERSION) ) !=
			 		sizeof (TACC_INF) - sizeof (VERSION) );
	}
	Fclose( handle );
	
	Fsetdta( dta_sav );
	return ( 0 );
}


int		main( void )
{
	RES_MEM		*rm;
	RESINF		*resi;
	int			drive = 0;
	int			flag = 0;
	char		params[62];
	long		len;
	int			kbsiz, recsiz;
		
	s = &sys;
	if ( GetCookie( 'TAcc' ) )
	{
		Cconws( mes[1] );
		return ( 0 );
	}
	
	if ( ReadInf() )
	{
		Cconws( mes[2] );
		return ( 0 );
	}

	sys.rdOn = sys.tai.rdNxtOn;
	if ( ( rm = GetResMem( 'TAcc' ) ) == NULL )
	{
		if ( sys.rdOn && ( drive = MarkDrv( sys.tai.rdNxtDrv ) ) < 2 )
		{
			sys.rdOn = 0;
		}
		sys.rdDrv = drive;
		kbsiz = sys.tai.nxtKbSiz;
		recsiz = sys.tai.nxtRecSiz * 512;
		if ( ( sys.ciPuninfo = GetPun() ) != NULL )
			if ( recsiz < sys.ciPuninfo->P_max_sector )
				recsiz = sys.ciPuninfo->P_max_sector;
#ifdef DEBUG
		recsiz = 512 * 4;
		kbsiz = 80;
#endif	
		if ( ( len = SetSYS1( kbsiz, recsiz ) ) != 0L )
		{
			if ( ( rm = AllocResMem( len, 'TAcc' ) ) == NULL )
			{
				if ( drive >= 2 )
					FreeDrv( drive );
				Cconws( mes[4] );
				return ( 0 );
			}
			sys.resMem = rm;
			resi = rm->rmDataStart;
			resi->kbSiz = kbsiz;
			resi->recSiz = recsiz;
			SetSYS2a( rm->rmDataStart );
		}			
	}
	else
	{
		sys.ciPuninfo = GetPun();
		sys.resMem = rm;
		if ( sys.rdOn && ( drive = MarkDrv( sys.tai.rdNxtDrv ) ) < 2 )
		{
			sys.rdOn = 0;
		}
		sys.rdDrv = drive;
		resi = rm->rmDataStart;
		kbsiz = resi->kbSiz;
		recsiz = resi->recSiz;
		if ( ( len = SetSYS1( kbsiz, recsiz ) ) != 0L )
		{
			SetSYS2b( rm->rmDataStart );
		}
		flag = 1;
	}		
	sys.ahdiFlag = ( sys.ciPuninfo != NULL );
	SetRest( &sys.tai.ciDrvTypes[0] );
	LinkSYS();

#ifndef DEBUG

	len = InstCookie( 'TAcc', (long) &sys );
	if ( len )
		rm->rmClrCookie = 1;
	else
		rm->rmClrCookie = 0;
	
	if ( sys.tai.rdFname[0] )
		if ( !flag || sys.tai.rdExecFlag )
		{
			if ( sys.tai.rdFname[3] )
			{
				strcpy( params + 1, sys.tai.rdParams );
				params[0] = (char) strlen( params + 1 );
				Pexec( 0, sys.tai.rdFname, params, (void *) 0L );
			}
		}
#endif
	Cconws( mes[0] );

#ifdef DEBUG

	sys.tai.rdOn = 1;
	sys.rdDrv = 15;
	
/*	Simulate1();
*/	Simulate();

	len = Super( 0L );	
	
	SysKEYBD = *(sys._OldKEYBD);
	Sys200HZ = *(sys._Old200HZ);
	
	Super( (void *) len );
	
	return ( 0 );
#endif

	len += (long) _ResStart;
	len -= (long) _BasPag;

	Ptermres( len, 0 );
	return ( 0 );
}