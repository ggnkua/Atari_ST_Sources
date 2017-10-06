/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <osbind.h>
#include <string.h>
#include <stdlib.h>
#include "ctype.h"			/* We use the version without macros!! */

#include "xa_types.h"
#include "xa_globl.h"
#include "xa_nkcc.h"
#include "xa_form.h"

#include "objects.h"
#include "c_window.h"
#include RSCHNAME
#include "widgets.h"
#include "xa_graf.h"
#include "xa_rsrc.h"
#include "scrlobjc.h"

/*
 *	FORM HANDLERS INTERFACE
 */


global
void center_form(OBJECT *form, short barsizes)
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
	short num_objs = 0, o;
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
	DIAG((D.form,-1,"alert_destructor\n"));
	remove_widget(lock, wind, XAW_TOOLBAR);
	return true;
}

/*
 * Small handler for clicks on an alert box
 */
static
WidgetBehaviour click_alert_widget	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	short sel_b = -1, f, b;
	RECT r;
	XA_TREE *wt = widg->stuff;
	OBJECT *alert_form;
	
/*	if (window_list != wind)			/* You can only work alerts when they are on top */
		return false;
*/
	if (window_list != wind)			/* HR 220501 */
	{
		C.focus = pull_wind_to_top(lock, wind);			/* HR */
		after_top(lock, false);
		display_non_topped_window(lock, 520, wind, nil);
		return false;
	}

	alert_form = wt->tree;

	rp_2_ap(wind, widg, &r);	/* Convert relative coords and window location to absolute screen location */

	f = find_object(alert_form, 0, 10, r.x + widg->click_x, r.y + widg->click_y);

	if (    f >= ALERT_BUT1			/* Did we click on a valid button? */
		and f <  ALERT_BUT1 + ALERT_BUTTONS
		and !(alert_form[f].ob_flags & HIDETREE)
		)
	{
/*		clear_clip();
*/	
		b = watch_object(lock, wt, f, SELECTED, 0);

		if (b)
			sel_b = f + 1 - ALERT_BUT1;

		if (sel_b > -1)
		{
			/* HR 210501: Really must do this BEFORE unblocking!!! */
			close_window(lock, wind);		
			delete_window(lock, wind);

			if (wt->pid != C.AESpid)
			{
				XA_CLIENT *client = Pid2Client(wt->pid);
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
short get_parts(short m, char to[][MAX_X+1], short *retv)
{
	short n = 0;
	while (n < m)
	{
		short s = lstr(to[n++],'|]');		/* delimited string, no translation */
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
short max_w(short m, char to[][MAX_X+1], short *tot)
{
	short n = 0, x = 2, t = 0;
	while (n < m)
	{
		short l = strlen(to[n]);
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
*/
global
short do_form_alert(LOCK lock, short default_button, char *alert, short owner)
{
	WindowKeypress key_alert_widget;
	XA_WINDOW *alert_window;
	XA_TREE *wt;
	OBJECT *alert_form,
	       *alert_icons;
	ALERTXT *alertxt;
	short x, y, w, h, n_lines, n_buttons, icon = 0, m_butt_w,
	      retv = 1, b, f;

	DIAG((D.form,owner,"called do_form_alert(%s)\n",alert));

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
		short icons[7] = {ALR_IC_SYSTEM, ALR_IC_WARNING, ALR_IC_QUESTION, ALR_IC_STOP,
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
		short w = strlen(alertxt->button[f])+3;
		w *= screen.c_max_w;
		alert_form[ALERT_BUT1 + f].ob_spec.string = alertxt->button[f];		/* HR 210501 */
		alert_form[ALERT_BUT1 + f].r.w = w;
		alert_form[ALERT_BUT1 + f].r.x = x;
		alert_form[ALERT_BUT1 + f].ob_flags &= ~(HIDETREE|DEFAULT);
		alert_form[ALERT_BUT1 + f].ob_state = 0;
		x += w + b;
	}

/* HR 100801: Verbeterde bladspiegel van alerts. */
	if (n_lines > 2)
	{
		short dh = (ALERT_LINES - n_lines)*screen.c_max_h;
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
		calc_window(owner, WC_BORDER, NAME, &alert_form->r, &r);		/* HR */
		alert_window = create_window(lock, nil, owner, false,
							NAME|MOVE|STORE_BACK|NO_WORK, MG,
							r,nil,nil);
	}

	wt = set_toolbar_widget(lock, alert_window, alert_form, -1);
	wt->extra = alertxt;
	wt->pid = owner;
	
/* Change the click & drag behaviours for the alert box widget, because alerts return a number */
/* 1 to 3, not an object index. */
/* HR: we also need a keypress handler for the default button (if there) */
	alert_window->keypress = key_alert_widget;
	alert_window->widgets[XAW_TOOLBAR].behaviour[XACB_CLICK] = click_alert_widget;
	alert_window->widgets[XAW_TOOLBAR].behaviour[XACB_DRAG] = click_alert_widget;
	
	alert_window->active_widgets |= NO_REDRAWS;	/* We don't want any redraw messages  */
											/* - The widget handler will take care of it */
/* Set the window title to be the client's name to avoid confusion */
	alert_window->widgets[XAW_TITLE].stuff = Pid2Client(owner)->name;	 /* HR */
	alert_window->destructor = alert_destructor;						/* HR 210501 */
	open_window(lock, owner, alert_window->handle, alert_window->r);
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
	short *o = pb->intout;

	CONTROL(0,5,1)

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
 			adjust_size(3, &r);				/* HR 290301:  */

		*o++ = 1;
		*(RECT *)o = r;

		DIAG((D.form,client->pid,"form_center ob=%lx :: %d/%d,%d/%d\n",ob,r));
	}

	return XAC_DONE;
}

global
short find_flag(OBJECT *ob, short flag)
{
	short f = 0;
	do
		if (ob[f].ob_flags & flag)
			return f;
	while ( ! (ob[f++].ob_flags & LASTOB));	/* HR: Check LASTOB before incrementing */
	return -1;
}

static
short find_cancel_button(OBJECT *ob)
{
	short f = 0;
	do
	{
		if (    (ob[f].ob_type & 0xff) == G_BUTTON
			and (ob[f].ob_flags & (SELECTABLE|TOUCHEXIT|EXIT)) != 0  )
		{
			short l;
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
					short i = 0;
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
short form_cursor(LOCK lock, XA_TREE *wt, unsigned short keycode, short obj)
{
#define editable (form[o].ob_flags & EDITABLE)

	OBJECT *form = wt->tree;
	short o = obj, ed = 0,
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
			short last = strlen(ted->te_ptext);
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
short find_shortcut(OBJECT *tree, unsigned short nk)
{
	short i = 0;
	nk&=0xff;
DIAG((D.keybd,-1,"find_shortcut: %d(0x%x), '%c'\n", nk, nk, nk));
	do
	{
		OBJECT *ob = tree + i;
		if (ob->ob_state&WHITEBAK)
		{
			short ty = ob->ob_type&0xff;
			if (ty == G_BUTTON or ty == G_STRING)
			{
				short j = (ob->ob_state>>8)&0x7f;
				if (j < 126)
				{
					char *s = get_ob_spec(ob)->string;
					if (s)
					{
						DIAG((D.keybd,-1,"  -  in '%s' find '%c' on %d\n",s,nk,j));
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
	XA_TREE *wt = &client->wt;
	OBJECT *form = pb->addrin[0];
	short obj = pb->intin[0],
	      keycode = pb->intin[1],
	      *op = pb->intout,
	      o;

	CONTROL(3,3,1)

	check_widget_tree(client, form);		/* HR 200201 */
DIAG((D.keybd,client->pid,"XA_form_keybd for %s(%d) %lx: obj:%d, k:%x, nob:%d\n",
			client->name, client->pid, form, obj, keycode, pb->intin[2]));

/* HR: removed spurious, and wrong check on EDITABLE which caused exit,
       and assign to a TEDINFO, which after all was not used.
*/
	o = form_cursor(lock, wt, keycode, obj);	/* HR: More duplicate code removed */

	if (o >= 0)		/* A cursor operation. */
	{
DIAG((D.keybd,client->pid,"XA_form_keybd: nxt_obj=%d, cursor operation\n", o));
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
			short state;
			vq_key_s(C.vh, &state);
			if ((state&(K_CTRL|K_ALT)) == K_ALT)
			{
				unsigned short nkcode = normkey(state, keycode);
				o = find_shortcut(form, nkcode);
				if (o >= 0)
				{
DIAG((D.keybd,client->pid,"XA_form_keybd: nxt_obj=%d, shortcut\n", o));
					if (form_button(lock, wt, form, o, nil, 0, 0, 0) == 0)
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
DIAG((D.keybd,client->pid,"XA_form_keybd: nxt_obj=%d, return, cancel, or shortcut\n", o));
			*op++ = 0;			/* exit object. */
			*op++ = o;			/* nxt_obj */
			*op   = 0;			/* pchar */
			return XAC_DONE;
		}
		else			
		{		/* just a plain key - pass character */
DIAG((D.keybd,client->pid,"XA_form_keybd: nxt_obj=%d, passing character back to client\n", obj));
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
	
DIAG((D.form,client->pid,"XA_alert %s\n",(char *)pb->addrin[0]));
	do_form_alert(lock, pb->intin[0], (char *)pb->addrin[0], client->pid);

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

DIAG((D.form,client->pid,"alert_err %s",error_alert));
	do_form_alert(lock, 1, error_alert, client->pid);

	return XAC_BLOCK;
}

global
short has_default(OBJECT *ob)
{
	short f = 0;
	do
		if (ob[f].ob_flags & DEFAULT)
			return true;
	while ( ! (ob[f++].ob_flags & LASTOB));
	return false;
}

/*
 *  Begin/end form handler
 *  This is important - I hope most programs call this, as XaAES puts its dialogs
 *  in windows, and the windows are created here...
 */
AES_function XA_form_dial	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{	
	XA_WINDOW *wind;
	RECT r;

	CONTROL(9,1,0)

	switch(pb->intin[0])
	{
	case FMD_START: 
		/* Work out sizing */
		DIAG((D.form,client->pid,"form_dial(FMD_START,%d,%d,%d,%d)\n",
				pb->intin[5], pb->intin[6], pb->intin[7], pb->intin[8]));

		calc_window(client->pid, WC_BORDER, NAME, (RECT *)&pb->intin[5], &r);

/* And create the window. It stays fixed until form_do is called
   when it gets a MOVE property.
   We create a window owned by the client so it will get button clicks for this area
   (in case it's gonna handle things its own way)

   HR 060201: If the client forgot to FMD_FINISH, we dont create a new window, but
       simply move the window to the new coordinates.
*/
		if (client->zen)
		{
			wind = client->zen;
			DIAG((D.form,client->pid,"Already zen %d\n", wind->handle));
			move_window(lock, wind, -1, r.x, r.y, r.w, r.h);
		othw
#if NOTYET
			/* HR 220401: Dont do it if it wouldnt fit anymore. */
			if (r.w > root_window->wa.w or r.h > root_window->wa.h)
				break;
#endif
			client->zen = wind = create_window(lock, nil, client->pid, false,
#if PRESERVE_DIALOG_BGD
			STORE_BACK |
#endif
			NO_MESSAGES | NAME | NO_WORK, MG,
			r, nil, nil);
			DIAG((D.form,client->pid,"New zen %d\n", wind->handle));
		}
		wind->dial = created_by_FMD_START;
/* Set the window title to be the clients name to avoid confusion */
#if GENERATE_DIAGS
		{
			char nm[32];
			strip_name(nm, client->name);
			sdisplay(client->zen_name, "%s (form_dial)", nm);
			wind->widgets[XAW_TITLE].stuff = client->zen_name;
		}
#else
		wind->widgets[XAW_TITLE].stuff = client->name;		/* HR added NAME to the create's */
#endif
		open_window(lock, client->pid, wind->handle, wind->r);
		break;
	case FMD_GROW:
		break;
	case FMD_SHRINK:
		break;
	case FMD_FINISH:
		DIAG((D.form,client->pid,"form_dial(FMD_FINISH)\n"));
		if (client->zen)	/* If the client's dialog window is still hanging around, dispose of it... */
		{
			wind = client->zen;
		/*	clear_clip();
		*/	client->zen = nil;
			DIAG((D.form,client->pid,"Finish zen %d\n", wind->handle));
			close_window(lock, wind);
			delete_window(lock, wind);
		} else	/* This was just a redraw request */
			display_windows_below(lock, (RECT *)&pb->intin[5], window_list);		/* HR */

		break;
	}
	
	pb->intout[0] = 1;
	
	return XAC_DONE;
}

typedef ;

/*
 *	Form_do() click handler
 */
static
void exit_form(LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg, short f, short os, short dbl)
{
	XA_TREE *wt = widg->stuff;
	XA_CLIENT *client = wind->owner;
	OBJECT *form = wt->tree;

	if (wt->handler)
	{
		if (os != -1)
		{
			form[f].ob_state = os;
			redraw_object(lock, wt, f);
		}
		wt->tree = form;				/* HR After redraw of object. :-) */
		wt->item = f|dbl;				/* HR 300101: pass the double click to the internal handlers as well. */
		(*(wt->handler))(lock, wt);
	othw

	/* HR: 300101   The sign bit for double click is also a feature of form_do()
					 (obno = form_do(x,y)) < 0 ? double_click : single_click; */
		client->waiting_pb->intout[0] = f|dbl;
	
		DIAG((D.form,wind->pid,"exit_form: obno=%d\n", f));
	
			/* If form_do created this window, destroy it now,
			 - if it didnt, then we expect the app to call FMD_FINISH to delete the window */
		if (wind->dial&created_by_FORM_DO)
		{									
			client->zen = nil;
			close_window(lock, wind);
			delete_window(lock, wind);
		}
/* HR 120201: Because we are out of the form_do any form_do() handlers must be removed! */
		else
			remove_widget(lock, wind, XAW_TOOLBAR);
		/* Write success to clients reply pipe to unblock the process */
		Unblock(client, XA_OK, 8);
	}
}

global
WindowKeypress handle_form_key /* LOCK lock, XA_WINDOW *wind, unsigned short keycode, unsigned short nkcode, CONKEY raw */ /* HR */
{
	XA_WIDGET *widg = wind->widgets + XAW_TOOLBAR;
	XA_TREE *wt = widg->stuff;
	OBJECT *form;
	TEDINFO *ed_txt;
	RECT r;
	short o, ed_obj;

	DIAG((D.form,wind->pid,"handle_form_key\n"));

	form = wt->tree;
	ed_obj = wt->edit_obj;

DIAG((D.k,wind->pid,"got keypress in form\n"));

	o = form_cursor(lock, wt, keycode, ed_obj);	/* HR: More duplicate code removed */

	if (o < 0)
	{
		/* Return - select default (if any) */
		/* HR: Enter */

		if (keycode == 0x1c0d or keycode == 0x720d)
			o = find_flag(form, DEFAULT);
		else if (keycode == 0x6100)		/* UNDO */
			o = find_cancel_button(form);
		else if ((raw.conin.state&(K_CTRL|K_ALT)) == K_ALT)
		{
			if (nkcode == 0)
				nkcode = nkc_tconv(raw.bcon);
			o = find_shortcut(form, nkcode);
			if (o >= 0)
			{
				short ns;
				if (form_button(lock, wt, form, o, &ns, 0, 0, 0))
				{	
					exit_form(lock, wind, widg, o, ns, 0);
DIAG((D.form,wind->pid,"on shortcut exited; item %d\n", o));
					return false;
				}
				return true;
			}
		}

		if (o >= 0)
		{
			exit_form(lock, wind, widg, o, -1, 0);
DIAG((D.form,wind->pid,"handle_form_key exited\n"));
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
DIAG((D.form,wind->pid,"handle_form_key after ed_char\n"));
			}
		}
	}

	return true;
}

/*
 *	Non-blocking form_do
 *	- Uses an object tree widget in a window to implement the form handler.
 */
AES_function XA_form_do	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_WINDOW *wind;
	XA_TREE *wt;
	OBJECT *form = (OBJECT *)pb->addrin[0];
	RECT r;
	short startedit;
	
	CONTROL(1,1,1)

	DIAG((D.form,client->pid,"form_do()\n"));

	client->waiting_pb = pb;
	
	if (!client->zen)	/* If the client hasn't called FMD_START (naughty), create a window for the dialog */
	{
		/* Work out sizing */
		calc_window(client->pid, WC_BORDER, NAME, &form->r, &r);

		if (form->ob_state&OUTLINED)
			adjust_size(3, &r);
	
		/* Create the window */
		client->zen = wind = create_window(lock, nil, client->pid, false,
		NO_WORK | NO_MESSAGES | NAME
#if PRESERVE_DIALOG_BGD
		| STORE_BACK
#endif
		, MG, r, nil, nil);

		wind->dial = created_by_FORM_DO; 
		DIAG((D.form,client->pid,"Without zen %d\n", wind->handle));
	/* Set the window title to be the clients name to avoid confusion */
#if GENERATE_DIAGS
		sdisplay(client->zen_name, "%s (form_do)", client->name);
		wind->widgets[XAW_TITLE].stuff = client->zen_name;
#else
		wind->widgets[XAW_TITLE].stuff = client->name;
#endif
	} else
	{
		wind = client->zen;
		wind->pid = client->pid;
		wind->owner = client;
		DIAG((D.form,client->pid,"With zen %d\n", wind->handle));
		wind->active_widgets |= MOVE;		/* HR */
	}
	
	client->waiting_for = XAWAIT_DIALOG;	/* |XAWAIT_KEY */

	/* HR */
	wt = set_toolbar_widget(lock, wind, form, pb->intin[0]);
	wt->pid = client->pid;
	wt->zen = true;		/* This can be of use for drawing. (keep off border & outline :-) */
	/* HR 300301: after correcting form_center() the following was also needed. */
	if (form->ob_state&OUTLINED)
	{
		XA_WIDGET *widg = &wind->widgets[XAW_TOOLBAR];
		widg->loc.r.x += 3, widg->loc.r.y += 3;
	}

	if (wind->is_open)
	{
		DIAG((D.form,client->pid,"display_toolbar: wind: %d/%d, form: %d/%d\n", wind->r.x, wind->r.y, form->r.x, form->r.y));
		display_toolbar(lock, wind, 0);
	}
	else
	{
		DIAG((D.form,client->pid,"open_window: wind: %d/%d, form: %d/%d\n", wind->r.x, wind->r.y, form->r.x, form->r.y));
		open_window(lock, client->pid, wind->handle, wind->r);		/* HR 210201 */
	}

#if 0			/* This all is done in set_toolbar_widget() */
#include "obsolete/form_do.h"
#endif

	return XAC_BLOCK;
}

/*
 * HR:
 * Small handler for ENTER/RETURN/UNDO on an alert box
 */
static
WindowKeypress key_alert_widget /* LOCK lock, XA_WINDOW *wind, unsigned short keycode, unsigned short nkcode, CONKEY raw */
{
	XA_WIDGET *widg = (wind->widgets) + XAW_TOOLBAR;
	short f = 0;
	RECT r;
	XA_TREE *wt = widg->stuff;
	OBJECT *alert_form;
	
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
	/*	clear_clip();
	*/
		/* HR 210501: Really must do this BEFORE unblocking!!! */
		close_window(lock, wind);
		delete_window(lock, wind);

		if (wt->pid != C.AESpid)
		{
		/* HR static pid array */
			XA_CLIENT *client = Pid2Client(wt->pid);
			client->waiting_pb->intout[0] = f - ALERT_BUT1 + 1;
				/* Write success to clients reply pipe to unblock the process */
			Unblock(client, XA_OK, 9);
		}
	}

	return false;			/* Always discontinue */
}

/*
 * Returns the object number of this object's parent or -1 if it is the root
 */
#if 0
short GetParent(OBJECT *t, short object)
{
	short last;
	
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
void Radio_b(LOCK lock, XA_TREE *odc_p, short object)
{
	OBJECT *d = odc_p->tree;
	short parent, o;
	RECT r;

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
bool form_button(LOCK lock,
					XA_TREE *wt,
					OBJECT *form, short f, short *item,
					short dbl,
					short click_x, short click_y)
{
	short is,os;
	bool go_exit = false;

	/* find_object can't report click on a HIDETREE object. */
	/* HR: Unfortunately it could. Fixed that. */

	/* Was click on a valid touchable object? */
	if (    (form[f].ob_state & DISABLED) == 0
		and (form[f].ob_flags & (EDITABLE | SELECTABLE | EXIT | TOUCHEXIT)) != 0
		)
	{
		if ((form[f].ob_type&0xff) == G_SLIST)
			if (dbl)
				dclick_scroll_list(lock, form, f, click_x, click_y);
			else
				click_scroll_list(lock, form, f, click_x, click_y);
		else
		{
			if ((form[f].ob_flags & EDITABLE) and (f != wt->edit_obj))
			{	/* Select a new editable text field? */
				TEDINFO *txt = get_ob_spec(&form[f])->tedinfo;
				short o = wt->edit_obj;
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
#if 1
AES_function XA_form_button	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	OBJECT *tree = pb->addrin[0], *ob;
	short f = pb->intin[0], dbl;
	bool exit;

	CONTROL(2,2,1)

DIAG((D.form,client->pid,"form_button %lx: obj:%d, clks:%d\n", tree, f, pb->intin[1]));

	check_widget_tree(client, tree);		/* HR 200201 */

	ob = tree + f;
	pb->intout[1] = f;
	dbl = ( (ob->ob_flags&TOUCHEXIT) and pb->intin[1] == 2)	/* double click */
		  ? 0x8000
		  : 0;

	exit = form_button(	lock,
						&client->wt,
						tree,
						f,
						nil,
						dbl,
						0, 0);

	pb->intout[0] = exit ? 0 : 1;
	pb->intout[1] |= dbl;

	if (   (    !(ob->ob_flags & EDITABLE)
		    and !exit								/* HR 120201 Only if not EXIT|TOUCHEXIT!! */
		   )										/*           I had to find this out, its not described anywhere. */
		or  (ob->ob_flags & HIDETREE)
		or  (ob->ob_state & DISABLED)
		)
		pb->intout[1] = 0;

DIAG((D.form,client->pid,"form_button done: c:%d, o:%d, clicks? 0x%x\n", pb->intout[0], pb->intout[1]&0x7fff, pb->intout[1]));
	return XAC_DONE;
}
#else
#include "obsolete/form_but.h"
#endif

/*
 * Form_do() (double) click handler
 */

static
bool click_object(LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg, short dbl)
{
	short f,is;
	XA_TREE *wt = widg->stuff;
	OBJECT *form;
	RECT r;

	if (window_list != wind)
	{
		C.focus = pull_wind_to_top(lock, wind);			/* HR */
		after_top(lock, false);
		display_non_topped_window(lock, 52, wind, nil);
		return false;
	}

/* HR: for after moving: adjusts form's x & y */
/* Convert relative coords and window location to absolute screen location */
	form = rp_2_ap(wind, widg, &r);

	f = find_object(form, 0, 10, r.x + widg->click_x, r.y + widg->click_y);
DIAG((D.mouse,wind->pid,"%sclick_object %d,%d on %d\n", dbl ? "dbl_" : "", r.x + widg->click_x, r.y + widg->click_y, f));

	if (form_button(lock, wt, form, f, &is, dbl, r.x + widg->click_x, r.y + widg->click_y))
		exit_form(lock, wind, widg, f, is, dbl);		/* is: new state. */

	return false;
}

global
WidgetBehaviour click_object_widget	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	return click_object(lock, wind, widg, 0);
}

global
WidgetBehaviour dclick_object_widget	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	return click_object(lock, wind, widg, 0x8000);
}

/*
 * HR: Direct display of the toolbar widget
 */
global
void display_toolbar(LOCK lock, XA_WINDOW *wind, short item)
{
	XA_WIDGET *widg = &wind->widgets[XAW_TOOLBAR];
	hidem();
	widg->start = item;
	(*widg->behaviour[XACB_DISPLAY])(lock, wind, widg);
	showm();
	widg->start = wind->item;
}
