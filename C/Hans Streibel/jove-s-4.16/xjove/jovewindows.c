/***************************************************************************
 * This program is Copyright (C) 1991-1996 by C.H.Lindsey, University of   *
 * Manchester.  (X)JOVETOOL is provided to you without charge, and with no *
 * warranty.  You may give away copies of (X)JOVETOOL, including sources,  *
 * provided that this notice is included in all the files, except insofar  *
 * as a more specific copyright notices attaches to the file (x)jovetool.c *
 ***************************************************************************/

#include <suntool/sunview.h>
#include <suntool/tty.h>
#include <stdio.h>
#include <string.h>
#include "exts.h"
#include "jovewindows.h"

private char command_prefix[] = "\033X";	/* ESC-X */
#define command_prefix_length	(sizeof(command_prefix) - 1)

Menu	main_menu;

private Menu
	file_menu,
	mode_menu,
	help_menu,
	move_menu,
	bind_menu,
	macro_menu,
	buffer_menu,
	window_menu,
	mark_menu,
	edit_menu,
	directory_menu,
	compile_menu,
	format_menu,
	search_menu,
	process_menu,
	abbrev_menu,
	misc_menu,
	variables_menu,
	another_help_menu,
	commands_menu,
	var_files_menu,
	var_modes_menu,
	var_move_menu,
	var_search_menu,
	var_process_menu,
	var_compile_menu,
	var_format_menu,
	var_misc_menu,
	var_abbrev_menu,
	empty_menu,
	on_off_menu;

private Menu_item	empty_menu_item;

private int
	describing,
	printing;

private caddr_t
print_client_data(m, mi)
	Menu		m;
	Menu_item	mi;
{	char	*menu_string;

	menu_string = (char *)menu_get(mi, MENU_CLIENT_DATA);
	ttysw_input(ttysw, menu_string, strlen(menu_string));
	/* ??? What value ought to be returned?  This is a guess -- DHR */
	return menu_get(mi, MENU_VALUE);
}

private caddr_t
main_notify(m, mi)
	Menu		m;
	Menu_item	mi;
{
	ttysw_input (ttysw, command_prefix, command_prefix_length);
	print_client_data(m, mi);
	ttysw_input (ttysw, "\n", 1);
	/* ??? What value ought to be returned?  This is a guess -- DHR */
	return NULL;
}

private caddr_t
sp_printit(m, mi)
	Menu		m;
	Menu_item	mi;
{	char	*menu_string;

	menu_string = (char *)menu_get(mi, MENU_CLIENT_DATA);
	if (mi != empty_menu_item)
		ttysw_input(ttysw, " ", 1);
	ttysw_input(ttysw, menu_string, strlen(menu_string));
	/* ??? What value ought to be returned?  This is a guess -- DHR */
	return menu_get(mi, MENU_VALUE);
}

private Menu_item
commands_proc(item, operation)
	Menu_item	item;
	Menu_generate	operation;
{
	return commands_menu;
}

#ifdef	NEVER	/* ??? seems to be unused */
Menu_item
var_proc(item, operation, menu)
	Menu_item	item;
	Menu_generate	operation;
	Menu		menu;
{
	switch (operation) {
	    case MENU_DISPLAY:
		if (!describing)
			menu_set(item, MENU_PULLRIGHT, menu, 0);
		break;
	    case MENU_DISPLAY_DONE:
		menu_set(item, MENU_PULLRIGHT, 0, 0);
		break;
	    case MENU_NOTIFY:
		break;
	    case MENU_NOTIFY_DONE:
		break;
	}
	return item;
}
#endif

private Menu_item
on_off_proc(item, operation)
	Menu_item	item;
	Menu_generate	operation;
{
	switch (operation) {
	    case MENU_DISPLAY:
		if (!describing & !printing) {
			menu_set(item, MENU_PULLRIGHT, on_off_menu, 0);
		} else {
			menu_set(item, MENU_PULLRIGHT, 0, 0);
		}
		break;
	    case MENU_DISPLAY_DONE:
	    case MENU_NOTIFY:
	    case MENU_NOTIFY_DONE:
		break;
	}
	return item;
}

private Menu
do_set_proc(mi, operation, menu)
	Menu_item	mi;
	Menu_generate	operation;
	Menu		menu;
{
	static Menu displayed;

	if (!describing) {
		switch (operation) {
			case MENU_DISPLAY:
				if (!strcmp(menu_get(mi, MENU_CLIENT_DATA), "print"))
					printing = 1;
				displayed = menu;
				menu_set(menu, MENU_SELECTED, 0, 0);
				break;
			case MENU_DISPLAY_DONE:
				printing = 0;
				break;
			case MENU_NOTIFY:
			case MENU_NOTIFY_DONE:
				if (!(displayed == menu) || !menu_get(menu, MENU_SELECTED)) {
					displayed = NULL;
					return empty_menu;
				}
				displayed = NULL;
				break;
		}
		return menu;
	} else return empty_menu;
}

private Menu
do_describing_proc(m, operation)
	Menu		m;
	Menu_generate	operation;
{
	switch (operation) {
	    case MENU_DISPLAY:
		describing = 1;
		break;
	    case MENU_DISPLAY_DONE:
		describing = 0;
		break;
	    case MENU_NOTIFY:
		describing = 1;
		break;
	    case MENU_NOTIFY_DONE:
		describing = 0;
		break;
	}
	return m;
}

#include "jovemenu.c"
