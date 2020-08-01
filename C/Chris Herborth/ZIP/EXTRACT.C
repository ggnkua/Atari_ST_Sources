/*---------------------------------------------------------------------------

  extract.c

  This file contains the high-level routines ("driver routines") for extrac-
  ting and testing zipfile members.  It calls the low-level routines in files
  explode.c, inflate.c, unreduce.c and unshrink.c.

  ---------------------------------------------------------------------------*/


#include "unzip.h"
#include "crypt.h"
#ifdef MSWIN
#  include "wizunzip.h"
#  include "replace.h"
#endif

int newfile;      /* used also in file_io.c (flush()) */
ulg *crc_32_tab;  /* used also in file_io.c and crypt.c (full version) */

static void makecrc __((void));
static int store_info __((void));
static int extract_or_test_member __((void));


/*******************************/
/*  Strings used in extract.c  */
/*******************************/

static char Far VersionMsg[] =
  "   skipping: %-22s  need %s compat. v%u.%u (can do v%u.%u)\n";
static char Far ComprMsg[] =
  "   skipping: %-22s  compression method %d\n";
static char Far FilNamMsg[] =
  "%s:  bad filename length (%s)\n";
static char Far ExtFieldMsg[] =
  "%s:  bad extra field length (%s)\n";
static char Far OffsetMsg[] =
  "file #%d:  bad zipfile offset (%s):  %ld\n";
static char Far ExtractMsg[] =
  "%8sing: %-22s  %s%s";
#ifndef SFX
   static char Far LengthMsg[] =
     "%s  %s:  %ld bytes required to uncompress to %lu bytes;\n    %s\
      supposed to require %lu bytes%s%s%s\n";
#endif

static char Far BadFileCommLength[] = "\n%s:  bad file comment length\n";
static char Far LocalHdrSig[] = "local header sig";
static char Far BadLocalHdr[] = "\nfile #%d:  bad local header\n";
static char Far AttemptRecompensate[] = "  (attempting to re-compensate)\n";
static char Far SkipVolumeLabel[] = "   skipping: %-22s  %svolume label\n";
static char Far ReplaceQuery[] =
  "replace %s? [y]es, [n]o, [A]ll, [N]one, [r]ename: ";
static char Far AssumeNone[] = " NULL\n(assuming [N]one)\n";
static char Far NewName[] = "new name: ";
static char Far InvalidResponse[] = "error:  invalid response [%c]\n";
static char Far SkipCantGetPasswd[] =
  "   skipping: %-22s  unable to get password\n";
static char Far SkipIncorrectPasswd[] =
  "   skipping: %-22s  incorrect password\n";
static char Far ErrorInArchive[] = "At least one %serror was detected in %s.\n";
static char Far ZeroFilesTested[] = "Caution:  zero files tested in %s.\n";

#ifndef VMS
   static char Far VMSFormat[] =
     "\n%s:  stored in VMS format.  Extract anyway? (y/n) ";
#endif

#ifdef CRYPT
   static char Far FilesSkipBadPasswd[] =
     "%d file%s skipped because of incorrect password.\n";
   static char Far MaybeBadPasswd[] =
     "    (may instead be incorrect password)\n";
#else
   static char Far SkipEncrypted[] =
     "   skipping: %-22s  encrypted (not supported)\n";
#endif

static char Far NoErrInCompData[] =
  "No errors detected in compressed data of %s.\n";
static char Far NoErrInTestedFiles[] =
  "No errors detected in %s for the %d file%s tested.\n";
static char Far FilesSkipped[] =
  "%d file%s skipped because of unsupported compression or encoding.\n";

static char Far ErrUnzipFile[] = "  error:  %s%s %s\n";
static char Far ErrUnzipNoFile[] = "\n  error:  %s%s\n";
static char Far NotEnoughMem[] = "not enough memory to ";
static char Far InvalidComprData[] = "invalid compressed data to ";
static char Far Inflate[] = "inflate";

#ifndef SFX
   static char Far Explode[] = "explode";
   static char Far Unshrink[] = "unshrink";
#endif

static char Far FileUnknownCompMethod[] = "%s:  unknown compression method\n";
static char Far BadCRC[] = " bad CRC %08lx  (should be %08lx)\n";
static char Far UnsupportedExtraField[] =
  "warning:  unsupported extra field compression type--skipping\n";
static char Far BadExtraFieldCRC[] =
  "error [%s]:  bad extra field CRC %08lx (should be %08lx)\n";





/**************************************/
/*  Function extract_or_test_files()  */
/**************************************/

int extract_or_test_files()    /* return PK-type error code */
{
    uch *cd_inptr;
    int cd_incnt, error, error_in_archive=PK_COOL;
    int i, j, renamed, query, len, filnum=(-1), blknum=0;
    int *fn_matched=NULL, *xn_matched=NULL;
    ush members_remaining, num_skipped=0, num_bad_pwd=0;
    long cd_bufstart, bufstart, inbuf_offset, request;
    LONGINT old_extra_bytes=0L;
    static min_info info[DIR_BLKSIZ];


/*---------------------------------------------------------------------------
    The basic idea of this function is as follows.  Since the central di-
    rectory lies at the end of the zipfile and the member files lie at the
    beginning or middle or wherever, it is not very desirable to simply
    read a central directory entry, jump to the member and extract it, and
    then jump back to the central directory.  In the case of a large zipfile
    this would lead to a whole lot of disk-grinding, especially if each mem-
    ber file is small.  Instead, we read from the central directory the per-
    tinent information for a block of files, then go extract/test the whole
    block.  Thus this routine contains two small(er) loops within a very
    large outer loop:  the first of the small ones reads a block of files
    from the central directory; the second extracts or tests each file; and
    the outer one loops over blocks.  There's some file-pointer positioning
    stuff in between, but that's about it.  Btw, it's because of this jump-
    ing around that we can afford to be lenient if an error occurs in one of
    the member files:  we should still be able to go find the other members,
    since we know the offset of each from the beginning of the zipfile.
  ---------------------------------------------------------------------------*/

    pInfo = info;
    members_remaining = ecrec.total_entries_central_dir;
#ifdef CRYPT
    newzip = TRUE;
#endif

    /* malloc space for CRC table and generate it */
    if ((crc_32_tab = (ulg *)malloc(256*sizeof(ulg))) == (ulg *)NULL)
        return PK_MEM2;
    makecrc();

    /* malloc space for check on unmatched filespecs (OK if one or both NULL) */
    if (filespecs > 0  &&
        (fn_matched=(int *)malloc(filespecs*sizeof(int))) != (int *)NULL)
        for (i = 0;  i < filespecs;  ++i)
            fn_matched[i] = FALSE;
    if (xfilespecs > 0  &&
        (xn_matched=(int *)malloc(xfilespecs*sizeof(int))) != (int *)NULL)
        for (i = 0;  i < xfilespecs;  ++i)
            xn_matched[i] = FALSE;

/*---------------------------------------------------------------------------
    Begin main loop over blocks of member files.  We know the entire central
    directory is on this disk:  we would not have any of this information un-
    less the end-of-central-directory record was on this disk, and we would
    not have gotten to this routine unless this is also the disk on which
    the central directory starts.  In practice, this had better be the ONLY
    disk in the archive, but maybe someday we'll add multi-disk support.
  ---------------------------------------------------------------------------*/

    while (members_remaining) {
        j = 0;

        /*
         * Loop through files in central directory, storing offsets, file
         * attributes, case-conversion and text-conversion flags until block
         * size is reached.
         */

        while (members_remaining && (j < DIR_BLKSIZ)) {
            --members_remaining;
            pInfo = &info[j];

            if (readbuf(sig, 4) == 0) {
                error_in_archive = PK_EOF;
                members_remaining = 0;  /* ...so no more left to do */
                break;
            }
            if (strncmp(sig, central_hdr_sig, 4)) {  /* just to make sure */
                FPRINTF(stderr, LoadFarString(CentSigMsg), j);  /* sig not found */
                FPRINTF(stderr, LoadFarString(ReportMsg));   /* check binary transfers */
                error_in_archive = PK_BADERR;
                members_remaining = 0;  /* ...so no more left to do */
                break;
            }
            /* process_cdir_file_hdr() sets pInfo->hostnum, pInfo->lcflag */
            if ((error = process_cdir_file_hdr()) != PK_COOL) {
                error_in_archive = error;   /* only PK_EOF defined */
                members_remaining = 0;  /* ...so no more left to do */
                break;
            }
            if ((error = do_string(crec.filename_length,FILENAME)) != PK_COOL) {
                if (error > error_in_archive)
                    error_in_archive = error;
                if (error > PK_WARN) {  /* fatal:  no more left to do */
                    FPRINTF(stderr, LoadFarString(FilNamMsg), filename, "central");
                    members_remaining = 0;
                    break;
                }
            }
            if ((error = do_string(crec.extra_field_length, EXTRA_FIELD)) != 0)
            {
                if (error > error_in_archive)
                    error_in_archive = error;
                if (error > PK_WARN) {  /* fatal */
                    FPRINTF(stderr, LoadFarString(ExtFieldMsg), filename, "central");
                    members_remaining = 0;
                    break;
                }
            }
            if ((error = do_string(crec.file_comment_length,SKIP)) != PK_COOL) {
                if (error > error_in_archive)
                    error_in_archive = error;
                if (error > PK_WARN) {  /* fatal */
                    FPRINTF(stderr, LoadFarString(BadFileCommLength),
                            filename);
                    members_remaining = 0;
                    break;
                }
            }
            if (process_all_files) {
                if (store_info())
                    ++j;  /* file is OK; info[] stored; continue with next */
                else
                    ++num_skipped;
            } else {
                int   do_this_file = FALSE;
                char  **pfn = pfnames-1;

                while (*++pfn)
                    if (match(filename, *pfn, C_flag)) {
                        do_this_file = TRUE;   /* ^-- ignore case or not? */
                        if (fn_matched)
                            fn_matched[pfn-pfnames] = TRUE;
                        break;       /* found match, so stop looping */
                    }
                if (do_this_file) {  /* check if this is an excluded file */
                    char  **pxn = pxnames-1;

                    while (*++pxn)
                        if (match(filename, *pxn, C_flag)) {
                            do_this_file = FALSE;  /* ^-- ignore case or not? */
                            if (xn_matched)
                                xn_matched[pxn-pxnames] = TRUE;
                            break;
                        }
                }
                if (do_this_file)
                    if (store_info())
                        ++j;            /* file is OK */
                    else
                        ++num_skipped;  /* unsupp. compression or encryption */
            } /* end if (process_all_files) */


        } /* end while-loop (adding files to current block) */

        /* save position in central directory so can come back later */
        cd_bufstart = cur_zipfile_bufstart;
        cd_inptr = inptr;
        cd_incnt = incnt;

    /*-----------------------------------------------------------------------
        Second loop:  process files in current block, extracting or testing
        each one.
      -----------------------------------------------------------------------*/

        for (i = 0; i < j; ++i) {
            filnum = i + blknum*DIR_BLKSIZ;
            pInfo = &info[i];

            /* if the target position is not within the current input buffer
             * (either haven't yet read far enough, or (maybe) skipping back-
             * ward), skip to the target position and reset readbuf(). */

            /* LSEEK(pInfo->offset):  */
            request = pInfo->offset + extra_bytes;
            inbuf_offset = request % INBUFSIZ;
            bufstart = request - inbuf_offset;

            Trace(("\ndebug: request = %ld, inbuf_offset = %ld\n", request,
              inbuf_offset));
            Trace(("debug: bufstart = %ld, cur_zipfile_bufstart = %ld\n",
              bufstart, cur_zipfile_bufstart));
            if (request < 0) {
                FPRINTF(stderr, LoadFarStringSmall(SeekMsg), zipfn,
                  LoadFarString(ReportMsg));
                error_in_archive = PK_ERR;
                if (filnum == 0 && extra_bytes != 0L) {
                    FPRINTF(stderr, LoadFarString(AttemptRecompensate));
                    old_extra_bytes = extra_bytes;
                    extra_bytes = 0L;
                    request = pInfo->offset; /* could also check if this != 0 */
                    inbuf_offset = request % INBUFSIZ;
                    bufstart = request - inbuf_offset;
                    Trace(("debug: request = %ld, inbuf_offset = %ld\n",
                      request, inbuf_offset));
                    Trace(("debug: bufstart = %ld, cur_zipfile_bufstart = %ld\n"
                      , bufstart, cur_zipfile_bufstart));
                } else {
                    error_in_archive = PK_BADERR;
                    continue;  /* this one hosed; try next */
                }
            }
            /* try again */
            if (request < 0) {
                Trace(("debug: recompensated request still < 0\n"));
                FPRINTF(stderr, LoadFarStringSmall(SeekMsg), zipfn,
                  LoadFarString(ReportMsg));
                error_in_archive = PK_BADERR;
                continue;
            } else if (bufstart != cur_zipfile_bufstart) {
                Trace(("debug: bufstart != cur_zipfile_bufstart\n"));
                cur_zipfile_bufstart = lseek(zipfd,(LONGINT)bufstart,SEEK_SET);
                if ((incnt = read(zipfd,(char *)inbuf,INBUFSIZ)) <= 0) {
                    FPRINTF(stderr, LoadFarString(OffsetMsg), filnum, "lseek",
                      bufstart);
                    error_in_archive = PK_BADERR;
                    continue;   /* can still do next file */
                }
                inptr = inbuf + (int)inbuf_offset;
                incnt -= (int)inbuf_offset;
            } else {
                incnt += (inptr-inbuf) - (int)inbuf_offset;
                inptr = inbuf + (int)inbuf_offset;
            }

            /* should be in proper position now, so check for sig */
            if (readbuf(sig, 4) == 0) {  /* bad offset */
                FPRINTF(stderr, LoadFarString(OffsetMsg), filnum, "EOF",
                  request);
                error_in_archive = PK_BADERR;
                continue;   /* but can still try next one */
            }
            if (strncmp(sig, local_hdr_sig, 4)) {
                FPRINTF(stderr, LoadFarString(OffsetMsg), filnum,
                  LoadFarStringSmall(LocalHdrSig), request);
                error_in_archive = PK_ERR;
                if ((filnum == 0 && extra_bytes != 0L) ||
                    (extra_bytes == 0L && old_extra_bytes != 0L)) {
                    FPRINTF(stderr, LoadFarString(AttemptRecompensate));
                    if (extra_bytes) {
                        old_extra_bytes = extra_bytes;
                        extra_bytes = 0L;
                    } else
                        extra_bytes = old_extra_bytes;  /* third attempt */
                    LSEEK(pInfo->offset)
                    if (readbuf(sig, 4) == 0) {  /* bad offset */
                        FPRINTF(stderr, LoadFarString(OffsetMsg), filnum, "EOF",
                          request);
                        error_in_archive = PK_BADERR;
                        continue;   /* but can still try next one */
                    }
                    if (strncmp(sig, local_hdr_sig, 4)) {
                        FPRINTF(stderr, LoadFarString(OffsetMsg), filnum,
                          LoadFarStringSmall(LocalHdrSig), request);
                        error_in_archive = PK_BADERR;
                        continue;
                    }
                } else
                    continue;  /* this one hosed; try next */
            }
            if ((error = process_local_file_hdr()) != PK_COOL) {
                FPRINTF(stderr, LoadFarString(BadLocalHdr), filnum);
                error_in_archive = error;   /* only PK_EOF defined */
                continue;   /* can still try next one */
            }
            if ((error = do_string(lrec.filename_length,FILENAME)) != PK_COOL) {
                if (error > error_in_archive)
                    error_in_archive = error;
                if (error > PK_WARN) {
                    FPRINTF(stderr, LoadFarString(FilNamMsg), filename, "local");
                    continue;   /* go on to next one */
                }
            }
            if (extra_field != (uch *)NULL) {
                free(extra_field);
                extra_field = (uch *)NULL;
            }
            if ((error = do_string(lrec.extra_field_length,EXTRA_FIELD)) != 0) {
                if (error > error_in_archive)
                    error_in_archive = error;
                if (error > PK_WARN) {
                    FPRINTF(stderr, LoadFarString(ExtFieldMsg), filename, "local");
                    continue;   /* go on */
                }
            }

            /*
             * just about to extract file:  if extracting to disk, check if
             * already exists, and if so, take appropriate action according to
             * fflag/uflag/overwrite_all/etc. (we couldn't do this in upper
             * loop because we don't store the possibly renamed filename[] in
             * info[])
             */
            if (!tflag && !cflag) {
                renamed = FALSE;   /* user hasn't renamed output file yet */

startover:
                query = FALSE;
#ifdef MACOS
                macflag = (pInfo->hostnum == MAC_);
#endif
                /* mapname can create dirs if not freshening or if renamed */
                if ((error = mapname(renamed)) > PK_WARN) {
                    if (error == IZ_CREATED_DIR) {

                        /* GRR:  add code to set times/attribs on dirs--
                         * save to list, sort when done (a la zip), set
                         * times/attributes on deepest dirs first */

                    } else if (error == IZ_VOL_LABEL) {
                        FPRINTF(stderr,
                          LoadFarString(SkipVolumeLabel), filename,
#ifdef DOS_NT_OS2
                          volflag? "hard disk " :
#endif
                          "");
                    /*  if (!error_in_archive)
                            error_in_archive = PK_WARN;  */
                    } else if (error > PK_ERR  &&  error_in_archive < PK_ERR)
                        error_in_archive = PK_ERR;
                    Trace((stderr, "mapname(%s) returns error = %d\n", filename,
                      error));
                    continue;   /* go on to next file */
                }

                switch (check_for_newer(filename)) {
                    case DOES_NOT_EXIST:
                        if (fflag && !renamed)  /* don't skip if just renamed */
                            continue;   /* freshen (no new files):  skip */
                        break;
                    case EXISTS_AND_OLDER:
                        if (overwrite_none)
                            continue;   /* never overwrite:  skip file */
                        if (!overwrite_all && !force_flag)
                            query = TRUE;
                        break;
                    case EXISTS_AND_NEWER:             /* (or equal) */
                        if (overwrite_none || (uflag && !renamed))
                            continue;  /* skip if update/freshen & orig name */
                        if (!overwrite_all && !force_flag)
                            query = TRUE;
                        break;
                }
                if (query) {
#ifdef MSWIN
                    FARPROC lpfnprocReplace;
                    int ReplaceDlgRetVal;   /* replace dialog return value */

                    ShowCursor(FALSE);      /* turn off cursor */
                    SetCursor(hSaveCursor); /* restore the cursor */
                    lpfnprocReplace = MakeProcInstance(ReplaceProc, hInst);
                    ReplaceDlgRetVal = DialogBoxParam(hInst, "Replace",
                      hWndMain, lpfnprocReplace, (DWORD)(LPSTR)filename);
                    FreeProcInstance(lpfnprocReplace);
                    hSaveCursor = SetCursor(hHourGlass);
                    ShowCursor(TRUE);
                    switch (ReplaceDlgRetVal) {
                        case IDM_REPLACE_RENAME:
                            renamed = TRUE;
                            goto startover;
                        case IDM_REPLACE_YES:
                            break;
                        case IDM_REPLACE_ALL:
                            overwrite_all = TRUE;
                            overwrite_none = FALSE;  /* just to make sure */
                            break;
                        case IDM_REPLACE_NONE:
                            overwrite_none = TRUE;
                            overwrite_all = FALSE;  /* make sure */
                            force_flag = FALSE;     /* ditto */
                            /* FALL THROUGH, skip */
                        case IDM_REPLACE_NO:
                            continue;
                    }
#else /* !MSWIN */
reprompt:
                    FPRINTF(stderr, LoadFarString(ReplaceQuery), filename);
                    FFLUSH(stderr);
                    if (fgets(answerbuf, 9, stdin) == (char *)NULL) {
                        FPRINTF(stderr, LoadFarString(AssumeNone));
                        FFLUSH(stderr);
                        *answerbuf = 'N';
                        if (!error_in_archive)
                            error_in_archive = 1;  /* not extracted:  warning */
                    }
                    switch (*answerbuf) {
                        case 'A':   /* dangerous option:  force caps */
                            overwrite_all = TRUE;
                            overwrite_none = FALSE;  /* just to make sure */
                            break;
                        case 'r':
                        case 'R':
                            do {
                                FPRINTF(stderr, LoadFarString(NewName));
                                FFLUSH(stderr);
                                fgets(filename, FILNAMSIZ, stdin);
                                /* usually get \n here:  better check for it */
                                len = strlen(filename);
                                if (filename[len-1] == '\n')
                                    filename[--len] = 0;
                            } while (len == 0);
                            renamed = TRUE;
                            goto startover;   /* sorry for a goto */
                        case 'y':
                        case 'Y':
                            break;
                        case 'N':
                            overwrite_none = TRUE;
                            overwrite_all = FALSE;  /* make sure */
                            force_flag = FALSE;     /* ditto */
                            /* FALL THROUGH, skip */
                        case 'n':
                            continue;   /* skip file */
                        default:
                            FPRINTF(stderr, LoadFarString(InvalidResponse),
                              *answerbuf);   /* warn the user */
                            goto reprompt;   /* why not another goto? */
                    } /* end switch (*answerbuf) */
#endif /* ?MSWIN */
                } /* end if (query) */
            } /* end if (extracting to disk) */

#ifdef CRYPT
            if (pInfo->encrypted && (error = decrypt()) != PK_COOL) {
                if (error == PK_MEM2) {
                    if (error > error_in_archive)
                        error_in_archive = error;
                    FPRINTF(stderr,
                      LoadFarString(SkipCantGetPasswd), filename);
                } else {  /* (error == PK_WARN) */
                    if (!((tflag && qflag) || (!tflag && !QCOND2)))
                        FPRINTF(stderr,
                          LoadFarString(SkipIncorrectPasswd), filename);
                    ++num_bad_pwd;
                }
                continue;   /* go on to next file */
            }
#endif /* CRYPT */
            disk_full = 0;
            if ((error = extract_or_test_member()) != PK_COOL) {
                if (error > error_in_archive)
                    error_in_archive = error;       /* ...and keep going */
                if (disk_full > 1) {
                    free(crc_32_tab);
                    if (fn_matched)
                        free(fn_matched);
                    if (xn_matched)
                        free(xn_matched);
                    return error_in_archive;        /* (unless disk full) */
                }
            }
        } /* end for-loop (i:  files in current block) */


        /*
         * Jump back to where we were in the central directory, then go and do
         * the next batch of files.
         */

        cur_zipfile_bufstart = lseek(zipfd, (LONGINT)cd_bufstart, SEEK_SET);
        read(zipfd, (char *)inbuf, INBUFSIZ);  /* were there b4 ==> no error */
        inptr = cd_inptr;
        incnt = cd_incnt;
        ++blknum;

#ifdef TEST
        printf("\ncd_bufstart = %ld (%.8lXh)\n", cd_bufstart, cd_bufstart);
        printf("cur_zipfile_bufstart = %ld (%.8lXh)\n", cur_zipfile_bufstart,
          cur_zipfile_bufstart);
        printf("inptr-inbuf = %d\n", inptr-inbuf);
        printf("incnt = %d\n\n", incnt);
#endif

    } /* end while-loop (blocks of files in central directory) */

/*---------------------------------------------------------------------------
    Check for unmatched filespecs on command line and print warning if any
    found.  Free allocated memory.
  ---------------------------------------------------------------------------*/

    if (fn_matched) {
        for (i = 0;  i < filespecs;  ++i)
            if (!fn_matched[i])
                FPRINTF(stderr, LoadFarString(FilenameNotMatched),
                  pfnames[i]);
        free(fn_matched);
    }
    if (xn_matched) {
        for (i = 0;  i < xfilespecs;  ++i)
            if (!xn_matched[i])
                FPRINTF(stderr, LoadFarString(ExclFilenameNotMatched),
                  pxnames[i]);
        free(xn_matched);
    }
    free(crc_32_tab);

/*---------------------------------------------------------------------------
    Double-check that we're back at the end-of-central-directory record, and
    print quick summary of results, if we were just testing the archive.  We
    send the summary to stdout so that people doing the testing in the back-
    ground and redirecting to a file can just do a "tail" on the output file.
  ---------------------------------------------------------------------------*/

    if (readbuf(sig, 4) == 0)
        error_in_archive = PK_EOF;
    if (strncmp(sig, end_central_sig, 4)) {         /* just to make sure */
        FPRINTF(stderr, LoadFarString(EndSigMsg));  /* didn't find sig */
        FPRINTF(stderr, LoadFarString(ReportMsg));  /* check binary transfers */
        if (!error_in_archive)       /* don't overwrite stronger error */
            error_in_archive = PK_WARN;
    }
    ++filnum;  /* initialized to -1, so now zero if no files found */
    if (tflag) {
        int num=filnum - num_bad_pwd;

        if (qflag < 2) {         /* GRR 930710:  was (qflag == 1) */
            if (error_in_archive)
                PRINTF(LoadFarString(ErrorInArchive),
                  (error_in_archive == 1)? "warning-" : "", zipfn);
            else if (num == 0)
                PRINTF(LoadFarString(ZeroFilesTested), zipfn);
            else if (process_all_files && (num_skipped+num_bad_pwd == 0))
                PRINTF(LoadFarString(NoErrInCompData), zipfn);
            else
                PRINTF(LoadFarString(NoErrInTestedFiles),
                  zipfn, num, (num==1)? "":"s");
            if (num_skipped > 0)
                PRINTF(LoadFarString(FilesSkipped), num_skipped,
                  (num_skipped==1)? "":"s");
#ifdef CRYPT
            if (num_bad_pwd > 0)
                PRINTF(LoadFarString(FilesSkipBadPasswd),
                  num_bad_pwd, (num_bad_pwd==1)? "":"s");
#endif /* CRYPT */
        } else if ((qflag == 0) && !error_in_archive && (num == 0))
            PRINTF(LoadFarString(ZeroFilesTested), zipfn);
    }

    /* give warning if files not tested or extracted */
    if ((filnum == 0) && error_in_archive <= PK_WARN)
        error_in_archive = PK_FIND;   /* no files found at all */
    else if ((num_skipped > 0) && !error_in_archive)
        error_in_archive = PK_WARN;
#ifdef CRYPT
    else if ((num_bad_pwd > 0) && !error_in_archive)
        error_in_archive = PK_WARN;
#endif /* CRYPT */

    return error_in_archive;

} /* end function extract_or_test_files() */





/**********************/
/* Function makecrc() */
/**********************/

static void makecrc()
/*
  Generate a table for a byte-wise 32-bit CRC calculation on the polynomial:
  x^32+x^26+x^23+x^22+x^16+x^12+x^11+x^10+x^8+x^7+x^5+x^4+x^2+x+1.

  Polynomials over GF(2) are represented in binary, one bit per coefficient,
  with the lowest powers in the most significant bit.  Then adding polynomials
  is just exclusive-or, and multiplying a polynomial by x is a right shift by
  one.  If we call the above polynomial p, and represent a byte as the
  polynomial q, also with the lowest power in the most significant bit (so the
  byte 0xb1 is the polynomial x^7+x^3+x+1), then the CRC is (q*x^32) mod p,
  where a mod b means the remainder after dividing a by b.

  This calculation is done using the shift-register method of multiplying and
  taking the remainder.  The register is initialized to zero, and for each
  incoming bit, x^32 is added mod p to the register if the bit is a one (where
  x^32 mod p is p+x^32 = x^26+...+1), and the register is multiplied mod p by
  x (which is shifting right by one and adding x^32 mod p if the bit shifted
  out is a one).  We start with the highest power (least significant bit) of
  q and repeat for all eight bits of q.

  The table is simply the CRC of all possible eight bit values.  This is all
  the information needed to generate CRC's on data a byte at a time for all
  combinations of CRC register values and incoming bytes.  The table is
  written to stdout as 256 long hexadecimal values in C language format.
*/
{
    ulg crc;   /* crc shift register */
    ulg xor;   /* polynomial exclusive-or pattern */
    int i;     /* counter for all possible eight bit values */
    int k;     /* byte being shifted into crc apparatus */
    /* terms of polynomial defining this crc (except x^32): */
    static uch p[] = {0,1,2,4,5,7,8,10,11,12,16,22,23,26};

    /* make exclusive-or pattern from polynomial (0xedb88320) */
    xor = 0L;
    for (i = 0; i < sizeof(p)/sizeof(uch); i++)
        xor |= 1L << (31 - p[i]);

    crc_32_tab[0] = 0L;
    Trace((stderr, "makecrc():  crc_32_tab[] = {\n  0x%08lxL", crc_32_tab[0]));
    /* the idea to initialize the register with the byte instead of
     * zero was stolen from Haruhiko Okumura's ar002 */
    for (i = 1; i < 256; i++) {
        crc = i;
        for (k = 8; k; k--)
            crc = crc & 1 ? (crc >> 1) ^ xor : crc >> 1;
        crc_32_tab[i] = crc;
        Trace((stderr, i % 5 ? ", 0x%08lxL" : ",\n  0x%08lxL", crc_32_tab[i]));
    }
    Trace((stderr, "\n};\n"));

} /* end function makecrc() */





/***************************/
/*  Function store_info()  */
/***************************/

static int store_info()   /* return 0 if skipping, 1 if OK */
{
#ifdef SFX
#  define UNKN_COMPR \
   (crec.compression_method!=STORED && crec.compression_method!=DEFLATED)
#else
#  define UNKN_COMPR \
   (crec.compression_method>IMPLODED && crec.compression_method!=DEFLATED)
#endif

/*---------------------------------------------------------------------------
    Check central directory info for version/compatibility requirements.
  ---------------------------------------------------------------------------*/

    pInfo->encrypted = crec.general_purpose_bit_flag & 1;       /* bit field */
    pInfo->ExtLocHdr = (crec.general_purpose_bit_flag & 8) == 8;/* bit field */
    pInfo->textfile = crec.internal_file_attributes & 1;        /* bit field */
    pInfo->crc = crec.crc32;
    pInfo->compr_size = crec.csize;

    switch (aflag) {
        case 0:
            pInfo->textmode = FALSE;   /* bit field */
            break;
        case 1:
            pInfo->textmode = pInfo->textfile;   /* auto-convert mode */
            break;
        default:  /* case 2: */
            pInfo->textmode = TRUE;
            break;
    }

    if (crec.version_needed_to_extract[1] == VMS_) {
        if (crec.version_needed_to_extract[0] > VMS_UNZIP_VERSION) {
            if (!((tflag && qflag) || (!tflag && !QCOND2)))
                FPRINTF(stderr, LoadFarString(VersionMsg), filename, "VMS",
                  crec.version_needed_to_extract[0] / 10,
                  crec.version_needed_to_extract[0] % 10,
                  VMS_UNZIP_VERSION / 10, VMS_UNZIP_VERSION % 10);
            return 0;
        }
#ifndef VMS   /* won't be able to use extra field, but still have data */
        else if (!tflag && !force_flag) {  /* if forcing, extract regardless */
            FPRINTF(stderr, LoadFarString(VMSFormat), filename);
            FFLUSH(stderr);
            fgets(answerbuf, 9, stdin);
            if ((*answerbuf != 'y') && (*answerbuf != 'Y'))
                return 0;
        }
#endif /* !VMS */
    /* usual file type:  don't need VMS to extract */
    } else if (crec.version_needed_to_extract[0] > UNZIP_VERSION) {
        if (!((tflag && qflag) || (!tflag && !QCOND2)))
            FPRINTF(stderr, LoadFarString(VersionMsg), filename, "PK",
              crec.version_needed_to_extract[0] / 10,
              crec.version_needed_to_extract[0] % 10,
              UNZIP_VERSION / 10, UNZIP_VERSION % 10);
        return 0;
    }

    if UNKN_COMPR {
        if (!((tflag && qflag) || (!tflag && !QCOND2)))
            FPRINTF(stderr, LoadFarString(ComprMsg), filename,
              crec.compression_method);
        return 0;
    }
#ifndef CRYPT
    if (pInfo->encrypted) {
        if (!((tflag && qflag) || (!tflag && !QCOND2)))
            FPRINTF(stderr, LoadFarString(SkipEncrypted), filename);
        return 0;
    }
#endif /* !CRYPT */

    /* map whatever file attributes we have into the local format */
    mapattr();   /* GRR:  worry about return value later */

    pInfo->offset = (long) crec.relative_offset_local_header;
    return 1;

} /* end function store_info() */





/***************************************/
/*  Function extract_or_test_member()  */
/***************************************/

static int extract_or_test_member()    /* return PK-type error code */
{
    char *nul="[empty] ", *txt="[text]  ", *bin="[binary]";
    register int b;
    int r, error=PK_COOL;



/*---------------------------------------------------------------------------
    Initialize variables, buffers, etc.
  ---------------------------------------------------------------------------*/

    bits_left = 0;     /* unreduce and unshrink only */
    bitbuf = 0L;       /* unreduce and unshrink only */
    zipeof = 0;        /* unreduce and unshrink only */
    newfile = TRUE;
    crc32val = 0xFFFFFFFFL;

#ifdef SYMLINKS
    /* if file came from Unix and is a symbolic link and we are extracting
     * to disk, prepare to restore the link */
    if (S_ISLNK(pInfo->file_attr) && (pInfo->hostnum == UNIX_) && !tflag &&
        !cflag && (lrec.ucsize > 0))
        symlnk = TRUE;
    else
        symlnk = FALSE;
#endif /* SYMLINKS */

    if (tflag) {
        if (!qflag) {
            FPRINTF(stdout, LoadFarString(ExtractMsg), "test", filename, "", "");
            fflush(stdout);
        }
    } else {
        if (cflag) {
            outfile = stdout;
#ifdef DOS_NT_OS2
            setmode(fileno(outfile), O_BINARY);
#           define NEWLINE "\r\n"
#else
#           define NEWLINE "\n"
#endif
#ifdef VMS
            if (open_outfile())   /* VMS:  required even for stdout! */
                return PK_DISK;
#endif
        } else if (open_outfile())
            return PK_DISK;
    }

/*---------------------------------------------------------------------------
    Unpack the file.
  ---------------------------------------------------------------------------*/

    switch (lrec.compression_method) {
        case STORED:
            if (!tflag && QCOND2) {
#ifdef SYMLINKS
                if (symlnk)   /* can also be deflated, but rarer... */
                    FPRINTF(stdout, LoadFarString(ExtractMsg), "link", filename,
                      "", "");
                else
#endif /* SYMLINKS */
                FPRINTF(stdout, LoadFarString(ExtractMsg), "extract", filename,
                  (aflag != 1 /* && pInfo->textfile == pInfo->textmode */ )? ""
                  : (lrec.ucsize == 0L? nul : (pInfo->textfile? txt : bin)),
                  cflag? NEWLINE : "");
                fflush(stdout);
            }
            outptr = slide;
            outcnt = 0L;
            while ((b = NEXTBYTE) != EOF && !disk_full) {
                *outptr++ = (uch)b;
                if (++outcnt == WSIZE) {
                    flush(slide, outcnt, 0);
                    outptr = slide;
                    outcnt = 0L;
                }
            }
            if (outcnt)          /* flush final (partial) buffer */
                flush(slide, outcnt, 0);
            break;

#ifndef SFX
        case SHRUNK:
            if (!tflag && QCOND2) {
                FPRINTF(stdout, LoadFarString(ExtractMsg),
                  LoadFarStringSmall(Unshrink), filename,
                  (aflag != 1 /* && pInfo->textfile == pInfo->textmode */ )? ""
                  : (pInfo->textfile? txt : bin), cflag? NEWLINE : "");
                fflush(stdout);
            }
            if ((r = unshrink()) != PK_COOL) {
                if ((tflag && qflag) || (!tflag && !QCOND2))
                    FPRINTF(stderr, LoadFarStringSmall(ErrUnzipFile),
                      LoadFarString(NotEnoughMem),
                      LoadFarStringSmall2(Unshrink),
                      filename);
                else
                    FPRINTF(stderr, LoadFarStringSmall(ErrUnzipNoFile),
                      LoadFarString(NotEnoughMem),
                      LoadFarStringSmall2(Unshrink));
                error = r;
            }
            break;

        case REDUCED1:
        case REDUCED2:
        case REDUCED3:
        case REDUCED4:
            if (!tflag && QCOND2) {
                FPRINTF(stdout, LoadFarString(ExtractMsg), "unreduc", filename,
                  (aflag != 1 /* && pInfo->textfile == pInfo->textmode */ )? ""
                  : (pInfo->textfile? txt : bin), cflag? NEWLINE : "");
                fflush(stdout);
            }
            unreduce();
            break;

        case IMPLODED:
            if (!tflag && QCOND2) {
                FPRINTF(stdout, LoadFarString(ExtractMsg), "explod", filename,
                  (aflag != 1 /* && pInfo->textfile == pInfo->textmode */ )? ""
                  : (pInfo->textfile? txt : bin), cflag? NEWLINE : "");
                fflush(stdout);
            }
            if (((r = explode()) != 0) && (r != 5)) {   /* treat 5 specially */
                if ((tflag && qflag) || (!tflag && !QCOND2))
                    FPRINTF(stderr, LoadFarStringSmall(ErrUnzipFile), r == 3?
                      LoadFarString(NotEnoughMem) :
                      LoadFarString(InvalidComprData),
                      LoadFarStringSmall2(Explode), filename);
                else
                    FPRINTF(stderr, LoadFarStringSmall(ErrUnzipNoFile), r == 3?
                      LoadFarString(NotEnoughMem) :
                      LoadFarString(InvalidComprData),
                      LoadFarStringSmall2(Explode));
                error = (r == 3)? PK_MEM3 : PK_ERR;
            }
            if (r == 5) {
                int warning = ((ulg)used_csize <= lrec.csize);

                if ((tflag && qflag) || (!tflag && !QCOND2))
                    FPRINTF(stderr, LoadFarString(LengthMsg), "", warning?
                      "warning":"error", used_csize, lrec.ucsize, warning?
                      "  ":"", lrec.csize, " [", filename, "]");
                else
                    FPRINTF(stderr, LoadFarString(LengthMsg), "\n", warning?
                      "warning":"error", used_csize, lrec.ucsize, warning?
                      "  ":"", lrec.csize, "", "", ".");
                error = warning? PK_WARN : PK_ERR;
            }
            break;
#endif /* !SFX */

        case DEFLATED:
            if (!tflag && QCOND2) {
                FPRINTF(stdout, LoadFarString(ExtractMsg), "inflat", filename,
                  (aflag != 1 /* && pInfo->textfile == pInfo->textmode */ )? ""
                  : (pInfo->textfile? txt : bin), cflag? NEWLINE : "");
                fflush(stdout);
            }
            if ((r = inflate()) != 0) {
                if ((tflag && qflag) || (!tflag && !QCOND2))
                    FPRINTF(stderr, LoadFarStringSmall(ErrUnzipFile), r == 3?
                      LoadFarString(NotEnoughMem) :
                      LoadFarString(InvalidComprData),
                      LoadFarStringSmall2(Inflate), filename);
                else
                    FPRINTF(stderr, LoadFarStringSmall(ErrUnzipNoFile), r == 3?
                      LoadFarString(NotEnoughMem) :
                      LoadFarString(InvalidComprData),
                      LoadFarStringSmall2(Inflate));
                error = (r == 3)? PK_MEM3 : PK_ERR;
            }
            break;

        default:   /* should never get to this point */
            FPRINTF(stderr, LoadFarString(FileUnknownCompMethod), filename);
            /* close and delete file before return? */
            return PK_WARN;

    } /* end switch (compression method) */

    if (disk_full) {            /* set by flush() */
        if (disk_full > 1)
            return PK_DISK;
        error = PK_WARN;
    }

/*---------------------------------------------------------------------------
    Close the file and set its date and time (not necessarily in that order),
    and make sure the CRC checked out OK.  Logical-AND the CRC for 64-bit
    machines (redundant on 32-bit machines).
  ---------------------------------------------------------------------------*/

#ifdef VMS                  /* VMS:  required even for stdout! (final flush) */
    if (!tflag)             /* don't close NULL file */
#else
    if (!tflag && !cflag)   /* don't close NULL file or stdout */
#endif
        close_outfile();

    if (error > PK_WARN)  /* don't print redundant CRC error if error already */
        return error;

    if ((crc32val = ((~crc32val) & 0xFFFFFFFFL)) != lrec.crc32) {
        /* if quiet enough, we haven't output the filename yet:  do it */
        if ((tflag && qflag) || (!tflag && !QCOND2))
            FPRINTF(stderr, "%-22s ", filename);
        FPRINTF(stderr, LoadFarString(BadCRC), crc32val, lrec.crc32);
#ifdef CRYPT
        if (pInfo->encrypted)
          FPRINTF(stderr, LoadFarString(MaybeBadPasswd));
#endif
        FFLUSH(stderr);
        error = PK_ERR;
    } else if (tflag) {
        if (!qflag)
            FPRINTF(stdout, " OK\n");
    } else {
        if (QCOND2 && !error)
            FPRINTF(stdout, "\n"); /* GRR:  is stdout reset to text mode yet? */
    }

    return error;

} /* end function extract_or_test_member() */





/***************************/
/*  Function memextract()  */
/***************************/

int memextract(tgt, tgtsize, src, srcsize)   /* extract compressed extra */
    uch *tgt, *src;                          /*  field block; return PK- */
    ulg tgtsize, srcsize;                    /*  type error level */
{
    uch *old_inptr=inptr;
    int  old_incnt=incnt, r, error=PK_OK;
    ush  method;
    ulg  extra_field_crc;


    method = makeword(src);
    extra_field_crc = makelong(src+2);

    /* compressed extra field exists completely in memory at this location: */
    inptr = src + 2 + 4;      /* method and extra_field_crc */
    incnt = (int)(csize = (long)(srcsize - (2 + 4)));
    mem_mode = TRUE;

    switch (method) {
        case STORED:
            memcpy((char *)tgt, (char *)inptr, (extent)incnt);
            outcnt = csize;   /* for CRC calculation */
            break;
        case DEFLATED:
            if ((r = inflate()) != 0) {
                FPRINTF(stderr, LoadFarStringSmall(ErrUnzipNoFile), r == 3?
                  LoadFarString(NotEnoughMem) :
                  LoadFarString(InvalidComprData),
                  LoadFarStringSmall2(Inflate));
                error = (r == 3)? PK_MEM3 : PK_ERR;
            }
            if (outcnt == 0L)   /* inflate's final FLUSH sets outcnt */
                break;
            if (outcnt <= tgtsize)
                memcpy((char *)tgt, (char *)slide, (extent)outcnt);
            else
                error = PK_MEM4;   /* GRR:  should be passed up via SetEAs() */
            break;
        default:
            FPRINTF(stderr, LoadFarString(UnsupportedExtraField));
            error = PK_WARN;   /* GRR:  should be passed on up via SetEAs() */
            break;
    }

    inptr = old_inptr;
    incnt = old_incnt;
    mem_mode = FALSE;

    if (!error) {
        register ulg crcval = 0xFFFFFFFFL;
        register ulg n = outcnt;   /* or tgtsize?? */
        register uch *p = tgt;

        while (n--)
            crcval = crc_32_tab[((uch)crcval ^ (*p++)) & 0xff] ^ (crcval >> 8);
        crcval = (~crcval) & 0xFFFFFFFFL;

        if (crcval != extra_field_crc) {
            FPRINTF(stderr, LoadFarString(BadExtraFieldCRC),
              zipfn, crcval, extra_field_crc);
            error = PK_WARN;
        }
    }
    return error;

} /* end function memextract() */
