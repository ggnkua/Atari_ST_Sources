/*
*** FFR by DG1BBQ@DB0CL.DEU.EU
***
*** identify.c
***
 */

#include "ffr.h"


/*
*** Identify BBS-headers 'n' prompts as well as encoded files.
***
 */
int check_line (int flag, int codeflag)
{
  static int type = -1;
  int  dum_int;
  int  parms = 0;
  int  elms;
  int  mbnum;
  char form[MAXGET+1];
  char *p;
  struct head *current;
  struct prompt *curprmt;


  /* don't do anything, if line is empty */
  if (win[0][0] ==  '\n' || win[0][0] == '\r')
    return (FALSE);


  if (debug)
  {
    printf ("\n=========================================================\n");
    printf ("'%s'\n", win[0]);
  }

  /* If flag == FALSE, only check headers and prompts that reposition the
     file read pointer. */

  if (!(ignore & 1))     /* bit 0 set, then don't check headers and prompts */
  {
    /* Identify header */
    mbnum = 0;
    while (mbhead[mbnum].type)            /* loop through defined BBS-types */
    {
      /* do quick test.. saves a bit of time. */
      if (qtest (mbhead[mbnum].qtest, mbhead[mbnum].qtline))
      {
        if (debug)
          printf ("######## Quick test for %s-header failed\n", mbhead[mbnum].type);
        mbnum++;
        continue;
      }

      if (debug)
        debug = 1;

      dum_int = 1;
      current = mbhead[mbnum].first; /* set pointer to first member of list */
      do
      {
        if (debug == 1)
        {
          debug++;
          printf ("\n######## Checking for %s header:\n",
                                                         mbhead[mbnum].type);
        }

        strcpy (form, current->format);
        p = strtok (form, "||");

        do
        {
          /* if format == "~", we want to check for an empty line */
          if (!strcmp (p, "~"))
          {
            /* check for CR and LF, because FFR may run on different systems  */
            if (win[current->y][0] != '\r' && win[current->y][0] != '\n')
            {
              dum_int = 0;
              parms = -1;
            }

            if (debug)
              printf ("Check for empty line at offset %d: %sOK\n",
                                                 current->y, parms?"not ":"");
          }
          else
          {
            /* check if line matches format */
            elms = elements (p);

            parms = sscanf (win[current->y], p,
                            dum[0], dum[1], dum[2], dum[3], dum[4],
                            dum[5], dum[6], dum[7], dum[8], dum[9]);
            if (parms != elms)
              dum_int = 0;

            if (debug) /* it's real difficult to find bugs in the definitions */
            {          /* without seeing what happens.. */
              int y;

              if (current->y)
                printf ("\nLine:\n'%s'\n", win[current->y]);
              printf ("Format: '%s'\n", p);
              printf ("Offset: %d line(s)\nParms_OK: %d, required: %d\n",
                                            current->y, parms, elms);
              for(y=0;y<parms;y++)
                printf ("%02d: '%s'\n", y+1, dum[y]);
            }
          }

          if (dum_int)
            break;
          dum_int = 1;

          p = strtok (NULL, "||");

          if (!p)
            dum_int = 0;
        }
        while (p);

        current = current->next;
      }
      while (current && dum_int);

      if (dum_int)
      {
        if (type != mbnum)
          boxtype = type = mbnum;

        if (debug)
          printf ("\n\007[INFO-header recognized] ######################\n");
        return (INFO);
      }
      mbnum++;
    }

    /* check global prompts in first round and prompts for current BBS
       in the second. */
    mbnum = dum_int = 0; /* use mbnum as a flag for the rounds */
    while (1 == 1)
    {
      if (mbnum == 0)
      {
        curprmt = prompt; /* set pointer to global prompts for first round */
        mbnum = 2;
      }
      else
      {
        curprmt = mbhead[boxtype].begin; /* second round */
        mbnum = 3;
      }

      if (debug)
        debug = 1;

      while (curprmt)
      {
        /* only check repositioning prompts, if !flag */
        if (!curprmt->repos && !flag)
        {
          curprmt = curprmt->next;
          continue;
        }
        if (debug == 1)
        {
          debug++;
          printf ("\n+++++++ Checking for ");
          if (mbnum == 2)
            printf ("global prompt:\n");
          else
            printf ("%s prompt:\n", mbhead[boxtype].type);
        }

        dum[curprmt->elements-1][0] = EOS;

        parms = 999;
        if (curprmt->elements)
        {
          parms = sscanf (win[0], curprmt->format,
                                   dum[0], dum[1], dum[2], dum[3], dum[4],
                                   dum[5], dum[6], dum[7], dum[8], dum[9]);
          if (parms == curprmt->elements)
          {
            mbnum = 1;
            if (curprmt->repos)
              dum_int = (int) strlen (dum[curprmt->elements-1]) *-1;
          }
        }
        else
        {
          /* no sscanf-elements, check with qtest(). */
          if (!qtest (curprmt->format, 0))
          {
            mbnum = 1;
            parms = 998;
            if (curprmt->repos)
              dum_int = ((int) strlen (win[0]) - curprmt->len) *-1;
          }
        }

        debug_out (curprmt->format, parms, curprmt->elements, -1);

        if (mbnum == 1)
        {
          if (dum_int)
          {
            if (strcmp (dum[curprmt->elements-1], LINESEP))
            {
              if (debug)
                printf ("\n\007[repositioning PROMPT recognized] ######\n");
              return (dum_int);
            }
          }
          if (debug)
            printf ("\n\007[PROMPT recognized] ######################\n");

          return (PROMPT);
        }
        curprmt = curprmt->next;
      }
      if (mbnum == 3)
        break;
    }
    if (!flag)
      return (FALSE);
  }

  if (!(ignore & 2))           /* bit 1 set, don't check for encoded files. */
  {
    if (debug)
      printf ("\n");

    /* the following tests only concern encoded files */

    mbnum = 0;

    while (code[mbnum].type && !codeflag)
    {
      /* check for start */
      elms = qtest (code[mbnum].qtest->format, code[mbnum].qtest->y);
      if (!elms)
      {
        if (debug)
          printf ("******** Checking for %s file\n", code[mbnum].type);

        parms = 999;
        current = code[mbnum].full;

        do
        {
          elms = elements (current->format);

          if (elms)
          {
            parms = sscanf (win[current->y], current->format,
                                       dum[0], dum[1], dum[2], dum[3], dum[4],
                                       dum[5], dum[6], dum[7], dum[8], dum[9]);
          }
          else
            if (!qtest (current->format, current->y))
              parms = 998;

          if (current->y && debug)
            printf ("Line:\n'%s'\n", win[current->y]);

          debug_out (current->format, parms, elms, current->y);

          if (parms != elms && parms != 998)
            parms = 999;

          current = current->next;
        }
        while (current && parms != 999);

        if (parms != 999)
        {
          if (debug)
            printf ("\n\007[Start of code] ##########################\n");
          codetype = mbnum;
          return (2 << code[mbnum].codetype);
        }
      }
      else
        if (debug)
          printf ("******** Quick test for %s failed.\n", code[mbnum].type);

      mbnum++;
    }

    /* check for end */
    if (codeflag) /* do check only if inside a file */
    {
      if (debug)
        printf ("******** Checking for end of %s file\n", code[codetype].type);

      elms = elements (code[codetype].end);

      parms = 999;
      if (elms)
      {
        parms = sscanf (win[0], code[codetype].end,
                                   dum[0], dum[1], dum[2], dum[3], dum[4],
                                   dum[5], dum[6], dum[7], dum[8], dum[9]);
      }
      else
        if (!qtest (code[codetype].end, 0))
          parms = 998;

      debug_out (code[codetype].end, parms, elms, -1);

      if (parms == 998 || parms == elms)
      {
        if (debug)
          printf ("\n\007[End of code] ############################\n");
        return ((2 << code[codetype].codetype) + 256);
      }
    }
  }
  return (FALSE); /* nothing found */
}

/*
*** Show debug info for check_line()
***
 */
void debug_out (char *format, int parms, int required, int offset)
{
  register y;

  if (debug)
  {
    printf ("Format: '%s'\n", format);
    if (offset > -1)
      printf ("Offset: %d, ", offset);
    if (parms < 998)
    {
      printf ("Parms_OK: %d, required: %d\n", parms, required);
      for(y=0;y<parms;y++)
        printf ("%02d: '%s'\n", y+1, dum[y]);
    }
    else
      if (parms == 998)
        printf ("Lines Match.\n");
      else
        printf ("No Match.\n");
    printf ("\n");
  }
}

/*
*** Check what kind of file we need to create: BBS-entry, personal Mail,
*** encoded file.
***
*** If identified, open an output file with according name.
***
 */

FILE *make_file (int flag, int codeflag)
{
  FILE *fp;
  static int tmpnr = 0;
  static char boardnam [9] = "NONAME  ";
  int  dum_int;
  int  dum_int2;
  int  p_mail;
  int  n, of_n;
  int  *y;
  char codename[MAXPATH];
  char typ  [21];
  char board [9];
  char sender[9];
  char date_ext[4];
  char date[21];
  char **m, *x;

  *destnam = *typ = *text = *date_ext = EOS;
  m = mycall;
  dum_int = dum_int2 = p_mail = n = of_n = 0;

  if (codeflag)
  {
    sscanf (win[code[codetype].name->y], code[codetype].name->format,
                                   dum[0], dum[1], dum[2], dum[3], dum[4],
                                   dum[5], dum[6], dum[7], dum[8], dum[9]);
    strcpy (codename, dum[elements (code[codetype].name->format) -1]);

    if (*code[codetype].part->format)
    {
      sscanf (win[code[codetype].part->y], code[codetype].part->format,
                                   dum[0], dum[1], dum[2], dum[3], dum[4],
                                   dum[5], dum[6], dum[7], dum[8], dum[9]);
      y = (int *) dum[elements (code[codetype].part->format) -1];
      n = *y;
    }

    if (*code[codetype].of_parts->format)
    {
      sscanf (win[code[codetype].of_parts->y], code[codetype].of_parts->format,
                                   dum[0], dum[1], dum[2], dum[3], dum[4],
                                   dum[5], dum[6], dum[7], dum[8], dum[9]);
      y = (int *) dum[elements (code[codetype].of_parts->format) -1];
      of_n = *y;
    }

    if (debug)
      printf ("Name: '%s', Part: %d of %d\n", codename, n, of_n);

    if (!n && !of_n || n == 1 && of_n == 1)
      x = code[codetype].pform_1;
    else
      x = code[codetype].pform_2;

    sprintf (dum[0], x, codename, n);

    /* get rid of paths that may be in the encoded file's name */
    if (strrchr(dum[0], PATHCHAR))
    strcpy (dum[0], strrchr(dum[0], PATHCHAR)+1);

    sprintf (destnam, "%s%s", codepath, dum[0]);
    sprintf (typ, "%s-", code[codetype].type);


    if (code[codetype].increment)
    {
      of_n = 0;
      while ((fp = fopen (destnam, OPEN_READ_BINARY)) != NULL)
      {
        fclose (fp);

        sprintf (dum[0], code[codetype].pform_2, codename, ++of_n);
        sprintf (destnam, "%s%s", codepath, dum[0]);

        if (of_n == 256)
        {
          printf ("\007FFR: error while creating filename!\n");
          printf ("     Too many entries for '");
          printf (x, codename, n);
          printf ("'\n");
          break;
        }
      }
    }
  }


  /* if a filename has been generated, check if file already exists */
  if (*destnam)
  {
    char tmp[MAXPATH];

    strlwr (destnam);
    strcpy (tmp, destnam);
    while ((fp = fopen (destnam, OPEN_READ_BINARY)) != NULL)
    {
      fclose (fp);
      printf ("\007\n%sfile '%s' already exists.\nOverwrite? [y/n] ",
                                                               typ, destnam);
      do
      {
        dum_int = getch ();
        if (dum_int == 'n' || dum_int == 'N')
        {
          fflush (stdin);
          printf ("n\n\nPlease enter new name (max 12 chars): ");
          fscanf (stdin, "%12[a-zA-Z0-9._-]", destnam);
          fflush (stdin);
          strlwr (destnam);
          if (!strlen (destnam))
          {
            printf ("OK, '%s' not extracted\n\n", tmp);
            fclose (fp);
            return (NULL);
          }
          dum_int = 0xff;
        }
      }
      while (dum_int != 'y' && dum_int != 'Y' && dum_int != 0xff);
      if (dum_int != 0xff)
        printf ("y\n");
      printf ("\n");
      if (dum_int != 0xff)
        break;
    }
  }
  else            /* nothing found yet. then it must be a BBS-entry */
  {
    /* get relevant data from BBS header */
    get_bsd (board, "xxxxxx", mbhead[boxtype].board, 6);
    get_bsd (sender, "noname", mbhead[boxtype].sender, 6);
    get_bsd (date, "0", mbhead[boxtype].date, 20);

    if (debug)
      printf ("\nBoard: '%s', sender: '%s', date: '%s'\n\n",
                                                        board, sender, date);
    strcat (sender, "_");
    if (strlen (sender) < 7)
      strcat (sender, "_");
     
    dum_int = 1;
    while (dum_int && *m)
      dum_int = stricmp (board, *m++);

    if (!dum_int)     /* if board name == mycall, create special nameformat */
    {
      p_mail = TRUE;
      x = sender;
    }
    else
      x = board;

    strlwr (x);

    /* reset tmpnr, if x is different than at previous call */
    if (stricmp (x, boardnam))
    {
      strcpy (boardnam, x);
      tmpnr = 0;
    }

    switch (mbhead[boxtype].dtype)
    {
      /* build extension representing date. format: '.MDD'
         DD = day (decimal), M = month (hex) */

      case 0: /* Type of date: DD?MM */
        if (!strcmp (date, "0"))
          strcpy (date, "01.01");
        sscanf (date, "%d%[^0-9]%d", &dum_int, dum[0], &dum_int2);
        sprintf (date_ext, "%1x%02d", dum_int2, dum_int);
        break;

      case 1: /* <D|DD>?<Month> */
        if (!strcmp (date, "0"))
          strcpy (date, "01 Jan");
        sscanf (date, "%d%[^a-zA-Z]%3s", &dum_int, dum[0], dum[0]);
        sprintf (date_ext, "0%02d", dum_int);
        date_ext[0] = get_month (dum[0]);
        break;

      case 2: /* MM?DD */
        if (!strcmp (date, "0"))
          strcpy (date, "01/01");
        sscanf (date, "%d%[^0-9]%d", &dum_int, dum[0], &dum_int2);
        sprintf (date_ext, "%1x%02d", dum_int, dum_int2);
        break;

      case 3: /* YYMMDD */
        if (!strcmp (date, "0"))
          strcpy (date, "010101");
        strncpy (dum[0], date+4, 2);
        dum[0][2] = EOS;
        sscanf (date+2, "%2d", &dum_int);
        sprintf (date_ext, "%1x%s", dum_int, dum[0]);
        break;
    }

    /* test, if current name already exists, else count index up, until
       a valid name is found */
    if ((tmpnr < 255 && !p_mail) || (tmpnr < 26 && p_mail))
    {
      fp = NULL;
      do
      {
        if (fp)
          fclose (fp);

        /* put sender's callsign/board and date together. */
        if (p_mail)
        {
          sprintf (dum[0], "%s%c.%s", boardnam, ++tmpnr +96, date_ext);
          sprintf (destnam, "%s%s", perspath, dum[0]);
        }
        else
        {
          sprintf (dum[0], "%s%02x.%s", boardnam, ++tmpnr, date_ext);
          sprintf (destnam, "%s%s", genpath, dum[0]);
        }
        if ((tmpnr > 255 && !p_mail) || (tmpnr > 26 && p_mail))
        {
          printf ("\007FFR: error while creating filename!\n");
          printf ("     Too many entries in '%s'\n", boardnam);
          break;
        }
        fp = fopen (destnam, OPEN_READ_BINARY);
      }
      while (fp);
    }
  }
  errno = 0;
  /* wrong board? flag set? don't open a file! */
  if ( *extract && !(!stricmp (board, extract) || flag))
    return (NULL);

  sprintf (text, "%s%sxtracting: %s\n%s",
                         typ, *typ?"e":"E", destnam, *typ?"\n":"");

  /* if typ set, then a code file was found. tell about it */
  if (*typ)
    printf ("%s", text);

  strlwr (destnam);
  /* open file and return filepointer */
  if ((tmpnr < 256 && !p_mail) || (tmpnr < 27 && p_mail) || *typ)
  {
    fp = fopen (destnam, OPEN_WRITE_BINARY);
    if (errno && !fp)
    {
      if (errno == 2)
        printf ("\007FFR: %d:Directory '%s' does not exist.\n",
                                           errno, (p_mail)?perspath:codepath);
      else
        printf ("\007FFR: %d:%s\n", errno, sys_errlist[errno]);
      printf ("     Can't create '%s'.\n\n", destnam);
      errno = 0;
    }
    else
      return (fp);
  }
  return (NULL);
}

/*
*** get either the board, sender or date from BBS-header.
***
 */
void get_bsd (char *bsd, char *deflt, struct head *head, int len)
{
  int elms = elements (head->format);

  if (sscanf (win[head->y], head->format, dum[0],dum[1],dum[2],dum[3],dum[4],
                                  dum[5],dum[6],dum[7],dum[8],dum[9]) != elms)
  {
    strcpy (bsd, deflt);
    return;
  }
  dum[elms-1][len] = EOS;
  strcpy (bsd, dum[elms-1]);
}

/*
*** Transform month into hex.
***
 */
char get_month (char *_month)
{
  int  i;

  strlwr (_month);
  for (i=0; i<12; i++)
    if (strstr (month[i], _month))
      return ((char) (i + 49 + (i>8)*39));
  return ('z'); /* unknow month identifier */
}

/*
*** Quick test for header / file id.
***
 */
int qtest (char *test, int testline)
{
  register i = -1;

  do
  {
    i++;

    if (!test[i])
      break;

    if (test[i] == '~')
      continue;

    if (test[i] != win[testline][i])
      return (1);
  }
  while (win[testline][i]);

  if (test[i])
    return (1);

  return (0);
}
