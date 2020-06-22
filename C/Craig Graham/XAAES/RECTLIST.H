#ifndef _RECTLIST_H_
#define _RECTLIST_H_
#include "XA_DEFS.H"

#if JOHAN_RECTANGLES

short rc_intersect(const GRECT *s, GRECT *d);
XA_RECT_LIST *create_work_list(XA_WINDOW *w);
void invalidate_rect_lists(XA_WINDOW *wind);
XA_RECT_LIST *generate_rect_list(XA_WINDOW *w);

#else

short rc_intersect(const GRECT *s, GRECT *d);
XA_RECT_LIST *generate_rect_list(XA_WINDOW *w);

#endif

#endif
