/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <osbind.h>
#include <string.h>
#include <ctype.h>			/* We use the version without macros!! */

#include "xa_types.h"
#include "xa_globl.h"
#include "xa_nkcc.h"
#include "xa_form.h"

#include "xalloc.h"
#include "objects.h"
#include "c_window.h"
#include "rectlist.h"
#include "widgets.h"
#include "xa_graf.h"
#include "xa_rsrc.h"
#include "xa_evnt.h"
#include "scrlobjc.h"

/*
 *	FORM HANDLERS INTERFACE
 */

global
void center_form(OBJECT *form, int barsizes)
{
	form->r.x =  root_window->wa.x
	           + (root_window->wa.w - form->r.w) / 2;
	form->r.y =  root_window->wa.y
	           + barsizes
	           + (root_window->wa.h - form->r.h) / 2;

}

/*
 *	Create a copy of an object tree
 *	- Intended for using the form templates in SYSTEM.RSC (we can't use them
 *	directly as this would cause problems when (for example) two apps do a form_alert()
 *	at the same time.
 */
static
OBJECT *CloneForm(OBJECT *form)
{
	int num_objs = 0, o;
	OBJECT *new_form;

	while ((form[num_objs++].ob_flags & LASTOB) == 0);		/* HR */

	new_form = xmalloc(sizeof(OBJECT) * num_objs, 9);
	
	for (o = 0; o < num_objs; o++)
		new_form[o] = form[o];
	
	return new_form;
}

/*
 *	Free up a copy of a form template
 *  HR 210501: and extra info 
 */
static
WindowDisplay alert_destructor		/* lock, wind */
{
	DIAG((D_form,nil,"alert_destructor\n"));
	remove_widget(lock, wind, XAW_TOOLBAR);
	return true;
}

/*
 * Small handler for clicks on an alert box
 */
static
WidgetBehaviour click_alert_widget	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	XA_TREE *wt = widg->stuff;
	RECT r;
	OBJECT *alert_form;
	int sel_b = -1, f, b;

	if (window_list != wind)			/* HR 220501 */
	{
		C.focus = pull_wind_to_top(lock, wind);			/* HR */
		after_top(lock, false);
		display_window(lock, 520, wind, nil);
		return false;
	}

	alert_form = wt->tree;

	rp_2_ap(wind, widg, &r);	/* Convert relative coords and window location to absolute screen location */

	f = find_object(alert_form, 0, 10, r.x + widg->x, r.y + widg->y, wt->dx, wt->dy);

	if (    f >= ALERT_BUT1			/* Did we click on a valid button? */
		and f <  ALERT_BUT1 + ALERT_BUTTONS
		and !(alert_form[f].ob_flags & HIDETREE)
		)
	{
		b = watch_object(lock, wt, f, SELECTED, 0);

		if (b)
			sel_b = f + 1 - ALERT_BUT1;

		if (sel_b > -1)
		{
			/* HR 210501: Really must do this BEFORE unblocking!!! */
			close_window(lock, wind);		
			delete_window(lock, wind);

			if (wt->owner != C.Aes)
			{
				XA_CLIENT *client = wt->owner;
				client->waiting_pb->intout[0] = f - ALERT_BUT1 +1;
					/* Write success to clients reply pipe to unblock the process */
				Unblock(client, XA_OK, 7);
			}
		}
	}
	
	return false;
}

/*
 *	Form_alert handler v2.1
 */

/* HR: Ok, I know nobody is perfect, but only a few are this stupid. 
			Corrupting a user's alert string. (see xalert.h)
   Partly rewritten using IPFF.
*/
#include "ipff.h"

static
int get_parts(int m, char to[][MAX_X+1], int *retv)
{
	int n = 0;
	while (n < m)
	{
		int s = lstr(to[n++],'|]');		/* delimited string, no translation */
		if (s eq '|')
			sk1();
		elif (s eq ']')
		{
			skc();
			break;
		othw					/* must be end of string */
			*retv = 0;
			break;
		}
	}
	return n;
}

static
int max_w(int m, char to[][MAX_X+1], int *tot)
{
	int n = 0, x = 2, t = 0;
	while (n < m)
	{
		int l = strlen(to[n]);
		if (l > x)
			x = l;
		t += l+3;
		n++;
	}
	if (tot)
		*tot = t * screen.c_max_w;
	return x*screen.c_max_w;
}

/* HR: changed thus, that a alert is always displayed, whether format error or not.
       otherwise the app is suspended and the screen & keyb are locked,
       and you can do nothing but a reset. :-(
   HR 250602: reactivated the STORE_BACK facility for form_alert only.
              If a application has locked the screen, there might be something
              unser the alert that is not a window.
*/
global
int do_form_alert(LOCK lock, XA_CLIENT *client, int default_button, char *alert)
{
	WindowKeypress key_alert_widget;
	XA_WIND_ATTR kind = NAME|TOOLBAR|USE_MAX;		/* HR 250602 */
	XA_WINDOW *alert_window;
	XA_WIDGET *widg;
	XA_TREE *wt;
	OBJECT *alert_form,
	       *alert_icons;
	ALERTXT *alertxt;
	G_i x, y, w, h;
	int  n_lines, n_buttons, icon = 0, m_butt_w,
	      retv = 1, b, f;

	DIAG((D_form,client,"called do_form_alert(%s)\n",alert));

/* HR: < */

/* Create a copy of the alert box templates */
	alert_form = CloneForm(ResourceTree(C.Aes_rsc, ALERT_BOX));
	alertxt = xmalloc(sizeof(*alertxt), 90);
	if (!alert_form or !alertxt)
		return 0;

	for (f = 0; f < ALERT_LINES; f++)
		alertxt->text[f][0] = '\0';

	ipff_init(MAX_X,-1,0,nil,alert,nil);

	if (sk() eq '[')		/* skip white space and give non_white char */
	{
		skc();				/* skip char & following white space, give non_white char */
		icon = idec();		/* give decimal number */
		if (sk() eq ']')
			skc();
	}

	if (sk() ne '[')
		retv = 0;
	else
		sk1();

	n_lines = get_parts(ALERT_LINES,alertxt->text,&retv);	/* parse ...|...|... ... ] */

	if (sk() ne '[')
		retv = 0;
	else
		sk1();

	ipff_init(MAX_B,-1,0,nil,nil,nil);

	n_buttons = get_parts(ALERT_BUTTONS,alertxt->button,&retv);
	
	w = max_w(n_lines,   alertxt->text, nil);
	    max_w(n_buttons, alertxt->button, &m_butt_w);

	if (m_butt_w > w)
		w = m_butt_w;

	w += 66;
/* >  */

	alert_icons = ResourceTree(C.Aes_rsc, ALERT_ICONS);

	alert_form->r.w = w;
	center_form(alert_form, ICON_H);

	{	/* HR */
		int icons[7] = {ALR_IC_SYSTEM, ALR_IC_WARNING, ALR_IC_QUESTION, ALR_IC_STOP,
						  ALR_IC_INFO,   ALR_IC_DRIVE,   ALR_IC_BOMB};
		if (icon > 7 or icon < 0)
			icon = 0;
		
		for (f = 0; f < 7; f++)
		{
			ICONBLK *ai = get_ob_spec(alert_icons + icons[f]    )->iconblk,
			        *af = get_ob_spec(alert_form  + ALERT_D_ICON)->iconblk;
			ai->ic.x = af->ic.x;
			ai->ic.y = af->ic.y;
		}

		(alert_form + ALERT_D_ICON)->ob_spec = (alert_icons + icons[icon])->ob_spec;
	}

	for (f = 0; f < ALERT_LINES; f++)				/* Fill in texts */
	{
		alert_form[ALERT_T1 + f].ob_spec.string = alertxt->text[f];		/* HR 210501 */
		if (*alertxt->text[f] == 0)
			alert_form[ALERT_T1 + f].ob_flags |= HIDETREE;
		else
			alert_form[ALERT_T1 + f].ob_flags &= ~HIDETREE;
	}

	x = w - m_butt_w; 					/* Space the buttons evenly */
	b = x / (n_buttons + 1);	
	x = b;

	for (f = 0; f < n_buttons; f++)		/* Fill in & show buttons */
	{
		int w = strlen(alertxt->button[f])+3;
		w *= screen.c_max_w;
		alert_form[ALERT_BUT1 + f].ob_spec.string = alertxt->button[f];		/* HR 210501 */
		alert_form[ALERT_BUT1 + f].r.w = w;
		alert_form[ALERT_BUT1 + f].r.x = x;
		alert_form[ALERT_BUT1 + f].ob_flags &= ~(HIDETREE|DEFAULT);
		alert_form[ALERT_BUT1 + f].ob_state = 0;
		x += w + b;
	}

/* HR 100801: Verbeterde bladspiegel van alerts. */
	{
		int nl = n_lines, dh;

		if (n_lines < 2)
			nl = 2;
		dh = (ALERT_LINES - nl)*screen.c_max_h;
		alert_form[0].r.h -= dh;
		alert_form[ALERT_BUT1].r.y -= dh;
		alert_form[ALERT_BUT2].r.y -= dh;
		alert_form[ALERT_BUT3].r.y -= dh;
	}

	if (default_button > 0)				/* Set the default button if it was specified HR: check > 0 */
	{
		if (default_button > n_buttons)		/* HR: please check your input! */
			default_button = n_buttons;
		alert_form[ALERT_BUT1 + default_button - 1].ob_flags |= DEFAULT;
	}

	for (f = n_buttons; f < ALERT_BUTTONS; f++)		/* Hide unused buttons */
		alert_form[ALERT_BUT1 + f].ob_flags |= HIDETREE;
	{
		RECT r;

/* Create a window and attach the alert object tree to it */
/* HR: better centered now */
		if (client->fmd.lock)						/* HR 250602 */
			kind |= STORE_BACK;

		r = calc_window(lock, client, WC_BORDER,
							kind,
							MG,
							C.Aes->options.thinframe,
							C.Aes->options.thinwork,
							alert_form->r);		/* HR */
		alert_window = create_window(lock, nil, client, false,
							kind,
							created_for_AES,
							MG,
							C.Aes->options.thinframe,
							C.Aes->options.thinwork,
							r,nil,nil);
	}
	widg = get_widget(alert_window, XAW_TOOLBAR);
	wt = set_toolbar_widget(lock, alert_window, alert_form, -1);
	wt->extra = alertxt;
	
/* Change the click & drag behaviours for the alert box widget, because alerts return a number */
/* 1 to 3, not an object index. */
/* HR: we also need a keypress handler for the default button (if there) */
	alert_window->keypress = key_alert_widget;
	widg->click = click_alert_widget;
	widg->drag  = click_alert_widget;
	
	/* HR: We won't get any redraw messages
	       - The widget handler will take care of it.
	       - (the message handler vector id nil!!!) */
/* Set the window title to be the client's name to avoid confusion */
	get_widget(alert_window, XAW_TITLE)->stuff = client->name;	 /* HR */
	alert_window->destructor = alert_destructor;						/* HR 210501 */
	open_window(lock, alert_window, alert_window->r);
	forcem();		/* For if the app has hidden the mouse */
	return retv;
}

/*
 * Primitive version of form_center....
 * - This ignores shadows & stuff
 *
 * HR: It seems that every app knows that :-)
 *
 */
AES_function XA_form_center	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	OBJECT *ob = pb->addrin[0];
	G_i *o = pb->intout;

	CONTROL(0,5,1)

	DIAG((D_form,client,"XA_form_center for %s ob=%lx o=%lx\n",c_owner(client),ob,o));

	if (ob and o)
	{
		RECT r;

		r.w = ob->r.w;
		r.h = ob->r.h;
		
		r.x = (root_window->wa.w - r.w) / 2;		/* HR: desktop work area */
		r.y = (root_window->wa.h - r.h) / 2;
		
		ob->r.x = r.x;
		ob->r.y = r.y;


 		if (ob->ob_state&OUTLINED)
 			adjust_size(3, &r);				/* HR 290301: This is what other AES's do */

		*o++ = 1;
		*(RECT *)o = r;

		DIAG((D_form,client,"   -->    %d/%d,%d/%d\n",r));
	}

	return XAC_DONE;
}

global
int find_flag(OBJECT *ob, int flag)
{
	int f = 0;
	do
		if (ob[f].ob_flags & flag)
			return f;
	while ( ! (ob[f++].ob_flags & LASTOB));	/* HR: Check LASTOB before incrementing */
	return -1;
}

static
int find_cancel_button(OBJECT *ob)
{
	int f = 0;
	do
	{
		if (    (ob[f].ob_type & 0xff) == G_BUTTON
			and (ob[f].ob_flags & (SELECTABLE|TOUCHEXIT|EXIT)) != 0  )
		{
			int l;
			char t[32]; char *s = t,*e;
			e = get_ob_spec(ob+f)->string;
			l = strlen(e);
			if (l < 32)
			{
				strcpy(t,e);
				/* strip surrounding spaces */
				e = t + l;
				while (*s == ' ') s++;
				while (*--e == ' ')  ;
				*++e = 0;
				if (e-s < CB_L)	/* No use comparing longer strings */
				{
					int i = 0;
					while (cfg.cancel_buttons[i][0])
						if (stricmp(s,cfg.cancel_buttons[i]) == 0)
							return f;
						else i++;
				}
			}
		}
	}
	while ( ! (ob[f++].ob_flags & LASTOB));
	return -1;
}

/*
 * Form Keyboard Handler for toolbars
 */


/* HR: more code duplication removed. */
/* Reduction of clumsyness.
   (clumsyness mainly caused by pathological use of for statement) */
/* N.B.  A form can be a single editable boxtext!            */
static
int form_cursor(LOCK lock, XA_TREE *wt, G_u keycode, int obj)
{
#define editable (form[o].ob_flags & EDITABLE)

	OBJECT *form = wt->tree;
	int o = obj, ed = 0,
	      last_ob = 0;
	while ( ! (form[last_ob].ob_flags & LASTOB))	/* Find last object & check for editable */
	{
		ed |= form[last_ob].ob_flags & EDITABLE;
		last_ob++;	
	}

	switch(keycode)
	{			/* 	The cursor keys are always eaten. */
	default:
		o = -1;			/* This is also a safeguard.  */
		break;

	case 0x0f09:		/* TAB moves to next field */
	case 0x5000:		/* DOWN ARROW also moves to next field */
		if (ed)
			do   o = o == last_ob ? 0       : o + 1;			/* loop round */
			while (!editable);
		break;

	case 0x4800:		/* UP ARROW moves to previous field */
		if (ed)
			do   o = o == 0       ? last_ob : o - 1;			/* loop round */
			while (!editable);
		break;

	case 0x4737:		/* SHIFT+HOME */
	case 0x5032:		/* SHIFT+DOWN ARROW moves to last field */
	case 0x5100:		/* page down key (Milan &| emulators)   */
		if (ed)
		{
			o = last_ob;
			while (!editable) o--;		/* Search for last editable object */
		}
		break;

	case 0x4700:		/* HOME */
	case 0x4838:		/* SHIFT+UP ARROW moves to first field */
	case 0x4900:		/* page up key (Milan &| emulators)    */
		if (ed)
		{
			o = 0;
			while (!editable) o++;		/* Search for first editable object */
		}
		break;
	}

	/* HR 040201: At last this piece of code is on the right spot.
		This is important! Now I know that bug fixes in here are good enough for all cases. */
	if (o >= 0)
		if (o != obj)	/* If edit field has changed, update the screen */
		{	
			TEDINFO *ted = get_ob_spec(&form[o])->tedinfo;
			int last = strlen(ted->te_ptext);
			if (wt->edit_pos > last)		/* HR 040201: fix corsor position of new field. */
				wt->edit_pos = last;
			wt->edit_obj = o;
			redraw_object(lock, wt, obj);
			if (*(ted->te_ptext) eq '@')				/* HR 101200 */
				*(ted->te_ptext) =  0;
			redraw_object(lock, wt, o);
		}

	return o;
}

static
int find_shortcut(OBJECT *tree, G_u nk)
{
	int i = 0;
	nk&=0xff;
DIAG((D_keybd,nil,"find_shortcut: %d(0x%x), '%c'\n", nk, nk, nk));
	do
	{
		OBJECT *ob = tree + i;
		if (ob->ob_state&WHITEBAK)
		{
			int ty = ob->ob_type&0xff;
			if (ty == G_BUTTON or ty == G_STRING)
			{
				int j = (ob->ob_state>>8)&0x7f;
				if (j < 126)
				{
					char *s = get_ob_spec(ob)->string;
					if (s)
					{
						DIAG((D_keybd,nil,"  -  in '%s' find '%c' on %d :: %c\n",s,nk,j, *(s+j)));
						if (j < strlen(s) and toupper(*(s+j)) == nk)
							return i;
					}
				}
			}
		}
	} while ( (tree[i++].ob_flags&LASTOB) == 0);

	return -1;
}

/* HR (*)() */
AES_function XA_form_keybd	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_TREE *wt;
	OBJECT *form = pb->addrin[0];
	G_i obj = pb->intin[0],
	      keycode = pb->intin[1],
	      *op = pb->intout;
	int  o;

	CONTROL(3,3,1)

	wt = check_widget_tree(lock, client, form);		/* HR 200201 */
DIAG((D_keybd,client,"XA_form_keybd for %s %lx: obj:%d, k:%x, nob:%d\n",
			c_owner(client), form, obj, keycode, pb->intin[2]));

/* HR: removed spurious, and wrong check on EDITABLE which caused exit,
       and assign to a TEDINFO, which after all was not used.
*/
	o = form_cursor(lock, wt, keycode, obj);	/* HR: More duplicate code removed */

	if (o >= 0)		/* A cursor operation. */
	{
DIAG((D_keybd,client,"XA_form_keybd: nxt_obj=%d, cursor operation\n", o));
		*op++ = 1;				/* continue */
		*op++ = o;				/* next obj */
		*op   = 0;				/* pchar */
	othw

/* Tried out with TOS 3.06: DEFAULT only, still exits. */
		if ((keycode == 0x1c0d or keycode == 0x720d))
			o = find_flag(form, DEFAULT);
		else if (keycode == 0x6100)		/* UNDO */
			o = find_cancel_button(form);
		else
		{
			G_i state;
			vq_key_s(C.vh, &state);
			if ((state&(K_CTRL|K_ALT)) == K_ALT)
			{
				G_u nkcode = normkey(state, keycode);
				o = find_shortcut(form, nkcode);
				if (o >= 0)
				{
DIAG((D_keybd,client,"XA_form_keybd: nxt_obj=%d, shortcut\n", o));
					if (do_form_button(lock, wt, form, o, nil, 0, 0, 0, 0) == 0)
					{
						*op++ = 1,
						*op++ = obj;
						*op   = 0;
						return XAC_DONE;
					}
				}
			}
		}

		if (o >= 0)
		{
DIAG((D_keybd,client,"XA_form_keybd: nxt_obj=%d, return, cancel, or shortcut\n", o));
			*op++ = 0;			/* exit object. */
			*op++ = o;			/* nxt_obj */
			*op   = 0;			/* pchar */
			return XAC_DONE;
		}
		else			
		{		/* just a plain key - pass character */
DIAG((D_keybd,client,"XA_form_keybd: nxt_obj=%d, passing character back to client\n", obj));
			*op++ = 1;			/* continue */
			*op++ = obj;		/* pnxt_obj */
			*op   = keycode;	/* pchar */
		}
	}

	return XAC_DONE;
}

AES_function XA_form_alert	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(1,1,1)

	client->waiting_pb = pb;
	
DIAG((D_form,client,"XA_alert %s\n",(char *)pb->addrin[0]));
	do_form_alert(lock, client, pb->intin[0], (char *)pb->addrin[0]);

	return XAC_BLOCK;
}

static
char error_alert[100];

AES_function XA_form_error	/* (LOCK lock, LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	char *msg;
	char icon;

	CONTROL(1,1,0)

	client->waiting_pb = pb;
	
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
	
	sdisplay(error_alert, "[%c][ ERROR: | %s ][ Bugger ]", icon, msg);

DIAG((D_form,client,"alert_err %s",error_alert));
	do_form_alert(lock, client, 1, error_alert);

	return XAC_BLOCK;
}

global
int has_default(OBJECT *ob)
{
	int f = 0;
	do
		if (ob[f].ob_flags & DEFAULT)
			return true;
	while ( ! (ob[f++].ob_flags & LASTOB));
	return false;
}

/* HR 250602: Better handling of xa_windows. Now also called in XA_objc_draw for root objects. */
static
XA_WINDOW *make_fmd(LOCK lock, XA_CLIENT *client)
{
	XA_WINDOW *wind;
	XA_WIND_ATTR kind = client->fmd.kind | TOOLBAR |USE_MAX;
	RECT r = client->fmd.r;

#if NOTYET
	/* HR 220401: Dont do it if it wouldnt fit anymore. */
	if (r.w > root_window->wa.w or r.h > root_window->wa.h)
		break;
#endif
	client->fmd.wind =
		wind =
			create_window(lock,
#if TEST_DIAL_SIZE
					handle_form_window,
#else
					nil,
#endif
					client, false,
					kind,
					client->fmd.state ? created_for_FMD_START : created_for_FORM_DO,
					MG,
					C.Aes->options.thinframe,
					C.Aes->options.thinwork,
					r,
#if TEST_DIAL_SIZE
					&r,
#else
					nil,
#endif
					nil);

/*	if (wind)
		wind->outline_adjust = true;		/* HR 250602: we dont know yet if it is necessary, but it doesnt do harm. */
*/
/* Set the window title to be the clients name to avoid confusion */
#if GENERATE_DIAGS
	{
		char nm[32];
		strip_name(nm, client->name);
		sdisplay(client->zen_name, "[%c%c]%s (form_dial)",
					client->fmd.lock ? 'U' : ' ',
					client->pid == S.mouse_lock ? 'M' : ' ', nm);
		get_widget(wind, XAW_TITLE)->stuff = client->zen_name;
	}
#else
	get_widget(wind, XAW_TITLE)->stuff = client->name;
#endif
	open_window(lock, wind, wind->r);

	DIAG((D_form,client,"make_fmd (form_dial/form_do window)\n"));
	return wind;
}

/*
 *  Begin/end form handler
 *  This is important - I hope most programs call this, as XaAES puts its dialogs
 *  in windows, and the windows are created here...
 *  HR 250602: postpone creating the window until form_do is called.
 */
AES_function XA_form_dial	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{	
	XA_WINDOW *wind;
	XA_WIND_ATTR kind = NAME
#if TEST_DIAL_SIZE
					|HSLIDE|LFARROW|VSLIDE|UPARROW|SIZE
#endif
					;

	CONTROL(9,1,0)

	switch(pb->intin[0])
	{
	case FMD_START: 
		DIAG((D_form,client,"form_dial(FMD_START,%d,%d,%d,%d) for %s\n",
				pb->intin[5], pb->intin[6], pb->intin[7], pb->intin[8], c_owner(client)));

/*   HR 060201: If the client forgot to FMD_FINISH, we dont create a new window, but
       simply move the window to the new coordinates.
*/
		if (client->fmd.wind)
		{
			RECT r;
			wind = client->fmd.wind;
			DIAG((D_form,client,"Already fmd.wind %d\n", wind->handle));

			r = calc_window(lock, client, WC_BORDER,
					kind,
					MG,
					C.Aes->options.thinframe,
					C.Aes->options.thinwork,
					*(RECT *)&pb->intin[5]);
			move_window(lock, wind, -1, r.x, r.y, r.w, r.h);
		othw

/*   HR 250602: Provisions made in the case form_do isnt used by the client at all.
              So the window creation is actually postponed until form_do is called.
              If the client doesnt call form_do, it probably has locked the screen already and XaAES will
              behave just like any other AES.
     HR 060702:
              As a benefit all handling of the 3 pixel gap caused by form_center on OUTLINED forms
              can be removed.
*/
			client->fmd.state = 1;
			client->fmd.kind = kind;
		}
		break;
	case FMD_GROW:
		break;
	case FMD_SHRINK:
		break;
	case FMD_FINISH:
		DIAG((D_form,client,"form_dial(FMD_FINISH) for %s\n", c_owner(client)));
		if (client->fmd.wind)	/* If the client's dialog window is still hanging around, dispose of it... */
		{
			wind = client->fmd.wind;
			DIAG((D_form,client,"Finish fmd.wind %d\n", wind->handle));
			close_window(lock, wind);
			delete_window(lock, wind);
		} else	/* This was just a redraw request */
			display_windows_below(lock, (RECT *)&pb->intin[5], window_list);		/* HR */

		memset(&client->fmd, 0, sizeof(client->fmd));
		break;
	}
	
	pb->intout[0] = 1;
	
	return XAC_DONE;
}

/*
 *	Form_do() handlers
 */
/* ExitForm(LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg, XA_TREE *wt, int f, int os, int dbl, int which, KEY *key) */

ExitForm XA_form_exit
{
	if (os != -1)
	{
		wt->tree[f].ob_state = os;
		redraw_object(lock, wt, f);
	}
	wt->which = 0;					/* HR After redraw of object. :-) */
	wt->current = f|dbl;			/* HR 300101: pass the double click to the internal handlers as well. */
	wt->exit_handler(lock, wt);		/* XaAES application point of view. */
}

ExitForm exit_toolbar				/* See the dialtest program :-) */
{
	via (wind->send_message)(lock, wind, nil,
					WM_TOOLBAR, 0, 0, wind->handle,
				    f, dbl ? 2 : 1, widg->k, 0);
}

#if WDIAL
ExitForm exit_wdial
{
	XA_CLIENT *client = wt->owner;
	MOOSE_DATA md;

	md.x = form->r.x + widg->x;
	md.y = form->r.y + widg->y;
	md.state = widg->s;
	md.clicks = dbl ? 2 : 1;

	if (os != -1)
	{
		form[f].ob_state = os;
		redraw_object(lock, wt, f);
	}
	wt->tree = form;				/* HR After redraw of object. :-) */
	wt->current = f|dbl;			/* HR 300101: pass the double click to the internal handlers as well. */
	wt->which = which;				/* HR 050402: pass the event type. */

	if (which == MU_BUTTON)
	{
		DIAG((D_wdlg, client, "button_event: x=%d, y=%d, clicks=%d\n", md.x, md.y, md.clicks));
		button_event(lock, client, &md);
	} else
	{
		DIAG((D_wdlg, client, "keybd_event: x=%d, y=%d, clicks=%d\n", md.x, md.y, md.clicks));
		keybd_event(lock, client, key);
	}
}
#endif

ExitForm exit_form_do
{
	XA_CLIENT *client = wind->owner;
	/* HR: 300101   The sign bit for double click is also a feature of form_do()
					 (obno = form_do(x,y)) < 0 ? double_click : single_click; */
	client->waiting_pb->intout[0] = f|dbl;

	DIAG((D_form,client,"exit_form_do: obno=%d\n", f));

	client->fmd.wind = nil;
	client->fmd.state = 0;

	close_window(lock, wind);
	delete_window(lock, wind);

	/* Write success to clients reply pipe to unblock the process */
	Unblock(client, XA_OK, 8);
}

ExitForm exit_form_dial
{
	XA_CLIENT *client = wind->owner;

	client->waiting_pb->intout[0] = f|dbl;

	DIAG((D_form,client,"exit_form_dial: obno=%d\n", f));

/* HR 120201: Because we are out of the form_do any form_do() handlers must be removed! */

	remove_widget(lock, wind, XAW_TOOLBAR);

	/* Write success to clients reply pipe to unblock the process */
	Unblock(client, XA_OK, 9);
}

ExitForm classic_exit_form_do
{
	XA_CLIENT *client = wt->owner;

	client->waiting_pb->intout[0] = f|dbl;

	client->fmd.keypress = nil;
	client->fmd.mousepress = nil;

	/* Write success to clients reply pipe to unblock the process */
	Unblock(client, XA_OK, 10);
}

global
WindowKeypress handle_form_key /* LOCK lock, XA_WINDOW *wind, XA_TREE wt, G_u keycode, G_u nkcode, KEY key */ /* HR */
{
	IFDIAG(XA_CLIENT *client = wind ? wind->owner : (wt ? wt->owner : nil);)
	XA_WIDGET *widg = nil;
	OBJECT *form;
	TEDINFO *ed_txt;
	int o, ed_obj;

	if (wind)
		widg = get_widget(wind, XAW_TOOLBAR);

	if (!wt)
	{
		if (widg)
			wt = widg->stuff;
		else
		{
			DIAGS(("Inconsistent handle_form_key!!!!"));
			return false;
		}
	}

	DIAG((D_form,client,"handle_form_key\n"));

	form = wt->tree;
	ed_obj = wt->edit_obj;

DIAG((D_k,client,"got keypress in form\n"));

	o = form_cursor(lock, wt, keycode, ed_obj);	/* HR: More duplicate code removed */

	if (o < 0)
	{
		/* Return - select default (if any) */
		/* HR: Enter */

		if (keycode == 0x1c0d or keycode == 0x720d)
			o = find_flag(form, DEFAULT);
		else if (keycode == 0x6100)		/* UNDO */
			o = find_cancel_button(form);
		else if ((key.raw.conin.state&(K_CTRL|K_ALT)) == K_ALT)
		{
			if (nkcode == 0)
				nkcode = nkc_tconv(key.raw.bcon);
			o = find_shortcut(form, nkcode);
			if (o >= 0)
			{
				int ns;
				if (do_form_button(lock, wt, form, o, &ns, 0, 0, 0, 0))
				{	
					via (wt->exit_form)(lock, wind, widg, wt, o, ns, 0, MU_KEYBD, &key);			/* HR 250602 via */
DIAG((D_form,client,"on shortcut exited; item %d\n", o));
					return false;
				}
				return true;
			}
		}

		if (o >= 0)
		{
			via (wt->exit_form)(lock, wind, widg, wt, o, -1, 0, MU_KEYBD, &key);		/* HR 250602 via */
DIAG((D_form,client,"handle_form_key exited\n"));
			return false;			/* HR 290501: discontinue */
		}
		else	/* handle plain key */
		{
			/* HR: another massive code duplication,
					they should be the same,
					but they were NOT! :-( */

			/* HR: moved to here, where it is needed, and then check if the field IS editable */
			if (form[ed_obj].ob_flags&EDITABLE)
			{
				ed_txt = get_ob_spec(&form[ed_obj])->tedinfo;
				if (ed_char(wt, ed_txt, keycode))	/* HR pass the widget tree */
					redraw_object(lock, wt, ed_obj);
DIAG((D_form,client,"handle_form_key after ed_char\n"));
			}
		}
	}

	return true;
}

global
void init_form_do(LOCK lock, XA_TREE *wt, OBJECT *form, int item, bool draw)
{
	/*
	 * If there is an editable field, we'll need a keypress handler.
	 *  HR: We need a keypress handler for the default object as well
	 */

	if (item <= 0)
		item = find_flag(form, EDITABLE);

	wt->edit_obj = item;
	
	if (item >= 0)
	{
		TEDINFO *ted = get_ob_spec(&form[item])->tedinfo;
		if (*(ted->te_ptext) eq '@')				/* HR 101200 */
			*(ted->te_ptext) =  0;
		wt->edit_pos = strlen(ted->te_ptext);
		if (draw)
			draw_object_tree(lock, wt, form, item, 0, 124);		/* draw the cursor */
	}
}

/*
 *	HR 250602
 * Attach a classic (blocked) form_do widget tree to a client.
 *   put in here because it is closely similar to set_toolbar_widget() below.
 */
void set_form_do(LOCK lock, XA_CLIENT *client, OBJECT *form, int item)
{
	XA_TREE *wt = &client->wt;

	wt->exit_form = classic_exit_form_do;
	wt->tree = form;
	wt->owner = client;
	
	init_form_do(lock, wt, form, item, true);			/* HR 060702 */

	if (has_default(form) or wt->edit_obj >= 0)
		client->fmd.keypress = handle_form_key;
	client->fmd.mousepress = click_form_do;
}

/*
 *	Non-blocking form_do
 *	- Uses an object tree widget in a window to implement the form handler.
 *        unless the client already locked the screen, or option 'xa_windows none' is set.	/* HR 250602 */
 */

AES_function XA_form_do	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *wind = nil;
	XA_WIND_ATTR kind = NAME;
	XA_TREE *wt;
	OBJECT *form = (OBJECT *)pb->addrin[0];
	int item = pb->intin[0];
	RECT r;
	
	CONTROL(1,1,1)

	DIAG((D_form,client,"form_do()\n"));

	client->waiting_pb = pb;

	if (client->fmd.wind)
	{
		wind = client->fmd.wind;
		DIAG((D_form,client,"With fmd %d; set_toolbar_widget\n", wind->handle));
		/* HR 070702 */
		wt = set_toolbar_widget(lock, wind, form, item);
		wt->zen = true;		/* This can be of use for drawing. (keep off border & outline :-) */
	}
	else
	if (client->fmd.lock)			/* HR 250602: classic form_do */
	{
		set_form_do(lock, client, form, item);		
		return XAC_BLOCK;
	othw
		/* Work out sizing */
		client->fmd.r =
		calc_window(lock, client, WC_BORDER,
				kind,
				MG,
				C.Aes->options.thinframe,
				C.Aes->options.thinwork,
				form->r);
	
		if (!client->options.xa_nomove)
			kind |= MOVE;
		client->fmd.kind = kind;
	
	IFDIAG(if (client->fmd.state == 0)			/* HR 250602 */
			DIAG((D_form,client,"Without fmd\n"));
		else
			DIAG((D_form,client,"Postponed fmd\n"));)
	}

/* We create a window owned by the client so it will get button clicks for this area
(in case it's gonna handle things its own way)
*/
	if (wind == nil)
	{
		wind = make_fmd(lock, client);
		DIAG((D_form,client,"make_fmd: %d; set_toolbar_widget\n", wind->handle));

		/* HR */
		wt = set_toolbar_widget(lock, wind, form, item);
		wt->zen = true;		/* This can be of use for drawing. (keep off border & outline :-) */
	}

	if (wind->is_open)
	{
		DIAG((D_form,client,"display_toolbar: wind: %d/%d, form: %d/%d\n", wind->r.x, wind->r.y, form->r.x, form->r.y));
		display_toolbar(lock, wind, 0);
	}
	else
	{
		DIAG((D_form,client,"open_window: wind: %d/%d, form: %d/%d\n", wind->r.x, wind->r.y, form->r.x, form->r.y));
		open_window(lock, wind, wind->r);		/* HR 210201 */
	}

	return XAC_BLOCK;
}

/*
 * HR:
 * Small handler for ENTER/RETURN/UNDO on an alert box
 */
static
WindowKeypress key_alert_widget /* LOCK lock, XA_WINDOW *wind, XA_TREE *wt, G_u keycode, G_u nkcode, CONKEY raw */
{
	XA_WIDGET *widg = get_widget(wind, XAW_TOOLBAR);
	RECT r;
	OBJECT *alert_form;
	int f = 0;

	wt = widg->stuff;		/* always nil */

	if (window_list != wind)			/* You can only work alerts when they are on top */
		return false;

	alert_form = wt->tree;

	rp_2_ap(wind, widg, &r);	/* Convert relative coords and window location to absolute screen location */

	if (keycode == 0x720d or keycode == 0x1c0d)
		f = find_flag(alert_form, DEFAULT);
	else if (keycode == 0x6100)   				/* UNDO */
		f = find_cancel_button(alert_form);

	if (    f >= ALERT_BUT1			/* Is f a valid button? */
		and f <  ALERT_BUT1 + 3
		and !(alert_form[f].ob_flags & HIDETREE)
		)
	{
		/* HR 210501: Really must do this BEFORE unblocking!!! */
		close_window(lock, wind);
		delete_window(lock, wind);

		if (wt->owner != C.Aes)
		{
		/* HR static pid array */
			XA_CLIENT *client = wt->owner;
			client->waiting_pb->intout[0] = f - ALERT_BUT1 + 1;
				/* Write success to clients reply pipe to unblock the process */
			Unblock(client, XA_OK, 11);
		}
	}

	return false;			/* Always discontinue */
}

/*
 * Returns the object number of this object's parent or -1 if it is the root
 */
#if 0
int GetParent(OBJECT *t, int object)
{
	int last;
	
	if (object == 0)
		return -1;
	else
	{
		do
		{
			last = object;
			object = t[object].ob_next;
		} while(t[object].ob_tail != last);
		return object;
	}
}
#else
#define GetParent get_parent
#endif

/*
 * Sets one of a group of radio buttons, and clears the rest.
 * Includes patch to allow for pop_icons as radio buttons.
 */
static
void Radio_b(LOCK lock, XA_TREE *odc_p, int object)
{
	OBJECT *d = odc_p->tree;
	int parent, o;

	if ((parent = GetParent(d, object)) == -1)
		return;		/* Only reasonable thing to do */

	o = d[parent].ob_head;
	
	while (o != parent)
	{
		if ((d[o].ob_flags & RBUTTON) and (d[o].ob_state & SELECTED))
		{
			d[o].ob_state &= ~SELECTED;
			redraw_object(lock, odc_p, o);
		}
		
		o = d[o].ob_next;
	}
	
	d[object].ob_state |= SELECTED;
	redraw_object(lock, odc_p,object);
}


static
bool do_form_button(LOCK lock,
					XA_TREE *wt,
					OBJECT *form, int f, int *item,
					int dbl,
					G_i click_x, G_i click_y, int click_s)
{
	int is,os;
	bool go_exit = false;

	/* find_object can't report click on a HIDETREE object. */
	/* HR: Unfortunately it could. Fixed that. */

	/* Was click on a valid touchable object? */
	if (    (form[f].ob_state & DISABLED) == 0
		and (form[f].ob_flags & (EDITABLE | SELECTABLE | EXIT | TOUCHEXIT)) != 0
		)
	{
		if ((form[f].ob_type&0xff) == G_SLIST)
		{
			MOOSE_DATA md;
			md.x = click_x;
			md.y = click_y;
			md.clicks = dbl ? 2 : 1;
			md.state = click_s;

			if (dbl)
				dclick_scroll_list(lock, form, f, &md);
			else
				click_scroll_list(lock, form, f, &md);
		}
		else
		{
			if ((form[f].ob_flags & EDITABLE) and (f != wt->edit_obj))
			{	/* Select a new editable text field? */
				TEDINFO *txt = get_ob_spec(&form[f])->tedinfo;
				int o = wt->edit_obj;
				wt->edit_obj = f;
				if (o >= 0)
					redraw_object(lock, wt, o);
				wt->edit_pos = strlen(txt->te_ptext);
				redraw_object(lock, wt, f);
			}
	
			os = form[f].ob_state;
			is = os ^ SELECTED;
	
		 	if (form[f].ob_flags & TOUCHEXIT)		/* Touch Exit button? */
		 	{
				if (form[f].ob_flags & RBUTTON)
					/* Was click on a radio button? */
					Radio_b(lock, wt, f);
				else if (form[f].ob_flags & SELECTABLE)
				{
					form[f].ob_state = is;
					redraw_object(lock, wt, f);
				}
				go_exit = true;
	
	/*
	 * How should an EXIT but not SELECTABLE be handled?
	 */
			}
			else if (form[f].ob_flags & SELECTABLE)	/* Selectable object? */
			{
	/*
	 * Should this perhaps be done in watch_object?
	 */
	 			form[f].ob_state = is;
	 			redraw_object(lock, wt, f);
		
				if (watch_object(lock, wt, f, is, os))
				{
					if (form[f].ob_flags & RBUTTON)		/* Was click on a radio button? */
						Radio_b(lock, wt, f);
						
					if (    (form[f].ob_flags & EXIT)		/* Exit button? */
						and (is               & SELECTED)	/* and changed to selected. */
						)
						go_exit = true;
				}
			}
		}
		if (item)
			*item = is;
	}

	return go_exit;
}

/* HR 060201: Made modular, hence complete and correct. */

AES_function XA_form_button	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_TREE *wt;
	OBJECT *tree = pb->addrin[0], *ob;
	int f = pb->intin[0], dbl;
	bool exit;

	CONTROL(2,2,1)

DIAG((D_form,client,"XA_form_button %lx: obj:%d, clks:%d\n", tree, f, pb->intin[1]));

	wt = check_widget_tree(lock, client, tree);		/* HR 200201 */

	ob = tree + f;

	dbl = ( (ob->ob_flags&TOUCHEXIT) and pb->intin[1] == 2)	/* double click */
		  ? 0x8000
		  : 0;

	exit = do_form_button(
						lock,
						wt,
						tree,
						f,
						nil,
						dbl,
						0, 0, 0);

	pb->intout[0] = exit ? 0 : 1;
	pb->intout[1] = f | dbl;							/* After any progdef drawing induced by do_form_button */

	if (   (    !(ob->ob_flags & EDITABLE)
		    and !exit								/* HR 120201 Only if not EXIT|TOUCHEXIT!! */
		   )										/*           I had to find this out, its not described anywhere. */
		or  (ob->ob_flags & HIDETREE)
		or  (ob->ob_state & DISABLED)
		)
		pb->intout[1] = 0;

DIAG((D_form,client,"form_button done: c:%d, f:%d, o:%d, dbl? 0x%x\n", pb->intout[0], f, pb->intout[1]&0x7fff, pb->intout[1]));
	return XAC_DONE;
}

/*
 * (xa_)windowed form_do() (double) click handler
 */

global
WidgetBehaviour click_object_widget	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	int f,is, dbl = widg->clicks > 1 ? 0x8000 : 0;
	XA_TREE *wt = widg->stuff;
	OBJECT *form;
	RECT r;

	if (window_list != wind)
	{
		C.focus = pull_wind_to_top(lock, wind);			/* HR */
		after_top(lock, false);
		display_window(lock, 52, wind, nil);
		return false;
	}

/* HR: for after moving: adjusts form's x & y */
/* Convert relative coords and window location to absolute screen location */
	form = rp_2_ap(wind, widg, &r);

	f = find_object(form, 0, 10, r.x + widg->x, r.y + widg->y, wt->dx, wt->dy);
DIAG((D_button,wind->owner,"%sclick_object %d,%d on %d\n", dbl ? "dbl_" : "", r.x + widg->x, r.y + widg->y, f));

	if (do_form_button(lock, wt, form, f, &is, dbl, r.x + widg->x, r.y + widg->y, widg->s))
	{
		via (wt->exit_form)(lock, wind, widg, wt, f, is, dbl, MU_BUTTON, nil);		/* is: new state. */	/* HR 250602 via */
	}
	return false;
}

/*
 * classic (blocked) form_do() (double) click handler
 */

global
ClassicClick click_form_do	/* LOCK lock, XA_CLIENT *client, MOOSE_DATA *md */
{
	int f,is, dbl = md->clicks > 1 ? 0x8000 : 0;
	XA_TREE *wt = &client->wt;
	OBJECT *form = wt->tree;

/* HR: for after moving: adjusts form's x & y */
/* Convert relative coords and window location to absolute screen location */

	f = find_object(form, 0, 10, md->x, md->y, 0, 0);
DIAG((D_button,client,"%sclick_form_do %d,%d on %d\n", dbl ? "dbl_" : "", md->x, md->y, f));

	if (f < 0)
		ping;
	else
	{
		if (do_form_button(lock, wt, form, f, &is, dbl, md->x, md->y, md->state))
			via (wt->exit_form)(lock, nil, nil, wt, f, is, dbl, MU_BUTTON, nil);		/* is: new state. */	/* HR 250602 via */
	}
}

static
TASK woken_active_widget		/* HR 230601: big simplification by constructing function do_active_widget() */
{						/*            This eliminates redrawing of the sliders when the mouse isnt moved. */
	C.active_timeout.timeout = 0;
	do_active_widget(tab->lock, tab->client);		/* HR 230601 see also pending_msgs */
}

global
void set_button_timer(LOCK lock, XA_WINDOW *wind)
{
	Tab *t = &C.active_timeout;
	MENU_TASK *k = &t->task_data.menu;
	vq_mouse(C.vh,&k->exit_mb,&k->x,&k->y);
	if (k->exit_mb)						/* still down? */
	{
		t->timeout = 50;
		t->wind = wind;
		t->client = wind->owner;			/* HR 090801 :-) */
		t->task = woken_active_widget;
		t->lock = lock;
	}
}

/*
 * HR: Direct display of the toolbar widget; HR 260102: over the rectangle list.
 */
global
void display_toolbar(LOCK lock, XA_WINDOW *wind, int item)
{
	XA_WIDGET *widg = get_widget(wind, XAW_TOOLBAR);
	XA_RECT_LIST *rl;

	hidem();
	widg->start = item;

	rl = rect_get_system_first(wind);
	while(rl)
	{			
		set_clip(&rl->r);
		widg->display(lock, wind, widg);
		rl = rect_get_system_next(wind);
	}

	clear_clip();
	showm();
	widg->start = wind->winitem;
}
 
SendMessage handle_form_window
/* (LOCK lock,
	struct xa_window *w,
	struct xa_client *to,
	G_i mp0, G_i mp1, G_i mp2, G_i mp3,
	G_i mp4, G_i mp5, G_i mp6, G_i mp7)  */
{
	XA_WIDGET *widg = wind->tool;
	bool draw = false;

	if (widg)
	{
		XA_TREE *wt = widg->stuff;
		OBJECT *ob = wt->tree + widg->start;
		int   ww = wind->wa.w,			/* window measures */
		      wh = wind->wa.h,
		      dx = wt->dx,			/* object displacement */
		      dy = wt->dy,
		      ow = ob->r.w,			/* object measures */
		      oh = ob->r.h;
#if 0
		int   wd = ow - ww,			/* space ouside workarea */
		      hd = oh - wh;
#endif
		switch (mp0)
		{
		case WM_ARROWED:
			if (mp4 < WA_LFPAGE)
			{
				if (wh < oh)
				{
					switch (mp4)
					{
					case WA_UPLINE:
						dy -= screen.c_max_h;
					break;
					case WA_DNLINE:
						dy += screen.c_max_h;
					break;
					case WA_UPPAGE:
						dy -= oh - screen.c_max_h;
					break;
					case WA_DNPAGE:
						dy += oh - screen.c_max_h;
					}
/* align ( not that object height is always >= work area height) */
					if (dy < 0)
						dy = 0;
					if (dy > oh - wh)		
						dy = oh - wh;
				}
			} else
			{
				if (ww < ow)
				{
					switch (mp4)
					{
					case WA_LFLINE:
						dx -= screen.c_max_w;
					break;
					case WA_RTLINE:
						dx += screen.c_max_w;
					break;
					case WA_LFPAGE:
						dx -= ow - screen.c_max_w;
					break;
					case WA_RTPAGE:
						dx += ow - screen.c_max_w;
					}
					if (dx < 0)
						dx = 0;
					if (dx > ow - ww)		/* align */
						dx = ow - ww;
				}
			}
		break;
		case WM_VSLID:
			if (wh < oh)
				dy = sl_to_pix(oh - wh, mp4);
		break;
		case WM_HSLID:
			if (ww < ow)
				dx = sl_to_pix(ow - ww, mp4);
		break;
#if 0
		case WM_SIZED:
/*			if (!wind->nolist and (wind->active_widgets&SIZE))
*/			{
				move_window(lock, wind, -1, mp4, mp5, mp6, mp7);
				ww = wind->wa.w,		/* window measures */
				wh = wind->wa.h,
				wd = ow - ww,			/* space ouside workarea */
				hd = oh - wh;
				if (dx > ow - ww)		/* align */
					dx = ow - ww;
				if (dy > oh - wh)		
					dy = oh - wh;
				XA_slider(wind, XAW_HSLIDE, ow, ww, dx);
				XA_slider(wind, XAW_VSLIDE, oh, wh, dy);
				draw = true;
			}
		break;
#endif
		default:
			return;
		}

		if (dx != wt->dx)
		{
			draw = true;
			XA_slider(wind, XAW_HSLIDE, ow, ww, dx);
		}

		if (dy != wt->dy)
		{
			draw = true;
			XA_slider(wind, XAW_VSLIDE, oh, wh, dy);
		}

		if (draw)
		{
			wt->dx = dx;
			wt->dy = dy;
			display_window(lock, 120, wind, nil);
		}

		set_button_timer(lock, wind);
	}
}
