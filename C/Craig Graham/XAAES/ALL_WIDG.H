#ifndef _ALL_WIDG_H_
#define _ALL_WIDG_H_

#include "XA_DEFS.H"

#define ICON_W 0x0010
#define ICON_H 0x0010

#if MONO_WIDGETS
#define DATASIZE 0x0010
#else
#define DATASIZE 0x0040
#endif

extern unsigned short widget_bitmap_close[DATASIZE];
extern unsigned short widget_bitmap_close_s[DATASIZE];

extern unsigned short widget_bitmap_size[DATASIZE];
extern unsigned short widget_bitmap_size_s[DATASIZE];

extern unsigned short widget_bitmap_full[DATASIZE];
extern unsigned short widget_bitmap_full_s[DATASIZE];

extern unsigned short widget_bitmap_left[DATASIZE];
extern unsigned short widget_bitmap_left_s[DATASIZE];

extern unsigned short widget_bitmap_right[DATASIZE];
extern unsigned short widget_bitmap_right_s[DATASIZE];

extern unsigned short widget_bitmap_up[DATASIZE];
extern unsigned short widget_bitmap_up_s[DATASIZE];

extern unsigned short widget_bitmap_down[DATASIZE];
extern unsigned short widget_bitmap_down_s[DATASIZE];

extern unsigned short widget_bitmap_iconify[DATASIZE];
extern unsigned short widget_bitmap_iconify_s[DATASIZE];

extern unsigned short bitmap_xaaes16[DATASIZE];
extern unsigned short bitmap_xaaes16_s[DATASIZE];

#endif