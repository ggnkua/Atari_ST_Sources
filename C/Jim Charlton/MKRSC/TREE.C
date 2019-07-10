#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"
#include "strings.h"


/*	trav_tree travels through an object tree from node 0 following
	the subtrees until it returns to node 0.  It records the index
	number of each object in the array 'order'.  It returns the
	total number of objects in the tree.  Objects that are encountered
	more than once (subtree nodes) are only entered into 'order' the
	first time that they are encountered.
*/


int trav_tree(tree,order)
	OBJECT	*tree;
	int		order[MAXONUM];
{
	int index, pos, head, next;
	

	index = 0;
	pos = 0;
	order[index] = 0;
	
	do
	{
		head = tree[pos].ob_head;
		next = tree[pos].ob_next;
		if( (head > -1 ) && (not_already(order,index,head)))	
		{	order[index+1] = head;
			pos = head;
			index++;
		}
		else if ( (next > -1) && (not_already(order,index,next)) )
		{	order[index+1] = next;
			pos = next;
			index++;
		}
		else if (next > -1)
			pos = next;
		else return(1);
	}
	while (tree[pos].ob_next > -1);
	return(index+1);
}

int not_already(order, index, head)
	int *order, index, head;
{
	int i;

	for (i=0;i < index+1;i++)
	{	if (order[i] == head)
			return(0);
	}
	return(1);
}
	
/*	ord_tree() travels an object tree and copies the objects to a 
	temporary tree in the proper order.  It then resets all of the 
	ob_next, ob_head and ob_tail pointers properly and recopies
	the final tree back into the original object tree array.
	I have rearranged the string, tedinfo etc arrays.  Lastly I reset
	thefrontwin->inwindow->count in case there have been deletions
*/

int ord_tree()
{
	int numobjs, i;
	int	order[MAXONUM];
	OBJECT *tmptree;
	objtreeptr	temp, thetree;
	OBJECT *inwinptr;

	temp  = (objtreeptr) malloc(sizeof(objtree));

	tmptree = temp->objt;

	thetree = thefrontwin->inwindow;

	inwinptr = thetree->objt;
	
	numobjs = trav_tree(inwinptr,order);

	thefrontwin->inwindow->count = numobjs-1;

	for (i=0;i<numobjs;i++)
	if(i != order[i])		/* don't copy identical things	*/
		tmptree[i] = inwinptr[order[i]];						/* objt	*/

	for (i=0;i<numobjs;i++)
	if(i != order[i])
		inwinptr[i] = tmptree[i];								/*	objt */

	for (i=0;i<numobjs;i++)
	{	inwinptr[i].ob_next = newpos(inwinptr[i].ob_next,numobjs,order);
		inwinptr[i].ob_head = newpos(inwinptr[i].ob_head,numobjs,order);
		inwinptr[i].ob_tail = newpos(inwinptr[i].ob_tail,numobjs,order);
	}

	for (i = 0; i < numobjs;i++)	
	if(i != order[i])
	{	bcopy(thetree->name[order[i]],temp->name[i],30);
		bcopy(thetree->strings[order[i]],temp->strings[i],60);
		bcopy(thetree->template[order[i]],temp->template[i],60);
		bcopy(thetree->valid[order[i]],temp->valid[i],60);
		temp->icblk[i] = thetree->icblk[order[i]];
		temp->ti[i] = thetree->ti[order[i]];
		temp->kind[i] = thetree->kind[order[i]];
		temp->treelink[i] = thetree->treelink[order[i]];
	}

	for (i = 0; i < numobjs;i++)
	if(i != order[i])
	{	bcopy(temp->name[i],thetree->name[i],30);
		bcopy(temp->strings[i],thetree->strings[i],60);
		bcopy(temp->template[i],thetree->template[i],60);
		bcopy(temp->valid[i],thetree->valid[i],60);
		thetree->icblk[i] = temp->icblk[i];
		thetree->ti[i] = temp->ti[i];
		thetree->kind[i] = temp->kind[i];
		thetree->treelink[i] = temp->treelink[i];

		switch (thetree->objt[i].ob_type)
		{
			case G_TEXT		:
			case G_BOXTEXT	:
			case G_FTEXT	:
			case G_FBOXTEXT	: 
				thetree->ti[i].te_ptext = (char *)thetree->strings[i];
				thetree->ti[i].te_ptmplt = (char *)thetree->template[i];
				thetree->ti[i].te_pvalid = (char *)thetree->valid[i];
				inwinptr[i].ob_spec = (char *)(&thetree->ti[i]);
				break;
			case G_BUTTON	:
			case G_STRING	:
			case G_TITLE	:
				inwinptr[i].ob_spec = (char *)thetree->strings[i];
				break;
			case G_ICON		:
				thetree->icblk[i].ib_ptext = (char *)thetree->name[i];
				inwinptr[i].ob_spec = (char *)(&thetree->icblk[i]);
				break;
		}		
	}
	free((char *)temp);
}	


int newpos(index,numobjs, order)
	int index, numobjs;
	int order[MAXONUM];
{
	int i;

	for (i=0;i < numobjs; i++)
		if (order[i] == index)
			return(i);
	return(-1);
}

/* 	in_ttl() puts new title entries onto the menu bar at the correct
	position given by x,y.  It makes a list of the index numbers of
	the current title numbers in ttls[] and the corresponding menu
	boxes in boxes[].  It uses these to position the new title and
	menu box entry.
*/

int in_ttl(x,y,paste)
	int x,y,paste;
{
	int	ttls[50], boxes[50], count, xoff, yoff;
	int i, head, tail, next, tparent, bparent, num;
	OBJECT *objptr, *tree;
	objtreeptr thetree;
	windowptr	thewin;

	thewin = thefrontwin;

	thetree = thefrontwin->inwindow;
	tree = thetree->objt;

	thefrontwin->inwindow->mbox = 0;

	for(i=0;i<(thefrontwin->inwindow->count + 1);i++)
				if(tree[i].ob_state & SELECTED)
					tree[i].ob_state &= ~SELECTED;

	objc_offset(tree,2,&xoff,&yoff);
	x = x - xoff;
	y = y - yoff;

/* handy pointer	*/
	num = ++thetree->count;

	if(paste)	
	{
			thefrontwin->inwindow->kind[num] = tempo.okind;
			strcpy(thefrontwin->inwindow->name[num],tempo.oname);
			strcpy(thefrontwin->inwindow->strings[num],tempo.ostrings);
			thefrontwin->inwindow->objt[num] = tempo.oobjt;
	}
	else
	{
/* copy the title into the object tree array in thetree struct */

	thetree->objt[num] = onleft[TITLE];

/* copy the oject index from onleft tree into 'kind'	*/

	thetree->kind[num] = TITLE;
	thetree->name[num][0] = NULL;

/* copy the TITLE string into the new object string space */

	strcpy(thetree->strings[num], onleft[TITLE].ob_spec);
	}
	thetree->objt[num].ob_spec = thetree->strings[num];

/* set up a handy ptr */
	objptr = &thetree->objt[num];

/* clear the pointers for the new object  */

	objptr->ob_next = -1;
	objptr->ob_head = -1;
	objptr->ob_tail = -1;

	tparent = 2;
	head = tree[tparent].ob_head;
	
	ttls[0]= head;
	for(next=head,i=1;(next!=2 && i < 500);next=tree[next].ob_next,i++)
		ttls[i] = tree[next].ob_next;
	count = i-1;	

/*	ttls contains the list of title index numbers
	and boxes contains the list of menu boxes
*/

	bparent = tree[1].ob_next;
	head = tree[bparent].ob_head;
	
	boxes[0] = head;
	for(next=head,i=1;(next!=bparent && i < 500);next=tree[next].ob_next,i++)
		boxes[i] = tree[next].ob_next;
		
/* insert the new title into the list of children */

	for(i=1;i<count;i++)
		if(tree[ttls[i]].ob_x > x)
			 break;

	objptr->ob_next = tree[ttls[i-1]].ob_next;
	if(objptr->ob_next == tparent)
		tree[tparent].ob_tail = num;
	tree[ttls[i-1]].ob_next = num;

/* put a new menu box into the tree	*/

	thetree->objt[++thetree->count] = onleft[MENUBOX];
	
/* handy pointer, as before	*/
	num = thetree->count;

/* set up a handy ptr, as before	 */
	objptr = &thetree->objt[num];

/* widen the box a bit	*/

	objptr->ob_width = 90;

/* insert new box into list of children	*/

	objptr->ob_next = tree[boxes[i-1]].ob_next;
	if(objptr->ob_next == bparent)
		tree[bparent].ob_tail = num;
	tree[boxes[i-1]].ob_next = num;

/* now rebuild the tree in perfect order and tidy up x values	*/

	tidy_m();
}


int tidy_m()
{
	int	ttls[50], boxes[50], count;
	int i, head, next, tparent, bparent, width;
	int	cx, cy, cw, ch;
	OBJECT *tree;
	objtreeptr thetree;
	windowptr	thewin;

	thewin = thefrontwin;

	thetree = thefrontwin->inwindow;
	tree = thetree->objt;

/* now rebuild the tree in perfect order	*/

	ord_tree();

/* clean up the x position of the new title and menu box
	first rebuild ttls and boxes
*/
	tparent = 2;
	head = tree[tparent].ob_head;

	ttls[0]= head;
	for(next=head,i=1;(next!=2 && i < 500);next=tree[next].ob_next,i++)
		ttls[i] = tree[next].ob_next;
	count = i-1;	

/*	ttls contains the list of title index numbers	*/

	bparent = tree[1].ob_next;
	head = tree[bparent].ob_head;
	
	boxes[0] = head;
	for(next=head,i=1;(next!=bparent && i < 500);next=tree[next].ob_next,i++)
		boxes[i] = tree[next].ob_next;

/* now fix x values */

	for(i=1;i<count;i++)
	{tree[ttls[i]].ob_x = tree[ttls[i-1]].ob_x + tree[ttls[i-1]].ob_width;
	 tree[ttls[i]].ob_y = tree[ttls[0]].ob_y;	
	 tree[boxes[i]].ob_x = tree[ttls[i]].ob_x + tree[boxes[0]].ob_x;
	 tree[boxes[i]].ob_y = tree[boxes[0]].ob_y;
	}

/* fix width of the box under the titles... object 2 in tree */

	for (i=0,width=0;i<count;i++)
	width += tree[ttls[i]].ob_width;
	tree[2].ob_width = width + 4;
	
}

/* 	mv_ttl() moves a title from one position to another
	it just unlinks an relinks the title and its associated
	menu box to a new position in the list of children and then
	tidies up the x values of the two lists of objects.
	'index' is the index of the title in the menu tree.
*/

int mv_ttl(index,x,y)
	int index,x,y;
{
	int	ttls[50], boxes[50], count, xoff, yoff;
	int i, head, tail, next, tparent, bparent, num, imbox;
	OBJECT *objptr, *tree;
	objtreeptr thetree;
	windowptr	thewin;

	thewin = thefrontwin;

	thetree = thefrontwin->inwindow;
	tree = thetree->objt;

	thefrontwin->inwindow->mbox = 0;

	for(i=0;i<(thefrontwin->inwindow->count + 1);i++)
				if(tree[i].ob_state & SELECTED)
					tree[i].ob_state &= ~SELECTED;

/* tparent is parent of titles and bparent parent of menu boxes	*/

		tparent = 2;
		bparent = tree[1].ob_next;

/* find the index number of the menu box associated with title 'index'	*/

		next = tree[bparent].ob_head;
		for (i=0;i<index-tparent;i++)
			{	imbox = next;
				next = tree[next].ob_next;
			} 

	objc_offset(tree,2,&xoff,&yoff);
	x = x - xoff;
	y = y - yoff;

/*	ttls contains the list of title index numbers
	and boxes contains the list of menu boxes
*/

	head = tree[bparent].ob_head;
	
	boxes[0] = head;
	for(next=head,i=1;(next!=bparent && i < 150);next=tree[next].ob_next,i++)
		boxes[i] = tree[next].ob_next;
	count = i-1;	
		
/* delete the title from the list of titles	*/

	tree[index-1].ob_next = tree[index].ob_next;
	if(tree[index].ob_next == tparent)
		tree[tparent].ob_tail = index-1;

/*	delete the associated menu box	*/

	for(i=0; i<count;i++)
		if (boxes[i] == imbox)
			break;

	tree[boxes[i-1]].ob_next = tree[imbox].ob_next;
	if(tree[imbox].ob_next == bparent)
		tree[bparent].ob_tail = boxes[i-1];
	
/* rebuild boxes and ttls  */

	head = tree[tparent].ob_head;
	
	ttls[0]= head;
	for(next=head,i=1;(next!=2 && i < 150);next=tree[next].ob_next,i++)
		ttls[i] = tree[next].ob_next;
	count = i-1;	

	head = tree[bparent].ob_head;
	
	boxes[0] = head;
	for(next=head,i=1;(next!=bparent && i < 150);next=tree[next].ob_next,i++)
		boxes[i] = tree[next].ob_next;
		
/* insert the new title into the list of children */

	for(i=1;i<count;i++)
		if(tree[ttls[i]].ob_x > x)
			 break;

	tree[index].ob_next = tree[ttls[i-1]].ob_next;
	if(tree[index].ob_next == tparent)
		tree[tparent].ob_tail = index;
	tree[ttls[i-1]].ob_next = index;

/* insert  box into new position	*/

	tree[imbox].ob_next = tree[boxes[i-1]].ob_next;
	if(tree[imbox].ob_next == bparent)
		tree[bparent].ob_tail = imbox;
	tree[boxes[i-1]].ob_next = imbox;

/* now rebuild the tree in perfect order and tidy up x values	*/

	tidy_m();
}

int name_obj()
{
	OBJECT *inwinptr;
	int		i, result;
	char newname[30];


/*	Set up handy pointer to right window object tree	*/

		inwinptr = thefrontwin->inwindow->objt;

/* point the tedinfo of the tree namer dialog to newname	*/

		((TEDINFO *)namobjt[NOEDIT].ob_spec)->te_ptext = newname;

/* point the tedinfo of the tree namer dialog to newname	*/

		((TEDINFO *)oldtree[NTEDIT].ob_spec)->te_ptext = newname;

	thefrontwin->saved = FALSE;

	if(thefrontwin->inwindow == &thefrontwin->maintree)
	 {	for(i=1;i<thefrontwin->inwindow->count+1;i++)
		if(inwinptr[i].ob_state & SELECTED)
		{	/* oldtree is object from RSC  */

			strcpy(newname,thefrontwin->inwindow->name[i]);

			oldtree[OTMENU].ob_state = NORMAL;
			oldtree[OTDIALOG].ob_state = NORMAL;
			oldtree[OTUNKNOW].ob_state = NORMAL;

			switch (thefrontwin->inwindow->kind[i])
			{
				case TMENU	:	oldtree[OTMENU].ob_state = SELECTED;
								break;
				case TDIALOG:	oldtree[OTDIALOG].ob_state = SELECTED;
								break;
				case TUNKNOWN:	oldtree[OTUNKNOW].ob_state = SELECTED;
								break;
			}
			result = do_dialog(oldtree,0);
			oldtree[OTOK].ob_state = NORMAL;
			oldtree[OTCANCEL].ob_state = NORMAL;
			if(result == OTCANCEL)
				return;
			else
			{ result = thefrontwin->inwindow->kind[i];
			  if (oldtree[OTMENU].ob_state & SELECTED) result = TMENU;
			  else if (oldtree[OTDIALOG].ob_state & SELECTED) result = TDIALOG;
			  else if (oldtree[OTUNKNOW].ob_state & SELECTED) result = TUNKNOWN;
			  if(thefrontwin->inwindow->kind[i] != result)
				{	thefrontwin->inwindow->kind[i] = result;
					thefrontwin->inwindow->treelink[i]->kind[0] = result;
	/* copy the new icon's ICONBLK to the maintree array of ICONBLKs	*/

					thefrontwin->inwindow->icblk[i] =
								 *((ICONBLK *)(treicont[result].ob_spec));
	/*  and point ICONBLK ptext to 'name' in maintree struct */

					thefrontwin->inwindow->icblk[i].ib_ptext = 
								thefrontwin->inwindow->name[i];
				}
			oldtree[OTMENU].ob_state = NORMAL;
			oldtree[OTDIALOG].ob_state = NORMAL;
			oldtree[OTUNKNOW].ob_state = NORMAL;
			if(strcmp(newname,thefrontwin->inwindow->name[i]) == 0)
				 return;
			if (check_name(newname) == 1)
					strcpy(thefrontwin->inwindow->name[i],newname);
			return;
			}
		}  /*  end of 'if icon selected in maintree'	*/
	}	/*  end of 'if its the manitree'	*/
	else	/* must be a subtree	*/
		{for(i=1;i<thefrontwin->inwindow->count+1;i++)
			if(inwinptr[i].ob_state & SELECTED)
			{	/* namobjt is object from RSC  */
	
				strcpy(newname,thefrontwin->inwindow->name[i]);

				result = do_dialog(namobjt,0);
				namobjt[NOOK].ob_state = NORMAL;
				namobjt[NOCANCEL].ob_state = NORMAL;
				if(result == NOCANCEL)
					return;
				if(strcmp(newname,thefrontwin->inwindow->name[i]) == 0)
					return;
				if (check_name(newname) == 1)
					strcpy(thefrontwin->inwindow->name[i],newname);
				return;
			}	
		}
}
/*	check_name() returns 0 if an object or tree already has that
	name... otherwise returns 1
*/

int check_name(str)
	char *str;
{
		int i, j;	
		objtreeptr	thesubtree;

		for(j=1;j<thefrontwin->maintree.count+1;j++)
		{
			if( (strlen(thefrontwin->maintree.name[j]) >0)
				&& (strcmp(thefrontwin->maintree.name[j],str) == 0) )
        	{	form_alert(1, "[0][   There is already an  |   object with that name.   |   Choose another name.   ][ OK ]");
				return(0);
			}
			thesubtree = thefrontwin->maintree.treelink[j];
			for(i=1;i<thesubtree->count+1;i++)
			{
				if( (strlen(thesubtree->name[i]) >0)
					&& (strcmp(thesubtree->name[i],str) == 0) )
        		{	form_alert(1, "[0][   There is already an  |   object with that name.   |   Choose another name.   ][ OK ]");
					return(0);
				}
			}
		}
		return(1);
}
	
