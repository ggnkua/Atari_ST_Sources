/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 1/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	Grundlagen: Levenshteindistanz und Soundex	*/
/*																		*/
/*																		*/
/*		M O D U L E		:	TEXTOMAT.C									*/
/*																		*/
/*																		*/
/*		Author			:	JÅrgen Lietzow fÅr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	21.11.91 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#include "textomat.h"


/*	Ein paar Macros fÅr den Umgang mit Resourcen	*/

#define	TrPtr(t)	((*((OBJECT ***)(&(_GemParBlk.global[5]))))[t])
#define	ObPtr(t,o)	((*((OBJECT ***)(&(_GemParBlk.global[5]))))[t]+o)

#define IsSelectable(ob)	((ob)->ob_flags & SELECTABLE)
#define	Select(ob)			((ob)->ob_state |= SELECTED)
#define	Deselect(ob)		((ob)->ob_state &= ~SELECTED)
#define IsSelected(ob)		((ob)->ob_state & SELECTED)

#define	RESOURCE_FILE		"TEXTOMAT.RSC"

/*
*	Folgende Parameter legen die Array-Grîûen und Attribute
*	von <<GetWLD()>> fest.
*/

#define	WORD_FILE	"TEXTOMAT.DAT"	/* Wîrterbuch */

#define	TMAT_MAGIC	'TMAT'			/* Damit beginnt das Wîrterbuch */

#define WORD_LEN	22				/* Maximale LÑnge eines Wortes */
#define MAX_WORD	10000			/* Anzahl der Worte, die in das */
									/* Wîrterbuch aufgenommen */
									/* werden kînnen */
#define	SHOW_NUM	100				/* Maximale Anzahl der Worte, die */
									/* angezeigt werden */

#define rep			2				/* Gewichtung fÅr Ersetzungen */
#define ins			1				/* Gewichtung fÅr EinfÅgungen */
#define del			3				/* Gewichtung fÅr Lîschungen */


/*	Aufbau des Wîrterbuchs */

typedef	struct
{
		char	word[WORD_LEN];		/* Wort im Original */
		char	sound[WORD_LEN];	/* Klangbild von <<word>> */
}	WORDS;


/*	Verwaltungsstruktur fÅr das Wîrterbuch	*/

typedef struct
{
		int		wld;				/* Gewichtete Levenshteindistanz */
		int		dummy;				/* Damit ist die Pure C	*/
									/* qsort-Funktion schneller */
		WORDS	*wp;				/* Zeiger auf entsprechenden */
									/* Eintrag im Wîrterbuch */
}	INDEX;


/*	Statische Variablen */

static	char	mx[32][32];			/* Berechnungsmatrix fÅr GetWLD() */
static	WORDS	words[MAX_WORD];	/* Wîrterbuch */
static	INDEX	index[MAX_WORD];	/* Kontrollstruktur. Kann bei */
									/* entsprechenden Abragen auch */
									/* kleiner sein */
static	int		numWord = 0;		/* Anzahl der Worte im Wîrterbuch */
static	int		numIdx = 0;			/* Anzahl der _gÅltigen_ Kontroll- */
									/* Strukturen */
									
static	GRECT	desk;				/* Desktopgrîûe */
static	int		drive;				/* Aktuelles Laufwerk bei */
									/* Programmstart */
static	char	entry_path[128];	/* Pfad bei Programmstart */


/*
*	Service-Routinen fÅr GEM
*/

static	int		ObjcDraw( OBJECT *tree, int start, int depth, GRECT *g )
{
	return	objc_draw( tree, start, depth, g->g_x, g->g_y,
					   g->g_w, g->g_h );
}

static	int		WindGet( int hdl, int type, GRECT *gr )
{
	return ( wind_get( hdl, type,
					   &gr->g_x, &gr->g_y, &gr->g_w, & gr->g_h ) );
}

static	void	ClrScreen( void )
{
	form_dial( FMD_FINISH, desk.g_x, desk.g_y, desk.g_w, desk.g_h,
			   desk.g_x, desk.g_y, desk.g_w, desk.g_h );
 	evnt_timer( 0, 0 );
}

/*
*	PrtBusy()
*
*	Bringt eine kleine Meldung, daû zur Zeit gearbeitet wird
*/

static	void	PrtBusy( void )
{
	int		dummy;
	OBJECT	*tree = TrPtr(BUSY);
	
	form_center( tree, &dummy, &dummy, &dummy, &dummy );
	ObjcDraw( tree, 0, 8, &desk );
}

/*
*	GetSound()
*
*	Erzeugt aus einem Wort, das Klangbild.
*
*	Hier darf nach belieben ausprobiert werden, denn die
*	vorgeschlagenen Umwandlungen entbehren jeder wissenschaftlichen
*	Grundlage, und sind auch nur durch Ausprobieren ermittelt.
*
*	Der ursprÅngliche Soundex-Algorithmus (fÅr die englische Sprache)
*	war in der Wortreduzierung noch viel brutaler. Allerdings war er
*	auch nicht fÅr das Zusammenspiel mit der Levenshteindistanz gedacht.
*	Da die Levenshteindistanz schon ihres tut, ist diese Lîsung hier
*	etwas sensibler.
*/

static	char	*GetSound( const char *src, char *dest )
{

/*
*	Aus zwei mach eins. ACHTUNG: Sie sind zur schnellern Abarbeitung
*	alphabetisch geordnet.
*/

static const char duo_src[] =  "AECKCZEIEYEUGKIEKSOEPFPHQUSCSZTSTZUE";
static const char duo_dest[] = "E C C AYAYOYC Y X ô V V CUC C C C Y ";

/*
*	Wenn es keine Zwei-Buchstaben-Kombination war, werden Buchtaben
*	aus <<one_src>> in entsprechende aus <<one_dest>> gewandelt
*/

static const char one_src[] =  "FGIJKPQTWZûéöÑîÅ";
static const char one_dest[] = "VCYYCBCDVCSEYEôY";

/*
*	Wenn es weder Zwei-Buchstaben-Kombinationen, noch welche aus
*	<<one_src>> waren, werden alle auûer die aus <<valid>> gelîscht.
*/

static const char valid[] =    "ABCDELMNORSUVXYô";


/*
*	WICHTIG ! Das ganze passiert _nicht_ in drei Passes. Wenn es sich
*	z.B. um eine Zwei-Buchstaben-Kombination handelt, ist das Ergebnis
*	(also das aus duo_dest) aus dem weiteren Rennen. In <<duo_dest>>
*	muû also das Ergebnis stehen, das nicht weiter transformiert werden
*	muû.
*/

	int		s, d, r;
	int		next = 0;
	char	c;
	
	strcpy( dest, src );
	strupr( dest );

	for ( s = 0, d = 0; ( c = dest[s] ) != '\0'; s++ )
	{
		if ( c == dest[s+1] )
			s++;
		else
			for ( r = 0; duo_src[r]; r += 2 )
			{
				if ( c == duo_src[r] && dest[s+1] == duo_src[r+1] )
				{
					dest[d++] = duo_dest[r];
					if ( duo_dest[r+1] != ' ' )
						dest[d++] = duo_dest[r+1];
					s++;
					next = 1;
					break;
				}
				else if ( c < duo_src[r] )
					break;
			}
		if ( !next )
		{
			for ( r = 0; one_src[r]; r++ )
				if ( c == one_src[r] )
				{
					dest[d++] = one_dest[r];
					next = 1;
					break;
				}
			if ( !next )
				for ( r = 0; valid[r]; r++ )
					if ( c == valid[r] )
					{
						dest[d++] = c;
						break;
					}
		}
		next = 0;
	}
	dest[d] = '\0';
	return ( dest );
}


static	char	min3( char a1, char a2, char a3 ) 
{ 
	if (a1 < a2)
		a2 = a1; 
	if (a2 < a3)
		a3 = a2; 
	return ( a3 ); 
} 

/*
*	GetWLD()
*
*	Berechnung der gewichteten Levenshteindistanz.
*	<<search>> ist das gesucht Wort, <<lserarch>> dessen LÑnge.
*	<<compare>> ist das zu vergleichende Wort, <<lcompare>> dessen LÑnge
*/

int GetWLD( const char *search, int lsearch, const char *compare,
			int lcompare ) 
{ 
	int		i, j;
	int		temp;

	mx[0][0] = 0; 

	/*	Basis setzen */
	
	for ( i = 1; i <= lsearch; i++) 
		mx[i][0] = mx[i - 1][0] + del; 
	for ( j = 1; j <= lcompare; j++ ) 
		mx[0][j] = mx[0][j - 1] + ins; 

	/* Jeden Buchtaben von search mit jedem Buchstaben von compare */
	/* vergleichen */
	
	for ( i = 0; i < lsearch; i++ ) 
		for ( j = 0; j < lcompare; j++ ) 
		{
			temp = ( search[i] == compare[j] ? 0 : rep );
			
			mx[i+1][j+1] = min3( mx[i]  [j]   + temp,
								 mx[i+1][j]   + ins,
								 mx[i]  [j+1] + del ); 
		}
	return mx[lsearch][lcompare]; 
} 

static	int		Cmp( INDEX *id1, INDEX *id2 )
{
	return ( id1->wld - id2->wld );
}

/*
*	GenList()
*
*	erzeugt die sortierte Index-Liste, die die WLD's der Wîrter aus
*	dem Wîrterbuch enthÑlt.
*/

static	void	GenList( const char *word )
{
	int		i;
	char	sound[WORD_LEN];
	WORDS	*wptr = words;
	INDEX	*idx = index;
	int		len1, len2;
	int		max;
	int		cnt;
	
	GetSound( word, sound );
	len1 = (int) strlen( sound );

	/* <<max>> gibt die grîûte Distanz an, */
	/* die noch toleriert werden soll */
	/* PS: ganz nach eigenem Geschmack */
	
	max = len1 * ( ins + rep + del ) / 6;

	/* Hier wird von allen <<Sounds>> aus dem Wîrterbuch die */
	/* WLD berechnet */
	
	for ( cnt = 0, i = numWord + 1; --i; wptr++ )
	{
		len2 = (int) strlen( wptr->sound );
		len2 = GetWLD( sound, len1, wptr->sound, len2 );
		if ( len2 <= max )
		{
			idx->wld = len2;
			idx->wp = wptr;
			idx++;
			cnt++;
		}
	}
	
	qsort( index, cnt, sizeof ( INDEX ), Cmp );

	if ( cnt > SHOW_NUM )
		cnt = SHOW_NUM;
	
	/* Von den Wîrtern die unserem Kriterium stand gehalten haben */
	/* wird zum Sound-WLD noch die Wort-WLD (2 zu 1) dazu addiert und */
	/* sortiert */
	
	len1 = (int) strlen( word );
	idx = index;
	for ( i = cnt + 1; --i; idx++ )
	{
		len2 = (int) strlen( idx->wp->word );

		idx->wld <<= 1;		/* Sound-WLD wird stÑrker gewichtet ??? */

		idx->wld += GetWLD( word, len1, idx->wp->word, len2 );
	}
	qsort( index, cnt, sizeof ( INDEX ), Cmp );

	numIdx = cnt;			/* Anzahl der Index festhalten */
}

/*
*	ShowList()
*
*	Schreibt in die Dialogbox fÅnf EintrÑge ab <<pos>>
*/

static	void	ShowList( int pos )
{
	OBJECT	*tree = TrPtr(TMAT);
	OBJECT	*obj = tree + WORDLIST + 1;
	int		i;
	char	*t1, *t2;
	int		w;
	
	for ( i = 0; i < 5; i++, obj++ )
	{
		if ( pos + i >= numIdx )
		{
			t1 = "";
			t2 = "";
			w = 0;
		}
		else
		{
			t1 = index[pos+i].wp->word;
			t2 = index[pos+i].wp->sound;
			w = index[pos+i].wld;
		}
		sprintf( obj->ob_spec.tedinfo->te_ptext, "%3d %-21s %-19s %2d ", 
				 i+pos, t1, t2, w );
	}
	ObjcDraw( tree, WORDLIST, 8, &desk );
}

/*
*	Hier die Funktionen fÅr das Wîrterbuch (Speichern, Laden, ...)
*/

/*
*	IsAlpha()
*
*	bestimmt die Zeichen die zu einem Wort gehîren dÅrfen
*/

static	int		IsAlpha( char c )
{
	if ( isalpha( c ) )
		return ( 1 );
	switch ( c )
	{
		case 'Ñ' :
		case 'î' :
		case 'Å' :
		case 'é' :
		case 'ô' :
		case 'ö' :
		case 'û' :	return ( 1 );
		default:	break;
	}
	return ( 0 );
}

/*
*	AddTokens()
*
*	lieût eine Textdatei in das Wîrterbuch
*	öberprÅft ob noch genug Platz im Wîrterbuch ist, und ignoriert
*	Wîrter, die lÑnger als WORD_LEN sind
*/

static	int	AddTokens( FILE *fp, WORDS *lst, int start )
{
	int		num = 0;
	int		pos;
	char	c;
	int		i;
	WORDS	*sav = lst;
	WORDS	*lst1;
	
	lst += start;
	do
	{
		if ( ( c = fgetc( fp ) ) == EOF )
			return ( num );
		if ( IsAlpha( c ) )
		{
			pos = 0;
			do
			{
				lst->word[pos++] = c;
				if ( ( c = fgetc( fp ) ) == EOF )
					return ( num );
				if ( pos == WORD_LEN - 1 )
				{
					do
					{
						if ( ( c = fgetc( fp ) ) == EOF )
							return ( num );
					} while ( IsAlpha( c ) );
					pos = 0;
					c = '\0';
				}
			} while ( IsAlpha( c ) );
			if ( pos > 1 )
			{
				if ( isupper( lst->word[1] ) )
					continue;
				lst->word[pos] = '\0';
				num++;
				lst++;
				for ( lst1 = sav, i = start + num; --i; lst1++ )
					if ( !strcmp( lst[-1].word, lst1->word ) )
					{
						num--;
						lst--;
						break;
					}
			}
		}
	} while ( num + start < MAX_WORD );			
	return ( num );
}

/*
*	AddText()
*
*	Textdatei îffnen, um in das Wîrterbuch einzulesen
*/

static	int		AddText( char *fname )
{
	FILE	*fp;
	char	fn[30];
	char	mes[200];
	int		num;
	int		i;
	
	if ( ( fp = fopen( fname, "r" ) ) == NULL )
	{
		strncpy( fn, fname, 29 );
		fn[29] = '\0';
		sprintf( mes, "[1][Konnte Datei|'%s'|nicht finden.][OK]", fn );
		form_alert( 1, mes );
		return ( 1 );
	}
	
	num = AddTokens( fp, words, numWord );
	fclose( fp );
	if ( num == 0 )
		return ( 1 );
		
	for ( i = 0; i < num; i++ )
		GetSound( words[i+numWord].word, words[i+numWord].sound );
	
	numWord += num;
	return ( 0 );
}

/*	
*	AddAction()
*
*	Benutzer wÑhlt die Texte aus, deren Wîrter in das Wîrterbuch 
*	aufgenommen werden sollen
*/

static	void	AddAction( void )
{
	static	char	path[128] = "X:";
	static	char	fname[14] = "";
			char	temp[128];
			int		ret;
			char	*ptr;
			
	if ( path[0] == 'X' )
	{
		path[0] = Dgetdrv() + 'A';
		Dgetpath( path + 2, 0 );
		strcat( path, "\\*.TXT" );
	}
	do
	{
		graf_mouse( ARROW, NULL );
		if ( fsel_input( path, fname, &ret ) == 0 || ret == 0 )
			break;
		graf_mouse( BUSYBEE, NULL );
		
		strcpy( temp, path );
		if ( ( ptr = strrchr( temp, '\\' ) ) == NULL )
			ptr = temp;
		else
			ptr++;
		strcpy( ptr, fname );

		PrtBusy();		
	} while ( !AddText( temp ) );	
}

/*
*	DeleteWord()
*
*	Lîscht ein Wort aus dem Wîrterbuch
*/

static	void	DeleteWord( char *word )
{
	int		i;
	WORDS	*lst = words;
	int		max = numWord;
	char	mes[256];
	
	for ( i = 0; i < max; i++, lst++ )
		if ( !strcmp( word, lst->word ) )
		{
			memmove( lst, lst + 1, ( max - i - 1 ) * sizeof (WORDS) );
			numWord--;
			numIdx = 0;
			return;
		}
	sprintf( mes, "[1][Das Wort|'%s'|war im Wîrterbuch|"
				  "nicht enthalten][OK]", word );
	form_alert( 1, mes );
}

/*
*	LoadDic()
*
*	LÑdt das Wîrterbuch
*/

static	void	LoadDic( void )
{
	FILE	*fp;
	long	arr[2];
	
	Dsetdrv( drive );
	Dsetpath( entry_path );
	
	if ( ( fp = fopen( WORD_FILE, "rb" ) ) == NULL )
		return;
		
	if ( fread( arr, sizeof (long), 2L, fp ) != 2L ||
		 arr[0] != TMAT_MAGIC )
	{
		form_alert( 1, "[1][Falsches Dateiformat|von'" WORD_FILE "'][OK]" );
		fclose( fp );
		return;
	}
	numWord = (int) arr[1];
	if ( numWord > MAX_WORD )
		numWord = MAX_WORD;
	
	if ( fread( words, sizeof (WORDS), numWord, fp ) != (long) numWord )
	{
		form_alert( 1, "[1][Lesefehler bei|'" WORD_FILE "'][OK]" );
		numWord = 0;
	}
	fclose( fp );
}	

/*
*	SaveDic()
*
*	Speichert das Wîrterbuch
*/

static	void	SaveDic( void )
{
	long	arr[2];
	FILE	*fp;

	Dsetdrv( drive );
	Dsetpath( entry_path );

	arr[0] = TMAT_MAGIC;
	arr[1] = numWord;
	
	if ( ( fp = fopen( WORD_FILE, "wb" ) ) == NULL ||
		fwrite( arr, sizeof (long), 2L, fp ) != 2L ||
		fwrite( words, sizeof (WORDS), numWord, fp ) != (long) numWord )
		form_alert( 1, "[1][Schreibfehler bei|'" WORD_FILE "'][OK]" );
	fclose( fp );
}

/*
*	PrtNumWord()
*
*	Schreibt die Anzahl der Wîrter im Wîrterbuch in die Dialogbox
*/

static	void	PrtNumWord( void )
{
	OBJECT	*tree = TrPtr(TMAT);
	
	sprintf( tree[NUMWORD].ob_spec.tedinfo->te_ptext,
			 "%4d Worte", numWord );
			 
	ObjcDraw( tree, NUMWORD, 8, &desk );
}


/*
*	EventLoop()
*
*	Von hier aus wird alles aufgerufen
*/

static	void	EventLoop( void )
{
	OBJECT	*tree = TrPtr(TMAT);
	int		pos = 0;
	int		obj;
	int		dummy;
	int		mstate;
	
	graf_mouse( BUSYBEE, NULL );
	LoadDic();
	
	form_center( tree, &obj, &obj, &obj, &obj );
	ObjcDraw( tree, 0, 8, &desk );
	PrtNumWord();
	ShowList( pos );
	
	do
	{
		graf_mouse( ARROW, NULL );
		obj = form_do( tree, SWORD ) & 0x7fff;
		graf_mouse( BUSYBEE, NULL );
		Deselect(tree+obj);
		
		switch ( obj )
		{
			case QUIT		:	graf_mouse( ARROW, NULL );
								return;
			case SAVEWRD	:	SaveDic();
								ObjcDraw( tree, obj, 8, &desk );
								break;
			case LOADTXT	:	ClrScreen();
								AddAction();
								ObjcDraw( tree, 0, 8, &desk );
								PrtNumWord();
								break;
			case SEARCH		:	
					GenList( tree[SWORD].ob_spec.tedinfo->te_ptext );
					pos = 0;
					ObjcDraw( tree, obj, 8, &desk );
					ShowList( pos );
					break;					
			case WORDUP		:	do
								{
									if ( pos )
									{
										pos--;
										ShowList( pos );
									}
									else
										break;
									graf_mkstate( &dummy, &dummy, &mstate,
												  &dummy );
								} while ( mstate );
								break;
			case WORDDOWN	:	do
								{
									if ( pos < SHOW_NUM - 5 &&
										 pos < numWord - 1 )
									{
										pos++;
										ShowList( pos );
									}
									else
										break;
									graf_mkstate( &dummy, &dummy, &mstate,
												  &dummy );
								} while ( mstate );
								break;
			case DELETE		:	
					DeleteWord( tree[SWORD].ob_spec.tedinfo->te_ptext );
					PrtNumWord();
					ObjcDraw( tree, obj, 8, &desk );
					break;
			default			:	break;
		}
	} while ( 1 );
}			

/*
*	main()
*
*	Applikation anmelden
*/

int		main( void )
{
	if ( _app )
	{
		if ( appl_init() >= 0 )
		{
			if ( rsrc_load( RESOURCE_FILE ) )
			{
				WindGet( 0, WF_CURRXYWH, &desk );
				drive = Dgetdrv();
				Dgetpath( entry_path, 0 );
				EventLoop();
				rsrc_free();
				appl_exit();
				return ( 0 );
			}
			else
			{
				form_alert( 1,	"[1][Resource-Datei|nicht gefunden]"
								"[ OK ]" );
				appl_exit();
			}
		}
		else
			form_alert( 1,	"[1][Diese Applikation konnte|"
							"nicht angemeldet werden"
							"[ OK ]" );
	}
	else
		fprintf( stderr, "Programm lÑuft nicht als Accessory\n" );
	return ( 1 );
}
