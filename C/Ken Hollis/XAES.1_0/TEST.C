/*
 *	XAES 1.00
 *	Test Program
 *
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.
 *	Program by Ken Hollis
 *
 *	Shows all functions of XAES off.  This program will most likely
 *	be larger after a few changes are made to XAES.
 *
 *	Although it takes quite a few parameters to create an actual
 *	window, it is relatively bug-free.  Read the docs (RTFM) for more
 *	information.  (Or hit HELP if you're using Pure C.)
 */

#include <stddef.h>
#include <stdio.h>

#include "test.h"
#include "xaes.h"
#include "nkcc.h"

int testkind, windsize;
BOOL backgroundable, sizeable, customwin;

OBJECT *test, *test2, *test3, *test4, *icontree, *test5, *test6,
	   *test7, *test8, *test9, *test10;

#define	infokind	(NAME|MOVER|CLOSER)
#define	allkind		0xFFFF
#define nokind		0x0000
#define	stdkind		(NAME|MOVER|CLOSER)

LOCAL int hormax, vermax, horstep, verstep;

void DoSliders(WINDOW *win)
{
	WCreateObject(WC_SLIDER, win->tree, 0, hormax, horstep, SLIDER_HOR, SLRT1, SLIDE1, TRACK1, SLLT1);
	WCreateObject(WC_SLIDER, win->tree, 100, 999, 5, SLIDER_HOR, HMAXINC, HMAXSLID, HMAXTRAK, HMAXDEC);
	WCreateObject(WC_SLIDER, win->tree, 25, 999, 5, SLIDER_HOR, VMAXINC, VMAXSLID, VMAXTRAK, VMAXDEC);
	WCreateObject(WC_SLIDER, win->tree, 5, 99, 5, SLIDER_HOR, HSTEPINC, HSTEPSLD, HSTEPTRK, HSTEPDEC);
	WCreateObject(WC_SLIDER, win->tree, 5, 99, 5, SLIDER_HOR, VSTEPINC, VSTEPSLD, VSTEPTRK, VSTEPDEC);
	WCreateObject(WC_SLIDER, win->tree, 0, vermax, verstep, SLIDER_VER, SLDN1, SLIDE5, TRACK5, SLUP1);
}

int Dlg1Dispatcher(WINDOW *win, int msg_buf[8])
{
	UNUSED(win);
	UNUSED(msg_buf);

	return FALSE;
}

int Dlg2Dispatcher(WINDOW *win, int msg_buf[8])
{
	switch(*msg_buf) {
		case WM_COPIED:
			if (win)
				DoSliders(win);
			break;

		case WM_SLIDER:
			switch(msg_buf[3]) {
				case HMAXDEC:
				case HMAXTRAK:
				case HMAXSLID:
				case HMAXINC:
					if (msg_buf[4] == 0)
						msg_buf[4] = 1;

					if (((msg_buf[4]!=0) && (msg_buf[5]!=0)) &&
						(msg_buf[4]!=msg_buf[5])) {
						hormax = msg_buf[4];
						WCreateObject(WC_SLIDER, win->tree, 0, hormax, horstep, SLIDER_HOR, SLRT1, SLIDE1, TRACK1, SLLT1);
						WUpdateWindowDlgLevel(win, desk.g_x, desk.g_y, desk.g_w, desk.g_h, TRACK1, 1);
					}
					break;

				case VMAXDEC:
				case VMAXTRAK:
				case VMAXSLID:
				case VMAXINC:
					if (msg_buf[4] == 0)
						msg_buf[4] = 1;

					if (((msg_buf[4]!=0) && (msg_buf[5]!=0)) &&
						(msg_buf[4]!=msg_buf[5])) {
						vermax = msg_buf[4];
						WCreateObject(WC_SLIDER, win->tree, 0, vermax, verstep, SLIDER_VER, SLDN1, SLIDE5, TRACK5, SLUP1);
						WUpdateWindowDlgLevel(win, desk.g_x, desk.g_y, desk.g_w, desk.g_h, TRACK5, 1);
					}
					break;

				case HSTEPDEC:
				case HSTEPTRK:
				case HSTEPSLD:
				case HSTEPINC:
					if (msg_buf[4] == 0)
						msg_buf[4] = 1;

					if (((msg_buf[4]!=0) && (msg_buf[5]!=0)) &&
						(msg_buf[4]!=msg_buf[5])) {
						horstep = msg_buf[4];
						WCreateObject(WC_SLIDER, win->tree, 0, hormax, horstep, SLIDER_HOR, SLRT1, SLIDE1, TRACK1, SLLT1);
					}
					break;

				case VSTEPDEC:
				case VSTEPTRK:
				case VSTEPSLD:
				case VSTEPINC:
					if (msg_buf[4] == 0)
						msg_buf[4] = 1;

					if (((msg_buf[4]!=0) && (msg_buf[5]!=0)) &&
						(msg_buf[4]!=msg_buf[5])) {
						verstep = msg_buf[4];
						WCreateObject(WC_SLIDER, win->tree, 0, vermax, verstep, SLIDER_VER, SLDN1, SLIDE5, TRACK5, SLUP1);
					}
					break;
			}
	}

	return FALSE;
}

int Dlg4Dispatcher(WINDOW *win, int msg_buf[8])
{
	UNUSED(win);
	UNUSED(msg_buf);

	return FALSE;
}

void CheckItems(void)
{
	menu_icheck(test3, NAMESET, (testkind & NAME) ? TRUE : FALSE);
	menu_icheck(test3, CLOSSET, (testkind & CLOSER) ? TRUE : FALSE);
	menu_icheck(test3, FULLSET, (testkind & FULLER) ? TRUE : FALSE);
	menu_icheck(test3, MOVESET, (testkind & MOVER) ? TRUE : FALSE);
	menu_icheck(test3, INFOSET, (testkind & INFO) ? TRUE : FALSE);
	menu_icheck(test3, SIZESET, (testkind & SIZER) ? TRUE : FALSE);
	menu_icheck(test3, UPARSET, (testkind & UPARROW) ? TRUE : FALSE);
	menu_icheck(test3, DNARSET, (testkind & DNARROW) ? TRUE : FALSE);
	menu_icheck(test3, VSLIDSET, (testkind & VSLIDE) ? TRUE : FALSE);
	menu_icheck(test3, LFARSET, (testkind & LFARROW) ? TRUE : FALSE);
	menu_icheck(test3, RTARSET, (testkind & RTARROW) ? TRUE : FALSE);
	menu_icheck(test3, HSLIDSET, (testkind & HSLIDE) ? TRUE : FALSE);
	menu_icheck(test3, CASCSET, (testkind & CASCADE) ? TRUE : FALSE);
	menu_icheck(test3, MENUSET, (testkind & MENUWORK) ? TRUE : FALSE);
	menu_icheck(test3, OPTISET, (testkind & OPTIONS) ? TRUE : FALSE);
	menu_icheck(test3, SIZEXAES, (sizeable) ? TRUE : FALSE);
	menu_icheck(test3, BKGNXAES, (backgroundable) ? TRUE : FALSE);
	menu_icheck(test3, LWINXAES, (windsize == WC_WINDOW) ? TRUE : FALSE);
	menu_icheck(test3, SWINXAES, (windsize == WC_SWINDOW) ? TRUE : FALSE);
	menu_icheck(test3, CUSTXAES, (customwin) ? TRUE : FALSE);

	menu_ienable(test3, CASCSET, (customwin) ? TRUE : FALSE);
	menu_ienable(test3, MENUSET, (customwin) ? TRUE : FALSE);
	menu_ienable(test3, OPTISET, (customwin) ? TRUE : FALSE);
	menu_ienable(test3, SIZEXAES, (customwin) ? TRUE : FALSE);
	menu_ienable(test3, LWINXAES, (customwin) ? TRUE : FALSE);
	menu_ienable(test3, SWINXAES, (customwin) ? TRUE : FALSE);
}

int EtcDispatcher(int msg_buf[8])
{
	switch (*msg_buf) {
		case MN_SELECTED:
			menu_tnormal(test3, msg_buf[3], TRUE);

			switch(msg_buf[4]) {
				case ABTXAES:
					WCreateObject(WC_WINDOW, W_OPEN|W_DIALOG|W_UNUNTOPPABLE|W_UNSIZABLE,
								((customwin) ? W_CUSTOMWINDOW : 0), (NAME|CLOSER|MOVER|SIZER),
								"Test dialog 1", "      Test info", test, NULL, 
								-1, -1, -1, -1, 0, icontree, 1, "Dialog 1", NULL);
					break;

				case WIN1XAES:
					WCreateObject(WC_WINDOW, W_OPEN|W_DIALOG|((backgroundable) ? W_BEVENT : 0)|((!(sizeable)) ? W_UNSIZABLE : 0),
								((customwin) ? W_CUSTOMWINDOW : 0), testkind,
								"Test dialog 1", "      Test info", test, NULL, 
								-1, -1, -1, -1, 0, icontree, 1, "Dialog 1", NULL);
					break;

				case WIN2XAES:
					{
						WINDOW *win;

						win = WCreateObject(WC_WINDOW, W_OPEN|W_DIALOG|((backgroundable) ? W_BEVENT : 0)|((!(sizeable)) ? W_UNSIZABLE : 0),
									((customwin) ? W_CUSTOMWINDOW : 0), testkind,
									"Test dialog 2", "      Test info", test2, Dlg2Dispatcher, 
									-1, -1, -1, -1, 12, icontree, 1, "Dialog 2", NULL);
					}
					break;

				case WIN3XAES:
					WCreateObject(WC_WINDOW, W_OPEN|W_DIALOG|((backgroundable) ? W_BEVENT : 0)|((!(sizeable)) ? W_UNSIZABLE : 0),
								((customwin) ? W_CUSTOMWINDOW : 0), testkind,
								"Test dialog", "      Test info", test5, NULL, 
								-1, -1, -1, -1, 0, icontree, 1, "Dialog", NULL);
					break;

				case WIN4XAES:
					WCreateObject(WC_WINDOW, W_OPEN|W_DIALOG|((backgroundable) ? W_BEVENT : 0)|((!(sizeable)) ? W_UNSIZABLE : 0),
								((customwin) ? W_CUSTOMWINDOW : 0), testkind,
								"Test dialog", "      Test info", test6, NULL, 
								-1, -1, -1, -1, 0, icontree, 1, "Dialog", NULL);
					break;

				case WIN5XAES:
					WCreateObject(WC_WINDOW, W_OPEN|W_DIALOG|((backgroundable) ? W_BEVENT : 0)|((!(sizeable)) ? W_UNSIZABLE : 0),
								((customwin) ? W_CUSTOMWINDOW : 0), testkind,
								"Test dialog", "      Test info", test7, NULL, 
								-1, -1, -1, -1, 0, icontree, 1, "Dialog", NULL);
					break;

				case WIN6XAES:
					WCreateObject(WC_WINDOW, W_OPEN|W_DIALOG|((backgroundable) ? W_BEVENT : 0)|((!(sizeable)) ? W_UNSIZABLE : 0),
								((customwin) ? W_CUSTOMWINDOW : 0), testkind,
								"Test dialog", "      Test info", test8, NULL, 
								-1, -1, -1, -1, 0, icontree, 1, "Dialog", NULL);
					break;

				case WIN7XAES:
					WCreateObject(WC_WINDOW, W_OPEN|W_DIALOG|((backgroundable) ? W_BEVENT : 0)|((!(sizeable)) ? W_UNSIZABLE : 0),
								((customwin) ? W_CUSTOMWINDOW : 0), testkind,
								"Test dialog", "      Test info", test9, NULL, 
								-1, -1, -1, -1, 0, icontree, 1, "Dialog", NULL);
					break;

				case WIN8XAES:
					WCreateObject(WC_WINDOW, W_OPEN|W_DIALOG|((backgroundable) ? W_BEVENT : 0)|((!(sizeable)) ? W_UNSIZABLE : 0),
								((customwin) ? W_CUSTOMWINDOW : 0), testkind,
								"Test dialog", "      Test info", test10, NULL, 
								-1, -1, -1, -1, 0, icontree, 1, "Dialog", NULL);
					break;

				case CHGSET:
					WCreateObject(WC_WINDOW, W_OPEN|W_DIALOG|W_BEVENT|W_UNSIZABLE,
								W_CUSTOMWINDOW, stdkind, "GUI_DEFS Settings", "      Test info", test4, NULL,
								-1, -1, -1, -1, 0, icontree, 1, "Settings", NULL);
					break;

				case QUITXAES:
					WDie(0);
					break;

				case NAMESET:
					testkind = (testkind & NAME) ? testkind & ~NAME : testkind | NAME;
					break;

				case CLOSSET:
					testkind = (testkind & CLOSER) ? testkind & ~CLOSER : testkind | CLOSER;
					break;

				case FULLSET:
					testkind = (testkind & FULLER) ? testkind & ~FULLER : testkind | FULLER;
					break;

				case MOVESET:
					testkind = (testkind & MOVER) ? testkind & ~MOVER : testkind | MOVER;
					break;

				case INFOSET:
					testkind = (testkind & INFO) ? testkind & ~INFO : testkind | INFO;
					break;

				case SIZESET:
					testkind = (testkind & SIZER) ? testkind & ~SIZER : testkind | SIZER;
					break;

				case UPARSET:
					testkind = (testkind & UPARROW) ? testkind & ~UPARROW : testkind | UPARROW;
					break;

				case DNARSET:
					testkind = (testkind & DNARROW) ? testkind & ~DNARROW : testkind | DNARROW;
					break;

				case VSLIDSET:
					testkind = (testkind & VSLIDE) ? testkind & ~VSLIDE : testkind | VSLIDE;
					break;

				case LFARSET:
					testkind = (testkind & LFARROW) ? testkind & ~LFARROW : testkind | LFARROW;
					break;

				case RTARSET:
					testkind = (testkind & RTARROW) ? testkind & ~RTARROW : testkind | RTARROW;
					break;

				case HSLIDSET:
					testkind = (testkind & HSLIDE) ? testkind & ~HSLIDE : testkind | HSLIDE;
					break;

				case CASCSET:
					testkind = (testkind & CASCADE) ? testkind & ~CASCADE : testkind | CASCADE;
					break;

				case MENUSET:
					testkind = (testkind & MENUWORK) ? testkind & ~MENUWORK : testkind | MENUWORK;
					break;

				case OPTISET:
					testkind = (testkind & OPTIONS) ? testkind & ~OPTIONS : testkind | OPTIONS;
					break;

				case SIZEXAES:
					sizeable = (sizeable) ? FALSE : TRUE;
					break;

				case BKGNXAES:
					backgroundable = (backgroundable) ? FALSE : TRUE;
					break;

				case LWINXAES:
					windsize = WC_WINDOW;
					break;

				case SWINXAES:
					windsize = WC_SWINDOW;
					break;

				case EALLXAES:
					testkind = allkind;
					break;

				case DALLXAES:
					testkind = nokind;
					break;

				case STANXAES:
					testkind = stdkind;
					break;

				case CUSTXAES:
					customwin = (customwin) ? FALSE : TRUE;
					break;
			}

			CheckItems();
			break;

		case WM_CLOSEALL:
			if (msg_buf[3] == K_ASK)
				if ((form_alert(1, "[3][Close all windows| |Are you sure?][ Okay | Cancel ]")) == 1)
					return FALSE;
				else
					return TRUE;

			if (msg_buf[3] == K_NO_STOP)
				return TRUE;

			break;

		case WM_PROGEND:
/*			WDie(0); */
			break;
	}

	return FALSE;
}

int KeyDispatcher(int key)
{
	if (key & NKF_CTRL)
		switch (key & 0xff) {
			case 'I':
			case 'i':
				WCreateObject(WC_WINDOW, W_OPEN|W_DIALOG|W_UNUNTOPPABLE|W_UNSIZABLE,
							((customwin) ? W_CUSTOMWINDOW : 0), (NAME|CLOSER|MOVER|SIZER),
							"Test dialog 1", "      Test info", test, NULL, 
							-1, -1, -1, -1, 0, icontree, 1, "Dialog 1", NULL);
				break;

			case 'Q':
			case 'q':
				if (_app)
					if ((form_alert(1, "[3][Doing this will quit|the demo.][ Okay | Cancel ]")) == 1)
						WDie(0);
					else
						return TRUE;

				return TRUE;

			case 'U':
			case 'u':
				WCloseWindow(NULL, WC_OBJECTABLE, K_ASK);
				break;

			case 'W':
			case 'w':
				WTopWindow(NULL);
				break;

			case 'A':
			case 'a':
				testkind = allkind;
				CheckItems();
				break;

			case 'D':
			case 'd':
				testkind = nokind;
				CheckItems();
				break;
		}

	if (key & NKF_FUNC)
		switch (key & 0xff) {
			case NK_F1:
				WCreateObject(WC_WINDOW, W_OPEN|W_DIALOG|((backgroundable) ? W_BEVENT : 0)|((!(sizeable)) ? W_UNSIZABLE : 0),
							((customwin) ? W_CUSTOMWINDOW : 0), testkind,
							"Test dialog 1", "      Test info", test, NULL, 
							-1, -1, -1, -1, 0, icontree, 1, "Dialog 1", NULL);
				break;

			case NK_F2:
				{
					WINDOW *win;

					win = WCreateObject(WC_WINDOW, W_OPEN|W_DIALOG|((backgroundable) ? W_BEVENT : 0)|((!(sizeable)) ? W_UNSIZABLE : 0),
								((customwin) ? W_CUSTOMWINDOW : 0), testkind,
								"Test dialog 2", "      Test info", test2, Dlg2Dispatcher, 
								-1, -1, -1, -1, 12, icontree, 1, "Dialog 2", NULL);
				}
				break;
		}

	return FALSE;
}

void UnfixObjects()
{
	unfix_object(test3);
	unfix_object(test);
	unfix_object(test2);
	unfix_object(test4);
}

int main(void)
{
	OBJECT *TT;

	if (rsrc_load(".\\TEST.RSC")) {
		WBoot();

		graf_mouse(ARROW, 0L);

		rsrc_gaddr(R_TREE, 0, &test3);
		rsrc_gaddr(R_TREE, 1, &test);
		rsrc_gaddr(R_TREE, 2, &test2);
		rsrc_gaddr(R_TREE, 3, &test4);
		rsrc_gaddr(R_TREE, 4, &icontree);
		rsrc_gaddr(R_TREE, 5, &test5);
		rsrc_gaddr(R_TREE, 6, &test6);
		rsrc_gaddr(R_TREE, 7, &test7);
		rsrc_gaddr(R_TREE, 8, &test8);
		rsrc_gaddr(R_TREE, 9, &test9);
		rsrc_gaddr(R_TREE, 10, &test10);

		testkind = NAME|MOVER|SIZER;
		backgroundable = TRUE;
		sizeable = FALSE;
		windsize = WC_WINDOW;
		customwin = TRUE;

		fix_object(test3, FALSE, FALSE);

		test2[SLIDE1].ob_x++;	test2[SLIDE1].ob_y++;
		test2[SLIDE5].ob_x++;	test2[SLIDE5].ob_y++;
		test2[HMAXSLID].ob_x++;	test2[HMAXSLID].ob_y++;
		test2[VMAXSLID].ob_x++;	test2[VMAXSLID].ob_y++;
		test2[HSTEPSLD].ob_x++;	test2[HSTEPSLD].ob_y++;
		test2[VSTEPSLD].ob_x++;	test2[VSTEPSLD].ob_y++;

		WInit(0, EtcDispatcher, KeyDispatcher, "  XAES Demo 0.01",
			  "XAES", FALSE);

		WSetCallback(XC_INITIALIZE, CheckItems);
		WSetCallback(XC_DEINITIALIZE, UnfixObjects);

		menu_bar(test3, TRUE);

		XCallInitializeCallback;
		XCallStartupCallback;

		hormax = 100;
		vermax = 25;
		horstep = 5;
		verstep = 5;

		WDoDial();
		menu_bar(test3, FALSE);

		XCallDeinitializeCallback;

		WTerm(FALSE);
	} else
		form_alert(1, "[3][Sorry, could not locate|the resource file!][ Okay ]");

	return FALSE;
}