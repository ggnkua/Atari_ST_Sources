/*---------------------------------------------------------------------------

  msdos.c

  MSDOS-specific routines for use with Info-ZIP's UnZip 5.1 and later.

  Contains:  Opendir()           (from zip)
             Readdir()           (from zip)
             do_wild()
             mapattr()
             mapname()
             checkdir()
             isfloppy()
             volumelabel()       (non-djgpp, non-emx)
             close_outfile()
             dateformat()
             version()
             _dos_getcountryinfo() (djgpp, emx)
             _dos_setftime()     (djgpp, emx)
             _dos_setfileattr()  (djgpp, emx)
             _dos_getdrive()     (djgpp, emx)
             _dos_creat()        (djgpp, emx)
             _dos_close()        (djgpp, emx)
             volumelabel()       (djgpp, emx)

  ---------------------------------------------------------------------------*/



#include "unzip.h"
#undef FILENAME    /* BC++ 3.1 and djgpp 1.11 define FILENAME in <dir.h> */

static int isfloppy OF((int nDrive));
static int volumelabel OF((char *newlabel));

static int created_dir;        /* used by mapname(), checkdir() */
static int renamed_fullpath;   /* ditto */
static unsigned nLabelDrive;   /* ditto, plus volumelabel() */

#if (defined(__GO32__) || defined(__EMX__))
#  define MKDIR(path,mode)   mkdir(path,mode)
#  include <dirent.h>        /* use readdir() */
#  define direct dirent
#  define Opendir opendir
#  define Readdir readdir
#  ifdef __EMX__
#    include <dos.h>
#    define GETDRIVE(d)      d = _getdrive()
#    define FA_LABEL         A_LABEL
#  else
#    define GETDRIVE(d)      _dos_getdrive(&d)
#  endif
#else /* !(__GO32__ || __EMX__) */
#  define MKDIR(path,mode)   mkdir(path)
#  ifdef __TURBOC__
#    define FATTR            FA_HIDDEN+FA_SYSTEM+FA_DIREC
#    define FVOLID           FA_VOLID
#    define FFIRST(n,d,a)    findfirst(n,(struct ffblk *)d,a)
#    define FNEXT(d)         findnext((struct ffblk *)d)
#    define GETDRIVE(d)      d=getdisk()+1
#    include <dir.h>
#  else /* !__TURBOC__ */
#    define FATTR            _A_HIDDEN+_A_SYSTEM+_A_SUBDIR
#    define FVOLID           _A_VOLID
#    define FFIRST(n,d,a)    _dos_findfirst(n,a,(struct find_t *)d)
#    define FNEXT(d)         _dos_findnext((struct find_t *)d)
#    define GETDRIVE(d)      _dos_getdrive(&d)
#    include <direct.h>
#  endif /* ?__TURBOC__ */
   typedef struct direct {
       char d_reserved[30];
       char d_name[13];
       int d_first;
   } DIR;
#  define closedir free
   DIR *Opendir OF((const char *));
   struct direct *Readdir OF((DIR *));




#ifndef SFX

/**********************/   /* Borland C++ 3.x has its own opendir/readdir */
/* Function Opendir() */   /*  library routines, but earlier versions don't, */
/**********************/   /*  so use ours regardless */

DIR *Opendir(name)
    const char *name;        /* name of directory to open */
{
    DIR *dirp;               /* malloc'd return value */
    char *nbuf;              /* malloc'd temporary string */
    int len = strlen(name);  /* path length to avoid strlens and strcats */


    if ((dirp = (DIR *)malloc(sizeof(DIR))) == (DIR *)NULL)
        return (DIR *)NULL;
    if ((nbuf = malloc(len + 5)) == (char *)NULL) {
        free(dirp);
        return (DIR *)NULL;
    }
    strcpy(nbuf, name);
    if (nbuf[len-1] == ':') {
        nbuf[len++] = '.';
    } else if (nbuf[len-1] == '/' || nbuf[len-1] == '\\')
        --len;
    strcpy(nbuf+len, "/*.*");
    Trace((stderr, "opendir:  nbuf = [%s]\n", nbuf));

    if (FFIRST(nbuf, dirp, FATTR)) {
        free((voidp *)nbuf);
        return (DIR *)NULL;
    }
    free((voidp *)nbuf);
    dirp->d_first = 1;
    return dirp;
}





/**********************/
/* Function Readdir() */
/**********************/

struct direct *Readdir(d)
    DIR *d;         /* directory stream from which to read */
{
    /* Return pointer to first or next directory entry, or NULL if end. */

    if (d->d_first)
        d->d_first = 0;
    else
        if (FNEXT(d))
            return (struct direct *)NULL;
    return (struct direct *)d;
}

#endif /* !SFX */
#endif /* ?(__GO32__ || __EMX__) */





#ifndef SFX

/************************/
/*  Function do_wild()  */   /* identical to OS/2 version */
/************************/

char *do_wild(wildspec)
    char *wildspec;          /* only used first time on a given dir */
{
    static DIR *dir = (DIR *)NULL;
    static char *dirname, *wildname, matchname[FILNAMSIZ];
    static char Far CantAllocateWildcard[] =
      "warning:  can't allocate wildcard buffers\n";
    static int firstcall=TRUE, have_dirname, dirnamelen;
    struct direct *file;


    /* Even when we're just returning wildspec, we *always* do so in
     * matchname[]--calling routine is allowed to append four characters
     * to the returned string, and wildspec may be a pointer to argv[].
     */
    if (firstcall) {        /* first call:  must initialize everything */
        firstcall = FALSE;

        /* break the wildspec into a directory part and a wildcard filename */
        if ((wildname = strrchr(wildspec, '/')) == (char *)NULL &&
            (wildname = strrchr(wildspec, ':')) == (char *)NULL) {
            dirname = ".";
            dirnamelen = 1;
            have_dirname = FALSE;
            wildname = wildspec;
        } else {
            ++wildname;     /* point at character after '/' or ':' */
            dirnamelen = wildname - wildspec;
            if ((dirname = (char *)malloc(dirnamelen+1)) == (char *)NULL) {
                FPRINTF(stderr, LoadFarString(CantAllocateWildcard));
                strcpy(matchname, wildspec);
                return matchname;   /* but maybe filespec was not a wildcard */
            }
/* GRR:  can't strip trailing char for opendir since might be "d:/" or "d:"
 *       (would have to check for "./" at end--let opendir handle it instead) */
            strncpy(dirname, wildspec, dirnamelen);
            dirname[dirnamelen] = '\0';   /* terminate for strcpy below */
            have_dirname = TRUE;
        }
        Trace((stderr, "do_wild:  dirname = [%s]\n", dirname));

        if ((dir = Opendir(dirname)) != (DIR *)NULL) {
            while ((file = Readdir(dir)) != (struct direct *)NULL) {
                Trace((stderr, "do_wild:  readdir returns %s\n", file->d_name));
                if (match(file->d_name, wildname, 1)) {  /* 1 == ignore case */
                    Trace((stderr, "do_wild:  match() succeeds\n"));
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
        Trace((stderr, "do_wild:  opendir(%s) returns NULL\n", dirname));

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
    while ((file = Readdir(dir)) != (struct direct *)NULL)
        if (match(file->d_name, wildname, 1)) {   /* 1 == ignore case */
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
    /* set archive bit (file is not backed up): */
    pInfo->file_attr = (unsigned)(crec.external_file_attributes | 32) & 0xff;
    return 0;

} /* end function mapattr() */





/*****************************/
/*  Strings used in msdos.c  */
/*****************************/

static char Far ConversionFailed[] = "mapname:  conversion of %s failed\n";
static char Far ErrSetVolLabel[] = "mapname:  error setting volume label\n";
static char Far PathTooLong[] = "checkdir error:  path too long: %s\n";
static char Far CantCreateDir[] = "checkdir error:  can't create %s\n\
                 unable to process %s.\n";
static char Far DirIsntDirectory[] =
  "checkdir error:  %s exists but is not directory\n\
                 unable to process %s.\n";
static char Far PathTooLongTrunc[] =
  "checkdir warning:  path too long; truncating\n                   %s\n\
                -> %s\n";
#ifndef SFX
   static char Far CantCreateExtractDir[] =
     "checkdir:  can't create extraction directory: %s\n";
#endif





/************************/
/*  Function mapname()  */
/************************/

int mapname(renamed)  /* return 0 if no error, 1 if caution (filename trunc), */
    int renamed;      /* 2 if warning (skip file because dir doesn't exist), */
{                     /* 3 if error (skip file), 10 if no memory (skip file) */
    char pathcomp[FILNAMSIZ];    /* path-component buffer */
    char *pp, *cp=(char *)NULL;  /* character pointers */
    char *lastsemi=(char *)NULL; /* pointer to last semi-colon in pathcomp */
    char *last_dot=(char *)NULL; /* last dot not converted to underscore */
    int quote = FALSE;           /* flag:  next char is literal */
    int dotname = FALSE;         /* flag:  path component begins with dot */
    int error = 0;
    register unsigned workch;    /* hold the character being tested */


/*---------------------------------------------------------------------------
    Initialize various pointers and counters and stuff.
  ---------------------------------------------------------------------------*/

    /* can create path as long as not just freshening, or if user told us */
    create_dirs = (!fflag || renamed);

    created_dir = FALSE;        /* not yet */
    renamed_fullpath = FALSE;

/* GRR:  for VMS, convert to internal format now or later? or never? */
    if (renamed) {
        cp = filename - 1;      /* point to beginning of renamed name... */
        while (*++cp)
            if (*cp == '\\')    /* convert backslashes to forward */
                *cp = '/';
        cp = filename;
        /* use temporary rootpath if user gave full pathname */
        if (filename[0] == '/') {
            renamed_fullpath = TRUE;
            pathcomp[0] = '/';  /* copy the '/' and terminate */
            pathcomp[1] = '\0';
            ++cp;
        } else if (isalpha(filename[0]) && filename[1] == ':') {
            renamed_fullpath = TRUE;
            pp = pathcomp;
            *pp++ = *cp++;      /* copy the "d:" (+ '/', possibly) */
            *pp++ = *cp++;
            if (*cp == '/')
                *pp++ = *cp++;  /* otherwise add "./"? */
            *pp = '\0';
        }
    }

    /* pathcomp is ignored unless renamed_fullpath is TRUE: */
    if ((error = checkdir(pathcomp, INIT)) != 0)    /* initialize path buffer */
        return error;           /* ...unless no mem or vol label on hard disk */

    *pathcomp = '\0';           /* initialize translation buffer */
    pp = pathcomp;              /* point to translation buffer */
    if (!renamed) {             /* cp already set if renamed */
        if (jflag)              /* junking directories */
            cp = (char *)strrchr(filename, '/');
        if (cp == (char *)NULL) /* no '/' or not junking dirs */
            cp = filename;      /* point to internal zipfile-member pathname */
        else
            ++cp;               /* point to start of last component of path */
    }

/*---------------------------------------------------------------------------
    Begin main loop through characters in filename.
  ---------------------------------------------------------------------------*/

    while ((workch = (uch)*cp++) != 0) {

        if (quote) {              /* if character quoted, */
            *pp++ = (char)workch; /*  include it literally */
            quote = FALSE;
        } else
            switch (workch) {
            case '/':             /* can assume -j flag not given */
                *pp = '\0';
/* GRR:  can add 8.3 truncation here */
                if (last_dot) {   /* one dot in directory name is legal */
                    *last_dot = '.';
                    last_dot = (char *)NULL;
                }
                if ((error = checkdir(pathcomp, APPEND_DIR)) > 1)
                    return error;
                pp = pathcomp;    /* reset conversion buffer for next piece */
                lastsemi = (char *)NULL; /* leave directory semi-colons alone */
                break;

            case ':':             /* drive names not stored in zipfile, */
            case '[':             /*  so no colons allowed; no brackets, */
            case ']':             /*  either */
                *pp++ = '_';
                break;

            case '.':
                if (pp == pathcomp) {     /* nothing appended yet... */
                    if (*cp == '/') {     /* don't bother appending a "./" */
                        ++cp;             /*  component to the path:  skip */
                        break;            /*  to next char after the '/' */
                    } else if (*cp == '.' && cp[1] == '/') {   /* "../" */
                        *pp++ = '.';      /* add first dot, unchanged... */
                        ++cp;             /* skip second dot, since it will */
                    } else {              /*  be "added" at end of if-block */
                        *pp++ = '_';      /* FAT doesn't allow null filename */
                        dotname = TRUE;   /*  bodies, so map .exrc -> _.exrc */
                    }                     /*  (extra '_' now, "dot" below) */
                } else if (dotname) {     /* found a second dot, but still */
                    dotname = FALSE;      /*  have extra leading underscore: */
                    *pp = '\0';           /*  remove it by shifting chars */
                    pp = pathcomp + 1;    /*  left one space (e.g., .p1.p2: */
                    while (pp[1]) {       /*  __p1 -> _p1_p2 -> _p1.p2 when */
                        *pp = pp[1];      /*  finished) [opt.:  since first */
                        ++pp;             /*  two chars are same, can start */
                    }                     /*  shifting at second position] */
                }
                last_dot = pp;    /* point at last dot so far... */
                *pp++ = '_';      /* convert dot to underscore for now */
                break;

            case ';':             /* start of VMS version? */
                lastsemi = pp;    /* omit for now; remove VMS vers. later */
                break;

            case '\026':          /* control-V quote for special chars */
                quote = TRUE;     /* set flag for next character */
                break;

            case ' ':             /* change spaces to underscore only */
                if (sflag)        /*  if specifically requested */
                    *pp++ = '_';
                else
                    *pp++ = (char)workch;
                break;

            default:
                /* allow European characters in filenames: */
                if (isprint(workch) || (128 <= workch && workch <= 254))
                    *pp++ = (char)workch;
            } /* end switch */

    } /* end while loop */

    *pp = '\0';                   /* done with pathcomp:  terminate it */

    /* if not saving them, remove VMS version numbers (appended "###") */
    if (!V_flag && lastsemi) {
        pp = lastsemi;            /* semi-colon was omitted:  expect all #'s */
        while (isdigit((uch)(*pp)))
            ++pp;
        if (*pp == '\0')          /* only digits between ';' and end:  nuke */
            *lastsemi = '\0';
    }

/* GRR:  can add 8.3 truncation here */
    if (last_dot != (char *)NULL) /* one dot is OK:  put it back in */
        *last_dot = '.';          /* (already done for directories) */

/*---------------------------------------------------------------------------
    Report if directory was created (and no file to create:  filename ended
    in '/'), check name to be sure it exists, and combine path and name be-
    fore exiting.
  ---------------------------------------------------------------------------*/

    if (filename[strlen(filename) - 1] == '/') {
        checkdir(filename, GETPATH);
        if (created_dir && QCOND2) {
            FPRINTF(stdout, "   creating: %s\n", filename);
            return IZ_CREATED_DIR;   /* set dir time (note trailing '/') */
        }
        return 2;   /* dir existed already; don't look for data to extract */
    }

    if (*pathcomp == '\0') {
        FPRINTF(stderr, LoadFarString(ConversionFailed), filename);
        return 3;
    }

    checkdir(pathcomp, APPEND_NAME);   /* returns 1 if truncated:  care? */
    checkdir(filename, GETPATH);

    if (pInfo->vollabel) {   /* set the volume label now */
        if (QCOND2)
            FPRINTF(stdout, "labelling %c: %-22s\n", (nLabelDrive + 'a' - 1),
              filename);
        if (volumelabel(filename)) {
            FPRINTF(stderr, LoadFarString(ErrSetVolLabel));
            return 3;
        }
        return 2;   /* success:  skip the "extraction" quietly */
    }

    return error;

} /* end function mapname() */





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
#ifdef MSC
    int attrs;                /* work around MSC stat() bug */
#endif

#   define FN_MASK   7
#   define FUNCTION  (flag & FN_MASK)



/*---------------------------------------------------------------------------
    APPEND_DIR:  append the path component to the path being built and check
    for its existence.  If doesn't exist and we are creating directories, do
    so for this one; else signal success or error as appropriate.
  ---------------------------------------------------------------------------*/

    if (FUNCTION == APPEND_DIR) {
        int too_long = FALSE;

        Trace((stderr, "appending dir segment [%s]\n", pathcomp));
        while ((*end = *pathcomp++) != '\0')
            ++end;

        /* GRR:  could do better check, see if overrunning buffer as we go:
         * check end-buildpath after each append, set warning variable if
         * within 20 of FILNAMSIZ; then if var set, do careful check when
         * appending.  Clear variable when begin new path. */

        if ((end-buildpath) > FILNAMSIZ-3)  /* need '/', one-char name, '\0' */
            too_long = TRUE;                /* check if extracting directory? */
#ifdef MSC /* MSC 6.00 bug:  stat(non-existent-dir) == 0 [exists!] */
        if (_dos_getfileattr(buildpath, &attrs) || stat(buildpath, &statbuf))  
#else
        if (stat(buildpath, &statbuf))      /* path doesn't exist */
#endif
        {
            if (!create_dirs) {   /* told not to create (freshening) */
                free(buildpath);
                return 2;         /* path doesn't exist:  nothing to do */
            }
            if (too_long) {
                FPRINTF(stderr, LoadFarString(PathTooLong), buildpath);
                fflush(stderr);
                free(buildpath);
                return 4;         /* no room for filenames:  fatal */
            }
            if (MKDIR(buildpath, 0777) == -1) {   /* create the directory */
                FPRINTF(stderr, LoadFarString(CantCreateDir), buildpath,
                        filename);
                fflush(stderr);
                free(buildpath);
                return 3;      /* path didn't exist, tried to create, failed */
            }
            created_dir = TRUE;
        } else if (!S_ISDIR(statbuf.st_mode)) {
            FPRINTF(stderr, LoadFarString(DirIsntDirectory), buildpath,
                    filename);
            fflush(stderr);
            free(buildpath);
            return 3;          /* path existed but wasn't dir */
        }
        if (too_long) {
            FPRINTF(stderr, LoadFarString(PathTooLong), buildpath);
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
        Trace((stderr, "appending filename [%s]\n", pathcomp));
        while ((*end = *pathcomp++) != '\0') {
            ++end;
            if ((end-buildpath) >= FILNAMSIZ) {
                *--end = '\0';
                FPRINTF(stderr, LoadFarString(PathTooLongTrunc),
                        filename, buildpath);
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

    if (FUNCTION == INIT) {
        Trace((stderr, "initializing buildpath to "));
        if ((buildpath = (char *)malloc(strlen(filename)+rootlen+1)) ==
            (char *)NULL)
            return 10;
        if (pInfo->vollabel) {
/* GRR:  for network drives, do strchr() and return IZ_VOL_LABEL if not [1] */
            if (renamed_fullpath && pathcomp[1] == ':')
                *buildpath = ToLower(*pathcomp);
            else if (!renamed_fullpath && rootpath && rootpath[1] == ':')
                *buildpath = ToLower(*rootpath);
            else {
                GETDRIVE(nLabelDrive);   /* assumed that a == 1, b == 2, etc. */
                *buildpath = (char)(nLabelDrive - 1 + 'a');
            }
            nLabelDrive = *buildpath - 'a' + 1;       /* save for mapname() */
            if (volflag == 0 || *buildpath < 'a' ||   /* no labels/bogus disk */
                (volflag == 1 && !isfloppy(nLabelDrive))) {  /* -$:  no fixed */
                free(buildpath);
                return IZ_VOL_LABEL;     /* skipping with message */
            }
            *buildpath = '\0';
            end = buildpath;
        } else if (renamed_fullpath) {   /* pathcomp = valid data */
            end = buildpath;
            while ((*end = *pathcomp++) != '\0')
                ++end;
        } else if (rootlen > 0) {
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
    command line.  Note that under OS/2 and MS-DOS, if a candidate extract-to
    directory specification includes a drive letter (leading "x:"), it is
    treated just as if it had a trailing '/'--that is, one directory level
    will be created if the path doesn't exist, unless this is otherwise pro-
    hibited (e.g., freshening).
  ---------------------------------------------------------------------------*/

#ifndef SFX
    if (FUNCTION == ROOT) {
        Trace((stderr, "initializing root path to [%s]\n", pathcomp));
        if (pathcomp == (char *)NULL) {
            rootlen = 0;
            return 0;
        }
        if ((rootlen = strlen(pathcomp)) > 0) {
            int had_trailing_pathsep=FALSE, has_drive=FALSE, xtra=2;

            if (isalpha(pathcomp[0]) && pathcomp[1] == ':')
                has_drive = TRUE;   /* drive designator */
            if (pathcomp[rootlen-1] == '/') {
                pathcomp[--rootlen] = '\0';
                had_trailing_pathsep = TRUE;
            }
            if (has_drive && (rootlen == 2)) {
                if (!had_trailing_pathsep)   /* i.e., original wasn't "x:/" */
                    xtra = 3;      /* room for '.' + '/' + 0 at end of "x:" */
            } else {               /* don't bother checking "x:." and "x:/" */
#ifdef MSC /* MSC 6.00 bug:  stat(non-existent-dir) == 0 [exists!] */
                if (_dos_getfileattr(pathcomp, &attrs) ||
                    SSTAT(pathcomp, &statbuf) || !S_ISDIR(statbuf.st_mode))
#else
                if (SSTAT(pathcomp, &statbuf) || !S_ISDIR(statbuf.st_mode))
#endif
                {
                    /* path does not exist */
                    if (!create_dirs
#ifdef OLD_EXDIR
                                     || (!has_drive && !had_trailing_pathsep)
#endif
                                                                             ) {
                        rootlen = 0;
                        return 2;   /* treat as stored file */
                    }
/* GRR:  scan for wildcard characters?  OS-dependent...  if find any, return 2:
 * treat as stored file(s) */
                    /* create directory (could add loop here to scan pathcomp
                     * and create more than one level, but really necessary?) */
                    if (MKDIR(pathcomp, 0777) == -1) {
                        FPRINTF(stderr, LoadFarString(CantCreateExtractDir),
                                pathcomp);
                        fflush(stderr);
                        rootlen = 0;   /* path didn't exist, tried to create, */
                        return 3;  /* failed:  file exists, or need 2+ levels */
                    }
                }
            }
            if ((rootpath = (char *)malloc(rootlen+xtra)) == (char *)NULL) {
                rootlen = 0;
                return 10;
            }
            strcpy(rootpath, pathcomp);
            if (xtra == 3)                  /* had just "x:", make "x:." */
                rootpath[rootlen++] = '.';
            rootpath[rootlen++] = '/';
            rootpath[rootlen] = '\0';
        }
        Trace((stderr, "rootpath now = [%s]\n", rootpath));
        return 0;
    }
#endif /* !SFX */

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






/***********************/
/* Function isfloppy() */
/***********************/

static int isfloppy(nDrive)  /* more precisely, is it removable? */
    int nDrive;
{
    union REGS regs;

    regs.h.ah = 0x44;
    regs.h.al = 0x08;
    regs.h.bl = (uch)nDrive;
#ifdef __EMX__
    _int86(0x21, &regs, &regs);
    if (regs.x.flags & 1)
#else
    intdos(&regs, &regs);
    if (regs.x.cflag)        /* error:  do default a/b check instead */
#endif
    {
        Trace((stderr,
          "error in DOS function 0x44 (AX = 0x%04x):  guessing instead...\n",
          regs.x.ax));
        return (nDrive == 1 || nDrive == 2)? TRUE : FALSE;
    } else
        return regs.x.ax? FALSE : TRUE;
}




#if (!defined(__GO32__) && !defined(__EMX__))

typedef struct dosfcb {
    uch  flag;        /* ff to indicate extended FCB */
    char res[5];      /* reserved */
    uch  vattr;       /* attribute */
    uch  drive;       /* drive (1=A, 2=B, ...) */
    uch  vn[11];      /* file or volume name */
    char dmmy[5];
    uch  nn[11];      /* holds new name if renaming (else reserved) */
    char dmmy2[9];
} dos_fcb;

/**************************/
/* Function volumelabel() */
/**************************/

static int volumelabel(newlabel)
    char *newlabel;
{
#ifdef DEBUG
    char *p;
#endif
    int len = strlen(newlabel);
    dos_fcb  fcb, dta, far *pfcb=&fcb, far *pdta=&dta;
    struct SREGS sregs;
    union REGS regs;


/*---------------------------------------------------------------------------
    Label the diskette specified by nLabelDrive using FCB calls.  (Old ver-
    sions of MS-DOS and OS/2 DOS boxes can't use DOS function 3Ch to create
    labels.)  Must use far pointers for MSC FP_* macros to work; must pad
    FCB filenames with spaces; and cannot include dot in 8th position.  May
    or may not need to zero out FCBs before using; do so just in case.
  ---------------------------------------------------------------------------*/

    memset((char *)&dta, 0, sizeof(dos_fcb));
    memset((char *)&fcb, 0, sizeof(dos_fcb));

#ifdef DEBUG
    for (p = (char *)&dta; (p - (char *)&dta) < sizeof(dos_fcb); ++p)
        if (*p)
            fprintf(stderr, "error:  dta[%d] = %x\n", (p - (char *)&dta), *p);
    for (p = (char *)&fcb; (p - (char *)&fcb) < sizeof(dos_fcb); ++p)
        if (*p)
            fprintf(stderr, "error:  fcb[%d] = %x\n", (p - (char *)&fcb), *p);
    printf("testing pointer macros:\n");
    segread(&sregs);
    printf("cs = %x, ds = %x, es = %x, ss = %x\n", sregs.cs, sregs.ds, sregs.es,
      sregs.ss);
#endif /* DEBUG */

#if 0
#ifdef __TURBOC__
    bdosptr(0x1a, dta, DO_NOT_CARE);
#else
    (intdosx method below)
#endif
#endif /* 0 */

    /* set the disk transfer address for subsequent FCB calls */
    sregs.ds = FP_SEG(pdta);
    regs.x.dx = FP_OFF(pdta);
    Trace((stderr, "segment:offset of pdta = %x:%x\n", sregs.ds, regs.x.dx));
    Trace((stderr, "&dta = %lx, pdta = %lx\n", (ulg)&dta, (ulg)pdta));
    regs.h.ah = 0x1a;
    intdosx(&regs, &regs, &sregs);

    /* fill in the FCB */
    sregs.ds = FP_SEG(pfcb);
    regs.x.dx = FP_OFF(pfcb);
    pfcb->flag = 0xff;          /* extended FCB */
    pfcb->vattr = 0x08;         /* attribute:  disk volume label */
    pfcb->drive = (uch)nLabelDrive;

#ifdef DEBUG
    Trace((stderr, "segment:offset of pfcb = %x:%x\n", sregs.ds, regs.x.dx));
    Trace((stderr, "&fcb = %lx, pfcb = %lx\n", (ulg)&fcb, (ulg)pfcb));
    Trace((stderr, "(2nd check:  labelling drive %c:)\n", pfcb->drive-1+'A'));
    if (pfcb->flag != fcb.flag)
        fprintf(stderr, "error:  pfcb->flag = %d, fcb.flag = %d\n",
          pfcb->flag, fcb.flag);
    if (pfcb->drive != fcb.drive)
        fprintf(stderr, "error:  pfcb->drive = %d, fcb.drive = %d\n",
          pfcb->drive, fcb.drive);
    if (pfcb->vattr != fcb.vattr)
        fprintf(stderr, "error:  pfcb->vattr = %d, fcb.vattr = %d\n",
          pfcb->vattr, fcb.vattr);
#endif /* DEBUG */

    /* check for existing label */
    Trace((stderr, "searching for existing label via FCBs\n"));
    regs.h.ah = 0x11;      /* FCB find first */
#if 0  /* THIS STRNCPY FAILS (MSC bug?): */
    strncpy(pfcb->vn, "???????????", 11);   /* i.e., "*.*" */
    Trace((stderr, "pfcb->vn = %lx\n", (ulg)pfcb->vn));
    Trace((stderr, "flag = %x, drive = %d, vattr = %x, vn = %s = %s.\n",
      fcb.flag, fcb.drive, fcb.vattr, fcb.vn, pfcb->vn));
#endif
    strncpy((char *)fcb.vn, "???????????", 11);   /* i.e., "*.*" */
    Trace((stderr, "fcb.vn = %lx\n", (ulg)fcb.vn));
    Trace((stderr, "regs.h.ah = %x, regs.x.dx = %04x, sregs.ds = %04x\n",
      regs.h.ah, regs.x.dx, sregs.ds));
    Trace((stderr, "flag = %x, drive = %d, vattr = %x, vn = %s = %s.\n",
      fcb.flag, fcb.drive, fcb.vattr, fcb.vn, pfcb->vn));
    intdosx(&regs, &regs, &sregs);

/*---------------------------------------------------------------------------
    If not previously labelled, write a new label.  Otherwise just rename,
    since MS-DOS 2.x has a bug which damages the FAT when the old label is
    deleted.
  ---------------------------------------------------------------------------*/

    if (regs.h.al) {
        Trace((stderr, "no label found\n\n"));
        regs.h.ah = 0x16;                 /* FCB create file */
        strncpy((char *)fcb.vn, newlabel, len);
        if (len < 11)   /* fill with spaces */
            strncpy((char *)(fcb.vn+len), "           ", 11-len);
        Trace((stderr, "fcb.vn = %lx  pfcb->vn = %lx\n", (ulg)fcb.vn,
          (ulg)pfcb->vn));
        Trace((stderr, "flag = %x, drive = %d, vattr = %x\n", fcb.flag,
          fcb.drive, fcb.vattr));
        Trace((stderr, "vn = %s = %s.\n", fcb.vn, pfcb->vn));
        intdosx(&regs, &regs, &sregs);
        regs.h.ah = 0x10;                 /* FCB close file */
        if (regs.h.al) {
            Trace((stderr, "unable to write volume name (AL = %x)\n",
              regs.h.al));
            intdosx(&regs, &regs, &sregs);
            return 1;
        } else {
            intdosx(&regs, &regs, &sregs);
            Trace((stderr, "new volume label [%s] written\n", newlabel));
            return 0;
        }
    } else {
        Trace((stderr, "found old label [%s]\n\n", dta.vn));  /* not term. */
        regs.h.ah = 0x17;                 /* FCB rename */
        strncpy((char *)fcb.vn, (char *)dta.vn, 11);
        strncpy((char *)fcb.nn, newlabel, len);
        if (len < 11)                     /* fill with spaces */
            strncpy((char *)(fcb.nn+len), "           ", 11-len);
        Trace((stderr, "fcb.vn = %lx  pfcb->vn = %lx\n", (ulg)fcb.vn,
          (ulg)pfcb->vn));
        Trace((stderr, "fcb.nn = %lx  pfcb->nn = %lx\n", (ulg)fcb.nn,
          (ulg)pfcb->nn));
        Trace((stderr, "flag = %x, drive = %d, vattr = %x\n", fcb.flag,
          fcb.drive, fcb.vattr));
        Trace((stderr, "vn = %s = %s.\n", fcb.vn, pfcb->vn));
        Trace((stderr, "nn = %s = %s.\n", fcb.nn, pfcb->nn));
        intdosx(&regs, &regs, &sregs);
        if (regs.h.al) {
            Trace((stderr, "Unable to change volume name (AL = %x)\n",
              regs.h.al));
            return 1;
        } else {
            Trace((stderr, "volume label changed to [%s]\n", newlabel));
            return 0;
        }
    }
} /* end function volumelabel() */

#endif /* !__GO32__ && !__EMX__ */





/****************************/
/* Function close_outfile() */
/****************************/

void close_outfile()
 /*
  * MS-DOS VERSION
  *
  * Set the output file date/time stamp according to information from the
  * zipfile directory record for this member, then close the file and set
  * its permissions (archive, hidden, read-only, system).  Aside from closing
  * the file, this routine is optional (but most compilers support it).
  */
{
#ifdef __TURBOC__
    union {
        struct ftime ft;        /* system file time record */
        struct {
            ush ztime;          /* date and time words */
            ush zdate;          /* .. same format as in .ZIP file */
        } zt;
    } td;
#endif


/*---------------------------------------------------------------------------
    Copy and/or convert time and date variables, if necessary; then set the
    file time/date.  WEIRD BORLAND "BUG":  if output is buffered, and if run
    under at least some versions of DOS (e.g., 6.0), and if files are smaller
    than DOS physical block size (i.e., 512 bytes) (?), then files MAY NOT
    get timestamped correctly--apparently setftime() occurs before any data
    are written to the file, and when file is closed and buffers are flushed,
    timestamp is overwritten with current time.  Even with a 32K buffer, this
    does not seem to occur with larger files.  UnZip output is now unbuffered,
    but if it were not, could still avoid problem by adding "fflush(outfile)"
    just before setftime() call.  Weird, huh?
  ---------------------------------------------------------------------------*/

#ifdef __TURBOC__
    td.zt.ztime = lrec.last_mod_file_time;
    td.zt.zdate = lrec.last_mod_file_date;
    setftime(fileno(outfile), &td.ft);
#else
    _dos_setftime(fileno(outfile), lrec.last_mod_file_date,
                                   lrec.last_mod_file_time);
#endif

/*---------------------------------------------------------------------------
    And finally we can close the file...at least everybody agrees on how to
    do *this*.  I think...  Also change the mode according to the stored file
    attributes, since we didn't do that when we opened the dude.
  ---------------------------------------------------------------------------*/

    fclose(outfile);

#ifdef __TURBOC__
#   if (defined(__BORLANDC__) && (__BORLANDC__ >= 0x0452))
#     define Chmod  _rtl_chmod
#   else
#     define Chmod  _chmod
#   endif
    if (Chmod(filename, 1, pInfo->file_attr) != pInfo->file_attr)
        FPRINTF(stderr, "\nwarning:  file attributes may not be correct\n");
#else /* !__TURBOC__ */
    _dos_setfileattr(filename, pInfo->file_attr);
#endif /* ?__TURBOC__ */

} /* end function close_outfile() */





#ifndef SFX

/*************************/
/* Function dateformat() */
/*************************/

int dateformat()
{

/*---------------------------------------------------------------------------
    For those operating systems which support it, this function returns a
    value which tells how national convention says that numeric dates are
    displayed.  Return values are DF_YMD, DF_DMY and DF_MDY (the meanings
    should be fairly obvious).
  ---------------------------------------------------------------------------*/

#ifndef MSWIN
#if (!defined(__GO32__) && !defined(__EMX__))
    unsigned short _CountryInfo[18];
    unsigned short far *CountryInfo = _CountryInfo;
    struct SREGS sregs;
    union REGS regs;

    sregs.ds  = FP_SEG(CountryInfo);
    regs.x.dx = FP_OFF(CountryInfo);
    regs.x.ax = 0x3800;
    int86x(0x21, &regs, &regs, &sregs);

#else /* __GO32__ || __EMX__ */
    unsigned short CountryInfo[18];

    _dos_getcountryinfo(CountryInfo);
#endif

    switch(CountryInfo[0]) {
        case 0:
            return DF_MDY;
        case 1:
            return DF_DMY;
        case 2:
            return DF_YMD;
    }
#endif /* !MSWIN */

    return DF_MDY;   /* default for systems without locale info */

} /* end function dateformat() */





/************************/
/*  Function version()  */
/************************/

void version()
{
#if defined(__WATCOMC__) || defined(__TURBOC__) || defined(_MSC_VER)
    char buf[80];
#endif

    PRINTF(LoadFarString(CompiledWith),

#ifdef __GNUC__
#  ifdef __EMX__      /* __EMX__ is defined as "1" only (sigh) */
      "emx+gcc ",
#  else
#  ifdef __GO32__     /* ...so is __GO32__ (double sigh) */
      "djgpp gcc ",
#  else
      "gcc ",
#  endif
#  endif
      __VERSION__,
#else
#ifdef __WATCOMC__
      "Watcom C", (sprintf(buf, " (__WATCOMC__ = %d)", __WATCOMC__), buf),
#else
#ifdef __TURBOC__
#  ifdef __BORLANDC__
      "Borland C++",
#    if (__BORLANDC__ < 0x0200)
        " 1.0",
#    else
#    if (__BORLANDC__ == 0x0200)   /* James:  __TURBOC__ = 0x0297 */
        " 2.0",
#    else
#    if (__BORLANDC__ == 0x0400)
        " 3.0",
#    else
#    if (__BORLANDC__ == 0x0410)   /* __BCPLUSPLUS__ = 0x0310 */
        " 3.1",
#    else
#    if (__BORLANDC__ == 0x0452)   /* __BCPLUSPLUS__ = 0x0320 */
        " 4.0 or 4.02",
#    else
        " later than 4.1",
#    endif
#    endif
#    endif
#    endif
#    endif
#  else
      "Turbo C",
#    if (__TURBOC__ >= 0x0400)     /* Kevin:  3.0 -> 0x0401 */
        "++ 3.0 or later",
#    else
#    if (__TURBOC__ == 0x0295)     /* [661] vfy'd by Kevin */
        "++ 1.0",
#    else
#    if ((__TURBOC__ >= 0x018d) && (__TURBOC__ <= 0x0200))  /* James: 0x0200 */
        " 2.0",
#    else
#    if (__TURBOC__ > 0x0100)
        " 1.5",                    /* James:  0x0105? */
#    else
        " 1.0",                    /* James:  0x0100 */
#    endif
#    endif
#    endif
#    endif
#  endif
#else
#ifdef MSC
      "Microsoft C ",
#  ifdef _MSC_VER
#    if (_MSC_VER == 800)
        "8.0/8.0c (Visual C++ 1.0/1.5)",
#    else
        (sprintf(buf, "%d.%02d", _MSC_VER/100, _MSC_VER%100), buf),
#    endif
#  else
      "5.1 or earlier",
#  endif
#else
      "unknown compiler", "",
#endif /* MSC */
#endif /* __TURBOC__ */
#endif /* __WATCOMC__ */
#endif /* __GNUC__ */

      "MS-DOS",

#if (defined(__GNUC__) || (defined(__WATCOMC__) && defined(__386__)))
      " (32-bit)",
#else
#  if defined(M_I86HM) || defined(__HUGE__)
      " (16-bit, huge)",
#  else
#  if defined(M_I86LM) || defined(__LARGE__)
      " (16-bit, large)",
#  else
#  if defined(M_I86MM) || defined(__MEDIUM__)
      " (16-bit, medium)",
#  else
#  if defined(M_I86CM) || defined(__COMPACT__)
      " (16-bit, compact)",
#  else
#  if defined(M_I86SM) || defined(__SMALL__)
      " (16-bit, small)",
#  else
#  if defined(M_I86TM) || defined(__TINY__)
      " (16-bit, tiny)",
#  else
      " (16-bit)",
#  endif
#  endif
#  endif
#  endif
#  endif
#  endif
#endif

#ifdef __DATE__
      " on ", __DATE__
#else
      "", ""
#endif
      );

    /* temporary debugging code for Borland compilers only */
#ifdef __TURBOC__
    PRINTF("\tdebug(__TURBOC__ = 0x%04x = %d)\n", __TURBOC__, __TURBOC__);
#ifdef __BORLANDC__
    PRINTF("\tdebug(__BORLANDC__ = 0x%04x)\n", __BORLANDC__);
#else
    PRINTF("\tdebug(__BORLANDC__ not defined)\n");
#endif
#ifdef __TCPLUSPLUS__
    PRINTF("\tdebug(__TCPLUSPLUS__ = 0x%04x)\n", __TCPLUSPLUS__);
#else
    PRINTF("\tdebug(__TCPLUSPLUS__ not defined)\n");
#endif
#ifdef __BCPLUSPLUS__
    PRINTF("\tdebug(__BCPLUSPLUS__ = 0x%04x)\n\n", __BCPLUSPLUS__);
#else
    PRINTF("\tdebug(__BCPLUSPLUS__ not defined)\n\n");
#endif
#endif

} /* end function version() */

#endif /* !SFX */





#if (defined(__GO32__) || defined(__EMX__))

int volatile _doserrno;

unsigned _dos_getcountryinfo(void *countrybuffer)
{
    asm("movl %0, %%edx": : "g" (countrybuffer));
    asm("movl $0x3800, %eax");
    asm("int $0x21": : : "%eax", "%ebx", "%ecx", "%edx", "%esi", "%edi");
    _doserrno = 0;
    asm("jnc 1f");
    asm("movl %%eax, %0": "=m" (_doserrno));
    asm("1:");
    return _doserrno;
}

void _dos_setftime(int fd, ush dosdate, ush dostime)
{
    asm("movl %0, %%ebx": : "g" (fd));
    asm("movl %0, %%ecx": : "g" (dostime));
    asm("movl %0, %%edx": : "g" (dosdate));
    asm("movl $0x5701, %eax");
    asm("int $0x21": : : "%eax", "%ebx", "%ecx", "%edx", "%esi", "%edi");
}

void _dos_setfileattr(char *name, int attr)
{
    asm("movl %0, %%edx": : "g" (name));
    asm("movl %0, %%ecx": : "g" (attr));
    asm("movl $0x4301, %eax");
    asm("int $0x21": : : "%eax", "%ebx", "%ecx", "%edx", "%esi", "%edi");
}

void _dos_getdrive(unsigned *d)
{
    asm("movl $0x1900, %eax");
    asm("int $0x21": : : "%eax", "%ebx", "%ecx", "%edx", "%esi", "%edi");
    asm("xorb %ah, %ah");
    asm("incb %al");
    asm("movl %%eax, %0": "=a" (*d));
}

unsigned _dos_creat(char *path, unsigned attr, int *fd)
{
    asm("movl $0x3c00, %eax");
    asm("movl %0, %%edx": :"g" (path));
    asm("movl %0, %%ecx": :"g" (attr));
    asm("int $0x21": : : "%eax", "%ebx", "%ecx", "%edx", "%esi", "%edi");
    asm("movl %%eax, %0": "=a" (*fd));
    _doserrno = 0;
    asm("jnc 1f");
    _doserrno = *fd;
    switch (_doserrno) {
    case 3:
           errno = ENOENT;
           break;
    case 4:
           errno = EMFILE;
           break;
    case 5:
           errno = EACCES;
           break;
    }
    asm("1:");
    return _doserrno;
}

unsigned _dos_close(int fd)
{
    asm("movl %0, %%ebx": : "g" (fd));
    asm("movl $0x3e00, %eax");
    asm("int $0x21": : : "%eax", "%ebx", "%ecx", "%edx", "%esi", "%edi");
    _doserrno = 0;
    asm("jnc 1f");
    asm ("movl %%eax, %0": "=m" (_doserrno));
    if (_doserrno == 6) {
          errno = EBADF;
    }
    asm("1:");
    return _doserrno;
}

static int volumelabel(char *name)
{
    int fd;

    return _dos_creat(name, FA_LABEL, &fd) ? fd : _dos_close(fd);
}

#endif /* __GO32__ || __EMX__ */
