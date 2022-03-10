#include <stdio.h>
#include <stddef.h>
#include <gemfast.h>
#include <osbind.h>
#include <ctype.h>
#include <types.h>

#include "ressourc.h"
#include "ressourc.c"

char *reso[] = {
  "[3][| haute ou moyenne | r‚solution seulement !][Arrˆt]",
  "[3][| high or medium | resolution only ! ][ abort ]",
  "[3][| high or medium | resolution only ! ][ abort ]"  } ;
char *lico[] = {
  "[1][| Aimez-vous les arbres ? |][ retourne ]",
  "[1][| Do you like trees ? |][ return ]",
  "[1][| Do you like trees ? |][ Ende ]" } ;

int xd, yd, wd, hd, itemh ;
int savrez, phys_handle ;
long _STKSIZ = 1000 ;

do_fenetre(ai,ax,ay,aw,ah)     /* ouverture d'une fenetre */
int *ax,*ay,*aw,*ah ;
OBJECT *ai ;
{
   form_center(ai, ax, ay, aw, ah ) ;             /* centre le dialogue */
   form_dial(FMD_START,0,0,0,0,*ax,*ay,*aw,*ah);  /* reserve screen ram */
   objc_draw(ai,0,10,*ax,*ay,*aw,*ah) ;           /* dessine dialogue   */
}


do_dialog()                    /*   dessine et gere le dialogue  */
{
      int nlii ;
      char debgr ;

      do_fenetre(&rs_ob[ARBRE1], &xd, &yd, &wd, &hd) ;
      while ((itemh = form_do(&rs_ob[ARBRE1],-1 )) != FINI )
        {
          objc_change(&rs_ob[ARBRE1],itemh,0,xd,yd,wd,hd,0,0) ;
          form_dial(FMD_FINISH,0,0,0,0,xd,yd,wd,hd);
          switch (itemh) {
          case LANGUE :  nxt_lg() ;
                         break ;
          case ICONE  :  form_alert( 1, lico[lang] ) ;
          default     :  break ;
          }
          do_fenetre(&rs_ob[ARBRE1], &xd, &yd, &wd, &hd) ;
        }
      objc_change(&rs_ob[ARBRE1],itemh,0,xd,yd,wd,hd,0,0) ;
      form_dial(FMD_FINISH,0,0,0,0, xd,yd,wd,hd);  /* libere screen ram */   
      return itemh;
}


/*   main - starts the application. */

main()
{
      int  dummy, key ;
              
      appl_init();                              /* init application */
      lang = 0 ;
      if ((savrez = Getrez()) != 0 )            /* test resolution  */
         { 
         met_rsc() ;                             /* init ressources  */
         phys_handle = graf_handle(&dummy, &dummy, &dummy, &dummy);
         graf_mouse(ARROW, NULL);
         do_dialog();
         }
      else
         form_alert( 1, reso[lang] ) ;
      appl_exit();
}

