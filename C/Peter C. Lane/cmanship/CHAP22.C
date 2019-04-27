/* C-Manship chapter 22 */

#include <aes.h>
#include <tos.h>
#include <vdi.h>
#include "string.h"
#include "stdio.h"
#include "stdlib.h"
#include "time.h"

#include "DATE.rsh"

/* GEM arrays */
int work_in[11],
	work_out[57],
	contrl[12],
	intin[128],
	ptsin[128],
	intout[128],
	ptsout[128];

int handle, /* application handle. */
	dum;	/* dummy storage. */

char * get_tedinfo_str (OBJECT * tree, int object);
void get_time (char * string, struct tm * time);
void get_date (char * string, struct tm * time);
void open_vwork (void);
void do_date (void);
int chk_date (OBJECT * dial_addr);
void set_date (OBJECT * dial_addr);

void main (int argc, char * argv) {
	appl_init ();
	open_vwork ();
	do_date ();
	rsrc_free ();
	v_clsvwk (handle);
	appl_exit ();
}

void do_date (void) {
	int dial_x, dial_y, dial_w, dial_h, choice, okay;
	OBJECT * datedial_addr;
	char date_str[10], time_str[10];
	char * string;
	time_t lt;
	struct tm * ptr;

	graf_mouse (ARROW, 0);
	if (!rsrc_load("\date.rsc")) {
		form_alert(1, "[1][date.rsc missing!][OK]");
	} else {
		rsrc_gaddr (R_TREE, DATEDIAL, &datedial_addr);

		lt = time(NULL);
		ptr = localtime (&lt);

		get_time (time_str, ptr);
		get_date (date_str, ptr);

		string = get_tedinfo_str (datedial_addr,DATEDIAL_TIMEFLD);
		strcpy (string, time_str);
		string = get_tedinfo_str (datedial_addr, DATEDIAL_DATEFLD);
		strcpy (string, date_str);

		form_center(datedial_addr, &dial_x, &dial_y, &dial_w, &dial_h);
		form_dial(FMD_START, 0, 0, 10, 10, dial_x, dial_y, dial_w, dial_h);
		okay = 1;

		do {
			objc_draw(datedial_addr, 0, 8, dial_x, dial_y, dial_w, dial_h);
			choice = form_do (datedial_addr, DATEDIAL_TIMEFLD);

			datedial_addr[choice].ob_state = SHADOWED;

			/* do action */
			if (choice == DATEDIAL_OKBUTN) {
				okay = chk_date (datedial_addr);
				if (okay) {
					set_date (datedial_addr);
				}
			}

		} while (okay == 0 && choice == DATEDIAL_OKBUTN);

		form_dial(FMD_FINISH, 0, 0, 10, 10, dial_x, dial_y, dial_w, dial_h);
	}
}

/* return time in string format, reducing hour to 1-12 if after noon */
void get_time (char * string, struct tm * time) {
	int hour = time->tm_hour;
	if (hour > 12) hour -= 12; /* correct for 24 hour clock */
 	sprintf (string, "%02d%02d%02d%cM", hour, time->tm_min, time->tm_sec, (time->tm_hour > 12 ? 'P' : 'A'));
}

/*
  month is 0-11 so add one for display
  year is from 1900, so add 1900 for display
 */
void get_date (char * string, struct tm * time) {
	sprintf (string, "%02d%02d%04d", time->tm_mday, time->tm_mon + 1, time->tm_year + 1900);
}

/* returns a pointer to an editable string in a dialog box */
char * get_tedinfo_str (OBJECT * tree, int object) {
	return tree[object].ob_spec.tedinfo->te_ptext;
}

void open_vwork (void) {
	int i;

	handle = graf_handle (&dum, &dum, &dum, &dum);
	for (i = 0; i < 10; work_in[i++] = 1);
	work_in[10] = 2;
	v_opnvwk (work_in, &handle, work_out);
}

/* Examine strings in dialog for a valid date and time. */
int chk_date (OBJECT * dial_addr) {
	int mnth, day, year, hour, min, sec, space, okay, x;
	char m[3], d[3], y[5], h[3], mn[3], s[3], ap[3];
	char * date_str;
	char * time_str;

	mnth = day = year = hour = min = sec = -1;

	date_str = get_tedinfo_str (dial_addr, DATEDIAL_DATEFLD);

	if (strlen (date_str) == 8) {
		strncpy (d, date_str, 2);
		d[2] = 0;
		strncpy (m, date_str+2, 2);
		m[2] = 0;
		strncpy (y, date_str+4, 4);
		y[4] = 0;
		mnth = atoi (m);
		day = atoi (d);
		year = atoi (y);
	}

	time_str = get_tedinfo_str (dial_addr, DATEDIAL_TIMEFLD);

	/* check for spaces in time string */
	space = 0;
	for (x = 0; x < 6; ++x) {
		if (time_str[x] == ' ') {
			space = 1;
		}
	}

	if ( (strlen(time_str) == 8) && !space ) {
		strncpy (h, time_str, 2);
		h[2] = 0;
		strncpy (mn, time_str+2, 2);
		mn[2] = 0;
		strncpy (s, time_str+4, 2);
		s[2] = 0;
		hour = atoi (h);
		min = atoi (mn);
		sec = atoi(s);
		strcpy (ap, time_str+6);
	}

	/* examine time and date for validity */
	if (day < 1 || day > 31 ||
	    mnth < 1 || mnth > 12 ||
	    year < 1980 || year > 2100 ||
	    hour < 1 || hour > 12 ||
	    min < 0 || min > 59 ||
	    sec < 0 || sec > 59 ||
		((strcmp(ap, "AM") != 0) && (strcmp(ap, "PM") != 0)) ){
		okay = 0;
		form_alert (1, "[1]Date or time not valid!][CONTINUE]");
	} else {
		okay = 1;
	}

	return okay;
}

/* put date and time into correct packed int format for setting via calls to GEMDOS */
void set_date (OBJECT * dial_addr) {

	char * string;
	char s[5];
	int time, date;
	int h;

	string = get_tedinfo_str (dial_addr,DATEDIAL_TIMEFLD);
	strncpy (s, string, 2);
	s[2] = '\0';
	h = atoi(s);

	/* adjust hour to the 24-hour clock format */
	if ((strcmp (&string[6], "PM") == 0) && (h != 12))
		h += 12;
	if ((strcmp (&string[6], "AM") == 0) && (h == 12))
		h = 0;

	/* shift bits into proper position */
	h = h << 11;
	time = h;

	/* get the 'minutes' portion */
	strncpy (s, &string[2], 2);
	s[2] = '\0';
	h = atoi (s);
	h = h << 5;
	time = time | h;

	/* process the 'seconds' portion */
	strncpy (s, &string[4], 2);
	s[2] = '\0';
	h = atoi (s) / 2;
	time = time | h;

	/* Set system clock to new time */
	Tsettime (time);

	/* Get the address of string for date */
	string = get_tedinfo_str (dial_addr,DATEDIAL_DATEFLD);

	/* process the month portion */
	strncpy (s, &string[2], 2);
	s[2] = '\0';
	h = atoi (s); /* months stored as 1-12 */
	h = h << 5;
	date = h;

	/* Process the day portion */
	strncpy(s, &string[0], 2);
	s[2] = '\0';
	h = atoi(s);
	date = date | h;

	/* Process the year portion */
	strncpy(s, &string[4], 4);
	s[4] = '\0';
	h = atoi(s) - 1980; /* years stored from 1980 */
	h = h << 9;
	date = date | h;

	/* Set system clock to new date */
	Tsetdate (date);
}
