/*********************************************/
/*   MODUL : RUBBER.C                        */
/* AUFGABE : Verbesserte Rubberbox-Routine   */
/*   AUTOR : Markus Hîvener                  */
/*           (C) MAXON Computer GmbH         */
/*********************************************/


# include <aes.h>
# include <portab.h>
# include <vdi.h>

# include "rubber.h"


#define FALSE  0
#define TRUE   !FALSE


#define Min(a,b) ((a < b) ?  a : b )
#define Max(a,b) ((a > b) ?  a : b )



/*********************************************/
/* Verwaltet die Rubberbox                   */
/*********************************************/
WORD DoRubberbox( WORD  v_handle,
                  WORD  start_x, WORD start_y,
                  GRECT *rect,
                  WORD  *res_width, WORD *res_height,
                  VOID  (*call_func)(WORD *new_rect) )
{
	WORD  events,       /* Eventtyp      */
	      m_x, m_y,     /* Mausposition  */
	      rect_xy[4],   /* Umrandung     */
	      pxy[4],       /* Die Box       */
	      spec_state,   /* Sondertasten  */
	      max_1, max_2, /* FÅr SHIFT...  */
	      dif,          /* dito          */
	      _void;        /* Unwichtiges   */


	/* 'rect' umrechnen */
	rect_xy[0] = rect->g_x;
	rect_xy[1] = rect->g_y;
	rect_xy[2] = rect->g_x + rect->g_w - 1;
	rect_xy[3] = rect->g_y + rect->g_h - 1;

	/* Maus nicht im Rechteck ?? */
	if( (start_x < rect_xy[0]) ||
	    (start_x > rect_xy[2]) ||
	    (start_y < rect_xy[1]) ||
	    (start_y > rect_xy[3]) )
		return( FALSE );
		
		
	pxy[0] = start_x;
	pxy[1] = start_y;
	
	
	/* Werte fÅr SHIFT-Benutzung */
	max_1 = Min( start_x - rect_xy[0], start_y - rect_xy[1] );
	max_2 = Min( rect_xy[2] - start_x, rect_xy[3] - start_y );

	

	/* Grafikmodi setzen */
	vswr_mode( v_handle, MD_XOR );
	vsl_type( v_handle, 7 );
	vsl_color( v_handle, 1 );
	vsl_width( v_handle, 1 );

	
	/* Maus als Zeiger */
	graf_mouse( POINT_HAND, 0L );
	
	wind_update( BEG_UPDATE );
	wind_update( BEG_MCTRL );
	
	
	/* Mauskoordinaten */
	graf_mkstate( &m_x, &m_y, &spec_state, &_void );
	
	
	do
	{
		/* Neue Koordinaten */
		pxy[2] = Max( m_x, rect_xy[0] );
		pxy[2] = Min( pxy[2], rect_xy[2] );
		
		pxy[3] = Max( m_y, rect_xy[1] );
		pxy[3] = Min( pxy[3], rect_xy[3] );

		
		/*******************/
		/* SHIFT gedrÅckt  */
		/*******************/
		if( spec_state & (K_LSHIFT | K_RSHIFT) )
		{
			/* Abstand errechnen */
			dif = pxy[2] - pxy[0];
			
			/* EinschrÑnken */
			dif = (dif > 0) ? Min( dif, max_2 )
			                : Max( dif, -max_1 );
			                
			/* Neue Koordinaten */
			pxy[2] = pxy[0] + dif;
			pxy[3] = pxy[1] + dif;
		}
		

		/* Rahmen zeichnen lassen */
		DrawBox( v_handle, pxy[0], pxy[1], pxy[2], pxy[3] );
		
		/* Eigene Funktion aufrufen */
		if( call_func )
			call_func( pxy );
			
			
		/*************/
		/* Event     */
		/*************/
		events = evnt_multi( /* Maus- und Rechteckevents */
		                     MU_BUTTON|MU_M1,
		                     /* Mausklick */
		                     1, 1, 0,
		                     /* Das Rechteck */
		                     1, m_x, m_y, 1, 1,
		                     0, 0, 0, 0, 0,
		                     /* Message-Buffer */
		                     0L,
		                     /* Kein Timer */
		                     0, 0,
		                     /* Endparameter */
		                     &m_x,        &m_y,   &_void,
		                     &spec_state, &_void, &_void );

		/* Wieder drÅber malen */
		DrawBox( v_handle, pxy[0], pxy[1], pxy[2], pxy[3] );
	}
	while( !(events & MU_BUTTON ) );


	wind_update( END_MCTRL );
	wind_update( END_UPDATE );

	graf_mouse( ARROW, 0L );

	/* Ergebnis eintragen */
	*res_width  = pxy[2] - pxy[0];
	*res_height = pxy[3] - pxy[1];

	return( TRUE );
}



/*********************************************/
/* Malt die Rubberbox                        */
/*********************************************/
VOID DrawBox( WORD v_handle, WORD x1, WORD y1, WORD x2, WORD y2 )
{
	WORD xy[4];
      

	graf_mouse( M_OFF, 0L );


	xy[0] = xy[2] = x1;
	xy[1] = y1;
	xy[3] = y2;
	vsl_udsty( v_handle, (xy[0] % 2) == (xy[1] % 2)
	                     ? 21845
	                     : (WORD)43690L );
	v_pline ( v_handle, 2, xy );


	xy[0] = xy[2] = x2;
	vsl_udsty( v_handle, (xy[0] % 2) == (xy[1] % 2)
	                     ? 21845 : (WORD)43690L );
	v_pline ( v_handle, 2, xy );


	xy[0] = x1;
	xy[2] = x2;
	xy[1] = xy[3] = y1;
	vsl_udsty( v_handle, (xy[1] % 2)
	                     ? (WORD)43690L : 21845 );
	v_pline ( v_handle, 2, xy );


	xy[1] = xy[3] = y2;
	vsl_udsty( v_handle, (xy[1] % 2)
	                     ? (WORD)43690L : 21845 );
	v_pline ( v_handle, 2, xy );


	graf_mouse( M_ON, 0L );
}