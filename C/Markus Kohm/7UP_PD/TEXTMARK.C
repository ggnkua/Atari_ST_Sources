/* markieren und anspringen von Textstellen */
/*****************************************************************************
*
*											  7UP
*                            Modul: TEXTMARK.C
*                           (c) by TheoSoft '90
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <aes.h>

#include "windows.h"
#include "forms.h"
#include "7up.h"

#include "language.h"

textmarker(WINDOW *wp, OBJECT *tree, int item, int kstate, int key)
{
	int i,k,exit_obj;
	char string[19];
	
	static long mark[5][5]=
	{
		0,0,0,0,0,
		0,0,0,0,0,
		0,0,0,0,0,
		0,0,0,0,0,
		0,0,0,0,0
	};

	switch(item)
	{
		case SEARSMRK:
			for(i=MARK1; i<=MARK5; i++)
			{
				if(tree[i].ob_type==G_USERDEF)
				{
					tree[i].ob_flags|=TOUCHEXIT;
					tree[i].ob_state&=~DISABLED;
					k=i/2-1;
					if(mark[k][0] ||
						mark[k][1] ||
						mark[k][2] ||
						mark[k][3])
					{
						tree[i].ob_state|=SELECTED;
					}
					else
					{
						tree[i].ob_state&=~SELECTED;
					}
				}
			}
			form_write(tree,MARKTITL,MARKE_SETZEN,FALSE);
			tree[MARKTITL].ob_width=strlen(MARKE_SETZEN)*8;
			exit_obj=form_exhndl(tree,0,0);
			if(exit_obj!=MARKABBR)
			{
				k=exit_obj/2-1;
				mark[k][0]=wp->row+wp->hfirst/wp->hscroll;
				mark[k][1]=wp->col+wp->wfirst/wp->wscroll;
				mark[k][2]=(long)wp->cstr;
				mark[k][3]=(long)wp->cstr->string;
				mark[k][4]=(long)wp;
				form_read(tree,exit_obj+1,string);
				if(!*string) /* nur ausfllen, wenn nichts drin */
				{
					strncpy(string,&wp->cstr->string[wp->col+wp->wfirst/wp->wscroll],18);
					string[18]=0;
					form_write(tree,exit_obj+1,string,FALSE);
				}
			}
			break;
		case SEARGMRK:
			for(i=MARK1; i<=MARK5; i++)
			{
				if(tree[i].ob_type==G_USERDEF)
				{
					k=i/2-1;
					if(mark[k][0] ||
						mark[k][1] ||
						mark[k][2] ||
						mark[k][3])
					{
						tree[i].ob_state=NORMAL;
					}
					else
					{
						tree[i].ob_state|=DISABLED;
						tree[i].ob_flags&=~TOUCHEXIT;
					}
				}
			}
			form_write(tree,MARKTITL,SUCHE_MARKE,FALSE);
			tree[MARKTITL].ob_width=strlen(SUCHE_MARKE)*8;
			exit_obj=form_exhndl(tree,0,0);
			if(exit_obj!=MARKABBR)
			{
				k=exit_obj/2-1;
				gotomark(wp,mark[k]);
			}
			break;
		default:
			if(key>=0 && key<=4)
				if(mark[key][0] ||
					mark[key][1] ||
					mark[key][2] ||
					mark[key][3])
				{
					gotomark(wp,mark[key]);
				}
			break;
	}
}
