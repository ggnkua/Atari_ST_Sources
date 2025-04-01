/********************************************************************
 * Modul	: wind_d.c												*
 * Projekt	: Speedy												*
 * Aufgabe	: Die Fensterverwaltung fÅr das Zeichensatzdemofenster	*
 *==================================================================*
 * Autor	: Erik Dick												*
 * Datum	: 17. August 1993										*
 *------------------------------------------------------------------*
 * Computer	: Atari ST												*
 * Compiler	: Pure-C												*
 * Optionen	: -----													*
 *------------------------------------------------------------------*
 * Datum	: 24. August 1993										*
 *==================================================================*
 * Copyright: E. Dick  & Maxon Computer GMBH						*
 ********************************************************************/

#include <aes.h>
#include <stddef.h>
#include <stdlib.h>
#include <vdi.h>

#include "font.h"
#include "common.h"
#include "speedo.h"
#include "resource.h"

#define WINDKIND NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE
#define WINDNAME "Demo"

/* Das Bezierarray	*/

#define BEZ_VERTICES 4096

/* Die Grîûe einer DIN A4 Seite	*/

#define DIN_A4_W 2100
#define DIN_A4_H 2970

/* Die Positionsangaben fÅr die Demopage */

#define HEAD_MARGIN 20			/* Der linke Rand fÅr öberschriften	*/
#define HEAD_WIDTH 30			/* Die Breite der öberschriften		*/

#define OFF_TYPEFACE 5			/* Y-Offset fÅr den Fontnamen		*/
#define OFF_ID 15				/* Y-Offset fÅr den Font-ID			*/
#define OFF_TABLE 30			/* Y-Offset fÅr die Zeichentabelle	*/
#define OFF_SIZES 125			/* Y-Offset fÅr die Zeichentabelle	*/
#define OFF_DISTORT1 225			/* Y-Offset fÅr die Verzerrung		*/
#define OFF_DISTORT2 245			/* Y-Offset fÅr die Verzerrung		*/

#define DEMO_MARGIN	60			/* X-Offset fÅr die Demos			*/

/* Die Grîûenangaben fÅr die Schriftgrîûen auf der Demopage */
/* Alle Angaben in fix31-Notation							*/

#define PT_SIZE_TABLE 0x000A0000L /* 10pt	*/
#define PT_SIZE_DISTORT 0x00200000L /* 32pt	*/

#define PT_SIZE_1	0x0002BFFEL	/* 2.75pt	*/
#define PT_SIZE_2	0x00030000L	/* 3pt		*/
#define PT_SIZE_3	0x00037FFFL	/* 3.5pt	*/
#define PT_SIZE_4	0x00040000L	/* 4pt		*/
#define PT_SIZE_5	0x00050000L	/* 5pt		*/
#define PT_SIZE_6	0x00060000L	/* 6pt		*/
#define PT_SIZE_7	0x00070000L	/* 7pt		*/
#define PT_SIZE_8	0x00080000L	/* 8pt		*/
#define PT_SIZE_9	0x000A0000L	/* 10pt		*/
#define PT_SIZE_10	0x000C0000L	/* 12pt		*/
#define PT_SIZE_11	0x00100000L	/* 12pt		*/
#define PT_SIZE_12	0x00180000L	/* 24pt		*/
#define PT_SIZE_13	0x00200000L	/* 32pt		*/
#define PT_SIZE_14	0x00300000L	/* 48pt		*/

typedef struct
{
	fix31	size;
	int		color;
}T_SIZEDEMO;

/****************************** GLOBALS *****************************/

int 	FontID = -1;		/* Die FontID des aktuell im Fenster	*/
							/* dargestellten Zeichensatzes			*/
char	*FontTypeface;		/* Der Name des dargestellten Fonts		*/
int		FontHandle = -1;	/* Der Handle des Fontfensters			*/

int		V_Offset = 0;		/* Der vertikale Offset durch Slider	*/
int		H_Offset = 0;		/* Der horizontale Offset durch Slider	*/

DEV_STRUCT	Screen;			/* Die Arbeitsstationsdaten des Bild-	*/
							/* schirmes								*/

/***************************** FUNCTIONS ****************************/


/*-----------------------------------------------------------------------------*
	Name			mm2pix

	Beschreibung	Rechnet mm in pixel um.

	Parameter		int			mm				Die umzurechnenden Milimeter
					int			Scale			Pixel pro Milimeter*10

	Ergebnis		Anzahl der Pixel in den Åbergebenen Milimetern
 *-----------------------------------------------------------------------------*/

long mm2pix(int mm,int Scale)
{
	return( (mm *(long) Scale)/10 );
}

/*-----------------------------------------------------------------------------*
	Name			create_demopage

	Beschreibung	Erzeugt die Demopage

	Parameter		DEV_STRUCT	*Device			Einige Parameter der Ausgabe-
												station.

	Ergebnis
 *-----------------------------------------------------------------------------*/

void create_demopage(DEV_STRUCT *Device,int X_off,int Y_off)
{
	static T_SIZEDEMO sizedemo[] = 
		{	{PT_SIZE_1,LMAGENTA},
			{PT_SIZE_2,LYELLOW},
			{PT_SIZE_3,LCYAN},
			{PT_SIZE_4,LBLUE},
			{PT_SIZE_5,LGREEN},
			{PT_SIZE_6,LRED},
			{PT_SIZE_7,LBLACK},
			{PT_SIZE_8,MAGENTA},
			{PT_SIZE_9,YELLOW},
			{PT_SIZE_10,CYAN},
			{PT_SIZE_11,BLUE},
			{PT_SIZE_12,GREEN},
			{PT_SIZE_13,RED},
			{PT_SIZE_14,BLACK}
		};

	char	ascii[10];
	int		hor_out,vert_out,
			char_w,char_h,cell_w,cell_h,
			x_step,y_step,i,k,
			dum;

	/* Einstellungen fÅr v_bar */
	vsf_interior( Device->handle,FIS_SOLID );
	vsf_color( Device->handle,WHITE );
	vsf_perimeter( Device->handle,0 );


	vst_font(Device->handle,1);
	vst_height(Device->handle,13,&dum,&dum,&dum,&dum);

	vswr_mode(Device->handle,MD_REPLACE);
	vst_effects(Device->handle,0);
	vst_color(Device->handle,BLACK);
	vst_alignment(Device->handle,2,5,&hor_out,&vert_out);

	/****************************************
	 * Erstmal die öberschriften ausgeben	*
	 ****************************************/

	v_justified(Device->handle,
				(int) (X_off + Device->x_off+mm2pix(HEAD_MARGIN+HEAD_WIDTH,Device->x_scale)),
				(int) (Y_off + Device->y_off+mm2pix(OFF_TYPEFACE,Device->y_scale)),
				"Typeface:",
				(int) mm2pix(HEAD_WIDTH,Device->x_scale),
				0,0);

	v_justified(Device->handle,
				(int) (X_off + Device->x_off+mm2pix(HEAD_MARGIN+HEAD_WIDTH,Device->x_scale)),
				(int) (Y_off + Device->y_off+mm2pix(OFF_ID,Device->y_scale)),
				"ID:",
				(int) mm2pix(HEAD_WIDTH,Device->x_scale),
				0,0);

	v_justified(Device->handle,
				(int) (X_off + Device->x_off+mm2pix(HEAD_MARGIN+HEAD_WIDTH,Device->x_scale)),
				(int) (Y_off + Device->y_off+mm2pix(OFF_TABLE,Device->y_scale)),
				"Zeichentabelle:",
				(int) mm2pix(HEAD_WIDTH,Device->x_scale),
				0,0);

	v_justified(Device->handle,
				(int) (X_off + Device->x_off+mm2pix(HEAD_MARGIN+HEAD_WIDTH,Device->x_scale)),
				(int) (Y_off + Device->y_off+mm2pix(OFF_SIZES,Device->y_scale)),
				"Schriftgrîûen:",
				(int) mm2pix(HEAD_WIDTH,Device->x_scale),
				0,0);

	v_justified(Device->handle,
				(int) (X_off + Device->x_off+mm2pix(HEAD_MARGIN+HEAD_WIDTH,Device->x_scale)),
				(int) (Y_off + Device->y_off+mm2pix(OFF_DISTORT1,Device->y_scale)),
				"Verzerrung:",
				(int) mm2pix(HEAD_WIDTH,Device->x_scale),
				0,0);

	/****************************************
	 * Fontnamen und Font-ID ausgeben		*
	 ****************************************/

	vst_alignment(Device->handle,0,5,&hor_out,&vert_out);
	v_gtext(Device->handle,
			(int) (X_off + Device->x_off+mm2pix(DEMO_MARGIN,Device->x_scale)),
			(int) (Y_off + Device->y_off+mm2pix(OFF_TYPEFACE,Device->y_scale)),
			FontTypeface);

	v_gtext(Device->handle,
			(int) (X_off + Device->x_off+mm2pix(DEMO_MARGIN,Device->x_scale)),
			(int) (Y_off + Device->y_off+mm2pix(OFF_ID,Device->y_scale)),
			itoa(FontID,ascii,10));

	vst_font(Device->handle,FontID);

	/****************************************
	 * Die Zeichensatztabelle				*
	 ****************************************/

	my_vst_arbpt32(Device->handle,PT_SIZE_TABLE,&char_w,&char_h,&cell_w,&cell_h);
	y_step = 0;
	ascii[1] = 0;
	for(i = 0;i < 16; i++)
	{
		x_step = 0;
		for(k = 0;k < 16; k++)
		{
			ascii[0] = i*16+k;
			v_ftext(Device->handle,
					x_step + (int) (X_off + Device->x_off+mm2pix(DEMO_MARGIN,Device->x_scale)),
					y_step + (int) (Y_off + Device->y_off+mm2pix(OFF_TABLE,Device->y_scale)),
					ascii);
			x_step += (15 * cell_w)/10;
		}
		y_step += cell_h;
	}

	/****************************************
	 * Die Grîûendemo						*
	 ****************************************/

	y_step = 0;

	for(i = 0;i < sizeof(sizedemo)/sizeof(T_SIZEDEMO);i++)
	{
		vst_color(Device->handle,sizedemo[i].color);
		my_vst_arbpt32(Device->handle,sizedemo[i].size,&char_w,&char_h,&cell_w,&cell_h);
		v_ftext(Device->handle,
				(int) (X_off + Device->x_off+mm2pix(DEMO_MARGIN,Device->x_scale)),
				y_step + (int) (Y_off + Device->y_off+mm2pix(OFF_SIZES,Device->y_scale)),
				"Hello World!");
		y_step += cell_h;
	}

	/****************************************
	 * Die Verzerrungsdemo					*
	 ****************************************/

	my_vst_arbpt32(Device->handle,PT_SIZE_DISTORT,&char_w,&char_h,&cell_w,&cell_h);
	vst_skew(Device->handle,-150);
	v_ftext(Device->handle,
			(int) (X_off + Device->x_off+mm2pix(DEMO_MARGIN,Device->x_scale)),
			(int) (Y_off + Device->y_off+mm2pix(OFF_DISTORT1,Device->y_scale)),
			"Linksgeneigt");
	vst_skew(Device->handle,150);
	v_ftext(Device->handle,
			(int) (X_off + Device->x_off+mm2pix(DEMO_MARGIN,Device->x_scale)),
			(int) (Y_off + Device->y_off+mm2pix(OFF_DISTORT2,Device->y_scale)),
			"Rechtsgeneigt");
	vst_skew(Device->handle,0);
}

/*-----------------------------------------------------------------------------*
	Name			demo_window_open

	Beschreibung	ôffnet das Fenster mit einer Beispieldarstellung des Speedo-
					fonts.

	Parameter		int			font_id			Die ID des Zeichensatzes der an-
												gezeigt werden soll.
					char		*typeface		Ein Zeiger auf den Namen des
												Zeichensatzes.

	Ergebnis		Das Handle des Fensters, wenn das ôffnen geklappt hat
					0, wenn das ôffnen fehlgeschlagen ist.
 *-----------------------------------------------------------------------------*/

int demo_window_open(int font_id,char *typeface)
{
	int		WindHandle,work_out[128],
			vslide_size,
			hslide_size;

	RECT	Desktop,
			WindWork,
			WindBord;

	/* Ist das DemoFenster offen ?	*/

	if(FontHandle != -1)
	{
		/* Prima, dann muû es nur nach oben gebracht werden	*/

		wind_set(FontHandle,WF_TOP);
		wind_get(	FontHandle,WF_WORKXYWH,
					&WindWork.X,&WindWork.Y,&WindWork.W,&WindWork.H);
		if(font_id != FontID)
		{
			/*	Der anzuzeigende Font hat sich aber 
				offensichtlich	geÑndert, deswegen 
				muû ein Redraw erzwungen werden		*/

			FontID = font_id;
			FontTypeface = typeface;
			V_Offset = 0;
			H_Offset = 0;
			vslide_size = slider_calc_size(WindWork.H,Screen.y_res);
			wind_set(FontHandle,WF_VSLSIZE,vslide_size);

			hslide_size = slider_calc_size(WindWork.W,Screen.x_res);
			wind_set(FontHandle,WF_HSLSIZE,hslide_size);
		}
		form_dial(	FMD_FINISH,
					0,0,0,0,
					WindWork.X,WindWork.Y,WindWork.W,WindWork.H);
		WindHandle = FontHandle;
	}
	else
	{
		Screen.handle = ScreenVHandle;
	
		vq_extnd(ScreenVHandle,0,work_out);
		Screen.x_scale = 10000 / work_out[3];
		Screen.y_scale = 10000 / work_out[4];
	
		Screen.x_res = (int) ((DIN_A4_W * (long) Screen.x_scale)/100L);
		Screen.y_res = (int) ((DIN_A4_H * (long) Screen.y_scale)/100L);
		Screen.x_off = 0;
		Screen.y_off = 0;
	
		wind_get(	0,WF_WORKXYWH,
					&Desktop.X,&Desktop.Y,&Desktop.W,&Desktop.H);
		wind_calc(WC_WORK,WINDKIND,
					Desktop.X,Desktop.Y,Desktop.W,Desktop.H,
					&WindWork.X,&WindWork.Y,&WindWork.W,&WindWork.H);
	
		if((WindWork.W > Screen.x_res) || (WindWork.H > Screen.y_res))
		{
			WindWork.W = min(WindWork.W,Screen.x_res);
			WindWork.H = min(WindWork.H,Screen.y_res);
		}

		wind_calc(WC_BORDER,WINDKIND,
					WindWork.X,WindWork.Y,WindWork.W,WindWork.H,
					&WindBord.X,&WindBord.Y,&WindBord.W,&WindBord.H);
		WindHandle = 
			wind_create(WINDKIND,
						WindBord.X,WindBord.Y,WindBord.W,WindBord.H);
	
		if (WindHandle > 0)
		{
			WindWork.X += CharW*2;
			WindWork.Y += CharH*2;
			wind_calc(WC_BORDER,
						WINDKIND,
						WindWork.X,WindWork.Y,WindWork.W,WindWork.H,
						&WindBord.X,&WindBord.Y,&WindBord.W,&WindBord.H);
	
			wind_open(WindHandle,
						WindBord.X,WindBord.Y,WindBord.W,WindBord.H);
			wind_set(WindHandle,WF_NAME,WINDNAME);
			FontID = font_id;
			FontTypeface = typeface;
			FontHandle = WindHandle;
			V_Offset = 0;
			H_Offset = 0;

			vslide_size = slider_calc_size(WindWork.H,Screen.y_res);
			wind_set(WindHandle,WF_VSLSIZE,vslide_size);

			hslide_size = slider_calc_size(WindWork.W,Screen.x_res);
			wind_set(WindHandle,WF_HSLSIZE,hslide_size);
		}
		TREE[R_MENU][R_E_PRINT].ob_state &= ~DISABLED;
	}
	return(WindHandle);
}

/*-----------------------------------------------------------------------------*
	Name			demo_window_redraw

	Beschreibung	Zeichnet den Inhalt des Fensters mit den Fontnamen neu.

	Parameter		int			Handle		Der Fensterhandle
					int			x,y,w,h		Die Koordinaten des Rechecks inner-
											halb dessen, neugezeichnet werden
											soll.

	Ergebnis
 *-----------------------------------------------------------------------------*/

void demo_window_redraw(int Handle,int x,int y,int w,int h)
{
	int		pxy[8],
			dummy;
	RECT	CompleteArea,SmallArea,Window;

	CompleteArea.X	= x;
	CompleteArea.Y	= y;
	CompleteArea.W	= w;
	CompleteArea.H	= h;

	wind_update(BEG_UPDATE);
	v_hide_c(ScreenVHandle);

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
			Clip( ScreenVHandle,&SmallArea,TRUE );

			/* Den Hintergrund weiû malen	*/

			pxy[0] = SmallArea.X;
			pxy[1] = SmallArea.Y;
			pxy[2] = SmallArea.X+SmallArea.W-1;
			pxy[3] = SmallArea.Y+SmallArea.H-1;
			v_bar(ScreenVHandle,pxy);

			/****************************/
			/* Das Demoblatt ausgeben	*/
			/****************************/

			create_demopage(&Screen,Window.X-H_Offset,Window.Y-V_Offset);

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
	Name			demo_window_move

	Beschreibung	Setzt die neue Position des Fensters

	Parameter		EVNT	*evnt_struct	Die den Event beschreibenden Daten

	Ergebnis
 *-----------------------------------------------------------------------------*/

void demo_window_move(EVENT *evnt_struct)
{
	wind_set(evnt_struct->ev_mmgpbuf[3],WF_CURRXYWH,
				evnt_struct->ev_mmgpbuf[4],
				evnt_struct->ev_mmgpbuf[5],
				evnt_struct->ev_mmgpbuf[6],
				evnt_struct->ev_mmgpbuf[7]);
}

/*-----------------------------------------------------------------------------*
	Name			demo_window_size

	Beschreibung	Reagiert auf die GrîûenÑnderungen des Fensters

	Parameter		EVNT	*evnt_struct	Die den Event beschreibenden Daten

	Ergebnis
 *-----------------------------------------------------------------------------*/

void demo_window_size(EVENT *evnt_struct)
{
	int		vslide_size,hslide_size;
	int		handle = evnt_struct->ev_mmgpbuf[3];
	RECT	work;

	wind_calc(WC_WORK,WINDKIND,
				evnt_struct->ev_mmgpbuf[4],
				evnt_struct->ev_mmgpbuf[5],
				evnt_struct->ev_mmgpbuf[6],
				evnt_struct->ev_mmgpbuf[7],
				&work.X,&work.Y,
				&work.W,&work.H);

	if((work.W > Screen.x_res) || (work.H > Screen.y_res))
	{
		work.W = min(work.W,Screen.x_res);
		work.H = min(work.H,Screen.y_res);
		wind_calc(WC_BORDER,WINDKIND,
					work.X,work.Y,
					work.W,work.H,
					&evnt_struct->ev_mmgpbuf[4],
					&evnt_struct->ev_mmgpbuf[5],
					&evnt_struct->ev_mmgpbuf[6],
					&evnt_struct->ev_mmgpbuf[7]);
	}

	H_Offset = max(0,min(H_Offset,Screen.x_res-work.W));
	V_Offset = max(0,min(V_Offset,Screen.y_res-work.H));

	vslide_size = slider_calc_size(work.H,Screen.y_res);
	wind_set(handle,WF_VSLSIZE,vslide_size);
	wind_set(	handle,
				WF_VSLIDE,
				slider_calc_pos(work.H,Screen.y_res,(long) V_Offset));

	hslide_size = slider_calc_size(work.W,Screen.x_res);
	wind_set(handle,WF_HSLSIZE,hslide_size);
	wind_set(	handle,
				WF_HSLIDE,
				slider_calc_pos(work.W,Screen.x_res,(long) H_Offset));

	demo_window_move(evnt_struct);
}


/*-----------------------------------------------------------------------------*
	Name			demo_window_full

	Beschreibung	Setzt das Fenster auf die maximale Grîûe

	Parameter		EVNT	*evnt_struct	Die den Event beschreibenden Daten

	Ergebnis
 *-----------------------------------------------------------------------------*/

void demo_window_full(EVENT *evnt_struct)
{
	RECT	full;

	wind_get(evnt_struct->ev_mmgpbuf[3],WF_FULLXYWH,
				&full.X,&full.Y,&full.W,&full.H);

	evnt_struct->ev_mmgpbuf[4] = full.X;
	evnt_struct->ev_mmgpbuf[5] = full.Y;
	evnt_struct->ev_mmgpbuf[6] = full.W;
	evnt_struct->ev_mmgpbuf[7] = full.H;

	demo_window_size(evnt_struct);
}

/*-----------------------------------------------------------------------------*
	Name			demo_window_arrowed

	Beschreibung	Die Slider sollen sich in irgendeine Richtung bewegen.

	Parameter		EVENT	*evnt_struct	Die Daten des aufgetretenen Events
					
	Ergebnis
 *-----------------------------------------------------------------------------*/

void demo_window_arrowed(EVENT *evnt_struct)
{
	int		handle,
			v_oldpos,h_oldpos,
			v_newpos,h_newpos;
	RECT	window;

	handle = evnt_struct->ev_mmgpbuf[3];

	wind_get(handle,WF_WORKXYWH,&window.X,&window.Y,&window.W,&window.H);
	wind_get(handle,WF_VSLIDE,&v_oldpos);
	wind_get(handle,WF_HSLIDE,&h_oldpos);

	switch(evnt_struct->ev_mmgpbuf[4])
	{
		/* Der vertikale Slider	*/
	
		case WA_UPPAGE: V_Offset = max(0,V_Offset - window.H);
						break;
		case WA_DNPAGE:	V_Offset = min(	Screen.y_res-window.H,
										V_Offset + window.H);
						break;
		case WA_UPLINE:	V_Offset = max(0,V_Offset - CharH);
						break;
		case WA_DNLINE: V_Offset = min(	Screen.y_res-window.H,
										V_Offset + CharH);
						break;

		/* Der horizontale Slider	*/
	
		case WA_LFPAGE: H_Offset = max(0,H_Offset - window.W);
						break;
		case WA_RTPAGE:	H_Offset = min(	Screen.x_res-window.W,
										H_Offset + window.W);
						break;
		case WA_LFLINE:	H_Offset = max(0,H_Offset - CharW);
						break;
		case WA_RTLINE: H_Offset = min(	Screen.x_res-window.W,
										H_Offset + CharW);
						break;
	}

	/* Es muû also etwas neugezeichnet werden	*/

	v_newpos = slider_calc_pos(	window.H,
								Screen.y_res,
								V_Offset);
	h_newpos = slider_calc_pos(	window.W,
								Screen.x_res,
								H_Offset);
	if(v_newpos != v_oldpos || h_newpos != h_oldpos)
	{
		demo_window_redraw(handle,window.X,window.Y,window.W,window.H);

		wind_set(handle,WF_VSLIDE,v_newpos);
		wind_set(handle,WF_HSLIDE,h_newpos);

	}
}

/*-----------------------------------------------------------------------------*
	Name			demo_window_vslid

	Beschreibung	Bewegt den vertikalen Slider.

	Parameter		EVENT	*evnt_struct	Die Daten des aufgetretenen Events
					
	Ergebnis
 *-----------------------------------------------------------------------------*/

void demo_window_vslid(EVENT *evnt_struct)
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

		V_Offset = (int)slider_get_pos(	workarea.H,
										Screen.y_res,
										slider_new_pos);

		wind_set(handle,WF_VSLIDE,slider_new_pos);

		demo_window_redraw(	handle,
							workarea.X,workarea.Y,
							workarea.W,workarea.H);
	}
}

/*-----------------------------------------------------------------------------*
	Name			demo_window_hslid

	Beschreibung	Bewegt den horizontalen Slider.

	Parameter		EVENT	*evnt_struct	Die Daten des aufgetretenen Events
					
	Ergebnis
 *-----------------------------------------------------------------------------*/

void demo_window_hslid(EVENT *evnt_struct)
{
	int		handle,
			slider_size,
			slider_old_pos,slider_new_pos;
	RECT	workarea;

	handle = evnt_struct->ev_mmgpbuf[3];
	wind_get(handle,WF_HSLSIZE,&slider_size);
	wind_get(handle,WF_HSLIDE,&slider_old_pos);
	slider_new_pos = evnt_struct->ev_mmgpbuf[4];

	if((slider_size < 1000) && (slider_new_pos != slider_old_pos))
	{
		wind_get(	handle,WF_WORKXYWH,
					&workarea.X,&workarea.Y,
					&workarea.W,&workarea.H);

		/* Die Sliderposition ermitteln	*/

		H_Offset = (int)slider_get_pos(	workarea.W,
										Screen.x_res,
										slider_new_pos);

		wind_set(handle,WF_HSLIDE,slider_new_pos);

		demo_window_redraw(	handle,
							workarea.X,workarea.Y,
							workarea.W,workarea.H);
	}
}

/*-----------------------------------------------------------------------------*
	Name			demo_window

	Beschreibung	Einsprungspunkt fÅr AES-Nachrichten ans Fenster

	Parameter		EVENT		*evnt		Zeiger auf den Puffer mit der Zu-
											standsbeschreibung des EVENT

	Ergebnis
 *-----------------------------------------------------------------------------*/

void demo_window(EVENT *Evnt)
{
	switch(Evnt->ev_mmgpbuf[0])
	{
		case WM_REDRAW:
			demo_window_redraw(	Evnt->ev_mmgpbuf[3],
								Evnt->ev_mmgpbuf[4],Evnt->ev_mmgpbuf[5],
								Evnt->ev_mmgpbuf[6],Evnt->ev_mmgpbuf[7]);
			break;
		case WM_TOPPED:
			wind_set(Evnt->ev_mmgpbuf[3],WF_TOP);
			break;
		case WM_CLOSED:
			FontID = -1;
			if(FontHandle == Evnt->ev_mmgpbuf[3])
			{
				wind_close(FontHandle);
				wind_delete(FontHandle);
				FontHandle = -1;
				TREE[R_MENU][R_E_PRINT].ob_state |= DISABLED;
			}
			break;
		case WM_FULLED:
			demo_window_full(Evnt);
			break;
		case WM_ARROWED:
			demo_window_arrowed(Evnt);
			break;
		case WM_HSLID:
			demo_window_hslid(Evnt);
			break;
		case WM_VSLID:
			demo_window_vslid(Evnt);
			break;
		case WM_SIZED:
			demo_window_size(Evnt);
			break;
		case WM_MOVED:
			demo_window_move(Evnt);
			break;
	}
}

/*-----------------------------------------------------------------------------*
	Name			handle_print

	Beschreibung	Startdialog zum Drucken
 *-----------------------------------------------------------------------------*/

void handle_print(void)
{
	int	x,y,w,h,
		exit,
		ende = FALSE,
		button;
	int	WorkIn[128] = {1,1,1,1,1,1,1,1,1,1,2},
		WorkOut[57];
	DEV_STRUCT	printer;
	RECT		clip_area;


	form_center(TREE[R_PRINT],&x,&y,&w,&h);
	form_dial(FMD_START,0,0,0,0,x,y,w,h);
	objc_draw(TREE[R_PRINT],ROOT,MAX_DEPTH,x,y,w,h);
	exit = form_do(TREE[R_PRINT],ROOT);
	TREE[R_PROGINFO][exit & 0x7FFF].ob_state &= ~SELECTED;
	if((exit & 0x7FFF) == R_PRINT_START)
	{
		WorkIn[0] = printer.handle = 21;
		do
		{
			v_opnwk(WorkIn,&printer.handle,WorkOut);
			if( printer.handle == 0 )
			{
				button = form_alert(1,"[1][Der Druckertreiber lÑût|sich nicht îffnen][Nochmal|Abbruch]");
				switch(button)
				{
					case 1: ende = FALSE;
							break;
					case 2: ende = TRUE;
							break;
				}
			}
			else
			{
				printer.x_scale = 10000 / WorkOut[3];
				printer.y_scale = 10000 / WorkOut[4];
			
				printer.x_res = WorkOut[0];
				printer.y_res = WorkOut[1];
				printer.x_off = (printer.x_res - (int) ((DIN_A4_W * (long) printer.x_scale)/100L))/2;
				printer.y_off = (printer.y_res - (int) ((DIN_A4_H * (long) printer.y_scale)/100L))/2;

				clip_area.X = 0;
				clip_area.Y = 0;
				clip_area.W = printer.x_res;
				clip_area.H = printer.y_res;

				Clip(printer.handle,&clip_area,1);
				vst_load_fonts(printer.handle,0);
				create_demopage(&printer,0,0);
				v_updwk(printer.handle);
				v_clrwk(printer.handle);
				Clip(printer.handle,&clip_area,0);

				vst_unload_fonts(printer.handle,0);
				v_clswk(printer.handle);

				ende = TRUE;
			}
		}while(!ende);
	}
	form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
}

/********************************************************************************
 *							E N D - O F - F I L E								*
 ********************************************************************************/
