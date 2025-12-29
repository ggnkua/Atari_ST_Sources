/*
*** FFR by DG1BBQ@DB0CL.DEU.EU
***
*** kill.c
***
 */

#include "ffr.h"


/*
*** Kill entries of a board from input file.
*** If board == "*" only get rid of the stuff between the entries.
*** Don't modify inputfile, if an alternative output file is specified
*** with the '-o'-option.
*** Just to be on the safe side, write all killed data into KILLFILE.
***
 */
void kill_entries (void)
{
  FILE *srcfp  = NULL;
  FILE *destfp = NULL;
  FILE *killfp = NULL;

  int  n         = 0;
  int  i         = 0;
  int  len       = 0;
  int  stat      = 0;
  int  skip      = 0;
  int  lfd_nr    = 0;
  int  flag      = 0;
  int  kflag     = 0;
  long killcount = 0;
  long srccount  = 0;
  long destcount = 0;

  if ((killfp = fopen (KILLFILE, OPEN_APPEND_BINARY)) == NULL)
  {
    printf ("\007Can't open killfile '"KILLFILE"'.\n");
    exit (0);
  }
  /* clear extract, if a numerical range has been specified */
  if (numbers[0] != 1000)
  {
    printf ("Deleting entries in specified area from %s.\n", srcfile);
    kflag = TRUE;
    *extract = EOS;
  }

  if (*extract)
  {
    if (*extract != '*')
    {
      /* kill entries of a board */
      kflag = TRUE;
      printf ("Deleting board '%s' from  %s.\n", extract, srcfile);
      suchbegriffe ();
    }
    else
    {
      /* kill stuff inbetween */
      printf ("Deleting excess data between entries from %s.\n", srcfile);
      printf ("This may take a while. Please wait...\n");
      flag = TRUE;
    }
  }

  if ((srcfp = fopen (srcfile, OPEN_READ_BINARY)) == NULL)
  {
    perror ("\007FFR: Can't open input file.\n");
    return;
  }

  if (*destfile)
  {
    printf ("Writing rest into %s.\n", destfile);
    destfp = fopen (destfile, OPEN_WRITE_BINARY);
  }
  else
    destfp = fopen (OUTFILE, OPEN_WRITE_BINARY);

  printf ("\n");

  if (destfp == NULL)
  {
    perror ("\007FFR: Can't open output file.\n");
    return;
  }
  setvbuf (killfp, NULL, _IOFBF, buflen); /* buffering speeds up */
  setvbuf (srcfp , NULL, _IOFBF, buflen);
  setvbuf (destfp, NULL, _IOFBF, buflen);

  while (read_wline (srcfp) != NULL)
  {
    len = (int) strlen(win[0]);
    srccount += len;

    stat = 0;
    if (!skip)
      stat = check_line (flag ^ !kflag, 0);    /* check for headers/prompts */
    else
      skip--;

    if (stat < 0)                           /* reposition file read pointer */
    {
      strcpy (dum[0], win[0]+ len + stat);
      if (dum[0][0] != '\r' && dum[0][0] != '\n')
      {
        len += stat;
        win[0][len] = EOS;
        srccount += stat;
        stat = PROMPT;
        read_wline (NULL);
        fseek ( srcfp, srccount, SEEK_SET);
      }
      else
        stat = 0;
    }
    if (stat)                                            /* anything found? */
    {
      if (kflag)            /* TRUE?, kill entry, else only stuff inbetween */
      {
        if (stat == PROMPT)                   /* prompt, switch off writing */
          flag = FALSE;
        if (stat == INFO)                                    /* info header */
        {
          lfd_nr++;
          flag = FALSE;                               /* switch off writing */
          get_bsd (dum[0], "xxxxxx", mbhead[boxtype].board, 8);
          if ((search_strings (mbhead[boxtype].length) && numbers[0] == 1000 &&
               !stricmp (dum[0], extract)) || numbers[n] == lfd_nr)
          {
            /* board is correct, all searchstrings are present, switch on
               writing */
            flag = TRUE;
            n++;

            printf ("Deleting:\n#%d", lfd_nr);
            for (i=0; i<mbhead[boxtype].length;i++)
#ifdef _TWOCHARSEP
            strip_cr (win[i]);
            printf ("\t%s", dum[0]);
#else
            printf ("\t%s", win[i]);
#endif
            printf ("\n");
            skip = mbhead[boxtype].length -1;
          }
          else
          {
            flag = FALSE;
            printf ("#%d  \r", lfd_nr);
            fflush (stdout);
          }
        }
      }
      else                                  /* only delete stuff inbetween. */
      {
        if (stat == PROMPT)
          flag = TRUE;

        if (stat == INFO)
        {
          printf ("#%d  \r", ++lfd_nr);
          fflush (stdout);
          flag = FALSE;
        }
      }
    }
    if (flag)
      count_n_write (&killcount, win[0], killfp);
    else
      count_n_write (&destcount, win[0], destfp);
  }
  fclose (srcfp);
  fclose (destfp);
  fclose (killfp);

  printf ("\nFFR-Statistics:\n");
  printf ("%7ld\tbytes read from '%s'.\n", srccount, srcfile);
  printf ("%7ld\tbytes deleted.\n", killcount);
  printf ("%7ld\tbytes ", destcount);

  if (*destfile)
    printf ("written into '%s'.\n\n", destfile);
  else
  {
    printf ("written back.\n\n");
    if (!unlink (srcfile))
      rename (OUTFILE, srcfile);
  }

  /*if (!killcount) */           /* delete KILLFILE, if nothing was deleted */
  /*  unlink (KILLFILE);*/
}
