#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"
#include "strings.h"
#include <fcntl.h>


int make_cout(cname)
	char cname[];
{
	char temp[80], trname[30], *type;
	int fildes, i, j, c, k, len;
	objtreeptr	thetree, *linkptr;
	int numobjs, order[MAXONUM];
	int tednum, first, tinum, upb;
	TEDINFO *tiptr;
	OBJECT tempobj;

	thetree = thefrontwin->inwindow;
	linkptr = thetree->treelink;

	tednum = 0;

    Fdelete(cname);
#ifndef __GNUC__
  	fildes = creat(cname,O_RDWR);
  	if(fildes != -1)	
#else
 	fildes = creat(cname,0666);
 	if(fildes > -1)	
#endif
	{	for( i=1;i < thetree->count + 1; i++)
		{	first = TRUE;
			strcpy(trname,thetree->name[i]);
			len = strlen(trname);
			for(k=0;k<len;k++)
				trname[k] = tolower(trname[k]);
			numobjs = trav_tree(linkptr[i]->objt,order);
			for(j=0;j < numobjs; j++)
			{	switch (linkptr[i]->objt[order[j]].ob_type)
			{
			case G_TEXT		:
			case G_BOXTEXT	:
			case G_FTEXT	:
			case G_FBOXTEXT	:
			{	tiptr = (TEDINFO *)linkptr[i]->objt[order[j]].ob_spec;
				if(first)
				{	sprintf(temp,"TEDINFO ted%d[] = {\n",tednum++);
					if(!(wr_it(fildes,temp))) return;
					sprintf(temp,"    \"%s\",\n",tiptr->te_ptext);
					if(!(wr_it(fildes,temp))) return;
					first = FALSE;
				}
				else
				{
					sprintf(temp,",\n    \"%s\",\n",tiptr->te_ptext);
					if(!(wr_it(fildes,temp))) return;
				}
				sprintf(temp,"    \"%s\",\n",tiptr->te_ptmplt);
				if(!(wr_it(fildes,temp))) return;
				sprintf(temp,"    \"%s\",\n",tiptr->te_pvalid);
				if(!(wr_it(fildes,temp))) return;
				sprintf(temp,"    %d,%d,%d,0x%x,%d,%d,%d,%d",
					tiptr->te_font, tiptr->te_junk1,
					tiptr->te_just, tiptr->te_color,
					tiptr->te_junk2, tiptr->te_thickness,
					tiptr->te_txtlen, tiptr->te_tmplen);
				if(!(wr_it(fildes,temp))) return;
				break;
			}
			} /* end of switch		*/
			} /*	end of for j =	*/
			if(!first)
			{	sprintf(temp,"      };\n\n");
				if(!(wr_it(fildes,temp))) return;
			}

/*	now build the object tree	*/

			first = TRUE;
			tinum = 0;
			for(j=0;j < numobjs; j++)
			{
/*	make a copy of the object and fix the pointers in the new order	*/

				tempobj = linkptr[i]->objt[order[j]];	
				/*	fix the size and width and special bytes	*/
				if(order[j]==0)
					tempobj.ob_x = tempobj.ob_y = 0;
				upb = (tempobj.ob_x & ~0xFFF8) << 8;
				tempobj.ob_x = tempobj.ob_x/gl_wchar + upb;
				upb = (tempobj.ob_width & ~0xFFF8) << 8;
				tempobj.ob_width = tempobj.ob_width/gl_wchar + upb;
				upb = (tempobj.ob_y & ~(0xFFFF-gl_hchar+1)) << 8;
				tempobj.ob_y = tempobj.ob_y/gl_hchar + upb;
				upb = (tempobj.ob_height & ~(0xFFFF-gl_hchar+1)) << 8;
				tempobj.ob_height = tempobj.ob_height/gl_hchar + upb;

				tempobj.ob_next = newpos(tempobj.ob_next,numobjs,order);
				tempobj.ob_head = newpos(tempobj.ob_head,numobjs,order);
				tempobj.ob_tail = newpos(tempobj.ob_tail,numobjs,order);
			
	/*	mark last object in subtree	*/
				if(j == (numobjs - 1))
					tempobj.ob_flags |= LASTOB;
				else
					tempobj.ob_flags &= ~LASTOB;

				if(first)
				{	sprintf(temp,"OBJECT %s[] = {\n",trname);
					if(!(wr_it(fildes,temp))) return;
				}

			switch (c = tempobj.ob_type)
			{
			case G_TEXT		:
			case G_BOXTEXT	:
			case G_FTEXT	:
			case G_FBOXTEXT	:
				if( c == G_TEXT)	type = "G_TEXT";
				else if (c == G_BOXTEXT)	type = "G_BOXTEXT";
				else if (c == G_FTEXT)	type = "G_FTEXT";
				else if (c == G_FBOXTEXT) 	type = "G_FBOXTEXT"; 
				sprintf(temp,",\n    %d,%d,%d,%s,0x%x,0x%x,(char *)&ted%d[%d],%d,%d,%d,%d",
				tempobj.ob_next, tempobj.ob_head,
				tempobj.ob_tail,
				type,
				(int)tempobj.ob_flags,
				(int)tempobj.ob_state,
				tednum-1,tinum++,
				tempobj.ob_x,
				tempobj.ob_y, tempobj.ob_width,
				tempobj.ob_height);
				if(!(wr_it(fildes,temp))) return;
				break;
			case G_BUTTON	:
			case G_STRING	:
			case G_TITLE	:
				if(c == G_BUTTON)	type = "G_BUTTON";
				else if (c == G_STRING)	type = "G_STRING";
				else if (c == G_TITLE)	type = "G_TITLE";
				sprintf(temp,",\n    %d,%d,%d,%s,0x%x,0x%x, \"%s\" ,%d,%d,%d,%d",
					tempobj.ob_next,
					tempobj.ob_head,
					tempobj.ob_tail,
					type,
					(int)tempobj.ob_flags,
					(int)tempobj.ob_state,
					(char *)tempobj.ob_spec,
					tempobj.ob_x,
					tempobj.ob_y,
					tempobj.ob_width,
					tempobj.ob_height);
				if(!(wr_it(fildes,temp))) return;
				break;
			case G_ICON		:
								break;
			case G_BOXCHAR	:
			case G_BOX		:
			case G_IBOX		:
				if(c == G_BOXCHAR)	type = " G_BOXCHAR";
				else if (c == G_BOX)	type = " G_BOX";
				else if (c == G_IBOX)	type = " G_IBOX";
				if(first)
				{	sprintf(temp,"    %d,",tempobj.ob_next);
					if(!(wr_it(fildes,temp))) return;
					first = FALSE;
				}
				else
				{	sprintf(temp,",\n    %d,",tempobj.ob_next);
					if(!(wr_it(fildes,temp))) return;
				}
					
				sprintf(temp,"%d,%d,%s,0x%x,0x%x,0x%lxL,%d,%d,%d,%d",
				 	tempobj.ob_head,
					tempobj.ob_tail,
					type,
					(int)tempobj.ob_flags,
					(int)tempobj.ob_state,
					(long)tempobj.ob_spec,
					tempobj.ob_x,
					tempobj.ob_y,
				 	tempobj.ob_width,
					tempobj.ob_height);
				if(!(wr_it(fildes,temp))) return;
								break;
			}		
			}
			if(!first)
			{	sprintf(temp,"      };\n\n");
				if(!(wr_it(fildes,temp))) return;
			}
		}	c = close(fildes);		
	}

}

int	wr_it(fildes,str)
	int fildes;
	char *str;
{
		long size, flenw;
		int c, button;

		size = strlen(str);
		if( (flenw = Fwrite(fildes,size,str)) <= 0)
		{
			button = form_alert(1, "[1][ Error writing file ][OK]");
			c = close(fildes);
			return(0);
		}
		return(1);
}
