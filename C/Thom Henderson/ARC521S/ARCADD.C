/*
 * $Header: arcadd.c,v 1.10 88/11/16 17:43:25 hyc Exp $
 */

/*
 * ARC - Archive utility - ARCADD
 * 
 * Version 3.40, created on 06/18/86 at 13:10:18
 * 
 * (C) COPYRIGHT 1985,86 by System Enhancement Associates; ALL RIGHTS RESERVED
 * 
 * By:  Thom Henderson
 * 
 * Description: This file contains the routines used to add files to an archive.
 * 
 * Language: Computer Innovations Optimizing C86
 */
#include <stdio.h>
#include "arc.h"
#if	MTS
#include <mts.h>
#endif

static	int	addfile();
char	*strcpy();
#ifdef __STDC__
int	readhdr();
#else
int	strcmp(), strlen(), free(), readhdr(), unlink();
#endif
#if	UNIX
int	izadir();
#endif
void	writehdr(), filecopy(), getstamp();
void	pack(), closearc(), openarc(), abort();

void
addarc(num, arg, move, update, fresh)		/* add files to archive */
	int             num;	/* number of arguments */
	char           *arg[];	/* pointers to arguments */
int             move;		/* true if moving file */
int             update;		/* true if updating */
int             fresh;		/* true if freshening */
{
	char           *d, *dir();	/* directory junk */
	char            buf[STRLEN];	/* pathname buffer */
	char          **path;	/* pointer to pointers to paths */
	char          **name;	/* pointer to pointers to names */
	int             nfiles = 0;	/* number of files in lists */
	int             notemp;	/* true until a template works */
	int             nowork = 1;	/* true until files are added */
	char           *i, *rindex();	/* string indexing junk */
#ifndef __STDC__
	char           *malloc(), *realloc();	/* memory allocators */
#endif
	int             n;	/* index */
#if	MSDOS
	unsigned int	coreleft();	/* remaining memory reporter */
#endif
	int		addbunch();

	if (num < 1) {		/* if no files named */
		num = 1;	/* then fake one */
#if	DOS
		arg[0] = "*.*";	/* add everything */
#endif
#if	UNIX
		arg[0] = "*";
#endif
#if	MTS
		arg[0] = "?";
#endif
	}
	path = (char **) malloc(sizeof(char **));
	name = (char **) malloc(sizeof(char **));


	for (n = 0; n < num; n++) {	/* for each template supplied */
		strcpy(buf, arg[n]);	/* get ready to fix path */
#if	!MTS
		if (!(i = rindex(buf, '\\')))
			if (!(i = rindex(buf, '/')))
				if (!(i = rindex(buf, ':')))
					i = buf - 1;
#else
		if (!(i = rindex(buf, sepchr[0])))
			if (buf[0] != tmpchr[0])
				i = buf - 1;
			else
				i = buf;
#endif
		i++;		/* pointer to where name goes */

		notemp = 1;	/* reset files flag */
		for (d = dir(arg[n]); d; d = dir((char *)NULL)) {
			notemp = 0;	/* template is giving results */
			nfiles++;	/* add each matching file */
			path = (char **) realloc(path, nfiles * sizeof(char **));
			name = (char **) realloc(name, nfiles * sizeof(char **));
			strcpy(i, d);	/* put name in path */
			path[nfiles - 1] = malloc(strlen(buf) + 1);
			strcpy(path[nfiles - 1], buf);
			name[nfiles - 1] = d;	/* save name */
#if	MSDOS
			if (coreleft() < 5120) {
				nfiles = addbunch(nfiles, path, name, move, update, fresh);
				nowork = nowork && !nfiles;
				while (nfiles) {
					free(path[--nfiles]);
					free(name[nfiles]);
				}
				free(path);
				free(name);
				path = name = NULL;
			}
#endif
		}
		if (notemp && warn)
			printf("No files match: %s\n", arg[n]);
	}

	if (nfiles) {
		nfiles = addbunch(nfiles, path, name, move, update, fresh);
		nowork = nowork && !nfiles;
		while (nfiles) {
			free(path[--nfiles]);
			free(name[nfiles]);
		}
		free(path);
		free(name);
	}
	if (nowork && warn)
		printf("No files were added.\n");
}

int
addbunch(nfiles, path, name, move, update, fresh)	/* add a bunch of files */
	int             nfiles;	/* number of files to add */
	char          **path;	/* pointers to pathnames */
	char          **name;	/* pointers to filenames */
	int             move;	/* true if moving file */
	int             update;	/* true if updating */
	int             fresh;	/* true if freshening */
{
	int             m, n;	/* indices */
	char           *d;	/* swap pointer */
	struct heads    hdr;	/* file header data storage */

	for (n = 0; n < nfiles - 1; n++) {	/* sort the list of names */
		for (m = n + 1; m < nfiles; m++) {
			if (strcmp(name[n], name[m]) > 0) {
				d = path[n];
				path[n] = path[m];
				path[m] = d;
				d = name[n];
				name[n] = name[m];
				name[m] = d;
			}
		}
	}

	for (n = 0; n < nfiles - 1;) {	/* consolidate the list of names */
		if (!strcmp(path[n], path[n + 1])	/* if duplicate names */
		    ||!strcmp(path[n], arcname)	/* or this archive */
#if	UNIX
		    ||izadir(path[n])	/* or a directory */
#endif
		    ||!strcmp(path[n], newname)	/* or the new version */
		    ||!strcmp(path[n], bakname)) {	/* or its backup */
			free(path[n]);	/* then forget the file */
			free(name[n]);
			for (m = n; m < nfiles - 1; m++) {
				path[m] = path[m + 1];
				name[m] = name[m + 1];
			}
			nfiles--;
		} else
			n++;	/* else test the next one */
	}

	if (!strcmp(path[n], arcname)	/* special check for last file */
	    ||!strcmp(path[n], newname)	/* courtesy of Rick Moore */
#if	UNIX
	    ||izadir(path[n])
#endif
	    || !strcmp(path[n], bakname)) {
		free(path[n]);
		free(name[n]);
		nfiles--;
	}
	if (!nfiles)		/* make sure we got some */
		return 0;

	for (n = 0; n < nfiles - 1; n++) {	/* watch out for duplicate
						 * names */
		if (!strcmp(name[n], name[n + 1]))
			abort("Duplicate filenames:\n  %s\n  %s", path[n], path[n + 1]);
	}
	openarc(1);		/* open archive for changes */

	for (n = 0; n < nfiles;) { /* add each file in the list */
		if (addfile(path[n], name[n], update, fresh) < 0) {
			free(path[n]);		/* remove this name if */
			free(name[n]);		/* it wasn't added */
			for (m = n; m < nfiles-1 ; m++) {
				path[m] = path[m+1];
				name[m] = name[m+1];
			}
			nfiles--;
		} else n++;
	}

	/* now we must copy over all files that follow our additions */

	while (readhdr(&hdr, arc)) {	/* while more entries to copy */
		writehdr(&hdr, new);
		filecopy(arc, new, hdr.size);
	}
	hdrver = 0;		/* archive EOF type */
	writehdr(&hdr, new);	/* write out our end marker */
	closearc(1);		/* close archive after changes */

	if (move) {		/* if this was a move */
		for (n = 0; n < nfiles; n++) {	/* then delete each file
						 * added */
			if (unlink(path[n]) && warn) {
				printf("Cannot unsave %s\n", path[n]);
				nerrs++;
			}
		}
	}
	return nfiles;		/* say how many were added */
}

static          int
addfile(path, name, update, fresh)	/* add named file to archive */
	char           *path;	/* path name of file to add */
	char           *name;	/* name of file to add */
	int             update;	/* true if updating */
	int             fresh;	/* true if freshening */
{
	struct heads    nhdr;	/* data regarding the new file */
	struct heads    ohdr;	/* data regarding an old file */
	FILE           *f;	/* file to add, opener */
#ifndef __STDC__
	FILE		*fopen();
#endif
	long            starts, ftell();	/* file locations */
	int             upd = 0;/* true if replacing an entry */

#if	!MTS
	if (!(f = fopen(path, OPEN_R)))
#else
	if (image)
		f = fopen(path, "rb");
	else
		f = fopen(path, "r");
	if (!f)
#endif
	{
		if (warn) {
			printf("Cannot read file: %s\n", path);
			nerrs++;
		}
		return(-1);
	}
#if	!DOS
	if (strlen(name) >= FNLEN) {
		if (warn) {
			char	buf[STRLEN];
			printf("WARNING: File %s name too long!\n", name);
			name[FNLEN-1]='\0';
			while(1) {
				printf("  Truncate to %s (y/n)? ", name);
				fflush(stdout);
				fgets(buf, STRLEN, stdin);
				*buf = toupper(*buf);
				if (*buf == 'Y' || *buf == 'N')
					break;
			}
			if (*buf == 'N') {
				printf("Skipping...\n");
				fclose(f);
				return(-1);
			}
		}
		else {
			if (note)
				printf("Skipping file: %s - name too long.\n",
					name);
			fclose(f);
			return(-1);
		}
	}
#endif
	strcpy(nhdr.name, name);/* save name */
	nhdr.size = 0;		/* clear out size storage */
	nhdr.crc = 0;		/* clear out CRC check storage */
#if	!MTS
	getstamp(f, &nhdr.date, &nhdr.time);
#else
	{
	char *buffer;
#ifndef __STDC__
	char *malloc();
#endif
	int	inlen;
	struct	GDDSECT	*region;

	region=gdinfo(f->_fd._fdub);
	inlen=region->GDINLEN;
	buffer=malloc(inlen);	/* maximum line length */
	setbuf(f,buffer);        
	f->_bufsiz=inlen;        
	f->_mods|=_NOIC;	/* Don't do "$continue with" */
	f->_mods&=~_IC;		/* turn it off, if set... */
	}
	getstamp(path, &nhdr.date, &nhdr.time);
#endif

	/* position archive to spot for new file */

	if (arc) {		/* if adding to existing archive */
		starts = ftell(arc);	/* where are we? */
		while (readhdr(&ohdr, arc)) {	/* while more files to check */
			if (!strcmp(ohdr.name, nhdr.name)) {
				upd = 1;	/* replace existing entry */
				if (update || fresh) {	/* if updating or
							 * freshening */
					if (nhdr.date < ohdr.date
					    || (nhdr.date == ohdr.date && nhdr.time <= ohdr.time)) {
						fseek(arc, starts, 0);
						fclose(f);
						return(0);/* skip if !newer */
					}
				}
			}
			if (strcmp(ohdr.name, nhdr.name) >= 0)
				break;	/* found our spot */

			writehdr(&ohdr, new);	/* entry preceeds update;
						 * keep it */
			filecopy(arc, new, ohdr.size);
			starts = ftell(arc);	/* now where are we? */
		}

		if (upd) {	/* if an update */
			if (note) {
				printf("Updating file: %-12s  ", name);
				fflush(stdout);
			}
			fseek(arc, ohdr.size, 1);
		} else if (fresh) {	/* else if freshening */
			fseek(arc, starts, 0);	/* then do not add files */
			fclose(f);
			return(0);
		} else {	/* else adding a new file */
			if (note) {
				printf("Adding file:   %-12s  ", name);
				fflush(stdout);
			}
			fseek(arc, starts, 0);	/* reset for next time */
		}
	} else {		/* no existing archive */
		if (fresh) {	/* cannot freshen nothing */
			fclose(f);
			return(0);
		} else if (note) {	/* else adding a file */
			printf("Adding file:   %-12s  ", name);
			fflush(stdout);
		}
	}

	starts = ftell(new);	/* note where header goes */
	hdrver = ARCVER;		/* anything but end marker */
	writehdr(&nhdr, new);	/* write out header skeleton */
	pack(f, new, &nhdr);	/* pack file into archive */
	fseek(new, starts, 0);	/* move back to header skeleton */
	writehdr(&nhdr, new);	/* write out real header */
	fseek(new, nhdr.size, 1);	/* skip over data to next header */
	fclose(f);		/* all done with the file */
	return(0);
}
