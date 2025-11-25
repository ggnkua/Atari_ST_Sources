/* Version */
#define _7P_VMAJOR 2
#define _7P_VMINOR 03
#define VERSION "2.03"
#define DATE "920717"

/*********************************************************************
*** 7PLUS ASCII- Encoder/Decoder, Axel Bauda, DG1BBQ @DB0CL.DEU.EU  ***
**********************************************************************
***
*** Compile:
*** --------
***
*** -------
*** | IBM |  : SMALL memory model
*** -------
***            Turbo C++ and Turbo C 2.0:
***            MAKE -FTC_MAKE
***
***      also: Turbo C++:
***            Compile in IDE using 7PLUS.PRJ
***
***      or  : Turbo C 2.0:
***            Rename TC2.PRJ to 7PLUS.PRJ and compile in IDE
***
*** ---------
*** | ATARI |  Pure C 1.0/Turbo C 2.0 : Use 7PLST.PRJ
*** ---------
*** --------
*** | UNIX |   support by Torsten H. Bischoff, DF6NL @ DB0BOX
*** --------
*** Supported systems are:
***   Interactive UNIX 386
***   SCO XENIX 386
***   VAX BSD 4.3/ Ultrix 4.1
***
*** Compile: make -fu_make
***
*** -------
*** |AMIGA|    Manx Aztec C 5.1b/5.2:  make -fa_make
*** -------
***
*** All systems:
*** Signed or unsigned char per default is: don't care.
*** No floating point lib required.
***
*** TABSIZE when editing: 2; don't insert real TABs (^I), use spaces instead.
***
*** When porting or modifying this source, make SURE it can still be compiled
*** on all systems! Do this by using #ifdef directives! Please let me know
*** about the modifications or portations, so I can include them in the origi-
*** nal 7PLUS.
***
**********************************************************************
***  7PLUS ASCII-Encoder/Decoder, Axel Bauda, DG1BBQ @DB0CL.DEU.EU  ***
**********************************************************************
***
*** File converter for transfer of arbitrary binary data
*** via store & forward.
***
*** 7PLUS is HAMWARE. No commercial use. Pass on only in it's entirety!
*** There is no warranty for the proper functioning. Use at own risk.
***
*** Tnx to:
*** DL1XAO, DB7YAH, DG3YFU and DL6YAV for testing and tips regarding
*** ATARI ST.
*** DB5ZP for his efforts concerning the AMIGA implementation.
*** DF6NL for adding UNIX-compatibility.
***
 */

#include "7plus.h"

/** globals **/
uint    crctab[256];
byte    decode[256];
byte    code  [216];
byte    extended = INDICATE;
size_t  buflen;
char    _drive[MAXDRIVE], _dir[MAXDIR], _file[MAXFILE], _ext[MAXEXT];
char    spaces[] = "                                                   ";
char    *endstr;
char    delimit[] = "\n";
char    cant[] = "\007\n'%s': Can't open. Break.\n";
char    notsame[] = "\007Filesize in %s differs from the original file!\nBreak.\n";
int     noquery = 0;
int     force   = 0;
int     fls     = 0;
int     autokill= 0;
struct  m_index *index;

#ifdef __TOS__
  int   nowait  = 0;
#endif

char logon_ctrl[] =
#ifdef __MSDOS__
"\nษออออออออออออออออออออออออออออออออออออออออออออออออป\nบ%sบ\nบ%sบ\nศออออออออออ\
ออออออออออออออออออออออออออออออออออออออผ\n";
#else
 #ifdef __TOS__
"\033p\033v\n%s\n%s\n\033q\n";
 #else
  #ifdef _AMIGA_
"\n\033[3m%s\n%s\033[0m\n\n";
  #else    /* neither __MSDOS__ or __TOS__ or _AMIGA_ */
"\n[]----------------------------------------------[]\n|%s|\n|%s|\n[]---------\
-------------------------------------[]\n";
  #endif   /* ifdef _AMIGA_   */
 #endif   /* ifdef __TOS__   */
#endif   /* ifdef __MSDOS__ */

char *logon[] = { "   7PLUS - file converter for store & forward   ",
                  " version "VERSION" ("DATE"), (C) DG1BBQ@DB0CL.DEU.EU " };

char *help[] = {
#ifdef _AMIGA_
"\n\033[1mExamples:\n",
"7plus <FILE.7pl>      Decode <FILE.7pl>. create <FILE.err>, if errors detected\n",
"7plus <FILE.p01>      Recombine & decode.                    \"\n",
"7plus <FILE>          Automatically correct and decode.\n",
"                      If a file named <FILE> exists, encode it.\n",
"7plus <FILE>          Encode (automatically split into 10K chunks).\n",
"             -s 30    30 lines/file (max 512 lines/file).\n",
"             -sp 3    3 parts of roughly equal size (max 255 parts).\n",
"             -sb 3000 Parts of roughly 3000 bytes (max 36000).\n",
"7plus <FILE.err> dh0:/pr/ Create correction file. look for <FILE> in dh0:/pr/.\n",
"7plus <FILE.cor>      Use <FILE.cor> to correct metafile <FILE.7mf>.\n",
"7plus <FILE.7pl> -c   Use 7PLUS-file as a correction file.\n",
"7plus <LOGFILE> -x <TEXT> Extract 7plus-files from <LOGFILE>. Only extract a\n",
"                      file, if its name contains <TEXT>. Omit <TEXT> to\n",
"                      extract files in <LOGFILE>.\n",
"7plus <FILE.err> <FILE2.err> -j  Add contents of error report <FILE2err> to\n",
"                      error report <FILE.err>.\n",
"7plus <FILE.err> -j   Add contents of error reports <FILE.eXX> to error\n",
"                      report <FILE.err> (multiple join).\n",
#ifdef _CHSIZE_OK
"7plus <FILE.7mf>      Create new error report from metafile.\n\n",
#else
"7plus <FILE.7ix>      Create new error report from indexfile.\n\n",
#endif
"Other Options:\n",
"-k           Automatically kill all obsolete files.\n",
"-p           Use Packet line separator CR for encoded files. Should be\n",
"             used, when uploading files to the BBS in binary mode!\n",
"-r 5         When encoding, only create part 5. Be sure to split the same\n",
"             way as for the first upload!\n",
"-t /ex       Append string '/ex' to encoded files (BBS file termination).\n",
"-tb <FILE>   Get head and footlines from <FILE> when encoding. See manual.\n",
"-y           Assume YES on all queries.\n",
"-#           Create 7PLUS.FLS when encoding. See Manual.\n",
"\033[0m\n\n",
#else
"\nExamples:\n",
"7plus file.7pl          Decode file.7pl. create file.err, if errors detected.\n",
"7plus file.p01          Recombine & decode.              \"\n",
"7plus file              Automatically correct and decode.\n",
"                        If a file named 'file' exists, encode it.\n",
"7plus file.txt          Encode (automatically split into 10K chunks).\n",
"               -s 30    30 lines/file (max 512 lines/file).\n",
"               -sp 3    3 parts of roughly equal size (max 255 parts).\n",
"               -sb 3000 Parts of roughly 3000 bytes (max 36000).\n",
"7plus file.err c:\\pr\\   Create correction file. look for file.txt in c:\\pr\\.\n",
"7plus file.cor          Use file.cor to correct metafile file.7mf.\n",
"7plus file.7pl -c       Use 7PLUS-file as a correction file.\n",
"7plus logfile -x text   Extract 7plus-files from logfile. Only extract a file\n",
"                        if its name contains 'text'. Omit 'text' to extract\n",
"                        all files in logfile.\n",
"7plus file.err file2.err -j  Add contents of error report file2.err to\n",
"                        error report file.err.\n",
"7plus file.err -j       Add contents of error reports file.eXX to error\n",
"                        report file.err (multiple join).\n",
#ifdef _CHSIZE_OK
"7plus file.7mf          Create new error report from metafile.\n\n",
#else
"7plus file.7ix          Create new error report from indexfile.\n\n",
#endif
"Other Options:\n",
"-k           Automatically kill all obsolete files.\n",
#ifdef __TOS__
"-n           Don't wait for a keystroke at termination.\n",
#endif
"-p           Use Packet line separator CR for encoded files. Should be\n",
"             used, when uploading files to the BBS in binary mode!\n",
"-r 5         When encoding, only create part 5. Be sure to split the same\n",
"             way as for the first upload!\n",
"-t /ex       Append string '/ex' to encoded files (BBS file termination).\n",
"-tb file     Get head and footlines from 'file' when encoding. See manual.\n",
"-y           Assume YES on all queries.\n",
"-#           Create 7PLUS.FLS when encoding. See manual.\n",
#endif
NULLCP
};


/* Depending on the system, it may be nessesary to prompt the user for a
   keystroke, before terminating, because user wouldn't be able to read
   the outputs to the screen, when the window closes at termination.
   However, the '-n' option overrides this. */
int main (int argc, char **argv)
{
#ifdef __TOS__
  int ret;
  
  ret = go_at_it (argc, argv);
  if ((!nowait || noquery) && !system(NULLCP))
  {
    printf("\n\033p Hit any key \033q");
    getch();
  }
  return (ret);
#else
  return (go_at_it (argc, argv));
#endif
}

/* This is the real main() */
int go_at_it (int argc, char **argv)
{
  char *p, *q, *r, *s, *t;
  int  i, extract, join, part, cor;
  long blocksize;

  i = extract = join = part = cor = 0;
  p = q = r = s = t = endstr = NULLCP;


  /* Default blocksize (abt 10000 bytes) */
  blocksize = 138 * 62;

  printf (logon_ctrl, logon[0], logon[1]);

  while (++i<argc)
  {
    if (*argv[i] != '-')
    {
      if (!p)
      {
        p = argv[i];  /* Name of file to de/encode */
        continue;
      }
      if (!r)
      {
        r = argv[i];  /* Searchpath for non-coded file. Needed for */
        continue;     /* generating correction file */
      }
    }

    if (!stricmp (argv[i], "-S")) /* Split option */
    {
      i++;
      if (i == argc)
      {
        blocksize = 512 * 62;  /* No parameter, set max blocksize */
        i--;
      }
      else
        blocksize = atol (argv[i]) * 62; /* Set blocksize to parameter */
    }

    if (!stricmp (argv[i], "-SP")) /* Split in equal parts */
    {
      i++;
      if (i == argc)
      {
        blocksize = 0; /* No parameter, no user defined split */
        i--;
      }
      else
        blocksize = 50000L + atol (argv[i]); /* Number of parts to encode */
    }

    if (!stricmp (argv[i], "-SB")) /* Split in parts of n bytes */
    {
      i++;
      if (i == argc)
        i--;
      else
        blocksize = (atol (argv[i]) /71 -2) *62;
    }

    if (!stricmp (argv[i], "-R")) /* Only reencode part n */
    {
      i++;
      if (i == argc)
        i--;
      else
        part = atoi (argv[i]);
    }

    if (!stricmp (argv[i], "-TB")) /* File to get head and foot lines from */
    {
      i++;
      if (i == argc)
        i--;
      else
        t = argv[i];
    }

    if (!stricmp (argv[i], "-T")) /* Define BBSs termination string */
    {
      i++;
      if (i == argc)
        i--;
      else
      {
        endstr = malloc ((int) strlen (argv[i]) +1);
        strcpy (endstr, argv[i]);
      }
    }

    if (!stricmp (argv[i], "-#")) /* Create 7PLUS.FLS. Contents e.g.:     */
      fls = 1;                    /* 10 TEST */
                                  /* for TEST.EXE encoded into 10 parts   */

    if (!stricmp (argv[i], "-C")) /* Use 7PLUS-file as a correction file  */
      cor = 1;

    if (!stricmp (argv[i], "-K")) /* Kill obsolete files */
      autokill = 1;

    if (!stricmp (argv[i], "-F")) /* Force usage of correction file */
      force = 1;

    if (!stricmp (argv[i], "-J")) /* Join two error reports */
      join = 1;

    #ifdef __TOS__
    if (!stricmp (argv[i], "-N")) /* Don't wait for a key at termination  */
      nowait = 1;
    #endif

    if (!stricmp (argv[i], "-P")) /* Write encoded files in Packet format */
      sprintf (delimit, "\r");    /* for direct binary upload. */

    if (!stricmp (argv[i], "-X")) /* Extract 7plus-files from log-file    */
      extract = 1;

    if (!stricmp (argv[i], "-VMAJOR")) /* Return version number +100      */
      return (_7P_VMAJOR +100);

    if (!stricmp (argv[i], "-VMINOR")) /* Return subversion number + 100  */
      return (_7P_VMINOR+100);

    if (!stricmp (argv[i], "-Y")) /* Always assume YES on queries.*/
      noquery = 1;

  }
  if (!p ) /* No File specified, show help */
  {
    int n = 4;
    i = 0;
    while (help[i])
    {
      if (++n == 24 && !noquery)
      {
        printf ("Press any key to continue....\r");
        fflush (stdout);
        while (!getch ());
        fflush (stdin);
        n = 0;
        printf ("                             \r");
      }
      printf (help[i++]);
    }
    return (0);
  }

  if ((s = malloc (50000U)) == NULLCP)
  {
     printf ("\007Argh error: Not enough memory present! Can't continue.....\n");
     exit (12);
  }
  free (s);

  if ((index = (struct m_index *)malloc (sizeof (struct m_index))) == NULL)
  {
    printf ("\007Argh error: Not enough memory present! Can't continue.....\n");
    exit (12);
  }

  buflen = 16384;

  init_crctab (); /* Initialize table for CRC-calculation */
  init_decodetab (); /* decoding-table */
  init_codetab   (); /* encoding-table */

  if (extract)
    if (p)
      return (extract_files (p, r));
    else
    {
      printf ("\007File to extract from not specified. Break.\n");
      return (6);
    }
  if (join)
    return (join_control (p, r));

  /* Does the filename contain an extension? */
  if ((q = strrchr (p, '.')) != NULLCP)
  {
    if (cor)
      return (correct_meta (p, 0));

    if (!strnicmp (".cor", q, 4) ||
        (toupper(*(q+1)) == 'C' && isxdigit(*(q+2)) && isxdigit(*(q+3))))
      return (correct_meta (p, 1));

    /* Call decode_file() if ext ist 7PL, P01, else encode_file() */
    if (!strnicmp (".7pl", q, 4) || !strnicmp (".p01", q, 4))
      return (control_decode (p));

    #ifdef _CHSIZE_OK
     if (!strnicmp (".7mf", q, 4))
       return(make_new_err (p));
    #else
     if (!strnicmp (".7ix", q, 4))
       return(make_new_err (p));
    #endif

    if (!strnicmp (".x", q, 3))
      return (extract_files (p, r));

    return (encode_file (p, blocksize, r, part, t));
  }
  else
  {
    if (!test_exist (p)) /* no EXT, but file exists on disk, then encode */
      return (encode_file (p, blocksize, r, part, t));
    else
      return (control_decode (p));
  }
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
 *+ Possible return codes:                                                 +*
 *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*

  0 No errors detected.
  1 Write error.
  2 File not found.
  3 7PLUS header not found.
  4 File does not contain expected part.
  5 7PLUS header corrrupted.
  6 No filename for extracting defined.
  7 invalid error report / correction / index file.
  8 Max number of parts exceeded.
  9 Bit 8 stripped.
 10 User break in test_file();
 11 Error report generated.
 12 Only one or no error report to join
 13 Error report/cor-file does not relate to the same original file
 14 Couldn't write 7plus.fls
 15 Filesize of original file and the size reported in err/cor-file not equal
 16 Correction not successful.
 17 No CRC found in err/cor-file.
 18 Timestamp in metafile differs from that in the correction file.
 19 Metafile already exists.

 1XX If invoked with '-VMAJOR' option, 7PLUS returns version number.
     e.g.: 101  <--- v1.5
         : 108  <--- v8.8

     Invoked with '-VMINOR':
     e.g.: 150  <--- v1.5
         : 180  <--- v8.8

 *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
