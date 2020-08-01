/*
 * Demonstration program for using the MagiCMac kernel API.
 *
 * Below you'll also find some code to access XCMD modules.
 *
 * Note about compilation:
 *  Disable stack checking, otherwise you might get a runtime
 *  error when Supexec is executed.
 *
 * Set TABs to 4
 *
 * Change History:
 *  18 June 96: "makeFileSpec" (now: "makeFSSpecFromPath")
 *              updated for MagiCMac 2.0 */

#define USE_XCMD	/* set only if MagiCMac-XCMDs are used, too */

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <tos.h>
#include "MGMC_API.H"
#include "SND_DEMO.H"
#include "..\ERRORS.H"
#include "..\MGMC_XFS\MAC_XFS.H"

/*
 * Attention:
 * If the following header file is missing,
 * disable the declaration of "USE_XCMD" (see above)!
 */
#ifdef USE_XCMD
	#include "..\XCMDDEMO\DEMOXCMD.h"
#else
	typedef struct {
		short	vRefNum;
		long	parID;
		char	name[64];	/* 0-terminated string */
	} FileSpec;
#endif

extern void TempleMon (void) 0x4AFC;	/* this calls the ATARI debugger when in ATARI mode */
/*
 * -----------
 * global vars
 * -----------
 */

MgMcCookie *gMgMcCookie;	/* referenced in MACCALLS.C */

/*
 * ----------------
 * helper functions
 * ----------------
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

static char* p2cstr (unsigned char* str)
/* converts a Pascal string into a C string */
{
	register short len;
	register unsigned char *d = str, *s = str;

	len = *s++;
	while (len--) {
		*d++ = *s++;
	}
	*d = 0;
	return (char*)str;
}

static unsigned char* c2pstr (char* str)
/* converts a C string into a Pascal string */
{
	register short len;
	register unsigned char *d, *s;

	len = strlen (str);
	d = (unsigned char*) str+len+1;
	s = (unsigned char*) str+len;
	while (len--) {
		*(--d) = *(--s);
	}
	str[0] = len;
	return (unsigned char*)str;
}

static void makeFSSpecFromFileSpec (FSSpec *out, FileSpec *in)
{
	/* convert FileSpec to FSSpec: the name must */
	/* be converted from a C to a Pascal string  */
	out->vRefNum = in->vRefNum;
	out->parID = in->parID;
	strcpy ((char*)out->name, in->name);
	c2pstr ((char*)out->name);
}

static void makeFileSpecFromFSSpec (FileSpec *out, FSSpec *in)
{
	/* convert FSSpec to FileSpec: the name must */
	/* be converted from a Pascal to a C string  */
	out->vRefNum = in->vRefNum;
	out->parID = in->parID;
	strncpy (out->name, (char*)in->name, in->name[0]+1);
	p2cstr ((unsigned char*)out->name);
}

static Boolean makeFSSpecFromPath (FSSpec *spec, char *filename)
/*
 * Creates a Macintosh file specification ("FSSpec")
 * from a GEMDOS path.
 *
 * In: file name with path, Out: FSSpec
 * Returns true (1) if the file's path is valid and on
 * a Macintosh volume, otherwise returns false (0).
 */
{
	long result;
	
	/* preset the FileSpec with defaults */
	spec->vRefNum = 0;
	spec->parID = 0;
	spec->name[0] = 0;
	
	/* Try to get the FSSpec with the new Dcntl function */
	/* that is available in MagiCMac 2.0 and above,      */
	/* because it recognizes & converts Umlauts.         */
	{
		MMEXRec mmex;

		/* get the FSSpec using the Dcntl() function */
		mmex.funcNo = MMEX_GETFSSPEC;
		mmex.destPtr = spec;
		result = Dcntl (FMACMAGICEX, filename, (long)&mmex);

		if (result == E_OK) {
			/* FSSpec is valid. Return it */
			return true;
		} else if (result != EINVFN) {
			/* the Dcntl function exists but returned some error */
			return false;
		}
	}
	
	/* The Dcntl function didn't work so we're running on    */
	/* a MagiCMac version before 2.0. In this case Umlauts   */
	/* are not converted by the MM-XFS and so we don't care  */
	/* either. We use the alternate way to get the FileSpec: */
	{
		char *nameStart;
		char path[256];
		long pathlength;
		XATTR xa_dir;
	
		/* first, find the end of the path in the file name */
		nameStart = strrchr (filename, '\\');
		if (nameStart == NULL) {
			nameStart = strrchr (filename, ':');
			if (nameStart == NULL) {
				nameStart = filename;
			} else {
				++nameStart;
			}
		} else {
			++nameStart;
		}
		
		/* copy the path to a local variable */
		pathlength = nameStart - filename;
		if (pathlength > sizeof (path)-1) pathlength = sizeof (path)-1;
		strncpy (path, filename, pathlength);
		path[pathlength] = 0;	/* 0-terminate the string */
		
		/* inquire the MacOS Volume ID and Directory ID of the path */
		result = Fxattr (0, path, &xa_dir);	/* 0: resolve symlinks */
		if (result != E_OK) return false;
		
		/* is it a MacOS volume? */
		if ((signed)xa_dir.dev >= 0) return false;
		
		/* now we can set up the FileSpec */
		spec->vRefNum = xa_dir.dev;
		spec->parID = xa_dir.index;
		strncpy ((char*)spec->name, nameStart, sizeof (spec->name));
		return true;
	}
}

#define	_bootdev 0x446L	/* default boot device */

static long get_bootdev (void)
/*
 * Return the drive number MagiC was booted from.
 * Must be called in Supervisor mode.
 */
{
	return *(short*)_bootdev;
}

/*
 * main function
 */

void main (void)
{
	char byte;
	long result;
	MacVersion *ver;
	XATTR xa_file, xa_dir;
	
	gMgMcCookie = (MgMcCookie*)getCookie ('MgMc');
	if (!gMgMcCookie) {
		printf ("Error: no MgMc cookie -- program isn't running on MagiCMac\n");
		exit (1);
	}
	
	/* display some MagiCMac specific information... */
	printf ("Version of the MgMc cookie: %x.%02x\n", gMgMcCookie->vers >> 8, gMgMcCookie->vers & 0xff);
	
	ver = gMgMcCookie->versionOfMacAppl;
	if (ver != NULL) {
		char ch;
		printf ("Version of the MagiCMac application: %x.%d.%d", ver->vm, ver->vn>>4, ver->vn&15);
		switch (ver->vt) {
			case 0x20: ch = 'd'; break;
			case 0x40: ch = 'a'; break;
			case 0x60: ch = 'b'; break;
			default:   ch = 0;
		}
		if (ch) {
			printf ("%c%x\n", ch, ver->vd);
		} else {
			printf ("\n");
		}
	}

	if (gMgMcCookie->vers >= 0x0105) {	/* before v1.05 the flags1 were set incorrect */
		printf ("Some static information:\n");
		printf ("  Running under ATARI screen emulation: %s.\n",
			(gMgMcCookie->flags1 & (1<<emulAtariScreenBit))?"Yes":"No");
		printf ("  Right & left shift keys return %s scan codes.\n",
			(gMgMcCookie->flags1 & (1<<distinctShiftKeysBit))?"distinct":"same");
			printf ("  A %s-button mouse is connected to this Macintosh.\n",
				(gMgMcCookie->flags1 & (1<<realTwoButtonMouseBit))?"two":"one");
		printf ("  The native CPU is a ");
		if ((gMgMcCookie->flags1 & (1<<runningOn68KEmulatorBit))) {
			printf ("PowerPC, emulating a ");
		}
		printf ("680%ld.\n", getCookie ('_CPU'));
	}

	if (gMgMcCookie->vers >= 0x0107) {
		short n;
		for (n=0; n<=1; ++n) {
			if (gMgMcCookie->floppyDrvInfoPtr[n].inserted) {
				printf ("Disk in drive %c has %s density format\n", (char)n+'A',
					gMgMcCookie->floppyDrvInfoPtr[n].highDensity?"high":"double");
			} else {
				printf ("No disk in drive %c\n", (char)n+'A');
			}
		}
	}

	/*
	 * Let's get some file information about our directory
	 * and this program.
	 */
	result = Fxattr (1, ".", &xa_dir); /* "." is current path */
	printf ("Fxattr \".\": %ld, index: %ld\n", result, xa_dir.index);
	result = Fxattr (1, "API_DEMO.TOS", &xa_file);
	printf ("Fxattr \"API_DEMO.TOS\": %ld, index: %ld\n", result, xa_file.index);

	/*
	 * Try out the "ext" functions
	 */
	if (gMgMcCookie->ext != NULL) {
		GenProc call = gMgMcCookie->ext;	/* make a copy for easier use */
		short maxExt = call (extMax, NULL);
		printf ("Number of kernel support functions: %d\n", maxExt);

		/*
		 * Show a Mac alert box - can be used when there's no way to
		 * use a AES dialog, e.g. in a driver:
		 */
		if (maxExt >= extAlert) {
				call (extAlert, "This is just a test.\r\rThis in line 3");
		}

		/*
		 * This shows how to convert a valid MacOS FSSpec to a GEMDOS path.
		 */
		if (maxExt >= extFSSpecToPath) {
			FSSpecToPathRec rec;
			long err;
			/* first we have to generate a valid FSSpec */
			makeFSSpecFromPath (&rec.specIn, "API_DEMO.TOS");	/* simply take our file name */
			/* now we can get the full path back from the FSSpec */
			err = call (extFSSpecToPath, &rec);
			if (err) {
				printf ("Error: Could not convert a FSSpec to a path.\n");
			} else {
				printf ("The full GEMDOS path of this program: %s\n", rec.pathOut);
			}
		}
	}

#ifdef USE_XCMD
	/*
	 * Call XCMD (the XCMD with the name "Demo XCMD" must be put
	 * into a folder named "MagiCMac XCMDs" inside the folder where
	 * the MagiCMac application resides. Alias files to the original
	 * XCMD file are allowed.
	 */
	if (gMgMcCookie->xcmdMgrPtr != NULL) {
		/* find and open the XCMD */
		XCMDMgrRec *xcmd = gMgMcCookie->xcmdMgrPtr;
		XCMDHdl hdl = xcmd->open ("Demo XCMD");
		if ((long)hdl < 0) {
			printf ("The Demo XCMD is not installed!\n");
		} else {
			short button;

			/* beep */
			printf ("Calling the Demo XCMD function #0...\n");
			xcmd->call (hdl, 0, NULL);
			
			/* display a Macintosh dialog */
			printf ("Calling the Demo XCMD function #1...\n");
			button = xcmd->call (hdl, 1, "Hello World!");
			printf ("The button with ID #%d was pressed.\n", button);
			
			/* create File IDs for all entries in the current dir. */
			{
				CreateFileIDsRec fid;
				fid.dirID = xa_dir.index;
				fid.vRefNum = xa_dir.dev;
				printf ("Calling the Demo XCMD function #2...\n");
				result = xcmd->call (hdl, xcmdCreateFileIDs, &fid);
				if (result != 0) {
					printf ("Error: %ld\n", result);
				} else {
					printf ("OK. All files in this dir should now have a File ID\n");
				}
			}
			
			/* resolve the File ID that we received above */
			{
				ResolveFileIDRec fid;
				fid.fileID = xa_file.index;
				fid.vRefNum = xa_file.dev;
				printf ("Calling the Demo XCMD function #3...\n");
				result = xcmd->call (hdl, xcmdResolveFileID, &fid);
				if (result != 0) {
					printf ("Error: %ld\n", result);
				} else {
					printf ("File name: %s, parent ID: %ld\n", fid.name, fid.parID);
				}
			}

			/* Get type & ceator of a file in the MagiC folders */
			/* Please note: In MagiCMac 2.x you can get the T&C */
			/* with new Dcntl functions. See XFS_DEMO.C         */
			{
				FileInfoRec fi;
				FSSpec macSpec;
				char filename[128];
				/*
				 * Use some file name. We look for MAGX.INF here
				 * because that should always be found in the
				 * root directory of the boot drive. Alternatvely
				 * we could use "fsel_input" here to ask for a
				 * file name.
				 */
				strcpy (filename, "_:\\MAGX.INF");
				filename[0] = 'A' + (char)Supexec(get_bootdev);
				if (!makeFSSpecFromPath (&macSpec, filename)) {
					printf ("Error: Can't create FSSpec for '%s'.\n", filename);
				} else {
					makeFileSpecFromFSSpec (&fi.spec, &macSpec);
					printf ("Calling the Demo XCMD function #4 to ask for T&C of '%s'...\n", filename);
					result = xcmd->call (hdl, xcmdGetFileInfo, &fi);
					if (result != 0) {
						printf ("Error: %ld\n", result);
					} else {
						char t[5], c[5];
						strncpy (c, (char*)&fi.creator, 4); c[4]=0;
						strncpy (t, (char*)&fi.type, 4); t[4]=0;
						printf ("File name '%s': creator %s, type %s\n",
								filename, c, t);
					}
				}
			}
				
			xcmd->close (hdl);
		}
	} else {
		/* XCMDs are not supported before v1.2.2 */
	}
#endif

	/* Invert switch for giving CPU time to Macintosh applications */
	if (gMgMcCookie->configKernel) {	/* ignore the compiler warning here! */
		/* first, get the current setting */
		byte = -1;
		result = gMgMcCookie->configKernel (2, &byte);
		if (result == -1) {
			printf ("Subcode 2 of ConfigKernel function not implemented.\n");
		} else {
			byte = 1 - result;	/* invert the flag (0<->1) */
			gMgMcCookie->configKernel (2, &byte);
			printf ("From now on Macintosh applications will get %s CPU time.\n", byte?"some":"no");
		}
	} else {
		printf ("ConfigKernel function not implemented.\n");
	}
	

	/* Switch to Mac side */
	if (gMgMcCookie->configKernel) {	/* ignore the compiler warning here! */
		byte = 2;
		result = gMgMcCookie->configKernel (5, &byte);
		if (result == -1) {
			printf ("Subcode 5 of ConfigKernel function not implemented.\n");
		}
	}
	
	PlayAMacSound ();

	exit (0);
}

/* EOF */
