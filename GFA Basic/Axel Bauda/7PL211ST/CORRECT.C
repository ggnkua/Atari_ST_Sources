#include "7plus.h"
#include "globals.h"

/*
***
***
***
 */
int correct_meta (char *name, int itsacor)
{
  FILE     *rfile, *meta, *ifile;
  char     inpath[MAXFPATH], indexfile[MAXPATH], metafile[MAXPATH];
  char     newname[MAXPATH], orgname[13], filename[13];
  char     *p, line[81];
  int      i, j, corrpart, corrline, corrline2, splitsize, length;
  int      num;
  uint     crc, csequence;
  long     binbytes, c_line, offset, oldoffset;
  ulong    ftimestamp;

  *indexfile = EOS;
  ftimestamp = 0UL;
  splitsize = corrpart = corrline = corrline2 = num = j = 0;
  crc = csequence = 0U;
  binbytes = offset = 0L;
  oldoffset = -62L;
  rfile = ifile = meta = NULLFP;

  /* Isolate input-path and filename */
  fnsplit (name, _drive, _dir, _file, _ext);
  sprintf (inpath, "%s%s", _drive, _dir);
  build_DOS_name (_file);
  build_DOS_name (_ext);
  _file[8] = _ext[3] = EOS;
  strcpy (newname, name);

  printf ("\n-------------\nCorrecting...\n-------------\n\n");

  index->lines_left = 1;

  while (index->lines_left)
  {
    if (itsacor)
    {
      if (num)
      {
        if (stricmp( _ext, "cor") && num == 1)
          break;

        if (num == 256 || (j > 4))
          break;

        sprintf (newname, "%s%s%s.c%02x", _drive, _dir, _file, num);
        if (test_exist (newname))
        {
          j++;
          continue;
        }
        j = 0;
      }
      num++;

      if ((i = crc_file (newname, "7PLUS corr", " P00:\n", 1)) != 0)
      {
        if (i != 17)
          return (i);

        if (!force)
        {
          printf ("\n\007If you want to use this cor-file anyway, run 7PLUS again\n");
          printf ("with the '-F' option (force usage). Bear in mind, that this can\n");
          printf ("cause irreparable damage to the metafile! Use at own risk.\n");

          return(7);
        }
      }
    }
    else
     if (num)
       break;

    /* Open COR-file */
    if (!(rfile = fopen (newname, OPEN_READ_BINARY)))
    {
      printf (cant, newname);
      return (2);
    }

    while ((p = my_fgets (line, 80, rfile)) != NULL)
    {
      if (!strncmp (line, "7PLUS correction:", 17) && itsacor)
        break;
      if (!strncmp (line, " go_7+.", 7) && !itsacor)
        break;
    }
    if (!p)
    {
      printf ("\007\n'%s': invalid correction file. Break.\n", newname);
      fclose (rfile);
      continue;
    }

    if (itsacor)
    {
      /* Get info from COR-file */
      sscanf (line, "7PLUS correction: %12s %ld %s [%lX]",
                                    orgname, &binbytes, filename, &ftimestamp);
      splitsize = get_hex (filename);
    }
    else
    {
      /* Get info from 7PLUS header */
      if(sscanf (line+8, "%d %s %d %s %ld %s %s %s %s %s",
                  &corrpart, indexfile, indexfile, orgname, &binbytes,
                  indexfile, metafile, indexfile, indexfile, indexfile) == 10)
      {

        if (strlen (indexfile) == 5)
          if (!mcrc(line, 2))
            *orgname = EOS;

        splitsize = get_hex (metafile);
        strlwr (orgname);
      }
      else
       *orgname = EOS;

      if (!*orgname)
      {
        printf ("\007\n'%s': Header is corrupted. Break.\n", newname);
        fclose (rfile);
        break;
      }
      offset = ftell (rfile);
      fseek (rfile, -72L, SEEK_END);

      while ((p = my_fgets (line, 80, rfile)) != NULL)
        if (!strncmp (line, " stop_7+.", 9))
          break;

      ftimestamp = 0UL;

      if (p)
      {
        /* Get timespamp */
        if (strchr (line, '['))
        {
          if (!mcrc (line, 0))
            rebuild (line, 2);

          if (mcrc (line, 0))
            if (sscanf (line, " stop_7+. %s [%lX]",
                indexfile, &ftimestamp) != 2)
              ftimestamp = 0UL;
        }
      }

      fseek (rfile, offset, SEEK_SET);
      offset = 0L;

      num = 1;
    }

    if (num == 1)
    {
      /* Strip ext from filename */
      fnsplit (orgname, NULL, NULL, filename, NULL);
      strlwr (filename);

      sprintf (metafile , "%s.7mf", filename);

      #ifndef _CHSIZE_OK
       sprintf (indexfile, "%s.7ix", filename);

       /* Open index file */
       if (!(ifile = fopen (indexfile, OPEN_READ_BINARY)))
       {
         printf (cant, indexfile);
         fclose (rfile);
         return (2);
       }

       /* read index info into struct index */
       if (read_index (ifile, index))
       {
         printf ("\007Invalid index info.\n");
         fclose (rfile);
         return (7);
       }

       fclose (ifile);
      #endif

      /* Open meta file */
      if (!(meta = fopen (metafile, OPEN_RANDOM_BINARY)))
      {
        printf (cant, metafile);
        fclose (rfile);
        return (2);
      }

      #ifdef _CHSIZE_OK
       strcpy (indexfile, metafile);
       ifile = meta;

       /* read index info into struct index */
       if (read_index (ifile, index))
       {
         printf ("\007Invalid index info.\n");
         fclose (rfile);
         return (7);
       }
      #endif
    }
    if (stricmp (orgname, index->filename) ||
        binbytes && binbytes != index->length)
    {
      printf ("\007\nCorrection file '%s.%s' and metafile '%s' do not relate\n",
                                                       _file, _ext, metafile);
      printf (" to the same original file!\n");
      fclose (rfile);
      continue;
    }
    if ((ftimestamp && index->timestamp && (ftimestamp != index->timestamp)) &&
         !force)
    {
      printf ("\007WARNING! The timestamps in the metafile and the correction file\n");
      printf ("'%s.%s' differ!\n", _file, _ext);
      printf ("If you still want to go ahead with the correction, call 7PLUS again\n");
      printf ("with the addition of the '-f' option (force usage).\n");
      printf ("Bear in mind, that this can cause irreparable damage to the metafile!\n");
      printf ("Use at own risk.\n");
      return (18);
    }

    printf ("Processing '%s'. Missing lines left: %ld      \r",
                                                   newname, index->lines_left);
    fflush (stdout);

    if (!splitsize)
      splitsize = index->splitsize;

    while (1==1)
    {
      if (!(p = my_fgets (line, 80, rfile)))
        break;

      if (itsacor)
      {
        if (p[0] == ' ' && p[1] == 'P')
        {
          if (!(corrpart = get_hex (p+2)))
            break;
          my_fgets (p, 80, rfile);
        }
        corrline = get_hex (p+2);
        my_fgets (p, 80, rfile);
      }
      else
        crc_n_lnum (&crc, &corrline, p);

      c_line = ((long) (corrpart-1) * splitsize) + corrline;

      /* Check, if that line is needed */
      if (!(index->lines_ok[(int)(c_line>>5)] & (1UL <<(c_line&31L))))
        continue;

      /* Get crc from code line */
      crc_n_lnum (&crc, &corrline2, p);

      /* Calculate CRC */
      csequence = 0;
      for (i=0; i<64; i++)
        csequence = crctab[csequence>>8] ^ (((csequence&255)<<8) | (byte)p[i]);
      csequence &= 0x3fff; /* strip calculated CRC to 14 bits */

      if (csequence != crc)
        if (!rebuild (p, 0))
          /* Incorrect CRC. Ignore line. */
          continue;
        else
          crc_n_lnum (&crc, &corrline2, p);

      /* Is it really the right line? */
      if (corrline2 != corrline)
        continue;

      /* Calculate offset to metafile and position the read pointer there */
      offset = (long) c_line * 62UL;
      if (offset != (oldoffset + 62UL) || !offset)
        fseek (meta, offset, SEEK_SET);
      oldoffset = offset;

      /* Calculate number of valid bytes in the line */
      length = 62;
      if (c_line == ((index->length +61) /62)-1)
      {
        length = (int) index->length % 62;
        if (!length)
          length = 62;
      }
      /* Decode & insert the line into the metafile */
      decode_n_write (meta, p, length);

      /* Mark line as present */
      index->lines_ok[(int)(c_line>>5)] &=
                                  (0xffffffffUL - (1UL <<(c_line&31L)));
      index->lines_left--;
      printf ("Processing '%s'. Missing lines left: %ld      \r",
                                                  newname, index->lines_left);
      fflush (stdout);

    }
    fclose (rfile);
  }
  printf ("\n");

  if (meta)
  {
    #ifdef _CHSIZE_OK
     if (!index->lines_left)
     {
       fseek (meta, 0L, SEEK_SET);
       chsize (fileno(meta), index->length);
     }
    #endif
    fclose (meta);
  }

#if (__MSDOS__ || __TOS__)
  p = index->filename;
#else
  p = index->full_name;
#endif

  if (index->lines_left)
  {
    if (autokill)
      kill_em (_file, inpath, "cor", "c", NULL, NULL, NULL);

    w_index_err (index, 0);
    printf ("\nCorrection of %s not successful.\n", p);

    return (16);
  }

  test_file (NULLFP, p, 1, MAXFNAME-1);
  replace (p, metafile, index->timestamp);
  #ifndef _CHSIZE_OK
   unlink (indexfile);
  #endif

  if (autokill)
    kill_em (_file, inpath, "err", "e", "cor", "c", NULL);

  printf ("\nCorrection successful! '%s', %ld bytes.\n", p, index->length);

  return (0);
}
