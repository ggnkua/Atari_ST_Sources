/* menu.h: Definitions relating to menus
 * phil comeau 30-jan-88
 * last edited 16-jul-89 0002
 *
 * Copyright 1990 Antic Publishing Inc.
 */

/* Menu Actions */
#define SELMNUITM 0			/* Make the menu item selectable */
#define DESELMNUITM 1			/* Prevent the menu item from being
					 * selected.
					 */
#define RESTOREMNU 2			/* Restore a menu's title to normal
					 * video after one of its items
					 * was selected.
					 */
#define CHKMNUITM 3			/* Place a checkmark beside a menu
					 * item.
					 */
#define UNCHKMNUITM 4			/* Remove a checkmark from a menu
					 * item.
					 */

/* Type definitions. */

/* MNUACT: Menu action table entry. Defines action to be performed when
 * specified menu event occurs.
 */
typedef struct {
	int action;			/* action applied to menu entry. */
	int menu;			/* menu or menu item id to which
					 * action will be applied.
					 */
} MNUACT;

/* MNUFUNC:	Used to map menu items to their associated functions. */
typedef struct {
	int menu;			/* menu object index */
	int menuItm;			/* menu item object index */
	BOOLEAN enabled;		/* TRUE if menu item enabled. */
	int (*menuFunc)();		/* function associated with item */
	MNUACT *menuAct;		/* menu action table invokes after
					 * function called
					 */
} MNUFUNC;
