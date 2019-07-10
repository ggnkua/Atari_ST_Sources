#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"


/*	dragging and resizing things in the window.  Index is the
	object to be dragged/resized.
*/

drag_right(index,mx,my)
	int		index,mx,my;
{
	int result, c, newstate, new_parent, parent;
	int sw, sh, sx, sy, bw, bh, bx, by;
	int xoff, yoff, an_mbox, next, xlim, ylim, nw, nh, nx, ny;
	int finalx,finaly, finalw,finalh;
	OBJECT *sobjptr;
	OBJECT *subtrptr;
	int	cx, cy, ms, kbd_state;

	xlim = ylim = 0;

	if(thefrontwin->inwindow->kind[0] == TMENU)
		{	drag_menu(index,mx,my);
			return;
		}
	subtrptr = thefrontwin->inwindow->objt;
	sobjptr = &subtrptr[index];
	an_mbox = thefrontwin->inwindow->mbox;

	/* need xoff yoff for dragbox */

	objc_offset(subtrptr, index, &xoff, &yoff);

	sx = xoff;	/* size of box to drag  */
	sy = yoff;
	sw = sobjptr->ob_width;
	sh = sobjptr->ob_height;

	/* sets limits to where you can do things */


			if(index == 0)
			{	bx = thefrontwin->work.g_x;
				by = thefrontwin->work.g_y;
				bw = thefrontwin->work.g_w;
				bh = thefrontwin->work.g_h;
			}
			else
			{	bx = subtrptr[0].ob_x;
				by = subtrptr[0].ob_y;
				bw = subtrptr[0].ob_width;
				bh = subtrptr[0].ob_height;
			}
		
	newstate = subtrptr[index].ob_state | SELECTED;
	objc_change(subtrptr,index,0,bx,by,bw,bh,newstate,1);

/*	check to see if mouse is near corner of object indicating that
	you should do a graf_rubberbox in order to resize object.
*/

	if( (mx < (sx+sw)) && ((sx+sw-mx) < 7)
			&& (my < (sy+sh)) && ((sy+sh-my) < 7) )
		
		{	graf_rubberbox(sx,sy,gl_wchar,gl_hchar,&finalw,&finalh);
/*	never make an object too small to encompass a child	*/
			if((next = subtrptr[index].ob_head) > 0)
			{	while(next != index)
				{	xlim = max(xlim,subtrptr[next].ob_x +
								 		subtrptr[next].ob_width);
					ylim = max(ylim,subtrptr[next].ob_y +
								 		subtrptr[next].ob_height);
					next = subtrptr[next].ob_next;
				}
			}
			if(finalw < xlim)
				finalw = xlim;
			if(finalh < ylim)
				finalh = ylim;
/*  never allow an object outside its parent	*/
			if((parent = find_parent(subtrptr,index)) != -1)
			{ if(finalw > subtrptr[parent].ob_width - subtrptr[index].ob_x)
				 finalw = subtrptr[parent].ob_width - subtrptr[index].ob_x; 
			  if(finalh > subtrptr[parent].ob_height - subtrptr[index].ob_y)
				 finalh = subtrptr[parent].ob_height - subtrptr[index].ob_y; 
			}
/*	make sure we are inside the window or object 0	*/
			if(finalw > (bw - sx + bx))
				finalw = bw - sx + bx;
			if(finalh > (bh - sy + by))
				finalh = bh - sy + by;
			sobjptr->ob_height = finalh;
			sobjptr->ob_width = finalw;
			if(snap)
			{	sobjptr->ob_width += gl_wchar/2;
				sobjptr->ob_width &= 0xFFF8;
				sobjptr->ob_height += gl_hchar/2;
				sobjptr->ob_height &=  (0xFFFF - gl_hchar + 1);
			}
			subtrptr[index].ob_state &= ~SELECTED;
			return;
		}

/*	Is the left-shift key down signifying a copy operation?	*/

	graf_mkstate(&cx,&cy,&ms,&kbd_state); 
	if( kbd_state == 0x2 )
	{ 	if(copy_obj(1));
			paste_obj();
		return;
	}

/*	can't move tree root   */

	if(index == 0) return;
	
	result = graf_dragbox(sw,sh,sx,sy,bx,by,bw,bh,&finalx,&finaly);
	if(result == 0) return;

/*	now find parent over which the object has been dragged	*/

	nw = sobjptr->ob_width;
	nh = sobjptr->ob_height;

	new_parent = good_parent(subtrptr,finalx,finaly,nw,nh,index); 
	if(new_parent == -1)
		return;

	c = objc_offset(subtrptr, new_parent, &xoff, &yoff);
	if(c == 0) return;

	sobjptr->ob_x = finalx - xoff;
	sobjptr->ob_y = finaly - yoff;
	if(snap)
	{	sobjptr->ob_x += gl_wchar/2;
		sobjptr->ob_x &= 0XFFF8;
		sobjptr->ob_y += gl_hchar/2;
		sobjptr->ob_y &= (0XFFFF - gl_hchar + 1);
	}

	c = objc_delete(subtrptr,index);
	c = objc_add(subtrptr,new_parent,index);
	
	/* deselect the object and redraw tree	*/

	subtrptr[index].ob_state &= ~SELECTED;

}

/*	good_parent() finds the first parent for an object that completely
	encompasses the object.  If it fails it returns -1.  x and y are the
	upper left coordinates of the incomeing object, w and h its width
	and height.  Index is its index number in the tree, if it is already
	a member of the tree.  Make index = -2 if its a new object to be
	added or pasted.
*/

int good_parent(objtr,x,y,w,h,index)
	OBJECT	*objtr;
	int	x,y,w,h,index;
{	
	int next, i, j, xoff, yoff, numobjs, nx, ny;
	int order[MAXONUM];
	int a, cx, cy, result, found;

/*	make a list of objects under the mouse in all_par[]	*/

	numobjs = trav_tree(objtr,order);

/* find the topmost object that is under any corner of the object	*/

	for(i= numobjs-1; i > -1; i--)
	{	a = -1;
		found = TRUE;
		cx = x;
		cy = y;
		if((a = objc_find(objtr,order[i],0,cx,cy)) < 0)
		{	cy = y + h;
			if((a = objc_find(objtr,order[i],0,cx,cy)) < 0)
			{	cx = x + w;
				if((a = objc_find(objtr,order[i],0,cx,cy)) < 0)
				{	cy = y;
					if((a = objc_find(objtr,order[i],0,cx,cy)) < 0)
					found = FALSE;
				}
		 	}
		 }
		 
/*	check to see if all four corners of snapped (or unsnapped) object
	is over the potential parent a
*/
		if(found)	 
		{	result = objc_offset(objtr, a, &xoff, &yoff);
			if ( result == 0) return -1;
			nx = x - xoff;
			ny = y - yoff;
			if(snap)
			{	nx += gl_wchar/2;
				nx &= 0XFFF8;
				ny += gl_hchar/2;
				ny &= (0XFFFF - gl_hchar + 1);
			}
			if (	(nx >= 0)
				&&	(ny >= 0)
				&&	(objtr[a].ob_width >= (nx + w))	
				&&	(objtr[a].ob_height >= (ny + h))
				&&  (a != index)	)
				return(a);
		}
	}
	return(-1);
}

drag_menu(index,mx,my)
	int		index,mx,my;
{
	int result, c, newstate;
	int sw, sh, sx, sy, bw, bh, bx, by;
	int xoff, yoff, an_mbox, next, xlim, ylim;
	int finalx,finaly, finalw, finalh;
	OBJECT *sobjptr;
	OBJECT *subtrptr;
	int titles[25], num_ti, i, doit, pos;
	int	cx, cy, ms, kbd_state;
	xlim = ylim = 0;

	subtrptr = thefrontwin->inwindow->objt;
	sobjptr = &subtrptr[index];
	an_mbox = thefrontwin->inwindow->mbox;

	/* need xoff yoff for dragbox */

	objc_offset(subtrptr, index, &xoff, &yoff);

	sx = xoff;	/* size of box to drag  */
	sy = yoff;
	sw = sobjptr->ob_width;
	sh = sobjptr->ob_height;

	/* sets limits to where you can do things */

	 if(sobjptr->ob_type == G_TITLE) 
		{	objc_offset(subtrptr,1,&xoff,&yoff);
			bx = xoff;
			by = yoff;
			bw = subtrptr[1].ob_width;
			bh = subtrptr[1].ob_height;
		}
	else if (index == an_mbox)
		{	bx = subtrptr[0].ob_x;
			by = subtrptr[0].ob_y;
			bw = subtrptr[0].ob_width;
			bh = subtrptr[0].ob_height;
		}
	else	
		{	objc_offset(subtrptr,an_mbox,&xoff,&yoff);
			bx = xoff;
			by = yoff;
			bw = subtrptr[an_mbox].ob_width;
			bh = subtrptr[an_mbox].ob_height;
		}
	
/*	check to see if mouse is near corner of object indicating that
	you should do a graf_rubberbox in order to resize object.
*/

	if( (mx < (sx+sw)) && ((sx+sw-mx) < 5)
			&& (my < (sy+sh)) && ((sy+sh-my) < 5) )
		
		{	newstate = subtrptr[index].ob_state & ~SELECTED;
			objc_change(subtrptr,index,0,bx,by,bw,bh,newstate,1);
			graf_rubberbox(sx,sy,gl_wchar,gl_hchar,&finalw,&finalh);

/*	never make an object too small to encompass a child	*/

			if((next = subtrptr[index].ob_head) > 0)
			{	while(next != index)
				{	xlim = max(xlim,subtrptr[next].ob_x +
								 		subtrptr[next].ob_width);
					ylim = max(ylim,subtrptr[next].ob_y +
								 		subtrptr[next].ob_height);
					next = subtrptr[next].ob_next;
				}
			}
			if(finalw < xlim)
				finalw = xlim;
			if(finalh < ylim)
				finalh = ylim;
/*	keep within the appropriate parent	*/
			if(finalw > (bw - sx + bx))
				finalw = bw - sx + bx;
			if(finalh > (bh - sy + by))
				finalh = bh - sy + by;
			sobjptr->ob_height = (finalh + gl_hchar/2);
			sobjptr->ob_width = finalw + gl_wchar/2;
			sobjptr->ob_width &= 0xFFF8;
			sobjptr->ob_height &=  (0xFFFF - gl_hchar + 1);

			if(sobjptr->ob_type == G_TITLE)
			{	sobjptr->ob_height = 0x13; 
				tidy_m();
			}
			return;
		}

/*	Is the left-shift key down signifying a copy operation
	of title or menu item?
*/

	graf_mkstate(&cx,&cy,&ms,&kbd_state); 
	if( kbd_state == 0x2 )
	{ 	if(copy_obj(1));
			paste_obj();
		return;
	}

/* can't move current drop down box	*/

	if(index == an_mbox) return;
		
/*	can't move menu objects 0, 1, and 2  */

	if(index < 3) return;
	
	result = graf_dragbox(sw,sh,sx,sy,bx,by,bw,bh,&finalx,&finaly);
	if(result == 0) return;

	subtrptr[index].ob_state &= ~SELECTED;

	 if( (sobjptr->ob_type == G_TITLE) && (index > 3 ) )
		{
			mv_ttl(index,finalx,finaly);   /*   in tree.c   */
		}
	else 
		{

/* check to make sure that you are not overlaying items in mbox	*/

	result = objc_find(subtrptr,0,10,finalx,finaly);
	if(result != an_mbox)
		return;
	
	c = objc_offset(subtrptr, an_mbox, &xoff, &yoff);
	if(c == 0) return;

	/* place the object properly	*/

	sobjptr->ob_x = finalx-xoff + gl_wchar/2;
	sobjptr->ob_y = finaly-yoff+gl_hchar/2;
	sobjptr->ob_x &= 0XFFF8;
	sobjptr->ob_y &= (0XFFFF - gl_hchar + 1);

	/* reorder tree	*/

	ord_tree();

		}		
}
