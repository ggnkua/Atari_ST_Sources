#include "7plus.h"
#include "globals.h"

#ifdef __unix__
 #ifdef __M_XENIX__
  struct utimbuf {
   time_t actime;
   time_t modtime;
  };
  extern time_t mktime (struct tm *utm);
 #else
  #include <utime.h>
 #endif
#endif

static char no[] = NO, yes[] = YES, always[] = ALWAYS;

/*
*** get a line from file. don't care about type of line separator.
***
***
 */

char *my_fgets (char *string, register n, FILE *rein)
{
  register in, i;

  if (feof (rein))
    return (NULL);

  i = 0;
  while ((in = fgetc (rein)) != EOF)
  {
    if (in == 0x0d)
    {
      if ((in = fgetc (rein)) != 0x0a)
        if (in != EOF)
          ungetc (in, rein);
      in = 0x0a;
    }
    string[i++] = (char) in;
    if (i == n || in == 0x0a)
      break;
  }
  string[i] = EOS;
  return (string);
} 

/*
***
*** Write a byte to file.
***
 */

int my_putc (int outchar, FILE *out)
{
  register x;

  if ((x = putc ((char) outchar, out)) == EOF)
  {
    printf ("\007\nWrite error! Can't continue.\n");
    exit (1);
  }
  return (x);
}

/*
*** Get crc and line number from code line.
***
***
 */

void crc_n_lnum (uint *crc, int *linenumber, char *line)
{
  register ulong cs;

  cs = 0xb640L * decode[(byte)line[66]] +
       0xd8L   * decode[(byte)line[65]] +
                 decode[(byte)line[64]];

  *linenumber = (int) (cs >> 14);   /* upper 9 bits are the line number */
  *crc = (uint) (cs & 0x3fffL);     /* lower 14 bits are the CRC */
}

/*
*** Get crc2 from code line.
***
***
 */

void crc2 (uint *crc, char *line)
{

  *crc = 0xd8 * decode[(byte)line[68]] +
                decode[(byte)line[67]];
}

/*
*** Whip up 2nd CRC
***
***
 */

void add_crc2 (char *line)
{
  register uint crc;
  register int i;

  /* Whip up 2nd CRC */
  crc = 0;
  for (i=66;i>-1;i--)
    crc = crctab[crc>>8] ^ (((crc&255)<<8) | (byte) line[i]);
  crc &= 0x7fff;

  i = 67;
  line[i++] = code[crc % 0xd8];
  line[i++] = code[crc / 0xd8];
  line[i] = EOS;
}

/*
*** mini-crc for header. safe enough...
***
***
 */

int mcrc (char *line, int flag)
{
  register int i, j;
  register uint crc;
  char test[3], *p;

  sprintf (test, "\xb0\xb1");

  if ((p = strstr (line, test)) == NULL)
    return (0);

  j = (int) (p - line) + 4;

  for (i=crc=0; i<j; i++)
    crc = crctab[crc>>8] ^ (((crc&255)<<8) | (byte)line[i]);
  crc %= 216;
  if (!flag)
  {
    if (crc == (uint) decode[(byte)line[j]])
      return (1);
    else
      return (0);
  }
  else
    line[j] = code[(byte)crc];

  return (crc);
}

/*
*** read info from indexfile
***
***
 */

int read_index (FILE *ifile, struct m_index *index)
{
  int j;
  ulong i, begin, end;

  #ifdef _CHSIZE_OK
   fseek (ifile, -4L, SEEK_END);
   fseek (ifile, read_ulong (ifile), SEEK_SET);
  #endif

  /* clear index */
  for (j = 0;j < 4080; j++)
    index->lines_ok[j] = 0UL;

  my_fgets (index->full_name, 12, ifile);
  if (strcmp(index->full_name, "7PLUS-index\x0a"))
  {
    printf ("\007No index info found.\n");
    return (1);
  }
  my_fgets (index->filename, 13, ifile);
  index->filename[(int)strlen(index->filename)-1] = EOS;
  my_fgets (index->full_name, 257, ifile);
  index->full_name[(int)strlen(index->full_name)-1] = EOS;
  index->timestamp = read_ulong (ifile);
  index->splitsize = read_uint  (ifile);
  index->lines_left= (long) read_ulong (ifile);

  /* convert defect list into bitvektor */
  while (1==1)
  {
    if ((begin = read_ulong (ifile)) == 0xffffffffUL)
      break;
    end = read_ulong (ifile);

    if ((end>>5) > (begin>>5))
      for (i = begin;i < ((begin |31UL) + 1UL); i++)
        index->lines_ok[(int)i>>5] |= (1UL <<(i&31UL));
    else
    {
      for (i = begin;i < end; i++)
        index->lines_ok[(int)i>>5] |= (1UL <<(i&31UL));
      continue;
    }

    for (i = (begin>>5) +1; i < (end>>5); i++)
      index->lines_ok[(int)i] = 0xffffffffUL;

    if (end&31)
      for (i = end &0xffffffe0UL; i < end; i++)
        index->lines_ok[(int)i>>5] |= (1UL <<(i&31UL));
  }
  index->length = read_ulong (ifile);

  #ifdef _CHSIZE_OK
   fseek (ifile, 0UL, SEEK_SET);
  #endif

  return (0);
}

/*
*** write info to indexfile
***
***
 */

int write_index (FILE *ifile, struct m_index *index, int flag)
{
  int j, part, prevpart, lines;
  ulong i, begin, end;

  part = prevpart = lines = 0;
  begin = end = 0UL;

  if (!flag)
  {
    #ifdef _CHSIZE_OK
     fseek (ifile, index->length, SEEK_SET);
    #endif

    fprintf (ifile, "7PLUS-index\n");
    fprintf (ifile, "%s\n", index->filename);
    fprintf (ifile, "%s\n", index->full_name);
    write_ulong (ifile, index->timestamp);
    write_uint  (ifile, index->splitsize);
    write_ulong (ifile, (ulong) index->lines_left);
  }
  /* convert bitvektor into defect list */
  i = 0UL;
  j = 0;
  while (1==1)
  {
    while (j < 4080 && !(index->lines_ok[j] &(1UL <<(i & 31UL))))
    {
      if (!(i&31UL) && index->lines_ok[j] == 0UL)
      {
        j++;
        i = (ulong) j<<5;
      }
      else
      {
        i++;
        j = (int) i>>5;
      }
    }

    if (j == 4080)
      break;

    begin = i;

    do
    {
      if (!(i&31UL) && index->lines_ok[j] == 0xffffffffUL)
      {
        j++;
        i = (ulong) j<<5;
      }
      else
      {
        i++;
        j = (int) i>>5;
      }
    }
    while (j < 4080 && (index->lines_ok[j] &(1UL <<(i & 31UL))));

    end = i;

    if (!flag)
    {
      write_ulong (ifile, begin);
      write_ulong (ifile, end);
    }
    else
    {
      for (i = begin; i < end; i++)
      {
        part = (int) i / index->splitsize +1;
        if (part != prevpart)
        {
          if (prevpart)
          {
            if (!(lines % 18) && lines)
              fprintf (ifile, delimit);
            lines = 0;
            fprintf (ifile, "FFF%s", delimit);
          }
          prevpart = part;
          fprintf (ifile, "%02X%s", part, delimit);
        }

        lines++; /* Number of missing or corrupted lines in this part. */
        fprintf (ifile, "%03X", (uint)(i % index->splitsize));
        if (!(lines % 18) && lines)
        {
          fprintf (ifile, delimit);
          lines = 0;
        }
        else
          fprintf (ifile, " ");
      }
    }
  }

  if (!flag)
  {
    write_ulong (ifile, 0xffffffffUL);
    write_ulong (ifile, index->length);
    #ifdef _CHSIZE_OK
     chsize (fileno (ifile), ftell (ifile));
    #endif
  }
  else
  {
    if (!(lines % 18) && lines)
      fprintf (ifile, delimit);
    fprintf (ifile, "FFF%s", delimit);
  }
  return (0);
}

/*
*** Reading/writing unsigned long(32bit)/int(16)
***
***
 */

ulong read_ulong (FILE *in)
{
  return ((ulong)fgetc (in)       +
         ((ulong)fgetc (in) <<8 ) +
         ((ulong)fgetc (in) <<16) +
         ((ulong)fgetc (in) <<24));
}

uint read_uint (FILE *in)
{
  return ((uint)fgetc (in)       +
         ((uint)fgetc (in) <<8 ));
}

void write_ulong (FILE *out, ulong val)
{
  my_putc ((int) (val     &0xffUL), out);
  my_putc ((int)((val>>8 )&0xffUL), out);
  my_putc ((int)((val>>16)&0xffUL), out);
  my_putc ((int)((val>>24)&0xffUL), out);
}

void write_uint (FILE *out, uint val)
{
  my_putc ((int) (val    &0xffU), out);
  my_putc ((int)((val>>8)&0xffU), out);
}

/*
*** read a file, search for s1, calculate CRC until s2 is found.
*** flag == 1: compare calculated an read CRC.
*** flag == 0: insert CRC into file.
 */

int crc_file (char *file, char *s1, char *s2, int flag)
{
  char line[81], *p;
  uint crc, cs;
  int i, j, k;
  FILE *in;

  crc = cs = 0;
  p = NULLCP;

  if (!(in = fopen (file, OPEN_RANDOM_BINARY)))
  {
    printf (cant, file);
    return (2);
  }

  i = (int) strlen (s1);
  k = (int) strlen (s2);

  j = 1;

  do
  {
    if (my_fgets (line, 80, in) == NULL)
      break;

    j = strncmp (line, s1, i);
  }
  while (j);

  if (j)
    p = s1;
  else
  {
    p = s2;
    do
    {
      for (i=0;i!=(int)strlen(line);i++)
        crc = crctab[crc>>8] ^ (((crc&255)<<8) | (byte)line[i]);

      j = strncmp (line, s2, k);

      if (!j)
        continue;

      if (my_fgets (line, 80, in) == NULL)
        break;
    }
    while (j);
  }

  if (j)
  {
    printf ("\n\007Can't calculate CRC\n");
    printf ("String '%s' not found in '%s'.\nBreak.\n", p, file);
    return (7);
  }

  /* evaluate CRC */
  if (flag)
  {
    my_fgets (line, 80, in);
    fclose (in);
    if (!line || strncmp ("CRC ", line, 4))
    {
      printf ("\n'%s': no CRC found.\n(File may be corrupted or from version \
earlier than 7PLUS v1.5)\n", file);
      return (17);
    }
    cs = get_hex (line+4);
    if (cs == crc)
      return (0);

    printf ("\007\n'%s' is corrupted. Break.\n", file);
    return (7);
  }

  /* insert CRC into file */
  fseek (in, 0UL, SEEK_CUR);
  fprintf (in, "CRC %04X", crc);
  fclose (in);

  return (0);
}

/*
*** Copy a file.
***
***
 */

int copy_file (char *to, char *from, ulong timestamp)
{
  FILE *_from, *_to;
  int _char, stat;

  stat = 0;

  _from = fopen (from, OPEN_READ_BINARY);
  _to   = fopen (to,   OPEN_WRITE_BINARY);

  while ((_char = getc (_from)) != EOF)
    if ((stat = putc (_char, _to)) == EOF)
      break;

  fclose (_from);

 #if defined (__MSDOS__) || (__TOS__)
  if (timestamp)
    set_filetime (_to, timestamp);

  fclose (_to);
 #else
  fclose (_to);

  if (timestamp)
    set_filetime (to, timestamp);
 #endif

  if (stat == EOF)
  {
    printf ("\007\nFatal error. Can't write '%s'! Break.\n", to);
    exit (1);
  }
  return (0);
}

/*
*** Replace one file with another
***
***
 */

void replace (char *old, char *new, ulong timestamp)
{
  unlink (old);

  if (rename (new, old))
  {
    copy_file (old, new, timestamp);
    unlink (new);
  }
  else
  {
    if (timestamp)
    {
     #if defined (__MSDOS__) || (__TOS__)
      FILE *_file;

      _file = fopen (old, OPEN_APPEND_BINARY);
      set_filetime (_file, timestamp);
      fclose (_file);
     #else
      set_filetime (old, timestamp);
     #endif
    }
  }
}

/*
*** Kill all files that aren't needed any more
***
***
 */

void kill_em (char *name, char *inpath, char *one, char *two,
              char *three, char *four, char *five)
{
  char *p, newname[MAXPATH];
  int i, j, k, len;

  k = 0;

  for (i = 0; i < 5; i++)
  {
    if (!i)
      printf ("\n");

    switch (i)
    {
      case 0:  p = one;
               break;
      case 1:  p = two;
               break;
      case 2:  p = three;
               break;
      case 3:  p = four;
               break;
      case 4:  p = five;

      default: p = NULLCP;
    }
    if (!p)
     break;

    len = strlen(p);

    for (j = 1; j <256; j++)
    {
      if (len == 3)
        sprintf (newname, "%s%s.%s", inpath, name, p);
      else
        sprintf (newname, "%s%s.%s%02x", inpath, name, p, j);

      if (unlink (newname))
        break;

      k++;

      printf ("Deleting: %s\r", newname);
      fflush (stdout);

      if (len == 3)
        break;
    }
  }
  if (k)
    printf ("\n");
}

/*
***
***
***
 */

void kill_dest (FILE *in, FILE *out, char *name)
{
    if (out)
      fclose (out);
    if (in)
      fclose (in);
    if (*name)
      unlink (name);
}

/*
***
***  test if a file exists at all
***
 */

int test_exist (char *filename)
{
  FILE *in = NULLFP;

  if ((in = fopen (filename, OPEN_READ_TEXT)) != NULLFP)
  {
    fclose (in);
    return (0);
  }
  return (1);
}


/*
***  test if outputfile already exists. prompt for overwrite or
***  new name.
***
 */

int test_file (FILE *in, char *destnam, int flag, int namsize)
{
   FILE *out;
   int  i, ret;

   ret = 0;

   if (noquery)
     return (ret);

   /* Loop as long as file can be opened. */
   while ((out = fopen (destnam, OPEN_READ_BINARY)) != NULLFP)
   {
     ret = 1;
     printf ("\007\nOutputfile '%s' already exists, overwrite? [y/n/a] ", destnam);
     do
     {
       i = toupper (getch());

       if (i == 'N')
       {
         if (flag)
         {
           printf ("%s\n\nEnter new name (max %d chars)\n", no, namsize);
           printf ("or simply press ENTER to break : ");
           if (namsize == 12)
             strlwr (destnam);
           i = getc(stdin);
           if(i != '\n')
           {
             ungetc(i, stdin);
             scanf ("%s", destnam);
           }
           else
             destnam[0] = EOS;
           destnam[namsize] = EOS;
         }
         else
           *destnam = EOS;
         if (!strlen (destnam))
         {
           if (!flag)
             printf ("%s\n", no);
           printf ("Break.\n");
           if (in)
             fclose (in);
           exit (10);
         }
         i = 0xff; /* indicate, that new name has been specified */
       }
     }
     while (i != 'Y' && i != 'A' && i != 0xff);

     if (i != 0xff)
     {
       if (i == 'A')
       {
         printf ("%s\n", always);
         noquery = 1;
       }
       else
         printf ("%s\n", yes);
     }
     printf ("\n");

     fclose (out);

     if (i != 0xff)
       break;
   }

   return (ret);
}


/*
*** initialize decoding table
***
***
 */

void init_decodetab (void)
{
  register i;
  register byte j;

  for (i = 0; i < 256; i++)
    decode[i] = 255;

  j = 0;
  for (i = 0x21; i < 0x2a; i++)
    decode[i] = j++;

  for (i = 0x2b; i < 0x7f; i++)
    decode[i] = j++;

  for (i = 0x80; i < 0x91; i++)
    decode[i] = j++;

  decode[0x92] = j++;

  for (i = 0x94; i < 0xfd; i++)
    decode[i] = j++;
}

/*
*** initialize encoding table
***
***
 */

void init_codetab (void)
{
  register byte i, j;

  j = 0;

  for (i = 0x21; i < 0x2a; i++, j++)
    code[j] = i;

  for (i = 0x2b; i < 0x7f; i++, j++)
    code[j] = i;

  for (i = 0x80; i < 0x91; i++, j++)
    code[j] = i;

  code[j++] = 146;

  for (i = 0x94; i < 0xfd; i++, j++)
    code[j] = i;
}

/*
*** Tnx to DC4OX.
***
*** calculate CRC-table
***
 */

void init_crctab (void)
{
  uint m, n, r, mask;

  static uint bitrmdrs[] = { 0x9188,0x48C4,0x2462,0x1231,
                             0x8108,0x4084,0x2042,0x1021 };

  for (n = 0; n < 256; ++n)
  {
    for (mask = 0x0080, r = 0, m = 0; m < 8; ++m, mask >>= 1)
      if (n & mask)
        r = bitrmdrs[m] ^ r;
    crctab[n] = r;
  }
}

/*
*** Create a MSDOS/ATARI compatible filename.
***
***
 */

void build_DOS_name (char *name)
{
  char tmp[MAXFNAME];
  register i, j;

  i = j = 0;

  strcpy (tmp, name);
  strlwr (tmp);

  if (*tmp)
  {
    do
    {
      tmp[i] &= 127;
      if (strchr (" <>=,;:*?&[]()/.\\\"~+@", tmp[i]) == NULL)
        name[j++] = tmp[i];
    }
    while (tmp[++i]);

    name[j] = EOS;
  }
}

#if defined (__MSDOS__) || (__TOS__)
 /*
 *** Get file's timestamp and package it into a 32-bit word (MS_DOS-format)
 ***
 ***
  */
 ulong get_filetime (FILE *_file)
 {
  ulong    ftimestamp;

  if (getftime (fileno(_file), (struct ftime *)&ftimestamp) == EOF)
    printf ("\007\nCan't get file's timestamp!\n");

 #ifdef __TOS__
  ftimestamp = swapl(ftimestamp);
 #endif

  return (ftimestamp);
 }

 /*
 *** Set file's timestamp
 ***
 ***
  */
 void set_filetime (FILE *_file, ulong ftimestamp)
 {
 #ifdef __TOS__
  ftimestamp = swapl(ftimestamp);
 #endif

  if (setftime (fileno(_file), (struct ftime *)&ftimestamp) == EOF)
    printf ("\007\nCan't set file's timestamp!");
 }
#else
 #ifndef _HAVE_GMTIME
  /*
  * mktime function from GNU C library V1.03; modified:
  * - expanded DEFUN and CONST macros from ansidecl.h
  * - inserted __isleap macro from time.h
  * - inserted __mon_lengths array and __offtime function from offtime.c
  * - inserted gmtime function from gmtime.c
  * - commented out call of localtime function
  * Be aware of the following copyright message for mktime !!!
  */

  /* Copyright (C) 1991 Free Software Foundation, Inc.
  This file is part of the GNU C Library.

  The GNU C Library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Library General Public License as
  published by the Free Software Foundation; either version 2 of the
  License, or (at your option) any later version.

  The GNU C Library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with the GNU C Library; see the file COPYING.LIB.  If
  not, write to the Free Software Foundation, Inc., 675 Mass Ave,
  Cambridge, MA 02139, USA.  */


  /* How many days are in each month.  */
  const unsigned short int __mon_lengths[2][12] =
    {
      /* Normal years.  */
      { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 },
      /* Leap years.  */
      { 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    };

  #define  __isleap(year)  \
    ((year) % 4 == 0 && ((year) % 100 != 0 || (year) % 400 == 0))

  #define  invalid()  return (time_t) -1


  #define  SECS_PER_HOUR  (60 * 60)
  #define  SECS_PER_DAY  (SECS_PER_HOUR * 24)

  /* Returns the `struct tm' representation of *T,
     offset OFFSET seconds east of UCT.  */
  struct tm *
  __offtime (const time_t *t, long int offset)
  {
    static struct tm tbuf;
    register long int days, rem;
    register int y;
    register const unsigned short int *ip;

    if (t == NULL)
      return NULL;

    days = *t / SECS_PER_DAY;
    rem = *t % SECS_PER_DAY;
    rem += offset;
    while (rem < 0)
    {
      rem += SECS_PER_DAY;
      --days;
    }
    while (rem >= SECS_PER_DAY)
    {
      rem -= SECS_PER_DAY;
      ++days;
    }
    tbuf.tm_hour = rem / SECS_PER_HOUR;
    rem %= SECS_PER_HOUR;
    tbuf.tm_min = rem / 60;
    tbuf.tm_sec = rem % 60;
    /* January 1, 1970 was a Thursday.  */
    tbuf.tm_wday = (4 + days) % 7;
    if (tbuf.tm_wday < 0)
      tbuf.tm_wday += 7;
    y = 1970;
    while (days >= (rem = __isleap(y) ? 366 : 365))
    {
      ++y;
      days -= rem;
    }
    while (days < 0)
    {
      --y;
      days += __isleap(y) ? 366 : 365;
    }
    tbuf.tm_year = y - 1900;
    tbuf.tm_yday = days;
    ip = __mon_lengths[__isleap(y)];
    for (y = 0; days >= ip[y]; ++y)
      days -= ip[y];
    tbuf.tm_mon = y;
    tbuf.tm_mday = days + 1;
    tbuf.tm_isdst = -1;

    return &tbuf;
  }


  /* Return the `struct tm' representation of *T in UTC.  */
  struct tm *
  gmtime (const time_t *t)
  {
    return __offtime(t, 0L);
  }
 #endif /* ifndef _HAVE_GMTIME */

 #ifndef _HAVE_MKTIME

  /* Return the `time_t' representation of TP and normalizes TP.
     Return (time_t) -1 if TP is not representable as a `time_t'.
     Note that 31 Dec 1969 23:59:59 is not representable
     because it is represented as (time_t) -1.  */
  time_t mktime (register struct tm *tp)
  {
    static struct tm min, max;
    static char init = 0;

    register time_t result;
    register time_t t;
    register int i;
    register const unsigned short *l;
    register struct tm *new;
    time_t end;

    if (tp == NULL)
    {
      errno = EINVAL;
      invalid();
    }

    if (!init)
    {
      init = 1;
      end = (time_t) LONG_MIN;
      new = gmtime(&end);
      if (new != NULL)
        min = *new;
      else
        min.tm_sec = min.tm_min = min.tm_hour =
      min.tm_mday = min.tm_mon = min.tm_year = INT_MIN;

      end = (time_t) LONG_MAX;
      new = gmtime(&end);
      if (new != NULL)
        max = *new;
      else
        max.tm_sec = max.tm_min = max.tm_hour =
      max.tm_mday = max.tm_mon = max.tm_year = INT_MAX;
    }

    /* Make all the elements of TP that we pay attention to
       be within the ranges of reasonable values for those things.  */
    #define  normalize(elt, min, max, nextelt)\
    while (tp->elt < min)                     \
    {                                         \
      --tp->nextelt;                          \
      tp->elt += max + 1;                     \
    }                                         \
    while (tp->elt > max)                     \
    {                                         \
      ++tp->nextelt;                          \
      tp->elt -= max + 1;                     \
    }

    normalize (tm_sec, 0, 59, tm_min);
    normalize (tm_min, 0, 59, tm_hour);
    normalize (tm_hour, 0, 24, tm_mday);

    /* Normalize the month first so we can use
       it to figure the range for the day.  */
    normalize (tm_mon, 0, 11, tm_year);
    normalize (tm_mday, 1, __mon_lengths[__isleap (tp->tm_year)][tp->tm_mon],
      tm_mon);

    /* Normalize the month again, since normalizing
       the day may have pushed it out of range.  */
    normalize (tm_mon, 0, 11, tm_year);

    /* Normalize the day again, because normalizing
       the month may have changed the range.  */
    normalize (tm_mday, 1, __mon_lengths[__isleap (tp->tm_year)][tp->tm_mon],
      tm_mon);

   /* Check for out-of-range values.  */
   #define  lowhigh(field, minmax, cmp)  (tp->field cmp minmax.field)
   #define  low(field)                   lowhigh(field, min, <)
   #define  high(field)                  lowhigh(field, max, >)
   #define  oor(field)                   (low(field) || high(field))
   #define  lowbound(field)              (tp->field == min.field)
   #define  highbound(field)             (tp->field == max.field)
   if (oor(tm_year))
     invalid();
   else
     if (lowbound(tm_year))
     {
       if (low(tm_mon))
         invalid();
       else
         if (lowbound(tm_mon))
         {
           if (low(tm_mday))
             invalid();
           else
             if (lowbound(tm_mday))
             {
               if (low(tm_hour))
                 invalid();
               else
                 if (lowbound(tm_hour))
                 {
                   if (low(tm_min))
                     invalid();
                   else
                     if (lowbound(tm_min))
                     {
                       if (low(tm_sec))
                       invalid();
                     }
                 }
             }
         }
     }
     else
       if (highbound(tm_year))
       {
         if (high(tm_mon))
           invalid();
         else
           if (highbound(tm_mon))
           {
             if (high(tm_mday))
               invalid();
             else
               if (highbound(tm_mday))
               {
                 if (high(tm_hour))
                   invalid();
                 else
                   if (highbound(tm_hour))
                   {
                     if (high(tm_min))
                       invalid();
                     else
                       if (highbound(tm_min))
                       {
                         if (high(tm_sec))
                         invalid();
                       }
                   }
               }
           }
       }
    t = 0;
    for (i = 1970; i > 1900 + tp->tm_year; --i)
      t -= __isleap(i) ? 366 : 365;
    for (i = 1970; i < 1900 + tp->tm_year; ++i)
      t += __isleap(i) ? 366 : 365;
    l = __mon_lengths[__isleap(1900 + tp->tm_year)];
    for (i = 0; i < tp->tm_mon; ++i)
      t += l[i];
    t += tp->tm_mday - 1;
    result = ((t * 60 * 60 * 24) +
             (tp->tm_hour * 60 * 60) +
             (tp->tm_min * 60) +
              tp->tm_sec);

    end = result;
   #if 0
    if (tp->tm_isdst < 0)
      new = localtime(&end);
    else
   #endif
      new = gmtime(&end);
    if (new == NULL)
      invalid();
    new->tm_isdst = tp->tm_isdst;
    *tp = *new;

    return result;
  }
 #endif /* ifndef _HAVE_MKTIME */

 #ifndef _FTIMEDEFINED
  /*
   * these functions have to convert a MS/DOS time to a UNIX time
   * and vice versa.
   * here comes the MS/DOS time structure
   */
  struct ftime
  {
    unsigned  ft_tsec  : 5;   /* 0..59 /2 (!) */
    unsigned  ft_min   : 6;   /* 0..59 */
    unsigned  ft_hour  : 5;   /* 0..23 */
    unsigned  ft_day   : 5;   /* 1..31 */
    unsigned  ft_month : 4;   /* 1..12 */
    unsigned  ft_year  : 7; /* Year minus 1980 */
  };
 #endif

 /*
  * Get file's timestamp and package it into a 32-bit word (MS_DOS-format).
  * This function should work on any system :-)
  */
 ulong get_filetime (char *filename)
 {
   struct ftime fti;
   ulong *retval = (ulong *) &fti;
   struct tm *utm;
   struct stat fst;

   *retval = 0UL;

   /* get file status */
   if (stat (filename, &fst) == 0)
   {
      /* get time of last modification and convert it to MS/DOS time */
     utm = gmtime (&fst.st_mtime);

     if (utm)
     {
       fti.ft_tsec  = utm->tm_sec / 2;
       fti.ft_min   = utm->tm_min;
       fti.ft_hour  = utm->tm_hour;
       fti.ft_day   = utm->tm_mday;
       fti.ft_month = utm->tm_mon + 1;
       fti.ft_year  = utm->tm_year - 80;
       return (*retval);
     }
   }

   /* error exit */
   printf ("\007\nCan't get file's timestamp!\n");
   return (*retval);
 }
 #ifdef __unix__
  /*
   * Set file's timestamp
   * This function only works on UNIX-systems
   */
  void set_filetime (char *filename, ulong ftimestamp)
  {
    time_t atime;
    struct utimbuf utim;
    struct ftime *fti;
    struct tm utm;

    /* convert MS/DOS ftimestamp to UNIX atime */
    fti = (struct ftime *) &ftimestamp;
    utm.tm_sec   = fti->ft_tsec * 2;
    utm.tm_min   = fti->ft_min;
    utm.tm_hour  = fti->ft_hour;
    utm.tm_mday  = fti->ft_day;
    utm.tm_mon   = fti->ft_month - 1;
    utm.tm_year  = fti->ft_year + 80;
    utm.tm_wday  = utm.tm_yday  =  utm.tm_isdst = 0;
    atime = mktime (&utm);

    if (atime != -1)
    {
      /* set access time and modification time */
      utim.actime = atime;
      utim.modtime = atime;
      if (utime (filename, &utim) >= 0)
        return;
    }

    /* error exit */
    printf ("\007\nCan't set file's timestamp!");
    return;
  }
 #else /* not UNIX */
  /*
   * Set file's timestamp
   *
   */
  void set_filetime (char *filename, ulong ftimestamp)
  {
    /* error exit */
    printf ("\007\nset_filetime not (yet) implemented on this system!");
    return;
  }
 #endif /* __unix__ */
#endif /* __MSDOS__ or __TOS__ */


/*
*** get_hex: some compilers have real big trouble when reading hex values from
***          a file with fscanf() that have leading zeros! e.g. 00A will be
***          read as two separate values (0 and A)! grr!!
***          get_hex skips all leading zeros to eliminate the problem.
***
 */

uint get_hex (char *hex)
{
  register i = 0;
  uint   ret = 0;

  while (hex[i] == '0')
    i++;
  sscanf(hex+i, "%x", &ret);
  return (ret);
}


#ifdef _FNSPLIT
/*
***       filenamesplit
***       (by DL1MEN, taken from SP-ST, modified for portability)
***
***       split filename up into drive, path, name and extension.
***
 */

void fnsplit(char *pth, char *dr, char *pa, char *fn, char *ft)
{
  char drv[MAXDRIVE], pat[MAXDIR], fna[MAXFILE], fty[MAXEXT], tmp[MAXPATH];
  char *p;

  strcpy(tmp,pth);

  if ((p = strchr(tmp,':')) != NULL)
  {
    *p++ = EOS;
    strcpy(drv,tmp);
  }
  else
  {
    p = tmp;
    drv[0] = EOS;
  }
  if ((pth = strrchr(p, PATHCHAR)) != NULL)
  {
    *pth++ = EOS;
    strcpy(pat,p);
  }
  else
  {
    pth = p;
    pat[0] = EOS;
  }
  if ((p = strchr(pth,'.')) != NULL)
  {
    strcpy(fty,p);
    fty[MAXEXT-1] = EOS;
    *p = EOS;
  }
  else
    fty[0] = EOS;

  strcpy(fna,pth);
  fna[MAXFILE-1] = EOS;

  if (dr)
  {
    strcpy(dr,drv);
    if (drv[0])
      strcat(dr,":");
  }
  if (pa)
  {
    strcpy(pa,pat);
    if (pat[0])
      strcat(pa, PATHSEP);
  }
  if (fn)
    strcpy(fn,fna);
  if (ft)
   strcpy(ft,fty);
}
#endif /** _FNSPLIT **/

#ifdef _ICMP
/* The following functions are unfortunately not avialable on all compilers */

/*
*** strupr - convert string to upper case.
***
***
 */

char *strupr (char *string)
{
  char *strcnvt (char *string, int flag);

  return (strcnvt (string, 1));
}

/*
*** strlwr - convert string to lower case.
***
***
 */

char *strlwr (char *string)
{
  char *strcnvt (char *string, int flag);

  return (strcnvt (string, 0));
}

/*
*** strcnvt - convert string to upper (flag == 1) or lower (flag == 0) case.
***
***
 */

char *strcnvt (char *string, int flag)
{
  register i = 0;

  while (string[i])
  {  
    string[i] = (flag)?toupper (string[i]):tolower (string[i]);
    i++;
  }

  return (string);
}

/*
*** stricmp - same as strcmp(), but ignores case.
*** s1 and s2 are not modified.
***
 */

int stricmp (const char *s1, const char *s2)
{
  return (strnicmp (s1, s2, (size_t) 80));
}

/*
*** strnicmp - same as strncmp(), but ignores case.
*** s1 and s2 are not modified.
***
 */

int strnicmp (const char *s1, const char *s2, size_t n)
{
  char _s1[81], _s2[81];

  strncpy (_s1, s1, 80);
  strncpy (_s2, s2, 80);
  strupr (_s1);
  strupr (_s2);

  return (strncmp (_s1, _s2, n));
}
#endif /** _ICMP **/
