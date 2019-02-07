/* Dialog:	Functions for manipulating Dialogs.
 * phil comeau 14-jun-89
 * last edited 11-oct-89 0003
 *
 * Copyright 1990 Antic Publishing Inc.
 */

#include <stdio.h>
#include <strings.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include <mylib.h>
#include <dialog.h>

/* DlgDisplay:	Display a Dialog tree. */
void DlgDisplay(tree, rect)
OBJECT *tree;
DLGRECT *rect;
{
	form_center(tree, &rect->x, &rect->y, &rect->w, &rect->h);
	form_dial(FMD_START, rect->x, rect->y, rect->w, rect->h,
	    rect->x, rect->y, rect->w, rect->h);
	objc_draw(tree, ROOT, MAX_DEPTH, rect->x, rect->y, rect->w, rect->h);
}

/* DlgErase:	Erase a Dialog from the screen. */
void DlgErase(tree, rect)
OBJECT *tree;
register DLGRECT *rect;
{
	form_dial(FMD_FINISH, rect->x, rect->y, rect->w, rect->h,
	    rect->x, rect->y, rect->w, rect->h);
}

/* DlgExecute:	Allow user to interact with a Dialog. The Dialog must be
 *		on the screen. Returns the index of the object that caused
 *		the Dialog to exit.
 */
int DlgExecute(tree)
OBJECT *tree;
{
	return (form_do(tree, 0));
}

/* DlgSelect:	Select an object in a dialog. If redraw is TRUE, the
 *		object will be redisplayed.
 */
void DlgSelect(tree, obj, redraw)
register OBJECT *tree;
int obj;
BOOLEAN redraw;
{
	/* Lop off object's high bit in case it was double-clicked. */
	obj &= 0x7fff;

	objc_change(tree, obj, 0, tree->ob_x, tree->ob_y, tree->ob_width,
	    tree->ob_height, GETOBJSTATE(tree, obj) | SELECTED, redraw);
}

/* DlgDeselect:	Deselect an object in a dialog. If redraw is TRUE, the
 *		object will be redisplayed.
 */
void DlgDeselect(tree, obj, redraw)
register OBJECT *tree;
int obj;
BOOLEAN redraw;
{
	/* Lop of object's high bit in case it was double-clicked. */
	obj &= 0x7fff;

	objc_change(tree, obj, 0, tree->ob_x, tree->ob_y, tree->ob_width,
	    tree->ob_height, GETOBJSTATE(tree, obj) & ~SELECTED, redraw);
}

/* Error:	Display an error alert and exit. The error message is
 *		limited to 32 characters.
 */
void Error(msg)
char *msg;
{
	char str[80];

	sprintf(str, "[3][%s][Ok]", msg);
	form_alert(1, str);
	exit(1);
}

/* Warning:	Display a warning alert. The alert message is limited to
 *		32 characters.
 */
void Warning(msg)
char *msg;
{
	char str[80];

	sprintf(str, "[1][%s][Ok]", msg);
	form_alert(1, str);
}

/* GetFilename:	Supervise file selection dialog with user. Displays a file
 *		selection form and constructs a pathname from the user's
 *		selection. "pattern" is a template used to match files, like
 *		"*.C". "pathname" contains an empty string the first time,
 *		and the pathname of the last file selected subsequent times.
 *		Returns the pathname and the button used to terminate the
 *		file selection dialog.
 */
int GetFilename(pattern, pathname)
char *pattern, *pathname;
{
	char path[MAXFILENAME], file[MAXFILENAME], *p;
	int button;

	/* Extract the path from the input pathname. */
	if ((p = rindex(pathname, '\\')) != NULL) {
		++p;
		strcpy(file, p);
		*p = '\0';
		sprintf(path, "%s%s", pathname, pattern);
	}
	else {

		/* Get the current working directory path */
		sprintf(path, "%c:\\%s", 'A' + (int)Dgetdrv(), pattern);
		*file = '\0';
	}

	/* Get a selection from the user. The user may just change
	 * directories, so we have to wait until a filename is entered.
	 */
	do {
		fsel_input(path, file, &button);
	} while (*file == '\0' && button != GFCANCEL);

	if (button == GFOK) {

		/* Construct a pathname (containing path & filename) from
		 * the values returned by fsel_input
		 */
		strcpy(pathname, path);
		if ((p = rindex(pathname, '\\')) != NULL) {
			*(++p) = '\0';
		}
		strcat(pathname, file);
	}

	return (button);
}
