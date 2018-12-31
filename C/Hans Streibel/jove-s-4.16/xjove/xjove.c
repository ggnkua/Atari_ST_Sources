/*
 * Copyright (C) 1986 Free Software Foundation, Inc.
 * Copyright (C) 1991-1996 C.H.Lindsey, University of Manchester
 *
 * This file is derived from the program emacstool, which is itself part of the
 * GNU Emacs system.
 *
 * In the same way as GNU Emacs itself, this file is distributed in the hope
 * that it will be useful, but without any warranty.  No author or
 * distributor accepts responsibility to anyone for the consequences of using
 * it or for whether it serves any particular purpose or works at all, unless
 * he says so in writing.
 *
 * Everyone is granted permission to copy, modify and redistribute this file,
 * but only under the conditions described in the document "GNU Emacs copying
 * permission notice".   A copy of that document is distributed along with
 * GNU Emacs and other GNU Products so that you can know how you may
 * redistribute it all. In particular and among other things, this copyright
 * notice must be preserved on all copies of this file and of files derived
 * from it.
 *
 *
 * For Jove in SunView/Sun-Windows: (supported by Sun Unix v3.2) Insert a
 * notifier filter-function to convert all useful input to "key" sequences
 * that jove can understand.  See: Xjove(1).
 *
 * Author (of Jovetool/Xjove): C. H. Lindsey, University of Manchester
 * <chl@clw.cs.man.ac.uk>
 * Author (of Emacstool): Jeff Peck, Sun Microsystems, Inc. <peck@sun.com>
 *
 * Original Idea: Ian Batten
 *
 */

#include <xview/defaults.h>
#include <xview/xview.h>
#include <xview/tty.h>
#include <xview/ttysw.h>	/* is this missing on some systems? */
#include <xview/termsw.h>
#include <xview/cursor.h>
#include <xview/font.h>
#include <X11/Xlib.h>
#include <X11/keysym.h>
#include <X11/Sunkeysym.h>	/* for Suns only */
#include <stdio.h>
#include <string.h>
#include <sys/file.h>
#include <stdlib.h>
#include <unistd.h>	/* is this missing on some systems? */
#include <fcntl.h>
#include <termios.h>

#include "exts.h"
#include "mousemsg.h"

#define BUFFER_SIZE 256		/* Size of all the buffers */

#define CLICK	400		/* max time in ms for click, or gap between
				 * double click */

/* define WANT_CAPS_LOCK to make f-key T1 (aka F1) behave as CapsLock */
/* #define WANT_CAPS_LOCK */

private const char mouse_prefix[] = "\030m";	/* ^x m */
private const char key_prefix[] = "\033[";	/* ESC-[ */

private char   *jove_name = "jove";	/* default run command */
private char    buffer[BUFFER_SIZE];	/* send to ttysw_input */
private const char title[] = "XJove - ";	/* initial title */

private Frame   frame;		/* Base frame for system */
Tty             ttysw;		/* Where jove is */
private Tty     ttyview;
private int     font_width, font_height;	/* For translating pixels to
						 * chars */
private int     left_margin, right_margin;

private FILE   *console = NULL;	/* for debugging: setenv DEBUGJOVETOOL */

private Icon    frame_icon;
/* make an icon_image */
private unsigned short default_image[] =
{
#include "jove.icon"
};
mpr_static_static(icon_image, 64, 64, 1, default_image);

private Xv_Cursor current_cursor, jove_cursor, cut_cursor, copy_cursor, paste_cursor, default_cursor;

private unsigned short cursor_image[] = {
#include "jove.cursor"
};
mpr_static_static(cursor_pix, 16, 16, 1, cursor_image);

private unsigned short cut_image[] = {
#include "cut.cursor"
};
mpr_static_static(cut_pix, 16, 16, 1, cut_image);

private unsigned short copy_image[] = {
#include "copy.cursor"
};
mpr_static_static(copy_pix, 16, 16, 1, copy_image);

private unsigned short paste_image[] = {
#include "paste.cursor"
};
mpr_static_static(paste_pix, 16, 16, 1, paste_image);

Xv_Font         font;



private void
set_cursor(cursor)
	Xv_Cursor       cursor;
{
	if (current_cursor != cursor) {
		xv_set(ttyview, WIN_CURSOR, cursor, 0);
		current_cursor = cursor;
	}
}


/*
 * button_value: encode mouse event into an xjove event code (the return
 * value) and a button state (stored in last_but).  If the event ought to be
 * ignored due to error, -1 is returned in place of the event code. If it is
 * to be ignored silently, -2 is returned.
 */
private int
                last_but = JT_UPEVENT,	/* button state */
                event_shift,	/* shift state */
                next_kdb_event_should_be_up;
private char
                last_event_string[7];	/* string from last F-key down event,
					 * 6 being the longest string
					 * expected from an F-key */

private int
button_value(event)
	Event          *event;
{
	static struct timeval
	                mouse_time = {0, 0},
	                prev_mouse_time;

	static int      multiclick_state = 0;

	int
	                this_but = event_shift,	/* button state, after this
						 * event */
	                mouse_code;	/* event code for this event */

	switch (event_id(event)) {
	case LOC_DRAG:
		if (last_but & JT_UPEVENT)
			return -1;
		else if (multiclick_state)
			return -2;
		last_but |= JT_DRAGEVENT;
		{
			/*
			 * Generate event code for leftmost depressed button.
			 * Currently, only one bit will be on, so this is
			 * overkill.
			 */
			static short    DragCode[8] = {
				-1, JTEC_LEFT, JTEC_MIDDLE, JTEC_LEFT,
			JTEC_RIGHT, JTEC_LEFT, JTEC_MIDDLE, JTEC_LEFT};

			return DragCode[last_but & JT_BUTMASK] + JTEC_DRAG;
		}
	case MS_LEFT:
		this_but |= JT_LEFT;
		mouse_code = JTEC_LEFT;
		break;
	case MS_MIDDLE:
		this_but |= JT_MIDDLE;
		mouse_code = JTEC_MIDDLE;
		break;
	case MS_RIGHT:
		this_but |= JT_RIGHT;
		mouse_code = JTEC_RIGHT;
		break;
	default:
		return -1;
	}

	/*
	 * Clicking too fast can sometimes beat the system. Also, a user
	 * might manage to get two buttons down at the same time.  The
	 * following tests detect such situations. Note that up events after
	 * JT_RIGHT are absorbed by the menu software.
	 */
	if (event_is_up(event)) {
		/* ignore up not following a down or up of a different button */
		if ((last_but & (JT_UPEVENT | JT_RIGHT)) == JT_UPEVENT
		    || ((last_but ^ this_but) & JT_BUTMASK) != 0)
			return -1;
		this_but |= JT_UPEVENT;
		mouse_code += JTEC_UP;
	} else if (event_is_down(event)) {
		if ((last_but & (JT_UPEVENT | JT_RIGHT)) == 0) {
			/* down event not preceded by an up or right event */
			return -1;
		}
	} else {		/* drag event */
		if ((last_but & (JT_DOWNEVENT | JT_DRAGEVENT)) == 0) {
			/* drag event not preceded by a down or drag event */
			return -1;
		}
	}
	/*
	 * The only way to get back into sync is to supply whatever up or
	 * down event it was waiting for. Thus jove should always see a
	 * consistent picture
	 */

	/*-- Detect and encode multi-clicks.
	 *
	 * - a multiclick is a train of alternating mouse-down and mouse-up events
	 * - the first must be a mouse-down
	 * - Each mouse up and down must be of the same button
	 * - each of which happens within CLICK milliseconds of its predecessor
	 * - Drags are not taken into consideration.
	 */

	prev_mouse_time = mouse_time;
	mouse_time = event_time(event);

	multiclick_state += 1;
	if (((multiclick_state & 1) == 0) == ((this_but & JT_UPEVENT) == 0)
	    && ((last_but ^ this_but) & JT_BUTMASK) == 0
	    && (mouse_time.tv_sec - prev_mouse_time.tv_sec) * 1000
	 + (mouse_time.tv_usec - prev_mouse_time.tv_usec) / 1000 <= CLICK) {
		switch (multiclick_state) {
		case 1:	/* first up */
			break;
		case 2:	/* second down */
			mouse_code += JTEC_CLICK2;
			/* FALLTHROUGH */
		case 3:	/* second up */
			this_but |= JT_CLICK2;
			break;
		case 4:	/* third down */
			mouse_code += JTEC_CLICK3;
			/* FALLTHROUGH */
		case 5:	/* third up */
			this_but |= JT_CLICK3;
			break;
		default:	/* too many multi-clicks */
			multiclick_state = 0;
			break;
		}
	} else {
		multiclick_state = 0;
	}

	last_but = this_but;
	return mouse_code;
}


/*
 * Filter function to translate selected input events for jove Mouse button
 * events become ^XmC(button-state x-col y-line font-width) . - C is an
 * eventcode (explained in mousemsg.h) - button-state is as described
 * mousemsg.h for this_but - x-col is horizontal column, in pixels (for
 * smooth scrollbar working) - y-col is height, in characters - font-width
 * allows conversion of x-col to characters Sun function keys (left, top, and
 * right) are converted to the ANSI sequence ESC [ P z, where P is a number
 * above 192
 */

private Notify_value
input_event_filter_function(window, event, arg, type)
	Xv_Window       window;
	Event          *event;
	Notify_arg      arg;
	Notify_event_type type;
{
	int             id = event_id(event);
	int             mouse_code = -3;	/* not -1 and not -2 and not
						 * >=0 */
	int             fkey;

	event_shift &= ~JT_CSMASK;
	if (event_shift_is_down(event))
		event_shift |= JT_SHIFT;
	if (event_ctrl_is_down(event))
		event_shift |= JT_CONTROL;
	/*
	 * Under Xview (but not SunView) the answers to the above queries do
	 * not reflect the effect of the current event!
	 */
	{
		int             delta = 0;

		switch (event_action(event)) {
		case SHIFT_LEFT:
		case SHIFT_RIGHT:
			delta = JT_SHIFT;
			break;
		case SHIFT_CTRL:
			delta = JT_CONTROL;
			break;
		case ACTION_PASTE:
			delta = JT_PASTE;
			break;
		case ACTION_CUT:
			delta = JT_CUT;
			break;
		}
		if (event_is_up(event))
			event_shift &= ~delta;
		else
			event_shift |= delta;
	}

	if (console != NULL) {
		fprintf(console, "Ttyview Event %d", id);
		if (event_shift != 0)
			fprintf(console, "; shift %d", event_shift);
		if (event_is_up(event))
			fprintf(console, "; up");
		if (event_is_button(event))
			fprintf(console, "; button %d", id - BUT(0));
		fprintf(console, "\n");
	}
	switch (id) {
	case LOC_DRAG:
		mouse_code = button_value(event);
		/* no need to set cursor */
		break;
	case MS_LEFT:
	case MS_MIDDLE:
	case MS_RIGHT:
		mouse_code = button_value(event);
		if (last_but & JT_PASTEMASK)
			last_event_string[0] = 0;
		/*
		 * We do not wish to see Left keys (esp. PASTE & CUT)
		 * associated with buttons
		 */
		/* FALLTHROUGH */
	case SHIFT_LEFT:
	case SHIFT_RIGHT:
	case SHIFT_CTRL:
		/* set cursor appropriately */
		if (event_shift == JT_SHIFT) {
			set_cursor(default_cursor);
		} else {
			switch (event_shift | (last_but & (JT_UPEVENT | JT_BUTMASK))) {
			case JT_SHIFT | JT_CONTROL | JT_MIDDLE:
				set_cursor(cut_cursor);
				break;
			case JT_CONTROL | JT_MIDDLE:
				set_cursor(copy_cursor);
				break;
			case JT_CONTROL | JT_LEFT:
				set_cursor(paste_cursor);
				break;
			default:
				set_cursor(jove_cursor);
				break;
			}
		}
		break;
	case KEY_LEFT(5):	/* EXPOSE or FRONT key */
	case KEY_LEFT(7):	/* OPEN key */
		/*
		 * UP L5 & L7 are Expose & Open, let them pass to SunView.
		 * Apparently it only cares about up events. Actually, the
		 * down event never gets this far, but the up event seems to
		 * be needed to force a refresh.
		 */
		return event_is_up(event)
			? notify_next_event_func(window, (Notify_event) event, arg, type)
			: NOTIFY_IGNORED;
	}

	/* Treat shifted events as normal Shelltool events. */
	if (event_shift == JT_SHIFT && id >= ISO_LAST) {
		Notify_value    result;

		/* Translate well-known left keys. */
		switch (id) {
		case KEY_LEFT(6):
			event->action = ACTION_COPY;
			break;
		case KEY_LEFT(8):
			event->action = ACTION_PASTE;
			break;
		case KEY_LEFT(10):
			event->action = ACTION_COPY;	/* CUT is censored */
			break;
		}

		event_shiftmask(event) &= ~SHIFTMASK;	/* get rid of shift */
		event_set_string(event, NULL);	/* later versions of xview
						 * seem to output this string
						 * even when they have already
						 * interpreted the event as a
						 * copy/paste/cut
						 */

		result = notify_next_event_func(window, (Notify_event) event, arg, type);
		return result;
	}
	/* do Mouse Button events */

	if (mouse_code >= 0) {
		int
		                this_x = event_x(event) - left_margin, this_y = event_y(event) / font_height;
		static int      last_x, last_y;

		if (last_but & JT_RIGHT) {
			/*
			 * ??? avoid passing up-event, if we catch it --
			 * would cause deadlock.
			 */
			if (last_but == JT_RIGHT)
				menu_show(main_menu, window, event, 0);
		} else {
			if (this_x == last_x && this_y == last_y) {
				if (id == LOC_DRAG)
					return NOTIFY_IGNORED;
				sprintf(buffer, "%s%d(%d)\015",
					mouse_prefix, mouse_code, last_but);
			} else {
				sprintf(buffer, "%s%d(%d %d %d %d)\015",
					mouse_prefix, mouse_code, last_but,
					this_x, this_y, font_width);
				last_x = this_x;
				last_y = this_y;
			}
			ttysw_input(ttysw, buffer, strlen(buffer));
		}
		return NOTIFY_IGNORED;
	} else if (mouse_code == -1) {
		ttysw_output(ttysw, "\007", 1);	/* beep */
		return NOTIFY_IGNORED;
	} else if (mouse_code == -2) {
		return NOTIFY_IGNORED;
	}
	if (next_kdb_event_should_be_up && event_is_down(event)
	    && event_is_iso(event)) {
		ttysw_output(ttysw, "\007", 1);	/* beep */
		return NOTIFY_IGNORED;
	}
	next_kdb_event_should_be_up = 0;

	if (event_is_string(event)	/* it has been rebound with
					 * XRebindKeysym */
	    ||event_is_key_left(event)) {	/* For some reason, up events
						 * of PASTE and CUT do not
						 * appear as string events,
						 * but they must be caught
						 * here */
		if (event_is_down(event)) {
			if (event_is_string(event)) {
				strcpy(last_event_string, event_string(event));
				/*
				 * because XView does not seem to provide
				 * these strings on the up event
				 */
			} else {
				last_event_string[0] = '\0';
				/*
				 * Sometimes, even the down event of PASTE is
				 * not a string, as when Caps Lock is down.
				 * Forget it!
				 */
			}
		}
		if (!event_button_is_down(event)) {
			/*
			 * we don't want any function keys (esp PASTE & CUT)
			 * seen when a button is down
			 */
			if (event_action(event) == ACTION_PASTE
			    || event_action(event) == ACTION_CUT) {
				if (event_is_down(event)) {
					/*
					 * we see PASTE and CUT when they
					 * come up
					 */
					next_kdb_event_should_be_up = 1;
					return NOTIFY_IGNORED;
				}
			} else if (event_is_up(event)) {
				/* we see other F-keys when they go down */
				return NOTIFY_IGNORED;
			}
			ttysw_input(ttysw, last_event_string, strlen(last_event_string));
		}
		return NOTIFY_IGNORED;
	}
	if (ISO_FIRST <= id && id <= ISO_LAST) {
		/*
		 * Force bit 8 if meta key is down. But it will only be
		 * noticed by the controlled process if it does a stty
		 * -istrip, or equivalent.
		 */
		if (event_shiftmask(event) & META_SHIFT_MASK)
			event->ie_code |= META_KEY_MASK;
	}
	/* If we get here, pass event off to next handler */
	return notify_next_event_func(window, (Notify_event) event, arg, type);
}

private         Notify_value
tty_event_filter_function(window, event, arg, type)
	Xv_Window       window;
	Event          *event;
	Notify_arg      arg;
	Notify_event_type type;
{
	if (console != NULL)
		fprintf(console, "Ttysw Event: %d\n", event_id(event));

	if (event_id(event) == KBD_USE) {
		win_set_kbd_focus(ttyview, xv_get(ttyview, XV_XID));
		return NOTIFY_IGNORED;
	} else {
		return notify_next_event_func(window, (Notify_event) event, arg, type);
	}
}


void
bind_key(ksym, string)
	KeySym          ksym;
	char           *string;
{
	Display        *dpy;
	static KeySym   shift_list[] =
	{XK_Shift_L, XK_Control_L, XK_Meta_L, XK_Alt_L, XK_Mode_switch};
	int             i;

	dpy = (Display *) xv_get(frame, XV_DISPLAY);
	XRebindKeysym(dpy, ksym, NULL, 0, (unsigned char *) string, strlen(string));
	for (i = 0; i != sizeof(shift_list) / sizeof(*shift_list); i++)
		XRebindKeysym(dpy, ksym, &shift_list[i], 1, (unsigned char *) string, strlen(string));
}

void
bind_function_keys(first, count, number)
	KeySym          first;
	unsigned int    count, number;
{
	int             i;
	char            buffer[6];

	for (i = 0; i < count; i++) {
		sprintf(buffer, "%s%3dz", key_prefix, number + i);
		bind_key(first + i, buffer);
	}
}

int
main(argc, argv)
	int             argc;
	char          **argv;
{
	int             error_code;	/* Error codes */
	int             forking;
	int             argstart = 1;
	char           *debug;
	int             child_argc, i;
	char          **child_argv;
	char           *icon_label;
	int             tty_fd;
	struct termios  tty;

	xv_init(XV_INIT_ARGC_PTR_ARGV, &argc, argv, 0);

	if ((debug = getenv("DEBUGJOVETOOL")) != NULL) {
		/*
		 * DEBUGJOVETOOL specifies the file or device to receive
		 * debugging output, if any.  The null name signifies stderr.
		 */
		console = *debug == '\0' ? stderr : fopen(debug, "w");
		forking = 0;
	} else if (!isatty(0)) {
		forking = 0;
	} else {
		forking = defaults_get_boolean("xjove.forking", "Xjove.Forking", 0);
	}

	if (argc>1 && !strcmp("-nf", argv[1])) {
		forking = 0;
		argstart = 2;
	} else if (argc>1 && !strcmp("-f", argv[1])) {
		forking = 1;
		argstart = 2;
	}

	if (forking) {
		switch (fork()) {
		case -1:
			fprintf(stderr, "fork failed");
			exit(1);
			/* NOTREACHED */
		case 0:	/* the child */
#ifdef SYSVR4
			setsid();	/* so it doesn't get killed when
					 * parent dies */
#else
			setpgid(0, 0);	/* For some reason, setsid() hinders
					 * passing of SIGWINCH events to the
					 * controlled process in SUNOS4 */
#endif
			break;
		default:	/* the parent */
			exit(0);
			/* NOTREACHED */
		}
	}

	putenv("IN_JOVETOOL=t");/* notify subprocess that it is in jovetool */

	font = (Xv_font) xv_find(ttysw, FONT, FONT_NAME,
				 defaults_get_string("font.name", "Font.Name", "lucidasanstypewriter-12"),
				 0);

	child_argv = (char **) malloc((argc + 1) * sizeof(char *));
	if (!(child_argv[0] = (char *) getenv("JOVETOOL")))	/* Set jove command name */
		child_argv[0] = jove_name;
	for (child_argc = 1, i = argstart; i < argc; i++) {
		if (!strcmp("-rc", argv[i])) {
			child_argv[0] = argv[++i];
			child_argc = 1;
		} else {
			child_argv[child_argc++] = argv[i];
		}
	}
	child_argv[child_argc] = NULL;

	/*
	 * choose a "sensible" parameter to put in the icon label, preferably
	 * the file to be edited
	 */
	icon_label = child_argv[0];
	for (i = 1; i < child_argc; i++)
		if (child_argv[i][0] != '-')
			icon_label = child_argv[i];
	frame_icon = icon_create(XV_LABEL, icon_label,
				 ICON_IMAGE, &icon_image,
				 0);

	/* construct the title of the window */
	strcpy(buffer, title);
	strncat(buffer, child_argv[0],	/* append run command name */
		(BUFFER_SIZE - (strlen(buffer)) - (strlen(argv[0]))) - 1);

	/* Build a frame to run in */
	frame = xv_create(XV_NULL, FRAME,
			  XV_LABEL, buffer,
			  FRAME_ICON, frame_icon,
			  0);
	/* construct the command parameters to be shown to Save Workspace */
	buffer[0] = '\0';
	for (i = 1; i < argc; i++)
		sprintf(&buffer[strlen(buffer)], "%s ", argv[i]);
	xv_set(frame, WIN_CMD_LINE, buffer, 0);

	/* Create a tty with jove in it */
	ttysw = xv_create(frame, TERMSW,
			  TTY_ARGV, TTY_ARGV_DO_NOT_FORK,
			  XV_LEFT_MARGIN, defaults_get_integer(
				 "text.margin.left", "Text.Margin.Left", 4),
			  XV_RIGHT_MARGIN, defaults_get_integer(
			       "text.margin.right", "Text.Margin.Right", 0),
	/* 0 because jove never uses the last column anyway */
			  TEXTSW_FONT, font,
			  0);

	ttyview = xv_get(ttysw, OPENWIN_NTH_VIEW, 0);
	left_margin = xv_get(ttysw, XV_LEFT_MARGIN);
	right_margin = xv_get(ttysw, XV_RIGHT_MARGIN);
	font_height = (int) xv_get(ttysw, WIN_ROW_HEIGHT);
	font_width = (int) xv_get(ttysw, WIN_COLUMN_WIDTH);

	tty_fd = (int) xv_get(ttysw, TTY_TTY_FD);
	tcgetattr(tty_fd, &tty);
	tty.c_iflag &= ~ISTRIP;
	tcsetattr(tty_fd, TCSANOW, &tty);
	/* "TTY_ARGV, child_argv" must not be set going before that tcsetattr */

	xv_set(ttysw, TERMSW_MODE, TTYSW_MODE_TYPE,
	       TTY_QUIT_ON_CHILD_DEATH, TRUE,
	       TTY_ARGV, child_argv,
	       OPENWIN_ADJUST_FOR_VERTICAL_SCROLLBAR, 0,
	       XV_WIDTH, defaults_get_integer(
			"window.columns", "Window.Columns", 80) * font_width
	       + left_margin + right_margin + 2,
	/*
	 * WIN_COLUMNS was not used here because it gets confused by the
	 * non-existent scrollbar; the '+ 2' is one pixel for each border
	 */
	       WIN_ROWS, defaults_get_integer(
					  "window.rows", "Window.Rows", 35),
	       0);


	xv_set(ttyview,
	       WIN_CONSUME_EVENTS,
		WIN_ASCII_EVENTS, WIN_META_EVENTS,
		WIN_MOUSE_BUTTONS, WIN_UP_EVENTS,
		LOC_DRAG,
		SHIFT_LEFT, SHIFT_RIGHT, SHIFT_CTRL, SHIFT_META,
		WIN_LEFT_KEYS, WIN_TOP_KEYS, WIN_RIGHT_KEYS,
		0,
	       WIN_COLLAPSE_EXPOSURES, FALSE,
	       0);

	default_cursor = xv_get(ttyview, WIN_CURSOR);
	jove_cursor = xv_create(XV_NULL, CURSOR,
				CURSOR_IMAGE, &cursor_pix,
				CURSOR_XHOT, 8,
				CURSOR_YHOT, 8,
				0);
	cut_cursor = xv_create(XV_NULL, CURSOR,
			       CURSOR_IMAGE, &cut_pix,
			       CURSOR_XHOT, 8,
			       CURSOR_YHOT, 8,
			       0);
	copy_cursor = xv_create(XV_NULL, CURSOR,
				CURSOR_IMAGE, &copy_pix,
				CURSOR_XHOT, 8,
				CURSOR_YHOT, 8,
				0);
	paste_cursor = xv_create(XV_NULL, CURSOR,
				 CURSOR_IMAGE, &paste_pix,
				 CURSOR_XHOT, 8,
				 CURSOR_YHOT, 8,
				 0);
	set_cursor(jove_cursor);

	/* Interpose my event function */
	error_code =
		(int) notify_interpose_event_func
		(ttyview, input_event_filter_function, NOTIFY_SAFE) +
		(int) notify_interpose_event_func
		(ttysw, tty_event_filter_function, NOTIFY_SAFE);
	if (error_code != 0) {	/* Barf */
		fprintf(stderr, "notify_interpose_event_func got %d.\n", error_code);
		exit(1);
	}
	menu_init();

	bind_function_keys((KeySym)XK_L1, 10, 192);
	bind_function_keys((KeySym)XK_Help, 1, 202);
	bind_function_keys((KeySym)XK_F1, 10, 224);
#ifdef SunXK_F36
	bind_function_keys((KeySym)SunXK_F36, 2, 234);	/* for Suns only */
#endif
	bind_function_keys((KeySym)XK_R1, 15, 208);
	/*
	 * But note that the keys R7-R15 are intercepted by XView which
	 * imposes its own bindings
	 */
	bind_function_keys((KeySym)XK_Insert, 1, 247);
	bind_function_keys((KeySym)XK_KP_0, 1, 247);
	bind_function_keys((KeySym)XK_KP_Decimal, 1, 249);
	bind_function_keys((KeySym)XK_KP_Enter, 1, 250);
	bind_function_keys((KeySym)XK_KP_Add, 1, 253);
	bind_function_keys((KeySym)XK_KP_Subtract, 1, 254);

	window_fit(frame);
	window_main_loop(frame);/* And away we go */
	return 0;		/* if this is ever reached */
}
