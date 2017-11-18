#include <stdlib.h>
#include <stdio.h>
#include <stddef.h>
#include <mintbind.h>
//#include "Nice_VDI.h"
#include <aes.h>

#define DOMAIN_MINT 1

long
main()
{
	long child_pid1,child_pid2,my_pid;
	short window_handle,message[8],x,y,w,h,cx,cy,cw,ch;
	
	Pdomain(DOMAIN_MINT);
	my_pid=appl_init();
	
	if((child_pid1=Pexec(100,"d:\\programming\\code\\c\\NewHW\\render.ovl","",""))<0)
		return(child_pid1);
	
	child_pid1=appl_find((char *)(child_pid1 | 0xFFFF0000));
	
	if((child_pid2=Pexec(100,"d:\\programming\\code\\c\\NewHW\\render.ovl","",""))<0)
		return(child_pid2);
	
	child_pid2=appl_find((char *)(child_pid2 | 0xFFFF0000));
	
	wind_get(0,WF_WORKXYWH,&x,&y,&w,&h);
	window_handle=wind_create(59,x,y,w,h);
	wind_open(window_handle,100,100,400,300);
	
	message[0]=28;
	message[1]=my_pid;
	message[2]=message[3]=0;
	wind_get(window_handle,WF_WORKXYWH,&message[4],&message[5],&message[6],&message[7]);
	message[6]=message[6]/2;
	appl_write(child_pid1,16,message);
	message[4]+=message[6];
	appl_write(child_pid2,16,message);
	
	
	for(;;)
	{
		evnt_mesag(message);
		
		switch(message[0])
		{
			case 20: //redraw
				//signal redraw_daemons to redraw window
				cx=message[4];
				cy=message[5];
				cw=message[6]+cx-1;
				ch=message[7]+cy-1;
				wind_get(window_handle,WF_FIRSTXYWH,&x,&y,&w,&h);
				while(w+h>0)
				{
					if(cx<(x+w-1) && cy<(y+h-1) && cw>x && ch>y)
					{
						message[4]=max(cx,x);
						message[5]=max(cy,y);
						message[6]=min(cw,x+w-1);
						message[7]=min(ch,y+h-1);
						message[1]=my_pid;
						appl_write(child_pid1,16,message);
						appl_write(child_pid2,16,message);
					}
					wind_get(window_handle,WF_NEXTXYWH,&x,&y,&w,&h);
				}
				
				break;
			
			case 50: //ap_term	
			case 22: //closed
				//signal redraw_daemon to terminate
				message[5]=message[0]=50;
				message[1]=my_pid;
				message[2]=message[3]=message[4]=message[6]=message[7]=0;
				appl_write(child_pid1,16,message);
				appl_write(child_pid2,16,message);
				return(0);
				break;
				
			case 27: //sized
			case 28: //moved
				wind_set(window_handle,WF_CURRXYWH,message[4],message[5],message[6],message[7]);
				//signal redraw_daemon the window has moved
				message[1]=my_pid;
				wind_get(window_handle,WF_WORKXYWH,&message[4],&message[5],&message[6],&message[7]);
				message[6]=message[6]/2;
				appl_write(child_pid1,16,message);
				message[4]+=message[6];
				appl_write(child_pid2,16,message);
				if(message[0]==27)
				{
					message[0]=20;
					message[4]-=message[6];
					message[6]+=message[6];
					appl_write(my_pid,16,message);
				}
				break;
				
			case 21://topped
				wind_set(window_handle,WF_TOP,message[3],0,0,0);
				break;
				
		}
		
	}
	
	return(0);
}
