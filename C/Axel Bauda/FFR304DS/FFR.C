#define VERSION  "3.04"
#define _VERSION "304"
#define DATE     "911216"
/*
***
*** FFR (Mailbox File Fractionizer) for capture files of any BBS
***              -    --
*** FFR is HAMWARE. No commercial use. Pass on only in it's entirety!
*** There is no warranty for the proper functioning. Use at own risk.
***
*** Compile:
*** -------------------------------------------------------------------------
*** -------
*** | IBM |  : SMALL memory model
*** -------
***            Turbo C++ and Turbo C 2.0:
***            MAKE -FTC_MAKE
***
***      also: Turbo C++:
***            Compile in IDE using FFR.PRJ
***
***      or  : Turbo C 2.0:
***            Rename TC2.PRJ to FFR.PRJ and compile in IDE
***
*** ---------
*** | ATARI |  Turbo C 2.0 : Use FFRST.PRJ
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
*** -------------------------------------------------------------------------
***
*** Indent: 2  Don't use TAB-chars.
***
*** 73s, Axel DG1BBQ (@DB0CL.DEU.EU)
***
*** Axel Bauda, Potsdamer Str.43, D-w2850 Bremerhaven 21, Germany
***
 */

#include "ffr.h"
#include "globals.h"

static char *logon[] = { "        BBS File Fractionizer (FFR)         ",
                         " Version "VERSION" ("DATE"), DG1BBQ@DB0CL.DEU.EU " };
static char *help[] = {
  "Command line:\n",
  "=============\n",
  "ffr <inputfile> [{command} <board|range> [options] [<searchstring1-5>]]\n",
  "\n",
  "<inputfile>        File to read from.\n",
  "<board>            Name of BBS-board (IBM, ALL...). '*' == any board\n",
  "<range>            Numerical range. Multiple ranges must be seperated by a\n",
  "                   comma: '1,5-7,20-'. No spaces allowed in a numerical range!\n",
  "<searchstring1-5>  Up to 5 strings that must be present in an entry's header\n",
  "                   before FFR will take notice of it (optional).\n",
  "Commands:\n",
  "=========\n",
  "-l List    | <-- Commands must be followed by a range, board name or an\n",
  "-k Kill    |     asterisk '*' to select all entries. Note: '-k *' will\n",
  "-x eXtract |     not kill all entries, but only the stuff inbetween!\n",
  "\n",
  "Options:\n",
  "========\n"
  "-debug      Activate outputs for debugging "CONFIGFILE".\n",
  "-gi <file>  Specify file to get list/kill/extract index from.\n",
  "-ic         Ignore code files. Handle them as ordinary info.\n",
  "-ih         Ignore headers. Only look for code files.\n"
  "-h          Show this help info.\n",
  "-m <call>   Tell your callsign to FFR if it's not set in "CONFIGFILE".\n",
  "-o <file>   Specify file FFR will write to instead of modifying <inputfile>.\n",
  "-cp <path>  Write code files to <path>.\n",
  "-gp <path>  Write general mail to <path>.\n",
  "-pp <path>  Write personal mail to <path>.\n",
  "-icp        Ignore path defined in "CONFIGFILE" for code files.\n",
  "-igp        Dito for general mail.\n",
  "-ipp        Dito for personal mail.\n",
  "-iap        Ignore all paths defined in "CONFIGFILE".\n",
  "\n",
  "Additional info: see FFR"_VERSION".DOC. 73s, Axel. :-)\n",
  NULL };

static char no_opt[] =
  "FFR: No argument for %s '%s' specified. Ignored.\n\n";

int main (int argc, char **argv)
{

  int action, helpflag, gi_flag, i, n;
  char *s;

  ignore = action = helpflag = gi_flag = debug = i = n = 0;
  *srcfile = *destfile = *extract = *codepath = *perspath = *genpath = EOS;
  *mycall  = *search   = s = NULL;
  numbers[0] = 1000;

#ifdef __MSDOS__
  printf ("\nษออออออออออออออออออออออออออออออออออออออออออออป\n");
  printf   ("บ%sบ\nบ%sบ\n", logon[0], logon[1]);
  printf   ("ศออออออออออออออออออออออออออออออออออออออออออออผ\n\n");
#else
  printf ("\n[]------------------------------------------[]\n");
  printf   ("|%s|\n|%s|\n", logon[0], logon[1]);
  printf   ("[]------------------------------------------[]\n\n");
#endif


  while (++i<argc)
  {

    /* input file and searchstrings */
    if ((*argv[i] != '-'))
      if (*srcfile)                              /* input file already set? */
      {                                                              /* yes */
        if (n<MAXSEARCH)                        /* get searchstrings. max 5 */
        {                                       /* allocate mem dynamically */
          search[n] = (char*) my_malloc ((int) strlen(argv[i])+1);
          strcpy (search[n], argv[i]);
          strupr (search[n++]);
          search[n] = NULL;                             /* mark end of list */
        }
      }
      else
        strcpy (srcfile, argv[i]);               /* get name of source file */

    /* commands */
    if (strstr (" -l -k -x ", argv[i]) || strstr (" -L -K -X ", argv[i]))
    {
      i++;
      /* is there an argument to this command? */
      if (i == argc || *argv[i] == '-' && *(argv[i]+1) > 64)
      {
        i--;
        printf (no_opt, "command", argv[i]);
        continue;
      }
      if (action)
      {
        printf ("FFR: Only one command allowed. '%s' ignored.\n", argv[i-1]);
        continue;
      }
      strcpy (extract, argv[i]); /* yes */

      if (!strnicmp(argv[i-1], "-l", 2))                    /* list entries */
        action = LIST;
      if (!strnicmp(argv[i-1], "-k", 2))                    /* kill entries */
        action = KILL;
      if (!strnicmp(argv[i-1], "-x", 2))                 /* extract entries */
        action = EXTRACT;
      continue;
    }

    /* options with parms */
    if (!strnicmp(argv[i], "-m", 2) && !mycall[0])                /* mycall */
    {
      i++;
      if (i == argc || *argv[i] == '-')
      {
        i--;
        printf (no_opt, "option", argv[i]);
        continue;
      }
      mycall[0] = my_malloc (7);
      strncpy(mycall[0], argv[i], 6);
      mycall[0][6] = EOS;
      mycall[1] = NULL;
      continue;
    }

    if (!strnicmp(argv[i], "-gi", 3) && !s)          /* get index from file */
    {
      i++;
      if (i == argc || *argv[i] == '-')
      {
        i--;
        printf (no_opt, "option", argv[i]);
        continue;
      }
      s = argv[i];
      gi_flag = 1;
      continue;
    }


    if (strstr (" -o -cp -pp -gp ", argv[i]) ||
        strstr (" -O -CP -PP -GP", argv[i]))
    {

      i++;
      if (i == argc || *argv[i] == '-')
      {
        i--;
        printf (no_opt, "option", argv[i]);
        continue;
      }
      if (!strnicmp(argv[i-1], "-o", 2))           /* output file, optional */
        strcpy (destfile, argv[i]);
      if (!strnicmp(argv[i-1], "-cp", 3))     /* output path for code-files */
        strcpy (codepath, argv[i]);
      if (!strnicmp(argv[i-1], "-pp", 3))  /* output path for personal mail */
        strcpy (perspath, argv[i]);
      if (!strnicmp(argv[i-1], "-gp", 3))   /* output path for general mail */
        strcpy (genpath, argv[i]);
      continue;
    }

    /* options without parms /*
    if (!strnicmp(argv[i], "-h", 2))                           /* help info */
      helpflag = 1;

    if (!strnicmp(argv[i], "-debug", 6))               /* output debug info */
      debug = 1;

    if (!strnicmp(argv[i], "-ih", 3))                     /* ignore headers */
      ignore |= 1;

    if (!strnicmp(argv[i], "-ic", 3))                  /* ignore code files */
      ignore |= 2;

    if (!strnicmp(argv[i], "-icp", 4))                  /* ignore code path */
      ignore |= 4;

    if (!strnicmp(argv[i], "-ipp", 4))              /* ignore personal path */
      ignore |= 8;

    if (!strnicmp(argv[i], "-igp", 4))               /* ignore general path */
      ignore |= 16;

    if (!strnicmp(argv[i], "-iap", 4))                  /* ignore all paths */
      ignore |= (4+8+16);


  } /* while */

#if (__MSDOS__) || (__TOS__)
  strlwr (srcfile);
  strlwr (destfile);
#endif
  strupr (extract);
  if (*mycall)
    strupr (*mycall);

  if (!*srcfile)
  {
    if (helpflag || argc == 1)
    {
      i = 0;
      n = 6;
      while (help[i])
      {
        if (++n == 24)
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
    }
    else
    {
      printf ("\007FFR: File to read from not specified!\n");
      return (1);
    }
  }
  else
  {
    if (gi_flag)
      get_index (s);
    else
      if (*extract && (*extract > '0' && *extract <= '9' || *extract == '-'))
      {
        /* a numerical range was specified. process it */
        get_range ();
      }

    if (numbers[0] != 1000)
      search[0] = NULL;

    set_win ();                                    /* init file read window */
    get_parms (*argv);       /* get BBS definitions from configfile FFR.CFG */

    /* Check, if there's enough mem */
    if ((s = malloc (32768U)) == NULL)
    {
       printf ("\007Argh error: Not enough memory present!"
               " Can't continue.....\n");
       exit (12);
    }
    free (s);

    buflen = 32767;
#ifdef __MSDOS__
    buflen /= 3;              /* there's not that much room in SMALL model. */
#endif

    /* This is for UNIX. '.' may be used instead of '*' to select all. */
    if (!strcmp (extract, "."))
      strcpy (extract, "*");

    if (action == FALSE)                /* set LIST, if no action specified */
    {
      action = EXTRACT;
      strcpy (extract, "*");
    }

    if (action == KILL)
      kill_entries ();
    else
      fraction (action);
  }
  return (0);
}
