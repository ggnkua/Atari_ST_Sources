/*	Change code to compensate 3D objects	*/

	WORD
gr_slidebox(tree, parent, obj, isvert)
	REG LONG		tree;
	WORD		parent;
	WORD		obj;
	WORD		isvert;
{
	REG GRECT	*pt, *pc;	/* new pointer for Reg Opt	*/
	GRECT		t, c;
	REG WORD	divnd, divis;
	OBJECT		*objc;
	WORD		pflags,cflags;

	pt = &t;
	pc = &c;
				/* get the parent real position */
	ob_actxywh(tree, parent, pc);
				/* get the relative position	*/
	ob_relxywh(tree, obj, pt);

	objc = tree;
 	pflags = objc[parent].ob_flags;
	cflags = objc[obj].ob_flags;	

	if ( ( pflags & IS3DOBJ ) )
	  pflags = 1;
	else
	  pflags = 0;

	if ( ( cflags & IS3DOBJ ) )
	  cflags = 1;
	else
	  cflags = 0;
	  
	if ( cflags ) 	/* if the child is 3D, then check 	    */
	{	
	  if ( !pflags ) /* if parent is not 3D, then the child is   */
	  {		/* ADJ3DPIX off, we need to adjust it	    */
  	    pt->g_x -= ADJ3DPIX;
	    pt->g_y -= ADJ3DPIX;
	  }	
	  pt->g_w += (ADJ3DPIX << 1);
	  pt->g_h += (ADJ3DPIX << 1);		  	  
	}

	gr_dragbox( pt->g_w, pt->g_h, pt->g_x + pc->g_x, pt->g_y + pc->g_y, 
		    pc, &pt->g_x, &pt->g_y ); 

	if ( isvert )		/* vertical movement	*/
	{
	  divnd = pt->g_y - pc->g_y;
	  divis = pc->g_h - pt->g_h;
	}
	else			/* horizontal movement	*/
	{
	  divnd = pt->g_x - pc->g_x;
	  divis = pc->g_w - pt->g_w;
	}

	if (divis)
	  return( mul_div( divnd, 1000, divis) );
	else
	  return(0);
}

