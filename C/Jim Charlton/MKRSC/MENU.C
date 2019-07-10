#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"

/*
	do_menu - determines which menu was selected and calls the
		appropriate routine to handle the item selected.
*/
do_menu(message)
	int *message;
{
	int menuid, itemid;

	menuid = message[3];
	itemid = message[4];

	switch(menuid) {
		case DESK:		handle_desk(itemid);
						break;
		case FILE:		handle_file(itemid);
						break;
		case EDIT:		handle_edit(itemid);
						break;
        case CHOOSE: 	handle_choose(itemid);
                   		break;
		case WINDOWS:	handle_rot();
						break;
	}

	menu_tnormal(mkrscmnu, menuid, 1);
}


int handle_rot()
{
	int i;
	OBJECT *inwinptr;


			inwinptr = thefrontwin->inwindow->objt;
			for(i=0;i<(thefrontwin->inwindow->count + 1);i++)
			if(inwinptr[i].ob_state & SELECTED)
				inwinptr[i].ob_state &= ~SELECTED;

			rot_wind();
}

int handle_desk(itemid)
	int itemid;
{
	switch(itemid) {
		case	ABOUT	:
							aboutt[AOK].ob_state = NORMAL;
							do_dialog(aboutt,0);
							break;
					}	

}

handle_file(itemid)
	int itemid;
{
	windowptr thewin;
	OBJECT *inwinptr;
	int i, button, abort, len;

	abort = 0;
	switch(itemid) {
		case NEW:		if(thewin = new_window())
							open_window(thewin);
						break;
		case OPEN:	if( (thefrontwin)
					  && (thefrontwin->inwindow != &thefrontwin->maintree) )
					{	inwinptr = thefrontwin->inwindow->objt;
						for(i=0;i<(thefrontwin->inwindow->count + 1);i++)
						if(inwinptr[i].ob_state & SELECTED)
							inwinptr[i].ob_state &= ~SELECTED;
						thefrontwin->inwindow = &thefrontwin->maintree;
						draw_inwind(thefrontwin,1);
						draw_obj(treicont);
					}
						len = strlen(fs_inpath);
						for(i=len;i>0;i--)  /* find last occurrence of \  */
							if(fs_inpath[i] =='\\') break;
						fs_inpath[i+1] = 0;
						strcat(fs_inpath,"*.RSC");
						ret_rsc();	
						len = strlen(fs_inpath);
						for(i=len;i>0;i--)  /* find last occurrence of \  */
							if(fs_inpath[i] =='\\') break;
						fs_inpath[i+1] = 0;
						strcat(fs_inpath,"*.*");
						break;
        case CLOSE:	 	if(thefrontwin)
					{ if(thefrontwin->inwindow == &thefrontwin->maintree)
		{
			
			{	button = 1;
				if(thefrontwin->saved != TRUE)
					button =  form_alert(1, "[2][ Save before closing? ][CLOSE|SAVE|CANCEL]");
				if (button == 3)
					break;
				else if (button == 2)
				{	if(getfile(thefrontwin))
						make_rsc();
						break;
				}
				else
					dispose_window(thefrontwin);
			}
		}
				else
					{	inwinptr = thefrontwin->inwindow->objt;
						for(i=0;i<(thefrontwin->inwindow->count + 1);i++)
						if(inwinptr[i].ob_state & SELECTED)
							inwinptr[i].ob_state &= ~SELECTED;
						if(thefrontwin->inwindow->kind[0] == TMENU)
							sort_boxes();
						thefrontwin->inwindow = &thefrontwin->maintree;

						draw_inwind(thefrontwin,1);
						draw_obj(treicont);
					}
					}
						break;
		case SAVEAS:
			if(thefrontwin)
				{	if(thefrontwin->inwindow != &thefrontwin->maintree)
					{	inwinptr = thefrontwin->inwindow->objt;
						for(i=0;i<(thefrontwin->inwindow->count + 1);i++)
						if(inwinptr[i].ob_state & SELECTED)
							inwinptr[i].ob_state &= ~SELECTED;
						if(thefrontwin->inwindow->kind[0] == TMENU)
							sort_boxes();
						thefrontwin->inwindow = &thefrontwin->maintree;
						draw_inwind(thefrontwin,1);
						draw_obj(treicont);
					}
						if(getfile(thefrontwin))
							make_rsc();
				}
						break;
		case SAVE:
				if(thefrontwin)
				{		if(thefrontwin->inwindow != &thefrontwin->maintree)
					{	inwinptr = thefrontwin->inwindow->objt;
						for(i=0;i<(thefrontwin->inwindow->count + 1);i++)
						if(inwinptr[i].ob_state & SELECTED)
							inwinptr[i].ob_state &= ~SELECTED;
						if(thefrontwin->inwindow->kind[0] == TMENU)
							sort_boxes();
						thefrontwin->inwindow = &thefrontwin->maintree;
						draw_inwind(thefrontwin,1);
						draw_obj(treicont);
					}
							make_rsc();
				}
						break;
		case QUIT:
		while(thefrontwin)
		{ if(thefrontwin->inwindow != &thefrontwin->maintree)
				{	inwinptr = thefrontwin->inwindow->objt;
					for(i=0;i<(thefrontwin->inwindow->count + 1);i++)
					if(inwinptr[i].ob_state & SELECTED)
						inwinptr[i].ob_state &= ~SELECTED;
					if(thefrontwin->inwindow->kind[0] == TMENU)
						sort_boxes();
					thefrontwin->inwindow = &thefrontwin->maintree;
					draw_inwind(thefrontwin,1);
					draw_obj(treicont);
				}
				button = 1;
				if(thefrontwin->saved != TRUE)
				button =  form_alert(1, "[2][ Save before closing? ][CLOSE|SAVE|CANCEL]");
				if (button == 3)
				{	abort = 1;
					break;
				}
				else if (button == 2)
				{	if(getfile(thefrontwin))
						make_rsc();
				}
				dispose_window(thefrontwin);
		}
		if(abort == 0)
			shutdown(0);
		break;
	}
}

int handle_edit(itemid)
	int itemid;
{
	switch(itemid)	{
		case ERASE	: 	if(thefrontwin)
						{ if(thefrontwin->inwindow != &thefrontwin->maintree)
							erase_obj();
						  else
							erase_tree();
						}
						break;
		case COPY 	:
			if(thefrontwin)
			{	if(thefrontwin->inwindow == &thefrontwin->maintree)
				{	if(tempm)
					{	free(tempm->treelink[0]);
						free(tempm);
					}
					tempm = copy_tree(1);
				}
				else
					copy_obj(1);
			}
						break;
		case PASTE	:
			if(thefrontwin)
			{	if ( (thefrontwin->inwindow == &thefrontwin->maintree) 
						&& (tempm) )
						paste_tree(tempm);
				else
					paste_obj();
					draw_inwind(thefrontwin,0);
			}
			break;
		case CUT	:	
			if(thefrontwin)
			{	if(thefrontwin->inwindow == &thefrontwin->maintree)
					{	if(tempm)
						{	free(tempm->treelink[0]);
							free(tempm);
						}
						tempm = copy_tree(0);
						erase_tree();
					}
					else
					{	copy_obj(0);
						erase_obj();
					}
			}
						break;
					}
}


int handle_choose(itemid)
	int itemid;
{
	OBJECT *inwinptr;
	int i, button;

	switch(itemid)	{
		case NAM	: 	if(thefrontwin)
						{	name_obj();
						inwinptr = thefrontwin->inwindow->objt;
						for(i=0;i<(thefrontwin->inwindow->count + 1);i++)
						if(inwinptr[i].ob_state & SELECTED)
						{	inwinptr[i].ob_state &= ~SELECTED;
							break;
						}
						draw_inwind(thefrontwin,0);
						}
						break;
		case SNAP	:
	if( (thefrontwin)
				&& (thefrontwin->inwindow != &thefrontwin->maintree) )
	{
		if (snap)
		{
			button =  form_alert(1, "[0][ Unsnapped objects may be | positioned differently at | different resolutions. ][OK|CANCEL]");
			if (button == 1)
			{	strcpy(mkrscmnu[SNAP].ob_spec,"  Snap now OFF");
				mkrscmnu[SNAP].ob_state = NORMAL;
				snap = FALSE;		
			}
		}
		else
		{	strcpy(mkrscmnu[SNAP].ob_spec,"  Snap now ON");
			mkrscmnu[SNAP].ob_state = CHECKED;
			snap = TRUE;
		}
	}
			break;
			
		case SALL	:
		{	inwinptr = thefrontwin->inwindow->objt;
				for(i=1;i<(thefrontwin->inwindow->count + 1);i++)
				{	inwinptr[i].ob_x += gl_wchar/2;
					inwinptr[i].ob_x &= 0xFFF8;
					inwinptr[i].ob_y += gl_hchar/2;
					inwinptr[i].ob_y &= (0xFFFF - gl_hchar + 1);
					inwinptr[i].ob_width += gl_wchar/2;
					inwinptr[i].ob_width &= 0xFFF8;
					inwinptr[i].ob_height += gl_hchar/2;
					inwinptr[i].ob_height &= (0xFFFF - gl_hchar + 1);
				}
				draw_inwind(thefrontwin,1);
		}
			break;
			
		case SSEL	:
			inwinptr = thefrontwin->inwindow->objt;
			for(i=1;i<(thefrontwin->inwindow->count + 1);i++)
			{	if(inwinptr[i].ob_state & SELECTED)
				{	inwinptr[i].ob_state &= ~SELECTED;
					inwinptr[i].ob_x += gl_wchar/2;
					inwinptr[i].ob_x &= 0xFFF8;
					inwinptr[i].ob_y += gl_hchar/2;
					inwinptr[i].ob_y &= (0xFFFF - gl_hchar + 1);
					inwinptr[i].ob_width += gl_wchar/2;
					inwinptr[i].ob_width &= 0xFFF8;
					inwinptr[i].ob_height += gl_hchar/2;
					inwinptr[i].ob_height &= (0xFFFF - gl_hchar + 1);
				}
			}
			draw_inwind(thefrontwin,1);
			break;
			
		case SORT	:
		if( (thefrontwin)
				&& (thefrontwin->inwindow != &thefrontwin->maintree) )
		{	inwinptr = thefrontwin->inwindow->objt;
			for(i=0;i<(thefrontwin->inwindow->count + 1);i++)
			if(inwinptr[i].ob_state & SELECTED)
			{	do_sort();
				break;
			}
		}
		draw_inwind(thefrontwin,0);
		break;
		case COUT	:	mkrscmnu[COUT].ob_state ^= CHECKED;
						cout ^= 1;
						break;
					}
}

int do_sort()
{
	int button;


	sortd[SRTOK].ob_state &= ~SELECTED;
	sortd[SRTCAN].ob_state &= ~SELECTED;
	sortd[SRTX].ob_state &= ~SELECTED;
	sortd[SRTY].ob_state &= ~SELECTED;
	sortd[SRTXY].ob_state &= ~SELECTED;
	sortd[SRTYX].ob_state &= ~SELECTED;

	button = do_dialog(sortd,0);
	switch (button)
	{
		case SRTCAN	:	return;
						break;
		case SRTOK	:
		if			(sortd[SRTX].ob_state &= SELECTED)
			{	sort_x();
				break;
			}	
		else if		(sortd[SRTY].ob_state &= SELECTED)
			{	sort_y();
				break;
			}
		else if		(sortd[SRTXY].ob_state &= SELECTED)
			{	sort_x();
				sort_y();
				break;
			}	
		else if		(sortd[SRTYX].ob_state &= SELECTED)
			{	sort_y();
				sort_x();
				break;
			}
		else break;	
	}
}

int sort_x()
{
	OBJECT *inwinptr;
	int	i, numobjs, head, k, j, finished;
	struct 	{	int index;
				int ob_x;
			} xorder[MAXONUM], temp;
	
	inwinptr = thefrontwin->inwindow->objt;
	for(i=0;i<(thefrontwin->inwindow->count + 1);i++)
	if(inwinptr[i].ob_state & SELECTED)
	{		
			inwinptr[i].ob_state &= ~SELECTED;
			head = inwinptr[i].ob_head;
			if (head < 1) break;
			k = 0;
/*	make an array of the children and their x values	*/

			for(j=head;j != i;j=inwinptr[j].ob_next)
			{	xorder[k].index = j;
				xorder[k++].ob_x = inwinptr[j].ob_x;
			}
			numobjs = k;
			if(numobjs < 2) break;
/*	sort the array according to x values	*/
			finished = FALSE;
			while(!finished)
			{	finished = TRUE;
				for(j = 0;j < numobjs-1; j++)
				if(xorder[j].ob_x > xorder[j+1].ob_x)
				{	temp = xorder[j];
					xorder[j] = xorder[j+1];
					xorder[j+1] = temp;
					finished = FALSE;
				}
			}
/*	remake the object tree	*/
			inwinptr[i].ob_head = xorder[0].index;
			for(j=0;j<numobjs-1;j++)
				inwinptr[xorder[j].index].ob_next = xorder[j+1].index;
			inwinptr[xorder[j].index].ob_next = i;
			inwinptr[i].ob_tail = xorder[j].index;
	}
}

int sort_y()
{
	OBJECT *inwinptr;
	int	i, numobjs, head, k, j, finished;
	struct 	{	int index;
				int ob_y;
			} xorder[MAXONUM], temp;
	
	inwinptr = thefrontwin->inwindow->objt;
	for(i=0;i<(thefrontwin->inwindow->count + 1);i++)
	if(inwinptr[i].ob_state & SELECTED)
	{		
			inwinptr[i].ob_state &= ~SELECTED;
			head = inwinptr[i].ob_head;
			if (head < 1) break;
			k = 0;
/*	make an array of the children and their y values	*/

			for(j=head;j != i;j=inwinptr[j].ob_next)
			{	xorder[k].index = j;
				xorder[k++].ob_y = inwinptr[j].ob_y;
			}
			numobjs = k;
			if(numobjs < 2) break;
/*	sort the array according to x values	*/
			finished = FALSE;
			while(!finished)
			{	finished = TRUE;
				for(j = 0;j < numobjs-1; j++)
				if(xorder[j].ob_y > xorder[j+1].ob_y)
				{	temp = xorder[j];
					xorder[j] = xorder[j+1];
					xorder[j+1] = temp;
					finished = FALSE;
				}
			}
/*	remake the object tree	*/
			inwinptr[i].ob_head = xorder[0].index;
			for(j=0;j<numobjs-1;j++)
				inwinptr[xorder[j].index].ob_next = xorder[j+1].index;
			inwinptr[xorder[j].index].ob_next = i;
			inwinptr[i].ob_tail = xorder[j].index;
	}
}

int sort_boxes()
{
	int	boxes[50], count;
	int i, head, next, bparent;
	OBJECT *tree;
	objtreeptr thetree;

	thetree = thefrontwin->inwindow;
	tree = thetree->objt;

	bparent = tree[1].ob_next;
	head = tree[bparent].ob_head;
	
	boxes[0] = head;
	for(next=head,i=1;(next!=bparent && i < 500);next=tree[next].ob_next,i++)
		boxes[i] = tree[next].ob_next;

	count = i -1;
	for(i = 1; i < count; i++)
	{	tree[boxes[i]].ob_state |= SELECTED;
		sort_y();
	}
}
