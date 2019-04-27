#if !defined(BIBFIND_H)
#define BIBFIND_H

/* #define ATARI_ST */ /* comment out if compiling on TOS 4 or higher */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <aes.h>
#include <gemf.h>
#include <vdi.h>
#include <ext.h>
#include <stdbool.h>

#include "record.h"
#include "recdata.h"
#include "chart.h"

#include "BIBFIND.rsh"

/* structure to hold data relevant to a single window */
struct win_data {
	int handle; /* window handle */
	OBJECT * dial_addr; /* dialog reference */
	int lines_shown; /* number of lines shown in current record */
	int colns_shown; /* number of columns shown in current record (longest line) */
	int vert_posn; /* number of lines down of vertical scroll bar */
	int horz_posn; /* number of characters from left of horizontal scroll bar */
	int fullx; /* x coordinate of window when full */
	int fully; /* y coordinate of window when full */
	int fullw; /* width of window when full */
	int fullh; /* height of window when full */
	bool is_chart; /* flag to indicate if window displays a chart */
	struct bar_chart * chart; /* pointer to chart, if displayed */
	struct win_data * next; /* pointer to next window, if on display */
};

static int app_handle; /* application handle */

void open_vwork (void);
void do_window (struct rec_data * rd, OBJECT * menu_addr, OBJECT * dial_addr);

#endif