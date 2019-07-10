#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"

#define  extern
#include "globals.h"
#undef   extern


main()

{
    int i, c, dummy, button;

        gl_apid = appl_init();

        rez = Getrez();       /* get the screen resolution   */
		if(rez == 0)
		{	button = form_alert(1, "[1][ Sorry....    | Need medium or high resolution. ][OK]");
		shutdown(2);
		}      

        handle = open_workstation(&source);
        
        set_clip(xdesk,ydesk,wdesk,hdesk); /* set_clip to desktop */
		/* set text alignment to bottom left */
   		vst_alignment(handle,0,3,&dummy,&dummy);
        graf_mouse(0,0x0L);   /* set mouse to arrow */
        v_show_c(handle,0);   /* reset visibility */
        cursor(0,10);         /* put the vt52 cursor at line 10 */


	init();
	init_path();	/* initialize fs_inpath with current path */


/*	build a new desktop	*/

	create_newtops();
	wind_set(0,WF_NEWDESK,hightreadr,lowtreadr, 0);

	draw_obj(treicont);
	onleft = treicont;

	mkrscmnu[CUT].ob_state = DISABLED;
	mkrscmnu[COPY].ob_state = DISABLED;
	mkrscmnu[ERASE].ob_state = DISABLED;
	mkrscmnu[PASTE].ob_state = DISABLED;
	mkrscmnu[NAM].ob_state = DISABLED;

   /* draw the menu bar   */
    menu_bar(mkrscmnu,TRUE);
       
  /* go to the event_multi handler   */
   TaskMaster();
  /* should never reach here!  */ 
    shutdown(0);                 /* quit  */
}

clear()       { Bconout(2,27); Bconout(2,'E'); }

cursor(x,y)   /* position the cursor*/
        int x,y;
  {     Bconout(2,27); Bconout(2,'Y');
        Bconout(2,(32 + y)); Bconout(2,(32 + x));
  }

