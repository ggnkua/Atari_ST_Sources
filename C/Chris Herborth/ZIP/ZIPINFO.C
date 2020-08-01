/*---------------------------------------------------------------------------

  zipinfo.c

  This file contains all of the zipfile-listing routines for UnZip, inclu-
  ding the bulk of what used to be the separate program ZipInfo.  All of
  the ZipInfo routines are by Greg Roelofs; list_files is by the usual mish-
  mash of Info-ZIP contributors (see the listing in CONTRIBS).

  Contains:  zi_opts()
             zi_end_central()
             zipinfo()
             zi_long()
             zi_short()
             zi_time()
             list_files()
             ratio()
             fnprint()

  ---------------------------------------------------------------------------*/


#include "unzip.h"

static char unkn[16];

static int ratio OF((ulg uc, ulg c));
static void fnprint OF((void));


/********************************************/
/*  Strings used in zipinfo.c (UnZip half)  */
/********************************************/

/* also referenced in UpdateListBox() in updatelb.c (Windows version) */
char Far HeadersS[] = " Length    Date    Time    Name";
char Far HeadersS1[] = " ------    ----    ----    ----";
char Far HeadersL[] = " Length  Method   Size  Ratio   Date    Time   CRC-32     Name";
char Far HeadersL1[] = " ------  ------   ----  -----   ----    ----   ------     ----";
char Far *Headers[][2] = { {HeadersS, HeadersS1}, {HeadersL, HeadersL1} };

static char Far CaseConversion[] = "%s (\"^\" ==> case\n%s   conversion)\n";
static char Far CompFactorStr[] = "%c%d%%";
static char Far CompMethodUnknown[] = "Unk:%03d";
#ifdef MSWIN
   static char Far LongHdrStats[] =
     "%7lu  %-7s%7lu %4s  %02u-%02u-%02u  %02u:%02u  %08lx  %c%s";
   static char Far LongFileHeader[] =
     "%7lu         %7lu %4s                              %-7u";
   static char Far ShortHdrStats[] = "%7lu  %02u-%02u-%02u  %02u:%02u  %c%s";
   static char Far ShortFileHeader[] = "%7lu                    %-7u";
#else /* !MSWIN */
   static char Far LongHdrStats[] =
     "%7lu  %-7s%7lu %4s  %02u-%02u-%02u  %02u:%02u  %08lx  %c";
   static char Far ShortHdrStats[] = "%7lu  %02u-%02u-%02u  %02u:%02u  %c";
   static char Far LongFileHeader[] =
     " ------          ------  ---                         \
     -------\n%7lu         %7lu %4s                              %-7u\n";
   static char Far ShortFileHeader[] =
     " ------                    -------\n%7lu                    %-7u\n";
#endif /* ?MSWIN */



#ifndef NO_ZIPINFO  /* strings use up too much space in small-memory systems */

/* Define OS-specific attributes for use on ALL platforms--the S_xxxx
 * versions of these are defined differently (or not defined) by different
 * compilers and operating systems. */

#define UNX_IFMT       0170000     /* Unix file type mask */
#define UNX_IFDIR      0040000     /* Unix directory */
#define UNX_IFREG      0100000     /* Unix regular file */
#define UNX_IFSOCK     0140000     /* Unix socket (BSD, not SysV or Amiga) */
#define UNX_IFLNK      0120000     /* Unix symbolic link (not SysV, Amiga) */
#define UNX_IFBLK      0060000     /* Unix block special       (not Amiga) */
#define UNX_IFCHR      0020000     /* Unix character special   (not Amiga) */
#define UNX_IFIFO      0010000     /* Unix fifo    (BCC, not MSC or Amiga) */
#define UNX_ISUID      04000       /* Unix set user id on execution */
#define UNX_ISGID      02000       /* Unix set group id on execution */
#define UNX_ISVTX      01000       /* Unix directory permissions control */
#define UNX_ENFMT      UNX_ISGID   /* Unix record locking enforcement flag */
#define UNX_IRWXU      00700       /* Unix read, write, execute: owner */
#define UNX_IRUSR      00400       /* Unix read permission: owner */
#define UNX_IWUSR      00200       /* Unix write permission: owner */
#define UNX_IXUSR      00100       /* Unix execute permission: owner */
#define UNX_IRWXG      00070       /* Unix read, write, execute: group */
#define UNX_IRGRP      00040       /* Unix read permission: group */
#define UNX_IWGRP      00020       /* Unix write permission: group */
#define UNX_IXGRP      00010       /* Unix execute permission: group */
#define UNX_IRWXO      00007       /* Unix read, write, execute: other */
#define UNX_IROTH      00004       /* Unix read permission: other */
#define UNX_IWOTH      00002       /* Unix write permission: other */
#define UNX_IXOTH      00001       /* Unix execute permission: other */

#define VMS_IRUSR      UNX_IRUSR   /* VMS read/owner */
#define VMS_IWUSR      UNX_IWUSR   /* VMS write/owner */
#define VMS_IXUSR      UNX_IXUSR   /* VMS execute/owner */
#define VMS_IRGRP      UNX_IRGRP   /* VMS read/group */
#define VMS_IWGRP      UNX_IWGRP   /* VMS write/group */
#define VMS_IXGRP      UNX_IXGRP   /* VMS execute/group */
#define VMS_IROTH      UNX_IROTH   /* VMS read/other */
#define VMS_IWOTH      UNX_IWOTH   /* VMS write/other */
#define VMS_IXOTH      UNX_IXOTH   /* VMS execute/other */

#define AMI_IFMT       06000       /* Amiga file type mask */
#define AMI_IFDIR      04000       /* Amiga directory */
#define AMI_IFREG      02000       /* Amiga regular file */
#define AMI_IHIDDEN    00200       /* to be supported in AmigaDOS 3.x */
#define AMI_ISCRIPT    00100       /* executable script (text command file) */
#define AMI_IPURE      00040       /* allow loading into resident memory */
#define AMI_IARCHIVE   00020       /* not modified since bit was last set */
#define AMI_IREAD      00010       /* can be opened for reading */
#define AMI_IWRITE     00004       /* can be opened for writing */
#define AMI_IEXECUTE   00002       /* executable image, a loadable runfile */
#define AMI_IDELETE    00001       /* can be deleted */

/* extra-field ID values: */
#define EF_AV        0x0007   /* PKWARE authenticity verification */
#define EF_OS2       0x0009   /* OS/2 extended attributes */
#define EF_PKVMS     0x000c   /* PKWARE's VMS ID */
#define EF_IZVMS     0x4d49   /* Info-ZIP's VMS ID ("IM") */
#define EF_ASIUNIX   0x756e   /* ASi/PKWARE's Unix ID ("IM") */
#define EF_SPARK     0x4341   /* David Pilling's Acorn/SparkFS ID ("AC") */

#define LFLAG  3   /* short "ls -l" type listing */

static int   zi_long   OF((void));
static int   zi_short  OF((void));
static char *zi_time   OF((ush *datez, ush *timez));


/**********************************************/
/*  Strings used in zipinfo.c (ZipInfo half)  */
/**********************************************/

static char Far LongHeader[] = "Archive:  %s   %ld bytes   %d file%s\n";
static char Far ShortHeader[] = "Archive:  %s   %ld   %d\n";
static char Far EndCentDirRec[] = "\nEnd-of-central-directory record:\n";
static char Far LineSeparators[] = "-------------------------------\n\n";
static char Far ActOffsetCentDir[] = "\
  Actual offset of end-of-central-dir record:   %9ld (%.8lXh)\n\
  Expected offset of end-of-central-dir record: %9ld (%.8lXh)\n\
  (based on the length of the central directory and its expected offset)\n\n";
static char Far SinglePartArchive[] = "\
  This zipfile constitutes the sole disk of a single-part archive; its\n\
  central directory contains %u %s.  The central directory is %lu\n\
  (%.8lXh) bytes long, and its (expected) offset in bytes from the\n\
  beginning of the zipfile is %lu (%.8lXh).\n\n";
static char Far MultiPartArchive[] = "\
  This zipfile constitutes disk %u of a multi-part archive.  The central\n\
  directory starts on disk %u; %u of its entries %s contained within\n\
  this zipfile, out of a total of %u %s.  The entire central\n\
  directory is %lu (%.8lXh) bytes long, and its offset in bytes from\n\
  the beginning of the zipfile in which it begins is %lu (%.8lXh).\n\n";
static char Far NoZipfileComment[] = "  There is no zipfile comment.\n";
static char Far ZipfileCommentDesc[] =
  "  The zipfile comment is %u bytes long and contains the following text:\n\n";
static char Far ZipfileCommBegin[] =
 "======================== zipfile comment begins ==========================\n";
static char Far ZipfileCommEnd[] =
 "========================= zipfile comment ends ===========================\n";
static char Far ZipfileCommTrunc2[] = "\n  The zipfile comment is truncated.\n";
static char Far ZipfileCommTruncMsg[] =
  "\ncaution:  zipfile comment truncated\n";

#ifdef T20_VMS
   static char Far CentralDirEntry[] = "\nCentral directory entry #%d:\n";
#else
   static char Far CentralDirEntry[] = "%s\nCentral directory entry #%d:\n";
#endif

static char Far CentralDirLines[] = "---------------------------\n\n";
static char Far ZipfileStats[] = 
  "%d file%s, %lu bytes uncompressed, %lu bytes compressed:  %s%d.%d%%\n";

/* zi_long() strings */
static char Far OS_FAT[] = "MS-DOS, OS/2 or NT FAT";
static char Far OS_Amiga[] = "Amiga";
static char Far OS_VAXVMS[] = "VAX VMS";
static char Far OS_Unix[] = "Unix";
static char Far OS_VMCMS[] = "VM/CMS";
static char Far OS_AtariST[] = "Atari ST";
static char Far OS_HPFS[] = "OS/2 or NT HPFS";
static char Far OS_Macintosh[] = "Macintosh";
static char Far OS_ZSystem[] = "Z-System";
static char Far OS_CPM[] = "CP/M";
static char Far OS_TOPS20[] = "TOPS-20";
static char Far OS_NTFS[] = "NT NTFS";
static char Far OS_QDOS[] = "QDOS (maybe)";
static char Far OS_Acorn[] = "Acorn RISCOS";

static char Far MthdNone[] = "none (stored)";
static char Far MthdShrunk[] = "shrunk";
static char Far MthdRedF1[] = "reduced (factor 1)";
static char Far MthdRedF2[] = "reduced (factor 2)";
static char Far MthdRedF3[] = "reduced (factor 3)";
static char Far MthdRedF4[] = "reduced (factor 4)";
static char Far MthdImplode[] = "imploded";
static char Far MthdToken[] = "tokenized";
static char Far MthdDeflate[] = "deflated";

static char Far Unknown[] = "unknown (%d)";

static char Far HostOS[] =
  "\n  host operating system (created on):               %s\n";
static char Far EncodeSWVer[] =
  "  version of encoding software:                     %d.%d\n";
static char Far MinOSCompReq[] =
  "  minimum operating system compatibility required:  %s\n";
static char Far MinSWVerReq[] =
  "  minimum software version required to extract:     %d.%d\n";
static char Far CompressMethod[] =
  "  compression method:                               %s\n";
static char Far SlideWindowSizeImplode[] =
  "  size of sliding dictionary (implosion):           %cK\n";
static char Far ShannonFanoTrees[] =
  "  number of Shannon-Fano trees (implosion):         %c\n";
static char Far CompressSubtype[] =
  "  compression sub-type (deflation):                 %s\n";
static char Far FileSecurity[] =
  "  file security status:                             %sencrypted\n";
static char Far ExtendedLocalHdr[] =
  "  extended local header:                            %s\n";
static char Far FileModDate[] =
  "  file last modified on:                            %s\n";
static char Far CRC32Value[] =
  "  32-bit CRC value (hex):                           %.8lx\n";
static char Far CompressedFileSize[] =
  "  compressed size:                                  %lu bytes\n";
static char Far UncompressedFileSize[] =
  "  uncompressed size:                                %lu bytes\n";
static char Far FilenameLength[] =
  "  length of filename:                               %u characters\n";
static char Far ExtraFieldLength[] =
  "  length of extra field:                            %u bytes\n";
static char Far FileCommentLength[] =
  "  length of file comment:                           %u characters\n";
static char Far FileDiskNum[] =
  "  disk number on which file begins:                 disk %u\n";
static char Far ApparentFileType[] =
  "  apparent file type:                               %s\n";
static char Far VMSFileAttributes[] =
  "  VMS file attributes (%06o octal):               %s\n";
static char Far AmigaFileAttributes[] =
  "  Amiga file attributes (%06o octal):             %s\n";
static char Far UnixFileAttributes[] =
  "  Unix file attributes (%06o octal):              %s\n";
static char Far NonMSDOSFileAttributes[] =
  "  non-MSDOS external file attributes:               %06lX hex\n";
static char Far MSDOSFileAttributes[] =
  "  MS-DOS file attributes (%02X hex):                  none\n";
static char Far MSDOSFileAttributesRO[] =
  "  MS-DOS file attributes (%02X hex):                  read-only\n";
static char Far MSDOSFileAttributesAlpha[] =
  "  MS-DOS file attributes (%02X hex):                  %s%s%s%s%s%s\n";
static char Far LocalHeaderOffset[] =
  "  offset of local header from start of archive:     %lu (%.8lXh) bytes\n";
static char Far ExtraFieldType[] = "\n\
  The central-directory extra field has ID 0x%04x (%s) and has %u\n\
  data bytes";
static char Far OS2EAs[] = "\
.  The local extra field has %lu bytes of OS/2 extended\n\
  attributes (may not match OS/2 \"dir\" amount due to storage method).";
static char Far First16[] = ".  The first 16 are%s";
static char Far ColonIndent[] = ":\n     ";
static char Far efFormat[] = " %02x";
static char Far efAV[] = "PKWARE AV";
static char Far efOS2[] = "OS/2";
static char Far efPKVMS[] = "PKWARE VMS";
static char Far efIZVMS[] = "Info-ZIP VMS";
static char Far efASiUnix[] = "ASi Unix";
/* static char Far efIZUnix[] = "Info-ZIP Unix"; */
static char Far efSpark[] = "Acorn SparkFS";
static char Far efUnknown[] = "unknown";
static char Far NoFileComment[] = "\n  There is no file comment.\n";
static char Far FileCommBegin[] = "\n\
------------------------- file comment begins ----------------------------\n";
static char Far FileCommEnd[] = "\
-------------------------- file comment ends -----------------------------\n";
static char Far JanMonth[] = "Jan";
static char Far FebMonth[] = "Feb";
static char Far MarMonth[] = "Mar";
static char Far AprMonth[] = "Apr";
static char Far MayMonth[] = "May";
static char Far JunMonth[] = "Jun";
static char Far JulMonth[] = "Jul";
static char Far AugMonth[] = "Aug";
static char Far SepMonth[] = "Sep";
static char Far OctMonth[] = "Oct";
static char Far NovMonth[] = "Nov";
static char Far DecMonth[] = "Dec";
static char Far BogusFmt[] = "%03d";
static char Far DMYHMTime[] = "%2u-%s-%02u %02u:%02u";
static char Far YMDHMSTime[] = "%u %s %u %02u:%02u:%02u";
static char Far DecimalTime[] = "%02u%02u%02u.%02u%02u%02u";





/************************/
/*  Function zi_opts()  */
/************************/

int zi_opts(pargc, pargv)
    int *pargc;
    char ***pargv;
{
    char   **argv, *s;
    int    argc, c, error=FALSE, negative=0;
    int    hflag_slmv=TRUE, hflag_2=FALSE;  /* diff options => diff defaults */
    int    tflag_slm=TRUE, tflag_2v=FALSE;
    int    explicit_h=FALSE, explicit_t=FALSE;


#ifdef MACOS
    lflag = LFLAG;   /* reset default on each call */
#endif
    argc = *pargc;
    argv = *pargv;

    while (--argc > 0 && (*++argv)[0] == '-') {
        s = argv[0] + 1;
        while ((c = *s++) != 0) {    /* "!= 0":  prevent Turbo C warning */
            switch (c) {
                case '-':
                    ++negative;
                    break;
                case '1':      /* shortest listing:  JUST filenames */
                    if (negative)
                        lflag = -2, negative = 0;
                    else
                        lflag = 1;
                    break;
                case '2':      /* just filenames, plus headers if specified */
                    if (negative)
                        lflag = -2, negative = 0;
                    else
                        lflag = 2;
                    break;
                case 'h':      /* header line */
                    if (negative)
                        hflag_2 = hflag_slmv = FALSE, negative = 0;
                    else {
                        hflag_2 = hflag_slmv = explicit_h = TRUE;
                        if (lflag == -1)
                            lflag = 0;
                    }
                    break;
                case 'l':      /* longer form of "ls -l" type listing */
                    if (negative)
                        lflag = -2, negative = 0;
                    else
                        lflag = 5;
                    break;
                case 'm':      /* medium form of "ls -l" type listing */
                    if (negative)
                        lflag = -2, negative = 0;
                    else
                        lflag = 4;
                    break;
                case 's':      /* default:  shorter "ls -l" type listing */
                    if (negative)
                        lflag = -2, negative = 0;
                    else
                        lflag = 3;
                    break;
                case 't':      /* totals line */
                    if (negative)
                        tflag_2v = tflag_slm = FALSE, negative = 0;
                    else {
                        tflag_2v = tflag_slm = explicit_t = TRUE;
                        if (lflag == -1)
                            lflag = 0;
                    }
                    break;
                case ('T'):    /* use (sortable) decimal time format */
                    if (negative)
                        T_flag = FALSE, negative = 0;
                    else
                        T_flag = TRUE;
                    break;
                case 'v':      /* turbo-verbose listing */
                    if (negative)
                        lflag = -2, negative = 0;
                    else
                        lflag = 10;
                    break;
                case 'z':      /* print zipfile comment */
                    if (negative)
                        zflag = negative = 0;
                    else
                        zflag = 1;
                    break;
                case 'Z':      /* ZipInfo mode:  ignore */
                    break;
                default:
                    error = TRUE;
                    break;
            }
        }
    }
    if ((argc-- == 0) || error) {
        *pargc = argc;
        *pargv = argv;
        return usage(error);
    }

    /* if no listing options given (or all negated), or if only -h/-t given
     * with individual files specified, use default listing format */
    if ((lflag < 0) || ((argc > 0) && (lflag == 0)))
        lflag = LFLAG;

    /* set header and totals flags to default or specified values */
    switch (lflag) {
        case 0:   /* 0:  can only occur if either -t or -h explicitly given; */
        case 2:   /*  therefore set both flags equal to normally false value */
            hflag = hflag_2;
            tflag = tflag_2v;
            break;
        case 1:   /* only filenames, *always* */
            hflag = FALSE;
            tflag = FALSE;
            zflag = FALSE;
            break;
        case 3:
        case 4:
        case 5:
            hflag = ((argc > 0) && !explicit_h)? FALSE : hflag_slmv;
            tflag = ((argc > 0) && !explicit_t)? FALSE : tflag_slm;
            break;
        case 10:
            hflag = hflag_slmv;
            tflag = tflag_2v;
            break;
    }

    *pargc = argc;
    *pargv = argv;
    return 0;

} /* end function zi_opts() */





/*******************************/
/*  Function zi_end_central()  */
/*******************************/

int zi_end_central()   /* return PK-type error code */
{
    int  error = PK_COOL;


/*---------------------------------------------------------------------------
    Print out various interesting things about the zipfile.
  ---------------------------------------------------------------------------*/

    /* header fits on one line, for anything up to 10GB and 10000 files: */
    if (hflag)
        PRINTF(((int)strlen(zipfn) < 39)?
          LoadFarString(LongHeader) :
          LoadFarString(ShortHeader), zipfn, (long)ziplen,
          ecrec.total_entries_central_dir,
          (ecrec.total_entries_central_dir==1)? "":"s");

    /* verbose format */
    if (lflag > 9) {
        PRINTF(LoadFarString(EndCentDirRec));
        PRINTF(LoadFarString(LineSeparators));

        PRINTF(LoadFarString(ActOffsetCentDir),
          (long)real_ecrec_offset, (long)real_ecrec_offset,
          (long)expect_ecrec_offset, (long)expect_ecrec_offset);

        if (ecrec.number_this_disk == 0) {
            PRINTF(LoadFarString(SinglePartArchive),
              ecrec.total_entries_central_dir,
              (ecrec.total_entries_central_dir == 1)? "entry" : "entries",
              ecrec.size_central_directory, ecrec.size_central_directory,
              ecrec.offset_start_central_directory,
              ecrec.offset_start_central_directory);
        } else {
            PRINTF(LoadFarString(MultiPartArchive),
              ecrec.number_this_disk,
              ecrec.num_disk_with_start_central_dir,
              ecrec.num_entries_centrl_dir_ths_disk,
              (ecrec.num_entries_centrl_dir_ths_disk == 1)? "is" : "are",
              ecrec.total_entries_central_dir,
              (ecrec.total_entries_central_dir == 1) ? "entry" : "entries",
              ecrec.size_central_directory, ecrec.size_central_directory,
              ecrec.offset_start_central_directory,
              ecrec.offset_start_central_directory);
        }

    /*-----------------------------------------------------------------------
        Get the zipfile comment, if any, and print it out.  (Comment may be
        up to 64KB long.  May the fleas of a thousand camels infest the arm-
        pits of anyone who actually takes advantage of this fact.)
      -----------------------------------------------------------------------*/

        if (!ecrec.zipfile_comment_length)
            PRINTF(LoadFarString(NoZipfileComment));
        else {
            PRINTF(LoadFarString(ZipfileCommentDesc),
              ecrec.zipfile_comment_length );
            PRINTF(LoadFarString(ZipfileCommBegin));
            if (do_string(ecrec.zipfile_comment_length, DISPLAY))
                error = PK_WARN;
            PRINTF(LoadFarString(ZipfileCommEnd));
            if (error)
                PRINTF(LoadFarString(ZipfileCommTrunc2));
        } /* endif (comment exists) */

    /* non-verbose mode:  print zipfile comment only if requested */
    } else if (zflag && ecrec.zipfile_comment_length) {
        if (do_string(ecrec.zipfile_comment_length,DISPLAY)) {
            FPRINTF(stderr, LoadFarString(ZipfileCommTruncMsg));
            error = PK_WARN;
        }
    } /* endif (verbose) */

    return error;

} /* end function zi_end_central() */





/************************/
/*  Function zipinfo()  */
/************************/

int zipinfo()   /* return PK-type error code */
{
    int   j, do_this_file=FALSE, error, error_in_archive=PK_COOL;
    int   *fn_matched=NULL, *xn_matched=NULL;
    ush   members=0;
    ulg   tot_csize=0L, tot_ucsize=0L;


/*---------------------------------------------------------------------------
    Malloc space for check on unmatched filespecs (no big deal if one or both
    are NULL).
  ---------------------------------------------------------------------------*/

    if (filespecs > 0  &&
        (fn_matched=(int *)malloc(filespecs*sizeof(int))) != NULL)
        for (j = 0;  j < filespecs;  ++j)
            fn_matched[j] = FALSE;

    if (xfilespecs > 0  &&
        (xn_matched=(int *)malloc(xfilespecs*sizeof(int))) != NULL)
        for (j = 0;  j < xfilespecs;  ++j)
            xn_matched[j] = FALSE;

/*---------------------------------------------------------------------------
    Set file pointer to start of central directory, then loop through cen-
    tral directory entries.  Check that directory-entry signature bytes are
    actually there (just a precaution), then process the entry.  We know
    the entire central directory is on this disk:  we wouldn't have any of
    this information unless the end-of-central-directory record was on this
    disk, and we wouldn't have gotten to this routine unless this is also
    the disk on which the central directory starts.  In practice, this had
    better be the *only* disk in the archive, but maybe someday we'll add
    multi-disk support.
  ---------------------------------------------------------------------------*/

    pInfo->lcflag = 0;    /* used in do_string():  never TRUE in zipinfo mode */
    pInfo->textmode = 0;  /* so one can read on screen (but is it ever used?) */

    for (j = 0;  j < (int)ecrec.total_entries_central_dir;  ++j) {
        if (readbuf(sig, 4) == 0)
            return PK_EOF;
        if (strncmp(sig, central_hdr_sig, 4)) {  /* just to make sure */
            FPRINTF(stderr, LoadFarString(CentSigMsg), j);  /* sig not found */
            return PK_BADERR;
        }
        if ((error = get_cdir_ent()) != PK_COOL)
            return error;       /* only PK_EOF defined */

        /* do Amigas (AMIGA_) also have volume labels? */
        if (IS_VOLID(crec.external_file_attributes) &&
            (pInfo->hostnum == FS_FAT_ || pInfo->hostnum == FS_HPFS_ ||
             pInfo->hostnum == FS_NTFS_ || pInfo->hostnum == ATARI_))
            pInfo->vollabel = TRUE;
        else
            pInfo->vollabel = FALSE;

        if ((error = do_string(crec.filename_length, FILENAME)) != PK_COOL) {
          error_in_archive = error;   /* might be warning */
          if (error > PK_WARN)        /* fatal */
              return error;
        }

        if (!process_all_files) {    /* check if specified on command line */
            char  **pfn = pfnames-1;

            do_this_file = FALSE;
            while (*++pfn)
                if (match(filename, *pfn, 0)) {
                    do_this_file = TRUE;
                    if (fn_matched)
                        fn_matched[pfn-pfnames] = TRUE;
                    break;       /* found match, so stop looping */
                }
            if (do_this_file) {  /* check if this is an excluded file */
                char  **pxn = pxnames-1;

                while (*++pxn)
                    if (match(filename, *pxn, 0)) {
                        do_this_file = FALSE;
                        if (xn_matched)
                            xn_matched[pxn-pxnames] = TRUE;
                        break;
                    }
            }
        }

    /*-----------------------------------------------------------------------
        If current file was specified on command line, or if no names were
        specified, do the listing for this file.  Otherwise, get rid of the
        file comment and go back for the next file.
      -----------------------------------------------------------------------*/

        if (process_all_files || do_this_file) {

            switch (lflag) {
                case 1:
                case 2:
                    fnprint();
                    SKIP_(crec.extra_field_length)
                    SKIP_(crec.file_comment_length)
                    break;

                case 3:
                case 4:
                case 5:
                    if ((error = zi_short()) != PK_COOL) {
                        error_in_archive = error;   /* might be warning */
                        if (error > PK_WARN)        /* fatal */
                            return error;
                    }
                    break;

                case 10:
#ifdef T20_VMS  /* GRR:  add cbreak-style "more" */
                    PRINTF(LoadFarString(CentralDirEntry), j);
#else
                    /* formfeed/CR for piping to "more": */
                    PRINTF(LoadFarString(CentralDirEntry), "\014", j);
#endif
                    PRINTF(LoadFarString(CentralDirLines));

                    if ((error = zi_long()) != PK_COOL) {
                        error_in_archive = error;   /* might be warning */
                        if (error > PK_WARN)        /* fatal */
                            return error;
                    }
                    break;

                default:
                    SKIP_(crec.extra_field_length)
                    SKIP_(crec.file_comment_length)
                    break;

            } /* end switch (lflag) */

            tot_csize += crec.csize;
            tot_ucsize += crec.ucsize;
            if (crec.general_purpose_bit_flag & 1)
                tot_csize -= 12;   /* don't count encryption header */
            ++members;

        } else {   /* not listing */
            SKIP_(crec.extra_field_length)
            SKIP_(crec.file_comment_length)

        } /* end if (list member?) */

    } /* end for-loop (j: member files) */

/*---------------------------------------------------------------------------
    Double check that we're back at the end-of-central-directory record.
  ---------------------------------------------------------------------------*/

    if (readbuf(sig, 4) == 0)  /* disk error? */
        return PK_EOF;
    if (strncmp(sig, end_central_sig, 4)) {     /* just to make sure again */
        FPRINTF(stderr, LoadFarString(EndSigMsg));  /* didn't find sig */
        error_in_archive = PK_WARN;
    }

/*---------------------------------------------------------------------------
    Check that we actually found requested files; if so, print totals.
  ---------------------------------------------------------------------------*/

    if (tflag) {
        char *sgn = "";
        int cfactor = ratio(tot_ucsize, tot_csize);

        if (cfactor < 0) {
            sgn = "-";
            cfactor = -cfactor;
        }
        PRINTF(LoadFarString(ZipfileStats),
          members, (members==1)? "":"s", tot_ucsize, tot_csize, sgn, cfactor/10,
          cfactor%10);
    }

/*---------------------------------------------------------------------------
    Check for unmatched filespecs on command line and print warning if any
    found.
  ---------------------------------------------------------------------------*/

    if (fn_matched) {
        for (j = 0;  j < filespecs;  ++j)
            if (!fn_matched[j])
                FPRINTF(stderr, LoadFarString(FilenameNotMatched),
                  pfnames[j]);
        free(fn_matched);
    }
    if (xn_matched) {
        for (j = 0;  j < xfilespecs;  ++j)
            if (!xn_matched[j])
                FPRINTF(stderr, LoadFarString(ExclFilenameNotMatched),
                  pxnames[j]);
        free(xn_matched);
    }
    if (members == 0 && error_in_archive <= PK_WARN)
        error_in_archive = PK_FIND;

    return error_in_archive;

} /* end function zipinfo() */





#define OS_unkn unkn

/************************/
/*  Function zi_long()  */
/************************/

static int zi_long()   /* return PK-type error code */
{
    int  error, error_in_archive=PK_COOL;
    ush  hostnum, hostver, extnum, extver, methnum, xattr;
    char workspace[12], attribs[22];
    static char meth_unkn[16];
    static char Far *os[NUM_HOSTS+1] = {
        OS_FAT, OS_Amiga, OS_VAXVMS, OS_Unix, OS_VMCMS, OS_AtariST, OS_HPFS,
        OS_Macintosh, OS_ZSystem, OS_CPM, OS_TOPS20, OS_NTFS, OS_QDOS,
        OS_Acorn, OS_unkn
    };
    static char Far *method[NUM_METHODS+1] = {
        MthdNone, MthdShrunk, MthdRedF1, MthdRedF2, MthdRedF3, MthdRedF4,
        MthdImplode, MthdToken, MthdDeflate, meth_unkn
    };
    static char *dtype[4] = {"normal", "maximum", "fast", "superfast"};


/*---------------------------------------------------------------------------
    Print out various interesting things about the compressed file.
  ---------------------------------------------------------------------------*/

    hostnum = MIN(crec.version_made_by[1], NUM_HOSTS);
    hostver = crec.version_made_by[0];
    extnum = MIN(crec.version_needed_to_extract[1], NUM_HOSTS);
    extver = crec.version_needed_to_extract[0];
    methnum = MIN(crec.compression_method, NUM_METHODS);

    if (hostnum == NUM_HOSTS)
        sprintf(OS_unkn, LoadFarString(Unknown), (int)crec.version_made_by[1]);
    if (methnum == NUM_METHODS)
        sprintf(meth_unkn, LoadFarString(Unknown), crec.compression_method);

    putchar(' ');  putchar(' ');  fnprint();

    PRINTF(LoadFarString(HostOS), LoadFarStringSmall(os[hostnum]));
    PRINTF(LoadFarString(EncodeSWVer), hostver/10, hostver%10);
    PRINTF(LoadFarString(MinOSCompReq), LoadFarStringSmall(os[extnum]));
    PRINTF(LoadFarString(MinSWVerReq), extver/10, extver%10);
    PRINTF(LoadFarString(CompressMethod), LoadFarStringSmall(method[methnum]));
    if (methnum == IMPLODED) {
        PRINTF(LoadFarString(SlideWindowSizeImplode),
          (crec.general_purpose_bit_flag & 2)? '8' : '4');
        PRINTF(LoadFarString(ShannonFanoTrees),
          (crec.general_purpose_bit_flag & 4)? '3' : '2');
    } else if (methnum == DEFLATED) {
        ush  dnum=(crec.general_purpose_bit_flag>>1) & 3;
        PRINTF(LoadFarString(CompressSubtype), dtype[dnum]);
    }
    PRINTF(LoadFarString(FileSecurity),
      (crec.general_purpose_bit_flag & 1)? "" : "not ");
    PRINTF(LoadFarString(ExtendedLocalHdr),
      (crec.general_purpose_bit_flag & 8)? "yes" : "no");
    /* print upper 3 bits for amusement? */
    PRINTF(LoadFarString(FileModDate),
      zi_time(&crec.last_mod_file_date, &crec.last_mod_file_time));
    PRINTF(LoadFarString(CRC32Value), crec.crc32);
    PRINTF(LoadFarString(CompressedFileSize), crec.csize);
    PRINTF(LoadFarString(UncompressedFileSize), crec.ucsize);
    PRINTF(LoadFarString(FilenameLength), crec.filename_length);
    PRINTF(LoadFarString(ExtraFieldLength), crec.extra_field_length);
    PRINTF(LoadFarString(FileCommentLength), crec.file_comment_length);
    PRINTF(LoadFarString(FileDiskNum), crec.disk_number_start);
    PRINTF(LoadFarString(ApparentFileType),
      (crec.internal_file_attributes & 1)? "text" : "binary");
/*
    PRINTF("  external file attributes (hex):                   %.8lx\n",
      crec.external_file_attributes);
 */
    xattr = (ush)((crec.external_file_attributes >> 16) & 0xFFFF);
    if (hostnum == VMS_) {
        char   *p=attribs, *q=attribs+1;
        int    i, j, k;

        for (k = 0;  k < 12;  ++k)
            workspace[k] = 0;
        if (xattr & VMS_IRUSR)
            workspace[0] = 'R';
        if (xattr & VMS_IWUSR) {
            workspace[1] = 'W';
            workspace[3] = 'D';
        }
        if (xattr & VMS_IXUSR)
            workspace[2] = 'E';
        if (xattr & VMS_IRGRP)
            workspace[4] = 'R';
        if (xattr & VMS_IWGRP) {
            workspace[5] = 'W';
            workspace[7] = 'D';
        }
        if (xattr & VMS_IXGRP)
            workspace[6] = 'E';
        if (xattr & VMS_IROTH)
            workspace[8] = 'R';
        if (xattr & VMS_IWOTH) {
            workspace[9] = 'W';
            workspace[11] = 'D';
        }
        if (xattr & VMS_IXOTH)
            workspace[10] = 'E';

        *p++ = '(';
        for (k = j = 0;  j < 3;  ++j) {    /* loop over groups of permissions */
            for (i = 0;  i < 4;  ++i, ++k)  /* loop over perms within a group */
                if (workspace[k])
                    *p++ = workspace[k];
            *p++ = ',';                       /* group separator */
            if (j == 0)
                while ((*p++ = *q++) != ','); /* system, owner perms are same */
        }
        *p-- = 0;
        *p = ')';   /* overwrite last comma */
        PRINTF(LoadFarString(VMSFileAttributes), xattr, attribs);

    } else if (hostnum == AMIGA_) {
        switch (xattr & AMI_IFMT) {
            case AMI_IFDIR:  attribs[0] = 'd';  break;
            case AMI_IFREG:  attribs[0] = '-';  break;
            default:         attribs[0] = '?';  break;
        }
        attribs[1] = (xattr & AMI_IHIDDEN)?   'h' : '-';
        attribs[2] = (xattr & AMI_ISCRIPT)?   's' : '-';
        attribs[3] = (xattr & AMI_IPURE)?     'p' : '-';
        attribs[4] = (xattr & AMI_IARCHIVE)?  'a' : '-';
        attribs[5] = (xattr & AMI_IREAD)?     'r' : '-';
        attribs[6] = (xattr & AMI_IWRITE)?    'w' : '-';
        attribs[7] = (xattr & AMI_IEXECUTE)?  'e' : '-';
        attribs[8] = (xattr & AMI_IDELETE)?   'd' : '-';
        attribs[9] = 0;   /* better dlm the string */
        PRINTF(LoadFarString(AmigaFileAttributes), xattr, attribs);

    } else if ((hostnum != FS_FAT_) && (hostnum != FS_HPFS_) &&
               (hostnum != FS_NTFS_) && (hostnum != ATARI_) &&
               (hostnum != ACORN_))
    {                                 /* assume Unix-like */
        switch (xattr & UNX_IFMT) {
            case UNX_IFDIR:   attribs[0] = 'd';  break;
            case UNX_IFREG:   attribs[0] = '-';  break;
            case UNX_IFLNK:   attribs[0] = 'l';  break;
            case UNX_IFBLK:   attribs[0] = 'b';  break;
            case UNX_IFCHR:   attribs[0] = 'c';  break;
            case UNX_IFIFO:   attribs[0] = 'p';  break;
            case UNX_IFSOCK:  attribs[0] = 's';  break;
            default:          attribs[0] = '?';  break;
        }
        attribs[1] = (xattr & UNX_IRUSR)? 'r' : '-';
        attribs[4] = (xattr & UNX_IRGRP)? 'r' : '-';
        attribs[7] = (xattr & UNX_IROTH)? 'r' : '-';

        attribs[2] = (xattr & UNX_IWUSR)? 'w' : '-';
        attribs[5] = (xattr & UNX_IWGRP)? 'w' : '-';
        attribs[8] = (xattr & UNX_IWOTH)? 'w' : '-';

        if (xattr & UNX_IXUSR)
            attribs[3] = (xattr & UNX_ISUID)? 's' : 'x';
        else
            attribs[3] = (xattr & UNX_ISUID)? 'S' : '-';   /* S = undefined */
        if (xattr & UNX_IXGRP)
            attribs[6] = (xattr & UNX_ISGID)? 's' : 'x';   /* == UNX_ENFMT */
        else
            attribs[6] = (xattr & UNX_ISGID)? 'l' : '-';
        if (xattr & UNX_IXOTH)
            attribs[9] = (xattr & UNX_ISVTX)? 't' : 'x';   /* "sticky bit" */
        else
            attribs[9] = (xattr & UNX_ISVTX)? 'T' : '-';   /* T = undefined */
        attribs[10] = 0;

        PRINTF(LoadFarString(UnixFileAttributes), xattr, attribs);

    } else {
        PRINTF(LoadFarString(NonMSDOSFileAttributes),
            crec.external_file_attributes >> 8);

    } /* endif (hostnum: external attributes format) */

    if ((xattr=(ush)(crec.external_file_attributes & 0xFF)) == 0)
        PRINTF(LoadFarString(MSDOSFileAttributes), xattr);
    else if (xattr == 1)
        PRINTF(LoadFarString(MSDOSFileAttributesRO), xattr);
    else
        PRINTF(LoadFarString(MSDOSFileAttributesAlpha),
          xattr, (xattr&1)?"rdo ":"", (xattr&2)?"hid ":"", (xattr&4)?"sys ":"",
          (xattr&8)?"lab ":"", (xattr&16)?"dir ":"", (xattr&32)?"arc":"");
    PRINTF(LoadFarString(LocalHeaderOffset),
      crec.relative_offset_local_header, crec.relative_offset_local_header);

/*---------------------------------------------------------------------------
    Skip the extra field, if any, and print the file comment, if any (the
    filename has already been printed, above).  That finishes up this file
    entry...
  ---------------------------------------------------------------------------*/

    if (crec.extra_field_length > 0) {
        ush ef_id, ef_datalen;

        if ((error = do_string(crec.extra_field_length, EXTRA_FIELD)) != 0) {
            error_in_archive = error;
            if (error > PK_WARN)   /* fatal:  can't continue */
                return error;
        }
        if (extra_field == (uch *)NULL)
            return PK_ERR;   /* not consistent with crec length */
        ef_id = makeword(extra_field);
        ef_datalen = makeword(&extra_field[2]);
        switch (ef_id) {
            case EF_AV:
                PRINTF(LoadFarString(ExtraFieldType), ef_id,
                  LoadFarStringSmall(efAV), ef_datalen);
                break;
            case EF_OS2:
                PRINTF(LoadFarString(ExtraFieldType), ef_id,
                  LoadFarStringSmall(efOS2), ef_datalen);
/* GRR:  should check that ef_datalen really 4 and not 2 before doing this: */
                PRINTF(LoadFarString(OS2EAs), makelong(&extra_field[4]));
                break;
            case EF_PKVMS:
                PRINTF(LoadFarString(ExtraFieldType), ef_id,
                  LoadFarStringSmall(efPKVMS), ef_datalen);
                break;
            case EF_IZVMS:
                PRINTF(LoadFarString(ExtraFieldType), ef_id,
                  LoadFarStringSmall(efIZVMS), ef_datalen);
                break;
            case EF_ASIUNIX:
                PRINTF(LoadFarString(ExtraFieldType), ef_id,
                  LoadFarStringSmall(efASiUnix), ef_datalen);
                break;
            case EF_SPARK:
                PRINTF(LoadFarString(ExtraFieldType), ef_id,
                  LoadFarStringSmall(efSpark), ef_datalen);
                break;
            default:
                PRINTF(LoadFarString(ExtraFieldType), ef_id,
                  LoadFarStringSmall(efUnknown), ef_datalen);
                break;
        }
        if (ef_id != EF_OS2) {
            ush i, n;

            if (ef_datalen <= 16) {
                PRINTF(LoadFarString(ColonIndent));
/* GRR:  should double-check that datalen <= crec.extra_field_length - 4 */
                n = ef_datalen;
            } else {
                PRINTF(LoadFarString(First16),
                  LoadFarStringSmall(ColonIndent));
                n = 16;
            }
            for (i = 0;  i < n;  ++i)
                PRINTF(LoadFarString(efFormat), extra_field[i+4]);
        }
        PRINTF("\n");
    }

    if (!crec.file_comment_length)
        PRINTF(LoadFarString(NoFileComment));
    else {
        PRINTF(LoadFarString(FileCommBegin));
        if ((error = do_string(crec.file_comment_length, DISPLAY)) != PK_COOL) {
          error_in_archive = error;   /* might be warning */
          if (error > PK_WARN)   /* fatal */
              return error;
        }
        PRINTF(LoadFarString(FileCommEnd));
    }

    return error_in_archive;

} /* end function zi_long() */





/*************************/
/*  Function zi_short()  */
/*************************/

static int zi_short()   /* return PK-type error code */
{
    int         k, error, error_in_archive=PK_COOL;
    ush         methnum, hostnum, hostver, xattr;
    char        *p, workspace[12], attribs[16];
    static char impl[5]="i#:#", defl[5]="def#";
    static char dtype[5]="NXFS";  /* normal, maximum, fast, superfast */
    static char *os[NUM_HOSTS+1] = {
        "fat", "ami", "vms", "unx", "cms", "atr", "hpf", "mac", "zzz",
        "cpm", "t20", "ntf", "qds", "aco", "???"
    };
    static char *method[NUM_METHODS+1] = {
        "stor", "shrk", "re:1", "re:2", "re:3", "re:4", impl, "tokn",
        defl, unkn
    };


/*---------------------------------------------------------------------------
    Print out various interesting things about the compressed file.
  ---------------------------------------------------------------------------*/

    methnum = MIN(crec.compression_method, NUM_METHODS);
    hostnum = MIN(crec.version_made_by[1], NUM_HOSTS);
    hostver = crec.version_made_by[0];
/*
    extnum = MIN(crec.version_needed_to_extract[1], NUM_HOSTS);
    extver = crec.version_needed_to_extract[0];
 */

    if (methnum == IMPLODED) {
        impl[1] = (char) ((crec.general_purpose_bit_flag & 2)? '8' : '4');
        impl[3] = (char) ((crec.general_purpose_bit_flag & 4)? '3' : '2');
    } else if (methnum == DEFLATED) {
        ush  dnum=(crec.general_purpose_bit_flag>>1) & 3;
        defl[3] = dtype[dnum];
    } else if (methnum == NUM_METHODS) {   /* unknown */
        sprintf(unkn, "u%03d", crec.compression_method);
    }

    for (k = 0;  k < 15;  ++k)
        attribs[k] = ' ';
    attribs[15] = 0;

    xattr = (ush)((crec.external_file_attributes >> 16) & 0xFFFF);
    switch (hostnum) {
        case VMS_:
            {   int    i, j;

                for (k = 0;  k < 12;  ++k)
                    workspace[k] = 0;
                if (xattr & VMS_IRUSR)
                    workspace[0] = 'R';
                if (xattr & VMS_IWUSR) {
                    workspace[1] = 'W';
                    workspace[3] = 'D';
                }
                if (xattr & VMS_IXUSR)
                    workspace[2] = 'E';
                if (xattr & VMS_IRGRP)
                    workspace[4] = 'R';
                if (xattr & VMS_IWGRP) {
                    workspace[5] = 'W';
                    workspace[7] = 'D';
                }
                if (xattr & VMS_IXGRP)
                  workspace[6] = 'E';
                if (xattr & VMS_IROTH)
                    workspace[8] = 'R';
                if (xattr & VMS_IWOTH) {
                    workspace[9] = 'W';
                    workspace[11] = 'D';
                }
                if (xattr & VMS_IXOTH)
                    workspace[10] = 'E';

                p = attribs;
                for (k = j = 0;  j < 3;  ++j) {     /* groups of permissions */
                    for (i = 0;  i < 4;  ++i, ++k)  /* perms within a group */
                        if (workspace[k])
                            *p++ = workspace[k];
                    *p++ = ',';                     /* group separator */
                }
                *--p = ' ';   /* overwrite last comma */
                if ((p - attribs) < 12)
                    sprintf(&attribs[12], "%d.%d", hostver/10, hostver%10);
            }
            break;

        case FS_FAT_:
        case FS_HPFS_:
        case FS_NTFS_:
        case ATARI_:
        case ACORN_:
            xattr = (ush)(crec.external_file_attributes & 0xFF);
            sprintf(attribs, ".r.-...     %d.%d", hostver/10, hostver%10);
            attribs[2] = (xattr & 0x01)? '-' : 'w';
            attribs[5] = (xattr & 0x02)? 'h' : '-';
            attribs[6] = (xattr & 0x04)? 's' : '-';
            attribs[4] = (xattr & 0x20)? 'a' : '-';
            if (xattr & 0x10) {
                attribs[0] = 'd';
                attribs[3] = 'x';
            } else
                attribs[0] = '-';
            if (IS_VOLID(xattr))
                attribs[0] = 'V';
            else if ((p = strrchr(filename, '.')) != (char *)NULL) {
                ++p;
                if (STRNICMP(p, "com", 3) == 0 || STRNICMP(p, "exe", 3) == 0 ||
                    STRNICMP(p, "btm", 3) == 0 || STRNICMP(p, "cmd", 3) == 0 ||
                    STRNICMP(p, "bat", 3) == 0)
                    attribs[3] = 'x';
            }
            break;

        case AMIGA_:
            switch (xattr & AMI_IFMT) {
                case AMI_IFDIR:  attribs[0] = 'd';  break;
                case AMI_IFREG:  attribs[0] = '-';  break;
                default:         attribs[0] = '?';  break;
            }
            attribs[1] = (xattr & AMI_IHIDDEN)?   'h' : '-';
            attribs[2] = (xattr & AMI_ISCRIPT)?   's' : '-';
            attribs[3] = (xattr & AMI_IPURE)?     'p' : '-';
            attribs[4] = (xattr & AMI_IARCHIVE)?  'a' : '-';
            attribs[5] = (xattr & AMI_IREAD)?     'r' : '-';
            attribs[6] = (xattr & AMI_IWRITE)?    'w' : '-';
            attribs[7] = (xattr & AMI_IEXECUTE)?  'e' : '-';
            attribs[8] = (xattr & AMI_IDELETE)?   'd' : '-';
            sprintf(&attribs[12], "%d.%d", hostver/10, hostver%10);
            break;

        default:   /* assume Unix-like */
            switch (xattr & UNX_IFMT) {
                case UNX_IFDIR:   attribs[0] = 'd';  break;
                case UNX_IFREG:   attribs[0] = '-';  break;
                case UNX_IFLNK:   attribs[0] = 'l';  break;
                case UNX_IFBLK:   attribs[0] = 'b';  break;
                case UNX_IFCHR:   attribs[0] = 'c';  break;
                case UNX_IFIFO:   attribs[0] = 'p';  break;
                case UNX_IFSOCK:  attribs[0] = 's';  break;
                default:          attribs[0] = '?';  break;
            }
            attribs[1] = (xattr & UNX_IRUSR)? 'r' : '-';
            attribs[4] = (xattr & UNX_IRGRP)? 'r' : '-';
            attribs[7] = (xattr & UNX_IROTH)? 'r' : '-';
            attribs[2] = (xattr & UNX_IWUSR)? 'w' : '-';
            attribs[5] = (xattr & UNX_IWGRP)? 'w' : '-';
            attribs[8] = (xattr & UNX_IWOTH)? 'w' : '-';

            if (xattr & UNX_IXUSR)
                attribs[3] = (xattr & UNX_ISUID)? 's' : 'x';
            else
                attribs[3] = (xattr & UNX_ISUID)? 'S' : '-';  /* S==undefined */
            if (xattr & UNX_IXGRP)
                attribs[6] = (xattr & UNX_ISGID)? 's' : 'x';  /* == UNX_ENFMT */
            else
                /* attribs[6] = (xattr & UNX_ISGID)? 'l' : '-';  real 4.3BSD */
                attribs[6] = (xattr & UNX_ISGID)? 'S' : '-';  /* SunOS 4.1.x */
            if (xattr & UNX_IXOTH)
                attribs[9] = (xattr & UNX_ISVTX)? 't' : 'x';  /* "sticky bit" */
            else
                attribs[9] = (xattr & UNX_ISVTX)? 'T' : '-';  /* T==undefined */

            sprintf(&attribs[12], "%d.%d", hostver/10, hostver%10);
            break;

    } /* end switch (hostnum: external attributes format) */

    PRINTF("%s %s %7lu %c%c", attribs, os[hostnum], crec.ucsize,
      (crec.general_purpose_bit_flag & 1)?
      ((crec.internal_file_attributes & 1)? 'T' : 'B') :   /* encrypted */
      ((crec.internal_file_attributes & 1)? 't' : 'b'),    /* plaintext */
      (crec.general_purpose_bit_flag & 8)? (crec.extra_field_length? 'X' : 'l')
                                        : (crec.extra_field_length? 'x' : '-'));
    if (lflag == 4) {
        ulg csiz = crec.csize;

        if (crec.general_purpose_bit_flag & 1)
            csiz -= 12;    /* if encrypted, don't count encryption header */
        PRINTF("%3d%%", (ratio(crec.ucsize,csiz) + 5)/10);
    } else if (lflag == 5)
        PRINTF(" %7lu", crec.csize);

    PRINTF(" %s %s ", method[methnum],
      zi_time(&crec.last_mod_file_date, &crec.last_mod_file_time));
    fnprint();

/*---------------------------------------------------------------------------
    Skip the extra field and/or the file comment, if any (the filename has
    already been printed, above).  That finishes up this file entry...
  ---------------------------------------------------------------------------*/

    SKIP_(crec.extra_field_length)
    SKIP_(crec.file_comment_length)

    return error_in_archive;

} /* end function zi_short() */





/************************/
/*  Function zi_time()  */
/************************/

static char *zi_time(datez, timez)
    ush *datez, *timez;
{
    ush yr, mo, dy, hh, mm, ss;
    static char d_t_str[21], bogus[4];
    static char Far *month[13] = {
        bogus, JanMonth, FebMonth, MarMonth, AprMonth, MayMonth, JunMonth,
        JulMonth, AugMonth, SepMonth, OctMonth, NovMonth, DecMonth
    };



/*---------------------------------------------------------------------------
    Convert the file-modification date and time info to a string of the form
    "1991 Feb 23 17:15:00" or "23-Feb-91 17:15," depending on value of lflag.
  ---------------------------------------------------------------------------*/

    yr = ((*datez >> 9) & 0x7f) + 80;
    mo = ((*datez >> 5) & 0x0f);
    dy = *datez & 0x1f;

    hh = (*timez >> 11) & 0x1f;
    mm = (*timez >> 5) & 0x3f;
    ss = (*timez & 0x1f) * 2;

    if (mo == 0 || mo > 12) {
        sprintf(bogus, LoadFarString(BogusFmt), mo);
        mo = 0;
    }

    if (lflag > 9)  /* verbose listing format */
        sprintf(d_t_str, LoadFarString(YMDHMSTime), yr+1900,
            LoadFarStringSmall(month[mo]), dy, hh, mm, ss);
    else if (T_flag)
        sprintf(d_t_str, LoadFarString(DecimalTime), yr%100, mo, dy, hh, mm,
          ss);
    else   /* was:  if ((lflag >= 3) && (lflag <= 5)) */
        sprintf(d_t_str, LoadFarString(DMYHMTime), dy,
            LoadFarStringSmall(month[mo]), yr%100, hh, mm);

    return d_t_str;

} /* end function zi_time() */

#endif /* !NO_ZIPINFO */





/*************************/
/* Function list_files() */
/*************************/

int list_files()    /* return PK-type error code */
{
    char sgn, cfactorstr[10];
    int do_this_file=FALSE, cfactor, error, error_in_archive=PK_COOL;
    int longhdr=(vflag>1), date_format, methnum;
    ush j, yr, mo, dy, hh, mm, members=0;
    ulg csiz, tot_csize=0L, tot_ucsize=0L;
#ifdef OS2
    ulg ea_size, tot_easize=0L, tot_eafiles=0L;
#endif
#ifdef MSWIN
    PSTR psLBEntry;  /* list box entry */
#endif
    min_info info;
    static char defl[]="Defl:#", dtype[]="NXFS";   /* see zi_short() */
    static char *method[NUM_METHODS+1] =
        {"Stored", "Shrunk", "Reduce1", "Reduce2", "Reduce3", "Reduce4",
         "Implode", "Token", defl, unkn};



/*---------------------------------------------------------------------------
    Unlike extract_or_test_files(), this routine confines itself to the cen-
    tral directory.  Thus its structure is somewhat simpler, since we can do
    just a single loop through the entire directory, listing files as we go.

    So to start off, print the heading line and then begin main loop through
    the central directory.  The results will look vaguely like the following:

  Length  Method   Size  Ratio   Date    Time   CRC-32     Name ("^" ==> case
  ------  ------   ----  -----   ----    ----   ------     ----   conversion)
   44004  Implode  13041  71%  11-02-89  19:34  8b4207f7   Makefile.UNIX
    3438  Shrunk    2209  36%  09-15-90  14:07  a2394fd8  ^dos-file.ext
  ---------------------------------------------------------------------------*/

    pInfo = &info;
    date_format = DATE_FORMAT;

#ifndef MSWIN
    if (qflag < 2)
        if (L_flag)
            PRINTF(LoadFarString(CaseConversion),
              LoadFarStringSmall(Headers[longhdr][0]),
              LoadFarStringSmall2(Headers[longhdr][1]));
        else
            PRINTF("%s\n%s\n", LoadFarString(Headers[longhdr][0]),
                   LoadFarStringSmall(Headers[longhdr][1]));
#endif /* !MSWIN */

    for (j = 0; j < ecrec.total_entries_central_dir; ++j) {

        if (readbuf(sig, 4) == 0)
            return PK_EOF;
        if (strncmp(sig, central_hdr_sig, 4)) {  /* just to make sure */
            FPRINTF(stderr, LoadFarString(CentSigMsg), j);   /* sig not found */
            FPRINTF(stderr, LoadFarString(ReportMsg));  /* check binary xfers */
            return PK_BADERR;
        }
        /* process_cdir_file_hdr() sets pInfo->lcflag: */
        if ((error = process_cdir_file_hdr()) != PK_COOL)
            return error;       /* only PK_EOF defined */

        /*
         * We could DISPLAY the filename instead of storing (and possibly trun-
         * cating, in the case of a very long name) and printing it, but that
         * has the disadvantage of not allowing case conversion--and it's nice
         * to be able to see in the listing precisely how you have to type each
         * filename in order for unzip to consider it a match.  Speaking of
         * which, if member names were specified on the command line, check in
         * with match() to see if the current file is one of them, and make a
         * note of it if it is.
         */

        if ((error = do_string(crec.filename_length, FILENAME)) != PK_COOL) {
            error_in_archive = error;             /*  ^--(uses pInfo->lcflag) */
            if (error > PK_WARN)   /* fatal:  can't continue */
                return error;
        }
        if (extra_field != (uch *)NULL) {
            free(extra_field);
            extra_field = (uch *)NULL;
        }
        if ((error = do_string(crec.extra_field_length, EXTRA_FIELD)) != 0) {
            error_in_archive = error;  
            if (error > PK_WARN)      /* fatal */
                return error;
        }
        if (!process_all_files) {   /* check if specified on command line */
            char **pfn = pfnames-1;

            do_this_file = FALSE;
            while (*++pfn)
                if (match(filename, *pfn, C_flag)) {
                    do_this_file = TRUE;
                    break;       /* found match, so stop looping */
                }
            if (do_this_file) {  /* check if this is an excluded file */
                char **pxn = pxnames-1;

                while (*++pxn)
                    if (match(filename, *pxn, C_flag)) {
                        do_this_file = FALSE;  /* ^-- ignore case in match */
                        break;
                    }
            }
        }
        /*
         * If current file was specified on command line, or if no names were
         * specified, do the listing for this file.  Otherwise, get rid of the
         * file comment and go back for the next file.
         */

        if (process_all_files || do_this_file) {

            yr = (((crec.last_mod_file_date >> 9) & 0x7f) + 80) % (unsigned)100;
            mo = (crec.last_mod_file_date >> 5) & 0x0f;
            dy = crec.last_mod_file_date & 0x1f;

            /* permute date so it displays according to national convention */
            switch (date_format) {
                case DF_YMD:
                    hh = mo; mo = yr; yr = dy; dy = hh;
                    break;
                case DF_DMY:
                    hh = mo; mo = dy; dy = hh;
            }
            hh = (crec.last_mod_file_time >> 11) & 0x1f;
            mm = (crec.last_mod_file_time >> 5) & 0x3f;

            csiz = crec.csize;
            if (crec.general_purpose_bit_flag & 1)
                csiz -= 12;   /* if encrypted, don't count encryption header */
            if ((cfactor = ratio(crec.ucsize, csiz)) < 0) {
                sgn = '-';
                cfactor = (-cfactor + 5) / 10;
            } else {
                sgn = ' ';
                cfactor = (cfactor + 5) / 10;
            }
            sprintf(cfactorstr, LoadFarString(CompFactorStr), sgn, cfactor);

            methnum = MIN(crec.compression_method, NUM_METHODS);
            if (methnum == DEFLATED)
                defl[5] = dtype[(crec.general_purpose_bit_flag>>1) & 3];
            else if (methnum == NUM_METHODS)
                sprintf(unkn, LoadFarString(CompMethodUnknown),
                    crec.compression_method);

#if 0       /* GRR/Euro:  add this? */
#if defined(DOS_NT_OS2) || defined(UNIX)
            for (p = filename;  *p;  ++p)
                if (!isprint(*p))
                    *p = '?';  /* change non-printable chars to '?' */
#endif /* DOS_NT_OS2 || UNIX */
#endif /* 0 */

#ifdef MSWIN
#ifdef NEED_EARLY_REDRAW
            /* turn on listbox redrawing just before adding last line */
            if (j == (ecrec.total_entries_central_dir-1))
                (void)SendMessage(hWndList, WM_SETREDRAW, TRUE, 0L);
#endif /* NEED_EARLY_REDRAW */
            psLBEntry =
              (PSTR)LocalAlloc(LMEM_FIXED, FILNAMSIZ+LONG_FORM_FNAME_INX);
            /* GRR:  does OemToAnsi filter out escape and CR characters? */
            OemToAnsi(filename, filename);  /* translate to ANSI */
            if (longhdr) {
                wsprintf(psLBEntry, LoadFarString(LongHdrStats),
                  crec.ucsize, (LPSTR)method[methnum], csiz, cfactorstr,
                  mo, dy, yr, hh, mm, crec.crc32, (pInfo->lcflag?'^':' '),
                  (LPSTR)filename);
                SendMessage(hWndList, LB_ADDSTRING, 0,
                  (LONG)(LPSTR)psLBEntry);
            } else {
                wsprintf(psLBEntry, LoadFarString(ShortHdrStats),
                  crec.ucsize, mo, dy, yr, hh, mm, (pInfo->lcflag?'^':' '),
                  (LPSTR)filename);
                SendMessage(hWndList, LB_ADDSTRING, 0,
                  (LONG)(LPSTR)psLBEntry);
            }
            LocalFree((HANDLE)psLBEntry);
#else /* !MSWIN */
            if (longhdr)
                PRINTF(LoadFarString(LongHdrStats),
                  crec.ucsize, method[methnum], csiz, cfactorstr, mo, dy, yr,
                  hh, mm, crec.crc32, (pInfo->lcflag?'^':' '));
            else
                PRINTF(LoadFarString(ShortHdrStats), crec.ucsize,
                  mo, dy, yr, hh, mm, (pInfo->lcflag?'^':' '));
            fnprint();
#endif /* ?MSWIN */

            error = do_string(crec.file_comment_length, QCOND? DISPLAY : SKIP);
            if (error) {
                error_in_archive = error;  /* might be just warning */
                if (error > PK_WARN)       /* fatal */
                    return error;
            }
            tot_ucsize += crec.ucsize;
            tot_csize += csiz;
            ++members;
#ifdef OS2
            if ((ea_size = SizeOfEAs(extra_field)) != 0) {
                tot_easize += ea_size;
                tot_eafiles++;
            }
#endif
        } else {        /* not listing this file */
            SKIP_(crec.file_comment_length)
        }
    } /* end for-loop (j: files in central directory) */

/*---------------------------------------------------------------------------
    Print footer line and totals (compressed size, uncompressed size, number
    of members in zipfile).
  ---------------------------------------------------------------------------*/

    if (qflag < 2) {
        if ((cfactor = ratio(tot_ucsize, tot_csize)) < 0) {
            sgn = '-';
            cfactor = (-cfactor + 5) / 10;
        } else {
            sgn = ' ';
            cfactor = (cfactor + 5) / 10;
        }
        sprintf(cfactorstr, LoadFarString(CompFactorStr), sgn, cfactor);
#ifdef MSWIN
        /* Display just the totals since the dashed lines get displayed
         * in UpdateListBox(). Get just enough space to display total. */
        if (longhdr)
            wsprintf(lpumb->szTotalsLine,LoadFarString(LongFileHeader), 
              tot_ucsize, tot_csize, cfactorstr, members);
        else
            wsprintf(lpumb->szTotalsLine, LoadFarString(ShortFileHeader), 
              tot_ucsize, members);
#else /* !MSWIN */
        if (longhdr)
            PRINTF(LoadFarString(LongFileHeader), tot_ucsize, tot_csize, cfactorstr, members);
        else
            PRINTF(LoadFarString(ShortFileHeader), tot_ucsize, members);
#endif /* ?MSWIN */
#ifdef OS2
        if (tot_eafiles && tot_easize)
            PRINTF("\n%ld file%s %ld bytes of EA's attached.\n", tot_eafiles, 
              tot_eafiles == 1 ? " has" : "s have a total of", tot_easize);
#endif
    }
/*---------------------------------------------------------------------------
    Double check that we're back at the end-of-central-directory record.
  ---------------------------------------------------------------------------*/

    if (readbuf(sig, 4) == 0)
        return PK_EOF;
    if (strncmp(sig, end_central_sig, 4)) {     /* just to make sure again */
        FPRINTF(stderr, LoadFarString(EndSigMsg));  /* didn't find sig */
        error_in_archive = PK_WARN;
    }
    if (members == 0 && error_in_archive <= PK_WARN)
        error_in_archive = PK_FIND;

    return error_in_archive;

} /* end function list_files() */





/********************/
/* Function ratio() */
/********************/

static int ratio(uc, c)
    ulg uc, c;
{
    ulg denom;

    if (uc == 0)
        return 0;
    if (uc > 2000000L) {    /* risk signed overflow if multiply numerator */
        denom = uc / 1000L;
        return ((uc >= c) ?
            (int) ((uc-c + (denom>>1)) / denom) :
          -((int) ((c-uc + (denom>>1)) / denom)));
    } else {             /* ^^^^^^^^ rounding */
        denom = uc;
        return ((uc >= c) ?
            (int) ((1000L*(uc-c) + (denom>>1)) / denom) :
          -((int) ((1000L*(c-uc) + (denom>>1)) / denom)));
    }                            /* ^^^^^^^^ rounding */
}





/************************/
/*  Function fnprint()  */
/************************/

static void fnprint()    /* print filename (after filtering) and newline */
{
    register uch *p = (uch *)filename-1;
    register uch *q = (uch *)slide;

#ifdef NATIVE
    PRINTF("%s", filename);   /* GRR:  can ANSI be used with EBCDIC? */
#else /* ASCII */
    while (*++p) {
        if (*p < 32) {        /* ASCII control character */
            *q++ = '^';
            *q++ = *p + 64;
        } else
            *q++ = *p;
    }                    /* filename better not be longer than slide[] ... */
    *q = '\0';
    PRINTF("%s\n", slide);
#endif /* ?NATIVE */

} /* end function fnprint() */
