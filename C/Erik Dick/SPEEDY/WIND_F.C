/********************************************************************
 * Modul	: wind_f.c												*
 * Projekt	: Speedy												*
 * Aufgabe	: Die Fensterverwaltung fÅr das Fontlistenfenster		*
 *==================================================================*
 * Autor	: Erik Dick												*
 * Datum	: 17. August 1993										*
 *------------------------------------------------------------------*
 * Computer	: Atari ST												*
 * Compiler	: Pure-C												*
 * Optionen	: -----													*
 *------------------------------------------------------------------*
 * Datum	: 17. August 1993										*
 *==================================================================*
 * Copyright: E. Dick  & Maxon Computer GMBH						*
 ********************************************************************/

#include <aes.h>
#include <stddef.h>
#include <vdi.h>

#include "font.h"
#include "common.h"

#define WINDKIND NAME|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE
#define WINDNAME "Fontliste"

/****************************** GLOBALS *****************************/

extern
FONTLIST	Fonts;				/* Externe Zeichensatzliste			*/
int			Offset = 0;			/* Der vertikale Offset durch Slider*/

/***************************** FUNCTIONS ****************************/

/*-----------------------------------------------------------------------------*
	Name			font_window_open

	Beschreibung	ôffnet das Fenster mit den Fontnamen

	Parameter

	Ergebnis		Das Handle des Fensters, wenn das ôffnen geklappt hat
					0, wenn das ôffnen fehlgeschlagen ist.
 *-----------------------------------------------------------------------------*/

int font_window_open(void)
{
	int		WindHandle,vslide_size;
	RECT	Desktop,
			WindWork,
			WindBord;

	wind_get(	0,WF_WORKXYWH,
				&Desktop.X,&Desktop.Y,&Desktop.W,&Desktop.H);
	wind_calc(WC_WORK,WINDKIND,
				Desktop.X,Desktop.Y,Desktop.W,Desktop.H,
				&WindWork.X,&WindWork.Y,&WindWork.W,&WindWork.H);

	wind_calc(WC_BORDER,WINDKIND,
				WindWork.X,WindWork.Y,WindWork.W,WindWork.H,
				&WindBord.X,&WindBord.Y,&WindBord.W,&WindBord.H);
	WindHandle = 
		wind_create(WINDKIND,
					WindBord.X,WindBord.Y,WindBord.W,WindBord.H);

	if (WindHandle > 0)
	{
		set_system_font(ScreenVHandle);
		WindWork.X += CharW;
		WindWork.Y += CharH;
		WindWork.W = min(WindWork.W,GDOS_TYPEFACE_LEN * CellW);
		WindWork.H -= 2 * CellH;
		WindWork.H = (WindWork.H/CellH) * CellH;
		wind_calc(WC_BORDER,
					WINDKIND,
					WindWork.X,WindWork.Y,WindWork.W,WindWork.H,
					&WindBord.X,&WindBord.Y,&WindBord.W,&WindBord.H);

		wind_open(WindHandle,
					WindBord.X,WindBord.Y,WindBord.W,WindBord.H);
		wind_set(WindHandle,WF_NAME,WINDNAME);

		vslide_size = slider_calc_size(	WindWork.H/CellH,
										count_fonts(Fonts));
		wind_set(WindHandle,WF_VSLSIZE,vslide_size);
	}

	return(WindHandle);
}

/*-----------------------------------------------------------------------------*
	Name			font_window_redraw

	Beschreibung	Zeichnet den Inhalt des Fensters mit den Fontnamen neu.

	Parameter		int			Handle		Der Fensterhandle
					int			x,y,w,h		Die Koordinaten des Rechecks inner-
											halb dessen, neugezeichnet werden
											soll.

	Ergebnis
 *-----------------------------------------------------------------------------*/

void font_window_redraw(int Handle,int x,int y,int w,int h)
{
	int		Index,pxy[8],
			lines,
			i,dummy;
	RECT	CompleteArea,SmallArea,Window;
	FONT	*current;


	CompleteArea.X	= x;
	CompleteArea.Y	= y;
	CompleteArea.W	= w;
	CompleteArea.H	= h;


	wind_update(BEG_UPDATE);
	v_hide_c(ScreenVHandle);

	/* Einstellungen fÅr v_bar */
	vsf_interior( ScreenVHandle,FIS_SOLID );
	vsf_color( ScreenVHandle,WHITE );
	vsf_perimeter( ScreenVHandle,0 );

	/* Einstellungen fÅr v_gtext */
	set_system_font(ScreenVHandle);
	vst_alignment(ScreenVHandle,0,5,&dummy,&dummy);

	wind_get( Handle,
				WF_WORKXYWH,
				&Window.X,&Window.Y,
				&Window.W, &Window.H );
	wind_get( Handle,
				WF_FIRSTXYWH,	
				&SmallArea.X,&SmallArea.Y,
				&SmallArea.W, &SmallArea.H );


	while ( SmallArea.W && SmallArea.H )
	{
		if ( Intersect(&CompleteArea,&SmallArea) == TRUE )
		{
			Index = Offset;

			Clip( ScreenVHandle,&SmallArea,TRUE );

			pxy[0] = SmallArea.X;
			pxy[1] = SmallArea.Y;
			pxy[2] = SmallArea.X+SmallArea.W-1;
			pxy[3] = SmallArea.Y+SmallArea.H-1;
			v_bar(ScreenVHandle,pxy);

			/* Die einzelnen EintrÑge der Liste ausgeben	*/

			current = get_font(Fonts,Index);
			lines = Window.H / CellH;
			for(i = 0; i < lines; i++)
			{
				if(current != NULL)
				{
					v_gtext(	ScreenVHandle,
								Window.X,
								Window.Y+i*CellH,
								current->typeface);
					current = current->next;
				}
			}

			Clip( ScreenVHandle,&SmallArea, FALSE );
		}
		wind_get(	Handle,
						WF_NEXTXYWH,
						&SmallArea.X,&SmallArea.Y,
						&SmallArea.W,&SmallArea.H );
	}

	vst_alignment(ScreenVHandle,0,0,&dummy,&dummy);
	vswr_mode(ScreenVHandle,MD_REPLACE);

	v_show_c(ScreenVHandle,0);
	wind_update(END_UPDATE);
}

/*-----------------------------------------------------------------------------*
	Name			font_window_move

	Beschreibung	Setzt die neue Position des Fensters

	Parameter		EVNT	*evnt_struct	Die den Event beschreibenden Daten

	Ergebnis
 *-----------------------------------------------------------------------------*/

void font_window_move(EVENT *evnt_struct)
{
	wind_set(evnt_struct->ev_mmgpbuf[3],WF_CURRXYWH,
				evnt_struct->ev_mmgpbuf[4],
				evnt_struct->ev_mmgpbuf[5],
				evnt_struct->ev_mmgpbuf[6],
				evnt_struct->ev_mmgpbuf[7]);
}

/*-----------------------------------------------------------------------------*
	Name			font_window_size

	Beschreibung	Setzt die neue Position des Fensters

	Parameter		EVNT	*evnt_struct	Die den Event beschreibenden Daten

	Ergebnis
 *-----------------------------------------------------------------------------*/

void font_window_size(EVENT *evnt_struct)
{
	int		vslide_size,lines;
	int		handle = evnt_struct->ev_mmgpbuf[3];
	RECT	desktop,work,max;

	wind_calc(WC_WORK,WINDKIND,
				evnt_struct->ev_mmgpbuf[4],
				evnt_struct->ev_mmgpbuf[5],
				evnt_struct->ev_mmgpbuf[6],
				evnt_struct->ev_mmgpbuf[7],
				&work.X,&work.Y,
				&work.W,&work.H);

	wind_get(	0,WF_WORKXYWH,
				&desktop.X,&desktop.Y,&desktop.W,&desktop.H);
	wind_calc(WC_WORK,WINDKIND,
				desktop.X,desktop.Y,desktop.W,desktop.H,
				&max.X,&max.Y,&max.W,&max.H);

	work.W = min(max.W,GDOS_TYPEFACE_LEN * CellW);
	work.H = (work.H/CellH) * CellH;
	wind_calc(WC_BORDER,WINDKIND,
				work.X,work.Y,
				work.W,work.H,
				&evnt_struct->ev_mmgpbuf[4],
				&evnt_struct->ev_mmgpbuf[5],
				&evnt_struct->ev_mmgpbuf[6],
				&evnt_struct->ev_mmgpbuf[7]);

	lines = work.H/CellH;
	Offset = max(0,min(Offset,(int)count_fonts(Fonts)-lines));

	vslide_size = slider_calc_size(lines,count_fonts(Fonts));
	wind_set(handle,WF_VSLSIZE,vslide_size);
	wind_set(	handle,
				WF_VSLIDE,
				slider_calc_pos(lines,
								count_fonts(Fonts),
								(long) Offset));

	font_window_move(evnt_struct);
}

/*-----------------------------------------------------------------------------*
	Name			font_window_full

	Beschreibung	Setzt das Fenster auf die maximale Grîûe

	Parameter		EVNT	*evnt_struct	Die den Event beschreibenden Daten

	Ergebnis
 *-----------------------------------------------------------------------------*/

void font_window_full(EVENT *evnt_struct)
{
	RECT	full;

	wind_get(evnt_struct->ev_mmgpbuf[3],WF_FULLXYWH,
				&full.X,&full.Y,&full.W,&full.H);

	evnt_struct->ev_mmgpbuf[4] = full.X;
	evnt_struct->ev_mmgpbuf[5] = full.Y;
	evnt_struct->ev_mmgpbuf[6] = full.W;
	evnt_struct->ev_mmgpbuf[7] = full.H;

	font_window_size(evnt_struct);
}

/*-----------------------------------------------------------------------------*
	Name			font_window_arrowed

	Beschreibung	Die Slider sollen sich in irgendeine Richtung bewegen.

	Parameter		EVENT	*evnt_struct	Die Daten des aufgetretenen Events
					
	Ergebnis
 *-----------------------------------------------------------------------------*/

void font_window_arrowed(EVENT *evnt_struct)
{
	int		handle,
			v_oldpos,v_newpos,
			lines,
			number_of_fonts;
	RECT	window;

	handle = evnt_struct->ev_mmgpbuf[3];

	wind_get(handle,WF_WORKXYWH,&window.X,&window.Y,&window.W,&window.H);
	wind_get(handle,WF_VSLIDE,&v_oldpos);

	lines = window.H / CellH;
	number_of_fonts = (int) count_fonts(Fonts);

	switch(evnt_struct->ev_mmgpbuf[4])
	{
		/* Der vertikale Slider	*/
	
		case WA_UPPAGE: Offset = max(0,Offset - lines);
						break;
		case WA_DNPAGE:	Offset = min(	number_of_fonts-lines,
										Offset + 1);
						break;
		case WA_UPLINE:	Offset = max(0,--Offset);
						break;
		case WA_DNLINE: Offset = min(	number_of_fonts-lines,
										Offset + 1);
						break;
	}

	/* Es muû also etwas neugezeichnet werden	*/

	v_newpos = slider_calc_pos(	lines,
								number_of_fonts,
								Offset);

	if(v_newpos != v_oldpos)
	{
		font_window_redraw(handle,window.X,window.Y,window.W,window.H);

		wind_set(handle,WF_VSLIDE,v_newpos);

	}
}

/*-----------------------------------------------------------------------------*
	Name			font_window_vslid

	Beschreibung	Bewegt den vertikalen Slider.

	Parameter		EVENT	*evnt_struct	Die Daten des aufgetretenen Events
					
	Ergebnis
 *-----------------------------------------------------------------------------*/

void font_window_vslid(EVENT *evnt_struct)
{
	int		handle,
			slider_size,
			slider_old_pos,slider_new_pos;
	RECT	workarea;

	handle = evnt_struct->ev_mmgpbuf[3];
	wind_get(handle,WF_VSLSIZE,&slider_size);
	wind_get(handle,WF_VSLIDE,&slider_old_pos);
	slider_new_pos = evnt_struct->ev_mmgpbuf[4];

	if((slider_size < 1000) && (slider_new_pos != slider_old_pos))
	{
		wind_get(	handle,WF_WORKXYWH,
					&workarea.X,&workarea.Y,
					&workarea.W,&workarea.H);

		/* Die Sliderposition ermitteln	*/

		Offset = (int)slider_get_pos(	workarea.H/CellH,
										count_fonts(Fonts),
										slider_new_pos);

		wind_set(handle,WF_VSLIDE,slider_new_pos);

		font_window_redraw(	handle,
							workarea.X,workarea.Y,
							workarea.W,workarea.H);
	}
}

/*-----------------------------------------------------------------------------*
	Name			font_window

	Beschreibung	Einsprungspunkt fÅr AES-Nachrichten ans Fenster

	Parameter		EVENT		*Evnt		Zeiger auf den Puffer mit der Zu-
											standsbeschreibung des EVENT

	Ergebnis
 *-----------------------------------------------------------------------------*/

void font_window(EVENT *Evnt)
{
	switch(Evnt->ev_mmgpbuf[0])
	{
		case WM_REDRAW:
			font_window_redraw(	Evnt->ev_mmgpbuf[3],
								Evnt->ev_mmgpbuf[4],
								Evnt->ev_mmgpbuf[5],
								Evnt->ev_mmgpbuf[6],
								Evnt->ev_mmgpbuf[7]);
			break;
		case WM_TOPPED:
			wind_set(Evnt->ev_mmgpbuf[3],WF_TOP);
			break;
		case WM_CLOSED:
			wind_close(Evnt->ev_mmgpbuf[3]);
			wind_delete(Evnt->ev_mmgpbuf[3]);
			break;
		case WM_FULLED:
			font_window_full(Evnt);
			break;
		case WM_ARROWED:
			font_window_arrowed(Evnt);
			break;
		case WM_VSLID:
			font_window_vslid(Evnt);
			break;
		case WM_SIZED:
			font_window_size(Evnt);
			break;
		case WM_MOVED:
			font_window_move(Evnt);
			break;
	}
}

/*-----------------------------------------------------------------------------*
	Name			font_window_click

	Beschreibung	Liefert den Index des angeklickten Zeichensatzes in der
					Liste.

	Parameter		int			*Handle		Handle des Fensters
					int			mouse_x,
								mouse_y		Die Koordinaten der Maus

	Ergebnis
 *-----------------------------------------------------------------------------*/

int font_window_click(int Handle, int mouse_x, int mouse_y)
{
	int		found = FALSE,
			index = -1;
	RECT	SmallArea,work;

	wind_get( Handle,
				WF_FIRSTXYWH,	
				&SmallArea.X,&SmallArea.Y,
				&SmallArea.W, &SmallArea.H );
	while ( SmallArea.W && SmallArea.H )
	{
		found |= isinrect(mouse_x,mouse_y,&SmallArea);
		wind_get(	Handle,
					WF_NEXTXYWH,
					&SmallArea.X,&SmallArea.Y,
					&SmallArea.W,&SmallArea.H );
	}
	if(found)
	{
		wind_get( Handle,WF_WORKXYWH,	
					&work.X,&work.Y,
					&work.W,&work.H );
		index = Offset+((mouse_y-work.Y)/CellH);
	}
	return( index );
}

/********************************************************************************
 *							E N D - O F - F I L E								*
 ********************************************************************************/
