/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */
#include <mintbind.h>
#include <string.h>

#include "xa_types.h"
#include "xa_globl.h"
#include "objects.h"
#include "xa_graf.h"		/* for graf_mouse */
#include "xa_evnt.h"		/* for multi_intout */

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
short watch_object(LOCK lock, XA_TREE *odc_p, short ob, short in_state, short out_state)
{
	OBJECT *dial = odc_p->tree,
	       *the_object = dial + ob;
	short pobf = -2, obf = ob, mx, my, mb, x, y, /* w, h, */ omx, omy;
	
	vq_mouse(C.vh, &mb, &omx, &omy);
	
	object_offset(dial, ob, &x, &y);

/*	w = the_object->r.w + 2;
	h = the_object->r.h + 2;
*/	x--;
	y--;

	if (!mb)	/* If mouse button is already released, assume that was just a click, so select */
	{
		(dial + ob)->ob_state = in_state;
		hidem();
		display_object(lock, odc_p, ob,x - the_object->r.x + 1, y - the_object->r.y + 1, false);
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
				obf = find_object(dial, ob, 10, mx, my);
		
				if (obf == ob)
					(dial + ob)->ob_state = in_state;
				else
					(dial + ob)->ob_state = out_state;
				
				if (pobf != obf)
				{
					pobf = obf;
					hidem();		
					display_object(lock, odc_p, ob, x - the_object->r.x + 1, y - the_object->r.y + 1, false);
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

static
void draw_box(short x, short y, short w, short h, short thickness)
{
	short pnt[4];

	if (thickness > 0)
	{
		pnt[0] = x;
		pnt[1] = y;
		pnt[2] = x + w - 1;
		pnt[3] = y + (thickness - 1);
		v_bar(C.vh, pnt);

		pnt[1] = y + h - 1 - (thickness - 1);
		pnt[3] = y + h - 1;
		v_bar(C.vh, pnt);

		pnt[1] = y + thickness;
		pnt[2] = x + (thickness - 1);
		pnt[3] = y + h - 2 - (thickness - 1);
		v_bar(C.vh, pnt);

		pnt[0] = x + w - 1 - (thickness - 1);
		pnt[2] = x + w - 1;
		v_bar(C.vh, pnt);
	}
	else
	if (thickness < 0)
	{
		thickness = -thickness;
		pnt[0] = x - thickness;
		pnt[1] = y - thickness;
		pnt[2] = x + w - 1 + thickness;
		pnt[3] = y - 1;
		v_bar(C.vh, pnt);

		pnt[1] = y + h;
		pnt[3] = y + h + (thickness - 1);
		v_bar(C.vh, pnt);

		pnt[1] = y - thickness;
		pnt[2] = x - 1;
		pnt[3] = y + h - 1;
		v_bar(C.vh, pnt);

		pnt[0] = x + w;
		pnt[2] = x + w + (thickness - 1);
		v_bar(C.vh, pnt);
	}
}

/*
 *	Ghost outline dragging routines.
 */
global
void drag_box(short w, short h, short xs, short ys, short bx, short by, short bw, short bh, short *xe, short *ye)
{
	short x, y, mb, idx, idy, dx, dy, odx = -1, ody = -1;
	short pnt[4];
	
	vq_mouse(C.vh, &mb, &x, &y);
	wr_mode(MD_XOR);

	f_color(BLACK);
	vsf_perimeter(C.vh, 0);

/*	clear_clip();
*/	
	idx = x - xs;
	idy = y - ys;

	while(mb)
	{
		Syield();
		vq_mouse(C.vh, &mb, &x, &y);

		dx = x - idx;
		dy = y - idy;
		
		if (dx < bx)		/* Ensure we are inside the bounding rectangle */
			dx = bx;
		else
		if (dx + w > bx + bw)
			dx = bx + bw - w;		/* HR remove -1 */

		if (dy < by)
			dy = by;
		else
		if (dy + h > by + bh)
			dy = by + bh - h;		/* HR remove -1 */
		
		if ((dx != odx) or (dy != ody))
		{
			hidem();
			if (odx != -1)
				draw_box(odx, ody, w, h, THICKNESS);
			draw_box(dx, dy, w, h, THICKNESS);				
			showm();
			odx = dx;
			ody = dy;
		}
	}

	if (odx != -1)
	{
		hidem();
		draw_box(dx, dy, w, h, THICKNESS);
		showm();
	}

	wr_mode(MD_TRANS);
	
	*xe = dx;
	*ye = dy;
}

/* HR: dx, dy for use with sizer: If you click in the middle of the sizer,
       than change your mind and release
       the button, without moving the mouse,
       the window size will not change.
*/
global
void rubber_box(short sx, short sy,
                short minw, short minh,
                short maxw, short maxh,
                short dx, short dy,
                short *lastw, short *lasth)
{
	short x, y, mb, dw, dh, odw = -1, odh = -1, cw, ch;
	short pnt[4];
	
	wr_mode(MD_XOR);		/* HR: !!!!! that's why perimeter works !!!!! */
	vq_mouse(C.vh, &mb, &x, &y);

	f_color(BLACK);
	vsf_perimeter(C.vh, 0);

	while(mb)
	{
		Syield();
		vq_mouse(C.vh, &mb, &x, &y);
		dw = x - sx;
		dh = y - sy;

		cw = dw + dx;
		ch = dh + dy;

		if (cw < minw)
			cw = minw;
		if (cw > maxw)			/* HR: 11/11/00 */
			cw = maxw;
		if (ch < minh)
			ch = minh;
		if (ch > maxh)			/* HR: 11/11/00 */
			ch = maxh;

		dw = cw - dx;
		dh = ch - dy;

		if ((dw != odw) or (dh != odh))
		{
			hidem();
			if (odw != -1)
				draw_box(sx, sy, odw + dx, odh + dy, THICKNESS);
			draw_box(sx, sy, dw + dx, dh + dy, THICKNESS);
			showm();
			odw = dw;
			odh = dh;
		}
	}
	
	if (odw != -1)
	{
		hidem();
		draw_box(sx, sy, dw + dx, dh + dy, THICKNESS);
		showm();
	}

	wr_mode(MD_TRANS);
	
	*lastw = dw + dx;
	*lasth = dh + dy;
}

/*
 *	INTERFACE TO INTERACTIVE BOX ROUTINES
 */

AES_function XA_graf_dragbox	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	short x, y;

	CONTROL(8,3,0)

	drag_box(	pb->intin[0],
				pb->intin[1],
				pb->intin[2],
				pb->intin[3],
				pb->intin[4],
				pb->intin[5],
				pb->intin[6],
				pb->intin[7],
				&x, &y);
	
	pb->intout[0] = 1;
	pb->intout[1] = x;
	pb->intout[2] = y;

DIAG((D.graf,client->pid,"_drag_box\n"));
	return XAC_DONE;
}

AES_function XA_graf_rubberbox	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	short w, h;
	
	CONTROL(4,3,0)

	rubber_box( pb->intin[0],
				pb->intin[1],
				pb->intin[2],		/* minimum */
				pb->intin[3],
				screen.r.w,		/* HR: maximum */
				screen.r.h,
				0, 0,
				&w, &h);

	pb->intout[0] = 1;
	pb->intout[1] = w;
	pb->intout[2] = h;
DIAG((D.graf,client->pid,"_rubbox x=%d, y=%d, w=%d, h=%d\n",pb->intin[0],pb->intin[1],w,h));	
	return XAC_DONE;
}

AES_function XA_graf_watchbox	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(4,1,1)
/*	memset(&client->wt,0,sizeof(XA_TREE));
*/	check_widget_tree(client, pb->addrin[0]);		/* HR 200201 */
	pb->intout[0] = watch_object(	lock,
									&client->wt,
									pb->intin[1],
									pb->intin[2],
									pb->intin[3]);
DIAG((D.graf,client->pid,"_watchbox\n"));
	return XAC_DONE;
}

/*HR: 301100  implementation */
AES_function XA_graf_slidebox
{
	short x, y, d;
	RECT p,c;				/* parent/child rectangles. */
	OBJECT *tree = pb->addrin[0];
	short pi = pb->intin[0],
	      ci = pb->intin[1];

	CONTROL(3,1,1)

	p = tree[pi].r;
	object_offset(tree, pi, &p.x, &p.y);
	c = tree[ci].r;
	object_offset(tree, ci, &c.x, &c.y);
	
	drag_box(	c.w,
				c.h,
				c.x,
				c.y,
				p.x,
				p.y,
				p.w,
				p.h,
				&x, &y);

	if (pb->intin[2])
		d = (1000L * (y - p.y))/(p.h - c.h);
	else
		d = (1000L * (x - p.x))/(p.w - c.w);

	pb->intout[0] = d < 0 ? 0 : (d > 1000 ? 1000 : d);

DIAG((D.graf,client->pid,"_slidebox d:%d x%d,y%d  p:%d/%d,%d/%d c:%d/%d,%d/%d\n",
			d, x, y, p.x,p.y,p.w,p.h, c.x,c.y,c.w,c.h));
	return XAC_DONE;
}

#if 0
/* If shrinkbox isnt there, why then growbox? or move_box? */
AES_function XA_graf_growbox		/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(8,1,0)

	short x = pb->intin[0];
	short y = pb->intin[1];
	short w = pb->intin[2];
	short h = pb->intin[3];
	short xe = pb->intin[4];
	short ye = pb->intin[5];
	short we = pb->intin[6];
	short he = pb->intin[7];
	short dx, dy, dw, dh;
	short f;
	
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
	
DIAG((D.graf,client->pid,"_growbox\n"));
	return XAC_DONE;
}


AES_function XA_graf_movebox		 /*(LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	short w = pb->intin[0];
	short h = pb->intin[1];
	short x = pb->intin[2];
	short y = pb->intin[3];
	short xe = pb->intin[4];
	short ye = pb->intin[5];
	short dx, dy;
	short f;
	
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
	
DIAG((D.graf,client->pid,"_movebox\n"));
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
{	0x0007, 0x0008, 0x0002, 0x0000, 0x0001,
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

M_SIZER_MOUSE =
{	0x0007, 0x0008, 0x0002, 0x0000, 0x0001,
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
 *	(Data Uncertain logo, mover & resizer)
 */
global
void graf_mouse(short m_shape, MFORM *mf)
{
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
	case USER_DEF:
		if (!mf)
			mf = &M_BUBD_MOUSE;	/* HR: Scare people ;-) */
		vsc_form(C.vh, mf);
		break;
	case XACRS_BUBBLE_DISC:		/* The Data Uncertain logo */
		vsc_form(C.vh, &M_BUBD_MOUSE);
		break;
	case XACRS_RESIZER:			/* The 'resize window' cursor */
		vsc_form(C.vh, &M_SIZER_MOUSE);
		break;
	case XACRS_MOVER:			/* The 'move window' cursor */
		vsc_form(C.vh, &M_MOVER_MOUSE);
		break;
	}
	hidem();				/* Hide/reveal cursor to update on screen image immediately */
	forcem();
}

/* Slight differance from GEM here - each application can have a different mouse form, */
/* and the one that is used is for the client with the top window. */
/* A non-top application can still hide & show the mouse though, to ensure that redraws */
/* are done correctly */
AES_function XA_graf_mouse	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	short m = pb->intin[0];
	
	CONTROL(1,1,1)

/* Store the mouse shape requested if this isn't a turn on/off request. */
	if (m == M_OFF or m == M_ON)
		graf_mouse(m, nil);	/* Any client can hide the mouse (required for redraws by clients */
	else							/* that aren't top) */
	{
		client->client_mouse = m;
		client->client_mouse_form = pb->addrin[0];	
/* Only actually set the cursor shape if the top window is our client's  */
/* or there are no windows open at all */
		if ((window_list == root_window) or (window_list->pid == client->pid))
			graf_mouse(m, pb->addrin[0]);
	}

/* Always return no error */
	pb->intout[0] = 1;

DIAG((D.v,client->pid,"mouse_form to %d\n", m));
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
	
DIAG((D.graf,client->pid,"_handle\n"));
	return XAC_DONE;
}

AES_function XA_graf_mkstate	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(0,5,0)

	multi_intout(pb->intout, 0);
	pb->intout[0] = 1;

DIAG((D.mouse,client->pid,"_mkstate: %d/%d, b=0x%x, ks=0x%x\n",button.x,button.y,button.b,button.ks));
	return XAC_DONE;		/* HR: was TRUE */
}
