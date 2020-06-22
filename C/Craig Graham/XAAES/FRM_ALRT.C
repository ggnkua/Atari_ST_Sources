/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <VDI.H>
#include <OSBIND.H>
#include <stdio.h>
#include <stdlib.h>
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
#include "system.h"
#include "watchbox.h"
#include "frm_util.h"

/*
	Form_alert handler v2.1
*/
short click_alert_widget(XA_WINDOW *wind, XA_WIDGET *widg);

short do_form_alert(short default_button, char *alert, short owner)
{
	XA_WINDOW *alert_window;
	XA_WIDGET_LOCATION dialog_toolbar_loc={LT,3,20};
	short x,y,w,h=0,n_lines=0,n_buttons=0,icon,max_w=0,m_butt_w=0;
	short ty,th,b;
	short f,pnt[10];
	char alert_text[5][100];	/* texts to display in the alert */
	char button_text[3][20];	/* text for buttons */
	short button_w[3];
	char *t;
	OBJECT *alert_form;
	OBJECT *alert_icons;

	for(ty=0; ty<5; ty++) alert_text[ty][0]='\0';
	
	if (alert[0]!='[') return 0;
	t=alert+1;
	for(f=1; (t[f]!=']')&&(t[f]!='\0'); f++);	/* Search for closing bracket on first field */
	if (t[f]!=']') return 0;

	t[f]='\0';
	icon=atoi(t);				/* calculate the icon */
	
	t+=f+1;
	if (t[0]!='[') return 0;
	
	t++;
	for(f=0; (t[f]!=']')&&(t[f]!='\0');f++)		/* Strip out the text lines */
	{
		if (t[f]=='|')
		{
			t[f]='\0';
			vqt_extent(V_handle,t,pnt);
			w=pnt[2]-pnt[0];
			th=pnt[7]-pnt[1];
			h+=th;
			if (w>max_w) max_w=w;
			sprintf(alert_text[n_lines],"%s",t);
			n_lines++;
			t+=f+1; f=0;
		}
	}
	if (t[f]!=']') return 0;
	t[f]='\0';
	vqt_extent(V_handle,t,pnt);
	w=pnt[2]-pnt[0];
	th=pnt[7]-pnt[1];
	h+=th;
	if (w>max_w) max_w=w;
	sprintf(alert_text[n_lines],"%s",t);
	n_lines++;

	t+=f+1;
	if (t[0]!='[') return 0;
	t++;

	for(f=0; (t[f]!=']')&&(t[f]!='\0');f++)		/* Strip out the text lines */
	{
		if (t[f]=='|')
		{
			t[f]='\0';
			vqt_extent(V_handle,t,pnt);
			button_w[n_buttons]=pnt[2]-pnt[0]+3*display.c_max_w;
			m_butt_w+=button_w[n_buttons];
			sprintf(button_text[n_buttons],"%s",t);
			n_buttons++;
			t+=f+1; f=0;
		}
	}
	if (t[f]!=']') return 0;
	t[f]='\0';
	vqt_extent(V_handle,t,pnt);
	button_w[n_buttons]=pnt[2]-pnt[0]+3*display.c_max_w;
	m_butt_w+=button_w[n_buttons];
	sprintf(button_text[n_buttons],"%s",t);
	n_buttons++;
	
	if (m_butt_w>max_w) max_w=m_butt_w;
	
	w=max_w + 50;
	
	h+=5*th;
	x=(display.w-w)/2;
	y=(display.h-h)/2;

/* Create a copy of the alert box template */
	alert_form=CloneForm(ResourceTree(system_resources,ALERT_BOX));
	alert_icons=ResourceTree(system_resources,ALERT_ICONS);
	alert_form->ob_width=w;
	alert_form->ob_x=x;
	alert_form->ob_y=y;

	if ( display.colours<16 )			/* hmm... perhaps this should be done in */
	{									/* "color mode" too? <mk> */
		long obspec=(long)alert_form->ob_spec;
		obspec &= ~0xfL ;
		obspec |= (display.dial_colours.bg_col & 0xf);	/* interior color */
		alert_form->ob_spec = (void*)obspec;
	}

	for(f=ALR_IC_DRIVE; f<=ALR_IC_BOMB; f++)
	{
		((ICONBLK*)(alert_icons+f)->ob_spec)->ib_xicon=((ICONBLK*)(alert_form+ALERT_D_ICON)->ob_spec)->ib_xicon;
		((ICONBLK*)(alert_icons+f)->ob_spec)->ib_yicon=((ICONBLK*)(alert_form+ALERT_D_ICON)->ob_spec)->ib_yicon;
	}
	
	switch(icon)	/* Setup the correct icon for this alert */
	{
		case 1:
			(ICONBLK*)(alert_form+ALERT_D_ICON)->ob_spec=(ICONBLK*)(alert_icons+ALR_IC_WARNING)->ob_spec;
			break;
		case 2:
			(ICONBLK*)(alert_form+ALERT_D_ICON)->ob_spec=(ICONBLK*)(alert_icons+ALR_IC_QUESTION)->ob_spec;
			break;
		case 3:
			(ICONBLK*)(alert_form+ALERT_D_ICON)->ob_spec=(ICONBLK*)(alert_icons+ALR_IC_STOP)->ob_spec;
			break;
		case 4:
			(ICONBLK*)(alert_form+ALERT_D_ICON)->ob_spec=(ICONBLK*)(alert_icons+ALR_IC_INFO)->ob_spec;
			break;
		case 5:
			(ICONBLK*)(alert_form+ALERT_D_ICON)->ob_spec=(ICONBLK*)(alert_icons+ALR_IC_DRIVE)->ob_spec;
			break;
		case 6:
			(ICONBLK*)(alert_form+ALERT_D_ICON)->ob_spec=(ICONBLK*)(alert_icons+ALR_IC_BOMB)->ob_spec;
			break;
		case 0:
		default:
			(ICONBLK*)(alert_form+ALERT_D_ICON)->ob_spec=(ICONBLK*)(alert_icons+ALR_IC_SYSTEM)->ob_spec;
			break;
	}
	
	for(f=0; f<5; f++)				/* Fill in texts */
		sprintf(((TEDINFO*)alert_form[ALERT_T1+f].ob_spec)->te_ptext,"%s",alert_text[f]);
	
	x=w-m_butt_w; 					/* space the buttons evenly */
	b=x/(n_buttons+1);	
	x=b;
	
	for(f=0; f<n_buttons; f++)		/* Fill in & show buttons */
	{
		if ( display.colours<16 )
		{
			/* Make sure we can *READ* the button text: */
			alert_form[ALERT_BUT1+f].ob_flags &= ~FLD3DANY ;	/* clear 3D flags */
			/* (this is just a stopgag measure - apparently the 3D button code
				isn't quite mono-compatible yet...) */
		}
		sprintf((char*)alert_form[ALERT_BUT1+f].ob_spec,"%s",button_text[f]);
		alert_form[ALERT_BUT1+f].ob_width=button_w[f];
		alert_form[ALERT_BUT1+f].ob_x=x;
		alert_form[ALERT_BUT1+f].ob_flags&=~(HIDETREE|DEFAULT);
		alert_form[ALERT_BUT1+f].ob_state=0;
		x+=button_w[f]+b;
	}
	
	if (default_button)				/* Set the default button if it was specified */
		alert_form[ALERT_BUT1+default_button-1].ob_flags|=DEFAULT;
	
	for(f=n_buttons; f<3; f++)		/* Hide unused buttons */
		alert_form[ALERT_BUT1+f].ob_flags|=HIDETREE;

/* Create a window and attach the alert object tree to it */
	alert_window=create_window(owner, NAME|MOVE|STORE_BACK|NO_WORK, alert_form->ob_x, alert_form->ob_y, 
									alert_form->ob_width+10, display.c_max_h+16+alert_form->ob_height);

	dialog_toolbar_loc.y=display.c_max_h+10;
	set_toolbar_widget(alert_window, dialog_toolbar_loc, alert_form);
	
/* Change the click & drag behaviours for the alert box widget, because alerts return a number */
/* 1 to 3, not an object index. */
	alert_window->widgets[XAW_TOOLBAR].behaviour[XACB_CLICK]=&click_alert_widget;
	alert_window->widgets[XAW_TOOLBAR].behaviour[XACB_DRAG]=&click_alert_widget;
	((XA_WIDGET_TREE*)alert_window->widgets[XAW_TOOLBAR].stuff)->owner=owner;
	
	alert_window->active_widgets|=NO_REDRAWS;	/* We don't want any redraw messages  */
											/* - the widget handler will take care of it */
	alert_window->is_open=TRUE;

/* Set the window title to be the clients name to avoid confusion */
	alert_window->widgets[XAW_TITLE].stuff=(void*)clients[owner].name;
	
	v_hide_c(V_handle);
	pull_wind_to_top(alert_window);
	display_window(alert_window);
	v_show_c(V_handle,1);
	
	return 0;
}

/*
	Small handler for clicks on an alert box
*/
short click_alert_widget(XA_WINDOW *wind, XA_WIDGET *widg)
{
	short x,y,sel_b=-1,f,b;
	unsigned long retv=XA_OK;
	XA_WIDGET_TREE *wt=(XA_WIDGET_TREE*)widg->stuff;
	OBJECT *alert_form;

	if (window_list!=wind)			/* You can only work alerts when they are on top */
		return FALSE;

	alert_form=wt->tree;

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */

	f=find_object(alert_form, 0, 10, x+widg->click_x, y+widg->click_y);

	if (((f>=ALERT_BUT1)			/* Did we click on a valid button? */
		&&(f<ALERT_BUT1+3))
		&&(!(alert_form[f].ob_flags&HIDETREE)))
	{
		clear_clip();
	
		b=watch_object(alert_form, f, SELECTED, 0);
	
		if (b)
			sel_b=f+1-ALERT_BUT1;
	
		if (sel_b>-1)					/* If the click was definite, we return the button & close the window */
		{
			clients[wt->owner].waiting_pb->intout[0]=sel_b;
			Fwrite(clients[wt->owner].clnt_pipe_wr, (long)sizeof(unsigned long),&retv);	/* Write success to clients reply pipe to unblock the process */

			v_hide_c(V_handle);
			display_windows_below(wind);
			v_show_c(V_handle,1);

			wind->is_open=FALSE;

			delete_window(wind);
			
			DeleteClone(alert_form);	/* Delete this copy of the alert form */
		}
	}
	
	return FALSE;
}
