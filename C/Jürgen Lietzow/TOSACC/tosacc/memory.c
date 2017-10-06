/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	MEMORY.C									*/
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

#include "tosglob.h"
#include "tosacc.h"

extern	long	ColdBoot( void );
extern	void	SaveAll( void );

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );
static	int		HandleSlider( OBJECT *tree, SLIDERBLK *sl );


static	SLIDERBLK sizeSl = { NXTMEM, 240, HandleSlider, 80, 8, -1 };
static	SLIDERBLK blkSl = { NXTBLK, 5, HandleSlider, 0, 1, -1 };

static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0, 1, -1,
								-1,
								NULL,	/* Steht alles in taccInf */
								NULL,
								HdlEvent,
								NULL
							};


/*
*	HandleSlider()
*
*	wird von 'HdlSlider()' aufgerufen, wenn der Slider einen neuen
*	Wert eingenommen hat
*/

static	int		HandleSlider( OBJECT *tr, SLIDERBLK *sl )
{
	char	t[8];
	
	switch ( sl->slider )
	{
		case NXTMEM:	sys->tai.nxtKbSiz = SlAbsToRel( sl, sl->pos );
						SlDigit( tr, sl, sys->tai.nxtKbSiz );
						break;
		case NXTBLK:	sys->tai.nxtRecSiz = 1 << SlAbsToRel( sl, sl->pos );
						itoa( sys->tai.nxtRecSiz * 512, t, 10 );
						strcpy( ObTxt(tr+NXTBLK+SL_SLIDER), t );
						break;
		default		 :	break;
	}
	return ( 0 );
}

/*
*	HdlEvent()
*
*	wird von TOSACC.C aufgerufen
*/

#pragma warn -par

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top )
{
	int		obj = FormEvent( &tl->wd, ev );
	long	t;
	
	switch ( obj & 0x7FFF )
	{
		case MEMINST:	if ( form_alert( 1, "[2][Dazu wird ein Reset|"
										  "durchgefhrt !]"
										  "[OK|Abbruch]" ) == 1 &&
						form_alert( 1, "[2][Sind alle Dateien schon|"
										  "gesichert ?]"
										  "[Ja|Nein]" ) == 1 )
										  				  
						{
							SaveAll();
							t = sys->tsecCount + 2 * sys->tai.ciDelay;
							while ( sys->tsecCount < t );
							Supexec( ColdBoot );
						}
						Deselect(tl->wd.tree+obj);
						RedrawWinObj(&tl->wd,obj,NULL);
						break;		
		default:
				if ( ObjInSl(obj, NXTMEM) )
					HdlSlider( &tl->wd, &sizeSl, obj );
				else if ( ObjInSl(obj, NXTBLK) )
					HdlSlider( &tl->wd, &blkSl, obj );
				break;
	}
	return ( 0 );
}

/*
*	MmInit()
*
*	wird bei Programmstart von TOSACC.C aufgerufen
*/

TOOL	*MmInit( FILE *fp, int handle )
{
	OBJECT	*tr = TrPtr(MEMORY);
	
	ours = handle;

	if ( sys->ahdiFlag )
	{
		ObString(tr+AHDIFLAG)[0] = ' ';
		ObString(tr+AHDIFLAG)[1] = 'E';
	}
	
	itoa( sys->kbSiz, ObString(tr+CURMEM), 10 );
	itoa( sys->absRecSiz, ObString(tr+CURBLK), 10 );
	
	InitEdObj( &ourTool.wd, tr, -1 );
	
	SlInit( tr, &sizeSl, sys->tai.nxtKbSiz );
	SlDigit( tr, &sizeSl, sys->tai.nxtKbSiz );
	sys->tai.nxtRecSiz = 1;
	SlInit( tr, &blkSl, 0 );
	SlDigit( tr, &blkSl, 512 );

	return ( &ourTool );
}

#pragma warn .par
