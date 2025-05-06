/* menu.h */

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

/* The following structure defines a menu item.  It will be displayed
 * to the user as the _key_ followed by the _item_.  If an item's _key_
 * is pressed, the _func_ for that item is called with one argument:
 * the _key_ pressed.
 */
typedef struct {
    char *item;		/* item string, ie: "add a user" */
    void (*func)();	/* function to call */
    ychar key;		/* activating keypress, ie: "a" */
} menu_item;

extern menu_item *menu_ptr;	/* if non-NULL, current menu in processing */

/* global functions */

extern void	kill_menu	();				/* menu.c */
extern void	update_menu	();				/* menu.c */
extern int	show_menu	( /* menuptr, len */ );		/* menu.c */
extern int	show_text	( /* prompt, func */ );		/* menu.c */
extern int	show_mesg	();				/* menu.c */
extern int	show_main_menu	();				/* menu.c */
extern int	show_option_menu();				/* menu.c */
extern int	show_user_menu	( /* title, func */ );		/* menu.c */
extern int	show_error_menu	( /* str1, str2 */ );		/* menu.c */
extern int	yes_no		( /* prompt */ );		/* menu.c */
extern void	update_user_menu();				/* menu.c */

/* EOF */
