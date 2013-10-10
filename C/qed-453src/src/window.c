#include "global.h"
#include "av.h"
#include "clipbrd.h"
#include "comm.h"
#include "event.h"
#include "icon.h"
#include "makro.h"
#include "menu.h"
#include "options.h"
#include "rsc.h"
#include "set.h"
#include "winlist.h"
#include "window.h"

#ifndef WM_SHADED
#define WM_SHADED				0x5758
#define WM_UNSHADED			0x5759
#define WF_SHADE				0x575D
#endif

#ifndef WF_M_BACKDROP
#define WF_M_BACKDROP		100
#endif

/*
 * exportierte Variablen
 */

WINDOWP 	sel_window;		/* Zeiger auf selektiertes Fenster */
SET		sel_objs;		/* Menge selektierter Objekte */
bool		all_iconified;


#define MIN_WIDTH		(8 * gl_wchar)			/* Kleinste Breite */
#define MIN_HEIGHT 	(8 * gl_hchar)			/* Kleinste H”he */

#define WORK_MOVED	0x01				/* Fr Verschieben und Vergr”žern */
#define WORK_SIZED	0x02


/*
 * lokale Variablen
*/
static GRECT	border;
static int		top_handle;

/*
 * Anzahl der offenen Fenster einer Klasse ermitteln.
*/
int num_openwin(int class)
{
	WINDOWP	p = used_list;
	int		anz = 0;

	while (p)
	{
		if ((p->flags & WI_OPEN) && ((p->class == class) || (class == CLASS_ALL)))
			anz++;
		p = p->next;
	}
	return anz;
}

/*
 * Listenelement zu AES-Fensterhandle suchen.
*/
WINDOWP get_window(int handle)
{
	WINDOWP	p = used_list;

	while (p)
	{
		if (p->handle == handle)
			return p;
		p = p->next;
	}
	return NULL;
}

/*
 * Funktion auf bestimmte Fensterklasse anwenden.
*/
void do_all_window(int class, WIN_DOFUNC func)
{
	WINDOWP	p = used_list;

	while (p)
	{
		if ((p->handle != UNUSED) && ((p->class == class) || (class == CLASS_ALL)))
			(*func)(p);
		p = p->next;
	}
}

/*
 * Erstes Fenster aus der Liste.
*/
WINDOWP winlist_top(void)			/* ehemals top() */
{
	if (used_list && used_list->handle != UNUSED)
		return used_list;
	else
		return NULL;
}

/*
 * Top-Fenster vom AES.
*/
void get_realtop(void)
{
	int	d;

	wind_get(0, WF_TOP, &top_handle, &d, &d, &d);
}

/*
 * Liefert Listenelement, das gleichzeitig oberstes AES-Fenster ist.
*/
WINDOWP real_top(void)
{
	WINDOWP	w;

	w = winlist_top();
	if (w == NULL)
		return NULL;
	get_realtop();
	return ((w->handle == top_handle) ? w : NULL);
}

/*
 * Fenster auf Bytegrenze einrasten.
*/
static void snap_window(WINDOWP w, GRECT *new, int mode)
{
	if (mode & WORK_SIZED)
	{
		new->g_w = new->g_w-(new->g_w % w->xfac);
		new->g_h = new->g_h-(new->g_h % w->yfac);
	}

	if (w->snap != NULL)
		(*w->snap)(w, new, mode);
}

/*
 * Fenster an Bildschirm anpassen.
*/
static void get_work(WINDOWP w, GRECT *new, int mode)
{
	if (mode & WORK_SIZED)
	{
		if (new->g_w < MIN_WIDTH)
			new->g_w = MIN_WIDTH;
		if (new->g_h < MIN_HEIGHT)
			new->g_h = MIN_HEIGHT;
	}

	wind_calc_grect(WC_WORK, w->kind, new, new);
	snap_window(w, new, mode);

	/* work und w_* (und doc) anpassen */
	w->work.g_x = new->g_x;
	w->work.g_y = new->g_y;
	if (mode & WORK_SIZED)
	{
		long max_doc;

		w->work.g_w = new->g_w;
		w->w_width  = w->work.g_w / w->xfac;
		max_doc = w->doc.w - w->w_width;
		if (max_doc < 0)
			max_doc = 0;
		if (w->doc.x > max_doc)						/* Jenseits rechter Bereich */
			w->doc.x = max_doc;

		w->work.g_h = new->g_h;
		w->w_height  = w->work.g_h / w->yfac;
		max_doc = w->doc.h - w->w_height;
		if (max_doc < 0)
			max_doc = 0;
		if (w->doc.y > max_doc)						/* Jenseits unterer Bereich */
			w->doc.y = max_doc;
	}

	if (w->flags & WI_OPEN)
	{
		wind_calc_grect(WC_BORDER, w->kind,	new, new);
		wind_set_grect(w->handle, WF_CURRXYWH, new);
	}

	if (mode & WORK_SIZED)
		set_sliders(w, HORIZONTAL+VERTICAL, SLPOS+SLSIZE);
}

/*
 * Rechteckliste
*/
bool rc_first(int wh, GRECT *b, GRECT *r)
{
	border = *b;
	if (!rc_intersect(&gl_desk, &border))					/* mit Bildschirm schneiden */
		return FALSE;
	wind_get_grect(wh, WF_FIRSTXYWH, r);
	while (r->g_w && r->g_h)
	{
		if (rc_intersect(&border, r))						/* Schneide Rechtecke */
			return TRUE;
		wind_get_grect(wh, WF_NEXTXYWH, r);
	}
	return FALSE;
}

bool rc_next(int wh, GRECT *r)
{
	wind_get_grect(wh, WF_NEXTXYWH, r);
	while (r->g_w && r->g_h)
	{
		if (rc_intersect(&border, r))
			return TRUE;
		wind_get_grect(wh, WF_NEXTXYWH, r);
	}
	return FALSE;
}

/*
 * Festerinhalt zeichnen
*/
void clr_area (GRECT *area)
{
	int	xy[4];

	grect_to_array(area, xy);								/* Bereich setzen */
	if (fill_color!=WHITE)
	{
		vsf_color(vdi_handle,WHITE);
		fill_color = WHITE;
	}
	vr_recfl(vdi_handle, xy);								/* Bereich l”schen */
}

bool free_for_draw(WINDOWP w)
{
	GRECT draw;

	if (rc_first(w->handle, &w->work, &draw))
	{
		if (w->work.g_w == draw.g_w && w->work.g_h == draw.g_h)
			return TRUE;
	}
	return FALSE;
}

void redraw_window(WINDOWP w, GRECT *area)
{
	GRECT	r1;

	if (w == NULL)
		return;

	wind_update(BEG_UPDATE);
	
	if (w->flags & WI_NOTDRAWED)
		w->flags &= (~WI_NOTDRAWED);

	else if ((w->flags & WI_OPEN) || (w->flags & WI_ICONIFIED))
	{
		if (w->flags & WI_ICONIFIED)
		{
			/*
			 * Icon-Position wieder eintragen, da alle Fenster den gleichen
			 * Objektbaum benutzen!!!
			 */
			winicon[0].ob_x = w->icon_x;
			winicon[0].ob_y = w->icon_y;
		}
		if (rc_first(w->handle, area, &r1))
		{
			hide_mouse();
			do
			{
				if (w->flags & WI_ICONIFIED)
				{
					if (rc_intersect (area, &r1))
						objc_draw(winicon, ROOT, MAX_DEPTH, r1.g_x, r1.g_y, r1.g_w, r1.g_h);
				}
				else
				{
					if (w->draw!=NULL)					/* Zeichenroutine ausfhren */
						(*w->draw)(w, &r1);
				}
			}
			while (rc_next(w->handle, &r1));
			show_mouse();
		}
	}
	wind_update(END_UPDATE);
}

/*
 * Setzt die Gr”že.
*/
void size_window(WINDOWP w, GRECT *new, bool border)
{
	GRECT r;

	if (w != NULL)
	{
		if (!border)
			wind_calc_grect(WC_BORDER, w->kind, (GRECT*)new, &r);
		else
			r = *new;
		if (w->kind & SIZER)
		{
			get_work(w, &r, WORK_SIZED);
			w->flags &= ~WI_FULLED;
			if (w->flags & WI_REDRAW)
				redraw_window(w, &w->work);
		}
		else
			move_window(w, &r);
	}
}

/*
 * Full/Prev Gr”že einstellen.
*/
void full_window(WINDOWP w)
{
	GRECT	new;

	if (w != NULL && w->kind & FULLER)
	{
		if (w->flags & WI_FULLED)					/* Mache Fenster klein */
			wind_get_grect(w->handle, WF_PREVXYWH, &new);
		else												/* Mache Fenster grož */
			wind_get_grect(w->handle, WF_FULLXYWH, &new);
		get_work(w, &new, WORK_MOVED|WORK_SIZED);
		w->flags ^= WI_FULLED;
	}
}

/*
 * Iconify.
*/
void iconify_window(WINDOWP w, GRECT *new)
{
	unclick_window ();			/* Deselektieren */

	if ((w->flags & WI_OPEN) && !(w->flags & WI_ICONIFIED))
	{
		GRECT	r;

		if (w->iconify != NULL)
			(*w->iconify)(w);

		/* alte Gr”že merken */
		wind_get_grect(w->handle, WF_CURRXYWH, &w->old_size);
		wind_set_grect(w->handle, WF_ICONIFY, (GRECT*)new);

		wind_get_grect(w->handle, WF_WORKXYWH, &r);
		winicon[0].ob_x = r.g_x;
		winicon[0].ob_y = r.g_y;
		winicon[0].ob_width = r.g_w;
		winicon[0].ob_height = r.g_h;
		winicon[1].ob_x = (r.g_w - winicon[1].ob_width) / 2;
		winicon[1].ob_y = (r.g_h - winicon[1].ob_height) / 2;
		w->icon_x = r.g_x;
		w->icon_y = r.g_y;

		w->flags |= WI_ICONIFIED;
		w->flags &= ~WI_OPEN;
		
		/*
		 * Nur nach hinten, wenn noch min. ein Fenster offen ist, da sonst die
		 * Applikation wechselt!
		*/
		if (num_openwin(CLASS_ALL) > 0)
			bottom_window(w, WM_BOTTOMED);
	}
}

void uniconify_window(WINDOWP w, GRECT *new)
{
	GRECT	r;

	if (w != NULL && (w->flags & WI_ICONIFIED))
	{
		if (w->uniconify != NULL)
			(*w->uniconify)(w);

		wind_calc_grect(WC_BORDER, w->kind, &w->work, &r);

		/* Wurde Font gewechselt w„hrend Fenster iconifiziert? */
		if (w->old_size.g_w != r.g_w)
			new = &r;

		if (new == NULL)
			wind_set_grect(w->handle, WF_UNICONIFY, &w->old_size);
		else
			wind_set_grect(w->handle, WF_UNICONIFY, (GRECT*)new);

		w->flags &= ~WI_ICONIFIED;
		w->flags |= WI_OPEN;
		top_window(w);
	}
}

void	all_iconify(WINDOWP w, GRECT *new)
{
	WINDOWP	p;

	if (makro_rec)
	{
		Bconout(2, 7);
		return;
	}

	/* Zun„chst alle Fenster bis auf das angeklickte schliežen */
	p = used_list;
	while (p)
	{
		if (p != w)
		{
			wind_close(p->handle);
			if (p->flags & WI_ICONIFIED)
				uniconify_window(p, NULL);
		}
		p = p->next;
	}

	/* und angeklicktes wird zum Icon */
	set_wtitle(w, " qed ");
	iconify_window(w, new);
	disable_menu();
	all_iconified = TRUE;
}

void all_uniconify(WINDOWP w, GRECT *new)
{
	GRECT		r;
	WINDOWP	p;
	
	if (all_iconified)
	{
		p = used_list;
		while (p)
		{
			if (p->flags & WI_ICONIFIED)
				uniconify_window(p, new);
			else
			{
				wind_calc_grect(WC_BORDER, p->kind, &p->work, &r);
				wind_open_grect(p->handle, &r);
			}
			p = p->next;
		}

#if 0
		/* damit wieder das richtige oben ist */
		top_window(w);
#endif

		enable_menu();
		all_iconified = FALSE;
	}
}

/*
 * Setzt die Position.
*/
void move_window(WINDOWP w, GRECT *new)
{
	if (w != NULL)
	{
		if (w->flags & WI_ICONIFIED)
		{
			int	x, y, d;

			/* Icon anpassen */
			wind_set_grect(w->handle, WF_CURRXYWH, (GRECT*)new);
			wind_get(w->handle, WF_WORKXYWH, &x, &y, &d, &d);
			winicon[0].ob_x = x;
			winicon[0].ob_y = y;
			w->icon_x = x;
			w->icon_y = y;
		}
		else if (w->kind & MOVER)
		{
			GRECT r;

			r = *new;
			get_work(w, &r, WORK_MOVED);
			w->flags &= ~WI_FULLED;
		}
	}
}

/*
 * Fenster von qed wurde aktiv.
*/
void ontop_window(WINDOWP w)
{
	if (w != NULL && w->ontop != NULL)
		(*w->ontop)(w);
}

/*
 * Fenster von qed wurde inaktiv.
*/
void untop_window(WINDOWP w)
{
	if (w != NULL && w->untop != NULL)
		(*w->untop)(w);
}

/*
 * Macht Fenster zum Aktiven.
*/
void top_window(WINDOWP w)
{
	if (w == NULL || !(w->flags & WI_OPEN) && !(w->flags & WI_ICONIFIED))
		return;

	if (w->top != NULL)
		(*w->top)(w);

	wind_set(w->handle, WF_TOP, 0, 0, 0, 0);
	top_handle = w->handle;

	if (w != sel_window)
		unclick_window();

	if (w != used_list)					/* War nicht top in der Liste */
	{
		clr_undo();
		move_to_top(w);
	}
}

/*
 * N„chstes Fenster toppen.
*/
void cycle_window(void)
{
	WINDOWP	w, last;
	
	if (used_list && used_list->next)		/* min. 2 Fenster offen */
	{
		w = used_list;
		last = NULL;
		while (w)									/* letzten CLASS_EDIT suchen */
		{
			if ((shift_pressed() || (w->class == CLASS_EDIT)) && !(w->flags & WI_ICONIFIED))
				last = w;
			w = w->next;
		}
		if (last)
			top_window(last);
	}
}

/*
 * Stellt Fenster nach hinten.
*/
void bottom_window(WINDOWP w, int which)
{
	if (w == NULL || !(w->flags & WI_OPEN) && !(w->flags & WI_ICONIFIED))
		return;

	if (w->bottom != NULL)
		(*w->bottom)(w);

	if (which == WM_BOTTOMED)									/* MTOS, MagiC >= 3 */
		wind_set(w->handle, WF_BOTTOM, 0, 0, 0, 0);
	else																/* Magic 2 */
		wind_set(w->handle, WF_M_BACKDROP, 0, 0, 0, 0);

	clr_undo();
	move_to_end(w);

	get_realtop();					/* qed ber das neue top-Fenster informieren */
	memset(msgbuff, 0, (int) sizeof(msgbuff));
	msgbuff[0] = WM_TOPPED;
	msgbuff[3] = top_handle;
	send_msg(gl_apid);
}

/*
 * Fenster-Shading (Reduktion auf Titel)
 * Winx 2.3, MagiC 5.2, N.AES 1.1.7
*/
void shade_window(WINDOWP w, int mode)
{
	if (w == NULL)
		return;

	switch (mode)
	{
		case WM_SHADED :
			w->flags |= WI_SHADED;
			break;
			
		case WM_UNSHADED :
			w->flags &= ~WI_SHADED;
			break;

		case -1 :
			wind_set(w->handle, WF_SHADE, 0, 0, 0, 0);
			w->flags &= ~WI_SHADED;
			top_window(w);
			break;
	}
}

/*
 * Scrollt den Inhalt des Fensters.
*/
static void scroll_window(WINDOWP w, int dir, long delta)
{
	MFDB		s, d;
	int		xy[8];
	GRECT		r;
	bool	draw;

	draw = FALSE;
	wind_get_grect(w->handle, WF_FIRSTXYWH, &r);
	if (r.g_w != w->work.g_w || r.g_h != w->work.g_h)
		draw = TRUE;

	r = w->work;
	if (!rc_intersect(&gl_desk, &r))
		return;

	if (dir & HORIZONTAL)
	{
		delta *= w->xfac;
		if (labs(delta) >= r.g_w)
			draw = TRUE;
	}
	else
	{
		delta *= w->yfac;
		if (labs(delta) >= r.g_h)
			draw = TRUE;
	}

	if (!draw)
	{
		grect_to_array(&r, xy);						/* Quelle fr vro_cpyfm */
		xy[4] = xy[0];									/* Ziel fr vro_cpyfm */
		xy[5] = xy[1];
		xy[6] = xy[2];
		xy[7] = xy[3];

		if (dir & HORIZONTAL)						/* Horizontales Scrolling */
		{
			if (delta > 0)								/* Links Scrolling */
			{
				xy[0] += (int) delta;
				xy[6] -= (int) delta;

				r.g_x += r.g_w - (int)delta;	/* Rechter Bereich nicht gescrollt, */
				r.g_w  = (int)delta;				/* muž neu gezeichnet werden */
			}
			else											/* Rechts Scrolling */
			{
				xy[2] += (int)delta;
				xy[4] -= (int)delta;

				r.g_w = (int)(-delta);			/* Linken Bereich noch neu zeichnen */
			}
		}
		else												/* Vertikales Scrolling */
		{
			if (delta > 0)								/* Aufw„rts Scrolling */
			{
				xy[1] += (int)delta;				/* Werte fr vro_cpyfm */
				xy[7] -= (int)delta;

				r.g_y += r.g_h - (int)delta;	/* Unterer Bereich nicht gescrollt, */
				r.g_h  = (int) delta;				/* muž neu gezeichnet werden */
			}
			else											/* Abw„rts Scrolling */
			{
				xy[3] += (int)delta;				/* Werte fr vro_cpyfm */
				xy[5] -= (int)delta;

				r.g_h = (int)(-delta);			/* Oberen Bereich noch neu zeichnen */
			}
		}
		s.fd_addr = d.fd_addr = NULL;				/* Erzwinge Bildschirmadresse */
		set_clip(TRUE, &w->work);
		hide_mouse();
		vro_cpyfm(vdi_handle, S_ONLY, xy, &s, &d);
		show_mouse();
		redraw_window(w, &r);
	}
	else
		redraw_window(w, &r);						/* Fenster zeichnen */
}

void scroll_vertical(GRECT *area, int delta)
{
	MFDB	s, d;
	int	xy[8];

	grect_to_array(area, xy);
	xy[4] = xy[0];
	xy[5] = xy[1]-delta;
	xy[6] = xy[2];
	xy[7] = xy[3]-delta;

	s.fd_addr = d.fd_addr = NULL;							/* Erzwinge Bildschirmadresse */
	vro_cpyfm (vdi_handle, S_ONLY, xy, &s, &d);		/* Eigentliches Scrolling */
}

/*
 * Auswertung der Scroll-Pfeile.
*/
static void do_arrow(WINDOWP w, int dir, long delta)
{
	if (delta)
	{
		if (dir == HORIZONTAL)						/* Horizontale Pfeile und Schieber */
			w->doc.x += delta;						/* Neue Position */
		else												/* Vertikale Pfeile und Schieber */
			w->doc.y += delta;						/* Neue Position */
		if (w->flags & WI_OPEN)
		{
			set_sliders(w, dir, SLPOS);			/* Schieber setzen */
			scroll_window(w, dir, delta);
		}
	}
}

void arrow_window (WINDOWP w, int arrow, long amount)
{
	int 	ww, wh, dir;
	long 	oldpos, newpos, max_slide;

	if (w != NULL)
	{
		ww = w->w_width; 								/* Breite in Zeichen */
		wh = w->w_height;								/* H”he in Zeichen */

		if (arrow <= WA_DNLINE)
		{
			oldpos = newpos = w->doc.y;
			dir	 = VERTICAL;
			max_slide = w->doc.h - wh;				/* Maximale Position */
		}
		else
		{
			oldpos = newpos = w->doc.x;
			dir	 = HORIZONTAL;
			max_slide = w->doc.w - ww;				/* Maximale Position */
		}
		switch (arrow)
		{
			case WA_UPPAGE :
				newpos -= wh * amount;
				break;
			case WA_DNPAGE :
				newpos += wh * amount;
				break;
			case WA_UPLINE :
				newpos -= amount;
				break;
			case WA_DNLINE :
				newpos += amount;
				break;
			case WA_LFPAGE :
				newpos -= ww * amount;
				break;
			case WA_RTPAGE :
				newpos += ww * amount;
				break;
			case WA_LFLINE :
				newpos -= amount;
				break;
			case WA_RTLINE :
				newpos += amount;
				break;
		}

		if (newpos > max_slide)
			newpos = max_slide;							/* Jenseits des Randes */
		if (newpos < 0)
			newpos = 0;					 					/* Jenseits des Randes */
		do_arrow(w, dir, newpos-oldpos);
	}
}

/*
 * Auswertung des horizontalen Sliders.
*/
void h_slider(WINDOWP w, int new_value)
{
	long	oldpos, newpos, max_slide;

	if (w != NULL)
	{
		max_slide = w->doc.w - w->w_width;		/* Maximale Position */
		oldpos = w->doc.x;
		newpos = (long)new_value * max_slide;
		newpos = (newpos+500) / 1000;				/* Teilen + Runden */

		if (newpos > max_slide)
			newpos = max_slide;						/* Jenseits des Randes */
		if (newpos < 0)
			newpos = 0;									/* Jenseits des Randes */
		do_arrow(w, HORIZONTAL, newpos-oldpos);
	}
}

/*
 * Auswertung des vertikalen Sliders.
*/
void v_slider(WINDOWP w, int new_value)
{
	long	oldpos, newpos, max_slide;

	if (w != NULL)
	{
		max_slide = w->doc.h - w->w_height;		/* Maximale Position */
		oldpos = w->doc.y;
		newpos = (long)new_value * max_slide;
		newpos = (newpos+500) / 1000;				/* Teilen + Runden */

		if (newpos > max_slide)
			newpos = max_slide;						/* Jenseits des Randes */
		if (newpos < 0)
			newpos = 0;									/* Jenseits des Randes */
		do_arrow(w, VERTICAL, newpos-oldpos);
	}
}

/*
 * Slieder einstellen.
*/
void set_sliders(WINDOWP w, int which, int mode)
{
	int	d;
	int	size, newval, oldval;
	long	max_doc;

	if (w->flags & WI_OPEN)
	{
		if ((which & HORIZONTAL) && (w->kind & HSLIDE))
		{
			size = w->w_width;
			max_doc = w->doc.w - size;

			if (mode & SLPOS)
			{
				if (max_doc <= 0)			/* Fenster zu grož oder passend */
					newval = 0;
				else
					newval = (int)((1000L * w->doc.x) / max_doc);

				wind_get (w->handle, WF_HSLIDE, &oldval, &d, &d, &d);
				if (newval != oldval)
					wind_set(w->handle, WF_HSLIDE, newval, 0, 0, 0);
			}
			if (mode & SLSIZE)
			{
				if (w->doc.w <= size)	/* Fenster zu grož oder passend */
					newval = 1000;
				else
					newval = (int)((1000L * size) / w->doc.w);

				wind_get(w->handle, WF_HSLSIZE, &oldval, &d, &d, &d);
				if (newval != oldval)
					wind_set(w->handle, WF_HSLSIZE, newval, 0, 0, 0);
			}
		}
		if ((which & VERTICAL) && (w->kind & VSLIDE))
		{
			size = w->w_height;
			max_doc = w->doc.h - size;

			if (mode & SLPOS)
			{
				if (max_doc <= 0)			/* Fenster zu grož oder passend */
					newval = 0;
				else
					newval = (int)((1000L * w->doc.y) / max_doc);
				wind_get(w->handle, WF_VSLIDE, &oldval, &d, &d, &d);
				if (newval != oldval)
					wind_set(w->handle, WF_VSLIDE, newval, 0, 0, 0);
			}
			if (mode & SLSIZE)
			{
				if (w->doc.h <= size)	/* Fenster zu grož oder passend */
					newval = 1000;
				else
					newval = (int)((1000L * size) / w->doc.h);
				wind_get (w->handle, WF_VSLSIZE, &oldval, &d, &d, &d);
				if (newval != oldval)
					wind_set(w->handle, WF_VSLSIZE, newval, 0, 0, 0);
			}
		}
	}
}

/*
 * Fenstertitel setzen.
*/
void set_wtitle(WINDOWP w, char *filename)
{
	if (w->flags & WI_CHANGED)
		sprintf(w->title, " *%s ", filename);
	else
		sprintf(w->title, " %s ", filename);

	if ((w->flags & WI_OPEN) && (w->kind & NAME))
		wind_set_str(w->handle, WF_NAME, w->title);
}

/*
 * Fensterinfozeile setzen.
*/
void set_winfo(WINDOWP w, char *info)
{
	strncpy(w->info, info, WINSTRLEN);
	w->info[WINSTRLEN] = EOS;

	if ((w->flags & WI_OPEN) && (w->kind & INFO))
		wind_set_str(w->handle, WF_INFO, w->info);
}

/*
 * '*' im Titel an/abschalten.
*/
void change_window(WINDOWP w, char *filename, bool changed)
{
	bool	old;
	
	if (w->flags & WI_CHANGED)
		old = TRUE;
	else
		old = FALSE;
	if (old != changed)
	{
		w->flags ^= WI_CHANGED;
		set_wtitle(w, filename);
	}
}

/*
 * Neues Fenster anfordern.
*/
WINDOWP create_window(int kind, int class, WIN_CRTFUNC crt)
{
	WINDOWP	w;
	int		wh;

	w = get_new_window(class);
	if (w)
	{
		wh = wind_create_grect(kind, &gl_desk);
		if (wh < 0)
			return NULL;
		w->handle = wh;
		w->kind = kind;

		if (crt != NULL)
			(*crt)(w);

		if (class != CLASS_ICON)
			size_window(w, &w->work, FALSE);
	}
	return w;
}

/*
 * Fenster ”ffnen.
*/
bool open_window(WINDOWP w)
{
	GRECT	r;

	if (w && !(w->flags & WI_OPEN))
	{

		clr_undo();
		unclick_window();
		w->flags |= WI_OPEN;
		w->flags &= ~WI_FULLED;					/* Fenster hat nicht volle Gr”že */

		wind_calc_grect(WC_BORDER, w->kind, &w->work, &r);

		if (w->kind & NAME)						/* Name setzen */
			wind_set_str(w->handle, WF_NAME, w->title);

		if (w->kind & INFO)						/* Infozeile setzen */
			wind_set_str(w->handle, WF_INFO, w->info);

		set_sliders(w, HORIZONTAL+VERTICAL, SLPOS+SLSIZE);

		wind_open_grect(w->handle, &r);
		top_handle = w->handle;
		move_to_top(w);
		redraw_window(w, &w->work);
		w->flags |= WI_NOTDRAWED;
		send_avwinopen(w->handle);
		return TRUE;
	}
	return TRUE;
}

/*
 * Fenster schliežen.
*/
void close_window(WINDOWP w)
{
	if (w != NULL)
	{
		unclick_window();														/* Deselektieren */
		if ((w->flags & WI_OPEN) || (w->flags & WI_ICONIFIED))	/* Fenster offen? */
		{
			wake_mouse();
			if (w->close != NULL)
				(*w->close)(w);

			wind_close(w->handle);
			wind_delete(w->handle);

			send_avwinclose(w->handle);
			w->flags &= ~WI_OPEN;
			get_realtop();
			clr_undo();
		}
		free_window(w);
	}
}

/*
 * Neuen Font einstellen.
*/
void do_font_change(WINDOWP w)
{
	GRECT	r;

	if (w->flags & WI_FONTSIZE)
	{
		w->xfac = font_wcell;
		w->yfac = font_hcell;

		r.g_x = w->work.g_x;
		r.g_y = w->work.g_y;
		r.g_w = w->work.g_w;
		r.g_h = font_hcell * w->w_height;
		if ((r.g_h + r.g_y) > gl_desk.g_h)
			r.g_h = gl_desk.g_h - r.g_y;
		size_window(w, &r, FALSE);
		redraw_window(w, &w->work);
	}
}

/*
 * Auswertung von Mausklicks.
*/
void click_window(WINDOWP w, int m_x, int m_y, int bstate, int kstate, int breturn)
{
	if (w != NULL && !(w->flags & WI_ICONIFIED))
	{
		if (w->click!=NULL)
			(*w->click)(w, m_x, m_y, bstate, kstate, breturn);
		else
			unclick_window();
	}
}

/*
 * Deselektieren eine Fensters.
*/
void unclick_window (void)
{
	if (sel_window != NULL && sel_window->unclick != NULL)
		(*sel_window->unclick) (sel_window);
	sel_window = NULL;
	setclr(sel_objs);
}

/*
 * Auswertung von Tastaturdaten.
*/
bool key_window(WINDOWP w, int kstate, int kreturn)
{
	if (w->key != NULL && !(w->flags & WI_ICONIFIED) && !(w->flags & WI_SHADED))
		return ((*w->key)(w, kstate, kreturn));
	return (FALSE);
}

/*
 * Fenster anordnen. Funktion kommt aus den 7Up 2.3 Quellen.
*/
void arrange_window(int mode)
{
	int		count, xstep, ystep, k, diff;
	GRECT		rect;
	WINDOWP	p = used_list;

	count = num_openwin(CLASS_EDIT);
	if (count > 1)
	{
		xstep = gl_desk.g_w / count;
		diff = (count - 1) * xstep + MIN_WIDTH - gl_desk.g_w;
		if( diff > 0)
			xstep -= diff / count;

		ystep = gl_desk.g_h / count;
		diff = (count - 1) * ystep + MIN_HEIGHT - gl_desk.g_h;
		if(diff > 0)
			ystep -= diff / count;

		k = 0;
		while (p)
		{
			if ((p->flags & WI_OPEN) && (p->kind & SIZER) && (p->flags & WI_TEXT))
			{
				switch(mode)
				{
					case MHINTER:
						rect.g_x = k * gl_desk.g_y + gl_desk.g_x;
						rect.g_y = k * gl_desk.g_y + gl_desk.g_y;
						rect.g_w = gl_desk.g_w - (count - 1) * gl_desk.g_y;
						rect.g_h = gl_desk.g_h - (count - 1) * gl_desk.g_y;
						break;
					case MNEBEN:
						rect.g_x = k * xstep + gl_desk.g_x;
						rect.g_y = gl_desk.g_y;
						rect.g_w = xstep;
						rect.g_h = gl_desk.g_h;
						break;
					case MUNTER:
						rect.g_x = gl_desk.g_x;
						rect.g_y = k * ystep + gl_desk.g_y;
						rect.g_w = gl_desk.g_w;
						rect.g_h = ystep;
						break;
				}
				size_window(p, &rect, TRUE);
				k++;
			}
			p = p->next;
		}
	}
}

/*
 * Modul-Init
*/
void init_window(void)
{
	init_winlist();
 	sel_window = NULL;
	setclr(sel_objs);
	top_handle = -1;
	all_iconified = FALSE;
}

void term_window(void)
{
	term_winlist();
}
