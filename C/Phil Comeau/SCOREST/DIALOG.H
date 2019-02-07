/* Dialog:	Definitions used by clients of GEM Objects & Dialogs.
 * phil comeau 29-may-89
 * last edited 11-oct-89 0010
 *
 * Copyright 1990 Antic Publishing Inc.
 *
 */

#ifndef DIALOG_H
#define DIALOG_H

/* Constants. */

#define NIL (-1)			/* undefined object index */

/* Constants used by GetFilename() */
#define GFCANCEL 0			/* File selection cancelled by user
					 */
#define GFOK 1				/* File selected by user */
#define MAXFILENAME 128			/* filename size limit */

/* Constants used by GetYN() */
#define GYNYES 1
#define GYNNO 2
#define GYNCANCEL 3

/* Types. */

/* DLGRECT:	Rectangle describing the screen geometry of a Dialog. */
typedef struct {
	int x, y, w, h;
} DLGRECT;

/* SLIDEBAR:	Describes an SlideBar object, used to set an integer 
 *		value using a SlideBar in a dialog.
 */
typedef struct {
	int *value;			/* pointer to value being managed. */
	int lowerLimit;			/* lower value range limit */
	int upperLimit;			/* upper value range limit */
	int smallIncr;			/* small increment value */
	int bigIncr;			/* big increment value */
	int valTxtObj;			/* text object index showing current
					 * value.
					 */
	int slideObj;			/* SlideBar object index */
	int lowerObj;			/* lower button object index */
	int raiseObj;			/* raise button object index */
	int thumbObj;			/* thumb button object index */
	char valStr[6 + 1];		/* place to hold value in ASCII */
	BOOLEAN horizontal;		/* TRUE if SlideBar is horizontal */
} SLIDEBAR;

/* SELECTOR:	Describes a Selector object, used to make selections from a
 *		collection of items.
 */
typedef struct {
	SLIDEBAR slideBar;		/* Selector's SlideBar */
	int nFields;			/* # fields in Selector */
	int *fieldObjs;			/* array of field object indexes */
	int nItems;			/* # items we can select from */
	char **items;			/* array of ptrs to items */
	BOOLEAN *itemSel;		/* itemSel[i] TRUE if items[i]
					 * selected
					 */
	int item1;			/* index of 1st visible item in
					 * items[]
					 */
	int maxItem1X;			/* largest index of 1st visible item
					 */
	int fieldWd;			/* width of a field in chars */
} SELECTOR;

/* Macros. */

/* GETOBJSTATE:	Return an object's current state. */
#define GETOBJSTATE(tree, obj) ((tree)[(obj)].ob_state)

/* GETOBJTYPE:	Return an object's type. */
#define GETOBJTYPE(tree, obj) ((tree)[(obj)].ob_type)

/* GETOBJFLAGS:	Return an object's flags. */
#define GETOBJFLAGS(tree, obj) ((tree)[(obj)].ob_flags)

/* GETOBJSPEC:	Return a pointer to an object's spec field */
#define GETOBJSPEC(tree, obj) ((tree)[(obj)].ob_spec)

/* GETOBJDLGRECT:	Return a pointer to a DLGRECT describing an object.
 *			Note that this DLGRECT may be relative to the
 *			object's parent.
 */
#define GETOBJDLGRECT(tree, obj) ((DLGRECT *)&(tree)[(obj)].ob_x)

/* ISOBJSEL:	Return TRUE if an object is selected. */
#define ISOBJSEL(tree, obj) ((GETOBJSTATE(tree, obj) & SELECTED) != 0)

/* SELOBJ:	Change an object's state to SELECTED. */
#define SELOBJ(tree, obj) GETOBJSTATE(tree, obj) |= SELECTED;

/* DESELOBJ:	Change an object's state to not SELECTED. */
#define DESELOBJ(tree, obj) GETOBJSTATE(tree, obj) &= ~SELECTED;

/* GETTED:	Returns a pointer to the TEDINFO structure associated with
 *		an object, given the object's tree and index.
 */
#define GETTED(tree, obj) ((TEDINFO *)(tree)[(obj)].ob_spec)

/* GETTEDTEXT:	Return a pointer to the text part of a TEDINFO field. */
#define GETTEDTEXT(tree, obj) (GETTED(tree, obj)->te_ptext)

/* GETTEDTMPLT:	Return a pointer to the template part of a TEDINFO field. */
#define GETTEDTMPLT(tree, obj) (GETTED(tree, obj)->te_ptmplt)

/* GETTEDLEN:	Return the length of a TEDINFO field. */
#define GETTEDLEN(tree, obj) (GETTED(tree, obj)->te_txtlen)

/* SETTEDTEXT:	Set the text address and length in a TEDINFO field. */
#define SETTEDTEXT(tree, obj, str, len) GETTED(tree, obj)->te_ptext = (str), \
    GETTED(tree, obj)->te_txtlen = (len)

/* SETTEDTMPLT:	Set the template address and length in a TEDINFO field. */
#define SETTEDTMPLT(tree, obj, str, len) GETTED(tree, obj)->te_ptmplt = \
    (str), GETTED(tree, obj)->te_tmplen = (len)

/* TEDTEXTTOINT:	Return the binary value of a TEDINFO text field. */
#define TEDTEXTTOINT(tree, obj) atoi(GETTED(tree, obj)->te_ptext)

/* Function Definitions. */
extern void DlgDisplay();
extern int DlgExecute();
extern void DlgErase();
extern void DlgDeselect();
extern void DlgSelect();
extern void DlgRedraw();
extern void Error();
extern int GetFilename();
extern int GetYN();
extern void SelectorSet();
extern BOOLEAN SelectorExec();
extern void SlideBarSet();
extern BOOLEAN SlideBarExec();
extern void Warning();

#endif DIALOG_H
