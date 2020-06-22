/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "K_DEFS.H"
#include "OBJECTS.H"
#include "FRM_ALRT.H"
#include "STD_WIDG.H"
#include "C_WINDOW.H"
#include "SYSTEM.H"
#include "RESOURCE.H"

/*
	XaAES About Box
*/

void open_about(void)
{
	XA_WINDOW *dialog_window;
	OBJECT *form=ResourceTree(system_resources,ABOUT_XAAES);
	XA_WIDGET_LOCATION dialog_toolbar_loc={LT,3,20};
	short x,y,w,h;
	
	form->ob_x=(display.w-form->ob_width)/2;
	form->ob_y=(display.h-form->ob_height)/2;
	
/* Create a temporary window to work out sizing */
	dialog_window=create_window(AESpid, CLOSE|NAME|MOVE, form->ob_x, form->ob_y, form->ob_width, form->ob_height);

	x=2*dialog_window->x - dialog_window->wx;
	y=2*dialog_window->y - dialog_window->wy;
	w=2*dialog_window->w - dialog_window->ww +1;
	h=2*dialog_window->h - dialog_window->wh +1;

/* Dispose of the temporary window we created */
	delete_window(dialog_window);

/* Now create the real window */
	dialog_window=create_window(AESpid, CLOSE|NAME|MOVE|NO_MESSAGES, x, y, w, h);

	dialog_window->created_by_FMD_START=FALSE;

/* Set the window title */
	dialog_window->widgets[XAW_TITLE].stuff="About XaAES....";

/* Set version date */
	((TEDINFO*)(form+ABOUT_DATE)->ob_spec)->te_ptext=__DATE__;
	
	dialog_toolbar_loc.y=display.c_max_h+10;
	set_toolbar_widget(dialog_window, dialog_toolbar_loc, form);
	
	((XA_WIDGET_TREE*)dialog_window->widgets[XAW_TOOLBAR].stuff)->owner=AESpid;

	dialog_window->widgets[XAW_TOOLBAR].behaviour[XACB_DCLICK]=NULL;
	dialog_window->widgets[XAW_TOOLBAR].behaviour[XACB_CLICK]=NULL;
	dialog_window->widgets[XAW_TOOLBAR].behaviour[XACB_DRAG]=NULL;
	
	dialog_window->active_widgets|=(NO_MESSAGES|MOVE);	/* We don't want any redraw messages 
															- the widget handler will take care of it */
	dialog_window->is_open=TRUE;

	v_hide_c(V_handle);
	pull_wind_to_top(dialog_window);
	display_window(dialog_window);
	v_show_c(V_handle,1);
}
