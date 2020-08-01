/* Bewegliche Dialogboxen aus der ST-Computer 12/90 */
/* Anpassung an Mark Williams C Version 3.09 durch 
   Michael Kovar, am 03.02.1991

   letzte énderung am 25.07.1992
   EinfÅgen von bildschirmrettenden Funktionen bei MOVEBOXEN
   Debugging der Funktionen 21.10.1992

   letzte énderung am 19.11.1992
   movebox() beachtet TT-Auflîsungen korrekt 

*/

/* Aktuelle Version 1.2 v. 19.11.1992 */

#include <stdio.h>
#include <aesbind.h>
#include <vdibind.h>
#include <gemdefs.h>
#include <obdefs.h>
#include "window.h"

#define EDINIT 1
#define EDEND 3

/* Globale Werte dieses Moduls */
extern int ap_id, vdi_handle;	/* Handle der virtuellen Arbeitsstation */
extern ACT aktuell;
extern WIND_DATA *windows;
extern char *dial_info();

static IMAGE a_grund = { 0, 0, 0L };	/* zum Speichern vom Bildhintergrund */


/* +----------------------------------------------------------------+ */
/* ! dient zum exporieren des Zeigers auf Bildschirmhintergrund bei ! */
/* ! verschachteltem Aufruf von beweglichen Dialogboxen             ! */
/* +----------------------------------------------------------------+ */

get_image_ptr(e)
IMAGE *e;
{
	e->breite = a_grund.breite;
	e->hoehe = a_grund.hoehe;
	e->getbuf = a_grund.getbuf;
}


/* +----------------------------------------------------------------+ */
/* ! dient zum Herstellen des Zeigers auf Bildschirmhintergrund bei ! */
/* ! verschachteltem Aufruf von beweglichen Dialogboxen             ! */
/* +----------------------------------------------------------------+ */

restore_image_ptr(e)
IMAGE *e;
{
	a_grund.breite = e->breite;
	a_grund.hoehe = e->hoehe;
	a_grund.getbuf = e->getbuf;
}


/* +----------------------------------------+ */
/* ! Vorbereitung zur Dialogbox-Darstellung ! */
/* + ---------------------------------------+ */

long vor_dial(dialbox, dialtype)
OBJECT	*dialbox;
int	dialtype;
{
	GRECT	a;
	int	mx, my, dummy;
	GRECT	desk;
	register long ret = 0L;


	/* Fenstererneuerung */
	wind_update(BEG_UPDATE);

	switch(dialtype)
	{
		case 1 :	/* MOVEDIAL */
				if((dialbox->ob_x == 0) && (dialbox->ob_y == 0))
				{
					form_center(dialbox, &a.g_x, &a.g_y,
								&a.g_w, &a.g_h);
				}
				else
				{
					a.g_x = dialbox->ob_x - 3;
					a.g_y = dialbox->ob_y - 3;
					a.g_w = dialbox->ob_width + 6;
					a.g_h = dialbox->ob_height + 6;
				}
				graf_mouse(M_OFF, 0L);
				ret = get_image(a.g_x, a.g_y,
					  a.g_x + a.g_w, a.g_y + a.g_h,
					  &a_grund);
				graf_mouse(M_ON, 0L);

				break;

		case 2 :	/* POPUPDIAL */
				dummy = evnt_button(1,1,0,&mx,&my,&dummy,&dummy);
				wind_get(0, WF_WORKXYWH, &desk.g_x, &desk.g_y,
						&desk.g_w, &desk.g_h);
				a.g_x = mx - (dialbox->ob_width / 2);

				if(a.g_x < desk.g_x)
					a.g_x = desk.g_x;

				if((a.g_x + dialbox->ob_width) > (desk.g_x + 
								  desk.g_w))
					a.g_x = desk.g_w - dialbox->ob_width;
				
				dialbox->ob_x = (a.g_x > 3) ? a.g_x : 4;

				a.g_y = my - (dialbox->ob_height / 2);
				if(a.g_y < desk.g_y)
					a.g_y = desk.g_y;

				if((a.g_y + dialbox->ob_height) > (desk.g_y + 
								   desk.g_h))
					a.g_y = desk.g_h - dialbox->ob_height;

				dialbox->ob_y = (a.g_y > 3) ? a.g_y : 4;

				/* Clipping-Bereich einstellen */
				a.g_x = dialbox->ob_x - 3;
				a.g_y = dialbox->ob_y - 3;
				a.g_w = dialbox->ob_width + 6;
				a.g_h = dialbox->ob_height + 6;

				break;

		default :	/* Standard-Dialogbox */
				form_center(dialbox, &a.g_x, &a.g_y, &a.g_w,
							&a.g_h);
				break;
	}
	form_dial(FMD_START, 0, 0, 0, 0, 
				a.g_x, a.g_y, a.g_w, a.g_h);


}

/* +--------------------------------+ */
/* ! Dialogbox vollstÑndig zeichnen ! */
/* +--------------------------------+ */

void draw_dial(dialbox, dialtype)
OBJECT	*dialbox;
int	dialtype;
{
	GRECT a;


	switch(dialtype)
	{
		case 1 :	/* Movedials */
				a.g_x = dialbox->ob_x - 3;
				a.g_y = dialbox->ob_y - 3;
				a.g_w = dialbox->ob_width + 6;
				a.g_h = dialbox->ob_height + 6;
				break;

		case 2 :	/* Popupdial */
				a.g_x = dialbox->ob_x - 3;
				a.g_y = dialbox->ob_y - 3;
				a.g_w = dialbox->ob_width + 6;
				a.g_h = dialbox->ob_height + 6;
				break;

		default : 	/* Standarddialog */
				form_center(dialbox, &a.g_x, &a.g_y, &a.g_w,
						&a.g_h);
				break;
	}

	objc_draw(dialbox, ROOT, MAX_DEPTH, a.g_x, a.g_y, a.g_w, a.g_h);
}


/* +----------------------------------------+ */
/* ! Nachbreitung der Dialogbox-Darstellung ! */
/* +----------------------------------------+ */

void nach_dial(dialbox, dialtype)
OBJECT	*dialbox;
int	dialtype;
{
	GRECT	a;
	int	clip[4]; /* Clipping-Rectangle */


	switch(dialtype)
	{
		case 1 :	/* Movedial */
				a.g_x = dialbox->ob_x - 3;
				a.g_y = dialbox->ob_y - 3;
				a.g_w = dialbox->ob_width + 6;
				a.g_h = dialbox->ob_height + 6;
				clip[0] = a.g_x;
				clip[1] = a.g_y + a.g_h;
				clip[2] = a.g_x + a.g_w;
				clip[3] = a.g_y;
				vs_clip(vdi_handle, 1, clip);
				graf_mouse(M_OFF, 0L);
				put_image(a.g_x, a.g_y,
					  0, 0, 0, 0, &a_grund, S_ONLY);
				graf_mouse(M_ON, 0L);
				vs_clip(vdi_handle, 0, clip);

				release_image(&a_grund);

				break;

		case 2 : 	/* Popupdial */
				a.g_x = dialbox->ob_x - 3;
				a.g_y = dialbox->ob_y - 3;
				a.g_w = dialbox->ob_width + 6;
				a.g_h = dialbox->ob_height + 6;
				break;

		default : 	/* Standardbox */
				form_center(dialbox, &a.g_x, &a.g_y, &a.g_w,
						&a.g_h);
				break;

	}
	form_dial(FMD_FINISH, 0, 0, 0, 0, 
			      a.g_x, a.g_y, a.g_w, a.g_h);
	wind_update(END_UPDATE);
}

/* +---------------------------------------------+ */
/* ! Movedial-Box auf dem Bildschirm verschieben ! */
/* +---------------------------------------------+ */

void movedial(dialbox, dialtype)
OBJECT	*dialbox;
int	dialtype;
{
	GRECT	desk;
	int	nx, ny;
	int	clip[4];	/* Clipping-Rectangle */


	if(dialtype == 1)
	{
		wind_update(BEG_UPDATE);
		wind_update(BEG_MCTRL);
		graf_mouse(FLAT_HAND, 0L);

		wind_get(0, WF_WORKXYWH, &desk.g_x, &desk.g_y, &desk.g_w,
						&desk.g_h);

		desk.g_y += 3;
		desk.g_w -= 7;
		desk.g_h -= 7;
		desk.g_x += 3;

		graf_dragbox(dialbox->ob_width, dialbox->ob_height,
			     dialbox->ob_x, dialbox->ob_y,
			     desk.g_x, desk.g_y, desk.g_w, desk.g_h,
			     &nx, &ny);


		form_dial(FMD_FINISH, 0, 0, 0, 0,
			(dialbox->ob_x - 3), (dialbox->ob_y - 3),
			(dialbox->ob_width + 6), (dialbox->ob_height + 6));

		/* Clipping setzen */
		clip[0] = dialbox->ob_x - 3;
		clip[1] = dialbox->ob_y + dialbox->ob_height + 3;
		clip[2] = dialbox->ob_x + dialbox->ob_width + 3;
		clip[3] = dialbox->ob_y - 3;
		vs_clip(vdi_handle, 1, clip);
		graf_mouse(M_OFF, 0L);
		put_image(dialbox->ob_x - 3, dialbox->ob_y - 3, 0, 0, 0, 0,
			  &a_grund, S_ONLY);
		vs_clip(vdi_handle, 0, clip);
		graf_mouse(M_ON, 0L);
		release_image(&a_grund);

		dialbox->ob_x += (nx - dialbox->ob_x);
		dialbox->ob_y += (ny - dialbox->ob_y);

		form_dial(FMD_START, 0, 0, 0, 0,
			(dialbox->ob_x - 3), (dialbox->ob_y - 3),
			(dialbox->ob_width + 6), (dialbox->ob_height + 6));

		a_grund.hoehe = a_grund.breite = 0;
		a_grund.getbuf = 0L;
		
		graf_mouse(M_OFF, 0L);
		get_image(dialbox->ob_x - 3, dialbox->ob_y - 3,
			  dialbox->ob_x + dialbox->ob_width + 3,
			  dialbox->ob_y + dialbox->ob_height + 3,
			  &a_grund);
		graf_mouse(M_ON, 0L);

		graf_mouse(ARROW, 0L);
		wind_update(END_MCTRL);
		wind_update(END_UPDATE);
	}
}

/* +---------------------------+ */
/* ! Movedial-Dialog erledigen ! */
/* +---------------------------+ */

int do_movedial(tree, dragger, obj)
OBJECT	*tree;
int	dragger, obj;
{
	register int ret, type;
	register long status;


	status = vor_dial(tree, 1);
	type = (status == 0L) ? 0 : 1;

	do
	{
		draw_dial(tree, type);
		ret = (exform_do(tree, obj) & 0x7fff);
		tree[ret].ob_state &= ~SELECTED;

		if(ret == dragger)
			movedial(tree, type);
	} while (ret == dragger);

	nach_dial(tree, type);

	return(ret);
}

/* +----------------------------+ */
/* ! Popup - Dialog durchfÅhren ! */
/* +----------------------------+ */

int do_popup(tree, obj)
OBJECT	*tree;
int	obj;
{
	register int	ret;

	vor_dial(tree, 2);
	draw_dial(tree, 2);

	ret = exform_do(tree, obj) & 0x7fff;

	tree[ret].ob_state &= ~SELECTED;

	nach_dial(tree, 2);
	return(ret);
}

/* +----------------------------+ */
/* ! Normal- Dialog durchfÅhren ! */
/* +----------------------------+ */

int do_dial(tree, obj)
OBJECT	*tree;
int	obj;
{
	register int	ret;


	vor_dial(tree, 0);
	draw_dial(tree, 0);

	ret = exform_do(tree, obj) & 0x7fff;

	tree[ret].ob_state &= ~SELECTED;

	nach_dial(tree, 0);
	return(ret);
}

/* +--------------------------------------------+ */
/* ! Zeichenroutine fÅr Dialogboxen in Fenstern ! */
/* +--------------------------------------------+ */

static void wobjc_draw(w_handle)
int w_handle;	/* Fenster-ID des Window-Managers */
{
	register OBJECT *tree;
	RECT r;
	Prect pr = { &r.g_x, &r.g_y, &r.g_w, &r.g_h };


	if((tree = ((OBJECT *)(windows[w_handle].rsc.tree))) == (OBJECT *)NULL)
		return; /* Keine Dialogbox! */

	wind_update(BEG_UPDATE);

	if(windows[w_handle].rsc.ed_flag == TRUE)
	{
		objc_edit(windows[w_handle].rsc.tree, 
			windows[w_handle].rsc.edit_obj,
			0, &windows[w_handle].rsc.idx, EDEND);
	}

	wind_get(windows[w_handle].handle, WF_FIRSTXYWH, pr);
	while(r.g_w && r.g_h)
	{
		objc_draw(tree, ROOT, MAX_DEPTH, r);
		wind_get(windows[w_handle].handle, WF_NEXTXYWH, pr);
	}

	/* editierbares Objekt auswÑhlen */

	if(windows[w_handle].rsc.ed_flag == TRUE)
	{
		objc_edit(windows[w_handle].rsc.tree, 
			windows[w_handle].rsc.edit_obj,
			0, &windows[w_handle].rsc.idx, EDINIT);
	}

	wind_update(END_UPDATE);

}

/* +---------------------------------------------------+ */
/* ! Nachbereitungsfunktion fÅr Dialogboxen in Fenstern! */
/* +---------------------------------------------------+ */

static void wobjc_nach(was, w_handle)
int	w_handle,	/* Fenster-ID des Window-Managers */
	was;		/* Art der Meldung */
{
	register OBJECT *tree;
	int x[4];

	switch(was)
	{

		case WM_NEWTOP:
		case WM_TOPPED:	/* Fenster liegt wieder oben */
				if(windows[w_handle].rsc.ed_flag == TRUE)
					objc_edit(windows[w_handle].rsc.tree,
						windows[w_handle].rsc.edit_obj,
						0, &windows[w_handle].rsc.idx,
						 EDINIT);

				windows[w_handle].rsc.next_obj = 0;
				break;

		case WM_MOVED:	/* Box-Koordinaten anpassen */
				tree = windows[w_handle].rsc.tree;
				wind_get(windows[w_handle].handle, WF_WORKXYWH,
					&x[0], &x[1], &x[2], &x[3]);
				if(is_objc(tree, ROOT, OUTLINED) == OUTLINED)
				{
					tree->ob_x = x[0] + 3;
					tree->ob_y = x[1] + 3;
				}
				else
				{
					tree->ob_x = x[0];
					tree->ob_y = x[1];
				}
				break;

		case WM_DEL: /* Fenster - Freigabe */
				windows[w_handle].rsc.tree = (OBJECT *) NULL;
				break;

	}

}

/* +---------------------------------------------+ */
/* ! Aufruf um Dialogbox in Fenster darzustellen ! */
/* +---------------------------------------------+ */

int wbox_draw(tree)
OBJECT *tree;
{
	RECT	loc;
	Prect	ploc = { &loc.g_x, &loc.g_y, &loc.g_w, &loc.g_h };
	int w_handle;
	register long doc_l, doc_w;
	

	form_center(tree, ploc);
	wind_calc(0, NAME+MOVER, loc, ploc);

	doc_l = (long)(loc.g_h / aktuell.text_y + 1);
	doc_w = (long)(loc.g_w / aktuell.text_x + 1);

	w_handle = open_window(dial_info(), "", wobjc_draw, FALSE,
			NAME + MOVER, 0, TRUE, TRUE, 
			aktuell.text_x, aktuell.text_y,
			doc_l, doc_w, 0L, 0L,
			loc.g_x, loc.g_y, loc.g_w, loc.g_h, 0, 0, 0, 0, 
			0, 0, wobjc_nach, TRUE);

	if(w_handle >= 0)
	{
		/* in Struktur eintragen */

		windows[w_handle].rsc.ed_flag = FALSE;
		windows[w_handle].rsc.tree = tree;
		windows[w_handle].rsc.next_obj = fm_inifld(tree, 0);
		windows[w_handle].rsc.idx = 0;
		windows[w_handle].rsc.edit_obj = 0;
	}
	return(w_handle);	/* Fenster-ID melden bzw. Fehlercode */
}


/* +----------------------------------------------------------+ */
/* ! Generierung einer Message fÅr die Applikation, falls ein ! */
/* ! Objekt mit (Touch)Exit-Status angewÑhlt wurde            ! */
/* +----------------------------------------------------------+ */

int wbox_message(w_handle, obj)
int w_handle, obj;
{
	int	msgbuf[8];	/* Nachrichtenbuffer */
	int	ret;

	msgbuf[0] = MSG_DIALOG;
	msgbuf[1] = ap_id;
	msgbuf[2] = 0;
	msgbuf[3] = windows[w_handle].handle;
	msgbuf[4] = (int) (((long) (windows[w_handle].rsc.tree)) >> 16);
	msgbuf[5] = (int) (((long) (windows[w_handle].rsc.tree)) & 0xffff);
	msgbuf[6] = obj;
	msgbuf[7] = 0;	/* reserviert */

	ret = appl_write(ap_id, 16, msgbuf);

	return(ret);
}

/* +-------------------------------------------+ */
/* ! Dialogbearbeitung in Fenstern abschlieûen ! */
/* +-------------------------------------------+ */

void wbox_undraw(w_handle)
int w_handle;
{
	int p[4];
	long pl[5];

	p[0] = w_handle;
	wm_call(WM_DEL, p, pl);	/* Fenster schlieûen und abmelden */

}
