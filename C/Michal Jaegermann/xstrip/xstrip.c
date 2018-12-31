/*
 *	strip TOS executable format files of symbol table info
 *	usage: strip [-g] [-k] [-l names] files ...
 *
 *	Original version by ++jrb	bammi@dsrgsun.ces.cwru.edu
 *	(i.e. Jwahar Bammi)
 *	Modified to add extra options -g -k and -l by
 *	Michal Jaegermann		ntomczak@ualtavm.bitnet
 *	November 1st, 1990
 *
 *	-g	keep all global symbols
 *	-k	keep _stksize symbol, so stack size can be adjusted
 *		even for nearly-stripped gcc produced executables
 *	-l nms	keep all symbols listed in a file 'nms'
 *
 *	Modified sources compile both with gcc and Sozobon C
 */
#include <stdio.h>
#ifdef atarist
#ifdef __GNUC__
#  include <memory.h>
#  include <unixlib.h>
#else
#include <malloc.h>
extern long lseek();
#endif
#endif

#ifdef unix
#  include <strings.h>
#  define lwrite write
#  define lread  read
#else
#  include <string.h>
#endif

#include <fcntl.h>

#ifdef __GNUC__
#define NULL		((void *)0)
#endif
#define NEWBUFSIZ	16384L

char            mybuf[NEWBUFSIZ];
char            tmpname[128];

#define SYMLEN 8
typedef char    symstr_t[SYMLEN];
symstr_t        stklist[] = {{'_', '_', 's', 't', 'k', 's', 'i', 'z',},
			     {'\0'}};

long            _stksize = 1L;

#ifdef __STDC__
# define	P(s) s
#else
# define P(s) ()
#endif

void usage P((char *s ));
int main P((int argc , char **argv ));
int strip P((	char *name,
		symstr_t *nmlist,
		long (*select )(int ,int ,long ,symstr_t *)));
long copy P((int from , int to , long bytes ));
void report P((char *s ));
symstr_t *mklist P((char *fname ));
long sel_globs P((int fd , int tfd , long sbytes , symstr_t *nmlist ));
long sel_listed P((int fd , int tfd , long sbytes , symstr_t *nmlist ));

extern char    *getenv P((const char *));

#ifdef __STDC__ 
int 
main (int argc , char **argv ) 
#else
int 
main (argc, argv)
    int             argc;
    char          **argv;
#endif
{
    int             status = 0;
    int             flag = -1;
    symstr_t       *nmlist = (symstr_t *) 0;
    long            (*select) P((int, int, long, symstr_t *));
#ifdef atarist
    char           *tmpdir;
    register int    l;
#endif

    select = (long (*) P((int, int, long, symstr_t *))) 0;
    /* process arguments */
    while (argv++, --argc) {
	if ('-' != **argv)
	    break;
	(*argv)++;
	if ((-1) != flag)
	    usage ("only one option at a time is accepted\r\n");
	flag = **argv;
	switch (flag) {
	case 'g':
	    select = sel_globs;
	    break;
	case 'k':
	    nmlist = stklist;
	    select = sel_listed;
	    break;
	case 'l':
	    (*argv)++;
	    if ('\0' == **argv) {
		--argc;
		argv++;
	    }
	    if ((symstr_t *) 0 == (nmlist = mklist (*argv)))
		usage ("cannot create a list of reserved names\r\n");
	    select = sel_listed;
	    break;
	default:
	    usage ("");
	    break;
	}
    }

    if (argc < 1) {
	usage ("");
    }

#ifdef __GNUC__
#ifdef atarist
    tmpname[0] = '\0';
    if ((tmpdir = getenv ("TEMP")) != NULL) {
	strcpy (tmpname, tmpdir);
	l = (int) strlen (tmpname) - 1;
	if (tmpname[l] == '\\')
	    tmpname[l] = '\0';
    }
    strcat (tmpname, "\\STXXXXXX");
#else
    strcpy (tmpname, "/tmp/STXXXXXX");
#endif

    mktemp (tmpname);
#else /* not __GNUC__ */
    if ((tmpdir = getenv ("TEMP")) != NULL) {
	strcpy (tmpname, tmpdir);
	l = (int) strlen (tmpname) - 1;
	if (tmpname[l] != '\\') {
	    l++;
	    tmpname[l] = '\\';
	}
	l++;
    }
    else {
	l = 0;
    }
    tmpnam (&tmpname[l]);
	
#endif /* __GNUC__ */
    do {
	status |= strip (*argv++, nmlist, select);
    } while (--argc > 0);

    unlink (tmpname);
    return status;
}

#undef P

void
#ifdef __STDC__ 
usage (char *s ) 
#else
usage (s)
    char           *s;
#endif
{
    report (s);
    report ("Usage: strip [-k] [-l names] [-g] files ...\r\n");
    exit (1);
}

#ifdef __GNUC__
#include <st-out.h>
#else
/* include relevant fragments of <st-out.h> file directly */

struct aexec {
	 short	a_magic;	/* magic number */
unsigned long	a_text;		/* size of text segment */
unsigned long	a_data;		/* size of initialized data */
unsigned long	a_bss;		/* size of uninitialized data */
unsigned long	a_syms;		/* size of symbol table */
unsigned long	a_AZero1;	/* always zero */
unsigned long	a_AZero2;	/* always zero */
unsigned short	a_isreloc;	/* is reloc info present */
};
#define	CMAGIC	0x601A		/* contiguous text */

#define	A_BADMAG(x) 	(((x).a_magic)!=CMAGIC)

/*
 * Format of a symbol table entry
 */
struct	asym 
	{
	char		a_name[SYMLEN];	/* symbol name */
	unsigned short	a_type;		/* type flag   */
	unsigned long	a_value;	/* value of this symbol
					   (or sdb offset) */
	};

#define A_GLOBL	0x2000		/* global */
#endif /* __GNUC__ */

#ifdef __STDC__ 
int 
strip (char *name,
       symstr_t * nmlist,
       long (*select) (int, int, long, symstr_t *))
#else
int 
strip (name, nmlist, select)
char *name;
symstr_t * nmlist;
long (*select)();
#endif
{
    register int    fd;
    register int    tfd;
    register long   count, rbytes, sbytes;
    long            lbytes;
    struct aexec    ahead;

    if ((fd = open (name, O_RDONLY, 0666)) < 0) {
	perror (name);
	return 2;
    }
    if ((tfd = open (tmpname, O_WRONLY | O_TRUNC | O_CREAT, 0644)) < 0) {
	perror (tmpname);
	close (fd);
	return 4;
    }
    if ((count = lread (fd, &ahead, (long) sizeof (ahead))) 
    				!= (long) sizeof (ahead)) {
	perror (name);
	close (tfd);
	close (fd);
	return 8;
    }
    if (A_BADMAG (ahead)) {
	report (name);
	report (": Bad Magic number\r\n");
	close (tfd);
	close (fd);
	return 0x10;
    }
    sbytes = ahead.a_syms;
    if (0L == sbytes) {
	report (name);
	report (": Already Stripped\r\n");
	close (tfd);
	close (fd);
	return 0x20;
    }
    if (lseek (fd, 0L, 0) < 0) {
	report (name);
	report (": seek error\r\n");
	close (tfd);
	close (fd);
	return 0x40;
    }
    count = sizeof (ahead) + ahead.a_text + ahead.a_data;
    if (copy (fd, tfd, count) != count) {
	close (tfd);
	close (fd);
	return 0x80;
    }
    if ((long(*)())0 == select) {	 /* remove whole symbol table */
	lbytes = 0L;
	if (lseek (fd, sbytes, 1) < 0) {
	    report (name);
	    report (": seek error\r\n");
	    close (tfd);
	    close (fd);
	    return 0x100;
	}
    }
    else {
	lbytes = ( *select )(fd, tfd, sbytes, nmlist);
    }
    if ((rbytes = copy (fd, tfd, 0x7fffffffL)) < 0) {
	close (tfd);
	close (fd);
	return 0x200;
    }
    if (lseek (tfd, (long)offsetof (struct aexec, a_syms), 0) < 0) {
	close (tfd);
	close (fd);
	return 0x400;
    }
    if (lwrite (tfd, &lbytes, (long)sizeof (lbytes)) != 
    					(long) sizeof (lbytes)) {
	close (tfd);
	close (fd);
	return 0x800;
    }
    close (tfd);
    close (fd);
    if ((fd = open (name, O_WRONLY | O_TRUNC, 0666)) < 0) {
	perror (name);
	return 0x1000;
    }
    if ((tfd = open (tmpname, O_RDONLY, 0666)) < 0) {
	perror (tmpname);
	close (fd);
	return 0x2000;
    }

    count = sizeof (ahead) + ahead.a_text + ahead.a_data + rbytes + lbytes;
    if (copy (tfd, fd, count) != count) {
	close (tfd);
	close (fd);
	return 0x4000;
    }
    close (tfd);
    close (fd);
    return 0;
}

/*
 * copy from, to in NEWBUFSIZ chunks upto bytes or EOF whichever occurs first
 * returns # of bytes copied
 */
#ifdef __STDC__ 
long 
copy (int from , int to , long bytes ) 
#else
long 
copy (from, to, bytes)
int from, to;
long bytes;
#endif
{
    register long   todo, done = 0L, remaining = bytes, actual;

    while (done != bytes) {
	todo = (remaining > NEWBUFSIZ) ? NEWBUFSIZ : remaining;
	if ((actual = lread (from, mybuf, todo)) != todo) {
	    if (actual < 0) {
		report ("Error Reading\r\n");
		return -done;
	    }
	}
	if (lwrite (to, mybuf, actual) != actual) {
	    report ("Error Writing\r\n");
	    return -done;
	}
	done += actual;
	if (actual != todo)	/* eof reached */
	    return done;
	remaining -= actual;
    }
    return done;
}

#ifdef __STDC__ 
void 
report (char *s ) 
#else
void 
report (s)
char * s;
#endif
{
    lwrite (2, s, (long) strlen (s));
}

/*
 * Given a name of a file with reserved symbols create an array of
 * reserved symbol names.  To terminate create an entry which starts
 * with a null character.
 */

#define LBUFSIZE 128
#define NMSTEP 10

#ifdef __STDC__ 
symstr_t       *
mklist (char *fname ) 
#else
symstr_t       *
mklist (fname)
char * fname;
#endif
{
    FILE           *fp;
    symstr_t       *list = (symstr_t *) 0;
    int             left = 0;
    int             pos = 0;
    int             i;
    size_t          max_size = 1;
    char            lbuf[LBUFSIZE];
    char           *in, *out;

    if (NULL == (fp = fopen (fname, "r"))) {
	report (fname);
	report (" -- ");
	usage ("cannot open this file\r\n");
    }

    while (NULL != fgets (lbuf, LBUFSIZE, fp)) {
	if (0 == left) {
	    max_size += NMSTEP;
	    if ((symstr_t *)0 == list) {
		list = (symstr_t *) malloc ( max_size * sizeof (symstr_t));
	    }
	    else {
		list = (symstr_t *) realloc ((void *) list,
					     max_size * sizeof (symstr_t));

	    }
	    if ((symstr_t *)0 == list) {
		report ("out of memory making symbol list\r\n");
		exit (-3);
	    }
	    left = NMSTEP;
	}
	/* strip all leading white space */
	in = lbuf;
	while (' ' == *in || '\t' == *in)
	    in++;
	if ('\n' == *in)
	    continue;		/* empty line - skip it */
	out = &list[pos][0];
	for (i = SYMLEN; i > 0; --i) {
	    if ('\n' == *in || ' ' == *in || '\t' == *in) {
		*out = '\0';
		break;
	    }
	    *out++ = *in++;
	}
	pos++;
	--left;
    }				/* while */
    if ((symstr_t *)0 != list) {
	list[pos][0] = '\0';	/* terminate created list */
    }
    return (list);
}

/*
 * From a file handle fd to a file handle tfd copy up to 'sbytes' bytes
 * of a symbol table selecting only those symbols which have A_GLOBL
 * flag set. Table nmlist is not really used, but is here for a uniform
 * interface.  Returns a number of bytes copied.
 */
#ifdef __STDC__ 
long
sel_globs (int fd , int tfd , long sbytes , symstr_t *nmlist ) 
#else
long
sel_globs (fd, tfd, sbytes, nmlist)
int fd, tfd;
long sbytes;
symstr_t * nmlist;
#endif
{
    long            lbytes = 0;
    struct asym     cur_sym;

    while (sbytes) {
	if ((long)sizeof (cur_sym) != lread (fd, &cur_sym, 
						(long)sizeof (cur_sym))) {
	    report ("error on reading symbol table\r\n");
	    break;
	}
	if (cur_sym.a_type & A_GLOBL) {
	    if ((long) sizeof (cur_sym) != lwrite (tfd, &cur_sym,
	    					(long)sizeof (cur_sym))) {
		report ("error on writing symbol table\r\n");
		break;
	    }
	    lbytes += sizeof (cur_sym);
	}
	sbytes -= sizeof (cur_sym);
    }
    return (lbytes);
}

/*
 * From a file handle fd to a file handle tfd copy up to 'sbytes' bytes
 * of a symbol table selecting only those symbols which are on nmlist.
 * Free nmlist if different from a default global one.
 * Returns a number of bytes copied.
 */
#ifdef __STDC__ 
long
sel_listed (int fd , int tfd , long sbytes , symstr_t *nmlist ) 
#else
long
sel_listed (fd, tfd, sbytes, nmlist)
int fd, tfd;
long sbytes;
symstr_t * nmlist;
#endif
{
    long            lbytes = 0;
    symstr_t       *kname;
    struct asym     cur_sym;

    if ((symstr_t *) 0 == nmlist)
	return (0L);

    while (sbytes) {
	if ((long) sizeof (cur_sym) != lread (fd, &cur_sym,
						(long) sizeof (cur_sym))) {
	    report ("error on reading symbol table\r\n");
	    break;
	}
	for (kname = nmlist; '\0' != **kname; kname++) {
	    if (0 == strncmp (&(*kname)[0], &cur_sym.a_name[0], SYMLEN)) {
		if ((long) sizeof (cur_sym) != lwrite (tfd, &cur_sym,
						(long) sizeof (cur_sym))) {
		    report ("error on writing symbol table\r\n");
		    goto leave;
		}
		lbytes += sizeof (cur_sym);
		break;
	    }
	}
	sbytes -= sizeof (cur_sym);
    }				/* while */
leave:
    if (nmlist != stklist) {
	free (nmlist);
	nmlist = (symstr_t *) 0;
    }
    return (lbytes);
}
