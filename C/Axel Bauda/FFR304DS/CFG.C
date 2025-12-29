/*
*** FFR by DG1BBQ@DB0CL.DEU.EU
***
*** cfg.c
***
 */

#include "ffr.h"


/*
***
*** read config file.
***
 */
void get_parms (char *arg0)
{
  char drive  [MAXDRIVE];
  char dir    [MAXDIR];
  char home   [MAXPATH];
  char string [MAXGET+1];
  int  count;
  int  count2;
  int  count3;
  int  len;
  FILE *fp;

  *home = EOS;
  count = count2 = count3 = 0;

  if (*mycall) /* in case a callsign has already been set on the command */
   count++;                                                      /* line.*/

  /* get dir and drive where the executable FFR can be found from argv[0].
     ATARI_ST: look for CONFIGFILE in root dir, because argv[0] is always
     empty there (at least with TC2.0). */

  if (arg0 == NULL)
    sprintf (home, "%s%s", PATHSEP, CONFIGFILE);
  else
  {
    fnsplit (arg0, drive, dir, NULL, NULL);
    sprintf (home, "%s%s%s", drive, dir, CONFIGFILE);
  }

  /* if CONFIGFILE not found, look in current dir */
  if ((fp = fopen (home, OPEN_READ_TEXT)) == NULL)
  {
    strcpy (home, CONFIGFILE);

#ifdef __unix__
    /*
     * if CONFIGFILE still not found, look up environment variable HOME
     */
    if ((fp = fopen (home, OPEN_READ_TEXT)) == NULL)
    {
      char *cp;

      cp = getenv ("HOME");
      strcpy (home, cp);
      if (cp[strlen(cp)-1] != PATHCHAR)
        strcat (home, PATHSEP);
      strcat (home, CONFIGFILE);
    }
    else
      fclose (fp);
#endif

  }
  else
    fclose (fp);

  if ((fp = fopen (home, OPEN_READ_TEXT)) != NULL)
  {
    while (fgets (string, MAXGET, fp) != NULL)
    {
      len = (int) strlen (string);

      /* comment, ignore */
      if (string[0] == '#')
        continue;

      /* path for encode files */
      if (!strnicmp (string, "codepath ", 9) && !*codepath && !(ignore & 4))
        sscanf (string+9, "\"%[^\"]", codepath);

      /* path for personal mail */
      if (!strnicmp (string, "perspath ", 9) && !*perspath && !(ignore & 8))
        sscanf (string+9, "\"%[^\"]", perspath);

      /* path for general mail */
      if (!strnicmp (string, "genpath ", 8) && !*genpath && !(ignore & 16))
        sscanf (string+8, "\"%[^\"]", genpath);

      /* mycalls. up to MAXMYCALL. useful for families and club stations */
      if (!strnicmp (string, "mycall ", 7) && count < MAXMYCALLS)
      {
        sscanf (string+7, "\"%[^\"]", dum[0]);
        strupr (dum[0]);
        cfg_alloc (&mycall[count], dum[0], 0, 0);
        mycall[++count] = NULL;
      }

      /* strings, thats delimit entries. global prompts */
      if (!strnicmp (string, "prompts", 7))
        get_prompts (&prompt, fp, NULL);

      /* get header definitions */
      if (!strnicmp (string, "header ", 7) && count2 < MAXMBTYPES)
      {
        cfg_alloc (&mbhead[count2].type, string, len, 7);
        get_mbdefs (count2, fp);
        mbhead[++count2].type = NULL;
      }

      /* get code file definitions */
      if (!strnicmp (string, "code ", 5) && count3 < MAXCOTYPES)
      {
        cfg_alloc (&code[count3].type, string, len, 5);
        get_codefs (count3, fp);
        code[++count3].type = NULL;
      }

      /* get month indentifiers */
      if (!strnicmp (string, "months", 6))
        get_month_ids (fp);
    }
    fclose (fp);
  }
  else
  {
    printf ("\007"CONFIGFILE" not found\n\n");
    exit (9);
  }
}

void cfg_alloc (char **destp, char *string, int len, int offset)
{
  if (!len)
    len = (int) strlen (string) +1;
  len -= offset;
  *destp = my_malloc (len--);
  strncpy (*destp, string+offset, len);
  (*destp)[len] = EOS;
}

/*
*** Read definitions for the BBS header identification and prompts
*** specific to that BBS.
***
 */
void get_mbdefs (int mbnum, FILE *cfg)
{
  int x;
  unsigned long flag;
  char string [MAXGET+1];
  char format [MAXGET+1];
  struct head **current;
  struct prompt **curprmpt;

  x = 0;
  flag = 0UL;

  current = &mbhead[mbnum].first;
  *current = NULL;
  curprmpt = &mbhead[mbnum].begin;
  *curprmpt = NULL;

  while (fgets (string, MAXGET, cfg) != NULL)
  {
    /* comment, ignore */
    if (string[0] == '#')
      continue;

    if (string[0] == '}')
      break;

    if (!strnicmp (string, "h ", 2))
    {
      get_mbdefline (string, current, &flag, 0);
      current = &(*current)->next;
      *current = NULL;
    }
    if (!strnicmp (string, "b ", 2))
      get_mbdefline (string, &mbhead[mbnum].board, &flag, 1);

    if (!strnicmp (string, "s ", 2))
      get_mbdefline (string, &mbhead[mbnum].sender, &flag, 2);

    if (!strnicmp (string, "d ", 2))
      get_mbdefline (string, &mbhead[mbnum].date, &flag, 3);

    if (!strnicmp (string, "t ", 2))
    {
      flag = flag | (1<<4);
      if (sscanf (string+2, "%d", &x) != 1)
        flag = flag | (1<<12);
      mbhead[mbnum].dtype = x;
    }
    if (!strnicmp (string, "l ", 2))
    {
      flag = flag | (1<<5);
      if (sscanf (string+2, "%d", &x) != 1)
        flag = flag | (1<<13);
      mbhead[mbnum].length = x;
    }
    if (!strnicmp (string, "q ", 2))
    {
      flag = flag | (1<<6);
      if (sscanf (string+2, "%d \"%[^\"]",
                                 &mbhead[mbnum].qtline, format) != 2)
        flag = flag | (1<<14);
      cfg_alloc (&mbhead[mbnum].qtest, format, 0, 0);
    }
    if (!strnicmp (string, "p ", 2))
      curprmpt = get_prompts (curprmpt, NULL, string);
  }

  if (flag != 127)
  {
    printf ("\007Error in "CONFIGFILE":\n");

    if ((flag & 255) != 127)
    {
      printf ("Incomplete definition for '%s'.\n", mbhead[mbnum].type);
      printf ("Missing:\n");
      mb_errs (flag);
      printf ("\n");
    }
    flag >>= 8;
    flag ^= 127;
    if (flag)
    {
      printf ("Wrong definition for '%s'.\n", mbhead[mbnum].type);
      printf ("Syntax error:\n");
      mb_errs (flag);
    }
    exit (0);
  }

}

/*
***
***
 */
void get_mbdefline (char *string, struct head **destp,
                    unsigned long *flag, int bit)
{                   
  char format[MAXGET+1];
  int y = 0;

  *format = EOS;

  *flag = *flag | (1<<bit);
  *destp = my_malloc (sizeof(struct head));
  if (sscanf (string+2, "%d \"%[^\"]", &y, format) != 2)
      *flag = *flag | (1<<(bit+8));
  (*destp)->y = y;
  cfg_alloc (&(*destp)->format, format, 0, 0);
}

/*
***
***
 */

void mb_errs (unsigned long flag)
{
  if (!(flag & 64))
    printf ("Quick test (q)\n");
  if (!(flag & 1))
    printf ("Header (h)\n");
  if (!(flag & 32))
    printf ("Length of Header (l)\n");
  if (!(flag & 2))
    printf ("Board (b)\n");
  if (!(flag & 4))
    printf ("Sender (s)\n");
  if (!(flag & 8))
    printf ("Date (d)\n");
  if (!(flag & 16))
    printf ("Type of Date (t)\n");
}

/*
*** Read definitions for the identification of encoded files.
***
***
 */
void get_codefs (int conum, FILE *cfg)
{
  int x;
  unsigned long flag;
  char string [MAXGET+1];
  struct head **current;

  current = &code[conum].full;
  *current = NULL;

  x = 0;
  flag = 0UL;

  while (fgets (string, MAXGET, cfg) != NULL)
  {
    /* comment, ignore */
    if (string[0] == '#')
      continue;

    if (string[0] == '}')
      break;

    if (!strnicmp (string, "q ", 2))
      get_scodefline (string, &code[conum].qtest, &flag, 0);

    if (!strnicmp (string, "f ", 2))
    {
      get_mbdefline (string, current, &flag, 1);
      current = &(*current)->next;
      *current = NULL;
    }

    if (!strnicmp (string, "n ", 2))
      get_scodefline (string, &code[conum].name, &flag, 2);

    if (!strnicmp (string, "p ", 2))
      get_scodefline (string, &code[conum].part, &flag, 3);

    if (!strnicmp (string, "o ", 2))
      get_scodefline (string, &code[conum].of_parts, &flag, 4);

    if (!strnicmp (string, "1 ", 2))
      get_codefline (string, &code[conum].pform_1, &flag, 5);

    if (!strnicmp (string, "2 ", 2))
      get_codefline (string, &code[conum].pform_2, &flag, 6);

    if (!strnicmp (string, "e ", 2))
      get_codefline (string, &code[conum].end, &flag, 7);

    if (!strnicmp (string, "i ", 2))
    {
      flag = flag | (1<<8);
      if (sscanf (string+2, "%d", &x) != 1)
        flag = flag | (1<<24);
      code[conum].increment = x;
    }
    if (!strnicmp (string, "t ", 2))
    {
      flag = flag | (1<<9);
      if (sscanf (string+2, "%d", &x) != 1)
        flag = flag | (1<<25);
      code[conum].codetype = x;
    }
    if (!strnicmp (string, "l ", 2))
    {
      flag = flag | (1<<10);
      if (sscanf (string+2, "%d", &x) != 1)
        flag = flag | (1<<26);
      code[conum].length = x;
    }
  }

  if (flag != (1<<11)-1)
  {
    printf ("\007Error in "CONFIGFILE":\n");

    if ((flag & (1<<16)-1) != (1<<11)-1)
    {
      printf ("Incomplete definition for '%s'.\n", code[conum].type);
      printf ("Missing:\n");
      co_errs (flag);
      printf ("\n");
    }
    flag >>= 16;
    flag ^= (1<<16)-1;
    if (flag)
    {
      printf ("Wrong definition for '%s'.\n", code[conum].type);
      printf ("Syntax error:\n");
      co_errs (flag);
    }
    exit (0);
  }

}

/*
***
***
 */
void get_codefline (char *string, char **destp, unsigned long *flag, int bit)
{                   
  char format[MAXGET+1];

  *format = EOS;

  *flag = *flag | (1<<bit);
  if (sscanf (string+2, "\"%[^\"]", format) != 1)
  {
    if (strstr(string+2, "\"\""))
      *format = EOS;
    else
      *flag = *flag | (1<<(bit+16));
  }
  cfg_alloc (destp, format, 0, 0);
}

/*
***
***
 */
void get_scodefline (char *string, struct shead **destp,
                    unsigned long *flag, int bit)
{                   
  char format[MAXGET+1];
  int y = 0;

  *format = EOS;

  *flag = *flag | (1<<bit);
  *destp = my_malloc (sizeof(struct shead));
  if (sscanf (string+2, "%d \"%[^\"]", &y, format) != 2)
  {
    if (strstr(string+2, "\"\""))
      *format = EOS;
    else
      *flag = *flag | (1<<(bit+16));
  }
  (*destp)->y = y;
  cfg_alloc (&(*destp)->format, format, 0, 0);
}

/*
***
***
 */
void co_errs (unsigned long flag)
{
  if (!(flag & 1))
    printf ("Quick test (q)\n");
  if (!(flag & 2))
    printf ("Full test (f)\n");
  if (!(flag & 1024))
    printf ("Length of header (l)\n");
  if (!(flag & 4))
    printf ("Name (n)\n");
  if (!(flag & 8))
    printf ("Part (p)\n");
  if (!(flag & 16))
    printf ("Of Part (o)\n");
  if (!(flag & 32))
    printf ("Print format 1 (1)\n");
  if (!(flag & 64))
    printf ("Print format 2 (2)\n");
  if (!(flag & 128))
    printf ("End test (e)\n");
  if (!(flag & 256))
    printf ("Inc-flag (i)\n");
  if (!(flag & 512))
    printf ("Type (t)\n");
}

/*
***
***
 */
struct prompt **get_prompts (struct prompt **prmpt, FILE *cfg, char *cfgline)
{
  struct prompt **current;
  char string[MAXGET+1];
  char *x, *y;
  int repos, m;

  current = prmpt;

  *string = EOS;
  x = y = NULL;
  repos = 0;

  do
  {
    if (cfg)
      x = fgets (string, MAXGET, cfg);
    else
      x = cfgline;

    if (*x == '#' || *x == '{')
      continue;

    if (strnicmp (x, "p ", 2))
    {
      x = NULL;
      break;
    }

    sscanf (x+2, "%d \"%[^\"]", &repos, dum[0]);

    strcpy (dum[1], dum[0]);
    if ((y = strstr (dum[0], "%m")) == NULL)
      y = strstr (dum[0], "%M");

    m = 0;
    while (mycall[m] && y || !y)
    {
      *current = my_malloc (sizeof(struct prompt));
      if (y)
      {
        strcpy (dum[0], dum[1]);
        *y = EOS;
        strcpy (string, dum[0]);
        strcpy (dum[2], mycall[m++]);
        if (*(y+1) == 'M')
          strupr (dum[2]);
        else
          strlwr (dum[2]);
        strcat (string, dum[2]);
        strcat (string, y+2);
        strcpy (dum[0], string);
      }
      cfg_alloc (&(*current)->format, dum[0], 0, 0);
      (*current)->len = (int) strlen (dum[0]);
      (*current)->elements = elements (dum[0]);
      (*current)->repos = repos;
      current = &(*current)->next;
      *current = NULL;
      if (!y)
        break;
    }
    if (cfgline)
      x = NULL;

  } while (x);

  return (current);
}

/*
*** get month identifiers
***
 */
void get_month_ids (FILE *cfg)
{

  char string [MAXGET+1];
  char months [MAXGET+1];
  int i;

  for (i=0;i<12;i++)
    month[i] = NULL;

  while (fgets (string, MAXGET, cfg) != NULL)
  {
    /* comment, ignore */
    if (string[0] == '#')
      continue;

    if (string[0] == '}')
      break;

    if (sscanf (string, "%d \"%[^\"]", &i, months) == 2)
      if (i < 13 && i > 0)
        cfg_alloc (&month[i-1], months, 0, 0);
  }
}

/*
*** Figure out, how many format elements are in the format string.
***
 */
int elements (char *format)
{
  int elms;
  int pos;

  elms = pos = 0;

  while (format[pos])
  {
    if (format[pos] == '%')
      if (format[pos+1] != '%')
        elms++;
      else
        pos ++;
    pos++;
  }
  return (elms);
}
