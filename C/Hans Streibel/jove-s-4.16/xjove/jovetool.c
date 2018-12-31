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
 * For Jove in SunView/Sun-Windows: (supported by Sun Unix) Insert a notifier
 * filter-function to convert all useful input to "key" sequences that jove
 * can understand.  See: Jovetool(1).
 *
 * Author (of Jovetool): C. H. Lindsey, University of Manchester
 * <chl@clw.cs.man.ac.uk>
 * Author (of Emacstool): Jeff Peck, Sun Microsystems, Inc. <peck@sun.com>
 *
 * Original Idea: Ian Batten
 *
 */

#include <suntool/sunview.h>
#include <suntool/tty.h>
#include <suntool/ttysw.h>
#include <stdio.h>
#include <sys/file.h>
#ifdef	__STDC__
#include <stdlib.h>
#endif
#include <string.h>

#include "exts.h"
#include "mousemsg.h"

#define BUFFER_SIZE 128		/* Size of all the buffers */

#define CLICK	400		/* max time in ms for click, or gap between
				 * double click */

/* define WANT_CAPS_LOCK to make f-key T1 (aka F1) behave as CapsLock */
/* #define WANT_CAPS_LOCK */

private const char mouse_prefix[] = "\030m";	/* ^x m */
private const char key_prefix[] = "\033[";	/* ESC-[ */

private char    jove_name[] = "jove";	/* default run command */
private char    buffer[BUFFER_SIZE];	/* send to ttysw_input */
private const char title[] = "Jovetool - ";	/* initial title */

private Frame   frame;		/* Base frame for system */
Tty             ttysw;		/* Where jove is */
private int     font_width, font_height;	/* For translating pixels to
						 * chars */

private FILE   *console = NULL;	/* for debugging: setenv DEBUGJOVETOOL */

private Icon    frame_icon;
/* make an icon_image */
private unsigned short default_image[] =
{
#include "jove.icon"
};
mpr_static_static(icon_image, 64, 64, 1, default_image);

private Cursor  current_cursor, jove_cursor, cut_cursor, copy_cursor, paste_cursor, default_cursor;

private short   cursor_image[] = {
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



private void
set_cursor(cursor)
	Cursor          cursor;
{
	if (current_cursor != cursor) {
		window_set(ttysw, WIN_CURSOR, cursor, 0);
		current_cursor = cursor;
	}
}


/*
 * button_value: encode mouse event into a jovetool event code (the return
 * value) and a button state (stored in last_but).  If the event ought to be
 * ignored due to error, -1 is returned in place of the event code. If it is
 * to be ignored silently, -2 is returned.
 */
private int
                last_but = JT_UPEVENT,	/* button state */
                event_shift;	/* shift state */
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
	case LOC_MOVEWHILEBUTDOWN:
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
		if ((last_but & JT_UPEVENT) != 0
		    || ((last_but ^ this_but) & JT_BUTMASK) != 0)
			return -1;
		this_but |= JT_UPEVENT;
		mouse_code += JTEC_UP;
	} else if (event_is_down(event)) {
		if ((last_but & (JT_UPEVENT | JT_RIGHT)) == 0) {
			/* down event not preceded by an up event */
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
	 * down event it was waiting for.  Thus jove should always see a
	 * consistent picture. ??? Good theory.  How is this implemented? --
	 * DHR
	 */

	/*
	 * Detect and encode multi-clicks.
	 *
	 * - a multiclick is a train of alternating mouse-down and mouse-up
	 * events - the first must be a mouse-down - Each mouse up and down
	 * must be of the same button - each of which happens within CLICK
	 * milliseconds of its predecessor - Drags are not taken into
	 * consideration.
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
 * eventcode (explained in mousemsg.h) - button-state is as described in
 * mousemsg.h for this_but - x-col is horizontal column, in pixels (for
 * smooth scrollbar working) - y-col is height, in characters - font-width
 * allows conversion of x-col to characters Sun function keys (left, top, and
 * right) are converted to the ANSI sequence ESC [ P z, where P is a number
 * above 192
 */

private Notify_value
input_event_filter_function(window, event, arg, type)
	Window          window;
	Event          *event;
	Notify_arg      arg;
	Notify_event_type type;
{
#ifdef WANT_CAPS_LOCK
	static int      caps_lock = 0;	/* toggle indicater for f-key T1 caps
					 * lock */
#endif
	int             id = event_id(event);
	int             mouse_code = -3;	/* not -1 and not -2 and not
						 * >=0 */
	int             fkey;

	event_shift &= ~JT_CSMASK;
	if (event_shift_is_down(event))
		event_shift |= JT_SHIFT;
	if (event_ctrl_is_down(event))
		event_shift |= JT_CONTROL;
	if (event_action(event) == ACTION_PASTE || event_action(event) == ACTION_CUT) {
		if (event_is_up(event))
			event_shift &= ~(event_action(event) == ACTION_PASTE ?
					 JT_PASTE : JT_CUT);
		else
			event_shift |= (event_action(event) == ACTION_PASTE ?
					JT_PASTE : JT_CUT);
	}
	if (console != NULL) {
		fprintf(console, "Event %d", id);
		if (event_shift != 0)
			fprintf(console, "; shift %d", event_shift);
		if (event_is_up(event))
			fprintf(console, "; up");
		if (event_is_button(event))
			fprintf(console, "; button %d", id - BUT(0));
		fprintf(console, "\n");
	}
	switch (id) {
	case LOC_MOVEWHILEBUTDOWN:
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
	case KEY_LEFT(5):	/* EXPOSE key */
	case KEY_LEFT(7):	/* OPEN key */
		/*
		 * UP L5 & L7 is Expose & Open, let them pass to SunView. ???
		 * Apparently it only cares about up events.
		 */
		return event_is_up(event)
			? notify_next_event_func(window, event, arg, type)
			: NOTIFY_IGNORED;
	}

	/*
	 * Treat shifted events as normal Shelltool events. This includes
	 * shifted characters which is a bit naughty (xjove must deal with
	 * them separately because it needs to clear the shiftmask for
	 * non-characters).
	 */
	if (event_shift == JT_SHIFT) {
		/*
		 * NOTE: at least under SunOS4.0.3, the shelltool routine
		 * turns off LOC_MOVEWHILEBUTDOWN, so we must restore it.
		 */
		Notify_value    result = notify_next_event_func(window, event, arg, type);

		window_set(ttysw, WIN_CONSUME_PICK_EVENT, LOC_MOVEWHILEBUTDOWN, 0);
		return result;
	}
	/* do Mouse Button events */

	if (mouse_code >= 0) {
		int
		                this_x = event_x(event), this_y = event_y(event) / font_height;
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
				if (id == LOC_MOVEWHILEBUTDOWN)
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
	/* process event if it was a function key stroke */

	fkey = 0;

	/* In JoveTool, WIN_STOP is handled separately, as a synonym for L1. */
	if (id == WIN_STOP)
		fkey = 192;
	else if (event_is_key_left(event))
		fkey = id - KEY_LEFT(1) + 192;
	else if (event_is_key_right(event))
		fkey = id - KEY_RIGHT(1) + 208;
	else if (event_is_key_top(event))
		fkey = id - KEY_TOP(1) + 224;

	if (fkey != 0) {
		if (event_is_down(event) || id == WIN_STOP)
			sprintf(last_event_string, "%s%dz", key_prefix, fkey);
		/* test should be !event_button_is_down(event) */
		if (last_but & JT_UPEVENT) {
			/*
			 * we don't want any function keys (esp PASTE & CUT)
			 * seen when a button is down
			 */
			if (event_action(event) == ACTION_PASTE
			    || event_action(event) == ACTION_CUT
			    || id == WIN_STOP) {
				if (event_is_down(event)) {
					/*
					 * we see PASTE and CUT and WIN_STOP
					 * when they come up
					 */
					return NOTIFY_IGNORED;
				}
			} else if (event_is_up(event)) {
				/* we see other F-keys when they go down */
				return NOTIFY_IGNORED;
			}
#ifdef WANT_CAPS_LOCK
			/*
			 * set a toggle and relabel window so T1 can act like
			 * caps-lock
			 */
			if (id == KEY_TOP(1)) {
				/* make a frame label with and without CAPS */
				static const char Caps[] = "[CAPS] ";
				char           *p = (char *) window_get(frame, FRAME_LABEL);

				strcpy(buffer, Caps);
				strncpy(buffer + sizeof(Caps) - 1,
					strncmp(p, Caps, sizeof(Caps) - 1) == 0 ? p + sizeof(Caps) - 1 : p,
					BUFFERSIZE - (sizeof(Caps)));
				buffer[BUFFER_SIZE - 1] = '\0';
				caps_lock = !caps_lock;
				window_set(frame, FRAME_LABEL,
					   buffer + (caps_lock ? 0 : sizeof(Caps) - 1), 0);
				return NOTIFY_IGNORED;
			}
#endif
			ttysw_input(ttysw, last_event_string, strlen(last_event_string));
		}
		return NOTIFY_IGNORED;
	}
	/* Discard key-up ascii or meta events */
	/*
	 * ??? is this needed?  Will the someone down the line not do this?
	 * We aren't even catching ascii up-events.
	 */
	if ((event_is_ascii(event) || event_is_meta(event))
	    && event_is_up(event))
		return NOTIFY_IGNORED;

#ifdef WANT_CAPS_LOCK
	/* shift alpha chars to upper case if capslock is set */
	if (caps_lock && event_is_ascii(event) && isupper(id))
		event_set_id(event, tolower(id));
#endif

	if (event_is_ascii(event)) {
		/*
		 * Force bit 8 if meta key is down. But it will only be
		 * noticed by the controlled process if it does a stty
		 * -istrip, or equivalent.
		 */
		if (event_shiftmask(event) & META_SHIFT_MASK)
			event->ie_code |= META_FIRST;	/* ??? META_KEY_MASK not
							 * in SunView */
	}
	/* If we get here, pass event off to next handler */
	return notify_next_event_func(window, event, arg, type);
}


extern char    *getenv proto((const char *));	/* fudge -- must be in some
						 * header */

int
main(argc, argv)
	int             argc;
	char          **argv;
{
	int             error_code;	/* Error codes */
	int             forking;
	char           *debug;

	if ((debug = getenv("DEBUGJOVETOOL")) != NULL) {
		/*
		 * DEBUGJOVETOOL specifies the file or device to receive
		 * debugging output, if any.  The null name signifies stderr.
		 */
		console = *debug == '\0' ? stderr : fopen(debug, "w");
		forking = 0;
	} else {
		forking = isatty(0);
	}

	if (argc>1 && (!strcmp("-f", argv[1]) || !strcmp("-nf", argv[1]))) {
		char	**p = &argv[1];

		forking = strcmp("-f", *p) == 0;
		do ; while ((p[0] = p[1]) != NULL);
	}

	if (forking) {
		switch (fork()) {
		case -1:
			fprintf(stderr, "fork failed");
			exit(1);
			/* NOTREACHED */
		case 0:	/* the child */
			setpgrp(0, 0);	/* so it doesn't get killed when
					 * parent dies */
			break;
		default:	/* the parent */
			exit(0);
			/* NOTREACHED */
		}
	}

	putenv("IN_JOVETOOL=t");/* notify subprocess that it is in jovetool */
	putenv("TERMCAP=");
	putenv("TERM=sun");	/* the TTYSW will be a sun terminal to
				 * override these, try % jovetool -rc script */
	if ((argv[0] = getenv("JOVETOOL")) == NULL)	/* Set jove command name */
		argv[0] = jove_name;
	for (argc = 1; argv[argc]; argc++)	/* Use last one on line */
		if (!(strcmp("-rc", argv[argc]))) {	/* Override if -rc given */
			int             i = argc;
			argv[argc--] = 0;	/* kill the -rc argument */
			if (argv[i + 1]) {	/* move to argv[0] and
						 * squeeze the rest */
				argv[0] = argv[i + 1];
				for (; argv[i + 2]; (argv[i] = argv[i + 2], argv[++i] = 0));
			}
		}
	frame_icon = icon_create(ICON_LABEL, argv[0],
				 ICON_IMAGE, &icon_image,
				 0);


	strcpy(buffer, title);
	strncat(buffer, argv[0],/* append run command name */
		(BUFFER_SIZE - (strlen(buffer)) - (strlen(argv[0]))) - 1);

	/* Build a frame to run in */
	frame = window_create((Window) NULL, FRAME,
			      FRAME_LABEL, buffer,
			      FRAME_ICON, frame_icon,
			      FRAME_ARGC_PTR_ARGV, &argc, argv,
			      0);

	/* Create a tty with jove in it */
	ttysw = window_create(frame, TTY,
			      TTY_QUIT_ON_CHILD_DEATH, TRUE,
	/* TTY_BOLDSTYLE, 4, */
			      TTY_ARGV, argv,
			      0);

	window_set(ttysw,
		   WIN_CONSUME_PICK_EVENTS,
		   WIN_STOP,
		   WIN_MOUSE_BUTTONS, WIN_UP_EVENTS,
	/* LOC_WINENTER, LOC_WINEXIT, LOC_MOVE, */
		   LOC_MOVEWHILEBUTDOWN,
		   0,

		   WIN_CONSUME_KBD_EVENTS,
		   WIN_STOP, SHIFT_LEFT, SHIFT_RIGHT, SHIFT_CTRL,
		   WIN_ASCII_EVENTS,
		   WIN_LEFT_KEYS, WIN_TOP_KEYS, WIN_RIGHT_KEYS,
	/* WIN_UP_ASCII_EVENTS, */
		   0,

		   0);

	default_cursor = window_get(ttysw, WIN_CURSOR);
	jove_cursor = cursor_create(
				    CURSOR_IMAGE, &cursor_pix,
				    CURSOR_XHOT, 8,
				    CURSOR_YHOT, 8,
				    0);
	cut_cursor = cursor_create(
				   CURSOR_IMAGE, &cut_pix,
				   CURSOR_XHOT, 8,
				   CURSOR_YHOT, 8,
				   0);
	copy_cursor = cursor_create(
				    CURSOR_IMAGE, &copy_pix,
				    CURSOR_XHOT, 8,
				    CURSOR_YHOT, 8,
				    0);
	paste_cursor = cursor_create(
				     CURSOR_IMAGE, &paste_pix,
				     CURSOR_XHOT, 8,
				     CURSOR_YHOT, 8,
				     0);
	set_cursor(jove_cursor);

	font_height = (int) window_get(ttysw, WIN_ROW_HEIGHT);
	font_width = (int) window_get(ttysw, WIN_COLUMN_WIDTH);

	/* Interpose my event function */
	error_code = (int) notify_interpose_event_func
		(ttysw, input_event_filter_function, NOTIFY_SAFE);

	if (error_code != 0) {	/* Barf */
		fprintf(stderr, "notify_interpose_event_func got %d.\n", error_code);
		exit(1);
	}
	menu_init();
	window_main_loop(frame);/* And away we go */
	exit(0);		/* if this is ever reached */
	/* NOTREACHED */
}
