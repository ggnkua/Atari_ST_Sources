/*             DEMO.C V1.0, 9.9.1990            */
/* Autor: Grischa Ekart / (c) by Grischa Ekart  */

/* Dies ist ein Beispiel zur Benutzung von GEM_IT.
   In einem RCS mÅssen Sie ein MenÅ M_MENU mit den
   EintrÑgen E_INFO und E_QUIT und ein
   Desktophintergrund D_DESK konstruieren.
*/

#include "gem_it.h"
#include "demo.h"

void  main(void);
int   quit(void);
int   info(void);

static   MENU menu_tab[] = 
{
   E_INFO, info,
   E_QUIT, quit,
   0, 0
};

void
main(void)
{
   int   msgbuf[8];

   gem_init("demo.rsc");
   desk_init(D_DESK);
   menu_init(M_MENU, menu_tab);
   while(TRUE)
   {
      evnt_mesag(msgbuf);
      if(msgbuf[0] == MN_SELECTED)
         if(menu_event(msgbuf[3], msgbuf[4]) ==
            FALSE)
               break;
   }
   menu_exit();
   gem_exit(NO_ERR);
}

int
quit(void)
{
   return(FALSE);
}

int
info(void)
{
   form_value(1, "[1][Das ist %s][  OK  ]",
      "DEMO.PRG");

   return(TRUE);
}

