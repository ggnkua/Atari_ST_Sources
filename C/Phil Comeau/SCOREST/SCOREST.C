/* ScoreST: Desktop music layout package for the Atari ST
 * phil comeau 04-jan-88
 * last edited 14-oct-89 0015
 *
 * Copyright 1988 by Phil Comeau
 * Copyright 1989, 1990 Antic Publishing Inc.
 */

#include <stdio.h>
#include <ctype.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include <eventmsg.h>
#include <mylib.h>
#include <dialog.h>
#include <list.h>
#include <graphics.h>
#include "graph.h"
#include "scoredef.h"
#include "symbol.h"
#include "entity.h"
#include "scorest.h"
#include "menu.h"
#include "config.h"

/* Constants. */
#define HIGHRES 2			/* monochrome monitor resolution */
#define CTRLB 0x02			/* menu-equivalent ctrl chars */
#define CTRLC 0x03
#define CTRLE 0x05
#define CTRLF 0x06
#define CTRLG 0x07
#define CTRLH 0x08
#define CTRLN 0x0e
#define CTRLO 0x0f
#define CTRLP 0x10
#define CTRLS 0x13
#define CTRLT 0x14
#define CTRLV 0x16
#define CTRLW 0x17
#define CTRLX 0x18
#define CTRLZ 0x1a
#define DEBUG 0				/* set to 1 to open debug file */

/* Global variables */
RECT2D PalScsRct;			/* rectangle describing screen area
					 * occupied by icon palette.
					 */
char FileNm[FILENAMESZ] = '\0';		/* Current filename. */
BOOLEAN FileDirty = FALSE;		/* TRUE if the file has been
					 * modified.
					 */
int GHandle;				/* Graphics (VDI) handle */
LINESTYLE LineStyle = {1, SQUAREEND,	/* Default line style. */
    SOLIDLNPAT};
LINESTYLE BeamStyle = {1, SQUAREEND,	/* Beam style. */
    SOLIDLNPAT};
TXTSTYLE TxtStyle = {1, 10, 0x0};	/* Default text style. */
BOOLEAN ShowGrid = TRUE;		/* Indicates whether drawing grid
					 * is to be superimposed over
					 * window.
					 */
CONFIG Config;				/* ScoreST configuration info. */
ENTITY *LastEntAdded;			/* Last entity added; used for
					 * fast deletion.
					 */
BOOLEAN LastEntValid;			/* TRUE if LastEntAdded contains
					 * an existing entity.
					 */
int LastEntPgNum;			/* Page number of the last entity
					 * added.
					 */
BOOLEAN PrtEnabled;			/* TRUE if printer has been config-
					 * ured correctly.
					 */
BOOLEAN Quit;				/* TRUE if it's time to quit. */
OBJECT *Palette = NULL;			/* pointer to icon palette object
					 * tree.
					 */

FILE *Debug;

/* Forward References. */
static void buttonHandler(), rspMsEvt(), rspBtnEvt(), rspMsgEvt(),
    rspKeyEvt(), getConfig(), delLastEnt(), initPalette(), invertIcon();

main()
{
	int createWind(), msgBfr[MSGBFRSZ], event, junk,
	    i, btnState, keyState, keyChar;
	long lJunk;
	BOOLEAN inWindow;
	POINT2D msPos;
	void showInfo();
	static MSFORM arwMsForm = {ARROW, {0}};
	static char str[MAXSTR];
	extern ENTITY *allocEnt();
	extern RECT2D WinScsRct;

	/* Perform the usual initialization. */
#if DEBUG
	Debug = fopen("debug.out", "w");
#endif

	appl_init();
	setMsForm(&arwMsForm);

	/* Make sure the necessary monitor resolution is available. */
	if (Getrez() != HIGHRES) {
		sprintf(str, "[3][%s|%s|%s|%s][Exit]",
		    "ScoreST requires high",
		    "resolution, using a",
		    "monochrome monitor.",
		    "Sorry.");
		form_alert(1, str);
		exit(1);
	}

	if (rsrc_load(RSRCFILE) == 0) {
		Error("Can't load resource file");
	}

	showInfo();

	GHandle = OpenVWk();

	/* Read the configuration file and set the Score configuration. */
	getConfig();

	/* Initialize the various objects and data structures. */
	initPalette();
	initMenu();
	initOpt();
	initPg();
	initSymTbl();
	initSel();
	LastEntAdded = allocEnt();

	/* Create the editing window. The window won't actually be opened
	 * until a file is opened.
	 */
	createWind();

	/* Here's where the real fun begins. We wait for 4 kinds of things
	 * to happen: 1) a menu item is selected, in which case the action
	 * associated with the item is performed; 2) an icon is selected,
	 * so the symbol associated with that icon becomes the current
	 * symbol; 3) the mouse is clicked in the window, so the action
	 * associated with the current symbol is performed; 4) a key is
	 * pressed.
	 */
	inWindow = FALSE;

	/* Get and classify an event. We wait for button presses, the
	 * mouse to enter or leave the window, or mouse button
	 * presses.
	 */
	Quit = FALSE;
	do {
		event = evnt_multi(MU_KEYBD | MU_BUTTON | MU_M1 | MU_MESAG,
		    1, LEFTBUTTON, BUTTONDOWN << LEFTBUTTONBIT,
		    inWindow ? MSEXIT : MSENTER, WinScsRct.x,
		    WinScsRct.y, WinScsRct.w, WinScsRct.h,
		    (int)NULL, (int)NULL, (int)NULL, (int)NULL, (int)NULL,
		    msgBfr, (int)NULL, (int)NULL, &msPos.x, &msPos.y,
		    &btnState, &keyState, &keyChar, &junk);

		/* This loop solves a timing problem where the mouse button
		 * may appear to be down when in fact it was just clicked.
		 * It may need some tuning on a faster processor.
		 */
		graf_mkstate(&junk, &junk, &btnState, &junk);
		for (i = 0; i < 50 && (btnState & LEFTBUTTON) != 0; ++i) {
			graf_mkstate(&junk, &junk, &btnState, &junk);
		}

		if ((event & MU_M1) != 0) {

			/* The mouse entered or left the window. */
			rspMsEvt(&inWindow);
		}
		if ((event & MU_BUTTON) != 0) {
			rspBtnEvt(btnState, keyState, &msPos, inWindow);
		}
		if ((event & MU_MESAG) != 0) {
			rspMsgEvt(msgBfr);
		}
		if ((event & MU_KEYBD) != 0) {
			rspKeyEvt(&msPos, inWindow, keyChar);
		}
	} while (!Quit);

	/* Shut down. */
	delWind();
	closeMenu();
	CloseVWk(GHandle);
#if DEBUG
	fclose(Debug);
#endif
	rsrc_free();
	appl_exit();
	exit(0);
}

/* rspMsEvt: Respond to a mouse transition event. Change some state variables
 * to indicate which area the mouse is (or isn't) in.
 */
static void rspMsEvt(inWindow)
BOOLEAN *inWindow;
{
	static MSFORM arwMsForm = {ARROW, {0}};
	extern SYMBOL *CurSym;

	/* We just crossed the window perimeter. */
	*inWindow = !*inWindow;

	/* Set the mouse to the form as required for the mouse's position
	 * with respect to the window. If the mouse is in the window,
	 * set it to the form associated with the currently-defined symbol,
	 * if there is one.
	 */
	if (CurSym != NULL) {
		setMsForm(*inWindow ? CurSym->symMs : &arwMsForm);
	}
}

/* rspBtnEvt: Respond to a mouse button event. */
static void rspBtnEvt(btnMask, keyState, msPos, inWindow)
BUTTONMASK btnMask;
int keyState;
POINT2D *msPos;
BOOLEAN inWindow;
{
	extern SYMBOL *CurSym;
	extern BOOLEAN Pasting;

	/* Determine where the mouse button was pressed. This determines
	 * how we'll respond to it.
	 */
	if (inWindow) {

		/* The mouse was clicked inside the window, indicating the
		 * user's intent to perform the action associated with the
		 * currently-selected symbol. If the user has previously
		 * selecting "Paste" from the Edit menu, then we'll paste
		 * the contents of the cut/paste buffer instead.
		 */
		if (Pasting) {
			doPaste(msPos);
		}
		else {
			if (CurSym != NULL) {
				addSym(msPos, CurSym, keyState, (char)NULL);
			}
		}
	}
	else {

		/* The mouse may have been clicked over a symbol or tool in
		 * the Palette. If so, may that one active.
		 */
		selectSym(msPos);
	}
}

/* rspMsgEvt: Respond to a message event. Classify the event, and dispatch
 * a function to act on it.
 */
static void rspMsgEvt(msgBfr)
register int msgBfr[];
{
	RECT2D rect;

	switch (msgBfr[MSGTYPE]) {
	case WM_REDRAW:
		wRedraw((RECT2D *)&msgBfr[WRDWX]);
		break;
	case WM_ARROWED:
		wArrowed(msgBfr[WARWACTION]);
		break;
	case WM_HSLID:
		wSlider(msgBfr[WHSLIDEPOS], WF_HSLIDE);
		break;
	case WM_VSLID:
		wSlider(msgBfr[WVSLIDEPOS], WF_VSLIDE);
		break;
	case WM_CLOSED:
		closeFile();
		break;
	case WM_TOPPED:
		wTopped();
		break;
	case MN_SELECTED:

		/* The user selected a menu item. Invoke the action
		 * function associated with it.
		 */
		execMnuFunc(msgBfr[MNTTLX], msgBfr[MNITMX]);
		break;
	}
}

/* rspKeyEvt: Respond to a keyboard event. */
static void rspKeyEvt(msPos, inWindow, keyChar)
POINT2D *msPos;
BOOLEAN inWindow;
register int keyChar;
{
	register char c;
	extern SYMBOL *CurSym;

	/* Classify and act on the keypress. */
	switch (keyChar) {
	case DELKEY:
	case BSKEY:
		delLastEnt();
		break;
	case LARROWKEY:
	case RARROWKEY:
	case UARROWKEY:
	case DARROWKEY:
	case S_LARROWKEY:
	case S_RARROWKEY:
	case S_UARROWKEY:
	case S_DARROWKEY:
		mvSelEntsKey(keyChar);
		break;
	default:

		/* See if the keystroke is a keyboard equivalent to a menu
		 * selection.
		 */
		c = keyChar & 0x7f;
		switch (c) {
		case CTRLB:
			execMnuFunc(PAGEMNU, PRVPGITM);
			break;
		case CTRLC:
			execMnuFunc(EDITMNU, COPYITM);
			break;
		case CTRLE:
			execMnuFunc(EDITMNU, ERAITM);
			break;
		case CTRLF:
			execMnuFunc(PAGEMNU, NXTPGITM);
			break;
		case CTRLG:
			execMnuFunc(PAGEMNU, TOPGITM);
			break;
		case CTRLH:
			execMnuFunc(OPTMNU, GRIDITM);
			break;
		case CTRLN:
			execMnuFunc(FILEMNU, NEWITM);
			break;
		case CTRLO:
			execMnuFunc(FILEMNU, OPENITM);
			break;
		case CTRLP:
			execMnuFunc(PAGEMNU, CRTPGITM);
			break;
		case CTRLS:
			execMnuFunc(FILEMNU, SVITM);
			break;
		case CTRLT:
			execMnuFunc(OPTMNU, TXTATITM);
			break;
		case CTRLV:
			execMnuFunc(EDITMNU, PSTITM);
			break;
		case CTRLW:
			execMnuFunc(OPTMNU, LNWDITM);
			break;
		case CTRLX:
			execMnuFunc(EDITMNU, CUTITM);
			break;
		case CTRLZ:
			execMnuFunc(OPTMNU, TXTSZITM);
			break;
		default:

			/* Add the character as a text symbol, if possible */
			if (CurSym != NULL &&
			    CurSym->symClass == TXTSYMCLASS) {
				if (isprint(c) || c == '\r' || c == '\t') {
					if (c == '\t') {
						c = ' ';
					}
					addSym(msPos, CurSym, 0x0, c);
				}
			}
			break;
		}
	}
}

/* showInfo: Display a form containing information about ScoreST. */
void showInfo()
{
	OBJECT *infoForm;
	GRECT formRct;
	int exitObj;
	extern char Version[];

	rsrc_gaddr(R_TREE, INFODLG, &infoForm);
	strcpy(GETOBJSPEC(infoForm, INVERFLD), Version);
	DlgDisplay(infoForm, &formRct);
	exitObj = DlgExecute(infoForm);
	DESELOBJ(infoForm, exitObj);
	DlgErase(infoForm, &formRct);
}

/* getConfig: Read the configuration file and set the ScoreST configuration.
 */
static void getConfig()
{
	register int fd;
	register BOOLEAN opened;
	char fileName[FILENAMESZ], str[MAXSTR];

	/* Attempt to open the configuration file. We look in three places:
	 * 1) the current directory 2) \scorest 3) \
	 */
	PrtEnabled = FALSE;
	opened = FALSE;
	if ((fd = Fopen(CFGFILE, 0)) >= 0) {
		opened = TRUE;
	}
	if (!opened) {
		sprintf(fileName, "\\SCOREST\\%s", CFGFILE);
		if ((fd = Fopen(fileName, 0)) >= 0) {
			opened = TRUE;
		}
	}
	if (!opened) {
		sprintf(fileName, "\\%s", CFGFILE);
		if ((fd = Fopen(fileName, 0)) >= 0) {
			opened = TRUE;
		}
	}
	if (!opened) {
		sprintf(str, "[1][%s|%s.|%s|%s][Ok]",
		    "Can't find",
		    CFGFILE,
		    "Printing is",
		    "disabled.");
		form_alert(1, str);
	}

	/* Read the configuration file. */
	if (opened) {
		if (Fread(fd, (long)sizeof(Config), &Config) !=
		    sizeof(Config)) {
			sprintf(str, "[1][%s|%s|%s|%s][Ok]",
			    "%s",
			    "is corrupt.",
			    "Printing is",
			    "disabled.");
			form_alert(1, str);
		}
		else {
			PrtEnabled = TRUE;
		}
		Fclose(fd);
	}
}

/* delLastEnt: Delete the last entity added. This is provided as a
 * convenience to users and doesn't really fit in with anything else.
 */
static void delLastEnt()
{
	RECT2D scsRct, clipRct;
	POINT2D junk;
	register ENTITY *ent;
	extern int getCurPgNum();
	extern ENTITY *fndEntPg();
	extern SYMBOL *CurSym;
	extern RECT2D WinScsRct;

	if (LastEntValid && LastEntPgNum == getCurPgNum()) {
		if ((ent = fndEntPg(LastEntAdded)) != NULL) {
			delEntPg(ent);
			WCSRCTTOSCS(&LastEntAdded->entRct, &scsRct);
			rect_intersect(scsRct, WinScsRct, &clipRct);
			setClipRct(&clipRct);
			drwPg();
			if (CurSym->symClass == TXTSYMCLASS) {
				addSym(&junk, CurSym, 0x0, '\b');
			}
		}
		LastEntValid = FALSE;
	}
}

/* initPalette: Initialize the icon palette and symbol selection. */
static void initPalette()
{
	/* Get a pointer to the icon palette tree. */
	if (rsrc_gaddr(R_TREE, ICONS, &Palette) == 0) {
		Error("Resource file is corrupt.");
	}

	/* Set the palette object's origin so it will be drawn at the
	 * bottom of the screen, centered horizontally.
	 */
	Palette->ob_x = SCSMAXX / 2 - Palette->ob_width / 2;
	Palette->ob_y = SCSMAXY - Palette->ob_height;

	/* Fill in the palette's screen rectangle. */
	COPYRECT((RECT2D *)&Palette->ob_x, &PalScsRct);
}

/* drwPalette: Display the icon palette. */
void drwPalette()
{
	hideMouse();
	objc_draw(Palette, ROOT, 1, Palette->ob_x, Palette->ob_y,
	    Palette->ob_width, Palette->ob_height);
	showMouse();
}
