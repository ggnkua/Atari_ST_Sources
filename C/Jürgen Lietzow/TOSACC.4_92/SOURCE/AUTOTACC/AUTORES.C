/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							AUTOTACC.PRG								*/
/*																		*/
/*		M O D U L E		:	AUTORES.C									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	26.02.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <tos.h>
#include <stdarg.h>

#include "transfer.h"

#if !defined (NULL)

#define	NULL	((void *) 0L)

#endif


extern	SYS		sys;

extern	void	XBconout0( long c );		/* wichtig (long) */
extern	int		XBcostat0( void );


/*	Residente Funktionen zur Verwaltung des Drucker-Spoolers */

/*
*	ResetSpooler()
*
*	Gibt die RAM-Disk fr Schreibzugriffe wieder frei
*/

void	*ResetSpooler( void )
{
	PHYS_HEAD		*ph = sys.ph_head;
	CH_BLOCK		*cb;
	int				i;
	unsigned int	*ptr;
	DTA				*dta_sav;
	
	sys.spInPos = sys.spOutPos = sys.spRun = sys.spLocked =
	sys.spLockCount = sys.spDemand = sys.spBcostatFlag = 
	sys.spGDBufPos = 0;
	sys.spNChars = sys.spLockTime = 0L;
	sys.spNBlocks = 3;
		
	if ( sys.spFile[0] )
	{
		dta_sav = Fgetdta();
		Fsetdta( &(sys.spDTA) );
		if ( ( i = Fcreate( sys.spFile, 0 ) ) >= 0 )
			Fclose( i );
		Fsetdta( dta_sav );
	}
	
	cb = (CH_BLOCK *) ( ((long) ph) + ph->code_len );
	
	sys.spOutFree = cb++;
	sys.spFrees = cb;
	cb->next_type = NOBUF;
	cb->next.ptr = NULL;
	cb++;
	sys.spOutBlk = sys.spInBlk = cb;
	cb++;

	sys.spBMap = ptr = (unsigned int *) cb;
		
	for ( i = 0; i < MAX_DBLOCKS / 16; i++ )
		*ptr++ = 0U;
	
	sys.rd_locked = 0;
	
	return ( ptr );
}

/*
*	MarkBlock()
*
*	Anhand einer Bit-Map wird festgestellt, wo ein Block in der 
*	Spooler-Datei frei ist
*/

void	MarkBlock( int num )
{
	unsigned int	*ptr = sys.spBMap;
	
	ptr += (num >> 4);
	
	num &= 0xfU;
	
	*ptr |= (0x8000U >> num);
}
	
void	FreeBlock( int num )
{
	unsigned int	*ptr = sys.spBMap;
	
	ptr += (num >> 4);
	
	num &= 0xfU;
	
	*ptr &= ~(0x8000U >> num);
}

int		GetBlock( void )
{
	unsigned int	*ptr = sys.spBMap;
	int				num = 0;
	unsigned int	pos = 0x8000U;

	while ( *ptr == 0xffffU )
	{
		ptr++;
		num += 16;
	}
	
	while ( *ptr & pos )
	{
		pos >>= 1;
		num++;
	}
	return ( num );
}

/*
*	FreeRAMBlk()
*
*	Dieser Block ist komplett an den Drucker geschickt worden, und
*	steht folglich zur weiteren Verwendung frei
*/
		
void	FreeRAMBlk( CH_BLOCK *cb )
{
	if ( !sys.spOutFree )
	{
		sys.spOutFree = cb;
		return;
	}
	if ( !sys.spFrees )
		cb->next_type = NOBUF;
	else	
		cb->next_type = RAMBUF;
	
	cb->next.ptr = sys.spFrees;
	
	sys.spFrees = cb;
}

/*
*	WriteBlock()
*
*	schreibt einen Block bei RAM-Mangel in die Spooler-Datei
*/

int			WriteBlock( CH_BLOCK *cb, int num )
{
	int		handle;
	long	off;
	DTA		*dta_sav;
	
	if ( !sys.spFile[0] )
		return ( -1 );

	dta_sav = Fgetdta();
	Fsetdta( &(sys.spDTA) );
	
	if ( ( handle = Fopen( sys.spFile, FO_RW ) ) < 0 )
	{
		Bconout( 2, 7 );
		Fsetdta( dta_sav );
		return ( -1 );
	}
	
	off = (long) num * 1024L;
	
	if ( Fseek( off, handle, 0 ) != off )
	{
		Fsetdta( dta_sav );
		Fclose( handle );
		return ( -1 );
	}
	
	if ( Fwrite( handle, 1024L, cb ) != 1024L )
	{
		Fsetdta( dta_sav );
		Fclose( handle );
		return ( -1 );
	}
	
	Fsetdta( dta_sav );
	Fclose( handle );
	MarkBlock( num );	
	return ( 0 );
}	
	
/*
*	ReadBlock()
*
*	liest einen zuvor geschrieben Block, um nun ausgedruckt zu werden
*/

int			ReadBlock( CH_BLOCK *cb, int num )
{
	int		handle;
	long	off = (long) num * 1024L;
	DTA		*dta_sav;
	
	dta_sav = Fgetdta();
	Fsetdta( &(sys.spDTA) );
	
	if ( ( handle = Fopen( sys.spFile, FO_READ ) ) < 0 )
	{
		Fsetdta( dta_sav );
		return ( -1 );
	}
	
	if ( Fseek( off, handle, 0 ) != off )
	{
		Fclose( handle );
		Fsetdta( dta_sav );
		return ( -1 );
	}
	
	if ( Fread( handle, 1024L, cb ) != 1024L )
	{
		Fclose( handle );
		Fsetdta( dta_sav );
		return ( -1 );
	}
	
	Fclose( handle );
	Fsetdta( dta_sav );
	FreeBlock( num );	
	return ( 0 );
}	

/*
*	ChangeBlock()
*
*	Da ein Block immer auf den n„chsten zeigt, und sich der n„chste
*	Block vom RAM in die Datei verschoben hat, muž der Zeiger
*	hier angepažt werden
*/

int	ChangeBlock( int num, ... )
{
	int		handle;
	long	off = (long) num * 1024L;
	va_list	ptr;
	void	*p;
	DTA		*dta_sav;
	
	dta_sav = Fgetdta();
	Fsetdta( &(sys.spDTA) );
	
	va_start( ptr, num );
	p = ptr;
	va_end( ptr );
	
	if ( ( handle = Fopen( sys.spFile, FO_WRITE ) ) < 0 )
	{
		Fsetdta( dta_sav );
		return ( -1 );
	}
	
	if ( Fseek( off, handle, 0 ) != off )
	{
		Fclose( handle );
		Fsetdta( dta_sav );
		return ( -1 );
	}
	
	if ( Fwrite( handle, 6L, p ) != 6L )
	{
		Fclose( handle );
		Fsetdta( dta_sav );
		return ( -1 );
	}
	
	Fclose( handle );
	Fsetdta( dta_sav );
	return ( 0 );
}	

/*
*	AllocDiskRAM()
*
*	besorgt den freien Speicher der RAM-Disk
*/

void	AllocDiskRAM( void )
{
	BPB			*bpb = sys.rd_bpb;
	char		*ptr = sys.rd_data;
	int			*clu;
	CH_BLOCK	*cb;
	int			max;
	int			i;
	
	if ( !sys.rd_maxsec || !sys.rd_installed )
		return;
	
	cb = (CH_BLOCK *) (ptr + ( ((long) bpb->datrec) * 512L ) );
	clu = (int *) (ptr + 512);
	
	max = bpb->numcl;
	sys.spNBlocks = 3L;
/*	Die ersten 2 FAT-Eintr„ge sind frei */

	clu += 2;	
	for ( i = 0; i < max; i++, clu++ )
		if ( !*clu )
		{
			cb[i].next.ptr = sys.spFrees;
			if ( sys.spFrees )
				cb[i].next_type = RAMBUF;
			else
				cb[i].next_type = NOBUF;
			sys.spFrees = cb + i;
			sys.spNBlocks++;
		}
	
	sys.rd_locked = 1;
}

/*
*	GetFreeRAMBlk()
*
*	besorgt einen Speicherblock (evtl durch Auslagern eines anderen)
*/

CH_BLOCK	*GetFreeRAMBlk( CH_BLOCK *old )
{
	CH_BLOCK	*cb;
	int			num;

/* <<old>> ist letzter input buffer, und damit immer im RAM */

	if ( !sys.rd_locked && sys.rd_maxsec && sys.rd_installed )
		AllocDiskRAM();
		
	if ( ( cb = sys.spFrees ) == NULL )
	{
		if ( ( num = GetBlock() ) > MAX_DBLOCKS )
			return ( NULL );
		old->next.ptr = old;
		old->next_type = RAMBUF;
		if ( WriteBlock( old, num ) )
		{
			old->next_type = NOBUF;
			old->next.ptr = NULL;
			return ( NULL );
		}
		if ( sys.spLastType == RAMBUF )
		{
			sys.spLast.ptr->next.pos = (long) num;
			sys.spLast.ptr->next_type = DISKBUF;
		}
		else
		{
			if ( ChangeBlock( (int) sys.spLast.pos, DISKBUF, (long) num ) )
			{
				old->next_type = NOBUF;
				old->next.ptr = NULL;
				FreeBlock( num );
				return ( NULL );
			}
		}
		sys.spLast.pos = (long) num;
		sys.spLastType = DISKBUF;
		old->next_type = NOBUF;
		cb = old;
	}
	else
	{
		sys.spFrees = cb->next.ptr;
		old->next_type = RAMBUF;
		old->next.ptr = cb;
		sys.spLastType = RAMBUF;
		sys.spLast.ptr = old;
		cb->next_type = NOBUF;
	}
	return ( cb );
}

/*
*	InputStatus()
*
*	wird vom BIOS-Trap aufgerufen (Bcostat)
*/

long		InputStatus( void )
{
	CH_BLOCK		*cb;
	
	if ( sys.spGEMDOSFlag )			/* vom GEMDOS aus aufgerufen ? */
	{
		sys.spBcostatFlag = 1;
		if ( sys.spGDBufPos < sizeof(sys.spGDBuf) - 2 )
			return ( 1L );
		else
			return ( 0L );
	}
		
	if ( !sys.spNChars && sys.rd_locked )
		ResetSpooler();

	if ( !sys.spLocked )
		return ( -1L );
	
	if ( sys.spLockTime < _hz_200 - 400L )
		return ( 0L );
	else
	{
		sys.spLockCount++;
		sys.spLockTime = _hz_200;
	}
		
	sys.in200HZ++;	
	if ( ( cb = GetFreeRAMBlk( sys.spInBlk ) ) == NULL )
	{
		sys.in200HZ--;	
		return ( 0L );
	}
	
	sys.spInPos = 0;
	sys.spInBlk = cb;
	sys.spLockCount = 0;
	sys.spLocked = 0;
	sys.in200HZ--;	
	return ( -1L );
}
	
/*
*	InputChar()
*
*	wird vom BIOS-Trap aufgerufen (Bconout)
*/

long	InputChar( char c )
{
	CH_BLOCK	*cb;
	
	if ( sys.spGEMDOSFlag )
	{
		if ( sys.spGDBufPos < sizeof (sys.spGDBuf) - 1 )
		{
			sys.spGDBuf[sys.spGDBufPos++] = c;
			return ( -1 );
		}
		else
			return ( 0 );
	}
			
	if ( sys.spRun )		/* nichts geht mehr */
		return( 0L );
		
	sys.in200HZ++;	
	while ( sys.spLocked )	/* aktueller cb ist voll */
	{
		if ( InputStatus() )
			break;
		if ( sys.spLockCount > 15 )		/* Time out zeit */
			sys.spRun = 1;
		sys.in200HZ--;	
		return( 0L );
	}

	cb = sys.spInBlk;			
	cb->data[sys.spInPos++] = c;
	sys.spNChars++;
	
	if ( sys.spInPos >= MAX_CHARS )
	{
		if ( ( cb = GetFreeRAMBlk( cb ) ) == NULL )
		{
			sys.spLockTime = _hz_200;
			sys.spLocked = 1;			/* Buffer momentan voll */
		}
		else
		{
			sys.spInBlk = cb;
			sys.spInPos = 0;
		}
	}
	sys.in200HZ--;	
	return ( -1L );
}

/*
*	DemandBlock()
*
*	wird von allen Traps aufgerufen. Holt einen Speicherblock von Disk
*	ins RAM
*/

void	DemandBlock( void )
{
	CH_BLOCK	*cb = sys.spOutBlk;
	int			pos = sys.spOutPos;
	CH_BLOCK	*n;

	sys.in200HZ++;	
	if ( pos >= MAX_CHARS && cb->next_type == DISKBUF )
	{
		if ( ReadBlock( cb, (int) cb->next.pos ) )
		{
			sys.in200HZ--;	
			return;
		}
		sys.spOutPos = 0;
	}
	if ( sys.spNChars < MAX_CHARS || cb->next_type == RAMBUF )
	{
		sys.spDemand = 0;
		sys.in200HZ--;	
		return;
	}
	if ( ( n = sys.spFrees ) == NULL )
	{
		if ( ( n = sys.spOutFree ) == NULL )
		{
			sys.in200HZ--;	
			return;
		}
		else
		{
			if ( ReadBlock( n, (int) cb->next.pos ) )
			{
				sys.in200HZ--;	
				return;
			}
			else
				sys.spOutFree = NULL;
		}
	}
	else
		if ( ReadBlock( n, (int) cb->next.pos ) )
		{
			sys.in200HZ--;	
			return;
		}
		else
			sys.spFrees = n->next.ptr;
			
	cb->next_type = RAMBUF;
	cb->next.ptr = n;
	sys.spDemand = 0;
	sys.in200HZ--;	
}

/*
*	OutputChar()
*
*	wird vom HZ200-Timer aufgerufen. Sendet also Zeichen vom Spooler
*	zum Drucker
*/

void	OutputChar( void )
{
	CH_BLOCK	*cb = sys.spOutBlk;
	int			pos = sys.spOutPos;
	long		temp = _hz_200 + sys.spRate;
	
	if ( pos >= MAX_CHARS )
	{
		if ( cb->next_type == RAMBUF )
		{
			sys.spOutBlk = cb->next.ptr;
			FreeRAMBlk( cb );
			pos = 0;
			cb = sys.spOutBlk;
		}
		else
		{
			sys.spDemand = 1;
			return;
		}
	}

	do
	{
		if ( !XBcostat0() )
			continue;
		
		XBconout0( (long) cb->data[pos] );
		sys.spNChars--;
		pos++;
	
		if ( !sys.spNChars )
			break;
				
		if ( pos >= MAX_CHARS )
		{
			if ( cb->next_type == RAMBUF )
			{
				sys.spOutBlk = cb->next.ptr;
				FreeRAMBlk( cb );
				cb = sys.spOutBlk;
				pos = 0;
			}
			else
			{
				sys.spDemand = 1;
				break;
			}
		}
	} while ( _hz_200 < temp );

	sys.spOutPos = pos;
}
	
