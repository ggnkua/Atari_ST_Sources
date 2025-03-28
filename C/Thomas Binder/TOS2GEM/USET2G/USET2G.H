/*3456789012345678901234567890123456789012345678*/
/*
 * Headerdatei zur Library 'uset2g.lib'
 * vom 17.01.1995
 *
 * Autor:   Dirk Klemmt
 *          Heimchenweg 41
 *          D-65929 Frankfurt am Main
 *          069/30 72 25
 * Email:   klemmt@informatik.uni-frankfurt.de
 */
#ifndef __USET2G__
#define __USET2G__

#include <portab.h>

#ifdef TOS2GEM_LIB
#define EXTERNAL
#else
#define EXTERNAL	extern
#endif


/*
 * Dies ist die Cookie-Struktur aus 'tos2gem.h'.
 * 'tos2gem.h' darf deshalb nicht mehr included
 * werden.
 */
#define RESERVED_SIZE	9

typedef struct
{
	WORD	date;
	WORD	(*reserve)(void);
	WORD	(*init)(void);
	WORD	(*deinit)(void);
	WORD	(*switch_output)(void);
	char	*text_buffer;
	WORD	max_lines,
			x_size, y_size,
			x_vis,
			y_vis,
			x_off, y_off,
			char_w, char_h,
			vdi_handle,
			y_offset,
			text_offset,
			cursor_handle,
			reserved[RESERVED_SIZE];
} TOS2GEM_COOKIE;

/*
 * Ab hier folgen die Defines fuer 'uset2g.lib'.
 */

/* GEM-Fenster mit allem */
#define T2G_WINDOW	NAME|CLOSER|FULLER|MOVER|\
					SIZER|UPARROW|DNARROW|VSLIDE|\
					LFARROW|RTARROW|HSLIDE

/*
 * Spalten auf max. 512 begrenzen. Darf niemals
 * groesser werden, wegen interner Beschraenkung
 * von Pure C.
 */
#define T2G_MAXCOLUMNS	512
#define T2G_MAXLINES	200

/*
 * zurueckgegebene Fehler-Codes.
 */
#define T2G_NOERROR			0
#define T2G_OLDTOS2GEM		1
#define T2G_NOTINSTALLED	2
#define T2G_CANNOTRESERVE	3
#define T2G_NOVDIHANDLE		4
#define T2G_OUTOFMEMORY		5

/* Puffer soll geloescht werden */
#define T2G_CLEARBUFFER		0x1

/* Fenstergroesse soll geandert werden */
#define T2G_CHGSCREENSIZE	0x2

/* Puffergroesse soll geandert werden */
#define T2G_CHGBUFFER		0x4

/* Fontgroesse soll geandert werden */
#define T2G_CHGFONT			0x8

/*
 * die Struktur fuer die Library.
 */
typedef struct
{
	WORD columns,
		 lines,
		 linebuffer,
		 fontnr,
		 fontsize,
		 fontcol,
		 winkind,
		 cur_text_offset,
		 cur_x_offset,
		 cur_y_offset,
		 work_out[57];
	BOOLEAN whole_buffer;
	TOS2GEM_COOKIE *cookie;
} TOS2GEM;

EXTERNAL TOS2GEM	*t2g;

/*
 * Makro fuer den Zugriff auf den Textpuffer.
 * Dabei steht y fuer die y. Zeile des sichtbaren
 * Ausschnitts und x fuer die x. Spalte (beides ab
 * Null gezaehlt)
 */
#define TPOS(x, y)	t2g->cookie->text_buffer\
					[(LONG)(x + t2g->\
					cur_x_offset) + ((LONG)(y) +\
					(LONG)t2g->cur_text_offset +\
					(LONG)t2g->cur_y_offset) *\
				(LONG)(t2g->cookie->x_size + 1)]

/* Routinen der Library */
WORD init_t2g( WORD t2g_columns, WORD t2g_lines,
			   WORD t2g_buffer, WORD t2g_fontnr,
			   WORD t2g_fontsize, WORD t2g_txtcol,
			   WORD t2g_mindate, WORD t2g_winkind,
			   BOOLEAN cursor_hndl,
			   BOOLEAN whole_buffer,
			   BOOLEAN lines_columns );
WORD calc_t2gwindow( GRECT *win_area,
					 GRECT *win_work,
					 WORD max_columns,
					 WORD max_lines );
WORD change_t2gstats( GRECT *win_area,
					  GRECT *win_work,
					  WORD type );
VOID exit_t2g( VOID );
VOID redraw_t2gwindow( GRECT *win_work,
					   GRECT *box,
   					   BOOLEAN clipping );
WORD moved_t2gwindow( GRECT win_work );
BOOLEAN adjust_t2gwindow( GRECT *new_area,
						  GRECT *win_work,
				   		  WORD *new_x_offset,
				   		  WORD *new_y_offset );
VOID scroll_t2gwindow( WORD x_jump, WORD y_jump,
					   WORD *new_x_offset,
					   WORD *new_y_offset,
					   WORD *new_text_offset );
VOID calc_t2gsliders( WORD *x_size, WORD *y_size,
					  WORD *x_pos, WORD *y_pos );
VOID calc_t2gdeltas( WORD *dx, WORD *dy );
WORD calc_t2gmax_text_offset( void );

#endif