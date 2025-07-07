/*
 * Copyright 1992 Eric R. Smith. All rights reserved.
 * Redistribution is permitted only if the distribution
 * is not for profit, and only if all documentation
 * (including, in particular, the file "copying")
 * is included in the distribution in unmodified form.
 * THIS PROGRAM COMES WITH ABSOLUTELY NO WARRANTY, NOT
 * EVEN THE IMPLIED WARRANTIES OF MERCHANTIBILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE. USE AT YOUR OWN
 * RISK.
 */
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <osbind.h>
#include <ctype.h>
#include <keycodes.h>
#include "xgem.h"

char *about_string = "About...";
char *desk_string = "TOSWIN";
void (*about_func)() = 0;

/* local variables */
static MENU 	*curmenu = 0;	/* currently displayed menu */
static MENU	*deskmenu = 0;	/* the whole menu bar, include " Desk " */
static OBJECT	*menuobj = 0;	/* menu object for the displayed menu */

/*
 * Create a menu with the given title. Under GEM, we automatically
 * add a space before and after the title, for aesthetics. (This is
 * done in fixmenu.)
 */

MENU *
create_menu(title)
	const char *title;
{
	MENU *m;

	m = malloc(sizeof(MENU));
	if (!m) return m;
	m->next = 0;
	m->title = strdup(title);
	m->width = 0;
	m->contents = 0;
	m->index = 0;
	return m;
}

/*
 * Destroy a menu, freeing any memory allocated for it.
 */

void
destroy_menu(menu)
	MENU *menu;
{
	MENU *m;
	ENTRY *e;

	if (curmenu && menu == curmenu) {
		hide_menu();
	}

	while (menu) {
		m = menu; menu = m->next;
		while ((e = m->contents)) {
			m->contents = e->next;
			free(e->entry);
			free(e);
		}
		free(m);
	}
}

/*
 * Add a new entry to a menu. We automatically add 2 spaces before and
 * 2 after the menu entry string, for aesthetics, in fixmenu, and
 * any special key symbols are also placed there; so the user doesn't
 * need to worry about these details.
 * NOTE: the string given as `entry' need not remain around permanently;
 * we duplicate it just to be on the safe side.
 * Returns: the newly added entry, or NULL on failure.
 */

ENTRY *
add_entry( m, entry, f, arg, key, state)
	MENU *m;
	char *entry;
	void (*f)();
	void *arg;
	int key, state;
{
	ENTRY *e, **ep;

	e = malloc(sizeof(ENTRY));
	if (!e) return 0;
	ep = &m->contents;
	while (*ep) {
		ep = &((*ep)->next);
	}
	*ep = e;
	e->next = 0;
	e->entry = strdup(entry);
	e->func = f;
	e->arg = arg;
	e->state = state;
	e->keycode = key;
	e->index = 0;
	return e;
}

/* calculate the length of an entry; this is:
 * 2 (leading blanks) + strlen(e->entry) + 2 (trailing blanks) +
 * (optional) some number of bytes for any key symbols
 */

#define MAXKEYSYMLEN 4

int
entrylen(e)
	ENTRY *e;
{
	return 4 + strlen(e->entry) + (e->keycode ? 1 + strlen(UNALT(e->keycode)) :
					 0);
}

/*
 * make a string representing a menu entry
 */

char *
entrystr(e, wide)
	ENTRY *e;
	int wide;
{
	int i, n;
	char *s, *ret, c;

	n = wide + 1;
	ret = malloc(n);
	if (!ret) return 0;
	i = 2;
	c = '-';
	for (s = e->entry; *s; s++) {
		ret[i++] = *s;
		if (*s != '-') c = ' ';
		if (i == n) break;
	}
	ret[0] = c; ret[1] = c;			/* leading blanks or dashes */

	while (i < n-1)
		ret[i++] = c;			/* trailing blanks or dashes */

	ret[n-1] = 0;
/* special case for '-----' type strings */
	if (c == '-') {
		return ret;
	}

/* special symbols for keyboard equivalents */
	if (e->keycode) {
		s = UNALT(e->keycode);
		i = (n-2) - strlen(s);		/* right justify, trailing blank */
		if (i > 3) {
			while (*s)
				ret[i++] = *s++;
		}
	}
	return ret;
}

static OBJECT *
fixmenu( bar )
	MENU *bar;
{
	OBJECT *obj;
	int i, wide, y, place;
	int numobjects, num_titles, num_entries;
	int menubox;
	MENU *m; ENTRY *e;
	char *s;

	numobjects = 4;	/* all menu bars needs some invisible boxes */
	num_titles = 0;

/* count up the number of objects necessary */
	for (m = bar; m; m = m->next) {
		num_titles++;
		numobjects++;		/* for the title */
		numobjects++;		/* for the menu box */
		for (e = m->contents; e; e = e->next) {
			numobjects++;	/* for the entry */
		}
	}

	obj = malloc(numobjects * sizeof(OBJECT));
	if (!obj) return obj;

/* now we create the various objects we need */
/* first, the root menu bar object */
	obj[0].ob_next = -1;
	obj[0].ob_head = 1;
	obj[0].ob_tail = num_titles + 3;
	obj[0].ob_type = G_IBOX;
	obj[0].ob_flags = NONE; obj[0].ob_state = NORMAL;
	obj[0].ob_spec = 0L;
	obj[0].ob_x = 0; obj[0].ob_y = 0;
	obj[0].ob_width = 90; obj[0].ob_height = 25;

/* now the menu bar box itself */
	obj[1].ob_next = obj[0].ob_tail;
	obj[1].ob_head = 2;
	obj[1].ob_tail = 2;
	obj[1].ob_type = G_BOX;
	obj[1].ob_flags = NONE; obj[1].ob_state = NORMAL;
	obj[1].ob_spec = 0x00001100L;
	obj[1].ob_x = 0; obj[1].ob_y = 0;
	obj[1].ob_width = 90; obj[1].ob_height = 513;

	obj[2].ob_next = 1;
	obj[2].ob_head = 3;
	obj[2].ob_tail = 2 + num_titles;
	obj[2].ob_type = G_IBOX;
	obj[2].ob_flags = NONE; obj[2].ob_state = NORMAL;
	obj[2].ob_spec = 0L;
	obj[2].ob_x = 2; obj[2].ob_y = 0;
	obj[2].ob_width = 0;		/* will be adjusted later */
	obj[2].ob_height = 769;

	i = 3;
	for (m = bar; m; m = m->next) {
		m->index = i;
		obj[i].ob_next = (m->next  == 0) ? 2 : i+1;
		obj[i].ob_head = obj[i].ob_tail = -1;
		obj[i].ob_type = G_TITLE;
		obj[i].ob_flags = NONE; obj[i].ob_state = NORMAL;
		obj[i].ob_width = strlen(m->title) + 2;
		s = malloc(obj[i].ob_width + 1);
		if (!s) return NULL;
		s[0] = ' ';
		strcpy(s+1, m->title);
		strcat(s, " ");
		obj[i].ob_spec = (long)s;
		obj[i].ob_height = 769;
		obj[i].ob_x = obj[2].ob_width;
		obj[2].ob_width += obj[i].ob_width;
		obj[i].ob_y = 0;
		i++;
	}
	obj[i].ob_next = 0;
	obj[i].ob_head = i+1;
	obj[i].ob_tail = 0;		/* to be adjusted later */
	menubox = i;
	obj[i].ob_type = G_IBOX;
	obj[i].ob_flags = NONE; obj[i].ob_state = NORMAL;
	obj[i].ob_spec = 0L;
	obj[i].ob_x = 0; obj[i].ob_y = 769;
	obj[i].ob_width = 80; obj[i].ob_height = 19;
	i++;

/* now, for each menu we calculate the number of entries and
 * the size of the necessary box
 */
	place = 2;

	for (m = bar; m; m = m->next) {
		int box;

		box = i;
		num_entries = wide = 0;
		for(e = m->contents; e; e = e->next) {
			num_entries++;
			if (m == deskmenu) {
				if (strlen(e->entry) > wide)
					wide = strlen(e->entry);
			} else {
				if (entrylen(e) > wide)
					wide = entrylen(e);
			}
		}
		if (m->next)
			obj[i].ob_next = i + num_entries + 1;
		else {
			obj[i].ob_next = menubox;
			obj[menubox].ob_tail = i;
		}
		obj[i].ob_head = i+1;
		obj[i].ob_tail = i + num_entries;
		obj[i].ob_type = G_BOX;
		obj[i].ob_flags = NONE; obj[i].ob_state = NORMAL;
		obj[i].ob_spec = 0x00ff1100L;
		obj[i].ob_x = place; obj[i].ob_y = 0;
		place += strlen(m->title)+2;
		obj[i].ob_width = wide; obj[i].ob_height = num_entries;
		i++;
		y = 0;

		for (e = m->contents; e; e = e->next) {
			e->index = i;
			obj[i].ob_next = (e->next) ? i+1 : box;
			obj[i].ob_head = obj[i].ob_tail = -1;
			obj[i].ob_type = G_STRING;
			obj[i].ob_flags = NONE;
			obj[i].ob_state = e->state;
	/* Do NOT malloc the strings for the Desk menu, or else there
	 * will be a memory leak!
	 */
			if (m != deskmenu)
				s = entrystr(e, wide);
			else {
				s = e->entry;
			}
			if (!s) return NULL;
			obj[i].ob_spec = (long)s;
			obj[i].ob_x = 0; obj[i].ob_y = y++;
			obj[i].ob_width = wide; obj[i].ob_height = 1;
			i++;
		}
	}
	obj[i-1].ob_flags = LASTOB;

/* now, fix the object tree up */
	for (i = 0; i < numobjects; i++)
		rsrc_obfix(obj, i);

	return obj;
}

void
handle_menu(title, index)
	int title, index;
{
	MENU *m;
	ENTRY *e;

	for (m = deskmenu; m; m = m->next) {
		if (m->index == title) break;
	}
	if (m) {
	    for (e = m->contents; e; e = e->next) {
		if (e->index == index) {
			(*e->func)(e->arg);
			menu_tnormal(menuobj, title, 1);
			return;
		}
	    }
	}

/* strange. Let's just punt and return */
}

/*
 * erase menu currently on screen (if one exists), and frees the memory
 * allocated for its strings
 */

void
hide_menu()
{
	int i;
	int firststring;
	extern short _app;

	if (!_app) {
		if (deskmenu)
			deskmenu->next = curmenu = 0;
		return;
	}

	if (curmenu && curmenu->contents) {
		firststring = curmenu->contents->index;
	} else {
		firststring = 0x7fff;	/* ridiculously big number */
	}

	if (menuobj) {
		menu_bar(menuobj, 0);
		i = 0;
		for(;;) {
			if (menuobj[i].ob_type == G_TITLE)
				free((void *)menuobj[i].ob_spec);
			else if (menuobj[i].ob_type == G_STRING) {
	/* Something to watch out for here: the desktop will replace the 6
	 * .ACC strings with its own strings (eek). So, we can only
	 * free G_STRINGS with the "right" indices
	 */
				if (i >= firststring)
					free((void *)menuobj[i].ob_spec);
			}
			if (menuobj[i].ob_flags & LASTOB) break;
			i++;
		}
		free(menuobj);
		menuobj = 0;
		deskmenu->next = curmenu = 0;
	}
}

/*
 * Show a menu bar; this will erase any previous menu. It will also
 * automatically construct a "Desk" menu.
 */

void
show_menu( m )
	MENU *m;
{
	static void dflt_about(), nullfunc();
	static char about_buf[22] = "  Your message here";
	int i; char *s;
	extern short _app;

	hide_menu();

	if (deskmenu == 0) {
		deskmenu = create_menu(desk_string);
		add_entry(deskmenu, about_buf, dflt_about, NULL, 0, NORMAL);
		add_entry(deskmenu, "--------------------", nullfunc, NULL, 0,
			DISABLED);
		add_entry(deskmenu, "1", nullfunc, NULL, 0, NORMAL);
		add_entry(deskmenu, "2", nullfunc, NULL, 0, NORMAL);
		add_entry(deskmenu, "3", nullfunc, NULL, 0, NORMAL);
		add_entry(deskmenu, "4", nullfunc, NULL, 0, NORMAL);
		add_entry(deskmenu, "5", nullfunc, NULL, 0, NORMAL);
		add_entry(deskmenu, "6", nullfunc, NULL, 0, NORMAL);
	}

	s = about_string;
	for (i = 2; i < 20; i++) {
		if (*s) {
			about_buf[i] = *s++;
		} else {
			about_buf[i] = ' ';
		}
	}

	deskmenu->contents->entry = about_buf;
	deskmenu->contents->func = about_func ? about_func : dflt_about;

	deskmenu->next = curmenu = m;

	if (_app && (menuobj = fixmenu(deskmenu)) != NULL) {
		menu_bar(menuobj, 1);
	}
}

/*
 * Look for a keyboard equivalent for a given menu; if found,
 * execute the associated action and return 1, otherwise return 0.
 */

int
menu_key(code, shift)
	int code;	/* keyboard code we're looking for */
	int shift;	/* not used */
{
	MENU *m;
	ENTRY *e;
	extern short _app;

	for (m = curmenu; m; m = m->next) {
		for (e = m->contents; e; e = e->next) {
			if (e->keycode == code) {
				if (_app) {
					menu_tnormal(menuobj, m->index, 0);
					handle_menu(m->index, e->index);
				} else {
					(*e->func)(e->arg);
				}
				return 1;
			}
		}
	}
	return 0;
}

static void
nullfunc()
{
}

/* not actually needed, TOSWIN sets up an about() function properly */

static void
dflt_about()
{
}

/*
 * routines for checking/unchecking menu entries
 */

void
check_entry(m, e)
	MENU *m;
	ENTRY *e;
{
	MENU *n;

	e->state = CHECKED;
	if (curmenu && menuobj) {
		for (n = curmenu; n; n = n->next) {
			if (n == m) {
				menu_icheck(menuobj, e->index, 1);
				return;
			}
		}
	}
}

void
uncheck_entry(m, e)
	MENU *m;
	ENTRY *e;
{
	MENU *n;

	e->state = NORMAL;
	if (curmenu && menuobj) {
		for (n = curmenu; n; n = n->next) {
			if (n == m) {
				menu_icheck(menuobj, e->index, 0);
				return;
			}
		}
	}
}

/*
 * routines for enabling/disabling menu items
 */

void
enable_entry(m, e)
	MENU *m;
	ENTRY *e;
{
	MENU *n;

	e->state = NORMAL;
	if (curmenu && menuobj) {
		for (n = curmenu; n; n = n->next) {
			if (n == m) {
				menu_ienable(menuobj, e->index, 1);
				return;
			}
		}
	}
}

void
disable_entry(m, e)
	MENU *m;
	ENTRY *e;
{
	MENU *n;

	e->state = DISABLED;
	if (curmenu && menuobj) {
		for (n = curmenu; n; n = n->next) {
			if (n == m) {
				menu_ienable(menuobj, e->index, 0);
				return;
			}
		}
	}
}

/*
 * ALT: finds the appropriate key-code for, e.g., ALT-A based upon
 * the current settings of the keyboard caps lock table
 */

int
ALT(c)
	int c;
{
	char *capstab;
	int i;

	c = toupper(c);
	if (c == '0') return (ALT_0 << 8);
	if (c >= '1' && c <= '9') {
		return (ALT_1 + (c - '1')) << 8;
	}

	capstab = *( ((char **)Keytbl(-1L, -1L, -1L)) + 2 );
	for (i = 0; i < 127; i++) {
		if (capstab[i] == c)
			return (i << 8);
	}
	return 0;
}

/*
 * UNALT: somewhat misnamed; finds an ASCII string representation for
 * the given keycode. Note that the returned string is overwritten
 * by subsequent UNALT calls.
 */

#define ALTSYM '\007'
#define CTRLSYM '^'
#define SHIFTSYM '\001'

struct kdef {
	int scan;
	char *name;
} keyname[] = {
	K_INS, "Ins",
	K_HOME, "Home",
	K_UNDO, "Undo",
	K_HELP, "Help",
	CURS_UP, "\001",
	CURS_DN, "\002",
	CURS_RT, "\003",
	CURS_LF, "\004",
	0, 0
};

char *
UNALT(code)
	int code;
{
	char *capstab, *s;
	static char retbuf[8];
	int scan, c;
	struct kdef *k;

	s = retbuf;
	if (!code) {
		*s++ = 0;
		return retbuf;
	}

	c = code & 0x00ff;
	scan = (code & 0xff00) >> 8;

	if ((scan == CURS_UP && c == '8') ||
	    (scan == CURS_DN && c == '2') ||
	    (scan == CURS_RT && c == '6') ||
	    (scan == CURS_LF && c == '4')) {
		*s++ = 'S'; *s++ = 'h'; *s++ = 'f'; *s++ = 't';
		c = 0;
	} else if (scan == K_HOME && c == '7') {
		strcpy(s, "Clr");
		return retbuf;
	}

	if (c) {
		if (c == 0x7f) {	/* DEL */
			*s++ = 'D';
			*s++ = 'E';
			c = 'L';
		} else if (c == '\033') {	/* ESC */
			*s++ = 'E';
			*s++ = 'S';
			c = 'C';
		}
		if (c < ' ') {		/* control characters */
			*s++ = CTRLSYM;
			c += '@';
		}
		*s++ = c;
		*s++ = 0;
		return retbuf;
	}

/* Special cases go here... */
	for (k = keyname; k->name; k++) {
		if (scan == k->scan) {
			strcpy(s, k->name);
			return retbuf;
		}
	}

/* shifted function keys */
	if (scan >= SHF_1 && scan <= SHF_10) {
		scan = (scan - SHF_1) + F_10 + 1;
		/* fall through */
	}

/* function keys */
	if (scan >= F_1 && scan <= F_10 + 10) {
		*s++ = 'F';
		c = scan - F_1 + 1;
		if (c >= 10) {
			*s++ = '1';
			c -= 10;
			if (c == 10) {
				s[-1] = '2';
				c = 0;
			}
		}
		*s++ = '0'+c;
		*s++ = 0;
		return retbuf;
	}

/* Now check for ALT keys */
	if (scan >= ALT_1 && scan <= ALT_0) {
		*s++ = ALTSYM;
		scan = (scan - ALT_1) + 1;
		if (scan == 10) scan = 0;
		*s++ = '0'+scan;
		*s++ = 0;
		return retbuf;
	}

/* look for ALT+key */
	capstab = *( ((char **)Keytbl(-1L, -1L, -1L)) + 2 );
	c = capstab[scan];
	if (c >= 'A' && c <= 'Z') {
		*s++ = ALTSYM;
		*s++ = c;
	}
	*s++ = 0;
	return retbuf;
}

#ifdef WWA_GEM_RUN
void desk_menu_show(yes)
	int yes;
{
	if (menuobj) {
		if (yes) {
			menu_bar(menuobj, 1);
		} else {
			menu_bar(menuobj, 0);
		}
	}
}
#endif
