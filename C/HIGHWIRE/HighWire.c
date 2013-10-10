#include <mintbind.h>
#include <vdi.h>
#include <aes.h>

#include "HighWire.h"

int
main(void)
{
	short u,x,y,w,h,result,mx,my;
	enum bool exit=false;
	VDI_Workstation dev;
	struct load_to_do *load_to_do_temp;
	char address[]="excerpt.htm#testpoint1";
	
	app_id=appl_init();
	vdi_handle=V_Opnvwk(&dev);
	Pdomain(DOMAIN_MINT);
	
	wind_get(DESK,WF_WORKXYWH,&x,&y,&w,&h);
	window_handle=wind_create(NAME+CLOSER+FULLER+MOVER+SMALLER+SIZER,x,y,w,h);
	wind_set(window_handle,WF_BEVENT,1,0,0,0);

	vst_scratch(vdi_handle,SCRATCH_BOTH);
	vst_kern(vdi_handle,TRACK_NORMAL,PAIR_ON,&u,&u);
	vst_load_fonts(vdi_handle,0);
	vswr_mode(vdi_handle,MD_TRANS);
	vst_font(vdi_handle,fonts[0][0][0]);
	vst_charmap(vdi_handle,0);
	
	first_frame=new_frame();
	
	read_to_do=add_to_do=(struct to_do_item *)malloc(sizeof(struct to_do_item));
	add_to_do->message_type=to_do_load_frame;
	add_to_do->next_to_do=0;
	load_to_do_temp=add_to_do->message=(struct load_to_do *)malloc(sizeof(struct load_to_do));
	load_to_do_temp->sub_type=0;
	load_to_do_temp->named_location=translate_address(address);
	load_to_do_temp->filename=address;
	load_to_do_temp->frame=first_frame;
	number_of_frames_left_to_load=1;
	
	wind_open(window_handle,100,100,500,300);
	
	while(exit!=true)
	{
		check_to_do_list();
		
		result=evnt_multi(
			MU_MESAG+MU_BUTTON+MU_TIMER,	//MU_KEYBD,MU_BUTTON,MU_M1,MU_M2,MU_MESAG,MU_TIMER
			1,1,1,	 						//MOUSE - 1 click,left button,left button
			0,0,0,0,0, 						//M1
			0,0,0,0,0, 						//M2
			event_messages,					//Returned messages
			100,0,							//Timer
			&mx,&my,&u,&u,&u,&u				//returned mouse and keyboard states
			);
		if(result & MU_MESAG)
			exit=process_messages(first_frame);
		if(result & MU_BUTTON)
			button_clicked(first_frame,mx,my);
		if(result & MU_TIMER)
			check_mouse_position(first_frame,mx,my);
	}
	
	wind_close(window_handle);
	wind_delete(window_handle);

	destroy_frame_structure(first_frame);
	
	vst_unload_fonts(vdi_handle,0);
	appl_exit();
	return 0;
}
