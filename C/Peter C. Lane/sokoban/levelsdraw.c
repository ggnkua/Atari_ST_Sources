#include "levelsdraw.h"

/* Draws the interior of the level table window */
void levels_draw (int app_handle, struct win_data * wd, struct scores * score_table, int x, int y, int w, int h) {
	char * string;
	struct level * current;
	int dum, cell_h;
	int level_count = 0;
	int lines_to_ignore = wd->vert_posn;
	int screen_y = y; /* top of screen */
	int widest_level_title = 0;

	/* find the widest level title */
	current = wd->ld->levels;
	while (current != NULL) {
		if (strlen (current->title) > widest_level_title) {
			widest_level_title = strlen(current->title);
		}

		current = current->next;
	}
	/* Create string to fit widest level description */
	string = malloc(sizeof(char)*(widest_level_title+20));

	vst_color (app_handle, 1);
	vst_point (app_handle, 11, &dum, &dum, &dum, &cell_h);

	/* Display all visible rows in table */

	wd->lines_shown = 0; /* update the number of lines shown to current record */
	wd->colns_shown = 0; /* update the number of columns shown to current record */

	current = wd->ld->levels;
	wd->lines_shown += 1;

	if (lines_to_ignore == 0) {
		y += cell_h;

		sprintf (string, "%-*s Moves  Pushes ", widest_level_title, "Name");
		if (strlen(string) > wd->colns_shown) wd->colns_shown = strlen(string);
		if (strlen(string) > wd->horz_posn) { /* display visible part of string */
			vst_effects (app_handle, 8); /* Underline the title */
			v_gtext (app_handle, x+8, y, string+wd->horz_posn);
			vst_effects (app_handle, 0);
		}
	} else {
		lines_to_ignore -= 1;
	}

	wd->lines_shown += 1;
	if (lines_to_ignore == 0) {
		y += cell_h;
	} else {
		lines_to_ignore -= 1;
	}
	wd->lines_shown += 1;
	if (lines_to_ignore == 0) {
		y += cell_h;
	} else {
		lines_to_ignore -= 1;
	}

	while (current != NULL) {
		int num_moves, num_pushes;

		level_count += 1;
		wd->lines_shown += 1;
		if (scores_find (score_table, wd->ld->title, current->title, &num_moves, &num_pushes)) {
			sprintf (string, "%-*s %4d   %4d ", widest_level_title, current->title, num_moves, num_pushes);
		} else {
			sprintf (string, "%-*s  --     -- ", widest_level_title, current->title);
		}
		if (lines_to_ignore == 0) {
			if (strlen(string) > wd->horz_posn) { /* display visible part of string */
				v_gtext (app_handle, x+8, y, string+wd->horz_posn);
			}
			y += cell_h;

			wd->start_posns[level_count-1]=y-2*cell_h+1-screen_y; /* y points at base of next text line */
			wd->end_posns[level_count-1]=y-cell_h-screen_y;

		} else {
			lines_to_ignore -= 1;

			wd->start_posns[level_count-1]=-1;
			wd->end_posns[level_count-1]=-1;
		}

		current = current->next;
	}
	free (string);

	wd->lines_shown += 1; /* gain a bit of space at bottom of window */
	wd->colns_shown += 2; /* gain a bit of space on the right of window */
}
