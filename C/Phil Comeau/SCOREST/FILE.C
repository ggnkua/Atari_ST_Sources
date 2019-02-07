/* file: Functions for dealing with Score files
 * phil comeau 31-jan-88
 * last edited 14-oct-89 0011
 *
 * Copyright 1990 Antic Publishing Inc.
 */

#include <stdio.h>
#include <strings.h>
#include <gemdefs.h>
#include <osbind.h>
#include <mylib.h>
#include <graphics.h>
#include <dialog.h>
#include "graph.h"
#include "scoredef.h"
#include "menu.h"

/* Global variables. */

static BOOLEAN Opened = FALSE;		/* TRUE if a file is currently open.
					 */

extern FILE *Debug;

/* openFile: Supervise the user's selection of an existing file, open the
 * file, and prepare things for its use.
 */
openFile()
{
	char tmpFlNm[FILENAMESZ], str[MAXSTR];
	static MSFORM arwMsForm = {ARROW, {0}},
	    busyMsForm = {HOURGLASS, {0}};
	int selectFile();
	register FILE *fp;
	register BOOLEAN opened, cancel, restored;
	extern BOOLEAN openWind(), rstPgsFile(), FileDirty, PrtEnabled;
	extern MNUACT FOpenMnuAct[], NPrtMnuAct[];
	extern char FileNm[];

	svMsForm();
	strcpy(tmpFlNm, FileNm);
	do {
		restored = cancel = FALSE;

		/* Open the file. */
		do {
			opened = cancel = FALSE;
			if (GetFilename("*.SCO", tmpFlNm) == GFCANCEL) {
				drwPalette();
				return;
			}
			setMsForm(&busyMsForm);
			drwPalette();
			if ((fp = fopen(tmpFlNm, "br")) == NULL) {
				rstMsForm();
				sprintf(str, "[%s][%s|%s][%s|%s]", "2",
				    tmpFlNm, "can't be opened.",
				    "Continue", "Cancel");
				if (form_alert(1, str) == 2) {
					cancel = TRUE;
				}
			}
			else {
				opened = TRUE;
			}
		} while (!opened && !cancel);

		if (cancel) {
			rstMsForm();
			return;
		}

		strcpy(FileNm, tmpFlNm);

		/* Restore the Score contents from the file. */
		if (!rstPgsFile(fp)) {
			rstMsForm();
			sprintf(str, "[%s][%s|%s|%s][%s|%s]", "2", FileNm,
			    "can't be read from.",
			    "It may not be a Score file.",
			    "Continue", "Cancel");
			if (form_alert(1, str) == 2) {
				cancel = TRUE;
			}
		}
		else {
			restored = TRUE;
		}
		fclose(fp);
	} while (!restored && !cancel);

	if (cancel) {

		/* Clean up any mess that may have been created. */
		delPgs();
		rstMsForm();
		return;
	}

	/* Set the initial page to Page 1 */
	setCurPg(1);

	FileDirty = FALSE;

	/* Open the window. */
	if (!openWind()) {
		return;
	}

	execMnuAct(FOpenMnuAct);

	/* Disable printing if printer isn't configured. */
	if (!PrtEnabled) {
		execMnuAct(NPrtMnuAct);
	}
	Opened = TRUE;
	rstMsForm();
}

/* newFile: Create a new file and prepare things for its use. */
newFile()
{
	extern char FileNm[];
	extern BOOLEAN openWind(), FileDirty, PrtEnabled;
	extern MNUACT FOpenMnuAct[], NPrtMnuAct[];

	strcpy(FileNm, "Untitled");

	/* Set the initial page to Page 1 */
	addPg(1);

	FileDirty = FALSE;

	/* Draw the palette. This doesn't have to be done with Open(),
	 * because it's redrawn after the file selection form is closed.
	 */
	drwPalette();

	/* Open the window. */
	if (!openWind()) {
		return;
	}

	execMnuAct(FOpenMnuAct);

	/* Disable printing if the printer isn't configured. */
	if (!PrtEnabled) {
		execMnuAct(NPrtMnuAct);
	}

	Opened = TRUE;
}

/* saveFile: Save the current file to disk, using its current name. */
saveFile()
{
	register BOOLEAN useExisting;
	int doSave();
	char tmpFileNm[FILENAMESZ];
	extern char FileNm[];
	extern BOOLEAN FileDirty;

	useExisting = TRUE;
	if (strcmp(FileNm, "Untitled") == 0) {
		if (GetFilename("*.SCO", tmpFileNm) != GFOK) {
			drwPalette();
			return;
		}
		drwPalette();
		strcpy(FileNm, tmpFileNm);
		useExisting = FALSE;
	}			
	if (doSave(FileNm, useExisting) != DONE) {
		return;
	}

	FileDirty = FALSE;
	updtWinTtl(FALSE);
}

/* svAsFile: Obtain a new name for the current file, then save the file
 * to disk under the new name.
 */
svAsFile()
{
	char tmpFileNm[FILENAMESZ];
	int doSave();
	register BOOLEAN saved, cancel;
	extern char FileNm[];
	extern BOOLEAN FileDirty;

	/* The new filename defaults to the existing one. */
	strcpy(tmpFileNm, FileNm);

	do {
		saved = cancel = FALSE;
		if (GetFilename("*.SCO", tmpFileNm) == GFCANCEL) {
			cancel = TRUE;
		}
		else {
			switch (doSave(tmpFileNm, FALSE)) {
			case DONE:
				strcpy(FileNm, tmpFileNm);
				FileDirty = FALSE;
				saved = TRUE;
				break;
			case RETRY:
				break;
			case CANCEL:
				cancel = TRUE;
				break;
			}
		}
	} while (!saved && !cancel);
	drwPalette();

	updtWinTtl(FALSE);
}

/* closeFile: Close the current file, verifying the user's decision if the
 * file has been modified.
 */
closeFile()
{
	int doClose();

	if (Opened) {
		if (doClose() != CANCEL) {
			Opened = FALSE;
		}
	}
}

/* quitFile: Terminate processing. Close the current file. */
quitFile()
{
	int doClose();
	extern BOOLEAN Quit;

	Quit = TRUE;
	if (Opened) {
		if (doClose() != CANCEL) {
			Quit = TRUE;
		}
		else {
			Quit = FALSE;
		}
	}
}

/* printFileD: Print the current file in draft mode. */
printFileD()
{
	prtPgs(DRAFT);
}

/* printFileF: Print the current file in final mode. */
printFileF()
{
	prtPgs(FINAL);
}

/* doSave: Save the Score information to a disk file. */
int doSave(fileNm, useExisting)
register char *fileNm;
register BOOLEAN useExisting;
{
	register button;
	register FILE *fp;
	char str[MAXSTR];
	static MSFORM busyMsForm = {HOURGLASS, {0}};
	extern BOOLEAN svPgsFile();

	svMsForm();

	/* Open the file. See if it already exists first, and whether this
	 * is legal.
	 */
	setMsForm(&busyMsForm);
	if ((fp = fopen(fileNm, "r")) != NULL) {
		fclose(fp);
		if (!useExisting) {
			rstMsForm();
			sprintf(str, "[%s][%s|%s][%s|%s|%s]", "2", fileNm,
		    	"already exists. Overwrite it?", "Yes", "No",
		    	"Cancel");
			if ((button = form_alert(1, str)) != 1) {

				/* The user doesn't want to use this file,
				 * or wants to cancel the save.
			 	 */
				return (button == 2 ? RETRY : CANCEL);
			}
		}
	}

	if ((fp = fopen(fileNm, "bw")) == NULL) {
		rstMsForm();
		sprintf(str, "[%s][%s|%s|%s|%s][%s]", "3",
		    fileNm, "Can't be written to.",
		    "Try using 'Save as...' to",
		    "select a new file.", "Ok");
		form_alert(1, str);
		return (CANCEL);
	}

	/* Save the pages to the file. */
	if (!svPgsFile(fp)) {
		rstMsForm();
		sprintf(str, "[%s][%s|%s.|%s|%s|%s][%s]", "3",
		    "Can't write to ", fileNm,
		    "The disk may be full.",
		    "Try using 'Save as...' to",
		    "select a new file.", "Ok");
		form_alert(1, str);
		return (CANCEL);
	}

	fclose(fp);
	rstMsForm();
	return (DONE);
}

/* doClose: Close the window. */
int doClose()
{
	char str[MAXSTR], tmpFileNm[FILENAMESZ];
	int doSave();
	register int rc;
	register BOOLEAN useExisting;
	extern MNUACT FCloseMnuAct[];
	extern RECT2D WinScsRct;
	extern BOOLEAN FileDirty;
	extern char FileNm[];

	/* See if the user wants to change his mind. */
	if (FileDirty) {
		sprintf(str, "[%s][%s|%s|%s|%s][%s|%s|%s]", "2", FileNm,
		    "has been modified.",
		    "Do you want to save it",
		    "before closing?", "Yes", "No", "Cancel");
		switch (form_alert(1, str)) {
		case 1:		/* Yes */
			useExisting = TRUE;
			if (strcmp(FileNm, "Untitled") == 0) {
				strcpy(tmpFileNm, FileNm);
				if ((rc = GetFilename("*.SCO", tmpFileNm)) !=
				    DONE) {
					drwPalette();
					return (rc);
				}
				drwPalette();
				strcpy(FileNm, tmpFileNm);
				useExisting = FALSE;
			}			
			if ((rc = doSave(FileNm, useExisting)) != DONE) {
				return (rc);
			}
			break;
		case 2:		/* No */
			break;
		case 3:		/* Cancel */
			return (CANCEL);
		}
	}

	/* Delete all the pages. */
	delPgs();

	clsWind();
	execMnuAct(FCloseMnuAct);

	/* Invalidate the window's rectangle. This will prevent
	 * mouse-rectangle events from occuring.
	 */
	SETRECT(&WinScsRct, 0, 0, 0, 0);

	return (DONE);
}
