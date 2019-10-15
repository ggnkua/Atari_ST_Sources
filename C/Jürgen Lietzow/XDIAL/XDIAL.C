/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 10/91  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	Erweiterte form_do()-Funktion als Accessory	*/
/*							XDIAL.ACC									*/
/*																		*/
/*		M O D U L E		:	XDIAL.C										*/
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
#include <stdio.h>

#if defined( __TURBOC__ )

	#include <vdi.h>
	#include <aes.h>
	#include <tos.h>

#else

	/* AES und VDI header */
	
	#error "Headerdateien von AES und VDI einbinden"
	
	#define Supexec(p)	xbios( 38, p )
	
#endif

/*	Grîûe des History-Buffers */

#define	MAX_TLEN	80
#define MAX_HIST	20


#define	INT_MIN		-32767
#define	INT_MAX		32767


/*	Scan- und Asciicode; zurÅckgegeben von evnt_multi() */

#define RETURN		0x1c0d
#define ENTER		0x720d
#define C_UP		0x4800
#define C_LEFT		0x4b00
#define C_RIGHT		0x4d00
#define C_DOWN		0x5000
#define SHFT_CL		0x4b34
#define SHFT_CR		0x4d36
#define SHFT_HOME	0x4737
#define HOME		0x4700


#define	Bell()		putchar( '\a' )


/*	Hilfreich im Umgang mit Objekten */

#define IsEditable(ob)	( ((ob)->ob_flags & EDITABLE) && \
						  ((((ob)->ob_type & 0xff) == G_FTEXT) || \
						  (((ob)->ob_type & 0xff) == G_FBOXTEXT)) )
#define IsHidden(ob)	((ob)->ob_flags & HIDETREE)
#define IsSelectable(ob)((ob)->ob_flags & SELECTABLE)

#define	ObString(ob)	((ob)->ob_spec.free_string)


#define	Abs(a)			((a) < 0 ? -(a) : (a))


typedef struct
{
		int		x, y;
		int		obj;
		int		cmp;
		int		tx, ty;
		long	temp;
}	TPBLK;

typedef struct
{
		char	valid[MAX_TLEN];
		char	text[MAX_TLEN];
}	HIST;

typedef	int (sub_fct)(OBJECT *tree, int obj, TPBLK *tb);


/*	Systemvariable fÅr Trap #2  (GEM-Trap) */

#define	SysGEM	((int (**)(int, long)) 0x88)


/*	Neue GEM-Trap-Funktion im Assembler-Modul */

extern	int		NewGEM( int, long );


/*	Globale Variablen; auch vom Assembler-Modul benutzt */

		int		(*OldGEM)( int, long );
		int		FormDo( OBJECT *tree, int startob );
		int		isOn = 1;


/*	Locale Variablen */


	/* Aktuelles Edit-Objekt und die Cursor-Position */
	
static	int		curEdObj;
static	int		edPos;


	/*	History-Buffer mit Scheib- und Leseposition */
	
static	HIST	hist[MAX_HIST];
static	int		readPos;
static	int		writePos;



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
*	ChangeEdField()
*
*	wechselt ein editierbares Objekt (curEdObj), lîscht und setzt
*	den Cursor und initialisiert die Cursorposition (edPos)
*/

static	void	ChangeEdField( OBJECT *tree, int new )
{ 
	if ( curEdObj >= 0 )
	{
		objc_edit( tree, curEdObj, 0, &edPos, ED_END );
		curEdObj = new;
		objc_edit( tree, curEdObj, 0, &edPos, ED_INIT );
	}
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

static	int		KeyToUpper( int key )
{
	static	char	*shift = NULL;

#define		NIX		((void *) -1L)

	if ( !shift )
		shift = Keytbl( NIX, NIX, NIX )->shift;

	return ( (int) shift[((unsigned int) key) >> 8] );
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
	
	obj = NextEditable( tree, 0 );	/*	liefert das erste editierbare */
									/*	Objekt */
	
	if ( obj > 0 )
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

static	void	GetHist( OBJECT *tree, char *(*fct)(char *) )
{
	char	*text;
	TEDINFO	*ted;
	int		obj = curEdObj;
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
			objc_edit( tree, obj, 0, &edPos, ED_END );
			strcpy( ted->te_ptext, text );
			objc_draw( tree, obj, 1, tree->ob_x, tree->ob_y,
					   tree->ob_width, tree->ob_height );
			objc_edit( tree, obj, 0, &edPos, ED_INIT );
		}
	}
}

/*
*	DoLoop()
*
*	verwaltet alle Benutzereingaben
*
*	RÅckgabe ist das selektierte Objekt
*/
		
static	int		DoLoop( OBJECT *tree )
{
	int		event;
	int		msg_buf[8];
	int		x, y, mstate, kstate, key, clicks;
	int		obj;
	int		dummy;
	
	while ( 1 )
	{
		event = evnt_multi( MU_KEYBD | MU_BUTTON,
							2, 0x1, 0x1,
							0, 0, 0, 0, 0,
							0, 0, 0, 0, 0,
							msg_buf,
							0, 0,
							&x, &y, &mstate, &kstate, &key, &clicks );

		if ( event & MU_KEYBD )
		{
			switch ( key )
			{
				case SHFT_CL:
					while ( edPos )
						objc_edit(tree, curEdObj, C_LEFT, &edPos, ED_CHAR);
					break;
				case SHFT_CR:
					ChangeEdField(tree, curEdObj);
					break;
				case HOME	:
					ChangeEdField(tree, NextEditable(tree, 0));
					break;
				case SHFT_HOME:
					ChangeEdField(tree, LastEditable(tree, INT_MAX));
					break;
				case C_UP | '8':
					GetHist( tree, LastHist );
					break;
				case C_DOWN | '2':
					GetHist( tree, NextHist );
					break;
				default	:
					
				if ( !form_keybd( tree, curEdObj, curEdObj,
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
						objc_edit( tree, curEdObj, key, &edPos, ED_CHAR );
						break;
					default:
						if ( !(kstate & K_ALT) && curEdObj >= 0 )
						{
							if ( obj != curEdObj )
								ChangeEdField(tree, obj);
							else if ( key )
								objc_edit( tree, curEdObj, key, &edPos,
											ED_CHAR );
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
				} /* switch ( key & 0xff ) */
				break;
			} /* switch ( key ) */
			
		} /* if MU_KEYBD */
		
		if ( event & MU_BUTTON )
		{
			obj = objc_find( tree, 0, 8, x, y );
			if ( obj >= 0 )
			{
				if ( !form_button( tree, obj, clicks, &obj ) )
				{
					if ( clicks == 2 )
						obj |= 0x8000;
					AddAllToHist( tree );
					return ( obj );
				}
				else if ( curEdObj >= 0 && curEdObj != obj &&
						  IsEditable(tree+obj) )
					ChangeEdField( tree, obj );
			}
			else
				Bell();
		}
	}
}
						
	
/*
*	FormDo()
*
*	wird ersetzt durch die standard GEM-form_do() Funktion
*/

int		FormDo( OBJECT *tree, int startob )
{
	int		ret;
	
	wind_update( BEG_UPDATE );		/* Unsere FormDo() Åbernimmt */
	wind_update( BEG_MCTRL );		/* die Kontrolle */
	
	/*	'curEdPos' soll das aktuelle editierbare Objekt enthalten */
	/*	Wenn keines vorhanden ist 'curEdPos' -1 */
	
	if ( startob >= 0 && IsEditable(tree+startob) )
		curEdObj = startob;
	else
	{
		curEdObj = NextEditable(tree,0);
		if ( !IsEditable(tree+curEdObj) )
			curEdObj = -1;
	}
	if ( curEdObj >= 0 )
	{
		/*	objc_edit(ED_START) hat bis zur aktuellen TOS-Version */
		/*	keine Funktion; objc_edit(ED_INIT) berechnet die Cursor- */
		/*	Position (edPos) und zeichnet den Cursor */

		if ( objc_edit( tree, curEdObj, 0, &edPos, ED_START ) &&
			 objc_edit( tree, curEdObj, 0, &edPos, ED_INIT ) )
			;
		else
			curEdObj = -1;
	}
	
	ret = DoLoop( tree );

	/*	objc_edit(ED_END) schaltet den Cursor aus */
		
	if ( curEdObj >= 0 )
		objc_edit( tree, curEdObj, 0, &edPos, ED_END );

	wind_update( END_MCTRL );
	wind_update( END_UPDATE );
	
	return ( ret );
}

/*
*	Installation und Benutzerdialog
*/		

/*
*	Install()
*
*	setzt den neuen GEM-Trap
*	muû im Super Mode aufgerufen werden
*/

static	long	Install( void )
{
	OldGEM = *SysGEM;		/* Alten GEM-Trap sichern */
	*SysGEM = NewGEM;
	
	return ( 0L );
}

/*
*	DoDialog()
*
*	Hier bestimmt der Benutzer ob die erweiterte FormDo()-Funktion
*	an- oder ausgeschaltet sein soll
*/

static	void	DoDialog( void )
{
	isOn = form_alert( 1, 
					   "[2]"
					   "[  Erweiterte|  Dialogbox-Funktionen]"
					   "[  Ein | Aus ]"
					  ) - 2;
}

/*
*	main()
*
*	Applikation anmelden
*	MenÅeintrag fÅr Accessory
*	Installation (GEM-Trap)
*/

int		main( void )
{
	int		menu_id;
	int		msg_buf[8];
	int		appl_id;
	
	if ( !_app )				/* Als Accessory gestartet ? */
	{
		appl_id = appl_init();
		
		if ( appl_id != -1 )
		{
			menu_id = menu_register( appl_id, "  X FormDo" );
			
			if ( menu_id != -1 )
			{
				Supexec( Install );
				evnt_timer( 0, 0 );	/*	setzt GemParBlk und installiert
										richtigen GEM-Trap */
				while ( 1 )
				{
					evnt_mesag( msg_buf );
					if ( !msg_buf[2] )
					{
						if ( msg_buf[0] == AC_OPEN &&
							 msg_buf[4] == menu_id )
							DoDialog();
					}
				}
			}
			else
			{
				appl_exit();
				fprintf( stderr, "Keine freien Accessory-EintrÑge\n" );
			}
		}
		else
			fprintf( stderr, "Es konnte keine Applikation "
							 "angemeldet werden" );
	}
	else
		fprintf( stderr, "Programm lÑuft nur als Accessory\n" );
	
	getchar();
	return ( 1 );
}
