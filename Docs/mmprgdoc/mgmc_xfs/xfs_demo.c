/*
 * Demonstration program for some extended Fcntl/Dcntl functions
 * in MagiCMac 2.0 (they work on Mac volumes only!).
 * Also shows how to copy a Macintosh File.
 *
 * By Thomas Tempelmann (tt@muc.de), 18 Jun 96.
 *
 * Set TABs to 4
 */

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>
#include "..\MGMC_API\MgMc_API.h"
#include "MAC_XFS.H"
#include "..\MAGX.H"

#define TempFileName	"TEMPFILE.TMP"
#define SrcMacFileName	"MAC_FILE"		/* a Mac file with rsrc fork */
#define DestMacFileName	"MAC_FILE.BAK"	/* name of duplicate file */

/*
 * additional Fcntl/Dcntl function codes
 */

#define	FSTAT		0x4600	/* Inquires XATTR with Fcntl/Dcntl functions */
#define	FUTIME		0x4603
#define	FTRUNCATE	0x4604

/*
 * support functions
 */

static long getCookie (long theCookie)
/* This function looks for a cookie. Returns 0 if not found. */
{
	long *p = *(long**)0x5A0;
	while (*p != 0) {
		if (*p == theCookie) {
			/* gefunden! */
			return p[1];
		}
		p += 2;
	}
	return 0L;
}

static void checkErr (long err, char *errmsg)
{
	if (err < 0) {
		fprintf (stderr, errmsg);
		fprintf (stderr, "Error code: %ld\n", err);
		exit (1);
	}
}

static void printOSType (long v)
{
	printf ("%c%c%c%c", ((char*)&v)[0], ((char*)&v)[1], ((char*)&v)[2], ((char*)&v)[3]);
}

static void printTC (long type, long creator)
{
	printf ("Type/Creator: ");
	printOSType (type);
	printf ("/");
	printOSType (creator);
	printf ("\n");
}

static void printXATTR (XATTR *xattr)
{
	if (xattr->attr & FA_SUBDIR) {
		/* this is a directory */
		printf ("  vRefNum: %d, dirID: %ld\n", xattr->dev, xattr->index);
	} else {
		/* this is a file */
		printf ("  vRefNum: %d, fileID: %ld\n", xattr->dev, xattr->index);
	}
}

static void ShowFSSpec (char *path)
{
	short err;
	MMEXRec mmex;
	FSSpec spec;

	/* get the FSSpec */
	mmex.funcNo = MMEX_GETFSSPEC;
	mmex.destPtr = &spec;
	err = Dcntl (FMACMAGICEX, path, (long)&mmex);
	printf ("Getting FSSpec record of the following path: \"%s\"\n", path);
	spec.name[spec.name[0]+1] = 0;	/* Pascal-String Null-terminieren */
	if (!err) {
		/* FSSpec anzeigen */
		printf ("  Result: vRefNum %d, dirID %ld, name: %s\n", spec.vRefNum, spec.parID, (char*)spec.name+1);
	} else {
		printf ("  Error: %d\n", err);
	}
	
	/* get the volID/dirID information from Fxattr, too: */
	if (!err) {
		XATTR xattr;
		err = Fxattr (0, path, &xattr);
		checkErr (err, "Fxattr() failed.\n");
		printXATTR (&xattr);
	}
}

static void CopyFork (short infile, short outfile)
/* helper function for CopyMacFile */
{
	long	l;
	char	buf[512];
	do {
		l = Fread (infile, sizeof (buf), buf);
		checkErr (l, "Fread() failed.\n");
		if (l == 0) return;
		l = Fwrite (outfile, l, buf);
		checkErr (l, "Fwrite() failed.\n");
	} while (1);
}

/*
 * CopyMacFile - copies a Macintosh file including resource fork.
 * Keeps file's Type & Creator, Attributes and Modification
 * Time Stamp.
 * Does not handle Symlinks (resolves SymLinks)!
 *
 * Works with Mac XFS of MagiCMac 2.0 and later.
 */
static void CopyMacFile (char *source, char *dest)
{
	long err;
	short infile, outfile;
	FInfo finfo;
	XATTR xattr;
	
	err = Dcntl (FMACGETTYCR, source, (long)&finfo);
	checkErr (err, "Dcntl(FMACGETTYCR) failed.\n");

	err = Fopen (source, FO_READ);
	checkErr (err, "Fopen() failed.\n");
	infile = (short)err;

	/* get Time Stamps and GEMDOS Attributes */
	err = Fcntl (infile, (long)&xattr, FSTAT);
	checkErr (err, "Fcntl(FSTAT) failed.\n");

	err = Fcreate (dest, 0);
	checkErr (err, "Fcreate() failed.\n");
	outfile = (short)err;

	/* Copy data fork */
	CopyFork (infile, outfile);
	
	/* Open resource fork. Copy it, too */
	err = Fcntl (infile, 0L, FMACOPENRES);
	checkErr (err, "Fcntl(FMACOPENRES) on source file failed.\n");
	err = Fcntl (outfile, 0L, FMACOPENRES);
	checkErr (err, "Fcntl(FMACOPENRES) on destination file failed.\n");
	CopyFork (infile, outfile);
	
	/*
	 * Must clear the hasBeenInited flags so that the Mac
	 * Finder will recognize the new file properly:
	 */
	finfo.fdFlags &= 0xFEFF;
	/* Set Finder Info (Type, Creator, Finder Attributes) */
	err = Fcntl (outfile, (long)&finfo, FMACSETTYCR);
	checkErr (err, "Fcntl(FMACSETTYCR) failed.\n");
	
	/* Set Time Stamp */
	Fdatime ((DOSTIME*)&xattr.mtime, outfile, 1);
	
	err = Fclose (outfile);
	checkErr (err, "Fclose() failed.\n");

	/* Set GEMDOS Attributes, set Archive flag */
	Fattrib (dest, 1, xattr.attr | FA_ARCHIVE);

	Fclose (infile);
}

static void Touch (char *path)
/*
 * Sets modification date&time of a file
 * or folder to the current date&time.
 */
{
	short err;
	struct mutimbuf t;
	
	t.modtime = t.actime = Tgettime ();
	t.moddate = t.acdate = Tgetdate ();
	err = Dcntl (FUTIME, path, (long)&t);	/* actime/acdate are not used on Macs */
	checkErr (err, "Dcntl(FUTIME) in Touch() failed.\n");
}

static void GetFeatures (Boolean *isV2, Boolean *futimeOnDirs)
{
	MgMcCookie *mmc;
	
	mmc = (MgMcCookie*)getCookie ('MgMc');
	*isV2 = (mmc->versionOfMacAppl->vm >= 2);
	*futimeOnDirs = (*isV2 && mmc->versionOfMacAppl->vn > 0);
}

/*
 * main function
 */

void main (void)
{
	long	err;
	short	tmpFile;
	XATTR	xattr;
	FInfo	finfo;
	Boolean	isV2, touchOnDirs;
	
	/*
	 * Get features of MagiCMac XFS
	 */
	GetFeatures (&isV2, &touchOnDirs);
	
	if (!isV2) {
		printf ("MagiCMac version is too old for this demo.\nMac XFS functions require MagiCMac 2.0 or later.\n");
		exit (1);
	}

	/*
	 * create a temp file
	 */
	err = Fcreate (TempFileName, 0);
	checkErr (err, "Can't create tmp file\n");
	tmpFile = err;
	
	/*
	 * Get the file's Mac OS infos from the opened file
	 */
	 
	printf ("Using Fcntl() on an open macintosh file:\n");
	
	/* get location of file on Mac volume */
	err = Fcntl (tmpFile, (long)&xattr, FSTAT);
	checkErr (err, "Fcntl(FSTAT) failed.\n");
	printXATTR (&xattr);
	
	/* get type & creator */
	err = Fcntl (tmpFile, (long)&finfo, FMACGETTYCR);
	checkErr (err, "Fcntl(FMACGETTYCR) failed.\n");
	printf ("  Reading: ");
	printTC (finfo.fdType, finfo.fdCreator);

	/* set new type & creator */
	if (finfo.fdType == 'TEXT') finfo.fdType = '.PRG'; else finfo.fdType = 'TEXT';
	printf ("  Setting: ");
	printTC (finfo.fdType, finfo.fdCreator);
	err = Fcntl (tmpFile, (long)&finfo, FMACSETTYCR);
	checkErr (err, "Fcntl(FMACSETTYCR) failed.\n");
	
	Fclose (tmpFile);

	/*
	 * Get the file's Mac OS infos from the closed file
	 */

	printf ("\nUsing Dcntl() on a closed macintosh file:\n");

	/* get location of file on Mac volume */
	err = Dcntl (FSTAT, TempFileName, (long)&xattr); /* same as: err = Fxattr (0, TempFileName, &xattr); */
	checkErr (err, "Fxattr() failed.\n");
	printXATTR (&xattr);

	/* get type & creator */
	err = Dcntl (FMACGETTYCR, TempFileName, (long)&finfo);
	checkErr (err, "Dcntl(FMACGETTYCR) failed.\n");
	printf ("  Reading: ");
	printTC (finfo.fdType, finfo.fdCreator);

	/* set new type & creator */
	if (finfo.fdType == 'TEXT') finfo.fdType = '.PRG'; else finfo.fdType = 'TEXT';
	printf ("  Setting: ");
	printTC (finfo.fdType, finfo.fdCreator);
	err = Dcntl (FMACSETTYCR, TempFileName, (long)&finfo);
	checkErr (err, "Dcntl(FMACSETTYCR) failed.\n");

	/* get type & creator again to verify modification */
	err = Dcntl (FMACGETTYCR, TempFileName, (long)&finfo);
	checkErr (err, "Dcntl(FMACGETTYCR) failed.\n");
	printf ("  Reading: ");
	printTC (finfo.fdType, finfo.fdCreator);

	/* get the FSSpec of the temp file and show it */
	printf ("\n");
	ShowFSSpec (TempFileName);
	
	/* get the FSSpec of the current path (a directory, not a file) */
	printf ("\n");
	ShowFSSpec ("");

	Fdelete (TempFileName);
	
	/*
	 * Copy a Macintosh file with both data and resource forks
	 */
	printf ("\nCopying %s to %s...\n", SrcMacFileName, DestMacFileName);
	CopyMacFile (SrcMacFileName, DestMacFileName);
	printf ("OK.\n\n");
	
	/*
	 * Touch our root directory
	 */
	if (!touchOnDirs) {
		printf ("MagiCMac version is too old for touching the root dir.\n'FUTIME' on directories require MagiCMac 2.0.1 or later.\n");
	} else {
		printf ("Touching the root directory.\n");
		Touch ("\\");
	}
	
	printf ("\nDone.\n");
	exit (0);
}
