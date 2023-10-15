/* ---------------------------------------------------------------------- */
/* Fenster: Text mit Slider                                               */
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
void draw_text(struct WINDOW *win);
void gputc(int x, int y, char c);

#define ZEILEN  50
#define SPALTEN 57

char liste[ZEILEN * SPALTEN];   /* Buffer fr Text */ 
int gl_wchar, gl_hchar;         /* Zeichenausmaže  */

/* ---------------------------------------------------------------------- */
/* Text-Buffer fllen                                                     */
/* ---------------------------------------------------------------------- */
void init_text(void)
{ 
	register int i;
	struct A_CNTRL *app_cntrl;
	
	app_cntrl = get_app_cntrl();
	gl_wchar = app_cntrl->gl_wchar;
	gl_hchar = app_cntrl->gl_hchar;
	
	for (i=0; i<ZEILEN; i++)
		sprintf(&liste[i+(i*(SPALTEN-1))], "%2d. Dieser Text ist zur"
	  		    " Demonstration der Slider gedacht.", i);
}


/* ---------------------------------------------------------------------- */
/* Fenster initialisieren und ”ffnen                                      */
/* ---------------------------------------------------------------------- */
void show_text(void)
{
	struct WINDOW *win;
	GRECT workarea, winpos = {50, 50, 300, 300};
	
	wind_get(0, WF_WORKXYWH, &workarea.g_x, &workarea.g_y, &workarea.g_w,
		 		&workarea.g_h);
	
	win = create_window(&workarea, &winpos, 200, 200, 
						NAME|INFO|CLOSER|MOVER|SIZER|FULLER|UPARROW|DNARROW|
						RTARROW|LFARROW|VSLIDE|HSLIDE, DATA_WINDOW,
						draw_text, 0, 0, 0);
	if (win)
	{
		/* Slider initialisieren -------------------------- */
		init_slider(win, SPALTEN, ZEILEN, gl_wchar, gl_hchar);
		open_window(win, "Text im Fenster", "Scrollen durch Slider");
	}
}


/* Zeichenfunktion des Textfensters ------------------------------------- */
void draw_text(struct WINDOW *win)
{
	register int x, y, z, s, x1, y1, x_offset, y_offset;
	GRECT workarea;
	char *b = liste, c;
	
	get_workarea(win, &workarea);
	x_offset = get_x_slider(win);
	y_offset = get_y_slider(win);

	x1 = workarea.g_x + workarea.g_w;
	y1 = workarea.g_y + workarea.g_h;

	for (y=workarea.g_y + gl_hchar, z=y_offset; y < y1; y += gl_hchar, z++)
		for (x=workarea.g_x, s=x_offset; x < x1; x += gl_wchar, s++)
			if (s < SPALTEN && z < ZEILEN && (c = b[z*SPALTEN+s]) != ' ')
				gputc(x,y,c);
}


/* Zeichen c an der der Stelle x,y ausgeben ----------------------------- */
void gputc(int x, int y, char c)
{
	int handle;
	static char out[2] = {' ', '\0'};
		
	handle = get_handle();
	out[0] = c;
	v_gtext(handle, x,y, out); 
}
