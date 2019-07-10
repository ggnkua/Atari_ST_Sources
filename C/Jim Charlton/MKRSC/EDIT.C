#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"
#include "strings.h"



/*	find the selected obj[i]....    find the obj[j].ob_next
	or ob_head pointing to it, point obj[j].ob_next or ob_head to
	obj[i].ob_next....  check that obj[obj[i].ob_next].ob_tail is not
	pointing back to the deleted object and if so point it to obj[j].
    .....   check that neither obj[j].ob_head nor
	obj[j].ob_tail point to themselves and if so set them to -1.
	Cannot erase obj[0] or menuboxes in menu trees
	When titles are erased, their menu boxes must be erased as well
*/

int erase_obj()
{
	OBJECT *inwinptr;
	int		i, j, start, imbox;

/*	Set up handy pointer to right window object tree	*/

		inwinptr = thefrontwin->inwindow->objt;
		thefrontwin->saved = FALSE;

	if(thefrontwin->inwindow->kind[0] == TMENU)
		start = 3;
	else 
		start = 1;

	for(i=start;i<(thefrontwin->inwindow->count + 1);i++)
		if( (inwinptr[i].ob_state & SELECTED) &&
			 (i != thefrontwin->inwindow->mbox) )
		{	
			for(j=0;j<(thefrontwin->inwindow->count + 1);j++)
			{	if(inwinptr[j].ob_head == i)
					{	inwinptr[j].ob_head = inwinptr[i].ob_next;
						break;
					}
				if(inwinptr[j].ob_next == i)
					{	inwinptr[j].ob_next = inwinptr[i].ob_next;
						break;
					}
			}
			if( inwinptr[inwinptr[i].ob_next].ob_tail == i)
				inwinptr[inwinptr[i].ob_next].ob_tail = j;

/*	if selected obj was a menu title, delete its menubox	*/

			if(inwinptr[i].ob_type == G_TITLE)
			{	imbox =	thefrontwin->inwindow->mbox;
					for(j=0;j<(thefrontwin->inwindow->count + 1);j++)
					{	if(inwinptr[j].ob_head == imbox)
							{inwinptr[j].ob_head = inwinptr[imbox].ob_next;
							 break;
							}
						if(inwinptr[j].ob_next == imbox)
							{inwinptr[j].ob_next = inwinptr[imbox].ob_next;
							 break;
							}
					}
					if( inwinptr[inwinptr[imbox].ob_next].ob_tail == imbox)
						inwinptr[inwinptr[imbox].ob_next].ob_tail = j;
				thefrontwin->inwindow->mbox = 0;
			}
			for(j=0;j<(thefrontwin->inwindow->count + 1);j++)
			{	if(inwinptr[j].ob_head == j)
					inwinptr[j].ob_head = -1;
				if(inwinptr[j].ob_tail == j)
					inwinptr[j].ob_tail = -1;
			}
		break;  /* out of for i = ......	*/
		}
	if(thefrontwin->inwindow->kind[0] == TMENU)
		tidy_m();
	else
		ord_tree();

	draw_inwind(thefrontwin,0);
}

int erase_tree()
{
	OBJECT	*inwinptr;
	int	c, i, start;

	inwinptr = thefrontwin->inwindow->objt;

	start = 1;

	for(i=start;i<(thefrontwin->inwindow->count + 1);i++)
		if(inwinptr[i].ob_state & SELECTED)
		{	c = objc_delete(inwinptr,i);
			free(thefrontwin->inwindow->treelink[i]);
		}
/*	ord_tree() will reorder tree and adjust count	*/
	ord_tree();
	
	for(i=start;i<(thefrontwin->inwindow->count + 1);i++)
	{	inwinptr[i].ob_x = 20 + ((i-1)%8)*50;
		inwinptr[i].ob_y = 20 + ((i-1)/8)*35;
	}

	draw_inwind(thefrontwin,0);
	thefrontwin->saved = FALSE;
}

objtreeptr copy_tree(deselect)
	int deselect;
{
	objtreeptr	tempmain, tempsub, inwinptr;
	int i;

	tempmain  = (objtreeptr) malloc(sizeof(objtree));
	tempsub  = (objtreeptr) malloc(sizeof(objtree));

	inwinptr = thefrontwin->inwindow;
	thefrontwin->saved = FALSE;

	for(i=1;i<(inwinptr->count + 1);i++)
	{	if(inwinptr->objt[i].ob_state & SELECTED)
		{	if(deselect)
				inwinptr->objt[i].ob_state &= ~SELECTED;
			tempmain->kind[0] = thefrontwin->inwindow->kind[i];
			strcpy(tempmain->name[0],thefrontwin->inwindow->name[i]);
			tempmain->icblk[0] = thefrontwin->inwindow->icblk[i];
			tempmain->objt[0] = thefrontwin->inwindow->objt[i];
			tempmain->objt[0].ob_state &= ~SELECTED;
			tempmain->treelink[0] = tempsub;
		
			*tempsub = *inwinptr->treelink[i];
			tempsub->kind[0] = tempmain->kind[0];
			draw_inwind(thefrontwin,0);

			return(tempmain);
		}
	}
			return(NULL);
} 


int	paste_tree(tempmain)
	objtreeptr	tempmain;
{
	int result, num, nindex, i;
	int cx,cy,cw,ch;
	OBJECT *objptr2;
	ICONBLK *ibptr;
	objtreeptr	newsub, inwinptr;

	inwinptr = thefrontwin->inwindow;
	thefrontwin->saved = FALSE;
	
	nindex = 0;
	newsub  = (objtreeptr) malloc(sizeof(objtree));

	num = ++inwinptr->count;
	inwinptr->kind[num] = tempmain->kind[0];
	strcpy(inwinptr->name[num],tempmain->name[0]);
	inwinptr->icblk[num] = tempmain->icblk[0];
	inwinptr->objt[num] = tempmain->objt[0];
	inwinptr->icblk[num].ib_ptext
			 			= inwinptr->name[num];
	inwinptr->objt[num].ob_spec
						= (char *)&inwinptr->icblk[num];
	*newsub = *tempmain->treelink[0];
	inwinptr->treelink[num] = newsub;

/*	correct all of the pointers in the subtree	*/

	for(i=0;i < newsub->count + 1;i++)
	{	switch (newsub->objt[i].ob_type)
		{
			case G_TEXT		:
			case G_BOXTEXT	:
			case G_FTEXT	:
			case G_FBOXTEXT	:
				newsub->objt[i].ob_spec = (char *)&newsub->ti[i];
				newsub->ti[i].te_ptext = newsub->strings[i];
				newsub->ti[i].te_ptmplt = newsub->template[i];
				newsub->ti[i].te_pvalid = newsub->valid[i];				
				break;
			case G_BUTTON	:
			case G_STRING	:
			case G_TITLE	:
				newsub->objt[i].ob_spec = newsub->strings[i];
					break;
			case G_ICON		:
				newsub->objt[i].ob_spec = (char *)&newsub->icblk[i];
				newsub->icblk[i].ib_ptext = newsub->strings[i];
					break;
		}		
	}


/* set up a handy ptr */
	objptr2 = &inwinptr->objt[num];

/* clear the pointers for the new object  */

	objptr2->ob_next = -1;
	objptr2->ob_head = -1;
	objptr2->ob_tail = -1;

/* set its position */

	objptr2->ob_x = 20 + ((num-1)%8)*50;
	objptr2->ob_y = 20 + ((num-1)/8)*35;
	
/* make it a last object  */

	objptr2->ob_flags |= LASTOB;

/* get its new name, put into maintree name array */

	sprintf(inwinptr->name[num],"TREE%03d",++iconum);
	
/* point the tedinfo of the tree namer dialog to thetree->name */
	{
	((TEDINFO *)newtree[NTEDIT].ob_spec)->te_ptext = 
									inwinptr->name[num];
	
	result = do_dialog(newtree,NTEDIT);	/* newtree is object from RSC  */
	newtree[NTOK].ob_state = NORMAL;
	newtree[NTCANCEL].ob_state = NORMAL;

	if (result == NTCANCEL)
		{	inwinptr->count--;
			iconum--;
			return;
		}	
	}
/* link the new object into its parent   */

	result = objc_add(inwinptr->objt,nindex,num);
	
/* reset the LASTOB for the previous object in tree  */

	inwinptr->objt[num-1].ob_flags &= ~LASTOB;
	
	draw_inwind(thefrontwin,0);
}
		
int copy_obj(deselect)
	int deselect;
{
	objtree	*inwinptr;
	int i;

	inwinptr = thefrontwin->inwindow;

	for(i=1;i<(inwinptr->count + 1);i++)
		if(inwinptr->objt[i].ob_state & SELECTED)
		{	if(deselect)
				inwinptr->objt[i].ob_state &= ~SELECTED;
			tempo.okind = thefrontwin->inwindow->kind[i];
			strcpy(tempo.oname,thefrontwin->inwindow->name[i]);
			strcpy(tempo.ostrings,thefrontwin->inwindow->strings[i]);
			strcpy(tempo.ovalid,thefrontwin->inwindow->valid[i]);
			strcpy(tempo.otemplate,thefrontwin->inwindow->template[i]);
			tempo.oti = thefrontwin->inwindow->ti[i];
			tempo.oicblk = thefrontwin->inwindow->icblk[i];
			tempo.oobjt = thefrontwin->inwindow->objt[i];
			tempo.oobjt.ob_state &= ~SELECTED;
			draw_inwind(thefrontwin,0);		
/*			objc_draw(inwinptr->objt,i,10,thefrontwin->work.g_x,
						thefrontwin->work.g_y,
						thefrontwin->work.g_h,
						thefrontwin->work.g_w);
*/
			spaste = TRUE;
			return(1);
		}
		return(0);
}

int paste_obj()
{
	int			nindex, x, y, sw, sh;
	int result, num, obj_type, xoff, yoff, dummy, ev_bkstate;
	int cx,cy,cw,ch;
	OBJECT *objptr2;
	objtreeptr thetree;
	windowptr	thewin;

	graf_mouse(3,0);
	evnt_button(1,1,1,&x,&y,&dummy,&ev_bkstate);
/*	if the left-shift key is down wait for a button up and then
	a second button dwn.
*/
	if (ev_bkstate ==2)
	{	evnt_button(1,1,0,&x,&y,&dummy,&ev_bkstate);
		evnt_button(1,1,1,&x,&y,&dummy,&ev_bkstate);
	}
	graf_mouse(0,0);
	
	objptr2 = thefrontwin->inwindow->objt;

/*	objptr2 points to the active object tree in the window	*/

	sw = tempo.oobjt.ob_width;
	sh = tempo.oobjt.ob_height;
	nindex = good_parent(objptr2,x,y,sw,sh,-2);
	if(nindex == -1)
		return;

	thewin = thefrontwin;
	thetree = thefrontwin->inwindow;

	if (tempo.oobjt.ob_type == G_TITLE)
	{
/*	make sure you are moving a title to the menu bar	*/
		result = objc_find(thetree->objt,1,0,x,y);
		if (result == 1)	
		{	in_ttl(x,y,1);
			draw_inwind(thefrontwin,0);
		}
		return;
	}

/*	bail out if its a menu tree and the icon is not being dragged to a
	menubox
*/

	if( (thetree->kind[0] == TMENU)
		&& (nindex != thetree->mbox
			|| tempo.oobjt.ob_type != G_STRING) )
				return;

	num = ++thetree->count;

	thetree->kind[num] = tempo.okind;
	strcpy(thetree->name[num],tempo.oname);
	strcpy(thetree->strings[num],tempo.ostrings);
	strcpy(thetree->valid[num],tempo.ovalid);
	strcpy(thetree->template[num],tempo.otemplate);
	thetree->objt[num] = tempo.oobjt;

/* set up a handy ptr */
	objptr2 = &thetree->objt[num];

/* clear the pointers for the new object  */

	objptr2->ob_next = -1;
	objptr2->ob_head = -1;
	objptr2->ob_tail = -1;

/* get the object type of object coming in	*/

	obj_type = thetree->objt[num].ob_type;

/* set its position */

		objc_offset(thetree->objt, nindex, &xoff, &yoff); 
		x -= xoff;
		y -= yoff;
		objptr2->ob_y = y;
		objptr2->ob_x = x;
		if(snap)
		{	objptr2->ob_x += gl_wchar/2;
			objptr2->ob_x &= 0xFFF8;
			objptr2->ob_y += gl_hchar/2;
			objptr2->ob_y &= (0xFFFF - gl_hchar + 1);
		}

/* make if a last object  */

	objptr2->ob_flags |= LASTOB;

/* copy any necessary structures to the newtree structure  */


	switch (obj_type)
	{
		case G_TEXT		:
		case G_BOXTEXT	:
		case G_FTEXT	:
		case G_FBOXTEXT	: 
			thetree->ti[num] = tempo.oti;
			thetree->objt[num].ob_spec = (char *)&(thetree->ti[num]);
			thetree->ti[num].te_ptext = thetree->strings[num];
			thetree->ti[num].te_ptmplt = thetree->template[num];
			thetree->ti[num].te_pvalid = thetree->valid[num];
			break;
		case G_BUTTON	:
		case G_STRING	:
		case G_TITLE	:
			thetree->objt[num].ob_spec = thetree->strings[num];
			break;
		case G_ICON		:
			thetree->icblk[num] = tempo.oicblk;
			thetree->objt[num].ob_spec = (char *)&thetree->icblk[num];
			thetree->icblk[num].ib_ptext = thetree->strings[num];
			break;
	}		


/* link the new object into its parent   */

	if(thetree->kind[0] == TMENU)
	{	thetree->objt[num].ob_width = min(thetree->objt[num].ob_width,
								thetree->objt[thetree->mbox].ob_width);
		thetree->objt[num].ob_x = 0;

		thetree->objt[num].ob_height = min(thetree->objt[num].ob_height,
								thetree->objt[thetree->mbox].ob_height);
		result = objc_add(thetree->objt,thetree->mbox,num);
	}
	else
	{	thetree->objt[num].ob_width = min(thetree->objt[num].ob_width,
								thetree->objt[0].ob_width);
		thetree->objt[num].ob_height = min(thetree->objt[num].ob_height,
								thetree->objt[0].ob_height);
		result = objc_add(thetree->objt,nindex,thetree->count);
	}
/* reset the LASTOB for the previous object in tree  */

	thetree->objt[num-1].ob_flags &= ~LASTOB;

}
