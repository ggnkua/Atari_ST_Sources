/*---------------------------------------------------------------------------

  unix.c

  Unix-specific routines for use with Info-ZIP's UnZip 5.1 and later.

  Contains:  readdir()
             do_wild()           <-- generic enough to put in file_io.c?
             mapattr()
             mapname()
             checkdir()
             mkdir()
             close_outfile()
             version()

  ---------------------------------------------------------------------------*/


#include "unzip.h"

/* SCO Unix, AIX, DNIX, TI SysV, Coherent 4.x, ... */
#if defined(__convexc__) || defined(SYSV) || defined(CRAY) || defined(BSD4_4)
#  define DIRENT
#endif
#if defined(_AIX)
#  define DIRENT
#endif
#ifdef COHERENT
#  if defined(_I386) || (defined(__COHERENT__) && (__COHERENT__ >= 0x420))
#    define DIRENT
#  endif
#endif

/* GRR:  may need to uncomment one or both of these for the relevant systems */

#if 0
#if defined(_POSIX_VERSION)
#  define DIRENT
#endif
#endif

#if 0
#if defined(M_XENIX)
#  define SYSNDIR
#endif
#endif

#ifdef DIRENT
#  include <dirent.h>
#else
#  ifdef SYSV
#    ifdef SYSNDIR
#      include <sys/ndir.h>
#    else
#      include <ndir.h>
#    endif
#  else /* !SYSV */
#    ifndef NO_SYSDIR
#      include <sys/dir.h>
#    endif
#  endif /* ?SYSV */
#  ifndef dirent
#    define dirent direct
#  endif
#endif /* ?DIRENT */

static int created_dir;        /* used in mapname(), checkdir() */
static int renamed_fullpath;   /* ditto */


#ifndef SFX
#ifdef NO_DIR                    /* for AT&T 3B1 */

#define opendir(path) fopen(path,"r")
#define closedir(dir) fclose(dir)
typedef FILE DIR;

/*
 *  Apparently originally by Rich Salz.
 *  Cleaned up and modified by James W. Birdsall.
 */
struct dirent *readdir(dirp)
    DIR *dirp;
{
    static struct dirent entry;

    if (dirp == NULL) 
        return NULL;

    for (;;)
        if (fread(&entry, sizeof (struct dirent), 1, dirp) == 0) 
            return (struct dirent *)NULL;
        else if (entry.d_ino) 
            return &entry;

} /* end function readdir() */

#endif /* NO_DIR */


/**********************/
/* Function do_wild() */   /* for porting:  dir separator; match(ignore_case) */
/**********************/

char *do_wild(wildspec)
    char *wildspec;         /* only used first time on a given dir */
{
    static DIR *dir = (DIR *)NULL;
    static char *dirname, *wildname, matchname[FILNAMSIZ];
    static int firstcall=TRUE, have_dirname, dirnamelen;
    struct dirent *file;


    /* Even when we're just returning wildspec, we *always* do so in
     * matchname[]--calling routine is allowed to append four characters
     * to the returned string, and wildspec may be a pointer to argv[].
     */
    if (firstcall) {        /* first call:  must initialize everything */
        firstcall = FALSE;

        /* break the wildspec into a directory part and a wildcard filename */
        if ((wildname = strrchr(wildspec, '/')) == (char *)NULL) {
            dirname = ".";
            dirnamelen = 1;
            have_dirname = FALSE;
            wildname = wildspec;
        } else {
            ++wildname;     /* point at character after '/' */
            dirnamelen = wildname - wildspec;
            if ((dirname = (char *)malloc(dirnamelen+1)) == (char *)NULL) {
                fprintf(stderr, "warning:  can't allocate wildcard buffers\n");
                strcpy(matchname, wildspec);
                return matchname;   /* but maybe filespec was not a wildcard */
            }
            strncpy(dirname, wildspec, dirnamelen);
            dirname[dirnamelen] = '\0';   /* terminate for strcpy below */
            have_dirname = TRUE;
        }

        if ((dir = opendir(dirname)) != (DIR *)NULL) {
            while ((file = readdir(dir)) != (struct dirent *)NULL) {
                if (file->d_name[0] == '.' && wildname[0] != '.')
                    continue;  /* Unix:  '*' and '?' do not match leading dot */
                if (match(file->d_name, wildname, 0)) {  /* 0 == case sens. */
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
            dir = (DIR *)NULL;
        }

        /* return the raw wildspec in case that works (e.g., directory not
         * searchable, but filespec was not wild and file is readable) */
        strcpy(matchname, wildspec);
        return matchname;
    }

    /* last time through, might have failed opendir but returned raw wildspec */
    if (dir == (DIR *)NULL) {
        firstcall = TRUE;  /* nothing left to try--reset for new wildspec */
        if (have_dirname)
            free(dirname);
        return (char *)NULL;
    }

    /* If we've gotten this far, we've read and matched at least one entry
     * successfully (in a previous call), so dirname has been copied into
     * matchname already.
     */
    while ((file = readdir(dir)) != (struct dirent *)NULL)
        if (match(file->d_name, wildname, 0)) {   /* 0 == don't ignore case */
            if (have_dirname) {
                /* strcpy(matchname, dirname); */
                strcpy(matchname+dirnamelen, file->d_name);
            } else
                strcpy(matchname, file->d_name);
            return matchname;
        }

    closedir(dir);     /* have read at least one dir entry; nothing left */
    dir = (DIR *)NULL;
    firstcall = TRUE;  /* reset for new wildspec */
    if (have_dirname)
        free(dirname);
    return (char *)NULL;

} /* end function do_wild() */

#endif /* !SFX */





/**********************/
/* Function mapattr() */
/**********************/

int mapattr()
{
    ulg tmp = crec.external_file_attributes;

    switch (pInfo->hostnum) {
        case UNIX_:
        case VMS_:
            pInfo->file_attr = (unsigned)(tmp >> 16);
            return 0;
        case AMIGA_:
            tmp = (unsigned)(tmp>>17 & 7);   /* Amiga RWE bits */
            pInfo->file_attr = (unsigned)(tmp<<6 | tmp<<3 | tmp);
            break;
        /* all remaining cases:  expand MSDOS read-only bit into write perms */
        case FS_FAT_:
        case FS_HPFS_:
        case FS_NTFS_:
        case MAC_:
        case ATARI_:             /* (used to set = 0666) */
        case TOPS20_:
        default:
            tmp = !(tmp & 1) << 1;   /* read-only bit --> write perms bits */
            pInfo->file_attr = (unsigned)(0444 | tmp<<6 | tmp<<3 | tmp);
            break;
    } /* end switch (host-OS-created-by) */

    /* for originating systems with no concept of "group," "other," "system": */
    umask( (int)(tmp=umask(0)) );    /* apply mask to expanded r/w(/x) perms */
    pInfo->file_attr &= ~tmp;

    return 0;

} /* end function mapattr() */





/************************/
/*  Function mapname()  */
/************************/

int mapname(renamed)  /* return 0 if no error, 1 if caution (filename trunc), */
    int renamed;      /* 2 if warning (skip file because dir doesn't exist), */
{                     /* 3 if error (skip file), 10 if no memory (skip file) */
    char pathcomp[FILNAMSIZ];    /* path-component buffer */
    char *pp, *cp=(char *)NULL;  /* character pointers */
    char *lastsemi=(char *)NULL; /* pointer to last semi-colon in pathcomp */
    int quote = FALSE;           /* flags */
    int error = 0;
    register unsigned workch;    /* hold the character being tested */


/*---------------------------------------------------------------------------
    Initialize various pointers and counters and stuff.
  ---------------------------------------------------------------------------*/

    if (pInfo->vollabel)
        return IZ_VOL_LABEL;    /* can't set disk volume labels in Unix */

    /* can create path as long as not just freshening, or if user told us */
    create_dirs = (!fflag || renamed);

    created_dir = FALSE;        /* not yet */

    /* user gave full pathname:  don't prepend rootpath */
    renamed_fullpath = (renamed && (*filename == '/'));

    if (checkdir((char *)NULL, INIT) == 10)
        return 10;              /* initialize path buffer, unless no memory */

    *pathcomp = '\0';           /* initialize translation buffer */
    pp = pathcomp;              /* point to translation buffer */
    if (jflag)                  /* junking directories */
        cp = (char *)strrchr(filename, '/');
    if (cp == (char *)NULL)     /* no '/' or not junking dirs */
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
                lastsemi = (char *)NULL; /* leave directory semi-colons alone */
                break;

            case ';':             /* VMS version (or DEC-20 attrib?) */
                lastsemi = pp;
                *pp++ = ';';      /* keep for now; remove VMS ";##" */
                break;            /*  later, if requested */

            case '\026':          /* control-V quote for special chars */
                quote = TRUE;     /* set flag for next character */
                break;

#ifdef MTS
            case ' ':             /* change spaces to underscore under */
                *pp++ = '_';      /*  MTS; leave as spaces under Unix */
                break;
#endif

            default:
                /* allow European characters in filenames: */
                if (isprint(workch) || (128 <= workch && workch <= 254))
                    *pp++ = (char)workch;
            } /* end switch */

    } /* end while loop */

    *pp = '\0';                   /* done with pathcomp:  terminate it */

    /* if not saving them, remove VMS version numbers (appended ";###") */
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
        checkdir(filename, GETPATH);
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

    checkdir(pathcomp, APPEND_NAME);   /* returns 1 if truncated:  care? */
    checkdir(filename, GETPATH);

    return error;

} /* end function mapname() */




#if 0  /*========== NOTES ==========*/

  extract-to dir:      a:path/
  buildpath:           path1/path2/ ...   (NULL-terminated)
  pathcomp:                filename 

  mapname():
    loop over chars in zipfile member name
      checkdir(path component, COMPONENT | CREATEDIR) --> map as required?
        (d:/tmp/unzip/)                    (disk:[tmp.unzip.)
        (d:/tmp/unzip/jj/)                 (disk:[tmp.unzip.jj.)
        (d:/tmp/unzip/jj/temp/)            (disk:[tmp.unzip.jj.temp.)
    finally add filename itself and check for existence? (could use with rename)
        (d:/tmp/unzip/jj/temp/msg.outdir)  (disk:[tmp.unzip.jj.temp]msg.outdir)
    checkdir(name, COPYFREE)     -->  copy path to name and free space

#endif /* 0 */




/***********************/
/* Function checkdir() */
/***********************/

int checkdir(pathcomp, flag)
    char *pathcomp;
    int flag;
/*
 * returns:  1 - (on APPEND_NAME) truncated filename
 *           2 - path doesn't exist, not allowed to create
 *           3 - path doesn't exist, tried to create and failed; or
 *               path exists and is not a directory, but is supposed to be
 *           4 - path is too long
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

    if (FUNCTION == APPEND_DIR) {
        int too_long = FALSE;
#ifdef SHORT_NAMES
        char *old_end = end;
#endif

        Trace((stderr, "appending dir segment [%s]\n", pathcomp));
        while ((*end = *pathcomp++) != '\0')
            ++end;
#ifdef SHORT_NAMES   /* path components restricted to 14 chars, typically */
        if ((end-old_end) > FILENAME_MAX)  /* GRR:  proper constant? */
            *(end = old_end + FILENAME_MAX) = '\0';
#endif

        /* GRR:  could do better check, see if overrunning buffer as we go:
         * check end-buildpath after each append, set warning variable if
         * within 20 of FILNAMSIZ; then if var set, do careful check when
         * appending.  Clear variable when begin new path. */

        if ((end-buildpath) > FILNAMSIZ-3)  /* need '/', one-char name, '\0' */
            too_long = TRUE;                /* check if extracting directory? */
        if (stat(buildpath, &statbuf)) {    /* path doesn't exist */
            if (!create_dirs) {   /* told not to create (freshening) */
                free(buildpath);
                return 2;         /* path doesn't exist:  nothing to do */
            }
            if (too_long) {
                fprintf(stderr, "checkdir error:  path too long: %s\n",
                  buildpath);
                fflush(stderr);
                free(buildpath);
                return 4;         /* no room for filenames:  fatal */
            }
            if (mkdir(buildpath, 0777) == -1) {   /* create the directory */
                fprintf(stderr, "checkdir error:  can't create %s\n\
                 unable to process %s.\n", buildpath, filename);
                fflush(stderr);
                free(buildpath);
                return 3;      /* path didn't exist, tried to create, failed */
            }
            created_dir = TRUE;
        } else if (!S_ISDIR(statbuf.st_mode)) {
            fprintf(stderr, "checkdir error:  %s exists but is not directory\n\
                 unable to process %s.\n", buildpath, filename);
            fflush(stderr);
            free(buildpath);
            return 3;          /* path existed but wasn't dir */
        }
        if (too_long) {
            fprintf(stderr, "checkdir error:  path too long: %s\n", buildpath);
            fflush(stderr);
            free(buildpath);
            return 4;         /* no room for filenames:  fatal */
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
        strcpy(pathcomp, buildpath);
        Trace((stderr, "getting and freeing path [%s]\n", pathcomp));
        free(buildpath);
        buildpath = end = (char *)NULL;
        return 0;
    }

/*---------------------------------------------------------------------------
    APPEND_NAME:  assume the path component is the filename; append it and
    return without checking for existence.
  ---------------------------------------------------------------------------*/

    if (FUNCTION == APPEND_NAME) {
#ifdef SHORT_NAMES
        char *old_end = end;
#endif

        Trace((stderr, "appending filename [%s]\n", pathcomp));
        while ((*end = *pathcomp++) != '\0') {
            ++end;
#ifdef SHORT_NAMES  /* truncate name at 14 characters, typically */
            if ((end-old_end) > FILENAME_MAX)      /* GRR:  proper constant? */
                *(end = old_end + FILENAME_MAX) = '\0';
#endif
            if ((end-buildpath) >= FILNAMSIZ) {
                *--end = '\0';
                fprintf(stderr, "checkdir warning:  path too long; truncating\n\
checkdir warning:  path too long; truncating\n\
                   %s\n                -> %s\n", filename, buildpath);
                fflush(stderr);
                return 1;   /* filename truncated */
            }
        }
        Trace((stderr, "buildpath now = [%s]\n", buildpath));
        return 0;  /* could check for existence here, prompt for new name... */
    }

/*---------------------------------------------------------------------------
    INIT:  allocate and initialize buffer space for the file currently being
    extracted.  If file was renamed with an absolute path, don't prepend the
    extract-to path.
  ---------------------------------------------------------------------------*/

/* GRR:  for VMS and TOPS-20, add up to 13 to strlen */

    if (FUNCTION == INIT) {
        Trace((stderr, "initializing buildpath to "));
        if ((buildpath = (char *)malloc(strlen(filename)+rootlen+1)) ==
            (char *)NULL)
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
        if (pathcomp == (char *)NULL) {
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
                if (!create_dirs                     /* || isshexp(pathcomp) */
#ifdef OLD_EXDIR
                                 || !had_trailing_pathsep
#endif
                                                         ) {
                    rootlen = 0;
                    return 2;   /* skip (or treat as stored file) */
                }
                /* create the directory (could add loop here to scan pathcomp
                 * and create more than one level, but why really necessary?) */
                if (mkdir(pathcomp, 0777) == -1) {
                    fprintf(stderr,
                      "checkdir:  can't create extraction directory: %s\n",
                      pathcomp);
                    fflush(stderr);
                    rootlen = 0;   /* path didn't exist, tried to create, and */
                    return 3;  /* failed:  file exists, or 2+ levels required */
                }
            }
            if ((rootpath = (char *)malloc(rootlen+2)) == (char *)NULL) {
                rootlen = 0;
                return 10;
            }
            strcpy(rootpath, pathcomp);
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





#ifdef NO_MKDIR

/********************/
/* Function mkdir() */
/********************/

int mkdir(path, mode)
    char *path;
    int mode;   /* ignored */
/*
 * returns:   0 - successful
 *           -1 - failed (errno not set, however)
 */
{
    char command[FILNAMSIZ+40]; /* buffer for system() call */

    /* GRR 930416:  added single quotes around path to avoid bug with
     * creating directories with ampersands in name; not yet tested */
    sprintf(command, "IFS=\" \t\n\" /bin/mkdir '%s' 2>/dev/null", path);
    if (system(command))
        return -1;
    return 0;
}

#endif /* NO_MKDIR */





#ifndef MTS

/****************************/
/* Function close_outfile() */
/****************************/

void close_outfile()
{
    static short yday[]={0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334};
    time_t m_time;
    int yr, mo, dy, hh, mm, ss, leap, days;
    struct utimbuf tp;
#   define YRBASE  1970
#ifndef BSD4_4
#ifdef BSD
    static struct timeb tbp;
#else /* !BSD */
    extern long timezone;
#endif /* ?BSD */
#endif /* !BSD4_4 */


/*---------------------------------------------------------------------------
    If symbolic links are supported, allocate a storage area, put the uncom-
    pressed "data" in it, and create the link.  Since we know it's a symbolic
    link to start with, we shouldn't have to worry about overflowing unsigned
    ints with unsigned longs.
  ---------------------------------------------------------------------------*/

#ifdef SYMLINKS
    if (symlnk) {
        unsigned ucsize = (unsigned)lrec.ucsize;
        char *linktarget = (char *)malloc((unsigned)lrec.ucsize+1);

        fclose(outfile);                    /* close "data" file... */
        outfile = fopen(filename, FOPR);    /* ...and reopen for reading */
        if (!linktarget || (fread(linktarget, 1, ucsize, outfile) != ucsize)) {
            fprintf(stderr, "\nwarning:  symbolic link (%s) failed\n",
              filename);
            if (linktarget)
                free(linktarget);
            fclose(outfile);
            return;
        }
        fclose(outfile);                    /* close "data" file for good... */
        unlink(filename);                   /* ...and delete it */
        linktarget[ucsize] = '\0';
        fprintf(stdout, "-> %s ", linktarget);
        if (symlink(linktarget, filename))  /* create the real link */
            perror("symlink error");
        free(linktarget);
        return;                             /* can't set time on symlinks */
    }
#endif /* SYMLINKS */

    fclose(outfile);

/*---------------------------------------------------------------------------
    Change the file permissions from default ones to those stored in the
    zipfile.
  ---------------------------------------------------------------------------*/

#ifndef NO_CHMOD
    if (chmod(filename, 0xffff & pInfo->file_attr))
            perror("chmod (file attributes) error");
#endif

/*---------------------------------------------------------------------------
    Convert from MSDOS-format local time and date to Unix-format 32-bit GMT
    time:  adjust base year from 1980 to 1970, do usual conversions from
    yy/mm/dd hh:mm:ss to elapsed seconds, and account for timezone and day-
    light savings time differences.
  ---------------------------------------------------------------------------*/

    yr = ((lrec.last_mod_file_date >> 9) & 0x7f) + (1980 - YRBASE);
    mo = ((lrec.last_mod_file_date >> 5) & 0x0f) - 1;
    dy = (lrec.last_mod_file_date & 0x1f) - 1;
    hh = (lrec.last_mod_file_time >> 11) & 0x1f;
    mm = (lrec.last_mod_file_time >> 5) & 0x3f;
    ss = (lrec.last_mod_file_time & 0x1f) * 2;

    /* leap = # of leap yrs from YRBASE up to but not including current year */
    leap = ((yr + YRBASE - 1) / 4);   /* leap year base factor */

    /* how many days from YRBASE to this year? (& add expired days this year) */
    days = (yr * 365) + (leap - 492) + yday[mo];

    /* if year is a leap year and month is after February, add another day */
    if ((mo > 1) && ((yr+YRBASE)%4 == 0) && ((yr+YRBASE) != 2100))
        ++days;   /* OK through 2199 */

    /* convert date & time to seconds relative to 00:00:00, 01/01/YRBASE */
    m_time = ((days + dy) * 86400) + (hh * 3600) + (mm * 60) + ss;

    /* adjust for local timezone */
#ifdef BSD
#ifdef BSD4_4
    m_time -= localtime(&m_time)->tm_gmtoff;  /* seconds EAST of GMT:  subtr. */
#else
    ftime(&tbp);                    /* get `timezone' */
    m_time += tbp.timezone * 60L;   /* seconds WEST of GMT:  add */
#endif /* ?BSD4_4 */
#else /* !BSD */
    tzset();              /* get `timezone' */
    m_time += timezone;   /* seconds WEST of GMT:  add */
#endif /* ?BSD */

    /* adjust for daylight savings time (or local equivalent) */
#ifndef BSD4_4  /* (DST already added to tm_gmtoff, so skip tm_isdst) */
    if (localtime(&m_time)->tm_isdst)
        m_time -= 60L * 60L;   /* adjust for daylight savings time */
#endif

    /* set the file's access and modification times */
    tp.actime = tp.modtime = m_time;
    if (utime(filename, &tp)) {
#ifdef AOS_VS
        fprintf(stderr, "... can't set time for %s", filename);
#else
        fprintf(stderr, "warning:  can't set the time for %s\n", filename);
#endif
        FFLUSH(stderr);
    }

} /* end function close_outfile() */

#endif /* !MTS */




#ifndef SFX

/************************/
/*  Function version()  */
/************************/

void version()
{
#if defined(CRAY) || defined(NetBSD)
    char buf1[40];
#if defined(CRAY)
    char buf2[40];
#endif
#endif

    printf(LoadFarString(CompiledWith),

#ifdef __GNUC__
      "gcc ", __VERSION__,
#else
#  if defined(CRAY) && defined(_RELEASE)
      "cc ", (sprintf(buf1, "version %d", _RELEASE), buf1),
#  else
#  ifdef __VERSION__
      "cc ", __VERSION__,
#  else
      "cc", "",
#  endif
#  endif
#endif

      "Unix",

#if defined(sgi) || defined(__sgi)
      " (Silicon Graphics IRIX)",
#else
#ifdef sun
#  ifdef sparc
#    ifdef __SVR4
      " (Sun Sparc/Solaris)",
#    else /* may or may not be SunOS */
      " (Sun Sparc)",
#    endif
#  else
#  if defined(sun386) || defined(i386)
      " (Sun 386i)",
#  else
#  if defined(mc68020) || defined(__mc68020__)
      " (Sun 3)",
#  else /* mc68010 or mc68000:  Sun 2 or earlier */
      " (Sun 2)",
#  endif
#  endif
#  endif
#else
#ifdef __hpux
      " (HP/UX)",
#else
#ifdef __osf__
      " (DEC OSF/1)",
#else
#ifdef _AIX
      " (IBM AIX)",
#else
#ifdef aiws
      " (IBM RT/AIX)",
#else
#if defined(CRAY) || defined(cray)
#  ifdef _UNICOS
      (sprintf(buf2, " (Cray UNICOS release %d)", _UNICOS), buf2),
#  else
      " (Cray UNICOS)",
#  endif
#else
#if defined(uts) || defined(UTS)
      " (Amdahl UTS)",
#else
#ifdef NeXT
#  ifdef mc68000
      " (NeXTStep/black)",
#  else
      " (NeXTStep for Intel)",
#  endif
#else              /* the next dozen or so are somewhat order-dependent */
#ifdef LINUX
      " (Linux)",
#else
#ifdef MINIX
      " (Minix)",
#else
#ifdef M_UNIX
      " (SCO Unix)",
#else
#ifdef M_XENIX
      " (SCO Xenix)",
#else
#ifdef __NetBSD__
#  ifdef NetBSD0_8
      (sprintf(buf1, " (NetBSD 0.8%c)", (char)(NetBSD0_8 - 1 + 'A')), buf1),
#  else
#  ifdef NetBSD0_9
      (sprintf(buf1, " (NetBSD 0.9%c)", (char)(NetBSD0_9 - 1 + 'A')), buf1),
#  else
#  ifdef NetBSD1_0
      (sprintf(buf1, " (NetBSD 1.0%c)", (char)(NetBSD1_0 - 1 + 'A')), buf1),
#  else
      (BSD4_4 == 0.5)? " (NetBSD before 0.9)" : " (NetBSD 1.1 or later)",
#  endif
#  endif
#  endif
#else
#ifdef __FreeBSD__
      (BSD4_4 == 0.5)? " (FreeBSD 1.x)" : " (FreeBSD 2.0 or later)",
#else
#ifdef __bsdi__
      (BSD4_4 == 0.5)? " (BSD/386 1.0)" : " (BSD/386 1.1 or later)",
#else
#ifdef __386BSD__
      (BSD4_4 == 1)? " (386BSD, post-4.4 release)" : " (386BSD)",
#else
#if defined(i486) || defined(__i486) || defined(__i486__)
      " (Intel 486)",
#else
#if defined(i386) || defined(__i386) || defined(__i386__)
      " (Intel 386)",
#else
#ifdef pyr
      " (Pyramid)",
#else
#ifdef ultrix
#  ifdef mips
      " (DEC/MIPS)",
#  else
#  ifdef vax
      " (DEC/VAX)",
#  else /* __alpha? */
      " (DEC/Alpha)",
#  endif
#  endif
#else
#ifdef gould
      " (Gould)",
#else
#ifdef MTS
      " (MTS)",
#else
#ifdef __convexc__
      " (Convex)",
#else
      "",
#endif /* Convex */
#endif /* MTS */
#endif /* Gould */
#endif /* DEC */
#endif /* Pyramid */
#endif /* 386 */
#endif /* 486 */
#endif /* 386BSD */
#endif /* BSDI BSD/386 */
#endif /* NetBSD */
#endif /* FreeBSD */
#endif /* SCO Xenix */
#endif /* SCO Unix */
#endif /* Minix */
#endif /* Linux */
#endif /* NeXT */
#endif /* Amdahl */
#endif /* Cray */
#endif /* RT/AIX */
#endif /* AIX */
#endif /* OSF/1 */
#endif /* HP/UX */
#endif /* Sun */
#endif /* SGI */

#ifdef __DATE__
      " on ", __DATE__
#else
      "", ""
#endif
      );

} /* end function version() */

#endif /* !SFX */
