/* Fontauswahlbox */
/*****************************************************************************
*
*											  7UP
*										Modul: FONTSEL.C
*									 (c) by TheoSoft '90
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>

#include "alert.h"

#include "forms.h"
#include "windows.h"
#include "7up.h"

#define MAXENTRIES     5
#define MAXLETTERS    32
#define MAXSPACES     18
#define POINT_MAX  32767
#define notnull(a) (((a)>0)?(a):(1))
#define VEKTOR_KENNZEICHEN 250

#define MONO 1
#define FLAGS15 0x8000

int additional=0;

int tid,tsize,tattr; /* topId, topSize, topAttr */
extern WINDOW *twp; /* Topwindowpointer */
extern char alertstr[256];
extern int boxh;

static int propfonts=FALSE;

long *get_cookie(long cookie);
/*
void objc_update(OBJECT *tree, int obj, int depth)
{
	int obx,oby;
	objc_offset(tree,obj,&obx,&oby);
	if(obj==ROOT) /* 3 Pixel Rand beachten */
		objc_draw(tree,obj,depth,obx-3,oby-3,
			tree[obj].ob_width+6,tree[obj].ob_height+6);
	else
		objc_draw(tree,obj,depth,obx,oby,
			tree[obj].ob_width,tree[obj].ob_height);
}
*/
void objc_update(OBJECT *tree, int obj, int depth)
{
	int obx,oby;
	int full[4],area[4],array[4];
	extern int windials, dial_handle;
		
	objc_offset(tree,obj,&array[0],&array[1]);
	if(obj==ROOT) /* 3 Pixel Rand beachten */
	{
		array[0]-=3;
		array[1]-=3;
		array[2]=tree[obj].ob_width+6;
		array[3]=tree[obj].ob_height+6;
	}
	else
	{
		array[2]=tree[obj].ob_width;
		array[3]=tree[obj].ob_height;
	}
	if(windials && dial_handle!=-1 && !(tree->ob_flags & FLAGS15))
	{
		wind_update(BEG_UPDATE);
		_wind_get( 0, WF_WORKXYWH,  &full[0], &full[1], &full[2], &full[3]);
		_wind_get(dial_handle, WF_FIRSTXYWH, &area[0], &area[1], &area[2], &area[3]);
		while( area[2] && area[3] )
		{
			if(rc_intersect(full,area))
				if(rc_intersect(array,area))
					objc_draw(tree,obj,depth,area[0],area[1],area[2],area[3]);
			_wind_get(dial_handle, WF_NEXTXYWH,&area[0],&area[1],&area[2],&area[3]);
		}
		wind_update(END_UPDATE);
	}
	else
	{
		objc_draw(tree,obj,depth,array[0],array[1],array[2],array[3]);
	}
}

void set_vslider(OBJECT *tree, int ext, int slide,  int newpos)
{
	long oldpos;
	oldpos=tree[ext].ob_height-tree[slide].ob_height;
	tree[slide].ob_y=(int)(oldpos*(long)newpos/1000L);
}

static void set_hslider(OBJECT *tree, int ext, int slide,  int newpos)
{
	long oldpos;
	oldpos=tree[ext].ob_width-tree[slide].ob_width;
	tree[slide].ob_x=(int)(oldpos*(long)newpos/1000L);
}

static int selfontsize(int size, int sizearray[])
{
	register int i;
	for(i=0; sizearray[i]!=-1; i++)
		if(size==sizearray[i])
			return(i);
	for(i=1; sizearray[i]!=-1; i++)
		if(size>sizearray[i-1] && size<sizearray[i])
		{
			if(abs(size-sizearray[i-1]) < abs(size-sizearray[i]))
				return(i-1);
			else
				return(i);
		}
	return(0);
}

static int isprop(int handle, int id)
{
	int ret, width, tst_width, dummy;

	if(propfonts)
		return(FALSE);
	
	vst_point(handle,10,&ret,&ret,&ret,&ret);
	vqt_width(handle, 'l', &width, &dummy, &dummy);		/* Breite 1. Zeichen */
	vqt_width(handle, 'W', &tst_width, &dummy, &dummy);  /* Breite 2. Zeichen */
	if (tst_width != width)						/* Ungleich? */
		return(TRUE);								 /* Ja -> Font ist proportional */
	return(FALSE);		/* Alle Zeichen gleich breit -> Font ist monospaced */
}

static void fsreverse(int *a, int *b, int cnt)
{
	register int i;
	for(i=cnt; i>0; i--)
		*a++ = *b--;
}

static int scan_font_names(int handle, FONTINFO *font, int add, int ftype)
{
	FONTINFO *fip;
	int id,i,j,k,m,ret,vektor;
	char *cp,name[64];
	int prop=0,fstemp[MAXSIZES+1];

	for(i=1,m=0; i<=add; i++)
	{
		memset(name,0,sizeof(name));
		id=vqt_name(handle,i,name);
		vektor=name[32];
		name[32]=0;
      if(stricmp(name,"dummy font"))
      {
			vst_font(handle,id);
			if(ftype && isprop(handle, id))
			{
				prop++;
			}
			else
			{
				fip=&font[m++];
				strcpy(fip->name,name);
				/* mehrfache Blanks killen */
				cp=strchr(fip->name,' ');
				while(cp)
				{
					if(*(cp+1L) == ' ')
						strcpy(cp,cp+1L);
					cp=strchr((*(cp+1L)==' '?cp:cp+1L),' ');
				}
				fip->id=id;
				fip->attr=vektor;
				fstemp[0]=-1;
				for(j=POINT_MAX,k=1; j>0 && k<=MAXSIZES; /* nix */)
				{
					fstemp[k]=j=vst_point(handle,j,&ret,&ret,&ret,&ret);
					if(fstemp[k]==fstemp[k-1])
						break;
					else
					  j--,k++;
				}
				fsreverse(fip->size,&fstemp[k-1],k);
			}
		}
	}
	return(add-prop);
}
/*
static void Three_D_Look(OBJECT *tree, int obj)
{
	tree[obj].ob_flags|=0x0200;
	tree[obj].ob_flags|=0x0400;
	tree[obj].ob_x+=2;
	tree[obj].ob_y+=2;
	tree[obj].ob_width-=4;
	tree[obj].ob_height-=4;
}
*/
int fontsel_input(OBJECT *tree, int handle, int fontid, int fontsize, int ncount, int ftype, int *id, int *size)
{
	static FONTINFO *fip;
	static long nf2=0,sf2=0;

	FONTINFO *font;
	long nfirst,sfirst,hfirst,newpos=0;
	int scount,kstate,exit_obj,done=FALSE;
	int i,k,ret,mx,my;
	int obx,oby;

	char string[34];

	graf_mkstate(&ret,&ret,&ret,&kstate); /* geheim, bei CTRL wird alles angezeigt */
	if(kstate & K_CTRL)
		propfonts=TRUE;

	if((font=(FONTINFO *)calloc(ncount,sizeof(FONTINFO)))==NULL)
	{
		return(-1); /* Fehler! */
	}
	ncount=scan_font_names(handle, font, ncount, ftype);

	/* Fontnamenslidergrîûe Ñndert sich nie */
	tree[FTHSLD].ob_width=MAXSPACES*tree[FTHBOX].ob_width/MAXLETTERS;
	set_hslider(tree,FTHBOX,FTHSLD,0);
	tree[FTSLIDE].ob_height=
		 MAXENTRIES*tree[FTBOX].ob_height/max(MAXENTRIES,ncount);
	
	/* MT 2.11.94 */
	tree[FTSLIDE].ob_height=max(boxh,tree[FTSLIDE].ob_height);
	
	set_vslider(tree,FTBOX,FTSLIDE,0);

/**************************************************************************/
/* letzte OK-Werte einstellen, falls verstellt und Abbruch gedrÅckt wurde */
/**************************************************************************/
	nfirst=nf2;
	sfirst=sf2;
	hfirst=0;

	for(i=nfirst; i<ncount /*&& i<MAXFONTS*/; i++) /* erstmal suchen,... */
		if(font[i].id==fontid)				  /* falls nicht in Box */
		{
			fip=&font[i];
			if((i-nfirst)>MAXENTRIES)
				nf2=nfirst=(i-MAXENTRIES+1);
		}

	/* Namenseinstellung */
	for(i=FTYPE1; i<=FTYPE5; i++)
	{
		tree[i].ob_state&=~SELECTED;
		tree[i].ob_flags&=~SELECTABLE;
	}
	/* falscher (int) cast */
	newpos=/*(int)*/(nfirst*1000L)/notnull(ncount-MAXENTRIES);
	newpos=min(newpos,1000);
	newpos=max(0,newpos);
	set_vslider(tree,FTBOX,FTSLIDE,newpos);
	newpos=/*(int)*/(hfirst*1000L)/(MAXLETTERS-MAXSPACES);
	newpos=min(newpos,1000);
	newpos=max(0,newpos);
	set_hslider(tree,FTHBOX,FTHSLD,newpos);
	for(i=nfirst,k=0; i<ncount /*&& i<MAXFONTS*/ && k<MAXENTRIES; i++,k++)
	{
		sprintf(string," %-16s ",&font[i].name[hfirst]);
		/* MT 5.11.94 Vektorfonts kennzeichnen */
		if(font[i].attr) string[0]=VEKTOR_KENNZEICHEN;
		
		string[MAXSPACES]=0;
		form_write(tree,FTYPE1+k,string,FALSE);
		tree[FTYPE1+k].ob_flags|=SELECTABLE;
		if(font[i].id==fontid)
		{
			tree[FTYPE1+k].ob_state|=SELECTED;
			fip=&font[i];
		}
	}
	for(; k<MAXENTRIES; k++)
	{
		memset(string,' ',MAXLETTERS);
		string[MAXLETTERS]=0;
		form_write(tree,FTYPE1+k,string,FALSE);
	}

	/* Punkteinstellung */
	for(i=FSIZE1; i<=FSIZE5; i++)
	{
		form_write(tree,i,"",FALSE);
		tree[i].ob_state&=~SELECTED;
		tree[i].ob_flags&=~SELECTABLE;
	}
	for(scount=0; fip->size[scount]!=-1; scount++)
		;
	for(i=sfirst; i<scount && i<MAXSIZES; i++) /* erstmal suchen,... */
		if(fip->size[i]==fontsize)				  /* falls nicht in Box */
		{
			if((i-sfirst)>MAXENTRIES)
				sf2=sfirst=(i-MAXENTRIES+1);
		}
	tree[FSSLIDE].ob_height=MAXENTRIES*tree[FSBOX].ob_height/max(MAXENTRIES,scount);

	/* MT 2.11.94 */
	tree[FSSLIDE].ob_height=max(boxh,tree[FSSLIDE].ob_height);

   newpos=/*(int)*/(sfirst*1000L)/notnull(scount-MAXENTRIES);
	newpos=min(newpos,1000);
	newpos=max(0,newpos);
	set_vslider(tree,FSBOX,FSSLIDE,newpos);

	for(i=sfirst,k=0; i<MAXSIZES && k<MAXENTRIES && i<scount; i++,k++)
	{
		sprintf(tree[FSIZE1+k].ob_spec.tedinfo->te_ptext," %3d ",fip->size[i]);
		tree[FSIZE1+k].ob_flags|=SELECTABLE;
		if(fip->size[i]==fontsize)
		{
			tree[FSIZE1+k].ob_state|=SELECTED;
         sprintf(string,"%3d",fontsize);
         form_write(tree,FSARBPT,string,FALSE);
		}
	}
/**************************************************************************/
	tid=*id=fontid,tsize=*size=fontsize,tattr=fip?fip->attr:0;
/*
	if(_GemParBlk.global[0] >=0x0340) /* Ab Falcon Muster Ñndern */
	{
		tree[FNTITLE].ob_spec.tedinfo->te_color&=~(7<<4); /* lîschen */
		tree[FNTITLE].ob_spec.tedinfo->te_color|=(4<<4);  /* neues Muster 4 */
		tree[FSTITLE].ob_spec.tedinfo->te_color&=~(7<<4); /* lîschen */
		tree[FSTITLE].ob_spec.tedinfo->te_color|=(4<<4);  /* neues Muster 4 */
		tree[FTBOX  ].ob_spec.obspec.fillpattern=4;
		tree[FTHBOX ].ob_spec.obspec.fillpattern=4;
		tree[FSBOX  ].ob_spec.obspec.fillpattern=4;
	}
*/
   if(vq_vgdos()==0x5F46534D) /* Vektor-GDOS */
   {
      tree[FSARBPT].ob_flags&=~HIDETREE;
      tree[FSARBPT].ob_flags|=EDITABLE;
   }
	else
	{
      tree[FSARBPT].ob_flags|=HIDETREE;
      tree[FSARBPT].ob_flags&=~EDITABLE;
   }
	form_exopen(tree,0);
	do
	{
		exit_obj=form_exdo(tree,0);
		graf_mkstate(&mx,&my,&ret,&kstate);
		switch(exit_obj)
		{
			case FTLF:
				if(hfirst>0)
					hfirst--;
				else
					exit_obj=-1;  /* lîschen */
				break;
			case FTRT:
				if(hfirst<(MAXLETTERS-MAXSPACES)) /* MAXSPACES+8=MAXLETTERS */
					hfirst++;
				else
					exit_obj=-1;
				break;
         case FTUP:
				if(kstate & (K_LSHIFT|K_RSHIFT))
				{
					if((nfirst-MAXENTRIES)>0)
						nfirst-=MAXENTRIES;
					else
						nfirst=0;
				}
				else
				{
	            if(nfirst>0)
	               nfirst--;
	            else
	               exit_obj=-1;
	         }
            break;
         case FTDN:
				if(kstate & (K_LSHIFT|K_RSHIFT))
				{
					if((nfirst+MAXENTRIES)<(ncount-MAXENTRIES))
						nfirst+=MAXENTRIES;
					else
						nfirst=ncount-MAXENTRIES;
				}
				else
				{
	            if(nfirst<ncount-MAXENTRIES)
	               nfirst++;
	            else
	               exit_obj=-1;
	         }
            break;
			case FSUP:
				if(sfirst>0)
					sfirst--;
				else
					exit_obj=-1;
				break;
			case FSDN:
				if(sfirst<scount-MAXENTRIES)
					sfirst++;
				else
					exit_obj=-1;
				break;
			case FTHSLD:
				graf_mouse(FLAT_HAND,NULL);
				newpos=graf_slidebox(tree,FTHBOX,FTHSLD,0);
				graf_mouse(ARROW,NULL);
				hfirst=((newpos*(MAXLETTERS-MAXSPACES))/1000L);
				break;
			case FTSLIDE:
				graf_mouse(FLAT_HAND,NULL);
				newpos=graf_slidebox(tree,FTBOX,FTSLIDE,1);
				graf_mouse(ARROW,NULL);
				nfirst=((newpos*(ncount-MAXENTRIES))/1000L);
				break;
			case FSSLIDE:
				graf_mouse(FLAT_HAND,NULL);
				newpos=graf_slidebox(tree,FSBOX,FSSLIDE,1);
				graf_mouse(ARROW,NULL);
				sfirst=((newpos*(scount-MAXENTRIES))/1000L);
				break;
			case FTHBOX:
				objc_offset(tree,FTHSLD,&obx,&oby);
				if(mx>obx)
				{
					if((hfirst+MAXSPACES)<(MAXLETTERS-MAXSPACES))
						hfirst+=MAXSPACES;
					else
						hfirst=MAXLETTERS-MAXSPACES;
				}
				else
				{
					if((hfirst-MAXSPACES)>0)
						hfirst-=MAXSPACES;
					else
						hfirst=0;
				}
				break;
			case FTBOX:
				objc_offset(tree,FTSLIDE,&obx,&oby);
				if(my>oby)
				{
					if((nfirst+MAXENTRIES)<(ncount-MAXENTRIES))
						nfirst+=MAXENTRIES;
					else
						nfirst=ncount-MAXENTRIES;
				}
				else
				{
					if((nfirst-MAXENTRIES)>0)
						nfirst-=MAXENTRIES;
					else
						nfirst=0;
				}
				break;
			case FSBOX:
				objc_offset(tree,FSSLIDE,&obx,&oby);
				if(my>oby)
				{
					if((sfirst+MAXENTRIES)<(scount-MAXENTRIES))
						sfirst+=MAXENTRIES;
					else
						sfirst=scount-MAXENTRIES;
				}
				else
				{
					if((sfirst-MAXENTRIES)>0)
						sfirst-=MAXENTRIES;
					else
						sfirst=0;
				}
				break;
			case FTYPE1:
			case FTYPE1+1:
			case FTYPE1+2:
			case FTYPE1+3:
			case FTYPE1+4:
			case FTYPE1+5:
				if(tree[exit_obj].ob_flags & SELECTABLE &&
				 !(tree[exit_obj].ob_state & DISABLED))
				{
					for(i=FSIZE1; i<=FSIZE5; i++)
					{
						tree[i].ob_state &= ~SELECTED;
						tree[i].ob_flags &= ~SELECTABLE;
					}
					fip=&font[exit_obj-FTYPE1+nfirst];
					*id=fip->id;
					for(scount=0; fip->size[scount]!=-1; scount++)
						;
					tree[FSSLIDE].ob_height=
						MAXENTRIES*tree[FSBOX].ob_height/max(MAXENTRIES,scount);
					
					/* MT 2.11.94 */
					tree[FSSLIDE].ob_height=max(boxh,tree[FSSLIDE].ob_height);
					
					set_vslider(tree,FSBOX,FSSLIDE,0);
					objc_update(tree,FSBOX,MAX_DEPTH);
					k=selfontsize(fontsize,fip->size);
					*size=fip->size[k];
					for(i=0; i<=(FSIZE5-FSIZE1)  && fip->size[i]!=-1; i++)
					{
						tree[FSIZE1+i].ob_flags |= SELECTABLE;
						sprintf(tree[FSIZE1+i].ob_spec.tedinfo->te_ptext,
							" %3d ",fip->size[i]);
						if(k==i) /* Fontsize == Eintrag? */
						{
							tree[FSIZE1+i].ob_state |= SELECTED;
				         sprintf(string,"%3d",fip->size[i]);
				         form_write(tree,FSARBPT,string,TRUE);
						}
						objc_update(tree,FSIZE1+i,0);
					}
					for(; i<=(FSIZE5-FSIZE1); i++)
						form_write(tree,FSIZE1+i,"     ",TRUE);
					sfirst=0;
				}
				break;
			case FSHELP:
				form_alert(1,Afontsel[0]);
				objc_change(tree,exit_obj,0,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height,tree[exit_obj].ob_state&~SELECTED,TRUE);
				break;
			case FSOK:
			case FSABBR:
				done=TRUE;
				break;
		}
		if(exit_obj&0x8000) /* verlassen bei Doppelklick */
		{
			switch(exit_obj&=0x7FFF)
			{
				case FTYPE1:
				case FTYPE1+1:
				case FTYPE1+2:
				case FTYPE1+3:
				case FTYPE1+4:
				case FTYPE1+5:
				case FSIZE1:
				case FSIZE1+1:
				case FSIZE1+2:
				case FSIZE1+3:
				case FSIZE1+4:
				case FSIZE1+5:
					objc_change(tree,FSOK,0,tree->ob_x,tree->ob_y,
									tree->ob_width,tree->ob_height,SELECTED,TRUE);
					done=TRUE;
					break;
			case FTLF:
				if(hfirst>0)
					hfirst=0;
				else
					exit_obj=-1;  /* lîschen */
				break;
			case FTRT:
				if(hfirst<MAXLETTERS-MAXSPACES) /* MAXSPACES+8=MAXLETTERS */
					hfirst=MAXLETTERS-MAXSPACES;
				else
					exit_obj=-1;
				break;
			case FTUP:
				if(nfirst>0)
					nfirst=0;
				else
					exit_obj=-1;
				break;
			case FTDN:
				if(nfirst<ncount-MAXENTRIES)
					nfirst=ncount-MAXENTRIES;
				else
					exit_obj=-1;
				break;
			case FSUP:
				if(sfirst>0)
					sfirst=0;
				else
					exit_obj=-1;
				break;
			case FSDN:
				if(sfirst<scount-MAXENTRIES)
					sfirst=scount-MAXENTRIES;
				else
					exit_obj=-1;
				break;
			case FSSHOW:
         case FSARBPT:
	         form_read(tree,FSARBPT,string);
   		   if(*size!=atoi(string))
   		   {
         		*size=atoi(string);
					tid=*id,tsize=*size,tattr=fip?fip->attr:0;
					objc_update(tree,FSSHOW,0);
				}
            break;
			}
		}
		switch(exit_obj)
		{
			case FTLF:
			case FTRT:
			case FTHBOX:
			case FTHSLD:
				newpos=/*(int)*/(hfirst*1000L)/(MAXLETTERS-MAXSPACES);
				newpos=min(max(0,newpos),1000);
				set_hslider(tree,FTHBOX,FTHSLD,newpos);
				objc_update(tree,FTHBOX,MAX_DEPTH);
				for(i=nfirst,k=0; /*i<MAXFONTS &&*/ k<MAXENTRIES && k<ncount; i++,k++)
				{
					sprintf(string," %-16s ",&font[i].name[hfirst]);
					/* MT 5.11.94 Vektorfonts kennzeichnen */
					if(font[i].attr) string[0]=VEKTOR_KENNZEICHEN;
					string[MAXSPACES]=0;
					form_write(tree,FTYPE1+k,string,TRUE);
				}
				break;
			case FTUP:
			case FTDN:
			case FTBOX:
			case FTSLIDE:
				if(ncount>MAXENTRIES)
				{
					for(i=FTYPE1; i<=FTYPE5; i++)
						tree[i].ob_state&=~SELECTED;
					newpos=/*(int)*/(nfirst*1000L)/notnull(ncount-MAXENTRIES);
					newpos=min(max(0,newpos),1000);
					set_vslider(tree,FTBOX,FTSLIDE,newpos);
					objc_update(tree,FTBOX,MAX_DEPTH);
					for(i=nfirst,k=0; /*i<MAXFONTS &&*/ k<MAXENTRIES; i++,k++)
					{
						sprintf(string," %-16s ",&font[i].name[hfirst]);
						/* MT 5.11.94 Vektorfonts kennzeichnen */
						if(font[i].attr) string[0]=VEKTOR_KENNZEICHEN;
						string[MAXSPACES]=0;
						form_write(tree,FTYPE1+k,string,TRUE);
						if(font[i].id==*id)
						{
							tree[FTYPE1+k].ob_state|=SELECTED;
							objc_update(tree,FTYPE1+k,0);
						}
					}
				}
				break;
			case FSUP:
			case FSDN:
			case FSBOX:
			case FSSLIDE:
				if(scount>MAXENTRIES)
				{
					for(i=FSIZE1; i<=FSIZE5; i++)
						tree[i].ob_state&=~SELECTED;
					newpos=/*(int)*/(sfirst*1000L)/notnull(scount-MAXENTRIES);
					newpos=min(max(0,newpos),1000);
					set_vslider(tree,FSBOX,FSSLIDE,newpos);
					objc_update(tree,FSBOX,MAX_DEPTH);
					for(i=sfirst,k=0; i<MAXSIZES && k<MAXENTRIES; i++,k++)
					{
						if(fip->size[i]==*size)
						{
							tree[FSIZE1+k].ob_state|=SELECTED;
				         sprintf(string,"%3d",fip->size[i]);
				         form_write(tree,FSARBPT,string,TRUE);
						}
						sprintf(tree[FSIZE1+k].ob_spec.tedinfo->te_ptext,
							" %3d ",fip->size[i]);
						objc_update(tree,FSIZE1+k,0);
					}
				}
				break;
		}
		switch(exit_obj)
		{
			case FTYPE1:
			case FTYPE1+1:
			case FTYPE1+2:
			case FTYPE1+3:
			case FTYPE1+4:
			case FTYPE1+5:
			case FSIZE1:
			case FSIZE1+1:
			case FSIZE1+2:
			case FSIZE1+3:
			case FSIZE1+4:
			case FSIZE1+5:
				for(i=FTYPE1,k=0; i<=FTYPE5; i++,k++)
					if(tree[i].ob_state & SELECTED)
					{
						fip=&font[k+nfirst];
						*id=fip->id;
						break;
					}
				for(i=FSIZE1,k=0; i<=FSIZE5; i++,k++)
					if(tree[i].ob_state & SELECTED)
					{
						*size=fip->size[k+sfirst];
						tid=*id,tsize=*size,tattr=fip?fip->attr:0;
						objc_update(tree,FSSHOW,0);
			         sprintf(string,"%3d",*size);
			         form_write(tree,FSARBPT,string,TRUE);
					}
				break;
		}
	}
	while(done!=TRUE);

	form_exclose(tree, exit_obj,0);
	tree[FSOK].ob_state&=~SELECTED;
	free(font);
	vst_font(handle,fontid); /* Alten Zustand wieder setzen */
	vst_point(handle,fontsize,&ret,&ret,&ret,&ret);

	switch(exit_obj)
	{
		case FTYPE1:
		case FTYPE1+1:
		case FTYPE1+2:
		case FTYPE1+3:
		case FTYPE1+4:
		case FTYPE1+5:
		case FSIZE1:
		case FSIZE1+1:
		case FSIZE1+2:
		case FSIZE1+3:
		case FSIZE1+4:
		case FSIZE1+5:
		case FSOK:
			nf2=nfirst;
			sf2=sfirst;
         form_read(tree,FSARBPT,string);
         if(*size!=atoi(string))
            *size =atoi(string);
			return(TRUE);
	}
	*id=*size=-1;
	return(FALSE);
}

void hndl_font(WINDOW *wp, OBJECT *tree)	 /* geraete direkt ansprechen */
{
	int id,size,ret,kstate;
	extern int work_out[];

#if MSDOS
	void far *l;
	long fsize;
#endif

	if(wp)
	{
		if(!(wp->w_state & GEMFONTS))
		{
			graf_mouse(BUSY_BEE,0L);
			vq_extnd(wp->vdihandle,0,work_out);
#if GEMDOS
			if(vq_gdos())
			{
				additional=vst_load_fonts(wp->vdihandle,0)+work_out[10];
				wp->w_state|=GEMFONTS;
			}
			else
				additional=work_out[10]; /* Nur 6x6 system font */
#else
			fsize=farcoreleft()-64*1024L;
			if(fsize>0 && (l=farmalloc(fsize))!=NULL)	 /*64*/
			{
				additional=vst_ex_load_fonts(wp->vdihandle, 0, 4096, 0)+work_out[10]; /*4096*/
				wp->w_state|=GEMFONTS;
				farfree(l);
			}
			else
				additional=work_out[10];
#endif
			graf_mouse(ARROW,0L);
		}
		twp=wp;
		switch(fontsel_input(tree,wp->vdihandle,wp->fontid,wp->fontsize,additional,MONO,&id,&size))
		{
			case TRUE:
				if(id!=wp->fontid || size!=wp->fontsize)
					Wnewfont(wp,id,size);
				graf_mkstate(&ret,&ret,&ret,&kstate);
				if(kstate & (K_LSHIFT|K_RSHIFT))
				{
					sprintf(alertstr,Afontsel[2],id,size);
					form_alert(1,alertstr);
				}
				break;
			case FALSE:
				break;
			case -1:
				form_alert(1,Afontsel[1]);
				break;
		}
	}
}
