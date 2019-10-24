#include <aes.h>
#include <vdi.h>

extern int handle;

int cdecl BarSeuil(PARMBLK *para)
{
	static int xc,yc,wc,hc;
	static int x,y,w,h;
	static int pxyb[10];
	static int pxy[4];
	static int seuil;
	xc=para->pb_xc;
	yc=para->pb_yc;
	wc=para->pb_wc;
	hc=para->pb_hc;
	x=para->pb_x;
	y=para->pb_y;
	w=para->pb_w;
	h=para->pb_h;
	seuil=(*(int *)(para->pb_parm));
	pxy[0]=xc,pxy[1]=yc,pxy[2]=xc+wc-1,pxy[3]=yc+hc-1;	
	vs_clip(handle,1,pxy);
	pxyb[0]=x+2;
	pxyb[1]=y+2;
	pxyb[2]=x+2+(w-3)*(seuil/32767.0);
	pxyb[3]=y+h-3;
	vswr_mode(handle,1);
	vsf_color(handle,RED);
	v_bar(handle,pxyb);	
	pxyb[0]=x+w-2,pxyb[1]=y+2;
	vsf_color(handle,WHITE);
	v_bar(handle,pxyb);
	vsl_color(handle,BLACK);
	pxyb[0]=x;
	pxyb[1]=y;
	pxyb[2]=x+w-1;
	pxyb[3]=y;
	pxyb[4]=x+w-1;
	pxyb[5]=y+h-1;
	pxyb[6]=x;
	pxyb[7]=y+h-1;
	pxyb[8]=x;
	pxyb[9]=y;
	v_pline(handle,5,pxyb);
	vs_clip(handle,0,pxy);
	return(para->pb_currstate);
}
