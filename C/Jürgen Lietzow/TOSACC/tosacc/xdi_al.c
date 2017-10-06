/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	Erweiterte form_do()- und form_alert()-		*/
/*							Funktion als Accessory						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	XDI_AL.C									*/
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

#include <string.h>
#include <ctype.h>
#include <stdlib.h>

#include "tosglob.h"
#include "tosacc.h"
/*

/* FÅr die Alertbox */

typedef struct
{
		int		old;
		int		new;
		char	fmt[2];
}	ALERTS;

typedef struct
{
		int		buf_len;
		int		pos;
		int		num;
		ALERTS	*alerts;
}	AL_INF;
*/

#define		objcDraw		(_GEMSwitches[0])
#define		objcEdit		(_GEMSwitches[4])
#define		objcChange		(_GEMSwitches[5])
#define		formDo			(_GEMSwitches[8])
#define		formDial		(_GEMSwitches[9])
#define		formAlert		(_GEMSwitches[10])
#define		formCenter		(_GEMSwitches[12])
#define		formKeybd		(_GEMSwitches[13])
#define		formButton		(_GEMSwitches[14])


/*	Neue GEM-Trap-Funktion im Assembler-Modul */

volatile	extern	int		NewGEM( int, long );
volatile	extern	int		_NewGEM( int, long );
volatile	extern	int		(*_OldGEM)( int, long );


/*	Globals fÅr Assembler-Modul */

			extern	char	_GEMSwitches[16];
			extern	int		GEMSwitch;
			extern	int		dpSwitch;;


/*	Locale Variablen */

static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );
static	int		Exit( TOOL *tl );

static	int		instOK = 0;
static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0, 1, -1,
								-1,
								Save,
								NULL,
								HdlEvent,
								Exit
							};



/*
*	Save()
*
*	Sichert aktuelle Einstellung
*/

#pragma warn -par

static	int		Save( TOOL *tl, FILE *fp )
{
	if ( fp )
	{
		if ( fwrite( &_GEMSwitches, sizeof (_GEMSwitches), 1L, fp ) == 1L &&
			 fwrite( &dpSwitch, sizeof (dpSwitch), 1L, fp ) == 1L &&
			 fwrite( &alInf, sizeof (AL_INF), 1L, fp ) == 1L &&
			 fwrite( alInf.alerts, alInf.pos, 1L, fp ) == 1L )
			return ( 0 );
		return ( 1 );
	}
	return ( 0 );
}

/*
*	HdlEvent()
*
*	wird von TOSACC.C aufgerufen
*/

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top )
{
	switch ( FormEvent( &tl->wd, ev ) & 0x7fff )
	{
		case	ALDEFPOS:	if ( IsSelected(tl->wd.tree+ALDEFPOS) )
								dpSwitch = 1;
							else
								dpSwitch = 0;
							break;
		case	XDON:		formDo ^= 1;	break;
		case	ALON:		formAlert ^= 1;	break;
		case	XEDON:		objcEdit ^= 1;	break;
		case	XDRAWON:	objcDraw ^= 1;
							formButton = formKeybd = objcChange = objcDraw;		
							FormDial( FMD_FINISH, NULL, NULL );
							break;
		case	XSHGRON:	formDial ^= 1;	break;
		case	ALERTDEL:	DelAlerts();
							Deselect( ObPtr(XDIAL,ALERTDEL) );
							RedrawWinObj( &tl->wd, ALERTDEL, NULL );
							break;
		default:			break;
	}
	return ( 0 );
}


static	int	Exit( TOOL *tl )
{
	if ( instOK )
		if ( Setexc( 34, (sys_vec) -1L ) == (sys_vec) NewGEM )
			Setexc( 34, (sys_vec) _OldGEM );
		else
			return ( 1 );
	return ( 0 );
}
	
#pragma warn .par

/*
*	XdaInit()
*
*	wird bei Programmstart von TOSACC.C aufgerufen
*/

TOOL	*XdaInit( FILE *fp, int handle )
{
	ours = handle;

	if ( fp )
	{
		if ( fread( &_GEMSwitches, sizeof (_GEMSwitches), 1L, fp ) == 1L &&
			 fread( &dpSwitch, sizeof (dpSwitch), 1L, fp ) == 1L &&
			 fread( &alInf, sizeof (AL_INF), 1L, fp ) == 1L )
		{
			alInf.buf_len = alInf.pos + AL_BUFLEN;
			alInf.alerts = malloc( alInf.buf_len );
			if ( alInf.alerts )
			{
				if ( fread( alInf.alerts, alInf.pos, 1L, fp ) != 1L )
					goto InitAlInf;
			}
			else
			{
				form_alert( 1, "[1][TOSACC erhÑlt nicht genÅgend|"
							   "eigenen Speicher, um die|"
							   "Konfiguration zu laden.][OK]" );
InitAlInf:
				alInf.pos = 0;
				alInf.buf_len = AL_BUFLEN;
				alInf.num = 0;
				alInf.alerts = (ALERTS *) alBuf;
			}
		}
	}

	InitEdObj( &ourTool.wd, TrPtr(XDIAL), -1 );

	if ( ( MaxX + 1 ) / _Cw < 80 || ( MaxY + 1 ) / _Ch < 25 )
	{
		formAlert = 0;
		Disable( ObPtr(XDIAL,ALON) );
	}

	if ( formAlert )
		Select(ObPtr(XDIAL,ALON));

	if ( formDo )
		Select(ObPtr(XDIAL,XDON));

	if ( objcEdit )
		Select(ObPtr(XDIAL,XEDON));

	if ( objcDraw )
		Select(ObPtr(XDIAL,XDRAWON));
	
	formButton = formKeybd = objcChange = objcDraw;		

	if ( !formDial )
		Select(ObPtr(XDIAL,XSHGRON));

	if ( dpSwitch )
		Select(ObPtr(XDIAL,ALDEFPOS));

/*	setzt neuen GEM-Trap, der sich nach dem ersten Aufruf wieder */
/*	ausklingt (Merkt sich den _GemParBlk dieses Accessories) */

	(sys_vec) _OldGEM = Setexc( 34, (sys_vec) _NewGEM );

	evnt_timer( 0, 0 );		/* irgend eine AES Funktion */

/*	Installiert den neuen GEM-Dispatcher */
/*	_OldGEM ist immernoch gÅltig */

	Setexc( 34, (sys_vec) NewGEM );

	GEMSwitch = 0;
	instOK = 1;
	return ( &ourTool );
}
