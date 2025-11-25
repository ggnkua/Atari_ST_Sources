#include "7plus.h"
#include "globals.h"

/*
*** First decode. If there already are CORs for that file, try correcting
*** afterwards.
***
 */
int control_decode (char *name)
{
  int i, cor_exists;
  char newname[MAXPATH];

  i = cor_exists = 0;
  *_ext = EOS;

  fnsplit (name, _drive, _dir, _file, _ext);
  sprintf (newname, "%s%s%s.cor", _drive, _dir, _file);

  if (!test_exist (newname))
    cor_exists = 1;

  i = decode_file (name, cor_exists);
  if ((i == 11 || i == 19) && cor_exists)
    return (correct_meta (newname, 1));

  return (i);
}

/*
*** decode a file. create error report, if errors detected.
***
***
 */

int decode_file (char *name, int flag)
{
  FILE     *in, *out;
  int      part, _part, parts, _parts, _parts0;
  int      c_line, c_line2, c_line3, f_lines, blocklines;
  int      defect, rest, length, hcorrupted, ignored;
  uint     csequence, crc;
  long     binbytes, _binbytes, lines, rebuilt;
  ulong    ftimestamp, line;
  char     rline[81], *p, dummi[20], dummi2[81];
  char     inpath[MAXFPATH], indexfile[MAXPATH], metafile[MAXPATH];
  char     filename[13], srcname[MAXPATH], orgname[MAXFNAME];
  char     orgname2[66], destname[13];
  register i, j;

  *orgname = EOS;
  in = out = NULLFP;
  hcorrupted = ignored = 0;
  ftimestamp = 0UL;

  /* Isolate input-path and filename */
  fnsplit (name, _drive, _dir, _file, _ext);
  sprintf (inpath, "%s%s", _drive, _dir);
  build_DOS_name (_file);
  build_DOS_name (_ext);
  _file[8] = _ext[3] = EOS;

  /* Make up names for the meta- and indexfile */
  sprintf (metafile,  "%s.7mf", _file);
  sprintf (indexfile, "%s.7ix", _file);

  if (!test_exist (metafile))
  {
    printf ("\007Metafile '%s' already exists.\n", metafile);
    return (19);
  }

  /* Initialize index-info */
  *index->filename  = *index->full_name  = EOS;
  index->length     = index->timestamp   = 0UL;
  index->splitsize  = 0;
  for (i=0;i<4080;i++)
    index->lines_ok[i] = 0UL;

  /* Find out, if it's a splitted file */
  parts = 2;
  sprintf (srcname, "%s%s.p01", inpath, _file);
  if (test_exist (srcname))
  {
    parts = 1;
    sprintf (srcname, "%s%s.7pl", inpath, _file);
    if (test_exist (srcname))
    {
      sprintf (srcname, "%s.7pl/p01", _file);
      printf (cant, srcname);
      return (2);
    }
  }

  /* Open input file */
  in = fopen (srcname, OPEN_READ_BINARY);

  /* Set I/O-buffering */
  setvbuf (in, NULL, _IOFBF, buflen);

  printf ("\n-----------\nDecoding...\n-----------\n\n");

  defect = _parts0 = rest = length = 0;
  lines = rebuilt = 0L;

  /* Loop for number of parts. */
  for (part = 1; part < parts +1; part++)
  {
    if (part == 256)
    {
      printf ("\007\nMore than 255 parts not allowed. Break.\n");
      kill_dest (in, out, metafile);
      return (8);
    }

    /* If more than 1 part, generate filename for messages and handling. */
    if (parts == 1)
      sprintf (filename, "%s.7pl", _file);
    else
      sprintf (filename, "%s.p%02x", _file, part);

    /* If we're already at part > 1, generate filename for next part. */
    if (part != 1)
    {
      sprintf (srcname, "%s%s", inpath, filename);
      if (!(in = fopen (srcname, OPEN_READ_BINARY)))
      {
        printf ("\007\n'%s': Not found. Break.\n", srcname);
        printf ("\nYou must have all parts to be able to decode!\n");
        printf ("              ===\n");
        printf ("Get the missing files and try again.\n");

        kill_dest (in, out, metafile);
        return (2);
      }
      setvbuf (in, NULL, _IOFBF, buflen);
    }

    /* Read, until starting line is found. */
    while ((p = my_fgets (rline, 80, in)) != NULL)
    {
      if (!strncmp (rline, " go_7+. ", 7))
        break;
    }
    /* p == NULL? then no starting line found. File no good. */
    if (!p)
    {
      printf ("\007'%s': 7PLUS-startline ", filename);
      printf ("not found. Break.\n");
      kill_dest (in, out, metafile);
      return (3);
    }

    if (!mcrc (rline, 0))
      rebuild (rline, 1);

    /* Check if file went trough 7bit channel */
    if (!strstr (rline, "\xb0\xb1"))
    {
      printf ("\007\n'%s':\nBit 8 has been stripped! Can't decode.\n", filename);
      printf ("Please check all settings of your terminal and tnc regarding 8 bit transfer.\n");
      printf ("You will have to re-read '%s' from the mailbox\n", filename);
      printf ("after having corrected the settings.\n");
      kill_dest (in, out, metafile);
      return (9);
    }

    /* Get info from 7PLUS header */
    if(sscanf (rline+8, "%d %s %d %s %ld %s %s %s %s %s",
            &_part, dummi, &_parts, destname,
            &binbytes, dummi, dummi2, dummi, dummi, dummi) != 10)
      hcorrupted = 1;
    blocklines = get_hex (dummi2);
    strlwr (destname);                  /* Convert to lower case */

    /* Set number of lines in this file */
    f_lines = blocklines;
    if (_part == _parts)
      f_lines = (int) (((binbytes + 61) / 62) % blocklines);
    if (!f_lines)
      f_lines = blocklines;
    f_lines--;

    if (strlen (dummi) == 5)
      if (!mcrc(rline, 0))
        hcorrupted = 1;

    if (!hcorrupted)
    {
      if (_part == 1)
      {
        _parts0  = _parts;
        strcpy (index->filename, destname);
        index->length  = binbytes;
        index->splitsize = blocklines;
      }

      if (_parts0 != _parts        || stricmp(index->filename, destname) ||
          index->length != binbytes || index->splitsize != blocklines)
        hcorrupted = 1;
    }
    if (hcorrupted)
    {
      printf ("'%s': Header is corrupted. Can't continue.\n", filename);
      kill_dest (in, out, metafile);
      return(5);
    }
    /* If first part, process filename, calculate how many valid binary bytes
       are contained in last code line of last part, initialize index-info. */
    if (_part == 1)
    {

      *orgname2 = EOS;

      if (dummi[3] == '*')
      {
        my_fgets (rline, 80, in);
        if (!mcrc (rline, 0))
        {
          printf ("\nExtended Filename corrupted. Using filename from header.\n");
          strcpy (orgname2, index->filename);
        }
        else
          sscanf (rline, "/%60[^/]", orgname2);
      }

      strcpy (orgname,  index->filename);
      if (extended == '*' && *orgname2)
        strncpy (orgname, orgname2, (size_t)(MAXFNAME-1));
      strcpy (index->full_name, orgname);

      rest = (int) (binbytes % 62);
      if (!rest)
        rest = 62;
      parts = _parts; /* Set number of parts to decode. */
    }

    /* Current file does not contain expected part */
    if (_part != part)
    {
      printf ("\007'%s': File does not contain part %03d. Break.\n", filename, part);
      kill_dest (in, out, metafile);
      return (4);
    }

    /* If first part, open metafile for writing. */
    if (part == 1)
    {
      out = fopen (metafile, OPEN_WRITE_BINARY);
      setvbuf (out, NULL, _IOFBF, buflen); /* As always, bufferize */
      printf ("File         Pt# of# Errors Rebuilt   Status\n");
      progress (filename, part, parts, 0, 0, "decoding...");
    }

    c_line = c_line2 = -1;

    /* Now decode this part */
    do
    {
      /* Get a line from code file */
      p = my_fgets (rline, 80, in);

      /* If line starts with a space, check if it's the last line */
      if (p && *rline == ' ')
        if (!strncmp (rline, " stop_7+.", 8))
        {
          /* Get timespamp */
          if (!ftimestamp && strchr (rline, '['))
          {
            if (!mcrc (rline, 0))
            {
              progress (filename, part, parts, lines, rebuilt, "### rebuilding a line ###");
              rebuild (rline, 2);
              progress (filename, part, parts, lines, rebuilt, "decoding...");
            }
            if (mcrc (rline, 0))
            {
              char dummy[30];

              if (sscanf (rline, " stop_7+. %s [%lX]",
                                                     dummy, &ftimestamp) != 2)
                ftimestamp = 0UL;
            }
            index->timestamp = ftimestamp;
          }
          p = NULL; /* Last line, set end indicator */
        }
      if (p)
      {
        /* Calculate CRC */
        csequence = 0;
        for (i=0; i<64; i++)
          csequence = crctab[csequence>>8] ^ (((csequence&255)<<8) |
                                                                  (byte)p[i]);
        csequence &= 0x3fff; /* strip calculated CRC to 14 bits */

        c_line3 = c_line;
        /* Get crc from code line */
        crc_n_lnum (&crc, &c_line, p);

        if (csequence != crc)
        {
          if (ignored &1)
            progress (filename, part, parts, lines, rebuilt, "*** rebuilding a line ***");
          else
            progress (filename, part, parts, lines, rebuilt, "### rebuilding a line ###");
          if (!rebuild (p, 0))
          {
            ignored++; /* Incorrect CRC. Ignore line. */
            c_line = c_line3;
            continue;
          }

          rebuilt++;
          progress (filename, part, parts, lines, rebuilt, "decoding...");
          crc_n_lnum (&crc, &c_line, p);
        }

        /* Number of valid binary bytes in this line. If it's the last line
           of the last part, set it to the number precalculated earlier */
        length = 62;
        if (c_line == f_lines && part == parts)
          length = rest;
      }

      /* If file ends prematurely, set current line number to number of
         lines in this part, so that the missing lines can be protocolled. */
      if (!p && f_lines != c_line)
        c_line = f_lines+2;

      /* If current line number is greater than previous one -> ok */
      if (c_line > c_line2)
      {
        /* Difference is greater than 1, then line(s) must be missing. */
        if (c_line2 != c_line-1)
        {
          defect = 1;

          /* Loop for number of missing or corrupted lines */
          for (i = c_line2+1; i < c_line; i++)
          {
            progress (filename, part, parts, lines, rebuilt, "decoding...");
            lines++; /* Number of missing or corrupted lines. */

            j = 62;
            if (i == f_lines && part == parts)
              j = rest;

            line = (long)(part-1) * index->splitsize +i;
            index->lines_ok[(int)(line>>5)] += 1UL << (int)(line&31);

            /* Write fill-bytes into metafile */
            for (;j;j--)
              my_putc ( 0, out);

            if (i == f_lines)
            {
              length = 0;
              break;
            }
          }
        }
        decode_n_write (out, rline, length);

        c_line2 = c_line; /* Memorize current line number */
      }
    }
    while (p); /* Loop until current code file ends */

    progress (filename, part, parts, lines, rebuilt, "decoding...");

    fclose (in);
  }
  progress (filename, part-1, parts, lines, rebuilt, "done...");

  index->lines_left = lines;

  /* Get size of metafile */
  _binbytes = ftell (out);

  if (out)
    fclose (out);

  if (defect) /* write index-file and error report */
    w_index_err (index, 0);
  else
  {
    if (_binbytes == binbytes)
    {
      test_file (NULLFP, orgname, 1, MAXFNAME-1);
      replace (orgname, metafile, ftimestamp);

      printf ("\n");

      if (autokill)
        kill_em (_file, inpath, (parts==1)?"7pl":"p", "cor", "c", "err", "e");

      printf ("\nDecoding successful! '%s', %ld bytes.\n",
                                                           orgname, binbytes);
      return (0);
    }
  }

  printf ("\n");
  if (!flag)
  {
    printf ("\nDecoding of '%s' not successful.\n", orgname);
    if (index->lines_left > (index->length/620L))
    {
      printf ("\nWARNING:\n========\n");
      printf ("More than 10%% of all lines are corrupted! Are you sure, your communications\n");
      printf ("programm is set correctly to handle 7PLUS files (character conversion ect..)?\n");
      printf ("Maybe you didn't get parts of the files because of link failures?\n");
      printf ("Of course, the cause may lie with the originating source...\n\n");
    }
  }
  if (_binbytes != binbytes)
  {
    printf ("\nDecoded file has wrong length! Disk full?\n");
    printf ("This error should never have occured.....I hoped...\n");
    return (1);
  }
  else
    if (autokill)
      kill_em (_file, inpath, (parts==1)?"7pl":"p", NULL, NULL, NULL, NULL);

  return (11);
}


/*
***
*** split up longs into 2 * 31 binary bytes and write to file.
***
 */
void decode_n_write (FILE *out, char *p, int length)
{
  static ulong after[16], *af;
  static int   i, j, k;

  /* Re-arrange data-characters to 2*8 longs containing 31 bits each.*/
  for (i=k=0; i<64; i++)
  {
    if ((i&3) == 3)
    {
      after[k] = 0L;
      for (j=i;j>(i-4);j--)
        after[k] = after[k] * 216L + decode[(byte)p[j]];
      k++;
    }
  }

  af = after;
  for (i=0; i<2; i++, af+=8)
  {
    /* Re-arrange to 2*8 longs containing 32 bits.
       7th and 15th long only contain 24 valid bits. */
    af[0] = (af[0] << 1) | (af[1] >> 30);
    af[1] = (af[1] << 2) | (af[2] >> 29);
    af[2] = (af[2] << 3) | (af[3] >> 28);
    af[3] = (af[3] << 4) | (af[4] >> 27);
    af[4] = (af[4] << 5) | (af[5] >> 26);
    af[5] = (af[5] << 6) | (af[6] >> 25);
    af[6] = (af[6] << 7) | (af[7] >> 24);
    af[7] = (af[7] << 8);
    for(j=0; j<8; j++)
    {
      for (k=24;k;k-=8)
      {
        if (!length)
          break;
        length--;
        my_putc ((int) (af[j] >> k), out);
      }
      if (j == 7 || !length)
        break;
      length--;
      my_putc ((int) af[j], out);
    }
  }
}

/*
*** Write indexfile and error report
***
***
 */
void w_index_err (struct m_index *index, int flag)
{
  FILE *ifile;
  char filename[13];

  if (!flag)
  {
    fnsplit (index->filename, NULL, NULL, filename, NULL);

    #ifndef _CHSIZE_OK
     strcat (filename, ".7ix");
     ifile = fopen (filename, OPEN_WRITE_BINARY);
    #else
     strcat (filename, ".7mf");
     ifile = fopen (filename, OPEN_RANDOM_BINARY);
    #endif
    write_index (ifile, index, 0);
    fclose (ifile);
  }
  fnsplit (index->filename, NULL, NULL, filename, NULL);
  strcat (filename, ".err");
  ifile = fopen (filename, OPEN_WRITE_TEXT);
  strupr (filename);
  fprintf (ifile, " go_text. %s%s", filename, delimit);
  strcpy (filename, index->filename);
  strupr (filename);
  fprintf (ifile, "7PLUS error report: %s %03X", filename, index->splitsize);
  if (strcmp (index->full_name, index->filename))
    fprintf (ifile, " /%s/", index->full_name);
  fprintf (ifile, " %ld%s", index->length, delimit);
  write_index (ifile, index, 1);
  fprintf (ifile, "[%lX]%s00%s", index->timestamp, delimit, delimit);
  fprintf (ifile, "________%s stop_text.%s", delimit, delimit);
  if (endstr)
    fprintf (ifile, "%s%s", endstr, delimit);
  fclose (ifile);

  fnsplit (index->filename, NULL, NULL, filename, NULL);
  strcat (filename, ".err");
  crc_file (filename, "7P", "00\n", 0);
}

/*
*** If an error report has been accidentally erased, it can be recreated
*** using the information in the indexfile, respectively metafile.
*** (depends on _CHSIZE_OK)
 */
int make_new_err (char *name)
{
  FILE   *rfile;

  printf ("-----------------------\nRecreating error report\n-----------------------\n\n");

  /* Open meta file */
  if (!(rfile = fopen (name, OPEN_READ_BINARY)))
  {
    printf (cant, name);
    return (2);
  }

  /* read index info into struct index */
  if (read_index (rfile, index))
  {
    printf ("\007Invalid index info.\n");
    return (7);
  }

  fclose (rfile);

  w_index_err (index, 1);

  printf ("Error report has been recreated from '%s'.\n", name);

  return (0);
}

/*
*** Progress indication
***
***
 */
void progress (char *filename, int part, int of_parts, long errors,
                                                    long rebuilt, char *status)
{
  printf ("%-12s %3d %3d %6ld  %6ld   %-30s\r",
    filename, part, of_parts, errors, rebuilt, status);
  fflush (stdout);
}
