/********************************************************************/
/* RESOURCE.C														*/
/*																	*/
/* Erm”glicht es, RSC-Dateien dirket in ein C-Programm einzubinden,	*/
/* binden.															*/
/* 		-> kein Nachladen											*/
/* 		-> weniger Dateien											*/
/* 		-> u.U. weniger Speicherbedarf								*/
/*																	*/
/********************************************************************/
/********************************************************************/
/**  ACHTUNG: Nicht jeder Resource-Editor gibt die RSH-Dateien im  **/
/**  ANSII-kompatiblen Format aus. Deshalb muž u.U. die RSH-Datei  **/
/**  vor dem Compilieren mit CONV_RSH.TTP konvertiert werden!	   **/
/**  															   **/
/**  Aufruf: CONV_RSH datei.RSH
/********************************************************************/
/********************************************************************/
/*																	*/
/* Ohne RESOURCE:													*/
/*																	*/
/*		...															*/
/*		rsrc_load ("TEST.RSC");										*/
/*		rsrc_gaddr (R_TREE, MENUE, &menue);							*/
/*		...															*/
/*																	*/
/* Mit RESOURCE:													*/
/*																	*/
/* 		#include "TEST.RSH"											*/
/*		...															*/
/*		rsrc_init(NUM_TREE, NUM_OBS, NUM_FRSTR, NUM_FRIMG,			*/
/*			rs_strings, rs_frstr, rs_bitblk, rs_frimg, rs_iconblk,	*/
/*			rs_tedinfo, rs_object, rs_trindex, rs_imdope);			*/
/*																	*/
/*		menue = (OBJECT *)rs_trindex[MENUE];						*/
/*		...															*/
/*																	*/
/********************************************************************/

#include <aes.h>
#include <resource.h>


/********************************************************************/
/* Prototypen														*/
/********************************************************************/

void ini_tree( int n_tree, OBJECT **rs_trindex, OBJECT *rs_object );
void ini_tedinfo( int object, OBJECT *rs_object, TEDINFO *rs_tedinfo, 
					BYTE **rs_strings );
void ini_bitblk( int object, OBJECT *rs_object, BITBLK *rs_bitblk,
					RS_IMDOPE *rs_imdope );
void ini_string( int object, OBJECT *rs_object, BYTE **rs_strings );
void ini_iconblk( int object, OBJECT *rs_object, ICONBLK *rs_iconblk,
					RS_IMDOPE *rs_imdope, BYTE **rs_strings );
void ini_frimg( int object, LONG *rs_frimg, BITBLK *rs_bitblk,
					RS_IMDOPE *rs_imdope );
void cut_obwidth( OBJECT *menu, WORD width );





/********************************************************************/
/* Resource initialisieren											*/
/********************************************************************/
/* Diese Funktion sollte am Programmanfang gleich nach dem			*/
/* Anmelden und	™ffnen der VDI-Workstation aufgerufen werden.		*/
/*																	*/
/* Diese "eierlegende Wollmilchsau" erledigt alle Initialisierungen,*/
/* die bei der eingebundenen Resource n”tig sind (normalerweise 	*/
/* wird das bei rsrc_load() automatisch getan). Die Funktionen, die */
/* von hier aus aufgerufen werden, machen im grožen und ganzen nur  */
/* eines: Sie ersetzen die Indizes, die im RSH-File an Stelle von	*/
/* richtigen Adressen (z.B. von Strings) stehen, durch die realen	*/
/* Adressen.														*/

void rsrc_init( int n_tree, int n_obs, int n_frstr, int n_frimg,
                 char **rs_strings, long *rs_frstr, BITBLK *rs_bitblk,
                 long *rs_frimg, ICONBLK *rs_iconblk,
                 TEDINFO *rs_tedinfo, 
                 OBJECT *rs_object, OBJECT **rs_trindex, 
                 RS_IMDOPE *rs_imdope )
{
int o;		/* Objektnummer */

	ini_tree( n_tree, rs_trindex, rs_object );

	for( o = 0; o < n_obs; o ++ )
	{
		switch( rs_object [o].ob_type & 0xFF )
		{
			/* Diese Objekte lassen wir in Ruhe: */
		case G_BOX:			
		case G_USERDEF:
		case G_IBOX:
		case G_BOXCHAR:
			break;
			
			/* Bei diesen mssen TEDINFOs initialisiert werden: */
		case G_TEXT:		
		case G_BOXTEXT:
		case G_FBOXTEXT:
		case G_FTEXT:
			ini_tedinfo( o, rs_object, rs_tedinfo, rs_strings );
            break;
            
			/* Bei diesen BITBLKs: */
		case G_IMAGE:
			ini_bitblk( o, rs_object, rs_bitblk, rs_imdope );
            break;
			
			/* Und bei jenen ICONBLKs: */
		case G_ICON:
			ini_iconblk( o, rs_object, rs_iconblk, rs_imdope, rs_strings );
			break;
            
			/* Hier mssen Stringadressen eingetragen werden: */
		case G_BUTTON:
		case G_STRING:
		case G_TITLE:
			ini_string( o, rs_object, rs_strings );
			break;
		}
	}

	/* Freie Strings initialisieren: */
	for (o = 0; o < n_frstr; o++)
		rs_frstr[o] = (LONG)rs_strings[rs_frstr[o]]; 

	/* Freie Images initialisieren: */
	for (o = 0; o < n_frimg; o++)
		ini_frimg(o, rs_frimg, rs_bitblk, rs_imdope);
}





/********************************************************************/
/* Objektb„ume initialisieren										*/
/********************************************************************/
/* Die Startadressen der einzelnen Objektb„ume werden in das Feld	*/
/* rs_trindex[] eingetragen. Aužerdem werden die Objektkoordinaten	*/
/* mit rsrc_obfix() an die aktuelle Aufl”sung angepažt.				*/

void ini_tree( int n_tree, OBJECT **rs_trindex, OBJECT *rs_object )
{
int   tree;		/* Baumnummer */
int   o;		/* Objektnummer */
OBJECT *pobject;

	for( tree = 0; tree < n_tree; tree++ )
	{
		rs_trindex[tree]
			= (OBJECT *)( &rs_object[ (int)rs_trindex[tree] ] );

		pobject = rs_trindex[tree];

		/* Bei allen Objekten des Baumes... */
		o = 0;
		do{
			/* ...Koordinaten umwandeln: */
			rsrc_obfix( pobject, o );
		}while( !( pobject[o++].ob_flags & LASTOB ) );
	}
}





/********************************************************************/
/* Tedinfo-Struktur initialisieren									*/
/********************************************************************/
/* Im OBSPEC der OBJECT-Struktur wird die Adresse des dazugeh”ren-	*/
/* TEDINFOs geschrieben. Aužerdem werden in die Stringzeiger der	*/
/* TEDINFO-Struktur die Stringadressen eingetragen.					*/
/*																	*/
/* Die TEDINFO-Struktur besteht aus:								*/
/*	char	*te_ptext;		Zeiger auf einen String					*/
/*	char	*te_ptmplt;		Zeiger auf die Stringmaske				*/
/*	char	*te_pvalid;		Zeiger auf den Gltigkeitsstring		*/
/*	int		te_font;		Zeichensatz								*/
/*	int		te_junk1;			(Mll)								*/
/*	int		te_just;		Justierung des Texts					*/
/*	int		te_color;		Farbe									*/
/*	int		te_junk2;			(Mll)								*/
/*	int		te_thickness;	Rahmenbreite							*/
/*	int		te_txtlen;		L„nge des Textes						*/
/*	int		te_tmplen;		L„nge der Stringmaske					*/

void ini_tedinfo( int object, OBJECT *rs_object, TEDINFO *rs_tedinfo, 
				char **rs_strings )
{
long i;

	i = rs_object[object].ob_spec.index;
	rs_object[object].ob_spec.tedinfo = &rs_tedinfo[i];

	rs_tedinfo[i].te_ptext 
		= rs_strings[ (int)rs_tedinfo[i].te_ptext ];
	rs_tedinfo[i].te_ptmplt 
		= rs_strings[ (int)rs_tedinfo[i].te_ptmplt ];
	rs_tedinfo[i].te_pvalid 
		= rs_strings[ (int)rs_tedinfo[i].te_pvalid ];
}





/********************************************************************/
/* Bitblk-Struktur initialisieren									*/
/********************************************************************/
/* In die BITBLK-Struktur wird eingetragen, wo sich die Grafikdaten	*/
/* befinden. Danach wird in OBSPEC die Adresse der BITBLK-Struktur	*/
/* notiert.															*/
/*																	*/
/* Ein BITBLK besteht aus:											*/
/*	int	*bi_pdata;	Zeiger auf die Grafikdaten						*/
/*	int	bi_wb;		Breite des Bildes in Bytes						*/
/*	int	bi_hl;		H”he in Linien              					*/
/*	int	bi_x;		x-Position										*/
/*	int	bi_y;		y-Position										*/
/*	int	bi_color;	Vordergrundfarbe								*/

void ini_bitblk( int object, OBJECT *rs_object, BITBLK *rs_bitblk, 
				RS_IMDOPE *rs_imdope )
{
long i1, i2;

	i1 = rs_object[object].ob_spec.index;
	i2 = (long)( rs_bitblk[i1].bi_pdata );

	rs_bitblk[i1].bi_pdata = rs_imdope[i2].image;
	rs_object[object].ob_spec.bitblk = &rs_bitblk[i1];
}





/********************************************************************/
/* Zeichenkette initialisieren										*/
/********************************************************************/
/* Die Anfangsadresse der Zeichenkette wird in OBSPEC eingetragen.	*/

void ini_string( int object, OBJECT *rs_object, char **rs_strings )
{
	rs_object[ object ].ob_spec.free_string
	 	= rs_strings[ (int)rs_object[object].ob_spec.index ];
}





/********************************************************************/
/* Iconblkstruktur initialisieren									*/
/********************************************************************/
/* Die Adressen von Maske, Bild und String werden in die ent-		*/
/* sprechenden Felder der ICONBLK-Struktur eingetragen. Danach wird	*/
/* die Adresse des ICONBLK im OBSPEC des betreffenden Objekts ver-	*/
/* merkt.															*/
/*																	*/
/* Ein ICONBLK-Struktur sieht folgendermažen aus:					*/
/*	int		*ib_pmask;	Zeiger auf die Maske  	        			*/
/*	int		*ib_pdata;	Zeiger auf das Icon-Bild	   				*/
/*	char	*ib_ptext;	Zeiger auf einen String    				 	*/
/*	int		ib_char;	In den unteren 8 Bit das darzustellende		*/
/*        				Zeichen, in den oberen 8 Bit die Farbe des	*/
/*						gesetzten (obere 4 Bit) und des gel”schten	*/
/*						(untere 8 Bit) Bits des Bitmuster IB_PDATA	*/
/*	int		ib_xchar;	x-Koordinate des Buchstabens				*/
/*	int		ib_ychar;	y-Koordinate des Buchstabens				*/
/*	int		ib_xicon;	x-Koordinate des Icons						*/
/*	int		ib_yicon;	y-Koordinate des Icons						*/
/*	int		ib_wicon;	Breite des Icons							*/
/*	int		ib_hicon;	H”he des Icons								*/
/*	int		ib_xtext;	x-Koordinate des Textes						*/
/*	int		ib_ytext;	y-Koordinate des Textes						*/
/*	int		ib_wtext;	Breite des Textes							*/
/*	int		ib_htext;	H”he des Textes								*/
/*	int		ib_resvd;	reserviert, muž 0 sein						*/

void ini_iconblk( int object, OBJECT *rs_object, ICONBLK *rs_iconblk,
					 RS_IMDOPE *rs_imdope, char **rs_strings )
{
long i1, i2;

	i1 = rs_object[object].ob_spec.index;

	i2 = (int)rs_iconblk[i1].ib_pmask;
	rs_iconblk[i1].ib_pmask = rs_imdope[i2].image;

	i2 = (int)rs_iconblk[i1].ib_pdata;
	rs_iconblk[i1].ib_pdata = rs_imdope[i2].image;

	i2 = (int)rs_iconblk[i1].ib_ptext;
	rs_iconblk[i1].ib_ptext = rs_strings[i2];

	rs_object[object].ob_spec.iconblk = &rs_iconblk[i1];
}





/********************************************************************/
/* Free Image initialisieren										*/
/********************************************************************/
/* Die Adresse der Grafikdaten wird in die BITBLK-Struktur ge-		*/
/* schrieben, die der BITBLK-Struktur in das OBSPEC des Objektes.	*/

void ini_frimg( int object, long *rs_frimg, BITBLK *rs_bitblk, 
				RS_IMDOPE *rs_imdope )
{
int i1, i2;

	i1 = (int)rs_frimg[object];
	i2 = (int)rs_bitblk[i1].bi_pdata;

	rs_bitblk[i1].bi_pdata = rs_imdope[i2].image;
	rs_frimg[object] = (LONG)&rs_bitblk[i1];
}




/********************************************************************/
/* Breite der Menleiste beschr„nken								*/
/********************************************************************/
/* Ist z.B. bei Overscan n”tig, da die Menzeile sonst ber den		*/
/* rechten Bildschirmrand herausragt								*/

void cut_obwidth( OBJECT *menu, WORD width )
{
int object = 0;	/* Objekt-Index */

	do{
		if( menu[object].ob_width > width )
			menu[object].ob_width = width;			
	}while( !( menu[object++].ob_flags & LASTOB ) );
}
