/*---------------------------------------------------------------------------

  mac.c

  Macintosh-specific routines for use with Info-ZIP's UnZip 5.1 and later.

  This source file incorporates the contents of what was formerly macfile.c,
  which supported commands (such as mkdir()) not available directly on the
  Mac, and which also determined whether HFS (Hierarchical File System) or
  MFS (Macintosh File System) was in use.

  Contains:  do_wild()
             mapattr()
             mapname()
             checkdir()
             close_outfile()
             version()
             IsHFSDisk()
             MacFSTest()
             macmkdir()
             ResolveMacVol()
             macopen()
             macfopen()
             maccreat()
             macread()
             macwrite()
             macclose()
             maclseek()

  ---------------------------------------------------------------------------*/



#include "unzip.h"

#ifdef MACOS
#ifndef FSFCBLen
#  define FSFCBLen  (*(short *)0x3F6)
#endif

#define read_only   file_attr   /* for readability only */

static short wAppVRefNum;
static long lAppDirID;
int HFSFlag;            /* set if disk has hierarchical file system */

static int created_dir;        /* used in mapname(), checkdir() */
static int renamed_fullpath;   /* ditto */

#define MKDIR(path)     macmkdir(path, gnVRefNum, glDirID)





/**********************/
/* Function do_wild() */   /* for porting:  dir separator; match(ignore_case) */
/**********************/

char *do_wild(wildspec)
    char *wildspec;         /* only used first time on a given dir */
{
    static DIR *dir = NULL;
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
        if ((wildname = strrchr(wildspec, ':')) == NULL) {
            dirname = ":";
            dirnamelen = 1;
            have_dirname = FALSE;
            wildname = wildspec;
        } else {
            ++wildname;     /* point at character after ':' */
            dirnamelen = wildname - wildspec;
            if ((dirname = (char *)malloc(dirnamelen+1)) == NULL) {
                fprintf(stderr, "warning:  can't allocate wildcard buffers\n");
                strcpy(matchname, wildspec);
                return matchname;   /* but maybe filespec was not a wildcard */
            }
            strncpy(dirname, wildspec, dirnamelen);
            dirname[dirnamelen] = '\0';
            have_dirname = TRUE;
        }

        if ((dir = opendir(dirname)) != NULL) {
            while ((file = readdir(dir)) != NULL) {
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

#ifndef THINK_C            /* Think C only matches one at most (for now) */
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
#endif

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
    /* only care about read-only bit, so just look at MS-DOS side of attrs */
    pInfo->read_only = (unsigned)(crec.external_file_attributes & 1);
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
    renamed_fullpath = (renamed && (*filename == '/'));

    if (checkdir((char *)NULL, INIT) == 10)
        return 10;              /* initialize path buffer, unless no memory */

    pp = pathcomp;              /* point to translation buffer */
    if (!(renamed_fullpath || jflag))
        *pp++ = ':';
    *pp = '\0';

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
                if (isprint(workch) || (128 <= workch && workch <= 254))
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

        if ((end-buildpath) > FILNAMSIZ-3)  /* need ':', one-char name, '\0' */
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
            if (MKDIR(buildpath) == -1) {   /* create the directory */
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
        *end++ = ':';
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
        if ((buildpath = (char *)malloc(strlen(filename)+rootlen+2)) == NULL)
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

/* GRR:  for VMS and TOPS-20, allow either y]z.dir or y.z] forms; fix as
 * appropriate before stat call */

/* GRR:  for MS-DOS and OS/2, may need to append '.' to path of form "x:" */

    if (FUNCTION == ROOT) {
        Trace((stderr, "initializing root path to [%s]\n", pathcomp));
        if (pathcomp == NULL) {
            rootlen = 0;
            return 0;
        }
        if ((rootlen = strlen(pathcomp)) > 0) {
            int had_trailing_pathsep=FALSE;

            if (pathcomp[rootlen-1] == ':') {
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
                if (MKDIR(pathcomp) == -1) {
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
            rootpath[rootlen++] = ':';
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
    long m_time;
    DateTimeRec dtr;
    ParamBlockRec pbr;
    HParamBlockRec hpbr;
    OSErr err;


    if (fileno(outfile) == 1)   /* don't attempt to close or set time on stdout */
        return;

    fclose(outfile);

    /*
     * Macintosh bases all file modification times on the number of seconds
     * elapsed since Jan 1, 1904, 00:00:00.  Therefore, to maintain
     * compatibility with MS-DOS archives, which date from Jan 1, 1980,
     * with NO relation to GMT, the following conversions must be made:
     *      the Year (yr) must be incremented by 1980;
     *      and converted to seconds using the Mac routine Date2Secs(),
     *      almost similar in complexity to the Unix version :-)
     *                                     J. Lee
     */

    dtr.year = (((lrec.last_mod_file_date >> 9) & 0x7f) + 1980);
    dtr.month = ((lrec.last_mod_file_date >> 5) & 0x0f);
    dtr.day = (lrec.last_mod_file_date & 0x1f);

    dtr.hour = ((lrec.last_mod_file_time >> 11) & 0x1f);
    dtr.minute = ((lrec.last_mod_file_time >> 5) & 0x3f);
    dtr.second = ((lrec.last_mod_file_time & 0x1f) * 2);

    Date2Secs(&dtr, (unsigned long *)&m_time);
    c2pstr(filename);
    if (HFSFlag) {
        hpbr.fileParam.ioNamePtr = (StringPtr)filename;
        hpbr.fileParam.ioVRefNum = gnVRefNum;
        hpbr.fileParam.ioDirID = glDirID;
        hpbr.fileParam.ioFDirIndex = 0;
        err = PBHGetFInfo(&hpbr, 0L);
        hpbr.fileParam.ioFlMdDat = m_time;
        if ( !fMacZipped )
            hpbr.fileParam.ioFlCrDat = m_time;
        hpbr.fileParam.ioDirID = glDirID;
        if (err == noErr)
            err = PBHSetFInfo(&hpbr, 0L);
        if (err != noErr)
            printf("error:  can't set the time for %s\n", filename);
    } else {
        pbr.fileParam.ioNamePtr = (StringPtr)filename;
        pbr.fileParam.ioVRefNum = pbr.fileParam.ioFVersNum =
          pbr.fileParam.ioFDirIndex = 0;
        err = PBGetFInfo(&pbr, 0L);
        pbr.fileParam.ioFlMdDat = pbr.fileParam.ioFlCrDat = m_time;
        if (err == noErr)
            err = PBSetFInfo(&pbr, 0L);
        if (err != noErr)
            printf("error:  can't set the time for %s\n", filename);
    }

    /* set read-only perms if needed */
    if ((err == noErr) && pInfo->read_only) {
        if (HFSFlag) {
            hpbr.fileParam.ioNamePtr = (StringPtr)filename;
            hpbr.fileParam.ioVRefNum = gnVRefNum;
            hpbr.fileParam.ioDirID = glDirID;
            err = PBHSetFLock(&hpbr, 0);
        } else
            err = SetFLock((ConstStr255Param)filename, 0);
    }
    p2cstr(filename);

} /* end function close_outfile() */





#ifndef SFX

/************************/
/*  Function version()  */
/************************/

void version()
{
#if 0
    char buf[40];
#endif

    printf(LoadFarString(CompiledWith),

#ifdef __GNUC__
      "gcc ", __VERSION__,
#else
#  if 0
      "cc ", (sprintf(buf, " version %d", _RELEASE), buf),
#  else
#  ifdef THINK_C
      "Think C", "",
#  else
#  ifdef MPW
      "MPW C", "",
#  else
      "unknown compiler", "",
#  endif
#  endif
#  endif
#endif

      "MacOS",

#if defined(foobar) || defined(FOOBAR)
      " (Foo BAR)",    /* hardware or OS version */
#else
      "",
#endif /* Foo BAR */

#ifdef __DATE__
      " on ", __DATE__
#else
      "", ""
#endif
      );

} /* end function version() */

#endif /* !SFX */





/************************/
/* Function IsHFSDisk() */
/************************/

static int IsHFSDisk(short wRefNum)
{
    /* get info about the specified volume */
    if (HFSFlag == true) {
        HParamBlockRec    hpbr;
        Str255 temp;
        short wErr;

        hpbr.volumeParam.ioCompletion = 0;
        hpbr.volumeParam.ioNamePtr = temp;
        hpbr.volumeParam.ioVRefNum = wRefNum;
        hpbr.volumeParam.ioVolIndex = 0;
        wErr = PBHGetVInfo(&hpbr, 0);

        if (wErr == noErr && hpbr.volumeParam.ioVFSID == 0
            && hpbr.volumeParam.ioVSigWord == 0x4244) {
                return true;
        }
    }

    return false;
} /* IsHFSDisk */





/************************/
/* Function MacFSTest() */
/************************/

void MacFSTest(int vRefNum)
{
    Str255 st;

    /* is this machine running HFS file system? */
    if (FSFCBLen <= 0) {
        HFSFlag = false;
    }
    else
    {
        HFSFlag = true;
    }

    /* get the file's volume reference number and directory ID */
    if (HFSFlag == true) {
        WDPBRec    wdpb;
        OSErr err = noErr;

        if (vRefNum != 0) {
            wdpb.ioCompletion = false;
            wdpb.ioNamePtr = st;
            wdpb.ioWDIndex = 0;
            wdpb.ioVRefNum = vRefNum;
            err = PBHGetVol(&wdpb, false);

            if (err == noErr) {
                wAppVRefNum = wdpb.ioWDVRefNum;
                lAppDirID = wdpb.ioWDDirID;
            }
        }

        /* is the disk we're using formatted for HFS? */
        HFSFlag = IsHFSDisk(wAppVRefNum);
    }

    return;
} /* mactest */





/***********************/
/* Function macmkdir() */
/***********************/

int macmkdir(char *path, short nVRefNum, long lDirID)
{
    OSErr    err = -1;

    if (path != 0 && strlen(path)<256 && HFSFlag == true) {
        HParamBlockRec    hpbr;
        Str255    st;

        c2pstr(path);
        if ((nVRefNum == 0) && (lDirID == 0))
        {
            hpbr.fileParam.ioNamePtr = st;
            hpbr.fileParam.ioCompletion = NULL;
            err = PBHGetVol((WDPBPtr)&hpbr, false);
            nVRefNum = hpbr.wdParam.ioWDVRefNum;
            lDirID = hpbr.wdParam.ioWDDirID;
        }
        else
        {
            err = noErr;
        }
        if (err == noErr) {
            hpbr.fileParam.ioCompletion = NULL;
            hpbr.fileParam.ioVRefNum = nVRefNum;
            hpbr.fileParam.ioDirID = lDirID;
            hpbr.fileParam.ioNamePtr = (StringPtr)path;
            err = PBDirCreate(&hpbr, false);
        }
        p2cstr(path);
    }

    return (int)err;
} /* macmkdir */





/****************************/
/* Function ResolveMacVol() */
/****************************/

void ResolveMacVol(short nVRefNum, short *pnVRefNum, long *plDirID, StringPtr pst)
{
    if (HFSFlag)
    {
        WDPBRec  wdpbr;
        Str255   st;
        OSErr    err;

        wdpbr.ioCompletion = (ProcPtr)NULL;
        wdpbr.ioNamePtr = st;
        wdpbr.ioVRefNum = nVRefNum;
        wdpbr.ioWDIndex = 0;
        wdpbr.ioWDProcID = 0;
        wdpbr.ioWDVRefNum = 0;
        err = PBGetWDInfo( &wdpbr, false );
        if ( err == noErr )
        {
            if (pnVRefNum)
                *pnVRefNum = wdpbr.ioWDVRefNum;
            if (plDirID)
                *plDirID = wdpbr.ioWDDirID;
            if (pst)
                BlockMove( st, pst, st[0]+1 );
        }
    }
    else
    {
        if (pnVRefNum)
            *pnVRefNum = nVRefNum;
        if (plDirID)
            *plDirID = 0;
        if (pst)
            *pst = 0;
    }
}





/**********************/
/* Function macopen() */
/**********************/

short macopen(char *sz, short nFlags, short nVRefNum, long lDirID)
{
    OSErr   err;
    Str255  st;
    char    chPerms = (!nFlags) ? fsRdPerm : fsRdWrPerm;
    short   nFRefNum;

    c2pstr( sz );
    BlockMove( sz, st, sz[0]+1 );
    p2cstr( sz );
    if (HFSFlag)
    {
        if (nFlags > 1)
            err = HOpenRF( nVRefNum, lDirID, st, chPerms, &nFRefNum);
        else
            err = HOpen( nVRefNum, lDirID, st, chPerms, &nFRefNum);
    }
    else
    {
        /*
         * Have to use PBxxx style calls since the high level
         * versions don't support specifying permissions
         */
        ParamBlockRec    pbr;

        pbr.ioParam.ioNamePtr = st;
        pbr.ioParam.ioVRefNum = gnVRefNum;
        pbr.ioParam.ioVersNum = 0;
        pbr.ioParam.ioPermssn = chPerms;
        pbr.ioParam.ioMisc = 0;
        if (nFlags >1)
            err = PBOpenRF( &pbr, false );
        else
            err = PBOpen( &pbr, false );
        nFRefNum = pbr.ioParam.ioRefNum;
    }
    if ( err || (nFRefNum == 1) )
        return -1;
    else {
        if ( nFlags )
            SetEOF( nFRefNum, 0 );
        return nFRefNum;
    }
}





/***********************/
/* Function macfopen() */
/***********************/

FILE *macfopen(char *filename, char *mode, short nVRefNum, long lDirID)
    {
        short outfd, fDataFork=TRUE;
        MACINFO mi;
        OSErr err;

        fMacZipped = FALSE;
        c2pstr(filename);
        if (extra_field &&
            (lrec.extra_field_length > sizeof(MACINFOMIN)) &&
            (lrec.extra_field_length <= sizeof(MACINFO))) {
            BlockMove(extra_field, &mi, lrec.extra_field_length);
            if ((makeword((uch *)&mi.header) == 1992) &&
                (makeword((uch *)&mi.data) ==
                    lrec.extra_field_length-sizeof(ZIP_EXTRA_HEADER)) &&
                (mi.signature == 'JLEE')) {
                gostCreator = mi.finfo.fdCreator;
                gostType = mi.finfo.fdType;
                fDataFork = (mi.flags & 1) ? TRUE : FALSE;
                fMacZipped = true;
                /* If it was Zipped w/Mac version, the filename has either */
                /* a 'd' or 'r' appended.  Remove the d/r when unzipping */
                filename[0]-=1;
            }
        }
        if (!fMacZipped) {
            if (!aflag)
                gostType = gostCreator = '\?\?\?\?';
            else {
                gostCreator = CREATOR;
                gostType = 'TEXT';
            }
        }
        p2cstr(filename);

        if ((outfd = creat(filename, 0)) != -1) {
            if (fMacZipped) {
                c2pstr(filename);
                if (HFSFlag) {
                    HParamBlockRec   hpbr;

                    hpbr.fileParam.ioNamePtr = (StringPtr)filename;
                    hpbr.fileParam.ioVRefNum = gnVRefNum;
                    hpbr.fileParam.ioDirID = glDirID;
                    hpbr.fileParam.ioFlFndrInfo = mi.finfo;
                    hpbr.fileParam.ioFlCrDat = mi.lCrDat;
                    hpbr.fileParam.ioFlMdDat = mi.lMdDat;
                    err = PBHSetFInfo(&hpbr, 0);
                } else {
                    err = SetFInfo((StringPtr)filename , 0, &mi.finfo);
                }
                p2cstr(filename);
            }
            outfd = open(filename, (fDataFork) ? 1 : 2);
        }

        if (outfd == -1)
            return NULL;
        else
            return (FILE *)outfd;
    }





/***********************/
/* Function maccreat() */
/***********************/

short maccreat(char *sz, short nVRefNum, long lDirID, OSType ostCreator, OSType ostType)
{
    OSErr   err;
    Str255  st;
    FInfo   fi;

    c2pstr( sz );
    BlockMove( sz, st, sz[0]+1 );
    p2cstr( sz );
    if (HFSFlag)
    {
        err = HGetFInfo( nVRefNum, lDirID, st, &fi );
        if (err == fnfErr)
            err = HCreate( nVRefNum, lDirID, st, ostCreator, ostType );
        else if (err == noErr)
        {
            fi.fdCreator = ostCreator;
            fi.fdType = ostType;
            err = HSetFInfo( nVRefNum, lDirID, st, &fi );
        }
    }
    else
    {
        err = GetFInfo( st, nVRefNum, &fi );
        if (err == fnfErr)
            err = Create( st, nVRefNum, ostCreator, ostType );
        else if (err == noErr)
        {
            fi.fdCreator = ostCreator;
            fi.fdType = ostType;
            err = SetFInfo( st, nVRefNum, &fi );
        }
    }
    if (err == noErr)
        return noErr;
    else
        return -1;
}





/**********************/
/* Function macread() */
/**********************/

short macread(short nFRefNum, char *pb, unsigned cb)
{
    long    lcb = cb;

    (void)FSRead( nFRefNum, &lcb, pb );

    return (short)lcb;
}





/***********************/
/* Function macwrite() */
/***********************/

long macwrite(short nFRefNum, char *pb, unsigned cb)
{
    long    lcb = cb;

#ifdef THINK_C
    if ( (nFRefNum == 1) )
        screenDump( pb, lcb );
    else
#endif
        (void)FSWrite( nFRefNum, &lcb, pb );

    return (long)lcb;
}





/***********************/
/* Function macclose() */
/***********************/

short macclose(short nFRefNum)
{
    return FSClose( nFRefNum );
}





/***********************/
/* Function maclseek() */
/***********************/

long maclseek(short nFRefNum, long lib, short nMode)
{
    ParamBlockRec   pbr;

    if (nMode == SEEK_SET)
        nMode = fsFromStart;
    else if (nMode == SEEK_CUR)
        nMode = fsFromMark;
    else if (nMode == SEEK_END)
        nMode = fsFromLEOF;
    pbr.ioParam.ioRefNum = nFRefNum;
    pbr.ioParam.ioPosMode = nMode;
    pbr.ioParam.ioPosOffset = lib;
    (void)PBSetFPos(&pbr, 0);
    return pbr.ioParam.ioPosOffset;
}

#endif /* MACOS */
