/*------------------------------------------------------------------------

  amiga.c

  Amiga-specific routines for use with Info-ZIP's UnZip 5.1 and later.
  See History.5xx for revision history.

  Contents:   mapattr()
              mapname()
              do_wild()
              checkdir()
              cmptime()
              invlocal()
              close_outfile()
              _abort()         (Aztec C only)
              version()

  ------------------------------------------------------------------------*/


#include "unzip.h"

/* Globular varibundus */

static int created_dir;      /* used in mapname(), checkdir() */
static int renamed_fullpath; /* ditto */
#define PERMS   0777
#define MKDIR(path,mode) mkdir(path)


#ifndef S_ISCRIPT          /* not having one implies you have none */
#  define S_IARCHIVE 0020  /* not modified since this bit was last set */
#  define S_IREAD    0010  /* can be opened for reading */
#  define S_IWRITE   0004  /* can be opened for writing */
#  define S_IDELETE  0001  /* can be deleted */
#endif /* S_ISCRIPT */

#ifndef S_IRWD
#  define S_IRWD     0015  /* useful combo of Amiga privileges */
#endif /* !S_IRWD */

#ifndef S_IHIDDEN
#  define S_IHIDDEN  0200  /* hidden supported in future AmigaDOS (someday) */
#endif /* !S_HIDDEN */



/**********************/
/* Function mapattr() */
/**********************/

int mapattr(void)      /* Amiga version */
{
    ulg  tmp = crec.external_file_attributes;


    /* Amiga attributes = hsparwed = hidden, script, pure, archive,
     * read, write, execute, delete */

    switch (pInfo->hostnum) {
        case AMIGA_:
            if ((tmp & 1) == (tmp>>18 & 1))
                tmp ^= 0x000F0000;      /* PKAZip compatibility kluge */
            /* turn off archive bit for restored Amiga files */
            pInfo->file_attr = (unsigned)((tmp>>16) & (~S_IARCHIVE));
            break;

        case UNIX_:   /* preserve read, write, execute:  use logical-OR of */
        case VMS_:    /* user, group, and other; if writable, set delete bit */
            tmp >>= 16;
            tmp = (( tmp>>6 | tmp>>3 | tmp) & 07) << 1;
            pInfo->file_attr = (unsigned)(tmp&S_IWRITE? tmp|S_IDELETE : tmp);
            break;

        /* all other platforms:  assume read-only bit in DOS half of attribute
         * word is set correctly ==> will become READ or READ+WRITE+DELETE */
        case FS_FAT_:
        case FS_HPFS_:  /* can add S_IHIDDEN check to MSDOS/OS2/NT eventually */
        case FS_NTFS_:
        case MAC_:
        case ATARI_:
        case TOPS20_:
        default:
            pInfo->file_attr = (unsigned)(tmp&1? S_IREAD : S_IRWD); 
            break;

    } /* end switch (host-OS-created-by) */

    pInfo->file_attr &= 0xff;   /* mask off all but lower eight bits */
    return 0;

} /* end function mapattr() */




/************************/
/*  Function mapname()  */
/************************/

int mapname(renamed)  /* return 0 if no error, 1 if caution (filename trunc), */
    int renamed;      /* 2 if warning (skip file because dir doesn't exist), */
{                     /* 3 if error (skip file), 10 if no memory (skip file) */
    char pathcomp[FILNAMSIZ];   /* path-component buffer */
    char *pp, *cp=NULL;         /* character pointers */
    char *lastsemi = NULL;      /* pointer to last semi-colon in pathcomp */
    int quote = FALSE;          /* flags */
    int error = 0;
    register unsigned workch;   /* hold the character being tested */


/*---------------------------------------------------------------------------
    Initialize various pointers and counters and stuff.
  ---------------------------------------------------------------------------*/

    /* can create path as long as not just freshening, or if user told us */
    create_dirs = (!fflag || renamed);

    created_dir = FALSE;        /* not yet */

    /* user gave full pathname:  don't prepend rootpath */
    renamed_fullpath = (renamed && strchr(filename, ':'));

    if (checkdir((char *)NULL, INIT) == 10)
        return 10;              /* initialize path buffer, unless no memory */

    *pathcomp = '\0';           /* initialize translation buffer */
    pp = pathcomp;              /* point to translation buffer */
    if (jflag)                  /* junking directories */
        cp = (char *)strrchr(filename, '/');
    if (cp == NULL)             /* no '/' or not junking dirs */
        cp = filename;          /* point to internal zipfile-member pathname */
    else
        ++cp;                   /* point to start of last component of path */

/*---------------------------------------------------------------------------
    Begin main loop through characters in filename.
  ---------------------------------------------------------------------------*/

    while ((workch = (uch)*cp++) != 0) {

        if (quote) {                 /* if character quoted, */
            *pp++ = (char)workch;    /*  include it literally */
            quote = FALSE;
        } else
            switch (workch) {
            case '/':             /* can assume -j flag not given */
                *pp = '\0';
                if ((error = checkdir(pathcomp, APPEND_DIR)) > 1)
                    return error;
                pp = pathcomp;    /* reset conversion buffer for next piece */
                lastsemi = NULL;  /* leave directory semi-colons alone */
                break;

            case ';':             /* VMS version (or DEC-20 attrib?) */
                lastsemi = pp;         /* keep for now; remove VMS ";##" */
                *pp++ = (char)workch;  /*  later, if requested */
                break;

            case '\026':          /* control-V quote for special chars */
                quote = TRUE;     /* set flag for next character */
                break;

            default:
                /* allow European characters in filenames: */
                if (isprint(workch) || (128 <= workch && workch <= 255))
                    *pp++ = (char)workch;
            } /* end switch */

    } /* end while loop */

    *pp = '\0';                   /* done with pathcomp:  terminate it */

    /* if not saving them, remove with VMS version numbers (appended ";###") */
    if (!V_flag && lastsemi) {
        pp = lastsemi + 1;
        while (isdigit((uch)(*pp)))
            ++pp;
        if (*pp == '\0')          /* only digits between ';' and end:  nuke */
            *lastsemi = '\0';
    }

/*---------------------------------------------------------------------------
    Report if directory was created (and no file to create:  filename ended
    in '/'), check name to be sure it exists, and combine path and name be-
    fore exiting.
  ---------------------------------------------------------------------------*/

    if (filename[strlen(filename) - 1] == '/') {
        if (checkdir(filename, GETPATH) == 1) {
            fprintf(stderr, "pathname too long:  truncat{ed/ing}\n");
            return 1;  /* GRR:  NEEDS WORK! (do checking only when appending) */
        }
        if (created_dir && QCOND2) {
            fprintf(stdout, "   creating: %s\n", filename);
            return IZ_CREATED_DIR;   /* set dir time (note trailing '/') */
        }
        return 2;   /* dir existed already; don't look for data to extract */
    }

    if (*pathcomp == '\0') {
        fprintf(stderr, "mapname:  conversion of %s failed\n", filename);
        return 3;
    }

    if ((error = checkdir(pathcomp, APPEND_NAME)) == 1) {
        /* GRR:  OK if truncated here:  warn and continue */
        /* (warn in checkdir?) */
    }
    checkdir(filename, GETPATH);

    return error;

} /* end function mapname() */


static int ispattern(char *p)
{
    register char c;
    while (c = *p++)
	if (c == '\\') {
	    if (!*++p)
		return FALSE;
        } else if (c == '?' || c == '*')
            return TRUE;
        else if (c == '[') {
            for (;;) {
                if (!(c = *p++))
                    return FALSE;
                else if (c == '\\') {
                    if (!*++p)
			return FALSE;
                } else if (c == ']')
                    return TRUE;
            }
        }
    return FALSE;
}

/**********************/
/* Function do_wild() */   /* for porting:  dir separator; match(ignore_case) */
/**********************/

char *do_wild(wildspec)
    char *wildspec;         /* only used first time on a given dir */
{
    static DIR *dir = NULL;
    static char *dirname, *wildname, matchname[FILNAMSIZ];
    static int firstcall=TRUE, have_dirname, dirnamelen;
    struct dirent *file;
    BPTR lok = 0;
    /* Even when we're just returning wildspec, we *always* do so in
     * matchname[]--calling routine is allowed to append four characters
     * to the returned string, and wildspec may be a pointer to argv[].
     */
    if (firstcall) {        /* first call:  must initialize everything */
        firstcall = FALSE;
        /* avoid needless readdir() scans: */
        if (!ispattern(wildspec) || (lok = Lock(wildspec, ACCESS_READ))) {
            if (lok) UnLock(lok);
            have_dirname = FALSE;
            strcpy(matchname, wildspec);
            return matchname;
        }

        /* break the wildspec into a directory part and a wildcard filename */
        if ((wildname = strrchr(wildspec, '/')) == NULL
                        && (wildname = strrchr(wildspec, ':')) == NULL) {
            dirname = "";               /* current dir */
            dirnamelen = 1;
            have_dirname = FALSE;
            wildname = wildspec;
        } else {
            ++wildname;     /* point at character after '/' or ':' */
            dirnamelen = wildname - wildspec;
            if ((dirname = (char *)malloc(dirnamelen+1)) == NULL) {
                fprintf(stderr, "warning:  can't allocate wildcard buffers\n");
                strcpy(matchname, wildspec);
                return matchname;   /* but maybe filespec was not a wildcard */
            }
            strncpy(dirname, wildspec, dirnamelen);
            dirname[dirnamelen] = 0;
            have_dirname = TRUE;
        }

        if ((dir = opendir(dirname)) != NULL) {
            while ((file = readdir(dir)) != NULL) {
                if (match(file->d_name, wildname, 1)) {  /* case insensitive */
                    if (have_dirname) {
                        strcpy(matchname, dirname);
                        strcpy(matchname+dirnamelen, file->d_name);
                    } else
                        strcpy(matchname, file->d_name);
                    return matchname;
                }
            }
            /* if we get to here directory is exhausted, so close it */
            closedir(dir);
            dir = NULL;
        }

        /* return the raw wildspec in case that works (e.g., directory not
         * searchable, but filespec was not wild and file is readable) */
        strcpy(matchname, wildspec);
        return matchname;
    }

    /* last time through, might have failed opendir but returned raw wildspec */
    if (dir == NULL) {
        firstcall = TRUE;  /* nothing left to try--reset for new wildspec */
        if (have_dirname)
            free(dirname);
        return (char *)NULL;
    }

    /* If we've gotten this far, we've read and matched at least one entry
     * successfully (in a previous call), so dirname has been copied into
     * matchname already.
     */
    while ((file = readdir(dir)) != NULL)
        if (match(file->d_name, wildname, 0)) {   /* 0 == don't ignore case */
            if (have_dirname) {
                /* strcpy(matchname, dirname); */
                strcpy(matchname+dirnamelen, file->d_name);
            } else
                strcpy(matchname, file->d_name);
            return matchname;
        }

    closedir(dir);     /* have read at least one dir entry; nothing left */
    dir = NULL;
    firstcall = TRUE;  /* reset for new wildspec */
    if (have_dirname)
        free(dirname);
    return (char *)NULL;

} /* end function do_wild() */



/***********************/
/* Function checkdir() */
/***********************/

int checkdir(pathcomp, flag)
    char *pathcomp;
    int flag;
/*
 * returns:  1 - (on APPEND_xxx) truncated path component
 *           2 - path doesn't exist, not allowed to create
 *           3 - path doesn't exist, tried to create and failed; or
 *               path exists and is not a directory, but is supposed to be
 *          10 - can't allocate memory for filename buffers
 */
{
    static int rootlen = 0;   /* length of rootpath */
    static char *rootpath;    /* user's "extract-to" directory */
    static char *buildpath;   /* full path (so far) to extracted file */
    static char *end;         /* pointer to end of buildpath ('\0') */

#   define FN_MASK   7
#   define FUNCTION  (flag & FN_MASK)



/*---------------------------------------------------------------------------
    APPEND_DIR:  append the path component to the path being built and check
    for its existence.  If doesn't exist and we are creating directories, do
    so for this one; else signal success or error as appropriate.
  ---------------------------------------------------------------------------*/

/* GRR:  check path length after each segment:  warn about truncation */

    if (FUNCTION == APPEND_DIR) {
        Trace((stderr, "appending dir segment [%s]\n", pathcomp));
        while ((*end = *pathcomp++))
            ++end;
        if (stat(buildpath, &statbuf)) {   /* path doesn't exist */
            if (!create_dirs) {   /* told not to create (freshening) */
                free(buildpath);
                return 2;         /* path doesn't exist:  nothing to do */
            }
            if (MKDIR(buildpath, 0777) == -1) {   /* create the directory */
                fprintf(stderr, 
                "checkdir:  can't create %s\n           unable to process %s.\n"
                  , buildpath, filename);
                fflush(stderr);
                free(buildpath);
                return 3;      /* path didn't exist, tried to create, failed */
            }
            created_dir = TRUE;
        } else if (!S_ISDIR(statbuf.st_mode)) {
            fprintf(stderr, "checkdir:  %s exists but is not a directory\n\
           unable to process %s.\n", buildpath, filename);
            fflush(stderr);
            free(buildpath);
            return 3;          /* path existed but wasn't dir */
        }
        *end++ = '/';
        *end = '\0';
        Trace((stderr, "buildpath now = [%s]\n", buildpath));
        return 0;

    } /* end if (FUNCTION == APPEND_DIR) */

/*---------------------------------------------------------------------------
    GETPATH:  copy full path to the string pointed at by pathcomp, and free
    buildpath.
  ---------------------------------------------------------------------------*/

    if (FUNCTION == GETPATH) {
        strcpy(pathcomp, buildpath);  /* DO ERROR CHECKING:  TOO LONG? */
        Trace((stderr, "getting and freeing path [%s]\n", pathcomp));
        free(buildpath);
        buildpath = end = NULL;
        return 0;
    }

/*---------------------------------------------------------------------------
    APPEND_NAME:  assume the path component is the filename; append it and
    return without checking for existence.
  ---------------------------------------------------------------------------*/

    if (FUNCTION == APPEND_NAME) {                /* DO ERROR CHECKING */
        Trace((stderr, "appending filename [%s]\n", pathcomp));
        while ((*end = *pathcomp++))
            ++end;
        Trace((stderr, "buildpath now = [%s]\n", buildpath));
        return 0;  /* could check for existence here, prompt for new name... */
    }

/*---------------------------------------------------------------------------
    INIT:  allocate and initialize buffer space for the file currently being
    extracted.  If file was renamed with an absolute path, don't prepend the
    extract-to path.
  ---------------------------------------------------------------------------*/

    if (FUNCTION == INIT) {
        Trace((stderr, "initializing buildpath to "));
        if ((buildpath = (char *)malloc(strlen(filename)+rootlen+1)) == NULL)
            return 10;
        if ((rootlen > 0) && !renamed_fullpath) {
            strcpy(buildpath, rootpath);
            end = buildpath + rootlen;
        } else {
            *buildpath = '\0';
            end = buildpath;
        }
        Trace((stderr, "[%s]\n", buildpath));
        return 0;
    }

/*---------------------------------------------------------------------------
    ROOT:  if appropriate, store the path in rootpath and create it if neces-
    sary; else assume it's a zipfile member and return.  This path segment
    gets used in extracting all members from every zipfile specified on the
    command line.
  ---------------------------------------------------------------------------*/

    if (FUNCTION == ROOT) {
        Trace((stderr, "initializing root path to [%s]\n", pathcomp));
        if (pathcomp == NULL) {
            rootlen = 0;
            return 0;
        }
        if ((rootlen = strlen(pathcomp)) > 0) {
            int had_trailing_pathsep=FALSE;

            if (pathcomp[rootlen-1] == '/') {
                pathcomp[--rootlen] = '\0';
                had_trailing_pathsep = TRUE;
            }
            if (stat(pathcomp, &statbuf) || !S_ISDIR(statbuf.st_mode)) {
                /* path does not exist */
                if (!create_dirs || !had_trailing_pathsep) {
                    rootlen = 0;
                    return 2;   /* treat as stored file */
                }
/* GRR:  scan for wildcard characters?  OS-dependent...  if find any, return 2:
 * treat as stored file(s) */
                /* create the directory (could add loop here to scan pathcomp
                 * and create more than one level, but why really necessary?) */
                if (MKDIR(pathcomp, 0777) == -1) {
                    fprintf(stderr,
                      "checkdir:  can't create extraction directory: %s\n",
                      pathcomp);
                    fflush(stderr);
                    rootlen = 0;   /* path didn't exist, tried to create, and */
                    return 3;  /* failed:  file exists, or 2+ levels required */
                }
            }
            if ((rootpath = (char *)malloc(rootlen+2)) == NULL) {
                rootlen = 0;
                return 10;
            }
            strcpy(rootpath, pathcomp);
            if (rootpath[rootlen - 1] != ':')
                rootpath[rootlen++] = '/';
            rootpath[rootlen] = '\0';
        }
        Trace((stderr, "rootpath now = [%s]\n", rootpath));
        return 0;
    }

/*---------------------------------------------------------------------------
    END:  free rootpath, immediately prior to program exit.
  ---------------------------------------------------------------------------*/

    if (FUNCTION == END) {
        Trace((stderr, "freeing rootpath\n"));
        if (rootlen > 0)
            free(rootpath);
        return 0;
    }

    return 99;  /* should never reach */

} /* end function checkdir() */


/**********************/
/* Function cmptime() */
/**********************/

/* cmptime() clone pinched from from Zip1.9h,
 * by Mark Adler, Jean-loup Gailly, et al., circa 1991.  
 * Incorporated into UnZip 5.1d by John Bush
 */

int cmptime(p, q)
struct tm *p, *q;       /* times to compare */
/* Return negative if time p is before time q, positive if after, and
   zero if the same */
{
  int r;                /* temporary variable */

  if (p == NULL)
    return -1;
  else if ((r = p->tm_year - q->tm_year) != 0)
    return r;
  else if ((r = p->tm_mon - q->tm_mon) != 0)
    return r;
  else if ((r = p->tm_mday - q->tm_mday) != 0)
    return r;
  else if ((r = p->tm_hour - q->tm_hour) != 0)
    return r;
  else if ((r = p->tm_min - q->tm_min) != 0)
    return r;
  else
    return p->tm_sec - q->tm_sec;
}


/***********************/
/* Function invlocal() */
/***********************/

/* mktime() clone pinched from from Zip1.9h,
 * by Mark Adler and Jean-loup Gailly, et.al, circa 1991.  
 * Incorporated into UnZip 5.1d by John Bush
 */
time_t invlocal(t)
struct tm *t;           /* time to convert */
/* Find inverse of localtime() using bisection.  This routine assumes that
   time_t is an integer type, either signed or unsigned.  The expectation
   is that sometime before the year 2038, time_t will be made a 64-bit
   integer, and this routine will still work. */
{
  time_t i;             /* midpoint of current root range */
  time_t l;             /* lower end of root range */
  time_t u;             /* upper end of root range */

  /* Bracket the root [0,largest time_t].  Note: if time_t is a 32-bit signed
     integer, then the upper bound is GMT 1/19/2038 03:14:07, after which all
     the Unix systems in the world come to a grinding halt.  Either that, or
     all those systems will suddenly find themselves transported to December
     of 1901 ... */
  l = 0;
  u = 1;
  while (u < (u << 1))
    u = (u << 1) + 1;

  /* Find the root */
  while (u - l > 1)
  {
    i = l + ((u - l) >> 1);
    if (cmptime(localtime(&i), t) <= 0)
      l = i;
    else
      u = i;
  }
  return l;
}



/**************************************/
/* Function close_outfile() */
/**************************************/
/* this part differs slightly with Zip */
/*-------------------------------------*/

void close_outfile(void)
{
    struct tm t;                /* good ole time structure */
    time_t u[2];                /* mean ole time stamp */
    ulg dd,dt;                  /* DOS format time stamps */
    LONG FileDate();
    time_t invlocal();

    if (cflag)                  /* can't set time on stdout */
        return;

  /* close the file *before* setting its time under AmigaDos */

    fclose(outfile);

  /* assign date and time to local variables */

    dd = lrec.last_mod_file_date;
    dt = lrec.last_mod_file_time;

  /* Convert DOS time to time_t format in (time_t)u */

    t.tm_sec =   (int) (dt <<  1) & 0x3e;
    t.tm_min =   (int) (dt >>  5) & 0x3f;
    t.tm_hour =  (int) (dt >> 11) & 0x1f;

    t.tm_mday =  (int) (dd        & 0x1f);
    t.tm_mon =  ((int) (dd >>  5) & 0xf ) - 1;
    t.tm_year = ((int) (dd >>  9) & 0x7f) + 80;

  /* invlocal() is equivalent to mktime() */

    u[0] = u[1] = invlocal(&t); 

#ifdef DEBUG
    fprintf (stderr,"\nclose_outfile(): u=%s\n",ctime(&u[0]));
#endif

    if (!FileDate(filename, u))
        fprintf(stderr, "warning:  can't set the time for %s\n", filename);

  /* set file perms after closing (not done at creation)--see mapattr() */

    chmod(filename, pInfo->file_attr);

} /* end function close_outfile() */


/********************************************************************/
/* Load filedate as a separate external file; it's used by Zip, too.*/
/*                                                                  */
#include "amiga/filedate.c"                                      /* */
/*                                                                  */
/********************************************************************/

/**************** for Aztec, do linewise with stat.c ****************/

#ifdef AZTEC_C
#  include "amiga/stat.c"
/* this is the exact same stat.c used for Aztec by Zip */

#  include <stdio.h>
#  include "crypt.h"

void _abort(void)               /* called when ^C is pressed */
{
    echon();
    close_leftover_open_dirs();
    fflush(stdout);
    fputs("\n^C\n", stderr);
    exit(1);
}
#endif /* AZTEC_C */


#ifndef SFX

/************************/
/*  Function version()  */
/************************/


/* NOTE:  the following include depends upon the environment 
 *        variable $Workbench to be set correctly.  (Set by
 *        default, by kickstart during startup)
 */
int WBversion = (int)
#include "ENV:Workbench"
;

void version()
{

/* Define buffers. */

   char buf1[16];  /* compiler name */
   char buf2[16];  /* revstamp */
   char buf3[16];  /* OS */
   char buf4[16];  /* Date */
/*   char buf5[16];  /* Time */

/* format "with" name strings */

#ifdef AMIGA
# ifdef __SASC
   strcpy(buf1,"SAS/C ");
# else
#  ifdef LATTICE
    strcpy(buf1,"Lattice C ");
#  else
#   ifdef AZTEC_C
     strcpy(buf1,"Manx Aztec C ");
#   else
     strcpy(buf1,"UNKNOWN ");
#   endif
#  endif
# endif
/* "under" */
  sprintf(buf3,"AmigaDOS v%d",WBversion);
#else
  strcpy(buf1,"Unknown compiler ");
  strcpy(buf3,"Unknown OS");
#endif

/* Define revision, date, and time strings.  
 * NOTE:  Do not calculate run time, be sure to use time compiled.
 * Pass these strings via your makefile if undefined.
 */

#if defined(__VERSION__) && defined(__REVISION__)
  sprintf(buf2,"version %d.%d",__VERSION__,__REVISION__);
#else
# ifdef __VERSION__
  sprintf(buf2,"version %d",__VERSION__);
# else
  sprintf(buf2,"unknown version");
# endif
#endif

#ifdef __DATE__
  sprintf(buf4," on %s",__DATE__);
#else
  strcpy(buf4," unknown date");
#endif

/******
#ifdef __TIME__
  sprintf(buf5," at %s",__TIME__);
#else
  strcpy(buf5," unknown time");
#endif
******/

/* Print strings using "CompiledWith" mask defined in unzip.c (used by all).
 *  ("Compiled with %s%s under %s%s%s%s.")
 */

   printf(LoadFarString(CompiledWith),
     buf1,
     buf2, 
     buf3,
     buf4,
     /* buf5, */ "",
     "" );  /* buf6 not used */

} /* end function version() */

#endif /* !SFX */
