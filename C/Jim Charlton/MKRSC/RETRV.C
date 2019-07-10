#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"
#include "strings.h"
#include <fcntl.h>

int ret_rsc()
{
	windowptr	thewin;
	RSHDR rsc_struct;
	int fildes, skres, i, j, button;
	OBJECT *treeptr, *iconptr;
	int order[MAXONUM], num_objs;	
	long red;
	objtreeptr sbstrct;
	TEDINFO	*tiptr;
	ICONBLK	*icptr;
	char temp[20], pname[30];
	int len;

	if(!(thewin = new_window()))
		return;
	if(!(getfile(thewin)))
	{	dispose_win_resources(thewin);
		return;
  	}
  	open_window(thewin);
  	graf_mouse(2,0L);
#ifndef __GNUC__
  	fildes = open(thefrontwin->title,O_BINARY);
  	if( (fildes == -1)||(red = Fread(fildes,36L,(char *)&rsc_struct)) != 36)
#else
	fildes = open(thefrontwin->title,0);
	if( (fildes < 0)||(red = Fread(fildes,36L,(char *)&rsc_struct)) != 36)
#endif
  			{	button = form_alert(1, "[1][ File read error ][OK]");
  				close(fildes);
  				return;
			}
	close(fildes);

	if (!rsrc_load(thefrontwin->title))
	{	form_alert(1, "[0][Cannot find .RSC file|Aborting ...][OK]");
		return;
	}

	graf_mouse(0,0L);

	iconptr = &onleft[TUNKNOWN];

	for(i=0;i<rsc_struct.rsh_ntree;i++)
	{	rsrc_gaddr(0, i, &treeptr);
		num_objs = trav_tree(treeptr,order);
		add_lefticon(iconptr,TUNKNOWN,1);
		sbstrct = thewin->inwindow->treelink[i+1];
		sbstrct->count = num_objs - 1;
	for(j=0;j <(num_objs);j++)
		{	sbstrct->objt[j] = treeptr[order[j]];
	switch (treeptr[j].ob_type)
	{
		case G_TEXT		:
		case G_BOXTEXT	:
		case G_FTEXT	:
		case G_FBOXTEXT	: 
			sbstrct->ti[j] = *((TEDINFO *)(treeptr[order[j]].ob_spec));
			sbstrct->objt[j].ob_spec = (char *)&sbstrct->ti[j];
			strcpy(sbstrct->strings[j],
				((TEDINFO *)(treeptr[order[j]].ob_spec))->te_ptext);
			sbstrct->ti[j].te_ptext = sbstrct->strings[j];
			strcpy(sbstrct->template[j],
				((TEDINFO *)(treeptr[order[j]].ob_spec))->te_ptmplt);
			sbstrct->ti[j].te_ptmplt = sbstrct->template[j];
			strcpy(sbstrct->valid[j],
				((TEDINFO *)(treeptr[order[j]].ob_spec))->te_pvalid);
			sbstrct->ti[j].te_pvalid = sbstrct->valid[j];
			break;
		case G_BUTTON	:
		case G_STRING	:
		case G_TITLE	:
			strcpy(sbstrct->strings[j], treeptr[order[j]].ob_spec);
			sbstrct->objt[j].ob_spec = sbstrct->strings[j];
			break;
		case G_ICON		:
			sbstrct->icblk[j] = *((ICONBLK *)(treeptr[order[j]].ob_spec));
			sbstrct->objt[j].ob_spec = (char *)&sbstrct->icblk[j];
			strcpy(sbstrct->strings[j],
				((ICONBLK *)(treeptr[order[j]].ob_spec))->ib_ptext);
			sbstrct->icblk[j].ib_ptext = sbstrct->strings[j];
			break;
	}
		}	/*	end of for(j=....	*/
/*	reset the pointers in the object tree...  newpos() in tree.c	*/
			for (j=0;j<num_objs;j++)
			{	sbstrct->objt[j].ob_next =
				 	newpos(sbstrct->objt[j].ob_next,num_objs,order);
				sbstrct->objt[j].ob_head =
				 	newpos(sbstrct->objt[j].ob_head,num_objs,order);
				sbstrct->objt[j].ob_tail =
				 	newpos(sbstrct->objt[j].ob_tail,num_objs,order);

			}
	}	/* end of for i=....	*/
	len = strlen(thefrontwin->title);
	for(i = len - 1; i > 0; i--)
		if(thefrontwin->title[i] == '.')
			break;
	strncpy(temp,thefrontwin->title,i);
	temp[i] = '\0';
	sprintf(pname,"%s.DEF",temp);	
	read_def(pname);

}
		
	

		
