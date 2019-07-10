#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"


/*
	You now want to move the object from the left hand menu pointed
	to by objptr to the tree structure inwindow.  It must be added to the
	array of objects in thfrontwin->inwindow->objt[], and count
	 incremented.  Then you must link it to the other objects in the
	 array with objc_add().  You link it to the parent object pointed 
	to by the index number 'nindex'.  'oindex' points to the object that
	 was selected from the onleft tree.  In the case of titles in menu
	bars, they are always linked to object 2 in tree.
*/	

int	add_tosub(objptr,nindex,oindex,x,y)
	OBJECT		*objptr;
	int			nindex, oindex, x, y;
{
	int result, num, obj_type, xoff, yoff;
	int cx,cy,cw,ch;
	OBJECT *objptr2;
	objtreeptr thetree;
	windowptr	thewin;

	thewin = thefrontwin;
	thetree = thefrontwin->inwindow;

	if (onleft[oindex].ob_type == G_TITLE)
	{
/*	make sure you are moving a title to the menu bar	*/
		result = objc_find(thetree->objt,1,0,x,y);
		if (result == 1)	
		{	in_ttl(x,y,0);
			draw_inwind(thefrontwin,1);
		}
		return;
	}

/*	bail out if its a menu tree and the icon is not being dragged to a
	menubox
*/

	if(thefrontwin->inwindow->kind[0] == TMENU
		 && nindex != thefrontwin->inwindow->mbox)
				return;


/* copy the icon into the object tree array in thetree struct */

	thetree->objt[++thetree->count] = *objptr;

/* handy pointer	*/
	num = thetree->count;

/* copy the oject index from onleft tree into 'kind'	*/

	thetree->kind[num] = oindex;
	thetree->name[num][0] = NULL;

/* set up a handy ptr */
	objptr2 = &thetree->objt[thetree->count];

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
		if(snap || (thefrontwin->inwindow->kind[0] == TMENU))

		{	objptr2->ob_x += gl_wchar/2;
			objptr2->ob_x &= 0xFFF8;
			objptr2->ob_y += gl_hchar/2;
			objptr2->ob_y &= (0xFFFF - gl_hchar + 1);
		}

	if(thefrontwin->inwindow->kind[0] == TMENU)
		objptr2->ob_x = 0;
	

/* make it a last object  */

	objptr2->ob_flags |= LASTOB;

/* copy any necessary structures to the newtree structure  */


	switch (obj_type)
	{
		case G_TEXT		:
		case G_BOXTEXT	:
		case G_FTEXT	:
		case G_FBOXTEXT	: 
			thetree->ti[num] = *((TEDINFO *)(onleft[oindex].ob_spec));
			thetree->objt[num].ob_spec = (char *)&thetree->ti[num];
			strcpy(thetree->strings[num],
				((TEDINFO *)(onleft[oindex].ob_spec))->te_ptext);
			thetree->ti[num].te_ptext = thetree->strings[num];
			strcpy(thetree->template[num],
				((TEDINFO *)(onleft[oindex].ob_spec))->te_ptmplt);
			thetree->ti[num].te_ptmplt = thetree->template[num];
			strcpy(thetree->valid[num],
				((TEDINFO *)(onleft[oindex].ob_spec))->te_pvalid);
			thetree->ti[num].te_pvalid = thetree->valid[num];
			break;
		case G_BUTTON	:
		case G_STRING	:
		case G_TITLE	:
			strcpy(thetree->strings[num], onleft[oindex].ob_spec);
			thetree->objt[num].ob_spec = thetree->strings[num];
			break;
		case G_ICON		:
			thetree->icblk[num] = *((ICONBLK *)(onleft[oindex].ob_spec));
			thetree->objt[num].ob_spec = (char *)&thetree->icblk[num];
			strcpy(thetree->strings[num],
				((ICONBLK *)(onleft[oindex].ob_spec))->ib_ptext);
			thetree->icblk[num].ib_ptext = thetree->strings[num];
			break;
	}		


/* link the new object into its parent   */

	if(thefrontwin->inwindow->kind[0] == TMENU)
		result = objc_add(thetree->objt,
							thefrontwin->inwindow->mbox,thetree->count);
	else
		result = objc_add(thetree->objt,nindex,thetree->count);
	
/* reset the LASTOB for the previous object in tree  */

	thetree->objt[num-1].ob_flags &= ~LASTOB;
	
/* redraw the icons in the window object tree  */

/*	draw_inwind(thefrontwin,0);	*/
	objc_draw(thetree->objt,nindex,10,thefrontwin->work.g_x,
						thefrontwin->work.g_y,
						thefrontwin->work.g_w,thefrontwin->work.g_h);
}

/*	Clicks is the number of button clicks and result is the object
	number of the object the mouse was over in the tree that was
	active in the right window
*/

hand_subtree(clicks,result,mousex,mousey)
	int clicks, result, mousex, mousey;
{
	int newstate,i;
	OBJECT *inwinptr;
	int mx, my, mstate, kbdstate;
	int tparent, bparent, next;

/*	Set up handy pointer to right window object tree	*/

		inwinptr = thefrontwin->inwindow->objt;

/*	tparent is parent of titles and bparent parent of menu boxes
	These are used only for menu object trees...  see below

*/

		tparent = 2;
		bparent = inwinptr[1].ob_next;

		if (clicks == 2)
		{
			dbl_clsub(result);
		}
		else		/*  clicks = 1   */
		{
		/*	deselect all selected objects	*/

			for(i=0;i<(thefrontwin->inwindow->count + 1);i++)
				if( (inwinptr[i].ob_state & SELECTED) && (result != i) )
					inwinptr[i].ob_state &= ~SELECTED;

/*	Toggle state of the selected icon and redraw tree
*/
			inwinptr[result].ob_state ^= SELECTED;

/* 	If it is a menu tree, and a title has been clicked
	figure out which menubox (mbox) is under it and
	display drop down menu box as well (see draw_inwind())
*/

				if( (thefrontwin->inwindow->kind[0] == TMENU)
					&& (inwinptr[result].ob_type == G_TITLE) )
				{	next = inwinptr[bparent].ob_head;
					for (i=0;i<result-tparent;i++)
						{	thefrontwin->inwindow->mbox	=next;
							next = inwinptr[next].ob_next;
						} 
				}

	/* check if the mouse button is being held down	*/

		graf_mkstate(&mx, &my, &mstate, &kbdstate);
		if(mstate == 1)
			drag_right(result,mousex,mousey);  /* see drag.c   */

		}	/* end of else	*/
			if( (result == 0)
				|| (thefrontwin->inwindow->kind[0] == TMENU) )
				draw_inwind(thefrontwin,1);
			else
				draw_inwind(thefrontwin,0);

}

/*	'result' is the object in the inwindow tree	*/
		
int dbl_clsub(result)
	int result;
{
	int obj_type;

	obj_type = thefrontwin->inwindow->objt[result].ob_type;

	switch (obj_type)
	{
		case G_TEXT		:
		case G_BOXTEXT	:
		case G_FTEXT	:
		case G_FBOXTEXT	:	do_tist(result);
		  					break;
		case G_BUTTON	:
		case G_STRING	:
		case G_TITLE	:	do_buttont(result);
							break;
		case G_ICON		:
							break;
		case G_BOXCHAR	:	do_boxct(result);
							break;
		case G_BOX		:
		case G_IBOX		:	do_boxt(result);
							break;
	}
}

