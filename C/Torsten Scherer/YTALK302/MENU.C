/* menu.c */

/*			   NOTICE
 *
 * Copyright (c) 1990,1992,1993 Britt Yenne.  All rights reserved.
 * 
 * This software is provided AS-IS.  The author gives no warranty,
 * real or assumed, and takes no responsibility whatsoever for any 
 * use or misuse of this software, or any damage created by its use
 * or misuse.
 * 
 * This software may be freely copied and distributed provided that
 * no part of this NOTICE is deleted or edited in any manner.
 * 
 */

/* Mail comments or questions to ytalk@austin.eds.com */

#include "header.h"
#include <fcntl.h>
#include "menu.h"

/* This particular file was written real early one night (morning?)
 * while trying to stay awake long enough to do laundry.  I hereby take
 * extra-special pains to absolve myself of any and all responsibility
 * for this source.
 */

static void main_menu_sel();
menu_item *menu_ptr = NULL;		/* current menu in processing */
static int menu_len;			/* number of items in current menu */
static int menu_long;			/* longest item of current menu */
static int menu_line;			/* current line number of menu */
static int text_pos = -1;		/* text offset if non-negative */
static int text_ypos = -1, text_xpos = -1; /* text coord if non-negative */

extern void raw_term();			/* our raw interface to the terminal */

/* some menus... */

static menu_item main_menu[] = {
    { "Main Menu",		NULL,		' ' },
    { "",			NULL,		' ' },
    { "add a user",		main_menu_sel,	'a' },
    { "delete a user",		main_menu_sel,	'd' },
    { "options",		main_menu_sel,	'o' },
    { "shell",			main_menu_sel,	's' },
    { "user list",		main_menu_sel,	'u' },
    { "output user to file",	main_menu_sel,	'w' },
    { "quit",			main_menu_sel,	'q' },
    { "",			NULL,		'\0'}	/* MUST BE LAST */
};

#define MAXUMENU 52
static menu_item user_menu[MAXUMENU];	/* this one changes each time */
static menu_item option_menu[20];	/* options menu buffer */
static menu_item yes_no_menu[1];	/* yes/no entry menu */
static menu_item mesg_menu[1];		/* message menu */

static char text_str[MAXTEXT+1];	/* string entry buffer */
static menu_item text_menu[2];		/* string entry menu */
static char user_buf[MAXUMENU][80];	/* user list buffers */

/* major hack below... [maniacal laughter] */

static int got_error = 0;
static char err_str[8][MAXERR];
static menu_item error_menu[] = {
    { "Ytalk Error",		NULL,		' ' },
    { "",			NULL,		' ' },
    { NULL,			show_error,	' ' },
    { NULL,			show_error,	' ' },
    { "",			NULL,		' ' },
    { NULL,			show_error,	' ' },
    { NULL,			show_error,	' ' },
    { "",			NULL,		' ' },
    { NULL,			show_error,	' ' },
    { NULL,			show_error,	' ' },
    { "",			NULL,		' ' },
    { NULL,			show_error,	' ' },
    { NULL,			show_error,	' ' },
    { "",			NULL,		'\0'}	/* MUST BE LAST */
};

/* ---- local functions ---- */

static yuser *output_user = NULL;

static void
do_output(filename)
  char *filename;
{
    int fd;

    if(output_user == NULL)
	return;
    if((fd = open(filename, O_RDWR | O_TRUNC | O_CREAT, 0600)) < 0)
    {
	show_error(filename);
	return;
    }
    output_user->output_fd = fd;
    spew_term(output_user, fd, output_user->rows, output_user->cols);
    output_user = NULL;
}

static void
do_output_user(user)
  yuser *user;
{
    /* if he has an open descriptor, close it */

    if(user->output_fd > 0)
    {
	close(user->output_fd);
	user->output_fd = 0;
	if(show_mesg("Output Terminated", NULL) >= 0)
	    update_menu();
	return;
    }

    /* else open one */

    output_user = user;
    if(show_text("Output filename?", do_output) >= 0)
	update_menu();
    else
	output_user = NULL;
}

static void
do_invite(name)
  char *name;
{
    invite(name, 1);
}

static void
main_menu_sel(key)
  ychar key;
{
    switch(key)
    {
	case 'a':	/* add a user */
	    if(show_text("Add Which User?", do_invite) >= 0)
		update_menu();
	    break;
	case 'd':	/* delete a user */
	    if(show_user_menu("Delete Which User?", free_user) >= 0)
		update_menu();
	    break;
	case 'o':	/* show options */
	    if(show_option_menu() >= 0)
		update_menu();
	    break;
	case 's':	/* invoke a shell */
	    kill_menu();
	    execute(NULL);
	    break;
	case 'u':	/* show a user list */
	    if(show_user_list() >= 0)
		update_menu();
	    break;
	case 'w':	/* output user to file */
	    if(show_user_menu("Output Which User?", do_output_user) >= 0)
		update_menu();
	    break;
	case 'q':	/* quit */
	    bail(0);
    }
}

static void
option_menu_sel(key)
  ychar key;
{
    register yuser *u;
    ylong old_flags;

    old_flags = def_flags;
    switch(key)
    {
	case 'a':	/* toggle asides */
	    def_flags ^= FL_ASIDE;
	    break;
	case 's':	/* toggle scrolling */
	    def_flags ^= FL_SCROLL;
	    break;
	case 'w':	/* toggle word wrap */
	    def_flags ^= FL_WRAP;
	    break;
	case 'i':	/* toggle automatic imports */
	    def_flags ^= FL_IMPORT;
	    break;
	case 'v':	/* toggle automatic invitations */
	    def_flags ^= FL_INVITE;
	    break;
	case 'r':	/* toggle automatic re-rings */
	    def_flags ^= FL_RING;
	    break;
    }

    if(old_flags != def_flags)
    {
	for(u = user_list; u != NULL; u = u->unext)
	    if(!(u->flags & FL_LOCKED))
		u->flags = def_flags;
    }

    if(show_option_menu() >= 0)
	update_menu();
    else
	kill_menu();
}

static void
user_menu_sel(key)
  ychar key;
{
    register int i;
    register yuser *u;

    /* Remember... the user list could have changed between the time
     * I created the user menu and the time I just now selected one
     * of the users from it.
     */
    for(i = 0; i < menu_len; i++)
	if(user_menu[i].key == key)
	{
	    for(u = user_list; u; u = u->unext)
		if(u->key == key
		&& strcmp(u->full_name, user_menu[i].item) == 0)
		{
		    user_menu[0].func(u);
		    break;
		}
	    break;
	}
    if(menu_ptr == user_menu)
	kill_menu();
}

#define MENU_EXTRA 7	/* number of extra characters per menu screen item */

static void
generate_text_length()
{
    menu_long = me->t_cols - MENU_EXTRA - 2;
    if(menu_long < 5 || menu_long > MAXTEXT)
	menu_long = MAXTEXT;
}

static void
generate_yes_no_length()
{
    menu_long = strlen(yes_no_menu[0].item) - 2;
}

static void
pad_str(from, len, to)
  char *from, *to;
  int len;
{
    for(; len > 0 && *from; len--, from++)
	*(to++) = *from;
    for(; len > 0; len--)
	*(to++) = ' ';
    *to = '\0';
}

/* ---- global functions ---- */

/* End any menu processing.
 */
void
kill_menu()
{
    register int i;

    if(menu_ptr != NULL)
    {
	menu_ptr = NULL;
	redraw_term(me, 0);
	flush_term(me);
	text_pos = -1;
	text_ypos = -1;
	text_xpos = -1;
    }
    if(got_error)
    {
	got_error = 0;
	for(i = 0; error_menu[i].key != '\0'; i++)
	    if(error_menu[i].func != NULL)
		error_menu[i].item = NULL;
    }
}

/* Update menu information.
 */
void
update_menu()
{
    register ychar *c;
    register char *d;
    register int j, i, y, x;
    static ychar *buf = NULL;
    static int buflen = 0;

    if(menu_ptr == NULL)
	return;
    
    /* process any input */

    if(io_len > 0)
    {
	ychar ic;

	if(menu_ptr == text_menu)
	{
	    for(; io_len > 0; io_len--)
	    {
		ic = *(io_ptr++);

		if(ic > ' ' && ic <= '~')
		{
		    if(text_pos >= menu_long)
			putc(7, stderr);
		    else
		    {
			text_str[text_pos] = (char)ic;
			if(text_ypos >= 0)
			    raw_term(me, text_ypos, text_xpos + text_pos,
				text_str + text_pos, 1);
			text_str[++text_pos] = '\0';
		    }
		}
		else if(ic == me->old_rub)
		{
		    if(text_pos > 0)
		    {
			text_str[--text_pos] = '\0';
			if(text_ypos >= 0)
			    raw_term(me, text_ypos, text_xpos + text_pos,
				" ", 1);
		    }
		}
		else if(ic == me->KILL || ic == me->WORD)
		{
		    if(text_pos > 0)
		    {
			text_str[0] = '\0';
			text_pos = 0;
			if(text_ypos > 0)
			    raw_term(me, text_ypos, text_xpos,
				"     ", menu_long);
		    }
		}
		else if(ic == '\n' || ic == '\r')
		{
		    if(text_pos > 0)
		    {
			text_str[text_pos] = '\0';	/* just to be sure */
			kill_menu();
			text_menu[0].func(text_str);
		    }
		    else
			kill_menu();
		    return;
		}
		else if(ic == 27 || ic == 4)
		{
		    kill_menu();
		    return;
		}
	    }
	    if(text_ypos >= 0)
	    {
		raw_term(me, text_ypos, text_xpos + text_pos, NULL, 0);
		flush_term(me);
		return;
	    }
	}
	else if(menu_ptr == yes_no_menu)
	{
	    /* don't handle yes/no input here */
	}
	else if(menu_ptr == mesg_menu)
	{
	    ic = *(io_ptr++);
	    io_len--;
	    kill_menu();
	    if(mesg_menu[0].func)
		mesg_menu[0].func(ic);
	    return;
	}
	else
	{
	    ic = *(io_ptr++);
	    io_len--;
	    if(ic == ' ' || ic == '\n' || ic == '\r')
	    {
		/* scroll the menu */

		menu_line += me->t_rows - 1;
		if(menu_line >= menu_len)
		{
		    kill_menu();
		    return;
		}
		i = menu_len - (me->t_rows - 1);	/* last full screen */
		if(i < menu_line)
		    menu_line = i;
	    }
	    else if(ic > ' ' && ic <= '~')
	    {
		for(i = 0; i < menu_len; i++)
		    if(menu_ptr[i].key == ic && menu_ptr[i].func != NULL)
		    {
			menu_ptr[i].func(ic);
			/*
			 * THE WHOLE WORLD COULD BE DIFFERENT NOW.
			 */
			i = -1;
			break;
		    }
		if(i >= 0)
		    kill_menu();
		return;
	    }
	    else
	    {
		kill_menu();
		return;
	    }
	}
    }

    /* Check the buffer.  Keep in mind that we could be here because
     * the window size has changed.
     */

    if(menu_ptr == text_menu)
    {
	generate_text_length();
	text_ypos = -1;		/* assume it's not displayed */
	text_xpos = -1;
    }
    else if(menu_ptr == yes_no_menu)
    {
	menu_len = 1;
	menu_line = 0;
	generate_yes_no_length();
    }
    if(menu_long > buflen)
    {
	buflen = menu_long + 64;
	buf = (ychar *)realloc_mem(buf, buflen + MENU_EXTRA);
    }

    /* get starting X and Y coord */

    x = center(me->t_cols, menu_long + MENU_EXTRA);
    if(menu_line == 0)
    {
	if(menu_len + 2 <= me->t_rows)
	{
	    y = center(me->t_rows, menu_len + 2);
	    raw_term(me, y++, x, "#####", menu_long + MENU_EXTRA);
	}
	else
	    y = 0;
    }
    else
	y = 0;

    /* show as many menu lines as we can */

    for(i = menu_line; y+1 < me->t_rows && i < menu_len; i++, y++)
    {
	c = buf;
	*(c++) = '#';
	*(c++) = ' ';
	if(menu_ptr[i].key == ' ')
	{
	    j = 0;
	    if(menu_ptr == text_menu)
	    {
		if(i > 0)
		{
		    *(c++) = '>';
		    *(c++) = ' ';
		    j += 2;
		    text_ypos = y;
		    text_xpos = x + j + 2;
		}
	    }
	    else if(menu_ptr != yes_no_menu)
	    {
		int temp;
		temp = center(menu_long + 3, strlen(menu_ptr[i].item));
		for(; j < temp; j++)
		    *(c++) = ' ';
	    }
	    for(d = menu_ptr[i].item; *d; d++, j++)
		*(c++) = (ychar)*d;
	    for(; j < menu_long + 3; j++)
		*(c++) = ' ';
	}
	else
	{
	    *(c++) = menu_ptr[i].key;
	    *(c++) = ':';
	    *(c++) = ' ';
	    for(d = menu_ptr[i].item, j = 0; *d; d++, j++)
		*(c++) = (ychar)*d;
	    for(; j < menu_long; j++)
		*(c++) = ' ';
	}
	*(c++) = ' ';
	*(c++) = '#';
	raw_term(me, y, x, buf, c - buf);
    }
    if(y < me->t_rows)
    {
	if(i < menu_len)
	{
	    c = buf;
	    *(c++) = '#';
	    *(c++) = ' ';
	    *(c++) = ' ';
	    *(c++) = ' ';
	    *(c++) = ' ';
	    for(d = "(more)", j = 0; *d; d++, j++)
		*(c++) = (ychar)*d;
	    for(; j < menu_long; j++)
		*(c++) = ' ';
	    *(c++) = ' ';
	    *(c++) = '#';
	    raw_term(me, y, x, buf, c - buf);
	    raw_term(me, y, x + 12, NULL, 0);
	}
	else
	{
	    raw_term(me, y, x, "#####", menu_long + MENU_EXTRA);
	    if(menu_ptr == text_menu)
		raw_term(me, text_ypos, text_xpos + text_pos, NULL, 0);
	    else if(menu_ptr == yes_no_menu)
		raw_term(me, y-1, x + menu_long + MENU_EXTRA - 2, NULL, 0);
	    else
		raw_term(me, y, me->t_cols / 2, NULL, 0);
	}
    }
    flush_term(me);
}

/* Show a menu, overriding any existing menu.
 */
int
show_menu(menu, len)
  menu_item *menu;
  int len;
{
    register int i, j;

    if(me->t_rows < 2)
    {
	show_error("show_menu: window too small");
	return -1;
    }

    /* scan the menu for problems */

    menu_long = 0;
    for(i = 0; i < len; i++)
    {
	if((j = strlen(menu[i].item)) > menu_long)
	    menu_long = j;
	if(menu[i].key < ' ' || menu[i].key >= '~')
	{
	    show_error("show_menu: invalid key");
	    return -1;
	}
    }
    if(menu_long <= 0)
    {
	show_error("show_menu: menu too small");
	return -1;
    }
    if(menu_long < 10)
	menu_long = 10;
    
    /* set up the menu for display */

    menu_ptr = menu;
    menu_len = len;
    menu_line = 0;
    
    return 0;
}

/* Show a text entry menu, overriding any existing menu.
 */
int
show_text(prompt, func)
  char *prompt;
  void (*func)();
{
    if(me->t_rows < 3)
    {
	show_error("show_text: window too small");
	return -1;
    }

    /* set up the menu for display */

    text_menu[0].item = prompt;
    text_menu[0].func = func;
    text_menu[0].key = ' ';

    text_str[0] = '\0';
    text_menu[1].item = text_str;
    text_menu[1].func = NULL;
    text_menu[1].key = ' ';

    menu_ptr = text_menu;
    menu_len = 2;
    menu_line = 0;
    text_ypos = -1;
    text_xpos = -1;
    text_pos = 0;
    generate_text_length();
    
    return 0;
}

/* Show a message in a menu.
 */
int
show_mesg(mesg, func)
  char *mesg;
  void (*func)();
{
    /* set up the menu for display */

    mesg_menu[0].item = mesg;
    mesg_menu[0].func = func;
    mesg_menu[0].key = ' ';

    return show_menu(mesg_menu, 1);
}

int
show_main_menu()
{
    static int main_items = 0;

    if(main_items == 0)
    {
	while(main_menu[main_items].key != '\0')
	    main_items++;
    }
    return show_menu(main_menu, main_items);
}

int
show_option_menu()
{
    register int i = 0;

    option_menu[i].item = "Options Menu";
    option_menu[i].func = NULL;
    option_menu[i].key = ' ';
    i++;

    option_menu[i].item = "";
    option_menu[i].func = NULL;
    option_menu[i].key = ' ';
    i++;

    if(def_flags & FL_SCROLL)
	option_menu[i].item = "turn scrolling off";
    else
	option_menu[i].item = "turn scrolling on";
    option_menu[i].func = option_menu_sel;
    option_menu[i].key = 's';
    i++;

    if(def_flags & FL_WRAP)
	option_menu[i].item = "turn word-wrap off";
    else
	option_menu[i].item = "turn word-wrap on";
    option_menu[i].func = option_menu_sel;
    option_menu[i].key = 'w';
    i++;

    if(def_flags & FL_IMPORT)
	option_menu[i].item = "turn auto-import off";
    else
	option_menu[i].item = "turn auto-import on";
    option_menu[i].func = option_menu_sel;
    option_menu[i].key = 'i';
    i++;

    if(def_flags & FL_INVITE)
	option_menu[i].item = "turn auto-invite off";
    else
	option_menu[i].item = "turn auto-invite on";
    option_menu[i].func = option_menu_sel;
    option_menu[i].key = 'v';
    i++;

    if(def_flags & FL_RING)
	option_menu[i].item = "turn auto-rering off";
    else
	option_menu[i].item = "turn auto-rering on";
    option_menu[i].func = option_menu_sel;
    option_menu[i].key = 'r';
    i++;

    if(term_does_asides())
    {
	if(def_flags & FL_ASIDE)
	    option_menu[i].item = "turn asides off";
	else
	    option_menu[i].item = "turn asides on";
	option_menu[i].func = option_menu_sel;
	option_menu[i].key = 'a';
	i++;
    }

    return show_menu(option_menu, i);
}

int
show_user_menu(title, func)
  char *title;
  void (*func)();
{
    register int i;
    register yuser *u;

    user_menu[0].item = title;
    user_menu[0].func = func;
    user_menu[0].key = ' ';

    user_menu[1].item = "";
    user_menu[1].func = NULL;
    user_menu[1].key = ' ';

    for(i = 2, u = user_list; u != NULL && i < MAXUMENU; u = u->unext)
	if(u != me)
	{
	    if(u->key != '\0')
	    {
		strcpy(user_buf[i], u->full_name);
		user_menu[i].item = user_buf[i];
		user_menu[i].func = user_menu_sel;
		user_menu[i].key = u->key;
		i++;
	    }
	}
    
    if(i > 2)
	return show_menu(user_menu, i);
    kill_menu();
    return -1;
}

int
show_user_list()
{
    register int i;
    register yuser *u;
    static char name_buf[25], stat_buf[25];

    i = 0;

    user_menu[i].item = "User List";
    user_menu[i].func = NULL;
    user_menu[i].key = ' ';
    i++;

    user_menu[i].item = "Name            Winsize [My_Size] Software       ";
    user_menu[i].func = NULL;
    user_menu[i].key = ' ';
    i++;

    user_menu[i].item = "";
    user_menu[i].func = NULL;
    user_menu[i].key = ' ';
    i++;

    for(u = connect_list; u && i < MAXUMENU; u = u->next)
	if(u != me)
	{
	    if(u->remote.vmajor > 2)
		sprintf(stat_buf, "YTalk V%d.%d",
		    u->remote.vmajor, u->remote.vminor);
	    else if(u->remote.vmajor == 2)
		sprintf(stat_buf, "YTalk V2.?");
	    else
		sprintf(stat_buf, "UNIX Talk");
	    pad_str(u->full_name, 15, name_buf);
	    pad_str(stat_buf, 15, stat_buf);
	    sprintf(user_buf[i], "%s %3.3dx%3.3d [%3.3dx%3.3d] %s",
		name_buf,
		u->remote.cols, u->remote.rows,
		u->remote.my_cols, u->remote.my_rows,
		stat_buf);

	    user_menu[i].item = user_buf[i];
	    user_menu[i].func = NULL;
	    user_menu[i].key = ' ';
	    i++;
	}

    for(u = wait_list; u && i < MAXUMENU; u = u->next)
    {
	pad_str(u->full_name, 15, name_buf);
	pad_str("<unconnected>", 15, stat_buf);
	sprintf(user_buf[i], "%s                   %s",
	    name_buf,
	    stat_buf);

	user_menu[i].item = user_buf[i];
	user_menu[i].func = NULL;
	user_menu[i].key = ' ';
	i++;
    }
    
    return show_menu(user_menu, i);
}

int
show_error_menu(str1, str2)
  char *str1, *str2;
{
    register int i;

    for(i = 0; error_menu[i].key != '\0'; i++)
	if(error_menu[i].item == NULL)
	{
	    strncpy(err_str[got_error], str1, MAXERR);
	    err_str[got_error][MAXERR-1] = '\0';
	    error_menu[i++].item = err_str[got_error++];

	    strncpy(err_str[got_error], str2, MAXERR);
	    err_str[got_error][MAXERR-1] = '\0';
	    error_menu[i++].item = err_str[got_error++];

	    return show_menu(error_menu, i);
	}
    return 0;
}

/* Prompt user for yes/no response.  Return the response.  It is
 * necessary for this function to hang until an answer is received.
 */
int
yes_no(prompt)
  char *prompt;
{
    int out = 0;

    yes_no_menu[0].func = NULL;
    yes_no_menu[0].key = ' ';

    /* show the menu and call input_loop() */

    do {
	yes_no_menu[0].item = prompt;
	menu_ptr = yes_no_menu;
	update_menu();
	input_loop();
	if(menu_ptr != yes_no_menu || yes_no_menu[0].item != prompt)
	{
	    /* somebody pre-empted us */
	    kill_menu();
	    io_len = 0;
	}
	for(; io_len > 0; io_len--, io_ptr++)
	{
	    if(*io_ptr == 'y' || *io_ptr == 'Y')
	    {
		out = 'y';
		break;
	    }
	    if(*io_ptr == 'n' || *io_ptr == 'N' || *io_ptr == 27)
	    {
		out = 'n';
		break;
	    }
	}
    } while(out == 0);

    kill_menu();
    io_len = 0;
    return out;
}

void
update_user_menu()
{
    if(menu_ptr == user_menu)
    {
	redraw_term(me, 0);
	if(user_menu[0].func)	/* it's a user menu */
	    (void)show_user_menu(user_menu[0].item, user_menu[0].func);
	else	/* it's a user status list */
	    (void)show_user_list();
	update_menu();
    }
}
