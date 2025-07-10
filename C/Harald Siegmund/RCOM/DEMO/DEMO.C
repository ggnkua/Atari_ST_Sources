
/*
*
*  Demonstration for Handling of compiled resources
*
*  Link this file in two ways:
*
*  - without DEMRSC.O and RSRC.O: the resource will be loaded from disk
*  - with DEMRSC.O and RSRC.O: the resource is included in the program file
*
*  You won't have to change anything in the source code!
*
*/


#include <aes.h>
#include "demorsc.h"



int main()
{

   int      x,y,w,h;                /* pos and size of demo form */
   OBJECT   *pmenu,                 /* ^ to menu bar tree */
            *pform;                 /* ^ to form tree */


   appl_init();                     /* init AES */

   rsrc_load("demorsc.rsc");        /* load the resource */
   rsrc_gaddr(R_TREE,MENU,&pmenu);  /* get ^ to menu bar */
   rsrc_gaddr(R_TREE,FORM,&pform);  /* and ^ to form */
   menu_bar(pmenu,1);               /* show menu bar */
   form_center(pform,&x,&y,&w,&h);  /* center form */

                                    /* lock redraw area */
   form_dial(FMD_START,0,0,0,0,x,y,w,h);
                                    /* draw form */
   objc_draw(pform,ROOT,MAX_DEPTH,x,y,w,h);
   evnt_keybd();                    /* wait for any key */
                                    /* force redraw of form background */
   form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);

   menu_bar(pmenu,0);               /* hide menu bar */
   rsrc_free();                     /* remove resource */
   appl_exit();                     /* exit AES */

   return 0;
}

