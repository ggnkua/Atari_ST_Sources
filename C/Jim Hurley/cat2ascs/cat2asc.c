/*
 * cat2asc - a program to convert a STDCAT catalog file into ascii.
 *
 *             Copyright (c) 1989 by Bob Silliker
 *                   All Rights Reserved
 *
 *                Permission is granted for
 *              unrestricted non-commercial use
 *
 * Usage:
 *	cat2asc <catalog_file>
 *
 * This source is intended to show how to access the information in the
 * catalog file.  This source will work with version 3.X and 4.X files.
 * There is no guarantee that this code will work with future versions
 * of the catalog program (although I will try to maintain compatibility).
 * The code was written for the Megamax Laser C compiler.  With little
 * modification it should compile using any of the compilers for the ST.
 *
 * Make any changes you would like to this code for your own purposes.
 *
 * Version 1.0 - created Feb 16, 1989 by Bob Silliker.
 * Version 1.1 - August 24, 1990 - Jim Hurley 
 *           (jimh@ultra.com, ...!ames!ultra!jimh)
 *           Changed output line to display more information.
 *           Made some structure changes to access bit-fields.
 *           Added osbind.h include.
 *           Changed name from catoasc to cat2asc.
 *           Many small cosmetic changes.
 */

#include <stdio.h>
#include <osbind.h>

#define SIG_STR "STDCAT"

/* define file attribute bit-format */
typedef union {
        struct {
           unsigned r : 1;          /* read-only           */
           unsigned h : 1;          /* hidden              */
           unsigned s : 1;          /* system              */
           unsigned v : 1;          /* volume              */
           unsigned d : 1;          /* directory           */
           unsigned a : 1;          /* archive             */
           unsigned x : 10;         /* reserved + byte pad */
        } part;
        unsigned int realfattr;     /* file attribute area */
} attrinfo;

/*
 * Disk structure.  Contains information for a disk.
 */
typedef struct {
    char volume[14];		/* Volume name.                       */
    long serial;		/* Disk serial number.                */
    long free;			/* Number of bytes free.              */
    long used;			/* Number of bytes used.              */
    int files;			/* Number of files on the disk.       */
    int directories;		/* Number of directories on the disk. */
}   MDISK;

/*
 * File structure.  Contains information for a file or directory.
 */
typedef struct {
    attrinfo attr;		/* File attributes.                     */
    timeinfo time;		/* File modification time.              */
    dateinfo date;		/* File modification date.              */
    long size;			/* Size of file in bytes.               */
    char name[14];		/* File name.                           */
    int flag;			/* Flag to control directory levels.    */
    int comment;		/* Flag to indicate there is a comment. */
}   MFILE;

/*
 * Misc sizes.
 */
#define COMMENT_SIZE 34	         /* Length of a disk or file comment. */
#define MDISK_SIZE sizeof(MDISK) /* Size of a disk structure.         */
#define MFILE_SIZE sizeof(MFILE) /* Size of a file structure.         */
#define SIG_SIZE 12		 /* Length of the signature string.   */

/*
 * Macros for error()
 */
#define ERR_USAGE  0		/* Program usage error.		*/
#define ERR_NOTME  1		/* File is not a catalog file. 	*/
#define ERR_READ   2		/* Read error on a file. 	*/
#define ERR_OPEN   3		/* Open error on a file. 	*/

MDISK disk;  /* Structure that holds the information for the current disk. */

char disk_comment[COMMENT_SIZE];               /* The current disk comment */
char file_comment[COMMENT_SIZE];               /* The current file comment */

int files;       /* Storage for the # of files on the current disk.       */
int directories; /* Storage for the # of directories on the current disk. */
int num_disks;	 /* Current number of disks read in.
                    Same as the disk number. */


main (argc, argv)
int argc;
char *argv[];
{
    int err;
    FILE *infile, *fopen ();

 
    /* If you add command line args then change this. */
    if (argc != 2)
	error (ERR_USAGE, "");

    /* Open the input file for reading. 
       The "br" is binary read where the read routine does what
         is should do which is to read the the information read
         exactly as it is in the file.
    */
    if ((infile = fopen (argv[1], "br")) == NULL)
	error (ERR_OPEN, argv[1]);

    /* Read the catalog and report any errors. */
    if (err = read_cat (infile)) {
	if (err == -1)
	    error (ERR_READ, argv[1]);
	else if (err == -2)
	    error (ERR_NOTME, argv[1]);
    }

    /* normal termination */
    (void) fclose (infile);
    exit(0);
}


/*
 * Read the entire catalog file.
 *
 * The caller passes an open FILE pointer.  The routine reads disk
 * structures and disk comments then calls the read_ent() routine to
 * read the contents of the disk.  When the read_ent() routine returns
 * with a value of 0 the file read pointer points to the next disk
 * structure in the file.  The process is repeated until there is an
 * error or there is no more information in the file.
 *
 * Returns:
 *	 0 - Read catalog ok.
 *	-1 - File read error.
 *	-2 - File not a catalog file.
 */
int
read_cat (fp)
FILE *fp;
{
    int version3;
    char sig[SIG_SIZE];

    num_disks = 0;

    /* Read in catalog signature and check for signature string.
       Should be 'STDCAT VX.X' with a NUL
          termination and an extra filler byte (to 12 bytes).
    */
    (void) fread (sig, SIG_SIZE, 1, fp);
    if (ferror (fp))
	return (-1);

    /* Check to see if the first 6 bytes match. */
    if (strncmp (SIG_STR, sig, 6))
	return (-2);

    /* Check to see if the file is version 3.X. */
    if (sig[8] == '3')
	version3 = 1;
    else
	version3 = 0;

    /* Read the catalog file while there aren't any errors
          and there is more information in the file.
    */
    do {

	/* Get the disk information block. */
	if (fread (&disk, MDISK_SIZE, 1, fp) != 1) {
	    /* Could not read a disk structure. 
               Either there was an error or it was end of file.
	       EOF returns 0 below.
            */
	    if (ferror (fp))
		break;
	    else
		return (0);
	}
	/* Keep track of the current disk number. */
	num_disks++;

	/* Check to see if the file is a version 3.0 file.
           This was when there were no serial numbers in the file.
           The value 0x40000000L is a magic number that should never
              conflict with a valid serial number.
           If you were to print the serial number then check to see if
	      the serial number is this value and don't output
              anything if it is. 
        */
	if (version3)
	    disk.serial = 0x40000000L;

	/* Get the disk comment line. */
	if (fread (disk_comment, COMMENT_SIZE, 1, fp) != 1)
	    break;

	/* Get temporary copies of the file and directory counts.
           This will be used to determine when there are no more 
              files and directories for the current disk.
           Passes this point once for each disk. 
        */
	files = disk.files;
	directories = disk.directories;

	/* Read the contents of this disk 
             and continue to the next disk if there are no errors.
        */
    } while (!read_ent (fp, "", ""));

    /* There was a file i/o error. */
    return (-1);
}


/*
 * Read the contents of an entire disk.
 *
 * The caller passes an open FILE pointer, a path string, and a directory
 * string.  The path string and directory string are combined to form a
 * new path that will be passed onto recursive calls.  A recursive call
 * is made when a directory has been encountered.  The contents of a
 * directory is read in, when encountered, before the rest of the
 * files/directories in the current directory.
 *
 * This routine is recursive and uses up about 300 bytes of stack
 * space per call.
 *
 * Returns:
 *	 0 - Read all files at current directory level.
 *	-1 - File read error.
 */
int
read_ent (fp, current_path, directory)
FILE *fp;
char *current_path, *directory;
{
    char new_path[256];
    MFILE file;

    /* Build the path.
       If the directory is zero length then this is the root level
         otherwise combine the current path with the new directory.
    */
    if (*directory == '\0')
	(void) strcpy (new_path, current_path);
    else
	(void) sprintf (new_path, "%s\\%s", current_path, directory);

    /* While there are more files or directories for the current disk. */
    while (directories || files) {
	/* Read one file structure. */
	if (fread (&file, MFILE_SIZE, 1, fp) != 1)
	    return (-1);

	/* Check to see if there should be a comment for the file. */
	if (file.comment) {
	    /* There should be a comment so read one. */
	    if (fread (file_comment, COMMENT_SIZE, 1, fp) != 1)
		return (-1);
	} else {
	    /* No comment so make sure the string is terminated anyway. */
	    file_comment[0] = '\0';
	}

	/* Check to see of the file structure is actually a directory. */
	if (file.attr.part.d) {
	    /* It is a directory so decrease the directory count for the disk.
               Passes this point once for each directory (not file).
            */
	    directories--;

	    /* If there are entries for this directory get them.
               The 0x02 bit, when set, indicates an empty directory.
            */
	    if (!(file.flag & 0x02)) {
		/* Get more the entries for this directory. */
		if (read_ent (fp, new_path, file.name))
		    return (-1);
	    }
	    /* Check to see if there are more entires.
               The 0x01 bit, when set, indicates the last
	          file/directory in a directory.
               A break from this loop causes the routine to return(0).
            */
	    if (file.flag & 0x01)
		break;
	} else {
	    /* This is a file structure so output the file info. 
               Passes this point once for each
	          file (not directory). 
            */
	    output_file (&file, new_path);

	    /* Decrement the number of files count for the current disk. */
	    files--;

	    /* Check to see if there are more entires.
               The 0x01 bit, when set, indicates the last
	          file/directory in a directory.  
               A break from this loop cause the routine to return(0). 
            */
	    if (file.flag & 0x01)
		break;
	}
    }
    return (0);
}


/*
 * Output routine.
 */

output_file (file, path)
MFILE *file;
char *path;
{
    char ra, ha, sa, va, da, aa;

    /* decipher the file attribute */
    ra = file->attr.part.r ? 'r' : '-';
    ha = file->attr.part.h ? 'h' : '-';
    sa = file->attr.part.s ? 's' : '-';
    va = file->attr.part.v ? 'v' : '-';
    da = file->attr.part.d ? 'd' : '-';
    aa = file->attr.part.a ? 'a' : '-';

    /* print the line */
    (void) printf (
  "%-14s %9ld %c%c%c%c%c%c %02d/%02d/%02d %02d:%02d:%02d %-14s %s\n",
  file->name, file->size, aa, da, va, sa, ha, ra,
  file->date.part.year+80, file->date.part.month, file->date.part.day,
  file->time.part.hours, file->time.part.minutes, file->time.part.seconds*2, 
  disk.volume, path );
}


/*
 * Print error and terminate the program with an
 * exit status of -1.
 *
 * The caller passes an error code integer and a pointer to
 * a NUL terminated character string.  The error code determines
 * the message displayed and the string is used as part of the
 * error message and is usually a file name.
 */
error (err, s)
int err;
char *s;
{
    char *p;
    char temp[128];
    char t[30];

    switch (err) {

    case (ERR_USAGE):
	p = "USAGE ERROR:";
	s = "cat2asc <catalog_file>";
	break;
    case (ERR_NOTME):
	p = "NOT A CATALOG FILE:";
	break;
    case (ERR_OPEN):
	p = "OPEN FAILURE:";
	break;
    case (ERR_READ):
	p = "READ FAILURE:";
	break;
    default:
	(void) sprintf (t, "UNDEFINED ERROR #%d:", err);
	p = t;
	break;
    }

    (void) fprintf (stderr,"\n%s\n%s\n", p, s);
    (void) puts ("Press RETURN...");
    (void) getchar(); 
    exit (-1);
}

/* end of file: cat2asc.c */
