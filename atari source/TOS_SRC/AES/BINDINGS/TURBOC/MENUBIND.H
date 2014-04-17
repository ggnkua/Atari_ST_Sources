/* Structure for passing menu data */
typedef struct _menu
{
   OBJECT *mn_tree;		/* Object tree of the menu */
   WORD   mn_menu;		/* Parent of the menu items*/
   WORD   mn_item;		/* Starting menu item      */
   WORD   mn_scroll;		/* scroll flag for the menu*/
   WORD   mn_keystate;
}MENU;


/* Structure for the Menu Settings */
typedef struct _mn_set
{
   LONG   Display;		/* The display delay      */
   LONG   Drag;			/* The drag delay         */
   LONG   Delay;		/* The Arrow Delay        */
   LONG   Speed;		/* The scroll speed delay */
   WORD   Height;		/* The menu scroll height */
}MN_SET;


WORD  menu_popup( MENU *Menu, WORD xpos, WORD ypos, MENU *MData );
WORD  menu_attach( WORD flag, OBJECT *tree, WORD item, MENU *Menu );
WORD  menu_istart( WORD flag, OBJECT *tree, WORD menu, WORD item );
WORD  menu_settings( WORD flag, MN_SET *Values );
