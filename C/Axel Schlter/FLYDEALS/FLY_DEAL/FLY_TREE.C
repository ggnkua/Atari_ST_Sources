/*
	FLY-DEAL Version 3.0 fr TOS 12.07.1992
	written '92 by Axel Schlter
	
	Die Treewalk - Routinen fr die Library
*/

#include "fly_prot.h"
#include <ctype.h>

extern int MAXY;

void setAll(OBJECT *tree,int obj,USERBLK *ublk,int cdecl (*rout)(PARMBLK *pblk));

void TreeWalk(OBJECT *tree,int mode)
{
	register int obj=0;
	
	for(;;)
	{
		if(mode==1)
		{ 
			if(tree[obj].ob_type==G_USERDEF)
				MakeSave(tree,obj,1);
		}
		else
		{
			if(tree[obj].ob_flags & DEFAULT) DEFAULTbutt[YAD]=obj;
			
			switch((tree[obj].ob_type & 0xFF00)>>8)
			{
				case FLYRADIO:
				    setAll(tree,obj,&flyradio,FLY_radio);
					break;
				case FLYBUTTONS:
				    setAll(tree,obj,&flybuttons,FLY_buttons);
					break;
				case FLYMOVEBUTT:
					MOVENUM=obj;
					tree[obj].ob_state&=~(CROSSED|OUTLINED);		
			        setAll(tree,obj,&flymovebutt,FLY_movebutt);
					break;
				case FLYTEXT:
				    setAll(tree,obj,&flytext,FLY_text);
					break;
				case FLYBOXES:
				    setAll(tree,obj,&flyboxes,FLY_boxes);
			}
		}
		if(!tree[obj].ob_next) return;
		obj++;
	}
}

void setAll(OBJECT *tree,int obj,USERBLK *ublk,int cdecl (*rout)(PARMBLK *pblk))
{
	MakeSave(tree,obj,0);
	tree[obj].ob_type        =G_USERDEF;
	tree[obj].ob_spec.userblk=ublk;
	ublk->ub_code            =rout;
}

void MakeSave(OBJECT *deal,int obj,int mode)
{
	switch(mode)
	{
		case 0:
			if((((deal[obj].ob_type&0xff00)>>8)!=FLYMOVEBUTT)&&
			   (deal[obj].ob_type!=0x161b))
				strcpy(SaveAll[YAD][obj].string,deal[obj].ob_spec.free_string);
			SaveAll[YAD][obj].old_type=deal[obj].ob_type;
			SaveAll[YAD][obj].old_pointer=deal[obj].ob_spec.free_string;
			break;
		case 1:
			deal[obj].ob_type=SaveAll[YAD][obj].old_type;
			deal[obj].ob_spec.free_string=SaveAll[YAD][obj].old_pointer;
			break;
	}
}

static int cdecl FLY_movebutt(PARMBLK *pblk)
{
	int x=pblk->pb_x+1,y=pblk->pb_y,
		w=pblk->pb_w-1,h=pblk->pb_h-1;
	
	vsl_color(VDI_ID,BLACK);			/* Auen */		
	fly_bar(x-3,y-3,w+5,h+5,WHITE);			
	fly_rectangle(x-3,y-3,w+5,h+5);
	
	vsl_color(VDI_ID,BLACK);			/* Innen */
	fly_rectangle(x,y,w-1,h-1); 			
	fly_line(x,y+1,x+w-1,y+1);				/* Verst„rkung X */
	fly_line(x+w-2,y,x+w-2,y+h-1);			/* Verst„rkung Y */
	
	vsl_color(VDI_ID,BLACK);			/* Schr„ge Linie */
	fly_line(x-3,y-2,x+w+2,y+h+3);          
		
	return(pblk->pb_currstate);
}

static int cdecl FLY_buttons(PARMBLK *pblk)
{
	int x=pblk->pb_x,y=pblk->pb_y,flags=pblk->pb_tree[pblk->pb_obj].ob_flags,
		b=pblk->pb_w,h=pblk->pb_h,Position,Cnt,
		obj=pblk->pb_obj,atrbu[10],textx,texty,linex,liney;
	char egal[79],*ziel,zsp[79]="";
	
	ziel =strchr(SaveAll[YAD][obj].string,(int)'[');
	
	if(ziel!=0)	/* Wenn Tastaturkrzel,Position holen & Krzel saven & Text machen */
	{
		KeyObjecte[YAD][tolower((int)*(ziel+1))] =obj;
		Position=(int)(ziel-SaveAll[YAD][obj].string);
		strncpy(zsp,SaveAll[YAD][obj].string,(size_t)Position); 
		strcat(zsp,ziel+1);
	}
	else		/* sonst Texte belassen und Position markieren */
	{
		Position=ERROR;
		strcpy(zsp,SaveAll[YAD][obj].string);
		strcpy(ziel,SaveAll[YAD][obj].string);
	}
	vqt_attributes(VDI_ID,atrbu);	/* Attribute fr H”he und Breite der Buchstaben */
	if(VERZERRT==1) 
		Cnt=1; else Cnt=2;
	
	strcpy(egal,ziel);	/* Das ist n”tig, weil die Ausgabe sonst verckt spielt ! */
		
	if(SaveAll[YAD][obj].ub_code!=0)	/* Exitstrings fr die Popup's */
	{
		v_gtext(VDI_ID,x,y+atrbu[7],zsp);
		linex=x+(Position*atrbu[8]);
		liney=y+atrbu[7]+Cnt;

		if(Position!=ERROR) 
			fly_line(linex,liney,linex+atrbu[8]-1,liney);
		return(pblk->pb_currstate&=~SELECTED);
	}			
	if((flags&EXIT)&&(!(flags&RBUTTON)))	/* Normale Exitbuttons */
	{
		vsl_color(VDI_ID,BLACK);
		
		textx=(x+b/2)-((int)(strlen(zsp)*atrbu[8])/2);
		texty=(y+h/2)+(atrbu[7]/2);
		linex=textx+(Position*atrbu[8]);
		liney=texty+Cnt;
	
		fly_rectangle(x-1,y-1,b+3,h+3); 
		fly_rectangle(x-2,y-2,b+5,h+5);
		if(flags&DEFAULT) fly_rectangle(x-3,y-3,b+7,h+7);
		fly_bar(x,y,b+1,h+1,WHITE);
	
		v_gtext(VDI_ID,textx,texty,zsp);
		vsl_color(VDI_ID,BLACK);
		if(Position!=ERROR) 
			fly_line(linex,liney,linex+atrbu[8]-1,liney);
		
		if(pblk->pb_currstate&SELECTED)
		{
			vswr_mode(VDI_ID,MD_XOR);
			fly_bar(x-1,y-1,b+3,h+3,BLACK); 
			vswr_mode(VDI_ID,MD_REPLACE);
			fly_line(x-1,y-1,x+1,y-2);
		}	
		if(pblk->pb_currstate&DISABLED)
		{
			vswr_mode(VDI_ID,MD_TRANS); vsf_interior(VDI_ID,2);
			vsf_style(VDI_ID,4);
			fly_bar(x,y,b+1,h+1,WHITE); 
			vswr_mode(VDI_ID,MD_REPLACE); vsf_interior(VDI_ID,1);
		}	
		
		return(pblk->pb_currstate&=~(SELECTED|DISABLED));
	}
	if(flags&RBUTTON)				/* Radiobuttons mit/ohne Touchexit */
	{
		if(pblk->pb_currstate&SELECTED)
			if(VERZERRT==1) fly_circle(x,y+1,3); else fly_circle(x,y,3);
		else
			if(VERZERRT==1) fly_circle(x,y+1,2); else fly_circle(x,y,2);
		
		v_gtext(VDI_ID,x+16,y+atrbu[7],zsp);
		linex=x+(Position*atrbu[8])+16;
		liney=y+atrbu[7]+Cnt;
		vsl_color(VDI_ID,BLACK);
		if(Position!=ERROR) 
			fly_line(linex,liney,linex+atrbu[8]-1,liney);
		
		if(pblk->pb_currstate&DISABLED)
		{
			vswr_mode(VDI_ID,MD_TRANS); vsf_interior(VDI_ID,2);
			vsf_style(VDI_ID,4);
			fly_bar(x-1,y-1,b+3,h+3,WHITE); 
			vswr_mode(VDI_ID,MD_REPLACE); vsf_interior(VDI_ID,1);
		}	
		
		return(pblk->pb_currstate&=~(SELECTED|DISABLED));
	}
	if((!(flags&EXIT))&&(!(flags&RBUTTON)))	/* Selectable mit/ohne Touchexit und ohne Exit */
	{
		int bb=(atrbu[8]-1)*2,bh=atrbu[9]-2;
	
		vsl_color(VDI_ID,BLACK);
		fly_rectangle(x,y,bb,bh);
		
		if(pblk->pb_currstate&SELECTED)
			vsl_color(VDI_ID,BLACK);
		else
			vsl_color(VDI_ID,WHITE);
		
		fly_line(x+1,y+1,x+bb-1,y+bh-1);
		fly_line(x+bb-1,y+1,x+1,y+bh-1);
		
		v_gtext(VDI_ID,x+16,y+atrbu[7],zsp);
		linex=x+(Position*atrbu[8])+16;
		liney=y+atrbu[7]+Cnt;
		vsl_color(VDI_ID,BLACK);
		if(Position!=ERROR) 
			fly_line(linex,liney,linex+atrbu[8]-1,liney);
		
		if(pblk->pb_currstate&DISABLED)
		{
			vswr_mode(VDI_ID,MD_TRANS); vsf_interior(VDI_ID,2);
			vsf_style(VDI_ID,4);
			fly_bar(x-1,y-1,b+3,h+3,WHITE); 
			vswr_mode(VDI_ID,MD_REPLACE); vsf_interior(VDI_ID,1);
		}	
		
		return(pblk->pb_currstate&=~(SELECTED|DISABLED));
	}
	return(0);  	/* Hier kommt das Programm nie ran, aber der
					   Compiler beschwert sich sonst !!          */
}

static int cdecl FLY_text(PARMBLK *pblk)
{
	int x=pblk->pb_x,
		y=pblk->pb_y,
		b=pblk->pb_w,atrbu[10],Pos;
	
	if(VERZERRT==1) Pos=2; else Pos=3;
	vqt_attributes(VDI_ID,atrbu);
	v_gtext(VDI_ID,x,y+atrbu[7],SaveAll[YAD][pblk->pb_obj].string);
	
	vsl_color(VDI_ID,BLACK);
	fly_line(x,y+atrbu[7]+Pos,x+b,y+atrbu[7]+Pos);
	
	return(pblk->pb_currstate);
}

static int cdecl FLY_boxes(PARMBLK *pblk)
{
	int x=pblk->pb_x,
		y=pblk->pb_y,
		b=pblk->pb_w,
		h=pblk->pb_h,atrbu[10],Pos;
	
	vqt_attributes(VDI_ID,atrbu);

	vsl_color(VDI_ID,BLACK);
	fly_rectangle(x,y,b,h);
	if(VERZERRT==1) Pos=2; else Pos=5;
	v_gtext(VDI_ID,x+atrbu[8],y+(atrbu[9]/2)-Pos,SaveAll[YAD][pblk->pb_obj].string);

	return(pblk->pb_currstate);
}

static int cdecl FLY_radio(PARMBLK *pblk)
{
	int obj=pblk->pb_obj,atrbu[10],
		x=pblk->pb_x-1,y=pblk->pb_y-1,b=pblk->pb_w+1,h=pblk->pb_h+1;
					
	if(SaveAll[YAD][obj].old_type==0x161b)
	{
		fly_bar(x+1,y+1,b-2,h-2,WHITE);
		fly_circle(x,y,1);
		fly_rectangle(x,y,b,h);
	}	
	else
	{
		fly_bar(x+1,y+1,b-2,h-2,WHITE);
		vqt_attributes(VDI_ID,atrbu);
		v_gtext(VDI_ID,x+1,y+atrbu[7]+1,SaveAll[YAD][obj].string);
		fly_rectangle(x,y,b,h);
	}
				
	return(pblk->pb_currstate&=~SELECTED);
}