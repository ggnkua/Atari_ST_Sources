/* option: Functions to set the user's options
 * phil comeau 31-jan-88
 * last edited 12-jul-89 0005
 *
 * Copyright 1988 by Phil Comeau
 * Copyright 1989, 1990 Antic Publishing Inc.
 */

#include <stdio.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <mylib.h>
#include <dialog.h>
#include <graphics.h>
#include "graph.h"
#include "scorest.h"
#include "menu.h"

/* SELINT: Structure associating an integer value with a selectable object
 * in an object tree.
 */
typedef struct {
	int objId;			/* Id of the selectable object. */
	int selVal;			/* Integer value associated with
					 * the object.
					 */
} SELINT;

/* Global data. */
static SELINT lnWdSel[] = {
	{LNWD1, 1}, {LNWD3, 3}, {LNWD5, 5}, {LNWD7, 7}, {LNWD9, 9},
	{LNWD11, 11}, {LNWD13, 13}, {LNWD15, 15}, {-1, -1}
};
static SELINT lnPatSel[] = {
	{LNPATSOL, SOLIDLNPAT}, {LNPATDOT, DOTTEDLNPAT},
	{LNPATDSH, DASHEDLNPAT}, {-1, -1}
};
static SELINT lnEndSel[] = {
	{LNENDSQR, SQUAREEND}, {LNENDRND, ROUNDEND},
	{LNENDARW, ARROWEND}, {-1, -1}
};
static SELINT txtSzSel[] = {
	{TXSZ8, 8}, {TXSZ9, 9}, {TXSZ10, 10}, {TXSZ16, 16},
	{TXSZ18, 18}, {TXSZ20, 20}, {-1, -1}
};
static SELINT txtAtSel[] = {
	{TXSTYBLD, THICKTEXT}, {TXSTYLT, LIGHTTEXT},
	{TXSTYITL, ITALICTEXT}, {TXSTYUL, UNDRLNTEXT},
	{TXSTYOL, OUTLNTEXT}, {-1, -1}
};

extern FILE *Debug;

/* initOpt: Initialize option selection by marking the default attributes
 * as "selected."
 */
initOpt()
{
	OBJECT *formObj;
	BOOLEAN fndSelVal();
	int objId;
	register int bit, attrMask;
	extern LINESTYLE LineStyle;
	extern TXTSTYLE TxtStyle;

	rsrc_gaddr(R_TREE, LNWDDLG, &formObj);
	if (fndSelVal(LineStyle.lnW, lnWdSel, &objId)) {
		SELOBJ(formObj, objId);
	}

	rsrc_gaddr(R_TREE, LNPATDLG, &formObj);
	if (fndSelVal(LineStyle.lnPat, lnPatSel, &objId)) {
		SELOBJ(formObj, objId);
	}

	rsrc_gaddr(R_TREE, LNENDDLG, &formObj);
	if (fndSelVal(LineStyle.lnEnd, lnEndSel, &objId)) {
		SELOBJ(formObj, objId);
	}

	rsrc_gaddr(R_TREE, TXSZDLG, &formObj);
	if (fndSelVal(TxtStyle.txtSz, txtSzSel, &objId)) {
		SELOBJ(formObj, objId);
	}

	rsrc_gaddr(R_TREE, TXSTYDLG, &formObj);
	attrMask = 0x1;
	for (bit = 0; bit < 16; ++bit) {
		if (fndSelVal(TxtStyle.txtAttr & attrMask, txtAtSel,
		    &objId)) {
			SELOBJ(formObj, objId);
		}
		attrMask <<= 1;
	}
}

/* lnWdOpt: Supervise the user's selection of a new line width. */
lnWdOpt()
{
	OBJECT *lnWdForm;
	GRECT formRct;
	int newLnWd, exitBtn;
	BOOLEAN fndSelInt();
	extern LINESTYLE LineStyle;

	rsrc_gaddr(R_TREE, LNWDDLG, &lnWdForm);
	DlgDisplay(lnWdForm, &formRct);
	if ((exitBtn = DlgExecute(lnWdForm)) == LNWDOK) {
		if (fndSelInt(lnWdForm, lnWdSel, &newLnWd)) {
			LineStyle.lnW = newLnWd;
		}
	}
	DESELOBJ(lnWdForm, exitBtn);
	DlgErase(lnWdForm, &formRct);
}

/* lnPatOpt: Supervise the user's selection of a new line pattern. */
lnPatOpt()
{
	OBJECT *lnPatForm;
	GRECT formRct;
	int newLnPat, exitBtn;
	BOOLEAN fndSelInt();
	extern LINESTYLE LineStyle;

	rsrc_gaddr(R_TREE, LNPATDLG, &lnPatForm);
	DlgDisplay(lnPatForm, &formRct);
	if ((exitBtn = DlgExecute(lnPatForm)) == LNPATOK) {
		if (fndSelInt(lnPatForm, lnPatSel, &newLnPat)) {
			LineStyle.lnPat = newLnPat;
		}
	}
	DESELOBJ(lnPatForm, exitBtn);
	DlgErase(lnPatForm, &formRct);
}

/* lnEndOpt: Supervise the user's selection of a new line endstyle. */
lnEndOpt()
{
	OBJECT *lnEndForm;
	GRECT formRct;
	int newLnEnd, exitBtn;
	BOOLEAN fndSelInt();
	extern LINESTYLE LineStyle;

	rsrc_gaddr(R_TREE, LNENDDLG, &lnEndForm);
	DlgDisplay(lnEndForm, &formRct);
	if ((exitBtn = DlgExecute(lnEndForm)) == LNENDOK) {
		if (fndSelInt(lnEndForm, lnEndSel, &newLnEnd)) {
			LineStyle.lnEnd = newLnEnd;
		}
	}
	DESELOBJ(lnEndForm, exitBtn);
	DlgErase(lnEndForm, &formRct);
}

/* txtSzOpt: Supervise the user's selection of a new text size. */
txtSzOpt()
{
	OBJECT *txtSzForm;
	GRECT formRct;
	int newTxtSz, exitBtn;
	BOOLEAN fndSelInt();
	extern TXTSTYLE TxtStyle;

	rsrc_gaddr(R_TREE, TXSZDLG, &txtSzForm);
	DlgDisplay(txtSzForm, &formRct);
	if ((exitBtn = DlgExecute(txtSzForm)) == TXSZOK) {
		if (fndSelInt(txtSzForm, txtSzSel, &newTxtSz)) {
			TxtStyle.txtSz = newTxtSz;
		}
	}
	DESELOBJ(txtSzForm, exitBtn);
	DlgErase(txtSzForm, &formRct);
}

/* txtAtOpt: Supervise the user's selection of text attributes. */
txtAtOpt()
{
	OBJECT *txtAtForm;
	GRECT formRct;
	register int newTxtAt, exitBtn;
	register SELINT *pSelInt;
	extern TXTSTYLE TxtStyle;

	rsrc_gaddr(R_TREE, TXSTYDLG, &txtAtForm);
	DlgDisplay(txtAtForm, &formRct);
	if ((exitBtn = DlgExecute(txtAtForm)) == TXSTYOK) {

		/* Set the attribute bit associated with each selected
		 * text attribute.
		 */
		newTxtAt = 0x0;
		for (pSelInt = txtAtSel; pSelInt->objId >= 0; ++pSelInt) {
			if (ISOBJSEL(txtAtForm, pSelInt->objId)) {
				newTxtAt |= pSelInt->selVal;
			}
		}
		TxtStyle.txtAttr = newTxtAt;
	}
	DESELOBJ(txtAtForm, exitBtn);
	DlgErase(txtAtForm, &formRct);
}

/* gridOpt: Toggle the grid superimposed over the drawing surface. */
gridOpt()
{
	extern MNUACT GridOnMnuAct[], GridOffMnuAct[];
	extern BOOLEAN ShowGrid;
	extern RECT2D WinScsRct;

	if ((ShowGrid = !ShowGrid)) {
		execMnuAct(GridOnMnuAct);
	}
	else {
		execMnuAct(GridOffMnuAct);
	}
	setClipRct(&WinScsRct);
	drwPg();
}

/* fndSelInt: Locate the first selected object in a tree from an array of
 * selectable objects and pass back an integer value associated with that
 * object. The end of the array is marked by a negative object id. If no
 * objects are selected, FALSE is returned.
 */
BOOLEAN fndSelInt(tree, selInt, intVal)
register OBJECT *tree;
register SELINT *selInt;
register int *intVal;
{
	while (selInt->objId >= 0) {
		if (ISOBJSEL(tree, selInt->objId)) {
			*intVal = selInt->selVal;
			return (TRUE);
		}
		++selInt;
	}

	return (FALSE);
}

/* fndSelVal: find a value associated with an object id and pass back the
 * object id. Returns TRUE if the value was found.
 */
BOOLEAN fndSelVal(val, selInt, objId)
register int val;
register SELINT *selInt;
register int *objId;
{
	while (selInt->objId >= 0) {
		if (val == selInt->selVal) {
			*objId = selInt->objId;
			return (TRUE);
		}
		++selInt;
	}
	return (FALSE);
}
