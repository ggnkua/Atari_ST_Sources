/*
	Mine.c

	Landmine game for all ST/TT resolutions.
	Copyright 1992 Atari Corporation
	Created: June, 1992 Kenneth Soohoo
*/

#include <stdio.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <aesbind.h>
#include <osbind.h>
#include <bios.h>
#include <xbios.h>
#include <ctype.h>
#include "landmine.h"
#include "mstruct.h"
#include "dialog.h"

/* Board dimensions (defaults) */
int boards_width[MAX_BOARDS] =  {10, 10, 15, 15, 15, 20, 20, 25, 25, 30};
int boards_height[MAX_BOARDS] = {10, 10, 15, 15, 15, 20, 20, 20, 20, 20};
int boards_mines[MAX_BOARDS] =  {10, 20, 20, 40, 60, 60, 80, 80, 99, 99};

int boards_scores[MAX_BOARDS];		/* Low scores here... */
char boards_names[MAX_BOARDS][13];	/* Matching names here */

int mine_colors[10] = {0, 3, 2, 1, 3, 2, 1, 3, 2};

/* Current working board */
MINE mine_arena[MAX_MINES];
int board_x, board_y;			/* Current board position */
int board_index;			/* Which board we're playing */
int board_width, board_height;		/* Dimensions in cells */
int board_mines;			/* Total mines on the board */
int board_remain;			/* Total mines remaining */
int board_time;				/* Seconds count */
int cell_x = 8, cell_y = 8;		/* Size of a cell, resolution dep */
int win_handle = 0;			/* Window handle, if one is open */
int win_open = FALSE;			/* TRUE if window is open */
int sounds = TRUE;			/* Sounds default to ON */
int DMA_sound = FALSE;			/* TRUE if DMA sound present */
int button_mode = ACCEPT;		/* Accept any button clicks */
int mine_count, user_mine_count;	/* Mines identifier, # user ID'd */
int game_state = FROZEN;		/* Game active, done, frozen? */
int text_height;			/* Height of a # in pixels */
int shades[3];				/* Three gray levels */
int base_board;				/* Color randomizer */
int first_step = TRUE;			/* Waiting for first step... */
int small_border = FALSE;		/* Less than 8 pixels per box? */

int workx, worky, workw, workh;
extern int fullx, fully, fullw, fullh;	/* Screen's biggest size */
extern int currx, curry, currw, currh;	/* Current coordinates */
extern int innerx, innery, innerw, innerh;
extern int handle;			/* Workstation handle */
extern int SCw, SCh;			/* Screen size */
extern int num_colors;
extern int micron_width, micron_height;
extern int app_handle;

/* DMA Sound */
extern void playit(), stop_sound();
extern int getcookie();
extern int ahh_sample[], clear_sample[], step_sample[], mark_sample[];
extern int yeah_sample[], success_sample[];

/* Resources */
OBJECT *mines_menu, *mines_about, *mines_scores, *mines_best,
       *help1, *help2, *fini, *kaboom;

/* Messages and such */
char no_resource[80] = "[3][Couldn't find LANDMINE.RSC.|Please try again.][ OK ]";
char boom_string[40] = "Boom... 000 Secs";
extern char mines_status[];
int messages[16];
char tnt_pattern[32] = {
	0x00, 0x00,
	0x00, 0x00,
	0x01, 0xE0,
	0x0E, 0x10,
	0x10, 0x30,
	0x00, 0xC0,
	0x01, 0xE0,
	0x03, 0x30,
	0x06, 0x18,
	0x04, 0x08,
	0x05, 0x08,
	0x06, 0xD8,
	0x03, 0x30,
	0x01, 0xE0,
	0x00, 0x00,
	0x00, 0x00
};

FDB screen, bomb;

/* Sounds */
#define MAX_EFFECTS		6
#define STEP_EFFECT		0
#define CLEAR_EFFECT		1
#define MARK_EFFECT		2
#define BOMB_EFFECT		3
#define HIGH_EFFECT		4
#define SUCCESS_EFFECT		5
extern char pow[], pow1[], boom[], boom1[], bonus[];
char *effects_paths[MAX_EFFECTS] = {
	NULL, NULL, NULL, NULL, NULL, NULL
};
char *effects[MAX_EFFECTS] = {
	step_sample, clear_sample, mark_sample, ahh_sample, yeah_sample,
	success_sample
};

int high_score_name_map[10] = {
	HINM0, HINM1, HINM2, HINM3, HINM4, HINM5, HINM6, HINM7, HINM8, HINM9
};

int high_score_board_map[10] = {
	HIBD0, HIBD1, HIBD2, HIBD3, HIBD4, HIBD5, HIBD6, HIBD7, HIBD8, HIBD9
};

void draw_besel();

int get_resource()
/*
	Load the MINES.RSC file to set up menus, dialogs and such.
*/
{
	TEDINFO *best_name;

	if (!rsrc_load("LANDMINE.RSC")) { return 0; }

	rsrc_gaddr(0, ABOUTIT, &mines_about);	
	rsrc_gaddr(0, MINEMENU, &mines_menu);	
	rsrc_gaddr(0, HIGHSCR, &mines_scores);	
	rsrc_gaddr(0, BEST, &mines_best);	
	rsrc_gaddr(0, HELP1, &help1);
	rsrc_gaddr(0, HELP2, &help2);
	rsrc_gaddr(0, FINI, &fini);
	rsrc_gaddr(0, BABOOM, &kaboom);

	best_name = (TEDINFO *)(mines_best[BESTNAME].ob_spec);
	strcpy(best_name->te_ptext, "@@@@@@@@@@@");

	return 1;
}

void write_scores()
/*
	Try to write out the LANDMINE.INF file that contains all the level
	definitions, the names, and the times.  Also write out the
	current board index, and the sounds flag.
*/
{
	int i;
	FILE *inf;

	if ((inf = fopen("LANDMINE.INF", "w")) == NULL) return;

	for (i = 0; i < MAX_BOARDS; ++i) {
		fprintf(inf, "B: %d\t%d\t%d\t%d\t%d\t%12s\n",
			i, boards_width[i], boards_height[i], boards_mines[i],
			boards_scores[i], boards_names[i]);
	}
	fprintf(inf, "C: %d\n", board_index);
	fprintf(inf, "S: %d\n", sounds);

	for (i = 0; i < MAX_EFFECTS; ++i) {
		if (effects_paths[i] != NULL) {
			fprintf(inf, "E: %d %s\n", i, effects_paths[i]);
		}
	}

	fclose(inf);

	return;
}

int get_setup()
/*
	Try to load the user options from LANDMINE.INF, for board sizes,
	high scores, sound toggle.
*/
{
	FILE *inf;
	int i, dummy;
	int tabs, index;
	char line[255];		/* Line buffer for config file */
	char path[255];		/* Complete path to sound effect */
	int effect;		/* Which sound effect this replaces */
	long effect_size;

	if ((inf = fopen("LANDMINE.INF", "r")) == NULL) return 0;

	while(fgets(line, 255, inf) != NULL) {
		if (line[0] == 'B') {
			/* Board definition */
			i = atoi(&line[3]);
			sscanf(line, "B: %d\t%d\t%d\t%d\t%d\n",
			&dummy, &boards_width[i], &boards_height[i],
			&boards_mines[i],
			&boards_scores[i]);
			if (boards_mines[i] > 99) boards_mines[i] = 99;
			for (tabs = 0, index = 0; tabs < 5; ++index) {
				if (line[index] == '\t') ++tabs;
			}
			strncpy(boards_names[i], &line[index], 12);
			index = 12;
			while ((index > 0) &&
			       isspace(boards_names[i][index])) {
				--index;
			}
			boards_names[i][index + 1] = '\0';
		} else if (line[0] == 'S') {
			/* Sound toggle flag */
			sscanf(line, "S: %d\n", &sounds);
		} else if (line[0] == 'C') {
			/* Current board */
			sscanf(line, "C: %d\n", &board_index);
		} else if (line[0] == 'E') {
			/* Sound effect */
			sscanf(line, "E: %d %s\n", &effect, path);
			if (effect < MAX_EFFECTS) {
				effects_paths[effect] = malloc(sizeof(path) + 1);
				strcpy(effects_paths[effect], path);
			}
		}
	}
	fclose(inf);

	/* Load any user-defined sounds */
	for (i = 0; i < MAX_EFFECTS; ++i) {
		if (effects_paths[i] != NULL) {
			inf = fopen(effects_paths[i], "rb");
			if (inf != NULL) {
				fseek(inf, 0L, 2);
				effect_size = ftell(inf);
				effects[i] = malloc((int )effect_size);
				fseek(inf, 0L, 0);
				fread(effects[i], 1, (int )effect_size, inf);
				fclose(inf);
			}
		}
	}

	return 1;
}

int do_setup()
/*
	Loads from the data structures for high scores, etc. into the
	resource for display.
*/
{
	int i;

	for (i = 0; i < MAX_BOARDS; ++i) {
		sprintf((char *)mines_menu[i + BOARD0].ob_spec,
			"  %2dx%-2d %2d Mines F%-2d", boards_width[i],
			boards_height[i], boards_mines[i], i + 1);
		sprintf(*(char **)mines_scores[high_score_board_map[i]].ob_spec,
			"%2dx%-2d %2d Mines",
			boards_width[i], boards_height[i], boards_mines[i]);
		sprintf((char *)mines_scores[high_score_name_map[i]].ob_spec,
			"%-12s %3d Secs", boards_names[i], boards_scores[i]);
	}
	mines_menu[BOARD0 + board_index].ob_state |= CHECKED;
	board_width = boards_width[board_index];
	board_height = boards_height[board_index];
	board_mines = board_remain = boards_mines[board_index];
	board_time = 0;

	if (sounds) {
		mines_menu[SOUND].ob_state |= CHECKED;
	} else {
		mines_menu[SOUND].ob_state &= ~CHECKED;
	}
}

void reset_highs()
/*
	Put the maximum possible score (worst) in each high score.
*/
{
	int i;

	for (i = 0; i < MAX_BOARDS; ++i) {
		boards_scores[i] = MAX_SCORE;
		strcpy(boards_names[i], "Landmines!");
	}
	do_setup();

	return;
}

void show_info()
/*
	Change the information line on the current landMines! window to
	reflect new # mines data, and new time.
*/
{
	if (win_open) {
		if ((SCw <= 320) && (board_index < 2)) {
			sprintf(mines_status, "%2d M %3d S",
				user_mine_count, board_time);
		} else {
			sprintf(mines_status, "%2d Mines %3d Secs",
				user_mine_count, board_time);
		}
		wind_set(win_handle, WF_INFO, mines_status, 0, 0, 0);
	}
}

void place_mine(x, y)
int x, y;
{
	int j;
	int row_index, temp_index;
	int max_index;

	max_index = board_width * board_height;

	row_index = (y - 1) * board_width;

	for (j = 0; j < 3; ++j) {
		temp_index = row_index + x;
		if ((row_index >= 0) && (row_index < max_index)) {
			if (x > 0) mine_arena[temp_index - 1].mines_around++;
			mine_arena[temp_index].mines_around++;
			if (x < (board_width - 1)) mine_arena[temp_index + 1].mines_around++;
		}
		row_index += board_width;
	}
}

void reposition_mine(x, y)
int x, y;
/*
	Take a mine from x, y and place it somewhere else on the board,
	anywhere else on the board, we really don't care.
*/
{
	int j;
	int newx, newy;
	int row_index, temp_index;
	int max_index;

	max_index = board_width * board_height;

	/*
	   Find a new home for the mine, not current home, which already
	   is marked as a landmine, so its OK
	*/
	do {
		newx = (int )Random() % board_width;
		newy = (int )Random() % board_height;
		newx = (newx > 0) ? newx : -newx;
		newy = (newy > 0) ? newy : -newy;
		row_index = newy * board_width;
	} while (mine_arena[newx + row_index].mine_type == LAND_MINE);

	/* Put the mine down */
	mine_arena[newx + row_index].mine_type = LAND_MINE;

	/* Account for the mine in neighbors */
	place_mine(newx, newy);

	/* Erase the previous mine */
	row_index = y * board_width;
	mine_arena[x + row_index].mine_type = NO_MINE;

	/* Account for the mine in neighbors */
	row_index -= board_width;
	for (j = 0; j < 3; ++j) {
		temp_index = row_index + x;
		if ((row_index >= 0) && (row_index < max_index)) {
			if (x > 0) mine_arena[temp_index - 1].mines_around--;
			mine_arena[temp_index].mines_around--;
			if (x < (board_width - 1)) mine_arena[temp_index + 1].mines_around--;
		}
		row_index += board_width;
	}
}

void initialize_board()
/*
	Clears the board for the current width and height.
*/
{
	int i;
	register int x, y;
	register int row_index;
	int max_index;

	max_index = board_width * board_height;

	/* Clear the board */
	for (y = 0; y < board_height; ++y) {
		row_index = y * board_width;
		for (x = 0; x < board_width; ++x) {
			mine_arena[x + row_index].mine_type = NO_MINE;
			mine_arena[x + row_index].state = HIDDEN;
			mine_arena[x + row_index].marked = UNTOUCHED;
			mine_arena[x + row_index].mines_around = 0;
		}
	}

	/* Drop down the mines on the board */
	for (i = 0; i < board_mines; ++i) {
		do {
			x = (int )Random() % board_width;
			y = (int )Random() % board_height;
			x = (x > 0) ? x : -x;
			y = (y > 0) ? y : -y;
			row_index = y * board_width;
		} while (mine_arena[x + row_index].mine_type == LAND_MINE);

		mine_arena[x + row_index].mine_type = LAND_MINE;
		
		place_mine(x, y);
	}

	/* Reset the time */
	board_time = 0;
	mine_count = board_mines;
	user_mine_count = board_mines;
	game_state = FROZEN;
	first_step = TRUE;

	base_board = (int )(Random() % num_colors);
	base_board = (base_board > 0) ? base_board : -base_board;

	show_info();

	return;
}

void check_best()
/*
	Check to see if this score is lower than the current low
	score for this particular board.  If so, then bring up the
	best dialog.  Allows user to enter name, then bring up the
	high scores dialog.  Otherwise, do nothing.
*/
{
	long save_super;
	TEDINFO *best_name;

	if (boards_scores[board_index] > board_time) {
		sprintf((char *)(mines_best[SCOREIT].ob_spec),
			"%2dx%-2d %2d Mines in %3d Secs",
			board_width, board_height, board_mines, board_time);
		best_name = (TEDINFO *)(mines_best[BESTNAME].ob_spec);

		if (DMA_sound && sounds) {
			save_super = Super(0L);
			playit(effects[HIGH_EFFECT], 0, 0, 0, 0);
			Super(save_super);
		}

		do_dialog(mines_best);

		boards_scores[board_index] = board_time;
		strcpy(boards_names[board_index], best_name->te_ptext);

		if (boards_names[board_index][0] == '@') {
			/* No name means blanks */
			boards_names[board_index][0] = '\0';
		}

		sprintf((char *)mines_scores[high_score_name_map[board_index]].ob_spec,
			"%12s %3d Secs", boards_names[board_index],
			boards_scores[board_index]);
		
		write_scores();

		do_dialog(mines_scores);
	} else {
		/* Good, but not great */
		if (sounds) {
			if (DMA_sound) {
				save_super = Super(0L);
				playit(effects[SUCCESS_EFFECT], 0, 0, 0, 0);
				Super(save_super);
			} else {
				Dosound(bonus);
			}
		}
		do_dialog(fini);
	}

	return;
}

void draw_exposed(x, y, cell)
int x, y;				/* Cell positions */
MINE_PTR cell;
/*
	Draw a cell, with mine or without.
	Must be exposed -- draws the # of neighboring cells with mines in them.
*/
{
	int bounds[8];
	char count[2];
	int colors[2];
	int a_line[4];

	bounds[0] = board_x + (x * cell_x);
	bounds[1] = board_y + (y * cell_y);
	bounds[2] = bounds[0] + cell_x - 1;
	bounds[3] = bounds[1] + cell_y - 1;

	if ((cell->state == MARKED_MINE) || (cell->mine_type == LAND_MINE)) {
		vsf_color(handle, 1);		/* Black */
		colors[0] = 0;
		colors[1] = 1;

		bounds[4] = bounds[0] + 1; 	/* Boundaries for blt */
		bounds[5] = bounds[1] + 1;
		bounds[6] = bounds[2] - 1;
		bounds[7] = bounds[3] - 1;
		bounds[0] = (16 - (bounds[6] - bounds[4] + 1)) / 2;
		bounds[1] = (16 - (bounds[7] - bounds[5] + 1)) / 2;
		bounds[2] = bounds[0] + (bounds[6] - bounds[4]);
		bounds[3] = bounds[1] + (bounds[7] - bounds[5]);

		if ((bounds[0] <= 2) && (bounds[1] <= 2)) {
			mouse_off();
			vrt_cpyfm(handle, 1, bounds, &bomb, &screen, colors);
			draw_besel(x, y, shades[2], shades[1], shades[0]);
			mouse_on();
		} else {
			a_line[0] = bounds[6];
			a_line[1] = bounds[5];
			a_line[2] = bounds[4];
			a_line[3] = bounds[7];
			vsl_color(handle, 0);

			mouse_off();
			vr_recfl(handle, &bounds[4]);
			v_pline(handle, 2, &bounds[4]);
			v_pline(handle, 2, a_line);
			draw_besel(x, y, shades[2], shades[1], shades[0]);
			mouse_on();
		}

		return;
	}

	vsf_color(handle, 0);		/* White */

	mouse_off();
	v_bar(handle, bounds);

	if (cell->mines_around != 0) {
		vst_color(handle, mine_colors[cell->mines_around]);
		count[1] = '\0';
		count[0] = (char )('0' + (char )cell->mines_around);
		vswr_mode(handle, 2);		/* transparent */
		v_gtext(handle, (bounds[0] + bounds[2] + 1) / 2, bounds[3] -
		        ((bounds[3] - bounds[1] - text_height + 1) / 2) - 1,
			count);
		vswr_mode(handle, 1);		/* replace */
	}
	mouse_on();

	return;
}

void draw_besel(x, y, outer, middle, inner)
int x, y;			/* position in cells */
int outer, middle, inner;	/* colors for the besel */
/*
	Draws a 3D besel using the given colors for shading.
*/
{
	int rect[4];
	int line1[10], line2[10], line3[10];

	rect[0] = line1[0] = line1[6] = board_x + (x * cell_x);
	rect[1] = line1[1] = line1[3] = board_y + (y * cell_y);
	rect[2] = line1[4] = line1[2] = rect[0] + cell_x - 1;
	rect[3] = line1[5] = line1[7] = rect[1] + cell_y - 1;
	line1[8] = line1[0];
	line1[9] = line1[1];

	rect[0]++; rect[1]++;		/* Inset by 1 */
	rect[2]--; rect[3]--;
	line2[0] = line2[6] = rect[0];
	line2[1] = line2[3] = rect[1];
	line2[4] = line2[2] = rect[2];
	line2[5] = line2[7] = rect[3];
	line2[8] = line2[0];
	line2[9] = line2[1];

	rect[0]++; rect[1]++;		/* Inset by 1 */
	rect[2]--; rect[3]--;
	line3[0] = line3[6] = rect[0];
	line3[1] = line3[3] = rect[1];
	line3[4] = line3[2] = rect[2];
	line3[5] = line3[7] = rect[3];
	line3[8] = line3[0];
	line3[9] = line3[1];

	rect[0]++; rect[1]++;		/* Inset by 1 */
	rect[2]--; rect[3]--;

	vsl_color(handle, outer);
	v_pline(handle, 5, line1);

	if (!small_border) {
		vsl_color(handle, middle);
		v_pline(handle, 5, line2);
		vsl_color(handle, inner);
		v_pline(handle, 5, line3);
	}

	vsl_color(handle, 1);
}

void draw_hidden(x, y)
int x, y;
/*
	Display the given block at the given position.
*/
{
	int rect[4];

	rect[0] = board_x + (x * cell_x) + 1;
	rect[1] = board_y + (y * cell_y) + 1;
	rect[2] = rect[0] + cell_x - 1 - 2;
	rect[3] = rect[1] + cell_y - 1 - 2;

	mouse_off();

	vsf_color(handle, 0);		/* White inside */
	if (num_colors >= 16) {
		vsf_color(handle, 2 + (((x + base_board) + (y * board_width))
			  % (num_colors - 2)));
	}
	vsf_interior(handle, 1);
	vswr_mode(handle, 1);
	vsf_perimeter(handle, 0);

	v_bar(handle, rect);

	draw_besel(x, y, shades[0], shades[1], shades[2]);

	mouse_on();

	return;	
}

void draw_false(x, y)
int x, y;				/* Cell positions */
/*
	Draw a cell that's not identified correctly.
*/
{
	int bounds[4];

	bounds[0] = board_x + (x * cell_x) + 1;
	bounds[1] = board_y + (y * cell_y) + 1;
	bounds[2] = bounds[0] + cell_x - 1 - 2;
	bounds[3] = bounds[1] + cell_y - 1 - 2;

	vsf_color(handle, 1);		/* Black cross pattern */
	vsf_interior(handle, 3);
	vsf_style(handle, 3);

	mouse_off();
	v_bar(handle, bounds);
	draw_besel(x, y, shades[2], shades[1], shades[0]);
	mouse_on();

	vsf_interior(handle, 1);
	vsf_style(handle, 1);

	return;
}

void expose_all()
/*
	Traverses all the cells and exposes them.
	If there's a marked one that isn't a mine, show it!
*/
{
	register int x, y;
	register int row_index;

	mouse_off();
	for (y = 0; y < board_height; ++y) {
		row_index = y * board_width;
		for (x = 0; x < board_width; ++x) {
			if (mine_arena[row_index + x].state != EXPOSED) {
				if ((mine_arena[row_index + x].mine_type != LAND_MINE) &&
				    (mine_arena[row_index + x].state & MARKED_MINE)) {
					draw_false(x, y);
					mine_arena[row_index + x].state |= EXPOSED;
				} else {
					mine_arena[row_index + x].state = EXPOSED;
					draw_exposed(x, y, &mine_arena[row_index + x]);
				}
			}
		}
	}
	mouse_on();

	return;
}

void redraw_board(rx, ry, rw, rh)
int rx, ry;				/* Upper left corner of redraw area */
int rw, rh;				/* Width and height */
/*
	Given the collision area in absolute coordinates, redraws the
	overlapping cells (with clipping).
*/
{
	register int x, y;
	int start_x, start_y;
	register int end_x, end_y;
	register int row_index;
	int state;			/* Mine's display state */
	int clip_region[4];		/* Damaged region */

	/* Set up the clip region, bounded by the screen */
	clip_region[0] = rx;
	clip_region[1] = ry;
	clip_region[2] = rx + rw - 1;
	clip_region[3] = ry + rh - 1;
	if (clip_region[2] >= SCw) clip_region[2] = SCw - 1;
	if (clip_region[3] >= SCh) clip_region[3] = SCh - 1;
	vs_clip(handle, 1, clip_region);
	
	start_x = (int )((rx - board_x) / cell_x);
	start_y = (int )((ry - board_y) / cell_y);
	if (start_x < 0) start_x = 0;
	if (start_y < 0) start_y = 0;

       	end_x = start_x + (int )((rx + rw + (cell_x / 2)) / cell_x);
	end_y = start_y + (int )((ry + rh + (cell_y / 2)) / cell_y);
	if (end_x >= board_width) end_x = board_width - 1;
	if (end_y >= board_height) end_y = board_height - 1;

	mouse_off();

	if (first_step) {
		for (y = start_y; y <= end_y; ++y) {
			for (x = start_x; x <= end_x; ++x) {
				draw_hidden(x, y);
			}
		}
	} else {
		for (y = start_y; y <= end_y; ++y) {
			row_index = y * board_width;
			for (x = start_x; x <= end_x; ++x) {
				state = mine_arena[row_index + x].state;
				if (state == (MARKED_MINE | EXPOSED)) {
					draw_false(x, y);
				} else 	if ((state & MARKED_MINE) || (state & EXPOSED)) {
					draw_exposed(x, y, &mine_arena[row_index + x]);
				} else {
					draw_hidden(x, y);
				}
			}
		}
	}
	mouse_on();
	vs_clip(handle, 0, clip_region);

	return;
}

void flood_from(x, y)
int x, y;
/*
	Performs a flood fill to expose zero-mine pieces.
*/
{
	int cell;

	if ((x < 0) || (x >= board_width)) return;
	if ((y < 0) || (y >= board_height)) return;

	cell = (y * board_width) + x;

	/* Terminate if already handled */
	if (mine_arena[cell].marked == TOUCHED) return;
	mine_arena[cell].marked = TOUCHED;

	/* Terminate if marked as a mine already */
	if ((mine_arena[cell].state == MARKED_MINE) ||
	    (mine_arena[cell].mine_type == LAND_MINE)) return;

	mine_arena[cell].state = EXPOSED;
	draw_exposed(x, y, &mine_arena[cell]);

	if (mine_arena[cell].mines_around == 0) {
		flood_from(x - 1, y - 1);
		flood_from(x, y - 1);
		flood_from(x + 1, y - 1);
		flood_from(x - 1, y);
		flood_from(x + 1, y);
		flood_from(x - 1, y + 1);
		flood_from(x, y + 1);
		flood_from(x + 1, y + 1);
	}

return;
}

void clear_marks()
/*
	Clears the board of all marks from the flood fill.
*/
{
	register int x, y;
	register int row_index;

	for (y = 0; y < board_height; ++y) {
		row_index = y * board_width;
		for (x = 0; x < board_width; ++x) {
			mine_arena[row_index + x].marked = UNTOUCHED;
		}
	}
	return;
}

void button_handler(mx, my, button)
int mx, my;				/* Mouse coordinates */
int button;				/* Button state */
{
	int touch_x, touch_y;
	int cell_offset;
	long save_super;

	/* Eliminate bogus clicks in info area. */
	if ((mx < board_x) || (my < board_y)) {
		return;
	}

	if (button_mode == WAIT_RELEASE) {
		if ((button & 3) == 0) button_mode = ACCEPT;
		return;
	}
	if ((button & 3) == 0) return;

	touch_x = (mx - board_x) / cell_x;
	touch_y = (my - board_y) / cell_y;

	if ((touch_x < 0) || (touch_x >= board_width)) return;
	if ((touch_y < 0) || (touch_y >= board_height)) return;

	cell_offset = touch_x + (touch_y * board_width);

	/* Don't allow first step to be a boom! */
	if (first_step && (mine_arena[cell_offset].mine_type == LAND_MINE) &&
	    (button & 1)) {
		reposition_mine(touch_x, touch_y);
	}

	if (button & 1)	{
		/* Only first step once */
		first_step = FALSE;

		if ((mine_arena[cell_offset].state == MARKED_MINE) ||
		    (mine_arena[cell_offset].state == EXPOSED)) {
			/* Don't allow user to step on mine if marked */
			button_mode = WAIT_RELEASE;
			return;
		}

		if (mine_arena[cell_offset].mine_type == LAND_MINE) {
			/* Boom. */
			if (sounds) {
				if (DMA_sound) {
					save_super = Super(0L);
					playit(effects[BOMB_EFFECT], 0,
					       0, 0, 0);
					Super(save_super);
				} else {
					Dosound(boom1);
				}
			}
			game_state = OVER;
			sprintf(boom_string, "Boom... %d Secs", board_time);
			wind_set(win_handle, WF_INFO, boom_string, 0, 0, 0);
			expose_all();
			button_mode = ACCEPT;
			/* do_dialog(kaboom); */
		} else if (mine_arena[cell_offset].mines_around == 0) {
			/* Flood fill, as it were... */
			if (sounds) {
				if (DMA_sound) {
					save_super = Super(0L);
					playit(effects[CLEAR_EFFECT], 0,
					       0, 0, 0);
					Super(save_super);
				} else {
					Dosound(boom);
				}
			}
			flood_from(touch_x, touch_y);
			clear_marks();
		} else {
			if (sounds) {
				if (DMA_sound) {
					save_super = Super(0L);
					playit(effects[STEP_EFFECT], 0,
					       0, 0, 0);
					Super(save_super);
				} else {
					Dosound(pow);
				}
			}
			mine_arena[cell_offset].state = EXPOSED;
			draw_exposed(touch_x, touch_y, &mine_arena[cell_offset]);
		}
	} else if (button & 2) {
		first_step = FALSE;
		if (mine_arena[cell_offset].state == MARKED_MINE) {
			if (sounds) {
				if (DMA_sound) {
					save_super = Super(0L);
					playit(effects[MARK_EFFECT], 0,
					       0, 0, 0);
					Super(save_super);
				} else {
					Dosound(pow1);
				}
			}

			/* If marked as a mine, go back to hidden */
			mine_arena[cell_offset].state = HIDDEN;
			draw_hidden(touch_x, touch_y);
			if (mine_arena[cell_offset].mine_type == LAND_MINE) {
				mine_count++;
			}
			button_mode = WAIT_RELEASE;
			user_mine_count++;
			show_info();
			return;
		} else if (mine_arena[cell_offset].state == HIDDEN) {
			if (sounds) {
				if (DMA_sound) {
					save_super = Super(0L);
					playit(effects[MARK_EFFECT],
					       0, 0, 0, 0);
					Super(save_super);
				} else {
					Dosound(pow1);
				}
			}
			/* If hidden, mark this is a mine */
			mine_arena[cell_offset].state = MARKED_MINE;
			if (mine_arena[cell_offset].mine_type == LAND_MINE) {
				mine_count--;
			}
			user_mine_count--;
			show_info();

		} else {
			/* If exposed, then don't bother doing anything */
			button_mode = WAIT_RELEASE;
			return;
		}
		draw_exposed(touch_x, touch_y, &mine_arena[cell_offset]);
	}

	if ((mine_count == 0) && (user_mine_count == 0)) {
		/* Game complete, check high score */
		game_state = COMPLETE;
		expose_all();
		check_best();
	}

	button_mode = WAIT_RELEASE;

	return;
}

int do_menu_select(option)
int option;
/* do_menu_select(option)
   Take the given option and perform the required subroutine for it's
   action. Returns the value of out -- 0 == stay in, 1 == exit.
 */
{
	int out = 0;

	/* If this selection is gray, forget it! */
	if (mines_menu[option].ob_state & DISABLED) return 0;
	
	switch(option) {
		case QUIT:
			out = 1;
			break;
		case ABOUT:
			do_dialog(mines_about);
			break;
		case PAUSE:
			if (game_state == ACTIVE) {
				game_state = FROZEN;
			}
			break;
		case NEWGAME:
			initialize_board();
			if (!win_open) {
				if ((win_handle = new_window()) < 0) {
					v_clsvwk(handle);
					appl_exit();
					exit();
				}
				win_open = TRUE;
				show_info();
			} else {
				/* Force a redraw of the entire thing */
				redraw_board(board_x, board_y,
					     (board_width * cell_x),
					     (board_height * cell_y));
			}
			button_mode = ACCEPT;
			
			break;
		case SHOWHI:
			do_dialog(mines_scores);
			break;
		case RESETHI:
			reset_highs();
			write_scores();
			break;
		case CLOSE:
			if (win_open) {
				close_window(win_handle);
				win_open = FALSE;
			}
			break;
		case SOUND:
			sounds = (sounds) ? FALSE : TRUE;
			if (sounds) {
				mines_menu[SOUND].ob_state |= CHECKED;
			} else {
				mines_menu[SOUND].ob_state &= ~CHECKED;
			}
			write_scores();
			break;
		case BASEHELP:
			do_dialog(help1);
			break;
		case ADVHELP:
			do_dialog(help2);
			break;
		case BOARD0:
		case BOARD1:
		case BOARD2:
		case BOARD3:
		case BOARD4:
		case BOARD5:
		case BOARD6:
		case BOARD7:
		case BOARD8:
		case BOARD9:
			/* Set the new dimensions */
			mines_menu[board_index + BOARD0].ob_state &= ~CHECKED;
			mines_menu[option].ob_state |= CHECKED;

			board_index = option - BOARD0;
			board_width = boards_width[board_index];
			board_height = boards_height[board_index];
			board_mines = board_remain = boards_mines[board_index];

			if (win_open) {
				close_window(win_handle);
				win_open = FALSE;
			}
			do_menu_select(NEWGAME);
			write_scores();
			
			break;
		default:
			break;
		}

	return(out);
}

int message_handler(messages)
int messages[];
/*
	Menu, window messages
*/
{
	int x, y, w, h;
	int out = 0;

	switch(messages[0]) {
		case WM_TOPPED:
			if ((messages[3] != win_handle) ||
			    (win_open != TRUE)) break;
			wind_set(win_handle, WF_TOP, 0, 0, 0, 0);
			break;
		case WM_CLOSED:
			if ((messages[3] != win_handle) ||
			    (win_open != TRUE)) break;

			close_window(win_handle);

			win_open = FALSE;
			break;
		case WM_REDRAW:
			if ((messages[3] != win_handle) ||
			    (win_open != TRUE))	break;
			redraw_event(win_handle, (GRECT *)&messages[4]);
			break;
		case WM_MOVED:
			if ((messages[3] != win_handle) ||
			    (win_open != TRUE)) break; 
			x = currx = messages[4]; 
			y = curry = messages[5];
			w = currw; 
			h = currh;
			wind_set(win_handle, WF_CURRXYWH, x, y, w, h);
			wind_get(win_handle, WF_WORKXYWH, 
				 &workx, &worky, 
				 &workw, &workh);

			board_x = workx;
			board_y = worky;

			break;
		case MN_SELECTED:
			out = do_menu_select(messages[4]);
			menu_tnormal(mines_menu, messages[3], 1);
			break;
		case WM_ALLCLOSE:
			out = 1;
			break;
		default:
			break;
	}

	/* Close down the window? */
	if (out && win_open) close_window(win_handle);

	return out;
}

long current_time()
{
	long save_super;
	long time_now;

	save_super = Super(0L);
	time_now = *((long *)0x4BA);	/* 200hz */
	Super(save_super);

	return time_now;
}

void get_events()
/*
	Handle menu bar events, timer events, click events, key events,
	until QUIT is selected.
*/
{
	int mx, my, button, keystate, dummy;
	unsigned int key;
	int breturn;
	int top_wind;			/* Top window handle */
	int type = 0, out = 0;
	long start_time;
	int time_remaining = 1000;
	int base_clip[4];

	start_time = current_time();

	while (out != 1) {
		type = 0;
		while (!(type & MU_KEYBD) && !(type & MU_MESAG) && 
		       !(type & MU_BUTTON) && !(type & MU_TIMER)) {

			type = evnt_multi((MU_KEYBD | MU_MESAG | MU_BUTTON | MU_TIMER), 
					0x182, 3, 3,
					0, 0, 0, 0, 0,
					0, 0, 0, 0, 0, 
					messages,
					time_remaining, 0,
					&mx, &my, &button, &keystate,
					&key, &breturn);
		}

		wind_get(win_handle, WF_TOP, &top_wind, &dummy, &dummy, &dummy);
		if (top_wind != win_handle) {
			if (game_state == ACTIVE) game_state == FROZEN;
		}

		/* Base clip region is the screen */
		base_clip[0] = base_clip[1] = 0;
		base_clip[2] = SCw - 1;
		base_clip[3] = SCh - 1;
		vs_clip(handle, 1, base_clip);

		wind_update(BEG_UPDATE);

		if (type & MU_KEYBD) {
			if (keystate & 4) {
			switch (key & 0xFF) {
				case 0x0E:	/* Control-N New Game */
					out = do_menu_select(NEWGAME);
					break;
				case 0x08:	/* Control-H High Scores */
					out = do_menu_select(SHOWHI);
					break;
				case 0x01:	/* Control-A Sound Toggle */
					out = do_menu_select(SOUND);
					break;
				case 0x11:	/* Control-Q Quit */
					out = do_menu_select(QUIT);
					break;
				case 0x17:	/* Control-W Close Window */
					out = do_menu_select(CLOSE);
					break;
				default:
					break;
				}
			} else {
				switch(key) {
				case 0x6200:		/* help key */
					out = do_menu_select(BASEHELP);
					break;
				case 0x3B00:
				case 0x3C00:
				case 0x3D00:
				case 0x3E00:
				case 0x3F00:
				case 0x4000:
				case 0x4100:
				case 0x4200:
				case 0x4300:
				case 0x4400:
					out = do_menu_select((key >> 8) - 0x3B + BOARD0);
					break;
				case 0x011B:	/* Esc Pause Game */
					out = do_menu_select(PAUSE);
					break;
				default:
					break;
				}
			}
			type &= ~MU_KEYBD;
		}

		if (type & MU_MESAG) {
			out = message_handler(messages);
			type &= ~MU_MESAG;
		}

		if (type & MU_BUTTON) {
			vq_mouse(handle, &button, &dummy, &dummy);
			if ((button & 3) && (game_state == FROZEN)) {
				game_state = ACTIVE;
			}

			if ((win_open == TRUE) && (top_wind == win_handle) &&
			    (game_state == ACTIVE)) {
				button_handler(mx, my, button);
			} else if ((win_open == TRUE) && (top_wind == win_handle) &&
				   ((game_state == OVER) || (game_state == COMPLETE))) {
				if (button == 3) {
					do_menu_select(NEWGAME);
				}
			}
			type &= ~MU_BUTTON;
		}

		if (type & MU_TIMER) {
			if ((win_open == TRUE) && (top_wind == win_handle) &&
			    (game_state == ACTIVE) && (first_step == FALSE)) {
				board_time++;
				show_info();
			}
			type &= ~MU_TIMER;
			time_remaining = 1000;
			start_time = current_time();
	
			if (board_time == 999) {
				/* Game over... Show everything... */
				game_state = OVER;
				wind_set(win_handle, WF_INFO, "Game Over.Click both to start.", 0, 0, 0);
				expose_all();
				button_mode = ACCEPT;
			}
		} else {
			time_remaining = (200 - (current_time() - start_time)) * 5;
			if (time_remaining < 0) time_remaining = 0;
		}

		wind_update(END_UPDATE);
	}
	return;
}

int find_color(color)
int color[3];
/*
	Search for the closest color to this indicated one.
*/
{
	int i;
	int rgb[3];
	int current_value;
	int closest_value = 0x7FFF, closest_idx = -1;
	
	for (i = 0; i < num_colors; ++i) {
		vq_color(handle, i, 1, rgb);
		current_value = abs(rgb[0] - color[0]);
		current_value += abs(rgb[1] - color[1]);
		current_value += abs(rgb[2] - color[2]);
		if (current_value < closest_value) {
			closest_value = current_value;
			closest_idx = i;
		}
	}
	
	/* Return color index */
	return closest_idx;
}

void initialize_colors()
/*
	Attempts to generate shades for the edges of pieces.
	Three gray levels is all we're interested in.
	We'll try to pick the closest we can...
*/
{
	int rgb[3];

	rgb[0] = rgb[1] = rgb[2] = 0;
	shades[0] = find_color(rgb);
	rgb[0] = rgb[1] = rgb[2] = 250;
	shades[1] = find_color(rgb);
	rgb[0] = rgb[1] = rgb[2] = 500;
	shades[2] = find_color(rgb);

	return;
}

int main()
{
	int dummy, i;
	int text_size[8];
	long temp;
	long mwidth, mheight;

	say_hello();
	open_work();

	/* Check the machine for DMA sounds */
	if (getcookie(0x5F534E44L, &temp)) {
		if (temp & 2) DMA_sound = TRUE;
	}
	/* Check to see if MiNT is running, if so then register menu */
	if (getcookie(0x4D694E54L, &temp)) {
		menu_register(app_handle, "  Landmine");
	}
	
	vsf_color(handle, 1);
	vsf_perimeter(handle, 1);
	vsf_interior(handle, 1);
	vst_alignment(handle, 1, 0, &dummy, &dummy);
	vswr_mode(handle, 1);
	vsf_udpat(handle, tnt_pattern, 1);
	vqt_extent(handle, "12345678", text_size);
	text_height = abs(text_size[1] - text_size[5]) - 1;
	initialize_colors();

	/* Hack for muddy colors in new TOS ROMs */
	if (num_colors > 188) num_colors = 188;

	for (i = 0; i < 10; ++i) {
		mine_colors[i] = (i % (num_colors - 1)) + 1;
	}

	/* Determine how big the cells are going to be! */
	mwidth = (long )micron_width;
	mheight = (long )micron_height;
	if (mwidth < mheight) {
		mheight = (mheight * 10000L) / mwidth;
		mwidth = 10000L;
	} else {
		mwidth = (mwidth * 10000L) / mheight;
		mheight = 10000L;
	}

	/* Assume that DPI won't be greater than 100, so larger screen
	   widths than 640 are bigger displays.  Smaller are a change
	  in DPI for this mode. */
	if ((SCw < 640) && (SCw > SCh)) {
		mwidth = (mwidth * 640L) / (long )SCw;
		mheight = (mheight * 640L) / (long )SCw;
	} else if ((SCh < 480) && (SCh > SCw)){
		mwidth = (mwidth * 480L) / (long )SCh;
		mheight = (mheight * 480L) / (long )SCh;
	}

	/* Determine how big the cells are going to be! */
	temp = 180000L;
	do {
		cell_x = (int )(temp / mwidth);
		cell_y = (int )(temp / mheight);
		temp -= 5L;
	} while (((20 * cell_y) + (text_height * 3)) > SCh);

	currx = cell_x;
	curry = cell_y * 2;

	if ((cell_x <= 8) || (cell_y <= 8)) {
		/* We've got a small box! */
		small_border = TRUE;
	}

	/* Always draw the perimeter. Lines in black. */
	vsl_color(handle, 1);
	vsl_ends(handle, 0, 0);
	vsl_type(handle, 1);

	screen.fd_addr = 0L;			/* MFDB for screen */
	bomb.fd_addr = (long )tnt_pattern;	/* MFDB for bomb pattern */
	bomb.fd_w = 16;
	bomb.fd_h = 16;
	bomb.fd_wdwidth = 1;
	bomb.fd_stand = 0;
	bomb.fd_nplanes = 1;
	bomb.fd_r1 = 0;
	bomb.fd_r2 = 0;
	bomb.fd_r3 = 0;

	if (get_resource()) {
		if (!get_setup()) {
			/* Initialize high scores */
			board_index = 0;
			reset_highs();
		}
		do_setup();
		mines_menu[mines_menu->ob_head].ob_width = SCw;
		menu_bar(mines_menu, 1);	/* Draw the menu bar */
		get_events();			/* Events until quit */
		menu_bar(mines_menu, 0);	/* Remove the menu bar */
	} else {
		form_alert(1, no_resource);
	}

	if (DMA_sound) {
		temp = Super(0L);
		stop_sound();
		Super(temp);
	}

	close_work();
	clean_up();

	return 0;
}
