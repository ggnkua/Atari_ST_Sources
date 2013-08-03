/* Storage declarations for C structures */

#include "portab.h"
#include "gsxdef.h"
#include "fontdef.h"
#include "attrdef.h"

struct attribute virt_work;	/* attribute areas for workstations */
WORD q_circle[MX_LN_WIDTH];	/* Holds the circle DDA */

WORD GCURX, GCURY;		/* Current position of locator */
WORD HIDE_CNT;			/* Number of levels the mouse is hidden */
WORD MOUSE_BT;			/* Mouse button state */
WORD REQ_COL[3][16];		/* Holds the requested colors */
WORD TERM_CH;			/* Input terminating character */
WORD chc_mode;			/* Input mode of choice device */
struct attribute *cur_work;	/* Pointer to current workstation attributes */
struct font_head *def_font;	/* Pointer to default font head */
struct font_head *font_ring[4];	/* Pointers to all fonts present */
WORD ini_font_count;		/* Number of fonts at open work */
WORD line_cw;			/* Width associated with q_circle data */
WORD loc_mode;			/* Input mode of locater device */
WORD num_qc_lines;		/* Number of lines making up wide line */
WORD str_mode;			/* Input mode of string device */
WORD val_mode;			/* Input mode of valuator device */

/* GDP variables */

WORD angle, beg_ang, del_ang, deltay, deltay1, deltay2, end_ang;
WORD start, xc, xrad, y, yc, yrad;

/* Fill Area variables */

WORD fil_intersect, fill_maxy, fill_miny, n_steps, odeltay;

/* Wide line attribute save areas */

WORD s_begsty, s_endsty, s_fil_col, s_fill_per, s_patmsk;
WORD *s_patptr;

struct font_head *cur_font;	/* Pointer to current font */
