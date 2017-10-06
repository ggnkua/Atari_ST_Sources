/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#ifndef _XA_GRAF_H_
#define _XA_GRAF_H_

/* Avoid a clash with the standard function name */
#define graf_mouse xaaes_graf_mouse

void graf_mouse(short m_shape, MFORM *mf);
void rubber_box(short sx, short sy,
                short minw, short minh,
                short maxw, short maxg,
                short dx, short dy,
                short *lastw, short *lasth);
void drag_box(short w, short h,
              short xs, short ys,
              short bx, short by, short bw, short bh,
              short *xe, short *ye);
short watch_object(LOCK lock, XA_TREE *odc_p, short ob, short in_state, short out_state);

#endif
