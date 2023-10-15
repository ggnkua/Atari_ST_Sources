/*
	FLY-DEAL Version 3.0 fr TOS 12.07.1992
	written '92 by Axel Schlter

	Die Hilfsgrafik-Routinen der Library
*/

#include "fly_prot.h"

long FLY_countsize(int b,int h)
{
	return(((long) ((b+15)/16) *
		    (long) h *
		    (long) PLANES * 2L)+ 8192L);
}

int FLY_bitblt(int x,int y,int x2,int y2,int b,int h,long *addr,long *addr2,int mode)
{
	MFDB hinter,bild;
	int xy[8];
	
	hinter.fd_w		  =(hinter.fd_wdwidth=((b+15)/16))*16;
	hinter.fd_h   	  =h;
	hinter.fd_addr 	  =addr;
	bild.fd_addr  	  =NULL;
	hinter.fd_nplanes =PLANES;
	hinter.fd_stand   =0;
				
	if(mode==PIC_TO_MEM) {	
		xy[0]=x;	xy[1]=y;	xy[2]=x+b;	xy[3]=y+h;		
		xy[4]=x2;	xy[5]=y2;	xy[6]=b;	xy[7]=h; 
		v_hide_c(VDI_ID);
		vro_cpyfm(VDI_ID,S_ONLY,xy,&bild,&hinter);
		v_show_c(VDI_ID,1);	}
	if(mode==MEM_TO_PIC) {
		xy[0]=x2;	xy[1]=y2;	xy[2]=b;	xy[3]=h;		
		xy[4]=x;	xy[5]=y;	xy[6]=x+b;	xy[7]=y+h; 
		v_hide_c(VDI_ID);
		vro_cpyfm(VDI_ID,S_ONLY,xy,&hinter,&bild);
		v_show_c(VDI_ID,1);	}
	if(mode==PIC_TO_PIC) {
		hinter.fd_addr=NULL; 
		xy[0]=x;	xy[1]=y;	xy[2]=x+b;	xy[3]=x+h;		
		xy[4]=x2;	xy[5]=y2;	xy[6]=x2+b;	xy[7]=y2+h; 
		v_hide_c(VDI_ID);
		vro_cpyfm(VDI_ID,S_ONLY,xy,&hinter,&bild);
		v_show_c(VDI_ID,1);	}
	if(mode==MEM_TO_MEM) {
		xy[0]=x;	xy[1]=y;	xy[2]=x+b;	xy[3]=y+h;		
		xy[4]=x2;	xy[5]=y2;	xy[6]=x2+b;	xy[7]=y2+h; 
		bild.fd_addr=addr2;
		vro_cpyfm(VDI_ID,S_ONLY,xy,&hinter,&bild);}
	return(0);
}	
	
void fly_rectangle(int x,int y,int b,int h)
{
	int xy[10];
	
	xy[0]=x;   xy[1]=y;   xy[2]=x+b; xy[3]=y;
	xy[4]=x+b; xy[5]=y+h; xy[6]=x;   xy[7]=y+h;
	xy[8]=x;   xy[9]=y;
	v_pline(VDI_ID,5,xy);
}

void fly_line(int x1,int y1,int x2,int y2)
{
	int xy[4];
	
	xy[0]=x1;  xy[1]=y1;  xy[2]=x2;  xy[3]=y2;
	v_pline(VDI_ID,2,xy);
}

void fly_bar(int x,int y,int w,int h,int color)
{
	int xy[4];

	vsf_color(VDI_ID,color);	
	xy[0]=x; xy[1]=y; xy[2]=x+w; xy[3]=y+h;
	v_bar(VDI_ID,xy);
}	

void fly_circle(int x,int y,int mode)
{
	BITBLK *bitblk=IMAGES[mode].ob_spec.bitblk;
	MFDB s,d; 
	int index[2],xy[8];
						
	s.fd_w		  =bitblk->bi_wb<<3;
	s.fd_wdwidth  =bitblk->bi_wb>>1;
	s.fd_h   	  =bitblk->bi_hl;
	s.fd_addr 	  =(void*)bitblk->bi_pdata;
	d.fd_addr  	  =NULL;
	s.fd_nplanes  =1;
					
	index[0]=BLACK;
	index[1]=WHITE;
				
	xy[0]=0;	xy[1]=0;	xy[2]=16;		xy[3]=s.fd_h;		
	xy[4]=x+1;	xy[5]=y+1;	xy[6]=x+s.fd_w;	xy[7]=y+s.fd_h; 

	v_hide_c(VDI_ID);
	vrt_cpyfm(VDI_ID,MD_REPLACE,xy,&s,&d,index);
	v_show_c(VDI_ID,1);
}
	
void fly_radio_box(int mode,OBJECT *dealog,int SelObject,int RoundObject)
{
	int x,y,b,h,adX,adY,atrbu[10];
	
	vqt_attributes(VDI_ID,atrbu);
	adX=dealog[0].ob_x+dealog[RoundObject].ob_x;
	adY=dealog[0].ob_y+dealog[RoundObject].ob_y;

	switch(mode)
	{
		case 0:
		    x=dealog[SelObject].ob_x+adX-1;
			y=dealog[SelObject].ob_y+adY-1;
			h=dealog[SelObject].ob_height+1;
			b=dealog[RoundObject].ob_width;
			fly_rectangle(x,y,b,h);
			fly_line(x+2,y+h+1,x+b+1,y+h+1);
			fly_line(x+b+1,y+2,x+b+1,y+h+1);
	
			x=(x+b)-2*atrbu[8];
			fly_line(x,y,x,y+h);	
			break;
		case 1:
			x=adX-1;
			y=adY-1;
			b=dealog[RoundObject].ob_width-2*atrbu[8]+2;
			h=dealog[RoundObject].ob_height;
			
			LITTLEbuf=Malloc(FLY_countsize(b,h));
			FLY_bitblt(x,y,0,0,b+4,h+2,LITTLEbuf,0,PIC_TO_MEM);
			
			fly_bar(x,y,b,h,WHITE);
			fly_rectangle(x,y,b,h);
			fly_bar(x+b,y+1,2,h+1,BLACK);
			fly_bar(x+1,y+h,b+1,2,BLACK);
			break;
		case 2:
			x=adX-1;
			y=adY-1;
			b=dealog[RoundObject].ob_width-2*atrbu[8]+2;
			h=dealog[RoundObject].ob_height;
			
			FLY_bitblt(x,y,0,0,b+4,h+2,LITTLEbuf,0,MEM_TO_PIC);
			Mfree(LITTLEbuf);
			break;
	}
}	
	
void trans_image(OBJECT *tree,int obj)
{
	BITBLK *bitblk=tree[obj].ob_spec.bitblk;
	int *taddr=bitblk->bi_pdata,
	    wb    =bitblk->bi_wb,
		hl    =bitblk->bi_hl;
	
	if(VERZERRT==1)
	{
		switch(obj)
		{
			case 1:bitblk->bi_pdata=FAchange; break;
			case 3:bitblk->bi_pdata=FAbuttOff; break;
			case 2:bitblk->bi_pdata=FAbuttOn; break;
		}
		hl=bitblk->bi_hl=7;
	}
	
	vdi_trans((void*)taddr,wb,(void*)taddr,wb,hl);
}

void vdi_fix(MFDB *pfd,void *saddr,int wb,int h)
{
	pfd->fd_addr   =saddr;
	pfd->fd_w      =wb<<3;
	pfd->fd_h      =h;
	pfd->fd_wdwidth=wb>>1;
	pfd->fd_nplanes=1;
}

void vdi_trans(void *saddr,int swb,void *daddr,int dwb,int h)
{
	MFDB s,d;
	
	vdi_fix(&s,saddr,swb,h);
	s.fd_stand=1;
	vdi_fix(&d,daddr,dwb,h);
	vr_trnfm(VDI_ID,&s,&d);
}