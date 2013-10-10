   /* external function declarations for rcs2 */
/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#ifndef RCSMENU_H

#define RCSMENU_H

EXTERN	WORD	in_bar(LONG tree, WORD obj);
EXTERN	WORD	in_menu(LONG tree, WORD obj);
EXTERN	WORD	is_menu(LONG tree, WORD obj);
EXTERN  WORD	in_which_menu(LONG tree, WORD obj);
EXTERN	WORD	menu_n(LONG tree, WORD n);
EXTERN	WORD	bar_n(LONG tree, WORD n);
EXTERN	WORD	get_active(LONG tree);
EXTERN	WORD	blank_menu(LONG tree, WORD sobj);
EXTERN	VOID	fix_menu_bar(LONG tree);
EXTERN	WORD	menu_ok(LONG tree, WORD obj);
EXTERN	VOID	desk_menufix(LONG tree);
EXTERN	VOID	undo_menufix(LONG tree);

#endif
