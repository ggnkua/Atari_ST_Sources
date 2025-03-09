/*            FIRST.C V1.0, 20.1.1992           */
/* Autor: Grischa Ekart                         */

#include    "g:\acs\acs.h"

static      Awindow *text_create(void *not_used);

#include    <first.ah>

int
ACSinit(void)
{
   Awindow  *rootwindow;

   rootwindow = Awi_root();
   if(rootwindow == NULL)
      return(FAIL);

   (rootwindow->service)(rootwindow, AS_NEWCALL,
      &TEXTFENSTER.create);

   return(OK);
}

static Awindow
*text_create(void *not_used)
{
   Awindow *window;

   window = Awi_create(&TEXTFENSTER);
   if(window == NULL)
      return(NULL);

   (window->open)(window);
   return(window);
}
