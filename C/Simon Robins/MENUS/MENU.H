/*	$Id: MENU.H,v 1.23 1994/06/12 22:00:00 SCR Exp SCR $ */

#ifndef ME_INQUIRE
#define ME_INQUIRE	(0)
#define ME_ATTACH	(1)
#define ME_REMOVE	(2)

typedef struct _menu {
	OBJECT *mn_tree;	/* the object tree of the menu			*/
	short mn_menu;		/* the parent object of the menu items	*/
	short mn_item;		/* the menu item for alignment			*/
	short mn_scroll;	/* the scroll field status of the menu	*/
	short mn_keystate;	/* CTRL, ALT, SHIFT						*/
} MENU;

#define SUBMENU	(0x0800)

int menu_attach(int flag, OBJECT *tree, int item, MENU *data);
int menu_istart(int flag, OBJECT *tree, int imenu, int item);
int menu_popup(MENU *menu, int xpos, int ypos, MENU *data);
#endif
