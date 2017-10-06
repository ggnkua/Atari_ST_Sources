/*
*	Routine to add a child object to a parent object.  The child
*	is added at the end of the parent's current sibling list.
*	It is also initialized.
*/
	VOID
ob_add(tree, parent, child)
	REG LONG	tree;
	REG WORD	parent, child;
{
	REG WORD	lastkid;
	REG LONG	ptail;

	if ( (parent != NIL) &&
	     (child != NIL) )
	{
						/* initialize child	*/
	  LWSET(OB_NEXT(child), parent);

	  lastkid = LWGET( ptail = OB_TAIL(parent) );
	  if (lastkid == NIL)
						/* this is parent's 1st	*/
						/*   kid, so both head	*/
						/*   and tail pt to it	*/
	    LWSET(OB_HEAD(parent), child);
	  else
						/* add kid to end of 	*/
						/*   kid list		*/
	    LWSET(OB_NEXT(lastkid), child);
	  LWSET(ptail, child);
	}
} /* ob_add */

/*
*	Routine to delete an object from the tree.
*/
	VOID
ob_delete(tree, obj)
	REG LONG	tree;
	REG WORD	obj;
{
	REG WORD	parent;
	WORD		prev, nextsib;
	REG LONG	ptail, phead;

	if (obj != ROOT)
	  parent = get_par(tree, obj, &nextsib);
	else
	  return;

	if ( LWGET(phead = OB_HEAD(parent)) == obj )
	{
						/* this is head child	*/
						/*   in list		*/
	  if ( LWGET(ptail = OB_TAIL(parent)) == obj)
	  {
						/* this is only child	*/
						/*   in list, so fix	*/
						/*   head & tail ptrs	*/
	    nextsib = NIL;
	    LWSET(ptail, NIL);
	  }
						/*   move head ptr to 	*/
						/*   next child in list	*/
	  LWSET(phead, nextsib);
	}
	else
	{
						/* it's somewhere else,	*/
						/*   so move pnext	*/
						/*   around it		*/
	  prev = get_prev(tree, parent, obj);
	  LWSET(OB_NEXT(prev), nextsib);
	  if ( LWGET(ptail = OB_TAIL(parent)) == obj)
						/* this is last child	*/
						/*   in list, so move	*/
						/*   tail ptr to prev	*/
						/*   child in list	*/
	    LWSET(ptail, prev);
	}
} /* ob_delete */


/*
*	Routine to change the order of an object relative to its
*	siblings in the tree.  0 is the head of the list and NIL
*	is the tail of the list.
*/
	VOID
ob_order(tree, mov_obj, new_pos)
	REG LONG	tree;
	REG WORD	mov_obj;
	WORD		new_pos;
{
	REG WORD	parent;
	WORD		chg_obj, ii, junk;
	REG LONG	phead, pnext, pmove;

	if (mov_obj != ROOT)
	  parent = get_par(tree, mov_obj, &junk);
	else
	  return;

	ob_delete(tree, mov_obj);
	chg_obj = LWGET(phead = OB_HEAD(parent));
	pmove = OB_NEXT(mov_obj);
	if (new_pos == 0)
	{
						/* put mov_obj at head	*/
						/*   of list		*/
	  LWSET(pmove, chg_obj);
	  LWSET(phead, mov_obj);
	}
	else
	{
						/* find new_pos		*/
	  if (new_pos == NIL)
	    chg_obj = LWGET(OB_TAIL(parent));
	  else
	  {
	    for (ii = 1; ii < new_pos; ii++)
	      chg_obj = LWGET(OB_NEXT(chg_obj));
	  } /* else */
						/* now add mov_obj 	*/
						/*   after chg_obj	*/
	  LWSET(pmove, LWGET(pnext = OB_NEXT(chg_obj)));
	  LWSET(pnext, mov_obj);
	}
	if (LWGET(pmove) == parent)
	  LWSET(OB_TAIL(parent), mov_obj);
} /* ob_order */

