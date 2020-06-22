/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <stdio.h>
#include <string.h>
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "K_DEFS.H"
#include "OBJECTS.H"
#include "FRM_ALRT.H"
#include "STD_WIDG.H"
#include "C_WINDOW.H"
#include "WATCHBOX.H"
#include "FORM_DO.H"

#if 0
#define CLIP(tree,obj,x,y,w,h)				\
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

/*
	FORM HANDLERS INTERFACE
*/

#if 0
extern XA_WINDOW *window_list;		/* The global system window stack */
#endif

/*
	Primitive version of form_center....
	-this ignores shadows & stuff
*/
short XA_form_center(short clnt_pid, AESPB *pb)
{
	OBJECT *ob = pb->addrin[0];
	short x, y, w, h;
	
	w = ob->ob_width;
	h = ob->ob_height;
	
	x = (display.w - w) / 2;
	y = (display.h - h) / 2;
	
	ob->ob_x = x;
	ob->ob_y = y;
	
	pb->intout[0] = 1;
	pb->intout[1] = x;
	pb->intout[2] = y;
	pb->intout[3] = w;
	pb->intout[4] = h;
	
	return TRUE;
}

/*
  Begin/end form handler
  This is important - I hope most programs call this, as XaAES puts it's dialogs
  in windows, and the windows are created here....
*/
short XA_form_dial(short clnt_pid, AESPB *pb)
{	
	XA_WINDOW *dialog_window;
	short x, y, w, h;

	switch(pb->intin[0])
	{
		case FMD_START: 			/* Create a window to put the dialog in */

			dialog_window = create_window(clnt_pid, NAME, pb->intin[5], pb->intin[6], 
							pb->intin[7], pb->intin[8]);

			x = 2 * dialog_window->x - dialog_window->wx;
			y = 2 * dialog_window->y - dialog_window->wy;
			w = 2 * dialog_window->w - dialog_window->ww + 1;
			h = 2 * dialog_window->h - dialog_window->wh + 1;

			delete_window(dialog_window);		/* Dispose of the temporary window we created */
												/* And create the real one. It stay's fixed until form_do is called */
												/* when it gets a MOVE property. */
/* We create a window owned by the client so it will get button clicks for this area (in case it's gonna handle things it's own way) */
			clients[clnt_pid].zen = dialog_window = create_window(clnt_pid, NAME | STORE_BACK | NO_MESSAGES, x, y, w, h);
			dialog_window->is_open = TRUE;
			dialog_window->created_by_FMD_START = TRUE;
/* Set the window title to be the clients name to avoid confusion */
			dialog_window->widgets[XAW_TITLE].stuff = (void*)clients[clnt_pid].name;

			v_hide_c(V_handle);
			pull_wind_to_top(dialog_window);
			display_window(dialog_window);
			v_show_c(V_handle, 1);
			
			break;
		case FMD_GROW:
			break;
		case FMD_SHRINK:
			break;
		case FMD_FINISH:		/* If the client's dialog window is still hanging around, dispose of it.... */
			dialog_window = clients[clnt_pid].zen;
			if (dialog_window)
			{
				v_hide_c(V_handle);
				display_windows_below(dialog_window);
				v_show_c(V_handle, 1);

				dialog_window->is_open = FALSE;

				delete_window(dialog_window);
				clients[clnt_pid].zen = NULL;
			}
			break;
	}
	
	pb->intout[0] = 1;
	
	return TRUE;
}

short XA_form_button(short clnt_pid, AESPB *pb)
{
	OBJECT *tree = (OBJECT*)pb->addrin[0];
	short ob = pb->intin[0];
	short is, os, x, y, w, h;

	pb->intout[1] = 0;

	if (tree[ob].ob_flags & EDITABLE)	/* Select a new editable text field? */
	{
	/*	
	 * Shouldn't this really do all that's done in form_do?
	 */

		pb->intout[1] = ob;
	}

	if (((tree[ob].ob_flags & HIDETREE)		/* Was click on a valid selectable object? */
		||(tree[ob].ob_state & DISABLED))
		||(!(tree[ob].ob_flags & (SELECTABLE | EXIT | TOUCHEXIT))))
	{
		pb->intout[0] = 1;
		return TRUE;
	}

	CLIP(tree, ob, x, y, w, h);

	os = tree[ob].ob_state;
	is = os ^ SELECTED;

	if (tree[ob].ob_flags & TOUCHEXIT)		/* Change state & exit for TOUCHEXIT objects */
	{
/*
 * Surely radio buttons must be handled as well?
 */
		/* Only selectable objects change appearance! */
		if (tree[ob].ob_flags & SELECTABLE)
		{
			tree[ob].ob_state = is;
			v_hide_c(V_handle);
			draw_object_tree(tree, ob, MAX_DEPTH);
			v_show_c(V_handle, 1);
		}

		pb->intout[1] = ob;
		
		pb->intout[0] = 0;
		
		if (pb->intin[1] == 2)	/* Double click? */
		{
			pb->intout[1] |= 0x8000;
		}
		
		return TRUE;
	}

/*
 * Should this perhaps be done in watch_object()?
 */
	tree[ob].ob_state = is;
	CLIP(tree, ob, x, y, w, h);
	v_hide_c(V_handle);
	draw_object_tree(tree, ob, MAX_DEPTH);
	v_show_c(V_handle, 1);
		
	if (watch_object(tree, ob, is, os))		/* Do a watch to see if object is really selected */
	{
/*
 * Surely this should check for radio buttons?
 */
 		if (tree[ob].ob_flags & EXIT)
		{
			pb->intout[1] = ob;
			pb->intout[0] = 0;
#ifdef CLIP
			clear_clip();
#endif
			
			return TRUE;
		}
	}

#ifdef CLIP
	clear_clip();
#endif

	pb->intout[0] = 1;
	return TRUE;
}

short XA_form_alert(short clnt_pid, AESPB *pb)
{
	clients[clnt_pid].waiting_pb = pb;
	
	do_form_alert(pb->intin[0], (char*)pb->addrin[0], clnt_pid);

	return FALSE;
}

char error_alert[100];
short XA_form_error(short clnt_pid, AESPB *pb)
{
	char *msg;
	char icon;

	clients[clnt_pid].waiting_pb = pb;
	
	switch(pb->intin[0])
	{
		case 2:
			msg = "File not found.";
			icon = '5';
			break;
		case 3:
			msg = "Path not found.";
			icon = '5';
			break;
		case 4:
			msg = "No more file handles.";
			icon = '5';
			break;
		case 5:
			msg = "Access denied.";
			icon = '5';
			break;
		case 8:
			msg = "Insufficient memory.";
			icon = '6';
			break;
		case 10:
			msg = "Invalid enviroment.";
			icon = '6';
			break;
		case 11:
			msg = "Invalid format.";
			icon = '6';
			break;
		case 15:
			msg = "Invalid drive specification.";
			icon = '5';
			break;
		case 16:
			msg = "Attempt to delete working directory.";
			icon = '5';
			break;
		case 18:
			msg = "No more files.";
			icon = '5';
			break;
		default:
			msg = "Unknown error.";
			icon = '7';
			break;
		
	}
	
	sprintf(error_alert, "[%c][ ERROR: | %s ][ Bugger ]", icon, msg);
	
	do_form_alert(1, error_alert, clnt_pid);

	return FALSE;
}

/*
	Non-blocking form_do
	- uses an object tree widget in a window to implement the form handler.
*/
short XA_form_do(short clnt_pid, AESPB *pb)
{
	XA_WINDOW *dialog_window;
	OBJECT *form = (OBJECT*)pb->addrin[0];
	XA_WIDGET_LOCATION dialog_toolbar_loc = {LT, 3, 20};
	short x, y, w, h;
	short startedit;

	clients[clnt_pid].waiting_pb = pb;
	
	if (!clients[clnt_pid].zen)			/* If the client hasn't called FMD_START (naughty), create a window for the dialog */
	{
		dialog_window = create_window(clnt_pid, NAME | MOVE, form->ob_x, form->ob_y, form->ob_width, form->ob_height);

		x = 2 * dialog_window->x - dialog_window->wx;
		y = 2 * dialog_window->y - dialog_window->wy;
		w = 2 * dialog_window->w - dialog_window->ww + 1;
		h = 2 * dialog_window->h - dialog_window->wh + 1;

		delete_window(dialog_window);		/* Dispose of the temporary window we created */

		clients[clnt_pid].zen = dialog_window = create_window(AESpid, NAME | MOVE | STORE_BACK | NO_MESSAGES, x, y, w, h);

		dialog_window->created_by_FMD_START = FALSE;
	/* Set the window title to be the clients name to avoid confusion */
		dialog_window->widgets[XAW_TITLE].stuff = (void*)clients[clnt_pid].name;
	}else{
		dialog_window = clients[clnt_pid].zen;
		dialog_window->owner = AESpid;
		
#if 0
		v_hide_c(V_handle);
		display_windows_below(dialog_window);
		v_show_c(V_handle, 1);
#endif
	}
	
	dialog_toolbar_loc.y = display.c_max_h + 10;
	set_toolbar_widget(dialog_window, dialog_toolbar_loc, form);
	
	/*
	 * If there is an editable field, we'll need a keypress handler.
	 */
	
	startedit = pb->intin[0];
	if (!startedit) {	/* If there's no set edit_obj field, search */
		short f = 0;
		do {
			if (form[f].ob_flags & EDITABLE) {
				startedit = f;
				break;
			}
			f++;
		} while (!(form[f].ob_flags & LASTOB));
	}
	
	((XA_WIDGET_TREE*)dialog_window->widgets[XAW_TOOLBAR].stuff)->owner = clnt_pid;
	((XA_WIDGET_TREE*)dialog_window->widgets[XAW_TOOLBAR].stuff)->edit_obj = startedit;
	((XA_WIDGET_TREE*)dialog_window->widgets[XAW_TOOLBAR].stuff)->edit_pos = 0;	/* Needed? */
	
	if (startedit) {	/* Set up keypress handler if needed */
		TEDINFO *te = (TEDINFO*)form[startedit].ob_spec;
		short f = 0;

		do {								/* Ensure that there aren't two fields flagged as the */
			form[f].ob_state &= ~IS_EDIT;		/* current edit field */
			f++;
		} while(!(form[f].ob_flags & LASTOB));
		
		dialog_window->keypress = &handle_form_key;
		form[startedit].ob_state |= IS_EDIT;
		te->te_tmplen = strlen(te->te_ptext);
		((XA_WIDGET_TREE*)dialog_window->widgets[XAW_TOOLBAR].stuff)->edit_pos = te->te_tmplen;

		CLIP(form, startedit, x, y, w, h);
		v_hide_c(V_handle);
		draw_object_tree(form, startedit, 2);
		v_show_c(V_handle, 1);
	}

	dialog_window->active_widgets |= (NO_MESSAGES | MOVE);	/* We don't want any redraw messages  */
											/* - the widget handler will take care of it */
	dialog_window->is_open = TRUE;

#if 0
	v_hide_c(V_handle);
	pull_wind_to_top(dialog_window);
	display_window(dialog_window);
	v_show_c(V_handle, 1);
#endif

	return FALSE;
}

short XA_form_keybd(short clnt_pid, AESPB *pb)
{
	OBJECT *form = pb->addrin[0];
	short ed_obj = pb->intin[0];
	short keycode = pb->intin[1];
	TEDINFO *ed_txt;
	char *txt;
	short o, x, y, w, h, last_ob;
	
	DIAGS(("form_keybd():%x,%x,%x\n", pb->intin[0], pb->intin[1], pb->intin[2]));
	
	pb->intout[0] = 1;
	pb->intout[1] = ed_obj;
	pb->intout[2] = 0;
	
	if (!(form[ed_obj].ob_flags & EDITABLE))
		return TRUE;

	ed_txt = (TEDINFO*)form[ed_obj].ob_spec;
	txt = ed_txt->te_ptext;

	switch(keycode)
	{
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
		for(last_ob = 0; !(form[last_ob].ob_flags & LASTOB); last_ob++) ; /*find last object*/
		o = last_ob;
		for(; !(form[o].ob_flags & EDITABLE); o--) ;		/* search for last editable object */
		break;
			
	case 0x4800:	/* UP ARROW moves to previous field */
		for(last_ob = 0; !(form[last_ob].ob_flags & LASTOB); last_ob++) ; /*find last object*/
				
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
					
	case 0x1c0d:	/* Return - select default (if any) */
		o = 0;
		do{
			if (form[o].ob_flags & DEFAULT)
			{
				pb->intout[0] = 0;
				pb->intout[1] = o;
				return TRUE;
			}
			o++;
		} while(!(form[o].ob_flags & LASTOB));
		break;
				
	default:		/* just a plain key - insert character */
		DIAGS(("passing character back to client\n"));
		pb->intout[2] = keycode;
		break;
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
			draw_object_tree(form, ed_obj, 2);

			((TEDINFO*)form[o].ob_spec)->te_tmplen = strlen(((TEDINFO*)form[o].ob_spec)->te_ptext);
			
			CLIP(form, o, x, y, w, h);
			draw_object_tree(form, o, 2);
			v_show_c(V_handle, 1);
				
			pb->intout[1] = o;
		}
	}
	
	return TRUE;
}
