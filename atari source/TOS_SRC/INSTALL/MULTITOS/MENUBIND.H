/* MENUBIND.H
 * ================================================================
 * DESCRIPTION: Bindings for PopUps and Heirarchical SubMenus
 * 03/17/92   cjg - updated for scroll fields
 * 		  - renamed key routines to match AES version.
 * 03/31/92   cjg - redo routines and added new structures
 */

/* STRUCTURES
 * ================================================================
 */
typedef struct _menu
{
   OBJECT *mn_tree;		/* Object tree of the menu */
   WORD   mn_menu;		/* Parent of the menu items*/
   WORD   mn_item;		/* Starting menu item      */
   WORD   mn_scroll;		/* scroll flag for the menu*/
}MENU;


typedef struct _mn_set
{
   LONG   Display;
   LONG   Drag;
   LONG   Delay;
   LONG   Speed;
   WORD   Height;
}MN_SET;



/* PROTOTYPES
 * ================================================================
 */
BOOLEAN menu_popup( MENU *Menu, WORD xpos, WORD ypos, MENU *MData );
BOOLEAN menu_attach( WORD flag, OBJECT *tree, WORD item, MENU *Menu );
WORD    menu_istart( WORD flag, OBJECT *tree, WORD menu, WORD item );
VOID	menu_settings( WORD flag, MN_SET *Values );

VOID    InitMenus( VOID );	
VOID 	FreeMenus( VOID );
BOOLEAN	mn_hdo( OBJECT *tree, WORD *ptitle, MENU *pmenu );
VOID	mn_bar( OBJECT *tree, WORD showit );
