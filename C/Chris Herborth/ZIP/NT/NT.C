/*---------------------------------------------------------------------------

  nt.c                                              Last updated:  24 Jun 94

  WinNT-specific routines for use with Info-ZIP's UnZip 5.1 and later.
  (Borrowed, pilfered and plundered code from OS/2 and MS-DOS versions and
  from ZIP; modified as necessary.)

  Contains:  GetLoadPath()
             opendir()
             readdir()
             closedir()
             mapattr()
             getNTfiletime()
             close_outfile()
             isfloppy()
             IsVolumeOldFAT()
             IsFileNameValid()
             map2fat()
             checkdir()
             do_wild()
             mapname()
             version()

  ---------------------------------------------------------------------------*/

#include <windows.h>
#include "unzip.h"


#define MKDIR(path,mode)   mkdir(path)

struct direct
{
    char    reserved [21];
    char    ff_attrib;
    short   ff_ftime;
    short   ff_fdate;
    long    size;
    char    d_name[MAX_PATH];
    int     d_first;
    HANDLE  d_hFindFile;
};


static int created_dir;         /* used by mapname(), checkdir() */
static int renamed_fullpath;    /* ditto */
static int fnlen;               /* ditto */
static unsigned nLabelDrive;    /* ditto */



#ifdef SFX

/**************************/
/* Function GetLoadPath() */
/**************************/

char *GetLoadPath(void) 
{
#ifdef MSC
    extern char *_pgmptr;
    return _pgmptr;

#else    /* use generic API call */
    GetModuleFileName(NULL, filename, FILNAMSIZ);
    return filename;
#endif

} /* end function GetLoadPath() */





#else /* !SFX */

/**********************/        /* Borrowed from ZIP 2.0 sources             */
/* Function opendir() */        /* Difference: no special handling for       */
/**********************/        /*             hidden or system files.       */

static struct direct *opendir(n)
    const char *n;  /* directory to open */
{
    struct direct *d;       /* malloc'd return value */
    char *p;                /* malloc'd temporary string */
    WIN32_FIND_DATA fd;
    int len = strlen(n);

    /* Start searching for files in the MSDOS directory n */

    if ((d = (struct direct *)malloc(sizeof(struct direct))) == NULL ||
        (p = malloc(strlen(n) + 5)) == NULL)
    {
        if (d != (struct direct *)NULL)
            free((void *)d);
        return (struct direct *)NULL;
    }
    strcpy(p, n);
    if (p[len-1] == ':')
        p[len++] = '.';   /* x: => x:. */
    else if (p[len-1] == '/' || p[len-1] == '\\')
        --len;            /* foo/ => foo */
    strcpy(p+len, "/*");

    if (INVALID_HANDLE_VALUE == (d->d_hFindFile = FindFirstFile(p, &fd))) {
        free((voidp *)d);
        free((voidp *)p);
        return NULL;
    }
    strcpy(d->d_name, fd.cFileName);

    free((voidp *)p);
    d->d_first = 1;
    return d;

} /* end of function opendir() */




/**********************/        /* Borrowed from ZIP 2.0 sources             */
/* Function readdir() */        /* Difference: no special handling for       */
/**********************/        /*             hidden or system files.       */

static struct direct *readdir(d)
    struct direct *d;         /* directory stream from which to read */
{
    /* Return pointer to first or next directory entry, or NULL if end. */

    if ( d->d_first )
        d->d_first = 0;
    else
    {
        WIN32_FIND_DATA fd;

        if ( !FindNextFile(d->d_hFindFile, &fd) )
            return NULL;

        strcpy(d->d_name, fd.cFileName);
    }
    return (struct direct *)d;

} /* end of function readdir() */




/***********************/
/* Function closedir() */       /* Borrowed from ZIP 2.0 sources */
/***********************/

static void closedir(d)
    struct direct *d;         /* directory stream to close */
{
    FindClose(d->d_hFindFile);
    free(d);
}

#endif /* ?SFX */




/**********************/
/* Function mapattr() */
/**********************/

/* Identical to MS-DOS, OS/2 versions.                                       */
/* However, NT has a lot of extra permission stuff, so this function should  */
/*  probably be extended in the future.                                      */

int mapattr()
{
    /* set archive bit (file is not backed up): */
    pInfo->file_attr = (unsigned)(crec.external_file_attributes | 32) & 0xff;
    return 0;

} /* end function mapattr() */




/****************************/      /* Get the file time in a format that */
/* Function getNTfiletime() */      /* can be used by SetFileTime() in NT */
/****************************/

int getNTfiletime(FILETIME *ft)
{
    FILETIME lft;      /* 64-bit value made up of two 32 bit [low & high] */
    WORD wDOSDate;     /* for converting from DOS date to Windows NT      */
    WORD wDOSTime;

    /* Copy and/or convert time and date variables, if necessary;   */
    /* then set the file time/date.                                 */
    wDOSTime = (WORD)lrec.last_mod_file_time;
    wDOSDate = (WORD)lrec.last_mod_file_date;

    /* The DosDateTimeToFileTime() function converts a DOS date/time    */
    /* into a 64 bit Windows NT file time                               */
    if (!DosDateTimeToFileTime(wDOSDate, wDOSTime, &lft))
    {
        printf("DosDateTime failed: %d\n", GetLastError());
        return FALSE;
    }
    if (!LocalFileTimeToFileTime( &lft, ft))
    {
        printf("LocalFileTime failed: %d\n", GetLastError());
        *ft = lft;
    }
    return TRUE;
}




/****************************/
/* Function close_outfile() */
/****************************/

void close_outfile()
{
    FILETIME ft;       /* File time type defined in NT */
    HANDLE hFile;      /* File handle defined in NT    */
    int gotTime;

    /* don't set the time stamp on standard output */
    if (cflag) {
        fclose(outfile);
        return;
    }

    gotTime = getNTfiletime(&ft);

    /* Close the file and then re-open it using the Win32
     * CreateFile call, so that the file can be created
     * with GENERIC_WRITE access, otherwise the SetFileTime
     * call will fail. */
    fclose(outfile);

    hFile = CreateFile(filename, GENERIC_WRITE, 0, NULL, OPEN_EXISTING,
         FILE_ATTRIBUTE_NORMAL, NULL);
    if ( hFile == INVALID_HANDLE_VALUE ) {
        fprintf(stderr, "\nCreateFile error %d when trying set file time\n",
                GetLastError());
    }
    else {
        if (gotTime)
            if (!SetFileTime(hFile, NULL, NULL, &ft))
                printf("\nSetFileTime failed: %d\n", GetLastError());
        CloseHandle(hFile);
    }

    /* HG: I think this could be done in the CreateFile call above - just  */
    /*     replace 'FILE_ATTRIBUTE_NORMAL' with 'pInfo->file_attr & 0x7F'  */
    if (!SetFileAttributes(filename, pInfo->file_attr & 0x7F))
        fprintf(stderr, "\nwarning (%d): could not set file attributes\n",
                GetLastError());

    return;

} /* end function close_outfile() */



/* ============================================================================
*/



/***********************/
/* Function isfloppy() */   /* more precisely, is it removable? */
/***********************/

static int isfloppy(int nDrive)   /* 1 == A:, 2 == B:, etc. */
{
    char rootPathName[4];

    rootPathName[0] = 'A' + nDrive - 1;   /* Build the root path name, */
    rootPathName[1] = ':';                /* e.g. "A:/"                */
    rootPathName[2] = '/';
    rootPathName[3] = '\0';

    return (GetDriveType(rootPathName) == DRIVE_REMOVABLE);

} /* end function isfloppy() */




/*****************************/
/* Function IsVolumeOldFAT() */
/*****************************/

/*
 * Note:  8.3 limits on filenames apply only to old-style FAT filesystems.
 *        More recent versions of Windows (Windows NT 3.5 / Windows 4.0)
 *        can support long filenames (LFN) on FAT filesystems.  Check the
 *        filesystem maximum component length field to detect LFN support.
 *        [GRR:  this routine is only used to determine whether spaces in
 *        filenames are supported...]
 */

static int IsVolumeOldFAT(char *name)
{
    char     *tmp0;
    char      rootPathName[4];
    char      tmp1[MAX_PATH], tmp2[MAX_PATH];
    unsigned  volSerNo, maxCompLen, fileSysFlags;

    if (isalpha(name[0]) && (name[1] == ':'))
        tmp0 = name;
    else
    {
        GetFullPathName(name, MAX_PATH, tmp1, &tmp0);
        tmp0 = &tmp1[0];
    }
    strncpy(rootPathName, tmp0, 3);   /* Build the root path name, */
    rootPathName[3] = '\0';           /* e.g. "A:/"                */

    GetVolumeInformation(rootPathName, tmp1, MAX_PATH, &volSerNo,
                         &maxCompLen, &fileSysFlags, tmp2, MAX_PATH);

    /* Long Filenames (LFNs) are available if the component length is > 12 */
    return maxCompLen <= 12;
/*  return !strncmp(strupr(tmp2), "FAT", 3);   old version */

}




/******************************/
/* Function IsFileNameValid() */
/******************************/

static int IsFileNameValid(char *name)
{
    HFILE    hf;
    OFSTRUCT of;

    hf = OpenFile(name, &of, OF_READ | OF_SHARE_DENY_NONE);
    if (hf == HFILE_ERROR)
        switch (GetLastError())
        {
            case ERROR_INVALID_NAME:
            case ERROR_FILENAME_EXCED_RANGE:
                return FALSE;
            default:
                return TRUE;
        }
    else
        _lclose(hf);
    return TRUE;
}




/**********************/
/* Function map2fat() */        /* Identical to OS/2 version */
/**********************/

void map2fat(pathcomp, pEndFAT)
    char *pathcomp, **pEndFAT;
{
    char *ppc = pathcomp;       /* variable pointer to pathcomp */
    char *pEnd = *pEndFAT;      /* variable pointer to buildpathFAT */
    char *pBegin = *pEndFAT;    /* constant pointer to start of this comp. */
    char *last_dot = NULL;      /* last dot not converted to underscore */
    int dotname = FALSE;        /* flag:  path component begins with dot */
                                /*  ("." and ".." don't count) */
    register unsigned workch;   /* hold the character being tested */


    /* Only need check those characters which are legal in HPFS but not
     * in FAT:  to get here, must already have passed through mapname.
     * (GRR:  oops, small bug--if char was quoted, no longer have any
     * knowledge of that.)  Also must truncate path component to ensure
     * 8.3 compliance...
     */
    while ((workch = (uch)*ppc++) != 0) {
        switch (workch) {
            case '[':
            case ']':
                *pEnd++ = '_';      /* convert brackets to underscores */
                break;

            case '.':
                if (pEnd == *pEndFAT) {   /* nothing appended yet... */
                    if (*ppc == '\0')     /* don't bother appending a */
                        break;            /*  "./" component to the path */
                    else if (*ppc == '.' && ppc[1] == '\0') {   /* "../" */
                        *pEnd++ = '.';    /* add first dot, unchanged... */
                        ++ppc;            /* skip second dot, since it will */
                    } else {              /*  be "added" at end of if-block */
                        *pEnd++ = '_';    /* FAT doesn't allow null filename */
                        dotname = TRUE;   /*  bodies, so map .exrc -> _.exrc */
                    }                     /*  (extra '_' now, "dot" below) */
                } else if (dotname) {     /* found a second dot, but still */
                    dotname = FALSE;      /*  have extra leading underscore: */
                    *pEnd = '\0';         /*  remove it by shifting chars */
                    pEnd = *pEndFAT + 1;  /*  left one space (e.g., .p1.p2: */
                    while (pEnd[1]) {     /*  __p1 -> _p1_p2 -> _p1.p2 when */
                        *pEnd = pEnd[1];  /*  finished) [opt.:  since first */
                        ++pEnd;           /*  two chars are same, can start */
                    }                     /*  shifting at second position] */
                }
                last_dot = pEnd;    /* point at last dot so far... */
                *pEnd++ = '_';      /* convert dot to underscore for now */
                break;

            default:
                *pEnd++ = (char)workch;

        } /* end switch */
    } /* end while loop */

    *pEnd = '\0';                 /* terminate buildpathFAT */

    /* NOTE:  keep in mind that pEnd points to the end of the path
     * component, and *pEndFAT still points to the *beginning* of it...
     * Also note that the algorithm does not try to get too fancy:
     * if there are no dots already, the name either gets truncated
     * at 8 characters or the last underscore is converted to a dot
     * (only if more characters are saved that way).  In no case is
     * a dot inserted between existing characters.
     */
    if (last_dot == NULL) {       /* no dots:  check for underscores... */
        char *plu = strrchr(pBegin, '_');   /* pointer to last underscore */

        if (plu == NULL) {   /* no dots, no underscores:  truncate at 8 chars */
            *pEndFAT += 8;        /* (or could insert '.' and keep 11...?) */
            if (*pEndFAT > pEnd)
                *pEndFAT = pEnd;  /* oops...didn't have 8 chars to truncate */
            else
                **pEndFAT = '\0';
        } else if (MIN(plu - pBegin, 8) + MIN(pEnd - plu - 1, 3) > 8) {
            last_dot = plu;       /* be lazy:  drop through to next if-blk */
        } else if ((pEnd - *pEndFAT) > 8) {
            *pEndFAT += 8;        /* more fits into just basename than if */
            **pEndFAT = '\0';     /*  convert last underscore to dot */
        } else
            *pEndFAT = pEnd;      /* whole thing fits into 8 chars or less */
    }

    if (last_dot != NULL) {       /* one dot (or two, in the case of */
        *last_dot = '.';          /*  "..") is OK:  put it back in */

        if ((last_dot - pBegin) > 8) {
            char *p=last_dot, *q=pBegin+8;
            int i;

            for (i = 0;  (i < 4) && *p;  ++i)  /* too many chars in basename: */
                *q++ = *p++;                   /*  shift .ext left and trun- */
            *q = '\0';                         /*  cate/terminate it */
            *pEndFAT = q;
        } else if ((pEnd - last_dot) > 4) {    /* too many chars in extension */
            *pEndFAT = last_dot + 4;
            **pEndFAT = '\0';
        } else
            *pEndFAT = pEnd;   /* filename is fine; point at terminating zero */
    }
} /* end function map2fat() */




/***********************/       /* Borrowed from OS2.C for UNZIP 5.1.        */
/* Function checkdir() */       /* Difference: no EA stuff                   */
/***********************/       /*             HPFS stuff works on NTFS too  */

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
    static int rootlen = 0;      /* length of rootpath */
    static char *rootpath;       /* user's "extract-to" directory */
    static char *buildpathHPFS;  /* full path (so far) to extracted file, */
    static char *buildpathFAT;   /*  both HPFS/EA (main) and FAT versions */
    static char *endHPFS;        /* corresponding pointers to end of */
    static char *endFAT;         /*  buildpath ('\0') */

#   define FN_MASK   7
#   define FUNCTION  (flag & FN_MASK)



/*---------------------------------------------------------------------------
    APPEND_DIR:  append the path component to the path being built and check
    for its existence.  If doesn't exist and we are creating directories, do
    so for this one; else signal success or error as appropriate.
  ---------------------------------------------------------------------------*/

    if (FUNCTION == APPEND_DIR) {
        char *p = pathcomp;
#ifdef OS2
        int longdirEA;
#endif
        int too_long=FALSE;

        Trace((stderr, "appending dir segment [%s]\n", pathcomp));
        while ((*endHPFS = *p++) != '\0')     /* copy to HPFS filename */
            ++endHPFS;
        if (IsFileNameValid(buildpathHPFS)) {
#ifdef OS2
            longdirEA = FALSE;
#endif
            p = pathcomp;
            while ((*endFAT = *p++) != '\0')  /* copy to FAT filename, too */
                ++endFAT;
        } else {
#ifdef OS2
            longdirEA = TRUE;
#endif
/* GRR:  check error return? */
            map2fat(pathcomp, &endFAT);  /* map, put in FAT fn, update endFAT */
        }

        /* GRR:  could do better check, see if overrunning buffer as we go:
         * check endHPFS-buildpathHPFS after each append, set warning variable
         * if within 20 of FILNAMSIZ; then if var set, do careful check when
         * appending.  Clear variable when begin new path. */

        /* next check:  need to append '/', at least one-char name, '\0' */
        if ((endHPFS-buildpathHPFS) > FILNAMSIZ-3)
            too_long = TRUE;                 /* check if extracting dir? */
        if (stat(buildpathFAT, &statbuf))    /* path doesn't exist */
        {
            if (!create_dirs) {   /* told not to create (freshening) */
                free(buildpathHPFS);
                free(buildpathFAT);
                return 2;         /* path doesn't exist:  nothing to do */
            }
            if (too_long) {   /* GRR:  should allow FAT extraction w/o EAs */
                fprintf(stderr, "checkdir error:  path too long: %s\n",
                  buildpathHPFS);
                fflush(stderr);
                free(buildpathHPFS);
                free(buildpathFAT);
                return 4;         /* no room for filenames:  fatal */
            }
            if (MKDIR(buildpathFAT, 0777) == -1) {   /* create the directory */
                fprintf(stderr, "checkdir error:  can't create %s\n\
                 unable to process %s.\n", buildpathFAT, filename);
                fflush(stderr);
                free(buildpathHPFS);
                free(buildpathFAT);
                return 3;      /* path didn't exist, tried to create, failed */
            }
            created_dir = TRUE;
#ifdef OS2
            /* only set EA if creating directory */
/* GRR:  need trailing '/' before function call? */
            if (longdirEA) {
                int e = SetLongNameEA(buildpathFAT, pathcomp);
                Trace((stderr, "APPEND_DIR:  SetLongNameEA() returns %d\n", e));
            }
#endif
        } else if (!S_ISDIR(statbuf.st_mode)) {
            fprintf(stderr, "checkdir error:  %s exists but is not directory\n\
                 unable to process %s.\n", buildpathFAT, filename);
            fflush(stderr);
            free(buildpathHPFS);
            free(buildpathFAT);
            return 3;          /* path existed but wasn't dir */
        }
        if (too_long) {
            fprintf(stderr, "checkdir error:  path too long: %s\n",
              buildpathHPFS);
            fflush(stderr);
            free(buildpathHPFS);
            free(buildpathFAT);
            return 4;         /* no room for filenames:  fatal */
        }
        *endHPFS++ = '/';
        *endFAT++ = '/';
        *endHPFS = *endFAT = '\0';
        Trace((stderr, "buildpathHPFS now = [%s]\n", buildpathHPFS));
        Trace((stderr, "buildpathFAT now =  [%s]\n", buildpathFAT));
        return 0;

    } /* end if (FUNCTION == APPEND_DIR) */

/*---------------------------------------------------------------------------
    GETPATH:  copy full FAT path to the string pointed at by pathcomp (want
    filename to reflect name used on disk, not EAs; if full path is HPFS,
    buildpathFAT and buildpathHPFS will be identical).  Also free both paths.
  ---------------------------------------------------------------------------*/

    if (FUNCTION == GETPATH) {
        Trace((stderr, "getting and freeing FAT path [%s]\n", buildpathFAT));
        Trace((stderr, "freeing HPFS path [%s]\n", buildpathHPFS));
        strcpy(pathcomp, buildpathFAT);
        free(buildpathFAT);
        free(buildpathHPFS);
        buildpathHPFS = buildpathFAT = endHPFS = endFAT = NULL;
        return 0;
    }

/*---------------------------------------------------------------------------
    APPEND_NAME:  assume the path component is the filename; append it and
    return without checking for existence.
  ---------------------------------------------------------------------------*/

    if (FUNCTION == APPEND_NAME) {
        char *p = pathcomp;
        int error = 0;

        Trace((stderr, "appending filename [%s]\n", pathcomp));
        while ((*endHPFS = *p++) != '\0') {    /* copy to HPFS filename */
            ++endHPFS;
            if ((endHPFS-buildpathHPFS) >= FILNAMSIZ) {
                *--endHPFS = '\0';
                fprintf(stderr, "checkdir warning:  path too long; truncating\n\
                   %s\n                -> %s\n", filename, buildpathHPFS);
                fflush(stderr);
                error = 1;   /* filename truncated */
            }
        }

#ifdef OS2
/* GRR:  how can longnameEA ever be set before this point???  we don't want
 * to save the original name to EAs if user renamed it, do we?
 *
 * if (!longnameEA && ((longnameEA = !IsFileNameValid(name)) != 0))
 */
#endif
        if ( pInfo->vollabel || IsFileNameValid(buildpathHPFS)) {
#ifdef OS2
            longnameEA = FALSE;
#endif
            p = pathcomp;
            while ((*endFAT = *p++) != '\0')   /* copy to FAT filename, too */
                ++endFAT;
        } else {
#ifdef OS2
            longnameEA = TRUE;
            if ((lastpathcomp = (char *)malloc(strlen(pathcomp)+1)) == NULL) {
                fprintf(stderr,
                  "checkdir warning:  can't save longname EA: out of memory\n");
                longnameEA = FALSE;
                error = 1;   /* can't set .LONGNAME extended attribute */
            } else           /* used and freed in close_outfile() */
                strcpy(lastpathcomp, pathcomp);
#endif
            map2fat(pathcomp, &endFAT);  /* map, put in FAT fn, update endFAT */
        }
        Trace((stderr, "buildpathHPFS: %s\nbuildpathFAT:  %s\n",
          buildpathHPFS, buildpathFAT));

        return error;  /* could check for existence, prompt for new name... */

    } /* end if (FUNCTION == APPEND_NAME) */

/*---------------------------------------------------------------------------
    INIT:  allocate and initialize buffer space for the file currently being
    extracted.  If file was renamed with an absolute path, don't prepend the
    extract-to path.
  ---------------------------------------------------------------------------*/

    if (FUNCTION == INIT) {

/* HG: variable not used here */
/*      char *p;              */

        Trace((stderr, "initializing buildpathHPFS and buildpathFAT to "));
        if ((buildpathHPFS = (char *)malloc(fnlen+rootlen+1)) == NULL)
            return 10;
        if ((buildpathFAT = (char *)malloc(fnlen+rootlen+1)) == NULL) {
            free(buildpathHPFS);
            return 10;
        }
        if (pInfo->vollabel) {  /* use root or renamed path, but don't store */
/* GRR:  for network drives, do strchr() and return IZ_VOL_LABEL if not [1] */
            if (renamed_fullpath && pathcomp[1] == ':')
                *buildpathHPFS = ToLower(*pathcomp);
            else if (!renamed_fullpath && rootpath && rootpath[1] == ':')
                *buildpathHPFS = ToLower(*rootpath);
            else {
#ifdef OS2
                ULONG lMap;
                DosQueryCurrentDisk(&nLabelDrive, &lMap);
#else /* NT */
                char tmpN[MAX_PATH], *tmpP;
                if (GetFullPathName(".", MAX_PATH, tmpN, &tmpP) > MAX_PATH)
                { /* by definition of MAX_PATH we should never get here */
                    fprintf(stderr,
                            "checkdir warning: current dir path too long\n");
                    return 1;   /* can't get drive letter */
                }
                nLabelDrive = *tmpN - 'a' + 1;
#endif
                *buildpathHPFS = (char)(nLabelDrive - 1 + 'a');
            }
            nLabelDrive = *buildpathHPFS - 'a' + 1;     /* save for mapname() */
            if (volflag == 0 || *buildpathHPFS < 'a' ||   /* no labels/bogus? */
                (volflag == 1 && !isfloppy(nLabelDrive))) {  /* -$:  no fixed */
                free(buildpathHPFS);
                free(buildpathFAT);
                return IZ_VOL_LABEL;   /* skipping with message */
            }
            *buildpathHPFS = '\0';
        } else if (renamed_fullpath)   /* pathcomp = valid data */
            strcpy(buildpathHPFS, pathcomp);
        else if (rootlen > 0)
            strcpy(buildpathHPFS, rootpath);
        else
            *buildpathHPFS = '\0';
        endHPFS = buildpathHPFS;
        endFAT = buildpathFAT;
        while ((*endFAT = *endHPFS) != '\0') {
            ++endFAT;
            ++endHPFS;
        }
        Trace((stderr, "[%s]\n", buildpathHPFS));
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

/* GRR:  for VMS and TOPS-20, allow either y]z.dir or y.z] forms; fix as
 * appropriate before stat call */

/* GRR:  for MS-DOS and OS/2, necessary to append '.' to path of form "x:"? */

    if (FUNCTION == ROOT) {
        Trace((stderr, "initializing root path to [%s]\n", pathcomp));
        if (pathcomp == NULL) {
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
                if (SSTAT(pathcomp, &statbuf) || !S_ISDIR(statbuf.st_mode))
                {   /* path does not exist */
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
                        fprintf(stderr,
                          "checkdir:  can't create extraction directory: %s\n",
                          pathcomp);
                        fflush(stderr);
                        rootlen = 0;   /* path didn't exist, tried to create, */
                        return 3;  /* failed:  file exists, or need 2+ levels */
                    }
                }
            }
            if ((rootpath = (char *)malloc(rootlen+xtra)) == NULL) {
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




#ifndef SFX

/************************/
/*  Function do_wild()  */   /* identical to OS/2 version */
/************************/

char *do_wild(wildspec)
    char *wildspec;         /* only used first time on a given dir */
{
    static struct direct *dir = NULL;
    static char *dirname, *wildname, matchname[FILNAMSIZ];
    static int firstcall=TRUE, have_dirname, dirnamelen;
    struct direct *file;


    /* Even when we're just returning wildspec, we *always* do so in
     * matchname[]--calling routine is allowed to append four characters
     * to the returned string, and wildspec may be a pointer to argv[].
     */
    if (firstcall) {        /* first call:  must initialize everything */
        firstcall = FALSE;

        /* break the wildspec into a directory part and a wildcard filename */
        if ((wildname = strrchr(wildspec, '/')) == NULL &&
            (wildname = strrchr(wildspec, ':')) == NULL) {
            dirname = ".";
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
            dirname[dirnamelen] = '\0';   /* terminate for strcpy below */
            have_dirname = TRUE;
        }
        Trace((stderr, "do_wild:  dirname = [%s]\n", dirname));

        if ((dir = opendir(dirname)) != NULL) {
            while ((file = readdir(dir)) != NULL) {
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
            dir = NULL;
        }
        Trace((stderr, "do_wild:  opendir(%s) returns NULL\n", dirname));

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
        if (match(file->d_name, wildname, 1)) {   /* 1 == ignore case */
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

#endif /* !SFX */




/************************/
/*  Function mapname()  */
/************************/

/*
 * There are presently two possibilities in OS/2:  the output filesystem is
 * FAT, or it is HPFS.  If the former, we need to map to FAT, obviously, but
 * we *also* must map to HPFS and store that version of the name in extended
 * attributes.  Either way, we need to map to HPFS, so the main mapname
 * routine does that.  In the case that the output file system is FAT, an
 * extra filename-mapping routine is called in checkdir().  While it should
 * be possible to determine the filesystem immediately upon entry to mapname(),
 * it is conceivable that the DOS APPEND utility could be added to OS/2 some-
 * day, allowing a FAT directory to be APPENDed to an HPFS drive/path.  There-
 * fore we simply check the filesystem at each path component.
 *
 * Note that when alternative IFS's become available/popular, everything will
 * become immensely more complicated.  For example, a Minix filesystem would
 * have limited filename lengths like FAT but no extended attributes in which
 * to store the longer versions of the names.  A BSD Unix filesystem would
 * support paths of length 1024 bytes or more, but it is not clear that FAT
 * EAs would allow such long .LONGNAME fields or that OS/2 would properly
 * restore such fields when moving files from FAT to the new filesystem.
 *
 * GRR:  some or all of the following chars should be checked in either
 *       mapname (HPFS) or map2fat (FAT), depending:  ,=^+'"[]<>|\t&
 */

int mapname(renamed)  /* return 0 if no error, 1 if caution (filename trunc), */
    int renamed;      /* 2 if warning (skip file because dir doesn't exist), */
{                     /* 3 if error (skip file), 10 if no memory (skip file), */
                      /* IZ_VOL_LABEL if can't do vol label, IZ_CREATED_DIR */
    char pathcomp[FILNAMSIZ];   /* path-component buffer */
    char *pp, *cp=NULL;         /* character pointers */
    char *lastsemi = NULL;      /* pointer to last semi-colon in pathcomp */
    int quote = FALSE;          /* flag:  next char is literal */
    int error = 0;
    register unsigned workch;   /* hold the character being tested */


/*---------------------------------------------------------------------------
    Initialize various pointers and counters and stuff.
  ---------------------------------------------------------------------------*/

    /* can create path as long as not just freshening, or if user told us */
    create_dirs = (!fflag || renamed);

    created_dir = FALSE;        /* not yet */
    renamed_fullpath = FALSE;
    fnlen = strlen(filename);

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
/* GRR:  watch out for VMS version... */
            cp = (char *)strrchr(filename, '/');
        if (cp == NULL)             /* no '/' or not junking dirs */
            cp = filename;          /* point to internal zipfile-member pathname */
        else
            ++cp;                   /* point to start of last component of path */
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
                if ((error = checkdir(pathcomp, APPEND_DIR)) > 1)
                    return error;
                pp = pathcomp;    /* reset conversion buffer for next piece */
                lastsemi = NULL;  /* leave directory semi-colons alone */
                break;

            case ':':
                *pp++ = '_';      /* drive names not stored in zipfile, */
                break;            /*  so no colons allowed */

            case ';':             /* start of VMS version? */
                lastsemi = pp;    /* remove VMS version later... */
                *pp++ = ';';      /*  but keep semicolon for now */
                break;

            case '\026':          /* control-V quote for special chars */
                quote = TRUE;     /* set flag for next character */
                break;

            case ' ':             /* keep spaces unless specifically */
#ifdef OS2
                if (sflag)        /*  requested to change to underscore */
#else /* NT */
                /* NT cannot create filenames with spaces on FAT volumes */
                if (sflag || IsVolumeOldFAT(filename))
#endif
                    *pp++ = '_';
                else
                    *pp++ = ' ';
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
        pp = lastsemi + 1;        /* semi-colon was kept:  expect #'s after */
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

    if (filename[fnlen-1] == '/') {
        checkdir(filename, GETPATH);
        if (created_dir && QCOND2) {
/* GRR:  trailing '/'?  need to strip or not? */
            fprintf(stdout, "   creating: %-22s\n", filename);
#ifdef OS2
            SetPathInfo(filename, lrec.last_mod_file_date,
                                  lrec.last_mod_file_time, -1);
            if (extra_field)  /* zipfile extra field has extended attributes */
                SetEAs(filename, extra_field);
#else /* NT */
            /* HG: are we setting the date&time on a newly created dir?  */
            /*     Not quite sure how to do this. It does not seem to    */
            /*     be done in the MS-DOS version of mapname().           */
#endif
            return IZ_CREATED_DIR;   /* dir time already set */
        }
        return 2;   /* dir existed already; don't look for data to extract */
    }

    if (*pathcomp == '\0') {
        fprintf(stderr, "mapname:  conversion of %s failed\n", filename);
        return 3;
    }

    checkdir(pathcomp, APPEND_NAME);   /* returns 1 if truncated:  care? */
    checkdir(filename, GETPATH);
    Trace((stderr, "mapname returns with filename = [%s] (error = %d)\n\n",
      filename, error));

    if (pInfo->vollabel) {   /* set the volume label now */

#ifdef OS2

        VOLUMELABEL FSInfoBuf;
/* GRR:  "VOLUMELABEL" defined for IBM C and emx, but haven't checked MSC... */
 
        strcpy(FSInfoBuf.szVolLabel, filename);
        FSInfoBuf.cch = (BYTE)strlen(FSInfoBuf.szVolLabel);
 
        if (QCOND2)
            fprintf(stdout, "labelling %c: %-22s\n", (nLabelDrive + 'a' - 1),
              filename);
        if (DosSetFSInfo(nLabelDrive, FSIL_VOLSER, &FSInfoBuf,
                         sizeof(VOLUMELABEL)))
#else /* NT */

        char drive[3];

        /* Build a drive string, e.g. "b:" */
        drive[0] = 'a' + nLabelDrive - 1;
        drive[1] = ':';
        drive[2] = '\0';
        if (QCOND2)
            fprintf(stdout, "labelling %s %-22s\n", drive, filename);
        if (!SetVolumeLabel(drive, filename))
#endif
        {
            fprintf(stderr, "mapname:  error setting volume label\n");
            return 3;
        }
        return 2;   /* success:  skip the "extraction" quietly */
    }

    return error;

} /* end function mapname() */





#ifndef SFX

/************************/
/*  Function version()  */
/************************/

void version()
{
#if defined(_MSC_VER)
    char buf[80];
#endif

    printf(LoadFarString(CompiledWith),

#ifdef _MSC_VER  /* MSC == VC++, but what about SDK compiler? */
      (sprintf(buf, "Microsoft C %d.%02d ", _MSC_VER/100, _MSC_VER%100), buf),
#  if (_MSC_VER >= 800)
        "(Visual C++)",
#  else
        "(bad version)",
#  endif
#else
      "unknown compiler (SDK?)", "",
#endif

      "Windows NT", " (32-bit)",

#ifdef __DATE__
      " on ", __DATE__
#else
      "", ""
#endif
      );

    return;

} /* end function version() */

#endif /* !SFX */
