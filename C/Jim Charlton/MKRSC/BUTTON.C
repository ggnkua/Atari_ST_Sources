#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"


int do_button(mousex,mousey,clicks)
	int mousex,mousey,clicks;
{
	int result, i, parent;
	OBJECT *inwinptr;
	int mx, my, ms, kbd_state, wi_gw1, dummy;

/*	check if mouse is over object in left box.  
	If it is start to drag it over to the right hand window.
	Does both maintree and subtree.
*/

	result = objc_find(onleft,1,2,mousex,mousey);
	if(result > 1)
	{	drag_left(result);

	}
/*	If a window is open check to see if mouse was clicked
	over an object in the window.
*/
	else
	{	if(thefrontwin)
	 {
	/* set a handy pointer to obj tree in window */

		inwinptr = thefrontwin->inwindow->objt;

/*	if its a menu tree, check to see if its a title
	if its not a title then search the currently
	open dropdown menu box (mbox)
*/

	if(thefrontwin->inwindow->kind[0] == TMENU)
		{ if( (result = objc_find(inwinptr,2,2,mousex,mousey)) == -1)
		  if (thefrontwin->inwindow->mbox > 0)
			result = objc_find(inwinptr,thefrontwin->inwindow->mbox,
														2,mousex,mousey);
		}
	else
		result = objc_find(inwinptr,0,10,mousex,mousey);

		if(result != -1)
		{	if(inwinptr == thefrontwin->maintree.objt)

/*	If it was over an object in the window and if its the icon maintree. */

				hand_maintree(clicks,result);		
			else
			{	/* else it was over a subtree object	*/
				/* control key depressed? */
				graf_mkstate(&mx,&my,&ms,&kbd_state); 
				if(kbd_state == 0x4)
					if( (thefrontwin->inwindow->kind[0] != TMENU)
						|| ( (inwinptr[result].ob_type != G_TITLE)
								&& result != thefrontwin->inwindow->mbox ) )
					{	parent = find_parent(inwinptr,result);
						if(result != -1)
							result = parent;
					}
					thefrontwin->saved = FALSE;
					hand_subtree(clicks,result,mousex,mousey);	/* in addsub.c */
			}
		}
		else	/* result == -1, deselect all objects and redraw	*/
			{	wind_get(0,WF_TOP,&wi_gw1,&dummy,&dummy,&dummy);
				if(wi_gw1 == thefrontwin->wihandle)
				{	for(i=0;i<(thefrontwin->inwindow->count + 1);i++)
					if(inwinptr[i].ob_state & SELECTED)
						inwinptr[i].ob_state &= ~SELECTED;
					draw_inwind(thefrontwin,0);	
				}
			}
	 }			/* if(thefrontwin)			*/
	}			/* else						*/
}	

/*	find_parent() returns the index number of the parent of the
	object 'result' or returns -1
*/

int find_parent(objptr,result)
	OBJECT *objptr;
	int	result;
{
	int next, tail, current;

	current = result;
	next = objptr[result].ob_next;
	if(result == 0 || next < 0 )
		return(-1); /* bail out if this is root node	*/
	while (objptr[next].ob_tail != current)
	{	current = next;
		next = objptr[current].ob_next;
		if(next < 0)
			return(-1); /* bail out if you get lost.. can't happen	*/
	}
	return(next);
}


hand_maintree(clicks,result)
	int clicks, result;
{
	int i;
	OBJECT	*inwinptr;
	int mx, my, mstate, kbdstate;
	objtreeptr	tempmain;

			inwinptr = thefrontwin->inwindow->objt;

			if(clicks == 2) 
			{
				dbl_click(result);
			}
			else if (result > 0)		/*  clicks = 1   */
			{

	/* making icons radio buttons does not seem to work so I have to
		deselect and redraw the other icons myself
	*/
			for(i=1;i<(thefrontwin->inwindow->count + 1);i++)
				if( (inwinptr[i].ob_state & SELECTED) && (result != i) )
					inwinptr[i].ob_state &= ~SELECTED;
	
	/* toggle state of the selected icon and redraw tree	*/

				inwinptr[result].ob_state ^= SELECTED;

	/* check if the mouse button and left-shift are being held down	*/

		graf_mkstate(&mx, &my, &mstate, &kbdstate);
		if(mstate == 1 && kbdstate == 0x2)
			{ 	if(tempmain = copy_tree(1));
				{	if(tempm)
						{	free(tempm->treelink[0]);
							free(tempm);
						}
						tempm = tempmain;
						paste_tree(tempm);
						return;
				}
			}

				draw_inwind(thefrontwin,0);

			}

}


/* 	dragging icons from onleft tree to inwindow tree.
	objptr1 is the onleft objptr, index is the object
	selected.
*/		

drag_left(index)
	int index;
{
	int result, button;
	int sw, sh, sx, sy, bw, bh, bx, by;
	int xoff, yoff;
	int finalx,finaly, new_parent;
	OBJECT *objptr2;
	OBJECT *iconptr;

	objc_offset(onleft, index, &xoff, &yoff); /* need xoff yoff for dragbox */
	iconptr = &onleft[index];

	sx = xoff;	/* size of box to drag  */
	sy = yoff;
	sw = iconptr->ob_width;
	sh = iconptr->ob_height;

	set_clip(xdesk,ydesk,wdesk,hdesk); /* set_clip to desktop */

	bx = xdesk; /* sets limits to where you can drag box   */
	by = ydesk;
	bw = wdesk;
	bh = hdesk;

		graf_dragbox(sw,sh,sx,sy,bx,by,bw,bh,&finalx,&finaly);
	
	if(thefrontwin)
	{	thefrontwin->saved = FALSE;
		objptr2 = thefrontwin->inwindow->objt;

/*	objptr2 points to the active object tree in the window	*/

/* 	new_parent is the index number of the object in the window over which
	the icon has been moved.  'index' is the index number of the icon
	which was moved from the lefthand object tree.
*/
		result = objc_find(objptr2,0,10,finalx,finaly);
		if(result != -1)
		{		if(thefrontwin->inwindow == &thefrontwin->maintree)
			/* moving icons to maintree		*/
					add_lefticon(iconptr,index,0);
				else
			/* moving objects to subtree		*/
				{	new_parent = good_parent(objptr2,finalx,finaly,sw,sh,-2);
					if(new_parent != -1)
						add_tosub(iconptr,new_parent,index,finalx,finaly);
				}
		}
	}
}

/*
	You now want to move the icon (object) from the left hand menu pointed
	to by iconptr to the tree structure inwindow.  It must be added to the
	array of objects in inwindow->objt[], and count incremented.  Then you
	must link it to the other objects in the array with objc_add().  You 
	link it to the parent object pointed to by the index number 
	'nindex'.  'oindex' is the index number of the icon in the onleft
	box (tree).  Since this is the maintree of menu and dialog icons
	nindex should always be 0, the box that the window opens with.
	'rflag' = 1 allows this function to be also used for retrieving old
	resource files.  See retrv.c 
*/	

int add_lefticon(iconptr,oindex, rflag)
	OBJECT		*iconptr;
	int			oindex, rflag;
{
	int result, num, i, nindex;
	int cx,cy,cw,ch;
	OBJECT *objptr2;
	windowptr thewin;
	objtreeptr thetree;
	ICONBLK *ibptr;
	char newname[30];
	
	nindex = 0;

	thewin = thefrontwin;

/*	copy the icon into the maintree array. 	*/

	thewin->inwindow->objt[++thewin->inwindow->count] = *iconptr;

	num = thewin->inwindow->count;

/* copy the icon type (menu, dialog or unknown) into 'kind'	*/

	thewin->inwindow->kind[num] = oindex;

/* set up a handy ptr */
	objptr2 = &thewin->inwindow->objt[num];

/* clear the pointers for the new object  */

	objptr2->ob_next = -1;
	objptr2->ob_head = -1;
	objptr2->ob_tail = -1;

/* set its position */

	objptr2->ob_x = 20 + ((num-1)%8)*50;
	objptr2->ob_y = 20 + ((num-1)/8)*35;
	
/* make it a last object  */

	objptr2->ob_flags |= LASTOB;

/* allocate a linked objtree structure for the icon and initialize	*/

	thetree	  = (objtreeptr) malloc(sizeof(objtree));

	thetree->count = 0;
	thetree->mbox = 0;
	for(i=0;i<MAXONUM;i++)
	{	thetree->treelink[i] = NULL;
		thetree->kind[i] = 0;
		thetree->name[i][0] = NULL;
		thetree->strings[i][0] = NULL;
		thetree->template[i][0] = NULL;
		thetree->template[i][0] = NULL;
	}

/*	set up a flag to later identify the tree as a menu or dialog	*/
	thetree->kind[0] = oindex;

/*  put addr of linked objtree structure into maintree pointer array  */
	thewin->inwindow->treelink[num] = thetree;

/* dup the icon's ICONBLK to the maintree array of ICONBLKs	*/

	thewin->inwindow->icblk[num] = *((ICONBLK *)(onleft[oindex].ob_spec));

/*	Give the linked objtree a starting dialog box or menu bar.
	The value of 17 for the total objects in the dummy menu tree
	may change if the tree is rebuilt.  The number 17, or its 
	relacement should be the total number of objects in the dummy
	menu tree.  Since there are some objects that may have been erased,
	it is the maximum index number into the tree for a object used by
	tree.  (copying 20 objects to be sure but setting count = 16).
*/
	if(!(rflag))
	{
	if(oindex == TMENU)
	{	bcopy((char *)dummnu,(char *)thetree->objt,(20*sizeof(OBJECT)));
		thetree->count += 16;  /* 17 objects 0 to 16  */;
		thetree->objt[thetree->count].ob_flags |= LASTOB;
	for(i=0;i<17;i++)
	switch (thetree->objt[i].ob_type)
		{	case G_BUTTON	:
			case G_STRING	:
			case G_TITLE	:
			strcpy(thetree->strings[i],thetree->objt[i].ob_spec);
			thetree->objt[i].ob_spec = thetree->strings[i];
			break;
		}
	}
	else
	{	thetree->objt[0] = *mtbox1;
		thetree->objt[thetree->count].ob_flags |= LASTOB;
	}
	}
/* get its new name, put into maintree name array */

	sprintf(thewin->inwindow->name[num],"TREE%03d",++iconum);
	
/* point ob_spec of new icon object to its new ICONBLK structure  */

	(ICONBLK *)thewin->inwindow->objt[num].ob_spec =
								 &thewin->inwindow->icblk[num];
	
/*  and point ICONBLK ptext to 'name' in maintree struct */

	thewin->inwindow->icblk[num].ib_ptext = thewin->inwindow->name[num];

/* point the tedinfo of the tree namer dialog to newname*/
	if(!(rflag))
	{
		strcpy(newname,thewin->inwindow->name[num]);
	((TEDINFO *)newtree[NTEDIT].ob_spec)->te_ptext = newname;
	
	result = do_dialog(newtree,NTEDIT);	/* newtree is object from RSC  */
	newtree[NTOK].ob_state = NORMAL;
	newtree[NTCANCEL].ob_state = NORMAL;

	if (result == NTCANCEL)
		{	thewin->inwindow->count--;
			free(thetree);
			return;
		}
	if(  (strcmp(newname,thewin->inwindow->name[num]) == 0)
		 || (check_name(newname) == 1) )
			strcpy(thewin->inwindow->name[num],newname);
		
	}
/* link the new object into its parent   */

	result = objc_add(thewin->inwindow->objt,nindex,num);
	
/* reset the LASTOB for the previous object in tree  */

	thewin->inwindow->objt[num-1].ob_flags &= ~LASTOB;
	draw_inwind(thefrontwin,0);
	
}
		
/*	dbl_click() handles icons that have been dbl clicked.  For the root
	objtree, this means drawing the appropriate linked subtree.
	'index' is the number of the object in the 'inwindow' tree.
*/

int dbl_click(index)
	int index;
{
	OBJECT	*subtrptr;
	objtreeptr	themtree, thesubtree;
	int cx,cy,cw,ch;

	if(index == 0)
		return;

	cx = thefrontwin->work.g_x;
	cy = thefrontwin->work.g_y;
	cw = thefrontwin->work.g_w;
	ch = thefrontwin->work.g_h;

	switch (thefrontwin->inwindow->kind[index])
	{
		case TMENU	:	draw_obj(mnuicont);
						break;
		case TDIALOG :
		case TUNKNOWN:	draw_obj(obicont);
						break;
		case 0		:	break;
/* 	only maintree icons have kind set ....  this is a lie!
	kind[0] of the subtree is also set to the same value as
	kind[i] of the maintree icon 'i'.  But kind[0] of the maintree
	is always 0.  The icon objects start at 1.
*/
	}


	themtree = thefrontwin->inwindow;
	themtree->mbox = 0;

	thesubtree = themtree->treelink[index];
	thefrontwin->inwindow = thesubtree;

	/* handy pointer */

	subtrptr = thesubtree->objt;

	/* put into window */

	subtrptr->ob_x = cx;
	subtrptr->ob_y = cy;
	set_clip(cx,cy,cw,ch);
	whiterect(thefrontwin);	
	if(thefrontwin->maintree.kind[index] == TMENU)
		objc_draw(subtrptr,1,2,cx,cy,cw,ch);
	else
		objc_draw(subtrptr,0,10,cx,cy,cw,ch);
}

