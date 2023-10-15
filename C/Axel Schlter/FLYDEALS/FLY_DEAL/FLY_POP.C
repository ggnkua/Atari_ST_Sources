/*
	FLY-DEAL Version 3.0 fr TOS 12.07.1992
	written '92 by Axel Schlter

	Alle Routinen fr die POPUP - Radiobutton's
*/

#include "fly_prot.h"

int  FLY_bitblt(int x,int y,int x2,int y2,int b,int h,long *addr,long *addr2,int mode);
long FLY_countsize(int b,int h);
int  TestObjc(OBJECT *tree,int obj);
int  TestCoord(int mx,int my,int bx,int by,int bw,int bh);
int  FLY_hndle_popup(OBJECT *dealog,int startObj,int mode,int px,int py,int pobj);
void FLY_radio_set(POPUP array[],int anzahl);

extern int MAXY;

int fly_do_every_radio(int exit)
{
	int egal,x,y,b,h,Eo;
	OBJECT *dealog;

	if((SaveAll[YAD][exit].ub_code!=0)&&(((SaveAll[YAD][exit].old_type&0xFF00)>>8)==18)) /* Tastatur-Select */
	{	
		Sdial[YAD][exit].ob_state=NORMAL;
		exit=(int)SaveAll[YAD][exit].ub_code;
	}
	if(SaveAll[YAD][exit].old_type==0x161a)	/* Hauptbox angeclickt */
	{
		int OObj=0,ParentX,ParentY,POPexit;

		dealog=(OBJECT*)SaveAll[YAD][exit].ub_code;
				
		form_center(dealog,&x,&y,&b,&h);
		while(dealog[OObj].ob_next!=0)
		{
			OObj++;
			if(dealog[OObj].ob_flags&SELECTABLE)
			{
				if(strcmp(SaveAll[YAD][exit].string,dealog[OObj].ob_spec.free_string)==0)	
					Eo=OObj;
				else
					dealog[OObj].ob_state&=~(SELECTED|CHECKED);
			}
		}
		dealog[OObj=Eo].ob_state=CHECKED|SELECTED;
		
		objc_offset(Sdial[YAD],exit,&ParentX,&ParentY);
		dealog[0].ob_x=ParentX;
		dealog[0].ob_y=ParentY-dealog[OObj].ob_y;
		
		if(dealog[0].ob_y+dealog[0].ob_height>MAXY)
			dealog[0].ob_y-=(dealog[0].ob_y+dealog[0].ob_height)-MAXY;
		if(dealog[0].ob_y<20) dealog[0].ob_y=20;
					
		x=dealog[0].ob_x; y=dealog[0].ob_y; 
		
		POPexit=FLY_hndle_popup(dealog,0,XYPOS,x,y,0);	
		dealog[Eo].ob_state=NORMAL;
		if((dealog[POPexit].ob_state&DISABLED)||(POPexit==ERROR)||
		   (!(dealog[POPexit].ob_flags&SELECTABLE))) 
			POPexit=Eo;
							
		dealog[POPexit].ob_state&=~SELECTED;
		dealog[POPexit].ob_state|=CHECKED;
		
		strcpy(SaveAll[YAD][exit].string,dealog[POPexit].ob_spec.free_string);
		
		Sdial[YAD][exit].ob_width-=1;	
		objc_draw(Sdial[YAD],exit,MAX_DEPTH,Sdial[YAD][0].ob_x,Sdial[YAD][0].ob_y,			
				  Sdial[YAD][0].ob_width,Sdial[YAD][0].ob_height);			
		Sdial[YAD][exit].ob_width+=1;	
							
		if(!(Sdial[YAD][exit].ob_flags&EXIT)) exit=MOVENUM;
		evnt_multi(MU_TIMER|MU_BUTTON,1,1,1,0,0,0,0,0,0,0,0,0,0,&egal,
				   200,0,&egal,&egal,&egal,&egal,&egal,&egal);
		
		if((dealog[POPexit].ob_flags&EXIT)||
		   (dealog[POPexit].ob_flags&TOUCHEXIT)) return(-1);
		return(-2);
	}	
	
	if(SaveAll[YAD][exit].old_type==0x161b)	/* Circlebox angeclickt */
	{
		int OObj=0,ShowObj;
				
		if(Sdial[YAD][exit].ob_next==exit-2)
			ShowObj=exit-1;
		else
			ShowObj=exit+1;
		dealog=(OBJECT*)SaveAll[YAD][ShowObj].ub_code;
									
		while(dealog[OObj].ob_next!=0)
		{
			OObj++;
			if(dealog[OObj].ob_flags&SELECTABLE)
			{
				dealog[OObj].ob_state&=~SELECTED;
				if(strcmp(SaveAll[YAD][ShowObj].string,dealog[OObj].ob_spec.free_string)==0) Eo=OObj;
			}
		}
		OObj=Eo;
		
		do{
			if(dealog[OObj].ob_next==0) OObj=0;
			OObj++;
		}while(dealog[OObj].ob_state&DISABLED || !(dealog[OObj].ob_flags&SELECTABLE));
			
		dealog[OObj].ob_state|=CHECKED;
	
		strcpy(SaveAll[YAD][ShowObj].string,dealog[OObj].ob_spec.free_string);
		
		Sdial[YAD][ShowObj].ob_width-=1;	
		objc_draw(Sdial[YAD],ShowObj,MAX_DEPTH,Sdial[YAD][0].ob_x,Sdial[YAD][0].ob_y,			
				  Sdial[YAD][0].ob_width-1,Sdial[YAD][0].ob_height-1);			
		Sdial[YAD][ShowObj].ob_width+=1;	
	
		evnt_timer(100,0);	/* Warten, da sonst viel zu schnell ! */

		if((dealog[OObj].ob_flags&EXIT)||
		   (dealog[OObj].ob_flags&TOUCHEXIT)) return(-1);
		return(-2);
	}
	return(-3);	/* Der Compiler meckert hier !! */
}

void FLY_radio_set(POPUP array[],int anzahl)
{
	int i;
	
	for(i=0;i<anzahl;i++)
	{
		SaveAll[YAD+1][array[i].object].ub_code=array[i].tree;
		SaveAll[YAD+1][array[i].tastSel].ub_code=(OBJECT*)array[i].object;
	}
}

int FLY_test_radio_set(POPUP array[],int which)
{
	char *string=SaveAll[YAD+1][array[which].object].string; 
	OBJECT *show=array[which].tree;
	int obj=1;
	
	while(show[obj].ob_next!=-1)
	{
		if(show[obj].ob_flags&SELECTABLE)
			if(strcmp(string,show[obj].ob_spec.free_string)==0)
				return(obj);	
		obj++;
	}
	return(ERROR);
}	

int FLY_hndle_popup(OBJECT *dealog,int startObj,int mode,int px,int py,int pobj)
{
	int egal,ex_flag=0,ExitMode,mx,my,object=1,oldobj=1,
		bx,by,bw=dealog[startObj].ob_width,bh=dealog[startObj].ob_height,
		ox=0,oy=0,keyCode,MTaste,startflag=1;
	long *memsize;

	switch(mode)
	{
		case CENTER:
			form_center(dealog,&bx,&by,&egal,&egal);
			break;
		case XYPOS:
			dealog[startObj].ob_x=px;
			dealog[startObj].ob_y=py;
			bx=px; by=py;
			break;
		case MOUSE:
			vq_mouse(VDI_ID,&egal,&mx,&my);
			dealog[startObj].ob_x=mx;
			dealog[startObj].ob_y=my-dealog[pobj].ob_y;
			bx=mx; by=my-dealog[pobj].ob_y;
			break;
	}
	
	memsize=Malloc(FLY_countsize(bw+7,bh+7));
	FLY_bitblt(bx-2,by-2,0,0,bw+7,bh+7,memsize,0,PIC_TO_MEM);
	
	graf_mkstate(&egal,&egal,&MTaste,&egal);
	if(MTaste) ExitMode=0; else ExitMode=1;
	
	if(objc_find(dealog,ROOT,MAX_DEPTH,mx,my)==0)
		dealog[startObj+1].ob_state=SELECTED;
	objc_draw(dealog,startObj,MAX_DEPTH,bx-2,by-2,bw+7,bh+7);
	
	while(dealog[object].ob_next!=-1)
	{
		if(dealog[object].ob_state&CHECKED) break;
		object++;
	}
	oldobj=object;
				
	do
	{
		vq_mouse(VDI_ID,&MTaste,&mx,&my);
		
		if(MTaste==ExitMode) 
		{
			if(TestCoord(mx,my,bx,by,bw,bh)==ERROR)
				object=ERROR;

			ex_flag=1;
			continue;
		}
		
		if((mx!=ox)||(my!=oy)) 	/* Bewegung, dann bearbeiten */
		{				
			graf_mkstate(&mx,&my,&MTaste,&egal);
			if(TestCoord(mx,my,bx,by,bw,bh)==ERROR) 
			{
				ox=mx; oy=my;
					
				if(!startflag)
				{
					if(oldobj>0)
						objc_change(dealog,oldobj,0,bx,by,bw,bh,NORMAL,1);
					oldobj=object=ERROR;					
				}
				else startflag=0;
				ex_flag=0;
			}
			else
			{
				object=objc_find(dealog,ROOT,MAX_DEPTH,mx,my);
				
				if(object>startObj+1) 
				{
					if ((object!=oldobj)&&(TestObjc(dealog,object)==object))
					{
						if(oldobj>0)
							objc_change(dealog,oldobj,0,bx,by,bw,bh,NORMAL,1);
						objc_change(dealog,object,0,bx,by,bw,bh,SELECTED,1);
						oldobj=object;
					}
				}
				ox=mx; 
				oy=my;
			}
		}
		
		if(kbhit()) 
		{
			keyCode=(int)((Crawcin())>>8);
		
			switch(keyCode)
			{
				case 0x1C00:		/* [RETURN] */
				case 0x7200:		/* [ENTER]  */
					ex_flag=1;
					break;
				case 0x5000: 				/* Runter */
					if(object<startObj+1)
						 {object=startObj;oldobj=ERROR;}
					if(dealog[object].ob_next!=startObj)
					{
						do{
							object++;
							if(dealog[object].ob_next==startObj) break;
						}while(dealog[object].ob_state&DISABLED);
						
						if(!(dealog[object].ob_state&DISABLED))
						{
							objc_change(dealog,oldobj,0,bx,by,bw,bh,NORMAL,1);
							objc_change(dealog,object,0,bx,by,bw,bh,SELECTED,1);
							oldobj=object;
						}
					}	  
					break;
				case 0x4800: 				/* Hoch */	
					if(object<startObj+1) 
						{object=dealog[startObj].ob_tail+1;oldobj=ERROR;}
					if(object-1!=startObj)
					{
						do{
							object--;
							if(object-1==startObj) break;
						}while(dealog[object].ob_state&DISABLED);
					
						if(!(dealog[object].ob_state&DISABLED))
						{
							objc_change(dealog,oldobj,0,bx,by,bw,bh,NORMAL,1);
							objc_change(dealog,object,0,bx,by,bw,bh,SELECTED,1);
							oldobj=object;
						}
					}	  
					break;
			}	
		}
	}while(ex_flag!=1);

	FLY_bitblt(bx-2,by-2,0,0,bw+7,bh+7,memsize,0,MEM_TO_PIC);
	Mfree(memsize);
	return(object);
}

int TestObjc(OBJECT *tree,int obj)
{
	if((tree[obj].ob_flags&SELECTABLE)&&
	   (tree[obj].ob_type==G_STRING)&&
	   (!(tree[obj].ob_state&DISABLED)))
	{
		return(obj);
	}
	else
		return(ERROR);
}

int TestCoord(int mx,int my,int bx,int by,int bw,int bh)
{
	if((mx<bx)||(my<by)||(mx>(bx+bw))||(my>(by+bh))) 
		return(ERROR);
	return(ALLES_OK);
}