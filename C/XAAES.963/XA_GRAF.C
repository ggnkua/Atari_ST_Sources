/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <mintbind.h>
#include <string.h>

#include "xa_types.h"
#include "xa_globl.h"
#include "objects.h"
#include "xa_graf.h"		/* for graf_mouse */
#include "xa_evnt.h"		/* for multi_intout */
#include "widgets.h"

#define THICKNESS	2

/*
 *	This routine behaves a lot like graf_watchbox() - in fact, XaAES's
 *	graf_watchbox calls this.
 *	
 *	The differance here is that we handle colour icons properly (something
 *	that AES4.1 didn't do).
 *	
 *	I've re-used this bit from the WINDIAL module I wrote for the DULIB GEM library.
 *	
 *	This routine assumes that any clipping is going to be done elsewhere
 *	before we get to here.
 */
global
int watch_object(LOCK lock, XA_TREE *wt, int ob, int in_state, int out_state)
{
	OBJECT *dial = wt->tree,
	       *the_object = dial + ob;
	int pobf = -2, obf = ob;
	G_i mx, my, mb, x, y, omx, omy;
	
	vq_mouse(C.vh, &mb, &omx, &omy);
	
	object_offset(dial, ob, wt->dx, wt->dy, &x, &y);

	x--;
	y--;

	if (!mb)	/* If mouse button is already released, assume that was just a click, so select */
	{
		(dial + ob)->ob_state = in_state;
		hidem();
		display_object(lock, wt, ob,x - the_object->r.x + 1, y - the_object->r.y + 1, 3);
		showm();
	} else
	{
	
		while (mb)	/* This loop contains a pretty busy wait, but I don't think it's to */
		{			/* much of a problem as the user is interacting with it continuously. */
			Syield();
			vq_mouse(C.vh, &mb, &mx, &my);
		
			if ((mx != omx) or (my != omy))
			{
				omx = mx;
				omy = my;
				obf = find_object(dial, ob, 10, mx, my, wt->dx, wt->dy);
		
				if (obf == ob)
					(dial + ob)->ob_state = in_state;
				else
					(dial + ob)->ob_state = out_state;
				
				if (pobf != obf)
				{
					pobf = obf;
					hidem();		
					display_object(lock, wt, ob, x - the_object->r.x + 1, y - the_object->r.y + 1, 4);
					showm();
				}
			}
		}
		
	}

	f_interior(FIS_SOLID);
	wr_mode(MD_TRANS);

	if (obf == ob)
		return 1;
	else
		return 0;
}

/*
 *	Ghost outline dragging routines.
 */
#define graf_void 0x8000


/* HR 150202: make rubber_box omnidirectional; helper functions. */

global
RECT *rect_dist(RECT *r, RECT *d)
{
	G_i mb, x, y;

	vq_mouse(C.vh, &mb, &x, &y);

	d->x = r->x - x;
	d->y = r->y - y;
	d->w = r->x + r->w - x;
	d->h = r->y + r->h - y;

	return d;
}


static
void check_wh(RECT *c, int minw, int minh, int maxw, int maxh)
{
	if (c->w < minw)
		c->w = minw;
	if (c->w > maxw)			/* HR: 11/11/00 */
		c->w = maxw;
	if (c->h < minh)
		c->h = minh;
	if (c->h > maxh)			/* HR: 11/11/00 */
		c->h = maxh;
}

global
void keep_inside(RECT *r, RECT *b)		/* fit rectangle r in bounding rectangle b */
{
	if (r->x < b->x)
		r->x = b->x;
	else
	if (r->x + r->w > b->x + b->w)
		r->x = b->x + b->w - r->w;

	if (r->y < b->y)
		r->y = b->y;
	else
	if (r->y + r->h > b->y + b->h)
		r->y = b->y + b->h - r->h;
}

global
RECT widen_rectangle(COMPASS xy, G_i mx, G_i my, RECT start, RECT *d)
{
	RECT r = start;

	switch (xy)
	{
	case NW:
		r.x = mx + d->x;
		r.w = (start.x + start.w) - r.x;
	case N_:
		r.y = my + d->y;
		r.h = (start.y + start.h) - r.y;
		break;
	case SW:
		r.h = my - r.y + d->h;
	case W_:
		r.x = mx + d->x;
		r.w = (start.x + start.w) - r.x;
		break;
	case SE:
		r.w = mx - r.x + d->w;
	case S_:
		r.h = my - r.y + d->h;
		break;
	case NE:
		r.y = my + d->y;
		r.h = (start.y + start.h) - r.y;
	case E_:
		r.w = mx - r.x + d->w;
		break;
	}
	return r;
}

global
RECT move_rectangle(G_i mx, G_i my, RECT r, RECT *d)
{
	r.x = mx + d->x;
	r.y = my + d->y;
	return r;
}


global
bool rect_changed(RECT *n, RECT *o)
{
	return
		   n->x != o->x
		or n->y != o->y
		or n->w != o->w
		or n->h != o->h;
}

static
void new_box(RECT *r, RECT *o)
{
	if (o)
		if (!rect_changed(r, o))
			return;

	hidem();

	if (o)
	{
		gbox(-1, o);
		gbox( 0, o);
		*o = *r;
	}

	gbox(-1, r);
	gbox( 0, r);

	showm();
}

/* HR: dist for use with sizer: If you click in the middle of the sizer,
       than change your mind and release
       the button, without moving the mouse,
       the window size will not change.
*/

/* HR 150202: complete redesign of the functions drag_box and rubberbox.
              By removing the mouse distance calculation from these functions
              and widely use of the RECT structure, they now look rediculously
              simple. (Which is what they are, whether in a computer or not). 
*/
/* HR 150202: make rubber_box omnidirectional. ;-) */

global
void rubber_box(COMPASS cp,
                RECT r,
                RECT *dist,
                int minw, int minh,
                int maxw, int maxh,
                RECT *last)
{
	G_i x, y, mb;
	RECT old = r;
	
	l_color(BLACK);

	wr_mode(MD_XOR);
	new_box(&r, nil);

	do
	{
		Syield();
		vq_mouse(C.vh, &mb, &x, &y);

		r = widen_rectangle(cp, x, y, r, dist);
		check_wh(&r, minw, minh, maxw, maxh);
		new_box(&r, &old);

	} while(mb);
	
	new_box(&r, nil);
	wr_mode(MD_TRANS);

	*last = r;
}

global
void drag_box(RECT r,
              RECT *bound,
              RECT *dist,
              RECT *last
             )
{
	G_i mb, x, y;
	RECT old = r;
	
	l_color(BLACK);

	wr_mode(MD_XOR);
	new_box(&r, nil);

	do
	{
		Syield();
		vq_mouse(C.vh, &mb, &x, &y);

		r = move_rectangle(x, y, r, dist);
		keep_inside(&r, bound);			/* Ensure we are inside the bounding rectangle */
		new_box(&r, &old);
		
	} while (mb);

	new_box(&r,nil);
	wr_mode(MD_TRANS);

	*last = r;
}

/*
 *	INTERFACE TO INTERACTIVE BOX ROUTINES
 */

AES_function XA_graf_dragbox	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	RECT r, last, dist;

	CONTROL(8,3,0)

	r.x = pb->intin[2];			/* Strange binding. */
	r.y = pb->intin[3];
	r.w = pb->intin[0];
	r.h = pb->intin[1];

	drag_box(	r,
				(RECT *)&pb->intin[4],
				rect_dist(&r,&dist),
				&last);
	
	pb->intout[0] = 1;
	pb->intout[1] = last.x;
	pb->intout[2] = last.y;

DIAG((D_graf,client,"_drag_box\n"));
	return XAC_DONE;
}

AES_function XA_graf_rubberbox	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	RECT r, d = {0};
	G_i mb;		/* HR 150202: generalization of rubber_box (See drag_border in widgets.c) */

	CONTROL(4,3,0)

	r.x = pb->intin[0],
	r.y = pb->intin[1];
	
	vq_mouse(C.vh, &mb, &r.w, &r.h);

	rubber_box( SE, r, &d,
				pb->intin[2],		/* minimum */
				pb->intin[3],
				screen.r.w,		/* HR: maximum */
				screen.r.h,
				&r);

	pb->intout[0] = 1;
	pb->intout[1] = r.w;
	pb->intout[2] = r.h;
DIAG((D_graf,client,"_rubbox x=%d, y=%d, w=%d, h=%d\n",pb->intin[0],pb->intin[1],r.w,r.h));	
	return XAC_DONE;
}

AES_function XA_graf_watchbox	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_TREE *wt;

	CONTROL(4,1,1)

	wt = check_widget_tree(lock, client, pb->addrin[0]);		/* HR 200201 */

	pb->intout[0] = watch_object(	lock,
									wt,
								/*	pb->intin[0]   is reserved */
									pb->intin[1],
									pb->intin[2],
									pb->intin[3]);

DIAG((D_graf,client,"_watchbox\n"));
	return XAC_DONE;
}

/*HR: 301100  implementation */
AES_function XA_graf_slidebox
{
	G_i d;
	RECT p, c,					/* parent/child rectangles. */
	     dist, last;			/* mouse distance, result. */
	OBJECT *tree = pb->addrin[0];
	int   pi = pb->intin[0],
	      ci = pb->intin[1];

	CONTROL(3,1,1)

	p = tree[pi].r;
	object_offset(tree, pi, 0, 0, &p.x, &p.y);
	c = tree[ci].r;
	object_offset(tree, ci, 0, 0, &c.x, &c.y);

	rect_dist(&c,&dist);			/* HR 070702: relative position of mouse in child rectangle */

DIAG((D_graf,client,"XA_graf_slidebox dx:%d, dy:%d, p:%d/%d,%d/%d c:%d/%d,%d/%d\n",
										dist.x, dist.y, p, c));
	drag_box(c, &p, &dist, &last);

	if (pb->intin[2])
		d = pix_to_sl(last.y - p.y, p.h - c.h);
	else
		d = pix_to_sl(last.x - p.x, p.w - c.w);

	pb->intout[0] = d < 0 ? 0 : (d > SL_RANGE ? SL_RANGE : d);

DIAG((D_graf,client,"    --     d:%d last.x%d, last.y%d  p:%d/%d,%d/%d c:%d/%d,%d/%d\n",
			d, last.x, last.y, p, c));
	return XAC_DONE;
}

#if 0
/* If shrinkbox isnt there, why then growbox? or move_box? */
AES_function XA_graf_growbox		/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(8,1,0)

	int x = pb->intin[0];
	int y = pb->intin[1];
	int w = pb->intin[2];
	int h = pb->intin[3];
	int xe = pb->intin[4];
	int ye = pb->intin[5];
	int we = pb->intin[6];
	int he = pb->intin[7];
	G_i dx, dy, dw, dh;
	int f;
	
	dx = (xe - x) / GRAF_STEPS;
	dy = (ye - y) / GRAF_STEPS;
	dw = (we - w) / GRAF_STEPS;
	dh = (he - h) / GRAF_STEPS;

	wr_mode(MD_XOR);

	hidem();

	for (f = 0; f < GRAF_STEPS; f++)
	{
		draw_2d_box(x, y, w, h, 1, BLACK);	/* Draw initial growing outline */
		x += dx;
		y += dy;
		w += dw;
		h += dh;
#if 0
		if (f % 2)
			Vsync();
#endif
	}
	
	x = pb->intin[0];						/* Reset to initial area */
	y = pb->intin[1];
	w = pb->intin[2];
	h = pb->intin[3];

	for (f = 0; f < GRAF_STEPS; f++)	/* Erase growing outline */
	{
		draw_2d_box(x, y, w, h, 1, BLACK);
		x += dx;
		y += dy;
		w += dw;
		h += dh;
#if 0
		if (f % 2)
			Vsync();
#endif
	}

	showm();

	wr_mode(MD_TRANS);
	
	pb->intout[0] = 1;
	
DIAG((D_graf,client->pid,"_growbox\n"));
	return XAC_DONE;
}


AES_function XA_graf_movebox		 /*(LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	int w = pb->intin[0];
	int h = pb->intin[1];
	int x = pb->intin[2];
	int y = pb->intin[3];
	int xe = pb->intin[4];
	int ye = pb->intin[5];
	G_i dx, dy;
	int f;
	
	CONTROL(6,1,0)

	dx = (xe - x) / GRAF_STEPS;
	dy = (ye - y) / GRAF_STEPS;

	wr_mode(MD_XOR);

	hidem();

	for (f = 0; f < GRAF_STEPS; f++)	/* Draw initial images */
	{
		draw_2d_box(x, y, w, h, 1, BLACK);
		x += dx;
		y += dy;
#if 0
		if (f % 2)
			Vsync();
#endif
	}
	
	x = pb->intin[2];					/* Reset to go back over same area */
	y = pb->intin[3];

	for (f = 0; f < GRAF_STEPS; f++)	/* Erase them again */
	{
		draw_2d_box(x, y, w, h, 1, BLACK);
		x += dx;
		y += dy;
#if 0
		if (f % 2)
			Vsync();
#endif
	}

	showm();

	wr_mode(MD_TRANS);
	
	pb->intout[0] = 1;
	
DIAG((D_graf,client->pid,"_movebox\n"));
	return XAC_DONE;
}
#endif

/*
 * Mouse definition block - standard GEM arrow
 */
static
MFORM M_ARROW_MOUSE =
{	0x0000, 0x0000, 0x0001, 0x0000, 0x0001,
/* Mask data */
	0xC000, 0xE000, 0xF000, 0xF800,
	0xFC00, 0xFE00, 0xFF00, 0xFF80,
	0xFFC0, 0xFFE0, 0xFE00, 0xEF00,
	0xCF00, 0x8780, 0x0780, 0x0380,
/* Cursor data */
	0x0000, 0x4000, 0x6000, 0x7000,
	0x7800, 0x7C00, 0x7E00, 0x7F00,
	0x7F80, 0x7C00, 0x6C00, 0x4600,
	0x0600, 0x0300, 0x0300, 0x0000
},

/*
 * Mouse definition block - standard GEM busy bee
 */

M_BEE_MOUSE =
{	0x0008, 0x0008, 0x0001, 0x0000, 0x0001,
/* Mask data */
	0x1C7E, 0x1CFF, 0x1CFF, 0xEFFF,
	0xFFFF, 0xFFFF, 0x3FFE, 0x3FFC,
	0x7FFE, 0xFFFE, 0xFFFF, 0xFFFF,
	0xFFFF, 0xFFFF, 0xFEFF, 0x7C3E,
/* Cursor data */
	0x0800, 0x083C, 0x0062, 0x06C2,
	0xC684, 0x198A, 0x1B54, 0x06E0,
	0x1D58, 0x33FC, 0x6160, 0x42DE,
	0x44D8, 0x4A56, 0x3414, 0x0000
},

/*
 * Mouse definition block standard GEM open hand
 */
#if 0
M_HAND_MOUSE =
{	0x0008, 0x0008, 0x0001, 0x0000, 0x0001,
/* Mask data */
	0x0300, 0x1FB0, 0x3FF8, 0x3FFC,
	0x7FFE, 0xFFFE, 0xFFFE, 0x7FFF,
	0x7FFF, 0xFFFF, 0xFFFF, 0x7FFF,
	0x3FFF, 0x0FFF, 0x01FF, 0x003F,
/* Cursor data */
	0x0300, 0x1CB0, 0x2448, 0x2224,
	0x7112, 0x9882, 0x8402, 0x4201,
	0x7001, 0x9801, 0x8401, 0x4000,
	0x3000, 0x0E00, 0x01C0, 0x0030
},
#else
/* non standard sliding hand */ 
M_HAND_MOUSE =
{	4,4,1,0,1,
 {	0x7A00, 0x7F40, 0xFFE0, 0xFFF0, 
	0xFFF8, 0x3FFC, 0x0FFE, 0xC7FF, 
	0xEFFF, 0xFFFF, 0xFFFF, 0x7FFF, 
	0x3FFF, 0x0FFF, 0x03FE, 0x00FC },
 {	0x5000, 0x2A00, 0x1540, 0xCAA0, 
	0x3550, 0x0AA8, 0x0404, 0x0252, 
	0xC402, 0xAA01, 0x5001, 0x3001, 
	0x0C01, 0x0300, 0x00C0, 0x0000 }
},
#endif

/*
 * Mouse definition block - standard GEM outlined cross
 */

M_OCRS_MOUSE =
{	0x0007, 0x0007, 0x0001, 0x0000, 0x0001,
/* Mask data */
	0x07C0, 0x07C0, 0x06C0, 0x06C0,
	0x06C0, 0xFEFE, 0xFEFE, 0xC006,
	0xFEFE, 0xFEFE, 0x06C0, 0x06C0,
	0x06C0, 0x07C0, 0x07C0, 0x0000,
/* Cursor data */
	0x0000, 0x0380, 0x0280, 0x0280,
	0x0280, 0x0280, 0x7EFC, 0x4004,
	0x7EFC, 0x0280, 0x0280, 0x0280,
	0x0280, 0x0380, 0x0000, 0x0000
},

/*
 * Mouse definition block - standard GEM pointing finger
 */

M_POINT_MOUSE =
{	0x0000, 0x0000, 0x0001, 0x0000, 0x0001,
/* Mask data */
	0x3000, 0x7C00, 0x7E00, 0x1F80,
	0x0FC0, 0x3FF8, 0x3FFC, 0x7FFC,
	0xFFFE, 0xFFFE, 0x7FFF, 0x3FFF,
	0x1FFF, 0x0FFF, 0x03FF, 0x00FF,
/* Cursor data */
	0x3000, 0x4C00, 0x6200, 0x1980,
	0x0C40, 0x32F8, 0x2904, 0x6624,
	0x93C2, 0xCF42, 0x7C43, 0x2021,
	0x1001, 0x0C41, 0x0380, 0x00C0
},

/*
 * Mouse definition block - standard GEM thin cross
 */

M_TCRS_MOUSE =
{	0x0007, 0x0007, 0x0001, 0x0000, 0x0001,
/* Mask data */
	0x0380, 0x0380, 0x0380, 0x0380,
	0x0280, 0x0280, 0xFEFE, 0xF01E,
	0xFEFE, 0x0280, 0x0280, 0x0380,
	0x0380, 0x0380, 0x0380, 0x0000,
/* Cursor data */
	0x0000, 0x0100, 0x0100, 0x0100,
	0x0100, 0x0100, 0x0100, 0x7FFC,
	0x0100, 0x0100, 0x0100, 0x0100,
	0x0100, 0x0100, 0x0000, 0x0000
},

/*
 * Mouse definition block - standard GEM thick cross
 */

M_THKCRS_MOUSE =
{	0x0007, 0x0007, 0x0001, 0x0000, 0x0001,
/* Mask data */
	0x07C0, 0x07C0, 0x07C0, 0x07C0,
	0x07C0, 0xFFFE, 0xFFFE, 0xFFFE,
	0xFFFE, 0xFFFE, 0x07C0, 0x07C0,
	0x07C0, 0x07C0, 0x07C0, 0x0000,
/* Cursor data */
	0x0000, 0x0380, 0x0380, 0x0380,
	0x0380, 0x0380, 0x7FFC, 0x7FFC,
	0x7FFC, 0x0380, 0x0380, 0x0380,
	0x0380, 0x0380, 0x0000, 0x0000
},

/*
 * Mouse definition block - standard GEM text cursor
 */

M_TXT_MOUSE =
{	0x0007, 0x0007, 0x0001, 0x0000, 0x0001,
/* Mask data */
	0x7E7E, 0x7FFE, 0x07E0, 0x03C0,
	0x03C0, 0x03C0, 0x03C0, 0x03C0,
	0x03C0, 0x03C0, 0x03C0, 0x03C0,
	0x03C0, 0x07E0, 0x7FFE, 0x7E7E,
/* Cursor data */
	0x3C3C, 0x0660, 0x03C0, 0x0180,
	0x0180, 0x0180, 0x0180, 0x0180,
	0x0180, 0x0180, 0x0180, 0x0180,
	0x0180, 0x03C0, 0x0660, 0x3C3C
},

/*
 * Mouse definition block - XaAES Data Uncertain logo cursor
 */

M_BUBD_MOUSE =
{	0x0007, 0x0008, 0x0001, 0x0000, 0x0001,
/* Mask data */
	0x07C0, 0x1FF0, 0x3FF8, 0x7FFC,
	0x7FFC, 0xFFFE, 0xFFFE, 0xFFFE,
	0xFFFE, 0xFFFE, 0x7FFC, 0x7FFC,
	0x3FF8, 0x1FF0, 0x07C0, 0x0000,
/* Cursor data */
	0x07C0, 0x1930, 0x2AA8, 0x5094,
	0x7114, 0x9012, 0x9112, 0x9FF2,
	0x8002, 0x8FE2, 0x4A24, 0x4B24,
	0x2B28, 0x1A30, 0x07C0, 0x0000
},

/*
 * Mouse definition block - XaAES re-sizer cursor
 */
#if 0
M_SIZER_MOUSE =
{	0x0007, 0x0008, 0x0001, 0x0000, 0x0001,
/* Mask data */
	0x0000, 0xFE00, 0x8100, 0x8E00,
	0x8400, 0xA200, 0xB100, 0xA888,
	0x4454, 0x0234, 0x0114, 0x0084,
	0x01C4, 0x0204, 0x01FC, 0x0000,
/* Cursor data */
	0x0000, 0x0000, 0x7E00, 0x7000,
	0x7800, 0x5C00, 0x4E00, 0x4700,
	0x0388, 0x01C8, 0x00E8, 0x0078,
	0x0038, 0x01F8, 0x0000, 0x0000
},
#else
/*
 * Mouse definition block - XaAES south east sizer cursor
 */
M_SE_SIZER_MOUSE =
{	0x0007, 0x0008, 0x0001, 0x0000, 0x0001,
/* Mask data */
	0x0000, 0x7F80, 0x7F80, 0x7F80,
	0x7E00, 0x7F00, 0x7F80, 0x77CE,
	0x73EE, 0x01FE, 0x00FE, 0x007E,
	0x01FE, 0x01FE, 0x01FE, 0x0000,
/* Cursor data */
	0x0000, 0x0000, 0x3F00, 0x3C00,
	0x3C00, 0x3E00, 0x2700, 0x2380,
	0x01C4, 0x00E4, 0x007C, 0x003C,
	0x003C, 0x00FC, 0x0000, 0x0000
},
#endif
/*
 * Mouse definition block - XaAES north east sizer cursor
 */
M_NE_SIZER_MOUSE =
{	0x0007, 0x0008, 0x0001, 0x0000, 0x0001,
/* Mask data */
	0x0000, 0x01FE, 0x01FE, 0x01FE,
	0x007E, 0x00FE, 0x01FE, 0x73EE,
	0x77CE, 0x7F80, 0x7F00, 0x7E00,
	0x7F80, 0x7F80, 0x7F80, 0x0000,
/* Cursor data */
	0x0000, 0x0000, 0x00FC, 0x003C,
	0x003C, 0x007C, 0x00E4, 0x01C4,
	0x2380, 0x2700, 0x3E00, 0x3C00,
	0x3C00, 0x3F00, 0x0000, 0x0000
},
/*
 * Mouse definition block - XaAES vertical sizer cursor
 */

M_VERTSIZER_MOUSE =
{	0x0008, 0x0007, 0x0001, 0x0000, 0x0001,
/* Mask data */
	0x0180, 0x03C0, 0x07E0, 0x0FF0,
	0x1FF8, 0x1FF8, 0x03C0, 0x03C0,
	0x03C0, 0x03C0, 0x1FF8, 0x1FF8,
	0x0FF0, 0x07E0, 0x03C0, 0x0180,
/* Cursor data */
	0x0000, 0x0180, 0x03C0, 0x07E0,
	0x0FF0, 0x0180, 0x0180, 0x0180,
	0x0180, 0x0180, 0x0180, 0x0FF0,
	0x07E0, 0x03C0, 0x0180, 0x0000
},

/*
 * Mouse definition block - XaAES horizontal sizer cursor
 */

M_HORSIZER_MOUSE =
{	0x0008, 0x0007, 0x0001, 0x0000, 0x0001,
/* Mask data */
	0x0000, 0x0000, 0x0000, 0x0C30,
	0x1C38, 0x3C3C, 0x7FFE, 0xFFFF,
	0xFFFF, 0x7FFE, 0x3C3C, 0x1C38,
	0x0C30, 0x0000, 0x0000, 0x0000,
/* Cursor data */
	0x0000, 0x0000, 0x0000, 0x0000,
	0x0810, 0x1818, 0x381C, 0x7FFE,
	0x7FFE, 0x381C, 0x1818, 0x0810,
	0x0000, 0x0000, 0x0000, 0x0000
},

/*
 * Mouse definition block - XaAES mover cursor
 */

M_MOVER_MOUSE =
{	0x0008, 0x0007, 0x0001, 0x0000, 0x0001,
/* Mask data */
	0x0000, 0x0080, 0x01C0, 0x0080,
	0x0080, 0x0080, 0x1084, 0x3FFE,
	0x1084, 0x0080, 0x0080, 0x0080,
	0x01C0, 0x0080, 0x0000, 0x0000,
/* Cursor data */
	0x0080, 0x0140, 0x0220, 0x0140,
	0x0140, 0x1144, 0x2F7A, 0x4001,
	0x2F7A, 0x1144, 0x0140, 0x0140,
	0x0220, 0x0140, 0x0080, 0x0000
};

/*
 *	AES graf_mouse() routines
 *	Small extension to give a couple of extra cursor shapes
 *	(Data Uncertain logo, mover & sizers)
 */
global
void graf_mouse(int m_shape, MFORM *mf)
{
	C.mouse_form = nil;
	switch(m_shape)
	{
	case M_ON:
		showm();
		return;
	case M_OFF:
		hidem();
		return;
	case ARROW:
		vsc_form(C.vh, &M_ARROW_MOUSE);
		break;
	case TEXT_CRSR:
		vsc_form(C.vh, &M_TXT_MOUSE);
		break;
	case HOURGLASS:
		vsc_form(C.vh, &M_BEE_MOUSE);
		break;
	case POINT_HAND:
		vsc_form(C.vh, &M_POINT_MOUSE);
		break;
	case FLAT_HAND:
		vsc_form(C.vh, &M_HAND_MOUSE);
		break;
	case THIN_CROSS:
		vsc_form(C.vh, &M_TCRS_MOUSE);
		break;
	case THICK_CROSS:
		vsc_form(C.vh, &M_THKCRS_MOUSE);
		break;
	case OUTLN_CROSS:
		vsc_form(C.vh, &M_OCRS_MOUSE);
		break;
	case M_SAVE:					/* HR 100302 */
		return;
	case M_RESTORE:					/* HR 100302 */
		return;
	case M_LAST:					/* HR 100302 */
		return;
	case USER_DEF:
		if (!mf)
			mf = &M_BUBD_MOUSE;	/* HR: Scare people ;-) */
		C.mouse_form = mf;
		vsc_form(C.vh, mf);
		break;
	case XACRS_BUBBLE_DISC:		/* The Data Uncertain logo */
		vsc_form(C.vh, &M_BUBD_MOUSE);
		break;
	case XACRS_RESIZER:			/* The 'resize window' cursor */
		vsc_form(C.vh, &M_SE_SIZER_MOUSE);
		break;
	case XACRS_NE_SIZER:
		vsc_form(C.vh, &M_NE_SIZER_MOUSE);
		break;
	case XACRS_MOVER:			/* The 'move window' cursor */
		vsc_form(C.vh, &M_MOVER_MOUSE);
		break;
	case XACRS_VERTSIZER:			/* The 'vertical size window' cursor */
		vsc_form(C.vh, &M_VERTSIZER_MOUSE);
		break;
	case XACRS_HORSIZER:			/* The 'horizontal size window' cursor */
		vsc_form(C.vh, &M_HORSIZER_MOUSE);
		break;
	}
	C.mouse = m_shape;
	hidem();				/* Hide/reveal cursor to update on screen image immediately */
	forcem();
}

/* Slight differance from GEM here - each application can have a different mouse form, */
/* and the one that is used is for the client with the top window. */
/* A non-top application can still hide & show the mouse though, to ensure that redraws */
/* are done correctly */
AES_function XA_graf_mouse	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	G_i m = pb->intin[0];
	
	CONTROL(1,1,1)

	if (m == M_OFF or m == M_ON)		/* HR 100302: M_SAVE */
	{
		graf_mouse(m, nil);	/* Any client can hide the mouse (required for redraws by clients that aren't top) */
		DIAG((D_f,client,"mouse %d %s\n", client->mouse, m == M_ON ? "on" : "off"));
	}
	else if (m == M_SAVE)
	{
		client->save_mouse      = client->mouse;
		client->save_mouse_form = client->mouse_form;
		DIAG((D_f,client,"M_SAVE; mouse_form %d\n", client->mouse));
	}
	else if (m == M_LAST)
	{
		graf_mouse(client->save_mouse, client->save_mouse_form);
		DIAG((D_f,client,"M_LAST; mouse_form from %d to %d\n", client->mouse, client->save_mouse));
		client->mouse       = client->save_mouse;
		client->mouse_form  = client->save_mouse_form;
	}
	else if (m == M_RESTORE)
	{
		graf_mouse(C.mouse, C.mouse_form);
		DIAG((D_f,client,"M_RESTORE; mouse_form from %d to %d\n", client->mouse, C.mouse));
		client->mouse       = C.mouse;
		client->mouse_form  = C.mouse_form;
	}
	else
	{
		graf_mouse(m, pb->addrin[0]);
		client->mouse = m;
		client->mouse_form = pb->addrin[0];	
		DIAG((D_f,client,"mouse_form to %d\n", m));
	}

/* Always return no error */
	pb->intout[0] = 1;

	return XAC_DONE;
}

AES_function XA_graf_handle	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(0,5,0)

	pb->intout[0] = C.P_handle;		/* graf_handle returns the physical workstation handle */
	pb->intout[1] = screen.c_max_w;
	pb->intout[2] = screen.c_max_h;
	pb->intout[3] = screen.c_max_w+2;
	pb->intout[4] = screen.c_max_h+2;
	
DIAG((D_graf,client,"_handle\n"));
	return XAC_DONE;
}

AES_function XA_graf_mkstate	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(0,5,0)

	multi_intout(pb->intout, 0);
	pb->intout[0] = 1;

DIAG((D_mouse,client,"_mkstate: %d/%d, b=0x%x, ks=0x%x\n",button.x,button.y,button.b,button.ks));
	return XAC_DONE;		/* HR: was TRUE */
}
