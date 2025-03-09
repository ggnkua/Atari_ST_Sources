/*             MENU.C V1.0, 18.9.1990           */
/* Autor: Grischa Ekart / (c) by Grischa Ekart  */

#include "gem_it.h"

static   int me_flag;

static   OBJECT *menu;

static   MENU *menu_table;

void
menu_init(int ob_index, MENU *menu_tab)
{
   rsrc_gaddr(R_TREE, ob_index, &menu);
   menu_bar(menu, TRUE);
   menu_table = menu_tab;
   me_flag = TRUE;
}

void
menu_exit(void)
{
   if(me_flag)
      menu_bar(menu, FALSE);

   me_flag = FALSE;
}

int
menu_event(int title, int entry)
{
   int   i;
   int   ret_code;

   for(i = 0; menu_table[i].do_menu != 0L; i++)
   {
      if(menu_table[i].ob_index == entry)
      {
         ret_code = (*(menu_table[i].do_menu))();
         break;
      }
   }
   if(menu_table[i].do_menu == 0L)
      ret_code = -1;

   menu_tnormal(menu, title, TRUE);
   return(ret_code);
}

void
menu_title(int title, GRECT *rect)
{
   rect->g_x = menu[title].ob_x;
   rect->g_y = menu[title].ob_x;
   rect->g_w = menu[title].ob_width;
   rect->g_h = menu[title].ob_height;
}
