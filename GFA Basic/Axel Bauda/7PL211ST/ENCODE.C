#include "7plus.h"
#include "globals.h"

/*
*** encode a file. split, if desired/needed. create correction file.
***
***
 */

int encode_file (char *name, long blocksize, char *searchbin,
                                                   int _part, char *head_foot)
{
  int      part, parts, blocklines, curline;
  int      correct, corrlines , corrpart, corrline, tune;
  uint     csequence;
  ulong    ftimestamp, ftstamp0 , after[16], *af, h;
  long     binbytes, binb0, position, size, corrsize;
  char     destname[13], hdrname[MAXFNAME], filename[13], corrname[13];
  char     orgname[66], inpath[MAXFPATH], line[81], line2[81];
  char     dummi[20], dummi2[20], *q, *r;
  char     go_buf[257], stop_buf[257], cor_head[129];

  FILE     *in, *out, *corr;
  register i, j, k;

  correct = i = corrpart = corrlines  = blocklines = 0;
  *destname = *hdrname = *filename = *corrname = *inpath = *orgname = EOS;
  *_file = *go_buf = *stop_buf = EOS;
  in = out = corr = NULLFP;
  ftimestamp = ftstamp0 = 0UL;
  corrsize = 0L;

  #ifdef TWO_CHAR_SEP
   tune = 1;
  #else
   tune = 0;
  #endif

  if (fls)
    if (!test_exist ("7plus.fls"))
      unlink ("7plus.fls");

  if (searchbin)
  {
    /* Get serchpath for binary (original) file. */
    fnsplit (searchbin, _drive, _dir, _file, _ext);
    sprintf (inpath, "%s%s", _drive, _dir);
  }

  q = name;
  /* create correction file, if ext of input file is .ERR */
  if ((r = strrchr (q, '.')) != NULL)
    if (!strnicmp (".err", r, 4))
    {
      /* OK, input file is an error file */
      correct = 1;

      if ((i = crc_file (q, "7PLUS error", "00\n", 1)) != 0)
        if (i != 17)
          return (i);

      corr = fopen (q, OPEN_READ_TEXT);

      /* Find starting line. */
      while ((r = my_fgets (line, 80, corr)) != NULL)
        if (!strncmp (line, "7PLUS ", 6))
          break;

      if (!r)
      {
        printf ("\007'%s': invalid error report. Break.\n", q);
        fclose (corr);
        return (7);
      }
      /* Get name, lines per part, and length of original
         file from error file.*/
      *orgname = EOS;
      binb0 = 0L;
      ftstamp0 = 0UL;
      sscanf (line+20, "%12s %s /%66[^/]/ %ld",
                          corrname, dummi, orgname, &binb0);
      corrlines  = get_hex (dummi);
      if (!*orgname)
      {
        binb0 = 0L;
        sscanf (line+20, "%s %s %ld",
                                      dummi, dummi, &binb0);
      }
      strlwr (corrname);
      if (extended != '*' || !*orgname)
        strcpy (orgname, corrname);
      /* Build complete filename for original file */
      if (!*_file)
        strcat (inpath, orgname);
      else
      {
        strcat (inpath, _file);
        strcat (inpath, _ext);
      }
      q = inpath;
    }

  if (!(in = fopen (q, OPEN_READ_BINARY)))
  {
    printf ("\007'%s' not found. Break.\n", q);
    return (2);
  }

  if (head_foot && !correct)
    read_tb (head_foot, go_buf, stop_buf);

  /* Get file's timestamp */
  #if defined (__MSDOS__) || (__TOS__)
   ftimestamp = get_filetime (in);
  #else
   ftimestamp = get_filetime (q);
  #endif

  /* determine size of original file. This could be done with filestat(),
     but it's not available on all compilers. */
  fseek (in, 0L, SEEK_END); /* position read pointer to end of file. */
  size = ftell (in);        /* get size. */
  fseek (in, 0L, SEEK_SET); /* reposition to beginning of file. */

  if (correct && binb0 && size != binb0)
  {
    printf (notsame, "error report");
    fclose (in);
    fclose (corr);
    return (15);
  }

  part = parts = 1;

  if (!correct)
  {
    /* Bufferize input, if we're encoding. */
    setvbuf (in, NULL, _IOFBF, buflen);

    /* if blocksize is greater then try to split into blocksize-50000 parts */
    if (blocksize > 50000L)
    {
      blocksize -= 50000L;
      /* calculate how many ascii-bytes per part are needed to get roughly
         equal filelengths. */
      blocksize = (((size + 61) / 62) + (blocksize - 1)) / blocksize;
      blocksize *= 62;
    }

    /* if blocksize is defined as zero or if it's bigger than the file,
       set it to filelength  */
    if (!blocksize || blocksize > size)
      blocksize = size;

    /* automatically split into 512 line parts, if file is bigger. */
    if (blocksize > (512 * 62))
    {
      blocksize = 512 * 62;
      printf ("Blocksize limited to 512 lines per file.\n");
    }
    /* how many lines do the parts contain? */
    blocklines = (int) ((blocksize + 61) / 62);

    /* how many parts result from that? */
    parts = (int) ((size + blocksize-1) / blocksize);

    if (parts > 255)
    {
      printf ("\007Not more than 255 parts allowed.\n");
      printf ("Choose different blocksize. Break.\n");
      fclose (in);
      return (8);
    }
  }
  else
    if (blocksize > 50000L || blocksize == 138L*62L)
      blocksize = 9940L;
    else
      blocksize = (blocksize/62) *71;

  /* generate filenames */
  fnsplit (q, NULL, NULL, _file, _ext);
  sprintf (orgname, "%s%s", _file, _ext);
  build_DOS_name (_file);
  build_DOS_name (_ext);
  /* make sure, the name isn't longer than 8 chars
     and extension not longer 4 (including dot). */
  _file[8] = _ext[3] = EOS;

  strcpy (destname, _file);
  sprintf (hdrname, "%s%s%s", _file, _ext[0]?".":"", _ext);
  strupr (hdrname);

  if (!correct)
    printf ("\n-----------\nEncoding...\n-----------\n\n");
  else
    printf ("\n---------------------------\nCreating correction file...\n\
---------------------------\n\n");

  if (!_part)
    part = 1;
  else
  {
    if (_part > parts || _part < 0)
    {
      printf ("\007Can't encode part %d of %d... You're pulling my leg!\n", _part, parts);
      return (1);
    }
    part = _part;
  }
  /* encode parts */
  for (; part<parts+1 ; part++)
  {
    if (!correct)
    {
      /* generate output filename. *.7PL, if unsplit. *.PXX if split.
         XX represents a two digit hex number. */
      if (parts == 1)
      {
        sprintf (filename, "%s%s", destname, ".7pl");
        printf ("'%s': Writing.\r", filename);
      }
      else
      {
        sprintf (filename, "%s.p%02x", destname, part);
        printf ("'%s': Writing part %03d of %03d.\r", filename, part, parts);
      }

      fflush (stdout);

      /* check, if output file already exists. */
      test_file (out, filename, 0, 12);
    }
    else /* we're creating a correction file, set name accordingly. */
    {
      fnsplit (corrname, NULL, NULL, destname, NULL);
      sprintf (filename, "%s.cor", destname);
    }
    out = fopen (filename, OPEN_WRITE_TEXT);
    setvbuf (out, NULL, _IOFBF, buflen);

    if (!correct)
    {
      if (part == parts && parts > 1)
      {
        if (size % blocksize)
          blocksize = size % blocksize;
        blocksize = ((blocksize + 61 ) / 62) *62;
      }

      top_bottom (out, go_buf, hdrname, part, parts);

      /* output header */
      sprintf (line, " go_7+. %03d of %03d %-12s %07ld %04X %03X (7PLUS v2.0) \
\xb0\xb1\xb2%c", part, parts, hdrname, size,
                    (uint)(((blocksize+61)/62) * 64), blocklines, extended);

      mcrc (line, 1);
      add_crc2 (line);
      fprintf (out, "%s%s", line, delimit);

      if (part == 1 && extended == '*')
      {
        sprintf (line, "///////////////////////////////////////////////////\
///////////\xb0\xb1\xb2*");
        memcpy (line+1, orgname, strlen(orgname));
        mcrc (line, 1);
        add_crc2 (line);
        fprintf (out, "%s%s", line, delimit);
      }
    }
    else
    {
      /* output correction file header */
      strcpy (dummi2, filename);
      strupr (dummi2);
      strupr (corrname);
      sprintf (cor_head, " go_text. %s%s7PLUS correction: %s %ld %03X", dummi2, delimit, corrname, size, corrlines );
      if (ftimestamp)
      {
        sprintf (dummi, " [%lX]", ftimestamp);
        strcat (cor_head, dummi);
      }
      strcat (cor_head, delimit);
      corrsize += fprintf (out, "%s", cor_head) +tune;

      strlwr (corrname);
      fscanf (corr, "%s", dummi2);
      corrpart = get_hex (dummi2);
      corrsize += fprintf (out, " P%02x:%s", corrpart, delimit) +tune;

      printf ("Compiling: '%s'\r", filename);
      fflush (stdout);
    }

    curline = j = 0;
    binbytes = 0L;

    if (_part)
      fseek (in, (long) blocksize * (_part -1), SEEK_SET);

    /* get bytes from original file until it ends or blocksize is reached. */
    while (!feof(in) && ((binbytes < blocksize) || parts == 1) || correct)
    {
      csequence = 0;

      if (correct)
      {
        /* get number of part and number of line to put into correction file
           from error file */
        fscanf (corr, "%s", dummi2);
        corrline  = get_hex (dummi2);
        if (corrline  == 0xfff || corrsize > blocksize)
        {
          if (corrline  == 0xfff)
          {
            corrpart = 0;
            fscanf (corr, "%s", dummi2);
            corrpart = get_hex (dummi2);
            if (!corrpart)
            {
              sscanf (dummi2, "[%lX]", &ftstamp0);
              corrsize = (long) blocksize+1;
              printf ("\n");
            }
            else
            {
              fscanf (corr, "%s", dummi2);
              corrline  = get_hex (dummi2);
            }
          }
          if (corrsize > blocksize)
          {
            corrsize = 0L;

            /* if we were creating a correction file, complete it. */
            fprintf (out, " P00:%s________%s stop_text.%s",
                                                   delimit, delimit, delimit);
            if (endstr)
              fprintf (out, "%s%s", endstr, delimit);
            fclose (out);

            crc_file (filename, "7P", " P00:\n", 0);

            if (!corrpart)
              break;

            fnsplit (corrname, NULL, NULL, destname, NULL);
            sprintf (filename, "%s.c%02x", destname, part++);

            out = fopen (filename, OPEN_WRITE_TEXT);
            setvbuf (out, NULL, _IOFBF, buflen);

            corrsize += fprintf (out, "%s", cor_head) +tune;

            printf ("Compiling: '%s'\r", filename);
            fflush (stdout);
          }
          corrsize += fprintf (out, " P%02X:%s", corrpart, delimit) +tune;
        }
        curline = corrline ;
        /* calculate position in original file to get data from. */
        position =  (long)(corrpart-1) * 62 * (long)corrlines  +
                    62 * (long)corrline  ;
        /* position read pointer. */
        fseek (in, position, SEEK_SET);
        corrsize += fprintf (out, " L%03X:%s", corrline , delimit) +tune;
      }

      /* get two groups of 31 bytes and stuff them into 2 * 8 longs. */
      af = after;
      for (i=0; i<2; i++, af+=8)
      {
        /* Get 31 Bytes and put them into 8 longs. */
        for(j=0; j<8; j++)
        {
          af[j] = 0L;
          for (k=(j==7)?2:3; k>-1; k--)
          {
            if ((h = fgetc (in)) == EOF)
            {
              if (!i && !j && k == 3)
                i = 255;
              h = 0L;
            }
            af[j] = (af[j] << 8) | h;
          }
        }
        /* Rearrange into 8 31bit values. */
        af[7] =  af[7]       | ((af[6] & 127L) << 24);
        af[6] = (af[6] >> 7) | ((af[5] & 63L ) << 25);
        af[5] = (af[5] >> 6) | ((af[4] & 31L ) << 26);
        af[4] = (af[4] >> 5) | ((af[3] & 15L ) << 27);
        af[3] = (af[3] >> 4) | ((af[2] & 7L  ) << 28);
        af[2] = (af[2] >> 3) | ((af[1] & 3L  ) << 29);
        af[1] = (af[1] >> 2) | ((af[0] & 1L  ) << 30);
        af[0] = (af[0] >> 1);
      }
      /* i is 256, then no bytes were read. End of file. */
      if (i == 256)
        break;

      binbytes += 62;

      /* write code line to output file. do radix216 conversion, crc
         calculation and ascii conversion as we go along. */
      for (i=j=0;i<16;i++)
      {
        line2[j++]  = code[(int)(after[i] % 0xd8L)];
        after[i]  /= 0xd8L;
        line2[j++]  = code[(int)(after[i] % 0xd8L)];
        after[i]  /= 0xd8L;
        line2[j++]  = code[(int)(after[i] % 0xd8L)];
        line2[j++]  = code[(int)(after[i] / 0xd8L)];
      }

      for (i=0;i<64;i++)
        csequence = crctab[csequence>>8] ^ (((csequence&255)<<8) |
                                                         (byte) line2[i]);

      /* package line number and crc into three radix216 bytes and add
         to code line. */
      after[0]  = ((long)(curline & 0x1ff) << 14) | (csequence & 0x3fff);
      line2[j++] = code[(int) (after[0] % 0xd8L)];
      after[0] /= 0xd8L;
      line2[j++] = code[(int) (after[0] % 0xd8L)];
      line2[j++] = code[(int) (after[0] / 0xd8L)];

      add_crc2 (line2);
      corrsize += fprintf (out, "%s", line2) +tune;

      /* conclude line with line separator. */
      corrsize += fprintf (out, delimit);
      curline++; /* increase line counter. */
    }

    if (!correct) /* put end indicator into output file. */
    {
      strupr (filename);

      /* Add timestamp */
      sprintf (line, "                                                  \
            \xb0\xb1\xb2\xdb");                                               
      if (parts > 1)
        sprintf (line2, " stop_7+. (%s/%02X) [%lX]", filename, parts, ftimestamp);
      else
        sprintf (line2, " stop_7+. (%s) [%lX]", filename, ftimestamp);
      memcpy (line, line2, strlen(line2));
      mcrc (line, 1);
      add_crc2 (line);
      fprintf (out, "%s%s", line, delimit);
      top_bottom (out, stop_buf, hdrname, part, parts);
      if (endstr)
        fprintf (out, "%s%s", endstr, delimit);

      /* OK. This part is done. */
      fclose (out);
    }
    else
      if (ftstamp0 && ftstamp0 != ftimestamp)
        printf ("\007Warning: Timestamp in error report differs from the original file!\n");

    if (ferror(out)) /* did any errors occur while writing? */
    {
      printf ("\n\007Write error. Break.\n");
      fclose (in);
      return (1);
    }

    if (_part || correct)
      part = 256;
  } /* end of for() */

  /* all parts done.
     tell user about action. */
  if (!correct)
  {
    printf ("\n\nEncoding successful!\n");
    if (fls)
    {
      if (!(out = fopen ("7plus.fls", OPEN_WRITE_TEXT)))
        return (14);
      fnsplit (filename, NULL, NULL, _file, NULL);
      fprintf (out, "%d %s\n", parts, _file);
      fclose (out);
    }
  }
  fclose (in);
  return (0);
}

/*
*** Get info from header ifile
***
***
 */

int read_tb (char *name, char *go_top, char *go_bottom)
{
  FILE *rfile;
  int i, j, prev;
  char *p, *q, line [81], compare[10];

  i = j = prev = 0;
  q = NULL;

  if (!(rfile = fopen (name, OPEN_READ_TEXT)))
  {
    printf (cant, name);
    return (2);
  }

  q = go_top;
  strcpy (compare, "@@TOP\n");

  while (1 == 1)
  {
    p = my_fgets (line, 80, rfile);

    if (strnicmp (p, compare, strlen(compare)))
    {
      *q = EOS;
      j  = EOF;
    }
    else
    {
      i = 0;
      do
      {
        prev = j;

        q[i] = j = fgetc(rfile);

        if (j == '\r')
          continue;
        i++;
      }
      while (j != EOF && !(j == '@' && prev == '\n') && i < 256);

      q[i-2] = '\n';
      q[i-1] = EOS;
    }

    if (j != '@' && j != EOF)
      do
      {
        prev = j;
        j = fgetc(rfile);
      }
      while (j != EOF && !(j == '@' && prev == '\n'));

    if (j == '@')
      ungetc (j, rfile);

    if (j == EOF && q == go_bottom)
      break;

    if (q == go_top)
    {
      q = go_bottom;
      strcpy (compare, "@@BOTTOM\n");
    }
  }
  fclose (rfile);

  return (0);
}

/*
*** output head or foot
***
***
 */

int top_bottom (FILE *wfile, char *top_bot, char *orgname, int part, int parts)
{
  int i;
  char __file[9], __ext[5];

  fnsplit (orgname, NULL, NULL, _file, _ext);
  strcpy (__file, _file);
  strcpy (__ext , _ext );
  strlwr (_file);
  strlwr (_ext );

  i = 0;
  while (top_bot[i] != EOS)
  {
    if (top_bot[i] == '%')
    {
      i++;
      if (!top_bot[i])
        break;

      switch (top_bot[i])
      {
        case 'o': fprintf (wfile, "%s%s", _file, _ext);
                  break;
        case 'O': fprintf (wfile, "%s%s", __file, __ext);
                  break;
        case 'n': fprintf (wfile, "%s.p%02x", _file, part);
                  break;
        case 'N': fprintf (wfile, "%s.P%02X", __file, part);
                  break;
        case 'p': fprintf (wfile, "%d", part);
                  break;
        case 'P': fprintf (wfile, "%02X", part);
                  break;
        case 'q': fprintf (wfile, "%d", parts);
                  break;
        case 'Q': fprintf (wfile, "%02X", parts);
                  break;
        case '%': fprintf (wfile, "%s", "%");
                  break;

        default : fprintf (wfile, "%%%c", top_bot[i]);
      }
      i++;
    }
    if (!top_bot[i])
      break;

    if (top_bot[i] == '\n')
      fprintf (wfile, "%s", delimit);
    else
      my_putc (top_bot[i], wfile);

    i++;
  }

  return (0);
}
