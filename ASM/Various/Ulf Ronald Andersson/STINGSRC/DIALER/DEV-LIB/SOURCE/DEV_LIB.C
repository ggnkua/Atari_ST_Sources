/*
 * Project    :		Device Library Version 0.20beta
 * Module     :		dev_lib.c
 * Author     :		Jan Kriesten
 * Date       :     07.05.1995
 *
 * Description:		main routines to install/deinstall devices
 *
 * Tabsize 4
 */

/*-----------------------------*/
/*--- includes              ---*/
/*-----------------------------*/

#include <import.h>
#include <device.h>

#include "dev_misc.h"
#include "types.h"
#include "port.h"

#include <export.h>

/*-----------------------------*/
/*--- defines               ---*/
/*-----------------------------*/

#define		BMAPSTART		5

#define		MAX_BLOCK		4096L
#define		MAX_SPEEDS		25

/*-----------------------------*/
/*--- types                 ---*/
/*-----------------------------*/

typedef enum
{
	DEV_STANDARD=0,
	DEV_FSER,
	DEV_RSVF,
	DEV_MINT,
	DEV_MAGIC
} DEV_TYPES;

typedef struct
{
	/*
	 * Sichtbar fr den User:
	 */
	DEV_LIST	device;		/* Liste der Device-Namen	*/
	
	/*
	 * Sytemdaten:
	 */
	WORD		bios;			/* BIOS-Nr. des Devices					*/
	WORD		func_num;		/* "normierte" Bconmap-Zugriffsnummer	*/
	BYTE		*dopen;			/* Name des Devices fr Fopen( )		*/
	
	/*
	 * Daten zur Verwaltung des Devices:
	 */
	DEV_TYPES	type;			/* Typ des Devices (RSVF, MiNT, Mag!C)	*/
	BOOLEAN		is_open;		/* TRUE, falls Device ge”ffnet			*/
	WORD		dhandle;		/* handle, falls mit Fopen( ) ge”ffnet	*/
	WORD		curr_pos;		/* aktulle Position im Puffer			*/
	WORD		num_read;		/* Anzahl der eingelesenen Zeichen		*/
	
	BYTE		*buf;			/* Zeiger Blockdevice-Puffer			*/
	LONG		*speeds;		/* Liste der einstellbaren DTE-speeds	*/
	CHAN_INFO	*chan_info;		/* Struktur unter FastSeriell			*/
	MAPTAB		*func_map;		/* Tabelle der einzelnen Funktionen		*/
	WORD		oldIBufSize,
				oldOBufSize;
	BYTE		*oldIBufPtr,
				*oldOBufPtr;
	LONG		ioctrlmap[6];	/* Index der m”glichen Fcntl-Funktionen	*/
} DEVICES;

typedef union
{
	UWORD word;
	struct
	{
		UWORD	bit7_15	: 9;
		UWORD	bit5_6	: 2;
		UWORD	bit3_4	: 2;
		UWORD	bit2	: 1;
		UWORD	bit1	: 1;
		UWORD	bit0	: 1;
	} bits;
} UCR;

/*-----------------------------*/
/*--- variables             ---*/
/*-----------------------------*/

LOCAL	UWORD		atari,
					tos,
					MiNT;
LOCAL	VOID		*MagX;

LOCAL	FSER_INFO	*fser;
LOCAL	RSVF_DEV	*rsvf;

LOCAL	BOOLEAN		has_bconmap,
					has_drv_u;

LOCAL	BYTE		*d_name[] =	{
									"Modem 1",
									"Modem 2",
									"Serial 1",
									"Serial 2",
									"Midi"
								},
					*d_open[] =	{
									"MODEM1",
									"MODEM2",
									"SERIAL1",
									"SERIAL2",
								};

LOCAL	LONG		speeds[] =	{
									19200L,
									9600L,
									4800L,
									3600L,
									2400L,
									2000L,
									1800L,
									1200L,
									600L,
									300L,
									200L,
									150L,
									134L,
									110L,
									75L,
									50L,
									-1L
								};
								
LOCAL LONG			midi_speeds[] = { 31250, -1 };

LOCAL	DEVICES		*devices;
LOCAL	LONG		cntrls[4];

LOCAL	VOID		(*pause_1)( VOID );
EXTERN	VOID		(*pause_2)( VOID );

/*--- prototypes            ---*/

LOCAL BOOLEAN	InitStdDevices	( MAPTAB *maps, BOOLEAN has_bconmap, WORD num_devices );
LOCAL BOOLEAN	InitRSVFDevices	( MAPTAB *maps, RSVF_DEV *dev );
LOCAL BOOLEAN	CreateSpeedlist	( DEVICES *dev );
LOCAL BOOLEAN	GetFcntlSpeeds	( DEVICES *dev );
LOCAL VOID		GetFserSpeeds	( DEVICES *dev );
LOCAL VOID		FreeSpeedlist	( DEVICES *dev );
LOCAL VOID		SetDevFunctions	( DEVICES *dev );
LOCAL VOID		SetPortProtokoll( DEVICES *dev );
LOCAL BOOLEAN	DevicePickup	( DEVICES *dev );
LOCAL BOOLEAN	DeviceSendBlock	( DEVICES *dev, BYTE *block, LONG len, BOOLEAN tst_dcd );

/*-----------------------------*/
/*--- global functions      ---*/
/*-----------------------------*/

/*-------------------------------------------------------------------*/ 

GLOBAL DEV_LIST *InitDevices( VOID *timerelease1, VOID *timerelease2 )
{
	/*
	 * Initialisiert alle vorhandenen Ports/Devices.
	 */
	WORD		num_devices;
	BOOLEAN		mega;
	MAPTAB		*maps;

	devices     = NULL;
	tos         = get_tos( );
	has_drv_u   = has_drive_u( );
	has_bconmap = (Bconmap( 0 )==0L);	
	
	pause_1     = timerelease1;
	pause_2     = timerelease2;

	atari = getcookie( '_MCH', cntrls ) ? (UWORD) (cntrls[0]>>16) : 0;
	mega  = (UWORD) cntrls[0] ? TRUE : FALSE;
	fser  = getcookie( 'FSER', cntrls ) ? (FSER_INFO *) cntrls[0] : NULL;
	rsvf  = getcookie( 'RSVF', cntrls ) ? (RSVF_DEV  *) cntrls[0] : NULL;
	MiNT  = getcookie( 'MiNT', cntrls ) ? (WORD)        cntrls[0] : 0;
	MagX  = getcookie( 'MagX', cntrls ) ? (VOID *)      cntrls[0] : NULL;
	
	/*
	 * Set MiNT process execution domain (to let Fread, Fwrite
	 * behave as stated in the terminal settings):
	 */
	if( MiNT && !rsvf && !fser )
		Pdomain( 1 );
	
	if( has_bconmap )
	{
		BCONMAP *bmap = (BCONMAP *) Bconmap( -2 );
		
		maps        = bmap->maptab;
		num_devices = bmap->maptabsize;
		
		if( !maps )
			has_bconmap = FALSE;
	}
	else
		maps        = NULL;
	
	switch( atari )
	{
		case 0:
		case 3:
				num_devices = 1;
				break;
		case 1:
				num_devices = mega ? 3 : 1;
				break;
		case 2:
				num_devices = 4;
				break;
	}
	
	if( !InitStdDevices( maps, has_bconmap, num_devices ) )
		return( NULL );
	
	if( rsvf && !InitRSVFDevices( maps, rsvf ) )
		return( NULL );
	
	return( (devices) ? &(devices->device) : NULL );
}

/*-------------------------------------------------------------------*/ 

GLOBAL VOID TermDevices( VOID )
{
	/*
	 * Gibt den Speicher der Device-Liste wieder frei:
	 */
	
	DEVICES	*dwalk;
	
	for( dwalk=devices; dwalk; dwalk=devices )
	{
		CloseDevice( (DEV_LIST *) dwalk );
		
		devices = (DEVICES *) dwalk->device.next;
		free( dwalk );
	}
}

/*-------------------------------------------------------------------*/ 

GLOBAL BOOLEAN OpenDevice( DEV_LIST *port )
{
	/*
	 * ™ffnet port und stellt alle entsprechenden Funktionen zusammen.
	 */
	DEVICES	*dev;
	
	dev = (DEVICES *) port;

	if( dev->is_open )
		return( FALSE );
	
	/*
	 * Erst den Standard-Aux umsetzen:
	 */
	if( has_bconmap && dev->bios>5 )
		Bconmap( dev->bios );
	
	/*
	 * Bei FastSerial keine Blockdevice-Routinen benutzen:
	 */
	if( fser && (dev->bios==1 || dev->bios>5) )
	{
		CHAN_INFO	*tst;
		
		tst = (CHAN_INFO *) Rsconf( -3, -3, -1, -1, -1, -1 );
		
		if( tst->task>0 )
			return( FALSE );
		
		dev->chan_info = tst;
		dev->is_open   = TRUE;
	}
	
	/*
	 * Testen, ob es sich um ein Block-Device handelt:
	 */
	if( !dev->is_open	&&
		dev->dopen		&&
		(dev->type==DEV_RSVF || dev->type==DEV_MINT) )
	{
		BYTE	path[64];
		LONG	rc;
		
		strcpy( path, "U:\\DEV\\" );
		strcpy( path+7, dev->dopen );
	
		if( (rc=Fopen( path, FO_RW|O_NDELAY ))>=0 )
		{
			dev->dhandle = (WORD) rc;
			dev->is_open = TRUE;
		}
		/*
		 * Falls -36 (EACCDN) zurckgegeben wird, so wurde das Device
		 * schon von einer anderen Applikation ge”ffnet.
		 */
		else
		if( rc==-36L )
			return( FALSE );
	}
	
	if( (dev->buf=(BYTE *) malloc( MAX_BLOCK * sizeof( BYTE ) ))==NULL )
	{
		CloseDevice( port );
		return( FALSE );
	}
	
	dev->is_open = TRUE;
	
	SetDevFunctions( dev );
	SetPortProtokoll( dev );
	
	if( !CreateSpeedlist( dev ) )
		CloseDevice( port );
	else
		StartReceiver( port );
	
	return( dev->is_open );
}

/*-------------------------------------------------------------------*/ 

GLOBAL VOID CloseDevice( DEV_LIST *port )
{
	/*
	 * Schliežt port und gibt den Speicher wieder frei
	 */
	DEVICES	*dev;
	
	dev = (DEVICES *) port;

	if( !dev->is_open )
		return;
	
	if( dev->dhandle>=0 )
	{
		Fclose( dev->dhandle );
		dev->dhandle = -1;
	}
	
	if( dev->buf )
	{
		free( dev->buf );
		dev->buf = NULL;
	}
	
	if( dev->oldIBufPtr )
	{
		IOREC	*iorec;
		BYTE	*b;
		
		iorec = dev->func_map->iorec;
		b     = iorec->ibuf;
		
		SetIorec( iorec, dev->oldIBufPtr, dev->oldIBufSize );
		
		(MiNT) ? Mfree( b ) : free( b );
		dev->oldIBufPtr  = NULL;
	}
	
	if( dev->oldOBufPtr )
	{
		IOREC	*iorec;
		BYTE	*b;
		
		iorec = dev->func_map->iorec;
		++iorec;
		b = iorec->ibuf;
		
		SetIorec( iorec, dev->oldOBufPtr, dev->oldOBufSize );
		
		(MiNT) ? Mfree( b ) : free( b );
		dev->oldOBufPtr  = NULL;
	}
	
	FreeSpeedlist( dev );
	
	dev->is_open = FALSE;
	
	return;
}

/*-------------------------------------------------------------------*/ 

GLOBAL WORD GetBiosNr( DEV_LIST *dev )
{
	return( ((DEVICES *) dev)->bios );
}

/*-------------------------------------------------------------------*/ 

GLOBAL LONG *GetSpeedList( DEV_LIST *dev )
{
	return( ((DEVICES *) dev)->speeds );
}

/*-------------------------------------------------------------------*/ 

GLOBAL LONG SetDTESpeed( DEV_LIST *port, LONG speed )
{
	DEVICES	*dev;
	
	dev  = (DEVICES *) port;
	
	/*
	 * Erst den Standard-Aux umsetzen:
	 */
	if( has_bconmap && dev->bios>5 )
		Bconmap( dev->bios );
	
	if( dev->dhandle>=0 )
	{
		cntrls[0] = speed;
		
		if( !Fcntl( dev->dhandle, cntrls, TIOCIBAUD ) )
			dev->device.curr_dte = speed;
	}
	else
	if( dev->bios==3 )
	{
		return( dev->device.curr_dte );
	}
	else
	if( fser )
	{
		WORD		i=0;
		BAUD_INFO	*help;
		
		help = (fser->baud_table_flag) ? dev->chan_info->alt_baud_table : dev->chan_info->baud_table;

		while( help->baudrate )
		{
			if( help->baudrate==speed )
				break;
			i++, help++;
		}
		
		if( help->baudrate>0 )
		{
			Rsconf( i, -1, -1, -1, -1, -1 );
			dev->device.curr_dte = speed;
		}
	}
	else
	{
		WORD	i=0;
		LONG	*help=dev->speeds;
		
		while( *help>0 )
		{
			if( *help==speed )
				break;
			i++, help++;
		}
		
		if( *help>0 )
		{
			Rsconf( i, -1, -1, -1, -1, -1 );
			dev->device.curr_dte = speed;
		}
	}
	
	return( dev->device.curr_dte );
}

/*-------------------------------------------------------------------*/ 

GLOBAL VOID StartReceiver( DEV_LIST *port )
{
	DEVICES	*dev;
	
	dev  = (DEVICES *) port;
	
	if( dev->dhandle>=0 )
		Fcntl( dev->dhandle, NULL, TIOCSTART );
}

/*-------------------------------------------------------------------*/ 

GLOBAL VOID StopReceiver( DEV_LIST *port )
{
	DEVICES	*dev;
	
	dev  = (DEVICES *) port;
	
	if( dev->dhandle>=0 )
		Fcntl( dev->dhandle, NULL, TIOCSTOP );
}

/*-------------------------------------------------------------------*/ 

GLOBAL WORD SetTxBuffer( DEV_LIST *port, WORD size )
{
	DEVICES	*dev;
	IOREC	*iorec;
	BYTE	*mem, *b=NULL;
	
	dev  = (DEVICES *) port;
	
	if( dev->dhandle>=0 )
	{
		cntrls[0] = cntrls[1] = cntrls[2] = -1L;
		cntrls[3] = (LONG) size;
		
		if( !Fcntl( dev->dhandle, cntrls, TIOCBUFFER ) )
			return( (WORD) cntrls[3] );
	}
	
	if( (mem=(BYTE *) (MiNT ? Mxalloc( size, 0x23 ) : malloc( size )))==NULL )
		return( -1 );
	
	iorec = dev->func_map->iorec;
	++iorec;
	
	if( !dev->oldOBufPtr )
	{
		dev->oldOBufSize = iorec->ibufsiz;
		dev->oldOBufPtr  = iorec->ibuf;
	}
	else
		b = iorec->ibuf;
	
	SetIorec( iorec, mem, size );
	
	if( b )
	{
		(MiNT) ? Mfree( b ) : free( b );
	}
	
	return( size );
}

/*-------------------------------------------------------------------*/ 

GLOBAL WORD GetTxBuffer( DEV_LIST *port )
{
	DEVICES	*dev;
	
	dev  = (DEVICES *) port;
	
	if( dev->dhandle>=0 )
	{
		cntrls[0] = cntrls[1] = cntrls[2] = cntrls[3] = -1L;
		
		if( !Fcntl( dev->dhandle, cntrls, TIOCBUFFER ) )
			return( (WORD) cntrls[3] );
	}

	return( -1 );
}

/*-------------------------------------------------------------------*/ 

GLOBAL WORD SetRxBuffer( DEV_LIST *port, WORD size )
{
	DEVICES	*dev;
	IOREC	*iorec;
	BYTE	*mem, *b=NULL;
	
	dev  = (DEVICES *) port;
	
	if( dev->dhandle>=0 )
	{
		cntrls[0] = (LONG) size;
		cntrls[1] = (LONG) (size >> 2);
		cntrls[2] = (LONG) ((size + size + size) >> 2);
		cntrls[3] = -1L;
		
		if( !Fcntl( dev->dhandle, cntrls, TIOCBUFFER ) )
			return( (WORD) cntrls[0] );
	}
	
	if( (mem=(BYTE *) (MiNT ? Mxalloc( size, 0x23 ) : malloc( size )))==NULL )
		return( -1 );
	
	iorec = dev->func_map->iorec;
	
	if( !dev->oldIBufPtr )
	{
		dev->oldIBufSize = iorec->ibufsiz;
		dev->oldIBufPtr  = iorec->ibuf;
	}
	else
		b = iorec->ibuf;
	
	SetIorec( iorec, mem, size );
	
	if( b )
	{
		(MiNT) ? Mfree( b ) : free( b );
	}
	
	return( size );
}

/*-------------------------------------------------------------------*/ 

GLOBAL WORD GetRxBuffer( DEV_LIST *port )
{
	DEVICES	*dev;
	
	dev  = (DEVICES *) port;
	
	if( dev->dhandle>=0 )
	{
		cntrls[0] = cntrls[1] = cntrls[2] = cntrls[3] = -1L;
		
		if( !Fcntl( dev->dhandle, cntrls, TIOCBUFFER ) )
			return( (WORD) cntrls[0] );
	}

	return( -1 );
}

/*-------------------------------------------------------------------*/ 

GLOBAL BOOLEAN PortSendByte( DEV_LIST *port, BYTE c )
{
	DEVICES	*dev;
	
	dev = (DEVICES *) port;
	
	if( dev->dhandle>=0 )
		return( DeviceSendBlock( dev, &c, 1L, FALSE ) );
	else
	if( dev->bios>=0 )
	{
		while( !Bcostat( dev->bios==3 ? 4 : dev->bios ) )
		{
			if( pause_1 )
				pause_1( );
		}
		
		Bconout( dev->bios, c );
		
		return( TRUE );
	}
	
	return( FALSE );
}

/*-------------------------------------------------------------------*/ 

GLOBAL BOOLEAN PortSendBlock( DEV_LIST *port, BYTE *block, LONG len, BOOLEAN tst_dcd )
{
	DEVICES	*dev;
	
	dev = (DEVICES *) port;
	
	if( dev->dhandle>=0 )
		return( DeviceSendBlock( dev, block, len, tst_dcd ) );
	else
	if( dev->bios==3 )
	{
		Midiws( (WORD) len-1, block );
		return( TRUE );
	}
	else
	if( dev->bios>=0 )
		return( SendBlock( dev, block, len, tst_dcd ) );
	
	return( FALSE );
}

/*-------------------------------------------------------------------*/ 

GLOBAL WORD PortGetByte( DEV_LIST *port )
{
	DEVICES	*dev;
	
	dev = (DEVICES *) port;
	
	if( dev->dhandle>=0 || dev->bios>=0 )
	{
		
		while( !CharAvailable( port ) )
		{
			if( !IsCarrier( port ) )
				return( -1 );
			
			if( pause_1 )
				pause_1( );
		}
		
		return( dev->buf[dev->curr_pos++] );
	}
	
	return( -1 );
}

/*-------------------------------------------------------------------*/ 

GLOBAL WORD PortPeekByte( DEV_LIST *port )
{
	DEVICES	*dev;
	
	dev = (DEVICES *) port;
	
	if( dev->dhandle>=0 || dev->bios>=0 )
	{
		if( CharAvailable( port ) )
			return( dev->buf[dev->curr_pos] & 0xff );
	}
	
	return( -1 );
}

/*-------------------------------------------------------------------*/ 

GLOBAL BOOLEAN OutIsEmpty( DEV_LIST *port )
{
	DEVICES	*dev;
	IOREC	*iorec;
	
	dev = (DEVICES *) port;
	
	if( dev->dhandle>=0 )
	{
		if( !Fcntl( dev->dhandle, cntrls, TIONOTSEND ) )
			return( cntrls[0]==0L );
	}
	
	iorec = dev->func_map->iorec;
	iorec++;
	
	return( iorec->ibufhd==iorec->ibuftl );
}

/*-------------------------------------------------------------------*/ 

GLOBAL BOOLEAN WaitOutEmpty( DEV_LIST *port, BOOLEAN tst_dcd, UWORD wait )
{
	ULONG	time_to_wait;
	
	if( wait )
		time_to_wait = Calc200Hz( (ULONG) wait );
		
	while( !OutIsEmpty( port ) )
	{
		if( (tst_dcd && !IsCarrier( port ))		||
			(wait    && time_to_wait<Get200Hz( )) )
		{
			ClearIOBuffer( port, IO_O_BUFFER );
			return( FALSE );
		}
		
		if( pause_1 )
			pause_1( );
	}
	
	return( TRUE );
}

/*-------------------------------------------------------------------*/ 

GLOBAL BOOLEAN CharAvailable( DEV_LIST *port )
{
	DEVICES	*dev;
	
	dev = (DEVICES *) port;
	
	if( dev->dhandle>=0 || dev->bios>=0 )
		return( dev->num_read>dev->curr_pos || DevicePickup( dev ) );
	
	return( FALSE );
}

/*-------------------------------------------------------------------*/ 

GLOBAL VOID ClearIOBuffer( DEV_LIST *port, LONG io )
{
	DEVICES	*dev;
	IOREC	*iorec;
	
	dev = (DEVICES *) port;
	
	if( dev->dhandle>=0 )
	{
		if( !Fcntl( dev->dhandle, io, TIOCFLUSH ) )
		{
			if( io!=IO_O_BUFFER )
			{
				dev->curr_pos = 0;
				dev->num_read = -1;
				StartReceiver( port );
			}
			return;
		}
	}
	
	iorec = dev->func_map->iorec;
	
	if( io!=IO_O_BUFFER )
	{
		/* Inbuffer l”schen: */
		iorec->ibuftl = iorec->ibufhd;
		dev->curr_pos = 0;
		dev->num_read = -1;
		StartReceiver( port );
	}

	if( io!=IO_I_BUFFER )
	{
		/* Outbuffer l”schen: */
		iorec++;
		iorec->ibufhd = iorec->ibuftl;
	}
}

/*-------------------------------------------------------------------*/ 

GLOBAL VOID DtrOn( DEV_LIST *port )
{
	DEVICES	*dev;
	
	dev = (DEVICES *) port;
	
	if( dev->dhandle>=0 && dev->ioctrlmap[0] & TIOCM_DTR )
	{
		cntrls[0] = cntrls[1] = TIOCM_DTR;
		
		Fcntl( dev->dhandle, cntrls, TIOCCTLSET );
	}
	else
	if( dev->func_num )
		high_dtr( dev->func_num-1, dev->func_map );
}

/*-------------------------------------------------------------------*/ 

GLOBAL VOID DtrOff( DEV_LIST *port )
{
	DEVICES	*dev;
	
	dev = (DEVICES *) port;
	
	if( dev->dhandle>=0 && dev->ioctrlmap[0] & TIOCM_DTR )
	{
		cntrls[0] = TIOCM_DTR;
		cntrls[1] = 0;
		
		Fcntl( dev->dhandle, cntrls, TIOCCTLSET );
	}
	else
	if( dev->func_num )
		low_dtr( dev->func_num-1, dev->func_map );
}

/*-------------------------------------------------------------------*/ 

GLOBAL BOOLEAN IsCarrier( DEV_LIST *port )
{
	DEVICES	*dev;
	
	dev = (DEVICES *) port;
	
	if( dev->dhandle>=0 &&
		dev->ioctrlmap[0] & TIOCM_CAR )
	{
		cntrls[0] = TIOCM_CAR;
		
		Fcntl( dev->dhandle, cntrls, TIOCCTLGET );
		
		return( (UWORD) cntrls[0] & TIOCM_CAR );
	}
	else
	if( dev->func_num )
		return( is_dcd( dev->func_num-1 ) );
	
	return( TRUE );
}

/*-------------------------------------------------------------------*/ 

GLOBAL VOID PortParameter( DEV_LIST *port, UWORD flowctl, UWORD charlen, UWORD stopbits, UWORD parity )
{
	DEVICES	*dev;
	
	dev = (DEVICES *) port;
	
	if( dev->dhandle>=0 )
	{
		UWORD	flags;
		
		if( !Fcntl( dev->dhandle, &flags, TIOCGFLAGS ) )
		{
			flags &= ~(TF_STOPBITS|TF_CHARBITS|TF_FLAG);
			flags |= (flowctl|charlen|stopbits|parity);
		
			if( !Fcntl( dev->dhandle, &flags, TIOCSFLAGS ) )
				return;
		}
	}
	
	if( dev->bios==1 || dev->bios>5 )
	{
		LONG	flags;
		UCR		ucr;
		
		if( has_bconmap && dev->bios>5 )
			Bconmap( dev->bios );
	
		flags = Rsconf( -1, -1, -1, -1, -1, -1 );
		
		ucr.word = *((BYTE *) &flags);
		ucr.word &= 0x0081;
		
		if( parity )
		{
			ucr.bits.bit2 = 1;
			if( parity==_EVENP )
				ucr.bits.bit1 = 1;
		}
		
		ucr.bits.bit3_4 = stopbits;
		ucr.bits.bit5_6 = charlen>>2;
		
		Rsconf( -1, flowctl, ucr.word, -1, -1, -1 );
	}
}

/*-----------------------------*/
/*--- local functions       ---*/
/*-----------------------------*/

/*-------------------------------------------------------------------*/ 

LOCAL BOOLEAN InitStdDevices( MAPTAB *maps, BOOLEAN has_bconmap, WORD num_devices )
{
	DEVICES	*dptr, *dwalk=NULL;
	WORD	loop, i;

	if( !has_bconmap || !num_devices )
		num_devices = 1;
	
	loop = (num_devices>4) ? 4 : num_devices;
	
	for( i=1; i<=loop; i++ )
	{
		if( (dptr=(DEVICES *) calloc( 1, sizeof( DEVICES ) ))==NULL )
			return( FALSE );
		
		if( dwalk )
			dwalk->device.next = (DEV_LIST *) dptr;
		else
			devices = dptr;
		
		dwalk = dptr;

		switch( i )
		{
			case 1:
					if( atari!=3 || num_devices!=1 )
					{
						dwalk->bios        = (has_bconmap) ? 6 : 1;
						dwalk->func_num    = 6 - BMAPSTART;
						dwalk->device.name = d_name[0];
						if( has_drv_u )
							dwalk->dopen   = d_open[0];
						break;
					}
			case 2:
					dwalk->bios        = 7;
					dwalk->func_num    = 7 - BMAPSTART;
					dwalk->device.name = d_name[1];
					if( has_drv_u )
						dwalk->dopen   = d_open[1];
					break;
			case 3:
					dwalk->bios = 8;
					if( atari==1 )
					{
						dwalk->func_num    = 9 - BMAPSTART;
						dwalk->device.name = d_name[3];
						if( has_drv_u )
							dwalk->dopen   = d_open[3];
					}
					else
					{
						dwalk->func_num    = 8 - BMAPSTART;
						dwalk->device.name = d_name[2];
						if( has_drv_u )
							dwalk->dopen   = d_open[2];
					}
					break;
			case 4:
					dwalk->bios        = 9;
					dwalk->func_num    = 9 - BMAPSTART;
					dwalk->device.name = d_name[3];
					if( has_drv_u )
						dwalk->dopen   = d_open[3];
					break;
		}

		dwalk->dhandle = -1;
		dwalk->num_read = -1;
		
			 if( fser ) dwalk->type = DEV_FSER;
		else if( MagX )	dwalk->type = DEV_MAGIC;
		else if( MiNT )	dwalk->type = DEV_MINT;
		else			dwalk->type = DEV_STANDARD;
		
		if( has_bconmap )
			dwalk->func_map = &maps[dwalk->bios-6];
		else
		if( i==1 )
			SetMapM1( &dwalk->func_map );
	}
	
	if( (dptr=(DEVICES *) calloc( 1, sizeof( DEVICES ) ))==NULL )
		return( FALSE );
		
	dwalk->device.next = (DEV_LIST *) dptr;
	
	dptr->bios        = 3;
	dptr->device.name = d_name[4];
	dptr->dhandle     = -1;
	dptr->num_read    = -1;
	dptr->type        = MagX ? DEV_MAGIC : DEV_STANDARD;
	
	SetMapMidi( &dptr->func_map );
	
	return( TRUE );
}

/*-------------------------------------------------------------------*/ 

LOCAL BOOLEAN InitRSVFDevices( MAPTAB *maps, RSVF_DEV *dev )
{
	DEVICES		*dwalk;
	
	while( dev->ptr )
	{
		if( !(dev->typ.device) )
		{
			dev = dev->ptr;
			continue;
		}
		
		dwalk = devices;
		
		while( dwalk )
		{
			if( (dwalk->bios==dev->bios_nr && strcmp( dev->ptr, "LAN" )) ||
				(!strcmp( dev->ptr, "MIDI" ) && dwalk->bios==3) )
			{
				if( dwalk->bios==3 )
					dwalk->bios = (dev->typ.bios) ? dev->bios_nr : 3;
				break;
			}
			
			dwalk = (DEVICES *) dwalk->device.next;
		}
		
		if( !dwalk )
		{
			DEVICES *dptr;
			
			if( (dptr=(DEVICES *) calloc( 1, sizeof( DEVICES ) ))==NULL )
				return( FALSE );
			
			dwalk = devices;
			while( dwalk->device.next )
				dwalk = (DEVICES *) dwalk->device.next;
			
			dwalk->device.next = (DEV_LIST *) dptr;
			dwalk              = dptr;
			
			dwalk->device.name = (BYTE *) dev->ptr;
			dwalk->bios        = (dev->typ.bios) ? dev->bios_nr : -1;
			
			dwalk->dhandle = -1;
			dwalk->num_read = -1;
			
			dwalk->func_map = (dwalk->bios>5) ? &maps[dwalk->bios-6] : NULL;
		}
		
		dwalk->dopen = (BYTE *) dev->ptr;
		dwalk->type  = DEV_RSVF;
		
		dev++;
	}
	
	return( TRUE );
}

/*-------------------------------------------------------------------*/ 

LOCAL BOOLEAN CreateSpeedlist( DEVICES *dev )
{
	if( (dev->speeds=(LONG *) calloc( MAX_SPEEDS, sizeof( LONG * ) ))==NULL )
		return( FALSE );
	
	if( dev->dhandle>=0 && GetFcntlSpeeds( dev ) )
		return( TRUE );
	else
	if( dev->bios==3 )		/* Midi */
	{
		LONG	*a_ptr, *b_ptr;
		
		a_ptr = midi_speeds;
		b_ptr = dev->speeds;
		
		while( *a_ptr>0 )
			*b_ptr++ = *a_ptr++;
		
		*b_ptr = *a_ptr;
		
		dev->device.curr_dte = 31250;
	}
	else
	if( fser )
		GetFserSpeeds( dev );
	else
	{
		WORD	i;
		LONG	*a_ptr, *b_ptr;
		
		if( tos<=0x104 )
			i = *((WORD *)((BYTE *) dev->func_map->iorec + 34));
		else
			i = (WORD) Rsconf( -2, -1, -1, -1, -1, -1 );

		a_ptr = speeds;
		
		while( i )
		{
			i--;
			a_ptr++;
		}
		dev->device.curr_dte = *a_ptr;
		
		a_ptr = speeds;
		b_ptr = dev->speeds;

		while( *a_ptr>0 )
			*b_ptr++ = *a_ptr++;
		
		*b_ptr = *a_ptr;
	}
	
	return( TRUE );	
}

/*-------------------------------------------------------------------*/ 

LOCAL BOOLEAN GetFcntlSpeeds( DEVICES *dev )
{
	LONG	*dte_ptr;
	LONG	last_dte, dte;
	
	/*
	 * Aktuelle DTE-Speed retten:
	 */
	dev->device.curr_dte = -1;
	if( Fcntl( dev->dhandle, &dev->device.curr_dte, TIOCIBAUD )<0 )
		return( FALSE );
	
	/*
	 * Von hohen zu niedrigen Baudraten wandern, solange es
	 * noch weitere gibt:
	 */
	dte_ptr  = dev->speeds;
	last_dte = dte = 0x7fffffffL;
	
	while( TRUE )
	{
		Fcntl( dev->dhandle, &dte, TIOCIBAUD );

		if( dte>=last_dte )
		{
			*dte_ptr = -1;
			break;
		}
		else
			last_dte = *dte_ptr++ = dte;
		
		dte--;
	}
	
	/*
	 * DTE-Speed wiederherstellen:
	 */	
	Fcntl( dev->dhandle, &dev->device.curr_dte, TIOCIBAUD );
	
	return( TRUE );
}

/*-------------------------------------------------------------------*/ 

LOCAL VOID GetFserSpeeds( DEVICES *dev )
{
	BAUD_INFO	*walk, *table;
	WORD		i, nums;
	LONG		*lptr;
		
	table = (fser->baud_table_flag) ? dev->chan_info->alt_baud_table : dev->chan_info->baud_table;
	nums  = 0;

	i    = (WORD) Rsconf( -2, -1, -1, -1, -1, -1 );
	walk = table;	
	
	while( i )
	{
		walk++;
		i--;
	}
	dev->device.curr_dte = walk->baudrate;
	
	walk = table;
	
	while( walk->baudrate )
	{
		if( walk->baudrate>0 )
		{
			lptr = dev->speeds;
		
			for( i=0; i<nums; i++ )
			{
				if( walk->baudrate>=*lptr )
					break;
				lptr++;
			}
			
			if( i<nums && !(walk->baudrate==*lptr) )
				memcpy( lptr+1, lptr, (nums-i) * sizeof( LONG ) );
			else
			if( i!=nums )
			{
				walk++;
				continue;
			}
				
			*lptr = walk->baudrate;
			nums++;
		}
		walk++;
	}
	
	dev->speeds[nums] = -1;
	
	return;
}

/*-------------------------------------------------------------------*/ 

LOCAL VOID FreeSpeedlist( DEVICES *dev )
{
	if( dev->speeds )
	{
		free( dev->speeds );
		dev->speeds = NULL;
	}
}

/*-------------------------------------------------------------------*/ 

LOCAL VOID SetDevFunctions( DEVICES *dev )
{
	if( dev->dhandle>=0 )
		Fcntl( dev->dhandle, dev->ioctrlmap, TIOCCTLMAP );
}

/*-------------------------------------------------------------------*/ 

LOCAL VOID SetPortProtokoll( DEVICES *dev )
{
	UWORD	flow=_RTSCTS;
	
	if( dev->dhandle>=0 && !strcmp( dev->dopen, "MIDI" ) )
		flow = _XONXOFF;
	
	PortParameter( (DEV_LIST *) dev, flow, _8BIT, _1STOP, _NO_PARITY );
	
	/*
	 * Unter MiNT muž noch der Terminal-Typ "raw" eingestellt
	 * werden (grrrrr!):
	 */
	if( dev->dhandle>=0 && !rsvf && MiNT )
	{
		SGTTYB tty;
		
		if( !Fcntl( dev->dhandle, &tty, TIOCGETP ) )
		{
			tty.sg_flags = T_RAW;
			Fcntl( dev->dhandle, &tty, TIOCSETP );
			Fcntl( dev->dhandle, &tty, TIOCGETP );
		}
	}
}

/*-------------------------------------------------------------------*/ 

LOCAL BOOLEAN DevicePickup( DEVICES *dev )
{
	LONG	count;

	dev->curr_pos = 0;
	dev->num_read = -1;
	
	if( dev->dhandle>=0 )
	{
		if( (count=Fread( dev->dhandle, MAX_BLOCK, dev->buf ))<=0 )
			return( FALSE );
	}
	else
	{
		if( (count=GetBlock( dev, MAX_BLOCK, dev->buf ))<=0 )
			return( FALSE );
	}
		
	dev->num_read = (WORD) count;
	
	return( TRUE );
}

/*-------------------------------------------------------------------*/ 

LOCAL BOOLEAN DeviceSendBlock( DEVICES *dev, BYTE *block, LONG len, BOOLEAN tst_dcd )
{
	LONG	sent=0L, help;
	LONG	timeout=0;
	
	while( sent<len )
	{
		if( tst_dcd && !IsCarrier( (DEV_LIST *) dev ) )
			return( FALSE );

		if( (help=Fwrite( dev->dhandle, len-sent, block+sent ))<0L )
			return( FALSE );
		
		sent += help;
		
		if( sent<len )
		{
			if( !timeout )
				timeout = Calc200Hz( 500L );
			else
			if( timeout<Get200Hz( ) )
				break;
			
			if( pause_1 )
				pause_1( );
		}
	}
	
	return( TRUE );
}
