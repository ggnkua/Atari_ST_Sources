/*---------------------------------------------------------------------------

  file_io.c

  This file contains routines for doing direct but relatively generic input/
  output, file-related sorts of things, plus some miscellaneous stuff.  Most
  of the stuff has to do with opening, closing, reading and/or writing files.

  Contains:  open_input_file()
             open_outfile()           (non-VMS)
             readbuf()
             readbyte()
             flush()                  (non-VMS)
             disk_error()             (non-VMS)
             handler()
             dos_to_unix_time()       (non-VMS)
             check_for_newer()        (non-VMS, non-OS/2)
             find_ecrec()
             get_cdir_ent()
             do_string()
             makeword()
             makelong()
             memset()                 (ZMEM only)
             memcpy()                 (ZMEM only)
             zstrnicmp()
             LoadFarString()          (SMALL_MEM only)
             LoadFarStringSmall()     (SMALL_MEM only)
             LoadFarStringSmall2()    (SMALL_MEM only)

  ---------------------------------------------------------------------------*/


#define FILE_IO_C
#include "unzip.h"
#include "crypt.h"
#include "tables.h"   /* definition/initialization of ebcdic[] */

#ifdef USE_FWRITE
#  define WriteError(buf,len,strm) \
     ((extent)fwrite((char *)(buf),1,(extent)(len),strm) != (extent)(len))
#else
#  define WriteError(buf,len,strm) \
     ((extent)write(fileno(strm),(char *)(buf),(extent)(len)) != (extent)(len))
#endif

static int disk_error OF((void));



/*****************************/
/* Strings used in file_io.c */
/*****************************/

#ifdef UNIX
   static char Far CannotDeleteOldFile[] = "\nerror:  cannot delete old %s\n";
#endif

static char Far CantOpenZipfile[] = "error:  can't open zipfile [ %s ]\n";
static char Far CannotCreateFile[] = "\nerror:  cannot create %s\n";
static char Far ReadError[] = "error:  zipfile read error\n";
static char Far DiskFull[] =
  "\n%s:  write error (disk full?).  Continue? (y/n/^C) ";
static char Far ZipfileCorrupt[] = "error:  zipfile probably corrupt (%s)\n";
static char Far CentDirEndSigNotFound[] = "\
  End-of-central-directory signature not found.  Either this file is not\n\
  a zipfile, or it constitutes one disk of a multi-part archive.  In the\n\
  latter case the central directory and zipfile comment will be found on\n\
  the last disk(s) of this archive.\n";
static char Far FilenameTooLongTrunc[] =
  "warning:  filename too long--truncating.\n";
static char Far ExtraFieldTooLong[] =
  "warning:  extra field too long (%d).  Ignoring...\n";





/******************************/
/* Function open_input_file() */
/******************************/

int open_input_file()    /* return 1 if open failed */
{
    /*
     *  open the zipfile for reading and in BINARY mode to prevent cr/lf
     *  translation, which would corrupt the bitstreams
     */

#if defined(UNIX) || defined(TOPS20) || defined(ATARI_ST)
    zipfd = open(zipfn, O_RDONLY);
#else /* !(UNIX || TOPS20) */
#ifdef VMS
    zipfd = open(zipfn, O_RDONLY, 0, "ctx=stm");
#else /* !VMS */
#ifdef MACOS
    zipfd = open(zipfn, 0);
#else /* !MACOS */
    zipfd = open(zipfn, O_RDONLY | O_BINARY);
#endif /* ?MACOS */
#endif /* ?VMS */
#endif /* ?(UNIX || TOPS20) */
    if (zipfd < 0) {
        FPRINTF(stderr, LoadFarString(CantOpenZipfile), zipfn);
        return 1;
    }
    return 0;

} /* end function open_input_file() */




#ifndef VMS                      /* for VMS use code in vms.c */

/***************************/
/* Function open_outfile() */
/***************************/

int open_outfile()         /* return 1 if fail */
{
#ifdef DOS_NT_OS2
    if (stat(filename, &statbuf) == 0 && !(statbuf.st_mode & S_IWRITE))
        chmod(filename, S_IREAD | S_IWRITE);
#endif
#ifdef UNIX
    if (stat(filename, &statbuf) == 0 && unlink(filename) < 0) {
        FPRINTF(stderr, LoadFarString(CannotDeleteOldFile), filename);
        return 1;
    }
#endif
#ifdef TOPS20
    char *tfilnam;

    if ((tfilnam = (char *)malloc(2*strlen(filename)+1)) == (char *)NULL)
        return 1;
    strcpy(tfilnam, filename);
    upper(tfilnam);
    enquote(tfilnam);
    if ((outfile = fopen(tfilnam, FOPW)) == (FILE *)NULL) {
        FPRINTF(stderr, LoadFarString(CannotCreateFile), tfilnam);
        free(tfilnam);
        return 1;
    }
    free(tfilnam);
#else
#ifdef MTS
    if (aflag)
        outfile = fopen(filename, FOPWT);
    else
        outfile = fopen(filename, FOPW);
    if (outfile == (FILE *)NULL) {
        FPRINTF(stderr, LoadFarString(CannotCreateFile), filename);
        return 1;
    }
#else
    if ((outfile = fopen(filename, FOPW)) == (FILE *)NULL) {
        FPRINTF(stderr, LoadFarString(CannotCreateFile), filename);
        return 1;
    }
#endif
#endif

#if 0      /* this SUCKS!  on Ultrix, it must be writing a byte at a time... */
    setbuf(outfile, (char *)NULL);   /* make output unbuffered */
#endif

#ifdef USE_FWRITE
#ifdef DOS_NT_OS2
    /* 16-bit MSC: buffer size must be strictly LESS than 32K (WSIZE):  bogus */
    setbuf(outfile, (char *)NULL);   /* make output unbuffered */
#else /* !DOS_NT_OS2 */
#ifdef _IOFBF  /* make output fully buffered (works just about like write()) */
    setvbuf(outfile, (char *)slide, _IOFBF, WSIZE);
#else
    setbuf(outfile, (char *)slide);
#endif
#endif /* ?DOS_NT_OS2 */
#endif /* USE_FWRITE */
    return 0;

} /* end function open_outfile() */

#endif /* !VMS */





/**********************/
/* Function readbuf() */
/**********************/

unsigned readbuf(buf, size)   /* return number of bytes read into buf */
    char *buf;
    register unsigned size;
{
    register unsigned count;
    unsigned n;

    n = size;
    while (size) {
        if (incnt == 0) {
#ifdef OLD_READBUF
            if ((incnt = read(zipfd, (char *)inbuf, INBUFSIZ)) <= 0)
                return (n-size);
#else
            if ((incnt = read(zipfd, (char *)inbuf, INBUFSIZ)) == 0)
                return (n-size);
            else if (incnt < 0) {
                FPRINTF(stderr, LoadFarString(ReadError));
                return 0;  /* discarding some data; better than lock-up */
            }
#endif
            /* buffer ALWAYS starts on a block boundary:  */
            cur_zipfile_bufstart += INBUFSIZ;
            inptr = inbuf;
        }
        count = MIN(size, (unsigned)incnt);
        memcpy(buf, inptr, count);
        buf += count;
        inptr += count;
        incnt -= count;
        size -= count;
    }
    return n;

} /* end function readbuf() */





/***********************/
/* Function readbyte() */
/***********************/

int readbyte()   /* refill inbuf and return a byte if available, else EOF */
{
    if (mem_mode || (incnt = read(zipfd,(char *)inbuf,INBUFSIZ)) <= 0)
        return EOF;
    cur_zipfile_bufstart += INBUFSIZ;   /* always starts on a block boundary */
    inptr = inbuf;

#ifdef CRYPT
    if (pInfo->encrypted) {
        uch *p;
        int n;

        for (n = (long)incnt > csize + 1 ? (int)csize + 1 : incnt,
             p = inptr;  n--;  p++)
            zdecode(*p);
    }
#endif /* CRYPT */

    --incnt;
    return *inptr++;

} /* end function readbyte() */





#ifndef VMS                 /* for VMS use code in vms.c */

/********************/
/* Function flush() */
/********************/

int flush(rawbuf, size, unshrink)   /* cflag => always 0; 50 if write error */
    uch *rawbuf;
    ulg size;
    int unshrink;
{
#ifdef ASM_CRC
    ulg CalcCRC(ulg *crc_table, ulg crcval, uch *rawbuf, ulg rawbufsize);
#else
    register ulg crcval = crc32val;
    register ulg n = size;
#endif
    register uch *p, *q;
    uch *transbuf;
    ulg transbufsiz;
    static int didCRlast = FALSE;


/*---------------------------------------------------------------------------
    Compute the CRC first; if testing or if disk is full, that's it.
  ---------------------------------------------------------------------------*/

#ifdef ASM_CRC
    crc32val = CalcCRC(crc_32_tab, crc32val, rawbuf, size);
#else
    p = rawbuf;
    while (n--)
        crcval = crc_32_tab[((uch)crcval ^ (*p++)) & 0xff] ^ (crcval >> 8);
    crc32val = crcval;
#endif /* ?ASM_CRC */

    if (tflag || size == 0L)   /* testing or nothing to write:  all done */
        return 0;

    if (disk_full)
        return 50;            /* disk already full:  ignore rest of file */

/*---------------------------------------------------------------------------
    Write the bytes rawbuf[0..size-1] to the output device, first converting
    end-of-lines and ASCII/EBCDIC as needed.  If SMALL_MEM or MED_MEM are NOT
    defined, outbuf is assumed to be at least as large as rawbuf and is not
    necessarily checked for overflow.
  ---------------------------------------------------------------------------*/

    if (!pInfo->textmode) {
        /* GRR:  note that for standard MS-DOS compilers, size argument to
         * fwrite() can never be more than 65534, so WriteError macro will
         * have to be rewritten if size can ever be that large.  For now,
         * never more than 32K.  Also note that write() returns an int, which
         * doesn't necessarily limit size to 32767 bytes if write() is used
         * on 16-bit systems but does make it more of a pain; however, because
         * at least MSC 5.1 has a lousy implementation of fwrite() (as does
         * DEC Ultrix cc), write() is used anyway.
         */
        if (WriteError(rawbuf, size, outfile))  /* write raw binary data */
            return cflag? 0 : disk_error();
    } else {
        if (unshrink) {
            /* rawbuf = outbuf */
            transbuf = outbuf2;
            transbufsiz = TRANSBUFSIZ;
        } else {
            /* rawbuf = slide */
            transbuf = outbuf;
            transbufsiz = OUTBUFSIZ;
            Trace((stderr, "\ntransbufsiz = OUTBUFSIZ = %u\n", OUTBUFSIZ));
        }
        if (newfile) {
            didCRlast = FALSE;   /* no previous buffers written */
            newfile = FALSE;
        }
        p = rawbuf;
        if (*p == LF && didCRlast)
            ++p;

    /*-----------------------------------------------------------------------
        Algorithm:  CR/LF => native; lone CR => native; lone LF => native.
        This routine is only for non-raw-VMS, non-raw-VM/CMS files (i.e.,
        stream-oriented files, not record-oriented).
      -----------------------------------------------------------------------*/

        for (didCRlast = FALSE, q = transbuf;  p < rawbuf+size;  ++p) {
            if (*p == CR) {              /* lone CR or CR/LF: EOL either way */
                PutNativeEOL
                if (p == rawbuf+size-1)  /* last char in buffer */
                    didCRlast = TRUE;
                else if (p[1] == LF)     /* get rid of accompanying LF */
                    ++p;
            } else if (*p == LF)         /* lone LF */
                PutNativeEOL
            else
#ifndef DOS_NT_OS2
            if (*p != CTRLZ)             /* lose all ^Z's */
#endif
                *q++ = native(*p);

#if (defined(SMALL_MEM) || defined(MED_MEM))
# if (lenEOL == 1)   /* don't check unshrink:  both buffers small but equal */
            if (!unshrink)
# endif
                /* check for danger of buffer overflow and flush */
                if (q > transbuf+transbufsiz-lenEOL) {
                    Trace((stderr,
                      "p - rawbuf = %u   q-transbuf = %u   size = %lu\n",
                      (unsigned)(p-rawbuf), (unsigned)(q-transbuf), size));
                    if (WriteError(transbuf, (unsigned)(q-transbuf), outfile))
                        return cflag? 0 : disk_error();
                    q = transbuf;
                    continue;
                }
#endif /* SMALL_MEM || MED_MEM */
        }

    /*-----------------------------------------------------------------------
        Done translating:  write whatever we've got to file.
      -----------------------------------------------------------------------*/

        Trace((stderr, "p - rawbuf = %u   q-transbuf = %u   size = %lu\n",
          (unsigned)(p-rawbuf), (unsigned)(q-transbuf), size));
        if (q > transbuf &&
            WriteError(transbuf, (unsigned)(q-transbuf), outfile))
            return cflag? 0 : disk_error();
    }

    return 0;

} /* end function flush() */





/*************************/
/* Function disk_error() */
/*************************/

static int disk_error()
{
    FPRINTF(stderr, LoadFarString(DiskFull), filename);
    FFLUSH(stderr);

#ifndef MSWIN
    fgets(answerbuf, 9, stdin);
    if (*answerbuf == 'y')   /* stop writing to this file */
        disk_full = 1;       /*  (outfile bad?), but new OK */
    else
#endif
        disk_full = 2;       /* no:  exit program */

    return 50;               /* 50:  disk full */

} /* end function disk_error() */

#endif /* !VMS */





/**********************/
/* Function handler() */
/**********************/

void handler(signal)   /* upon interrupt, turn on echo and exit cleanly */
    int signal;
{
#if defined(SIGBUS) || defined(SIGSEGV)
#  ifdef SMALL_MEM
    static char *corrupt;
    corrupt = LoadFarString(ZipfileCorrupt);
#  else
    static char *corrupt = LoadFarString(ZipfileCorrupt);
#  endif
#endif

#if !defined(DOS_NT_OS2) && !defined(MACOS)
    echon();
    putc('\n', stderr);
#endif /* !DOS_NT_OS2 && !MACOS */
#ifdef SIGBUS
    if (signal == SIGBUS) {
        FPRINTF(stderr, corrupt, "bus error");
        exit(3);
    }
#endif /* SIGBUS */
#ifdef SIGSEGV
    if (signal == SIGSEGV) {
        FPRINTF(stderr, corrupt, "segmentation violation");
        exit(3);
    }
#endif /* SIGSEGV */
    exit(0);
}





#ifndef VMS

/*******************************/
/* Function dos_to_unix_time() */
/*******************************/

time_t dos_to_unix_time(ddate, dtime)
    unsigned ddate, dtime;
{
    int yr, mo, dy, hh, mm, ss;
#ifdef TOPS20
#   define YRBASE  1900
    struct tmx *tmx;
    char temp[20];
    time_t retval;
#else /* !TOPS20 */
#   define YRBASE  1970
    static short yday[]={0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334};
    int leap;
    long m_time, days=0;
#if (!defined(MACOS) && !defined(MSC))
#if (defined(BSD) || defined(MTS) || defined(__GO32__))
#ifndef BSD4_4
    static struct timeb tbp;
#endif /* !BSD4_4 */
#else /* !(BSD || MTS || __GO32__) */
#ifdef ATARI_ST
    extern long _timezone;
#   define timezone _timezone;  /* a whoops in our library... */
#else /* !ATARI_ST */
    extern long timezone;       /* declared in <time.h> for MSC (& Borland?) */
#endif /* ?ATARI_ST */
#endif /* ?(BSD || MTS || __GO32__) */
#endif /* !MACOS && !MSC */
#endif /* ?TOPS20 */


    /* dissect date */
    yr = ((ddate >> 9) & 0x7f) + (1980 - YRBASE);
    mo = ((ddate >> 5) & 0x0f) - 1;
    dy = (ddate & 0x1f) - 1;

    /* dissect time */
    hh = (dtime >> 11) & 0x1f;
    mm = (dtime >> 5) & 0x3f;
    ss = (dtime & 0x1f) * 2;

#ifdef TOPS20
    tmx = (struct tmx *)malloc(sizeof(struct tmx));
    sprintf (temp, "%02d/%02d/%02d %02d:%02d:%02d", mo+1, dy+1, yr, hh, mm, ss);
    time_parse(temp, tmx, (char *)0);
    retval = time_make(tmx);
    free(tmx);
    return retval;

#else /* !TOPS20 */
    /* leap = # of leap years from BASE up to but not including current year */
    leap = ((yr + YRBASE - 1) / 4);   /* leap year base factor */

    /* calculate days from BASE to this year and add expired days this year */
    days = (yr * 365) + (leap - 492) + yday[mo];

    /* if year is a leap year and month is after February, add another day */
    if ((mo > 1) && ((yr+YRBASE)%4 == 0) && ((yr+YRBASE) != 2100))
        ++days;                 /* OK through 2199 */

    /* convert date & time to seconds relative to 00:00:00, 01/01/YRBASE */
    m_time = ((long)(days + dy) * 86400L) + ((long)hh * 3600) + (mm * 60) + ss;
      /* - 1;   MS-DOS times always rounded up to nearest even second */

#ifndef MACOS
#if (defined(BSD) || defined(MTS) || defined(__GO32__))
#ifndef BSD4_4
    ftime(&tbp);
    m_time += tbp.timezone * 60L;
#endif
#else /* !(BSD || MTS || __GO32__) */
#ifdef WIN32
    {
        TIME_ZONE_INFORMATION tzinfo;
        DWORD res;

        /* account for timezone differences */
        res = GetTimeZoneInformation(&tzinfo);
        if (res == TIME_ZONE_ID_STANDARD)
            m_time += 60*(tzinfo.Bias + tzinfo.StandardBias);
        else if (res == TIME_ZONE_ID_DAYLIGHT)
            m_time += 60*(tzinfo.Bias + tzinfo.DaylightBias);
        /* GRR:  are other return-values possible? */
    }
#else /* !WIN32 */
    tzset();                    /* set `timezone' variable */
    m_time += timezone;
#endif /* ?WIN32 */
#endif /* ?(BSD || MTS || __GO32__) */
#endif /* !MACOS */

#ifdef BSD4_4               /* see comments in unix.c */
    m_time -= localtime((time_t *) &m_time)->tm_gmtoff;
#else /* !BSD4_4 */
#ifndef WIN32
    if (localtime((time_t *)&m_time)->tm_isdst)
        m_time -= 60L * 60L;    /* adjust for daylight savings time */
#endif /* !WIN32 */
#endif /* ?BSD4_4 */

    return m_time;
#endif /* ?TOPS20 */

} /* end function dos_to_unix_time() */

#endif /* !VMS */





#if !defined(VMS) && !defined(OS2)

/******************************/
/* Function check_for_newer() */
/******************************/

int check_for_newer(filename)   /* return 1 if existing file newer or equal; */
    char *filename;             /*  0 if older; -1 if doesn't exist yet */
{
    time_t existing, archive;

    if (stat(filename, &statbuf))
        return DOES_NOT_EXIST;

    /* round up existing filetime to nearest 2 seconds for comparison */
    existing = (statbuf.st_mtime & 1) ? statbuf.st_mtime+1 : statbuf.st_mtime;
    archive  = dos_to_unix_time(lrec.last_mod_file_date,
                                lrec.last_mod_file_time);
#ifdef PRINT_TIME
    FPRINTF(stderr, "existing %ld, archive %ld, e-a %ld\n", existing, archive,
      existing-archive);
#endif

    return (existing >= archive);

} /* end function check_for_newer() */

#endif /* !VMS && !OS2 */





/*************************/
/* Function find_ecrec() */
/*************************/

int find_ecrec(searchlen)   /* return PK-class error */
    long searchlen;
{
    int i, numblks, found=FALSE;
    LONGINT tail_len;
    ec_byte_rec byterec;


/*---------------------------------------------------------------------------
    Treat case of short zipfile separately.
  ---------------------------------------------------------------------------*/

    if (ziplen <= INBUFSIZ) {
        lseek(zipfd, 0L, SEEK_SET);
        if ((incnt = read(zipfd,(char *)inbuf,(unsigned int)ziplen)) ==
             (int)ziplen)

            /* 'P' must be at least 22 bytes from end of zipfile */
            for (inptr = inbuf+(int)ziplen-22;  inptr >= inbuf;  --inptr)
                if ((native(*inptr) == 'P')  &&
                     !strncmp((char *)inptr, end_central_sig, 4)) {
                    incnt -= inptr - inbuf;
                    found = TRUE;
                    break;
                }

/*---------------------------------------------------------------------------
    Zipfile is longer than INBUFSIZ:  may need to loop.  Start with short
    block at end of zipfile (if not TOO short).
  ---------------------------------------------------------------------------*/

    } else {
        if ((tail_len = ziplen % INBUFSIZ) > ECREC_SIZE) {
            cur_zipfile_bufstart = lseek(zipfd, ziplen-tail_len, SEEK_SET);
            if ((incnt = read(zipfd,(char *)inbuf,(unsigned int)tail_len)) !=
                 (int)tail_len)
                goto fail;      /* shut up; it's expedient */

            /* 'P' must be at least 22 bytes from end of zipfile */
            for (inptr = inbuf+(int)tail_len-22;  inptr >= inbuf;  --inptr)
                if ((native(*inptr) == 'P')  &&
                     !strncmp((char *)inptr, end_central_sig, 4)) {
                    incnt -= inptr - inbuf;
                    found = TRUE;
                    break;
                }
            /* sig may span block boundary: */
            strncpy((char *)hold, (char *)inbuf, 3);
        } else
            cur_zipfile_bufstart = ziplen - tail_len;

    /*-----------------------------------------------------------------------
        Loop through blocks of zipfile data, starting at the end and going
        toward the beginning.  In general, need not check whole zipfile for
        signature, but may want to do so if testing.
      -----------------------------------------------------------------------*/

        numblks = (int)((searchlen - tail_len + (INBUFSIZ-1)) / INBUFSIZ);
        /*               ==amount=   ==done==   ==rounding==    =blksiz=  */

        for (i = 1;  !found && (i <= numblks);  ++i) {
            cur_zipfile_bufstart -= INBUFSIZ;
            lseek(zipfd, cur_zipfile_bufstart, SEEK_SET);
            if ((incnt = read(zipfd,(char *)inbuf,INBUFSIZ)) != INBUFSIZ)
                break;          /* fall through and fail */

            for (inptr = inbuf+INBUFSIZ-1;  inptr >= inbuf;  --inptr)
                if ((native(*inptr) == 'P')  &&
                     !strncmp((char *)inptr, end_central_sig, 4)) {
                    incnt -= inptr - inbuf;
                    found = TRUE;
                    break;
                }
            /* sig may span block boundary: */
            strncpy((char *)hold, (char *)inbuf, 3);
        }
    } /* end if (ziplen > INBUFSIZ) */

/*---------------------------------------------------------------------------
    Searched through whole region where signature should be without finding
    it.  Print informational message and die a horrible death.
  ---------------------------------------------------------------------------*/

fail:
    if (!found) {
#ifdef MSWIN
        MessageBeep(1);
#endif
        if (qflag || (zipinfo_mode && !hflag))
            FPRINTF(stderr, "[%s]\n", zipfn);
        FPRINTF(stderr, LoadFarString(CentDirEndSigNotFound));
        return PK_ERR;   /* failed */
    }

/*---------------------------------------------------------------------------
    Found the signature, so get the end-central data before returning.  Do
    any necessary machine-type conversions (byte ordering, structure padding
    compensation) by reading data into character array and copying to struct.
  ---------------------------------------------------------------------------*/

    real_ecrec_offset = cur_zipfile_bufstart + (inptr-inbuf);
#ifdef TEST
    printf("\n  found end-of-central-dir signature at offset %ld (%.8lXh)\n",
      real_ecrec_offset, real_ecrec_offset);
    printf("    from beginning of file; offset %d (%.4Xh) within block\n",
      inptr-inbuf, inptr-inbuf);
#endif

    if (readbuf((char *)byterec, ECREC_SIZE+4) == 0)
        return PK_EOF;

    ecrec.number_this_disk =
        makeword(&byterec[NUMBER_THIS_DISK]);
    ecrec.num_disk_with_start_central_dir =
        makeword(&byterec[NUM_DISK_WITH_START_CENTRAL_DIR]);
    ecrec.num_entries_centrl_dir_ths_disk =
        makeword(&byterec[NUM_ENTRIES_CENTRL_DIR_THS_DISK]);
    ecrec.total_entries_central_dir =
        makeword(&byterec[TOTAL_ENTRIES_CENTRAL_DIR]);
    ecrec.size_central_directory =
        makelong(&byterec[SIZE_CENTRAL_DIRECTORY]);
    ecrec.offset_start_central_directory =
        makelong(&byterec[OFFSET_START_CENTRAL_DIRECTORY]);
    ecrec.zipfile_comment_length =
        makeword(&byterec[ZIPFILE_COMMENT_LENGTH]);

    expect_ecrec_offset = ecrec.offset_start_central_directory +
                          ecrec.size_central_directory;
    return PK_COOL;

} /* end function find_ecrec() */





/***************************/
/* Function get_cdir_ent() */
/***************************/

int get_cdir_ent()   /* return PK-type error code */
{
    cdir_byte_hdr byterec;


/*---------------------------------------------------------------------------
    Read the next central directory entry and do any necessary machine-type
    conversions (byte ordering, structure padding compensation--do so by
    copying the data from the array into which it was read (byterec) to the
    usable struct (crec)).
  ---------------------------------------------------------------------------*/

    if (readbuf((char *)byterec, CREC_SIZE) == 0)
        return PK_EOF;

    crec.version_made_by[0] = byterec[C_VERSION_MADE_BY_0];
    crec.version_made_by[1] = byterec[C_VERSION_MADE_BY_1];
    crec.version_needed_to_extract[0] = byterec[C_VERSION_NEEDED_TO_EXTRACT_0];
    crec.version_needed_to_extract[1] = byterec[C_VERSION_NEEDED_TO_EXTRACT_1];

    crec.general_purpose_bit_flag =
        makeword(&byterec[C_GENERAL_PURPOSE_BIT_FLAG]);
    crec.compression_method =
        makeword(&byterec[C_COMPRESSION_METHOD]);
    crec.last_mod_file_time =
        makeword(&byterec[C_LAST_MOD_FILE_TIME]);
    crec.last_mod_file_date =
        makeword(&byterec[C_LAST_MOD_FILE_DATE]);
    crec.crc32 =
        makelong(&byterec[C_CRC32]);
    crec.csize =
        makelong(&byterec[C_COMPRESSED_SIZE]);
    crec.ucsize =
        makelong(&byterec[C_UNCOMPRESSED_SIZE]);
    crec.filename_length =
        makeword(&byterec[C_FILENAME_LENGTH]);
    crec.extra_field_length =
        makeword(&byterec[C_EXTRA_FIELD_LENGTH]);
    crec.file_comment_length =
        makeword(&byterec[C_FILE_COMMENT_LENGTH]);
    crec.disk_number_start =
        makeword(&byterec[C_DISK_NUMBER_START]);
    crec.internal_file_attributes =
        makeword(&byterec[C_INTERNAL_FILE_ATTRIBUTES]);
    crec.external_file_attributes =
        makelong(&byterec[C_EXTERNAL_FILE_ATTRIBUTES]);  /* LONG, not word! */
    crec.relative_offset_local_header =
        makelong(&byterec[C_RELATIVE_OFFSET_LOCAL_HEADER]);

    return PK_COOL;

} /* end function get_cdir_ent() */





/************************/
/* Function do_string() */
/************************/

int do_string(len, option)      /* return PK-type error code */
    unsigned int len;           /* without prototype, ush converted to this */
    int option;
{
    long comment_bytes_left, block_length;
    int error=PK_OK;
    ush extra_len;


/*---------------------------------------------------------------------------
    This function processes arbitrary-length (well, usually) strings.  Three
    options are allowed:  SKIP, wherein the string is skipped (pretty logical,
    eh?); DISPLAY, wherein the string is printed to standard output after un-
    dergoing any necessary or unnecessary character conversions; and FILENAME,
    wherein the string is put into the filename[] array after undergoing ap-
    propriate conversions (including case-conversion, if that is indicated:
    see the global variable pInfo->lcflag).  The latter option should be OK,
    since filename is now dimensioned at 1025, but we check anyway.

    The string, by the way, is assumed to start at the current file-pointer
    position; its length is given by len.  So start off by checking length
    of string:  if zero, we're already done.
  ---------------------------------------------------------------------------*/

    if (!len)
        return PK_COOL;

    switch (option) {

    /*
     * First case:  print string on standard output.  First set loop vari-
     * ables, then loop through the comment in chunks of OUTBUFSIZ bytes,
     * converting formats and printing as we go.  The second half of the
     * loop conditional was added because the file might be truncated, in
     * which case comment_bytes_left will remain at some non-zero value for
     * all time.  outbuf and slide are used as scratch buffers because they
     * are available (we should be either before or in between any file pro-
     * cessing).
     */

    case DISPLAY:
        comment_bytes_left = len;
        block_length = OUTBUFSIZ;    /* for the while statement, first time */
        while (comment_bytes_left > 0 && block_length > 0) {
#ifndef MSWIN
            register uch *p = outbuf;
            register uch *q = outbuf;
#endif
            if ((block_length = readbuf((char *)outbuf,
                   (unsigned) MIN(OUTBUFSIZ, comment_bytes_left))) == 0)
                return PK_EOF;
            comment_bytes_left -= block_length;

            /* this is why we allocated an extra byte for outbuf: */
            outbuf[block_length] = '\0';   /* terminate w/zero:  ASCIIZ */

            /* remove all ASCII carriage returns comment before printing
             * (since used before A_TO_N(), check for CR instead of '\r')
             */
            while (*p) {
                while (*p == CR)
                    ++p;
                *q++ = *p++;
            }
            /* could check whether (p - outbuf) == block_length here */
            *q = '\0';

            A_TO_N(outbuf);   /* translate string to native */

#ifdef MSWIN
            /* ran out of local mem -- had to cheat */
            WriteStringToMsgWin(outbuf, bRealTimeMsgUpdate);
#else /* !MSWIN */
#ifdef NATIVE
            PRINTF("%s", outbuf);   /* GRR:  can ANSI be used with EBCDIC? */
#else /* ASCII */
            p = outbuf - 1;
            q = slide;
            while (*++p) {
                if (*p == 0x1B) {   /* ASCII escape char */
                    *q++ = '^';
                    *q++ = '[';
                } else
                    *q++ = *p;
                if ((unsigned)(q-slide) > WSIZE-3) {   /* time to flush */
                    *q = '\0';
                    PRINTF("%s", slide);
                    q = slide;
                }
            }
            *q = '\0';
            PRINTF("%s", slide);
#endif /* ?NATIVE */
#endif /* ?MSWIN */
        }
        PRINTF("\n");   /* assume no newline at end */
        break;

    /*
     * Second case:  read string into filename[] array.  The filename should
     * never ever be longer than FILNAMSIZ-1 (1024), but for now we'll check,
     * just to be sure.
     */

    case FILENAME:
        extra_len = 0;
        if (len >= FILNAMSIZ) {
            FPRINTF(stderr, LoadFarString(FilenameTooLongTrunc));
            error = PK_WARN;
            extra_len = len - FILNAMSIZ + 1;
            len = FILNAMSIZ - 1;
        }
        if (readbuf(filename, len) == 0)
            return PK_EOF;
        filename[len] = '\0';   /* terminate w/zero:  ASCIIZ */

        A_TO_N(filename);       /* translate string to native */

        if (pInfo->lcflag)      /* replace with lowercase filename */
            TOLOWER(filename, filename);

        if (pInfo->vollabel && len > 8 && filename[8] == '.') {
            char *p = filename+8;
            while (*p++)
                p[-1] = *p;  /* disk label, and 8th char is dot:  remove dot */
        }

        if (!extra_len)         /* we're done here */
            break;

        /*
         * We truncated the filename, so print what's left and then fall
         * through to the SKIP routine.
         */
        FPRINTF(stderr, "[ %s ]\n", filename);
        len = extra_len;
        /*  FALL THROUGH...  */

    /*
     * Third case:  skip string, adjusting readbuf's internal variables
     * as necessary (and possibly skipping to and reading a new block of
     * data).
     */

    case SKIP:
        LSEEK(cur_zipfile_bufstart + (inptr-inbuf) + len)
        break;

    /*
     * Fourth case:  assume we're at the start of an "extra field"; malloc
     * storage for it and read data into the allocated space.
     */

    case EXTRA_FIELD:
        if (extra_field != (uch *)NULL)
            free(extra_field);
        if ((extra_field = (uch *)malloc(len)) == (uch *)NULL) {
            FPRINTF(stderr, LoadFarString(ExtraFieldTooLong), len);
            LSEEK(cur_zipfile_bufstart + (inptr-inbuf) + len)
        } else
            if (readbuf((char *)extra_field, len) == 0)
                return PK_EOF;
        break;

    } /* end switch (option) */
    return error;

} /* end function do_string() */





/***********************/
/* Function makeword() */
/***********************/

ush makeword(b)
    uch *b;
{
    /*
     * Convert Intel style 'short' integer to non-Intel non-16-bit
     * host format.  This routine also takes care of byte-ordering.
     */
    return (ush)((b[1] << 8) | b[0]);
}





/***********************/
/* Function makelong() */
/***********************/

ulg makelong(sig)
    uch *sig;
{
    /*
     * Convert intel style 'long' variable to non-Intel non-16-bit
     * host format.  This routine also takes care of byte-ordering.
     */
    return (((ulg)sig[3]) << 24)
        + (((ulg)sig[2]) << 16)
        + (((ulg)sig[1]) << 8)
        + ((ulg)sig[0]);
}





#ifdef ZMEM   /* memset, memcpy for systems without them */

/*********************/
/* Function memset() */
/*********************/

char *memset(buf, init, len)
    register char *buf, init;   /* buffer loc and initializer */
    register unsigned int len;  /* length of the buffer */
{
    char *start;

    start = buf;
    while (len--)
        *(buf++) = init;
    return start;
}





/*********************/
/* Function memcpy() */
/*********************/

char *memcpy(dst, src, len)
    register char *dst, *src;
    register unsigned int len;
{
    char *start;

    start = dst;
    while (len-- > 0)
        *dst++ = *src++;
    return start;
}

#endif /* ZMEM */





/************************/
/* Function zstrnicmp() */
/************************/

int zstrnicmp(s1, s2, n)
    register char *s1, *s2;
    register int n;
{
    for (; n > 0;  --n, ++s1, ++s2) {

        if (ToLower(*s1) != ToLower(*s2))
            /* test includes early termination of one string */
            return (ToLower(*s1) < ToLower(*s2))? -1 : 1;

        if (*s1 == '\0')   /* both strings terminate early */
            return 0;
    }
    return 0;
}





#ifdef SMALL_MEM

char rgchBigBuffer[512];
char rgchSmallBuffer[96];
char rgchSmallBuffer2[96];

/******************************/
/*  Function LoadFarString()  */   /* (and friends...) */
/******************************/

char *LoadFarString(char Far *sz)
{
    (void)zfstrcpy(rgchBigBuffer, sz);
    return rgchBigBuffer;
}

char *LoadFarStringSmall(char Far *sz)
{
    (void)zfstrcpy(rgchSmallBuffer, sz);
    return rgchSmallBuffer;
}

char *LoadFarStringSmall2(char Far *sz)
{
    (void)zfstrcpy(rgchSmallBuffer2, sz);
    return rgchSmallBuffer2;
}


/*************************/
/*  Function zfstrcpy()  */   /* portable clone of _fstrcpy() */
/*************************/

char Far * Far zfstrcpy(char Far *s1, const char Far *s2)
{
    char Far *p = s1;

    while ((*s1++ = *s2++) != '\0');
    return p;
}

#endif /* SMALL_MEM */
