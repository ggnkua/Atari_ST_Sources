/***********************************************/
/* Demo zur Verwendung des 'Button Managers'   */
/*                                             */
/* von Hans-JÅrgen Richstein                   */
/*     (c) 1990 Maxon Computer GmbH            */
/***********************************************/

#include <vdi.h>
#include <aes.h>
#include <stddef.h>

#define NUM_TREES 1 /* Anzahl der BÑume im RCS */

#include "demo.h" /* Resource-Definitionen */
#include "but_mnge.c" /* Button-Manager */

int  appl_id,msgbuf[8],v_handle, /* Gem-Krams */
   work_in[] = {1,1,1,1,1,1,1,1,1,1,2},
   work_out[57],dummy,x,y,w,h;

OBJECT *trees[NUM_TREES + 1]; /* Anzahl der BÑume
                              + Abschluss-Null */
/*---------------------------------------------*/
int main(void)
{
  unsigned int i;
  
  appl_id =  appl_init();
  if (appl_id != -1)
  {
    v_handle = graf_handle(&dummy,&dummy,
                                  &dummy,&dummy);
    v_opnvwk(work_in,&v_handle,work_out);
    if (v_handle != 0)
    {
      graf_mouse(ARROW,0);
      if (rsrc_load("demo.rsc"))
      {
        /* Array mit den Baumadressen belegen */

        for (i = 0;i < NUM_TREES; i++)
          rsrc_gaddr(0,i,&trees[i]);
        
        /* Array-Abschluss mit Nullzeiger */
        trees[NUM_TREES] = NULL;

        init_buttons(v_handle,trees); /* Jetzt
                                    passiert's */

        /* Hier geht es dann ganz normal weiter,
          als wenn es keine neuen Buttons gÑbe */

        form_center(trees[0],&x,&y,&w,&h);
        form_dial(FMD_START,0,0,0,0,x,y,w,h);
        objc_draw (trees[0],0,MAX_DEPTH,x,y,w,h);
        form_do(trees[0],-1);
        form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);
      }
      v_clsvwk(v_handle);
    }
    appl_exit();
  }
  return (0);
}   
