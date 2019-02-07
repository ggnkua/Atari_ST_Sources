
/* Copyright 1990 by Antic Publishing, Inc. */

/* Tab expansion/compression spacing should be set to '4' in your editor. */

/* NOTE: Watch out for the dialog strings when compressing spaces to tabs!*/

/**************************************************************************
 *
 * picsave.c  Load or Save a screen image as a NEO or DEGAS picture. 
 *
 * Abstract:  The routines in this module allow a picture to be saved or
 *			  loaded in NEO or DEGAS format.  The routines conduct an
 *			  fsel_input dialog with the user to select the filename to be
 *			  loaded.  There is also a routine which allows the filetype
 *			  for a file save to be selected, either by the user (via a
 *			  dialog box), or by the programmatic caller.
 *
 *			  These routines can be used in a couple different ways... 
 *			  The default filetype for picture saves is DEGAS.	If the main
 *			  application is menu-driven, it can put a 'Select Image Format'
 *			  type menu item up, and call the pic_fmtset() routine in 
 *			  response to this menu item, with a flag of PIC_USERSELECT 
 *			  to let the user pick the file format at any time.  
 *			  If the main ap keeps track of user preferences via a 
 *			  preferences file (or whatever), it can set the user's
 *			  preference by calling pic_fmtset() with the appropriate 
 *			  format flag.	If the ap is not event-driven (no menus), 
 *			  another possibility is that pic_fmtset(PIC_USERSELECT) always
 *			  be called before calling pic_save().	
 *
 *			  On a picture load, the format is determined by the size of
 *			  the input file.  A size of 32034 implies a DEGAS file, and
 *			  32128 implies NEO.  When a picture is loaded, the picture
 *			  save format is reset to reflect the type of picture loaded.
 *
 * Author:	  Ian Lepore
 * 
 * Usage:	  See usage notes under pic_save, pic_load, and pic_fmtset.
 *
 * Notes:	  Unlike many 'canned source' modules, this code does NOT
 *			  save and restore the screen via bit-blit.  This is primarily
 *			  due to the use of the file selector, which sends out redraw
 *			  messages that we can't do anything about anyway.
 *
 *			  The only global names exported by this module are the three
 *			  entry-point routines, pic_save(), pic_load(), & pic_fmtset().
 *
 * Environment:
 *
 *			  Developed with Sozobon C v1.1 PD compiler.
 *			  AESFAST v1.2 PD GEM bindings and utilities.  
 *			  Should be compatible with Alcyon, Sozobon, MegaMax, and Laser.
 *
 * Related Modules:
 *
 *			  PICSAVE.H - Header file for programs using this module.
 *			  GEMFAST.H - GEM header file (equiv. to OBDEFS+GEMDEFS).
 *
 * Maintenance:
 * 
 *	07/15/89  v1.0
 *			  Formalized function as a 'cannned source' library routine.
 *	08/25/89  v1.1
 *			  Added prompt that "NEO is for low rez only", and added logic
 *			  so that the prompt only shows up in med/high rez.  Also, 
 *			  added code for compatibility with non-GEMFAST bindings.
 *************************************************************************/

#include "gemfast.h"	/* equivelent to standard OBDEFS.H+GEMDEFS.H */
#include <osbind.h>
#include "picsave.h"

#ifndef NULL
#define NULL		 0L
#endif

#ifndef TRUE
#define TRUE		 1
#define FALSE		 0
#endif

#define IO_SUCCESS	 0
#define IO_CANCEL	 1
#define IO_RETRY	 2

#define FSEL_CANCEL  0
#define FSEL_OK 	 1

#define NEOHDR_LENGTH	 128
#define DEGASHDR_LENGTH  34

#define E_DISKFULL	-128	/* My standard error code for disk full */

#define Getcolor(a)   Setcolor((a),-1)

extern char *strrchr(); 	/* Library routine, returns ptr to char. */

/*-------------------------------------------------------------------------
 * Resource tree stuff for the Picture Format dialog...
 *-----------------------------------------------------------------------*/

static char pfmtstr1[] = " Select file format for saving ";
static char pfmtstr2[] = "      screen-image files.      ";
static char pfmtstr3[] = "   (NEO is for low rez only)   ";
static char pfmtbtn1[] = "NEO";
static char pfmtbtn2[] = "DEGAS";
static char pfmtbtn3[] = "OK";

#define HIDE 0x0080

static OBJECT pfmttree[] = {
   -1,	1,	6, G_BOX,	 NONE, OUTLINED, 0x00021100L,	  0, 0, 33, 11,
	2, -1, -1, G_STRING, NONE, NORMAL,	 (long)pfmtstr1,  1, 1, 31,  1,
	3, -1, -1, G_STRING, NONE, NORMAL,	 (long)pfmtstr2,  1, 2, 31,  1,
	4, -1, -1, G_STRING, HIDE, NORMAL,	 (long)pfmtstr3,  1, 3, 31,  1,
	5, -1, -1, G_BUTTON, 0x11, NORMAL,	 (long)pfmtbtn1,  6, 5,  8,  2,
	6, -1, -1, G_BUTTON, 0x11, SELECTED, (long)pfmtbtn2, 18, 5,  8,  2,
	0, -1, -1, G_BUTTON, 0x27, NORMAL,	 (long)pfmtbtn3, 12, 8,  8,  2
 };

#define PFMTSTLO 3	/* NEO is for lowrez prompt */
#define PFMTBRNF 4	/* NEO	 radio button */
#define PFMTBRDF 5	/* DEGAS radio button */
#define PFMTBXOK 6	/* OK	 exit  button */

/*-------------------------------------------------------------------------
 * Some working variables, all declared as static...
 *-----------------------------------------------------------------------*/

static int	picformat = PIC_DEGASFORMAT; /* must match pre-selected button in pfmttree */

static int	currez; 					/* Current rez, set on each call  */
static char selpath[80];				/* Path set by fsel dialog		  */
static char fullpath[80] = "";			/* Full drive+path+filename 	  */
static char fname[14] = ""; 			/* Filename set by fsel dialog	  */
static char neowildcard[6]	 = "*.NEO"; /* NEO wildcard for fsel		  */
static char degaswildcard[6] = "*.PI?"; /* DEGAS wildcard for fsel		  */

#define DEGASREZ_FILETYPE 4 			/* degaswildcard[4] is rez char   */

static char *neoftype	= &neowildcard[1];		/* Used to build output   */
static char *degasftype = &degaswildcard[1];	/* filename based on type.*/

static char loadprompt[]   = " Load image in "; 	/* These strings are  */
static char saveprompt[]   = " Save image in "; 	/* pieced together to */
static char neoprompt[]    = "NEO format "; 		/* build the fsel	  */
static char degasprompt[]  = "DEGAS format ";		/* dialog prompt.	  */

static union {
		NEOHEADER	 u_neohdr;
		DEGASHEADER  u_degashdr;
		  } fileheader;

#define neoheader	fileheader.u_neohdr
#define degasheader fileheader.u_degashdr
	
/**************************************************************************
 *
 * do_fsel - Conduct a file selector dialog with the user.
 *
 *	Note:	 This routine uses fsel_exinput(), a TOS 1.4 function.	If
 *			 the AESFAST bindings system is used, this will work on any
 *			 release of TOS (AESFAST includes an emulator of the new file
 *			 selector, and uses it if on a pre-1.4 system).
 *
 *			 If you are using GEM bindings that don't support fsel_exinput,
 *			 you won't be including 'gemfast.h' as your header file.  In 
 *			 that case, the #define will change fsel_exinput to fsel_input
 *			 and everything else should compile just fine.
 *
 *************************************************************************/

#ifndef GEMFAST_H
#define fsel_exinput fsel_input
#endif

static int
do_fsel(pprompt)
	char *pprompt;
{
	int  exitbutton;
	char *pwrkchar;

/*
 * On the first call, 'selpath' will be null, since we haven't done a
 * dialog with the user yet.  In this case, build the initial file selector
 * path from the current default drive and path.  If the user changes the
 * path in the file selector, it will remain untouched between fsel calls,
 * so that the user always sees the same path s/he last saw.
 */
   
	if (selpath[0] == 0x00) {
		selpath[0] = 'A' + Dgetdrv();
		selpath[1] = ':';
		Dgetpath(&selpath[2], 0);
		strcat(selpath,"\\");
	}
	
/*
 * Append the appropriate wildcard to the fsel path...
 */
 
	if (picformat == PIC_NEOFORMAT) {
		strcat(selpath, neowildcard);
	}
	else {
		degaswildcard[DEGASREZ_FILETYPE] = '1' + currez;
		strcat(selpath, degaswildcard);
	}
/*
 * Do the fsel dialog.	Upon return, truncate the wildcard info off the
 * end of the path, since the logic above will expect a clean pathname on
 * the next call, even if the user selected CANCEL this time.
 */
 
	fsel_exinput(selpath, fname, &exitbutton, pprompt);

	pwrkchar = strrchr(selpath, '\\');
	if (pwrkchar != NULL) {
		*++pwrkchar = 0x00;
	}

/*
 * If the user hit CANCEL, or failed to enter a filename, return IO_CANCEL.
 */
 
	if (exitbutton == FSEL_CANCEL || fname[0] == 0x00)
		return IO_CANCEL;

	return IO_SUCCESS;	 
}

/**************************************************************************
 *
 * setfmt - Internal routine to set the picture format flag, and force the
 *			dialog box's radio buttons to match.
 *
 *************************************************************************/

static void
setfmt(newformat)
	int newformat;
{

	register OBJECT *ptree = pfmttree;	  
	
	picformat = newformat;

/*
 * Force the radio buttons in the Picture Format selection dialog to conform
 * to the current state of our internal picture format flag.  This keeps
 * everything in sync when the format is changed by a picture load, or by
 * the main application calling pic_fmtset() to force the format.
 */
 
	if (newformat == PIC_NEOFORMAT) {
		ptree[PFMTBRDF].ob_state &= ~SELECTED;		/* de-sel DEGAS */
		ptree[PFMTBRNF].ob_state |=  SELECTED;		/* select NEO	*/
	}
	else {
		ptree[PFMTBRDF].ob_state |=  SELECTED;		/* select DEGAS */
		ptree[PFMTBRNF].ob_state &= ~SELECTED;		/* de-sel NEO	*/
	}

}

/**************************************************************************
 *
 * pic_save - Save a screen image.
 *
 * Usage:	  int status = pic_save(char *scrnimage);
 *
 *			  'scrnimage' is a pointer to a 32000 byte screen image to be
 *			  saved.  To save the current active (displayed) screen, code
 *			  PIC_USEMAINSCREEN in place of the pointer.
 *
 *			  Return status:
 *				-128		  - Disk full (E_DISKFULL).
 *				-64 thru -1   - TOS error code.
 *				0			  - Success.
 *				1			  - User requested cancel.
 *
 *			  These routines do no error prompting or reporting
 *			  to the user; it is the caller's responsibility to handle
 *			  non-zero return codes and invoke retries if appropriate.
 *
 *************************************************************************/

int
pic_save(pscreen)
	char  *pscreen;
{
	register int	*pwrkint;
	register int	counter;
	int 			fhandle;
	int 			status;
	int 			error_detected;
	int 			exitobject;
	int 			dmy;
	long			headerlength;
	char			*pfiletype;
	char			*pwrkchar;
	char			prompt[40];

/*
 * Get current screen rez (used in picture header, and in DEGAS filetype),
 * and, build the first part of the prompt, indicating that a Save Screen
 * is in progress.	If the caller passed us a NULL screen pointer, use the
 * current system screen logical address. 
 */

	currez = Getrez();
	
	strcpy(prompt, saveprompt);

	if (pscreen == PIC_USEMAINSCREEN)
		pscreen = (char *)Logbase();

/*
 * Init the whole fileheader area (128 bytes, in case it's a NEO picture).
 * Based upon the picture format currently set, put the screen rez where
 * it belongs, set the length of the fileheader, and set a pointer to 
 * where within the header the color pallette is stored (it's a couple 
 * bytes further into a NEO header than it is on DEGAS).  Also, we can
 * now finish building the fsel prompt string, based on file format.
 */

	pwrkint = (int *)&fileheader;
	for (counter = 0; counter < 64; counter++) {
			*pwrkint++ = 0;
	}

	if (picformat == PIC_NEOFORMAT) {
		neoheader.rez	= currez;
		headerlength	= NEOHDR_LENGTH;
		pwrkint 		= neoheader.pallete;
		pfiletype		= neoftype;
		strcat(prompt, neoprompt);
	}
	else {
		degasheader.rez = currez;
		headerlength	= DEGASHDR_LENGTH;
		pwrkint 		= degasheader.pallete;
		pfiletype		= degasftype;
		strcat(prompt, degasprompt);
	}

/*
 * Copy the current system color pallete into the fileheader.
 */
 
	for (counter = 0; counter < 16; counter++) {
		*pwrkint++ = Getcolor(counter);
	}

/* 
 * Do the file selector dialog. If the user requested a CANCEL, return now.
 */

	if (IO_CANCEL == do_fsel(prompt,picformat)) {
		return IO_CANCEL;
	}

/*
 * Force the filetype to be .NEO or .PIx, as appropriate to the selected
 * format, regardless of what the user entered.  The 'pfiletype' pointer
 * was set to point to the appropriate type in the code above.
 */

	pwrkchar = strrchr(fname,'.');
	if (pwrkchar != NULL) {
		strcpy(pwrkchar, pfiletype);
	}
	else {	  
		strcat(fname, pfiletype);
	}
	
	strcpy(fullpath, selpath);
	strcat(fullpath, fname);

/*
 * Attempt to create the output file.  If the create fails, return the 
 * failing status code to the caller, who is responsible for error handling.
 */

	status = fhandle = Fcreate(fullpath, 0);
	if (status < IO_SUCCESS) {
		return status;
	}

/*
 * If the file was created OK, write the fileheader.  If that works, write
 * the screen image from the buffer/screen.  Since we now have a file handle
 * open, we can't check or return any error status until after we close
 * the file.
 */
  
	status = Fwrite(fhandle, headerlength, &fileheader);
	if (status == headerlength) {
		status = Fwrite(fhandle, 32000L, pscreen);
	}
	
	Fclose(fhandle);

/*
 * If the file write worked, set the status to indicate that, else delete
 * the file (since it's only a partial or has bad sectors or something).
 * If the status was > 0, we must have run into a full disk, so reset the
 * status to indicate that.
 */
	if (status == 32000) {
		status = IO_SUCCESS;
	}
	else {
		Fdelete(fullpath);
		if (status > IO_SUCCESS) {
			status = E_DISKFULL;
		}
	}	 
	
	return status;
}

/**************************************************************************
 *
 * pic_load - Load a screen image.
 *
 * Usage:	  int status = pic_load(char *scrnimage, int palleteflag);
 *
 *			  'scrnimage' is a pointer to a 32000 byte screen area into 
 *			  which the image is loaded.  To load to the current active 
 *			  (displayed) screen, code PIC_USEMAINSCREEN in place of the 
 *			  pointer.
 *
 *			  The value of 'palleteflag' determines what to do with the
 *			  color pallete stored in the picture file.  If the value is
 *			  PIC_USEPALLETE the pallete from the picture file is loaded
 *			  into the system pallete.	If the value is PIC_NOPALLETE the
 *			  pallete info is simply discarded.
 * 
 *			  Return status:
 *				PIC_WRONGREZ  - Picture to be loaded doesn't match cur rez.
 *				PIC_BADFORMAT - Can't determine picture format to load.
 *				-64 thru -1   - TOS error code.
 *				0			  - Success.
 *				1			  - User requested cancel.
 *
 *			  These routines do no error prompting or reporting
 *			  to the user; it is the caller's responsibility to handle
 *			  non-zero return codes and invoke retries if appropriate.
 *
 *************************************************************************/

int
pic_load(pscreen, pallete_flag)
	char  *pscreen;
	int   pallete_flag;
{
	register int	counter;
	int 			picrez;
	int 			*ppallete;
	int 			fhandle;
	int 			status;
	int 			error_detected;
	int 			exitobject;
	int 			dmy;
	long			headerlength;
	char			*pfiletype;
	char			*pwrkchar;
	char			prompt[40];
	

/*
 * Get current screen rez (used in picture header, and in DEGAS filetype).
 * If the caller passed us a NULL screen pointer, use the current system
 * screen logical address. 
 */

	currez = Getrez();
	
	if (pscreen == PIC_USEMAINSCREEN)
		pscreen = (char *)Logbase();

/*
 * Build the prompt string based upon the currently selected format.
 */
 
	strcpy(prompt, loadprompt);

	if (picformat == PIC_NEOFORMAT) {
		strcat(prompt, neoprompt);
	}
	else {
		strcat(prompt, degasprompt);
	}

/* 
 * Do the file selector dialog. If the user requested a CANCEL, return now,
 * else build the full path/filename from the selector values.
 */

	if (IO_CANCEL == do_fsel(prompt,picformat)) {
		return IO_CANCEL;
	}

	strcpy(fullpath, selpath);
	strcat(fullpath, fname);

/*
 * Attempt to open the input file.	If the open fails, return the failing
 * status code to the caller, who is responsible for error handling.
 */

	status = fhandle = Fopen(fullpath, 0);
	if (status < IO_SUCCESS) {
		return status;
	}

/*
 * If the file was opened OK, check the file length to insure that it's
 * a DEGAS or NEO file.  If it's not, return error status to the caller.
 * If it is, set the current picture format as appropriate, and set 
 * pointers to the rez and pallete info in the header.
 */
 
	status = Fseek(0L, fhandle, 2); 	/* Seek to EOF to get length   */
	Fseek(0L, fhandle, 0);				/* Seek to BOF for later reads */

	headerlength = status - 32000;		/* Filesz - scrnsz = header length */

	switch (headerlength) {
	
	 case NEOHDR_LENGTH:

		setfmt(PIC_NEOFORMAT);
		picrez	 = neoheader.rez;
		ppallete = neoheader.pallete;
		break;

	 case DEGASHDR_LENGTH:

		setfmt(PIC_DEGASFORMAT);
		picrez	 = degasheader.rez;
		ppallete = degasheader.pallete;
		break;

	 default:

		Fclose(fhandle);
		return PIC_BADFORMAT;
	 }

/*
 * If the file was opened OK, read the fileheader.	If the fileheader reads
 * in OK, insure that the rez stored in the fileheader matches the current
 * system rez.
 */
  
	status = Fread(fhandle, headerlength, &fileheader);
	
	if (status != headerlength) {
		Fclose(fhandle);
		if (status < IO_SUCCESS) {
			return status;
		}
		else {
			return PIC_BADFORMAT;	/* This should never happen, but... */
		}
	}
	
	if (picrez != currez) {
		Fclose(fhandle);
		return PIC_WRONGREZ;
	}

/*
 * If the pallete flag indicates that we are to use the pallete stored
 * within the file header, set the system pallete before loading the pic.
 */

	if (pallete_flag == PIC_USEPALLETE) {
		Setpallete(ppallete);
	}

/*
 * OK, finally we can read in the screen image. Note that if the read goes
 * awry, we're gonna have a partital or munged image on the screen, but
 * we leave it up to the caller to do something about it.
 */
  
	status = Fread(fhandle, 32000L, pscreen);
	Fclose(fhandle);

	if (status == 32000L) {
		status = IO_SUCCESS;
	}
	else {
		if (status > IO_SUCCESS) {
			status = PIC_BADFORMAT;
		}
	}
	
	return status;
}

/**************************************************************************
 *
 * pic_fmtset - Set picture save format, or allow user to set format.
 *
 *	Usage:	  void pic_fmtset( int setflag );
 *			 
 *			  'setflag' is one of the following:
 *				PIC_NEOFORMAT
 *				PIC_DEGASFORMAT
 *				PIC_USERSELECT
 *
 *			  This routine sets the format for subsequent picture saves
 *			  to NEO or DEGAS, or puts up a dialog box to allow the user
 *			  to select the desired format.
 *
 *************************************************************************/

void
pic_fmtset(prechoosen)
	int  prechoosen;
{
	register OBJECT *ptree;
	register int	objcounter;
	int 			currez;
	static	 int	initdone = FALSE;
	GRECT			dialrect;

	currez = Getrez();

/*
 * If the caller is asking for a user dialog, fall into the dialog code
 * below, otherwise assume the caller is trying to pre-set the picture
 * format programmatically.  If the pre-set value is invalid, we return
 * without doing anything, else we set the picture format flag.
 */
 
	switch (prechoosen) {
	 case PIC_USERSELECT:
		break;
	 case PIC_NEOFORMAT:
		if (currez != 0) {
			return;
		}
		/* fall thru */
	 case PIC_DEGASFORMAT:
		setfmt(prechoosen);
	 default:
		return;
	}

/*
 * If this is a first-time call, do rsrc_obfix() calls for everything in
 * the picture-format dialog tree.	Also, if we are not in low rez, disable
 * the NEO button.	That makes the entire concept of format selection
 * invalid, but we also un-HIDE a string object which states that NEO is
 * for low rez only, so the user should get the idea.
 */
	ptree = pfmttree;

	if (initdone == FALSE) {
		
		objcounter = -1;
		do	{
			objcounter++;
			rsrc_obfix(ptree, objcounter);
		} while (!(ptree[objcounter].ob_flags & LASTOB));

		if (currez != 0) {
			ptree[PFMTBRNF].ob_state |=  DISABLED;
			ptree[PFMTSTLO].ob_flags &= ~HIDETREE;
		}

		initdone = TRUE;
	}

/* 
 * Do the dialog to let the user select the picture format via radio button.
 */
	
	form_center(ptree, &dialrect.g_x, &dialrect.g_y,
					   &dialrect.g_w, &dialrect.g_h);
				 
	form_dial(FMD_START, 0,0,0,0, dialrect);
	objc_draw(ptree, R_TREE, MAX_DEPTH, dialrect);
	form_do(ptree, 0);
	ptree[PFMTBXOK].ob_state &= ~SELECTED;
	form_dial(FMD_FINISH, 0,0,0,0, dialrect);

/*
 * Set the picture format flag based on which radio button is now selected.
 */

	if (ptree[PFMTBRNF].ob_state & SELECTED)
		picformat = PIC_NEOFORMAT;
	else	
		picformat = PIC_DEGASFORMAT;
		
	return;
}

