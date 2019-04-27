#include "windows.h"

int app_handle; /* application graphics handle */

/* GEM arrays */
int work_in[11],
	work_out[57],
	contrl[12],
	intin[128],
	ptsin[128],
	intout[128],
	ptsout[128];

int num_colours; /* number of colours in display */
int last_used_scale; /* last scale used in positions */

enum theme {SMALL_THEME, MEDIUM_THEME, LARGE_THEME};

void create_display (OBJECT * menu_addr, struct win_data * wd_list, struct level * level);
struct win_data * create_level_display (OBJECT * menu_addr, struct level_data * ld, struct scores * score_table);
void update_level_display (OBJECT * menu_addr, struct win_data * wd, struct scores * score_table);
void create_posns (struct win_data * wd);
void event_loop (OBJECT * menu_addr, struct win_data * wd, struct scores * score_table);

void make_move (struct win_data * top_win, struct win_data * wd, struct scores * score_table, enum direction dirn);
void undo_move (struct win_data * wd, struct scores * score_table);
void reset_position (struct win_data * wd, struct scores * score_table);
void close_level_displays (struct win_data * wd);
void open_levels_file (OBJECT * menu_addr, struct win_data * wd, struct scores * score_table);
void open_classic_levels (OBJECT * menu_addr, struct win_data * wd, struct scores * score_table);
void open_stats_window (OBJECT * menu_addr, struct win_data * wd, struct scores * score_table);
void update_levels_info_line (struct win_data * wd, struct scores * score_table);
void show_help_message (void);

void set_theme (OBJECT * menu_addr, struct win_data * wd, struct scores * score_table, enum theme t);
void update_theme_menu (OBJECT * menu_addr, struct win_data * wd);

struct win_data * get_win_data (struct win_data * wd, int handle);
void set_clip (bool flag, GRECT rec);
int slider_size (int avail_lines, int lines_shown);
int slider_posn (int avail_lines, int lines_shown, int top);
void calc_slid (struct win_data * wd);
bool is_window_full (struct win_data * wd);

void do_arrow (struct win_data * wd, struct scores * score_table, int arrow);
void do_close (struct win_data * wd, int handle);
void do_fulled (struct win_data * wd);
void do_menu (OBJECT * menu_addr, struct win_data * wd, struct scores * score_table, int menu);
void do_redraw (struct win_data * wd, struct scores * score_table, GRECT * rec1);
void do_sized (struct win_data * wd, struct scores * score_table, int * msg_buf);
void do_vslide (struct win_data * wd, struct scores * score_table, int posn);
void do_hslide (struct win_data * wd, struct scores * score_table, int posn);

void refresh_display (struct win_data * wd, struct scores * score_table, int type);
void draw_interior (struct win_data * wd, struct scores * score_table, GRECT clip, int type);

/* ---------------------------------------------------------------- */

/* open RSC and start window, and enter event loop */
void start_program (void) {

	if (!rsrc_load ("\SOKOBAN.rsc")) {
		form_alert (1, "[1][SOKOBAN .rsc file missing!][OK]");
	} else {
		OBJECT * menu_addr;
		struct level_data * ld = leveldata_create ();
		struct scores * score_table = scores_from_file ();

		rsrc_gaddr (R_TREE, MAIN_MENU, &menu_addr);
		menu_bar (menu_addr, true);

		graf_mouse (ARROW, 0L); /* ensure mouse is an arrow */
		leveldata_classic (ld);

		/* make sure classic is stored in score table */
		if (score_table == NULL) {
			score_table = scores_new (ld->title, ld->size);
		} else {
			scores_store_set (score_table, ld->title, ld->size);
		}

		event_loop (menu_addr, create_level_display (menu_addr, ld, score_table), score_table);

		menu_bar (menu_addr, false);
		scores_save_file (score_table);
		leveldata_free (ld);
	}
}

/* standard code to set up gem arrays and open work area */
void open_vwork (void) {
	int i;
	int dum;

	app_handle = graf_handle (&dum, &dum, &dum, &dum);
	for (i = 0; i < 10; work_in[i++] = 1);
	work_in[10] = 2;
	v_opnvwk (work_in, &app_handle, work_out);
	num_colours = work_out[13]; /* store number of colours */
	last_used_scale = MEDIUM_SIZE; /* set initial scale for positions */
}

/* ------------- private functions to handle GUI events ------------ */

/* Create a display window for given level, attaching it as
   the next window to end of wd list. */
void create_display (OBJECT * menu_addr, struct win_data * wd_list, struct level * level) {
	struct win_data * wd = malloc (sizeof (struct win_data));
	struct win_data * cur;
	int fullx, fully, fullw, fullh;
	int targetw, targeth;

	wd->window_type = POSITION;
	wd->ld = wd_list->ld; /* keep a reference to level list in all child windows */
	wd->level_title = level->title;
	wd->definition = level->definition;
	wd->position = position_from_defn (level->definition);
	wd->num_moves = 0;
	wd->num_pushes = 0;

	/* ideal size of window is based on level size + space for widgets */
	targetw = last_used_scale * (2 + wd->position->width) + 40;
	targeth = last_used_scale * (2 + wd->position->height) + 60;

	/* set up window */
	wind_get (0, WF_WORKXYWH, &fullx, &fully, &fullw, &fullh);
	wd->handle = wind_create (PARTS, fullx, fully, fullw, fullh);
	if (wd->handle < 0) { /* error, could not create window */
		position_free (wd->position);
		free (wd);
		form_alert (3, "[1][Error: could not create window|Try closing another window][OK]");
		return;
	}

	wind_set (wd->handle, WF_NAME, level->title, 0, 0);
	sprintf (wd->info, "   0 Moves    0 Pushes");
	wind_set (wd->handle, WF_INFO, wd->info);
	wind_open (wd->handle, fullx, fully,
			(fullw > targetw ? targetw : fullw),
			(fullh > targeth ? targeth : fullh));
	wd->vert_posn = 0; /* initially, vertical scroll bar at top */
	wd->horz_posn = 0; /* initially, horizontal scroll bar at left */
	/* set dimensions based on cell size */
	wd->cell_h = last_used_scale;
	wd->cell_w = last_used_scale;
	wd->shaded = false;

	/* add to end of list */
	cur = wd_list;
	if (cur != NULL) {
		while (cur->next != NULL) {
			cur = cur->next;
		}
		cur->next = wd;
		wd->next = NULL;
	}

	/* ENABLE MENU */
	menu_ienable (menu_addr, MAIN_MENU_SMALL, true);
	menu_ienable (menu_addr, MAIN_MENU_MEDIUM, true);
	menu_ienable (menu_addr, MAIN_MENU_LARGE, true);
	menu_icheck (menu_addr, MAIN_MENU_SMALL, wd->cell_h == SMALL_SIZE);
	menu_icheck (menu_addr, MAIN_MENU_MEDIUM, wd->cell_h == MEDIUM_SIZE);
	menu_icheck (menu_addr, MAIN_MENU_LARGE, wd->cell_h == LARGE_SIZE);
}

/* Create a window to display given level list.
   This will always be the first window to be shown. */
struct win_data * create_level_display (OBJECT * menu_addr, struct level_data * ld, struct scores * score_table) {
	struct win_data * wd = malloc (sizeof (struct win_data));
	int dum, fullx, fully, fullw, fullh;

	wd->window_type = LEVELS;
	wd->ld = ld;
	create_posns (wd);
	wd->next = NULL;
	wd->shaded = false;

	/* set up window */
	wind_get (0, WF_WORKXYWH, &fullx, &fully, &fullw, &fullh);
	wd->handle = wind_create (PARTS, fullx, fully, fullw, fullh);
	if (wd->handle < 0) { /* error, could not create window */
		free (wd);
		form_alert (3, "[1][Error: could not create window|Try closing another window][OK]");
		return NULL;
	}

	/* Create info line in table view and title */
	sprintf (wd->info, "Levels: %d  Completed: %d", wd->ld->size, scores_number_done(score_table, wd->ld->title));
	wind_set (wd->handle, WF_INFO, wd->info, 0, 0);
	wind_set (wd->handle, WF_NAME, wd->ld->title, 0, 0);

	wind_open (wd->handle, fullx, fully,
			(fullw > 280 ? 280 : fullw),
			(fullh > 350 ? 350 : fullh));
	wd->vert_posn = 0; /* initially, vertical scroll bar at top */
	wd->horz_posn = 0; /* initially, horizontal scroll bar at left */
	/* set dimensions based on character font */
	vst_point (app_handle, 11, &dum, &dum, &wd->cell_w, &wd->cell_h);
	/* DISABLE MENU */
	menu_ienable (menu_addr, MAIN_MENU_SMALL, false);
	menu_ienable (menu_addr, MAIN_MENU_MEDIUM, false);
	menu_ienable (menu_addr, MAIN_MENU_LARGE, false);

	return wd;
}

/* Update the level display window (wd) with new level data */
void update_level_display (OBJECT * menu_addr, struct win_data * wd, struct scores * score_table) {
	close_level_displays (wd);
	create_posns (wd);

	/* Make sure new level set is in score table */
	scores_store_set (score_table, wd->ld->title, wd->ld->size);

	/* Update info line in table view and title */
	sprintf (wd->info, "Levels: %d  Completed: %d", wd->ld->size, scores_number_done(score_table, wd->ld->title));
	wind_set (wd->handle, WF_INFO, wd->info, 0, 0);
	wind_set (wd->handle, WF_NAME, wd->ld->title, 0, 0);

	/* Bring the table view to the top */
	wind_set (wd->handle, WF_TOP, 0, 0);
	/* Redraw the window */
	{
		GRECT rec;
		wind_get (wd->handle, WF_WORKXYWH, &rec.g_x, &rec.g_y, &rec.g_w, &rec.g_h);
		do_redraw (wd, score_table, &rec);
	}
	/* DISABLE MENU */
	menu_ienable (menu_addr, MAIN_MENU_SMALL, false);
	menu_ienable (menu_addr, MAIN_MENU_MEDIUM, false);
	menu_ienable (menu_addr, MAIN_MENU_LARGE, false);
}

/* create the start/end posns fields */
void create_posns (struct win_data * wd) {
	int i;

	/* get rid of old set */
	if (wd->start_posns != NULL) free(wd->start_posns);
	if (wd->end_posns != NULL) free(wd->end_posns);

	wd->start_posns = malloc(sizeof(int)*wd->ld->size);
	wd->end_posns = malloc(sizeof(int)*wd->ld->size);
	for (i = 0; i < wd->ld->size; i += 1) {
		wd->start_posns[i] = -1;
		wd->end_posns[i] = -1;
	}
}

/* Process main event loop, using wd as start of window list */
void event_loop (OBJECT * menu_addr, struct win_data * wd, struct scores * score_table) {
	int msg_buf[8];

	if (wd == NULL) return; /* if there was a problem in creating initial display, exit */

	do {
		int dum, event, key;
		int mouse_x, mouse_y, mouse_state, clicks;

		event = evnt_multi (MU_MESAG|MU_BUTTON|MU_KEYBD, 2,1,1,0,0,0,0,0,0,0,0,0,0,msg_buf,0,0,
			&mouse_x,&mouse_y,&mouse_state,&dum, &key, &clicks);

		/* -- check for and handle keyboard events */
		if (event & MU_KEYBD) {
			if (key == 0x1011) { /* code for ctrl-Q */
			    break; /* quit the do-while loop */
			} else if (key == 25088) { /* HELP */
				show_help_message ();
			} else {
				int top_handle;
				struct win_data * win = wd;

				/* retrieve handle of top window */
				wind_get (0, WF_TOP, &top_handle, 0, 0, 0);
				/* find its win_data */
				while ((win != NULL) && (win->handle != top_handle)) {
					win = win->next;
				}
				/* if valid and window not shaded, check for key actions */
				if (win != NULL && !win->shaded && win->window_type == POSITION) {
					if (key == 0x4800) { /* up arrow */
						make_move (wd, win, score_table, UP);
					} else if (key == 0x4B00) { /* left arrow */
						make_move (wd, win, score_table, LEFT);
					} else if (key == 0x4D00) { /* right arrow */
						make_move (wd, win, score_table, RIGHT);
					} else if (key == 0x5000) { /* down arrow */
						make_move (wd, win, score_table, DOWN);
					} else if (key == 0x1372) { /* r key */
						reset_position (win, score_table);
					} else if (key == 0x1675 || key == 24832) { /* u / UNDO */
						undo_move (win, score_table);
					}
				}
			}
		}

		/* -- check for and handle mouse events */
		if ((event & MU_BUTTON) && (mouse_state & 1) && (clicks == 2)) {

			/* check mouse click in window of level table */
			if (wind_find(mouse_x,mouse_y) == wd->handle) {
				int i;
				int c_x, c_y, c_w, c_h;

				wind_get (wd->handle, WF_WORKXYWH, &c_x, &c_y, &c_w, &c_h);
				mouse_y -= c_y; /* get mouse_y into window coordinates */

				/* find game based on position of click in table */
				for (i = 0; i < wd->ld->size; i += 1) {
					if (wd->start_posns[i] == -1) continue;
					if ((wd->start_posns[i] <= mouse_y) && (wd->end_posns[i] > mouse_y)) {
						create_display(menu_addr, wd, leveldata_nth(wd->ld, i));

					}
				}
			}
		}

		/* -- check for and handle window/menu events */
		if (event & MU_MESAG) {
			switch (msg_buf[0]) {

				case MN_SELECTED: /* menu selection */
        		    do_menu (menu_addr, wd, score_table, msg_buf[4]);
					/* return menu to normal */
        	    	menu_tnormal (menu_addr, msg_buf[3], true);
					break;

				case WM_TOPPED: /* fall through to ontop for updating menu/window */
					wind_set (msg_buf[3], WF_TOP, 0, 0);
#if !defined(ATARIST)
				case WM_ONTOP: /* AES 4.0 message, when window becomes top */
#endif
					update_theme_menu (menu_addr, get_win_data (wd, msg_buf[3]));
					break;

				case WM_MOVED:
					wind_set (msg_buf[3], WF_CURRXYWH, msg_buf[4],
						msg_buf[5], msg_buf[6], msg_buf[7]);
					break;

				case WM_FULLED:
					do_fulled (get_win_data(wd, msg_buf[3]));
					break;

				case WM_SIZED:
					do_sized (get_win_data(wd, msg_buf[3]), score_table, msg_buf);
					break;

				case WM_ARROWED:
					wind_set (msg_buf[3], WF_TOP, 0, 0); /* bring to the top */
					update_theme_menu (menu_addr, get_win_data (wd, msg_buf[3]));
					do_arrow (get_win_data(wd, msg_buf[3]), score_table, msg_buf[4]);
					break;

				case WM_VSLID:
					wind_set (msg_buf[3], WF_TOP, 0, 0);
					update_theme_menu (menu_addr, get_win_data (wd, msg_buf[3]));
					do_vslide (get_win_data(wd, msg_buf[3]), score_table, msg_buf[4]);
					break;

				case WM_HSLID:
					wind_set (msg_buf[3], WF_TOP, 0, 0);
					update_theme_menu (menu_addr, get_win_data (wd, msg_buf[3]));
					do_hslide (get_win_data(wd, msg_buf[3]), score_table, msg_buf[4]);
					break;

				case WM_REDRAW:
					do_redraw (get_win_data(wd, msg_buf[3]), score_table, (GRECT *)&msg_buf[4]);
					break;

				case WM_CLOSED:
					do_close (wd, msg_buf[3]);
					break;

#if !defined(ATARIST)
				case WM_SHADED: /* AES 4.0 message - do not redraw screen */
					(get_win_data(wd, msg_buf[3]))->shaded = true;
					break;

				case WM_UNSHADED: /* AES 4.0 message - return to drawing screen */
					(get_win_data(wd, msg_buf[3]))->shaded = false;
					break;

				case WM_BOTTOMED:
					wind_set (msg_buf[3], WF_BOTTOM, 0, 0, 0, 0);
					break;
#endif
			}
		}

	} while (!(msg_buf[0] == MN_SELECTED && msg_buf[4] == MAIN_MENU_QUIT) &&
#if !defined(ATARIST)
			 !(msg_buf[0] == AP_TERM) &&
#endif
			 !(msg_buf[0] == WM_CLOSED && msg_buf[3] == wd->handle));

	/* Close up any open windows */
	while (wd != NULL) {
		if (wd->window_type == POSITION) {
			position_free (wd->position);
		} else if (wd->window_type == LEVELS) {
			free (wd->start_posns);
			free (wd->end_posns);
		}
		wind_close (wd->handle);
		wind_delete (wd->handle);

		wd = wd->next;
	}
}

/* Try to move character in given direction */
void make_move (struct win_data * top_win, struct win_data * wd, struct scores * score_table, enum direction dirn) {
	if (position_is_complete (wd->position)) return;

	if (position_can_move (wd->position, dirn)) {
		position_make_move (wd->position, dirn);
		wd->num_moves += 1;
		if (wd->position->last_move[4] != -1) {
			wd->num_pushes += 1;
		}

		refresh_display (wd, score_table, MOVE);

		if (position_is_complete (wd->position)) {
			GRECT rec;
			struct win_data * cur = top_win;

			/* completed position, so store the score obtained, if better */
			scores_store (score_table, wd->ld->title, wd->level_title, wd->num_moves, wd->num_pushes);
			/* update the display of levels and statistics windows? */
			while (cur != NULL) {
				if (cur->window_type == LEVELS || cur->window_type == STATISTICS) {
					update_levels_info_line (cur, score_table);
					wind_get (cur->handle, WF_WORKXYWH, &rec.g_x, &rec.g_y, &rec.g_w, &rec.g_h);
					do_redraw (cur, score_table, &rec);
				}
				cur = cur->next;
			}
		}
	}
}

/* Try to undo last move */
void undo_move (struct win_data * wd, struct scores * score_table) {
	if (wd->position->move_list == NULL) return; /* no move to undo */

	position_undo_move (wd->position);
	wd->num_moves -= 1;
	if (wd->position->last_move[4] != -1) {
		wd->num_pushes -= 1;
	}
	refresh_display (wd, score_table, MOVE);
}

/* Reset position to start */
void reset_position (struct win_data * wd, struct scores * score_table) {
	position_free (wd->position);
	wd->position = position_from_defn (wd->definition);
	wd->num_moves = 0;
	wd->num_pushes = 0;

	refresh_display (wd, score_table, UPDATE);
}

/* Closes all the level display windows */
void close_level_displays (struct win_data * wd) {
	struct win_data * curr = wd->next;
	struct win_data * prev = wd;

	while (curr != NULL) {
		if (curr->window_type == POSITION) {
			struct win_data * to_free;

			wind_close (curr->handle);
			wind_delete (curr->handle);

			to_free = curr;
			prev->next = curr->next; /* preserve link of remaining windows */
			curr = curr->next; /* move to next window */
			free (to_free);
		} else {
			prev = curr;
			curr = curr->next;
		}
	}
}


/* Revert to using the classic levels */
void open_classic_levels (OBJECT * menu_addr, struct win_data * wd, struct scores * score_table) {
	leveldata_classic (wd->ld);
	update_level_display (menu_addr, wd, score_table);
}

/* Open a levels file, updating the display and level_data */
void open_levels_file (OBJECT * menu_addr, struct win_data * wd, struct scores * score_table) {
	char * filename;
	char path[1000], name[200];
	int i, button;

	for (i = 0; i < 1000; path[i++] = '\0');
	for (i = 0; i < 200; name[i++] = '\0');
	path[0] = Dgetdrv() + 65;
	strcpy (&path[1], ":\\*.*");
	fsel_exinput (path, name, &button, "Select level text file");

	if (button == 1) {
		filename = malloc(strlen(path)+strlen(name));

		for (i = 0; i < strlen(path)-3; i += 1) {
			filename[i] = path[i];
		}
		for (i = 0; i < strlen(name); i += 1) {
			filename[strlen(path)-3 + i] = name[i];
		}
		filename[strlen(path)-3 + strlen(name)] = '\0';

		/* remove extension from name, for use in level name
                 * also, truncate over long names to 30 characters, to stop
                 * overflow in window titles.
                 */
		for (i = 0; i < strlen(name); i += 1) {
			if (name[i] == '.' || i == 30) {
				name[i] = 0;
				break;
			}
		}

		graf_mouse (BUSYBEE, 0L);
		if (leveldata_load (wd->ld, name, filename, wd->handle) == -1) {
			graf_mouse (ARROW, 0L);
			form_alert(1, "[3][     Open Error|Failed to read levels][OK]");
		} else {
			graf_mouse (ARROW, 0L);
		}

		free (filename);

		update_level_display (menu_addr, wd, score_table);
	}
}

/* If statistics window is already open, bring to top, else create it */
void open_stats_window (OBJECT * menu_addr, struct win_data * wd, struct scores * score_table) {
	struct win_data * prev = NULL;

	while (wd != NULL) {
		if (wd->window_type == STATISTICS) {
			/* found it, so bring to top and escape */
			wind_set (wd->handle, WF_TOP, 0, 0);
			update_theme_menu (menu_addr, wd);

			return;
		}

		prev = wd;
		wd = wd->next;
	}

	/* at end of list, so create a new window */
	if (prev != NULL && prev->next == NULL) {
		struct win_data * new_wd = malloc (sizeof (struct win_data));
		int dum, fullx, fully, fullw, fullh;

		new_wd->window_type = STATISTICS;

		/* set up window */
		wind_get (0, WF_WORKXYWH, &fullx, &fully, &fullw, &fullh);
		new_wd->handle = wind_create (PARTS_NOINFO, fullx, fully, fullw, fullh);
		if (new_wd->handle < 0) { /* error, could not create window */
			free (new_wd);
			form_alert (3, "[1][Error: could not create window|Try closing another window][OK]");
			return;
		}

		wind_set (new_wd->handle, WF_NAME, "Level Stats", 0, 0);
		wind_open (new_wd->handle, fullx, fully,
				(fullw > 300 ? 300 : fullw),
				(fullh > 350 ? 350 : fullh));
		new_wd->vert_posn = 0; /* initially, vertical scroll bar at top */
		new_wd->horz_posn = 0; /* initially, horizontal scroll bar at left */
		/* set dimensions based on character font */
		vst_point (app_handle, 11, &dum, &dum, &new_wd->cell_w, &new_wd->cell_h);
		new_wd->shaded = false;
		/* DISABLE MENU */
		menu_ienable (menu_addr, MAIN_MENU_SMALL, false);
		menu_ienable (menu_addr, MAIN_MENU_MEDIUM, false);
		menu_ienable (menu_addr, MAIN_MENU_LARGE, false);
		/* add to end of list */
		prev->next = new_wd;
		new_wd->next = NULL;
	}
}

/* update info line of levels table */
void update_levels_info_line (struct win_data * wd, struct scores * score_table) {
	if (wd->window_type == LEVELS) {
		sprintf (wd->info, "Levels: %d  Completed: %d", wd->ld->size, scores_number_done(score_table, wd->ld->title));
		wind_set (wd->handle, WF_INFO, wd->info, 0, 0);
	}
}

/* Show a simple help message */
void show_help_message (void) {
	form_alert (1, "[1][Use the cursor keys to move|'u' / 'Undo' to take a move back|'r' to reset the level|Control-Q to exit the game][OK]");
}

/* For the top-most window position, change the theme size */
void set_theme (OBJECT * menu_addr, struct win_data * wd, struct scores * score_table, enum theme t) {
	int top_handle;
	struct win_data * win = wd;
	int new_height, new_width;
	int x, y, w, h;

	/* retrieve handle of top window */
	wind_get (0, WF_TOP, &top_handle, 0, 0, 0);
	/* find its win_data */
	while ((win != NULL) && (win->handle != top_handle)) {
		win = win->next;
	}

	if (win != NULL && win->window_type == POSITION) {
		switch (t) {
			case SMALL_THEME:
				last_used_scale = SMALL_SIZE;
				break;

			case MEDIUM_THEME:
				last_used_scale = MEDIUM_SIZE;
				break;

			case LARGE_THEME:
				last_used_scale = LARGE_SIZE;
				break;
		}
		win->cell_h = last_used_scale;
		win->cell_w = last_used_scale;
		menu_icheck (menu_addr, MAIN_MENU_SMALL, last_used_scale == SMALL_SIZE);
		menu_icheck (menu_addr, MAIN_MENU_MEDIUM, last_used_scale == MEDIUM_SIZE);
		menu_icheck (menu_addr, MAIN_MENU_LARGE, last_used_scale == LARGE_SIZE);

		wind_get (win->handle, WF_WORKXYWH, &x, &y, &w, &h);

		new_height = (h / win->cell_h) + 1; /* find new height in characters */
		new_width = (w / win->cell_w) + 1;  /* find new width in characters */

		/* if new height is bigger than lines_shown - vert_posn,
		   we can decrease vert_posn to show more lines */
		if (new_height > win->lines_shown - win->vert_posn) {
			win->vert_posn -= new_height - (win->lines_shown - win->vert_posn);
			if (win->vert_posn < 0) win->vert_posn = 0;
		}
		/* if new height is less than lines_shown - vert_posn,
		   we leave vertical position in same place,
		   so nothing has to be done  */

		/* similarly, if new width is bigger than colns_shown - horz_posn,
		   we can decrease horz_posn to show more columns */
		if (new_width > win->colns_shown - win->horz_posn) {
			win->horz_posn -= new_width - (win->colns_shown - win->horz_posn);
			if (win->horz_posn < 0) win->horz_posn = 0;
		}

		refresh_display (win, score_table, ALL);
		calc_slid (win);
	}
}

/* Update tick/enabled status of theme menu, depending on current top window */
void update_theme_menu (OBJECT * menu_addr, struct win_data * wd) {
	int top_handle;
	struct win_data * win = wd;

	/* retrieve handle of top window */
	wind_get (0, WF_TOP, &top_handle, 0, 0, 0);
	/* find its win_data */
	while ((win != NULL) && (win->handle != top_handle)) {
		win = win->next;
	}

	if (win->window_type == POSITION) {
		menu_ienable (menu_addr, MAIN_MENU_SMALL, true);
		menu_ienable (menu_addr, MAIN_MENU_MEDIUM, true);
		menu_ienable (menu_addr, MAIN_MENU_LARGE, true);

		switch (win->cell_h) {
			case SMALL_SIZE:
				menu_icheck (menu_addr, MAIN_MENU_SMALL, true);
				menu_icheck (menu_addr, MAIN_MENU_MEDIUM, false);
				menu_icheck (menu_addr, MAIN_MENU_LARGE, false);
				break;

			case MEDIUM_SIZE:
				menu_icheck (menu_addr, MAIN_MENU_SMALL, false);
				menu_icheck (menu_addr, MAIN_MENU_MEDIUM, true);
				menu_icheck (menu_addr, MAIN_MENU_LARGE, false);
				break;

			case LARGE_SIZE:
				menu_icheck (menu_addr, MAIN_MENU_SMALL, false);
				menu_icheck (menu_addr, MAIN_MENU_MEDIUM, false);
				menu_icheck (menu_addr, MAIN_MENU_LARGE, true);
				break;
		}
	} else { /* level display */
		menu_ienable (menu_addr, MAIN_MENU_SMALL, false);
		menu_ienable (menu_addr, MAIN_MENU_MEDIUM, false);
		menu_ienable (menu_addr, MAIN_MENU_LARGE, false);
	}
}

/* show information about the program */
void show_about (void) {
	form_alert(1, "[1][     Sokoban v1.1.2| A GEM version of Sokoban.|Written by Peter Lane, 2016.][OK]");
}

/* Retrieve win_data from list corresponding to given handle, or NULL */
struct win_data * get_win_data (struct win_data * wd, int handle) {
	while (wd != NULL) {
		if (wd->handle == handle) break;
		wd = wd->next;
	}
	return wd;
}

/* sets/unsets clipping rectangle in VDI */
void set_clip (bool flag, GRECT rec) {
	int pxy[4];

	pxy[0] = rec.g_x;
	pxy[1] = rec.g_y;
	pxy[2] = rec.g_x + rec.g_w - 1;
	pxy[3] = rec.g_y + rec.g_h - 1;

	vs_clip (app_handle, flag, pxy);
}

/* calculate slider size out of 1000:
 * uses int-only, so works on ST as well as Firebee.
 * avail_lines: the number of lines that can be shown on screen
 * lines_shown: the total number of lines within the window
 */
int slider_size (int avail_lines, int lines_shown) {
	int res;

	/* in case number of lines shown is smaller than those available */
	if (avail_lines >= lines_shown) { /* all lines visible */
		return 1000; /* so slider complete */
	}

	res = (1000 * (long)avail_lines) / lines_shown;
	if (res > 1000) res = 1000;

	return res;
}

/* calculate slider position out of 1000:
 * uses int-only, so works on ST as well as Firebee.
 * avail_lines: the number of lines that can be shown on screen
 * lines_shown: the total number of lines within the window
 * top: the current top of slider
 */
int slider_posn (int avail_lines, int lines_shown, int top) {
	int res;
	int scrollable_region, tmp1, tmp2;

	/* in case number of lines shown is smaller than those available */
	if (avail_lines >= lines_shown) { /* all lines visible */
		return 0; /* so slider complete, and show bar at top position */
	}
	/* number of lines scrollbar can move across: must be positive due to above check */
	scrollable_region = lines_shown - avail_lines;
	tmp1 = top / scrollable_region;
	tmp2 = top % scrollable_region;

	res = (1000 * (long)tmp1) + ((1000 * (long)tmp2) / scrollable_region);
	if (res > 1000) res = 1000;

	return (int)res;
}

/* Calculate position and size of sliders given the current dimensions of window */
void calc_slid (struct win_data * wd) {
	int lines_avail, cols_avail;
	int wrkx, wrky, wrkw, wrkh;

	wind_get (wd->handle, WF_WORKXYWH, &wrkx, &wrky, &wrkw, &wrkh);
	lines_avail = wrkh / wd->cell_h;
	cols_avail = wrkw / wd->cell_w;

 	/* handle vertical slider */
	wind_set (wd->handle, WF_VSLSIZE, slider_size (lines_avail, wd->lines_shown), 0, 0, 0);
	wind_set (wd->handle, WF_VSLIDE, slider_posn (lines_avail, wd->lines_shown, wd->vert_posn), 0, 0, 0);

	/* handle horizontal slider */
	wind_set (wd->handle, WF_HSLSIZE, slider_size (cols_avail, wd->colns_shown), 0, 0, 0);
	wind_set (wd->handle, WF_HSLIDE, slider_posn (cols_avail, wd->colns_shown, wd->horz_posn), 0, 0, 0);
}

/* calculates if window is currently full */
bool is_window_full (struct win_data * wd) {
	int curx, cury, curw, curh;
	int fullx, fully, fullw, fullh;

	wind_get (wd->handle, WF_CURRXYWH, &curx, &cury, &curw, &curh);
	wind_get (wd->handle, WF_FULLXYWH, &fullx, &fully, &fullw, &fullh);
	if (curx != fullx || cury != fully || curw != fullw || curh != fullh) {
		return false;
	} else {
		return true;
	}
}

/* Called to move vertical slider up by a page */
void do_uppage (struct win_data * wd, struct scores * score_table) {
	GRECT r;
	int lines_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	lines_avail = r.g_h / wd->cell_h;
	wd->vert_posn -= lines_avail;
	if (wd->vert_posn < 0) wd->vert_posn = 0;
	do_redraw (wd, score_table, &r);
}

/* Called to move vertical slider down by a page */
void do_dnpage (struct win_data * wd, struct scores * score_table) {
	GRECT r;
	int lines_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	lines_avail = r.g_h / wd->cell_h;
	wd->vert_posn += lines_avail;
	if (wd->lines_shown > lines_avail && wd->vert_posn > wd->lines_shown - lines_avail) {
		wd->vert_posn = wd->lines_shown - lines_avail;
	} else if (lines_avail >= wd->lines_shown) {
		wd->vert_posn = 0;
	}
	do_redraw (wd, score_table, &r);
}

/* Called to move vertical slider up by a single row */
void do_upline (struct win_data * wd, struct scores * score_table) {
	FDB s, d;
	GRECT r;
	int pxy[8];

	if (wd->vert_posn == 0) return; /* already at top of screen */
	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	wd->vert_posn -= 1;
	if (wd->vert_posn < 0) wd->vert_posn = 0;

	set_clip (true, r);
	graf_mouse (M_OFF, 0L);
	s.fd_addr = 0L;
	d.fd_addr = 0L;
	pxy[0] = r.g_x;
	pxy[1] = r.g_y + 1;
	pxy[2] = r.g_x + r.g_w;
	pxy[3] = r.g_y + r.g_h - wd->cell_h - 1;
	pxy[4] = r.g_x;
	pxy[5] = r.g_y + wd->cell_h + 1;
	pxy[6] = r.g_x + r.g_w;
	pxy[7] = r.g_y + r.g_h - 1;
	vro_cpyfm (app_handle, S_ONLY, pxy, &s, &d);

	graf_mouse (M_ON, 0L);
	set_clip (false, r);
	r.g_h = 2*wd->cell_h; /* draw the height of two rows at top */
	do_redraw (wd, score_table, &r);
}

/* Called to move vertical slider down by a single row */
void do_dnline (struct win_data * wd, struct scores * score_table) {
	FDB s, d;
	GRECT r;
	int pxy[8];
	int lines_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	lines_avail = r.g_h / wd->cell_h;

	if (wd->vert_posn >= (wd->lines_shown - lines_avail)) return; /* at bottom */

	wd->vert_posn += 1;
	if (wd->lines_shown > lines_avail && wd->vert_posn > wd->lines_shown - lines_avail) {
		wd->vert_posn = wd->lines_shown - lines_avail;
	} else if (lines_avail >= wd->lines_shown) {
		/* don't move if all lines are showing */
		wd->vert_posn = 0;
	}

	set_clip (true, r);
	graf_mouse (M_OFF, 0L);
	s.fd_addr = 0L;
	d.fd_addr = 0L;
	pxy[0] = r.g_x;
	pxy[1] = r.g_y + wd->cell_h + 1;
	pxy[2] = r.g_x + r.g_w;
	pxy[3] = r.g_y + r.g_h - 1;
	pxy[4] = r.g_x;
	pxy[5] = r.g_y + 1;
	pxy[6] = r.g_x + r.g_w;
	pxy[7] = r.g_y + r.g_h - wd->cell_h - 1;
	vro_cpyfm (app_handle, S_ONLY, pxy, &s, &d);

	graf_mouse (M_ON, 0L);
	set_clip (false, r);
	r.g_y = r.g_y + r.g_h - 2*wd->cell_h;
	r.g_h = 2*wd->cell_h; /* draw the height of two rows at bottom */
	do_redraw (wd, score_table, &r);
}

/* Called to move horizontal slider left by a page */
void do_lfpage (struct win_data * wd, struct scores * score_table) {
	GRECT r;
	int colns_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	colns_avail = r.g_w / wd->cell_w;
	wd->horz_posn -= colns_avail;
	if (wd->horz_posn < 0) wd->horz_posn = 0;
	do_redraw (wd, score_table, &r);
}

/* Called to move horizontal slider right by a page */
void do_rtpage (struct win_data * wd, struct scores * score_table) {
	GRECT r;
	int colns_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	colns_avail = r.g_w / wd->cell_w;
	wd->horz_posn += colns_avail;
	if (wd->colns_shown > colns_avail && wd->horz_posn > wd->colns_shown - colns_avail) {
		wd->horz_posn = wd->colns_shown - colns_avail;
	} else if (colns_avail >= wd->colns_shown) {
		wd->horz_posn = 0;
	}
	do_redraw (wd, score_table, &r);
}

/* Called to move horizontal slider left by a single column */
void do_lfline (struct win_data * wd, struct scores * score_table) {
	FDB s, d;
	GRECT r;
	int pxy[8];

	if (wd->horz_posn == 0) return; /* already on left */

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	wd->horz_posn -= 1;
	if (wd->horz_posn < 0) wd->horz_posn = 0;

	set_clip (true, r);
	graf_mouse (M_OFF, 0L);
	s.fd_addr = 0L;
	d.fd_addr = 0L;
	pxy[0] = r.g_x;
	pxy[1] = r.g_y + 1;
	pxy[2] = r.g_x + r.g_w - wd->cell_w;
	pxy[3] = r.g_y + r.g_h - 1;
	pxy[4] = r.g_x + wd->cell_w;
	pxy[5] = r.g_y + 1;
	pxy[6] = r.g_x + r.g_w;
	pxy[7] = r.g_y + r.g_h - 1;
	vro_cpyfm (app_handle, S_ONLY, pxy, &s, &d);

	graf_mouse (M_ON, 0L);
	set_clip (false, r);
	r.g_w = 2*wd->cell_w; /* draw the width of two chars at left */

	do_redraw (wd, score_table, &r);
}

/* Called to move horizontal slider right by a single column */
void do_rtline (struct win_data * wd, struct scores * score_table) {
	FDB s, d;
	GRECT r;
	int colns_avail;
	int pxy[8];

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	colns_avail = r.g_w / wd->cell_w;

	if (wd->horz_posn == (wd->colns_shown - colns_avail)) return; /* already on right */

	wd->horz_posn += 1;
	if (wd->colns_shown > colns_avail && wd->horz_posn > wd->colns_shown - colns_avail) {
		wd->horz_posn = wd->colns_shown - colns_avail;
	} else if (colns_avail >= wd->colns_shown) {
		wd->horz_posn = 0;
	}

	set_clip (true, r);
	graf_mouse (M_OFF, 0L);
	s.fd_addr = 0L;
	d.fd_addr = 0L;
	pxy[0] = r.g_x + wd->cell_w;
	pxy[1] = r.g_y + 1;
	pxy[2] = r.g_x + r.g_w;
	pxy[3] = r.g_y + r.g_h - 1;
	pxy[4] = r.g_x;
	pxy[5] = r.g_y + 1;
	pxy[6] = r.g_x + r.g_w - wd->cell_w;
	pxy[7] = r.g_y + r.g_h - 1;
	vro_cpyfm (app_handle, S_ONLY, pxy, &s, &d);

	graf_mouse (M_ON, 0L);
	set_clip (false, r);
	r.g_x = r.g_x + r.g_w - 2*wd->cell_w;
	r.g_w = 2*wd->cell_w; /* draw the width of two chars at right */

	do_redraw (wd, score_table, &r);
}

/* Respond to an arrow event by determining the type of arrow event, and
   calling appropriate function.
 */
void do_arrow (struct win_data * wd, struct scores * score_table, int arrow) {
	switch (arrow) {
		case WA_UPPAGE:
			do_uppage (wd, score_table);
			break;

		case WA_DNPAGE:
			do_dnpage (wd, score_table);
			break;

		case WA_UPLINE:
			do_upline (wd, score_table);
			break;

		case WA_DNLINE:
			do_dnline (wd, score_table);
			break;

		case WA_LFPAGE:
			do_lfpage (wd, score_table);
			break;

		case WA_RTPAGE:
			do_rtpage (wd, score_table);
			break;

		case WA_LFLINE:
			do_lfline (wd, score_table);
			break;

		case WA_RTLINE:
			do_rtline (wd, score_table);
			break;
	}
}

/* Close window, and preserve remaining list of windows */
void do_close (struct win_data * wd, int handle) {
	struct win_data * prev_win = NULL;
	struct win_data * this_win = wd;

	if (handle == wd->handle) return; /* do not close topmost (list) window */

	while ((this_win != NULL) && (this_win->handle != handle)) {
		prev_win = this_win;
		this_win = this_win->next;
	}
	if (this_win != NULL) {
    if (this_win->window_type == POSITION) {
		  position_free (this_win->position);
    }
		wind_close (this_win->handle);
		wind_delete (this_win->handle);

		if (prev_win == NULL) { /* This is first window in wd's list */
			wd->next = this_win->next;
		} else {
			prev_win->next = this_win->next;
		}
		free (this_win); /* reclaim storage for this_win */
	}
}

/* called when the full-box is clicked.
   Window will be made full or return to its previous size, depending
   on current state.
 */
void do_fulled (struct win_data * wd) {
	if (is_window_full (wd)) { /* shrink to previous size */
		int oldx, oldy, oldw, oldh;
		int fullx, fully, fullw, fullh;

		wind_get (wd->handle, WF_PREVXYWH, &oldx, &oldy, &oldw, &oldh);
		wind_get (wd->handle, WF_FULLXYWH, &fullx, &fully, &fullw, &fullh);
		graf_shrinkbox (oldx, oldy, oldw, oldh, fullx, fully, fullw, fullh);
		wind_set (wd->handle, WF_CURRXYWH, oldx, oldy, oldw, oldh);

	} else { /* make full size */
		int curx, cury, curw, curh;
		int fullx, fully, fullw, fullh;

		wind_get (wd->handle, WF_CURRXYWH, &curx, &cury, &curw, &curh);
		wind_get (wd->handle, WF_FULLXYWH, &fullx, &fully, &fullw, &fullh);
		graf_growbox (curx, cury, curw, curh, fullx, fully, fullw, fullh);
		wind_set (wd->handle, WF_CURRXYWH, fullx, fully, fullw, fullh);
	}
}

/* handle menu events */
void do_menu (OBJECT * menu_addr, struct win_data * wd, struct scores * score_table, int menu) {
	switch (menu) { /* check which menu was selected */
		case MAIN_MENU_ABOUT:
			show_about ();
			break;

		case MAIN_MENU_CLASSIC:
			open_classic_levels (menu_addr, wd, score_table);
			break;

		case MAIN_MENU_OPEN:
			open_levels_file (menu_addr, wd, score_table);
			break;

		case MAIN_MENU_STATS:
			open_stats_window (menu_addr, wd, score_table);
			break;

		case MAIN_MENU_SMALL:
			set_theme (menu_addr, wd, score_table, SMALL_THEME);
			break;

		case MAIN_MENU_MEDIUM:
			set_theme (menu_addr, wd, score_table, MEDIUM_THEME);
			break;

		case MAIN_MENU_LARGE:
			set_theme (menu_addr, wd, score_table, LARGE_THEME);
			break;

		case MAIN_MENU_HELP:
			show_help_message ();
			break;
	}
}

/* Called when application asked to redraw parts of its display.
   Walks the rectangle list, redrawing the relevant part of the window.
 */
void do_redraw (struct win_data * wd, struct scores * score_table, GRECT * rec1) {
	GRECT rec2;

	wind_update (BEG_UPDATE);

	wind_get (wd->handle, WF_FIRSTXYWH, &rec2.g_x, &rec2.g_y, &rec2.g_w, &rec2.g_h);
	while (rec2.g_w && rec2.g_h) {
		if (rc_intersect (rec1, &rec2)) {
			draw_interior (wd, score_table, rec2, ALL);
		}
		wind_get (wd->handle, WF_NEXTXYWH, &rec2.g_x, &rec2.g_y, &rec2.g_w, &rec2.g_h);
	}

	wind_update (END_UPDATE);
}

/* called when the window is resized.  It resizes the current window
   to the new dimensions, but stops the new dimensions going beyond
   the minimum allowed height and width.
   */
void do_sized (struct win_data * wd, struct scores * score_table, int * msg_buf) {
	int new_height;
	int new_width;
	bool changed = false; /* flag indicates if horz or vert position changed */

	if (msg_buf[6] < MIN_WIDTH) msg_buf[6] = MIN_WIDTH;
	if (msg_buf[7] < MIN_HEIGHT) msg_buf[7] = MIN_HEIGHT;

	new_height = (msg_buf[7] / wd->cell_h) + 1; /* find new height in characters */
	new_width = (msg_buf[6] / wd->cell_w) + 1;  /* find new width in characters */

	/* if new height is bigger than lines_shown - vert_posn,
	   we can decrease vert_posn to show more lines */
	if (new_height > wd->lines_shown - wd->vert_posn) {
		wd->vert_posn -= new_height - (wd->lines_shown - wd->vert_posn);
		if (wd->vert_posn < 0) wd->vert_posn = 0;
		changed = true;
	}
	/* if new height is less than lines_shown - vert_posn,
	   we leave vertical position in same place,
	   so nothing has to be done  */

	/* similarly, if new width is bigger than colns_shown - horz_posn,
	   we can decrease horz_posn to show more columns */
	if (new_width > wd->colns_shown - wd->horz_posn) {
		wd->horz_posn -= new_width - (wd->colns_shown - wd->horz_posn);
		if (wd->horz_posn < 0) wd->horz_posn = 0;
		changed = true;
	}

	wind_set (wd->handle, WF_CURRXYWH, msg_buf[4], msg_buf[5], msg_buf[6], msg_buf[7]);

	if (changed) { /* as contents changed, redraw whole window */
		GRECT rec;

		wind_get (wd->handle, WF_WORKXYWH, &rec.g_x, &rec.g_y, &rec.g_w, &rec.g_h);
		do_redraw (wd, score_table, &rec);
	}
}

/* Called when vertical slider moved. */
void do_vslide (struct win_data * wd, struct scores * score_table, int posn) {
	GRECT r;
	int lines_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	lines_avail = r.g_h / wd->cell_h;
	wd->vert_posn = posn * (wd->lines_shown - lines_avail) / 1000;
	if (wd->vert_posn < 0) wd->vert_posn = 0;
	wind_set (wd->handle, WF_VSLIDE, posn, 0, 0, 0);
	do_redraw (wd, score_table, &r);
}

/* Called when horizontal slider moved. */
void do_hslide (struct win_data * wd, struct scores * score_table, int posn) {
	GRECT r;
	int colns_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	colns_avail = r.g_w / wd->cell_w;
	wd->horz_posn = posn * (wd->colns_shown - colns_avail) / 1000;
	if (wd->horz_posn < 0) wd->horz_posn = 0;
	wind_set (wd->handle, WF_HSLIDE, posn, 0, 0, 0);
	do_redraw (wd, score_table, &r);
}

/* Used to refresh display after something changed: only called when
   wd is the top window
 */
void refresh_display (struct win_data * wd, struct scores * score_table, int type) {
	GRECT rec;

	if (wd->window_type == POSITION) { /* update info line of position */
		sprintf (wd->info, "%4d Move%s %4d Push%s  %s",
					wd->num_moves, (wd->num_moves == 1 ? " ": "s"),
					wd->num_pushes, (wd->num_pushes == 1 ? "  ": "es"),
					(position_is_complete (wd->position) ? "COMPLETE" : ""));
		wind_set (wd->handle, WF_INFO, wd->info, 0, 0);
	}
	update_levels_info_line (wd, score_table);

	/* redraw contents of all windows */
	wind_get (wd->handle, WF_WORKXYWH, &rec.g_x, &rec.g_y, &rec.g_w, &rec.g_h);
	draw_interior (wd, score_table, rec, type);
}

/* Draw interior of window, within given clipping rectangle */
void draw_interior (struct win_data * wd, struct scores * score_table, GRECT clip, int type) {
	int pxy[4];
	int wrkx, wrky, wrkw, wrkh; /* some variables describing current working area */

	if (wd->shaded) return; /* no screen updates if shaded */

	graf_mouse (M_OFF, 0L);
	set_clip (true, clip);
	wind_get (wd->handle, WF_WORKXYWH, &wrkx, &wrky, &wrkw, &wrkh);

	/* clears the display */
	if (type == ALL) {
		vsf_interior (app_handle, SOLID);
		if (num_colours >= 16 && wd->window_type == POSITION) {
			vsf_color (app_handle, GREEN);
		} else {
			vsf_color (app_handle, WHITE);
		}
		pxy[0] = wrkx;
		pxy[1] = wrky;
		pxy[2] = wrkx + wrkw - 1;
		pxy[3] = wrky + wrkh - 1;
		vr_recfl (app_handle, pxy);
	}

	switch (wd->window_type) {
		case POSITION:
			/* call out to draw current position on screen */
			position_draw (app_handle, wd->position, wrkx, wrky, wrkw, wrkh, wd->horz_posn, wd->vert_posn, type, wd->cell_h, wd->cell_w, num_colours);

			wd->lines_shown = wd->position->height + 2;
			wd->colns_shown = wd->position->width + 2;
			break;

		case LEVELS:
			levels_draw (app_handle, wd, score_table, wrkx, wrky, wrkw, wrkh);
			break;

		case STATISTICS:
			stats_draw (app_handle, wd, score_table, wrkx, wrky, wrkw, wrkh);
			break;
	}

	set_clip (false, clip);
	calc_slid (wd);
	graf_mouse (M_ON, 0L);
}
