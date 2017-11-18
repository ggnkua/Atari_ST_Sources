#include <stdlib.h>
#include <stdio.h>
#include <stddef.h>
#include <mintbind.h>
#include <vdi.h>
#include "Highwire.h"
#include <aes.h>

#define page_border 2

long
main()
{
	long my_pid;
	short pxy[4],clip[4];
	short message[8];
	VDI_Workstation dev;
	struct paragraph_item *page;
	short minimum_page_width,u,current_page_width;
	
	if(Pgetppid()==0)
		return(0);
	
	vdi_handle=V_Opnvwk(&dev);
	my_pid=appl_init();
	
	vst_scratch(vdi_handle,SCRATCH_BOTH);
	vst_kern(vdi_handle,TRACK_NORMAL,PAIR_ON,&u,&u);
	vst_load_fonts(vdi_handle,0);
	vswr_mode(vdi_handle,MD_TRANS);
	vst_font(vdi_handle,fonts[0][0][0]);
	vst_charmap(vdi_handle,0);
	vsf_color(vdi_handle,background_colour);
	
	page=parse(load_file("test2.htm"),&minimum_page_width);
	minimum_page_width+=(page_border*2);
	current_page_width=minimum_page_width;
	
	for(;;)
	{
		evnt_mesag(message);
		
		switch(message[0])
		{
			case 20: //redraw
				if(pxy[0]<pxy[2] && pxy[1]<pxy[3])
				{
					if(message[4]<pxy[2] && message[5]<pxy[3] && message[6]>pxy[0] && message[7]>pxy[1])
					{
						clip[0]=max(message[4],pxy[0]);
						clip[1]=max(message[5],pxy[1]);
						clip[2]=min(message[6],pxy[2]);
						clip[3]=min(message[7],pxy[3]);
						vs_clip(vdi_handle,1,clip);
						
						v_bar(vdi_handle,pxy);
						render_page_contents(page,pxy[0]+page_border,pxy[1],current_page_width,pxy[3],pxy[1]);
				
						vs_clip(vdi_handle,0,clip);
					}
				}
				break;
			
			case 27: //sized	
			case 28: //moved
				pxy[0]=message[4];
				pxy[1]=message[5];
				pxy[2]=message[6]+pxy[0]-1;
				pxy[3]=message[7]+pxy[1]-1;
				if(message[6]-(page_border*2)>minimum_page_width)
					current_page_width=message[6]-(page_border*2);
				else
					current_page_width=minimum_page_width;
				break;
			
			case 50: //terminate
				vst_unload_fonts(vdi_handle,0);
				appl_exit();
				destroy_paragraph_structure(page);
				return(0);
		}
		
	}
	
	vst_unload_fonts(vdi_handle,0);
	appl_exit();
	destroy_paragraph_structure(page);
	return(0);
}
