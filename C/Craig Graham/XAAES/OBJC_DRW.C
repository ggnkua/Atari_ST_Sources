/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "K_DEFS.H"
#include "RECTLIST.H"
#include "OBJECTS.H"

/*
	Object Tree Handling Interface
*/

unsigned long XA_objc_draw(short clnt_pid, AESPB *pb)
{
	v_hide_c(V_handle);
	set_clip(pb->intin[2], pb->intin[3], pb->intin[4], pb->intin[5]);
	pb->intout[0]=draw_object_tree(pb->addrin[0],pb->intin[0],pb->intin[1]+1);
	clear_clip();
	v_show_c(V_handle,1);
	
	return XAC_DONE;
}

unsigned long XA_objc_offset(short clnt_pid, AESPB *pb)
{
	pb->intout[0]=object_abs_coords(pb->addrin[0],pb->intin[0],pb->intout+1,pb->intout+2);
	return XAC_DONE;
}

unsigned long XA_objc_find(short clnt_pid, AESPB *pb)
{
	pb->intout[0]=find_object(pb->addrin[0],pb->intin[0], pb->intin[1], pb->intin[2], pb->intin[3]);

	return XAC_DONE;
}

unsigned long XA_objc_change(short clnt_pid, AESPB *pb)
{
	OBJECT *root=(OBJECT*)pb->addrin[0];
	
	root[pb->intin[0]].ob_state=pb->intin[6];
	
	if (pb->intin[7])
	{
		v_hide_c(V_handle);
		set_clip(pb->intin[2], pb->intin[3], pb->intin[4], pb->intin[5]);
		draw_object_tree(root,pb->intin[0],pb->intin[1]+1);
		clear_clip();
		v_show_c(V_handle,1);
	}
	
	pb->intout[0]=1;
	
	return XAC_DONE;
}
