#include <osbind.h>
#include <stdlib.h>
#include <types.h>
#include <stat.h>
#include <time.h>
#include <string.h>
#include "errors.i"
#include "zoofns.h"

#ifdef __GNUC__
size_t __DEFAULT_BUFSIZ__ = 32768L;
long _stksize = 16384L;
#endif

#ifdef GLOB
static void add_targv(char *s);
extern char **glob(char *, int);
extern int contains_wild(char *);

char **targv = (char **)NULL;
int  targc = 0;
#endif

/****************
Function fixfname() converts the supplied filename to a syntax
legal for the host system.  It is used during extraction.
*/

char *fixfname(fname)
char *fname;
{
        /* note this is valid for gcc lib only, where the lib does file name
         * conversions (see LIBSRC/unx2dos.c)
         */
        return (fname); /* default is no-op */
}

/* No file truncate call for the Atari ST.  Make it a no-op. */
int zootrunc(f)
FILE *f;
{
    return 0;
}

/*
Function gettz(), returns the offset from GMT in seconds of the
local time, taking into account daylight savings time */

#ifdef GETTZ
long gettz()
{
#ifdef __GNUC__
    struct tm *tm;
    static char first_time = 1;
    static long t;
    extern time_t _timezone;

    if(first_time)
    {
        first_time = 0;
        t = time ((long *) 0);
        tm = localtime (&t);
        t = _timezone - tm->tm_isdst*3600;
    }
    return t;
#else
    return 0L;
#endif
}
#endif /* GETTZ */

/* Function isadir() returns 1 if the supplied handle is a directory, 
else it returns 0.  
*/

int isadir (file)
ZOOFILE file;
{
   int handle = fileno(file);
   struct stat buf;           /* buffer to hold file information */
   if (fstat (handle, &buf) == -1) {
      return (0);             /* inaccessible -- assume not dir */
   } else {
      return (buf.st_mode & S_IFMT) == S_IFDIR;
   }
}

#ifdef SPECEXIT
/*
 * detect shells
 */
#include <sysvars.h>
#include <support.h>

static  long    (*shell_p)(char *);
static int _is_a_shell(void)
{
    int ret;
    
    shell_p = (long (*)(char *)) get_sysvar((void *) _shell_p);
    if(!(long)shell_p) return(0);
    ret = 1;
    if(((*((long *)(((long) shell_p)-10))) & 0x00FFFFFFL) == 0x00420135L)
        ret = 2;                                     /* Gulam */
    if(*((long *)(((long) shell_p)-4)) == 0xCDCEC5D2L || /* Master 5.0 */
       *((long *)(((long) shell_p)-8)) == 0x4D415354L)   /* Master 5.4 */
        ret = 3;                                     /* Master */
    if(*((long *)(((long) shell_p)-4)) == 0x21534821L)   /* Craft */
        ret = 4;
    return(ret);
}

void zooexit(status)
int status;
{
    extern char *getenv(const char *);
    char *p;
    char dk = 0;

    if(!getenv("SHELL"))
    { /* no env SHELL */
        if(!(p = getenv("ZOOPAUSE")))
        { /* no env ZOOPAUSE */
            if(!_is_a_shell())
                dk = 1; /* not called from a reasonable shell */
        } else if((*p == 'y') || (*p == 'Y'))
            dk = 1; /* ZOOPAUSE is 'y' or 'Y' */
    }
    if(dk)
    {
        fprintf(stderr,"\nHit any key to exit ......");
        fflush(stderr);
        (void)Bconin(2);
    }
    exit(status);
}
#endif /* SPECEXIT */

#include <types.h>
#include <stat.h>
static int nameisdir(n)
char *n;
{
    struct stat s;

    if(stat(n, &s))
        return 0;
    return ((s.st_mode) & S_IFMT) == S_IFDIR;
}
#ifdef GLOB
int main (argc, argv)
int argc;
char **argv;
{
    int i;
    char **matches;
    int decend_dir;             /* decend subdirs recursively when adding? */
    void free_all(void);
    int  do_globbing = 0;
    
    if (argv[0][0] == '\0')     /* Add program name if we're called */
        add_targv("zoo");       /* from the desktop */ 
    else
        add_targv(argv[0]);     /* Else use what the shell sent */

    if (argc < 2)       /* If there are no commands, let zoo handle it */
        goto no_glob;

    /* Now some hacks for the novice commands */
    if (str_icmp(argv[1], "-backup") == 0)
        strcpy(argv[1], "ah//");
    else if (str_icmp(argv[1], "-restore") == 0)
        strcpy(argv[1], "x//");

    add_targv(argv[1]);         /* Add the commands */

    if (argc < 3)               /* If there's no archive name, let zoo */
        goto no_glob;           /* handle it */
    add_targv(argv[2]);         /* Add the archive name */

    if (argc < 4)               /* If there are no filespecs, we don't */
        goto no_glob;           /* have to glob */

    /* decide is we will do any globbing (only if its an 'a' cmd) */
    if (!(
      (*argv[1] != 'a') && (*argv[1] != 'A') &&
      (str_icmp(argv[1], "-add") != 0) &&
      (str_icmp(argv[1], "-freshen") != 0) &&
      (str_icmp(argv[1], "-update") != 0) &&
      (str_icmp(argv[1], "-move") != 0)))
    do_globbing = 1;
    
    /* Is '//' one of the options given for the `a' command ? */
    decend_dir = ((*argv[1] == 'a') || (*argv[1] == 'A')) &&
             (strstr(argv[1], "//") != NULL);

    /* Now we are going to start adding filenames that we want to send */
    /* to Zoo */ 
    for (i = 3; i < argc; i++)
    {
    /* Does it have any wildcards ? */ 
    if (do_globbing && (contains_wild(argv[i]) ||
                (decend_dir && nameisdir(argv[i]))))
                if ((matches = glob(strlwr(argv[i]), decend_dir)) != NULL)
                {
                        char **m = matches;
                        while(*matches)
                                add_targv(*matches++);
                        free(m);
                }
                else 
                    prterror('e', no_match); /* Not FATAL because */
                                             /* there could have been */
                                             /* some valid files that */
                                             /* didn't contain wildcards */
                                             /* This will probably */
                                             /* change  -- bjsjr */
        else
            add_targv(argv[i]); /* Add any filename that doesn't */
                                /* contain wildcards */
    }
    
no_glob:    
    add_targv("");      /* yes, *nix compatibility */
    targv[--targc] = NULL;

    return zoomain(targc, targv);
}

#define CHUNK_SIZE 16

static void add_targv(char *s)
{
    static size_t allocsize = 0;
    static int avail = 0;
    
    if(avail == 0)
    {  /* need more mem */
        allocsize += (CHUNK_SIZE * sizeof(char **));
        avail = CHUNK_SIZE;
        targv = (char **)((targv == (char **)NULL) ? malloc(allocsize)
                          : realloc(targv, allocsize));
        if(!targv)
            prterror('f', no_memory);
    }

    targv[targc++] = s;
    avail--;
}
#endif /* GLOB */

/* Standard UNIX-compatible time functions */
#include "nixtime.i"

/* Standard UNIX-specific file attribute routines */
#include "nixmode.i"
