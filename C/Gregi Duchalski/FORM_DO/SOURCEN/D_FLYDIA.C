 /***************************************************************
 *  Userdefined Objects in GFA-BASIC 3.x                        *
 *  (c)8/92 Gregi Duchalski                                     *
 *																*
 *  last change 04.08.92                                        *
 *      														*
 *  FLYDIALS zeichnen (Routine von Dirk Koenen)                 *
 ***************************************************************/

#include <portab.h>
#include <aes.h>
#include <vdi.h>

WORD cdecl fly_dial(PARMBLK *parmblk)
{
	WORD xy[6],xy_clip[4],v_handle;

/* Bildschirmv_handle holen */

	v_handle=(WORD) parmblk->pb_parm; 

/* Clipping setzen */

	xy_clip[0]=parmblk->pb_xc;
	xy_clip[1]=parmblk->pb_yc;
	xy_clip[2]=xy_clip[0]+parmblk->pb_wc;
	xy_clip[3]=xy_clip[1]+parmblk->pb_hc;
	
	vs_clip(v_handle,1,xy_clip);	

/* Flydial zeichnen */

	xy[0]=parmblk->pb_x-3;
	xy[1]=parmblk->pb_y-3;
	xy[2]=xy[0]+parmblk->pb_w+5;
	xy[3]=xy[1]+parmblk->pb_h+5;
	
	vsf_interior(v_handle,FIS_PATTERN);
	vsf_color(v_handle,1);
	vsl_color(v_handle,1);
	vsf_style(v_handle,4);
	vsf_perimeter(v_handle,0);
	vswr_mode(v_handle,MD_TRANS);

	v_bar(v_handle,xy);

	vswr_mode(v_handle,MD_REPLACE);
	vsf_perimeter(v_handle,1);
	vsf_interior(v_handle,FIS_HOLLOW);

	xy[0]+=2;xy[3]-=2;

	v_bar(v_handle,xy);

	v_pline(v_handle,2,xy);
	xy[0]+=1;xy[3]-=1;
	v_pline(v_handle,2,xy);

	xy[0] += 1;
	xy[1] += 2;
	xy[3] -= 1;
	xy[4]=xy[2]-2;
	xy[5]=xy[3];
	xy[2]=xy[0];

	v_pline(v_handle,3,xy);

/* Clipping aus */

	vs_clip(v_handle,0,xy_clip);	

	return(parmblk->pb_currstate);
}