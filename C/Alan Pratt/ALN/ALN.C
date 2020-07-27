/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 90/10/19 17:07:40 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	aln.c,v $
* Revision 1.11  90/10/19  17:07:40  apratt
* Added checks so option arguments with more than one character, or
* no characters, give an error message.
* 
* Revision 1.10  90/10/19  17:02:55  apratt
* Added -n flag and noheaderflag variable.
* 
* Revision 1.9  90/01/24  15:46:34  apratt
* Fixed a longstanding bug: -c files were not null-terminated after
* they were read into memory, so the parser carried on into the next
* malloc block.  Fun, huh?  Fixed now.
* 
* Also added comments in -c files: a comment character means "skip
* to the next \n and continue from there."  The comment character
* is number-sign (#).
* 
* Revision 1.8  89/09/05  14:23:48  apratt
* Removed some debugging printf's for new -a arguments.
* 
* Revision 1.7  89/04/27  14:19:21  apratt
* Fixed -h processing. Don't know how it got broken...
* 
* Revision 1.6  89/04/17  15:06:02  apratt
* Added call to getargs if ATARIST.  This scans for ARGV in the
* environment and interprets MWC-style args.  My version of getargs
* checks to see that the args really came from my parent, by checking
* for 0x7f in the command-line length byte.  msh puts 0x7f there, but
* none of the MWC tools checks for it.
* 
* Revision 1.5  89/03/30  14:10:17  apratt
* Added -h option: sets hflags in prg header (aln.c, writefns.c)
* 
* Revision 1.4  89/02/06  21:48:00  apratt
* Bug: no -u's would say UNRESOLVED SYMBOLS but not list them.
* 
* Revision 1.3  89/01/31  14:42:41  apratt
* More than one -u option causes unresolved symbols not to be listed.
* The warning itself ("UNRESOLVED SYMBOLS") still appears.
* 
* Revision 1.2  88/08/24  10:35:35  apratt
* Addition of -q and -k options, mainly for OS builds.
* 
* Revision 1.1  88/08/23  14:20:15  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.11 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/aln.c,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * ALN - Atari Linker
 *
 * Written by Allan Pratt (started 7/7/86)
 *
 * Undocumented command-line switches, only if DEBUG is defined:
 * -z: toggle debugging
 * -1: perform DOLIST (use this before -z to avoid seeing dolist output)
 * -2: perform malloc debugging
 * -3: turn debugging on for relmod and write functions.
 * -4: disable free() (but do continue tracing calls to it if -2)
 */

/*
 * for notes of operation, flags, bugs, etc., see the man page.
 */

#include "aln.h"

/*
 * max number of arguments in a command file
 */

#define MAXARGS 256

/*
 * number of characters in a filename argument
 */

#define FARGSIZE 128

/*
 * macro used in doargs:
 */

#define warn(x,f)    printf("Warning: repeated flag `%c'%s\n",x,\
			f ? "; previous one(s) ignored." : ".")

/* these are initialized to zero (FALSE) */

int aflag, dflag, fflag, kflag, lflag, mflag, oflag, pflag, qflag;
int sflag, uflag, vflag, wflag, yflag;
int noheaderflag;
int waitflag, versflag;

#ifdef DBMALLOC
int twoflag;
int fourflag;
#endif DBMALLOC
#ifdef DEBUG
int threeflag;
#endif DEBUG

long tval, dval, bval;		/* values of these abs bases */
int ttype, dtype, btype;	/* type flag: 0, -1, -2, -3, -4 */
long hflags;			/* value of the arg to -h option */

#ifdef SRECORDS
int rflag;
long rval;
#endif SRECORDS

/* strings in the BSS (all initially empty strings) */
char ofile[FARGSIZE];		/* output file name (.o or .prg) */
char libdir[FARGSIZE*3];	/* library directory to search */

#ifdef ATARIST
char *initbreak;
extern char *_break;		/* defined in gemstart, used by malloc */
#endif ATARIST

struct HREC *htable[NBUCKETS];		/* the hash table */
struct HREC *unresolved = NULL;

struct OFILE *olist = NULL;	/* ptr to first ofile in list */
struct OFILE *olast;		/* ptr to last ofile */

/* 
 * the PLIST is a list of object file images as they were read off disk.
 * Only the name, arname, flags, image, and next fields of the ofile
 * structure are used.  Object files are taken off the Plist by dolist(),
 * which passes the fields as arguments to doobj().  After exhausting the
 * PLIST, dolist() culls the UNRESOVLED list of names which are defined.
 */

struct OFILE *plist = NULL;
struct OFILE *plast;

#ifdef DEBUG
int _dbflag = FALSE;
#endif DEBUG

static int globflag = TRUE;	/* when TRUE, okay to see global options */

/*
 * doargs(argc, argv) takes an argument list (parsed by the C startup or
 * 		    by this program) and parses the command line,
 *		    performing the indicated actions.  If -c is encountered,
 *		    parses it and recursively calls link.
 *
 * RETURNS: 0 if the command line was exhausted, or an error code.
 */

doargs(argc,argv)
int argc;
register char *argv[];
{
    int i = 1;
    int c;
    char *ifile, *isym;		/* file name and symbol name for -i */
    
    if (globflag) {
	while (i < argc && argv[i][0] == '-') {

	    /* barf if not exactly one char after the dash */
	    if (!argv[i][1] || argv[i][2]) {
		printf ("Illegal option argument: %s\n",argv[i]);
		return TRUE;
	    }
	    c = argv[i++][1];
	    DEBUG1 ("Option `%c'\n", c);
	    switch (c) {
	      case 'h': case 'H':	/* set hflags value */
		if (getval(argv[i],&hflags)) {
		    printf(
    "\nError in -h (hflags) value: %s is not a number\n",argv[i]);
		    return TRUE;
		}
		i++;
		break;
#ifdef DEBUG
	      case 'z': case 'Z': 	/* toggle debugging */
		_dbflag = !_dbflag;
		break;
#endif DEBUG
	      case 'n': case 'N':	/* no header */
		noheaderflag = TRUE;
		break;
	      case 'a': case 'A': 	/* set absolute linking on */
		if (aflag) warn('a',TRUE);
		if (i + 2 >= argc) {
		    printf("Not enough arguments to -a\n");
		    return TRUE;
		}
		aflag = TRUE;

		/* text seg can be 'r', 'xd', 'xb', or a value */
		if ((*argv[i] == 'r' || *argv[i] == 'R') && !argv[i][1])
		    ttype = -1;
		else if ((*argv[i] == 'x' || *argv[i] == 'X')) {
		    switch (argv[i][1]) {
			case 0: default: goto texterr;
			case 'd': case 'D': ttype = -3; break;
			case 'b': case 'B': ttype = -4; break;
		    }
		}
		else if ((ttype = 0), getval(argv[i],&tval)) {
texterr:
		    printf(
    "Error in text-segment address: %s is not 'r', 'xd', 'xb', or an address.",
			argv[i]);
		    return TRUE;
		}
		i++;

		/* data seg can be 'r', 'x', 'xt', 'xb', or a value */
		if ((*argv[i] == 'r' || *argv[i] == 'R') && !argv[i][1])
		    dtype = -1;
		else if ((*argv[i] == 'x' || *argv[i] == 'X')) {
		    switch (argv[i][1]) {
			case 0: case 't': case 'T': dtype = -2; break;
			case 'b': case 'B': dtype = -4; break;
			default: goto dataerr;
		    }
		}
		else if ((dtype = 0), getval(argv[i],&dval)) {
dataerr:
		    printf(
    "Error in data-segment address: %s is not 'r', 'x[tb]', or an address.",
			argv[i]);
		    return TRUE;
		}
		i++;

		/* bss seg can be 'r', 'x', 'xt', 'xd', or a value */
		if ((*argv[i] == 'r' || *argv[i] == 'R') && !argv[i][1])
		    btype = -1;
		else if ((*argv[i] == 'x' || *argv[i] == 'X')) {
		    switch (argv[i][1]) {
			case 0: case 'd': case 'D': btype = -3; break;
			case 't': case 'T': btype = -2; break;
			default: goto bsserr;
		    }
		}
		else if ((btype = 0), getval(argv[i],&bval)) {
bsserr:
		    printf(
    "Error in BSS-segment address: %s is not 'r', 'x[td]', or an address.",
			argv[i]);
		    return TRUE;
		}
		i++;
/*		printf("ABS: t %d d %d b %d\n",ttype, dtype, btype);/**/
		break;
	      case 'd': case 'D':	/* wait for "return" before exiting */
		if (dflag) warn('d',FALSE);
		dflag = TRUE;
		waitflag = TRUE;
		break;
	      case 'f': case 'F':		/* use "file" symbols  */
		if (fflag) warn('f',FALSE);
		fflag = TRUE;
		sflag = TRUE;
		break;
	      case 'k': case 'K':	/* add to kill list */
		if (i >= argc) {
		    printf("No symbol following -k switch\n");
		    return TRUE;
		}
		if (strlen(argv[i]) > SYMSIZE) {
		    printf(
		      "Symbol argument to -k flag too long (%d-char max)\n",
		      SYMSIZE);
		    return TRUE;
		}
		if (!kflag) {
		    /* initialize kill list */
		    if (kinit()) return TRUE;
		    kflag = TRUE;
		}
		if (kadd(argv[i++])) return TRUE;
		break;
	      case 'l': case 'L': 	/* include local symbols */
		if (lflag) warn('l',FALSE);
		lflag = TRUE;
		break;
	      case 'm': case 'M': 	/* produce a load map */
		if (mflag) warn('m',FALSE);
		mflag = TRUE;
		break;
	      case 'o': case 'O': 	/* specify an output file */
		if (oflag) warn('o',TRUE);
		oflag = TRUE;
		if (i >= argc) {
		    printf("No output filename following -o switch\n");
		    return TRUE;
		}
		if (strlen(argv[i]) > FARGSIZE - 5) {
		    printf("Output file name too long (sorry!)\n");
		    return TRUE;
		}
		strcpy(ofile,argv[i++]);
		break;
	      case 'p': case 'P':	/* partial link (.o file output) */
		if (pflag) warn('p',FALSE);
		pflag = TRUE;
		break;
	      case 'q': case 'Q':	/* partial link, plus nail down BSS */
		if (qflag) warn('q',FALSE);
		qflag = TRUE;
		break;
#ifdef SRECORDS
	      case 'r': case 'R': 	/* produce s-records for rval-K ROM */
		if (rflag) warn('r',TRUE);
		rflag = TRUE;
		if (getval (argv[i++],&rval)) return TRUE;
		break;
#endif
	      case 's': case 'S': 	/* include global symbols */
		sflag = TRUE;
		break;
	      case 'u': case 'U': 	/* do not abort on unresolved extern */
		uflag++;		/* if > 1, don't even list them */
		break;
	      case 'v': case 'V':	/* double and triple this for more */
		if (!vflag && !versflag) {
    		    version();
		}
		++vflag;
		break;
	      case 'w': case 'W':	/* warn about double exports in libs */
		if (wflag) warn('w',FALSE);
		wflag = TRUE;
		break;
	      case 'y': case 'Y':	/* search path */
		if (yflag) warn('y',TRUE);
		yflag = TRUE;
		if (i >= argc) {
		    printf("No search path argument to 'y' switch\n");
		    return TRUE;
		}
		strcpy(libdir,argv[i++]);
		break;
#ifdef DBMALLOC
	      case '4':
		fourflag = !fourflag;
		break;
#endif DBMALLOC
#ifdef DEBUG
	      case '3':
		threeflag = TRUE;
		break;
#endif DEBUG
	      case 'c': case 'C':
	      case 'i': case 'I':
	      case 'x': case 'X':
		i--;
		goto locals;

	      default:
		printf ("unknown option argument `%c'\n", c);
		return TRUE;
	    }
	}
    }

    /* set flags which are implied by other flags */
    if (qflag) pflag = TRUE;
    if (lflag || pflag) sflag = TRUE;

    if (oflag && vflag) printf("Output file is %s\n",ofile);
    
  locals:		/* start processing local arguments */
    DEBUG1("do locals; first is %s\n",argv[i]); 
    while (i < argc) {
	if (argv[i][0] == '-') {

	    /* barf if there is not exactly one char after the dash */
	    if (!argv[i][1] || argv[i][2]) {
		printf ("illegal option argument: %s\n",argv[i]);
		return TRUE;
	    }
	    c = argv[i++][1];
	    DEBUG1("local option %c\n",c);
	    switch (c) {
#ifdef DBMALLOC
	      case '2':
		twoflag = !twoflag;
		break;
	      case '4':
		fourflag = !fourflag;
		break;
#endif DBMALLOC
#ifdef DEBUG
	      case '1':		/* special debugging flag does dolist; */
		if (flush_handles()) return TRUE;
		dolist();	/* when followed by -z, this helps */
		break;
	      case '3':
		threeflag = TRUE;
		break;
	      case 'z': case 'Z':
		_dbflag = !_dbflag;
		break;
#endif DEBUG
	      case 'c': case 'C': 
		if (i == argc) {
		    printf ("Not enough arguments to -c\n");
		    return TRUE;
		}
		if (docmdfile (argv[i++])) {	/* calls link */
		    return TRUE;
		}
		break;
		
	      case 'i': case 'I': 
		if (i + 2 > argc) {
		    printf ("Not enough arguments to -i");
		    return TRUE;
		}
		globflag = FALSE;
		ifile = argv[i++];
		isym = argv[i++];
		if (dofile (ifile, (c == 'i') ? 1 : 2, isym))
		    return TRUE;
		break;

	      case 'x': case 'X': 
		if (i == argc) {
		    printf("Not enough arguments to -x");
		    return TRUE;
		}
		globflag = FALSE;
		if (outputfile(argv[i])) return TRUE;
		if (whole_archive(argv[i++])) return TRUE;
		break;
	      default: 
		printf ("Illegal option argument: %c\n", c);
		return TRUE;
	    }
	}
	else {	    /* not an option argument; a filename */
	    globflag = FALSE;

	    if (outputfile(argv[i])) return TRUE;
	    if (dofile(argv[i++],FALSE,NULL)) return TRUE;
	}
    }
    DEBUG0("doargs: returning FALSE\n");
    return FALSE;		/* no problem! */
}

outputfile(s)
char *s;
{
    char *suffix;

    if (!oflag) {
	if (strlen(s) > FARGSIZE - 5) {
	    printf("First filename too long for output file: %s\n",s);
	    return TRUE;
	}
	oflag = TRUE;
	strcpy(ofile,s);
	if (index(ofile,'.')) *(index(ofile,'.')) = '\0';
	if (pflag) suffix = ".o";
	else if (aflag) suffix = ".abs";
	else suffix = ".prg";
	strcat(ofile,suffix);
	if (vflag) printf("Output file is %s\n",ofile);
	if (strcmp(ofile,s) == 0) {
	    printf("Output file %s would overwrite the input file.\n",ofile);
	    printf("Use \"-o <name>\" to specify an output file (e.g. \"-o linkout%s\")\n",suffix);
	    return TRUE;
	}
    }
    return FALSE;
}

docmdfile(fname)
char *fname;
{
	int fd;
	long size;
	char *ptr;
	int newargc;
	char *(*newargv)[];

	/* used for input from stdin */
	char linebuf[256];
	char *inbuf;
	int inbufindex,inbufsize;

	DEBUG1("Docmdfile(%s)\n",fname ? fname : "stdin");
	if (!(newargv = (char ***)malloc((long)(sizeof(char *) * MAXARGS)))) {
	    printf("Out of memory.\n");
	    return TRUE;
	}
	    
	if (fname) {
	    if ((fd = OPEN(fname,0)) < 0) {
		printf("Cannot open command file %s\n",fname);
		return TRUE;
	    }
	    size = FSIZE(fd);
	    if ((ptr = malloc(size+1)) == NULL) {
		printf("Out of memory\n");
		CLOSE(fd);
		return TRUE;
	    }
	    if (READ(fd,ptr,size) != size) {
	    	printf("read error on command file %s\n",fname);
		CLOSE (fd);
		return TRUE;
	    }
	    *(ptr+size) = 0;		/* null-terminate the buffer */
	    CLOSE(fd);
	}
	else {
	    waitflag = TRUE;
	    if ((inbuf = malloc(256L)) == NULL) {
		printf("Out of memory.\n");
		return TRUE;
	    }
	    inbufsize = 256;
	    inbufindex = 0;

	    while (TRUE) {
		DEBUG0("Get a line\n");
		printf("* ");
		*linebuf = 0;

		/* gets() is evil! */
		gets(linebuf);
		if (*linebuf == 0) break;
		DEBUG1("Len is %d\n",strlen(linebuf));
		if (inbufsize-inbufindex < strlen(linebuf)+2) {
		    DEBUG0("Need to expand\n");
		    if ((inbuf = realloc(inbuf,(long)(inbufsize+256)))
			== NULL) {
			    printf("Out of memory\n");
			    return TRUE;
			}
		    inbufsize += 256;
		    DEBUG1("New size is %d\n",inbufsize);
		}
		strcpy(&inbuf[inbufindex],linebuf);
		strcat(&inbuf[inbufindex]," ");
		inbufindex += strlen(linebuf)+1;
		DEBUG1("New index is %d\n",inbufindex);
	    }
	    /* ...+1 below is so the null termination is saved also */
	    if ((inbuf = realloc(inbuf,(long)inbufindex+1)) == NULL) {
		printf("Out of memory\n");
		return TRUE;
	    }
	    ptr = inbuf;
	}
	
	DEBUG1("Ptr is \"%s\"\n",ptr);
	if ((newargc = parse(ptr,*newargv)) == -1) {
		return TRUE;
	}
	if ((newargv = (char ***)realloc(newargv,(long)newargc*4)) == NULL) {
	    printf("Out of memory\n");
	    return TRUE;
	}
	if (doargs(newargc,*newargv)) {
		DEBUG0("docmdfile: doargs returns TRUE\n");
		return TRUE;
	}
	free(ptr);
	free(newargv);
	return FALSE;
}

/*
 * parse: load newargv with pointers to arguments found in buf (one-based).
 * RETURNS: the number of arguments found +1 (like argc).
 *
 * Note that this doesn't clobber newargv[0]: you can call this
 * incrementally, passing (as newargv) a pointer to the element before the
 * next element to fill.
 */

int parse(buf,newargv)
register char *buf;
char *newargv[];
{
    register int i = 1;
    
    DEBUG0("begin parsing\n");
    while (1) {
	while (*buf && index(",\t\n\r\14 ",*buf)) buf++;

	/* test for eof */
	if (*buf == '\0' || *buf == 26) {
	    if (i == 0) {
		printf("No commands in command file\n");
		return -1;
	    }
	    else return i;
	}
	/* test for comment */
	if (*buf == '#') {
	    /* found a comment; skip to next \n and start over */
	    while (*buf && *buf != '\n') buf++;
	    continue;
	}
        if (i == MAXARGS) {
	    printf("Too many arguments in command file\n");
	    return -1;
	}
	newargv[i] = buf;
	while (! index(",\t\n\r\14 ",*buf)) {
	    if (*buf == '\0' || *buf == 26) {
		DEBUG1("Finished parsing %d args\n",i);
		return i;
	    }
	    buf++;
	}
	*buf++ = '\0';
	DEBUG2("argv[%d] = \"%s\"\n",i,newargv[i]);
	i++;
    }
}

whole_archive(arname)
char *arname;
{
    register int fd;
    char magic[2];
    
    if ((fd = OPEN(arname,0)) < 0) {
	printf("Cannot open archive %s\n",arname);
	return TRUE;
    }
    if (READ(fd,magic,2L) < 2) {
	printf("Cannot read archive %s\n",arname);
	CLOSE(fd);
	return TRUE;
    }
    if ((unsigned)getword(magic) != 0xff65) {
	printf("File %s is not an archive\n",arname);
	CLOSE(fd);
	return TRUE;
    }
    if (get_all(fd,arname)) return TRUE;
    return FALSE;
}

char *noargv[] = { "aln", "-c", NULL };

main(argc, argv)
int argc;
char *argv[];
{
    struct HREC *utemp;
    struct OHEADER *header;
    int errflag = FALSE;	/* error flag - goes TRUE on error */
    char *s, *getenv();

#ifdef ATARIST
    initbreak = _break;		/* for memory-used computation */
    getargs(&argc,&argv);	/* try for MWC-style arguments */
#endif

    if (s = getenv("ALNPATH")) strcpy(libdir,s);

    if (argc == 1) {
	version();
	versflag = TRUE;	/* say we've dumped the version banner */
	printf("Enter options and file names (you can enter more than one\n");
        printf("per line, and more than one line); enter a blank line to link.\n");
	argv = noargv;
	argc = 3;
    }

    if (doargs (argc, argv)) {
	DEBUG0 ("doargs() returns TRUE\n");
	errflag = TRUE;
	goto cleanup;
    }

 /* finished with argument list */
    DEBUG0("Finished with argument list.\n");
    if (flush_handles()) {
    	errflag = TRUE;
    	goto cleanup;
    }

    if (dolist()) {
	errflag = TRUE;
	goto cleanup;
    }

    if (olist == NULL) {
	printf("No object files to link.\n");
	errflag = TRUE;
	goto cleanup;
    }

    /* report unresolved externals */
    if (unresolved != NULL) {
	printf("UNRESOLVED SYMBOLS\n");
	/* don't list them if two -u's or more */
	if (uflag < 2) {
	    utemp = unresolved;
	    while (utemp != NULL) {
		printf("\t%s (",utemp->h_sym);
		put_name(utemp->h_ofile);
		printf(")\n");
		utemp = utemp->h_next;
	    }
	}
	if (!uflag) {
	    errflag = TRUE;
	    goto cleanup;
	}
    }

    if ((header = make_ofile()) == NULL) {
	errflag = TRUE;
	goto cleanup;
    }

#ifdef DEBUG
    if (threeflag) _dbflag = TRUE; /* debug on for write */
#endif DEBUG

    if (kflag) do_klist(header);

    if (pflag) {
	DEBUG0("Just ofile linking\n");
	if (write_ofile(header)) {
	    errflag = TRUE;
	}
    }
    else if (!aflag) {
	DEBUG0("Relocatable linking\n");
	symfix(header);
	if (relmod(header)) {
	    errflag = TRUE;
	    goto showmap;
	}
	if (write_prg(header)) errflag = TRUE;
    }
    else {			/* absolute */
	DEBUG0("Absolute linking\n");
	symfix(header);
	if (absmod(header)) {
	    errflag = TRUE;
	    goto showmap;
	}
	DEBUG1("Header magic is %x\n",header->magic);
	if (write_ofile(header)) errflag = TRUE;
    }

showmap:

    /* write_map destroys the order of the symbol table, so don't use it
       until you're finished writing everything. */

    if (mflag) if (write_map(header)) errflag = TRUE;

    if (vflag) {
	printf("\nSizes:\t  Text\t  Data\t   Bss\n");
	printf("(hex)\t%6lx\t%6lx\t%6lx\n\n",
	    header->tsize,header->dsize,header->bsize);
    }

cleanup:
   
    if (vflag) {
#ifdef ATARIST
	{
	    char x;			/* &x is close to our stack pointer */
	    char *lsbrk();
	    printf("Link %s. %ldK used, %ldK free\n",
		errflag ? "aborted" : "complete",
		(lsbrk(0L) - initbreak) >> 10, (&x - lsbrk(0L)) >> 10);
	}
#else
	printf("Link %s.\n",errflag ? "aborted" : "complete");
#endif
    }
    if (waitflag) {
    	char linebuf[128];
    	printf("Press the <return> key to continue: ");
    	gets(linebuf);
    }
    return errflag;
}

/*
 * dofile functions: collect file names and handles in a buffer
 * so there is less disk activity
 *
 * Call dofile with flag FALSE for normal object files and archives.
 * Call it with flag TRUE and a symbol name for include files (-i).
 */

#define NHANDLES 12			/* number of open handles at once */

static int handle[NHANDLES];		/* open file handles */
static char *name[NHANDLES];		/* associated file names */
static int hflag[NHANDLES];		/* flag: true for include files: 1 means data seg, 2 means text */
static char *hsym1[NHANDLES];		/* first symbol for include files */
static char *hsym2[NHANDLES];		/* second symbol for include files */
static int hd = 0;			/* index of next handle to fill */

dofile(fname,flag,sym)
char *fname;
int flag;
char *sym;
{
    int fd;

    DEBUG2("Dofile `%s' %s",fname,flag ? "INCLUDE" : "NORMAL");
    if (flag) DEBUG1(" symbol %s",sym);
    DEBUG0("\n");

    if (hd == NHANDLES) {
	if (flush_handles()) return TRUE;
    }
    
    if ((fd = tryopen(&fname)) < 0) {
	printf("Cannot find input module %s\n",fname);
	return TRUE;
    }
    
    /* the file is open; save its info in the handle and name arrays */
    
    handle[hd] = fd;
    name[hd]=fname;		/* this is the malloc()ed name from tryopen */
    hflag[hd] = flag;
    if (flag) {
	int temp;
	
	temp = strlen(sym);
	/* 8 is max length of a symbol */
	if (temp > 8) {
	    sym[8] = '\0';
	    temp = 8;
	}

	/* malloc enough for two symbols, then build the second one */
	/* second one may be one char longer than first */
	if ((hsym1[hd] = malloc((long)temp+1)) == NULL ||
	    (hsym2[hd] = malloc((long)temp+2)) == NULL) {
		printf("Out of memory for include-file symbols\n");
		return TRUE;
	    }
	strcpy(hsym1[hd],sym);
	strcpy(hsym2[hd],sym);

	if (temp == 8) {
	    if (sym[7] == 'x') {
		printf("Last char of %s is already 'x': choose another name\n",
		       sym);
		return TRUE;
	    }
	    hsym2[hd][7] = 'x';
	}
	else {
	    hsym2[hd][temp] = 'x';
	    hsym2[hd][temp+1] = '\0';
	}
    }
    
    hd++;

    return FALSE;			/* no problem; just continue */
}

/*
 * try opening "name", "name.o", "${libdir}name", "${libdir}name.o"
 * return the handle of the file successfully opened.
 *
 * P_name is updated to point to a malloc()'ed string which is
 * the name which actually got opened.
 *
 * P_name will return unchanged if the file can't be found.
 */

tryopen(p_name)
char **p_name;
{
    char *name = *p_name;
    char *tmpbuf, *lastdot;
    int fd, hasdot;

    /* note that libdir will be an empty string if there is none specified */
    if ((tmpbuf = malloc((long)strlen(name) + strlen(libdir) + 3)) == NULL) {
	printf("Out of memory\n");
	return -1;
    }
    strcpy(tmpbuf,name);
    
    hasdot = ((lastdot = rindex(tmpbuf,'.')) > rindex(tmpbuf,'/')) &&
	       (lastdot > rindex(tmpbuf,'\\'));

    if ((fd = OPEN(tmpbuf,0)) >= 0) goto ok;
    if (!hasdot) {
	strcat(tmpbuf,".o");
	if ((fd = OPEN(tmpbuf,0)) >= 0) goto ok;
    }

    /* try the libdir only if the name isn't already anchored */

    if (*name != '/' && *name != '\\' && !index(name,':')) {
	strcpy(tmpbuf,libdir);
	/* add a trailing path char if there isn't one already */
	pathadd(tmpbuf);
	strcat(tmpbuf,name);
	if ((fd = OPEN(tmpbuf,0)) >= 0) goto ok;
	if (!hasdot) {
	    strcat(tmpbuf,".o");
	    if ((fd = OPEN(tmpbuf,0)) >= 0) goto ok;
	}
    }

    /* really not found */
    return -1;

  ok:
    if ((tmpbuf = realloc(tmpbuf,(long)strlen(tmpbuf)+1)) == NULL) {
	printf("Out of memory\n");
	return -1;
    }
    *p_name = tmpbuf;
    return fd;
}

/*
 * pathadd: add a path character to the end of string 's' if it doesn't
 * already end with one.
 *
 * The last occurrance of '/' or '\\' in the string is assumed to be
 * the path character.
 */

pathadd(s)
register char *s;
{
    char pathchar;

    while (*s) {
	if (*s == '/' || *s == '\\') pathchar = *s;
	s++;
    }
    s--;
    if (*s == pathchar) return;

    *++s = pathchar;
    *++s = 0;
}

flush_handles()
{
    register int i;
    char magic[2];
    
    DEBUG0("Flush_handles()\n");
    for (i = 0; i < hd; i++) {
	if (vflag > 1) {
	    printf("Read file %s%s\n",name[i],hflag[i] ? " (include)" : "");
	}
	if (!hflag[i]) {
#ifdef ATARIST
	    if (!isofile(name[i])) {
#endif ATARIST
		if (READ(handle[i],magic,2) != 2) {
		    printf("Error reading file %s\n",name[i]);
		    CLOSE(handle[i]);
		    return TRUE;
		}
		
		FSEEK(handle[i],0L,0);		/* reset to start of file */
		
		if ((unsigned)getword(magic) == 0xff65) {
		    if (doarchive(name[i],handle[i])) return TRUE;
		}
		else if (getword(magic) == 0x601a) {
		    if (doobject (name[i],handle[i],0L)) return TRUE;
		}
		else {
		    printf("Error: %s is neither an object file nor an archive\n",
			   name[i]);
		    CLOSE(handle[i]);
		    return TRUE;
		}
#ifdef ATARIST
	    }
	    else {
		long memavail;	/* &memavail is around our sp */
		long amt;	/* amount actually read from the file */
		char *lsbrk();
		char *brk = lsbrk(0L);
		memavail = (char *)(&memavail)-1024-brk;
		DEBUG1("memavail is %lx\n",memavail);
		amt = READ(handle[i],brk,memavail);
		DEBUG1("amt is %lx\n",amt);
		if (amt < 0) {
		    printf("Error reading file %s\n",name[i]);
		    CLOSE(handle[i]);
		    return TRUE;
		}
		if (getword(brk) == 0x601a) {
		    /* object file: update break and send to doobject */
		    if (amt >= memavail) {
			printf("Out of memory while reading file %s\n",name[i]);
			return TRUE;
		    }
		    if (lsbrk(amt) == (char *)-1) {
			printf("Out of memory while reading file %s\n",name[i]);
			return TRUE;
		    }
		    CLOSE(handle[i]);
		    if (doobject(name[i],handle[i],brk)) return TRUE;
		}
		else if (getword(brk) == 0xff65) {
		    /* it's an object file after all: forget what we read */
		    if (doarchive(name[i],handle[i])) return TRUE;
		}
		else {
		    printf("Error: %s is neither an object file nor an archive\n",
			   name[i]);
		    return TRUE;
		}
	    } /* close else (!isofile) */
#endif ATARIST
	} /* close if(!hflag[i]) */
	else {
	    /* include file */
	    /* if hflag[i] is 1, include this in the data segment; if 2, put in in text */
	    if (doinclude(name[i],handle[i],hsym1[i],hsym2[i],hflag[i]-1)) return TRUE;
	}
    }
    
    for (i=0; i<hd; i++) {
	free(name[i]); /* free them all at once */
	if (hflag[i]) {
	    free(hsym1[i]);
	    free(hsym2[i]);
	}
    }
    
    hd = 0;
    return FALSE;
}

#ifdef ATARIST
isofile(name)
char *name;
{
    int i;
    for (i=0; name[i]; i++);
    return (i > 2) && (name[i-1] == 'o') && (name[i-2] == '.');
}

	
#endif ATARIST

