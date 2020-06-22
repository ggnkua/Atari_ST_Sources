/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <VDI.H>
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "K_DEFS.H"
#include "OBJECTS.H"

/*
	This routine behaves a lot like graf_watchbox() - in fact, XaAES's
	graf_watchbox calls this.
	
	The differance here is that we handle colour icons properly (something
	that AES4.1 didn't do).
	
	I've re-used this bit from the WINDIAL module I wrote for the DULIB GEM library.
	
	This routine assumes that any clipping is going to be done elsewhere before we get
	to here.
*/
short watch_object(OBJECT *dial, short ob, short in_state, short out_state)
{
	OBJECT *the_object=dial+ob;
	short pobf=-2,obf,mx,my,mb,x,y,w,h,omx,omy;
	
	vq_mouse(V_handle,&mb,&omx,&omy);
	
	object_abs_coords(dial, ob, &x, &y);	/* call XaAES's internal objc_offset() */
	w=the_object->ob_width+2;
	h=the_object->ob_height+2;
	x--; y--;

	if (!mb)		/* If mouse button is already released, assume that was just a click, so select */
	{
		(dial+ob)->ob_state=in_state;
		v_hide_c(V_handle);
		display_object(dial,ob,x-the_object->ob_x+1,y-the_object->ob_y+1);
		v_show_c(V_handle,1);
		obf=ob;
	}else{
	
		while (mb)		/* This loop contains a pretty busy wait, but I don't think it's to */
		{				/* much of a problem as the user is interacting with it continuously. */
			vq_mouse(V_handle,&mb,&mx,&my);
		
			if ((mx!=omx)||(my!=omy))
			{
				omx=mx; omy=my;
				obf=find_object(dial, ob, 10, mx, my);
		
				if (obf==ob)
					(dial+ob)->ob_state=in_state;
				else
					(dial+ob)->ob_state=out_state;
				
				if (pobf!=obf)
				{
					pobf=obf;
					v_hide_c(V_handle);		
					display_object(dial,ob,x-the_object->ob_x+1,y-the_object->ob_y+1);
					v_show_c(V_handle,1);
				}
			}
		}
		
	}

	vst_alignment(V_handle,0,5,&x,&x);
	vsf_interior(V_handle,FIS_SOLID);
	vswr_mode(V_handle, MD_TRANS);
	vst_font(V_handle,display.standard_font_id);
	vst_point(V_handle,display.standard_font_point,&x,&x,&x,&x);

	if (obf==ob)
		return 1;
	else
		return 0;
}
