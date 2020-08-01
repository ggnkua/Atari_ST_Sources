/********************************************************************
 *																0.10*
 *	XAES: Help window routines										*
 *	By Ken Hollis													*
 *																	*
 *	Copyright (C) 1994, Bitgate Software							*
 *																	*
 *	Mark my words, these routines *WILL* be redesigned.				*
 *																	*
 ********************************************************************/

#include <stdio.h>

#include "xaes.h"

#define W_ULSIZE 1   /* BOX dans l'arbre WINDOW */
#define W_PCLOSE 2   /* BOX dans l'arbre WINDOW */
#define W_CLOSER 3   /* BOXTEXT dans l'arbre WINDOW */
#define W_TSIZE  4   /* BOX dans l'arbre WINDOW */
#define W_URSIZE 5   /* BOX dans l'arbre WINDOW */
#define W_PCASC  6   /* BOX dans l'arbre WINDOW */
#define W_FULLER 7   /* BOXTEXT dans l'arbre WINDOW */
#define W_LSIZE  8   /* BOX dans l'arbre WINDOW */
#define W_RSIZE  9   /* BOX dans l'arbre WINDOW */
#define W_LLSIZE 10  /* BOX dans l'arbre WINDOW */
#define W_PSLLT  11  /* BOX dans l'arbre WINDOW */
#define W_SLLT   12  /* BOXTEXT dans l'arbre WINDOW */
#define W_BSIZE  13  /* BOX dans l'arbre WINDOW */
#define W_LRSIZE 14  /* BOX dans l'arbre WINDOW */
#define W_PSLDN  15  /* BOX dans l'arbre WINDOW */
#define W_SLDN   16  /* BOXTEXT dans l'arbre WINDOW */
#define W_MOVER  17  /* BOXTEXT dans l'arbre WINDOW */
#define W_CASCADE 18  /* BOXTEXT dans l'arbre WINDOW */
#define W_MENU   19  /* BOX dans l'arbre WINDOW */
#define W_MENU_L 20  /* BOXTEXT dans l'arbre WINDOW */
#define W_MENU_R 21  /* BOXTEXT dans l'arbre WINDOW */
#define W_INFO   22  /* BOXTEXT dans l'arbre WINDOW */
#define W_INFO_R 23  /* BOXTEXT dans l'arbre WINDOW */
#define W_INFO_L 24  /* BOXTEXT dans l'arbre WINDOW */
#define WORKAREA 25  /* BOXTEXT dans l'arbre WINDOW */
#define W_SLUP   26  /* BOXTEXT dans l'arbre WINDOW */
#define W_VERTRK 27  /* BOX dans l'arbre WINDOW */
#define W_VERSL  28  /* BOX dans l'arbre WINDOW */
#define W_HORTRK 29  /* BOX dans l'arbre WINDOW */
#define W_HORSL  30  /* BOX dans l'arbre WINDOW */
#define W_SLRT   31  /* BOXTEXT dans l'arbre WINDOW */
#define W_OPTION 32  /* BOXTEXT dans l'arbre WINDOW */

#define HELPWIN  4   /* Formulaire/Dialogue */
#define HELPTITL 2   /* TEXT dans l'arbre HELPWIN */
#define HELPWORK 3   /* BOX dans l'arbre HELPWIN */
#define HELPOK   5   /* BOXTEXT dans l'arbre HELPWIN */

WHELP SIZE_HELP[] =
{
	"Window sizer help",
	"This gadget lets you resize the",
	"window. If the window has a",
	"minimum size, it will not let",
	"you resize it any smaller than",
	"its minimum.  You can resize the",
	"the window to the screen size",
	"regardless.", " " };

WHELP CLOSER_HELP[] =
{
	"Window closer help",
	"This gadget closes the window.",
	"If you hold down the button down",
	"on the gadget, a popup menu will",
	"appear with choices to close or",
	"iconify the window.", " ", " ", " " };

WHELP FULLER_HELP[] =
{
	"Window fuller help",
	"This gadget lets you bring the",
	"window up to its maximum size,",
	"or back to its original size.",
	"A popup also appears if you hold",
	"down the button, where you can",
	"minimize the window, bringing it",
	"down to its minimum stored size.", " " };

WHELP MOVESLIDE_HELP[] =
{
	"Window slider arrow help",
	"This moves the associated slider",
	"in the indicated direction.  If",
	"you hold the button down, it",
	"will move the slider rapidly.",
	"If you double click, it will",
	"move it to the extreme edge.", " ", " " };

WHELP MOVER_HELP[] =
{
	"Window title bar / mover help",
	"This lets you move the window",
	"to any position on the screen.",
	"The text within the mover is",
	"also the title of the window.",
	"If the window cannot be moved,",
	"the text will be grayed out.", " ", " " };

WHELP CASCADE_HELP[] =
{
	"Window cascader help",
	"This lets you switch between",
	"application windows on the desk.",
	"If you hold down the button, you",
	"can rotate windows, bring to",
	"front, set background bit, and",
	"change window settings.", " ", " " };

WHELP MENU_HELP[] =
{
	"Window menu bar help",
	"This allows you to scroll the",
	"window menu tree left or right.",
	" "," "," "," "," "," " };

WHELP INFO_HELP[] =
{
	"Window info bar help",
	"This allows you to scroll the",
	"window info bar left or right.",
    " "," "," "," "," "," " };

WHELP SLIDER_HELP[] =
{
	"Window slider help",
	"This allows you to scroll the",
	"contents of the window.",
	" "," "," "," "," "," " };

WHELP WORKAREA_HELP[] =
{
	"Window work area help",
	"This is the area of the window",
	"that is used by applications.",
	" "," "," "," "," "," " };

WHELP OPTION_HELP[] =
{
	"Window option help",
	"This button allows you to",
	"control the miscellaneous",
	"options for the window.",
	" "," "," "," "," " };

WHELP NOINFO_HELP[] =
{
	"No info available",
	"Sorry, no information is",
	"available on the object you",
	"selected.", " ", " ", " ", " ", " " };

WHELP OKAYBUT_HELP[] =
{
	"Help about help",
	"This button closes the window,",
	"and lets you get on with your",
	"normal business.", " ", " ", " ", " ", " " };

WHELP EDITABLE_HELP[] =
{
	"This is an editable text field.",
	"Insert switches insert/replace",
	"modes, you can click the mouse",
	"to move the cursor within the",
    "field, you can cut and paste",
    "using the ^X, ^C and ^V keys,",
    "and you can use the arrow keys",
    "in conjunction with SHIFT, CTRL",
    "and ALT." };

WHELP BUTTON_HELP[] =
{
	"This is a button. If the dialog",
	"is backgroundable, you can click",
	"on buttons without having to top",
	"the window first.", " ", " ", " ", " ", " " };

WHELP RBUTTON_HELP[] =
{
	"This is a radio button. Only one",
	"button from a group of radio",
	"buttons can be selected. If the",
	"dialog is backgroundable, you",
    "can click on buttons without",
    "having to top the window first.", " ", " ", " " };

WHELP DSLIDER_HELP[] =
{
	"This is a slider. You can drag",
	"the slider within the confines",
	"of its track to change a value",
	"within a program. If it is",
    "'active', you can drag the",
    "slider in realtime.", " ", " ", " " };

WHELP DSLIDERBTN_HELP[] =
{
	"This is a slider button. You can",
	"use this to adjust the position",
	"of the slider in small amounts,",
	"or you can double click on this",
    "button to move it to the extreme",
    "edge.", " ", " ", " " };

WHELP ICONIFY_HELP[] =
{
	"This is an iconified window.",
	" ", " ", " ", " ", " ", " ", " ", " " };

GLOBAL void WSetWindowText(WINDOW *win, WHELP *txt)
{
	if (win)
		if (txt)
			(WHELP *) win->user = txt;
}

LOCAL void ShowText(WINDOW *win, WHELP *txt)
{
	int x, y;

	if (win) {
		WGrafMouse(M_OFF);

		objc_offset(win->tree, HELPWORK, &x, &y);

		x += 3;
		y += gr_ch + 1;

		ChangeObjectText(win->tree, HELPTITL, txt->wind_title, 3, TE_CNTR);

		v_gtext(VDIhandle, x, y, txt->hline1);	y += gr_ch;
		v_gtext(VDIhandle, x, y, txt->hline2);	y += gr_ch;
		v_gtext(VDIhandle, x, y, txt->hline3);	y += gr_ch;
		v_gtext(VDIhandle, x, y, txt->hline4);	y += gr_ch;
		v_gtext(VDIhandle, x, y, txt->hline5);	y += gr_ch;
		v_gtext(VDIhandle, x, y, txt->hline6);	y += gr_ch;
		v_gtext(VDIhandle, x, y, txt->hline7);	y += gr_ch;
		v_gtext(VDIhandle, x, y, txt->hline8);

		WGrafMouse(M_ON);
	}
}

LOCAL int WhatHelpDispatcher(WINDOW *win, int msg_buf[8])
{
	if (win) {
		switch(*msg_buf) {
			case WM_PAINT:
				ShowText(win, (WHELP *) win->user);
				return FALSE;

			case WM_DIALOG:
				switch(msg_buf[3]) {
					case HELPOK:
						WCloseWindow(win, WC_OBJECTABLE, K_ASK);
						return FALSE;
				}

				return FALSE;

			case WM_GETHELP:
				switch(msg_buf[4]) {
					case HELPOK:
						win = WCreateObject(WC_WINDOW, W_OPEN|W_DIALOG|W_UNSIZABLE|W_BEVENT,
										W_CUSTOMWINDOW, NAME|MOVER|CLOSER,
										"What's this ???", NULL, HELPWINDOW, WhatHelpDispatcher, 
										-1, -1, -1, -1, 0, NULL, 0, 0);
						ChangeObjectText(win->tree, HELPTITL, ((WHELP *) OKAYBUT_HELP->wind_title), 3, TE_CNTR);
						WSetWindowText(win, OKAYBUT_HELP);

						return TRUE;
				}

				return FALSE;
		}
	}

	return FALSE;
}

GLOBAL void WHandleWindowHelp(int button)
{
	WINDOW *win;

	win = WCreateObject(WC_WINDOW, W_OPEN|W_DIALOG|W_UNSIZABLE|W_BEVENT,
					W_CUSTOMWINDOW, NAME|MOVER|CLOSER,
					"What's this ???", NULL, HELPWINDOW, WhatHelpDispatcher, 
					-1, -1, -1, -1, 0, NULL, 0, 0);

	if (win) {
		switch(button) {
			case W_ULSIZE:
			case W_TSIZE:
			case W_URSIZE:
			case W_LSIZE:
			case W_RSIZE:
			case W_LLSIZE:
			case W_BSIZE:
			case W_LRSIZE:
				ChangeObjectText(win->tree, HELPTITL, ((WHELP *) SIZE_HELP->wind_title), 3, TE_CNTR);
				WSetWindowText(win, SIZE_HELP);
				break;

			case W_CLOSER:
				ChangeObjectText(win->tree, HELPTITL, ((WHELP *) CLOSER_HELP->wind_title), 3, TE_CNTR);
				WSetWindowText(win, CLOSER_HELP);
				break;

			case W_FULLER:
				ChangeObjectText(win->tree, HELPTITL, ((WHELP *) FULLER_HELP->wind_title), 3, TE_CNTR);
				WSetWindowText(win, FULLER_HELP);
				break;

			case W_SLLT:
			case W_SLDN:
			case W_SLUP:
			case W_SLRT:
				ChangeObjectText(win->tree, HELPTITL, ((WHELP *) MOVESLIDE_HELP->wind_title), 3, TE_CNTR);
				WSetWindowText(win, MOVESLIDE_HELP);
				break;

			case W_MOVER:
				ChangeObjectText(win->tree, HELPTITL, ((WHELP *) MOVER_HELP->wind_title), 3, TE_CNTR);
				WSetWindowText(win, MOVER_HELP);
				break;

			case W_CASCADE:
				ChangeObjectText(win->tree, HELPTITL, ((WHELP *) CASCADE_HELP->wind_title), 3, TE_CNTR);
				WSetWindowText(win, CASCADE_HELP);
				break;

			case W_MENU_L:
			case W_MENU_R:
				ChangeObjectText(win->tree, HELPTITL, ((WHELP *) MENU_HELP->wind_title), 3, TE_CNTR);
				WSetWindowText(win, MENU_HELP);
				break;

			case W_INFO_R:
			case W_INFO_L:
				ChangeObjectText(win->tree, HELPTITL, ((WHELP *) INFO_HELP->wind_title), 3, TE_CNTR);
				WSetWindowText(win, INFO_HELP);
				break;

			case W_VERTRK:
			case W_VERSL:
			case W_HORTRK:
			case W_HORSL:
				ChangeObjectText(win->tree, HELPTITL, ((WHELP *) SLIDER_HELP->wind_title), 3, TE_CNTR);
				WSetWindowText(win, SLIDER_HELP);
				break;

			case WORKAREA:
				ChangeObjectText(win->tree, HELPTITL, ((WHELP *) WORKAREA_HELP->wind_title), 3, TE_CNTR);
				WSetWindowText(win, WORKAREA_HELP);
				break;

			case W_OPTION:
				ChangeObjectText(win->tree, HELPTITL, ((WHELP *) OPTION_HELP->wind_title), 3, TE_CNTR);
				WSetWindowText(win, OPTION_HELP);
				break;

			default:
				ChangeObjectText(win->tree, HELPTITL, "No info available", 3, TE_CNTR);
				WSetWindowText(win, NOINFO_HELP);
				break;
		}

		helpmode = FALSE;
		WGrafMouse(ARROW);
	}
}