/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 11/91  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	Erweiterte form_do()-Funktion als Accessory	*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	XDI_AL.C									*/
/*																		*/
/*																		*/
/*		Author			:	JÅrgen Lietzow fÅr TOS-Magazin				*/
/*																		*/
/*		Last Update		:	28.08.91 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <string.h>
#include <ctype.h>
#include <stdlib.h>

#include "tosglob.h"

#include "tosacc.h"


/* FÅr die Alertbox */

#define		MAX_STRLEN	30
#define		MAX_BUTLEN	10

static	int		btList[] = { BUTTON1, BUTTON2, BUTTON3 };
static	int		stList[] = { STRING1, STRING2, STRING3, STRING4, STRING5 };
static	int		icList[] = { ICEXCLAM, ICQUEST, ICSTOP };


/*	Grîûe des History-Buffers */

#define	MAX_TLEN	80
#define MAX_HIST	20


#define	INT_MIN		-32767
#define	INT_MAX		32767


typedef struct
{
		char	valid[MAX_TLEN];
		char	text[MAX_TLEN];
}	HIST;


/*	Neue GEM-Trap-Funktion im Assembler-Modul */

extern	int		NewGEM( int, long );
extern	int		_NewGEM( int, long );


/*	Globals fÅr Assembler-Modul */

		int		(*OldGEM)( int, long );
		int		xdSwitch = 1;
		int		xaSwitch = 1;


/*	Locale Variablen */


	/*	History-Buffer mit Scheib- und Leseposition */
	
static	HIST	hist[MAX_HIST];
static	int		readPos;
static	int		writePos;


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
*	Hilfsfunktionen fÅr die neue FormDo()-Funktion
*/

/*
*	ScanTree()
*
*	wird solange ausgefÅhrt bis fct() != 0
*
*	RÅckgabewert :	fct()
*/

int		ScanTree( OBJECT *tree, int obj, TPBLK *tp, sub_fct *fct )
{
	int		next;
	int		ret;
	
	tp->x += tree[obj].ob_x;
	tp->y += tree[obj].ob_y;
	
	ret = fct( tree, obj, tp );
	
	if ( ret )
		return ( ret );
		
	if ( ( next = tree[obj].ob_head ) != -1 )
		do
			if ( !IsHidden(tree+next) )
			{
				ret = ScanTree( tree, next, tp, fct );
				if ( ret )
					return ( ret );
			}
		while ( ( next = tree[next].ob_next ) != obj );

	tp->x -= tree[obj].ob_x;
	tp->y -= tree[obj].ob_y;

	return ( ret );
}


/*
*	SaveScreen()
*/

int		SaveScreen( OBJECT *tr, int obj, int frame, void **buffer, long *len )
{
	MFDB		scrn;
	MFDB		*sav;
	int			*pxy;
	long		l;
	int			off,
				x, y,
				rw = tr[obj].ob_height,
				co = tr[obj].ob_width;

	objc_offset( tr, obj, &x, &y );

	x -= frame;		y -= frame;
	
	frame <<= 1;
	
	rw += frame;	co += frame;
	
	/* auf Wort-Grenze */

	off = x % 16;
	if ( off )	
	{
		co += off;
		x -= off;
	}
	off = co % 16;
	if ( off )
		co += 16 - off;

	l = (long) ( co >> 3 ) * (long) rw * (long) _Planes;
	l += 8L * sizeof(int) + sizeof (MFDB);
	
	if ( !*buffer )
	{
		*len = l;
		*buffer = malloc( l + 8L * sizeof (int) );
		if ( !*buffer )
			return ( 1 );
	}
	else
		if ( *len < l )
			return ( 1 );
	
	sav = *buffer;
	pxy = (int *) &sav[1];

	sav->fd_addr = &pxy[8];
	sav->fd_wdwidth = ( co >> 4 ) * _Planes;
	sav->fd_w = --co;
	sav->fd_h = --rw;
	sav->fd_stand = 0;
	sav->fd_nplanes = _Planes;

	pxy[0] = x;
	pxy[1] = y;
	pxy[2] = x + co;
	pxy[3] = y + rw;
	pxy[4] = 0;
	pxy[5] = 0;
	pxy[6] = co;
	pxy[7] = rw;
	
	scrn.fd_addr = NULL;	
	MouseOff();
	vro_cpyfm( vdiHdl, S_ONLY, pxy, &scrn, sav );
	MouseOn();
	return ( 0 );
}

void	RedrawScreen( void *buffer )
{
	MFDB	scrn;
	MFDB	*sav = buffer;
	int		*pxy = (int *) &sav[1];
	long	temp;
	
	temp = *(long *) &pxy[0];
	*(long *) &pxy[0] = *(long *) &pxy[4];
	*(long *) &pxy[4] = temp;
	
	temp = *(long *) &pxy[2];
	*(long *) &pxy[2] = *(long *) &pxy[6];
	*(long *) &pxy[6] = temp;

	scrn.fd_addr = NULL;	
	MouseOff();
	vro_cpyfm( vdiHdl, S_ONLY, pxy, sav, &scrn );
	MouseOn();
}

static	int		_IsInParent( OBJECT *tree, int obj, TPBLK *tp )
{
	if ( obj == tp->cmp )
		return ( 1 );
	else
		return ( 0 );
}

int		IsInParent( OBJECT *tree, int parent, int obj )
{
	TPBLK	tp;
	
	tp.cmp = obj;
	
	return ( ScanTree( tree, parent, &tp, _IsInParent ) );
}

static	int _NextEditable( OBJECT *tree, int obj, TPBLK *tp )
{
	if ( IsEditable(tree+obj) && tp->cmp < obj && tp->obj > obj )
		tp->obj = obj;
	return ( 0 );
}

/*
*	NextEditable()
*
*	liefert das nÑchste editierbare Objekt >= obj
*/

int		NextEditable( OBJECT *tree, int obj )
{
	TPBLK	tp;
	
	tp.cmp = obj;
	tp.obj = INT_MAX;
	
	ScanTree( tree, 0, &tp, _NextEditable );
	
	if ( tp.obj == INT_MAX )
		return ( obj );
	else
		return ( tp.obj );
}

static	int	_LastEditable( OBJECT *tree, int obj, TPBLK *tp )
{
	if ( IsEditable(tree+obj) && tp->cmp > obj && tp->obj < obj )
		tp->obj = obj;
	return ( 0 );
}

/*
*	LastEditable()
*
*	liefert das vorherige editierbare Objekt <= obj
*/

int		LastEditable( OBJECT *tree, int obj )
{
	TPBLK	tp;
	
	tp.cmp = obj;
	tp.obj = INT_MIN;
	
	ScanTree( tree, 0, &tp, _LastEditable );
	
	if ( tp.obj == INT_MIN )
		return ( obj );
	else
		return ( tp.obj );
}


/*
*	IsFirstUpper()
*
*	1 : erster Groûbuchstabe == key
*	0 : erster Groûbuchstabe != key
*/

static	int		IsFirstUpper( const char *str, int key )
{
	int		c;
	
	while ( ( c = *str++ ) != '\0' )
		if ( isupper( c ) )
			if ( c == key )
				return ( 1 );
			else
				return ( 0 );
	return ( 0 );
}


/* Warnung: 'Parameter XXXX never used' ausschalten */

#pragma warn -par

static	int	_RightString( OBJECT *tree, int obj, TPBLK *tp )
{
	if ( Abs( tp->y - tp->ty ) <= 4 && tp->x > tp->tx )
		if ( tp->cmp == -1 || tp->x < tp->tx )
			tp->cmp = obj;
	return ( 0 );
}

/* Warnung: 'Parameter XXXX never used' zurÅcksetzen */

#pragma warn .par

/*
*	RightString()
*
*	sucht rechts neben einem Objekt ein Objekt des Typs 'G_STRING'
*/

int		RightString( OBJECT *tree, int obj )
{
	TPBLK	tp;
	
	tp.cmp = -1;
	tp.x = tp.y = 0;
	objc_offset( tree, obj, &tp.tx, &tp.ty );

	ScanTree( tree, 0, &tp, _RightString );
	
	if ( tp.cmp != -1 &&
		 ( tree[tp.cmp].ob_type & 0xff ) == G_STRING )
		return ( tp.cmp );
	else
		return ( -1 );
}

static	int	_GetButton( OBJECT *tree, int obj, TPBLK *tp )
{
	int temp;
	
	if ( IsSelectable(tree+obj) )
	{
		switch ( tree[obj].ob_type & 0xff )
		{
			case G_BUTTON :
			case G_STRING :

				if ( IsFirstUpper( ObString(tree+obj), tp->cmp ) )
					if ( tp->obj < 0 )
						tp->obj = obj;
					else
						return ( -1 );
				break;
			case G_BOXCHAR	:
				if ( toupper( tree[obj].ob_spec.obspec.character ) ==
					 tp->cmp )
				{
					if ( tp->obj < 0 )
						tp->obj = obj;
					else
						return ( -1 );
				}
			case G_BOX		:
			case G_IBOX		:
			case G_USERDEF	:
			
				temp = RightString( tree, obj );
				if ( temp >= 0 &&
					 IsFirstUpper( ObString(tree+temp), tp->cmp ) )
					if ( tp->obj < 0 )
						tp->obj = obj;
					else
						return ( -1 );
				break;
			default		  :	break;
		}
	}
	return ( 0 );
}

/*
*	GetButton()
*
*	ermittelt ein selektierbares Objekt, dessen erster Groûbuchstabe
*	'key' entspricht
*	PrÅft auf Eindeutigkeit: Existieren mehrere Objekte, wird -1
*	                         zurÅckgegeben
*	-1 falls nicht gefunden
*/

static	int		GetButton( OBJECT *tree, int key )
{
	TPBLK	tp;
	
	tp.obj = -1;
	tp.cmp = key;
	
	if ( ScanTree( tree, 0, &tp, _GetButton ) )
		return ( -1 );
	else
		return ( tp.obj );
}

/*
*	KeyToUpper()
*
*	liefert anhand des Scancodes den Ascii-Wert als Groûbuchstabe
*/

int		KeyToUpper( int key )
{
	static	char	*shift = NULL;

#define		NIX		((void *) -1L)

	if ( !shift )
		shift = Keytbl( NIX, NIX, NIX )->shift;

	return ( (int) shift[((unsigned int) key) >> 8] );
}


void	CursorChg( WINDIA *wd )
{
	int		pxy[4];
	int		pos, i;
	char	*tmplt;

	if ( wd->edobj <= 0 )
		return;
		
	if ( wd->ted->te_txtlen <= 1 )
		return;

	tmplt = wd->ted->te_ptmplt;
	
	for ( i = -1, pos = wd->pos + 1; pos; i++ )
		if ( *tmplt++ == '_' )
			pos--;
	
	pxy[0] = wd->x + (i << 3);
	pxy[1] = wd->y;
	pxy[2] = pxy[0] + 7;
	pxy[3] = pxy[1] + _Ch - 1;
		
	vswr_mode( vdiHdl, 3 );
	vsf_interior( vdiHdl, 1 );

	MouseOff();
	vr_recfl( vdiHdl, pxy );
	MouseOn();
}

void	InitCurPos( WINDIA *wd )
{
	OBJECT	*tr = wd->tree;
	TEDINFO	*ted = wd->ted;
	int		obj = wd->edobj;

	if ( obj <= 0 )
		return;
			
	objc_offset( tr, obj, &wd->x, &wd->y );
	tr += obj;
	wd->y += ( tr->ob_height - _Ch ) >> 1;
	if ( ted->te_just )
	{
		obj = tr->ob_width - ( ( ted->te_tmplen - 1 ) << 3 );
		if ( ted->te_just == 2 )
			obj >>= 1;
		wd->x += obj;
	}	
}
	
void	InitEdObj( WINDIA *wd, OBJECT *tree, int obj )
{
	TEDINFO	*ted;
	
	wd->tree = tree;
	wd->edobj = obj;
	
	if ( obj < 0 || !IsEditable(tree + obj) )
	{
		wd->edobj = obj = NextEditable( tree, -1 );
		if ( obj < 0 )
			return;
	}
	tree += obj;
	ted = tree->ob_spec.tedinfo;
	wd->ted = ted;
	InitCurPos( wd );
	if ( ted->te_ptext[0] == '@' )
		ted->te_ptext[0] = '\0';
	obj = (int) strlen( ted->te_ptext );
	if ( obj >= ted->te_txtlen - 1 )
		obj--;
	wd->pos = obj;
}
	
/*
*	ChangeEdField()
*
*	wechselt ein editierbares Objekt (curEdObj), lîscht und setzt
*	den Cursor und initialisiert die Cursorposition (edPos)
*/

void	ChangeEdField( WINDIA *wd, int new, int window )
{ 
	if ( wd->edobj >= 0 )
		RedrawWinObj( wd, -1, window );

	InitEdObj( wd, wd->tree, new );
	RedrawWinObj( wd, -1, window );
}

int		GetValid( int key, char *valid, int pos )
{
	if ( !*valid )
		return ( 0 );
		
	while ( pos-- )
	{
		valid++;
		if ( !*valid )
		{
			valid--;
			break;
		}
	}
	
	switch ( *valid )
	{
		case '9':	if ( isdigit( key ) )
						return ( key );
					break;
		case 'A':	if ( isalpha( key ) || key == ' ' )
						return ( toupper( key ) );
					break;
		case 'a':	if ( isalpha( key ) || key == ' ' )
						return ( key );
					break;
		case 'N':	if ( isalnum(key) || key == ' ' )
						return ( toupper(key) );
					break;
		case 'n':	if ( isalnum(key) || key == ' ' )
						return ( key );
					break;
		case 'F':	if ( isalnum(key) || key == '*' || key == '?' ||
						 key == '_' || key == '$'  )
						return ( toupper(key) );
					break;
		case 'P':	if ( isalnum(key) || key == '*' || key == '?' ||
						 key == '_' || key == '$' || key == '\\' ||
						 key == ':' )
						return ( toupper(key) );
					break;
		case 'p':	if ( isalnum(key) || key == '_' || key == '$' ||
						 key == '\\' || key == ':' )
						return ( toupper(key) );
					break;
		case 'X':	return ( key );
		
		default :	break;
	}
	return ( 0 );
}

int		ObjcInsChar( WINDIA *wd, int key, int window )
{
	OBJECT		*ob = wd->tree + wd->edobj;
	TEDINFO		*ted;
	char		*txt;
	char		*tmplt;
	int			i = wd->pos;
	int			v;
	int			obj;
	
	ted = ob->ob_spec.tedinfo;
	txt = ted->te_ptext;
	
	if ( ted->te_txtlen <= 1 )
		return ( key );
		
	switch ( key )
	{
		case ESC:		*txt = '\0';
						RedrawWinObj( wd, -1, window );
						wd->pos = 0;
						break;
		case BACKSPACE:	if ( i )
						{
							i--;
							RedrawWinObj( wd, -1, window );
							wd->pos = i;
							goto Delete;
						}
						else
							return ( 0 );
		case DELETE:	RedrawWinObj( wd, -1, window );
	Delete:
						txt += i;
						tmplt = txt + 1;
						if ( *txt )
							while ( *txt++ = *tmplt++ );
						break;
		case C_LEFT:	if ( i )
						{
							RedrawWinObj( wd, -1, window );
							wd->pos--;
							RedrawWinObj( wd, -1, window );
						}
						return ( 0 );
		case C_RIGHT:	if ( txt[i] && i < ted->te_txtlen - 2 )
						{
							RedrawWinObj( wd, -1, window );
							wd->pos++;
							RedrawWinObj( wd, -1, window );
						}
						return ( 0 );
		case SHFT_CL:	RedrawWinObj( wd, -1, window );
						wd->pos = 0;
						RedrawWinObj( wd, -1, window );
						return ( 0 );
		case SHFT_CR:	RedrawWinObj( wd, -1, window );
						while ( txt[i] )
							i++;
						if ( i >= ted->te_txtlen - 1 )
							i--;
						wd->pos = i;
						RedrawWinObj( wd, -1, window );
						return ( 0 );
		default		:	RedrawWinObj( wd, -1, window );
						obj = GetValid( key & 0xff, ted->te_pvalid, i );
						if ( obj )
						{
							while ( txt[i++] );
							if ( i > ted->te_txtlen - 2 )
								i = ted->te_txtlen - 2;
							while ( i != wd->pos )
							{
								txt[i] = txt[i-1];
								i--;
							}
							txt[i] = obj;
							if ( i < ted->te_txtlen - 2 )
								wd->pos++;
							break;
						}
						else
						{
							if ( i >= ted->te_txtlen - 2 )
							{
								RedrawWinObj( wd, wd->edobj, window );
								return ( key );
							}
							obj = key & 0xff;
							tmplt = ted->te_ptmplt;
							txt += i;
							do
							{
								if ( *tmplt++ == '_' )
									if ( !i-- )
										break;
							} while ( *tmplt );
							if ( !*tmplt )
								break;
							i = 1;
							while ( *tmplt == '_' )
							{
								i++;
								tmplt++;
							}
							if ( !*tmplt || *tmplt != obj )
								break;
							wd->pos += i;
							txt[i] = '\0';
							while ( i-- )
								txt[i] = ' ';
						}
						break;
	}
	RedrawWinObj( wd, wd->edobj, window );
	return ( 0 );
}

/*
*	Hilfsfunktionen fÅr History
*/

/*
*	AddToHist()
*
*	nimmt 'text' und 'valid' in History-Buffer auf, wenn noch
*	nicht enthalten
*/

static	void	AddToHist( char *text, char *valid )
{
	int		i;
	
	if ( (int) strlen( text ) >= MAX_TLEN ||
		 (int) strlen( valid ) >= MAX_TLEN )
		return;
	for ( i = 0; i < MAX_HIST; i++ )
		if ( !strcmp( text, hist[i].text ) &&
			 !strcmp( valid, hist[i].valid ) )
			return;
	strcpy( hist[writePos].text, text );
	strcpy( hist[writePos].valid, valid );

	if ( ++writePos >= MAX_HIST )
		writePos = 0;
	readPos = writePos;
}

/*
*	AddAllToHist()
*
*	nimmt alle 'te_ptext' und 'te_pvalid' des Objektbaumes in 
*	History-Buffer auf
*/

static	void	AddAllToHist( OBJECT *tree )
{
	int		obj;
	int		next;
	TEDINFO	*ted;
	
	obj = NextEditable( tree, -1 );	/*	liefert das erste editierbare */
									/*	Objekt */
	
	if ( obj >= 0 )
	{
		do
		{
			ted = tree[obj].ob_spec.tedinfo;
			AddToHist( ted->te_ptext, ted->te_pvalid );
			next = obj;
			obj = NextEditable( tree, next );
		} while ( obj != next );
	}
}

/*
*	NextHist() und LastHist()
*
*	liefern einen Zeiger auf 'text' vom History-Buffer
*/

static	char	*NextHist( char *valid )
{
	int		i = readPos;
	
	do
	{
		if ( ++i >= MAX_HIST )
			i = 0;
		if ( !strcmp( valid, hist[i].valid ) )
		{
			readPos = i;
			return hist[i].text;
		}
	} while ( i != readPos );

	return ( NULL );
}

static	char	*LastHist( char *valid )
{
	int		i;
	int		end = readPos - 1;
	
	if ( end < 0 )
		end = MAX_HIST -1;
	i = end;
	do
	{
		if ( !strcmp( valid, hist[i].valid ) )
		{
			readPos = i;
			return hist[i].text;
		}
		if ( --i < 0 )
			i = MAX_HIST - 1;
	} while ( i != end );

	return ( NULL );
}

/*
*	GetHist()
*
*	schreibt im aktuellen editierbaren Objekt einen Text aus dem
*	History-Buffer
*/

static	void	GetHist( WINDIA *wd, char *(*fct)(char *), int window )
{
	OBJECT	*tree = wd->tree;
	char	*text;
	TEDINFO	*ted;
	int		obj = wd->edobj;
	int		temp;
		
	if ( obj >= 0 )
	{
		ted = tree[obj].ob_spec.tedinfo;
		temp = readPos;
		AddToHist( ted->te_ptext, ted->te_pvalid );
		readPos = temp;
		text = fct( ted->te_pvalid );
		if ( text )
		{
			RedrawWinObj( wd, -1, window );
			strcpy( ted->te_ptext, text );
			InitEdObj( wd, wd->tree, obj );
			RedrawWinObj( wd, obj, window );
		}
	}
}

int		DialButton( WINDIA *wd, int x, int y, int clicks, int window )
{
	int		obj = objc_find( wd->tree, 0, 8, x, y );
	
	if ( obj >= 0 )
	{
		if ( !form_button( wd->tree, obj, clicks, &obj ) )
		{
			if ( clicks == 2 )
				obj |= 0x8000;
			AddAllToHist( wd->tree );
			return ( obj );
		}
		else if ( wd->edobj > 0 && wd->edobj != obj &&
				  IsEditable(wd->tree+obj) )
			ChangeEdField( wd, obj, window );
	}
	else
		Bell();
	return ( 0 );
}

int		DialKeybd( WINDIA *wd, int key, int kstate, int window )
{
	OBJECT	*tree = wd->tree;
	int		obj;
	int		dummy;
	
	switch ( key )
	{
		case HOME	:
			ChangeEdField(wd, NextEditable(tree, -1), window);
			break;
		case SHFT_HOME:
			ChangeEdField(wd, LastEditable(tree, INT_MAX), window);
			break;
		case C_UP | '8':
			GetHist( wd, LastHist, window );
			break;
		case C_DOWN | '2':
			GetHist( wd, NextHist, window );
			break;
		default	:
			
		if ( !form_keybd( tree, wd->edobj, 
						  wd->edobj,
						  key, &obj, &key ) )
		{
			AddAllToHist( tree );
			return ( obj );
		}
		
		switch ( key & 0xff )
		{
		case '{':
		case '}':
		case '[':
		case ']':
		case '\\':
		case '@':
				ObjcInsChar( wd, key, window );
				break;
		default:
		
			if ( !(kstate & K_ALT) && wd->edobj > 0 )
			{
				if ( obj != wd->edobj )
					ChangeEdField(wd, obj, window);
				else if ( key )
					ObjcInsChar( wd, key, window );
			}
			else if ( key )
			{
				key = KeyToUpper( key );
				obj = GetButton( tree, key );
				if ( obj >= 0 )
					if ( !form_button( tree, obj, 1, &dummy ) )
					{
						AddAllToHist( tree );
						return ( obj );
					}
			}
		break;
		}
		break;
	} /* switch ( key ) */
	return ( 0 );
}	

	

/*
*	DoLoop()
*
*	verwaltet alle Benutzereingaben
*
*	RÅckgabe ist das selektierte Objekt
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
			obj = DialButton( wd, ev.mox, ev.moy, ev.mreturn, window );
		if ( event & MU_KEYBD )
			obj = DialKeybd( wd, ev.kreturn, ev.kstate, window );
		
		if ( event & MU_TIMER && !( event & MU_BUTTON ) && !obj )
		{
			graf_mkstate( &ev.mox, &ev.moy, &ev.mstate, &ev.kstate );
			if ( ev.mstate == 2 )
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
	
	wind_update( BEG_UPDATE );		/* Unsere FormDo() Åbernimmt */
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

/* FÅr die Alertbox */

static	void	SwitchDefault( OBJECT *tree, int num )
{
	if ( --num >= 0 && num < 3 )
		tree[btList[num]].ob_flags ^= DEFAULT;
}

static	void	SwitchIcon( OBJECT *tree, int num )
{
	if ( --num >= 0 && num < 3 )
		tree[icList[num]].ob_flags ^= HIDETREE;
}

static	int		StrLen( const char *ptr )
{
	int		l = 0;
	char	c;
	
	while ( c = *ptr++ )
	{
		if ( c == '|' || c == ']' )
			return ( l );
		l++;
	}
	return ( l );
}

static	char	*NextType( const char *ptr )
{
	char	c;
	
	while ( c = *ptr++ )
		if ( c == '[' )
			return ( ptr );

	return ( NULL );
}

static	char	*NextString( const char *ptr )
{
	char	c;
	
	while ( c = *ptr++ )
	{
		if ( c == '|' )
			return ( ptr );
		if ( c == ']' )
			return ( NULL );
	}
	return ( NULL );
}

int		FormAlert( int deflt, const char *fmt )
{
	OBJECT	*tree = TrPtr(ALERT);
	OBJECT	*ob;
	int		icon;
	int		ret;
	char	*ptr;
	int		lineCnt = 0;
	int		buttonCnt = 0;
	int		c;
	int		l;
	GRECT	gr;
	
	if ( !( fmt = NextType( fmt ) )	)
		return ( 0 );
	
	if ( !isdigit( *fmt ) )
		return ( 0 );
	
	icon = *fmt - '0';
	
	if ( !( fmt = NextType( fmt ) )	)
		return ( 0 );

	do
	{
		ptr = fmt;
		if ( ( l = StrLen( fmt ) ) > MAX_STRLEN )
			return ( 0 );
		ob = &tree[stList[lineCnt++]];
		strncpy( ObString( ob ), fmt, l );
		ObString(ob)[l] = '\0';
		UnHide(ob);
		ob->ob_width = l * _Cw;
	} while ( fmt = NextString( fmt ) );
	
	if ( !( fmt = NextType( ptr ) ) )
		return ( 0 );
	
	do
	{
		ptr = fmt;
		
		if ( ( l = StrLen( fmt ) ) > MAX_BUTLEN )
			return ( 0 );
		ob = &tree[btList[buttonCnt++]];
		strncpy( ObString( ob ), fmt, l );
		ObString(ob)[l] = '\0';
		UnHide(ob);
	} while ( fmt = NextString( fmt ) );

	for ( l = lineCnt; l < 5; l++ )
		Hide( &tree[stList[l]] );
	for ( l = buttonCnt; l < 3; l++ )
		Hide( &tree[btList[l]] );
	
	SwitchDefault( tree, deflt );
	SwitchIcon( tree, icon );

	wind_update(BEG_UPDATE);	
	wind_update(BEG_MCTRL);	

	FormCenter( tree );
	
	SaveScreen( tree, 0, 3, &scBuffer, &scBufLen );
	
	gr = *ObGRECT(tree);
	gr.g_x -= 3;
	gr.g_y -= 3;
	gr.g_w += 6;
	gr.g_h += 6;
	ObjcDraw( tree, 0, 8, &gr );

	ret = FormDo( tree, 0 ) & 0x7fff;
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


static	long	Install1( void )
{
	OldGEM = *SysGEM;
	
	*SysGEM = _NewGEM;
	
	return ( 0L );
}

static	long	Install2( void )
{
	*SysGEM = NewGEM;
	
	return ( 0L );
}

static	int		Save( TOOL *tl, FILE *fp )
{
	if ( fp )
	{
		if ( fwrite( &xdSwitch, sizeof (int), 1L, fp ) == 1L )
			if ( fwrite( &xaSwitch, sizeof (int), 1L, fp ) == 1L )
				return ( 0 );
		return ( 1 );
	}
	return ( 0 );
}

static	int		HdlEvent( TOOL *tl, int evtype, EVENT *ev, int top )
{
	int		obj = 0;

	if ( evtype & MU_BUTTON )
		obj = DialButton( &tl->wd, ev->mox, ev->moy, ev->mreturn, winHdl );
	else if ( evtype & MU_KEYBD )
		obj = DialKeybd( &tl->wd, ev->kreturn, ev->kstate, winHdl );

	switch ( obj & 0x7fff )
	{
		case	XDON:		xdSwitch = 1;	break;
		case	XDOFF:		xdSwitch = 0;	break;
		case	ALON:		xaSwitch = 1;	break;
		case	ALOFF:		xaSwitch = 0;	break;
		default:			break;
	}
	return ( 0 );
}

TOOL	*XdaInit( FILE *fp, int handle )
{
	ours = handle;
	
	if ( fp )
	{
		fread( &xdSwitch, sizeof (int), 1L, fp );
		fread( &xaSwitch, sizeof (int), 1L, fp );
	}

	InitEdObj( &ourTool.wd, TrPtr(XDIAL), -1 );

	wind_get( 0, WF_SCREEN, (int *) &scBuffer, ((int *) &scBuffer) + 1,
							(int *) &scBufLen, ((int *) &scBufLen) + 1 );
	

	if ( !scBuffer | !scBufLen )
	{
		scBufLen = ( (long) MaxX * (long) MaxY * (long) _Planes) >> 4;
		scBuffer = malloc( scBufLen );
		
		if ( !scBuffer )
		{
			xaSwitch = 0;
			Disable( ObPtr(XDIAL,ALON) );
			form_alert( 1, "[2][Zu wenig Speicher|fÅr erweiterte Alertbox"
						   "][ OK ]" );
		}
	}
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
