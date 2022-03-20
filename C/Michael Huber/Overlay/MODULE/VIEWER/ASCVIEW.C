/********************************************************************/
/*	Overlay-Modul: ASCVIEW.OLM										*/
/*	Viewer fÅr ASCII-Texte						    				*/
/*	von	Michael Huber   											*/
/********************************************************************/
/*  (c) OverScan 8/94						     			    	*/
/********************************************************************/


#include <ext.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <tos.h>
#include <aes.h>
#include <portab.h>
#include "..\xmodpars\xmodpars.h"


/********************************************************************/

#define XD_BUTTON_MASK 		0x4000
#define XD_NO_KEY_MASK 		0x8000
#define XD_KEY_MASK 		(~XD_BUTTON_MASK & ~XD_NO_KEY_MASK) 
#define PLAYER_KEY(val)  	( (val&0x0F)==6 )  

#define MAX_WIN 			100
#define DEF_WIN_WIDTH 		320
#define DEF_WIN_HEIGHT 		200
#define DEF_FONT_SIZE 		10
#define DEF_ATTR 			0
#define DEF_TAB_WIDTH 		4

#define	min(a, b)		((a) < (b) ? (a) : (b))
#define	max(a, b)		((a) > (b) ? (a) : (b))

/********************************************************************/

typedef struct
{
	UBYTE *buf;         /* Zeichen-Puffer							*/
	LONG len;			/* Anzahl der Zeichen 						*/	
	WORD line;			/* akt. erste Zeile 						*/
	WORD lines;			/* Gesamtzahl der Zeilen 					*/
	WORD win_lines;		/* Zeilen pro Fenster 						*/
	WORD win_rows;		/* Spalten pro Fenster 						*/
	WORD x;				/* Fenster-x-Koordinaten					*/
	WORD y;				/* y-Koordinate								*/
	WORD w;     		/* Breite 									*/
	WORD h;				/* Hîhe										*/
	WORD font_h;		/* Zeichenzellenhîhe 						*/
	WORD font_hb;		/* Zeichenhîhe 								*/
	WORD font_w;		/* Zeichenbreite 							*/
	WORD font_s;		/* Zeichengrîûe in Punkt 					*/
	WORD font_c;		/* Zeichenfarbe: Index 						*/
	WORD bg_col;		/* Hintergrundfarbe: Index					*/
	WORD attr;			/* Attribute 								*/
	WORD tab_w;			/* Tabulatorbreite							*/
} TEXTW;


/********************************************************************/

WORD Text_Num = 0;		/* Anzahl der geladenen Texte 				*/
WORD Act_Text = 0;		/* aktueller Text 							*/
WORD Return = 0;		/* Nach Anzeige sofort zurÅckkehren			*/
WORD vdih;				/* Vdi-Handle 								*/
TEXTW Texts[MAX_WIN];	/* Texte 									*/
WORD Font_C;			/* Farbe 									*/	
WORD Col_Num;			/* Zahl der verf. Farben					*/	
WORD pxy[20];			/* Vdi-xy-Array 							*/
MFDB psrcMFDB, 
     pdesMFDB; 			/* Rastercopy - Strukturen 					*/
UBYTE Out_Line[256];	/* Ausgabezeile 							*/
WORD Dummy;				/* Dummy fÅr unnÅtze Funktionswerte 		*/  


/********************************************************************/

WORD Aview_MakeLine( UBYTE *out, UBYTE *in, WORD max, WORD tab )
{

	/*** Auszugebende Zeile aufbauen ***/

	
	WORD i, n;
	
		
	for( i=0, n=0; in[i] && n<255 && in[i] != '\n' ; i++ )
	{
		if( in[i] > 13 )	/* Steuerzeichen ignorieren */
		{
			out[n] = in[i];
			n++;
		} 	
			
		if( in[i] == 9 && tab )	/* Tab */
		{
			out[n] = ' ';
			for( n++; ( n % tab ); n++ )
				out[n] = ' ';
		}		
	}
	for( ; n<max; n++ )		/* restlichen String auffÅllen */
		out[n] = ' ';
	
	out[n] = 0;				/* Ende des Strings */

	return n;
	
}	
	

/********************************************************************/

WORD Aview_GetLineLen( UBYTE *line_start )
{
	
	/*** LÑnge der Zeile ermitteln ***/
	
	
	WORD len;
	
	
	for( len=0;
		 line_start[len] != '\n' && line_start[len] && len < 256; 
		 len++ );
	
	return len;
		
}


/********************************************************************/

UBYTE *Aview_GetLine( WORD t, WORD l )
{

	/*** Zeiger auf Zeile l holen ***/
	
	
	LONG i;
	WORD n;
	
	
	for( i=0, n=0; n != l; i++ )
		if( Texts[t].buf[i] == '\n' ) /* Zeilentrenner? */
			n++;

	return Texts[t].buf+i;
	
}


/********************************************************************/

VOID Aview_PrintLine( WORD t, WORD l )
{

	/*** l.te Zeile eines Textes ausgeben ***/
	
	
	if( l < Texts[t].lines )
	{	
		Aview_MakeLine( Out_Line, Aview_GetLine( t, l ), 
						Texts[t].win_rows+1,
						Texts[t].tab_w );
		/*  Hintergrundbox zeichnen */
		pxy[0] = Texts[t].x;
		pxy[1] = Texts[t].y + (l-Texts[t].line-1) * Texts[t].font_h
				+Texts[t].font_h;
		pxy[2] = Texts[t].x + Texts[t].w;
		pxy[3] = Texts[t].y + (l-Texts[t].line) * Texts[t].font_h
				+Texts[t].font_h-1;
		v_bar( vdih, pxy );
		
		vswr_mode( vdih, MD_TRANS );						
		v_gtext( vdih, Texts[t].x, 
			Texts[t].y + (l-Texts[t].line) * Texts[t].font_h
				+Texts[t].font_hb, (BYTE *)Out_Line );		
		vswr_mode( vdih, MD_REPLACE );						
		
	}				   
		
}


/********************************************************************/

VOID Aview_ScrollUp( WORD t )
{

	/*** 1 Zeile nach oben ***/

	
	if( Texts[t].line )
	{
		Texts[t].line--;
		
		/* Ausschnitt nach unten kopieren */
		
		pxy[0] = 
		pxy[4] = Texts[t].x;
		pxy[1] = Texts[t].y; 
		pxy[2] = 
		pxy[6] = Texts[t].x+Texts[t].w; 
		pxy[3] = Texts[t].y
					+(Texts[t].win_lines-1)*Texts[t].font_h-1;
		pxy[5] = Texts[t].y+Texts[t].font_h;
		pxy[7] = Texts[t].y+Texts[t].win_lines*Texts[t].font_h-1;
		vro_cpyfm( vdih, S_ONLY, pxy, &psrcMFDB, &pdesMFDB);	
		
		/* erste Fensterzeile ausgeben */   
		
		Aview_PrintLine( t, Texts[t].line );		
	}
					
}


/********************************************************************/

VOID Aview_ScrollDown( WORD t )
{

	/*** 1 Zeile nach unten ***/
	
	
	if( Texts[t].line + Texts[t].win_lines < Texts[t].lines)
	{
		
		/* Ausschnitt nach oben kopieren */

		pxy[0] = 
		pxy[4] = Texts[t].x;
		pxy[1] = Texts[t].y+Texts[t].font_h; 
		pxy[2] = 
		pxy[6] = Texts[t].x+Texts[t].w; 
		pxy[3] = Texts[t].y+Texts[t].win_lines*Texts[t].font_h-1;
		pxy[5] = Texts[t].y;
		pxy[7] = Texts[t].y+(Texts[t].win_lines-1)*Texts[t].font_h-1;
		vro_cpyfm( vdih, S_ONLY, pxy, &psrcMFDB, &pdesMFDB);	
		
		Texts[t].line++;
		Aview_PrintLine( t, Texts[t].line+Texts[t].win_lines-1 );

	}	
	
}


/********************************************************************/

VOID Aview_ClipText( WORD t )
{

	/*** Text-Fenster clippen ***/
	
	
	pxy[0] = Texts[t].x;
	pxy[1] = Texts[t].y;	
	pxy[2] = Texts[t].x+Texts[t].w-1;	
	pxy[3] = Texts[t].y+Texts[t].h-1;	
	vs_clip( vdih, 1, pxy );			

}


/********************************************************************/

VOID Aview_SetVdiAttr( WORD t )
{
	
	
	/*** Clipping, Attribute ***/
	
	
 	Aview_ClipText( t );
 	
	vst_point( vdih, Texts[t].font_s, 		/* Zeichengrîûe 		*/
		&Dummy, &Dummy, &Dummy, &Dummy );	/* setzen				*/
	vst_color( vdih, Texts[t].font_c ); 	/* Zeichenfarbe  		*/
	vst_effects( vdih, Texts[t].attr );		/* Attribute 			*/
	vsf_color( vdih, Texts[t].bg_col );		/* Hintergrundfarbe 	*/

}


/********************************************************************/

VOID Aview_DrawFrame( WORD t )
{

	/*** Rahmen um Text t zeichnen ***/

	
	vswr_mode( vdih, MD_XOR );			
	vsf_interior( vdih, FIS_HOLLOW ); 
	
	pxy[0] = Texts[t].x-1;
	pxy[1] = Texts[t].y-1;	
	pxy[2] = Texts[t].x+Texts[t].w;	
	pxy[3] = Texts[t].y+Texts[t].h;	

	v_bar( vdih, pxy );
	vswr_mode( vdih, MD_REPLACE );		
	vsf_interior( vdih, FIS_SOLID ); 

}					


/********************************************************************/

VOID Aview_ShowText( WORD t )
{

	/*** kompletten Text ab der aktuellen Zeile anzeigen ***/
	
	
	WORD i;
	
	
	Aview_SetVdiAttr( t );			/* Vdi-Attribute setzen */
	
	/* Hintergrundbox zeichnen */
	pxy[0] = Texts[t].x;
	pxy[1] = Texts[t].y;
	pxy[2] = Texts[t].x + Texts[t].w -1;
	pxy[3] = Texts[t].y + Texts[t].h-1;
	v_bar( vdih, pxy );	
	
	for( i=0; i<Texts[t].win_lines; i++ )
		Aview_PrintLine( t, Texts[t].line+i );
	
}


/********************************************************************/

VOID Aview_ScrollPage( WORD t, WORD up )
{

	/*** Eine Seite scrollen ***/


	if( up )									/* Hochscrollen */
		Texts[t].line 
			= max( 0, 
				Texts[t].line-Texts[t].win_lines );
	else
		Texts[t].line 
			= min( Texts[t].lines-Texts[t].win_lines, 
				   Texts[t].line+Texts[t].win_lines );
				   
	Aview_ShowText( t );							
			
}	


/********************************************************************/

WORD Aview_SetAct( WORD t )
{

	/*** Aktuelles Textfenster setzen ***/


	static act_frm = 0;					/* aktueller Text umrahmt 	*/
	
	
	if( t < 0 || t == Text_Num )		/* legaler Text-Index?		*/		
		return 0;
		
	if( Act_Text != t || !act_frm )		/* Akt. Text oder Rahmen	*/
	{									/* noch nicht gesetzt?		*/
		vs_clip( vdih, 0, pxy );		/* Clipping aus 			*/
		if( act_frm )					/* wenn schon umrahmt 		*/	
			Aview_DrawFrame( Act_Text );/* Rahmen zurÅck 			*/
		Act_Text = t;
		Aview_DrawFrame( Act_Text );	/* Rahmen setzen 			*/
		Aview_SetVdiAttr( Act_Text );	/* Vdi-Attribute setzen 	*/
				act_frm = 1;						
		return 1;
	}

	return 0;
	
}		


/********************************************************************/

WORD Aview_PrevText( WORD act_t )
{

	/*** vorhergehenden Text suchen ***/
	
	
	WORD t, prev_t, prev_x;
	
	
	prev_t = -1;
	prev_x = 0;
	for( t=0; t<Text_Num; t++ )			/* vorhergehenden */		
	{									/* Text */	
		if( Texts[t].x <= Texts[act_t].x/* suchen */ 
			&& t != act_t 				
			&& Texts[t].x > prev_x 
			&& Texts[t].win_lines <		/* scrollbar? */
				Texts[t].lines )
		{		
			prev_t = t;
			prev_x = Texts[t].x;
		}	
	}		
	
	return prev_t;
	
}


/********************************************************************/

WORD Aview_NextText( WORD act_t )
{

	/*** nÑchsten Text suchen ***/
	
	
	WORD t, next_t, next_x;
	
	
	next_t = Text_Num;
	next_x = 32767;
	for( t=0; t<Text_Num; t++ )			
	{										
		if( ( act_t == -1 				
			|| Texts[t].x >= Texts[act_t].x ) &&
			t != act_t && 				
			Texts[t].x < next_x &&
			Texts[t].win_lines <		/* scrollbar? */
				Texts[t].lines )
		{		
			next_t = t;
			next_x = Texts[t].x;
		}	
	}		
	
	return next_t;

}


/********************************************************************/

WORD Aview_Handle( WORD key )
{

	/*** Key auswerten ***/
	
	
	switch( key & XD_KEY_MASK )
	{
		case 'u':	Aview_ScrollUp( Act_Text ); 
					break;
		case 'd':	Aview_ScrollDown( Act_Text ); 
					break;
		case 'l':	Aview_SetAct( Aview_PrevText( Act_Text ) ); 
					break;
		case 'r':   Aview_SetAct( Aview_NextText( Act_Text ) );
					break;
		case 'U':	Aview_ScrollPage( Act_Text, 1 ); 
					break;
		case 'D':	Aview_ScrollPage( Act_Text, 0 ); 
					break;
		case 'h':	Texts[Act_Text].line = 0;
					Aview_ShowText( Act_Text );							
					break;
		case 'H':	Texts[Act_Text].line 
					= Texts[Act_Text].lines-Texts[Act_Text].win_lines;
					Aview_ShowText( Act_Text );							
					break;	
		case ' ':									/* alles		*/
		case 'a': 									/* Abbruch-     */
		case 'b':									/* tasten		*/	
		case 'c':	return 1;						/* Ende 		*/
	}
			
	return 0;
	
}


/********************************************************************/

WORD Aview_MouseIn( VOID )
{

	/*** Mausevent empfangen und umsetzen ***/

	
	WORD key = XD_NO_KEY_MASK;
	WORD ikey;
	WORD ev_mgpbuff[8];
	WORD button=0;
	WORD dummy;
	WORD event=0, mx, my;
	static WORD old_mx=0, old_my=0, first=1, mouse_in_move = 0;
		
		
	event = evnt_multi( MU_TIMER|MU_BUTTON,
							0x101, 3, 0,
							0, 0, 0, 0, 0,
							0, 0, 0, 0, 0,
							ev_mgpbuff, 1, 0, &mx, &my,
							&button, &ikey,
							&dummy, &dummy);
							
	if( PLAYER_KEY( ikey ) )			/* Control/Shift? */		
		return( XD_BUTTON_MASK );	
	
	if( event & MU_BUTTON )				/* Maustasten */
	{
		switch( button )
		{
			case 1: 
				key = 'd'; break;		/* nach oben */
			case 2: 
				key = 'u'; break;   	/* nach unten */
			case 3: 
				key = XD_BUTTON_MASK; 	/* Abbruch */ 
				break;	
		}	
	}			
	
	/* Mausbewegungen */
	
	if( mx-old_mx > 0 && !first 
		&& !mouse_in_move)				/* Bewegung nach rechts */
	{
		mouse_in_move = 1;				/* Maus in Bewegung */
		key = 'r';
	}	
	else if( mx-old_mx < 0 
		&& !mouse_in_move)   			/* Bewegung nach links */
	{
		mouse_in_move = 1;				/* Maus in Bewegung */
		key = 'l';
	}
	
	if( old_mx == mx && old_my == my )	/* Maus gestoppt */
		mouse_in_move = 0;	
					
	old_mx = mx;
	old_my = my;
	first = 0;
			
	return key;
	
}


/********************************************************************/

WORD Aview_CountLines( WORD num )
{

	/*** Zahl der Zeilen ***/
	
	
	LONG i;
	WORD n;
	
	
	for( i=0, n=0; Texts[num].buf[i]; i++ )
		if( Texts[num].buf[i] == '\n' ) 
			n++;

	return n+1;
	
}


/********************************************************************/

UBYTE *Aview_GetNum( UBYTE *buf, WORD *num )
{

	/*** Text --> Zahl ***/
	
	
	for( *num = 0; *buf >= '0' && *buf <= '9'; buf++ )
		*num = *num * 10 + *buf-'0';
		
	return buf;
	
}


/********************************************************************/

UBYTE *Aview_GetNextAttr( UBYTE *buf, WORD t )
{

	/*** suche nÑchstes Attribut ***/
	
	
	if( *buf )
	{
		switch( tolower(*buf) )
		{
			case 's': 
				return( Aview_GetNum( buf+1, 
						&Texts[t].font_s ) );
			case 'c':
				return( Aview_GetNum( buf+1, 
						&Texts[t].font_c ) );
			case 'b':
				return( Aview_GetNum( buf+1, 
						&Texts[t].bg_col ) );
				
			case 't':
				return( Aview_GetNum( buf+1,
						&Texts[t].tab_w ) );			
			case 'f': 
				Texts[t].attr |= 0x01;	/* Fettschrift */
				return( buf+1 );
			case 'l':
				Texts[t].attr |= 0x02;	/* hell */
				return( buf+1 );
			case 'k':
				Texts[t].attr |= 0x04;	/* kursiv */
				return( buf+1 );
			case 'u':
				Texts[t].attr |= 0x08;	/* unterstrichen */
				return( buf+1 );
			case 'o':
				Texts[t].attr |= 0x10;	/* umrandet */
				return( buf+1 );
			case 'r':
				Return = 1;				/* sofort zurÅck */
				return( buf+1 );	
			case '#':
				if( *(buf+1) == '/' )	/* Ende */
					return 0;		
		}
		return buf+1;
	}
	
	return 0; 							/* nichts gefunden */	
	
}


/********************************************************************/

UBYTE *Aview_GetAttrLine( UBYTE *buf )
{
	
	/*** suche Attributzeile ***/
	
	
	for( ;*buf; buf++ )
		if( *buf == '/' && *(buf+1) == '#' )
			return buf+2;

	return 0;
	
}


/********************************************************************/

VOID Aview_DelAttrLine( WORD t )
{


	/*** Attribut-Definition aus dem Text entfernen ***/
	
	
	UBYTE *attr, *attr_end;
	
	
	attr = Aview_GetAttrLine( Texts[t].buf );
	for( attr_end = attr; *attr_end; attr_end++ )
	{
		if( *attr_end == '#' && *(attr_end+1) == '/' )
		{
			attr_end +=2;
			for( ;*attr_end != '\n' && *attr_end; attr_end++ ); 
			if( *attr_end == '\n' )
				strcpy( (BYTE *)attr-2, (BYTE *)attr_end+1 );
			if( *attr_end == 0 )
				*attr=0;	
			break;
		}	
	}	
			
}


/********************************************************************/

VOID Aview_SetAttr( WORD t ) 
{

	/*** Textattribute suchen und setzen ***/
	
	
	UBYTE *act_attr;
	
	
	Texts[t].font_s = DEF_FONT_SIZE;		
	Texts[t].font_c = Font_C;		
	Texts[t].attr = DEF_ATTR;
	Texts[t].tab_w = DEF_TAB_WIDTH;
	
	act_attr = Aview_GetAttrLine( Texts[t].buf );
	if( act_attr )
	{
		while( (act_attr = Aview_GetNextAttr( act_attr, t )) != 0 );
		Aview_DelAttrLine( t );		
	}

	/* aktuelle Fontmaûe ermitteln */
	vst_point( vdih, Texts[t].font_s, &Dummy, &Texts[t].font_hb, 
		&Texts[t].font_w, &Texts[t].font_h );
		
	/* Vorder/Hintergrundfarben berichtigen */
	if( Texts[t].bg_col >= Col_Num )
		Texts[t].bg_col = Texts[t].font_c ? 0 : 1;
	if( Texts[t].font_c >= Col_Num )
		Texts[t].font_c = Texts[t].bg_col ? 0 : 1;
		
}


/********************************************************************/

VOID Aview_SetCoord( WORD i, WORD t )
{

	/*** x,y,w,h setzen ***/
	
	
	if( Xmd_ParSet[i].original == XMD_SC )
	{
		Texts[t].x = Xmd_ParHead.view_x1;
		Texts[t].w = Xmd_ParHead.view_x2
						- Texts[t].x+1;
		Texts[t].y = Xmd_ParHead.view_y1;						
		Texts[t].h = Xmd_ParHead.view_y2
						- Texts[t].y+1;
	} else
	/* Parameterkoordinaten Åbernehmen */
	{
		Texts[t].x = 
			min(Xmd_ParHead.view_x1
				+ Xmd_ParSet[i].x, 
				Xmd_ParHead.view_x2);
		Texts[t].y = 
			min(Xmd_ParHead.view_y1+
				Xmd_ParSet[i].y,
				Xmd_ParHead.view_y2);
				
		if( Xmd_ParSet[i].original == XMD_OR )
		{
			Texts[t].w = min
				(DEF_WIN_WIDTH, 
				Xmd_ParHead.view_x2-Texts[t].x);
			Texts[t].h = min
				(DEF_WIN_HEIGHT,
				Xmd_ParHead.view_y2-Texts[t].y);
		} else	/* selbstdefinierte Hîhe / Breite */
		{
			Texts[t].w = min( Xmd_ParHead.view_x2
								-Texts[t].x,
								Xmd_ParSet[i].w );
			Texts[t].h = min( Xmd_ParHead.view_y2
								-Texts[t].y,
								Xmd_ParSet[i].h );
		}						
	}
	
	/* Platz fÅr Rahmen freilassen */
	Texts[t].x++;	
	Texts[t].y++; 
	Texts[t].w = max(Texts[t].w - 2, 1 );
	Texts[t].h = max(Texts[t].h - 2, 1 );
	
}

				
/********************************************************************/

WORD Aview_LoadTexts( VOID )
{

	/*** Alle (vorhandenen) Texte einladen und Anzahl zurÅckg. ***/
	
	
	WORD i, t, handle;
	static BYTE fn[256];	/* Stack schonen */
	
	
	for( i=0, t=0; i<Xmd_ParNum; i++ )
	{
		Texts[t].buf = 0;
		strcpy( fn, Xmd_ParSet[i].obj_name );
		handle = (WORD) Fopen( fn, FO_READ );
		if(  handle >= 0 )
		{
			DTA *dta;
			Fsfirst( fn, 0 );
	  		dta = Fgetdta();
			Texts[t].buf = malloc( dta->d_length+1 ); 
			if( Texts[t].buf && 
				Fread( handle, dta->d_length, Texts[t].buf ) > 0  )
			{
				Texts[t].buf[dta->d_length] = 0;
				Aview_SetCoord( i, t );	/* Position setzen */
				Aview_SetAttr( t );		/* Attribute setzen */
				Texts[t].len = dta->d_length;
				Texts[t].line = 0;
				Texts[t].win_lines 
					= ((Texts[t].h)/Texts[t].font_h );
				Texts[t].win_rows 
					= min(256, ((Texts[t].w)/Texts[t].font_w));
				Texts[t].lines = Aview_CountLines( t );	
				t++;	
			}	
		}
	}

	return t;
	
}


/********************************************************************/

WORD main( int argc, char *argv[] )
{

	/*** Initialisierung + Hauptschleife ***/
	
	
	WORD i, key;
	BYTE driver_inst = 0;
	WORD end = 0;
	WORD win[11]={0,1,1,1,1,1,1,1,1,1,2},wout[57];


	win[0]=Getrez()+2;
	vdih = 
		graf_handle( &Dummy, &Dummy, 	/* Vdi-Handle holen 		*/
					 &Dummy, &Dummy );
	
	v_opnvwk( win, &vdih, wout );
	Col_Num = wout[13];					/* Anzahl Farben			*/
	
	vqt_attributes( vdih, wout );
	Font_C = wout[1];
	vst_font( vdih, 1 );				/* System-Zeichensatz 		*/
	v_hide_c( vdih );
	psrcMFDB.fd_addr 					/* Rasterstrukturen init. 	*/		
		= pdesMFDB.fd_addr = 0;
	if (Xmod_GetPars( argc, argv ) ) 	/* Parameter einlesen		*/
		return 1;						/* keine Parameter -> Ende  */
	if( !Xmod_LoadXDriver() ) 			/* ext. Treiber inst. 		*/
		driver_inst = 1;
	Text_Num = Aview_LoadTexts();		/* max. MAX_WIN Texte laden */
	for( i=0; i<Text_Num; i++ )
		Aview_ShowText( i ); 			/* Texte anzeigen			*/
	
	if( !Return )						/* gleich zurÅck? 			*/	
	{	
		Aview_SetAct(Aview_NextText(-1));/* ersten scrollb. Text sel.*/
		do
		{	
			key = Aview_MouseIn();		/* Maus-Event empfangen 	*/
			if( driver_inst && 
				(key & XD_NO_KEY_MASK) )/* bei inst. Treiber 		*/
				key = Xmod_CallXDriver();/* --> aufrufen 			*/
			if( key == (XD_BUTTON_MASK) )/* Abbruch? 				*/
				break;
			end = Aview_Handle( key );	/* Eingabe verarbeiten 		*/	
		}
		while( !end );
	}	

	v_show_c(vdih, 1);
	v_clsvwk( vdih );

	return 0;
				
}

/********************************************************************/