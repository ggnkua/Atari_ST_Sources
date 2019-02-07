/*
 * CARDEXTN.H
 *   Global reference variables for cards.c
 *
 * (C) Copyright 1988 by Dynamic Software Design
 *
 */

#include "carddefn.h"

extern int	gl_apid;	/* system id */

extern  int xres, yres;			/* Current screen resolution of system... */

extern  int	box_x, box_y;		/* Coordinates of box... */

extern  int	hidden;				/* Mouse hidden or visible? */

extern  int	handle;				/* handle to the graphics worktstation */

extern  char *clear_me;
extern unsigned long countdown;

extern long menuadd;			/* address of resource */
extern OBJECT *rsc_pointer;		/* pointer to beginning of resource */

extern char	*clear_me;
extern char	*end_clear;
extern unsigned long countdown;

extern union	{
	char four_bytes[4];
	int	 two_ints[2];
	long one_long;
} bufo;

extern  struct window_info {
	int	status;		/* Window open or closed?	*/
	int	handle;		/* This window's window handle */
	int	x;			/* This window's working size for x */
	int	y;			/* This window's working size for y */
	int	w;			/* This window's working size for w */
	int	h;			/* This window's working size for h */
	int	big_x;		/* This window's total area, x */
	int	big_y;		/* This window's total area, y */
	int	big_w;		/* This window's total area, w */
	int	big_h;		/* This window's total area, h */
} w_inf[8];		/* 8 possible slots for windows (Note: I only use one */
				/* in this program, however, this is a nice generic	  */
				/* structure that you can use elsewhere.  8 windows   */
				/* is the current maximum number available to be open */
				/* at once.											  */

extern 	int cur_drive;
extern	char cur_dir[68];
extern	char	tbuf[108];	/* Strings for handling string input	*/
extern	char	path_buf[108];	/* stuff...				*/
extern	char	wild_buf[108];

extern	char	name_is[8];

extern	char	munch_buff[];

extern	char	paste_buff[510];
extern	char	paste_mark;

extern int	search_mode;	/* Showing searched cards, or all cards */
extern int	global_mode;	/* Global search mode */


extern int i, number_fields, starting_1_point, length_1;
extern int starting_2_point, length_2;
extern int card_1, card_2;
extern int swap_flag, flag;
extern char card_1_buff[51], card_2_buff[51];

extern int	top_cursor, bottom_cursor;		/* Top and bottom edges of cursor */
extern int	search_direction, search_alpha_direction;

extern int	old_y, new_y;	/* Last row and current row that the cursor was on */
extern int	print_using;	/* Use old_y and new_y to define printer lines? */

extern	int		card_matches[MAX_CARDS];

extern	char	data_space[MAX_CARDS][510];
extern	int		card_index;
extern	int		current_mark;			/* Which mark is currently to be used... */
extern	char	card_marks[MAX_CARDS];
extern	int		cursor_x, cursor_y;		/* Cursor x and y position */
extern	int		record_offset;

extern  int	num_marked;

extern	int	mark_resource[];

extern	char	key_convert[];

extern  int	mark_test[];

extern	char	start_name[];

extern	char	digits[];
extern	char	info_line[];
extern	char	unshifted[];
extern	char	shifted[];

extern  int mx, my, buttons, keys;
extern  int event;
extern  int msgbuff[8];
extern  int dummy;
extern	int what_key;

extern  int		xdesk,ydesk,wdesk,hdesk;

extern  int	gl_wchar;	/* width of a standard GEM character cell */
extern  int	gl_hchar;	/* height of a standard GEM character cell */
extern  int	gl_wbox;
extern  int	gl_hbox;

extern  int	contrl[12];
extern  int	intin[128];
extern  int	ptsin[128];
extern  int	intout[128];
extern  int	ptsout[128];	/* storage wasted for idiotic bindings */

extern  int work_in[11];	/* Input to GSX parameter array */
extern  int work_out[57];	/* Output from GSX parameter array */
extern  int pxyarray[10];	/* input point array */
