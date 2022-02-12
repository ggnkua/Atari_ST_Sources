char *ckzv = "Unix file support, 4E(037) 27 Jan 88";

/* C K U F I O  --  Kermit file system support for Unix systems */

/* 4E, conditionals added for Apollo Aegis. */

/*
 Author: Frank da Cruz (SY.FDC@CU20B),
 Columbia University Center for Computing Activities, January 1985.
 Copyright (C) 1985, Trustees of Columbia University in the City of New York.
 Permission is granted to any individual or institution to use, copy, or
 redistribute this software so long as it is not sold for profit, provided this
 copyright notice is retained. 
*/
/* Includes */

#include <sys/types.h>			/* Data types */
#include "ckcker.h"			/* Kermit definitions */
#include "ckcdeb.h"			/* Typedefs, debug formats, etc */
#include <ctype.h>			/* Character types */
#include <stdio.h>			/* Standard i/o */
#ifdef MINIX
#include <limits.h>
#endif
#include <dirent.h>			/* Directory structure */
#include <pwd.h>			/* Password file for shell name */

#ifdef CIE
#include <stat.h>			/* File status */
#else
#include <sys/stat.h>
#endif


/* Berkeley Unix Version 4.x */
/* 4.1bsd support added by Charles E Brooks, EDN-VAX */

#ifdef BSD4
#ifdef MAXNAMLEN
#define BSD42
char *ckzsys = " 4.2 BSD";
#else
#ifdef FT18
#define BSD41
char *ckzsys = " Fortune For:Pro 1.8";
#else
#define BSD41
char *ckzsys = " 4.1 BSD";
#endif
#endif
#endif

/* 2.9bsd support contributed by Bradley Smith, UCLA */
#ifdef BSD29
char *ckzsys = " 2.9 BSD";
#endif

/* Version 7 Unix  */
#ifdef V7
char *ckzsys = " Version 7 Unix";
#endif

/* DEC Professional-300 series with Venturcom Venix v1 */
#ifdef PROVX1
char *ckzsys = " DEC Pro-3xx/Venix v1";
#endif

/* NCR Tower support contributed by John Bray, Auburn, AL. */
/* Tower OS is like Sys III but with BSD features -- mostly follows BSD. */
#ifdef TOWER1
char *ckzsys = " NCR Tower 1632, OS 1.02";
#endif

/* Sys III/V, Xenix, PC/IX,... support by Herm Fischer, Litton Data Systems */
#ifdef UXIII
#ifdef XENIX
char *ckzsys = " Xenix/286";
#else
#ifdef PCIX
char *ckzsys = " PC/IX";
#else
#ifdef ISIII
char *ckzsys = " Interactive Systems Corp, System III";
#else
#ifdef ZILOG
char *ckzsys = " Zilog S8000 Zeus 3.21+";
#else
char *ckzsys = " AT&T System III/System V";
#endif
#endif
#endif
#endif
#endif

/* Definitions of some Unix system commands */

char *DELCMD = "rm -f ";		/* For file deletion */
char *PWDCMD = "pwd ";			/* For saying where I am */

#ifdef FT18
char *DIRCMD = "ls -l | more ";		/* For directory listing */
char *TYPCMD = "more ";			/* For typing a file */
#else
char *TYPCMD = "cat ";			/* For typing a file */
char *DIRCMD = "ls -l ";		/* For directory listing */
#endif

#ifdef FT18
#undef BSD4
#endif

#ifdef BSD4
char *SPACMD = "pwd ; quota ; df .";	/* Space/quota of current directory */
#else
#ifdef FT18
char #SPACMD = "pwd ; du ; df .";
#else
char *SPACMD = "df ";
#endif
#endif

char *SPACM2 = "df ";			/* For space in specified directory */

#ifdef FT18
#define BSD4
#endif

#ifdef BSD4
char *WHOCMD = "finger ";		/* For seeing who's logged in */
#else
char *WHOCMD = "who ";			/* For seeing who's logged in */
#endif

/*
  Functions (n is one of the predefined file numbers from ckermi.h):

   zopeni(n,name)   -- Opens an existing file for input.
   zopeno(n,name)   -- Opens a new file for output.
   zclose(n)        -- Closes a file.
   zchin(n,&c)      -- Gets the next character from an input file.
   zsout(n,s)       -- Write a null-terminated string to output file, buffered.
   zsoutl(n,s)      -- Like zsout, but appends a line terminator.
   zsoutx(n,s,x)    -- Write x characters to output file, unbuffered.
   zchout(n,c)      -- Add a character to an output file, unbuffered.
   zchki(name)      -- Check if named file exists and is readable, return size.
   zchko(name)      -- Check if named file can be created.
   znewn(name,s)    -- Make a new unique file name based on the given name.
   zdelet(name)     -- Delete the named file.
   zxpand(string)   -- Expands the given wildcard string into a list of files.
   znext(string)    -- Returns the next file from the list in "string".
   zxcmd(cmd)       -- Execute the command in a lower fork.
   zclosf()         -- Close input file associated with zxcmd()'s lower fork.
   zrtol(n1,n2)     -- Convert remote filename into local form.
   zltor(n1,n2)     -- Convert local filename into remote form.
   zchdir(dirnam)   -- Change working directory.
   zhome()          -- Return pointer to home directory name string.
   zkself()         -- Kill self, log out own job.
 */

#ifdef FT18
#define PROVX1
#endif

/* Which systems include <sys/file.h>... */
#ifndef PROVX1
#ifndef aegis
#ifndef CIE
#ifndef MINIX
#ifndef XENIX
/* Watch out, some versions of Xenix might need to do this include, */
/* but reportedly SCO Xenix 2.2 on an 80x86 system does not. */
#include <sys/file.h>			/* File access */
#endif
#endif
#endif
#endif
#endif

#ifdef FT18
#undef PROVX1
#endif

/* Some systems define these symbols in include files, others don't... */
#ifndef R_OK
#define R_OK 4				/* For access */
#endif

#ifndef W_OK
#define W_OK 2
#endif

#ifdef PROVX1
#define MAXNAMLEN DIRSIZ		/* Max file name length */
#endif

#ifdef UXIII
#include <fcntl.h>
#define MAXNAMLEN DIRSIZ
#endif

#ifndef O_RDONLY
#define O_RDONLY 000
#endif

#ifndef MAXNAMLEN
#define MAXNAMLEN 14			/* If still not defined... */
#endif

#ifdef PROVX1
#define MAXWLD 50			/* Maximum wildcard filenames */
#else
#ifdef BSD29
#define MAXWLD 50			/* Maximum wildcard filenames */
#else
#define MAXWLD 500
#endif
#endif

/* Declarations */

FILE *fp[ZNFILS] = { 			/* File pointers */
    NULL, NULL, NULL, NULL, NULL, NULL, NULL };

static int pid;	    			/* pid of child fork */
static int fcount;			/* Number of files in wild group */
static char nambuf[MAXNAMLEN+2];	/* Buffer for a filename */
char *malloc(), *getenv(), *strcpy();	/* System functions */
extern errno;				/* System error code */

static char *mtchs[MAXWLD],		/* Matches found for filename */
     **mtchptr;				/* Pointer to current match */

/*  Z K S E L F  --  Kill Self: log out own job, if possible.  */

/* Note, should get current pid, but if your system doesn't have */
/* getppid(), then just kill(0,9)...  */

zkself() {				/* For "bye", but no guarantee! */
#ifdef PROVX1
    return(kill(0,9));
#else
#ifdef V7
    return(kill(0,9));
#else
#ifdef TOWER1
    return(kill(0,9));
#else
#ifdef FT18
    return(kill(0,9));
#else
#ifdef aegis
    return(kill(0,9));
#else
    return(kill(getppid(),1));
#endif
#endif
#endif
#endif
#endif
}

/*  Z O P E N I  --  Open an existing file for input. */

zopeni(n,name) int n; char *name; {
    debug(F111," zopeni",name,n);
    debug(F101,"  fp","",(int) fp[n]);
    if (chkfn(n) != 0) return(0);
    if (n == ZSYSFN) {			/* Input from a system function? */
        debug(F110," invoking zxcmd",name,0);
	return(zxcmd(name));		/* Try to fork the command */
    }
    if (n == ZSTDIO) {			/* Standard input? */
	if (isatty(0)) {
	    ermsg("Terminal input not allowed");
	    debug(F110,"zopeni: attempts input from unredirected stdin","",0);
	    return(0);
	}
	fp[ZIFILE] = stdin;
	return(1);
    }
    fp[n] = fopen(name,"r");		/* Real file. */
    debug(F111," zopeni", name, (int) fp[n]);
    if (fp[n] == NULL) perror("zopeni");
    return((fp[n] != NULL) ? 1 : 0);
}

/*  Z O P E N O  --  Open a new file for output.  */

zopeno(n,name) int n; char *name; {
    debug(F111," zopeno",name,n);
    if (chkfn(n) != 0) return(0);
    if ((n == ZCTERM) || (n == ZSTDIO)) {   /* Terminal or standard output */
	fp[ZOFILE] = stdout;
	debug(F101," fp[]=stdout", "", (int) fp[n]);
	return(1);
    }
    fp[n] = fopen(name,"w");		/* A real file, try to open */
    if (fp[n] == NULL) {
        perror("zopeno can't open");
    } else {
	chown(name, getuid(), getgid());     /* In case set[gu]id */
        if (n == ZDFILE) setbuf(fp[n],(char *)NULL); /* Debugging file unbuffered */
    }
    debug(F101, " fp[n]", "", (int) fp[n]);
    return((fp[n] != NULL) ? 1 : 0);
}

/*  Z C L O S E  --  Close the given file.  */

/*  Returns 0 if arg out of range, 1 if successful, -1 if close failed.  */

zclose(n) int n; {
    int x;
    if (chkfn(n) < 1) return(0);	/* Check range of n */
    if ((n == ZIFILE) && fp[ZSYSFN]) {	/* If system function */
    	x = zclosf();			/* do it specially */
    } else {
    	if ((fp[n] != stdout) && (fp[n] != stdin)) x = fclose(fp[n]);
	fp[n] = NULL;
    }
    return((x == EOF) ? -1 : 1);
}

/*  Z C H I N  --  Get a character from the input file.  */

/*  Returns -1 if EOF, 0 otherwise with character returned in argument  */

zchin(n,c) int n; char *c; {
    int a;
    if (chkfn(n) < 1) return(-1);
    a = getc(fp[n]);
    if (a == EOF) return(-1);
    *c = a & 0377;
    return(0);
}

/*  Z S O U T  --  Write a string to the given file, buffered.  */

zsout(n,s) int n; char *s; {
    if (chkfn(n) < 1) return(-1);
    fputs(s,fp[n]);
    return(0);
}

/*  Z S O U T L  --  Write string to file, with line terminator, buffered  */

zsoutl(n,s) int n; char *s; {
    if (chkfn(n) < 1) return(-1);
    fputs(s,fp[n]);
    fputs("\n",fp[n]);
    return(0);
}

/*  Z S O U T X  --  Write x characters to file, unbuffered.  */

zsoutx(n,s,x) int n, x; char *s; {
    if (chkfn(n) < 1) return(-1);
/*  return(write(fp[n]->_file,s,x));  */
    return(write(fileno(fp[n]),s,x));
}


/*  Z C H O U T  --  Add a character to the given file.  */

/*  Should return 0 or greater on success, -1 on failure (e.g. disk full)  */

zchout(n,c) int n; char c; {
    if (chkfn(n) < 1) return(-1);
    if (n == ZSFILE)
    	return(write(fileno(fp[n]),&c,1)); /* Use unbuffered for session log */
    else {				/* Buffered for everything else */
	if (putc(c,fp[n]) == EOF)	/* If true, maybe there was an error */
	    return(ferror(fp[n])?-1:0);	/* Check to make sure */
	else				/* Otherwise... */
	    return(0);			/* There was no error. */
    }
}

/*  C H K F N  --  Internal function to verify file number is ok  */

/*
 Returns:
  -1: File number n is out of range
   0: n is in range, but file is not open
   1: n in range and file is open
*/
chkfn(n) int n; {
    switch (n) {
	case ZCTERM:
	case ZSTDIO:
	case ZIFILE:
	case ZOFILE:
	case ZDFILE:
	case ZTFILE:
	case ZPFILE:
	case ZSFILE:
	case ZSYSFN: break;
	default:
	    debug(F101,"chkfn: file number out of range","",n);
	    fprintf(stderr,"?File number out of range - %d\n",n);
	    return(-1);
    }
    return( (fp[n] == NULL) ? 0 : 1 );
}

/*  Z C H K I  --  Check if input file exists and is readable  */

/*
  Returns:
   >= 0 if the file can be read (returns the size).
     -1 if file doesn't exist or can't be accessed,
     -2 if file exists but is not readable (e.g. a directory file).
     -3 if file exists but protected against read access.
*/
/*
 For Berkeley Unix, a file must be of type "regular" to be readable.
 Directory files, special files, and symbolic links are not readable.
*/
long
zchki(name) char *name; {
    struct stat buf;
    int x; long y; 

    x = stat(name,&buf);
    if (x < 0) {
	debug(F111,"zchki stat fails",name,errno);
	return(-1);
    }
    x = buf.st_mode & S_IFMT;		/* Isolate file format field */
    if ((x != 0) && (x != S_IFREG)) {
	debug(F111,"zchki skipping:",name,x);
	return(-2);
    }
    debug(F111,"zchki stat ok:",name,x);

    if ((x = access(name,R_OK)) < 0) { 	/* Is the file accessible? */
	debug(F111," access failed:",name,x); /* No */
    	return(-3);			
    } else {
	y = buf.st_size;
	debug(F111," access ok:",name,(int) y); /* Yes */
	return( (y > -1) ? y : 0 );
    }
}

/*  Z C H K O  --  Check if output file can be created  */

/*
 Returns -1 if write permission for the file would be denied, 0 otherwise.
*/
zchko(name) char *name; {
    int i, x;
    char s[50], *sp;	

    sp = s;				/* Make a copy, get length */
    x = 0;
    while ((*sp++ = *name++) != '\0')
    	x++;
    if (x == 0) return(-1);		/* If no filename, fail. */

    debug(F101," length","",x);
    for (i = x; i > 0; i--)		/* Strip filename. */
	if (s[i-1] == '/') break;
    
    debug(F101," i","",i);
    if (i == 0)				/* If no path, use current directory */
    	strcpy(s,"./");			
    else				/* Otherwise, use given one. */
        s[i] = '\0';

    x = access(s,W_OK);			/* Check access of path. */
    if (x < 0) {
	debug(F111,"zchko access failed:",s,errno);
	return(-1);
    } else {
	debug(F111,"zchko access ok:",s,x);
	return(0);
    }
}

/*  Z D E L E T  --  Delete the named file.  */

zdelet(name) char *name; {
    unlink(name);
}


/*  Z R T O L  --  Convert remote filename into local form  */

/*  For UNIX, this means changing uppercase letters to lowercase.  */

zrtol(name,name2) char *name, *name2; {
    for ( ; *name != '\0'; name++) {
    	*name2++ = isupper(*name) ? tolower(*name) : *name;
    }
    *name2 = '\0';
    debug(F110,"zrtol:",name2,0);
}


/*  Z L T O R  --  Local TO Remote */

/*  Convert filename from local format to common (remote) form.  */

zltor(name,name2) char *name, *name2; {
    char work[100], *cp, *pp;
    int dc = 0;
#ifdef aegis
    char *getenv(), *index(), *namechars;
    int tilde = 0, bslash = 0;

    if ((namechars = getenv("NAMECHARS")) != NULL) {
    	if (index(namechars, '~' ) != NULL) tilde  = '~';
    	if (index(namechars, '\\') != NULL) bslash = '\\';
    } else {
        tilde = '~';
        bslash = '\\';
    }
#endif

    debug(F110,"zltor",name,0);
    pp = work;
#ifdef aegis
    cp = name;
    if (tilde && *cp == tilde)
    	++cp;
    for (; *cp != '\0'; cp++) {	/* strip path name */
    	if (*cp == '/' || *cp == bslash) {
#else
    for (cp = name; *cp != '\0'; cp++) {	/* strip path name */
    	if (*cp == '/') {
#endif
	    dc = 0;
	    pp = work;
	}
	else if (islower(*cp)) *pp++ = toupper(*cp); /* Uppercase letters */
	else if (*cp == '~') *pp++ = 'X';	/* Change tilde to 'X' */
	else if (*cp == '#') *pp++ = 'X';	/* Change number sign to 'X' */
	else if ((*cp == '.') && (++dc > 1)) *pp++ = 'X'; /* & extra dots */
	else *pp++ = *cp;
    }
    *pp = '\0';				/* Tie it off. */
    cp = name2;				/* If nothing before dot, */
    if (*work == '.') *cp++ = 'X';	/* insert 'X' */
    strcpy(cp,work);
    debug(F110," name2",name2,0);
}    


/*  Z C H D I R  --  Change directory  */

zchdir(dirnam) char *dirnam; {
    char *hd;
    if (*dirnam == '\0') hd = getenv("HOME");
    else hd = dirnam;
    return((chdir(hd) == 0) ? 1 : 0);
}


/*  Z H O M E  --  Return pointer to user's home directory  */

char *
zhome() {
    return(getenv("HOME"));
}

/*  Z G T D I R  --  Return pointer to user's current directory  */

char *
zgtdir() {

#ifdef MAXPATHLEN
#define CWDBL MAXPATHLEN
#else
#define CWDBL 100
#endif

#ifdef UXIII
    char cwdbuf[CWDBL+1];
    char *buf;
    char *getcwd();
    buf = cwdbuf;
    return(getcwd(buf,CWDBL));
#else
#ifdef BSD4
    char cwdbuf[CWDBL+1];
    char *buf;
    char *getwd();
    buf = cwdbuf;
    return(getwd(buf));
#else
    return("(directory unknown)");
#endif
#endif
}

/*  Z X C M D -- Run a system command so its output can be read like a file */

zxcmd(comand) char *comand; {
    int pipes[2];
    if (pipe(pipes) != 0) {
	debug(F100,"zxcmd pipe failure","",0);
	return(0);			/* can't make pipe, fail */
    }
#ifdef aegis
    if ((pid = vfork()) == 0) {		/* child */
#else
    if ((pid = fork()) == 0) {		/* child */
#endif


/*#if BSD4*/		/* Code from Dave Tweten@AMES-NAS */
			/* readapted to use getpwuid to find login shell */
			/*   -- H. Fischer */
	char *shpath, *shname, *shptr;	/* to find desired shell */
#ifndef aegis
	struct passwd *p;
	extern struct passwd * getpwuid();
	extern int getuid();
	char *defShel = "/bin/sh";	/* default shell */
#endif

	close(pipes[0]);		/* close input side of pipe */
	close(0);			/* close stdin */
	if (open("/dev/null",0) < 0) return(0);	/* replace input by null */

#ifndef UXIII
	dup2(pipes[1],1);		/* replace stdout & stderr */
	dup2(pipes[1],2);		/* by the pipe */
#else
	close(1);			/* simulate dup2 */
	if (dup(pipes[1]) != 1 )
	    conol("trouble duping stdout in routine zxcmd\n");
	close(2);			/* simulate dup2 */
	if (dup(pipes[1]) != 2 )
	    conol("trouble duping stderr in routine zxcmd\n");
#endif

	close(pipes[1]);		/* get rid of this copy of the pipe */

#ifdef aegis
	if ((shpath = getenv("SERVERSHELL")) == NULL) shpath = "/bin/sh";
#else

/**** 	shptr = shname = shpath = getenv("SHELL");  /* What shell? */
	p = getpwuid( getuid() );	/* get login data */
	if ( p == (struct passwd *) NULL || !*(p->pw_shell) ) shpath = defShel;
	  else shpath = p->pw_shell;
#endif
	shptr = shname = shpath;
	while (*shptr != '\0') if (*shptr++ == '/') shname = shptr;
	debug(F100,"zxcmd...","",0);
	debug(F110,shpath,shname,0);

/* Remove the following uid calls if they cause trouble... */
#ifdef BSD4
	setegid(getgid());		/* Override 4.3BSD csh */
	seteuid(getuid());		/*  security checks */
#endif /* bsd4 */

	execl(shpath,shname,"-c",comand,(char *)NULL); /* Execute the cmd */
	exit(0);			/* just punt if it failed. */
    } else if (pid == -1) {
	debug(F100,"zxcmd fork failure","",0);
	return(0);
    }
    close(pipes[1]);			/* don't need the output side */
    fp[ZIFILE] = fdopen(pipes[0],"r");	/* open a stream for it */
    fp[ZSYSFN] = fp[ZIFILE];		/* Remember. */
    return(1);
}

/*  Z C L O S F  - wait for the child fork to terminate and close the pipe. */

zclosf() {
    int wstat;
    if (kill(pid,9) == 0) {
	debug(F101,"zclosf pid =","",pid);
        while ((wstat = wait((int *)0)) != pid && wstat != -1) ;
        pid = 0;
    }
    fclose(fp[ZIFILE]);
    fp[ZIFILE] = fp[ZSYSFN] = NULL;
    return(1);
}

/*  Z X P A N D  --  Expand a wildcard string into an array of strings  */
/*
  Returns the number of files that match fn1, with data structures set up
  so that first file (if any) will be returned by the next znext() call.
*/
zxpand(fn) char *fn; {
    fcount = fgen(fn,mtchs,MAXWLD);	/* Look up the file. */
    if (fcount > 0) {
	mtchptr = mtchs;		/* Save pointer for next. */
    }
    debug(F111,"zxpand",mtchs[0],fcount);
    return(fcount);
}


/*  Z N E X T  --  Get name of next file from list created by zxpand(). */
/*
 Returns >0 if there's another file, with its name copied into the arg string,
 or 0 if no more files in list.
*/
znext(fn) char *fn; {
    if (fcount-- > 0) strcpy(fn,*mtchptr++);
    else *fn = '\0';
    debug(F111,"znext",fn,fcount+1);
    return(fcount+1);
}


/*  Z N E W N  --  Make a new name for the given file  */

znewn(fn,s) char *fn, **s; {
#ifdef BSD4
    static char buf[256];
#else
    static char buf[100];
#endif
    char *bp, *xp;
    int len = 0, n = 0, d = 0, t, i, power = 1;
#ifdef MAXNAMLEN
    int max = MAXNAMLEN;
#else
    int max = 14;
#endif
    bp = buf;
    while (*fn) {			/* Copy name into buf */
	*bp++ = *fn++;
	len++;
    }
    if (len > max-2) { 			/* Don't let it get too long */
	bp = buf + max-2;
	len = max - 2;
    }
	
    for (i = 1; i < 4; i++) {		/* Try up to 999 times */
	power *= 10;
	*bp++ = '*';			/* Put a star on the end */
	*bp-- = '\0';
	
	n = zxpand(buf);		/* Expand the resulting wild name */
    
	while (n-- > 0) {		/* Find any existing name~d files */
	    xp = *mtchptr++;
	    xp += len;
	    if (*xp == '~') {
		t = atoi(xp+1);
		if (t > d) d = t;	/* Get maximum d */
	    }
	}
	if (d < power-1) {
	    sprintf(bp,"~%d",d+1);	/* Make name~(d+1) */
	    *s = buf;
	    return;
	}
	bp--; len--;
    }
/* If we ever get here, we'll overwrite the xxx~100 file... */
}

/* Directory Functions for Unix, written by Jeff Damens, CUCCA, 1984. */

/*
 * The path structure is used to represent the name to match.
 * Each slash-separated segment of the name is kept in one
 * such structure, and they are linked together, to make
 * traversing the name easier.
 */

struct path {
              char npart[MAXNAMLEN];	/* name part of path segment */
              struct path *fwd;		/* forward ptr */
            };

#ifdef PROVX1
#define SSPACE 500
#else
#ifdef BSD29
#define SSPACE 500
#else
#ifdef aegis
#define SSPACE 10000			/* size of string-generating buffer */
static char bslash;			/* backslash character if active */
#else
#define SSPACE 2000			/* size of string-generating buffer */
#endif
#endif
#endif
static char sspace[SSPACE];             /* buffer to generate names in */
static char *freeptr,**resptr;         	/* copies of caller's arguments */
static int remlen;                      /* remaining length in caller's array*/
static int numfnd;                      /* number of matches found */

/*
 * splitpath:
 *  takes a string and splits the slash-separated portions into
 *  a list of path structures.  Returns the head of the list.  The
 *  structures are allocated by malloc, so they must be freed.
 *  Splitpath is used internally by the filename generator.
 *
 * Input: A string.
 * Returns: A linked list of the slash-separated segments of the input.
 */

struct path *
splitpath(p)
char *p;
{
 struct path *head,*cur,*prv;
 int i;
 head = prv = NULL;
 if (*p == '/') p++;            /* skip leading slash */
 while (*p != '\0')
 {
   cur = (struct path *) malloc(sizeof (struct path));
   debug(F101,"splitpath malloc","",cur);
   if (cur == NULL) fatal("malloc fails in splitpath()");
   cur -> fwd = NULL;
   if (head == NULL) head = cur;
   else prv -> fwd = cur;       /* link into chain */
   prv = cur;
#ifdef aegis
   /* treat backslash as "../" */
   if (bslash && *p == bslash) {
     strcpy(cur->npart, "..");
     ++p;
   } else {
     for (i=0; i < MAXNAMLEN && *p && *p != '/' && *p != bslash; i++)
       cur -> npart[i] = *p++;
     cur -> npart[i] = '\0';      /* end this segment */
     if (i >= MAXNAMLEN) while (*p && *p != '/' && *p != bslash) p++;
   }
   if (*p == '/') p++;
#else
   for (i=0; i < MAXNAMLEN && *p != '/' && *p != '\0'; i++)
     cur -> npart[i] = *p++;
   cur -> npart[i] = '\0';      /* end this segment */
   if (i >= MAXNAMLEN) while (*p != '/' && *p != '\0') p++;
   if (*p == '/') p++;
#endif
 }
 return(head);
}

/*
 * fgen:
 *  This is the actual name generator.  It is passed a string,
 *  possibly containing wildcards, and an array of character pointers.
 *  It finds all the matching filenames and stores them into the array.
 *  The returned strings are allocated from a static buffer local to
 *  this module (so the caller doesn't have to worry about deallocating
 *  them); this means that successive calls to fgen will wipe out
 *  the results of previous calls.  This isn't a problem here
 *  because we process one wildcard string at a time.
 *
 * Input: a wildcard string, an array to write names to, the
 *        length of the array.
 * Returns: the number of matches.  The array is filled with filenames
 *          that matched the pattern.  If there wasn't enough room in the
 *	    array, -1 is returned.
 * By: Jeff Damens, CUCCA, 1984.
 */

fgen(pat,resarry,len)
char *pat,*resarry[];
int len;
{
 struct path *head;
 char scratch[100],*sptr;
#ifdef aegis
 char *getenv(), *index(), *namechars;
 int tilde = 0, bquote = 0;

 if ((namechars = getenv("NAMECHARS")) != NULL) {
  if (index(namechars, '~' ) != NULL) tilde  = '~';
  if (index(namechars, '\\') != NULL) bslash = '\\';
  if (index(namechars, '`' ) != NULL) bquote = '`';
 }
 else { tilde = '~'; bslash = '\\'; bquote = '`'; }

 sptr = scratch;
 /* copy "`node_data", etc. anchors */
 if (bquote && *pat == bquote)
  while (*pat && *pat != '/' && *pat != bslash)
   *sptr++ = *pat++;
 else if (tilde && *pat == tilde)
  *sptr++ = *pat++;
 while (*pat == '/')
  *sptr++ = *pat++;
 if (sptr == scratch)
 {
  strcpy(scratch,"./");
  sptr = scratch+2;
 }					/* init buffer correctly */
 head = splitpath(pat);
#else
 head = splitpath(pat);
 if (*pat == '/')
 {
  scratch[0] = '/';
  sptr = scratch+1;
 }
 else
 {
  strcpy(scratch,"./");
  sptr = scratch+2;
 }					/* init buffer correctly */
#endif
 numfnd = 0;                            /* none found yet */
 freeptr = sspace;			/* this is where matches are copied */
 resptr = resarry;			/* static copies of these so*/
 remlen = len;				/* recursive calls can alter them */
 traverse(head,scratch,sptr);		/* go walk the directory tree */
 for (; head != NULL; head = head -> fwd)
   free(head);				/* return the path segments */
 return(numfnd);			/* and return the number of matches */
}

/* traverse:
 *  Walks the directory tree looking for matches to its arguments.
 *  The algorithm is, briefly:
 *   If the current pattern segment contains no wildcards, that
 *   segment is added to what we already have.  If the name so far
 *   exists, we call ourselves recursively with the next segment
 *   in the pattern string; otherwise, we just return.
 *
 *   If the current pattern segment contains wildcards, we open the name
 *   we've accumulated so far (assuming it is really a directory), then read
 *   each filename in it, and, if it matches the wildcard pattern segment, add
 *   that filename to what we have so far and call ourselves recursively on the
 *   next segment.
 *
 *   Finally, when no more pattern segments remain, we add what's accumulated
 *   so far to the result array and increment the number of matches.
 *
 * Input: a pattern path list (as generated by splitpath), a string
 *	  pointer that points to what we've traversed so far (this
 *	  can be initialized to "/" to start the search at the root
 *	  directory, or to "./" to start the search at the current
 *	  directory), and a string pointer to the end of the string
 *	  in the previous argument.
 * Returns: nothing.
 */
traverse(pl,sofar,endcur)
struct path *pl;
char *sofar,*endcur;
{
 DIR *fd, *opendir();
 struct dirent *dirbuf;
 struct stat statbuf;
 if (pl == NULL)
 {
  *--endcur = '\0';                    /* end string, overwrite trailing / */
  addresult(sofar);
  return;
 }
 if (!iswild(pl -> npart))
 {
  strcpy(endcur,pl -> npart);
  endcur += strlen(pl -> npart);
  *endcur = '\0';                     	/* end current string */
  if (stat(sofar,&statbuf) == 0)	/* if current piece exists */
  {
      *endcur++ = '/';                  /* add slash to end */
      *endcur = '\0';			/* and end the string */
      traverse(pl -> fwd,sofar,endcur);
  }
  return;
 }
/* cont'd... */

/*...traverse, cont'd */

/* segment contains wildcards, have to search directory */
 *endcur = '\0';                        	/* end current string */
 if (stat(sofar,&statbuf) == -1) return;   	/* doesn't exist, forget it */
 if ((statbuf.st_mode & S_IFDIR) == 0) return;  /* not a directory, skip */
 if ((fd = opendir(sofar)) == NULL) return;  	/* can't open, forget it */
 while (dirbuf = readdir(fd))
{
  strncpy(nambuf,dirbuf->d_name,MAXNAMLEN); /* Get a null terminated copy!!! */
  nambuf[MAXNAMLEN] = '\0';
  if (dirbuf->d_ino != 0 && match(pl -> npart,nambuf)) {
    char *eos;
    strcpy(endcur,nambuf);
    eos = endcur + strlen(nambuf);
    *eos = '/';                    /* end this segment */
    traverse(pl -> fwd,sofar,eos+1);
  }
}
 closedir(fd);
}

/*
 * addresult:
 *  Adds a result string to the result array.  Increments the number
 *  of matches found, copies the found string into our string
 *  buffer, and puts a pointer to the buffer into the caller's result
 *  array.  Our free buffer pointer is updated.  If there is no
 *  more room in the caller's array, the number of matches is set to -1.
 * Input: a result string.
 * Returns: nothing.
 */

addresult(str)
char *str;
{
 int l;
 if (strncmp(str,"./",2) == 0) str += 2;
 if (--remlen < 0) {
  numfnd = -1;
  return;
 }
 l = strlen(str) + 1;			/* size this will take up */
 if ((freeptr + l) > &sspace[SSPACE-1]) {
    numfnd = -1;			/* do not record if not enough space */
    return;
  }
 strcpy(freeptr,str);
 *resptr++ = freeptr;
 freeptr += l;
 numfnd++;
}

iswild(str)
char *str;
{
 char c;
 while ((c = *str++) != '\0')
   if (c == '*' || c == '?') return(1);
 return(0);
}

/*
 * match:
 *  pattern matcher.  Takes a string and a pattern possibly containing
 *  the wildcard characters '*' and '?'.  Returns true if the pattern
 *  matches the string, false otherwise.
 * by: Jeff Damens, CUCCA
 *
 * Input: a string and a wildcard pattern.
 * Returns: 1 if match, 0 if no match.
 */

match(pattern,string) char *pattern,*string; {
    char *psave,*ssave;			/* back up pointers for failure */
    psave = ssave = NULL;
    while (1) {
	for (; *pattern == *string; pattern++,string++)  /* skip first */
	    if (*string == '\0') return(1);	/* end of strings, succeed */
	if (*string != '\0' && *pattern == '?') {
	    pattern++;			/* '?', let it match */
	    string++;
	} else if (*pattern == '*') {	/* '*' ... */
	    psave = ++pattern;		/* remember where we saw it */
	    ssave = string;		/* let it match 0 chars */
	} else if (ssave != NULL && *ssave != '\0') {	/* if not at end  */
  					/* ...have seen a star */
	    string = ++ssave;		/* skip 1 char from string */
	    pattern = psave;		/* and back up pattern */
	} else return(0);		/* otherwise just fail */
    }
}
