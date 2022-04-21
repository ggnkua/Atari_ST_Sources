/*****************************************************************************/

GLOBAL WORD dial_do (di, edit_obj)
DIALINFO *di;
WORD		 edit_obj;

{	WORD 	   but;

	do
	{
		but = form_xdo (di->Tree, edit_obj);
		if ((di->Tree[but & 0x7fff].ob_type >> 8) == DIALMOVER)		/* Dial Mover */
		{
			graf_mouse (FLAT_HAND, NULL);
			dial_move (di, mydesk.x, mydesk.y, mydesk.w, mydesk.h);
			graf_mouse (*my_mousnumber, *my_mousform);
		}
		else
			return (but);
	}
	while (TRUE);
}

/*****************************************************************************/

LOCAL WORD find_obj (tree, start_obj, which)
OBJECT *tree;												/* routine to find the next editable */
WORD	 start_obj;										/* text field, or a field that is as */
WORD	 which;												/* marked as a default return field. */

{	WORD obj, flag, theflag, inc;

	obj = 0;
	flag = EDITABLE;
	inc = 1;

	switch (which)
	{
		case FMD_BACKWARD:
			inc = -1;										 /* fall thru */
		case FMD_FORWARD:
			obj = start_obj + inc;
			break;
		case FMD_DEFLT:
			flag = DEFAULT;
			break;
	}

	while (obj >= 0)
	{
		theflag = tree[obj].ob_flags;

		if (theflag & flag)
			return (obj);

		if (theflag & LASTOB)
			obj = -1;
		else
			obj += inc;
	}

	return (start_obj);
}

/*****************************************************************************/

LOCAL WORD fm_inifld (tree, start_fld)
OBJECT *tree;
WORD	 start_fld;

{
	if (!start_fld)					/* position cursor on	the starting field */
		start_fld = find_obj(tree, 0, FMD_FORWARD);

	return (start_fld);
}

/*****************************************************************************/
/* Neue form_do Routine 																										 */
/*****************************************************************************/

LOCAL WORD myedit_obj, myidx;

LOCAL WORD form_xdo (tree, start_fld)
OBJECT *tree;
WORD	 start_fld;

{	WORD 	  next_obj, which, cont, wbox;
	UWORD	  knorm;
	RECT 	  work;
	TEDINFO *ted;
	MYEVENT e;

	wind_update (BEG_UPDATE);
	wind_update (BEG_MCTRL);
	
	memset (&e, 0, sizeof (MEVENT));
	e.e_flags = MU_KEYBD | MU_BUTTON;
	e.e_bclk = 2;
	e.e_bmsk = e.e_bst = 1;

	if (init_MyEvnt != NULL)	(*init_MyEvnt) (&e);

	/* set starting field	to edit, if want first editing field then walk tree	*/
	next_obj = fm_inifld (tree, start_fld);
	myedit_obj = 0;

	cont = TRUE;															/* interact with user	*/
	while (cont)
	{
		/* position cursor on	the selected editing field */
		if ((next_obj != 0) && (myedit_obj != next_obj))
		{
	 	 	myedit_obj = next_obj;
	 	 	next_obj = 0;
	 	 	obj_edit(tree, myedit_obj, 0, 0, &myidx, EDINIT, FALSE, &myedit_obj, NIL);
		}
																						/* wait for mouse or key */
		which = evnt_multi (e.e_flags,
												e.e_bclk, e.e_bmsk, e.e_bst,
												e.e_m1flags, e.e_m1.g_x, e.e_m1.g_y, e.e_m1.g_w, e.e_m1.g_h,
												e.e_m2flags, e.e_m2.g_x, e.e_m2.g_y, e.e_m2.g_w, e.e_m2.g_h,
												e.e_mepbuf,
												e.e_ltime, e.e_htime,
												&e.e_mx, &e.e_my, &e.e_mb, &e.e_ks, &e.e_kr, &e.e_br);

		if (form_MyEvnt != NULL)	(*form_MyEvnt) (&which, &e);
		
		if (which & MU_KEYBD)										/* handle keyboard event*/
		{
			knorm = normkey (e.e_ks, e.e_kr);

			if ((tree[myedit_obj].ob_flags & FLAGS15) && (knorm == (NKF_FUNC|NK_UP) && find_prev (tree, myedit_obj) != NIL) || (knorm == (NKF_FUNC|NK_DOWN) && find_next (tree, myedit_obj) != NIL))
			{
				obj_edit (tree, myedit_obj, e.e_ks, e.e_kr, &myidx, EDCHAR, FALSE, &myedit_obj, NIL);
				next_obj = myedit_obj;
				e.e_kr = 0;
		 	}
			else
		 	 	cont = form_Keybd (tree, myedit_obj, next_obj, e.e_kr, e.e_ks, &next_obj, &e.e_kr);

	 	 	if (e.e_kr)
	 	 	{
	 	 		obj_edit (tree, myedit_obj, e.e_ks, e.e_kr, &myidx, EDCHAR, FALSE, &myedit_obj, NIL);
	 	 		next_obj = myedit_obj;
	 	 	}
	 	 	else
		  {	if ((tree[myedit_obj].ob_flags & EXIT) && myedit_obj != next_obj && cont)
				{
					next_obj = myedit_obj;
					cont = myedit_obj = FALSE;
				}
			}
		}

		if (which & MU_BUTTON)									/* handle button event	*/
		{
	 		next_obj = objc_find (tree, ROOT, MAX_DEPTH, e.e_mx, e.e_my);
 			if (next_obj == NIL)
	 		{
	 	 		mybeep();
	 	 		next_obj = 0;
	 		}
	 		else
			{
				if (myedit_obj && (tree[myedit_obj].ob_type & 0xff) == G_USERDEF)
				{
					dial_drawcursor (tree, myedit_obj, myidx, NIL);
					cont = form_Button (NIL, tree, next_obj, e.e_br, &next_obj);
					dial_drawcursor (tree, myedit_obj, myidx, NIL);
				}
				else
					cont = form_Button (NIL, tree, next_obj, e.e_br, &next_obj);

				if ((tree[myedit_obj].ob_flags & EXIT) && myedit_obj != next_obj && cont)
				{
					next_obj = myedit_obj;
					cont = myedit_obj = FALSE;
				}
				if (cont && (tree[next_obj].ob_flags & EDITABLE))
				{
					if (next_obj != myedit_obj)
					{
						obj_edit (tree, myedit_obj, e.e_ks, 0, &myidx, EDEND, FALSE, &myedit_obj, NIL);
						myedit_obj = next_obj;
						next_obj = 0;
					}
					objc_rect(tree, myedit_obj, &work, FALSE);

					ted = (TEDINFO *)get_obspec (tree, myedit_obj);

					if (ted->te_font == SMALL)
						wbox = 6;
					else
						wbox = mygl_wbox;

					if (ted->te_just != TE_LEFT)
					{
						work.w = work.w - dial_curspos (tree, myedit_obj, min (ted->te_tmplen - 1, tree[myedit_obj].ob_width / wbox), wbox);
						if (ted->te_just == TE_CNTR)
							work.w /= 2;

						work.x += work.w;
					}
					myidx = dial_charpos (tree, myedit_obj, e.e_mx - work.x, wbox);
					myedit_obj = dial_setcpos (tree, myedit_obj, &myidx);
				}
			}
		}
		/* handle end of field, clean up */
		if ((!cont) || ((next_obj != 0) && (next_obj != myedit_obj)))
	 		obj_edit(tree, myedit_obj, e.e_ks, 0, &myidx, EDEND, FALSE, &myedit_obj, NIL);
	}

	wind_update(END_MCTRL);
	wind_update(END_UPDATE);

	/* return exit object, high bit may be set if exit obj. was double-clicked */
	return (next_obj);
}
