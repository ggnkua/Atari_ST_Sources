>>>>>>>>>>>>>>>>>>>>>>> Basic Dialog Handler <<<<<<<<<<<<<<<<<<<<<<<

	WORD
hndl_dial(tree, def, x, y, w, h)
	LONG	tree;
	WORD	def;
	WORD	x, y, w, h;
	{
	WORD	xdial, ydial, wdial, hdial, exitobj;

	form_center(tree, &xdial, &ydial, &wdial, &hdial);
	form_dial(0, x, y, w, h, xdial, ydial, wdial, hdial);
	form_dial(1, x, y, w, h, xdial, ydial, wdial, hdial);
	objc_draw(tree, ROOT, MAX_DEPTH, xdial, ydial, wdial, hdial);
	exitobj = form_do(tree, def) & 0x7FFF;
	form_dial(2, x, y, w, h, xdial, ydial, wdial, hdial);
	form_dial(3, x, y, w, h, xdial, ydial, wdial, hdial);
	return (exitobj);
	}

>>>>>>>>>>>>>>>>>>>>>>> Object rectangle utility <<<<<<<<<<<<<<<<<<<<<<<<<

	VOID
objc_xywh(tree, obj, p)		/* get x,y,w,h for specified object	*/
	LONG	tree;
	WORD	obj;
	GRECT	*p;
	{
	objc_offset(tree, obj, &p->g_x, &p->g_y);
	p->g_w = LWGET(OB_WIDTH(obj));
	p->g_h = LWGET(OB_HEIGHT(obj));
	}

>>>>>>>>>>>>>>>>>>>>>>> Object flag utilities <<<<<<<<<<<<<<<<<<<<<<<<<<<

	VOID
undo_obj(tree, which, bit)	/* clear specified bit in object state	*/
	LONG	tree;
	WORD	which, bit;
	{
	WORD	state;

	state = LWGET(OB_STATE(which));
	LWSET(OB_STATE(which), state & ~bit);
	}

	VOID
desel_obj(tree, which)		/* turn off selected bit of spcfd object*/
	LONG	tree;
	WORD	which;
	{
	undo_obj(tree, which, SELECTED);
	}

	VOID
do_obj(tree, which, bit)	/* set specified bit in object state	*/
	LONG	tree;
	WORD	which, bit;
	{
	WORD	state;

	state = LWGET(OB_STATE(which));
	LWSET(OB_STATE(which), state | bit);
	}

	VOID
sel_obj(tree, which)		/* turn on selected bit of spcfd object	*/
	LONG	tree;
	WORD	which;
	{
	do_obj(tree, which, SELECTED);
	}

	BOOLEAN
statep(tree, which, bit)
	LONG	tree;
	WORD	which;
	WORD	bit;
	{
	return ( (LWGET(OB_STATE(which)) & bit) != 0);
	}

	BOOLEAN
selectp(tree, which)
	LONG	tree;
	WORD	which;
	{
	return statep(tree, which, SELECTED);
	}

>>>>>>>>>>>>>>>>>>>>>> Sample radio buttons after dialog <<<<<<<<<<<<<<<<<<<<

	WORD
encode(tree, ob1st, num)
	LONG	tree;
	WORD	ob1st, num;
	{
	for (; num--; )
		if (selectp(ob1st+num))
			return(num);
	return (-1);
	}

