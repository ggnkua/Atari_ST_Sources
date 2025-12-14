/* ---------------------------------------------------------------------- */
/* PowerGem Library, Version 1.1                                          */
/*																		  */
/* by Boris Sander			                                              */
/* Gerh.-Hauptmann-Str. 23	    										  */
/* 4350 Recklinghausen													  */
/*																		  */
/* Copyright (c) 1992 by ICP - Innovativ Computer-Presse GmbH & Co. KG    */
/* erweitert und, soweit sichtbar ,fehlerbereinigt von Mario Bahr			  */
/* ---------------------------------------------------------------------- */
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include "powergem.h"

/* gehîrt eigentlich in aes.h */
#ifndef WF_BOTTOM
#define WF_BOTTOM 25
#endif
/* ---------------------------------------------------------------------- */
/* Funktionsprototypen                                                    */
/* ---------------------------------------------------------------------- */
struct WINDOW      *alloc_window(void);
struct BUTTON_LIST *alloc_button(struct WINDOW *win);
struct KEY_LIST    *alloc_key(void);
struct MENU_LIST   *alloc_menu(void);
struct MSG_LIST    *alloc_msg(void);

boolean compare_grect(GRECT *r1, GRECT *r2);
void    copy_grect(GRECT *r1, GRECT *r2);
void    clipping(int vdi_handle, GRECT *r, int mode);
void    blank(struct WINDOW *, int x, int y, int w, int h);

void sort_win_by_top(struct WINDOW *win);
void kill_window(int wh);
void win_manager(int msg, struct WINDOW *win, int x, int y, int w, int h);
void change_slider_size(struct WINDOW *win);
void new_slider_pos(struct WINDOW *win);
void hndl_slider_pos(struct WINDOW *win, int what, int position);

int  find_obj(OBJECT *tree);
int  fm_inifld(OBJECT *tree, int start_fld);
void draw_dial(struct WINDOW *win, GRECT *rc);
void draw_object(struct WINDOW *win,int obj_index);
void align_dial(struct WINDOW *win);
void align_panel(struct WINDOW *win);
boolean check_rect(int x,int y,GRECT *rect);

void button_manager(int m_x, int m_y, int m_button, int k_state);
void kill_button(struct WINDOW *win);

void key_manager(int code);
void kill_key(void);

void menu_manager(int title, int item, int scan_code);
void menu_all_change(int menu_flag);		  
void kill_menu(void);

void msg_manager(int *event);
void kill_msg(void);
void all_free(void);

#define DESK_TOP (void *)-1UL
/* ---------------------------------------------------------------------- */
/* Globale Variablen                                                      */
/* ---------------------------------------------------------------------- */
struct MSG_LIST  *msg_start;
struct KEY_LIST  *key_start;
struct MENU_LIST *menu_start; 
struct WINDOW *start, *help; 
MFDB screen;				 /* Struktur fÅr Bildschirmparameter   */

struct A_CNTRL app_cntrl;

/* ---------------------------------------------------------------------- */
/* Programmdeskriptor initialisieren, Resourcedatei laden, MenÅ darst.    */
/* ---------------------------------------------------------------------- */
boolean init_powergem(char *rsc_name, int menu_index)
{
	register int i;
	int phys_handle;
	int work_in[11], work_out[57],work_ext[57];
	char alert_text[80];
	/* Alle globalen Variablen Null setzen */
	msg_start  = NULL;
	key_start  = NULL;
	menu_start =  NULL;
	start= help = NULL;
	memset( &app_cntrl, 0, sizeof(struct A_CNTRL));

	if ((app_cntrl.ap_id = appl_init()) != -1)
	{
		phys_handle = graf_handle(&app_cntrl.gl_wchar, &app_cntrl.gl_hchar,
								  &app_cntrl.gl_wbox, &app_cntrl.gl_hbox);
		work_in[0] = Getrez() + 2;
		for (i =1 ; i < 10; work_in[i++] = 1);
		work_in[10] = 2;
		app_cntrl.vdi_handle = phys_handle;

		v_opnvwk(work_in, &app_cntrl.vdi_handle, work_out);
		vq_extnd(app_cntrl.vdi_handle,1,work_ext);

	   /* fÅllt die vollstÑndige BITBLK-Struktur des Bildschirms */	 
       screen.fd_addr=NULL;	          /* Bildspeicherbasisadresse */
       screen.fd_w=work_out[0]+1;     /* Blockbreite in Pixeln    */
       screen.fd_h=work_out[1]+1;     /* Hîhe des Blocks in Pixeln*/
       screen.fd_wdwidth=((screen.fd_w+15)>>4);
       					             /* Blockbreite in Integern  */
       screen.fd_stand=0;            /* gerÑteabhÑngiges Format  */
	   screen.fd_nplanes=work_ext[4];/* Anzahl der Farbebenen    */
       screen.fd_r1=screen.fd_r2=screen.fd_r3=0;
       							     /* reserviert               */
	}
	else
	{
		sprintf(alert_text, "[3][Applikation konnte nicht|angemeldet werden!|"
				"][Abbruch]");
		form_alert(1, alert_text);
		return(FALSE);
	} 

	/* Warnung, wenn Resource-Datei nicht geladen werden konnte -> Abbruch */
	if (!rsrc_load(rsc_name))
	{ 
		sprintf(alert_text, "[3][Die Resource-Datei|  %s|konnte nicht geladen|"
				"werden!][Abbruch]", rsc_name);
		form_alert(1, alert_text);
		return(FALSE);
	}	
	
	if (rsrc_gaddr(0, menu_index, &app_cntrl.menu))
		menu_bar(app_cntrl.menu, 1);
	else 
		return(FALSE);
	
	wind_get(0, WF_WORKXYWH, &app_cntrl.workarea.g_x,
			 &app_cntrl.workarea.g_y, &app_cntrl.workarea.g_w, 
			 &app_cntrl.workarea.g_h);
	return(TRUE);
}
/***********************************************************
 * Stellt den DESKTOP-Hintergrund dar 					   *	
 ***********************************************************/
boolean init_desktop(int desk)
{
OBJECT *desktop;
extern GEMPARBLK _GemParBlk;
if(rsrc_gaddr(R_TREE,desk,&desktop) && 	_GemParBlk.global[0]<0x0400
										 && _GemParBlk.global[1] == 1  )
	{
	desktop[ROOT].ob_x =app_cntrl.workarea.g_x;
	desktop[ROOT].ob_y =app_cntrl.workarea.g_y;
	desktop[ROOT].ob_width =app_cntrl.workarea.g_w;
	desktop[ROOT].ob_height=app_cntrl.workarea.g_h;
	wind_set(0,WF_NEWDESK,desktop,ROOT,MAX_DEPTH);
		objc_draw(desktop, 0,ROOT, desktop[ROOT].ob_x
   	  , desktop[ROOT].ob_y, desktop[ROOT].ob_width,desktop[ROOT].ob_height);
	}
else
	return FALSE;
return TRUE;
}
/***************************
 * Screenadresse ermitteln *
 ***************************/
MFDB *get_screen(void)
{
	return(&screen);
}
/***************************************** 
 * Oberstes Fenster je nach Typ 		 *
 * Input:  Typ des Fensters				 *
 * Output: wh_handle				     *
 *****************************************/
struct WINDOW *get_lastwin(int typ) 
{
struct WINDOW *win_b;

win_b=start;
if(win_b == NULL)
	return NULL;
if( (win_b->type&3) == typ)
   return start;        /* Etwa oberstes Fenster ? */

while(win_b->next != NULL)
	{
	win_b=win_b->next;
	if((win_b->type&3) == typ)
		return win_b; 	  
	}
return NULL;
}	
/**************************************************
 * Ermittlungn des Powergemeigenen VDI-Handles    *
 **************************************************/
int get_handle(void)
{
	return(app_cntrl.vdi_handle);
}	

/**************************************
 * PowerGEM anmelden zum verlassen 	  *
 **************************************/
void exit_powergem(void)
{
app_cntrl.quit = TRUE;	/* Quit-Flag auf TRUE setzen (fÅr multi) */
}
/******************************************
 * Gibt die Resourcen von PowerGEM frei   *
 ******************************************/
void all_free(void)
{
int x,y,w,h,wh;
extern GEMPARBLK _GemParBlk;
	
/* PrÅfen, ob noch Fenster offen sind */
help = start;
while(start)
	{
	/* Fenster schlieûen, Speicher freigeben */
	start = help->next;
	wind_get(help->w_handle, WF_CURRXYWH, &x, &y, &w, &h);
	graf_shrinkbox(0,0,0,0, x,y,w,h);
	wind_close(help->w_handle); 
	wind_delete(help->w_handle);
	if ((help->type & DIAL_WINDOW) || (help->type & PANEL_WINDOW))
		kill_button(help);
	if(help->close_code)
		help->close_code(help);/* Resourcen des Anwenders ebenfalls freigeben */
	kill_window(help->w_handle); 
	help = start;
	}
			
/* evtl. Key-Liste freigeben */
if (key_start)
	kill_key();

/* evtl. Message-Liste freigeben */ 
if (msg_start)
	kill_msg();
	
/* evtl. Menu-Liste freigeben */
if (menu_start)
	kill_menu();
		
/* MenÅ lîschen */
	menu_bar(app_cntrl.menu, 0);

/* Resource-Speicher freigeben */
	rsrc_free();

/* Erst ab TOS 1.4 ! -Fenster der Accssories auch schlieûen !*/
wind_get(0, WF_TOP, &wh, 0,0,0);/* Oberstes Fenster ermitteln  */  
if(_GemParBlk.global[0] >= 0x140 && wh > 0)
	wind_new();  	
}
/* ---------------------------------------------------------------------- */
/* Adresse des Programmdeskriptors ermitteln                              */
/* ---------------------------------------------------------------------- */
struct A_CNTRL *get_app_cntrl()
{
	return(&app_cntrl);
}
/**************************************************************************
 * Sortiert WINDOW-next-Pointer neu (fÅr Fensterreihenfolge bei Tastatur- * 
 * topping)                                                               *
 * Zugriff auf globalen start-Zeiger                                      *
 * Input: win getopptes Fenster  									      *	
 **************************************************************************/
void sort_win_by_top(struct WINDOW *win)
{
struct WINDOW *win_b;

win_b=start;
	
if( win != start)         /* sonst win schon oberstes Fenster */
	{
	while(win_b->next != win) /* VorgÑnger suchen */
		win_b = win_b->next;
	win_b->next = win->next; /* Bekommt nun Zeiger auf dem ich zeige    */
	win->next = start;       /* Zeige nun auf das ehemals erste Element */
	start = win;             /* Werde erstes Element                    */
	}
}	

/**************************************************************************
 * Speicher fÅr WINDOW-Struktur alloziieren                               *
 **************************************************************************/
struct WINDOW *alloc_window(void)
{
	help = start;           
	start = (struct WINDOW *)calloc(1,sizeof(struct WINDOW)); 
	if (!start)
		return(NULL);
	start->next = help;     
	return(start);          
}

/************************************************************************
 * WINDOW-struct-Speicher freigeben                                     *
 * Input: wh Fensterhandle                                              *
 ************************************************************************/
void kill_window(int wh)
{
struct WINDOW *ptr;

ptr = get_winfh(wh);            
if (ptr) 
	{
	help = start; 
	if (help == ptr)    /* Wenn erstes Element */             
		{
		if (ptr->next)   /* wenn es einen Nachfolger gibt */
			{
			start = help->next; /* Element freigeben, Zeiger verbiegen */
			if (ptr->slider)
				free(ptr->slider);    
			if (ptr->dialog)         
				free(ptr->dialog);    
			free(ptr); 
			}
		else		
			{
			start = help = NULL; /* Es gibt keinen Nachfolger -> alles */
			if (ptr->slider)		/* auf NULL setzen, freigeben */
				free(ptr->slider);
			if (ptr->dialog)
				free(ptr->dialog);
			free(ptr);
			}
		}
	else 
		{									
		while (help->next != ptr) /* VorgÑnger suchen */
			help = help->next;
				
		if (!ptr->next)   /* Wenn es keinen Nachfolger gibt */ 
			{
			help->next = 0; /* dann lîschen */
			if (ptr->slider)
				free(ptr->slider);
			if (ptr->dialog)
				free(ptr->dialog);
			free(ptr);
			}
		else              /* Ansonsten Zeiger verbiegen und lîschen */
			{
			help->next = ptr->next;
			if (ptr->slider)
				free(ptr->slider);
			if (ptr->dialog)
				free(ptr->dialog);
			free(ptr);
			}
		}
	}
}

/* ---------------------------------------------------------------------- */
/* Suche anhand des gegebenen Window Handles die passende WINDOW Struktur */
/* Ergebnis: Adresse der WINDOW Struktur, ansonsten NULL          		  */
/* ---------------------------------------------------------------------- */
struct WINDOW *get_winfh(int wh)
{
	help = start;
	while(help)
	{
		if (help->w_handle == wh)
			return(help);
		help = help->next;
	}
	return(NULL);
}

/* ---------------------------------------------------------------------- */
/* Suche anhand des gegebenen Fensternamens die passende WINDOW Struktur  */
/* Ergebnis: Adresse der WINDOW Struktur, ansonsten NULL          		  */
/* ---------------------------------------------------------------------- */
struct WINDOW *get_winfn(char *name)
{
	help = start;
	while(help)
	{
		if (!(strcmp(help->name, name)))
			return(help);
		help = help->next;
	}
	return(NULL);
}
/**************************************************************************
 * Stellt das aktive Fenster fest                                         *
 * Output: Zeiger auf WINDOW-Struktur oder NULL                           *
 **************************************************************************/
 struct WINDOW *get_activwin(void)
 {
 int wh;
 
wind_get(0, WF_TOP, &wh, 0,0,0);     /* Oberstes Fenster ermitteln  */  
if(wh > 0)
	return(get_winfh(wh));
return NULL;
 }
  
/**************************************************************************
 * Macht das jetzige Fenster zum letzten                                  *
 * Zugriff auf globalen start-Zeiger                                      *
 **************************************************************************/
void untop_win(void)
{
struct WINDOW *win_b1,*win_b2;

if(start == NULL)
	return;
	
if( start->next != NULL)
	{
	win_b1=start;
	win_b2=start;
	wind_set(start->w_handle, WF_BOTTOM, 0,0,0,0); 

	start=start->next;    /* darunterliegende Fenster nach oben */
	while( win_b2->next != NULL)  /* letzte Fenster suchen */
		win_b2=win_b2->next;

	win_b2->next=win_b1; /* erhÑlt Zeiger auf ehemals erstes Fenster     */
	win_b1->next=NULL;   /* ehemals erstes Fenster hat keinen Nachfolger */	
	wind_set(start->w_handle, WF_TOP, 0,0,0,0); 
	app_cntrl.w_handle = start->w_handle;
	if (start->type & DIAL_WINDOW)         /* Åblichen Reaktionen */
		start->dialog->cont = TRUE;
	if (start->type & DIAL_WINDOW)
		start->dialog->cont = TRUE;
	if(start->wtop_code) 		/* Erste Reaktion des Fensters */ 
		start->wtop_code(start);
	}
}
/* ---------------------------------------------------------------------- */
/* Kopieren einer Rechteckstruktur                                        */
/* ---------------------------------------------------------------------- */
void copy_grect(GRECT *src, GRECT *dest)
{
	dest->g_x = src->g_x;
	dest->g_y = src->g_y;
	dest->g_w = src->g_w;
	dest->g_h = src->g_h;
}

/* ---------------------------------------------------------------------- */
/* Vergleich zweier Rechteckstrukturen, Ergebnis: TRUE oder FALSE         */
/* ---------------------------------------------------------------------- */
boolean compare_grect(GRECT *r1, GRECT *r2)
{
	return((r1->g_x & r2->g_x) &
		   (r1->g_y & r2->g_y) &
		   (r1->g_w & r2->g_w) &
		   (r1->g_h & r2->g_h));
}
	
/* ---------------------------------------------------------------------- */
/* Schnittmenge zweier Rechtecke berechnen                                */
/* ---------------------------------------------------------------------- */
boolean rc_intersect(GRECT *r1, GRECT *r2)
{
	int x, y, w, h;
	
	x = max(r2->g_x, r1->g_x);
	y = max(r2->g_y, r1->g_y);
	w = min(r2->g_x + r2->g_w, r1->g_x + r1->g_w);
	h = min(r2->g_y + r2->g_h, r1->g_y + r1->g_h);
	r2->g_x = x;
	r2->g_y = y;
	r2->g_w = w - x;
	r2->g_h = h - y;
	return((boolean)((w > x) && (h > y)));
}

/* ---------------------------------------------------------------------- */
/* Bildschirmausgabe "clippen"                                            */
/* ---------------------------------------------------------------------- */
void clipping(int vdi_handle, GRECT *r, int mode)
{
	int pxy[4];
	
	pxy[0] = r->g_x;
	pxy[1] = r->g_y;
	pxy[2] = r->g_x + r->g_w - 1;
	pxy[3] = r->g_y + r->g_h - 1;
	vs_clip(vdi_handle, mode, pxy);
}

/* ---------------------------------------------------------------------- */
/* Bereich lîschen                                                        */
/* ---------------------------------------------------------------------- */
/* Alle FÅllattributeinstellungen der Workstation werden gesichert und    */
/* zurÅckgesetzt                                                  		  */
/* ---------------------------------------------------------------------- */
void blank(struct WINDOW *win, int x, int y, int w, int h)
{
	GRECT r1, r2;
	int pxy[4];
	int attr[5];

	if(start == NULL)
		return;
		
	vqf_attributes(app_cntrl.vdi_handle, attr);
	if(win==NULL) /* Alles updaten */
		{
		win=start;
		x=app_cntrl.workarea.g_x;
		y=app_cntrl.workarea.g_y;
		w=app_cntrl.workarea.g_w;
		h=app_cntrl.workarea.g_h;
		}
	else
		{
		if(win->type&8)		
			return;	/* Dieses Fenster wird geschloûen -> REDRAW sinnlos */
		}
	r2.g_x = pxy[0] = x;
	r2.g_y = pxy[1] = y;
	r2.g_w = w;
	r2.g_h = h;
	pxy[2] = x + w - 1;
	pxy[3] = y + h - 1;
	
	graf_mouse(M_OFF, 0);
	wind_get(win->w_handle, WF_FIRSTXYWH, &r1.g_x, &r1.g_y, &r1.g_w,
				&r1.g_h);
	
	while (r1.g_w && r1.g_h)
		{
		if (rc_intersect(&r2, &r1) == TRUE)
			{
			clipping(app_cntrl.vdi_handle, &r1, TRUE);
			vsf_color(app_cntrl.vdi_handle, 1);
			vsf_interior(app_cntrl.vdi_handle, 0);
			vsf_style(app_cntrl.vdi_handle, 0);
			vswr_mode(app_cntrl.vdi_handle, 0);
			vsf_perimeter(app_cntrl.vdi_handle, 0);
			wind_update(BEG_UPDATE);
			if ((win->type&3) != DIAL_WINDOW)
				{	
				if (win->type & PANEL_WINDOW)
					{
					v_bar(app_cntrl.vdi_handle, pxy);
					draw_dial(win, &r1);
					}
				if(win->draw_code)
					win->draw_code(win);
				}
			else
				draw_dial(win, &r1);
			wind_update(END_UPDATE);
			clipping(app_cntrl.vdi_handle, &r1, FALSE);
			vsf_interior(app_cntrl.vdi_handle,  attr[0]);
			vsf_color(app_cntrl.vdi_handle,     attr[1]);
			vsf_style(app_cntrl.vdi_handle,     attr[2]);
			vswr_mode(app_cntrl.vdi_handle,     attr[3]);
			vsf_perimeter(app_cntrl.vdi_handle, attr[4]);
		}
		wind_get(win->w_handle, WF_NEXTXYWH, &r1.g_x, &r1.g_y, &r1.g_w,
			      &r1.g_h);
	}
	clipping(app_cntrl.vdi_handle, &r1, FALSE);
	graf_mouse(M_ON, 0);
}


/* ---------------------------------------------------------------------- */
/* Rechteck #1 beobachten                                                 */
/* ---------------------------------------------------------------------- */
void watch_r1(int flag, GRECT *rc, void (*code)(void))
{
	if (rc)
		app_cntrl.multi_flags |= MU_M1;
	else
		app_cntrl.multi_flags &= ~MU_M1;

	app_cntrl.m1_flag = flag;
	copy_grect(rc, &app_cntrl.m1);
	app_cntrl.m1_code = code;
}

/* ---------------------------------------------------------------------- */
/* Rechteck #2 beobachten                                                 */
/* ---------------------------------------------------------------------- */
void watch_r2(int flag, GRECT *rc, void (*code)(void))
{
	if (rc)
		app_cntrl.multi_flags |= MU_M2;
	else
		app_cntrl.multi_flags &= ~MU_M2;

	app_cntrl.m2_flag = flag;
	copy_grect(rc, &app_cntrl.m2);
	app_cntrl.m2_code = code;
}

/* ---------------------------------------------------------------------- */
/* Zeitabschnitt abwarten                                                 */
/* ---------------------------------------------------------------------- */
void watch_timer(int low, int high, void (*code)(void))
{
	if (low == 0 && high == 0)
		app_cntrl.multi_flags &= ~MU_TIMER;

	else
		app_cntrl.multi_flags |= MU_TIMER;

	app_cntrl.mt_locount = low;
	app_cntrl.mt_hicount = high;
	app_cntrl.time_code  = code;
}

/* ---------------------------------------------------------------------- */
/* Ereignisse einstellen, auf die multi() reagiert                        */
/* ---------------------------------------------------------------------- */
void watch_events(int flags, int clicks, int mask, int state)
{
	app_cntrl.multi_flags = flags;
	app_cntrl.mb_clicks   = clicks;
	app_cntrl.mb_mask     = mask;
	app_cntrl.mb_state    = state;
}


/* ---------------------------------------------------------------------- */
/* Ereignisverwaltung                                                     */
/* ---------------------------------------------------------------------- */
void multi()
{
int event = 0, mmo_x, mmo_y, mm_button, mmok_state, mk_return, mb_return;
int msgbuff[8] = {0,0,0,0,0,0,0,0},
	 buffer[8]  = {0,0,0,0,0,0,0,0};
int sel_obj, obj_state;
GRECT h1,h2;
struct WINDOW *win;
struct BUTTON_LIST *button_help;
int wh;

do
{
	copy_grect(&app_cntrl.m1, &h1);
	copy_grect(&app_cntrl.m2, &h2); 
	if(app_cntrl.modal != NULL)			/* wenn modales Fenster */
		win=app_cntrl.modal;
	else
		{
		wind_get(0, WF_TOP, &wh, 0,0,0);     /* Oberstes Fenster ermitteln  */  
		win = get_winfh(app_cntrl.w_handle); 
		if(win)
			{
			/* Modale Dialogbox -> andere Aktionen sperren */
			if((win->type&MODAL)==MODAL && app_cntrl.modal == NULL )
				{
				app_cntrl.modal = win;
				menu_all_change(0);	/* alle MenÅeintrÑge disablen   */	  
								/* (ACC noch bedienbar !!       */
				}
			}
		}				
	/* Wenn externes Fenster 'getopped' ist und wenn es sich um einen */
	/* Dialog handelt, passiert nichts */
	if ((win) && (win->type & DIAL_WINDOW) && (win->w_handle != wh))
		win->dialog->cont = FALSE;  

	/* Wenn es ein Dialog ist und es editierbare Texte gibt, dann */
	/* wird der Cursor an der akt. Position im Text eingeschaltet */
	if ((win) && (win->type & DIAL_WINDOW) && 
		 (win->dialog->next_obj != 0) &&
		 (win->dialog->edit_obj != win->dialog->next_obj))
		{
		if (win->dialog->cont) 
			{	
			if(ObjTree(win)[win->dialog->next_obj].ob_type ==G_FTEXT 
			|| ObjTree(win)[win->dialog->next_obj].ob_type ==G_FBOXTEXT)
				win->dialog->edit_obj = win->dialog->next_obj;
			win->dialog->next_obj = 0;
			objc_edit(win->dialog->tree, win->dialog->edit_obj, 0,
		   	          &(win->dialog->idx), ED_INIT);
			}
		}

	/* Ereignisse abwarten, die im Programmdeskriptor festgelegt */
	/* wurden */
	event = evnt_multi(app_cntrl.multi_flags, app_cntrl.mb_clicks,
					   app_cntrl.mb_mask, app_cntrl.mb_state,
	                   app_cntrl.m1_flag, h1.g_x, h1.g_y, h1.g_w, h1.g_h,
	                   app_cntrl.m2_flag, h2.g_x, h2.g_y, h2.g_w, h2.g_h, 
					   msgbuff, app_cntrl.mt_locount,
					   app_cntrl.mt_hicount, &mmo_x, &mmo_y, &mm_button,
					   &mmok_state, &mk_return, &mb_return);
	
	if (event & MU_MESAG)
		{
		/* Hat das Ereignis was mit Fenstern zu tun ? */
		if (msgbuff[0] >= WM_REDRAW && WM_NEWTOP >= msgbuff[0])
			{
			if(app_cntrl.modal != NULL && (msgbuff[0] == WM_TOPPED) ) 
				{
				if(win == app_cntrl.modal)
					printf("\a");
				}
			else
				win = get_winfh(msgbuff[3]);
			if(win)
				{
				wind_update(BEG_UPDATE);
				win_manager(msgbuff[0], win, msgbuff[4],
					msgbuff[5], msgbuff[6], msgbuff[7]);
				wind_update(END_UPDATE);
				}
			}
		else 
			{
			if ((msgbuff[0] & MN_SELECTED) && app_cntrl.modal==NULL)
				menu_manager(msgbuff[3], msgbuff[4], 0);
		/* Hier kann der Programmierer im Message Manager auf andere */
		/* Nachrichten reagieren, z.B. Schnittstelle via appl_write  */
			else
				{
				if(app_cntrl.modal==NULL)
					msg_manager(msgbuff);	       
				}
			}
		}
	
	/* Wurde eine Taste betÑtigt ? */
	if (event & MU_KEYBD)
	    {
		if(app_cntrl.modal != NULL)			/* wenn modales Fenster */
			win=app_cntrl.modal;
		else
			win = get_winfh(app_cntrl.w_handle); 
		
		/* Wenn es ein Dialog ist */
		if ((win) && (win->type & DIAL_WINDOW))
		{
			/* dann bearbeite Taste und editiere den aktuellen Text */
			win->dialog->cont = form_keybd(win->dialog->tree,
										   win->dialog->edit_obj,
									       win->dialog->next_obj, mk_return, 
										   &(win->dialog->next_obj), 
										   &mk_return);
			if (!win->dialog->cont)
			{
				button_help = win->dialog->button_start;
				while(button_help->obj_index != win->dialog->next_obj)
					button_help = button_help->next;
				if (button_help->obj_index == win->dialog->next_obj)
				{
					if(button_help->action)
						button_help->action();
					obj_state = win->dialog->tree[win->dialog->next_obj].
								ob_state;
					obj_state ^= SELECTED;
					objc_change(win->dialog->tree, win->dialog->next_obj, 0, 
				   	            win->workarea.g_x, win->workarea.g_y, 
				      	        win->workarea.g_w, win->workarea.g_h, 
				         	    obj_state, 1);

					if (button_help->redraw)
						{
						buffer[0] = WM_REDRAW;
						buffer[1] = app_cntrl.ap_id;
						buffer[3] = win->w_handle;
						buffer[4] = win->workarea.g_x;
						buffer[5] = win->workarea.g_y;
						buffer[6] = win->workarea.g_w;
						buffer[7] = win->workarea.g_h;
						appl_write(app_cntrl.ap_id, 16, buffer);
						}
					}
				}						 
			if ((mk_return) && (win->dialog->cont)) 
				objc_edit(win->dialog->tree, win->dialog->edit_obj,
						  mk_return, &(win->dialog->idx), ED_CHAR);

			if ((!win->dialog->cont) || ((win->dialog->next_obj != 0) &&
				 (win->dialog->next_obj != win->dialog->edit_obj)))
				objc_edit(win->dialog->tree, win->dialog->edit_obj, 0,
				      &(win->dialog->idx), ED_END); 	
			}
/*		if (((mk_return & 0xff) < 0x20 || (mk_return & 0xff) > 0x7e)*/

		if(app_cntrl.modal == NULL)
			{
			menu_manager(0,0, mk_return);
			key_manager(mk_return);
			}
		else 
			{
			if ((win) && (win->key_code))
				win->key_code(win, (char)mk_return & 0xff);
			}
		}
		
	/* Wurde Maustaste betÑtigt ? */
	if (event & MU_BUTTON)
		{
		if(app_cntrl.modal != NULL) 
			win = app_cntrl.modal;
		else
			win = get_winfh(app_cntrl.w_handle);
        /* wenn normales Fenster */ 	
		if ((win) && (win->type&3) == DATA_WINDOW)
			{  /* innerhalb des Fensters  */
            if (check_rect(mmo_x,mmo_y,&win->workarea))
				{
				if (win->button_code)
					win->button_code(win, mmo_x, mmo_y, mm_button, mmok_state);
				}	
			else  /* auûerhalb des Fensters */
				{	
				if (app_cntrl.button_code && app_cntrl.modal == NULL)
					app_cntrl.button_code(mmo_x, mmo_y, mm_button, mmok_state);
				}
			}	
		else 
			{    /* auûerhalb der Fenster und kein eigenes Fenster aktiv */
			if ((!win) && (app_cntrl.button_code) && app_cntrl.modal == NULL )
				app_cntrl.button_code(mmo_x, mmo_y, mm_button, mmok_state);
			}
		/* Dialog und Panelfenster */		
		if ((win) && ((win->type & DIAL_WINDOW) || (win->type & PANEL_WINDOW)))
			{
			/* Bei Dialogen wird ÅberprÅft, ob ein OBJECT angeklickt wurde */
			win->dialog->next_obj = objc_find(win->dialog->tree,0,8,mmo_x, mmo_y);
			/* Wenn ja, wird der Objektstatus angepaût und ggfl. ein */
			/* neuer editierbarer Text initialisiert */
			if (win->dialog->next_obj >= 0)
				{ 
				int ob_flags=ObjTree(win)[win->dialog->next_obj].ob_flags;
				sel_obj = win->dialog->next_obj;

				/* Fixing bei form_button da Fehler bei Touchexit und Exit */
				if((ob_flags&EXIT) || (ob_flags&TOUCHEXIT))
					{
					ObjTree(win)[win->dialog->next_obj].ob_state^=SELECTED;
					win->dialog->cont= FALSE;
					}
				else
					win->dialog->cont = form_button(win->dialog->tree, 
									    win->dialog->next_obj, mb_return,
									    &(win->dialog->next_obj));
				if ( ((!win->dialog->cont) || win->dialog->next_obj != 0) &&
					(win->dialog->next_obj != win->dialog->edit_obj) &&
					(win->type & DIAL_WINDOW))
						{
						objc_edit(win->dialog->tree, win->dialog->edit_obj, 0,
								  &(win->dialog->idx), ED_END); 	
						win->dialog->cont=TRUE;
						}
				/* Aktion ausfÅhren, die den ausgewÑhlten Button betrifft */ 
				if (win->dialog->tree[sel_obj].ob_state & SELECTED)
					button_manager(mmo_x, mmo_y, mm_button, mmok_state);
				else if (win->dialog->tree[sel_obj].ob_flags & TOUCHEXIT)
					button_manager(mmo_x, mmo_y, mm_button, mmok_state);
				if (win->dialog->release)
					win->dialog->release(sel_obj, win->dialog->tree[sel_obj].ob_state);
				}
			else /* wenn kein OBJECT angeklickt worden ist */ 
				{
				if ((win->type & PANEL_WINDOW) && check_rect(mmo_x,mmo_y,&win->workarea))
					{  /* innerhalb des Panelfensters aber auûerhalb des Dialoges */
					if (win->button_code)
						win->button_code(win, mmo_x, mmo_y, mm_button, mmok_state);
					}	
				else 
					{
					if (app_cntrl.button_code && app_cntrl.modal == NULL )
					/*	{*/
						app_cntrl.button_code(mmo_x, mmo_y, mm_button, mmok_state);	
	/* geÑndert */
						if ((win->type & DIAL_WINDOW) || ((win->dialog->next_obj != 0) &&
							 (win->dialog->next_obj != win->dialog->edit_obj)))
							{
							objc_edit(win->dialog->tree, win->dialog->edit_obj, 0,
									  &(win->dialog->idx), ED_END); 	
							win->dialog->next_obj = win->dialog->edit_obj;
							win->dialog->edit_obj = 0;
							}
				/*		} */
					}
				}
			}
		}		
	/* Wurde der Mauspfeil in ein Rechteck hinein oder aus einem Recht- */
	/* eck heraus bewegt, dann die zugehîrige Aktion bearbeiten */
	if (event & MU_M1 && app_cntrl.modal == NULL)
		if (app_cntrl.m1_code)
			app_cntrl.m1_code();
		
	if (event & MU_M2 && app_cntrl.modal == NULL)
		if (app_cntrl.m2_code)
			app_cntrl.m2_code();
		
	/* Aktion zu einem Zeitereignis aufrufen */
	if (event & MU_TIMER && app_cntrl.modal == NULL)
		{
		if (app_cntrl.time_code)
			app_cntrl.time_code();
		}
		
	} while (!app_cntrl.quit); /* Solange bis der Anwender das Programm */
										/* verlassen mîchte */
	all_free();
	v_clsvwk(app_cntrl.vdi_handle);
	appl_exit();
}

/* ---------------------------------------------------------------------- */
/* Sliderstruktur initialisieren                                          */
/* ---------------------------------------------------------------------- */
boolean init_slider(struct WINDOW *win, int x_elements, int y_elements,
						  int x_size, int y_size)
{
	struct slide_def *ptr;
	 
	/* Ist noch genug Speicher da ? */
	if ((ptr = (struct slide_def *)calloc(1, sizeof(struct slide_def)))
		 != NULL)
	{
		win->slider = ptr;
		win->slider->x_elements = x_elements;
		win->slider->y_elements = y_elements;
		win->slider->x_size     = x_size;
		win->slider->y_size     = y_size;
		
		win->slider->x_offset   = 0;
		win->slider->y_offset   = 0;
		win->slider->x_cursor   = 0;
		win->slider->y_cursor   = 0;
			
		change_slider_size(win); /* Slidergrîûen anpassen  */
		new_slider_pos(win);
		return(TRUE);
	}
	else
	{
		form_alert(1,"[3][Slider konnte nicht|initialisiert werden!][Sorry]");
		return(FALSE);
	}
}

/* ---------------------------------------------------------------------- */
/* Hor. und vert. Slidergrîûen anpassen                                   */
/* ---------------------------------------------------------------------- */
void change_slider_size(struct WINDOW *win)
{
	float x,y;
	
	if (win->slider)
	{
	    x = 1000.0 / (float)win->slider->x_elements;
		x *= (float)win->workarea.g_w / (float)win->slider->x_size;
	    y = 1000.0 / (float)win->slider->y_elements;
		y *= (float)win->workarea.g_h / (float)win->slider->y_size;
			        
		wind_set(win->w_handle, WF_HSLSIZE, (unsigned int)x, 0, 0, 0);
		wind_set(win->w_handle, WF_VSLSIZE, (unsigned int)y, 0, 0, 0);

		if (win->workarea.g_w/win->slider->x_size+win->slider->x_offset >
			 win->slider->x_elements )
			set_x_slider(win,(int)((float)win->slider->x_elements - 
								(float)win->workarea.g_w/win->slider->x_size));

		if (win->workarea.g_h/win->slider->y_size+win->slider->y_offset >
			 win->slider->y_elements )
			set_y_slider(win,(int)((float)win->slider->y_elements - 
								(float)win->workarea.g_h/win->slider->y_size));
	}
}


/* ---------------------------------------------------------------------- */
/* Sliderposition verwalten                                               */
/* ---------------------------------------------------------------------- */
void hndl_slider_pos(struct WINDOW *win, int what, int position)
{
	long x,y;
	int  w,h;
	int sx_b,sy_b;
	static int change;
	
	sy_b=win->slider->y_offset;
	sx_b=win->slider->x_offset; /* Zwischenspeichern */
	if ((w = win->workarea.g_w / win->slider->x_size) * win->slider->x_size 
		  > win->workarea.g_w)
		w--;
   if ((h = win->workarea.g_h / win->slider->y_size) * win->slider->y_size
   	  > win->workarea.g_h)
   	h--;

	switch (what)
	{
		case PAGE_UP:
			if (win->slider->y_offset >= h)
			{
				win->slider->y_offset -= h;
				change = 2;
			}
			else if (win->slider->y_offset > 0)
			{
				win->slider->y_offset = 0;
				change = 1;
			}
			if (win->slider->y_cursor > win->slider->y_offset + h - 1)
				win->slider->y_cursor = win->slider->y_offset + h - 1;	
			break;
		
		case PAGE_DN:
			if (win->slider->y_offset + 2*h < win->slider->y_elements)
			{
				win->slider->y_offset += h;
				change = 2;
			}
			else if (win->slider->y_offset < win->slider->y_elements - h)
			{
				win->slider->y_offset = win->slider->y_elements - h;
				change = 1;
			}
			if (win->slider->y_cursor < win->slider->y_offset)
				win->slider->y_cursor = win->slider->y_offset;
			break;
			
		case PAGE_LF:
			if (win->slider->x_offset >= w)
			{
				win->slider->x_offset -= w;
				change = 2;
			}
			else if (win->slider->x_offset > 0)
			{
				win->slider->x_offset = 0;
				change = 1;
			}
			if (win->slider->x_cursor > win->slider->x_offset + w - 1)
				win->slider->x_cursor = win->slider->x_offset + w - 1;
			break;
		
		case PAGE_RT:
			if (win->slider->x_offset + 2*w < win->slider->x_elements)
			{
				win->slider->x_offset += w;
				change = 2;
			}
			else if (win->slider->x_offset < win->slider->x_elements - w)
			{
				win->slider->x_offset = win->slider->x_elements - w;
				change = 1;
			}
			if (win->slider->x_cursor < win->slider->x_elements)
				win->slider->x_cursor = win->slider->x_elements;
			break;
			
		case CLMN_LF:
			if (win->slider->x_offset > 0)
			{
				win->slider->x_offset--;
				change = 2;
				if (win->slider->x_cursor > win->slider->x_offset + w - 1)
					win->slider->x_cursor--;
			}
			else 
				change = 0;
			break;
			
		case CLMN_RT:
			if (win->slider->x_offset + w - 1 < win->slider->x_elements - 1)
			{
				win->slider->x_offset++;
				change = 2;
				if (win->slider->x_cursor < win->slider->x_offset)
					win->slider->x_cursor++;
			}
			else
				change = 0;
			break;
			
		case ROW_UP:
			if (win->slider->y_offset > 0)
			{
				win->slider->y_offset--;
				change = 2;
				if (win->slider->y_cursor > win->slider->y_offset + h - 1)
					win->slider->y_cursor--;
			}
			else
				change = 0;
			break;
			
		case ROW_DN:
			if (win->slider->y_offset + h - 1 < win->slider->y_elements - 1)
			{
				win->slider->y_offset++;
				change = 2;
				if (win->slider->y_cursor < win->slider->y_offset)
					win->slider->y_cursor++;
			}
			else
				change = 0;
			break;
			
		case H_SLIDE:
			x = win->slider->x_elements - win->workarea.g_w / 
				 win->slider->x_size;
			x *= position;
			x /= 1000;
			win->slider->x_offset = (unsigned int)x;
			change = 1;
			break;

		case V_SLIDE:
			y = win->slider->y_elements - win->workarea.g_h /
				 win->slider->y_size;
			y *= position;
			y /= 1000;
			win->slider->y_offset = (unsigned int)y; 
			change = 1;
	}

	if (change > 0 && ( win->slider->y_offset != sy_b || win->slider->x_offset!= sx_b) )
	{
		new_slider_pos(win);
	}
	if (change == 1)
		change = 0;
}


/**************************************************************************
 * Sliderposition innerhalb des Fensters setzen                           *
 * Dazu werden die einfach die Sliderkoordinaten abgefragt 				  *	
 * Input: win: Fensterverwaltungsstruktur u.a . mit den Daten fÅr die     *
 * 			   Slider des aktuellen Fensters							  *	
 **************************************************************************/
void new_slider_pos(struct WINDOW *win)
{
	float x,y;
			
	if (win->slider)
	{
		if(win->slider->x_offset==win->slider->x_elements)
			x=1000.0; /* wegen Quantisierung */
		else
			{
			if(win->slider->x_elements - win->workarea.g_w / 
			    win->slider->x_size!=0)
				{
				x =( 1000.0 / ((float)win->slider->x_elements 
				-(float)win->workarea.g_w /(float)win->slider->x_size));
				x *= win->slider->x_offset;
				}
			else x=0.0;
			}
		if(win->slider->y_offset==win->slider->y_elements)
			y=1000.0;
		else
			{	
			if(win->slider->y_elements - win->workarea.g_h / 
			    win->slider->y_size!=0)
				{			
				y =(1000.0 / ((float)win->slider->y_elements
				- (float)win->workarea.g_h/(float)win->slider->y_size));
				y *= win->slider->y_offset;
				}
			else y=0.0; 
			}
		wind_set(win->w_handle, WF_VSLIDE, (unsigned int)y, 0, 0, 0);
		wind_set(win->w_handle, WF_HSLIDE, (unsigned int)x, 0, 0, 0);
		/* Window Redraw erzwingen */
		blank(win, win->workarea.g_x, win->workarea.g_y,
				win->workarea.g_w, win->workarea.g_h); 
	}
}


/* ---------------------------------------------------------------------- */
/* Zeile einfÅgen (z.B. in Textfenster)                                   */
/* ---------------------------------------------------------------------- */
void add_rows(struct WINDOW *win, int count)
{
	win->slider->y_elements += count;
	if(win->slider->y_elements<=0) 
		win->slider->y_elements = 1;
	 			
}

/* ---------------------------------------------------------------------- */
/* Spalte einfÅgen                                                        */
/* ---------------------------------------------------------------------- */
void add_columne(struct WINDOW *win, int count)
{
	win->slider->x_elements += count;
	if(win->slider->x_elements<=0)
		win->slider->x_elements = 1;
}
	 
/* ---------------------------------------------------------------------- */
/* Fensterstruktur generieren                                             */
/* ---------------------------------------------------------------------- */
struct WINDOW *create_window(GRECT *max, GRECT *real, int min_w, int min_h,
									  int flags, int type, 
									  void (*draw_code)(struct WINDOW *win),
									  void (*slide_code)(struct WINDOW *win,
									                     int message),
									  void (*button_code)(struct WINDOW *win, int mx,
									  					  int my, int mb, int ks),
									  void (*key_code)(struct WINDOW *win,
									  						 char ascii),
									  void (*wtop_code)(struct WINDOW *win),
									  int  (*close_code)(struct WINDOW *win))

{
	int wh;
	struct WINDOW *ptr;
	
	if(start) /* eventuell im letzen Fensters Cursor ausschalten */
		{
		if( start->type & DIAL_WINDOW)
			{
			if(ObjTree(start)[start->dialog->edit_obj].ob_type ==G_FTEXT 
			|| ObjTree(start)[start->dialog->edit_obj].ob_type ==G_FBOXTEXT)
			objc_edit(start->dialog->tree, start->dialog->edit_obj, 0,
    	    &(start->dialog->idx), ED_END); 	
			}
		}
	ptr = alloc_window();
	if (!ptr)
	{
		form_alert(1,"[3][Kein Speicher frei!|Kann Fenster nicht îffnen.]"
					  "[Abbruch]");	
		return(FALSE);
	} 
	
	if ((wh =  wind_create(flags, max->g_x, max->g_y, max->g_w, 
		  max->g_h)) < 0)
	{	
		form_alert(1,"[3][Zuviele Fenster offen!|Bitte schlieûen Sie ein|"
					  "nicht mehr benîtigtes Fenster.][Okay]");
		return(FALSE);
	}
	
	/* Struktur initialisieren */
	ptr->w_handle    = wh;
	ptr->type        = (type&7); 	
	if (type & DATA_WINDOW)
		ptr->dialog   = NULL;
	ptr->fulled      = compare_grect(max, real);
	ptr->flags       = flags;
	ptr->min_w       = min_w;
	ptr->min_h       = min_h;
	ptr->draw_code   = draw_code;
	ptr->slide_code  = slide_code;
	ptr->key_code    = key_code;
	ptr->button_code = button_code;
	ptr->wtop_code   = wtop_code;
	ptr->close_code   = close_code;
	ptr->slider      = NULL;
	copy_grect(real, &ptr->actual_position);

	return(ptr);
}


/* ---------------------------------------------------------------------- */
/* Panel-Window generieren                                                */
/* ---------------------------------------------------------------------- */
struct WINDOW *create_pwindow(int obj_name, GRECT *max, GRECT *real,
							  int min_w, int min_h, int flags,int modal,
							  int align,
							  void (*draw_code)(struct WINDOW *win),
							  void (*slide_code)(struct WINDOW *win, 
    											 int message),
						      void (*button_code)(struct WINDOW *win, int mx,
				  		  					      int my, int mb, int ks),
						      void (*key_code)(struct WINDOW *win,
					    					   char ascii),
						      void (*wtop_code)(struct WINDOW *win),

						      void (*release)(int obj_index, int obj_state))
{
	struct WINDOW *ptr;
	OBJECT *tree;
	int msgbuff[8] = {0,0,0,0,0,0,0,0};
	int type_flag= PANEL_WINDOW;

	if (rsrc_gaddr(0, obj_name, &tree))
	{
		help = start;
		while (help)
		{
			if ((help->dialog) && (help->dialog->tree) && 
				 (help->dialog->tree == tree))
			{
				msgbuff[0] = WM_TOPPED;
				msgbuff[1] = app_cntrl.ap_id;
				msgbuff[3] = help->w_handle;
				appl_write(app_cntrl.ap_id, 16, msgbuff);
				return(NULL);
			}
			help = help->next;
		}
		if(modal)
			type_flag|=MODAL;
		ptr = create_window(max, real, min_w, min_h, flags, type_flag,
								  draw_code, slide_code, button_code
								  	, key_code,wtop_code,0);
		if (!ptr)
			return(NULL);
		
		ptr->dialog = (struct dial *)calloc(1, sizeof(struct dial));
		if (!ptr->dialog)
			return(NULL);
		
		ptr->dialog->tree    = tree;
		ptr->dialog->release = release;
		ptr->dialog->align   = align;
		return(ptr);
	}
	else
		return(NULL);
}
																										 

/* ---------------------------------------------------------------------- */
/* Fenster îffnen                                                         */
/* ---------------------------------------------------------------------- */
void open_window(struct WINDOW *win, char *name, char *info) 
{
	strcpy(win->name, name);
	wind_set(win->w_handle, WF_NAME, win->name, 0, 0);
	if (win->flags & INFO)
	{
		strcpy(win->info, info);
		wind_set(win->w_handle, WF_INFO, win->info, 0, 0);
	}
	else
		strcpy(win->info, "\0");

	graf_growbox(0,0,0,0, win->actual_position.g_x, win->actual_position.g_y,
				 win->actual_position.g_w, win->actual_position.g_h);
	wind_open(win->w_handle, win->actual_position.g_x, win->actual_position.g_y,
			  win->actual_position.g_w, win->actual_position.g_h);
	wind_get(win->w_handle, WF_WORKXYWH, &win->workarea.g_x, &win->workarea.g_y,
		     &win->workarea.g_w, &win->workarea.g_h);

	if (win->slider)
		change_slider_size(win);
	
	if (win->type & DIAL_WINDOW)
		align_dial(win);
		
	if (win->type & PANEL_WINDOW)
		align_panel(win);
		
	/* Window Handle in Programmdeskriptor eintragen */
	app_cntrl.w_handle = win->w_handle;
	blank(win, win->workarea.g_x, win->workarea.g_y,
			win->workarea.g_w, win->workarea.g_h);  /* REDRAW erzwingen */
	if(win->wtop_code!=NULL) /* Erste Reaktion des Fensters */ 
		win->wtop_code(win);

}	


/* ---------------------------------------------------------------------- */
/* PANEL an Fensterkoordinaten anpassen                                   */
/* ---------------------------------------------------------------------- */
void align_panel(struct WINDOW *win)
{
	win->dialog->tree->ob_x = win->workarea.g_x;
	win->dialog->tree->ob_y = win->workarea.g_y;
		
	switch(win->dialog->align)
	{
		case ALIGN_X:
			win->dialog->tree->ob_width = win->workarea.g_w;
			win->workarea.g_y += win->dialog->tree->ob_height;
			win->workarea.g_h -= win->dialog->tree->ob_height;
			break;
		case ALIGN_Y:
			win->dialog->tree->ob_height = win->workarea.g_h;
			win->workarea.g_x += win->dialog->tree->ob_width;
			win->workarea.g_w -= win->dialog->tree->ob_width;
	}
}


/* ---------------------------------------------------------------------- */
/* DIALOG an Fensterkoordinaten anpassen                                  */
/* ---------------------------------------------------------------------- */
void align_dial(struct WINDOW *win)
{
	win->dialog->tree->ob_x = win->workarea.g_x;
	win->dialog->tree->ob_y = win->workarea.g_y;
	win->dialog->tree->ob_width = win->workarea.g_w;
	win->dialog->tree->ob_height = win->workarea.g_h;
}

/* ---------------------------------------------------------------------- */
/* Window Manager                                                         */
/* ---------------------------------------------------------------------- */
void win_manager(int msg, struct WINDOW *ptr, int x, int y, int w, int h)
{
	int act_wh;
	struct WINDOW *win;
	if(ptr==NULL)
		{
		printf("\n The worst case in the win_manager!");
		return; /* Das schlimmste verhindern (kommt manchmal vor !)*/
		}
		
	switch(msg)
	{
		case WM_REDRAW:            /* Window wird neu gezeichnet */
			blank(ptr, x,y,w,h);
			if (ptr->type & DIAL_WINDOW) /* Wenn Dialog, dann prÅfe, ob */
			{                            /* Fenster ganz oben liegt */
				wind_get(0, WF_TOP, &act_wh, 0,0,0);
				if (act_wh == ptr->w_handle) /* Wenn ja, erzwinge */
				{                            /* Cursor Redraw     */
					ptr->dialog->cont     = TRUE;
					ptr->dialog->next_obj = ptr->dialog->edit_obj;
					ptr->dialog->edit_obj = 0;
				}
			}
			break;
		case WM_CLOSED:      /* Fenster soll geschlossen werden */
			if(ptr->close_code!=NULL)   /* POWERGEM-Nutzer gibt frei */
				if(ptr->close_code(ptr) !=0 )
					break;    /* Will es der POWERGEM-Nutzer auch ? */
			if(app_cntrl.modal != NULL)
				{
				app_cntrl.modal=NULL; /* Fenster nach schlieûen der modalen
								  Dialogbox freigeben */
				menu_all_change(1); /* MenÅ wie vorher an */
				}
			wind_get(ptr->w_handle, WF_CURRXYWH, &x, &y, &w, &h);
			graf_shrinkbox(0,0,0,0, x,y,w,h);
			wind_close(ptr->w_handle); 
			wind_delete(ptr->w_handle); /* Alles, was mit dem Fenster zusam- */
			if (ptr->type & DIAL_WINDOW || (ptr->type & PANEL_WINDOW))
				kill_button(ptr);
			kill_window(ptr->w_handle); /* menhÑngt, wird aus dem Speicher   */
			wind_get(0, WF_TOP, &(app_cntrl.w_handle), 0,0,0); /* entfernt   */
			ptr=get_winfh(app_cntrl.w_handle);
			if(ptr)
				{
				if(ptr->wtop_code) /* das Fenster darunter wurde somit   */
					ptr->wtop_code(ptr);/* unfreiwillig getoppt          */  
				}	
			break;
		case WM_MOVED:  /* Fenster wurde verschoben/vergrîûert/verkleinert */
		case WM_SIZED:  /* Neue Fensterausmaûe erfragen */
			wind_set(ptr->w_handle, WF_CURRXYWH, x,y,max(ptr->min_w,
	    		  min(w,ptr->actual_position.g_w)), max(ptr->min_h,
	    		  		min(h,ptr->actual_position.g_h)));

			wind_get(ptr->w_handle, WF_WORKXYWH, &ptr->workarea.g_x, &ptr->workarea.g_y,
						&ptr->workarea.g_w, &ptr->workarea.g_h);
			  
			if (ptr->type & DIAL_WINDOW) /* Bei Dialogen wird die OBJECT- */
				align_dial(ptr);

			if (ptr->type & PANEL_WINDOW)
				align_panel(ptr);

			change_slider_size(ptr);
			break;
		case WM_TOPPED: /* Neues Fenster soll nach oben gebracht werden */
		case WM_NEWTOP:
			win=start; /* evtl. Cursor im alten Fenster aus !*/
			if(win)
				{
				if( win->type & DIAL_WINDOW)
					{
					if(ObjTree(win)[win->dialog->edit_obj].ob_type ==G_FTEXT 
					|| ObjTree(win)[win->dialog->edit_obj].ob_type ==G_FBOXTEXT)
					objc_edit(win->dialog->tree, win->dialog->edit_obj, 0,
						  &(win->dialog->idx), ED_END); 	
					}
				}
			wind_set(ptr->w_handle, WF_TOP, 0,0,0,0);
			win = get_winfh(app_cntrl.w_handle);
			if(!win)
				break;
			if (win->type & DIAL_WINDOW)
				win->dialog->cont = FALSE;
			app_cntrl.w_handle = ptr->w_handle;
			win = get_winfh(ptr->w_handle);
			if(!win)
				printf("\n Great mistake 2 in win_manager !");
			if (win->type & DIAL_WINDOW)
				win->dialog->cont = TRUE;
			if(win->wtop_code) 		/* Erste Reaktion des Fensters */ 
				win->wtop_code(win);
			sort_win_by_top(win);  /* Pointer neu sortieren */
			break;
		case WM_FULLED: /* Fenster auf volle Grîûe/letzte Position bringen */
			if ((ptr->fulled ^= TRUE))
				wind_get(ptr->w_handle, WF_FULLXYWH, &x, &y, &w, &h);
			else
				wind_get(ptr->w_handle, WF_PREVXYWH, &x, &y, &w, &h);
			wind_set(ptr->w_handle, WF_CURRXYWH, x,y,w,h);
			wind_get(ptr->w_handle, WF_WORKXYWH, &ptr->workarea.g_x, &ptr->workarea.g_y,
						&ptr->workarea.g_w, &ptr->workarea.g_h); 	 	

			if (ptr->type & PANEL_WINDOW)
				align_panel(ptr);

  			change_slider_size(ptr);			
			break;
		case WM_ARROWED: /* Sliderverwaltung */
			hndl_slider_pos(ptr, x, 0);
			break;
		case WM_VSLID:
			hndl_slider_pos(ptr, V_SLIDE, x);
			break;
		case WM_HSLID:
			hndl_slider_pos(ptr, H_SLIDE, x);
	}
}



/* ---------------------------------------------------------------------- */
/* Auskunftsfunktionen                                                    */
/* ---------------------------------------------------------------------- */
/************************************************
 * Arbeitsbereich eines  Fensters bzw. des      * 
 * Desktops ermitteln			    		    *
 * Input: win Zeiger auf Window-Struktur        *
 *            (bei Null -> Desktop-Koordinaten) *
 * 		  rc  Zeiger auf Rechteckstruktur fÅr   *
 *            Ergebnisdaten						*
 ************************************************/
void get_workarea(struct WINDOW *win, GRECT *rc)
{
if(win)	
	copy_grect(&win->workarea, rc);
else
	copy_grect(&app_cntrl.workarea, rc);
}	

/* ---------------------------------------------------------------------- */
/* Fensterposition ermitteln                                              */
/* ---------------------------------------------------------------------- */
void get_winpos(struct WINDOW *win, GRECT *rc)
{
	copy_grect(&win->actual_position, rc);
}

/**************************************************************************
 * Horizontale Sliderposition abfragen									  *
 * Input: win Zeiger auf aktuelle Fensterverwaltungsstruktur			  *
 **************************************************************************/
int get_y_slider(struct WINDOW *win)
{
if(win)
	{
	if(win->slider)
		return(win->slider->y_offset);
	}
return 0;	
}

/**************************************************************************
 * Vertikale Sliderposition abfragen									  *
 * Input: win Zeiger auf aktuelle Fensterverwaltungsstruktur			  *
 **************************************************************************/
int get_x_slider(struct WINDOW *win)
{
if(win)
	{
	if(win->slider)
		return(win->slider->x_offset);
	}
return 0;	
}

/* ---------------------------------------------------------------------- */
/* énderungsfunktionen                                                    */
/* ---------------------------------------------------------------------- */
/***************************
 * Setzt die Mausposition  *
 ***************************/
void set_mousepos(int x,int y)
{
int buf[4];
buf[0]=0;		/* muû null sein  		 */
buf[1]=2;		/* Code fÅr Mausbewegung */
buf[2]=x;		/* x-Koordinate			 */
buf[3]=y;		/* y-Koordinate			 */
appl_tplay(&buf[0],1,100); /* abspielen  */
}
/**************************************************************************
 * Horizontale Sliderposition setzen evtl. Unter/Åberschreitungen		  *
 * werden erkannt und korrigiert 										  *
 * Slider wird upgedatet												  *	
 * Input: win Zeiger auf aktuelle Fensterverwaltungsstruktur			  *
 *        new neuer Wert												  *	
 **************************************************************************/
void set_y_slider(struct WINDOW *win,int new_y_offset)
{
int h;

if(win)
	{
	if(win->slider)
		{	
		if((h = win->workarea.g_h / win->slider->y_size) 
		* win->slider->y_size > win->workarea.g_h)
			h--;

		if(new_y_offset < 0)
			new_y_offset=0;
		else
			if((long)new_y_offset + (long)h > (long)win->slider->y_elements)
				new_y_offset=  win->slider->y_elements-h;			
			
		if(new_y_offset == win->slider->y_offset)
			return;
		else
			{
			win->slider->y_offset=new_y_offset;
			new_slider_pos(win); /* Slider updaten */
			}
		}
	}
}
/**************************************************************************
 * Vertikale Sliderposition setzen evtl. Unter/Åberschreitungen		  	  *
 * werden erkannt und korrigiert 										  *
 * Input: win Zeiger auf aktuelle Fensterverwaltungsstruktur			  *
 *        new neuer Wert												  *	
 **************************************************************************/
void set_x_slider(struct WINDOW *win,int new_x_offset)
{
int w;

if(win)
	{
	if(win->slider)
		{
		if((w = win->workarea.g_w / win->slider->x_size) 
		* win->slider->x_size > win->workarea.g_w)
			w--;
		if(new_x_offset < 0)
			new_x_offset=0;
		else
			if((long)new_x_offset + (long)w > (long)win->slider->x_elements)
				new_x_offset=  win->slider->x_elements-w;			

		if(new_x_offset < 0)
			new_x_offset=0;

		if(win->slider->x_offset == new_x_offset)
			return;
		else
			{
			win->slider->x_offset=new_x_offset;
			new_slider_pos(win); /* Slider updaten */
			}
		}
	}
}
	
 
/* ---------------------------------------------------------------------- */
/* Fensterposition setzen                                                 */
/* ---------------------------------------------------------------------- */
void set_winpos(struct WINDOW *win, GRECT *rc)
{
	copy_grect(rc, &win->actual_position);
}
/* ---------------------------------------------------------------------- */
/* Dialog Manager                                                         */
/* ---------------------------------------------------------------------- */
/* Dialog erzeugen                        										  */
/* ---------------------------------------------------------------------- */
struct WINDOW *create_dial(int obj_name, int start_obj, int wi_flags,int modal, 
						   void (*slide_code)(struct WINDOW *win,
						 				      int message), 
						   void (*button_code)(struct WINDOW *win, int mx,
												   int my, int mb, int ks),
						   void (*key_code)(struct WINDOW *win,
										    char ascii),
					   	  void (*wtop_code)(struct WINDOW *win),

						   void (*release)(int obj_index, int obj_state))		 					  
{
	struct WINDOW *win;
	OBJECT *tree;
	GRECT r1 = {0,0,0,0}, r2 = {0,0,0,0};
	int msgbuff[8] = {0,0,0,0,0,0,0,0};
	int type_flag=DIAL_WINDOW;
	int mx,my,dummy;

	if(modal)
		type_flag|=MODAL;				

	if (rsrc_gaddr(0, obj_name, &tree))
	{
		help = start;
		while (help)
		{
			if ((help->dialog) && (help->dialog->tree) && 
				 (help->dialog->tree == tree))
			{
				msgbuff[0] = WM_TOPPED;
				msgbuff[1] = app_cntrl.ap_id;
				msgbuff[3] = help->w_handle;
				appl_write(app_cntrl.ap_id, 16, msgbuff);

				if(!(help->type & DIAL_WINDOW))
					return(NULL);
				help->dialog->next_obj = fm_inifld(help->dialog->tree, start_obj);
				help->type        = type_flag&7; 	
			    help->slide_code  = slide_code;
				help->button_code = button_code;
				help->key_code    = key_code;						    
				help->wtop_code   = wtop_code;
				help->dialog->release = release;
				return(help); /* es lÑût sich darÅber streiten ob
				NULL oder help (Es wurde dementsprechend vorher 
				diese Dialogbox mit z. B. evtl. anderen ! TEXTEN geschloûen).  
				Vorsicht ist trotzdem geboten ! */	
			}
			help = help->next;
		}

		wind_get(0, WF_WORKXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	
		r2.g_x = tree->ob_x;
		r2.g_y = tree->ob_y;
		r2.g_w = tree->ob_width;
		r2.g_h = tree->ob_height;
		wind_calc(0, wi_flags, r2.g_x, r2.g_y, r2.g_w, r2.g_h,
				    &r2.g_x, &r2.g_y, &r2.g_w, &r2.g_h);
		
		/* unter der Maus positionieren */
		graf_mkstate( &mx,&my,&dummy,&dummy);
		r2.g_x= mx + r2.g_w/2; 
		r2.g_y= my + r2.g_h/2;
		r2.g_x=  min(r2.g_x - r2.g_w,app_cntrl.workarea.g_x +
		app_cntrl.workarea.g_w -r2.g_w);
		
		r2.g_y=  min(r2.g_y - r2.g_h,app_cntrl.workarea.g_y +
		app_cntrl.workarea.g_h -r2.g_h);
		r2.g_x = max(r2.g_x,app_cntrl.workarea.g_x);
		r2.g_y = max(r2.g_y,app_cntrl.workarea.g_y);
		
		win = create_window(&r1, &r2, tree->ob_width, tree->ob_height,
								  wi_flags, type_flag, 0, slide_code, button_code,
								  key_code,wtop_code,0);
		if (!win)
			return(NULL);		
	
		wind_calc(1, wi_flags, r2.g_x, r2.g_y, r2.g_w, r2.g_h,
					 &r2.g_x, &r2.g_y, &r2.g_w, &r2.g_h);
		tree->ob_x = r2.g_x;
		tree->ob_y = r2.g_y; 
	
		win->dialog = (struct dial *)calloc(1, sizeof(struct dial));
		if (!win->dialog)
			return(NULL);
		
		win->dialog->release = release;
		win->dialog->tree = tree;
		win->dialog->cont = TRUE;
		win->dialog->next_obj = fm_inifld(win->dialog->tree, start_obj);
		win->dialog->edit_obj = 0;
		return(win);
	}
	else
		return(NULL);
}   


void draw_dial(struct WINDOW *win, GRECT *rc)
{
	objc_draw(win->dialog->tree, 0,MAX_DEPTH, 
	                              rc->g_x, rc->g_y, rc->g_w, rc->g_h);
}

void draw_object(struct WINDOW *win,int obj_index)
	{
	int x,y,w,h;

	x=win->dialog->tree[obj_index].ob_x + win->dialog->tree[0].ob_x;
	y=win->dialog->tree[obj_index].ob_y + win->dialog->tree[0].ob_y;;
	w=win->dialog->tree[obj_index].ob_width + win->dialog->tree[0].ob_width;
	h=win->dialog->tree[obj_index].ob_height + win->dialog->tree[0].ob_height;
	objc_draw( win->dialog->tree,obj_index,0,x,y,w,h);
	}

int fm_inifld(OBJECT *tree, int start_obj)
{
	if (start_obj == 0)
		start_obj = find_obj(tree);
	return(start_obj);
}
 

int find_obj(OBJECT *tree)
{
	int obj = 0;
	
	while (!(tree[obj].ob_flags & LASTOB))
	{
		if (tree[obj].ob_flags & EDITABLE)
			return(obj);
		obj++;
	}
	return(0);
}

/* ---------------------------------------------------------------------- */
/* Button Manager																			  */
/* ---------------------------------------------------------------------- */
/* DESKTOP Button-Funktion anmelden                                       */
/* ---------------------------------------------------------------------- */
void set_button_fnc(void (*button_code)(int m_x, int m_y, int mb_state,
				        int k_state))
{
	app_cntrl.button_code = button_code;
}


/* ---------------------------------------------------------------------- */
/* Speicher fÅr Button-Ereignis alloziieren                               */
/* ---------------------------------------------------------------------- */
struct BUTTON_LIST *alloc_button(struct WINDOW *win)
{
	struct BUTTON_LIST *help;

	help = win->dialog->button_start;
	win->dialog->button_start = (struct BUTTON_LIST *)calloc(1,
								 sizeof(struct BUTTON_LIST));
	win->dialog->button_start->next = help;
	return(win->dialog->button_start);
}


/* ---------------------------------------------------------------------- */
/* Button-Ereignis anmelden                                               */
/* ---------------------------------------------------------------------- */
void button_action(struct WINDOW *win, int obj_index, void (*action)(void),
						 boolean redraw)
{
	struct BUTTON_LIST *ptr;
	ptr = alloc_button(win);
	if (ptr)
	{
	 	ptr->tree      = win->dialog->tree;
		ptr->obj_index = obj_index;
		ptr->action    = action;
		ptr->redraw    = redraw;
	}
}


/* ---------------------------------------------------------------------- */
/* Button-Ereignisse bearbeiten     												  */
/* ---------------------------------------------------------------------- */
void button_manager(int m_x, int m_y, int m_button, int k_state)
{
	struct BUTTON_LIST *help;

	int obj_index, obj_state;
	struct WINDOW *win;
	int buffer[8] = {0,0,0,0,0,0,0,0};
	
	win = get_winfh(app_cntrl.w_handle);
	if(!win)
		{printf("\n Great Error in button_manager");return;}
	
	if ((win->type & DIAL_WINDOW) || (win->type & PANEL_WINDOW))
	{
		if ((obj_index = objc_find(win->dialog->tree, 0, 8, m_x, m_y)) >= 0)
			{
			help = win->dialog->button_start;
			while (help) 
				{
				if (obj_index == help->obj_index)
					{
					if ((win->dialog->tree[obj_index].ob_flags & TOUCHEXIT))
						{
						obj_state = win->dialog->tree[obj_index].ob_state;
						obj_state ^= SELECTED;
						objc_change(win->dialog->tree, obj_index, 0, 
					   	         win->workarea.g_x, win->workarea.g_y, 
					      	      win->workarea.g_w, win->workarea.g_h, 
					         	   obj_state, 1);
						}
					
					if(help->action);
						help->action();
	
					if (help->redraw)
						{
						buffer[0] = WM_REDRAW;
						buffer[1] = app_cntrl.ap_id;
						buffer[3] = win->w_handle;
						buffer[4] = win->workarea.g_x;
						buffer[5] = win->workarea.g_y;
						buffer[6] = win->workarea.g_w;
						buffer[7] = win->workarea.g_h;
						appl_write(app_cntrl.ap_id, 16, buffer);
						}

					break;
					}
				help = help->next;
				}
			}
		else
			if(win->button_code)
				win->button_code(win, m_x, m_y, m_button, k_state); 
	}
}


/* ---------------------------------------------------------------------- */
/* Button-Liste freigeben  															  */
/* ---------------------------------------------------------------------- */
void kill_button(struct WINDOW *win)
{
	struct BUTTON_LIST *help;

	help = win->dialog->button_start;
	while(win->dialog->button_start)
	{
		win->dialog->button_start = help->next;
		free(help);
		help = win->dialog->button_start;
	}
}
	
	

/* ---------------------------------------------------------------------- */
/* Dialog abbrechen (bsp. "Abbruch" - Button im Dialog gedrÅckt)          */
/* ---------------------------------------------------------------------- */
void break_dial(void)
{
break_win(get_winfh(app_cntrl.w_handle));
}
/*********************************************************
 * Fenster schlieûen, so ist es auch mîglich, Fenster 	 *
 * per Tastatur zu schlieûen.							 *	
 * Input: win	zu schlieûendes Fenster					 *
 *********************************************************/
void break_win(struct WINDOW *win)
{
int buffer[8] = {0,0,0,0,0,0,0,0};

if (win)
	{
	win->type|=CLOSED;/* Kennung, so daû keine sinnlosen REDRAWS */
	buffer[0] = WM_CLOSED;
	buffer[1] = app_cntrl.ap_id;
	buffer[3] = win->w_handle;
	appl_write(app_cntrl.ap_id, 16, buffer);
	}
}
/******************************************************************
 * Adresse eines Zeichenbuffers in TEDINFO-Struktur eintragen     *        
 * und updaten 													  *			
 * Input: win Fensterstruktur 									  *
 *        obj_index upzudatendes Objekt							  *
 *        buf Zeiger auf neuen Text								  *
 *		  lenght LÑnge des Textes								  *			
 *        redraw Sofortiges Redraw bei TRUE 					  *
 ******************************************************************/
void set_text(struct WINDOW *win, int obj_index, char *buf, int length,
														boolean redraw)
{
if(!win)
	return;
win->dialog->tree[obj_index].ob_spec.tedinfo->te_ptext  = buf;
win->dialog->tree[obj_index].ob_spec.tedinfo->te_txtlen = length+1;

if(redraw ==TRUE) /* REDRAW */
	{
	int x,y,w,h;
	x=win->dialog->tree[obj_index].ob_x + win->dialog->tree[0].ob_x;
	y=win->dialog->tree[obj_index].ob_y + win->dialog->tree[0].ob_y;;
	w=win->dialog->tree[obj_index].ob_width;
	h=win->dialog->tree[obj_index].ob_height;
    blank(win, x, y, w, h);
	}
}
/********************************************************
 * Testet ob Åbergebene Koordinatenpaar innerhalb       *
 * eines Rechteckes sind.                               *
 * Input: x    x-Koordinate                             *  
 *        y    y-Koordinate                             *
 *        rect Zeiger auf Rechteckkoordinaten           *                   
 * Output: TRUE innerhalb des Rechteckes                *
 *         FALSE auûerhalb                              *              
 ********************************************************/
boolean check_rect(int x,int y,GRECT *rect)
{
if(x >= rect->g_x && y >= rect->g_y &&
   x <= (rect->g_x + rect->g_w) && y <= (rect->g_y + rect->g_h))
	return TRUE;

return FALSE;
}
/* ---------------------------------------------------------------------- */
/* Button selektieren 																	  */
/* ---------------------------------------------------------------------- */
void select_btn(struct WINDOW *win, int obj_index, boolean redraw)
{
	if ((win) && (obj_index != 0) && (!(win->dialog->tree[obj_index].ob_state
		 & SELECTED)))
		objc_change(win->dialog->tree, obj_index, 0, win->workarea.g_x,
						win->workarea.g_y, win->workarea.g_w, win->workarea.g_h,
						win->dialog->tree[obj_index].ob_state | SELECTED, redraw);
}


/* ---------------------------------------------------------------------- */
/* Button deselektieren                                                   */
/* ---------------------------------------------------------------------- */
void unselect_btn(struct WINDOW *win, int obj_index, boolean redraw)
{
	if ((win) && (obj_index != 0) && (win->dialog->tree[obj_index].ob_state 
		 & SELECTED))
		objc_change(win->dialog->tree, obj_index, 0, win->workarea.g_x,
					   win->workarea.g_y, win->workarea.g_w, win->workarea.g_h,
					   win->dialog->tree[obj_index].ob_state ^ SELECTED, redraw);
}



/* ---------------------------------------------------------------------- */
/* Button selektiert ?  --> TRUE oder FALSE                               */
/* ---------------------------------------------------------------------- */
boolean get_objstate(struct WINDOW *win, int obj_index)				   
{
	return(win->dialog->tree[obj_index].ob_state & SELECTED);
}
	
/* ---------------------------------------------------------------------- */
/* Key Manager                                                            */
/* ---------------------------------------------------------------------- */
/* Speicher fÅr Tastatur-Ereignis alloziieren									  */
/* ---------------------------------------------------------------------- */
struct KEY_LIST *alloc_key()
{
	struct KEY_LIST *help;
	
	help = key_start;
	key_start = (struct KEY_LIST *)calloc(1, sizeof(struct KEY_LIST));
	key_start->next = help;
	return(key_start);
}


/* ---------------------------------------------------------------------- */
/* Tastatur-Ereignis anmelden   														  */
/* ---------------------------------------------------------------------- */
void key_action(int code, void (*action)(void))
{
	struct KEY_LIST *ptr;
	ptr = alloc_key();
	if (ptr)
	{
	 	ptr->code   = code;
		ptr->action = action;
	}
}


/* ---------------------------------------------------------------------- */
/* Tastatur-Ereignisse bearbeiten                                         */
/* ---------------------------------------------------------------------- */
void key_manager(int code)
{
	struct KEY_LIST *help;
	
	help = key_start;

	while (help)
	{
		if (code == help->code)
			if(help->action)
				help->action();
		help = help->next;
	} 
}	



/* ---------------------------------------------------------------------- */
/* Key-Liste freigeben																	  */
/* ---------------------------------------------------------------------- */
void kill_key(void)
{
	struct KEY_LIST *help;

	help = key_start;
	while(key_start)
	{
		key_start = help->next;
		free(help);
		help = key_start;
	}
}

/* ---------------------------------------------------------------------- */
/* Menu Manager 																			  */
/* ---------------------------------------------------------------------- */
/* Speicher fÅr MenÅ-Ereignis reservieren                                 */
/* ---------------------------------------------------------------------- */                 
struct MENU_LIST *alloc_menu(void)
{
	struct MENU_LIST *help;

	help = menu_start;
	menu_start = (struct MENU_LIST *)calloc(1, sizeof(struct MENU_LIST));
	menu_start->next = help;
	return(menu_start);
}


/* ---------------------------------------------------------------------- */
/* MenÅ-Ereignis anmelden                                                 */
/* ---------------------------------------------------------------------- */
void menu_action(int title, int item, int scan_code, void (*action)(void))
{
	struct MENU_LIST *ptr;
	ptr = alloc_menu();
	if (ptr)
	{
	 	ptr->title     = title;
		ptr->item      = item;
		ptr->scan_code = scan_code;
		ptr->action    = action;
	}
} 
/*******************************************
 * MenÅeintrÑge ein/auschalten             *
 * Input: menu_flag 0 ALLE auschalten 	   *
 *                  1 Zustand rÅcksetzen   *
 *******************************************/
void menu_all_change(int menu_flag)		  
{
struct MENU_LIST *help;
	
help = menu_start;
while(help)
	{
	menu_ienable( app_cntrl.menu,help->item,menu_flag );

	if(((app_cntrl.menu+help->item)->ob_state&DISABLED) == 0 &&
		menu_flag==0)
		menu_ienable( app_cntrl.menu,help->item,0);

	if(((app_cntrl.menu+help->item)->ob_state&DISABLED) == 1 &&
		menu_flag==1)
		menu_ienable( app_cntrl.menu,help->item,1);
	
	help = help->next;
	}
}

/* ---------------------------------------------------------------------- */
/* MenÅ-Ereignisse bearbeiten                                             */
/* ---------------------------------------------------------------------- */
void menu_manager(int title, int item, int scan_code)
{
	struct MENU_LIST *help;
	OBJECT *menue;
	menue=get_app_cntrl()->menu;
	help = menu_start;

	while (help)
	{
		if (((title == help->title && item == help->item) ||
			 (scan_code == help->scan_code)) && 	
			 (((menue+help->item)->ob_state&DISABLED) == 0)) 
			 
		{
			if(help->action)
				help->action();
			menu_tnormal(app_cntrl.menu, title, 1);
			return;
		}
		help = help->next;
	} 		
}	


/* ---------------------------------------------------------------------- */
/* Menu-Liste freigeben                                                   */
/* ---------------------------------------------------------------------- */
void kill_menu()
{
	struct MENU_LIST *help;

	help = menu_start;
	while(menu_start)
	{
		menu_start = help->next;
		free(help);
		help = menu_start;
	}
}

/*------------------------------------------------------------------------*/
/* Message Manager               													  */
/*------------------------------------------------------------------------*/
/* Speicher fÅr Message-Ereignis alloziieren                              */
/* ---------------------------------------------------------------------- */
struct MSG_LIST *alloc_msg(void)
{
	struct MSG_LIST *help;
	
	help = msg_start;
	msg_start = (struct MSG_LIST *)calloc(1, sizeof(struct MSG_LIST));
	msg_start->next = help;
	return(msg_start);
}



/*------------------------------------------------------------------------*/
/* Message-Ereignis anmelden                                              */
/* ---------------------------------------------------------------------- */
void msg_action(int event, void (*action)(int *))
{
	struct MSG_LIST *ptr;
	ptr = alloc_msg();
	if (ptr)
	{
	 	ptr->event  = event;
		ptr->action = action;
	}
}



/*------------------------------------------------------------------------*/
/* Message-Ereignisse bearbeiten                                          */
/* ---------------------------------------------------------------------- */
void msg_manager(int *event)
{
	struct MSG_LIST *help;
	
	help = msg_start;
	while (help) 
	{
		if (event[0] == help->event)
			help->action(event);
		help = help->next;
	} 
}	



/*------------------------------------------------------------------------*/
/* Message-Liste freigeben                                                */
/* ---------------------------------------------------------------------- */
void kill_msg()
{
	struct MSG_LIST *help;

	help = msg_start;
	while(msg_start)
	{
		msg_start = help->next;
		free(help);
		help = msg_start;
	}
}
/* EOF */