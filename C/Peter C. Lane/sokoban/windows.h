#if !defined(WINDOWS_H)
#define WINDOWS_H

/* general code for managing GEM application */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <aes.h>
#include <gemf.h>
#include <vdi.h>
#include <ext.h>
#include <stdbool.h>

#include "levels.h"
#include "position.h"
#include "posndraw.h"
#include "levelsdraw.h"
#include "score.h"
#include "statsdraw.h"

#include "SOKOBAN.rsh"

enum type { LEVELS, POSITION, STATISTICS };

/* structure to hold data relevant to a list of windows */
struct win_data {
	int handle; /* window handle */

	int lines_shown; /* number of lines shown in current table */
	int colns_shown; /* number of columns shown in current table (longest line) */
	int vert_posn; /* number of lines down of vertical scroll bar */
	int horz_posn; /* number of characters from left of horizontal scroll bar */

	int cell_h; /* height of char/cell in window */
	int cell_w; /* width of char/cell in window */
	char info[60]; /* space for the information string */

	bool shaded; /* flag to set if window is shaded or not */

	enum type window_type; /* type of window */
	/* -- information for level display window */
	struct level_data * ld; /* list of levels */
	int * start_posns; /* start positions of rows in table */
	int * end_posns; /* end positions of rows in table */

	/* -- information for position display window */
	char * level_title; /* title of current level */
	char * definition; /* definition of level */
	struct position * position;   /* current position in game */
	int num_moves; /* number of moves made */
	int num_pushes; /* number of push moves made */

	struct win_data * next; /* pointer to build a linked list of open windows */
};

/* title and parts for window */
#define PARTS NAME|CLOSER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|MOVER|FULLER|INFO
#define PARTS_NOINFO NAME|CLOSER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|MOVER|FULLER
#define MIN_WIDTH 64
#define MIN_HEIGHT 64

/* cell sizes for different scales */
#define SMALL_SIZE 12
#define MEDIUM_SIZE 20
#define LARGE_SIZE 30

void start_program (void);
void open_vwork (void);

#endif
