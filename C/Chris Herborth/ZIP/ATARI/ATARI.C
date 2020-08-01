/*---------------------------------------------------------------------------

  atari.c

  Atari-specific routines for use with Info-ZIP's UnZip 5.1 and later.

  Contains:  readdir()
             do_wild()           <-- generic enough to put in file_io.c?
             mapattr()
             mapname()
             checkdir()
             mkdir()
             close_outfile()
             version()

  Due to the amazing MiNT library being very, very close to BSD unix's
  library, I'm using the unix.c as a base for this.  Note:  If you're not
  going to compile this with the MiNT libraries (for GNU C, Turbo C, Pure C,
  Lattice C, or Heat & Serve C), you're going to be in for some nasty work.
  Most of the modifications in this file were made by Chris Herborth
  (cherborth@semprini.waterloo-rdp.on.ca) and /should/ be marked with [cjh].

  ---------------------------------------------------------------------------*/


#include "unzip.h"
#include <dirent.h>            /* MiNTlibs has dirent [cjh] */

static int created_dir;        /* used in mapname(), checkdir() */
static int renamed_fullpath;   /* ditto */

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


    /* Even when we're just returning wildspec, we *always* do so in
     * matchname[]--calling routine is allowed to append four characters
     * to the returned string, and wildspec may be a pointer to argv[].
     */
    if (firstcall) {        /* first call:  must initialize everything */
        firstcall = FALSE;

        /* break the wildspec into a directory part and a wildcard filename */
        if ((wildname = strrchr(wildspec, '/')) == NULL) {
            dirname = ".";
            dirnamelen = 1;
            have_dirname = FALSE;
            wildname = wildspec;
        } else {
            ++wildname;     /* point at character after '/' */
            dirnamelen = wildname - wildspec;
            if ((dirname = (char *)malloc(dirnamelen+1)) == NULL) {
                fprintf(stderr, "warning:  can't allocate wildcard buffers\n");
                strcpy(matchname, wildspec);
                return matchname;   /* but maybe filespec was not a wildcard */
            }
            strncpy(dirname, wildspec, dirnamelen);
            dirname[dirnamelen] = '\0';   /* terminate for strcpy below */
            have_dirname = TRUE;
        }

        if ((dir = opendir(dirname)) != NULL) {
            while ((file = readdir(dir)) != NULL) {
                if (file->d_name[0] == '.' && wildname[0] != '.')
                    continue;  /* Unix:  '*' and '?' do not match leading dot */
                    /* Need something here for TOS filesystem? [cjh] */
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
        /* May need special TOS handling here. [cjh] */
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





/**********************/
/* Function mapattr() */
/**********************/

int mapattr()
{
    ulg tmp = crec.external_file_attributes;

    switch (pInfo->hostnum) {
        case UNIX_:
            /* minix filesystem under MiNT on Atari [cjh] */
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
            /* TOS filesystem [cjh] */
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
    char pathcomp[FILNAMSIZ];   /* path-component buffer */
    char *pp, *cp=NULL;         /* character pointers */
    char *lastsemi = NULL;      /* pointer to last semi-colon in pathcomp */
    int quote = FALSE;          /* flags */
    int error = 0;
    register unsigned workch;   /* hold the character being tested */


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
/* SHORT_NAMES required for TOS, but it has to co-exist for minix fs... [cjh] */
#ifdef SHORT_NAMES
        char *old_end = end;
#endif

        Trace((stderr, "appending dir segment [%s]\n", pathcomp));
        while ((*end = *pathcomp++) != '\0')
            ++end;
/* SHORT_NAMES required for TOS, but it has to co-exist for minix fs... [cjh] */
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
        buildpath = end = NULL;
        return 0;
    }

/*---------------------------------------------------------------------------
    APPEND_NAME:  assume the path component is the filename; append it and
    return without checking for existence.
  ---------------------------------------------------------------------------*/

    if (FUNCTION == APPEND_NAME) {
/* SHORT_NAMES required for TOS, but it has to co-exist for minix fs... [cjh] */
#ifdef SHORT_NAMES
        char *old_end = end;
#endif

        Trace((stderr, "appending filename [%s]\n", pathcomp));
        while ((*end = *pathcomp++) != '\0') {
            ++end;
/* SHORT_NAMES required for TOS, but it has to co-exist for minix fs... [cjh] */
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
            if ((rootpath = (char *)malloc(rootlen+2)) == NULL) {
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




/****************************/
/* Function close_outfile() */
/****************************/

void close_outfile()
{
    static short yday[]={0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334};
    long m_time;
    int yr, mo, dy, hh, mm, ss, leap, days;
    struct utimbuf tp;
#   define YRBASE  1970
    extern long timezone;  /* seems ok for Atari if undefine __STRICT_ANSI__ */
                           /* [cjh] */

/*---------------------------------------------------------------------------
    If symbolic links are supported, allocate a storage area, put the uncom-
    pressed "data" in it, and create the link.  Since we know it's a symbolic
    link to start with, we shouldn't have to worry about overflowing unsigned
    ints with unsigned longs.
  ---------------------------------------------------------------------------*/

    /* symlinks allowed on minix filesystems [cjh]
     * Hopefully this will work properly... We won't bother to try if
     * MiNT isn't present; the symlink should fail if we're on a TOS
     * filesystem.
     * BUG: should we copy the original file to the "symlink" if the
     *      link fails?
     */
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
    /* This seems ok, if you undefine __STRICT_ANSI__; use tzset(). [cjh] */
    tzset();              /* get `timezone' */
    m_time += timezone;   /* seconds WEST of GMT:  add */

    /* adjust for daylight savings time (or local equivalent) */
    if (localtime(&m_time)->tm_isdst)
        m_time -= 60L * 60L;   /* adjust for daylight savings time */

    /* set the file's access and modification times */
    tp.actime = tp.modtime = m_time;
    if (utime(filename, &tp))
        fprintf(stderr, "warning:  can't set the time for %s\n", filename);

} /* end function close_outfile() */




#ifndef SFX

/************************/
/*  Function version()  */
/************************/

void version()
{
#ifdef __TURBOC__
    char buf[40];
#endif

    printf(LoadFarString(CompiledWith),

#ifdef __GNUC__
      "gcc ", __VERSION__,
#else
#  if 0
      "cc ", (sprintf(buf, " version %d", _RELEASE), buf),
#  else
#  ifdef __TURBOC__
      "Turbo C", (sprintf(buf, " (0x%04x = %d)", __TURBOC__, __TURBOC__), buf),
#  else
      "unknown compiler", "",
#  endif
#  endif
#endif

#ifdef __MINT__
      "Atari TOS/MiNT",
#else
      "Atari TOS",
#endif

#if defined(atarist) || defined(ATARIST)
      " (Atari ST/TT/Falcon030)",
#else
      "",
#endif

#ifdef __DATE__
      " on ", __DATE__
#else
      "", ""
#endif
      );

} /* end function version() */

#endif /* !SFX */
