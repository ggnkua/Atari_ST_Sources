/* Manages GUI and events */

#include "bibgui.h"

/* GEM arrays */
int work_in[11],
	work_out[57],
	contrl[12],
	intin[128],
	ptsin[128],
	intout[128],
	ptsout[128];

/* Some global variables, defining application level information */
int char_w, char_h, box_w, box_h; /* dimensions of characters in display */

/* title and parts for window */
char * title = "BibFind";
#define PARTS NAME|CLOSER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|MOVER|FULLER|INFO
#define MIN_WIDTH 64
#define MIN_HEIGHT 64

#define MAX_W 60 /* maximum width of display, in characters */

char * last_search_string = "";

/* Message definitions, not in AHCC's INCLUDE/AES.H */
#define SH_WDRAW 72		/* MultiTOS    */
#define SC_CHANGED 80	/* MultiTOS    */
#define APP_FIRST 0
#define APP_NEXT 1
#define APP_DESK 2

/* ------------------------------------------------------------------ */
void do_work (void);
void get_clipboard_file (char * scrap_path);
void update_clipboard_observers (char * path);
char * get_tedinfo_str (OBJECT * tree, int object);
bool full_wind (struct win_data * wd);
void set_clip (int flag, GRECT rec);

void do_menu (struct win_data * wd, struct rec_data * rd, int event);
void show_about (void);
void do_find_terms (struct win_data * wd, struct rec_data * rd);
void do_next_record (struct win_data * wd, struct rec_data * rd);
void do_previous_record (struct win_data * wd, struct rec_data * rd);
void do_copy_record_id (struct rec_data * rd);
void do_copy_record_cite (struct rec_data * rd);
void do_copy_record_harvard (struct rec_data * rd);
void do_copy_record_ieee (struct rec_data * rd);
void do_mark_record (struct win_data * wd, struct rec_data * rd);
void do_clear_marks (struct win_data * wd, struct rec_data * rd);
void update_info_line (struct win_data * wd, struct rec_data * rd);
void do_mark_record (struct win_data * wd, struct rec_data * rd);
void save_marked_records (struct rec_data * rd, char type);
void do_statistics_by_type (struct win_data * wd, struct rec_data * rd);
void do_statistics_by_year (struct win_data * wd, struct rec_data * rd);

void do_arrow (struct win_data * wd, struct rec_data * rd, int event);
void do_uppage (struct win_data * wd, struct rec_data * rd);
void do_dnpage (struct win_data * wd, struct rec_data * rd);
void do_upline (struct win_data * wd, struct rec_data * rd);
void do_dnline (struct win_data * wd, struct rec_data * rd);
void do_lfpage (struct win_data * wd, struct rec_data * rd);
void do_rtpage (struct win_data * wd, struct rec_data * rd);
void do_lfline (struct win_data * wd, struct rec_data * rd);
void do_rtline (struct win_data * wd, struct rec_data * rd);
void do_vslide (struct win_data * wd, struct rec_data * rd, int posn);
void do_hslide (struct win_data * wd, struct rec_data * rd, int posn);
void do_fulled (struct win_data * wd, struct rec_data * rd);
void do_sized (struct win_data * wd, GRECT * rec);
void do_close (struct win_data * wd, int handle);
void draw_interior (struct win_data * wd, GRECT clip, struct rec_data * rd);
void do_redraw (struct win_data * wd, GRECT * rec1, struct rec_data * rd);
void calc_slid (struct win_data * wd);


/* ------------------------------------------------------------------ */

/* Function for responding to all events for program */
void do_window (struct rec_data * rd, OBJECT * menu_addr, OBJECT * dial_addr) {
	struct win_data wd; /* the window specific data */
	int msg_buf[8]; /* information on events */

	/* return mouse to arrow */
	graf_mouse (ARROW, 0L);

	/* set up window and its data */
	wd.is_chart = false;
	wd.chart = NULL;
	wd.next = NULL;

	wind_get (0, WF_WORKXYWH, &wd.fullx, &wd.fully, &wd.fullw, &wd.fullh);
	wd.handle = wind_create (PARTS, wd.fullx, wd.fully, wd.fullw, wd.fullh);
	wind_set (wd.handle, WF_NAME, title, 0, 0);
	wind_open (wd.handle, wd.fullx, wd.fully, 300, 200);
	wd.vert_posn = 0; /* initially, vertical scroll bar at top */
	wd.horz_posn = 0; /* initially, horizontal scroll bar at left */
	wd.dial_addr = dial_addr; /* dialog reference */

	update_info_line (&wd, rd);

	/* receive event messages until close clicked */
	do {
		int dum, event, key;

		event = evnt_multi (MU_MESAG|MU_KEYBD, 0,0,0,0,0,0,0,0,0,0,0,0,0,msg_buf,0,0,
			&dum,&dum,&dum,&dum, &key, &dum);

		/* -- check for and handle keyboard events */
		if (event & MU_KEYBD) {
			if ((char)key == 'n' || key == 12622 || key == 19712) { /* right arrow */
				do_next_record (&wd, rd);
			} else if ((char)key == 'p' || key == 6480 || key == 19200) { /* left arrow */
				do_previous_record (&wd, rd);
			} else if (key == 0x1011) { /* code for ctrl-Q */
			    break; /* quit the do-while loop */
			} else if (key == 8454) { /* code for ctrl-F */
				do_find_terms (&wd, rd);
			} else if (key == 11779) { /* code for ctrl-C */
				do_copy_record_id (rd);
			} else if (key == 4882) { /* code for ctrl-R */
				do_copy_record_cite (rd);
			} else if (key == 8968) { /* code for ctrl-H */
				do_copy_record_harvard (rd);
			} else if (key == 5897) { /* code for ctrl-I */
				do_copy_record_ieee (rd);
			} else if (key == 0x326D) { /* m to toggle mark on record */
				do_mark_record (&wd, rd);
			} else if (key == 0x250B) { /* code for ctrl-K */
				do_clear_marks (&wd, rd);
			}
		}

		/* -- check for and handle window/menu events */
		if (event & MU_MESAG) {
			switch (msg_buf[0]) {

				case MN_SELECTED: /* menu selection */
        		    do_menu (&wd, rd, msg_buf[4]);
					/* return menu to normal */
        	    	menu_tnormal ( menu_addr, msg_buf[3], TRUE );
					break;

				case WM_TOPPED:
					wind_set (msg_buf[3], WF_TOP, 0, 0);
					break;

				case WM_MOVED:
					wind_set (msg_buf[3], WF_CURRXYWH, msg_buf[4],
						msg_buf[5], msg_buf[6], msg_buf[7]);
					break;

				case WM_FULLED: /* only the main window has a full button */
					do_fulled (&wd, rd);
					break;

				case WM_SIZED:
					{
						struct win_data * cur = &wd;

						do {
							if (cur->handle == msg_buf[3]) {
								do_sized (cur, (GRECT *)&msg_buf[4]);
								break;
							}
							cur = cur->next;
						} while (cur != NULL);
					}
					break;

				case WM_ARROWED:
					do_arrow (&wd, rd, msg_buf[4]);
					break;

				case WM_VSLID:
					do_vslide (&wd, rd, msg_buf[4]);
					break;

				case WM_HSLID:
					do_hslide (&wd, rd, msg_buf[4]);
					break;

				case WM_REDRAW:
					{
						struct win_data * cur = &wd;

						do {
							if (cur->handle == msg_buf[3]) {
								do_redraw (cur, (GRECT *)&msg_buf[4], rd);
								break;
							}
							cur = cur->next;
						} while (cur != NULL);
					}
					break;

				case WM_CLOSED:
					do_close (&wd, msg_buf[3]);
					break;

			}
		}
	} while (!(msg_buf[0] == WM_CLOSED  && wd.handle == msg_buf[3]) &&
			 !(msg_buf[0] == MN_SELECTED && msg_buf[4] == MAIN_MENU_QUIT));

	{ /* close all the windows */
		struct win_data * cur = &wd;

		do {
			wind_close (cur->handle);
			wind_delete (cur->handle);
			cur = cur->next;
		} while (cur != NULL);
	}
}

/* Find path and file for clipboard folder, and place in given
   scrap_path.  Also, delete all files in that folder.
   If clipboard does not exist, create one in the current drive.
 */
void get_clipboard_file (char * scrap_path) {
	char * env_scrap_path = NULL;
	char dirname[PATH_MAX];
	struct ffblk cur_file;

	/* check possible environment variables */
	shel_envrn (&env_scrap_path, "CLIPBOARD=");
	if (env_scrap_path == NULL) {
		shel_envrn (&env_scrap_path, "CLIPBRD=");
	}
	if (env_scrap_path == NULL) {
		shel_envrn (&env_scrap_path, "SCRAPDIR=");
	}

	if (env_scrap_path == NULL) {
		/* if not found, use the scrap_path result */
		scrp_read (scrap_path);
	} else {
		/* copy env_scrap_path into scrap_path */
		strcpy (scrap_path, env_scrap_path);
	}

	/* check we have a valid path, adding \ to end if needed */
	if (scrap_path[strlen(scrap_path)-1] != '\\') {
		if (strlen(scrap_path) < PATH_MAX - 2) {
			int end = strlen(scrap_path)-1;
			scrap_path[end] = '\\';
			scrap_path[end+1] = 0;
		}
	}

	/* set up clipboard folder if one does not exist */
	if (strlen (scrap_path) == 0) {
		int curr_drive = Dgetdrv ();
		/* cannot modify an in-place string, so copy it:
		   this caused a strange error, where menu would not
		   reappear when re-focussing the application.
		 */
		char * folder = strdup("A:\\CLIPBRD\\");

		folder[0] += curr_drive; /* set to current drive */
		Dcreate (folder);        /* make sure it exists */
		scrp_write (folder);     /* write the clipboard folder */
		scrp_read (scrap_path);  /* read it back in */
		free (folder);
	}

	/* delete any SCRAP.* files currently in the scrap directory */
	strcpy (dirname, scrap_path);
	strcat (dirname, "SCRAP.*");
	if (findfirst (dirname, &cur_file, 664) == 0) {
		do {
			char * filename = malloc (sizeof(char) * PATH_MAX);
			if (strcmp (cur_file.ff_name, ".") == 0) continue;
			if (strcmp (cur_file.ff_name, "..") == 0) continue;
			strcpy (filename, scrap_path);
			strcat (filename, cur_file.ff_name);
			remove (filename);
		} while (findnext (&cur_file) == 0);
	}
	/* Write data as plain text */
	strcat (scrap_path, "SCRAP.TXT");
}

/* notify applications and desktop that clipboard has changed */
void update_clipboard_observers (char * path) {
	short msg[8] = {0, 0, 0, 0, 0, 0, 0, 0};
	char name[PATH_MAX];
	int id, type;

	if (strlen(path) < 3) return; /* if too short to be a path */

	/* update desktop */
	msg[0] = SH_WDRAW;
	msg[1] = app_handle;
	msg[3] = toupper(path[0]) - 'A';
	if (appl_search (APP_DESK, name, &type, &id) == 1) {
		appl_write (id, 0, msg);
	}

	/* inform other applications */
	msg[0] = SC_CHANGED;
	msg[3] = 0x0002; /* updated a text file */
	if (appl_search (APP_FIRST, name, &type, &id) == 1) {
		do {
			appl_write (id, 0, msg);
		} while (appl_search (APP_NEXT, name, &type, &id) == 1);
	}
}

/* returns a pointer to an editable string in a dialog box */
char * get_tedinfo_str (OBJECT * tree, int object) {
	return tree[object].ob_spec.tedinfo->te_ptext;
}

/* standard code to set up gem arrays and open work area */
void open_vwork (void) {
	int i;

	app_handle = graf_handle (&char_w, &char_h, &box_w, &box_h);
	for (i = 0; i < 10; work_in[i++] = 1);
	work_in[10] = 2;
	v_opnvwk (work_in, &app_handle, work_out);
}

/* calculates if window is currently at maximum size */
bool full_wind (struct win_data * wd) {
	int c_x, c_y, c_w, c_h, f_x, f_y, f_w, f_h;

	wind_get (wd->handle, WF_CURRXYWH, &c_x, &c_y, &c_w, &c_h);
	wind_get (wd->handle, WF_FULLXYWH, &f_x, &f_y, &f_w, &f_h);
	if (c_x != f_x || c_y != f_y || c_w != f_w || c_h != f_h) {
		return true;
	} else {
		return false;
	}
}

/* sets/unsets clipping rectangle in VDI */
void set_clip (int flag, GRECT rec) {
	int pxy[4];

	pxy[0] = rec.g_x;
	pxy[1] = rec.g_y;
	pxy[2] = rec.g_x + rec.g_w - 1;
	pxy[3] = rec.g_y + rec.g_h - 1;

	vs_clip (app_handle, flag, pxy);
}

/* handle menu events */
void do_menu (struct win_data * wd, struct rec_data * rd, int event) {
	switch (event) { /* check which menu was selected */
		case MAIN_MENU_ABOUT:
			show_about ();
			break;

		case MAIN_MENU_SAVE_HARVARD:
			save_marked_records (rd, 'h');
			break;

		case MAIN_MENU_SAVE_IEEE:
			save_marked_records (rd, 'i');
			break;

		case MAIN_MENU_FIND:
			do_find_terms (wd, rd);
			break;

		case MAIN_MENU_NEXT:
			do_next_record (wd, rd);
			break;

		case MAIN_MENU_PREV:
			do_previous_record (wd, rd);
			break;

		case MAIN_MENU_COPY_ID:
			do_copy_record_id (rd);
			break;

		case MAIN_MENU_COPY_CITE:
			do_copy_record_cite (rd);
			break;

		case MAIN_MENU_COPY_HARVARD:
			do_copy_record_harvard (rd);
			break;

		case MAIN_MENU_COPY_IEEE:
			do_copy_record_ieee (rd);
			break;

		case MAIN_MENU_MARK:
			do_mark_record (wd, rd);
			break;

		case MAIN_MENU_CLEAR_MARKS:
			do_clear_marks (wd, rd);
			break;

		case MAIN_MENU_STATS_TYPE:
			do_statistics_by_type (wd, rd);
			break;

		case MAIN_MENU_STATS_YEAR:
			do_statistics_by_year (wd, rd);
			break;
	}
}

/* show information about the program */
void show_about (void) {
	form_alert(1, "[1][      BibFind v1.1.1|For searching BibTeX files.|Written by Peter Lane, 2015-16.][OK]");
}

/* show dialog to enter search terms, then update found records
   unless Cancel pressed
 */
void do_find_terms (struct win_data * wd, struct rec_data * rd) {
	GRECT rec;
	char * search_terms;
	int dial_x, dial_y, dial_w, dial_h, choice;

	/* first blank out the search terms */
	search_terms = get_tedinfo_str (wd->dial_addr, FIND_DIALOG_TEXT);
	strcpy (search_terms, "");

	/* display dialog */
	form_center (wd->dial_addr, &dial_x, &dial_y, &dial_w, &dial_h);
	form_dial(FMD_START, 0, 0, 10, 10, dial_x, dial_y, dial_w, dial_h);
	objc_draw(wd->dial_addr, 0, 8, dial_x, dial_y, dial_w, dial_h);

	choice = form_do (wd->dial_addr, FIND_DIALOG_TEXT);

	if (choice == FIND_DIALOG_FIND) {
		search_terms = get_tedinfo_str (wd->dial_addr, FIND_DIALOG_TEXT);
	}

	form_dial(FMD_FINISH, 0, 0, 10, 10, dial_x, dial_y, dial_w, dial_h);

	if (choice == FIND_DIALOG_FIND) {
		free (last_search_string);
		last_search_string = strdup (search_terms);
		/* do search and reset displayed records */
		recdata_find (rd, search_terms);

		update_info_line (wd, rd);
		wind_get (wd->handle, WF_WORKXYWH, &rec.g_x, &rec.g_y, &rec.g_w, &rec.g_h);
		draw_interior (wd, rec, rd);
	}
}

/* advance record to next one, and redraw */
void do_next_record (struct win_data * wd, struct rec_data * rd) {
	if (recdata_next (rd)) {
		GRECT rec;

		update_info_line (wd, rd);

		wind_get (wd->handle, WF_WORKXYWH, &rec.g_x, &rec.g_y, &rec.g_w, &rec.g_h);
		draw_interior (wd, rec, rd);
	}
}

/* move record to previous one, and redraw */
void do_previous_record (struct win_data * wd, struct rec_data * rd) {
	if (recdata_previous (rd)) {
		GRECT rec;

		update_info_line (wd, rd);
		wind_get (wd->handle, WF_WORKXYWH, &rec.g_x, &rec.g_y, &rec.g_w, &rec.g_h);
		draw_interior (wd, rec, rd);
	}
}

/* Copy given string to clipboard */
void do_copy_string (char * str) {
	FILE * fp;
	char scrap_path [PATH_MAX];

	get_clipboard_file (scrap_path);

	if ((fp = fopen (scrap_path, "w")) != NULL) {
		fprintf (fp, "%s", str);
		fclose (fp);
	}
	free (str);
	update_clipboard_observers (scrap_path);
}

/* Copy record id to clipboard */
void do_copy_record_id (struct rec_data * rd) {
	if (rd == NULL || rd->current == NULL) return; /* do nothing if no record */

	do_copy_string (strdup(rd->current->rd->id));
}

/* Copy record citation, in (author, year) style, to clipboard */
void do_copy_record_cite (struct rec_data * rd) {
	if (rd == NULL || rd->current == NULL) return; /* do nothing if no record */

	do_copy_string (record_citation(rd->current));
}

/* Copy record reference in Harvard style to clipboard */
void do_copy_record_harvard (struct rec_data * rd) {
	if (rd == NULL || rd->current == NULL) return; /* do nothing if no record */

	do_copy_string (record_harvard(rd->current));
}

/* Copy record reference in IEEE style to clipboard */
void do_copy_record_ieee (struct rec_data * rd) {
	if (rd == NULL || rd->current == NULL) return; /* do nothing if no record */

	do_copy_string (record_ieee(rd->current));
}

/* toggles the mark on a record */
void do_mark_record (struct win_data * wd, struct rec_data * rd) {

	if (rd->current != NULL) {
		rd->current->rd->marked = !rd->current->rd->marked;
		update_info_line (wd, rd);
	}
}

/* save marked records to file
   type is 'h' for Harvard style
           'i' for IEEE style
 */
void save_marked_records (struct rec_data * rd, char type) {
	int n = recdata_num_marked (rd);
	struct record ** marked_recs;
	FILE * fp;
	char path[50], name[13], filepath[70];
	int button, i;

	if (n == 0) {
		form_alert (1, "[1][There are no marked records.|Nothing to save][OK]");
		return;
	}
	/* Get an array of the marked records */
	marked_recs = malloc(sizeof(struct record *) * n);
	recdata_get_marked_records (rd, marked_recs);

	/* Request filename to save to */

	for (i = 0; i < 50; path[i++] = '\0');
	for (i = 0; i < 13; name[i++] = '\0');
	path[0] = Dgetdrv() + 65;
	strcpy (&path[1], ":\\*.*");
	fsel_exinput (path, name, &button, "Save references as ...");

	if (button == 1) {
		for (i = 0; i < strlen(path)-3; i += 1) {
			filepath[i] = path[i];
		}
		for (i = 0; i < strlen(name); i += 1) {
			filepath[strlen(path)-3 + i] = name[i];
		}
		filepath[strlen(path)-3 + strlen(name)] = '\0';

		if ((fp = fopen (filepath, "w")) != NULL) {
			for (i = 0; i < n; i += 1) {
				switch (type) {
					case 'h':
						fprintf (fp, record_harvard (marked_recs[i]));
						break;

					case 'i':
						fprintf (fp, record_ieee (marked_recs[i]));
						break;

					default: /* unknown type */
						break;
				}
				fprintf (fp, "\n");
			}
			fclose (fp);
		}
	}

	free (marked_recs);
}

void do_clear_marks (struct win_data * wd, struct rec_data * rd) {
	int button = form_alert (1, "[2][Clear all marks?][Yes|No]");

	if (button == 1) {
		recdata_clear_marks (rd);
		update_info_line (wd, rd);
	}
}

/* Create a new window containing given bar chart, and add to wd list */
void open_statistics_window (struct win_data * wd, struct bar_chart * bc, char * type) {
	int x,y,w,h;
	GRECT rec;
	struct win_data * new_wd = malloc (sizeof (struct win_data));
	struct win_data * cur;
	char title[40];

	wind_get (0, WF_WORKXYWH, &x, &y, &w, &h);
	new_wd->chart = bc;
	new_wd->is_chart = true;
	new_wd->next = NULL;

	new_wd->handle = wind_create (NAME|MOVER|CLOSER|SIZER, x, y, w, h);
	sprintf (title, "BibFind: Statistics by %s", type);
	wind_set (new_wd->handle, WF_NAME, title, 0, 0);
	wind_open (new_wd->handle, x, y+50, 300, 200);

	/* attach new window to wd list */
	cur = wd;
	do {
		if (cur->next == NULL) {
			cur->next = new_wd;
			break;
		}
		cur = cur->next;
	} while (cur != NULL);

	/* draw the initial window contents */
	wind_get (new_wd->handle, WF_WORKXYWH, &rec.g_x, &rec.g_y, &rec.g_w, &rec.g_h);
	draw_interior (new_wd, rec, NULL); /* for charts, recdata ignored */
}

/* Sort lists of labels/values in order of labels */
void sort_by_labels (int n, int values [], char * labels []) {
	int i, j;
	int tmp;
	char * tmp_str;

	for (i = 0; i < n; i += 1) {
		for (j = i+1; j < n; j += 1) {
			if (strcmp (labels[i], labels[j]) > 0) {
				tmp = values[i];
				values[i] = values[j];
				values[j] = tmp;

				tmp_str = labels[i];
				labels[i] = labels[j];
				labels[j] = tmp_str;
			}
		}
	}
}

/* Both statistics do the same, but with different name and data */
void do_statistics (struct win_data * wd, struct rec_data * rd, struct strcount * sc, char * type) {
	int num_values = strcount_size (sc);
	int * values = malloc (sizeof(int) * num_values);
	char ** labels = malloc (sizeof(char *) * num_values);
	int i;
	struct strcount * cur = sc;
	char chart_title [40];
	struct bar_chart * chart;

	/* copy values from strcount into arrays */
	for (i = 0; i < num_values && cur != NULL; i += 1) {
		values[i] = cur->count;
		labels[i] = cur->str;
		cur = cur->next;
	}

	free (sc);

	sort_by_labels (num_values, values, labels);

	/* construct title of chart */
	if (strlen (last_search_string) > 0) {
		strcpy (chart_title, "for \"");
		strncpy (chart_title+strlen(chart_title), last_search_string, 38-strlen(chart_title));
		strcpy (chart_title+strlen(chart_title), "\"");
	} else {
		strcpy (chart_title, "for all");
	}

	/* Create the bar chart */
	chart = chart_make_bar (chart_title, type, "Frequency", num_values, values);

	for (i = 0; i < num_values; i += 1) {
		chart_set_bar_x_label (chart, i, labels[i]);
	}

	open_statistics_window (wd, chart, type);
}

/* Show a window with bar chart by type */
void do_statistics_by_type (struct win_data * wd, struct rec_data * rd) {
	do_statistics (wd, rd, recdata_statistics_by_type (rd), "type");
}

/* Show a window with bar chart by year */
void do_statistics_by_year (struct win_data * wd, struct rec_data * rd) {
	do_statistics (wd, rd, recdata_statistics_by_year (rd), "year");
}

void update_info_line (struct win_data * wd, struct rec_data * rd) {
	char str[20];

	if (rd->current == NULL) {
		sprintf (str, "No Records Found");
	} else {
		sprintf (str, "Record: %d/%d   %s", rd->index, rd->total,
			(rd->current->rd->marked ? "***" : ""));
	}
	wind_set (wd->handle, WF_INFO, str, 0, 0);
}

/* Respond to an arrow event by determining the type of arrow event, and
   calling appropriate function.
 */
void do_arrow (struct win_data * wd, struct rec_data * rd, int event) {
	switch (event) {
		case WA_UPPAGE:
			do_uppage (wd, rd);
			break;

		case WA_DNPAGE:
			do_dnpage (wd, rd);
			break;

		case WA_UPLINE:
			do_upline (wd, rd);
			break;

		case WA_DNLINE:
			do_dnline (wd, rd);
			break;

		case WA_LFPAGE:
			do_lfpage (wd, rd);
			break;

		case WA_RTPAGE:
			do_rtpage (wd, rd);
			break;

		case WA_LFLINE:
			do_lfline (wd, rd);
			break;

		case WA_RTLINE:
			do_rtline (wd, rd);
			break;
	}
}

/* Called to move horizontal slider up by a page */
void do_uppage (struct win_data * wd, struct rec_data * rd) {
	GRECT r;
	int lines_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	lines_avail = r.g_h / char_h;
	wd->vert_posn -= lines_avail;
	if (wd->vert_posn < 0) wd->vert_posn = 0;
	draw_interior (wd, r, rd);
}

/* Called to move horizontal slider down by a page */
void do_dnpage (struct win_data * wd, struct rec_data * rd) {
	GRECT r;
	int lines_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	lines_avail = r.g_h / char_h;
	wd->vert_posn += lines_avail;
	if (wd->lines_shown > lines_avail && wd->vert_posn > wd->lines_shown - lines_avail) {
		wd->vert_posn = wd->lines_shown - lines_avail;
	} else if (lines_avail >= wd->lines_shown) {
		wd->vert_posn = 0;
	}
	draw_interior (wd, r, rd);
}

/* Called to move horizontal slider up by a single row */
void do_upline (struct win_data * wd, struct rec_data * rd) {
	GRECT r;
	int lines_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	wd->vert_posn -= 1;
	if (wd->vert_posn < 0) wd->vert_posn = 0;
	draw_interior (wd, r, rd);
}

/* Called to move horizontal slider down by a single row */
void do_dnline (struct win_data * wd, struct rec_data * rd) {
	GRECT r;
	int lines_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	lines_avail = r.g_h / char_h;
	wd->vert_posn += 1;
	if (wd->lines_shown > lines_avail && wd->vert_posn > wd->lines_shown - lines_avail) {
		wd->vert_posn = wd->lines_shown - lines_avail;
	} else if (lines_avail >= wd->lines_shown) {
		/* don't move if all lines are showing */
		wd->vert_posn = 0;
	}
	draw_interior (wd, r, rd);
}

/* Called to move horizontal slider left by a page */
void do_lfpage (struct win_data * wd, struct rec_data * rd) {
	GRECT r;
	int colns_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	colns_avail = r.g_w / char_w;
	wd->horz_posn -= colns_avail;
	if (wd->horz_posn < 0) wd->horz_posn = 0;
	draw_interior (wd, r, rd);
}

/* Called to move horizontal slider right by a page */
void do_rtpage (struct win_data * wd, struct rec_data * rd) {
	GRECT r;
	int colns_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	colns_avail = r.g_w / char_w;
	wd->horz_posn += colns_avail;
	if (wd->colns_shown > colns_avail && wd->horz_posn > wd->colns_shown - colns_avail) {
		wd->horz_posn = wd->colns_shown - colns_avail;
	} else if (colns_avail >= wd->colns_shown) {
		wd->horz_posn = 0;
	}
	draw_interior (wd, r, rd);
}

/* Called to move horizontal slider left by a single column */
void do_lfline (struct win_data * wd, struct rec_data * rd) {
	GRECT r;
	int colns_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	colns_avail = r.g_w / char_w;
	wd->horz_posn -= 1;
	if (wd->horz_posn < 0) wd->horz_posn = 0;
	draw_interior (wd, r, rd);
}

/* Called to move horizontal slider right by a single column */
void do_rtline (struct win_data * wd, struct rec_data * rd) {
	GRECT r;
	int colns_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	colns_avail = r.g_w / char_w;
	wd->horz_posn += 1;
	if (wd->colns_shown > colns_avail && wd->horz_posn > wd->colns_shown - colns_avail) {
		wd->horz_posn = wd->colns_shown - colns_avail;
	} else if (colns_avail >= wd->colns_shown) {
		wd->horz_posn = 0;
	}
	draw_interior (wd, r, rd);
}

/* Called when vertical slider moved. */
void do_vslide (struct win_data * wd, struct rec_data * rd, int posn) {
	GRECT r;
	int lines_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	lines_avail = r.g_h / char_h;
	wd->vert_posn = posn * (wd->lines_shown - lines_avail) / 1000;
	if (wd->vert_posn < 0) wd->vert_posn = 0;
	wind_set (wd->handle, WF_VSLIDE, posn, 0, 0, 0);
	draw_interior (wd, r, rd);
}

/* Called when horizontal slider moved. */
void do_hslide (struct win_data * wd, struct rec_data * rd, int posn) {
	GRECT r;
	int colns_avail;

	wind_get (wd->handle, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	colns_avail = r.g_w / char_w;
	wd->horz_posn = posn * (wd->colns_shown - colns_avail) / 1000;
	if (wd->horz_posn < 0) wd->horz_posn = 0;
	wind_set (wd->handle, WF_HSLIDE, posn, 0, 0, 0);
	draw_interior (wd, r, rd);
}

/* called when the full-box is clicked.
   Window will be made full or return to its previous size, depending
   on current state.
 */
void do_fulled (struct win_data * wd, struct rec_data * rd) {
	if (!full_wind (wd)) { /* shrink to previous size */
		int oldx, oldy, oldw, oldh;

		wind_get (wd->handle, WF_PREVXYWH, &oldx, &oldy, &oldw, &oldh);
		graf_shrinkbox (oldx, oldy, oldw, oldh, wd->fullx, wd->fully, wd->fullw, wd->fullh);
		wind_set (wd->handle, WF_CURRXYWH, oldx, oldy, oldw, oldh);

	} else { /* make full size */
		int curx, cury, curw, curh;
		GRECT rec;

		wind_get (wd->handle, WF_CURRXYWH, &curx, &cury, &curw, &curh);
		graf_growbox (curx, cury, curw, curh, wd->fullx, wd->fully, wd->fullw, wd->fullh);
		wind_set (wd->handle, WF_CURRXYWH, wd->fullx, wd->fully, wd->fullw, wd->fullh);

		rec.g_x = wd->fullx;
		rec.g_y = wd->fully;
		rec.g_w = wd->fullw;
		rec.g_h = wd->fullh;

		draw_interior (wd, rec, rd);
	}
}

/* called when the window is resized.  It resizes the current window
   to the new dimensions, but stops the new dimensions going beyond
   the minimum allowed height and width.
   Also, adjusts the vertical position of the displayed text, if
   the new size is larger than what is currently shown.
   */
void do_sized (struct win_data * wd, GRECT * rec) {
	int new_height;
	int new_width;

	if (rec->g_w < MIN_WIDTH) rec->g_w = MIN_WIDTH;
	if (rec->g_h < MIN_HEIGHT) rec->g_h = MIN_HEIGHT;
	wind_set (wd->handle, WF_CURRXYWH, rec->g_x, rec->g_y, rec->g_w, rec->g_h);

	if (!wd->is_chart) { /* only the main window has scroll bars */
		new_height = (rec->g_h / char_h) + 1; /* find new height in characters */
		new_width = (rec->g_w / char_w) + 1;  /* find new width in characters */

		/* if new height is bigger than lines_shown - vert_posn,
		   we can decrease vert_posn to show more lines */
		if (new_height > wd->lines_shown - wd->vert_posn) {
			wd->vert_posn -= new_height - (wd->lines_shown - wd->vert_posn);
			if (wd->vert_posn < 0) wd->vert_posn = 0;
		}
		/* if new height is less than lines_shown - vert_posn,
		   we leave vertical position in same place,
		   so nothing has to be done  */

		/* similarly, if new width is bigger than colns_shown - horz_posn,
		   we can decrease horz_posn to show more columns */
		if (new_width > wd->colns_shown - wd->horz_posn) {
			wd->horz_posn -= new_width - (wd->colns_shown - wd->horz_posn);
			if (wd->horz_posn < 0) wd->horz_posn = 0;
		}

		calc_slid (wd);
	} else { /* just redraw the chart window */
		GRECT rec;
		wind_get (wd->handle, WF_WORKXYWH, &rec.g_x, &rec.g_y, &rec.g_w, &rec.g_h);
		draw_interior (wd, rec, NULL); /* for charts, recdata ignored */
	}
}

/* Called when application asked to redraw parts of its display.
   Walks the rectangle list, redrawing the relevant part of the window.
 */
void do_redraw (struct win_data * wd, GRECT * rec1, struct rec_data * rd) {
	GRECT rec2;

	wind_update (BEG_UPDATE);

	wind_get (wd->handle, WF_FIRSTXYWH, &rec2.g_x, &rec2.g_y, &rec2.g_w, &rec2.g_h);
	while (rec2.g_w && rec2.g_h) {
		if (rc_intersect (rec1, &rec2)) {
			draw_interior (wd, rec2, rd);
		}
		wind_get (wd->handle, WF_NEXTXYWH, &rec2.g_x, &rec2.g_y, &rec2.g_w, &rec2.g_h);
	}

	wind_update (END_UPDATE);
}

/* When closing one of the chart displays, just close that window */
void do_close (struct win_data * wd, int handle) {
	struct win_data * prev_win = NULL;
	struct win_data * this_win = wd;

	if (handle == wd->handle) return; /* do not close main window */

	while ((this_win != NULL) && (this_win->handle != handle)) {
		prev_win = this_win;
		this_win = this_win->next;
	}
	if (this_win != NULL) {
		wind_close (this_win->handle);
		wind_delete (this_win->handle);

		if (prev_win == NULL) { /* This is first window in wd's list */
			wd->next = this_win->next;
		} else {
			prev_win->next = this_win->next;
		}
		free_bar (this_win->chart);
		free (this_win); /* reclaim storage for this_win */
	}
}

/* Actually draws the interior of the window, within the given clipping rectangle.
   Information is given about the current record to be displayed.
 */
void draw_interior (struct win_data * wd, GRECT clip, struct rec_data * rd) {
	int pxy[4];
	char * string;
	struct keyval * keys;
	int lines_to_ignore;
	int wrkx, wrky, wrkw, wrkh; /* some variables describing current working area */
	int dum;

	graf_mouse (M_OFF, 0L);
	set_clip (true, clip);
	wind_get (wd->handle, WF_WORKXYWH, &wrkx, &wrky, &wrkw, &wrkh);

	if (wd->is_chart) {
		chart_draw_bar (wd->chart, app_handle, wrkx, wrky, wrkw, wrkh);

		set_clip (false, clip);
		graf_mouse (M_ON, 0L);

		return;
	}
	/* else is not a chart, so draw text contents of main window */
	vsf_interior (app_handle, SOLID);
	vsf_color (app_handle, WHITE);
	vst_point (app_handle, 11, &dum, &dum, &dum, &dum);
	pxy[0] = wrkx;
	pxy[1] = wrky;
	pxy[2] = wrkx + wrkw - 1;
	pxy[3] = wrky + wrkh - 1;
	vr_recfl (app_handle, pxy);

	wrky += 20; /* move down to top line */
	lines_to_ignore = wd->vert_posn; /* use current position to ignore lines */
	wd->lines_shown = 0;     /* update the number of lines shown to current record */
	wd->colns_shown = 0; /* update the number of columns shown to current record */

	if (rd->current != NULL) {
		wd->lines_shown += 1;
		/* we must always check the width of the string that might be displayed */
		string = malloc(sizeof(char)*(1+3+strlen(rd->current->rd->id)+strlen(rd->current->rd->type)));
		sprintf (string, "%s (%s)", rd->current->rd->id, rd->current->rd->type);
		if (strlen(string) > wd->colns_shown) wd->colns_shown = strlen(string);
		if (lines_to_ignore == 0) {
			if (strlen(string) > wd->horz_posn) { /* display visible part of string */
				v_gtext (app_handle, wrkx+8, wrky, string+wd->horz_posn);
			}
			wrky += char_h;
			free (string);

		} else {
			lines_to_ignore -= 1;
		}

    	/* loop through key-value pairs, displaying each one */
	    keys = rd->current->rd->values;
    	while (keys != NULL) {
   			wd->lines_shown += 1;
   			/* we must always check the width of the string that might be displayed */
			string = malloc (sizeof(char) * (6 + strlen(keys->key) + strlen(keys->val)));
			sprintf (string, ": %s = %s", keys->key, keys->val);
			if (strlen(string) > wd->colns_shown) {
				/* update the columns shown, but remember that we wrap to MAX_W */
				wd->colns_shown = strlen(string);
				if (wd->colns_shown > MAX_W) wd->colns_shown = MAX_W;
			}

    		if (lines_to_ignore == 0) {
				if (strlen(string) > wd->horz_posn) {
					/* display visible part of string, using simple word wrapping */
					int cur_x = 0;
					char * next = strtok (string + wd->horz_posn, " ");

					if (string[wd->horz_posn] == ' ') cur_x += 1; /* HACK: strtok skips initial space */
					do {
						if ((next != NULL) && (cur_x + wd->horz_posn + strlen(next) > MAX_W)) {
							/* move to next line */
							cur_x = 2 - wd->horz_posn; /* allow two spaces at edge */
							wrky += char_h;
							wd->lines_shown += 1;
						}

						if (cur_x >= 0) {
							v_gtext (app_handle, wrkx + 8 + cur_x*char_w, wrky, next);
						} else if (strlen(next) > -cur_x) {
							/* text off left side of screen but visible */
							v_gtext (app_handle, wrkx + 8, wrky, next-cur_x);
						}

						cur_x += strlen (next) + 1;
					} while ((next = strtok (NULL, " ")) != NULL);
				}
				wrky += char_h;
				free (string);
			} else {
				lines_to_ignore -= 1;
			}
			keys = keys->next;
	    }
	}

	wd->lines_shown += 1; /* gain a bit of space at bottom of window */
	wd->colns_shown += 2; /* gain a bit of space on the right of window */
	set_clip (false, clip);
	calc_slid (wd);
	graf_mouse (M_ON, 0L);
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
	lines_avail = wrkh / char_h;
	cols_avail = wrkw / char_w;

	/* handle vertical slider */
	wind_set (wd->handle, WF_VSLSIZE, slider_size (lines_avail, wd->lines_shown), 0, 0, 0);
	wind_set (wd->handle, WF_VSLIDE, slider_posn (lines_avail, wd->lines_shown, wd->vert_posn), 0, 0, 0);

	/* handle horizontal slider */
	wind_set (wd->handle, WF_HSLSIZE, slider_size(cols_avail, wd->colns_shown), 0, 0, 0);
	wind_set (wd->handle, WF_HSLIDE, slider_posn (cols_avail, wd->colns_shown, wd->horz_posn), 0, 0, 0);
}
