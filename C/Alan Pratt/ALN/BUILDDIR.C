/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 88/08/23 14:20:19 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	builddir.c,v $
* Revision 1.1  88/08/23  14:20:19  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/builddir.c,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * BUILDDIR: Create a directory for an archive.
 *
 * Note nomenclature change: directories became indexes (and this program
 * became doindex) on 10/22/86.
 *
 * USAGE:
 * 	builddir [-i] [-w] archive
 *
 * Creates archive.ndx.		** used to create archive.dir **
 * 
 * The -i flag prints an index of the archive, with each file's imports 
 * and exports.
 * The -w flag prints warnings about redefined externals in the archive.  
 * These are in addition to creating the directory as advertised. 
 * The -e flag prints the names of symbols imported by somebody in the
 * archive, but not exported by anybody.
 * The -d flag dumps the index (only slightly human-readable).
 *
 * Undocumented command-line options:
 * -z: set debugging flag (only if DEBUG defined)
 *
 * Some functions are imported from bdcommon.c, which is also used by aln.
 */

/*
 * build_directory: make a directory for an archive
 *
 * USAGE: image = build_directory(ifd,flag);
 *	  char *image;
 *	  int ifd;		file descriptor to read from
 *	  int flag;		if true, display an index of this archive
 *
 * IMPORTANT:
 *	  The input file descriptor ifd must refer to an archive file
 *	  whose magic number has already been read; that is, the first
 *	  byte of the next read should be the first byte of the first
 *	  archived file's header.
 *
 * 	  If 'flag' is TRUE, an index of the archive, listing each file
 *	  (in archive order), its file number, offset in the archive,
 *	  imports and exports, is sent to the standard output.
 *	  This feature is provided because such information is built
 *	  by the procedure but lost when the directory is finished.
 *
 * RETURNS:
 *	  a pointer to a (malloc-ed) image of the directory of the archive
 *	  or NULL if there is an error.
 *
 * OPERATION:
 * 	for each .o file in the archive,
 *		compile a list of its imports and exports.
 * 	for each .o file in the archive,
 *		compile a list of the .os which export its imports,
 *		and (recursively) the rest of the dependency tree
 *	write the directory header.
 *	write the list of filenames and offsets.
 * 	write all pairs (exported symbol, .o file exporting it).
 * 	write all n-tuples (.o file, .o files also required)
 *
 * FORMAT OF IMAGE:
 *
 * struct {
 *     WORD magic;		magic number for archive directory: 0xff75.
 *     WORD nsymbols;		number of symbols exported by .o files
 *     WORD nfiles;		number of files in the archive.
 * } header;			total of HEADSIZE bytes (6)
 *
 * struct {
 *	char f_name[FNLEN];	name of the n-th file in the archive
 *	long f_offset;		offset of the body of that file
 * } files[];			there are nfiles of these, FNSIZE bytes each
 *
 * struct {			sorted list of exports
 *	char s_name[SYMSIZE];	symbol name, null-terminated
 *	int filenumber;		file number in archive exporting this symbol
 * } symbols[];			this array has nsymbols elements
 *
 * char dependencies[nfiles][(nfiles+7)>>3];
 *
 * The dependency information is stored as a bitmap, with one bit per file
 * in the archive, and one such bitmap per file.  For a given file, each
 * bit in the bitmap represents a file on which this one depends.  The
 * bitmaps are exhaustive: the tree has been fully walked, and all the
 * dependencies noted.  Therefore, once you establish which modules export
 * the symbols you need, you can OR together the bitmaps of those modules,
 * and the result is a bitmap of ALL the files you need from this archive.
 *
 * A given bit vector is zero-padded to the next BYTE; the next bitmap
 * follows immediately.  The first bit of the bitmap, corresponding to the
 * first file in the archive, is the MOST SIGNIFICANT BIT of the FIRST BYTE
 * of the dependencies array.
 *
 * The reason the vector is BYTE-oriented is to avoid byte-order problems.
 */


#include "builddir.h"

/* externals and forward declarations */

char *build_directory();		/* exported from here */

#ifdef DEBUG
int _dbflag = FALSE;		/* set TRUE by -x flag */
#endif DEBUG

/* 
 * define twoflag & fourflag even if not dbmalloc because other sources
 * may have been compiled using them.
 */

int twoflag = FALSE;
int fourflag = FALSE;
int wflag = FALSE;		/* set TRUE by -w flag */
int eflag = FALSE;		/* set TRUE by -e flag */

static struct FILEREC *b_do_file();
int strcmp();

static int nexports;	/* total number of exported symbols in a library */
static int nfiles;	/* number of files in the archive */
static int vecsize;	/* size of one dependency vector */
static char *exports;	/* list of pairs (symbol, file number exporting it) */
static char *files;	/* list of pairs (file, offset in archive) */


char *build_directory(ifd,flag)
int ifd;
int flag;		/* if TRUE, show the index on stdout */
{
    register struct FILEREC *Filerec = NULL;	/* always head of list */
    register struct FILEREC *temp;
    register struct FILEREC *curr = NULL;
    register char *image;			/* image of directory */

    nexports = 0;		/* domodule() increments this value */
    nfiles = 0;			/* and this value, too */

    /* get a linked list of all the files, with full Filerecs */

    for (;;) {
	if ((temp = b_do_file(ifd)) == NULL) break;
	nfiles++;
	if (Filerec == NULL) Filerec = temp;
	else curr->f_next = temp;
	curr = temp;
    }

    /* if FLAG is true, we display the index */

    if (flag) {	
	show_index(Filerec);
    }

    vecsize = ((nfiles+7) >> 3);	/* size of one dependency vector */
    if ((image = calloc(1L,(long)(HEADSIZE+
				 nfiles*FNSIZE+
				 nexports*SYMSIZE+
				 nfiles*vecsize)))	== NULL)
	panic("Out of memory");

    DEBUG0("Write Header\n");
    write_header(image);

    DEBUG0("Write Files\n");

    files = image+HEADSIZE;
    write_files(image+HEADSIZE,Filerec);

    exports = image+HEADSIZE+nfiles*FNSIZE;	/* ptr to exports list */

    DEBUG0("Get Exports\n");

    get_exports(Filerec);

    DEBUG0("Get Dependencies\n");
    get_dependencies(Filerec,image+HEADSIZE+nfiles*FNSIZE+(nexports*SYMSIZE));

    freeall(Filerec);

    DEBUG0("Finished.\n");
    return image;
}


/*
 * b_do_file: build a file record for the next file in the archive
 *
 * RETURNS a pointer to the file record, or NULL if there are no more files.
 */

static struct FILEREC *b_do_file(ifd)
register int ifd;
{
    struct ARHEADER Arheader;
    register struct FILEREC *Filerec;
    register char *temp;
    long hold;

    hold = FTELL(ifd);		/* index of file header */
    DEBUG1("b_do_file: header at 0x%lx\n",hold);

    /* as long as there are headers to get, get them */
    if (get_header(ifd,&Arheader)) return NULL;

    if ((Filerec = Newfilerec()) == NULL)
	panic("Out of memory");

    strncpy(Filerec->f_name,Arheader.a_fname,14);

    Filerec->f_offset = hold;	/* offset of .o file header */
    Filerec->f_next = NULL;
    Filerec->f_imports = NULL;
    Filerec->f_exports = NULL;

    if ((temp = malloc(Arheader.a_fsize)) == NULL) {
	printf("Out of memory\n");
	exit(-1);
    }

    if (READ(ifd,temp,Arheader.a_fsize) != Arheader.a_fsize)
	panic("Error reading archived module");

    if (domodule(Filerec,temp)) return NULL; /* fill in filerec lists */
    free(temp);

    return Filerec;		/* all done. */
}



/*
 * domodule: fill in the two lists of the filerec with imported and
 *		exported symbols from the file whose image is at 'image'.
 *
 * This function is also called from doobject() during linking.
 * In that phase, the nexports and nfiles values are meaningless.
 */

domodule(Filerec,image)
register struct FILEREC *Filerec;
register char *image;		/* pointer to image of the .o file */
{
    register struct SYMREC *hold;
    register int    nsymbols;
    register long   offset;
    register int    i;
    int tbits;
    long value;
#ifdef DEBUG
    char    temp[SYMSIZE];
#endif DEBUG

 /* add up the sizes of the regions, plus 28 bytes of header */

    offset = getlong (image + 2) + getlong (image + 6) + 28;
    nsymbols = getlong (image + 14) / 14;

    image += offset;		/* image points to the start of a symbol */

    for (i = nsymbols; i; i--) {
	tbits = getword (image + 8) & T_COMMON;
	value = getlong(image+10);

    /* the two important bits are global & external */

#ifdef DEBUG
	if (_dbflag)
	    symcopy (temp, image);
#endif DEBUG

	if (tbits == T_GLOBAL || (tbits == T_COMMON && value != 0)) {
		DEBUG1 ("EXPORTED: %s\n", temp);
		nexports++;
		hold = Filerec -> f_exports;
		if ((Filerec -> f_exports = Newsymrec ()) == NULL) {
		    printf ("Out of memory\n");
		    return TRUE;
		}
		symcopy (Filerec -> f_exports -> s_name, image);
		Filerec -> f_exports -> s_next = hold;
	}
	else if (tbits == T_EXTERN || (tbits == T_COMMON && value == 0)) {
		DEBUG1 ("IMPORTED: %s\n", temp);
		hold = Filerec -> f_imports;
		if ((Filerec -> f_imports = Newsymrec ()) == NULL) {
		    printf ("Out of memory\n");
		    return TRUE;
		}
		symcopy (Filerec -> f_imports -> s_name, image);

		Filerec -> f_imports -> s_next = hold;
	}
	image += 14;		/* skip over this symbol */
    }
    return FALSE;
}


/*
 * get_exports: fill in the global exports array with the names & offsets
 * of all exported symbols
 */

static get_exports(Filerec)
register struct FILEREC *Filerec;
{
	register int fnum = 0;
	register char *ptr;
	register struct SYMREC *symrec;

	ptr = exports;

	/* for each File in the list */
	for ( ; Filerec != NULL; Filerec = Filerec->f_next) {
		DEBUG2("File %s (number %d)\n",Filerec->f_name,fnum);
		/* for each of its exports */
		for (symrec = Filerec->f_exports;
		     symrec != NULL;
		     symrec = symrec->s_next) {
			DEBUG1("\texports %s\n",symrec->s_name);
			symcopy(ptr,symrec->s_name);
			putword(ptr+SYMLEN,fnum);
			ptr += SYMSIZE;
		}
		fnum++;
	}
	qsort(exports, nexports, SYMSIZE, strcmp);
	mark_duplicates();
}


/*
 * mark_duplicates: go through the exports list and destroy duplicate entries.
 *
 * This procedure alters the sorted list of symbols and file numbers
 * such that all in instances of a repeated symbol, the file number of 
 * that symbol is set to the largest file number of any of them.
 *
 * The upshot is that the LAST file in the archive exporting a given
 * name is the one which will be picked; all others might as well not
 * be exporting it at all.
 *
 * This complication is necessary because the qsort put the identical
 * symbols in random order, and we need to be backward-compatible with
 * the old linker.
 *
 */

mark_duplicates()
{
    register char  *listend;	/* end of exports list */
    register char  *start;	/* start of repeated pattern */
    register char  *end;	/* first entry not matching pattern */
    register int    n;		/* max(S(n)) */
    register int    flag = FALSE;	/* for warning messages */

    listend = exports + nexports * SYMSIZE;

    start = exports;

    while (start < listend) {
	n = getword(start+SYMLEN);	/* initial max value */
	end = start + SYMSIZE;	/* initial end pointer */
	flag = FALSE;
	while (strcmp (start, end) == 0) {
	  if (wflag) {
	    if (!flag) {		/* first time */
		printf ("Warning: %s exported by %s and %s",
			start, files+n*FNSIZE,
			files+getword(end+SYMLEN)*FNSIZE);
		flag = TRUE;
	    }
	    else {
		printf(" and %s",files+getword(end+SYMLEN)*FNSIZE);
	    }
	  }
	  n = max (n, getword (end + SYMLEN));
	  end += SYMSIZE;
	}
	if (flag && wflag) {
	    printf(".\n\tValue from %s used; others discarded.\n",
		files+n*FNSIZE);
	}
	while (start != end) {
	    putword (start + SYMLEN, n);
	    start += SYMSIZE;
	}
    }
}


/*
 * get_dependencies: Fills 'image' with dependency information for each
 * file.  'image' had better be nfiles*vecsize bytes long.
 */

static get_dependencies(Filerec,image)
register struct FILEREC *Filerec;
char *image;
{
	register struct SYMREC *import;
	register int fnumber;
	register struct FILEREC *temp;
	register char *ptr = image;
	int scount = 0, first = TRUE;

	/* for each file */
	for (temp = Filerec; temp != NULL; temp = temp->f_next) {
		DEBUG1("File %s\n",temp->f_name);
		/* for each import */
		for (import = temp->f_imports;
		     import != NULL;
		     import = import->s_next) {
			DEBUG1("\tSymbol: %s\n",import->s_name);
			fnumber = find_file_number(import->s_name,
						   exports,nexports);
			if (fnumber == -1) {
			    /* truly external */
			    DEBUG1("External to archive: %s\n",import->s_name);
			}
			else {
				DEBUG2("\tsetbit(0x%lx,%d)\n",ptr,fnumber);
				Setbit(ptr,fnumber);
			}
		}
		ptr += vecsize;
	}
	fix_dependencies(nfiles,image);
}


/*
 * fix_dependencies: walk the list of dependencies until all files have all
 *	bits set which they depend on, even indirectly.
 */

static int level;
static char *image;
static char *markv;

fix_dependencies(xnfiles,ximage)
register int xnfiles;
register char *ximage;
{
	register int i;

	image = ximage;
	nfiles = xnfiles;
	vecsize = (xnfiles+7) >> 3;

	if ((markv = calloc((long)nfiles,(long)vecsize)) == NULL)
		panic("Out of memory");

	for (i=0; i<nfiles; i++) {
		DEBUG1("fix_dependencies: %d\n",i);
		if (!(Testbit(markv,i))) {
			level = 0;
			rec_fix(i);
		}
	}
}

rec_fix(i)
register int i;
{
	register int j;
	register char *myvector;

	if (Testbit(markv,i)) return;

	level++;

#ifdef DEBUG
	if (_dbflag) indent(level);
#endif DEBUG

	DEBUG1("rec_fix(%d)\n",i);

	Setbit(markv,i);
	myvector = image+i*vecsize;
	for (j=0; j<nfiles; j++) {
		if (Testbit(myvector,j)) {
#ifdef DEBUG
			if (_dbflag) indent(level);
#endif DEBUG
			DEBUG1("Depends on %d\n",j);
			rec_fix (j);
			vector_or(myvector,image+j*vecsize,vecsize);
		}
	}

	level--;
	return;
}

indent(x)
int x;
{
	while (x--) printf("    ");
}


/*
 * write_header: write the directory file header
 */

static write_header(image)
register char *image;	/* where we write to */
{
    putword(image,0xff75);
    putword(image+2,nexports);
    putword(image+4,nfiles);
}

/*
 * write_files: dump each file name and its offset to the directory image
 */

static write_files(image,Filerec)
register char *image;
register struct FILEREC *Filerec;
{
	for ( ; Filerec != NULL; Filerec = Filerec->f_next) {
		strcpy(image,Filerec->f_name);
		putlong(image+FNLEN,Filerec->f_offset);
		image += FNSIZE;
	}
}


/*
 * freeall: free all the data structures hanging off all the Filerecs
 * in the list, including the Filerecs themselves.
 */

static freeall(Filerec)
register struct FILEREC *Filerec;
{
    register struct SYMREC *s;
    register struct FILEREC *holdf;
    register struct SYMREC *holds;

    while (Filerec != NULL) {
					/* free the exports list */
	s = Filerec->f_exports;
	while (s != NULL) {
	    holds = s->s_next;
	    free(s);
	    s = holds;
	}
					/* free the imports list */
	s = Filerec->f_imports;
	while (s != NULL) {
	    holds = s->s_next;
	    free(s);
	    s = holds;
	}
					/* free the filerec itself */
	holdf = Filerec->f_next;
	free(Filerec);
	Filerec = holdf;
    }
}


/*
 * show_index: display (in human-readable format) an index of
 * 		this archive: its component files, their offsets,
 *		their imports, and their exports.
 *
 * This is debugging code, invoked by -i.
 */

show_index(Filerec)
register struct FILEREC *Filerec;
{
    register struct SYMREC *s;
    register int    col;
    register int    n = 0;

    for (; Filerec != NULL; Filerec = Filerec -> f_next) {
	printf ("File %s; offset 0x%lx in archive\n",
		Filerec->f_name, Filerec->f_offset);
	n++;
	if (Filerec -> f_exports != NULL) {
	    printf ("\tEXPORTS: ");
	    col = 18;
	    for (s = Filerec -> f_exports; s != NULL; s = s -> s_next) {
		if (col > 70) {
		    printf ("\n\t\t ");
		    col = 18;
		}
		printf ("%s ", s -> s_name);
		col += strlen(s->s_name) + 1;
	    }
	    printf ("\n");
	}
	if (Filerec -> f_imports != NULL) {
	    printf ("\tIMPORTS: ");
	    col = 18;
	    for (s = Filerec -> f_imports; s != NULL; s = s -> s_next) {
		if (col > 70) {
		    printf ("\n\t\t ");
		    col = 18;
		}
		printf ("%s ", s -> s_name);
		col += strlen (s -> s_name) + 1;
	    }
	    printf ("\n");
	}
    }
}


/*
 * show_directory:	Take an image of a directory and display it.
 * 	This is debugging code, invoked by -d.
 */

show_directory(buf)
register char *buf;
{
	register int magic;
	register int nexports;
	register int nfiles;

	magic = getword(buf);
	nexports = getword(buf+2);
	nfiles = getword(buf+4);
	buf += HEADSIZE;

	DEBUG3("Show_directory: magic is 0x%x, %d exports, %d files\n",
		magic, nexports,nfiles);

	printf("ARCHIVE FILE CONTAINS %d FILES EXPORTING %d SYMBOLS\n\n",
			nfiles,nexports);

	show_files(buf,nfiles);
	buf += nfiles*FNSIZE;

	printf("\nEXPORTS\n\n");

	while (nexports--) {
		printf("%s%s\t%d\n",buf,
				    ((strlen(buf) < 8) ? "\t" : ""),
				    getword(buf+SYMLEN));
		buf += SYMSIZE;
	}

	/* end of symbols; now display dependencies */
	printf("\nFILE:\tDEPENDS ON:\n\n");
	dump_dependencies(buf);
}


/*
 * dump_dependencies: dump the dependency information starting at 'image'.
 *	This is debugging code, invoked by -d.
 */

dump_dependencies(image)
register char *image;
{
    register int    i;
    register int    j;
    register int flag;

    for (i=0; i < nfiles; i++) {
	flag = FALSE;
	for (j = 0; j<nfiles; j++) {
		if (Testbit(image,j)) {
			if (!flag) {
				flag = TRUE;
				printf("%d:\t",i);
			}
			printf("%d ",j);
		}
	}
	if (flag) printf("\n");
	image += vecsize;
    }
}

/*
 * show_files: display the file number, file name, and file offset of
 * each file in the directory (whose file information starts at buf).
 *
 * This is debugging code, invoked by -d.
 */

show_files(buf,nfiles)
register char *buf;
register int nfiles;
{
	register int i;
	for (i=0; i<nfiles; i++) {
		printf("%4d: offset 0x%05lx %s\n",i,getlong(buf+FNLEN),buf);
		buf += FNSIZE;
	}
}


/*
 * dump_exports: display the exports list.  
 *	This is debugging code, invoked by -d.
 */

dump_exports()
{
	register int i;
	register char *buffer = exports;

	for(i=nexports ; i-- ; ) {
		printf("%s %d\n",buffer,getword(buffer+SYMLEN));
		buffer += SYMSIZE;
	}
}

usage()
{
	puts("Usage: doit [-i] [-d] [-z] fname\n");
	puts("-d: display the archive index verbatim (dump it)");
	puts("-i: display an imports/exports index of the archive");
	puts("-w: display warnings about multiply-defined externals");
	puts("-z: display (lots of) debugging information");
	exit(1);
}

panic(string)
char *string;
{
	printf("Panic: %s\n",string);
	exit(1);
}


main(argc, argv)
int argc;
char *argv[];
{
    char    buf[2];		/* buffer to hold magic number */
    register int    i;
    register int    ifd;
    register int    ofd;
    register char  *image;
    char    *outfile, *rindex();
    int     dflag = FALSE;
    int     iflag = FALSE;
    long    size;

    if (argc == 1)
	usage ();

    i = 1;
    while (*argv[i] == '-') {
	switch (argv[i][1]) {
	    case 'd': 
		dflag = TRUE;
		break;
	    case 'e':
		eflag = TRUE;
		break;
	    case 'i': 
		iflag = TRUE;
		break;
	    case 'w':
		wflag = TRUE;
		break;
#ifdef DEBUG
	    case 'z': 
		_dbflag = !_dbflag;
		break;
#endif DEBUG

#ifdef DBMALLOC
	    case '2':
		twoflag = !twoflag;
		break;
	    case '4':
		fourflag = !fourflag;
		break;
#endif DBMALLOC
	    default: 
		usage ();
	}
	i++;
    }

    if ((ifd = OPEN (argv[i], 0)) < 0)
	panic ("Can't open input file");

    if (READ (ifd, buf, 2L) != 2)
	panic ("Error reading input file");
    if (getword (buf) != 0xff65) {
	printf ("File %s is not an archive",argv[i]);
	usage ();
    }

    if ((image = build_directory (ifd, iflag)) == NULL) {
	printf ("Couldn't build an index file for %s\n", argv[i]);
	usage ();
    }

    if (CLOSE (ifd))
	panic ("Error closing input file");

    if (dflag)
	show_directory (image);

    if ((outfile = malloc((long)strlen(argv[i]) + 5)) == NULL)
	panic("Out of memory");

    strcpy (outfile, argv[i]);
    if (rindex(outfile,'.') != NULL) *(rindex(outfile,'.')) = '\0';
    strcat (outfile, DIRSUFFIX);

    if ((ofd = CREAT (outfile)) < 0)
	panic ("Can't open output file");

    nexports = getword (image + 2);
    nfiles = getword (image + 4);
    size = HEADSIZE + nfiles*FNSIZE + nexports * SYMSIZE + nfiles * vecsize;

    if (WRITE (ofd, image, size) != size)
	panic ("Error writing index file");
    if (CLOSE (ofd))
	panic ("Error closing index file");

    free (image);
}
