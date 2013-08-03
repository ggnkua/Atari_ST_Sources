#include "portab.h"
#include "gsxdef.h"
#include "gsxextrn.h"

extern	struct	font_head second;

/* OPEN_WORKSTATION: */
	VOID
v_opnwk()
{
    font_ring[1] = &second;

    cur_work = &virt_work;
    CONTRL[6] = virt_work.handle = 1;
    virt_work.next_work = NULLPTR;
	
    line_cw = -1;	/* invalidate current line width */

    text_init();	/* initialize the SIZ_TAB info */

    init_wk();

    /* Input must be initialized here and not in init_wk */

    loc_mode = 0; 	/* default is request mode	*/
    val_mode = 0;       /* default is request mode	*/
    chc_mode = 0; 	/* default is request mode	*/
    str_mode = 0; 	/* default is request mode	*/

    HIDE_CNT = 1;	/* mouse is initially hidden */

    GCURX = DEV_TAB[0]/2;	/* initialize the mouse to center */
    GCURY = DEV_TAB[1]/2;

    INIT_G();		/* go into graphics mode */
}
