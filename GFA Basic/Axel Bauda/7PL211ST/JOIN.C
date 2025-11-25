#include "7plus.h"
#include "globals.h"

/*
*** control joining of err-files
***
***
 */
int join_control (char *file1, char *file2)
{
  char *q, errnam[MAXPATH], dummi[20];
  int  errn, n;

  n = 0;

  if (file1 && file2)
    return (join_err (file1, file2));

  if (!file1)
  {
    printf ("\007No error report specified.\nBreak.\n");
    return (12);
  }

  strcpy (errnam, file1);

  errn = 1;
  do
  {
    if ((q = strrchr (errnam, '.')) != NULL)
      *q = EOS;
    sprintf (dummi, ".e%02x", errn++);
    strcat (errnam, dummi);

    if (n > 4)
      break;

    if (test_exist (errnam))
    {
      n++;
      continue;
    }

    if (join_err (file1, errnam))
      break;

    n = 0;
  }
  while (errn != 256);

  return (0);
}



/*
*** join error reports. This is useful when many different error reports
*** were received. if the sum of missing lines in the reports isn't too big,
*** it may be practical to upload a correction file that covers lines from
*** more than a single error report.
 */

int join_err (char *file1, char *file2)
{
  FILE *_file[2], *tmp;
  char *p[2], *file[2], line[2][81];
  char name[2][80], fullname [2][31];
  char ltab[512], dummi[20];
  char *err_rprt = "7PLUS error report:";
  char *scan     = "%12s %s /%30[^/]/ %ld";
  char *scan2    = "%12s %s %ld";
  char *inv_err  = "\007Invalid error report: '%s'\n";
  int  blocksize[2], part[2], _part;
  int  i, j, k;
  long fsize[2];
  ulong timestamp[2];

  file[0] = strdup (file1);
  file[1] = strdup (file2);

  for (i=0;i<2;i++)
  {
    *name[i] = *fullname[i] = EOS;
    blocksize[i] = part[i] = 0;
    fsize[i] = 0L;
    timestamp[i] = 0UL;
    p[i] = NULL;

    if (crc_file (file[i], err_rprt, "00\n", 1) == 1)
      return (7);

    _file[i] = fopen (file[i], OPEN_READ_TEXT);

    while ((p[i] = my_fgets (line[i], 80, _file[i])) != NULL)
      if (!strncmp (line[i], err_rprt, 19))
        break;

    if (!p[i])
    {
      printf (inv_err, file[i]);
      return(7);
    }
    sscanf (&line[i][20], scan, name[i], dummi, fullname[i], &fsize[i]);
    blocksize[i] = get_hex (dummi);
    if (!*fullname[i])
    {
      fsize[i] = 0L;
      sscanf (&line[i][20], scan2, name[i], dummi, &fsize[i]);
    }
  }
  if (strcmp (name[0], name[1]) || (blocksize[0] != blocksize[1]) ||
       ((fsize[0] && fsize[1]) && (fsize[0] != fsize[1])))
  {
    printf ("\007The two error reports do not relate to the same original file!\n");
    printf ("Break.\n");
    return (13);
  }

  if (!fsize[0])
    fsize[0] = fsize[1];

  if (!fsize[1])
    fsize[1] = fsize[0];

  if (!*fullname[0])
    strcpy (fullname[0], fullname[1]);

  if (!*fullname[1])
    strcpy (fullname[1], fullname[0]);

  if (!(tmp = fopen ("7plus.tmp", OPEN_WRITE_TEXT)))
  {
    printf ("\007Can't write new error report.\nBreak.\n");
    return (1);
  }

  fnsplit (name[0], NULL, NULL, line[0], NULL);
  strupr (line[0]);
  fprintf (tmp, " go_text. %s.ERR%s", line[0], delimit);
  fprintf (tmp, "7PLUS error report: %s %03X", name[0], blocksize[0]);
  if (*fullname[0])
    fprintf (tmp, " /%s/", fullname[0]);
  if (fsize[0])
    fprintf (tmp, " %ld", fsize[0]);
  fprintf (tmp, delimit);

  part[0] = part[1] = 0;
  for (_part=1;_part<256;_part++)
  {
    for (i=0;i<2;i++)
    {
      if (part[i] < _part && part[i] != -1)
      {
        fscanf (_file[i], "%s", line[i]);
        if (*line[i] == '[')
        {
          sscanf (line[i], "[%lX", &timestamp[i]);
          part[i] = 0;
        }
        else
          part[i] = get_hex (line[i]);
      }
      if (!part[i])
        part[i] = -1;
    }

    if (part[0] == -1 && part[1] == -1)
      break;

    for (i=0;i<512;i++)
      ltab[i] = 0;
    for (i=0;i<2;i++)
    {
      if (part[i] == _part)
      {
        j = 0;
        while (j != 0xfff)
        {
          fscanf (_file[i], "%s", line[0]);
          j = get_hex (line[0]);
          if (j != 0xfff)
            ltab[j] = 1;
          else
            break;
        }
      }
    }
    for (i=k=0;i<512;i++)
      k += ltab[i];
    if (k)
    {
      fprintf (tmp, "%02X%s", _part, delimit);
      k = 18;
      for (i=0;i<512;i++)
      {
        if (ltab[i])
        {
          fprintf (tmp, "%03X ", i);
          k--;
        }
        if (!k)
        {
          fprintf (tmp, delimit);
          k = 18;
        }
      }
      fprintf (tmp, "FFF%s", delimit);
    }
  }

  i = 0;
  if (!timestamp[0] && timestamp[1])
    i = 1;

  if (timestamp[i])
    fprintf (tmp, "[%lX]%s", timestamp[i], delimit);
  fprintf (tmp, "00%s________%s stop_text.%s", delimit, delimit, delimit);

  fclose (_file[0]);
  fclose (_file[1]);
  fclose (tmp);

  if (timestamp[0] && timestamp[1] && timestamp[0] != timestamp[1])
  {
    unlink ("7plus.tmp");
    printf ("\007The two error reports do not relate to the same original file!\n");
    printf ("The timestamps contained are different!\n");
    printf ("Break.\n");
    return (13);
  }

  unlink (file[0]);
  rename ("7plus.tmp", file[0]);
  crc_file (file[0], "7P",  "00\n", 0);

  printf ("'%s' has been joined to '%s'.\n", file[1], file[0]);

  return(0);
}
