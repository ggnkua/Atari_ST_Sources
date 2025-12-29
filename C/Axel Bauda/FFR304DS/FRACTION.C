/*
*** FFR by DG1BBQ@DB0CL.DEU.EU
***
*** fraction.c
***
 */

#include "ffr.h"


/*
*** control extraction of info-, user-entries and encoded files.
***
 */
void fraction (int action)
{
  FILE *srcfp  = NULL;
  FILE *destfp = NULL;
  FILE *codefp = NULL;

  int  n         = 0;
  int  i         = 0;
  int  lflag     = 0;
  int  wflag     = 0;
  int  codeflag  = 0;
  int  stat      = 0;
  int  skip      = 0;
  int  lfd_nr    = 0;
  long srccount  = 0;
  long destcount = 0;
  long codecount = 0;

  char board [9];

  if (!strcmp (extract, "*"))
    *extract = EOS;

  /* tell user, what is being done... */
  if (ignore & 1)
    printf ("Extracting code files ");
  else
  {
    if (action == LIST)
      printf ("List ");
    else
      printf ("Extract ");


    if (numbers[0] != 1000)
    {
      *extract = EOS;
      if (numbers[0] != 1000)
        printf ("entries in specified area ");
    }
    else
      if (*extract)
        printf ("board %s ", extract);
  }
  printf ("from %s.\n\n", srcfile);

  suchbegriffe ();

  if ((srcfp = fopen (srcfile, OPEN_READ_BINARY)) == NULL)
  {
    perror ("\007FFR: Can't open input file\n");
    return;
  }
  setvbuf (srcfp, NULL, _IOFBF, buflen);

  while (read_wline (srcfp) != NULL)
  {
    srccount += strlen (win[0]);

    if (!skip)
      stat = check_line (wflag, codeflag); /* anything found? */
    else
    {
      stat = 0;
      skip--;
    }
    if (stat < 0) /* exemption, see check_line() */
    {
      strcpy (dum[0], win[0]+ (strlen(win[0])+stat));
      if (dum[0][0] != '\r' && dum[0][0] != '\n')
      {
        srccount += stat;
        stat = PROMPT;
        read_wline (NULL);
        fseek ( srcfp, srccount, SEEK_SET);
      }
      else
        stat = 0;
    }
    if (stat)
    {
      if (stat == INFO || stat == PROMPT)
      {
        codeflag = 0;
        codefp = my_fclose (codefp);
      }
      /* begin of an entry found */
      if (stat == INFO)
      {
        if (n && numbers[n] == 1000)
          break;
        wflag = FALSE;

        /* if a file is already open, close it, because a new entry is
           starting. */
        destfp = my_fclose (destfp);

        lfd_nr++;
        if (search_strings (mbhead[boxtype].length) &&
                             (numbers[n] == lfd_nr || numbers[0] == 1000))
        {
          n++;
          if (action == LIST)
          {
            get_bsd (board, "xxxxxx", mbhead[boxtype].board, 8);
            if (!*extract || !stricmp (board, extract))
              lflag = TRUE;
          }
          else
          {
            if ((destfp = make_file (0, codeflag)) != NULL)
            {
              setvbuf (destfp, NULL, _IOFBF, buflen);
              printf ("%s", text);
              wflag = lflag = TRUE;
            }
          }
        }

        if (lflag)
        {
          lflag = FALSE;
          printf ("#%d", lfd_nr);
          for (i=0; i<mbhead[boxtype].length; i++)
          {
#ifdef _TWOCHARSEP
            strip_cr (win[i]);
            printf ("\t%s", dum[0]);
#else
            printf ("\t%s", win[i]);
#endif
          }
          printf ("\n");
        }
        else
        {
          printf ("#%d  \r", lfd_nr);
          fflush (stdout);
        }
        skip = mbhead[boxtype].length -1;
      }
      /* close file, when end of entry found */
      if (stat == PROMPT && wflag)
      {
        wflag = FALSE;
        destfp = my_fclose (destfp);
      }
      /* only open a code file, if currently writing a BBS-entry and
         no codefile is open */
      if ((stat == CODESTART || stat == TEXTSTART) &&
                                           !codeflag && (wflag || ignore & 1))
      {
        if ((search_strings (code[codetype].length) && ignore & 1) ||
                                                              !(ignore & 1))
        {
          codeflag = 1;
          if ((codefp = make_file (destfp != NULL, codeflag)) != NULL)
          {
            setvbuf (codefp, NULL, _IOFBF, buflen);
            if (!(ignore & 1))
              destcount += fprintf (destfp,
                     LINESEP"*** Contents: see file '%s'***"LINESEP, destnam);
          }
          else
            codeflag = 0;
        }
        else
        {
          for (i=0; i<code[codetype].length; i++)
          {
#ifdef _TWOCHARSEP
            strip_cr (win[i]);
            printf ("\t%s", dum[0]);
#else
            printf ("\t%s", win[i]);
#endif
          }
          skip = code[codetype].length -1;
        }
      }
      if ((stat == CODEEND || stat == TEXTEND) && codeflag)
        codeflag = 3; /* close code file after having written last line */
    }
    if (!(stat & TEXTSTART))
    {
      if (codeflag)
      {
        if (codefp)
          count_n_write (&codecount, win[0], codefp);
      }
      else
        if (destfp)
          count_n_write (&destcount, win[0], destfp);
    }
    if (codeflag == 3)
    {
      codefp = my_fclose (codefp);
      codeflag = 0;
    }
  } /* while */

  fclose (srcfp);
  my_fclose (destfp);
  my_fclose (codefp);

  printf ("\nStatistics:\n");
  printf ("%7ld\tbytes read from '%s'.\n", srccount, srcfile);
  printf ("%7ld\tbytes extracted.\n", destcount);
  printf ("%7ld\tbytes of code extracted.\n\n", codecount);
}

#ifdef _TWOCHARSEP
/*
*** get rid of excess CR for screen output
*** (only on systems with CR/LF as line delimitor).
 */
void strip_cr (char *string)
{
  register int len;


  strcpy (dum[0], string);

  len = (int) strlen (dum[0]) -2;

  if (len >= 0 && dum[0][len] == '\r')
  {
    dum[0][len] = '\n';
    dum[0][++len] = '\0';
  }
}
#endif