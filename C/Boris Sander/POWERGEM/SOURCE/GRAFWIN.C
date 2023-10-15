/* ---------------------------------------------------------------------- */
/* Fenster: PANEL-Window mit Grafik                                       */
/* ---------------------------------------------------------------------- */
#include <stdio.h>
#include <aes.h>
#include <vdi.h>
#include "header.h"
#include "demo.h"
#include "powergem.h"

/* ---------------------------------------------------------------------- */
/* Prototypen                                                             */
/* ---------------------------------------------------------------------- */
void dec_begin(void);
void inc_begin(void);
void dec_end(void);
void inc_end(void);
void draw_grafik(struct WINDOW *win);

int winkel_a = 900, winkel_b = 0;   /* Winkel fÅr v_ellpie */

/* ---------------------------------------------------------------------- */
/* Grafikfenster initialisieren und îffnen                                */
/* ---------------------------------------------------------------------- */
void show_grafik(void)
{
	struct WINDOW *win; 
	GRECT workarea, winpos = {70, 70, 450, 300};/*Koordinaten beim ôffnen*/
	
	/* Desktop-Koordinaten ermitteln --------------------------------- */
	wind_get(0, WF_WORKXYWH, &workarea.g_x, &workarea.g_y, &workarea.g_w,
			 &workarea.g_h);
			  
	win = create_pwindow(PANEL, &workarea, &winpos, 100, 100,
						 NAME|INFO|CLOSER|MOVER|SIZER|FULLER, ALIGN_X,
						 draw_grafik, 0, draw_win_box, 0,0);
	if (win)
	{
		button_action(win, BEGDEC, dec_begin, TRUE);
		button_action(win, BEGINC, inc_begin, TRUE);
		button_action(win, ENDDEC, dec_end,   TRUE);
		button_action(win, ENDINC, inc_end,   TRUE);

		open_window(win, "Grafik im Fenster", "Grîûe der Ellipse paût sich"
				    " dem Fenster an");		
	}
}


/* Zeichenfunktion des Grafikfensters ----------------------------------- */
void draw_grafik(struct WINDOW *win)
{
	int handle;            /* VDI-Handle von PowerGEM */
	GRECT workarea;        /* Arbeitsbereich des Fensters (abzgl. PANEL!) */
	char anf[5], end[5];   /* G_TEXT-Buffer */
	OBJECT *tree;		   /* Zeiger auf Objektbaum */
	struct A_CNTRL *app_cntrl; /* Zeiger auf A_CNTRL-Struktur */
	
	app_cntrl = get_app_cntrl(); /* A_CNTRL-Struktur suchen */
	handle = get_handle();       /* VDI-Handle Åbernehmen */
	get_workarea(win, &workarea); /* Arbeitsbereich des Fensters ermitteln*/
	tree = ObjTree(win);         /* Objektbaum ermitteln */

	if (win->w_handle == app_cntrl->w_handle) /* Fenster geTOPped ? */
	{
		sprintf(anf, "%4d", winkel_a);    /* Text f. Winkelanzeige setzen */
		sprintf(end, "%4d", winkel_b);
		set_text(win, ANFWINKL, anf, 5);
		set_text(win, ENDWINKL, end, 5);
	
		/* Redraw der Winkelanzeige ---------------------------------- */
		objc_draw(win->dialog->tree, ANFWINKL, 0, tree->ob_x, tree->ob_y,
				  tree->ob_width, tree->ob_height); 
		objc_draw(win->dialog->tree, ENDWINKL, 0, tree->ob_x, tree->ob_y,
				  tree->ob_width, tree->ob_height);
	}
	
	vsf_perimeter(handle, 1);     /* VDI-Attribute setzen */
	vsf_interior(handle, 2);
	vsf_color(handle, 1);
	vsf_style(handle, 4);
	
	/* gefÅllter Ellipsenausschnitt zeichnen ---------------------------- */
	v_ellpie(handle, workarea.g_x + workarea.g_w / 2, workarea.g_y +
			 workarea.g_h / 2, workarea.g_w / 2, workarea.g_h / 2, winkel_a,
			 winkel_b);
}						   



/* Anfangswinkel dekrementieren ----------------------------------------- */
void dec_begin(void)
{
	winkel_a -= 100;
}


/* Anfangswinkel inkrementieren ----------------------------------------- */
void inc_begin(void)
{
	winkel_a += 100;
}


/* Endwinkel dekrementieren --------------------------------------------- */
void dec_end(void)
{
	winkel_b -= 100;
}


/* Endwinkel inkrementieren --------------------------------------------- */
void inc_end(void)
{
	winkel_b += 100;
}
