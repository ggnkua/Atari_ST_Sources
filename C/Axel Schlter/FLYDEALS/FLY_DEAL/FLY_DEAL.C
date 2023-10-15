/*
	FLY-DEAL Version 3.1 fÅr TOS 12.07.1992
	written '92 by Axel SchlÅter

	ACHTUNG: KEINE UNTERSCHEIDUNG MEHR ZWISCHEN GROû- UND
			 KLEINSCHREIBUNG BEI TASTATURSELECTING !!!  

	Die eigentliche Verwaltung ....
*/

#include <stdio.h>
#include <stdlib.h>
#include <aes.h>
#include <vdi.h>
#include <ext.h>
#include <string.h>
#include <tos.h>
#include "fly_deal.h"
#include "fly_scan.h"
#include "images.h"
#include "structur.h"

#define FMD_BACKWARD -1
#define FMD_FORWARD  -2
#define FMD_DEFLT    -3
#define TRUE		  1

void 			 MakeDial(OBJECT *dealog,int object);
int 			 do_deal(void);
int 			 ask_for_infoscrn(int *x,int *y,int *b,int *h);
void 			 movebox(long *Boxadr);
void 			 MakeSave(OBJECT *deal,int obj,int mode);
void 			 fly_bar(int x,int y,int w,int h,int color);
void 			 fly_line(int x1,int y1,int x2,int y2);
void 			 fly_rectangle(int x,int y,int b,int h);
void 			 fly_circle(int x,int y,int mode);
void			 fly_round(int x,int y,int mode);
void 			 fly_radio_box(int mode,OBJECT *dealog,int object,int RoundObject);
void 			 TreeWalk(OBJECT *tree,int mode);
static void 	 _tw(void (*callrout)(OBJECT *deal,int obj),int start);
int 		 	 ask_for_infoscrn(int *x,int *y,int *b,int *h);
int 			 fly_do_every_radio(int exit);
void 			 trans_image(OBJECT *tree,int obj);
void 			 vdi_trans(void *saddr,int swb,void *daddr,int dwb,int h);
void 			 vdi_fix(MFDB *pfd,void *saddr,int wb,int h);
int 			 second_form_do(OBJECT *tree,int start);
static int cdecl NEW_menu(PARMBLK *pblk);

/*==========================================================================================*/

int MAXX;	

int FLY_init(int work_in[],int work_out[])	/* System mit VDI und AES initialisieren */
{
	int egal,vq_out[57],wchar,hchar;
	
	if ((AES_ID=appl_init())==-1) return(ERROR);	/* AES anmelden */
	
 	VDI_ID=graf_handle(&wchar,&hchar,&egal,&egal);	/* VDI anmelden */
	for(egal=0;egal<10;egal++)
		work_in[egal]=1;
	work_in[10]=2;
	v_opnvwk(work_in,&VDI_ID,work_out);	/* virtuelle Workstation îffnen */
	if (!VDI_ID) return(ERROR);
	MAXY=work_out[1];
	MAXX=work_out[0];
	vq_extnd(VDI_ID,1,vq_out);
	PLANES=vq_out[4];
	
	ALERT=fly_object;					/* Vorbereitung der Alert-Rsc */
	for(egal=0;egal<14;egal++)
		rsrc_obfix(fly_object,egal);
	for(egal=2;egal<13;egal++)
		ALERT[egal].ob_flags|=HIDETREE;
	
	IMAGES=ImageTree;				    /* Vorbereitungen der Bilder  */
	for(egal=0;egal<4;egal++)
		rsrc_obfix(ImageTree,egal);
	
	if((hchar>>1)!=wchar) VERZERRT=1; else VERZERRT=0;
	
	trans_image(IMAGES,1);
	trans_image(IMAGES,2);
	trans_image(IMAGES,3);
	
	return(ALLES_OK);
}

int FLY_exit(void)
{
	if (!rsrc_free()) return(ERROR);
 	v_clsvwk(VDI_ID);
	if (!appl_exit()) return(ERROR);

	return(ALLES_OK);
}

long *FLY_deal_start(OBJECT *dealog)
{
	long *memsize;
	int XY[4],x,y,b,h,sx,sy,sb,sh;

	XY[0]=0; XY[1]=0; XY[2]=MAXX; XY[3]=MAXY;
	vs_clip(VDI_ID,1,XY);
		
	vsf_interior(VDI_ID,2);
	vsf_style(VDI_ID,8);
	vsl_color(VDI_ID,BLACK);

	YAD++;
	Sdial[YAD]=dealog;
	
	if(dealog[0].ob_y<21)
		form_center(Sdial[YAD],&x,&y,&b,&h);
	else
	{
		x=dealog[0].ob_x-3;	    y=dealog[0].ob_y-3;
		b=dealog[0].ob_width+6; h=dealog[0].ob_height+6;
	}	
	if((ask_for_infoscrn(&sx,&sy,&sb,&sh))==ALLES_OK)
		{x=sx+(sb/2)-(b/2);	y=sy+(sh/2)-(h/2);}
	
	memsize=Malloc(FLY_countsize(b,h));
	if(memsize<0) 
		return((long *)ERROR);
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
		
	TreeWalk(Sdial[YAD],0);
	
	FLY_bitblt(x,y,0,0,b,h,memsize,0,PIC_TO_MEM); 
	objc_draw(Sdial[YAD],ROOT,MAX_DEPTH,x,y,b,h);
	return(memsize);	
}

int FLY_deal_do(int firsttext,long *Boxadr,int mode)
{
	int exit;
			
	for(;;)
	{
		exit=second_form_do(Sdial[YAD],firsttext);
		if(exit==MOVENUM)
			movebox(Boxadr);
		else
			switch(fly_do_every_radio(exit))
			{
				case -3: return(exit);
				case -1: if(mode==EXIT) return(exit);
			} 
	}
}

int FLY_deal_stop(long *memsize)
{
	int x=Sdial[YAD][ROOT].ob_x-3,
		y=Sdial[YAD][ROOT].ob_y-3,
		b=Sdial[YAD][ROOT].ob_width+5,
		h=Sdial[YAD][ROOT].ob_height+5,
		XY[4];
		
	FLY_bitblt(x,y,0,0,b,h,memsize,0,MEM_TO_PIC);
	
	Mfree(memsize); memsize=0L;
	TreeWalk(Sdial[YAD],1);
	YAD--;
	
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	XY[0]=0; XY[1]=0; XY[2]=MAXX; XY[3]=MAXY;
	vs_clip(VDI_ID,1,XY);
	return(ALLES_OK); 
}

void FLY_menu_make(OBJECT *menu)	/* Die Routine zum MenÅbearbeiten */
{
	register int obj=0;
	char *such="-----";

	do{
		if(menu[obj].ob_type==G_STRING)
		{	
			if((strstr(menu[obj].ob_spec.free_string,such)!=0)&&
			   (menu[obj].ob_state&DISABLED))
			   {
			   		menu[obj].ob_type        =G_USERDEF;
					menu[obj].ob_spec.userblk=&newmenu;
					newmenu.ub_code          =NEW_menu;
				}
		}
		
		if((menu[menu[obj-1].ob_next].ob_flags&LASTOB)
		    &&(obj!=1)) return;
		obj++;
	}while(1!=0);
}

/* ======================== Ende der Hauptroutinen ====================*/

static int cdecl NEW_menu(PARMBLK *pblk)
{
	int x=pblk->pb_x+1,y=pblk->pb_y,
		w=pblk->pb_w-1,h=pblk->pb_h-1,
		xy[4],Ypos=7;
		
	if(VERZERRT==1) Ypos=3; 
	
	xy[0]=x-2; xy[1]=y-2; xy[2]=x+w-1; xy[3]=y+h-1;

	vs_clip(VDI_ID,1,xy);	
	fly_line(x-1,y+Ypos  ,x+w+2,y+Ypos);
	fly_line(x-2,y+Ypos+1,x+w+1,y+Ypos+1);	
	vs_clip(VDI_ID,0,xy);		
	return(pblk->pb_currstate&~SELECTED);
}

int find_object(OBJECT *tree,int start,int which)
{
	int object=0,flag=EDITABLE,theflag,increment=1;
	
	switch(which)
	{
		case FMD_BACKWARD:
			increment=-1;
		case FMD_FORWARD:
			object=start+increment;
		case FMD_DEFLT:
			flag=DEFAULT;
			break;
	}
	
	while(object>=0)
	{
		theflag=tree[object].ob_flags;
		
		if(theflag&flag) 
			return(object);
		if(theflag&LASTOB) 
			object=-1;
		else	
			object+=increment;
	}
	
	return start;
}

int ini_field(OBJECT *tree,int start)
{	
	if(start==0) start=find_object(tree,0,FMD_DEFLT);
	return start;
}

int second_form_do(OBJECT *tree,int start)
{
	int edit,next,which,cont,idx,mx,my,mb,ks,kr,br;
	
	next=start;
	edit=0;
	cont=1;
	
	while(cont)
	{
		if((next!=0)&&(edit!=next))
		{
			edit=next;
			next=0;
			objc_edit(tree,edit,0,&idx,ED_INIT);
		}
		
		which=evnt_multi(MU_KEYBD|MU_BUTTON,2,1,1,0,0,0,0,0,0,0,0,0,0,
						 0x0L,0,0,&mx,&my,&mb,&ks,&kr,&br);
						 
		if(which&MU_KEYBD)
		{
			if(kr==0x1c0d || kr==0x720d) /* [ENTER] or [RETURN] */
			{
				next=DEFAULTbutt[YAD];
				cont=form_button(tree,next,br,&next);
			}
			else
			{
				if(ks&K_ALT)
				{
					int i;
					
					kr>>=8;
					for(i=0;i<39;i++)
						if(SCAN_TO_ASCII[i][0]==kr)
							next=KeyObjecte[YAD][SCAN_TO_ASCII[i][2]];
					if(next!=0)
						cont=form_button(tree,next,br,&next);
				}
				else	
				{
					cont=form_keybd(tree,edit,next,kr,&next,&kr);
					if(kr)
						objc_edit(tree,edit,kr,&idx,ED_CHAR);
				}
			}
		}
		if(which&MU_BUTTON)
		{
			next=objc_find(tree,0,MAX_DEPTH,mx,my);
			
			if(next==-1)
			{
				Bconout(2,7);
				next=0;
			}
			else
				cont=form_button(tree,next,br,&next);
		}
	
		if((start!=0)&&(!cont||((next!=0)&&(next!=edit))))
			objc_edit(tree,edit,0,&idx,ED_END);
	}
	return next&0x7fff;
}	

void movebox(long *Boxadr)
{
	int bx,by,bb,bh,x=Sdial[YAD][0].ob_x-3,
		ex,ey,		y=Sdial[YAD][0].ob_y-3,
					b=Sdial[YAD][0].ob_width+5,
					h=Sdial[YAD][0].ob_height+5;
	long *zsp;
	
	wind_get(0,WF_WORKXYWH,&bx,&by,&bb,&bh);
	
	graf_mouse(FLAT_HAND,0L);
	graf_dragbox(b+1,h+1,x,y,bx,by,bb,bh,&ex,&ey);
	graf_mouse(ARROW,0L);

	if(ex==x && ey==y) return;
	graf_mouse(M_OFF,0L);

	zsp=Malloc(FLY_countsize(b,h));
	if((((x+b)<ex)&&((y+h)<ey))||(((ex+b)<x)&&((ey+h)<y)))
	{
		FLY_bitblt(ex,ey,30,30,b,h,zsp,0,PIC_TO_MEM);
		FLY_bitblt(x,y,ex,ey,b,h,NULL,0,PIC_TO_PIC);
		FLY_bitblt(0,0,0,0,b,h,zsp,Boxadr,MEM_TO_MEM);
	}
	else
	{
		FLY_bitblt(x,y,0,0,b,h,zsp,0,PIC_TO_MEM);
		FLY_bitblt(x,y,0,0,b,h,Boxadr,0,MEM_TO_PIC);
		FLY_bitblt(ex,ey,0,0,b,h,Boxadr,0,PIC_TO_MEM);
		FLY_bitblt(ex,ey,0,0,b,h,zsp,0,MEM_TO_PIC);
	}
	Mfree(zsp);
		
	graf_mouse(M_ON,0L);
	Sdial[YAD][ROOT].ob_x=ex+3;
	Sdial[YAD][ROOT].ob_y=ey+3;
}