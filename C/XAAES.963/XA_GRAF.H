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

#ifndef _XA_GRAF_H_
#define _XA_GRAF_H_

typedef enum
{
	NW,
	N_,
	NE,
	E_,
	SE,
	S_,
	SW,
	W_,
	CDV			/* compass divisions */
} COMPASS;


/* Avoid a clash with the standard function name */
#define graf_mouse xaaes_graf_mouse

void graf_mouse(int m_shape, MFORM *mf);

bool rect_changed(RECT *n, RECT *o);
void keep_inside(RECT *r, RECT *o);
RECT *rect_dist(RECT *r, RECT *d);

RECT widen_rectangle(COMPASS compass,
                G_i mx, G_i my,
                RECT start,
                RECT *dist );

RECT move_rectangle(G_i mx, G_i my,
                RECT r,
                RECT *dist );

void rubber_box(COMPASS compass,
                RECT start, RECT *dist,
                int minw, int minh,
                int maxw, int maxg,
                RECT *last );
void drag_box(RECT start,
              RECT *bound,
              RECT *dist,
              RECT *last );

int watch_object(LOCK lock, XA_TREE *odc_p, int ob, int in_state, int out_state);


#endif
