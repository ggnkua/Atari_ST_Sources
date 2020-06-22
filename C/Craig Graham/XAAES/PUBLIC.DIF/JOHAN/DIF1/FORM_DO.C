/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <VDI.H>
#include <OSBIND.H>
#include <string.h>
#include <ctype.h>
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "XA_DEFS.H"
#include "BOX3D.H"
#include "FRM_ALRT.H"
#include "K_DEFS.H"
#include "RESOURCE.H"
#include "OBJECTS.H"
#include "WATCHBOX.H"
#include "C_WINDOW.H"
#include "STD_WIDG.H"

#if 0
#define CLIP(tree,obj,x,y,w,h) 				\
	object_abs_coords(tree, obj, &x, &y);	\
	w = tree[obj].ob_width;					\
	h = tree[obj].ob_height;				\
	set_clip(x, y, w, h);
#endif

#define CLIP(tree,obj,x,y,w,h)	clear_clip()
#define set_clip(x,y,w,h)		/* We don't want this now! */

#if 0
#undef CLIP            /* Those set_clip(..) can't be useful */
#endif

/* Returns the object number of this object's parent or -1 if it is the root*/
short GetParent(OBJECT *t, short object)
{
	short last;
	
	if (object == 0)
		return -1;
	else {
		do {
			last = object;
			object = t[object].ob_next;
		} while(t[object].ob_tail != last);
		return object;
	}
}

/*
  Sets one of a group of radio buttons, and clears the rest.
  Includes patch to allow for pop_icons as radio buttons.
*/
void Radio_b(OBJECT *d, short object)
{
	short parent, o, x, y, w, h;

	if ((parent = GetParent(d, object)) == -1)
		return;		/* Only reasonable thing to do */

	o = d[parent].ob_head;
	
	while (o != parent)
	{
		if ((d[o].ob_flags & RBUTTON) && (d[o].ob_state & SELECTED))
		{
			d[o].ob_state &= ~SELECTED;

			CLIP(d, o, x, y, w, h);
			v_hide_c(V_handle);
			draw_object_tree(d, o, MAX_DEPTH);
			v_show_c(V_handle, 1);
		}
		
		o = d[o].ob_next;
	}
	
	d[object].ob_state |= SELECTED;

	CLIP(d, object, x, y, w, h);
	v_hide_c(V_handle);
	draw_object_tree(d, object, MAX_DEPTH);
	v_show_c(V_handle, 1);
}

/*
	Form_do() click handler
*/
short click_object_widget(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x, y, w, h, f, is, os;
	short retv = XA_OK;
	XA_WIDGET_TREE *wt = (XA_WIDGET_TREE*)widg->stuff;
	OBJECT *form;

#if 0
	if (window_list != wind)	/* You can only work alerts when they are on top */
		return FALSE;
#endif
	if (window_list != wind) {
		v_hide_c(V_handle);
		pull_wind_to_top(wind);
		display_window(wind);
		v_show_c(V_handle, 1);
		return FALSE;
	}
   
	form = wt->tree;

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */

	f = find_object(form, 0, 10, x + widg->click_x, y + widg->click_y);

	/* find_object can't report click on a HIDETREE object. */
#if 0
	if (((form[f].ob_flags & HIDETREE)		/* Was click on a valid selectable object? */
#endif
	if ((form[f].ob_state & DISABLED)	/* Was click on a valid selectable object? */
		||(!(form[f].ob_flags & (EDITABLE | SELECTABLE | EXIT | TOUCHEXIT))))
	{	
		return FALSE;
	}

	if ((form[f].ob_flags & EDITABLE) && (f != wt->edit_obj))	/* Select a new editable text field? */
	{
		TEDINFO *txt=(TEDINFO*)form[f].ob_spec;
		
		form[f].ob_state |= IS_EDIT;
		form[wt->edit_obj].ob_state &= ~IS_EDIT;

		CLIP(form, wt->edit_obj, x, y, w, h);
		v_hide_c(V_handle);
		draw_object_tree(form, wt->edit_obj, MAX_DEPTH);

		wt->edit_obj = f;
		wt->edit_pos = txt->te_tmplen = strlen(txt->te_ptext);
		
		CLIP(form, f, x, y, w, h);
		draw_object_tree(form, f, MAX_DEPTH);
		v_show_c(V_handle, 1);
	}

	CLIP(form, f, x, y, w, h);

	os = form[f].ob_state;
	is = os ^ SELECTED;

 	if (form[f].ob_flags & TOUCHEXIT)	/* Touch Exit button? */
	{
		if (form[f].ob_flags & RBUTTON) {	/* Was click on a radio button? */
			Radio_b(form, f);
		} else if (form[f].ob_flags & SELECTABLE) {
			form[f].ob_state = is;
			v_hide_c(V_handle);
			draw_object_tree(form, f, MAX_DEPTH);
			v_show_c(V_handle, 1);
		}


		clients[wt->owner].waiting_pb->intout[0] = f;
		Fwrite(clients[wt->owner].clnt_pipe_wr, (long)sizeof(short), &retv);	/* Write success to clients reply pipe to unblock the process */
		if (!(wind->created_by_FMD_START))	/* If FMD_START didn't create this window, destroy it now */
		{									/* - if it did, then we expect the app to call FMD_FINISH to delete the window */
			clients[wt->owner].zen = NULL;
			v_hide_c(V_handle);
			display_windows_below(wind);
			v_show_c(V_handle, 1);
			wind->is_open = FALSE;
			delete_window(wind);
		}
/*
 * How should an EXIT but not SELECTABLE be handled?
 */
	} else if (form[f].ob_flags & SELECTABLE) {	/* Selectable object? */

/*
 * Should this perhaps be done in watch_object?
 */
		form[f].ob_state = is;
		CLIP(form, f, x, y, w, h);
		v_hide_c(V_handle);
		draw_object_tree(form, f, MAX_DEPTH);
		v_show_c(V_handle, 1);

		if (watch_object(form, f, is, os))
		{
#ifdef CLIP
			set_clip(x, y, w, h);
#endif
	
			if (form[f].ob_flags & RBUTTON)	/* Was click on a radio button? */
			{
				Radio_b(form, f);
			}
					
			if (form[f].ob_flags & EXIT)		/* Exit button? */
			{
				clients[wt->owner].waiting_pb->intout[0] = f;
				Fwrite(clients[wt->owner].clnt_pipe_wr, (long)sizeof(short), &retv);	/* Write success to clients reply pipe to unblock the process */
	
				if (!(wind->created_by_FMD_START))	/* If FMD_START didn't create this window, destroy it now */
				{									/* - if it did, then we expect the app to call FMD_FINISH to delete the window */
					clients[wt->owner].zen = NULL;
					v_hide_c(V_handle);
					display_windows_below(wind);
					v_show_c(V_handle, 1);
					wind->is_open = FALSE;
					delete_window(wind);
				}
			}
			
		}
	}
	
#ifdef CLIP
	clear_clip();
#endif
	
	return FALSE;
}

/*
	Form Keyboard Handler
*/
short handle_form_key(XA_WINDOW *wind, unsigned short keycode)
{
	XA_WIDGET *widg = (wind->widgets) + XAW_TOOLBAR;
	XA_WIDGET_TREE *wt;
	OBJECT *form;
	TEDINFO *ed_txt;
	short retv = XA_OK;
	char *txt;
	short cursor_pos, o, ed_obj, x, y, w, h, last_ob;
	int key, tmask, n, update = 0;
	
	wt = (XA_WIDGET_TREE*)widg->stuff;
	form = wt->tree;
	ed_obj = wt->edit_obj;
	ed_txt = (TEDINFO*)form[ed_obj].ob_spec;
	txt = ed_txt->te_ptext;
	cursor_pos = ed_txt->te_tmplen;
	
	switch(keycode)
	{
	case 0x011b:		/* ESCAPE clears the field */
		txt[0] = '\0';
		ed_txt->te_tmplen = wt->edit_pos = 0;
		update = 1;
		break;

	case 0x537f:		/* DEL deletes character after cursor */
		if (txt[cursor_pos])
		{
			for(x = cursor_pos; x < ed_txt->te_txtlen - 1; x++)
				txt[x] = txt[x + 1];

			update = 1;				
		}
		break;
		
	case 0x0e08:		/* BACKSPACE deletes character before cursor (if any) */
		if (cursor_pos)
		{
			for(x = cursor_pos; x < ed_txt->te_txtlen; x++)
				txt[x - 1] = txt[x];
				
			wt->edit_pos--;
			ed_txt->te_tmplen = wt->edit_pos;

			update = 1;
		}
		break;
			
	case 0x0f09:		/* TAB moves to next field */
	case 0x5000:		/* DOWN ARROW also moves to next field */
		if (form[ed_obj].ob_flags & LASTOB)	/* Loop round */
			o = 0;
		else
			o = ed_obj;
				
		for(o++; !(form[o].ob_flags & EDITABLE); o++)		/* search for next editable object */
		{
			if (form[o].ob_flags & LASTOB)	/* Loop round */
				o = 0;
		}

		break;

	case 0x5032:		/* SHIFT+DOWN ARROW moves to last field */
		for(last_ob = 0; !(form[last_ob].ob_flags & LASTOB) ; last_ob++); /*find last object*/
		o = last_ob;
		for(; !(form[o].ob_flags & EDITABLE); o--) ;		/* search for last editable object */
		break;
		
	case 0x4800:	/* UP ARROW moves to previous field */
		for(last_ob = 0; !(form[last_ob].ob_flags & LASTOB) ; last_ob++); /*find last object*/
		
		if (ed_obj == 1)	/* Loop round ? */
			o = last_ob + 1;
		else
			o = ed_obj;
				
		for(o--; !(form[o].ob_flags & EDITABLE); o--)		/* search for previous editable object */
		{
			if (o == 1)	/* Loop round */
				o = last_ob + 1;
		}
			
		break;

	case 0x4838:		/* SHIFT+UP ARROW moves to first field */
		o = 0;
		for(o++; !(form[o].ob_flags & EDITABLE); o++) ;	/* search for first editable object */
		break;
			
	case 0x4d00:	/* RIGHT ARROW moves cursor right */
		if ((txt[cursor_pos]) && (cursor_pos < ed_txt->te_txtlen - 1))
		{
			wt->edit_pos++;
			ed_txt->te_tmplen = wt->edit_pos;
			update = 1;
		}
		break;

	case 0x4d36:	/* SHIFT+RIGHT ARROW move cursor to far right of current text */
		for(x = 0; txt[x]; x++) ;
			
		if (x != cursor_pos)
		{
			wt->edit_pos = x;
			ed_txt->te_tmplen = wt->edit_pos;
			update = 1;
		}
		break;
			
	case 0x4b00:	/* LEFT ARROW moves cursor left */
		if (cursor_pos)
		{
			wt->edit_pos--;
			ed_txt->te_tmplen = wt->edit_pos;
			update = 1;
		}
		break;
			
	case 0x4b34:	/* SHIFT+LEFT ARROW move cursor to start of field */
	case 0x4700:	/* CLR/HOME also moves to far left */
		if (cursor_pos)
		{
			wt->edit_pos = ed_txt->te_tmplen = 0;
			update = 1;
		}
		break;

	case 0x1c0d:	/* Return - select default (if any) */
		o = 0;
		do{
			if (form[o].ob_flags & DEFAULT)
			{
				clients[wt->owner].waiting_pb->intout[0] = o;
				Fwrite(clients[wt->owner].clnt_pipe_wr, (long)sizeof(short), &retv);	/* Write success to clients reply pipe to unblock the process */
				if (!(wind->created_by_FMD_START))	/* If FMD_START didn't create this window, destroy it now */
				{									/* - if it did, then we expect the app to call FMD_FINISH to delete the window */
					clear_clip();
					clients[wt->owner].zen = NULL;
					v_hide_c(V_handle);
					display_windows_below(wind);
					v_show_c(V_handle, 1);
					wind->is_open = FALSE;
					delete_window(wind);
				}
				return TRUE;
			}
			o++;
		} while(!(form[o].ob_flags & LASTOB));
		break;
		
	default:		/* Just a plain key - insert character */
		if (cursor_pos == ed_txt->te_txtlen - 1) {
			cursor_pos--;
			wt->edit_pos--;		/* Increased below */
		}

		key = keycode & 0xff;
		tmask  = isdigit(key) ? 0x01 : 0;
		tmask |= isalpha(key) ? 0x02 : 0;
		tmask |= isspace(key) ? 0x04 : 0;
		tmask |= isupper(key) ? 0x08 : 0;
		tmask |= ((key == ':') || (key == '\\'))? 0x10 : 0;
		tmask |= (key == '.') ? 0x20 : 0;
		tmask |= ((key == '?') || (key == '*')) ? 0x40 : 0;

		n = strlen(ed_txt->te_pvalid) - 1;
		if (cursor_pos < n)
			n = cursor_pos;

		switch(ed_txt->te_pvalid[n]) {
		case '9':
			tmask &= 0x01;
			break;
		case 'a':
			tmask &= 0x06;
			break;
		case 'n':
			tmask &= 0x07;
			break;
		case 'p':
			tmask &= 0x17;
			key = toupper((char)key);
			break;
		case 'A':
			tmask &= 0x0c;
			key = toupper((char)key);
			break;
		case 'N':
			tmask &= 0x0d;
			key = toupper((char)key);
			break;
		case 'F':
			tmask &= 0x57;
			key = toupper((char)key);
			break;
		case 'P':
			tmask &= 0x77;
			key = toupper((char)key);
			break;
		case 'X':
			tmask = 1;
			break;
		case 'x':
			tmask = 1;
			key = toupper((char)key);
			break;
		default:
			tmask = 0;
			break;			
		}
			
		if (!tmask) {
			for(n = x = 0; ed_txt->te_ptmplt[n]; n++) {
		   		if (ed_txt->te_ptmplt[n] == '_')
					x++;
				else if ((ed_txt->te_ptmplt[n] == key)
					&& (x >= cursor_pos))
					break;
			}
			if (key && (ed_txt->te_ptmplt[n] == key)) {
				for(n = cursor_pos; n < x; n++)
					txt[n] = ' ';
				txt[x] = '\0';
				wt->edit_pos = x;
				ed_txt->te_tmplen = wt->edit_pos;
			} else {
				wt->edit_pos = ed_txt->te_tmplen;
				return(TRUE);
			}
		} else {
			txt[ed_txt->te_txtlen - 2] = '\0';	/* Needed! */
			for(x = ed_txt->te_txtlen - 1; x > cursor_pos; x--)
				txt[x] = txt[x - 1];

			txt[cursor_pos] = (char)key;

			wt->edit_pos++;
			ed_txt->te_tmplen = wt->edit_pos;
		}
			
		update = 1;
		break;
	}
	if (update) {		/* Moved from a number of places above. */
		CLIP(form, ed_obj, x, y, w, h);
		v_hide_c(V_handle);
		draw_object_tree(form, ed_obj, MAX_DEPTH);
		v_show_c(V_handle, 1);
	}
	switch(keycode) {	/* Moved from four places above. */
	case 0x0f09:		/* All the common updating is */
	case 0x5000:		/* done here now. */
	case 0x5032:
	case 0x4800:
	case 0x4838:
		if (o != ed_obj)	/* If edit field has changed, update the display */
		{
			form[o].ob_state |= IS_EDIT;
			form[ed_obj].ob_state &= ~IS_EDIT;
			
			CLIP(form, ed_obj, x, y, w, h);
			v_hide_c(V_handle);
			draw_object_tree(form, ed_obj, MAX_DEPTH);

			wt->edit_obj = o;
			wt->edit_pos = ((TEDINFO*)form[o].ob_spec)->te_tmplen = strlen(((TEDINFO*)form[o].ob_spec)->te_ptext);
		
			CLIP(form, o, x, y, w, h);
			draw_object_tree(form, o, MAX_DEPTH);
			v_show_c(V_handle, 1);
		}
		break;
	}
			
	return TRUE;
}
