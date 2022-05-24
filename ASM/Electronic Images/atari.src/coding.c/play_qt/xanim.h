/*
 * xanim.h
 *
 * Copyright (C) 1990,1991,1992,1993,1994 by Mark Podlipec. 
 * All rights reserved.
 *
 * This software may be freely copied, modified and redistributed
 * without fee provided that this copyright notice is preserved 
 * intact on all copies and modified copies.
 * 
 * There is no warranty or other guarantee of fitness of this software.
 * It is provided solely "as is". The author(s) disclaim(s) all
 * responsibility and liability with respect to this software's usage
 * or its effect upon hardware or computer systems.
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/param.h>
#include <memory.h>
#include <unistd.h>

#include "xanim_config.h"

#define XA_OPEN_MODE "rb"


typedef unsigned long XID;

typedef XID Window;
typedef XID Drawable;
typedef XID Font;
typedef XID Pixmap;
typedef XID Cursor;
typedef XID Colormap;
typedef XID GContext;
typedef XID KeySym;

typedef char XImage;

#define LONG long
#define ULONG unsigned long
#define BYTE char
#define UBYTE unsigned char
#define SHORT short
#define USHORT unsigned short
#define WORD int
#define UWORD unsigned int

#define TRUE 1
#define FALSE 0
#define XA_NOFILE 2

#define XA_MIN(x,y)   ( ((x)>(y))?(y):(x) )
#define XA_MAX(x,y)   ( ((x)>(y))?(x):(y) )

/* Read xanim.readme at the end for more info on this line
*/
#ifndef HZ
#define HZ 60
#endif

#define MS_PER_60HZ 17

/* X11 variables */

#define XA_GRAYSCALE	0x06
#define XA_STATICGRAY	0x03
#define XA_PSEUDOCOLOR	0x14
#define XA_STATICCOLOR	0x11
#define XA_DIRECTCOLOR	0x18
#define XA_TRUECOLOR	0x19
#define XA_MONOCHROME	0x00

#define XA_X11_STATIC	0x01
#define XA_X11_GRAY	0x02
#define XA_X11_CMAP	0x04
#define XA_X11_TRUE	0x08
#define XA_X11_COLOR	0x10

extern LONG x11_depth;
extern LONG x11_class;
extern LONG x11_bytes_pixel;
extern LONG x11_bits_per_pixel;
extern LONG x11_bitmap_pad;
extern LONG x11_bitmap_unit;
extern LONG x11_bit_order;
extern LONG x11_byte_order;
extern LONG x11_pack_flag;
extern LONG x11_cmap_flag;
extern LONG x11_cmap_size;
extern LONG x11_disp_bits;
extern LONG x11_cmap_type;
extern LONG x11_depth_mask;
extern LONG x11_display_type;
extern LONG x11_red_mask;
extern LONG x11_green_mask;
extern LONG x11_blue_mask;
extern LONG x11_red_shift;
extern LONG x11_green_shift;
extern LONG x11_blue_shift;
extern LONG x11_red_bits;
extern LONG x11_green_bits;
extern LONG x11_blue_bits;
extern LONG x11_black;
extern LONG x11_white;
extern LONG x11_verbose_flag;
extern ULONG x11_kludge_1;

#define X11_MSB  1
#define X11_LSB  0

extern LONG xa_anim_holdoff;
extern LONG xa_anim_status;

/*------*/
#define XA_NEXT_MASK	0x01
#define XA_STOP_MASK	0x02
#define XA_STEP_MASK	0x04
#define XA_RUN_MASK	0x08
#define XA_ISTP_MASK	0x10
#define XA_FILE_MASK	0x20
#define XA_CLEAR_MASK	0x01
#define XA_BEGIN_MASK	0x01
/*------*/
#define XA_UNSTARTED   0x00
#define XA_BEGINNING   0x80
#define XA_STOP_PREV   0x02
#define XA_STOP_NEXT   0x03
#define XA_STEP_PREV   0x04
#define XA_STEP_NEXT   0x05
#define XA_RUN_PREV    0x08
#define XA_RUN_NEXT    0x09
#define XA_ISTP_PREV   0x14
#define XA_ISTP_NEXT   0x15
#define XA_FILE_PREV   0x24
#define XA_FILE_NEXT   0x25

#define XA_SHOW_NORM   0
#define XA_SHOW_SKIP   1

#define NOFILE_ANIM   0xffff
#define UNKNOWN_ANIM  0
#define IFF_ANIM      1
#define FLI_ANIM      2
#define GIF_ANIM      3
#define TXT_ANIM      4
#define FADE_ANIM     5
#define DL_ANIM       6
#define JPG_ANIM      7
#define PFX_ANIM      8
#define SET_ANIM      9
#define RLE_ANIM     10
#define AVI_ANIM     11
#define QT_ANIM      12
#define MPG_ANIM     13

typedef struct
{
  USHORT red,green,blue,gray;
} ColorReg;

typedef struct XA_ACTION_STRUCT
{
 LONG type;		/* type of action */
 LONG cmap_rev;          /* rev of cmap */
 UBYTE *data;		/* data ptr */
 struct XA_ACTION_STRUCT *next;
 struct XA_CHDR_STRUCT *chdr;
 ColorReg *h_cmap;	/* For IFF HAM images */
 ULONG *map;
 struct XA_ACTION_STRUCT *next_same_chdr; /*ptr to next action with same cmap*/
} XA_ACTION;

typedef struct XA_CHDR_STRUCT
{
 LONG rev;
 ColorReg *cmap;
 ULONG csize,coff;
 ULONG *map;
 ULONG msize,moff;
 struct XA_CHDR_STRUCT *next;
 XA_ACTION *acts;
 struct XA_CHDR_STRUCT *new_chdr;
} XA_CHDR;

typedef struct
{
 ULONG csize,coff;
 UBYTE data[4];
} ACT_CMAP_HDR;

typedef struct XA_FRAME_STRUCT
{
  XA_ACTION *act;	/* ptr to relevant Action */
  LONG time;		/* # of millisecondes */
} XA_FRAME;

typedef struct
{
  ULONG count;    /* number of loops */
  LONG cnt_var;   /* var to keep track of loops */
  ULONG end_frame; /* last frame of loop */
} ACT_BEG_LP_HDR;

typedef struct ACT_END_LP_STRUCT
{
  ULONG *count;       /* points back to beg_lp->count */
  LONG *cnt_var;      /* points back to beg_lp->cnt_var */
  ULONG begin_frame;  /* first frame of loop */
  ULONG *end_frame;   /* points back to beg_lp->end_frame */
  XA_ACTION *prev_end_act; /* used to nest loops during creation */
} ACT_END_LP_HDR;

typedef struct XA_PAUSE_STRUCT
{
  ULONG frame;
  struct XA_PAUSE_STRUCT *next;
} XA_PAUSE;


typedef struct XA_ANIM_HDR_STRUCT
{
  LONG file_num;
  LONG anim_type;	/* animation type */
  LONG imagex;		/* width */
  LONG imagey;		/* height */
  LONG imagec;		/* number of colors */
  LONG imaged;		/* depth in planes */
  LONG dispx;		/* display width */
  LONG dispy;		/* display height */
  LONG buffx;		/* buffered width */
  LONG buffy;		/* buffered height */
  LONG anim_flags;
  LONG loop_num;	/* number of times to loop animation */
  LONG loop_frame;	/* index of loop frame */
  LONG last_frame;	/* index of last frame */
  char *name;		/* name of anim */
  char *fname;		/* name of anim data file */
  LONG max_fsize;	/* Largest codec size */
  XA_FRAME *frame_lst;	/* array of Frames making up the animation */
  XA_ACTION *acts;	/* actions associated with this animation */
  XA_PAUSE *pause_lst;  /* pause list */
  struct XA_ANIM_HDR_STRUCT *next_file;
  struct XA_ANIM_HDR_STRUCT *prev_file;
} XA_ANIM_HDR;

#define ANIM_HAM	0x00000009
#define ANIM_HAM6	0x00000001
#define ANIM_LACE	0x00000002
#define ANIM_CYCLE	0x00000004
#define ANIM_HAM8	0x00000008
#define ANIM_PIXMAP	0x00000100
#define ANIM_PING	0x00010000
#define ANIM_NOLOOP	0x00020000
/* single buffered, x11_bytes_pixel */
#define ANIM_SNG_BUF	0x01000000
/* double buffered, 1 byte per pixel */
#define ANIM_DBL_BUF	0x02000000
#define ANIM_3RD_BUF	0x04000000
/* open anim_hdr->fname when starting anim */
#define ANIM_USE_FILE	0x08000000

typedef struct
{
 LONG imagex;
 LONG imagey;
 LONG xoff;
 LONG yoff;
} SIZE_HDR;

typedef struct
{ 
 LONG xpos;
 LONG ypos;
 LONG xsize;
 LONG ysize;
 XImage *image;
 UBYTE *clip;
} ACT_IMAGE_HDR;

typedef struct
{ 
 LONG xpos;
 LONG ypos;
 LONG xsize;
 LONG ysize;
 Pixmap pixmap;
 Pixmap clip;
} ACT_PIXMAP_HDR;

typedef struct
{ 
  ULONG (*delta)();
  ULONG flags;
  ULONG xpos,ypos;
  ULONG xsize,ysize;
  ULONG special;
  ULONG extra;
  ULONG fpos;
  ULONG fsize;
  UBYTE data[4];
} ACT_DLTA_HDR;

/* ACT_DLTA_HDR Flag Values */
#define ACT_SNGL_BUF    0x0100   /* delta is from sngl buffer anim */
#define ACT_DBL_BUF     0x0200   /* delta is from sngl buffer anim */
#define ACT_3RD_BUF     0x0400   /* needs 3rd buffer for HAM or Dither */
#define DLTA_DATA	0x1000   /* delta data is present */

/* DELTA Return VALUES */
#define ACT_DLTA_NORM   0x00000000   /* nothing special */
#define ACT_DLTA_BODY   0x00000001   /* IFF BODY - used for dbl buffer */
#define ACT_DLTA_XOR    0x00000002   /* delta work in both directions */
#define ACT_DLTA_NOP    0x00000004   /* delta didn't change anything */
#define ACT_DLTA_MAPD   0x00000008   /* delta was able to map image */
#define ACT_DLTA_BAD    0x80000000   /* uninitialize value if needed */


typedef struct STRUCT_ACT_SETTER_HDR
{ 
 XA_ACTION *work;
 LONG xback,yback;
 LONG xpback,ypback; 
 XA_ACTION *back;
 LONG xface,yface;
 LONG xpface,ypface;
 LONG depth;
 XA_ACTION *face;
 struct STRUCT_ACT_SETTER_HDR *next;
} ACT_SETTER_HDR;

typedef struct
{ 
  LONG xpos;
  LONG ypos;
  LONG xsize;
  LONG ysize;
  LONG psize;
  UBYTE *clip;
  UBYTE *data; 
} ACT_MAPPED_HDR;

typedef struct
{ 
  LONG xpos;
  LONG ypos;
  LONG xsize;
  LONG ysize;
  LONG psize;
  LONG rbits;
  LONG gbits;
  LONG bbits;
  UBYTE *clip;
  UBYTE *data; 
} ACT_TRUE_HDR;

typedef struct
{ 
  LONG xpos;
  LONG ypos;
  LONG xsize;
  LONG ysize;
  LONG pk_size;
  UBYTE *clip;
  UBYTE data[4]; 
} ACT_PACKED_HDR;

typedef struct
{ 
 LONG xpos;
 LONG ypos;
 LONG xsize;
 LONG ysize;
 XImage *image;
 UBYTE *clip_ptr;
} ACT_CLIP_HDR;

#define ACT_NOP		0x0000
#define ACT_DELAY	0x0001
#define ACT_IMAGE	0x0002
#define ACT_CMAP	0x0003
#define ACT_SIZE	0x0004
#define ACT_FADE	0x0005
#define ACT_CLIP	0x0006
#define ACT_PIXMAP	0x0007
#define ACT_SETTER	0x0008
#define ACT_RAW		0x0009
#define ACT_PACKED	0x0010
#define ACT_DISP	0x0011
#define ACT_MAPPED	0x0012
#define ACT_TRUE	0x0013
#define ACT_PIXMAPS	0x0014
#define ACT_IMAGES	0x0015
#define ACT_CYCLE	0x0016
#define ACT_DELTA	0x0017
#define ACT_BEG_LP	0x0100
#define ACT_END_LP	0x0101
#define ACT_JMP2END	0x0102

/* flags */
extern LONG xa_verbose;
extern LONG xa_debug;
extern LONG xa_jiffy_flag;
extern LONG xa_buffer_flag;
extern LONG xa_file_flag;
extern LONG xa_optimize_flag;
extern LONG xa_use_depth_flag;

#define DEBUG_LEVEL1   if (xa_debug >= 1) 
#define DEBUG_LEVEL2   if (xa_debug >= 2) 
#define DEBUG_LEVEL3   if (xa_debug >= 3) 
#define DEBUG_LEVEL4   if (xa_debug >= 4) 
#define DEBUG_LEVEL5   if (xa_debug >= 5) 

#define XA_CMAP_SIZE 256
#define XA_HMAP_SIZE  64
#define XA_HMAP6_SIZE 16
#define XA_HMAP8_SIZE 64

/* CMAP function flags for ACT_Setup_CMAP */
#define CMAP_DIRECT		0x000000
#define CMAP_ALLOW_REMAP	0x000001


#define CMAP_SCALE4 4369
#define CMAP_SCALE5 2114
#define CMAP_SCALE6 1040
#define CMAP_SCALE8  257
#define CMAP_SCALE9  128
#define CMAP_SCALE10  64
#define CMAP_SCALE11  32
#define CMAP_SCALE13   8
extern ULONG cmap_scale[17];
extern LONG cmap_true_to_332;
extern LONG cmap_true_to_gray;
extern LONG cmap_true_to_1st;
extern LONG cmap_true_to_all;
extern LONG cmap_true_map_flag;
extern LONG cmap_dither_type;

extern LONG cmap_luma_sort;
extern LONG cmap_map_to_1st_flag;
extern LONG cmap_play_nice;
extern XA_CHDR *xa_chdr_start;
extern XA_CHDR *xa_chdr_cur;
extern XA_CHDR *xa_chdr_now;
extern ColorReg *xa_cmap;
extern ULONG xa_cmap_size;
extern ULONG xa_cmap_off;
extern LONG cmap_median_type;
extern SHORT cmap_floyd_error;
extern LONG cmap_map_to_one_flag;
extern LONG pod_max_colors;
extern LONG cmap_hist_flag;
extern LONG cmap_median_bits;
extern ULONG cmap_cache_size;
extern ULONG cmap_cache_bits;
extern ULONG cmap_cache_rmask;
extern ULONG cmap_cache_gmask;
extern ULONG cmap_cache_bmask;
extern USHORT *cmap_cache;
extern XA_CHDR *cmap_cache_chdr;

extern ULONG xa_gamma_flag;
extern USHORT xa_gamma_adj[];

extern ULONG xa_r_shift,xa_g_shift,xa_b_shift;
extern ULONG xa_r_mask,xa_g_mask,xa_b_mask;
extern ULONG xa_gray_bits,xa_gray_shift;

#define XA_HAM_MAP_INVALID 0xffffffff
#define XA_HAM6_CACHE_SIZE   4096
#define XA_HAM8_CACHE_SIZE 262144

typedef struct
{
 ULONG rate;	/* rate at which to cycle colors in milliseconds */
 ULONG flags;   /* flags */
 ULONG size;    /* size of color array */
 ULONG curpos;  /* curpos in array */
 UBYTE data[4];  /* array of cmap pixel values to cycle */
} ACT_CYCLE_HDR;

/* ACT_CYCLE flags values */
/* NOTE: ACTIVE isn't currently checked. It's assumed to be active or
 *       else it shouldn't have been created by anim reader. */
#define ACT_CYCLE_ACTIVE  0x01
#define ACT_CYCLE_REVERSE 0x02
#define ACT_CYCLE_STARTED 0x80000000

extern void TheEnd();
extern void TheEnd1();
extern void ShowAnimation();
extern void ShowAction();
extern void Cycle_It();
extern ULONG X11_Get_True_Color();
extern ULONG X11_Get_Line_Size();

/* 
 * Useful Macros 
 */

#define CMAP_GET_GRAY(r,g,b,scale) \
( ((scale)*((r)*11+(g)*16+(b)*5) ) >> xa_gray_shift)

#define CMAP_GET_332(r,g,b,scale) ( \
( (((r)*(scale)) & xa_r_mask) >> xa_r_shift) | \
( (((g)*(scale)) & xa_g_mask) >> xa_g_shift) | \
( (((b)*(scale)) & xa_b_mask) >> xa_b_shift) )

#define X11_Get_Bitmap_Width(x) \
  ( ((x + x11_bitmap_unit - 1)/x11_bitmap_unit) * x11_bitmap_unit )

#define X11_Make_Pixel(p)  (x11_cmap_type == 0)?(p): \
		( (((p)<<24)|((p)<<16)|((p)<<8)|(p)) & x11_depth_mask )

#define XA_PIC_SIZE(p) ( (xa_use_depth_flag==TRUE)?((p) * x11_bytes_pixel): \
		(p) )

#define XA_GET_TIME(t) ( (xa_jiffy_flag)?(xa_jiffy_flag):(t) )

#define XA_MEMSET(p,d,size) \
{ if (x11_bytes_pixel==4) { ULONG _sz=(size); \
    ULONG *_lp=(ULONG *)p; while(_sz--) *_lp++ = (ULONG)(d); } \
  else if (x11_bytes_pixel==2) { ULONG _sz=(size); \
    USHORT *_sp=(USHORT *)p; while(_sz--) *_sp++ = (USHORT)(d); } \
  else { memset(p,d,size); } \
}

#define XA_REALLOC(p,cur_size,new_size) { if (new_size > cur_size) \
{ char *_tmp; \
  if (p == 0) _tmp=(char *)malloc(new_size); \
  else _tmp=(char *)realloc(p,new_size); \
  if (_tmp == 0) TheEnd1("XA_Realloc: malloc err"); \
  p = _tmp; cur_size = new_size; } \
} 

#define FREE(_p,_q) free(_p)
/* For Debug
#define FREE(_p,_q) { fprintf(stderr,"FREE %lx %lx\n",_p,_q); free(_p); }
*/
