/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 1/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	Erweiterte form_do()- und form_alert()-		*/
/*							Funktion als Accessory						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	XDI_AL.C									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	21.11.91 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <string.h>
#include <ctype.h>
#include <stdlib.h>

#include "tosglob.h"
#include "tosacc.h"


/* Fr die Alertbox */

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
	
#define		MAX_STRLEN	31
#define		MAX_BUTLEN	10
#define		AL_BUFLEN	1024

static	char	alBuf[AL_BUFLEN];
static	AL_INF	alInf = { AL_BUFLEN, 0, 0, (ALERTS *) alBuf };

static	int		btList[] = { BUTTON1, BUTTON2, BUTTON3 };
static	int		stList[] = { STRING1, STRING2, STRING3, STRING4, STRING5 };
static	int		icList[] = { ICEXCLAM, ICQUEST, ICSTOP };


/*	Neue GEM-Trap-Funktion im Assembler-Modul */

volatile	extern	int		NewGEM( int, long );
volatile	extern	int		_NewGEM( int, long );


/*	Globals fr Assembler-Modul */

volatile			int		(*OldGEM)( int, long );
					int		xdSwitch = 1;
					int		xaSwitch = 1;


/*	Locale Variablen */

static	int		Save( TOOL *tl, FILE *fp );
static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top );

static	void	*scBuffer;
static	long	scBufLen;

static	int		ours;
static	TOOL	ourTool =	{	NULL, NULL, 0, 0, 0, 0,
								-1,
								Save,
								NULL,
								HdlEvent,
							};

/*
*	DoLoop()
*
*	verwaltet alle Benutzereingaben
*
*	Rckgabe ist das selektierte Objekt
*/


static	int		DoLoop( WINDIA *wd, int window )
{
			int		event;
	static	EVENT	ev = {	MU_KEYBD | MU_BUTTON | MU_TIMER,
							2, 0x1, 1,
							0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
							50, 0,
							{ 0 },
							0, 0, 0, 0, 0, 0, 0 };
			int		obj = 0;

	do
	{
		event = EventMulti( &ev );

		if ( event & MU_BUTTON )
			obj = DialButton( wd, ev.ev_mmox, ev.ev_mmoy, ev.ev_mbreturn, window );
		if ( event & MU_KEYBD )
			obj = DialKeybd( wd, ev.ev_mkreturn, ev.ev_mmokstate, window );

		if ( event & MU_TIMER && !( event & MU_BUTTON ) && !obj )
		{
			graf_mkstate( &ev.ev_mmox, &ev.ev_mmoy, &ev.ev_mmobutton, &ev.ev_mmokstate );
			if ( ev.ev_mmobutton == 2 )
				obj = DialKeybd( wd, RETURN, 0, window );
		}

	} while ( !obj );
	return ( obj );
}


/*
*	FormDo()
*
*	wird ersetzt durch die standard GEM-form_do() Funktion
*/

int		FormDo( OBJECT *tree, int startob )
{
	int		ret;
	WINDIA	wd;

	wind_update( BEG_UPDATE );		/* Unsere FormDo() bernimmt */
	wind_update( BEG_MCTRL );		/* die Kontrolle */

	InitEdObj( &wd, tree, startob );
	if ( wd.edobj >= 0 )
		RedrawWinObj( &wd, -1, -1 );

	ret = DoLoop( &wd, -1 );

	if ( wd.edobj >= 0 )
		RedrawWinObj( &wd, -1, -1 );

	wind_update( END_MCTRL );
	wind_update( END_UPDATE );

	return ( ret );
}

/*
*	ObjcEdit()
*
*	wird ersetzt durch die standard GEM-Funktion objc_edit()
*/

int ObjcEdit( OBJECT *tree, int edobj, int key, int *pos, int type )
{
	static	WINDIA	wd;

	switch ( type )
	{
		case ED_START	:	break;
		case ED_INIT	:	InitEdObj( &wd, tree, edobj );
							*pos = wd.pos;
							RedrawWinObj( &wd, -1, -1 );
							break;
		case ED_CHAR	:	if ( *pos != wd.pos || wd.tree != tree )
								return ( 0 );
							ObjcInsChar( &wd, key, -1 );
							*pos = wd.pos;
							break;
		case ED_END		:	if ( *pos != wd.pos || wd.tree != tree )
								return ( 0 );
							RedrawWinObj( &wd, -1, -1 );
							break;
		default			:	return ( 0 );
	}
	return ( 1 );
}

/*
*/

static	int	CheckList( const char *fmt_txt, int dflt )
{
	ALERTS	*al = alInf.alerts;
	int		num = alInf.num;
	
	while ( num-- )
	{
		if ( dflt == al->old && !strcmp( fmt_txt, al->fmt ) )
			return ( al->new );
		(char *) al += sizeof (ALERTS) + ( (int)strlen(al->fmt) & 0xfffe);
	}
	return ( 0 );
}

static int AddToList( const char *fmt, int dflt_old, int dflt_new )
{
	ALERTS		*al;
	
	if ( alInf.pos + strlen( fmt ) + sizeof (ALERTS) >= alInf.buf_len )
		return ( -1 );
	alInf.num++;
	al = (ALERTS *) &(((char *) alInf.alerts)[alInf.pos]);
	al->old = dflt_old;
	al->new = dflt_new;
	strcpy( al->fmt, fmt );
	alInf.pos += (int) sizeof (ALERTS) + ( (int) strlen( fmt ) & 0xfffe );
	return ( 0 );
}	

/*
*	SwitchDefault()
*
*	setzt den Default-Button in der AlertBox()
*/

static	void	SwitchDefault( OBJECT *tree, int num )
{
	if ( --num >= 0 && num < 3 )
		tree[btList[num]].ob_flags ^= DEFAULT;
}

/*
*	SwitchIcon()
*
*	setzt das ausgew„hlte Icon in der Alertbox
*	(Fragezeichen, Stopschild, ...)
*/

static	void	SwitchIcon( OBJECT *tree, int num )
{
	if ( --num >= 0 && num < 3 )
		tree[icList[num]].ob_flags ^= HIDETREE;
}

/*
*	StrLen()
*
*	berechnet die L„nge eines Eintrages im Formattext der Alertbox
*/

static	int		StrLen( const char *ptr )
{
	int		l = 0;
	char	c;

	while ( ( c = *ptr++ ) != 0 )
	{
		if ( c == '|' || c == ']' )
			return ( l );
		l++;
	}
	return ( l );
}

/*
*	NextType()
*
*	Geht zum n„chsten Eintrag im Formattext der Alertbox
*	(getrennt durch '|')
*/

static	char	*NextType( const char *ptr )
{
	char	c;

	while ( ( c = *ptr++ ) != 0 )
		if ( c == '[' || ( c == ' ' && ptr[-2] == ']' ) )
			return ( (char *) ptr );

	return ( NULL );
}

/*
*	NextString()
*
*	Geht zum n„chsten Eintrag im Formattext der Alertbox
*	(getrennt durch '[' oder ']')
*/

static	char	*NextString( const char *ptr )
{
	char	c;

	while ( ( c = *ptr++ ) != 0 )
	{
		if ( c == '|' )
			return ( (char *) ptr );
		if ( c == ']' )
			return ( NULL );
	}
	return ( NULL );
}

/*
*	_FormAlert()
*
*	Low level Alert, wird von Alert() und DelAlerts() benutzt
*/

int		_FormAlert( int deflt, const char *fmt )
{
	OBJECT		*tree = TrPtr(ALERT);
	OBJECT		*ob;
	int			icon;
	int			ret;
	char		*ptr;
	int			lineCnt = 0;
	int			buttonCnt = 0;
	int			l;
	GRECT		gr;

	if ( ( fmt = NextType( fmt ) ) == NULL	)
		return ( 0 );

	if ( !isdigit( *fmt ) )
		return ( 0 );

	icon = *fmt - '0';

	if ( ( fmt = NextType( fmt ) ) == NULL )
		return ( 0 );

	do
	{
		ptr = (char *) fmt;
		if ( ( l = StrLen( fmt ) ) > MAX_STRLEN )
			return ( 0 );
		ob = &tree[stList[lineCnt++]];
		strncpy( ObString( ob ), fmt, l );
		ObString(ob)[l] = '\0';
		UnHide(ob);
		ob->ob_width = l * _Cw;
	} while ( ( fmt = NextString( fmt ) ) != NULL );

	if ( ( fmt = NextType( ptr ) ) == NULL )
		return ( 0 );

	do
	{
		ptr = (char *) fmt;

		if ( ( l = StrLen( fmt ) ) > MAX_BUTLEN )
			return ( 0 );
		ob = &tree[btList[buttonCnt++]];
		strncpy( ObString( ob ), fmt, l );
		ObString(ob)[l] = '\0';
		UnHide(ob);
	} while ( ( fmt = NextString( fmt ) ) != NULL );

	for ( l = lineCnt; l < 5; l++ )
		Hide( &tree[stList[l]] );
	for ( l = buttonCnt; l < 3; l++ )
		Hide( &tree[btList[l]] );

	SwitchDefault( tree, deflt );
	SwitchIcon( tree, icon );

	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);

	SetClip( NULL, 1 );
	FormCenter( tree );

	if ( tree->ob_state & OUTLINED )
		SaveScreen( ObGRECT(tree), 3, &scBuffer, &scBufLen );
	else
		SaveScreen( ObGRECT(tree), 0, &scBuffer, &scBufLen );

	gr = *ObGRECT(tree);
	gr.g_x -= 3;
	gr.g_y -= 3;
	gr.g_w += 6;
	gr.g_h += 6;
	ObjcDraw( tree, 0, 8, &gr );

	MouseOn();
	ret = FormDo( tree, 0 ) & 0x7fff;
	MouseOff();
	Deselect(tree+ret);

	RedrawScreen( scBuffer );

	wind_update(END_MCTRL);
	wind_update(END_UPDATE);

	SwitchDefault( tree, deflt );
	SwitchIcon( tree, icon );

	for ( l = 0; l < 3; l++ )
		if ( btList[l] == ret )
			return ( l + 1 );

	return ( 0 );
}


/*
*	FormAlert()
*
*	wird ersetzt duch die standard GEM-Funktion form_alert()
*/

int		FormAlert( int deflt, const char *fmt )
{
	OBJECT		*tree = TrPtr(ALERT);
	int			ret;
	const char	*sav = fmt;

	ret = CheckList( fmt, deflt );
	if ( ret != 0 )
	{
		if ( ( deflt = ret ) < 0 )
			return ( -ret );
		Disable( tree + NXTAUTO );
		Disable( tree + NXTDFLT );
	}
	
	ret = _FormAlert( deflt, fmt );
	
	if ( IsSelected( tree + NXTAUTO ) )
	{
		Deselect( tree + NXTAUTO );
		Deselect( tree + NXTDFLT );
		AddToList( sav, deflt, -ret );
	}
	if ( IsSelected( tree + NXTDFLT ) )
	{
		Deselect( tree + NXTDFLT );
		AddToList( sav, deflt, ret );
	}
		
	Enable( tree + NXTAUTO );
	Enable( tree + NXTDFLT );

	return ( ret );
}

static	void	DelAlerts( void )
{
	OBJECT	*tree = TrPtr(ALERT);
	char	*sav = tree[NXTAUTO].ob_spec.tedinfo->te_ptext;
	int		i;
	ALERTS	*al = alInf.alerts;
	int		ret;
	char	*ptr;
		
	tree[NXTAUTO].ob_spec.tedinfo->te_ptext = "Delete";
	Hide( tree + NXTDFLT );

	evnt_timer( 0, 0 );
	for ( i = 0; i < alInf.num; i++ )
	{
		ret = _FormAlert( al->old, al->fmt );
		if ( IsSelected( tree + NXTAUTO ) )
		{
			Deselect( tree + NXTAUTO );
			alInf.num--;
			ret = (int)( sizeof (ALERTS) + ((int)strlen(al->fmt) & 0xfffe));
			ptr = (char *) al + ret;
			memmove( al, ptr, alInf.buf_len - alInf.pos );
			alInf.pos -= ret;
		}
		else
			al = (ALERTS *) ( (char *) al + 
				 sizeof (ALERTS) + ((int) strlen(al->fmt) & 0xfffe ) );
	}
	tree[NXTAUTO].ob_spec.tedinfo->te_ptext = sav;
	UnHide( tree + NXTDFLT );
}

/*
*	Install1()
*
*	setzt neuen GEM-Trap, der sich nach dem ersten Aufruf wieder
*	ausklingt (Merkt sich den _GemParBlk dieses Accessories)
*/

static	long	Install1( void )
{
	OldGEM = *SysGEM;

	*SysGEM = _NewGEM;

	return ( 0L );
}

/*
*	Install2()
*
*	ersetzt den Original GEM-Trap
*/

static	long	Install2( void )
{
	*SysGEM = NewGEM;

	return ( 0L );
}

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
		if ( fwrite( &xdSwitch, sizeof (int), 1L, fp ) == 1L &&
			 fwrite( &xaSwitch, sizeof (int), 1L, fp ) == 1L &&
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
	int		obj = 0;

	if ( evtype & MU_BUTTON )
		obj = DialButton( &tl->wd, ev->ev_mmox, ev->ev_mmoy, ev->ev_mbreturn, winHdl );
	else if ( evtype & MU_KEYBD )
		obj = DialKeybd( &tl->wd, ev->ev_mkreturn, ev->ev_mmokstate, winHdl );

	switch ( obj & 0x7fff )
	{
		case	XDON:		xdSwitch = 1;	break;
		case	XDOFF:		xdSwitch = 0;	break;
		case	ALON:		xaSwitch = 1;	break;
		case	ALOFF:		xaSwitch = 0;	break;
		case	ALERTDEL:	DelAlerts();
							Deselect( ObPtr(XDIAL,ALERTDEL) );
							RedrawWinObj( &tl->wd, ALERTDEL, winHdl );
							break;
		default:			break;
	}
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
	long	len;
	
	ours = handle;

	if ( fp )
	{
		if ( fread( &xdSwitch, sizeof (int), 1L, fp ) == 1L &&
			 fread( &xaSwitch, sizeof (int), 1L, fp ) == 1L &&
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
				form_alert( 1, "[1][TOSACC erh„lt nicht gengend|"
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

	wind_get( 0, WF_SCREEN, (int *) &scBuffer, ((int *) &scBuffer) + 1,
							(int *) &scBufLen, ((int *) &scBufLen) + 1 );

	len = (long) ( ( TrPtr(ALERT)->ob_width + 6 + 15 ) >> 8 ) *
		  (long) ( TrPtr(ALERT)->ob_height + 6 ) * (long) _Planes;
		  
	if ( !scBuffer || scBufLen < len )
	{
		scBufLen = len;
		scBuffer = malloc( scBufLen );

		if ( !scBuffer )
		{
			xaSwitch = 0;
			Disable( ObPtr(XDIAL,ALON) );
			form_alert( 1, "[1][Zu wenig Speicher|fr erweiterte Alertbox."
						   "][OK]" );
		}
	}
	if ( ( MaxX + 1 ) / _Cw < 80 || ( MaxY + 1 ) / _Ch < 25 )
		TrPtr(ALERT)->ob_state &= ~OUTLINED;

	if ( xaSwitch )
		Select(ObPtr(XDIAL,ALON));
	else
		Select(ObPtr(XDIAL,ALOFF));

	if ( xdSwitch )
		Select(ObPtr(XDIAL,XDON));
	else
		Select(ObPtr(XDIAL,XDOFF));

	Supexec( Install1 );

	evnt_timer( 0, 0 );		/* irgend eine AES Funktion */

	Supexec( Install2 );

	return ( &ourTool );
}
