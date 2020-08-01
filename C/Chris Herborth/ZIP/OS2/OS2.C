/*---------------------------------------------------------------------------

  os2.c

  OS/2-specific routines for use with Info-ZIP's UnZip 5.1 and later.

  This file contains the OS/2 versions of the file name/attribute/time/etc
  code.  Most or all of the routines which make direct use of OS/2 system
  calls (i.e., the non-lowercase routines) are Kai Uwe Rommel's.  The read-
  dir() suite was written by Michael Rendell and ported to OS/2 by Kai Uwe;
  it is in the public domain.

  Contains:  GetCountryInfo()
             GetFileTime()
             SetPathInfo()
             IsEA()
             SetEAs()
             SizeOfEAs()
             GetLoadPath()
             opendir()
             closedir()
             readdir()
             [ seekdir() ]             not used
             [ telldir() ]             not used
             free_dircontents()
             getdirent()
             IsFileSystemFAT()
             do_wild()
             mapattr()
             mapname()
             checkdir()
             isfloppy()
             IsFileNameValid()
             map2fat()
             SetLongNameEA()
             close_outfile()
             check_for_newer()
             dateformat()
             version()
             InitNLS()
             IsUpperNLS()
             ToLowerNLS()
             StringLower()
             DebugMalloc()

  ---------------------------------------------------------------------------*/


#include "unzip.h"
char *StringLower(char *szArg);

/* local prototypes */
static int   isfloppy        __((int nDrive));
static int   IsFileNameValid __((char *name));
static void  map2fat         __((char *pathcomp, char **pEndFAT));
static int   SetLongNameEA   __((char *name, char *longname));
static void  InitNLS         __((void));

#ifndef __EMX__
#  if (_MSC_VER >= 600) || defined(__IBMC__)
#    include <direct.h>          /* have special MSC/IBM C mkdir prototype */
#  else                          /* own prototype because dir.h conflicts? */
     int mkdir(const char *path);
#  endif
#  define MKDIR(path,mode)   mkdir(path)
#else
#  define MKDIR(path,mode)   mkdir(path,mode)
#endif

#define INCL_NOPM
#define INCL_DOSNLS
#define INCL_DOSPROCESS
#define INCL_DOSDEVICES
#define INCL_DOSDEVIOCTL
#define INCL_DOSERRORS
#include <os2.h>

#ifdef __32BIT__

USHORT DosDevIOCtl32(PVOID pData, USHORT cbData, PVOID pParms, USHORT cbParms,
                     USHORT usFunction, USHORT usCategory, HFILE hDevice)
{
  ULONG ulParmLengthInOut = cbParms, ulDataLengthInOut = cbData;
  return (USHORT) DosDevIOCtl(hDevice, usCategory, usFunction,
                              pParms, cbParms, &ulParmLengthInOut,
                              pData, cbData, &ulDataLengthInOut);
}

#  define DosDevIOCtl DosDevIOCtl32
#else
#  define DosDevIOCtl DosDevIOCtl2
#endif


#define EAID     0x0009


typedef struct
{
  ush nID;
  ush nSize;
  ulg lSize;
}
EAHEADER, *PEAHEADER;


#ifndef __32BIT__

typedef struct
{
  ULONG oNextEntryOffset;
  BYTE fEA;
  BYTE cbName;
  USHORT cbValue;
  CHAR szName[1];
}
FEA2, *PFEA2;

typedef struct
{
  ULONG cbList;
  FEA2 list[1];
}
FEA2LIST, *PFEA2LIST;


#define DosSetPathInfo(p1, p2, p3, p4, p5) \
        DosSetPathInfo(p1, p2, p3, p4, p5, 0)
#define DosQueryPathInfo(p1, p2, p3, p4) \
        DosQPathInfo(p1, p2, p3, p4, 0)
#define DosMapCase DosCaseMap
#define DosQueryCtryInfo DosGetCtryInfo

#endif /* !__32BIT__ */





/*
 * @(#) dir.h 1.4 87/11/06   Public Domain.
 */

#define MAXNAMLEN  256
#define MAXPATHLEN 256

#define A_RONLY    0x01
#define A_HIDDEN   0x02
#define A_SYSTEM   0x04
#define A_LABEL    0x08
#define A_DIR      0x10
#define A_ARCHIVE  0x20


struct direct
{
  ino_t    d_ino;                   /* a bit of a farce */
  int      d_reclen;                /* more farce */
  int      d_namlen;                /* length of d_name */
  char     d_name[MAXNAMLEN + 1];   /* null terminated */
  /* nonstandard fields */
  long     d_size;                  /* size in bytes */
  unsigned d_mode;                  /* MS-DOS or OS/2 file attributes */
  unsigned d_time;
  unsigned d_date;
};

/* The fields d_size and d_mode are extensions by me (Kai Uwe Rommel).  The
 * find_first and find_next calls deliver these data without any extra cost.
 * If these data are needed, the fields save a lot of extra calls to stat()
 * (each stat() again performs a find_first call !).
 */

struct _dircontents
{
  char *_d_entry;
  long _d_size;
  unsigned _d_mode, _d_time, _d_date;
  struct _dircontents *_d_next;
};

typedef struct _dirdesc
{
  int  dd_id;                   /* uniquely identify each open directory */
  long dd_loc;                  /* where we are in directory entry is this */
  struct _dircontents *dd_contents;   /* pointer to contents of dir */
  struct _dircontents *dd_cp;         /* pointer to current position */
}
DIR;


extern DIR *opendir(char *);
extern struct direct *readdir(DIR *);
extern void seekdir(DIR *, long);
extern long telldir(DIR *);
extern void closedir(DIR *);
#define rewinddir(dirp) seekdir(dirp, 0L)

int IsFileSystemFAT(char *dir);
char *StringLower(char *);




/*
 * @(#)dir.c 1.4 87/11/06 Public Domain.
 */

#ifdef __32BIT__
#  define DosFindFirst(p1, p2, p3, p4, p5, p6) \
          DosFindFirst(p1, p2, p3, p4, p5, p6, 1)
#else
#  define DosQueryCurrentDisk DosQCurDisk
#  define DosQueryFSAttach(p1, p2, p3, p4, p5) \
          DosQFSAttach(p1, p2, p3, p4, p5, 0)
#  define DosQueryPathInfo(p1, p2, p3, p4) \
          DosQPathInfo(p1, p2, p3, p4, 0)
#  define DosSetPathInfo(p1, p2, p3, p4, p5) \
          DosSetPathInfo(p1, p2, p3, p4, p5, 0)
#  define DosEnumAttribute(p1, p2, p3, p4, p5, p6, p7) \
          DosEnumAttribute(p1, p2, p3, p4, p5, p6, p7, 0)
#  define DosFindFirst(p1, p2, p3, p4, p5, p6) \
          DosFindFirst(p1, p2, p3, p4, p5, p6, 0)
#  define DosMapCase DosCaseMap
#endif

#ifndef S_IFMT
#  define S_IFMT 0xF000
#endif


#ifdef __WATCOMC__
   unsigned char __near _osmode = OS2_MODE;
#endif

#ifndef SFX
   static char *getdirent(char *);
   static void free_dircontents(struct _dircontents *);
   static int attributes = A_DIR | A_HIDDEN | A_SYSTEM;
#  ifdef __32BIT__
     static HDIR hdir;
     static ULONG count;
     static FILEFINDBUF3 find;
#  else
     static HDIR hdir;            /* GRR:  is there a difference?  HDIR2?? */
     static USHORT count;
     static FILEFINDBUF find;
#  endif
#endif /* !SFX */




static int created_dir;        /* used by mapname(), checkdir() */
static int renamed_fullpath;   /* ditto */
static int fnlen;              /* ditto */
#ifdef __32BIT__
   static ULONG nLabelDrive;   /* ditto */
#else
   static USHORT nLabelDrive;
#endif
static int longnameEA;         /* checkdir(), close_outfile() */
static char *lastpathcomp;     /* ditto */


int GetCountryInfo(void)
{
    COUNTRYINFO ctryi;
    COUNTRYCODE ctryc;
#ifdef __32BIT__
    ULONG cbInfo;
#else
    USHORT cbInfo;
#endif

  ctryc.country = ctryc.codepage = 0;

  if ( DosQueryCtryInfo(sizeof(ctryi), &ctryc, &ctryi, &cbInfo) != NO_ERROR )
    return 0;

  return ctryi.fsDateFmt;
}


long GetFileTime(char *name)
{
#ifdef __32BIT__
  FILESTATUS3 fs;
#else
  FILESTATUS fs;
#endif
  USHORT nDate, nTime;

  if ( DosQueryPathInfo(name, 1, (PBYTE) &fs, sizeof(fs)) )
    return -1;

  nDate = * (USHORT *) &fs.fdateLastWrite;
  nTime = * (USHORT *) &fs.ftimeLastWrite;

  return ((ULONG) nDate) << 16 | nTime;
}


void SetPathInfo(char *path, ush moddate, ush modtime, int flags)
{
  union {
    FDATE fd;               /* system file date record */
    ush zdate;              /* date word */
  } ud;
  union {
    FTIME ft;               /* system file time record */
    ush ztime;              /* time word */
  } ut;
  FILESTATUS fs;
  USHORT nLength;
  char szName[CCHMAXPATH];

  strcpy(szName, path);
  nLength = strlen(szName);
  if (szName[nLength - 1] == '/')
    szName[nLength - 1] = 0;

  if ( DosQueryPathInfo(szName, FIL_STANDARD, (PBYTE) &fs, sizeof(fs)) )
    return;

  ud.zdate = moddate;
  ut.ztime = modtime;
  fs.fdateLastWrite = fs.fdateCreation = ud.fd;
  fs.ftimeLastWrite = fs.ftimeCreation = ut.ft;

  if ( flags != -1 )
    fs.attrFile = flags; /* hidden, system, archive, read-only */

  DosSetPathInfo(szName, FIL_STANDARD, (PBYTE) &fs, sizeof(fs), 0);
}


typedef struct
{
  ULONG cbList;               /* length of value + 22 */
#ifdef __32BIT__
  ULONG oNext;
#endif
  BYTE fEA;                   /* 0 */
  BYTE cbName;                /* length of ".LONGNAME" = 9 */
  USHORT cbValue;             /* length of value + 4 */
  BYTE szName[10];            /* ".LONGNAME" */
  USHORT eaType;              /* 0xFFFD for length-preceded ASCII */
  USHORT eaSize;              /* length of value */
  BYTE szValue[CCHMAXPATH];
}
FEALST;


int IsEA(void *extra_field)
{
  EAHEADER *pEAblock = (PEAHEADER) extra_field;
  return extra_field != NULL && pEAblock -> nID == EAID;
}


void SetEAs(char *path, void *eablock)
{
  EAHEADER *pEAblock = (PEAHEADER) eablock;
#ifdef __32BIT__
  EAOP2 eaop;
  PFEA2LIST pFEA2list;
#else
  EAOP eaop;
  PFEALIST pFEAlist;
  PFEA pFEA;
  PFEA2LIST pFEA2list;
  PFEA2 pFEA2;
  ULONG nLength2;
#endif
  USHORT nLength;
  char szName[CCHMAXPATH];

  if ( !IsEA(eablock) )
    return;

  strcpy(szName, path);
  nLength = strlen(szName);
  if (szName[nLength - 1] == '/')
    szName[nLength - 1] = 0;

  if ( (pFEA2list = (PFEA2LIST) malloc((size_t) pEAblock -> lSize)) == NULL )
    return;

  if ( memextract((char *) pFEA2list, pEAblock -> lSize,
                  (char *) (pEAblock + 1), 
                  pEAblock -> nSize - sizeof(pEAblock -> lSize)) )
  {
    free(pFEA2list);
    return;
  }

#ifdef __32BIT__
  eaop.fpGEA2List = NULL;
  eaop.fpFEA2List = pFEA2list;
#else
  pFEAlist  = (PVOID) pFEA2list;
  pFEA2 = pFEA2list -> list;
  pFEA  = pFEAlist  -> list;

  do
  {
    nLength2 = pFEA2 -> oNextEntryOffset;
    nLength = sizeof(FEA) + pFEA2 -> cbName + 1 + pFEA2 -> cbValue;

    memcpy(pFEA, (PCH) pFEA2 + sizeof(pFEA2 -> oNextEntryOffset), nLength);

    pFEA2 = (PFEA2) ((PCH) pFEA2 + nLength2);
    pFEA = (PFEA) ((PCH) pFEA + nLength);
  }
  while ( nLength2 != 0 );

  pFEAlist -> cbList = (PCH) pFEA - (PCH) pFEAlist;

  eaop.fpGEAList = NULL;
  eaop.fpFEAList = pFEAlist;
#endif

  eaop.oError = 0;
  DosSetPathInfo(szName, FIL_QUERYEASIZE, (PBYTE) &eaop, sizeof(eaop), 0);

  if (!tflag && (qflag < 2))
    PRINTF(" (%ld bytes EA's)", pFEA2list -> cbList);

  free(pFEA2list);
}


ulg SizeOfEAs(void *extra_field)
{
    EAHEADER *pEAblock = (PEAHEADER)extra_field;

    if (extra_field != NULL  &&  makeword((uch *)&pEAblock->nID) == EAID)
        return makelong((uch *)&pEAblock->lSize);

    return 0L;
}





#ifdef SFX

char *GetLoadPath(void) 
{
#ifdef __32BIT__ /* generic for 32-bit API */

  PTIB pptib;
  PPIB pppib;
  char *szPath;

  DosGetInfoBlocks(&pptib, &pppib);
  szPath = pppib -> pib_pchenv;

  while (*szPath) /* find end of process environment */
    szPath = strchr(szPath, 0) + 1;

  return szPath + 1; /* .exe file name follows environment */

#else /* 16-bit, specific for MS C 6.00, note: requires large data model */

  extern char _far *_pgmptr;
  return _pgmptr;

#endif
} /* end function GetLoadPath() */





#else /* !SFX */

DIR *opendir(char *name)
{
  struct stat statb;
  DIR *dirp;
  char c;
  char *s;
  struct _dircontents *dp;
  char nbuf[MAXPATHLEN + 1];
  int len;

  strcpy(nbuf, name);
  if ((len = strlen(nbuf)) == 0)
    return NULL;

  if ( ((c = nbuf[len - 1]) == '\\' || c == '/') && (len > 1) )
  {
    nbuf[len - 1] = 0;
    --len;

    if ( nbuf[len - 1] == ':' )
    {
      strcpy(nbuf+len, "\\.");
      len += 2;
    }
  }
  else
    if ( nbuf[len - 1] == ':' )
    {
      strcpy(nbuf+len, ".");
      ++len;
    }

  /* GRR:  Borland and Watcom C return non-zero on wildcards... < 0 ? */
  if (stat(nbuf, &statb) < 0 || (statb.st_mode & S_IFMT) != S_IFDIR)
  {
    Trace((stderr, "opendir:  stat(%s) returns negative or not directory\n",
      nbuf));
    return NULL;
  }

  if ( (dirp = malloc(sizeof(DIR))) == NULL )
    return NULL;

  if ( nbuf[len - 1] == '.' && (len == 1 || nbuf[len - 2] != '.') )
    strcpy(nbuf+len-1, "*");
  else
    if ( ((c = nbuf[len - 1]) == '\\' || c == '/') && (len == 1) )
      strcpy(nbuf+len, "*");
    else
      strcpy(nbuf+len, "\\*");

  /* len is no longer correct (but no longer needed) */
  Trace((stderr, "opendir:  nbuf = [%s]\n", nbuf));

  dirp -> dd_loc = 0;
  dirp -> dd_contents = dirp -> dd_cp = NULL;

  if ((s = getdirent(nbuf)) == NULL)
    return dirp;

  do
  {
    if (((dp = malloc(sizeof(struct _dircontents))) == NULL) ||
        ((dp -> _d_entry = malloc(strlen(s) + 1)) == NULL)      )
    {
      if (dp)
        free(dp);
      free_dircontents(dirp -> dd_contents);

      return NULL;
    }

    if (dirp -> dd_contents)
    {
      dirp -> dd_cp -> _d_next = dp;
      dirp -> dd_cp = dirp -> dd_cp -> _d_next;
    }
    else
      dirp -> dd_contents = dirp -> dd_cp = dp;

    strcpy(dp -> _d_entry, s);
    dp -> _d_next = NULL;

    dp -> _d_size = find.cbFile;
    dp -> _d_mode = find.attrFile;
    dp -> _d_time = *(unsigned *) &(find.ftimeLastWrite);
    dp -> _d_date = *(unsigned *) &(find.fdateLastWrite);
  }
  while ((s = getdirent(NULL)) != NULL);

  dirp -> dd_cp = dirp -> dd_contents;

  return dirp;
}


void closedir(DIR * dirp)
{
  free_dircontents(dirp -> dd_contents);
  free(dirp);
}


struct direct *readdir(DIR * dirp)
{
  static struct direct dp;

  if (dirp -> dd_cp == NULL)
    return NULL;

  dp.d_namlen = dp.d_reclen =
    strlen(strcpy(dp.d_name, dirp -> dd_cp -> _d_entry));

  dp.d_ino = 0;

  dp.d_size = dirp -> dd_cp -> _d_size;
  dp.d_mode = dirp -> dd_cp -> _d_mode;
  dp.d_time = dirp -> dd_cp -> _d_time;
  dp.d_date = dirp -> dd_cp -> _d_date;

  dirp -> dd_cp = dirp -> dd_cp -> _d_next;
  dirp -> dd_loc++;

  return &dp;
}



#if 0  /* not used in unzip; retained for possibly future use */

void seekdir(DIR * dirp, long off)
{
  long i = off;
  struct _dircontents *dp;

  if (off >= 0)
  {
    for (dp = dirp -> dd_contents; --i >= 0 && dp; dp = dp -> _d_next);

    dirp -> dd_loc = off - (i + 1);
    dirp -> dd_cp = dp;
  }
}


long telldir(DIR * dirp)
{
  return dirp -> dd_loc;
}

#endif /* 0 */



static void free_dircontents(struct _dircontents * dp)
{
  struct _dircontents *odp;

  while (dp)
  {
    if (dp -> _d_entry)
      free(dp -> _d_entry);

    dp = (odp = dp) -> _d_next;
    free(odp);
  }
}


static char *getdirent(char *dir)
{
  int done;
  static int lower;

  if (dir != NULL)
  {                                    /* get first entry */
    hdir = HDIR_SYSTEM;
    count = 1;
    done = DosFindFirst(dir, &hdir, attributes, &find, sizeof(find), &count);
    lower = IsFileSystemFAT(dir);
  }
  else                                 /* get next entry */
    done = DosFindNext(hdir, &find, sizeof(find), &count);

  if (done == 0)
  {
    if ( lower )
      StringLower(find.achName);
    return find.achName;
  }
  else
  {
    DosFindClose(hdir);
    return NULL;
  }
}



int IsFileSystemFAT(char *dir)     /* FAT / HPFS detection */
{
  static USHORT nLastDrive=(USHORT)(-1), nResult;
  ULONG lMap;
  BYTE bData[64], bName[3];
#ifdef __32BIT__
  ULONG nDrive, cbData;
  PFSQBUFFER2 pData = (PFSQBUFFER2) bData;
#else
  USHORT nDrive, cbData;
  PFSQBUFFER pData = (PFSQBUFFER) bData;
#endif

  if ( _osmode == DOS_MODE )
    return TRUE;
  else
  {
    /* We separate FAT and HPFS+other file systems here.
       at the moment I consider other systems to be similar to HPFS,
       i.e. support long file names and case sensitive */

    if ( isalpha(dir[0]) && (dir[1] == ':') )
      nDrive = toupper(dir[0]) - '@';
    else
      DosQueryCurrentDisk(&nDrive, &lMap);

    if ( nDrive == nLastDrive )
      return nResult;

    bName[0] = (char) (nDrive + '@');
    bName[1] = ':';
    bName[2] = 0;

    nLastDrive = nDrive;
    cbData = sizeof(bData);

    if ( !DosQueryFSAttach(bName, 0, FSAIL_QUERYNAME, (PVOID) pData, &cbData) )
      nResult = !strcmp(pData -> szFSDName + pData -> cbName, "FAT");
    else
      nResult = FALSE;

    /* End of this ugly code */
    return nResult;
  }
} /* end function IsFileSystemFAT() */





/************************/
/*  Function do_wild()  */
/************************/

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
                FPRINTF(stderr, "warning:  can't allocate wildcard buffers\n");
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
/*  Function mapattr()  */
/************************/

int mapattr()
{
    /* set archive bit (file is not backed up): */
    pInfo->file_attr = (unsigned)(crec.external_file_attributes | 32) & 0xff;
    return 0;
}





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
    char pathcomp[FILNAMSIZ];    /* path-component buffer */
    char *pp, *cp=(char *)NULL;  /* character pointers */
    char *lastsemi=(char *)NULL; /* pointer to last semi-colon in pathcomp */
    int quote = FALSE;           /* flag:  next char is literal */
    int error = 0;
    register unsigned workch;    /* hold the character being tested */


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
        if (cp == (char *)NULL)     /* no '/' or not junking dirs */
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
                lastsemi = (char *)NULL; /* leave directory semi-colons alone */
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
                if (sflag)        /*  requested to change to underscore */
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
            FPRINTF(stdout, "   creating: %-22s\n", filename);
            if (extra_field)  /* zipfile extra field has extended attributes */
                SetEAs(filename, extra_field);
            SetPathInfo(filename, lrec.last_mod_file_date,
                                  lrec.last_mod_file_time, -1);
            return IZ_CREATED_DIR;   /* dir time already set */
        }
        return 2;   /* dir existed already; don't look for data to extract */
    }

    if (*pathcomp == '\0') {
        FPRINTF(stderr, "mapname:  conversion of %s failed\n", filename);
        return 3;
    }

    checkdir(pathcomp, APPEND_NAME);   /* returns 1 if truncated:  care? */
    checkdir(filename, GETPATH);
    Trace((stderr, "mapname returns with filename = [%s] (error = %d)\n\n",
      filename, error));

    if (pInfo->vollabel) {   /* set the volume label now */
        VOLUMELABEL FSInfoBuf;
/* GRR:  "VOLUMELABEL" defined for IBM C and emx, but haven't checked MSC... */
 
        strcpy(FSInfoBuf.szVolLabel, filename);
        FSInfoBuf.cch = (BYTE)strlen(FSInfoBuf.szVolLabel);
 
        if (QCOND2)
            FPRINTF(stdout, "labelling %c: %-22s\n",
              (char)(nLabelDrive + 'a' - 1), filename);
        if (DosSetFSInfo(nLabelDrive, FSIL_VOLSER, (PBYTE)&FSInfoBuf,
                         sizeof(VOLUMELABEL)))
        {
            FPRINTF(stderr, "mapname:  error setting volume label\n");
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
        int longdirEA, too_long=FALSE;

        Trace((stderr, "appending dir segment [%s]\n", pathcomp));
        while ((*endHPFS = *p++) != '\0')     /* copy to HPFS filename */
            ++endHPFS;
        if (IsFileNameValid(buildpathHPFS)) {
            longdirEA = FALSE;
            p = pathcomp;
            while ((*endFAT = *p++) != '\0')  /* copy to FAT filename, too */
                ++endFAT;
        } else {
            longdirEA = TRUE;
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
#ifdef MSC /* MSC 6.00 bug:  stat(non-existent-dir) == 0 [exists!] */
        if (GetFileTime(buildpathFAT) == -1 || stat(buildpathFAT, &statbuf))
#else
        if (stat(buildpathFAT, &statbuf))    /* path doesn't exist */
#endif
        {
            if (!create_dirs) {   /* told not to create (freshening) */
                free(buildpathHPFS);
                free(buildpathFAT);
                return 2;         /* path doesn't exist:  nothing to do */
            }
            if (too_long) {   /* GRR:  should allow FAT extraction w/o EAs */
                FPRINTF(stderr, "checkdir error:  path too long: %s\n",
                  buildpathHPFS);
                fflush(stderr);
                free(buildpathHPFS);
                free(buildpathFAT);
                return 4;         /* no room for filenames:  fatal */
            }
            if (MKDIR(buildpathFAT, 0777) == -1) {   /* create the directory */
                FPRINTF(stderr, "checkdir error:  can't create %s\n\
                 unable to process %s.\n", buildpathFAT, filename);
                fflush(stderr);
                free(buildpathHPFS);
                free(buildpathFAT);
                return 3;      /* path didn't exist, tried to create, failed */
            }
            created_dir = TRUE;
            /* only set EA if creating directory */
/* GRR:  need trailing '/' before function call? */
            if (longdirEA) {
#ifdef DEBUG
                int e =
#endif
                  SetLongNameEA(buildpathFAT, pathcomp);
                Trace((stderr, "APPEND_DIR:  SetLongNameEA() returns %d\n", e));
            }
        } else if (!S_ISDIR(statbuf.st_mode)) {
            FPRINTF(stderr, "checkdir error:  %s exists but is not directory\n\
                 unable to process %s.\n", buildpathFAT, filename);
            fflush(stderr);
            free(buildpathHPFS);
            free(buildpathFAT);
            return 3;          /* path existed but wasn't dir */
        }
        if (too_long) {
            FPRINTF(stderr, "checkdir error:  path too long: %s\n",
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
        buildpathHPFS = buildpathFAT = endHPFS = endFAT = (char *)NULL;
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
                FPRINTF(stderr, "checkdir warning:  path too long; truncating\n\
                   %s\n                -> %s\n", filename, buildpathHPFS);
                fflush(stderr);
                error = 1;   /* filename truncated */
            }
        }

/* GRR:  how can longnameEA ever be set before this point???  we don't want
 * to save the original name to EAs if user renamed it, do we?
 *
 * if (!longnameEA && ((longnameEA = !IsFileNameValid(name)) != 0))
 */
        if (pInfo->vollabel || IsFileNameValid(buildpathHPFS)) {
            longnameEA = FALSE;
            p = pathcomp;
            while ((*endFAT = *p++) != '\0')   /* copy to FAT filename, too */
                ++endFAT;
        } else {
            longnameEA = TRUE;
            if ((lastpathcomp = (char *)malloc(strlen(pathcomp)+1)) ==
                (char *)NULL)
            {
                FPRINTF(stderr,
                  "checkdir warning:  can't save longname EA: out of memory\n");
                longnameEA = FALSE;
                error = 1;   /* can't set .LONGNAME extended attribute */
            } else           /* used and freed in close_outfile() */
                strcpy(lastpathcomp, pathcomp);
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
        Trace((stderr, "initializing buildpathHPFS and buildpathFAT to "));
        if ((buildpathHPFS = (char *)malloc(fnlen+rootlen+1)) == (char *)NULL)
            return 10;
        if ((buildpathFAT = (char *)malloc(fnlen+rootlen+1)) == (char *)NULL) {
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
                ULONG lMap;
                DosQueryCurrentDisk(&nLabelDrive, &lMap);
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
#ifdef MSC      /* MSC 6.00 bug:  stat(non-existent-dir) == 0 [exists!] */
                if (GetFileTime(pathcomp) == -1 || 
                    SSTAT(pathcomp, &statbuf) || !S_ISDIR(statbuf.st_mode))
#else
                if (SSTAT(pathcomp, &statbuf) || !S_ISDIR(statbuf.st_mode))
#endif
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
                        FPRINTF(stderr,
                          "checkdir:  can't create extraction directory: %s\n",
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
/* Function isfloppy() */   /* more precisely, is it removable? */
/***********************/

static int isfloppy(nDrive)
    int nDrive;   /* 1 == A:, 2 == B:, etc. */
{
    uch ParmList[1] = {0};
    uch DataArea[1] = {0};
    char Name[3];
    HFILE handle;
#ifdef __32BIT__
    ULONG rc;
    ULONG action;
#else
    USHORT rc;
    UINT action;
#endif


    Name[0] = (char) (nDrive + 'A' - 1);
    Name[1] = ':';
    Name[2] = 0;

    rc = DosOpen(Name, &handle, &action, 0L, FILE_NORMAL, FILE_OPEN,
                 OPEN_FLAGS_DASD | OPEN_FLAGS_FAIL_ON_ERROR |
                 OPEN_ACCESS_READONLY | OPEN_SHARE_DENYNONE, 0L);

    if (rc == ERROR_NOT_READY)   /* must be removable */
      return TRUE;
    else if (rc) {   /* other error:  do default a/b heuristic instead */
      Trace((stderr, "error in DosOpen(DASD):  guessing...\n", rc));
      return (nDrive == 1 || nDrive == 2)? TRUE : FALSE;
    }

    rc = DosDevIOCtl(DataArea, sizeof(DataArea), ParmList, sizeof(ParmList),
                     DSK_BLOCKREMOVABLE, IOCTL_DISK, handle);
    DosClose(handle);

    if (rc) {   /* again, just check for a/b */
        Trace((stderr, "error in DosDevIOCtl category IOCTL_DISK, function "
          "DSK_BLOCKREMOVABLE\n  (rc = 0x%04x):  guessing...\n", rc));
        return (nDrive == 1 || nDrive == 2)? TRUE : FALSE;
    } else {
        return DataArea[0] ? FALSE : TRUE;
    }
} /* end function isfloppy() */





int IsFileNameValid(char *name)
{
  HFILE hf;
#ifdef __32BIT__
  ULONG uAction;
#else
  USHORT uAction;
#endif

  switch( DosOpen(name, &hf, &uAction, 0, 0, FILE_OPEN,
                  OPEN_ACCESS_READONLY | OPEN_SHARE_DENYNONE, 0) )
  {
  case ERROR_INVALID_NAME:
  case ERROR_FILENAME_EXCED_RANGE:
    return FALSE;
  case NO_ERROR:
    DosClose(hf);
  default:
    return TRUE;
  }
}





/**********************/
/* Function map2fat() */
/**********************/

void map2fat(pathcomp, pEndFAT)
    char *pathcomp, **pEndFAT;
{
    char *ppc = pathcomp;          /* variable pointer to pathcomp */
    char *pEnd = *pEndFAT;         /* variable pointer to buildpathFAT */
    char *pBegin = *pEndFAT;       /* constant pointer to start of this comp. */
    char *last_dot = (char *)NULL; /* last dot not converted to underscore */
    int dotname = FALSE;           /* flag:  path component begins with dot */
                                   /*  ("." and ".." don't count) */
    register unsigned workch;      /* hold the character being tested */


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
    if (last_dot == (char *)NULL) {  /* no dots:  check for underscores... */
        char *plu = strrchr(pBegin, '_');    /* pointer to last underscore */

        if (plu == (char *)NULL) { /* no dots, no underscores:  truncate at 8 */
            *pEndFAT += 8;        /* chars (or could insert '.' and keep 11?) */
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

    if (last_dot != (char *)NULL) {   /* one dot (or two, in the case of */
        *last_dot = '.';              /*  "..") is OK:  put it back in */

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





int SetLongNameEA(char *name, char *longname)
{
  EAOP eaop;
  FEALST fealst;

  eaop.fpFEAList = (PFEALIST) &fealst;
  eaop.fpGEAList = NULL;
  eaop.oError = 0;

  strcpy(fealst.szName, ".LONGNAME");
  strcpy(fealst.szValue, longname);

  fealst.cbList  = sizeof(fealst) - CCHMAXPATH + strlen(fealst.szValue);
  fealst.cbName  = (BYTE) strlen(fealst.szName);
  fealst.cbValue = sizeof(USHORT) * 2 + strlen(fealst.szValue);

#ifdef __32BIT__
  fealst.oNext   = 0;
#endif
  fealst.fEA     = 0;
  fealst.eaType  = 0xFFFD;
  fealst.eaSize  = strlen(fealst.szValue);

  return DosSetPathInfo(name, FIL_QUERYEASIZE,
                        (PBYTE) &eaop, sizeof(eaop), 0);
}





/****************************/
/* Function close_outfile() */
/****************************/

void close_outfile()   /* only for extracted files, not directories */
{
    fclose(outfile);

    /* set extra fields, both stored-in-zipfile and .LONGNAME flavors */
    if (extra_field)
        SetEAs(filename, extra_field);

    if (longnameEA) {
#ifdef DEBUG
        int e =
#endif
          SetLongNameEA(filename, lastpathcomp);
        Trace((stderr, "close_outfile:  SetLongNameEA() returns %d\n", e));
        free(lastpathcomp);
    }

    /* set date/time and permissions */
    SetPathInfo(filename, lrec.last_mod_file_date,
                          lrec.last_mod_file_time, pInfo->file_attr);

} /* end function close_outfile() */





/******************************/
/* Function check_for_newer() */
/******************************/

int check_for_newer(filename)   /* return 1 if existing file newer or equal; */
    char *filename;             /*  0 if older; -1 if doesn't exist yet */
{
    long existing, archive;

    if ((existing = GetFileTime(filename)) == -1)
        return DOES_NOT_EXIST;
    archive = ((long) lrec.last_mod_file_date) << 16 | lrec.last_mod_file_time;

    return (existing >= archive);
}





#ifndef SFX

/*************************/
/* Function dateformat() */
/*************************/

int dateformat()
{
/*-----------------------------------------------------------------------------
  For those operating systems which support it, this function returns a value
  which tells how national convention says that numeric dates are displayed.
  Return values are DF_YMD, DF_DMY and DF_MDY.
 -----------------------------------------------------------------------------*/

    switch (GetCountryInfo()) {
        case 0:
            return DF_MDY;
        case 1:
            return DF_DMY;
        case 2:
            return DF_YMD;
    }
    return DF_MDY;   /* default if error */

} /* end function dateformat() */





/************************/
/*  Function version()  */
/************************/

void version()
{
#if defined(__IBMC__) || defined(__WATCOMC__) || defined(_MSC_VER)
    char buf[80];
#endif

    PRINTF(LoadFarString(CompiledWith),

#ifdef __GNUC__
#  ifdef __EMX__  /* __EMX__ is defined as "1" only (sigh) */
      "emx+gcc ", __VERSION__,
#  else
      "gcc/2 ", __VERSION__,
#  endif
#else
#ifdef __IBMC__
      "IBM C Set/2", (sprintf(buf, " %d.%02d", __IBMC__/100,__IBMC__%100), buf),
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
#    if (__BORLANDC__ == 0x0200)
        " 2.0",
#    else
#    if (__BORLANDC__ == 0x0400)
        " 3.0",
#    else
#    if (__BORLANDC__ == 0x0410)
        " 3.1",
#    else
        " later than 3.1",
#    endif
#    endif
#    endif
#    endif
#  else
      "Turbo C",
#    if (__TURBOC__ >= 661)
       "++ 1.0 or later",
#    else
#    if (__TURBOC__ == 661)
       " 3.0?",
#    else
#    if (__TURBOC__ == 397)
       " 2.0",
#    else
       " 1.0 or 1.5?",
#    endif
#    endif
#    endif
#  endif
#else
#ifdef MSC
      "Microsoft C ",
#  ifdef _MSC_VER
      (sprintf(buf, "%d.%02d", _MSC_VER/100, _MSC_VER%100), buf),
#  else
      "5.1 or earlier",
#  endif
#else
      "unknown compiler", "",
#endif /* MSC */
#endif /* __TURBOC__ */
#endif /* __WATCOMC__ */
#endif /* __IBMC__ */
#endif /* __GNUC__ */

      "OS/2",

/* GRR:  does IBM C/2 identify itself as IBM rather than Microsoft? */
#if (defined(MSC) || (defined(__WATCOMC__) && !defined(__386__)))
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
#else
      " 2.x (32-bit)",
#endif

#ifdef __DATE__
      " on ", __DATE__
#else
      "", ""
#endif
      );

    /* temporary debugging code for Borland compilers only */
#ifdef __TURBOC__
    PRINTF("\t(__TURBOC__ = 0x%04x = %d)\n", __TURBOC__, __TURBOC__);
#ifdef __BORLANDC__
    PRINTF("\t(__BORLANDC__ = 0x%04x)\n", __BORLANDC__);
#else
    PRINTF("\tdebug(__BORLANDC__ not defined)\n");
#endif
#ifdef __TCPLUSPLUS__
    PRINTF("\t(__TCPLUSPLUS__ = 0x%04x)\n", __TCPLUSPLUS__);
#else
    PRINTF("\tdebug(__TCPLUSPLUS__ not defined)\n");
#endif
#ifdef __BCPLUSPLUS__
    PRINTF("\t(__BCPLUSPLUS__ = 0x%04x)\n\n", __BCPLUSPLUS__);
#else
    PRINTF("\tdebug(__BCPLUSPLUS__ not defined)\n\n");
#endif
#endif /* __TURBOC__ */

} /* end function version() */

#endif /* !SFX */





static unsigned char cUpperCase[256], cLowerCase[256];
static BOOL bInitialized;

/* Initialize the tables of upper- and lowercase characters, including
   handling of country-dependent characters. */

static void InitNLS(void)
{
  unsigned nCnt, nU;
  COUNTRYCODE cc;

  bInitialized = TRUE;

  for ( nCnt = 0; nCnt < 256; nCnt++ )
    cUpperCase[nCnt] = cLowerCase[nCnt] = (unsigned char) nCnt;

  cc.country = cc.codepage = 0;
  DosMapCase(sizeof(cUpperCase), &cc, (PCHAR) cUpperCase);

  for ( nCnt = 0; nCnt < 256; nCnt++ )
  {
    nU = cUpperCase[nCnt];
    if (nU != nCnt && cLowerCase[nU] == (unsigned char) nU)
      cLowerCase[nU] = (unsigned char) nCnt;
  }

  for ( nCnt = 'A'; nCnt <= 'Z'; nCnt++ )
    cLowerCase[nCnt] = (unsigned char) (nCnt - 'A' + 'a');
}


int IsUpperNLS(int nChr)
{
  if (!bInitialized)
    InitNLS();
  return (cUpperCase[nChr] == (unsigned char) nChr);
}


int ToLowerNLS(int nChr)
{
  if (!bInitialized)
    InitNLS();
  return cLowerCase[nChr];
}


char *StringLower(char *szArg)
{
  unsigned char *szPtr;

  if (!bInitialized)
    InitNLS();
  for ( szPtr = szArg; *szPtr; szPtr++ )
    *szPtr = cLowerCase[*szPtr];
  return szArg;
}


#if defined(__IBMC__) && defined(__DEBUG_ALLOC__)
void DebugMalloc(void)
{
  _dump_allocated(0); /* print out debug malloc memory statistics */
}
#endif
