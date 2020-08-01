/********************************************************************
 *																1.20*
 *	XAES: Custom text editor										*
 *	Code by Ken Hollis, GNU C Extensions by Sascha Blank			*
 *																	*
 *	Copyright (c) 1994, Bitgate Software							*
 *																	*
 *	These are just the form_keybd replacement calls for windows.	*
 *	I need to add template checking.								*
 *																	*
 ********************************************************************/

#include <string.h>
#include <stdio.h>
#include <ctype.h>

#include "xaes.h"		/* XAES header file */
#include "nkcc.h"		/* Normalized Keycodes header file */

#ifdef __TURBOC__
#pragma warn -pia
#endif

#ifndef __FORMKEYBOARD__
#define __FORMKEYBOARD__
#endif

/*
 *  Reposition the cursor to an index
 *  (It took a bit of thinking it out, but it worked in the end!)
 *
 *  where = offset into string to put cursor on
 */
GLOBAL void edit_pos(WINDOW *win, int where)
{
	if ((win) && (win->handle != 0)) {
/*		if (where!=win->edpos) { */
			int textlen = (int)(strlen(win->tree[win->edobject].ob_spec.tedinfo->te_ptext));
			WObjc_Edit(win, ED_END, 0, 0);

			if (where > (win->tree[win->edobject].ob_spec.tedinfo->te_txtlen - 1))
				win->edpos = win->tree[win->edobject].ob_spec.tedinfo->te_txtlen - 1;
			else
				win->edpos = where;

			if (win->edpos > textlen)
				win->edpos = textlen;

			WObjc_Edit(win, ED_INIT, 0, 0);
	}
}

/*
 *	Function to reposition cursor inside an object
 *
 *	This code segment by Jan Starzynski
 *	Modifications by Ken Hollis
 *
 *	obj = Address of the root object (dialog box)
 *	No  = editable object which was clicked on
 *	mx  = X coordinate of mouse at time of click (from event info)
 *
 */
GLOBAL int find_position(OBJECT *obj, int No, int mx)
{
	int te_x= 0;	/* Absolute coordinate of text */
	int	P_text = 0;	/* Position in text */
	int	P_mask = 0;	/* Position in mask */
	int	size;		/* Text font size */
	int	i, Child;	/* Children and the parent pointer */

	size = (obj[No].ob_spec.tedinfo->te_font == 3) ? 8 : 6;
	te_x = (obj[No].ob_spec.tedinfo->te_just)
			? obj[No].ob_width - (obj[No].ob_spec.tedinfo->te_tmplen - 1) * size : 0;
	if(obj[No].ob_spec.tedinfo->te_just == 2)
			te_x /= 2;
	te_x += obj[No].ob_x + size / 2;
	Child = No;
	for (i = No - 1; 0 <= i; i--)
		if ((obj[i].ob_head <= Child) && (Child <= obj[i].ob_tail))	{
			Child = i;
			te_x += obj[i].ob_x;
		}

	while ((te_x < mx) && (P_mask < obj[No].ob_spec.tedinfo->te_tmplen - 1)) {
		if (obj[No].ob_spec.tedinfo->te_ptmplt[P_mask++] == '_')
			P_text++;
		te_x += size;
	}
	return P_text;
}


/*
 *  Check to see if an object is hidden
 *
 *  tree = Address of dialog box to check
 *  obj  = Object to check
 *  flag = Flag to truly check for the object (usually TRUE)
 *
 *  Returns: TRUE = it is hidden
 *			 FALSE = it is not
 */
LOCAL int IsHidden(OBJECT *tree, int obj, int flag)
{
	int	index = obj, next;

	if (!(tree[obj].ob_flags & HIDETREE))
		if (flag == TRUE || !(tree[obj].ob_state & DISABLED)) {
			while ((next = tree[index].ob_next) != -1) {
				if ((tree[index].ob_flags & HIDETREE))
					return TRUE;
				index = next;
			}
			return FALSE;
		}

	return TRUE;
}

/*
 *  Check for a specified flag against an object
 *
 *  tree = Address of the dialog box
 *  obj  = Object to check
 *  flag = Boolean value to truly check or not (usually TRUE)
 *  mask = Mask to check for; make sure it's an integer value!
 *
 *  Returns: TRUE = object is flag
 *			 FALSE = it is not
 */
LOCAL int IsFlag(OBJECT *tree, int obj, int flag, int mask)
{
	if ((flag & mask) && (!IsHidden(tree, obj, FALSE)))
		return TRUE;

	return FALSE;
}

/*
 *  Jump to the first editable object
 *
 *  tree = Address of the dialog box to go to the first object in
 *
 *  Returns: index of the first object
 *			 0 on failure
 */
LOCAL int FirstEdit(OBJECT *tree)
{
	int	index = 0;

	do {
		index++;
		if (IsFlag(tree, index, tree[index].ob_flags, EDITABLE))
			return index;
	}
	while (!(tree[index].ob_flags & LASTOB));

	return 0;
}

/*
 *  Jump to the last editable object
 *
 *  tree = Address of the dialog box to jump to the last object in
 *
 *  Returns: index of the last object
 *			 0 on failure
 */
LOCAL int LastEdit(OBJECT *tree)
{
	int	index = 0, last = 0;

	do {
		index++;
		if (IsFlag(tree, index, tree[index].ob_flags, EDITABLE))
			last = index;
	}
	while (!(tree[index].ob_flags & LASTOB));

	if (last)
		return last;

	return 0;
}

/*
 *	Find next editable object
 *
 *	tree = Address of the dialog box to search
 *	cobj = Current object the cursor is at
 *
 *	Returns: index of the next object
 *			 0 on failure
 */
LOCAL int NextEdit(OBJECT *tree, int cobj)
{
	int	index = cobj;
	int	flag = FALSE;

	if (index) {
		while (!(tree[index].ob_flags & LASTOB)) {
			index++;
			if (IsFlag(tree, index, tree[index].ob_flags, EDITABLE))
				return index;
		}

		if (!flag)
			return FirstEdit(tree);
	}

	return 0;
}

/*
 *	Clear all editable fields
 *
 *	tree = Object tree to clear out editable fields
 */
LOCAL int ClearAllEdit(OBJECT *tree)
{
	int	index = 0;

	do {
		if (tree[++index].ob_flags & EDITABLE)
			tree[index].ob_spec.tedinfo->te_ptext = "\0";
	} while (!(tree[index].ob_flags & LASTOB));

	return FirstEdit(tree);
}

/*
 *  Find the object before the current one
 *
 *  tree = Address of the dialog box to search
 *  cobj = Current object that the cursor is at
 *
 *  Returns: the index of the previous editable object
 *			 0 on failure
 */
LOCAL int PrevEdit(OBJECT *tree, int cobj)
{
	int	index = cobj;
	int	flag = FALSE;

	if (index) {
		do {
			index--;
			if (IsFlag(tree, index, tree[index].ob_flags, EDITABLE))
				return index;
		}
		while (index);

		if (!flag)
			return LastEdit(tree);
	}

	return 0;
}

/*
 *  Customized form_keybd call
 *
 *  win    = Window structure
 *  key    = Keyboard keycode from EvntMulti
 *	kstate = Keyboard status
 *  nchr   = Processed keycode (0 if handled, otherwise, it
 *           returns the keycode that was typed.)
 *
 *	Returns: 0 if an exitobject was selected
 */
GLOBAL int WForm_keybd(WINDOW *win, int key, int kstate, int *nobj, int *nchr)
{
	int n_key;

	*nobj = 0;

	if ((win) && (win->handle != 0)) {
		int lastob = 0;

		n_key = nkc_tconv((key & 0xff) | (((long) key & 0xff00) << 8) | ((long) kstate << 24)) & ~(NKF_FUNC | NKF_RESVD | NKF_NUM);
		*nchr = 0;

		do {
			lastob++;
		} while (!(win->tree[lastob].ob_flags & LASTOB));

		if ((!win->edobject && n_key == NK_RET) || (n_key == (NK_RET | NKF_CTRL))) {
			int	i = 0;

			do {
				if (win->tree[i].ob_flags & DEFAULT) {
					*nobj = i;

					if (*nobj != 0) {
						printf("\033Y1 Object: %3d\n", *nobj);
						Objc_Change(win, *nobj, 0, win->tree[*nobj].ob_state | SELECTED, 1);
					}

					return FALSE;
				}
				i++;
			} while (!(win->tree[i++].ob_flags & LASTOB) && (i<lastob));

			*nobj = 0;
			return TRUE;
		}

/*		if (!win->edobject || n_key & NKF_ALT) {
			int	i = 0, mask = (toupper(n_key & 0xff) & 0x7f);

			do {
				EXTINFO *ex = (EXTINFO *)(win->tree[i].ob_spec.userblk->ub_parm);

				if ((ex->te_hotkey == mask) && !(win->tree[i].ob_state & DISABLED) && ((win->tree[i].ob_flags & SELECTABLE) || (win->tree[i].ob_flags & EXIT))) {
					*nobj = i;
					return FALSE;
				}
				i++;
			}
			while (!(win->tree[i++].ob_flags & LASTOB));
		} */

		if (win->edobject) {
			register char *text = win->tree[win->edobject].ob_spec.tedinfo->te_ptext;
			switch (n_key) {
				case NK_ENTER:
				case NK_DOWN:
				case NK_TAB:
				case NK_RET:
					WObjc_Edit(win, ED_END, 0, 0);
					win->edobject = NextEdit(win->tree, win->edobject);
					win->edpos = (int) strlen(win->tree[win->edobject].ob_spec.tedinfo->te_ptext);
					WObjc_Edit(win, ED_INIT, 0, 0);
					break;

				case NK_UP:
				case NK_TAB | NKF_LSH:
				case NK_TAB | NKF_RSH:
					WObjc_Edit(win, ED_END, 0, 0);
					win->edobject = PrevEdit(win->tree, win->edobject);
					win->edpos = (int) strlen(win->tree[win->edobject].ob_spec.tedinfo->te_ptext);
					WObjc_Edit(win, ED_INIT, 0, 0);
					break;

				case NK_UNDO:
					WCallUndoDispatcher(win);
					break;

				case NK_HELP:
					WCallHelpDispatcher(win);
	 				break;

				case NK_F1:
					WCallFKeyDispatcher(win, 1);
					break;

				case NK_F2:
					WCallFKeyDispatcher(win, 2);
					break;

				case NK_F3:
					WCallFKeyDispatcher(win, 3);
					break;

				case NK_F4:
					WCallFKeyDispatcher(win, 4);
					break;

				case NK_F5:
					WCallFKeyDispatcher(win, 5);
					break;

				case NK_F6:
					WCallFKeyDispatcher(win, 6);
					break;

				case NK_F7:
					WCallFKeyDispatcher(win, 7);
					break;

				case NK_F8:
					WCallFKeyDispatcher(win, 8);
					break;

				case NK_F9:
					WCallFKeyDispatcher(win, 9);
					break;

				case NK_F10:
					WCallFKeyDispatcher(win, 10);
					break;

				case NK_CLRHOME | NKF_CTRL:
					{
						int x, y, w, h;

						win->edobject = ClearAllEdit(win->tree);
						WWindGet(win, WF_WORKXYWH, &x, &y, &w, &h);
						WRedrawWindow(win, x, y, w, h);
					}
					break;

				case NK_LEFT | NKF_LSH:
				case NK_LEFT | NKF_RSH:
					edit_pos(win, 0);
					break;

				case NK_RIGHT | NKF_LSH:
				case NK_RIGHT | NKF_RSH:
					edit_pos(win, (int) strlen(text));
					break;

				case NK_RIGHT | NKF_CTRL:
					{
						char *ptr = text + win->edpos;

						if (*ptr) {
							while (*(++ptr))
								if (isalnum(*ptr) && !isalnum(*(ptr - 1)))
									break;

							edit_pos(win, (int) (ptr - text));
						}
					}
					break;

				case NK_LEFT | NKF_CTRL:
					if (win->edpos) {
						char *ptr = text + win->edpos;

						while (text != --ptr)
							if (!isalnum(*ptr) && text != ptr - 1)
								if (isalnum(*(ptr - 1)))
									break;

						edit_pos(win, (int) (ptr - text));
					}
					break;

				case NK_LEFT:
					{
						int pos = win->edpos;

						pos--;
						if (pos<0) pos = 0;
						edit_pos(win, pos);
					}
					break;

				case NK_RIGHT:
					{
						int pos = win->edpos;

						pos++;
						if (pos>(int) strlen(text)) pos = (int) strlen(text);
						edit_pos(win, pos);
					}
					break;

				case NK_UP | NKF_LSH:
				case NK_UP | NKF_RSH:
				case NK_CLRHOME:
					{
						int prev = win->edobject;
						int storage;

						storage = FirstEdit(win->tree);
						if (storage == prev) {
							win->edobject = prev;
							edit_pos(win, 0);
						} else {
							WObjc_Edit(win, ED_END, 0, 0);
							win->edobject = storage;
							win->edpos = (int) strlen(win->tree[win->edobject].ob_spec.tedinfo->te_ptext);
							WObjc_Edit(win, ED_INIT, 0, 0);
						}
					}
					break;

				case NK_CLRHOME | NKF_LSH:
				case NK_CLRHOME | NKF_RSH:
				case NK_DOWN | NKF_LSH:
				case NK_DOWN | NKF_RSH:
					{
						int prev = win->edobject;
						int	storage;

						storage = LastEdit(win->tree);
						if (storage == prev) {
							win->edobject = prev;
							edit_pos(win, 0);
						} else {
							WObjc_Edit(win, ED_END, 0, 0);
							win->edobject = storage;
							win->edpos = (int) strlen(win->tree[win->edobject].ob_spec.tedinfo->te_ptext);
							WObjc_Edit(win, ED_INIT, 0, 0);
						}
					}
					break;

				case NK_INS:
					WGrafMouse(ARROW);
					{
/*						int edittype = WFind_EditType(win);
						*nchr = (char) WAscii_Table(edittype); */
						WObjc_Edit(win, ED_END, 0, 0);

						if (win->editmode == EDIT_INSERT)
							win->editmode = EDIT_REPLACE;
						else
							win->editmode = EDIT_INSERT;

						WObjc_Edit(win, ED_INIT, 0, 0);
					}
					break;

				default:
					*nchr = key;
					break;
			}
		}

		*nobj = win->edobject;

		return TRUE;
	} else
		return TRUE;
}