/**************************************************************************/
/**************************************************************************/
/*
**                      menu library
*/
/**************************************************************************/
/**************************************************************************/
 
#include "define.h"
 
extern OBJECT *allocate();
extern WORD handle;
extern WORD gl_hchar,gl_wchar;

static BYTE *tstr[] = {
"--------------------",
"  Acc 1   ",
"  Acc 2   ",
"  Acc 3   ",
"  Acc 4   ",
"  Acc 5   ",
"  Acc 6   "};

/*

       Organization of a 3 title menu

	  It is an array of OBJECTs.

                        root IBOX(0)
                      /                \
                    /                    \
                BOX(1) ---------------- IBOX(4)
                 | |                   /    \
                IBOX(2)               /      \
              /         \            /        \
            /            \          /          \
          TITLE-TITLE-TITLE(3)  BOX(5)--BOX(7)--BOX(9)
                                /    \         /   \
                              /        \      /     \
                            STRING-STRING(6) STR - STR(10)

The TITLE elements are the menu titles (!) and the
STRINGs are the menu items.

The elements must be stored in the order given in parantheses in the
diagram above, otherwise nasty strange things happen (for reasons 
only known to DRI!) 

*/

OBJECT obj_arr[] = {
-1, 1, 1, G_IBOX, NONE, NORMAL, 0x0L, 0,0, 80,25,

0, 2, 2, G_BOX, NONE, NORMAL, 0x1100L, 0,0, 80,513,
1, 3, 3, G_IBOX, NONE, NORMAL, 0x0L, 2,0, 6,769,

2, -1, -1, G_TITLE, NONE, NORMAL, 0x0L, 0,0, 6,769,
/* extra titles are added here */
-1, -1, -1, G_IBOX, NONE, NORMAL, 0x0L, 0,769, 80,19,

-1, -1, -1, G_BOX, NONE, NORMAL, 0xFF1100L, 2,0, 20,1,
-1, -1, -1, G_STRING, NONE, NORMAL, 0x0L, 0,0, 20,1,
-1, -1, -1, G_STRING, NONE, DISABLED,0L, 0,1, 20,1,
-1, -1, -1, G_STRING, NONE, NORMAL,0L, 0,2, 20,1,
-1, -1, -1, G_STRING, NONE, NORMAL, 0L, 0,3, 20,1,
-1, -1, -1, G_STRING, NONE, NORMAL, 0L, 0,4, 20,1,
-1, -1, -1, G_STRING, NONE, NORMAL, 0L, 0,5, 20,1,
-1, -1, -1, G_STRING, NONE, NORMAL, 0L, 0,6, 20,1,
-1, -1, -1, G_STRING, LASTOB, NORMAL, 0L, 0,7, 20,1
/* extra items are added here */
                  };
 
#define MENU_SIZE      14       /* initial menu size */
#define PAR_TITLE       2       /* index of parent of the titles */
#define PAR_MENU        4       /* index of parent of the first menu */
#define DESK_TITLE      3       /* index of the Desk title */
#define ABOUT_ITEM      6       /* initial index of About menu */
#define LINE_MENU       2       /* index of the BOX surrounding titles */
#define ELEMENT         4       /* index of first title + 1 */
#define DESK_MENU       5       /* index de l'entete menu bureau */
#define DESK_ITEMS      7       /* number of entries in desk menu */

static OBJECT *menu;        /* pointer to menu tree */
BOOLEAN menu_init;          /* is the menu initialised? */
BOOLEAN menu_draw;          /* has the menu been displayed? */
static LONG free_item;      /* index of next free item */
static LONG last_obj;       /* index of last item that may be added */
static LONG menu_len;       /* length of menu bar */
static LONG sub_menu;       /* index of the current sub-menu box */
static LONG item_no;        /* number of item within this sub-menu */
static LONG max_titles;     /* max titles in this menu*/
static LONG titles;         /* actual number of titles in menu */

/*----------------------*/
/*      copy_object     */
/*----------------------*/
VOID copy_object(dest,source)
LONG *dest,*source;
{
int i;
        for(i=sizeof(OBJECT)/4; i-- ;*dest++ = *source++);
}
/*----------------------*/
/*      init_menu       */
/*----------------------*/
BOOLEAN init_menu(desk_name,about_name,n_titles,max_items)
LONG desk_name, about_name;
LONG n_titles,max_items;
{
LONG count;
        if (menu_init || menu_draw || max_titles<0 ||max_items < 0)
                return(FALSE);
        max_titles = n_titles;
        menu_init = TRUE;
        free_item = MENU_SIZE + max_titles;
        last_obj = free_item  + max_titles + max_items;
        menu = allocate(sizeof(OBJECT)*(last_obj+1));

        /* initialise menu tree */
        for (count = 0; count < ELEMENT; count++)
                copy_object(&(menu[count]),&(obj_arr[count]));
        for (count = ELEMENT + max_titles; count < free_item; count++)
                copy_object(&(menu[count]),&(obj_arr[count-max_titles]));
        menu[DESK_TITLE].ob_spec = desk_name;
        menu[DESK_TITLE].ob_width = menu_len = strlen(desk_name);
        menu[ABOUT_ITEM+max_titles].ob_spec = about_name;
        titles = 0;
        objc_add(menu, 0, 4 + max_titles);
        objc_add(menu, 4 + max_titles, 5 + max_titles);
        objc_add(menu, 5 + max_titles, 6 + max_titles);
        return(ABOUT_ITEM + max_titles);
}
/*----------------------*/
/*      draw_menu       */
/*----------------------*/
BOOLEAN draw_menu()     
{
register LONG count, len;
register OBJECT *ptr, *p; 
        if (!menu_init)
                return(0);

        if (!menu_draw)
        {
                menu[LINE_MENU].ob_width = menu_len;
                /* convert line/column co-ords to pixels */
                for (count = 0; count < free_item; count++)
                {
                        ptr = &(menu[count]);
                        /* calculate box sizes */
                        if (ptr->ob_spec == 0xFF1100)
                        {       /* if this is a sub menu */
                                ptr->ob_width = len = 5;
                                if (ptr->ob_head != -1)
                                {       /* if there aer items */
                                        p = &(menu[ptr->ob_head]);
                                        do
                                        { /* calculate max width of items */
                                                len = max(len,p->ob_width);
                                                p = &(menu[p->ob_next]);
                                        }
                                        while(p->ob_spec != 0xFF1100);
                                        len++;
                                        ptr->ob_width = len;
                                        p = &(menu[ptr->ob_head]);
                                        do
                                        {/*make all the entries the same width*/
                                                p->ob_width = len;
                                                p = &(menu[p->ob_next]);
                                        }
                                        while(p->ob_spec != 0xFF1100);
                                }
                        }
                        ptr->ob_x *= gl_wchar;
                        ptr->ob_width *= gl_wchar;
                        ptr->ob_y = (ptr->ob_y & 255)*gl_hchar
                                                          + (ptr->ob_y >> 8);
                        ptr->ob_height = (ptr->ob_height & 255)*gl_hchar
                                                      + (ptr->ob_height >> 8);
                }
                menu_draw = TRUE;
        }
        len = menu_bar(menu,TRUE);

        /* ignore desk accs */
        for (count = ABOUT_ITEM + max_titles;
                        count < ABOUT_ITEM+DESK_ITEMS+max_titles;
                        count++)
        {
                menu[count].ob_next = -1;
                menu[count].ob_head = -1;
                menu[count].ob_tail = -1;
        }
        menu[ABOUT_ITEM+max_titles].ob_next = DESK_MENU + max_titles;
        menu[DESK_MENU+max_titles].ob_head = ABOUT_ITEM + max_titles;
        menu[DESK_MENU+max_titles].ob_tail = ABOUT_ITEM + max_titles;
        menu[DESK_MENU+max_titles].ob_height = gl_hchar;
        return(len);
}
/*----------------------*/
/*      delete_menu     */
/*----------------------*/
BOOLEAN delete_menu()     
{
        if (!menu_init || !menu_draw)
                return(0);
        return(menu_bar(menu,FALSE));
}
/*----------------------*/
/*      title_menu      */
/*----------------------*/
LONG title_menu(title_name)
LONG title_name;
{
register OBJECT *ptr;
register LONG old_menu_len;
        if (!menu_init || free_item > last_obj || titles > max_titles
                                                                || menu_draw)
                return(0);      /* no more space in tree */

        /* add the menu title itself */
        ptr = &(menu[titles+ELEMENT]);
        ptr->ob_next = -1;
        ptr->ob_head = -1;
        ptr->ob_tail = -1;
        ptr->ob_type = G_TITLE;
        ptr->ob_state = NORMAL;
        ptr->ob_flags = NONE;
        ptr->ob_spec = title_name;
        ptr->ob_x = menu_len;
        ptr->ob_y = 0;
        old_menu_len = menu_len;
        menu_len += (ptr->ob_width = strlen(title_name));
        ptr->ob_height = 0x0301;
        objc_add(menu, PAR_TITLE, ELEMENT+titles++);

        /* initialise the sub-menu box */
        menu[free_item-1].ob_flags ^= LASTOB;
        sub_menu = free_item;   /* save the index of sub-menu box */
        ptr=&(menu[free_item]);
        ptr->ob_next = -1;
        ptr->ob_head = -1;
        ptr->ob_tail = -1;
        ptr->ob_type = G_BOX;
        ptr->ob_state = NORMAL;
        ptr->ob_flags = LASTOB;
        ptr->ob_spec = 0xFF1100;
        ptr->ob_x = old_menu_len + 2;
        ptr->ob_y = 0;
        ptr->ob_width = 20; /* 20 is random */
        ptr->ob_height = 1;
        objc_add(menu, PAR_MENU+max_titles, free_item++);
        item_no = 0;
        return(ELEMENT+titles-1);
}
/*----------------------*/
/*      item_menu       */
/*----------------------*/
LONG item_menu(item_name)
LONG item_name;
{
register OBJECT *ptr;
        if (!menu_init || menu_draw || free_item > last_obj-1)
                return(0);      /* no space in tree */
        menu[free_item-1].ob_flags ^= LASTOB;

        /* add the item itself */
        ptr = &(menu[free_item]);
        ptr->ob_next = -1;
        ptr->ob_head = -1;
        ptr->ob_tail = -1;
        ptr->ob_type = G_STRING;
        ptr->ob_state = NORMAL;
        ptr->ob_flags = LASTOB;
        ptr->ob_spec = item_name;
        ptr->ob_x = 0;
        ptr->ob_y = item_no++;
        ptr->ob_width = strlen(item_name);
        ptr->ob_height = 1;
        objc_add(menu, sub_menu, free_item++);
        menu[sub_menu].ob_height = item_no; /* max height of sub menu */
        return(free_item-1);
}
/*----------------------*/
/*      check_menu      */
/*----------------------*/
BOOLEAN check_menu(menu_item)
LONG menu_item;
{
        if (!init_menu || menu_item >= free_item)
                return(FALSE);
        if (menu[menu_item].ob_type != G_STRING)
                return(FALSE);
        menu[menu_item].ob_state ^= CHECKED;
        return((LONG)(menu[menu_item].ob_state & CHECKED));
}
/*----------------------*/
/*      enable_menu     */
/*----------------------*/
BOOLEAN enable_menu(menu_item)
LONG menu_item;
{
        if (!init_menu || menu_item >= free_item)
                return(FALSE);
        if (menu[menu_item].ob_type != G_STRING && menu[menu_item].ob_type !=
                                                                       G_TITLE)
                return(FALSE);
        menu[menu_item].ob_state ^= DISABLED;
        return((LONG)(menu[menu_item].ob_state & DISABLED));
}
/*----------------------*/
/*      select_menu     */
/*----------------------*/
BOOLEAN select_menu(menu_item)
LONG menu_item;
{
        if (!init_menu || menu_item >= free_item)
                return(FALSE);
        if (menu[menu_item].ob_type != G_TITLE)
                return(FALSE);
        menu_tnormal(menu, menu_item, (menu[menu_item].ob_state & SELECTED) != 0);
        return((LONG)(menu[menu_item].ob_state & SELECTED));
}
