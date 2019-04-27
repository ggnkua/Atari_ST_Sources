#include "statsdraw.h"

void stats_draw (int app_handle, struct win_data * wd, struct scores * score_table, int x, int y, int w, int h) {
	char * string;
	struct scores * current;
	int widest_name = 0;
	int cell_h, dum;
	int lines_to_ignore = wd->vert_posn;

	/* find the widest levels title */
	current = score_table;
	while (current != NULL) {
		if (strlen (current->name) > widest_name) {
			widest_name = strlen (current->name);
		}
		current = current->next;
	}
	/* Create string to fit widest level description */
	string = malloc (sizeof(char)*(widest_name+20));

	vst_color (app_handle, 1);
	vst_point (app_handle, 11, &dum, &dum, &dum, &cell_h);

	wd->lines_shown = 0; /* update the number of lines shown to current record */
	wd->colns_shown = 0; /* update the number of columns shown to current record */

	wd->lines_shown += 1;

	if (lines_to_ignore == 0) {
		y += cell_h;

		sprintf (string, "%-*s  Completed ", widest_name, "Name");
		if (strlen(string) > wd->colns_shown) wd->colns_shown = strlen(string);
		if (strlen(string) > wd->horz_posn) { /* display visible part of string */
			vst_effects (app_handle, 8); /* Underline the title */
			v_gtext (app_handle, x+8, y, string+wd->horz_posn);
			vst_effects (app_handle, 0);
		}
	} else {
		lines_to_ignore -= 1;
	}
	/* Blank line before values */
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

	/* Display all entries in score table */
	vst_color (app_handle, 1);
	vst_point (app_handle, 11, &dum, &dum, &dum, &cell_h);

	current = score_table;
	while (current != NULL) {
		int percent_done = (100*scores_number_done(score_table, current->name))/current->total_levels;
		wd->lines_shown += 1;
		sprintf (string, "%-*s   %4d%%", widest_name, current->name, percent_done);
		if (strlen(string) > wd->colns_shown) wd->colns_shown = strlen(string);
		if (lines_to_ignore == 0) {
			if (strlen(string) > wd->horz_posn) { /* display visible part of string */
				v_gtext (app_handle, x+8, y, string+wd->horz_posn);
			}
			y += cell_h;
		} else {
			lines_to_ignore -= 1;
		}

		current = current->next;
	}

	free (string);

	wd->lines_shown += 1; /* gain a bit of space at bottom of window */
	wd->colns_shown += 2; /* gain a bit of space on the right of window */
}