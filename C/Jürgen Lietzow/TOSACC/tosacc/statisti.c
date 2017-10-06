/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/91  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	STATISTI.C									*/
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

#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <ext.h>

#include "tosglob.h"
#include "tosacc.h"

static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );
static	int		Mode( TOOL *tool, int type );


static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0, 1, -1,
								-1,
								NULL,
								Mode,
								HdlEvent,
								NULL
							};



/*
*	HdlEvent()
*
*	wird von TOSACC.C aufgerufen
*/

#pragma warn -par

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top )
{
	return ( 0 );
}


/*
*	Mode()
*
*	Wird von TOSACC.C aufgerufen. Bei jedem Timer-Ereignis, bei
*	AC_CLOSE, und bei einem Toolwechsel.
*/

static	int		Mode( TOOL *tl, int type )
{
	OBJECT	*tr = TrPtr(STATIST);
	char	t[10];


	if ( type & MODE_TOPEN || 
	 ( type & MODE_TIMER && type & MODE_TACTIV  && mainWD.window >= 0 ) )
	{
		ltoa( sys->ciLogrd, t, 10 );
		t[8] = 0;
		sprintf( ObTxt(tr+CILOGRD), "%7s", t );

		ltoa( sys->ciLogwrt, t, 10 );
		t[8] = 0;
		sprintf( ObTxt(tr+CILOGWRT), "%7s", t );

		ltoa( sys->ciPhrd, t, 10 );
		t[8] = 0;
		sprintf( ObTxt(tr+CIPHRD), "%7s", t );

		ltoa( sys->ciPhwrt, t, 10 );
		t[8] = 0;
		sprintf( ObTxt(tr+CIPHWRT), "%7s", t );

		ltoa( (1000L * sys->ciPhrd ) / (sys->ciLogrd + 1L), t, 10 );
		t[5] = 0;
		sprintf( ObTxt(tr+CIRATRD), "%5s", t );

		ltoa( (1000L * sys->ciPhwrt ) / (sys->ciLogwrt + 1L), t, 10 );
		t[5] = 0;
		sprintf( ObTxt(tr+CIRATWRT), "%5s", t );

		ltoa( sys->ciFixederr, t, 10 );
		t[8] = 0;
		sprintf( ObTxt(tr+CICHKERR), "%7s", t );

		ltoa( sys->ciFatalerr, t, 10 );
		t[8] = 0;
		sprintf( ObTxt(tr+CIFATERR), "%7s", t );
		
		itoa( sys->spBlkNum, t, 10 );
		t[8] = 0;
		sprintf( ObTxt(tr+SPBLK), "%7s", t );
			
		itoa( sys->blkFreeNum, t, 10 );
		t[8] = 0;
		sprintf( ObTxt(tr+FREEBLK), "%7s", t );

		itoa( sys->ciBlkNum, t, 10 );
		t[8] = 0;
		sprintf( ObTxt(tr+CIBLK), "%7s", t );

		itoa( sys->rdBlkNum, t, 10 );
		t[8] = 0;
		sprintf( ObTxt(tr+RDBLK), "%7s", t );

		ltoa( sys->spTChars, t, 10 );
		t[8] = 0;
		sprintf( ObTxt(tr+SENDCHAR), "%7s", t );
	}	

	if ( type & MODE_TIMER && type & MODE_TACTIV  && mainWD.window >= 0 )
	{
		RedrawWinObj( &tl->wd, CIPHRD, NULL );
		RedrawWinObj( &tl->wd, CILOGRD, NULL );
		RedrawWinObj( &tl->wd, CIPHWRT, NULL );
		RedrawWinObj( &tl->wd, CILOGWRT, NULL );
		RedrawWinObj( &tl->wd, CIRATRD, NULL );
		RedrawWinObj( &tl->wd, CIRATWRT, NULL );
		RedrawWinObj( &tl->wd, CICHKERR, NULL );
		RedrawWinObj( &tl->wd, CIFATERR, NULL );
		RedrawWinObj( &tl->wd, SPBLK, NULL );
		RedrawWinObj( &tl->wd, RDBLK, NULL );
		RedrawWinObj( &tl->wd, CIBLK, NULL );
		RedrawWinObj( &tl->wd, FREEBLK, NULL );
		RedrawWinObj( &tl->wd, SENDCHAR, NULL );
	}
	return ( 0 );
}

/*
*	SkInit()
*
*	wird bei Programmstart von TOSACC.C aufgerufen
*/

TOOL	*SkInit( FILE *fp, int handle )
{

	ours = handle;

	InitEdObj( &ourTool.wd, TrPtr(STATIST), -1 );
	return ( &ourTool );
}

#pragma warn .par
