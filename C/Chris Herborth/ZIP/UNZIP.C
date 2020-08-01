/*---------------------------------------------------------------------------

  unzip.c

  UnZip - a zipfile extraction utility.  See below for make instructions, or
  read the comments in Makefile and the various Contents files for more de-
  tailed explanations.  To report a bug, send a *complete* description to
  zip-bugs@wkuvx1.wku.edu; include machine type, operating system and ver-
  sion, compiler and version, and reasonably detailed error messages or prob-
  lem report.  To join Info-ZIP, see the instructions in README.

  UnZip 5.x is a greatly expanded and partially rewritten successor to 4.x,
  which in turn was almost a complete rewrite of version 3.x.  For a detailed
  revision history, see UnzpHist.zip at quest.jpl.nasa.gov.  For a list of
  the many (near infinite) contributors, see "CONTRIBS" in the UnZip source
  distribution.

  ---------------------------------------------------------------------------

  [from original zipinfo.c]

  This program reads great gobs of totally nifty information, including the
  central directory stuff, from ZIP archives ("zipfiles" for short).  It
  started as just a testbed for fooling with zipfiles, but at this point it
  is actually a useful utility.  It also became the basis for the rewrite of
  UnZip (3.16 -> 4.0), using the central directory for processing rather than
  the individual (local) file headers.

  As of ZipInfo v2.0 and UnZip v5.1, the two programs are combined into one.
  If the executable is named "unzip" (or "unzip.exe", depending), it behaves
  like UnZip by default; if it is named "zipinfo" or "ii", it behaves like
  ZipInfo.  The ZipInfo behavior may also be triggered by use of unzip's -Z
  option; for example, "unzip -Z [zipinfo_options] archive.zip".

  Another dandy product from your buddies at Newtware!

  Author:  Greg Roelofs, newt@uchicago.edu, 23 August 1990 -> ... 1994

  ---------------------------------------------------------------------------

  Version:  unzip511.{tar.Z | zip | zoo} for Unix, VMS, OS/2, MS-DOS, Windows,
              Windows NT, Macintosh, Amiga, Atari, Human68K and TOPS-20.  De-
              cryption requires sources in zcrypt22.zip, and Windows (not NT)
              support requires sources in wunz20sr.zip (not up to date).  See
              accompanying file "Where" in the main source distribution for
              ftp, uucp and mail-server sites.

  Copyrights:  see accompanying file "COPYING" in UnZip source distribution.

  ---------------------------------------------------------------------------*/



#include "unzip.h"        /* includes, typedefs, macros, prototypes, etc. */
#include "crypt.h"        /* for "unzip -v" diagnostics only */
#include "version.h"
#ifdef MSWIN
#  include "wizunzip.h"
#endif



/**********************/
/*  Global Variables  */
/**********************/

int zipinfo_mode;     /* behave like ZipInfo or like normal UnZip? */

int aflag=0;          /* -a: do ASCII-EBCDIC and/or end-of-line translation */
int cflag=0;          /* -c: output to stdout */
int C_flag=0;         /* -C: match filenames case-insensitively */
int dflag=0;          /* -d: all args are files/dirs to be extracted */
int fflag=0;          /* -f: "freshen" (extract only newer files) */
int hflag=0;          /* -h: header line (zipinfo) */
int jflag=0;          /* -j: junk pathnames (unzip) */
int lflag=(-1);       /* -12slmv: listing format (zipinfo) */
int L_flag=0;         /* -L: convert filenames from some OSes to lowercase */
int overwrite_none=0; /* -n: never overwrite files (no prompting) */
int overwrite_all=0;  /* -o: OK to overwrite files without prompting */
int force_flag=0;     /* (shares -o for now): force to override errors, etc. */
int qflag=0;          /* -q: produce a lot less output */
#ifdef DOS_NT_OS2
   int sflag=0;       /* -s: convert filename spaces (blanks) to underscores */
   int volflag=0;     /* -$: extract volume labels */
#endif
int tflag=0;          /* -t: test (unzip) or totals line (zipinfo) */
int T_flag=0;         /* -T: decimal time format (zipinfo) */
int uflag=0;          /* -u: "update" (extract only newer & brand-new files) */
int vflag=0;          /* -v: (verbosely) list directory */
int V_flag=0;         /* -V: don't strip VMS version numbers */
#ifdef VMS
   int secinf=0;      /* -X: keep owner/protection */
#endif
int zflag=0;          /* -z: display the zipfile comment (only, for unzip) */

int filespecs;        /* number of real file specifications to be matched */
int xfilespecs;       /* number of excluded filespecs to be matched */
int process_all_files = 0;
int create_dirs;      /* used by main(), mapname(), checkdir() */
int extract_flag;

LONGINT real_ecrec_offset, expect_ecrec_offset;

long csize;           /* used by list_files(), ReadByte(): must be signed */
long ucsize;          /* used by list_files(), unReduce(), explode() */
long used_csize;      /* used by extract_or_test_member(), explode() */

static char *fnames[2] = {"*", NULL};   /* default filenames vector */
char **pfnames = fnames, **pxnames = &fnames[1];
char near sig[5];
char near answerbuf[10];

min_info info[DIR_BLKSIZ], *pInfo=info;

/*---------------------------------------------------------------------------
    unreduce/unshrink/explode/inflate working storage and globals:
  ---------------------------------------------------------------------------*/

union work area;              /* see unzip.h for the definition of work */
ulg crc32val;

ush near mask_bits[] = {
    0x0000,
    0x0001, 0x0003, 0x0007, 0x000f, 0x001f, 0x003f, 0x007f, 0x00ff,
    0x01ff, 0x03ff, 0x07ff, 0x0fff, 0x1fff, 0x3fff, 0x7fff, 0xffff
};

/*---------------------------------------------------------------------------
    Input file variables:
  ---------------------------------------------------------------------------*/

uch *inbuf, *inptr;             /* input buffer (any size is OK) and pointer */
int incnt;

ulg bitbuf;
int bits_left;
boolean zipeof;

char *wildzipfn, *zipfn;    /* GRR:  MSWIN:  must nuke any malloc'd zipfn... */
#ifdef SFX
   char *argv0;                 /* used for NT and EXE_EXTENSION */
#endif

int zipfd;                      /* zipfile file handle */
LONGINT ziplen;

uch *hold;
char near local_hdr_sig[5];     /* initialize signatures at runtime so unzip */
char near central_hdr_sig[5];   /*  executable won't look like a zipfile */
char near end_central_sig[5];
/* char extd_local_sig[5];  NOT USED YET */

cdir_file_hdr crec;             /* used in unzip.c, extract.c, misc.c */
local_file_hdr lrec;            /* used in unzip.c, extract.c */
ecdir_rec ecrec;                /* used in unzip.c, extract.c */
struct stat statbuf;            /* used by main, mapname, check_for_newer */

LONGINT cur_zipfile_bufstart;   /* extract_or_test_files, readbuf, ReadByte */
LONGINT extra_bytes = 0;        /* used in unzip.c, misc.c */

uch *extra_field = (uch *)NULL; /* used by VMS, Mac and OS/2 versions */

#ifdef MACOS
   short  gnVRefNum;
   long  glDirID;
   OSType  gostCreator;
   OSType  gostType;
   boolean  fMacZipped;
   boolean  macflag;
   CursHandle  rghCursor[4];    /* status cursors */
   short  giCursor = 0;
#endif

/*---------------------------------------------------------------------------
    Output stream variables:
  ---------------------------------------------------------------------------*/

int mem_mode = 0;
int disk_full;
#ifdef SYMLINKS
   int symlnk;
#endif
FILE *outfile;
uch *outbuf;
uch *outptr;
ulg outcnt;                     /* number of chars stored in outbuf */
#ifdef SMALL_MEM
   uch *outbuf2;                /* initialized in main() (never changes) */
#else
   uch *outbuf2 = (uch *)NULL;  /* malloc'd ONLY if unshrink and -a */
#endif
#ifdef MSWIN
   char *filename;
#else
   char near filename[FILNAMSIZ];  /* also used by NT for temporary SFX path */
#endif





/********************/
/*  Global strings  */
/********************/

char Far UnzipVersion[] = UZ_VERSION;   /* now defined in version.h */
#ifndef NO_ZIPINFO
   char Far ZipinfoVersion[] = ZI_VERSION;
#endif

char Far EndSigMsg[] = "\nnote:\
  didn't find end-of-central-dir signature at end of central dir.\n";
char Far CentSigMsg[] =
  "error:  expected central file header signature not found (file #%u).\n";
char Far SeekMsg[] =
  "error [%s]:  attempt to seek before beginning of zipfile\n%s";
char Far FilenameNotMatched[] = "caution: filename not matched:  %s\n";
char Far ExclFilenameNotMatched[] =
  "caution: excluded filename not matched:  %s\n";

#ifndef SFX
  char Far CompiledWith[] = "Compiled with %s%s for %s%s%s%s.\n\n";
#endif

#ifdef VMS
  char Far ReportMsg[] = "\
  (please check that you have transferred or created the zipfile in the\n\
  appropriate BINARY mode--this includes ftp, Kermit, AND unzip'd zipfiles)\n";
#else
  char Far ReportMsg[] = "\
  (please check that you have transferred or created the zipfile in the\n\
  appropriate BINARY mode and that you have compiled unzip properly)\n";
#endif

/*******************/
/*  Local strings  */
/*******************/

#ifndef SFX
   static char Far EnvUnZip[] = ENV_UNZIP;
   static char Far EnvUnZip2[] = ENV_UNZIP2;
   static char Far EnvZipInfo[] = ENV_ZIPINFO;
   static char Far EnvZipInfo2[] = ENV_ZIPINFO2;
   static char Far NotExtracting[] = "caution:  not extracting; -d ignored\n";
   static char Far MustGiveExdir[] =
     "error:  must specify directory to which to extract with -d option\n";
#endif

static char Far CentDirTooLong[] =
  "error [%s]:  reported length of central directory is\n\
  %d bytes too long (Atari STZip zipfile?  J.H.Holm ZIPSPLIT 1.1\n\
  zipfile?).  Compensating...\n";
static char Far InvalidOptionsMsg[] = "error:\
  -fn or any combination of -c, -l, -p, -t, -u and -v options invalid\n";
static char Far IgnoreOOptionMsg[] =
  "caution:  both -n and -o specified; ignoring -o\n";
static char Far CantAllocateBuffers[] =
  "error:  can't allocate unzip buffers\n";

/* usage() strings */
#ifndef VMSCLI
#ifndef SFX
#ifdef VMS
    static char Far Example2[] = "vms.c";
    static char Far Example1[] = 
"unzip \"-V\" foo \"Bar\" => must quote uppercase options and filenames in VMS";
#else
    static char Far Example2[] = "ReadMe";
    static char Far Example1[] =
"unzip -p foo | more  => send contents of foo.zip via pipe into program more";
#endif /* ?VMS */

#ifdef DOS_NT_OS2
    static char Far loc_str[] = " -$  label removables (-$$ => fixed disks)";
    static char Far loc2str[] = "\
                                             -s  spaces in filenames => '_'\n";
#else /* !DOS_NT_OS2 */
#ifdef VMS
    static char Far loc_str[] = "\"-X\" restore owner/protection info";
    static char Far loc2str[] = "\n";
#else
    static char Far loc_str[] = "";   /* Unix, Amiga, Mac, etc. */
 /* char Far loc_str[] = " -X  restore UID/GID info";    Unix version, in 5.2 */
    static char Far loc2str[] = "";
#endif /* ?VMS */
#endif /* ?DOS_NT_OS2 */
#endif /* !SFX */

#ifndef NO_ZIPINFO
#ifdef VMSWILD
   static char Far ZipInfoExample[] = "* or % (e.g., \"*font-%.zip\")";
#else
   static char Far ZipInfoExample[] = "*, ?, [] (e.g., \"[a-j]*.zip\")";
#endif
static char Far ZipInfoUsageLine1[] = "\
ZipInfo %s, by Newtware and the fine folks at Info-ZIP.\n\
\n\
List name, date/time, attribute, size, compression method, etc., about files\n\
in list (excluding those in xlist) contained in the specified .zip archive(s).\
\n\"file[.zip]\" may be a wildcard name containing %s.\n\n\
   usage:  zipinfo [-12smlvhtTz] file[.zip] [list...] [-x xlist...]\n\
      or:  unzip %s-Z%s [-12smlvhtTz] file[.zip] [list...] [-x xlist...]\n";

static char Far ZipInfoUsageLine2[] = "\nmain\
 listing-format options:             -s  short Unix \"ls -l\" format (def.)\n\
  -1  filenames ONLY, one per line       -m  medium Unix \"ls -l\" format\n\
  -2  just filenames but allow -h/-t/-z  -l  long Unix \"ls -l\" format\n\
                                         -v  verbose, multi-page format\n";

static char Far ZipInfoUsageLine3[] = "miscellaneous options:\n\
  -h  print header line       -t  print totals for listed files or for all\n\
  -z  print zipfile comment  %c-T%c print file times in sortable decimal format\
\n  -x  exclude filenames that follow from listing\n";
/*"  -p  disable automatic \"more\" function (for pipes) [not implemented]\n";*/
#endif /* !NO_ZIPINFO */
#endif /* !VMSCLI */

#ifdef BETA
   static char Far BetaVersion[] = "%s\
      THIS IS STILL A BETA VERSION OF UNZIP%s -- DO NOT DISTRIBUTE.\n\n";
#endif

#ifdef SFX
   static char Far UnzipSFXUsage[] = "\
UnZipSFX %s, by Info-ZIP (zip-bugs@wkuvx1.wku.edu).\n\
Valid options are -tfupcz; modifiers are -ajnoqCLV%s.\n";
   static char Far CantFindMyself[] =
     "unzipsfx:  can't find myself! [%s]\n";
#else /* !SFX */
   static char Far CompileOptions[] = "UnZip special compilation options:\n";
   static char Far CompileOptFormat[] = "\t%s\n";
   static char Far EnvOptions[] = "\nUnZip and ZipInfo environment options:\n";
   static char Far EnvOptFormat[] = "%16s:  %s\n";
   static char Far None[] = "[none]";
#  ifdef NO_ZIPINFO
     static char Far No_ZipInfo[] = "NO_ZIPINFO";
#  endif
#  ifdef CHECK_EOF
     static char Far Check_EOF[] = "CHECK_EOF";
#  endif
#  ifdef DOSWILD
     static char Far DosWild[] = "DOSWILD";
#  endif
#  ifdef VMSWILD
     static char Far VmsWild[] = "VMSWILD";
#  endif
#  ifdef VMSCLI
     static char Far VmsCLI[] = "VMSCLI";
#  endif
#  ifdef ASM_INFLATECODES
     static char Far AsmInflateCodes[] = "ASM_INFLATECODES";
#  endif
#  ifdef ASM_CRC
     static char Far AsmCRC[] = "ASM_CRC";
#  endif
#  ifdef REGARGS
     static char Far RegArgs[] = "REGARGS";
#  endif
#  ifdef OLD_EXDIR
     static char Far Old_Exdir[] = "OLD_EXDIR";
#  endif
#  ifdef CHECK_VERSIONS
     static char Far Check_Versions[] = "CHECK_VERSIONS";
#  endif
#  ifdef RETURN_CODES
     static char Far Return_Codes[] = "RETURN_CODES";
#  endif
#  ifdef RETURN_SEVERITY
     static char Far Return_Severity[] = "RETURN_SEVERITY";
#  endif
#  ifdef DEBUG
     static char Far Debug[] = "DEBUG";
#  endif
#  ifdef CRYPT
     static char Far Decryption[] = "[decryption]";
#  endif

/* UnzipUsageLine1[] is also used in vms/cmdline.c:  do not make it static */
char Far UnzipUsageLine1[] = "\
UnZip %s, by Info-ZIP.  Portions (c) 1989 by S. H. Smith.\n\
Send bug reports to authors at zip-bugs@wkuvx1.wku.edu; see README for details.\
\n\n";
static char Far UnzipUsageLine2a[] = "\
Latest sources and executables are always in ftp.uu.net:/pub/archiving/zip, at\
\nleast as of date of this release; see \"Where\" for other ftp and non-ftp \
sites.\n\n";

#ifndef VMSCLI
static char Far UnzipUsageLine2[] = "\
Usage: unzip %s[-opts[modifiers]] file[.zip] [list] [-x xlist] [-d exdir]\n \
 Default action is to extract files in list, except those in xlist, to exdir;\n\
  file[.zip] may be a wildcard.  %s\n\n";

#ifdef NO_ZIPINFO
#  define ZIPINFO_MODE_OPTION  ""
   static char Far ZipinfoMode[] =
     "(ZipInfo mode is disabled in this version.)";
#else
#  define ZIPINFO_MODE_OPTION  "[-Z] "
#  ifdef VMS
     static char Far ZipinfoMode[] =
       "\"-Z\" => ZipInfo mode (`unzip \"-Z\"' for usage).";
#  else
     static char Far ZipinfoMode[] =
       "-Z => ZipInfo mode (\"unzip -Z\" for usage).";
#  endif
#endif /* ?NO_ZIPINFO */

static char Far UnzipUsageLine3[] = "\
  -p  extract files to pipe, no messages     -l  list files (short format)\n\
  -f  freshen existing files, create none    -t  test compressed archive data\n\
  -u  update files, create if necessary      -z  display archive comment\n\
  -x  exclude files which follow (in xlist)  -d  extract files into exdir\n\n";

static char Far UnzipUsageLine4[] = "\
modifiers:                                   -q  quiet mode (-qq => quieter)\n\
  -n  never overwrite existing files         -a  auto-convert any text files\n\
  -o  overwrite files WITHOUT prompting      -aa treat ALL files as text\n \
 -j  junk paths (don't make directories)    -v  be verbose/print version info\n\
 %c-C%c match filenames case-insensitively    %c-L%c make (some) names \
lowercase\n %-42s %c-V%c retain VMS version numbers\n%s";

static char Far UnzipUsageLine5[] = "\
Examples (see unzip.doc for more info):\n\
  unzip data1 -x joe   => extract all files except joe from zipfile data1.zip\n\
  %s\n\
  unzip -fo foo %-6s => quietly replace existing %s if archive file newer\n";
#endif /* !VMSCLI */

/* process_zipfiles() strings */
   static char Far FilesProcessOK[] = "%d archive%s successfully processed.\n";
   static char Far ArchiveWarning[] =
     "%d archive%s had warnings but no fatal errors.\n";
   static char Far ArchiveFatalError[] = "%d archive%s had fatal errors.\n";
   static char Far FileHadNoZipfileDir[] =
     "%d file%s had no zipfile directory.\n";
   static char Far ZipfileWasDir[] = "1 \"zipfile\" was a directory.\n";
   static char Far ManyZipfilesWereDir[] =
     "%d \"zipfiles\" were directories.\n";
   static char Far NoZipfileFound[] = "No zipfiles found.\n";
#endif /* ?SFX */

/* do_seekable() strings */
#ifndef SFX
#ifdef UNIX
   static char Far CantFindZipfileDirMsg[] =
     "%s:  can't find zipfile directory in one of %s or\n\
        %s%s.zip, and can't find %s, period.\n";
   static char Far CantFindEitherZipfile[] =
     "%s:  can't find %s, %s.zip or %s, so there.\n";
#else /* !UNIX */
   static char Far CantFindZipfileDirMsg[] =
     "%s:  can't find zipfile directory in %s,\n\
        %sand can't find %s, period.\n";
   static char Far CantFindEitherZipfile[] =
     "%s:  can't find either %s or %s, so there.\n";
#endif /* ?UNIX */
   static char Far MaybeExe[] =
     "note:  %s may be a plain executable, not an archive\n";
   static char Far CentDirNotInZipMsg[] = "\n\
     Zipfile is part of a multi-disk archive, and this is not the disk on\n\
     which the central zipfile directory begins.\n";
#ifdef NO_MULTIPART
   static char Far NoMultiDiskArcSupport[] =
     "\nerror [%s]:  zipfile is part of multi-disk archive\n\
  (sorry, not yet supported).\n";
   static char Far MaybePakBug[] = "warning [%s]:\
  zipfile claims to be 2nd disk of a 2-part archive;\n\
  attempting to process anyway.  If no further errors occur, this archive\n\
  was probably created by PAK v2.51 or earlier.  This bug was reported to\n\
  NoGate in March 1991 and was supposed to have been fixed by mid-1991; as\n\
  of mid-1992 it still hadn't been.  (If further errors do occur, archive\n\
  was probably created by PKZIP 2.04c or later; UnZip does not yet support\n\
  multi-part archives.)\n";
#else
   static char Far MaybePakBug[] = "warning [%s]:\
  zipfile claims to be last disk of a multi-part archive;\n\
  attempting to process anyway, assuming all parts have been concatenated\n\
  together in order.  Expect \"errors\" and warnings...true multi-part support\
\n  doesn't exist yet (coming soon).\n";
#endif
   static char Far ExtraBytesAtStart[] =
     "warning [%s]:  extra %ld bytes at beginning or within zipfile\n\
  (attempting to process anyway)\n";
#endif /* !SFX */

static char Far MissingBytes[] =
  "error [%s]:  missing %ld bytes in zipfile\n\
  (attempting to process anyway)\n";
static char Far NullCentDirOffset[] =
  "error [%s]:  NULL central directory offset\n\
  (attempting to process anyway)\n";
static char Far ZipfileEmpty[] = "warning [%s]:  zipfile is empty\n";
static char Far CentDirStartNotFound[] =
  "error [%s]:  start of central directory not found;\n\
  zipfile corrupt.\n%s";
static char Far ZipfileCommTrunc1[] = "\ncaution:  zipfile comment truncated\n";





#ifdef MSWIN
#  include "winsetup.c"   /* duplicates some code in main() */
#else /* !MSWIN */



/******************/
/*  Main program  */
/******************/

int MAIN(argc, argv)   /* return PK-type error code (except under VMS) */
    int argc;
    char *argv[];
{
#ifndef NO_ZIPINFO
    char *p;
#endif
    int error=FALSE;
#if defined(__IBMC__) && defined(__DEBUG_ALLOC__)
    extern void DebugMalloc(void);


    atexit(DebugMalloc);
#endif

/*---------------------------------------------------------------------------
    Macintosh initialization code.
  ---------------------------------------------------------------------------*/

#ifdef MACOS
    int a;

    for (a = 0;  a < 4;  ++a)
        rghCursor[a] = GetCursor(a+128);
    giCursor = 0;

    aflag=cflag=dflag=fflag=L_flag=jflag=qflag=tflag=uflag=vflag=zflag = 0;
    local_hdr_sig[1] = central_hdr_sig[1] = end_central_sig[1] = '\0';
/*  extd_local_sig[1] = '\0';  */
    error = FALSE;

    overwrite_none = overwrite_all = force_flag = 0;
#endif /* MACOS */

#ifdef MALLOC_WORK
    area.Slide = (uch *)calloc(8193, sizeof(short)+sizeof(char)+sizeof(char));
    area.shrink.Prefix_of = (short *)area.Slide;
    area.shrink.Suffix_of = area.Slide + (sizeof(short)*(HSIZE+1));
    area.shrink.Stack = area.Slide + (sizeof(short) + sizeof(char))*(HSIZE+1);
#endif

/*---------------------------------------------------------------------------
    Human68K initialization code.
  ---------------------------------------------------------------------------*/

#ifdef __human68k__
    InitTwentyOne();
#endif

/*---------------------------------------------------------------------------
    Set signal handler for restoring echo, warn of zipfile corruption, etc.
  ---------------------------------------------------------------------------*/

    signal(SIGINT, handler);
#ifdef SIGTERM                 /* some systems really have no SIGTERM */
    signal(SIGTERM, handler);
#endif
#ifdef SIGBUS
    signal(SIGBUS, handler);
#endif
#ifdef SIGSEGV
    signal(SIGSEGV, handler);
#endif

/*---------------------------------------------------------------------------
    Debugging info for checking on structure padding:
  ---------------------------------------------------------------------------*/

#ifdef DEBUG_STRUC
    printf("local_file_hdr size: %X\n",
           sizeof(local_file_hdr));
    printf("local_byte_hdr size: %X\n",
           sizeof(local_byte_hdr));
    printf("actual size of local headers: %X\n", LREC_SIZE);

    printf("central directory header size: %X\n",
           sizeof(cdir_file_hdr));
    printf("central directory byte header size: %X\n",
           sizeof(cdir_byte_hdr));
    printf("actual size of central dir headers: %X\n", CREC_SIZE);

    printf("end central dir record size: %X\n",
           sizeof(ecdir_rec));
    printf("end central dir byte record size: %X\n",
           sizeof(ec_byte_rec));
    printf("actual size of end-central-dir record: %X\n", ECREC_SIZE);
#endif /* DEBUG_STRUC */

/*---------------------------------------------------------------------------
    First figure out if we're running in UnZip mode or ZipInfo mode, and put
    the appropriate environment-variable options into the queue.  Then rip
    through any command-line options lurking about...
  ---------------------------------------------------------------------------*/

#ifdef SFX
    argv0 = argv[0];
#if defined(OS2) || defined(NT)
    zipfn = GetLoadPath();   /* non-MSC NT puts path into filename[] */
#else
    zipfn = argv0;
#endif
    zipinfo_mode = FALSE;
    if ((error = uz_opts(&argc, &argv)) != 0)
        RETURN(error);

#else /* !SFX */

#ifdef MSDOS
    /* extract MKS extended argument list from environment (before envargs!) */
    mksargs(&argc, &argv);
#endif

#ifdef VMSCLI
    {
        ulg status = vms_unzip_cmdline(&argc, &argv);
        if (!(status & 1))
            return status;
    }
#endif /* VMSCLI */

#ifndef NO_ZIPINFO
    if ((p = strrchr(argv[0], DIR_END)) == (char *)NULL)
        p = argv[0];
    else
        ++p;

    if (STRNICMP(p, "zipinfo", 7) == 0 || STRNICMP(p, "ii", 2) == 0 ||
        (argc > 1 && strncmp(argv[1], "-Z", 2) == 0))
    {
        zipinfo_mode = TRUE;
        envargs(&argc, &argv, LoadFarStringSmall(EnvZipInfo),
          LoadFarStringSmall2(EnvZipInfo2));
        error = zi_opts(&argc, &argv);
    } else
#endif /* NO_ZIPINFO */
    {
        zipinfo_mode = FALSE;
        envargs(&argc, &argv, LoadFarStringSmall(EnvUnZip),
          LoadFarStringSmall2(EnvUnZip2));
        error = uz_opts(&argc, &argv);
    }
    if ((argc < 0) || error)
        RETURN(error);

#endif /* ?SFX */

/*---------------------------------------------------------------------------
    Now get the zipfile name from the command line and then process any re-
    maining options and file specifications.
  ---------------------------------------------------------------------------*/

#ifdef DOS_NT_OS2
    /* convert MSDOS-style directory separators to Unix-style ones for
     * user's convenience (include zipfile name itself)
     */
    pfnames = argv;
    while (*pfnames != NULL) {
        char *q;

        for (q = *pfnames;  *q;  ++q)
            if (*q == '\\')
                *q = '/';
        ++pfnames;
    }
#endif

    wildzipfn = *argv++;

#if (defined(OLD_EXDIR) || defined(SFX))

#ifndef SFX
    if (argc > 0) {
        /* -d:  "name/" immediately after zipfile name is a stored directory to
         * be extracted--do NOT treat as directory to which to extract files
         */
        if (extract_flag && !dflag) {
            create_dirs = !fflag;
            if ((error = checkdir(*argv, ROOT)) > 2)  /* mem, or file in way */
                RETURN(error);
            else if (!error) {   /* it IS extract-to dir, so adjust pointers */
                ++argv;
                --argc;
            }
        }
    }
#endif /* !SFX */

    filespecs = argc;
    xfilespecs = 0;

    if (argc > 0) {
        char **pp = argv-1;

        pfnames = argv;
        while (*++pp)
            if (strcmp(*pp, "-x") == 0) {
                if (pp > argv) {
                    *pp = 0;           /* terminate pfnames */
                    filespecs = pp - pfnames;
                } else {
                    pfnames = fnames;  /* defaults */
                    filespecs = 0;
                }
                pxnames = pp + 1;      /* excluded-names ptr starts after -x */
                xfilespecs = argc - filespecs - 1;
                break;                 /* skip rest of args */
            }
        process_all_files = FALSE;
    } else
        process_all_files = TRUE;       /* for speed */

#else /* !(OLD_EXDIR || SFX) */

    filespecs = argc;
    xfilespecs = 0;

    if (argc > 0) {
        int in_files=FALSE, in_xfiles=FALSE;
        char **pp = argv-1;

        process_all_files = FALSE;
        pfnames = argv;
        while (*++pp) {
            Trace((stderr, "pp - argv = %d\n", pp-argv));
            if (!dflag && strncmp(*pp, "-d", 2) == 0) {
                char *q = *pp;
                int firstarg = (pp == argv);

                dflag = TRUE;
                if (in_files) {      /* ... zipfile ... -d exdir ... */
                    *pp = 0;                    /* terminate pfnames */
                    filespecs = pp - pfnames;
                    in_files = FALSE;
                } else if (in_xfiles) {
                    *pp = 0;                    /* terminate pxnames */
                    xfilespecs = pp - pxnames;
                    /* "... -x xlist -d exdir":  nothing left */
                }
                /* first check for "-dpath", then for "-d path" */
                if (q[2])
                    q += 2;
                else if (*++pp)
                    q = *pp;
                else {
                    FPRINTF(stderr, LoadFarString(MustGiveExdir));
                    RETURN(PK_PARAM);  /* don't extract here by accident */
                }
                if (extract_flag) {
                    create_dirs = !fflag;
                    if ((error = checkdir(q, ROOT)) > 2)
                        RETURN(error);  /* out of memory, or file in way */
                } else
                    FPRINTF(stderr, LoadFarString(NotExtracting));
                if (firstarg)   /* ... zipfile -d exdir ... */
                    if (pp[1]) {
                        pfnames = pp + 1;  /* argv+2 */
                        filespecs = argc - (pfnames-argv);  /* for now... */
                    } else {
                        process_all_files = TRUE;
                        pfnames = fnames;  /* GRR: necessary? */
                        filespecs = 0;     /* GRR: necessary? */
                        break;
                    }
            } else if (!in_xfiles) {
                if (strcmp(*pp, "-x") == 0) {
                    in_xfiles = TRUE;
                    if (pp == argv || (pp == argv+2 && dflag)) {
                        pfnames = fnames;  /* defaults */
                        filespecs = 0;
                    } else if (in_files) {
                        *pp = 0;                   /* terminate pfnames */
                        filespecs = pp - pfnames;  /* adjust count */
                        in_files = FALSE;
                    }
                    pxnames = pp + 1;  /* excluded-names ptr starts after -x */
                    xfilespecs = argc - (pxnames-argv);  /* anything left... */
                } else
                    in_files = TRUE;
            }
        }
    } else
        process_all_files = TRUE;      /* for speed */

#endif /* ?(OLD_EXDIR || SFX) */

/*---------------------------------------------------------------------------
    Okey dokey, we have everything we need to get started.  Let's roll.
  ---------------------------------------------------------------------------*/

    inbuf = (uch *)malloc(INBUFSIZ + 4);    /* 4 extra for hold[] (below) */
    outbuf = (uch *)malloc(OUTBUFSIZ + 1);  /* 1 extra for string termin. */

    if ((inbuf == (uch *)NULL) || (outbuf == (uch *)NULL)) {
        FPRINTF(stderr, LoadFarString(CantAllocateBuffers));
        RETURN(PK_MEM);
    }
    hold = inbuf + INBUFSIZ;     /* to check for boundary-spanning signatures */
#ifdef SMALL_MEM
    outbuf2 = outbuf+RAWBUFSIZ;  /* never changes */
#endif

    RETURN(process_zipfiles());  /* keep passing errors back... */

} /* end main() */





/**********************/
/* Function uz_opts() */
/**********************/

int uz_opts(pargc, pargv)
    int *pargc;
    char ***pargv;
{
    char **argv, *s;
    int argc, c, error=FALSE, negative=0;


    argc = *pargc;
    argv = *pargv;

    while (--argc > 0 && (*++argv)[0] == '-') {
        s = argv[0] + 1;
        while ((c = *s++) != 0) {    /* "!= 0":  prevent Turbo C warning */
            switch (c) {
                case ('-'):
                    ++negative;
                    break;
                case ('a'):
                    if (negative) {
                        aflag = MAX(aflag-negative,0);
                        negative = 0;
                    } else
                        ++aflag;
                    break;
                case ('b'):
                    if (negative)
                        negative = 0;   /* do nothing:  "-b" is default */
                    else
                        aflag = 0;
                    break;
                case ('c'):
                    if (negative) {
                        cflag = FALSE, negative = 0;
#ifdef NATIVE
                        aflag = 0;
#endif
                    } else {
                        cflag = TRUE;
#ifdef NATIVE
                        aflag = 2;  /* so you can read it on the screen */
#endif
                    }
                    break;
                case ('C'):    /* -C:  match filenames case-insensitively */
                    if (negative)
                        C_flag = FALSE, negative = 0;
                    else
                        C_flag = TRUE;
                    break;
                case ('d'):  /* arg after zipfn is stored dir, not extract-to */
#ifdef OLD_EXDIR
                    if (negative)
                        dflag = FALSE, negative = 0;
                    else
                        dflag = TRUE;
#endif
                    break;
                case ('e'):    /* just ignore -e, -x options (extract) */
                    break;
                case ('f'):    /* "freshen" (extract only newer files) */
                    if (negative)
                        fflag = uflag = FALSE, negative = 0;
                    else
                        fflag = uflag = TRUE;
                    break;
                case ('j'):    /* junk pathnames/directory structure */
                    if (negative)
                        jflag = FALSE, negative = 0;
                    else
                        jflag = TRUE;
                    break;
#ifndef SFX
                case ('l'):
                    if (negative) {
                        vflag = MAX(vflag-negative,0);
                        negative = 0;
                    } else
                        ++vflag;
                    break;
#endif /* !SFX */
                case ('L'):    /* convert (some) filenames to lowercase */
                    if (negative)
                        L_flag = FALSE, negative = 0;
                    else
                        L_flag = TRUE;
                    break;
                case ('n'):    /* don't overwrite any files */
                    if (negative)
                        overwrite_none = FALSE, negative = 0;
                    else
                        overwrite_none = TRUE;
                    break;
                case ('o'):    /* OK to overwrite files without prompting */
                    if (negative) {
                        overwrite_all = MAX(overwrite_all-negative,0);
                        force_flag = MAX(force_flag-negative,0);
                        negative = 0;
                    } else {
                        ++overwrite_all;
                        ++force_flag;  /* (share -o for now) force to cont. */
                    }
                    break;
                case ('p'):    /* pipes:  extract to stdout, no messages */
                    if (negative) {
                        cflag = FALSE;
                        qflag = MAX(qflag-999,0);
                        negative = 0;
                    } else {
                        cflag = TRUE;
                        qflag += 999;
                    }
                    break;
                case ('q'):    /* quiet:  fewer comments/messages */
                    if (negative) {
                        qflag = MAX(qflag-negative,0);
                        negative = 0;
                    } else
                        ++qflag;
                    break;
#ifdef DOS_NT_OS2
                case ('s'):    /* spaces in filenames:  allow by default */
                    if (negative)
                        sflag = FALSE, negative = 0;
                    else
                        sflag = TRUE;
                    break;
#endif
                case ('t'):
                    if (negative)
                        tflag = FALSE, negative = 0;
                    else
                        tflag = TRUE;
                    break;
                case ('u'):    /* update (extract only new and newer files) */
                    if (negative)
                        uflag = FALSE, negative = 0;
                    else
                        uflag = TRUE;
                    break;
                case ('U'):    /* obsolete; to be removed in future release */
                    if (negative)
                        L_flag = TRUE, negative = 0;
                    else
                        L_flag = FALSE;
                    break;
#ifndef SFX
                case ('v'):    /* verbose */
                    if (negative) {
                        vflag = MAX(vflag-negative,0);
                        negative = 0;
                    } else if (vflag)
                        ++vflag;
                    else
                        vflag = 2;
                    break;
#endif /* !SFX */
                case ('V'):    /* Version (retain VMS/DEC-20 file versions) */
                    if (negative)
                        V_flag = FALSE, negative = 0;
                    else
                        V_flag = TRUE;
                    break;
                case ('x'):    /* extract:  default */
                    break;
#ifdef VMS
                case ('X'):   /* restore owner/protection info (need privs?) */
                    if (negative)
                        secinf = FALSE, negative = 0;
                    else
                        secinf = TRUE;
                    break;
#endif /* VMS */
                case ('z'):    /* display only the archive comment */
                    if (negative) {
                        zflag -= negative;
                        negative = 0;
                    } else
                        ++zflag;
                    break;
#ifdef DOS_NT_OS2
                case ('$'):
                    if (negative) {
                        volflag = MAX(volflag-negative,0);
                        negative = 0;
                    } else
                        ++volflag;
                    break;
#endif /* DOS_NT_OS2 */
                default:
                    error = TRUE;
                    break;

            } /* end switch */
        } /* end while (not end of argument string) */
    } /* end while (not done with switches) */

/*---------------------------------------------------------------------------
    Check for nonsensical combinations of options.
  ---------------------------------------------------------------------------*/

    if ((cflag && tflag) || (cflag && uflag) || (tflag && uflag) ||
        (fflag && overwrite_none)) {
        FPRINTF(stderr, LoadFarString(InvalidOptionsMsg));
        error = TRUE;
    }
    if (aflag > 2)
        aflag = 2;
    if (overwrite_all && overwrite_none) {
        FPRINTF(stderr, LoadFarString(IgnoreOOptionMsg));
        overwrite_all = FALSE;
    }

#ifdef SFX
    if (error)
#else
    if ((argc-- == 0) || error)
#endif
    {
        *pargc = argc;
        *pargv = argv;
#ifndef SFX
        if (vflag >= 2 && argc == -1) {
            char *envptr, *getenv();
            int numopts = 0;

            PRINTF(LoadFarString(UnzipUsageLine1),
              LoadFarStringSmall(UnzipVersion));
            PRINTF(LoadFarString(UnzipUsageLine2a));
            version();
            PRINTF(LoadFarString(CompileOptions));
#ifdef NO_ZIPINFO
            PRINTF(LoadFarString(CompileOptFormat),
              LoadFarStringSmall(No_ZipInfo));
            ++numopts;
#endif
#ifdef CHECK_EOF
            PRINTF(LoadFarString(CompileOptFormat),
              LoadFarStringSmall(Check_EOF));
            ++numopts;
#endif
#ifdef DOSWILD
            PRINTF(LoadFarString(CompileOptFormat),
              LoadFarStringSmall(DosWild));
            ++numopts;
#endif
#ifdef VMSWILD
            PRINTF(LoadFarString(CompileOptFormat),
              LoadFarStringSmall(VmsWild));
            ++numopts;
#endif
#ifdef VMSCLI
            PRINTF(LoadFarString(CompileOptFormat),
              LoadFarStringSmall(VmsCLI));
            ++numopts;
#endif
#ifdef ASM_INFLATECODES
            PRINTF(LoadFarString(CompileOptFormat),
              LoadFarStringSmall(AsmInflateCodes));
            ++numopts;
#endif
#ifdef ASM_CRC
            PRINTF(LoadFarString(CompileOptFormat),
              LoadFarStringSmall(AsmCRC));
            ++numopts;
#endif
#ifdef REGARGS
            PRINTF(LoadFarString(CompileOptFormat),
              LoadFarStringSmall(RegArgs));
            ++numopts;
#endif
#ifdef OLD_EXDIR
            PRINTF(LoadFarString(CompileOptFormat),
              LoadFarStringSmall(Old_Exdir));
            ++numopts;
#endif
#ifdef CHECK_VERSIONS
            PRINTF(LoadFarString(CompileOptFormat),
              LoadFarStringSmall(Check_Versions));
            ++numopts;
#endif
#ifdef RETURN_CODES
            PRINTF(LoadFarString(CompileOptFormat),
              LoadFarStringSmall(Return_Codes));
            ++numopts;
#endif
#ifdef RETURN_SEVERITY
            PRINTF(LoadFarString(CompileOptFormat),
              LoadFarStringSmall(Return_Severity));
            ++numopts;
#endif
#ifdef DEBUG
            PRINTF(LoadFarString(CompileOptFormat), LoadFarStringSmall(Debug));
            ++numopts;
#endif
#ifdef CRYPT
            PRINTF(LoadFarString(CompileOptFormat),
              LoadFarStringSmall(Decryption));
            ++numopts;
#endif
            if (numopts == 0)
                PRINTF(LoadFarString(CompileOptFormat),
                  LoadFarStringSmall(None));

            PRINTF(LoadFarString(EnvOptions));
            envptr = getenv(LoadFarStringSmall(EnvUnZip));
            PRINTF(LoadFarString(EnvOptFormat), LoadFarStringSmall(EnvUnZip),
              (envptr == (char *)NULL || *envptr == 0)?
              LoadFarStringSmall2(None) : envptr);
            envptr = getenv(LoadFarStringSmall(EnvUnZip2));
            PRINTF(LoadFarString(EnvOptFormat), LoadFarStringSmall(EnvUnZip2),
              (envptr == (char *)NULL || *envptr == 0)?
              LoadFarStringSmall2(None) : envptr);
            envptr = getenv(LoadFarStringSmall(EnvZipInfo));
            PRINTF(LoadFarString(EnvOptFormat), LoadFarStringSmall(EnvZipInfo),
              (envptr == (char *)NULL || *envptr == 0)?
              LoadFarStringSmall2(None) : envptr);
            envptr = getenv(LoadFarStringSmall(EnvZipInfo2));
            PRINTF(LoadFarString(EnvOptFormat), LoadFarStringSmall(EnvZipInfo2),
              (envptr == (char *)NULL || *envptr == 0)?
              LoadFarStringSmall2(None) : envptr);

            return 0;
        } else
#endif /* !SFX */
            return usage(error);
    }

    if (cflag || tflag || vflag)
        extract_flag = FALSE;
    else
        extract_flag = TRUE;

    *pargc = argc;
    *pargv = argv;
    return 0;

} /* end function uz_opts() */





/********************/
/* Function usage() */
/********************/

#ifdef SFX
#  ifdef VMS
#    define LOCAL "X.  Quote uppercase options"
#  else
#    ifdef DOS_NT_OS2
#      define LOCAL "s$"
#    else
#       ifdef AMIGA
#         define LOCAL "$"
#       else
#         define LOCAL ""
#       endif
#    endif /* ?DOS_NT_OS2 */
#  endif /* ?VMS */

int usage(error)   /* return PK-type error code */
    int error;
{
    FILE *usagefp;

    if (error)
        usagefp = (FILE *)stderr;
    else
        usagefp = (FILE *)stdout;

    FPRINTF(usagefp, LoadFarString(UnzipSFXUsage),
      LoadFarStringSmall(UnzipVersion), LOCAL);
#ifdef BETA
    FPRINTF(usagefp, LoadFarString(BetaVersion), "\n", "SFX");
#endif

    if (error)
        return PK_PARAM;
    else
        return PK_COOL;     /* just wanted usage screen: no error */

} /* end function usage() */





#else /* !SFX */
#ifndef VMSCLI

int usage(error)   /* return PK-type error code */
    int error;
{
#ifdef VMS
#  define QUOT '\"'
#  define QUOTS "\""
#else
#  define QUOT ' '
#  define QUOTS ""
#endif

    FILE *usagefp;


/*---------------------------------------------------------------------------
    If user requested usage, send it to stdout; else send to stderr.
  ---------------------------------------------------------------------------*/

    if (error)
        usagefp = (FILE *)stderr;
    else
        usagefp = (FILE *)stdout;

/*---------------------------------------------------------------------------
    Print either ZipInfo usage or UnZip usage, depending on incantation.
    (Strings must be no longer than 512 bytes for Turbo C, apparently.)
  ---------------------------------------------------------------------------*/

    if (zipinfo_mode) {

#ifndef NO_ZIPINFO

        FPRINTF(usagefp, LoadFarString(ZipInfoUsageLine1),
          LoadFarStringSmall(ZipinfoVersion),
          LoadFarStringSmall2(ZipInfoExample), QUOTS,QUOTS);
        FPRINTF(usagefp, LoadFarString(ZipInfoUsageLine2));
        FPRINTF(usagefp, LoadFarString(ZipInfoUsageLine3), QUOT,QUOT);
#ifdef VMS
        FPRINTF(usagefp, "\nRemember that non-lowercase filespecs must be\
 quoted in VMS (e.g., \"Makefile\").\n");
#endif

#endif /* !NO_ZIPINFO */

    } else {   /* UnZip mode */

        FPRINTF(usagefp, LoadFarString(UnzipUsageLine1),
          LoadFarStringSmall(UnzipVersion));
#ifdef BETA
        FPRINTF(usagefp, LoadFarString(BetaVersion), "", "");
#endif
        FPRINTF(usagefp, LoadFarString(UnzipUsageLine2), ZIPINFO_MODE_OPTION,
          LoadFarStringSmall(ZipinfoMode));

        FPRINTF(usagefp, LoadFarString(UnzipUsageLine3));

        FPRINTF(usagefp, LoadFarString(UnzipUsageLine4), QUOT,QUOT, QUOT,QUOT,
                LoadFarStringSmall(loc_str), QUOT,QUOT,
                LoadFarStringSmall2(loc2str));

        /* This is extra work for SMALL_MEM, but it will work since
         * LoadFarStringSmall2 uses the same buffer.  Remember, this
         * is a hack. */
        FPRINTF(usagefp, LoadFarString(UnzipUsageLine5),
                LoadFarStringSmall(Example1),
                LoadFarStringSmall2(Example2),
                LoadFarStringSmall2(Example2));

    }

    if (error)
        return PK_PARAM;
    else
        return PK_COOL;     /* just wanted usage screen: no error */

} /* end function usage() */

#endif /* !VMSCLI */
#endif /* ?SFX */
#endif /* ?MSWIN */




/*******************************/
/* Function process_zipfiles() */
/*******************************/

int process_zipfiles()    /* return PK-type error code */
{
#ifndef SFX
    char *lastzipfn = (char *)NULL;
    int NumWinFiles, NumLoseFiles, NumWarnFiles;
    int NumMissDirs, NumMissFiles;
#endif
    int error=0, error_in_archive=0;


/*---------------------------------------------------------------------------
    Start by constructing the various PK signature strings.
  ---------------------------------------------------------------------------*/

    local_hdr_sig[0]  /* = extd_local_sig[0] */  = '\120';   /* ASCII 'P', */
    central_hdr_sig[0] = end_central_sig[0] = '\120';        /* not EBCDIC */

    strcpy(local_hdr_sig+1, LOCAL_HDR_SIG);
    strcpy(central_hdr_sig+1, CENTRAL_HDR_SIG);
    strcpy(end_central_sig+1, END_CENTRAL_SIG);
/*  strcpy(extd_local_sig+1, EXTD_LOCAL_SIG);   still to be used in multi? */

/*---------------------------------------------------------------------------
    Match (possible) wildcard zipfile specification with existing files and
    attempt to process each.  If no hits, try again after appending ".zip"
    suffix.  If still no luck, give up.
  ---------------------------------------------------------------------------*/

#ifdef SFX
    if ((error = do_seekable(0)) == PK_NOZIP) {
#ifdef EXE_EXTENSION
        int len=strlen(argv0);

        /* append .exe if appropriate; also .sfx? */
        if ((zipfn = (char *)malloc(len+5)) != (char *)NULL) {
            strcpy(zipfn, argv0);
            strcpy(zipfn+len, EXE_EXTENSION);
            error = do_seekable(0);
            free(zipfn);
            zipfn = argv0;  /* for "can't find myself" message only */
        }
#endif /* EXE_EXTENSION */
#ifdef NT
        zipfn = argv0;  /* for "can't find myself" message only */
#endif
    }
    if (error) {
        if (error == IZ_DIR)
            error_in_archive = PK_NOZIP;
        else
            error_in_archive = error;
        if (error == PK_NOZIP)
            FPRINTF(stderr, LoadFarString(CantFindMyself), zipfn);
    }

#else /* !SFX */
    NumWinFiles = NumLoseFiles = NumWarnFiles = 0;
    NumMissDirs = NumMissFiles = 0;

    while ((zipfn = do_wild(wildzipfn)) != (char *)NULL) {
        Trace((stderr, "do_wild( %s ) returns %s\n", wildzipfn, zipfn));

        lastzipfn = zipfn;

        /* print a blank line between the output of different zipfiles */
        if (!qflag  &&  error != PK_NOZIP  &&  error != IZ_DIR  &&
            (NumWinFiles+NumLoseFiles+NumWarnFiles+NumMissFiles) > 0)
            PRINTF("\n");
        FFLUSH(stdout);

        if ((error = do_seekable(0)) == PK_WARN)
            ++NumWarnFiles;
        else if (error == IZ_DIR)
            ++NumMissDirs;
        else if (error == PK_NOZIP)
            ++NumMissFiles;
        else if (error)
            ++NumLoseFiles;
        else
            ++NumWinFiles;

        if (error != IZ_DIR && error > error_in_archive)
            error_in_archive = error;
        Trace((stderr, "do_seekable(0) returns %d\n", error));

    } /* end while-loop (wildcard zipfiles) */

    if ((NumWinFiles + NumWarnFiles + NumLoseFiles) == 0  &&
        (NumMissDirs + NumMissFiles) == 1  &&  lastzipfn != (char *)NULL)
    {
        char *p = lastzipfn + strlen(lastzipfn);

        NumMissDirs = NumMissFiles = 0;
        if (error_in_archive == PK_NOZIP)
            error_in_archive = PK_COOL;
        zipfn = lastzipfn;
        strcpy(p, ".zip");

#ifdef UNIX
        if ((error = do_seekable(0)) == PK_NOZIP || error == IZ_DIR) {
            if (error == IZ_DIR)
                ++NumMissDirs;
            strcpy(p, ".ZIP");
            error = do_seekable(1);
        }
#else
        error = do_seekable(1);
#endif
        if (error == PK_WARN)
            ++NumWarnFiles;
        else if (error == IZ_DIR)
            ++NumMissDirs;
        else if (error == PK_NOZIP)
            /* if increment again => bug: "1 file had no zipfile directory." */
            /* ++NumMissFiles */ ;
        else if (error)
            ++NumLoseFiles;
        else
            ++NumWinFiles;

        if (error > error_in_archive)
            error_in_archive = error;
        Trace((stderr, "do_seekable(1) returns %d\n", error));
    }
#endif /* ?SFX */

    FFLUSH(stdout);
    FFLUSH(stderr);

/*---------------------------------------------------------------------------
    Print summary of all zipfiles, assuming zipfile spec was a wildcard (no
    need for a summary if just one zipfile).
  ---------------------------------------------------------------------------*/

#ifndef SFX
    if (iswild(wildzipfn)) {
        if (NumMissFiles + NumLoseFiles + NumWarnFiles > 0 || NumWinFiles != 1)
            FPRINTF(stderr, "\n");
        if ((NumWinFiles > 1) || (NumWinFiles == 1 &&
            NumMissDirs + NumMissFiles + NumLoseFiles + NumWarnFiles > 0))
            FPRINTF(stderr, LoadFarString(FilesProcessOK),
              NumWinFiles, (NumWinFiles == 1)? " was" : "s were");
        if (NumWarnFiles > 0)
            FPRINTF(stderr, LoadFarString(ArchiveWarning),
              NumWarnFiles, (NumWarnFiles == 1)? "" : "s");
        if (NumLoseFiles > 0)
            FPRINTF(stderr, LoadFarString(ArchiveFatalError),
              NumLoseFiles, (NumLoseFiles == 1)? "" : "s");
        if (NumMissFiles > 0)
            FPRINTF(stderr, LoadFarString(FileHadNoZipfileDir),
              NumMissFiles, (NumMissFiles == 1)? "" : "s");
        if (NumMissDirs == 1)
            FPRINTF(stderr, LoadFarString(ZipfileWasDir));
        else if (NumMissDirs > 0)
            FPRINTF(stderr, LoadFarString(ManyZipfilesWereDir), NumMissDirs);
        if (NumWinFiles + NumLoseFiles + NumWarnFiles == 0)
            FPRINTF(stderr, LoadFarString(NoZipfileFound));
    }
#endif /* !SFX */

    /* free allocated memory */
    inflate_free();
    checkdir((char *)NULL, END);
#ifndef SMALL_MEM
    if (outbuf2)
        free(outbuf2);   /* malloc'd ONLY if unshrink and -a */
#endif
    free(outbuf);
    free(inbuf);

    return error_in_archive;

} /* end function process_zipfiles() */





/**************************/
/* Function do_seekable() */
/**************************/

int do_seekable(lastchance)    /* return PK-type error code */
    int lastchance;
{
#ifndef SFX
    static int no_ecrec = FALSE;
    int maybe_exe=FALSE;
#endif
    int error=0, error_in_archive;


/*---------------------------------------------------------------------------
    Open the zipfile for reading in BINARY mode to prevent CR/LF translation,
    which would corrupt the bit streams.
  ---------------------------------------------------------------------------*/

    if (SSTAT(zipfn, &statbuf) || (error = S_ISDIR(statbuf.st_mode)) != 0) {
#ifndef SFX
        if (lastchance)
            if (no_ecrec)
                FPRINTF(stderr, LoadFarString(CantFindZipfileDirMsg),
                  zipinfo_mode? "zipinfo" : "unzip",
                  wildzipfn, zipinfo_mode? "  " : "",
#ifdef UNIX
                                                     wildzipfn,
#endif
                                                               zipfn);
            else
                FPRINTF(stderr,
                  LoadFarString(CantFindEitherZipfile),
                  zipinfo_mode? "zipinfo" : "unzip", wildzipfn,
#ifdef UNIX
                                                               wildzipfn,
#endif
                                                                         zipfn);
#endif /* !SFX */
        return error? IZ_DIR : PK_NOZIP;
    }
    ziplen = statbuf.st_size;

#ifndef SFX
#if defined(UNIX) || defined(DOS_NT_OS2)
    if (statbuf.st_mode & S_IEXEC)   /* no extension on Unix exec's:  might */
        maybe_exe = TRUE;            /*  find unzip, not unzip.zip; etc. */
#endif
#endif /* !SFX */

#ifdef VMS
    if (check_format())      /* check for variable-length format */
        return PK_ERR;
#endif

    if (open_input_file())   /* this should never happen, given */
        return PK_NOZIP;     /*  the stat() test above, but... */

/*---------------------------------------------------------------------------
    Find and process the end-of-central-directory header.  UnZip need only
    check last 65557 bytes of zipfile:  comment may be up to 65535, end-of-
    central-directory record is 18 bytes, and signature itself is 4 bytes;
    add some to allow for appended garbage.  Since ZipInfo is often used as
    a debugging tool, search the whole zipfile if zipinfo_mode is true.
  ---------------------------------------------------------------------------*/

    cur_zipfile_bufstart = 0;
    inptr = inbuf;

    if (!qflag && !zipinfo_mode)
        PRINTF("Archive:  %s\n", zipfn);

    if ((
#ifndef NO_ZIPINFO
         zipinfo_mode &&
          ((error_in_archive = find_ecrec(ziplen)) != 0 ||
          (error_in_archive = zi_end_central()) > PK_WARN))
        || (!zipinfo_mode &&
#endif
          ((error_in_archive = find_ecrec(MIN(ziplen,66000L))) != 0 ||
          (error_in_archive = uz_end_central()) > PK_WARN)))
    {
        close(zipfd);
#ifdef SFX
        ++lastchance;   /* avoid picky compiler warnings */
        return error_in_archive;
#else
        if (maybe_exe)
            FPRINTF(stderr, LoadFarString(MaybeExe), zipfn);
        if (lastchance)
            return error_in_archive;
        else {
            no_ecrec = TRUE;    /* assume we found wrong file:  e.g., */
            return PK_NOZIP;    /*  unzip instead of unzip.zip */
        }
#endif /* ?SFX */
    }

    if ((zflag > 0) && !zipinfo_mode) {   /* in unzip, zflag = comment ONLY */
        close(zipfd);
        return error_in_archive;
    }

/*---------------------------------------------------------------------------
    Test the end-of-central-directory info for incompatibilities (multi-disk
    archives) or inconsistencies (missing or extra bytes in zipfile).
  ---------------------------------------------------------------------------*/

#ifdef NO_MULTIPART
    error = !zipinfo_mode && (ecrec.number_this_disk == 1) &&
            (ecrec.num_disk_with_start_central_dir == 1);
#else
    error = !zipinfo_mode && (ecrec.number_this_disk != 0);
#endif

#ifndef SFX
    if (zipinfo_mode &&
        ecrec.number_this_disk != ecrec.num_disk_with_start_central_dir)
    {
        FPRINTF(stderr, LoadFarString(CentDirNotInZipMsg));
        error_in_archive = PK_FIND;
#ifdef NO_MULTIPART   /* concatenation of multiple parts works in some cases */
    } else if (!zipinfo_mode && !error && ecrec.number_this_disk != 0) {
        FPRINTF(stderr, LoadFarString(NoMultiDiskArcSupport), zipfn);
        error_in_archive = PK_FIND;
#endif
    } else {   /* this is a (relatively) normal zipfile:  process normally */
        if (error) {
            FPRINTF(stderr, LoadFarString(MaybePakBug), zipfn);
            error_in_archive = PK_WARN;
        }
#endif
        if ((extra_bytes = real_ecrec_offset-expect_ecrec_offset) < (LONGINT)0)
        {
            FPRINTF(stderr, LoadFarString(MissingBytes), zipfn,
              (long)(-extra_bytes));
            error_in_archive = PK_ERR;
        } else if (extra_bytes > 0) {
            if ((ecrec.offset_start_central_directory == 0) &&
                (ecrec.size_central_directory != 0))   /* zip 1.5 -go bug */
            {
                FPRINTF(stderr, LoadFarString(NullCentDirOffset), zipfn);
                ecrec.offset_start_central_directory = extra_bytes;
                extra_bytes = 0;
                error_in_archive = PK_ERR;
            }
#ifndef SFX
            else {
                FPRINTF(stderr, LoadFarString(ExtraBytesAtStart), zipfn,
                  (long)extra_bytes);
                error_in_archive = PK_WARN;
            }
#endif
        }

    /*-----------------------------------------------------------------------
        Check for empty zipfile and exit now if so.
      -----------------------------------------------------------------------*/

        if (expect_ecrec_offset == 0L  &&  ecrec.size_central_directory == 0) {
            if (zipinfo_mode)
                PRINTF("%sEmpty zipfile.\n", lflag>9 ? "\n  " : "");
            else
                FPRINTF(stderr, LoadFarString(ZipfileEmpty), zipfn);
            close(zipfd);
            return (error_in_archive > PK_WARN)? error_in_archive : PK_WARN;
        }

    /*-----------------------------------------------------------------------
        Compensate for missing or extra bytes, and seek to where the start
        of central directory should be.  If header not found, uncompensate
        and try again (necessary for at least some Atari archives created
        with STZip, as well as archives created by J.H. Holm's ZIPSPLIT 1.1).
      -----------------------------------------------------------------------*/

        LSEEK( ecrec.offset_start_central_directory )
#ifdef OLD_SEEK_TEST
        if (readbuf(sig, 4) == 0) {
            close(zipfd);
            return PK_ERR;  /* file may be locked, or possibly disk error(?) */
        }
        if (strncmp(sig, central_hdr_sig, 4))
#else
        if ((readbuf(sig, 4) == 0) || strncmp(sig, central_hdr_sig, 4))
#endif
        {
            long tmp = extra_bytes;

            extra_bytes = 0;
            LSEEK( ecrec.offset_start_central_directory )
            if ((readbuf(sig, 4) == 0) || strncmp(sig, central_hdr_sig, 4)) {
                FPRINTF(stderr, LoadFarString(CentDirStartNotFound), zipfn,
                  LoadFarStringSmall(ReportMsg));
                close(zipfd);
                return PK_BADERR;
            }
            FPRINTF(stderr, LoadFarString(CentDirTooLong), zipfn, -tmp);
            error_in_archive = PK_ERR;
        }

    /*-----------------------------------------------------------------------
        Seek to the start of the central directory one last time, since we
        have just read the first entry's signature bytes; then list, extract
        or test member files as instructed, and close the zipfile.
      -----------------------------------------------------------------------*/

        Trace((stderr, "about to extract/list files (error = %d)\n",
          error_in_archive));

        LSEEK( ecrec.offset_start_central_directory )

#ifndef NO_ZIPINFO
        if (zipinfo_mode) {
            error = zipinfo();                     /* ZIPINFO 'EM */
            if (lflag > 9)
                PRINTF("\n");
        } else
#endif
#ifndef SFX
            if (vflag && !tflag && !cflag)
                error = list_files();              /* LIST 'EM */
            else
#endif
                error = extract_or_test_files();   /* EXTRACT OR TEST 'EM */

        Trace((stderr, "done with extract/list files (error = %d)\n", error));

        if (error > error_in_archive)   /* don't overwrite stronger error */
            error_in_archive = error;   /*  with (for example) a warning */
#ifndef SFX
    }
#endif

    close(zipfd);
    return error_in_archive;

} /* end function do_seekable() */





/*****************************/
/* Function uz_end_central() */
/*****************************/

int uz_end_central()    /* return PK-type error code */
{
    int error = PK_COOL;


/*---------------------------------------------------------------------------
    Get the zipfile comment (up to 64KB long), if any, and print it out.
    Then position the file pointer to the beginning of the central directory
    and fill buffer.
  ---------------------------------------------------------------------------*/

#ifdef MSWIN
    cchComment = ecrec.zipfile_comment_length; /* save for comment button */
    if (ecrec.zipfile_comment_length && (zflag > 0))
#else
    if (ecrec.zipfile_comment_length && (zflag > 0 || (zflag == 0 && !qflag)))
#endif
    {
#if 0
#ifndef MSWIN
        if (zflag == 0)       (add "&& single_zipfile" perhaps; unnecessary with
            PRINTF("[%s] comment:\n", zipfn);  multiple zipfiles: "Archive:...")
#endif /* !MSWIN */
#endif /* 0 */
        if (do_string(ecrec.zipfile_comment_length,DISPLAY)) {
            FPRINTF(stderr, LoadFarString(ZipfileCommTrunc1));
            error = PK_WARN;
        }
    }
    return error;

} /* end function uz_end_central() */





/************************************/
/* Function process_cdir_file_hdr() */
/************************************/

int process_cdir_file_hdr()    /* return PK-type error code */
{
    int error;


/*---------------------------------------------------------------------------
    Get central directory info, save host and method numbers, and set flag
    for lowercase conversion of filename, depending on the OS from which the
    file is coming.
  ---------------------------------------------------------------------------*/

    if ((error = get_cdir_ent()) != 0)
        return error;

    pInfo->hostnum = MIN(crec.version_made_by[1], NUM_HOSTS);
/*  extnum = MIN(crec.version_needed_to_extract[1], NUM_HOSTS); */

    pInfo->lcflag = 0;
    if (L_flag)               /* user specified case-conversion */
        switch (pInfo->hostnum) {
            case FS_FAT_:     /* PKZIP and zip -k store in uppercase */
            case ATARI_:      /* MS-DOS filesystem */
            case CPM_:        /* like MS-DOS, right? */
            case VM_CMS_:     /* all caps? */
            case TOPS20_:
            case VMS_:        /* our Zip uses lowercase, but ASi's doesn't */
        /*  case Z_SYSTEM_:   ? */
        /*  case QDOS_:       ? */
                pInfo->lcflag = 1;   /* convert filename to lowercase */
                break;

            default:     /* AMIGA_, FS_HPFS_, FS_NTFS_, MAC_, UNIX_, */
                break;   /*  (Z_SYSTEM_):  no conversion */
        }

    /* do Amigas (AMIGA_) also have volume labels? */
    if (IS_VOLID(crec.external_file_attributes) &&
        (pInfo->hostnum == FS_FAT_ || pInfo->hostnum == FS_HPFS_ ||
         pInfo->hostnum == FS_NTFS_ || pInfo->hostnum == ATARI_))
    {
        pInfo->vollabel = TRUE;
        pInfo->lcflag = 0;        /* preserve case of volume labels */
    } else
        pInfo->vollabel = FALSE;

    return PK_COOL;

} /* end function process_cdir_file_hdr() */





/*************************************/
/* Function process_local_file_hdr() */
/*************************************/

int process_local_file_hdr()    /* return PK-type error code */
{
    local_byte_hdr byterec;


/*---------------------------------------------------------------------------
    Read the next local file header and do any necessary machine-type con-
    versions (byte ordering, structure padding compensation--do so by copy-
    ing the data from the array into which it was read (byterec) to the
    usable struct (lrec)).
  ---------------------------------------------------------------------------*/

    if (readbuf((char *)byterec, LREC_SIZE) == 0)
        return PK_EOF;

    lrec.version_needed_to_extract[0] = byterec[L_VERSION_NEEDED_TO_EXTRACT_0];
    lrec.version_needed_to_extract[1] = byterec[L_VERSION_NEEDED_TO_EXTRACT_1];

    lrec.general_purpose_bit_flag = makeword(&byterec[L_GENERAL_PURPOSE_BIT_FLAG]);
    lrec.compression_method = makeword(&byterec[L_COMPRESSION_METHOD]);
    lrec.last_mod_file_time = makeword(&byterec[L_LAST_MOD_FILE_TIME]);
    lrec.last_mod_file_date = makeword(&byterec[L_LAST_MOD_FILE_DATE]);
    lrec.crc32 = makelong(&byterec[L_CRC32]);
    lrec.csize = makelong(&byterec[L_COMPRESSED_SIZE]);
    lrec.ucsize = makelong(&byterec[L_UNCOMPRESSED_SIZE]);
    lrec.filename_length = makeword(&byterec[L_FILENAME_LENGTH]);
    lrec.extra_field_length = makeword(&byterec[L_EXTRA_FIELD_LENGTH]);

    csize = (long) lrec.csize;
    ucsize = (long) lrec.ucsize;

    if ((lrec.general_purpose_bit_flag & 8) != 0) {
        /* can't trust local header, use central directory: */
        lrec.crc32 = pInfo->crc;
        csize = (long)(lrec.csize = pInfo->compr_size);
    }

    return PK_COOL;

} /* end function process_local_file_hdr() */
