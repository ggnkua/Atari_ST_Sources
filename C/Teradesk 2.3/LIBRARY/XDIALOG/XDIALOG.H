/*
 * Xdialog Library. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef __XDIALOG_H__
#define __XDIALOG_H__

#ifndef __PUREC__
#define cdecl
#endif

#include <np_aes.h>			/* HR 151102: modern */

#ifndef __XWINDOW_H__
 #include "xwindow.h"
#endif

/* Errorcodes. */

#define XDVDI			1		/* Geen vdi handle meer beschikbaar. */
#define XDNMWINDOWS		2		/* Geen windows meer. */
#define XDNSMEM			3		/* Niet voldoende geheugen. */

/* key-status constants */

#define XD_SHIFT		0x0100
#define XD_CTRL			0x0200
#define XD_ALT			0x0400
#define XD_SCANCODE		0x8000

/* Extended types (1 t/m 63) */

#define XD_EMODECOUNT	64		/* Number of extended types. */

/* 4 is gereserveerd voor speciale functies (bij voorbeeld markering)
   XUSERBLK. */

#define XD_DRAGBOX		5		/* button rechtsboven waarmee dialoogbox verplaatst kan worden. */
#define XD_ROUNDRB		6		/* ronde radiobutton. */
#define XD_RECTBUT		7		/* rechthoekige button. */
#define XD_BUTTON		8		/* gewone button, met toetsbediening. */
#define XD_RBUTPAR		9		/* Rechthoek met titel. */
#define XD_TITLE		10		/* IA: Underlined title */
#define XD_RECTBUTTRI	11		/* IA: rectangle button: tri-state!
								   this means cycle between:
								   NORMAL / SELECTED / CHECKED */
#define XD_CYCLBUT		12		/* IA: cycling button. used with pop-ups mostly. */
#define XD_SCRLEDIT		13		/* HR 021202: scrolling editable text fields. */

#define XD_UP			52		/* Codes voor buttons met bediening cursortoetsen */
#define XD_DOWN			53
#define XD_LEFT			54
#define XD_RIGHT		55
#define XD_SUP			56
#define XD_SDOWN		57
#define XD_SLEFT		58
#define XD_SRIGHT		59
#define XD_CUP			60
#define XD_CDOWN		61
#define XD_CLEFT		62
#define XD_CRIGHT		63

/* Constantes voor positie mode */

#define XD_CENTERED	0
#define XD_MOUSE	1
#define XD_CURRPOS	2

/* Constantes voor dialoog mode */

#define XD_NORMAL	0
#define XD_BUFFERED	1
#define XD_WINDOW	2

/* I_A: constants for ob_state when using 'tri-state' buttons */

#define TRISTATE_MASK	(CROSSED | CHECKED)
#define TRISTATE_0		CROSSED
#define TRISTATE_1		CHECKED
#define TRISTATE_2		(CROSSED | CHECKED)

extern unsigned char xd_emode_specs[XD_EMODECOUNT];

#define __XD_IS_ELEMENT		0x01
#define __XD_IS_SPECIALKEY	0x02
#define __XD_IS_SELTEXT		0x04/* element that may employ 'shortcuts' */
#define __XD_IS_NOTYETDEF	0x08/* element type that's not yet defined (how sad ;-)) */

#define xd_is_xtndbutton(emode)		\
	((xd_emode_specs[(emode)] & __XD_IS_SELTEXT) != 0)
#define xd_is_xtndelement(emode)	\
	((xd_emode_specs[(emode)] & __XD_IS_ELEMENT) != 0)
#define xd_is_xtndspecialkey(emode)	\
	((xd_emode_specs[(emode)] & __XD_IS_SPECIALKEY) != 0)

typedef struct xdinfo
{
	OBJECT *tree;			/* pointer naar object boom. */
	int dialmode;			/* dialoog mode. */
	RECT drect;				/* Maten van de dialoogbox. */
	WINDOW *window;			/* Indien in window mode pointer naar window structuur. */
	int edit_object;		/* Object waarop de cursor staat. */
	int cursor_x;			/* x positie in edit_object. */
	int curs_cnt;			/* cursor counter. */
	MFDB mfdb;				/* Indien in buffered mode structuur met data buffer. */
	struct xd_func *func;	/* Pointer naar de structuur met funkties van een niet modale dialoogbox. */
	struct xdinfo *prev;
} XDINFO;

typedef struct xd_func
{
	void (*dialbutton) (XDINFO *info, int object);
	void (*dialclose) (XDINFO *info);
	void (*dialmenu) (XDINFO *info, int title, int item);
	void (*dialtop) (XDINFO *info);
} XD_NMFUNC;

typedef struct
{
	int ev_mflags;
	int ev_mbclicks, ev_mbmask, ev_mbstate;
	int ev_mm1flags;
	RECT ev_mm1;
	int ev_mm2flags;
	RECT ev_mm2;
	unsigned int ev_mtlocount, ev_mthicount;

	int ev_mwhich;
	int ev_mmox, ev_mmoy;
	int ev_mmobutton;
	int ev_mmokstate;
	int ev_mkreturn;
	int ev_mbreturn;

	int ev_mmgpbuf[8];

	int xd_keycode;
} XDEVENT;

typedef int (*userkeys) (XDINFO *info, void *userdata, int scancode);

/* Funkties voor het openen en sluiten van een dialoog */

void xd_open(OBJECT *tree, XDINFO *info);
void xd_open_wzoom(OBJECT *tree, XDINFO *info, RECT *xywh,
						  int zoom);
void xd_close(XDINFO *info);
void xd_close_wzoom(XDINFO *info, RECT *xywh, int zoom);

/* Funkties voor het tekenen van objecten in een dialoogbox. */

void xd_draw(XDINFO *info, int start, int depth);
void xd_change(XDINFO *info, int object, int newstate,
					  int draw);

/* Funkties voor het uitvoeren van een dialoog. */

int xd_kform_do(XDINFO *info, int start, userkeys userfunc,
					   void *userdata);
int xd_form_do(XDINFO *info, int start);
int xd_kdialog(OBJECT *tree, int start, userkeys userfunc,
					  void *userdata);
int xd_dialog(OBJECT *tree, int start);

/* Funkties voor initialisatie van een resource. */

int xd_gaddr(int type, int index, void *addr);
void xd_fixtree(OBJECT *tree);
void xd_set_userobjects(OBJECT *tree);
char *xd_set_srcl_text(OBJECT *tree, int item, char *txt);

/* Funkties voor het zetten van de verschillende modes */

int xd_setdialmode(int new, int (*hndl_message) (int *message),
						  OBJECT *menu, int nmnitems, int *mnitems);
int xd_setposmode(int new);

/* Funkties voor initialisatie bibliotheek */

int init_xdialog(int *vdi_handle, void *(*malloc) (unsigned long size),
						void (*free) (void *block), const char *prgname,
						int load_fonts, int *nfonts);
void exit_xdialog(void);

/* Hulpfunkties */

int xd_rcintersect(RECT *r1, RECT *r2, RECT *intersection);
int xd_inrect(int x, int y, RECT *r);

long xd_initmfdb(RECT *r, MFDB *mfdb);

void xd_objrect(OBJECT *tree, int object, RECT *r);

void xd_userdef(OBJECT *object, USERBLK *userblk,
					   int cdecl(*code) (PARMBLK *parmblock));

void xd_rect2pxy(RECT *r, int *pxy);

int xd_obj_parent(OBJECT *tree, int object);

int xd_wdupdate(int mode);
void xd_mouse_off(void);
void xd_mouse_on(void);

int xd_get_rbutton(OBJECT *tree, int rb_parent);
void xd_set_rbutton(OBJECT *tree, int rb_parent, int object);

OBSPEC xd_get_obspec(OBJECT *object);
void xd_set_obspec(OBJECT *object, OBSPEC obspec);
void *xd_get_scrled(OBJECT *tree, int edit_obj);	/* HR 021202 */

int xd_set_tristate(int ob_state, int state);
int xd_get_tristate(int ob_state);
int xd_is_tristate(OBJECT *tree);

void xd_clip_on(RECT *r);
void xd_clip_off(void);

/* Event funkties */

int xe_keycode(int scancode, int kstate);
int xe_xmulti(XDEVENT *events);
int xe_button_state(void);
int xe_mouse_event(int mstate, int *x, int *y, int *kstate);

/* Funkties voor niet modale dialoogboxen. */

int xd_nmopen(OBJECT *tree, XDINFO *info, XD_NMFUNC *funcs,
			  int start, int x, int y, OBJECT *menu, RECT *xywh,
			  int zoom, const char *title);
void xd_nmclose(XDINFO *info, RECT *xywh, int zoom);

#endif
