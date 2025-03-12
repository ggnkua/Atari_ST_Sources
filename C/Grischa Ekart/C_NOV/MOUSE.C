/*            MOUSE.C V1.0, 9.9.1990            */
/* Autor: Grischa Ekart / (c) by Grischa Ekart  */

#include "gem_it.h"

static   int hidden = FALSE;

void
show_mouse(void)
{
   if(hidden)
   {
      graf_mouse(M_ON, NULL);
      hidden = FALSE;
   }
}

void
hide_mouse(void)
{
   if(!hidden)
   {
      graf_mouse(M_OFF, NULL);
      hidden = TRUE;
   }
}
