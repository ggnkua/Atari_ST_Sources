/****************************************************************
*  Userdefined Objects in GFA-BASIC 3.x							*
*  (c)8/92 Gregi Duchalski										*
*																*
*  last change 04.08.92											*
*      															*
*  MENUE-NICELINE zeichnen							(Tabweite 4)*
****************************************************************/

#include <portab.h>
#include <aes.h>
#include <vdi.h>
#include <string.h>

WORD cdecl button(PARMBLK *parmblk)
{
	WORD	xy[4],xy_clip[4],v_handle;
		
	v_handle=(WORD) parmblk->pb_parm;   /* Bildschirmhandle */

/* Clipping setzen */
	
	xy_clip[0]=parmblk->pb_xc;
	xy_clip[1]=parmblk->pb_yc;
	xy_clip[2]=xy_clip[0]+parmblk->pb_wc-1;
	xy_clip[3]=xy_clip[1]+parmblk->pb_hc-1;

	vs_clip(v_handle,1,xy_clip);
	
/* Linie ausgeben */
	
	xy[0]=parmblk->pb_x;
	xy[1]=parmblk->pb_y + parmblk->pb_h/2-2;
	xy[2]=xy[0]+parmblk->pb_w-1;
	xy[3]=xy[1]+1;
		
	vsf_color(v_handle,1);
	vsf_interior(v_handle,FIS_PATTERN);
	vsf_style(v_handle,4);
	vsf_perimeter(v_handle,0);
	vr_recfl(v_handle,xy);
	
/* Clipping aus, Schreibmodus zurck */
	
	vs_clip(v_handle,0,xy_clip);
	
	return (parmblk->pb_currstate); 
}
