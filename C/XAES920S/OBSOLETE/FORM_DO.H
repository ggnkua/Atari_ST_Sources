	/* This all is done in set_toolbar_widget() */
	/*
	 * If there is an editable field, we'll need a keypress handler.
	 *  HR: We need a keypress handler for the default object as well
	 */
	if (has_default(form))
		dialog_window->keypress = handle_form_key;
	startedit = pb->intin[0];
	if (startedit <= 0)
		startedit = find_flag(form, EDITABLE);		/* HR */
	wt->edit_obj = startedit;
	wt->edit_pos = 0;	/* Needed? */

	if (startedit > 0)	/* Set up keypress handler if needed */
	{
		TEDINFO *ted = ob_spec(&form[startedit]);
		
		if (*(ted->te_ptext) eq '@')				/* HR 101200 */
			*(ted->te_ptext) =  0;
		wt->edit_pos = strlen(ted->te_ptext);
		dialog_window->keypress = handle_form_key;
	}
