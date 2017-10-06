/*********************************************************************/
/*      Fixtree Test Routine                                         */
/*      by Guy L. Albertelli    07/30/87                             */
/*           ********** SHAREWARE ************                       */
/*                                                                   */
/*      This routine will cycle through each tree defined in your    */
/*      resource file. Obviously if a tree has no object marked      */
/*      EXIT then there is no way to give the program control back   */
/*********************************************************************/

/* original include files
#include "portab.h"
#include "obdefs.h"
#include "define.h"
#include "gemdefs.h"
#include "osbind.h"

#include <sample.h>
#include <sample.rsh>
*/
/*********************************************************************/
/* INCLUDE FILES                                                     */
/*********************************************************************/

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include <portab.h>
/*********************************************************************/
/* RESOURCE DATA                                                     */
/*********************************************************************/

#include "sample.h"
#include "sample.c"
/****************************************************************/
/* Note from Lung:                                              */
/*      My RCS can generate .C code but no .RSH code. The file  */
/*      SAMPLE.RSH seems not correct anyway. I use RCS to       */
/*      regeneate .C file and recompile FIXTRTST.C. It runs     */
/*      flawlessly now.                                         */
/****************************************************************/


/*********************************************************************/
/* EXTERNALS                                                         */
/*********************************************************************/

extern  int     gl_apid;

/*********************************************************************/
/* GLOBAL VARIABLES                                                  */
/*********************************************************************/

int     gl_hchar;
int     gl_wchar;
int     gl_wbox;
int     gl_hbox;        /* system sizes */

int     phys_handle;    /* physical workstation handle */
int     handle;         /* virtual workstation handle */

int     xdesk,ydesk,hdesk,wdesk;

int     contrl[12];
int     intin[128];
int     ptsin[128];
int     intout[128];
int     ptsout[128];    /* storage wasted for idiotic bindings */

int work_in[11];        /* Input to GSX parameter array */
int work_out[57];       /* Output from GSX parameter array */
int pxyarray[10];       /* input point array */

/****************************************************************/
/* open virtual workstation                                     */
/****************************************************************/
open_vwork()
{
int i;
        for(i=0;i<10;work_in[i++]=1);
        work_in[10]=2;
        handle=phys_handle;
        v_opnvwk(work_in,&handle,work_out);
}

/****************************************************************/
/*              Accessory Init. Until First Event_Multi         */
/****************************************************************/
disp_diag(tr,x,y,w,h,obj)
WORD x,y,w,h,obj;
LONG tr;
{
        WORD xd,yd,wd,hd,ex;
        form_center(tr,&xd,&yd,&wd,&hd);

        x=y=w=h=0;      /* initialize them to 0 to get better zooming effect
                           Jinfu Chen   Jan 23, 1988 */

        form_dial(0,x,y,w,h,xd,yd,wd,hd);
        form_dial(1,x,y,w,h,xd,yd,wd,hd);
        objc_draw(tr,0,MAX_DEPTH,xd,yd,wd,hd);
        ex = form_do(tr,obj);
        form_dial(2,x,y,w,h,xd,yd,wd,hd);
        form_dial(3,x,y,w,h,xd,yd,wd,hd);
        evnt_timer(0,0);
        return ex;
}

/****************************************************************/
/*              Accessory Init. Until First Event_Multi         */
/****************************************************************/
main()
{
        LONG tree;
        WORD i;

        appl_init();
        phys_handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
        wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
        open_vwork();
        graf_mouse(ARROW,0x0L);

        fix_tree(NUM_TREE);

        for(i=0;i<NUM_TREE;i++){
                rsrc_gaddr(R_TREE,i,&tree);
                disp_diag(tree,xdesk,ydesk,wdesk,hdesk,0);
        }

        unfix_tree();

        v_clsvwk(handle);
        appl_exit();

}

