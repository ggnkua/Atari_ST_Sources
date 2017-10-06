AES_function XA_form_button	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_TREE *wt = &client->wt;
	OBJECT *tree = (OBJECT*)pb->addrin[0];
	short ob = pb->intin[0];
	short is, os;
	RECT r;

	CONTROL(2,2,1)

	wt->tree = tree;
	pb->intout[1] = 0;

	if (tree[ob].ob_flags & EDITABLE)	/* Select a new editable text field? */
	/* Shouldn't this really do all that's done in form_do? */
		pb->intout[1] = ob;

	if (((tree[ob].ob_flags & HIDETREE) 		/* Was click on a valid selectable object? */
		|| (    tree[ob].ob_state & DISABLED))
		|| ( ! (tree[ob].ob_flags & (SELECTABLE | EXIT | TOUCHEXIT))))
	{
		pb->intout[0] = 1;				/* continue */
		return XAC_DONE;
	}

	os = tree[ob].ob_state;
	is = os ^ SELECTED;

	if (tree[ob].ob_flags & TOUCHEXIT)	/* Change state & exit for TOUCHEXIT objects */
	{
/*
 * Surely radio buttons must be handled as well?
 */
		/* Only selectable objects change appearance! */
		if (tree[ob].ob_flags & SELECTABLE)
		{
			tree[ob].ob_state = is;
			redraw_object(lock, wt, ob); 
		}

		pb->intout[1] = ob;
		
		pb->intout[0] = 0;				/* not continue */
		
		if (pb->intin[1] == 2)	/* Double click? */
			pb->intout[1] |= 0x8000;

		return XAC_DONE;
	}

/*
 * Should this perhaps be done in watch_object()?
 */
 	tree[ob].ob_state = is;
	redraw_object(lock,wt, ob); 
		
	if (watch_object(lock, wt, ob, is, os))	/* Do a watch to see if object is really selected */
	{
		if ( ! (tree[ob].ob_flags & SELECTABLE))
		{
			tree[ob].ob_state = os;
			redraw_object(lock, wt, ob);
		}
/*
 * Surely this should check for radio buttons?
 */
 		if (tree[ob].ob_flags & EXIT)
		{
			pb->intout[1] = ob;
			pb->intout[0] = 0;				/* not continue */
			return XAC_DONE;
		}
	}

	pb->intout[0] = 1;
	return XAC_DONE;
} 
