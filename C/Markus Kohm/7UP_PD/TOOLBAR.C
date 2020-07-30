/* Fenster Toolbar */
/*****************************************************************************
*
*											  7UP
*									  Modul: TOOLBAR.C
*									 (c) by TheoSoft '93
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <aes.h>
#include <vdi.h>

#include "windows.h"
#include "7up.h"

#include "alert.h"
#include "toolbar.h"

#define FLAGS9  0x0200
#define FLAGS10 0x0400

extern WINDOW *twp;

int tabbar = TRUE;

int _wind_get(int handle, int field, int *xr, int *yr, int *wr, int *hr);

static void toolbar_update(WINDOW *wp, OBJECT *tree, int obj, int depth)
{
	int full[4],area[4],array[4];
	
	if(wp && tree)
	{
		objc_offset(tree,obj,&array[0],&array[1]);
		array[2]=tree[obj].ob_width;
		array[3]=tree[obj].ob_height;

		array[0]-=2;
		array[1]-=2;
		array[2]=tree[obj].ob_width+4;
		array[3]=tree[obj].ob_height+4;

		wind_update(BEG_UPDATE);
		_wind_get( 0, WF_WORKXYWH,  &full[0], &full[1], &full[2], &full[3]);
		_wind_get(wp->wihandle, WF_FIRSTXYWH, &area[0], &area[1], &area[2], &area[3]);
		while( area[2] && area[3] )
		{
			if(rc_intersect(full,area))
				if(rc_intersect(array,area))
					objc_draw(tree,obj,depth,area[0],area[1],area[2],area[3]);
			_wind_get(wp->wihandle, WF_NEXTXYWH,&area[0],&area[1],&area[2],&area[3]);
		}
		wind_update(END_UPDATE);
	}
}

void toolbar_do(WINDOW *wp, OBJECT *tree, int x, int y, int bstate, int kstate)
{
	int i,oum,msgbuf[8];
	char *cp;
	extern int gl_apid;
	
   if(wp && tree)
   {
      if((oum=objc_find(tree, ROOT, MAX_DEPTH, x, y))>0) /* null, nicht -1! */
      {
			if((EXOB_TYPE(tree[oum].ob_type) == TABBAR) || (tree[oum].ob_type == G_USERDEF))
			{
				if(tree[oum].ob_type == G_USERDEF)
					cp=(char *)((TEDINFO *)tree[oum].ob_spec.userblk->ub_parm)->te_ptext;
				else
					cp=tree[oum].ob_spec.tedinfo->te_ptext;
	
				if(kstate & (K_LSHIFT|K_RSHIFT)) /* Reseten der Tableiste */
				{
					if(form_alert(1,Atoolbar[0])==2)
					{
						memset(cp,'.',STRING_LENGTH);
	
						cp[0] = '[';
						cp[wp->umbruch-2] = ']';
						cp[STRING_LENGTH] = 0;
						for(i=1; i<STRING_LENGTH; i++)
							if( ! (i%wp->tab))
								cp[i] = TABSIGN; /*Htchen im Zeichensatz*/
	
						cp[STRING_LENGTH] = 0;
						twp=wp;
						toolbar_update(wp,tree,oum,1);
					}
				}
				else /* Tabulator setzen/l”schen */
				{
					i = (x-wp->xwork+wp->wfirst)/wp->wscroll;
					if( i>0 && i<MAX_LEN-1)
					{
						if(bstate==2)
							cp[i] = DEZTAB;  /* Raute */
						else
						{
							if(cp[i] == '.')
								cp[i] = TABSIGN; /* Htchen */
							else
								cp[i] = '.';
						}
						twp=wp;
						toolbar_update(wp,tree,oum,1);
					}
				}
				return(oum);
			}

			if( (tree[oum].ob_flags & SELECTABLE) && 
			   !(tree[oum].ob_state & DISABLED))
			{
				if(EXOB_TYPE(tree->ob_type) == 2) /* neue Buttonversion */
				{
					tree[oum-1].ob_flags&=~FLAGS10;

					tree[oum-1].ob_flags|=SELECTABLE;
					form_button(tree,oum-1,1,&i);
					toolbar_update(wp,tree,oum-1,MAX_DEPTH);
					tree[oum-1].ob_flags&=~SELECTABLE;
				}
				else
					form_button(tree,oum,1,&i);
				
				if(oum>0)
				{
					msgbuf[0]=MN_SELECTED;
					msgbuf[1]=gl_apid;
					msgbuf[2]=0;
					msgbuf[3]=WINFILE;
					msgbuf[4]=EXOB_TYPE(tree[oum].ob_type);
					msgbuf[5]=0;
					msgbuf[6]=0;
					msgbuf[7]=0;
					appl_write(gl_apid,16,msgbuf);
					return(oum);
				}
			}
      }
   }
   return(FALSE);
}

int toolbar_tnormal(WINDOW *wp, OBJECT *tree, int menuitem, int mode)
{
	WORD obj;
	OBJECT *ob;
	
	if(wp && tree)
	{
		obj = 0;
	   do
	   {
			ob = &tree [++obj];
			if(EXOB_TYPE(ob->ob_type) == menuitem)
			{
				if(EXOB_TYPE(tree->ob_type) == 2) /* neue Buttonversion  */
				{
					if(mode)
						tree[obj-1].ob_state&=~SELECTED;
					else
						tree[obj-1].ob_state|=SELECTED;
					toolbar_update(wp,tree,obj-1,MAX_DEPTH);
/*
					if(mode)
					{
						objc_change(tree,obj-1,0,tree->ob_x,tree->ob_y,
														tree->ob_width,tree->ob_height,
														tree[obj-1].ob_state&~SELECTED,FALSE);
					}
					else
					{
						objc_change(tree,obj-1,0,tree->ob_x,tree->ob_y,
														tree->ob_width,tree->ob_height,
														tree[obj-1].ob_state|SELECTED,FALSE);
					}
					toolbar_update(wp,tree,obj-1,0);
					toolbar_update(wp,tree,obj,0);
*/
				}
				else
				{
					if(mode)
						tree[obj].ob_state&=~SELECTED;
					else
						tree[obj].ob_state|=SELECTED;
					toolbar_update(wp,tree,obj,0);
/*
					if(mode)
						objc_change(tree,obj,0,tree->ob_x,tree->ob_y,
														tree->ob_width,tree->ob_height,
														tree[obj].ob_state&~SELECTED,FALSE);
					else
						objc_change(tree,obj,0,tree->ob_x,tree->ob_y,
														tree->ob_width,tree->ob_height,
														tree[obj].ob_state|SELECTED,FALSE);
					toolbar_update(wp,tree,obj,0);
*/
				}
				return(menuitem);
			}
		} 
		while (! (ob->ob_flags & LASTOB));
	}
	return(0);
}

void toolbar_adjust(WINDOW *wp)
{
	WORD obj, type;
	OBJECT *ob;

   if(wp && wp->toolbar) /* Toolbar anpassen */
   {
		if(EXOB_TYPE(wp->toolbar->ob_type) == 1) /* senkrecht */
		{
			wp->toolbar->ob_x     =wp->xwork-wp->toolbar->ob_width-wp->wscroll/2;
			wp->toolbar->ob_y     =wp->ywork;
			wp->toolbar->ob_height=wp->hwork;
		}
		else /* waagerecht */
		{
			wp->toolbar->ob_x    =wp->xwork-wp->wscroll/2;
			wp->toolbar->ob_y    =wp->ywork-wp->toolbar->ob_height;
			wp->toolbar->ob_width=wp->wwork+wp->wscroll/2;

			obj = 0;
		   do 
		   {
				ob	= &wp->toolbar[++obj];
				if((EXOB_TYPE(ob->ob_type)==TABBAR) ||
					          (ob->ob_type ==G_USERDEF))
				{
					ob->ob_width = wp->wwork; /* Weite Anpassen wg. Redraw */
				}
			} 
			while (! (ob->ob_flags & LASTOB));
		}
   }
}

int toolbar_inst(OBJECT *wtree, WINDOW * wp, OBJECT *ttree)
{
	WORD obj, chr, i;
	OBJECT *ob;
	char *cp;
	
	extern int dialbgcolor;
	
	if(wp && wtree && ttree)
	{
		ttree->ob_height++; /* ein Pixel gr”žer */
		obj = 0;
	   do 
	   {
			ob = &ttree [++obj];
			if((ob->ob_type & 0x00FF) == G_ICON)
			{
			   chr = ob->ob_spec.iconblk->ib_char;
			   chr &= 0xf000;      /* untere 12 Bits l”schen */
			   chr |= (dialbgcolor<<8); 
			   ob->ob_spec.iconblk->ib_char = chr;
			}
			if(EXOB_TYPE(ob->ob_type) == 0xFF) /* Kennzeichen fr Tableiste */
			{
				cp = (char *)malloc(STRING_LENGTH+1);
				if(cp)
				{
					memset(cp,'.',STRING_LENGTH);

					cp[0] = '[';
					cp[wp->umbruch-2] = ']';
					cp[STRING_LENGTH] = 0;
					for(i=1; i<STRING_LENGTH; i++)
						if( ! (i%wp->tab))
							cp[i] = TABSIGN; /*Htchen im Zeichensatz*/

					cp[STRING_LENGTH] = 0;

					ob->ob_spec.tedinfo->te_ptext  = cp;
					ob->ob_spec.tedinfo->te_ptmplt = cp;
					ob->ob_spec.tedinfo->te_pvalid = cp;
					ob->ob_x += wp->wscroll/2;
					ob->ob_width = wp->wwork;
					ob->ob_spec.tedinfo->te_txtlen = STRING_LENGTH-1;
					wp->tabbar = ob;

					/* als benutzerdefiniertes Objekt zeichenen lassen */
					tabbar_fix(wp);
				}
				if(!tabbar)
				{	/* verstecken und H”he verringern */
					ob->ob_flags |= HIDETREE;
					ttree->ob_height -= ob->ob_height;
					wp->tabbar = NULL;
				}
			}
		} 
		while (! (ob->ob_flags & LASTOB));
	}
	return(TRUE);
}

void tabbar_inst(WINDOW *wp, int selected)
{
	OBJECT *ob;
	int obj;
	
	extern int toolbar_zeigen;
		
	if(wp && wp->toolbar /*&& !toolbar_senkrecht*/)
	{
		obj = 0;
	   do
	   {
			ob	= &wp->toolbar[++obj];
			if((EXOB_TYPE(ob->ob_type)==TABBAR) ||
				          (ob->ob_type ==G_USERDEF))
			{
				if(selected && !tabbar)
				{	/* aufdecken und H”he vergr”žern */
					ob->ob_flags &= ~HIDETREE;
					wp->toolbar->ob_height += ob->ob_height;
					_wind_get(wp->wihandle,WF_WORKXYWH,&wp->xwork,&wp->ywork,&wp->wwork,&wp->hwork);
					form_dial(FMD_FINISH,0,0,0,0,
						wp->xwork-wp->wscroll/2,wp->ywork-wp->toolbar->ob_height,
						wp->wwork+wp->wscroll/2,wp->hwork+wp->toolbar->ob_height);
					wp->tabbar = ob;
				}
				if(!selected && tabbar)
				{	/* verstecken und H”he verringern */
					ob->ob_flags |= HIDETREE;
					wp->toolbar->ob_height -= ob->ob_height;
					_wind_get(wp->wihandle,WF_WORKXYWH,&wp->xwork,&wp->ywork,&wp->wwork,&wp->hwork);
					form_dial(FMD_FINISH,0,0,0,0,
						wp->xwork-wp->wscroll/2,wp->ywork-wp->toolbar->ob_height,
						wp->wwork+wp->wscroll/2,wp->hwork+wp->toolbar->ob_height);
					wp->tabbar = NULL;
				}
				break;
			}
		} 
		while (! (ob->ob_flags & LASTOB));
	}
}

hndl_mm1(OBJECT *tree, int mx, int my)
{
	WINDOW *wp;
	OBJECT *ob;
	int obj;
  
	static char infostr[31] = "";
	static int lastobj = -1;
  
	wp = Wgettop();
	if(wp && wp->toolbar && (wp->kind & INFO))
	{
		if((obj=objc_find(wp->toolbar, 0, MAX_DEPTH, mx, my))>0)
		{
			ob = &wp->toolbar[obj];
			if(obj != lastobj)
			{
				if(EXOB_TYPE(ob->ob_type)>0 && 
					EXOB_TYPE(ob->ob_type)<TABBAR) /* nicht bei Tabbar */
				{
					strcpy(infostr, &((char *)tree[EXOB_TYPE(ob->ob_type)].ob_spec.index)[1]);
					wind_set(wp->wihandle,WF_INFO,infostr);
					strcpy(wp->info, infostr);
					lastobj = obj;
				}
			}

			if((EXOB_TYPE(ob->ob_type)==TABBAR) ||
			             (ob->ob_type ==G_USERDEF))
			{
				sprintf(infostr," Tab: %ld",(mx-wp->xwork+wp->wfirst)/wp->wscroll+1);
				wind_set(wp->wihandle,WF_INFO,infostr);
				strcpy(wp->info, infostr);
				lastobj = obj;
			}

		}
	}
}

int Wgetnexttab(WINDOW *wp)
{
	int i;
	char *cp;
	long abscol;
	
	if(wp && wp->toolbar && wp->tabbar)
	{
		abscol=wp->col+wp->wfirst/wp->wscroll; /* absolute position */
		
		if(wp->tabbar->ob_type==G_USERDEF)
			cp=(char *)((TEDINFO *)wp->tabbar->ob_spec.userblk->ub_parm)->te_ptext;
		else
			cp=wp->tabbar->ob_spec.tedinfo->te_ptext;
		
		for(i=abscol+1; i<STRING_LENGTH; i++)
			if((cp[i] == TABSIGN) || (cp[i] == DEZTAB))
				return(i-abscol);
	}
	return(0);
}

int Wgetprevtab(WINDOW *wp)
{
	int i;
	char *cp;
	long abscol;

	if(wp && wp->toolbar && wp->tabbar)
	{
		abscol=wp->col+wp->wfirst/wp->wscroll; /* absolute position */
		
		if(wp->tabbar->ob_type==G_USERDEF)
			cp=(char *)((TEDINFO *)wp->tabbar->ob_spec.userblk->ub_parm)->te_ptext;
		else
			cp=wp->tabbar->ob_spec.tedinfo->te_ptext;
		
		for(i=abscol-1; i>=0; i--)
			if((cp[i] == TABSIGN) || (cp[i] == DEZTAB))
				return(abscol-i);
	}
	return(0);
}

char Wgettab(WINDOW *wp)
{
	char *cp;
	long abscol;
	
	if(wp && wp->toolbar && wp->tabbar)
	{
		abscol=wp->col+wp->wfirst/wp->wscroll; /* absolute position */
		
		if(wp->tabbar->ob_type==G_USERDEF)
			cp=(char *)((TEDINFO *)wp->tabbar->ob_spec.userblk->ub_parm)->te_ptext;
		else
			cp=wp->tabbar->ob_spec.tedinfo->te_ptext;
		
		return(cp[abscol]);
	}
	return('.');
}

void Wtabbarupdate(WINDOW *wp)
{
	WORD obj, type;
	OBJECT *ob;
	static int old = 0;

	if(wp && 
		wp->toolbar && 
		wp->tabbar && 
		( (wp->wfirst/wp->wscroll != old)) || FALSE
		  /*((char *)((TEDINFO *)wp->tabbar->ob_spec.userblk->ub_parm)->te_ptext[wp->umbruch-2] != ']')*/
		)
	{
		obj = 0;
	   do 
	   {
			ob	= &wp->toolbar[++obj];
			if((EXOB_TYPE(ob->ob_type)==TABBAR) ||
				          (ob->ob_type ==G_USERDEF))
			{
				twp=wp;
				toolbar_update(wp,wp->toolbar,obj,1);
				old = wp->wfirst/wp->wscroll;
			}
		} 
		while (! (ob->ob_flags & LASTOB));
	}
}
