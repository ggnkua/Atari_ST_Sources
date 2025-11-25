#include "7plus.h" 
#include "globals.h"

int rebuild (char *line, int flag)
{
  char buf[100], *p;
  uint cs1, cs2, _cs1, _cs2, xcrc;
  int oldcode, c_line, cflag, len, sw, i, j, k, end, end2;

  p = buf;
  sw = cflag = oldcode = 0;
  _cs1 = _cs2 = xcrc = 0;

  len = (int) strlen (line);

  if (flag)
  {
    oldcode = code[215];
    code[215] = 32;
  }

  end2 = 216;
  end = -1;

  if (len == 69)
    sw  = 1;

  if (len == 70)
    sw  = 2;

  if (len == 71)
  {
    end = -2;
    end2 = 1;
    sw  = 4;
  }
  if (!sw)
    return (0);

  /* Try each character in line */
  for (j=66;j>end;j--)
  {
    fflush (stdout);
    if (sw == 1)
    {
      if (j)
        strncpy (p, line, j);
      strncpy (p+j+1, line+j, 71-j);
      p[71] = EOS;
    }
    if (sw == 2)
      strcpy (buf, line);

    if (sw == 4)
    {
      strcpy (p, line);
      strncpy (p+j+1, line+j+2, 70-j);
      p[71] = EOS;
    }

    if (!cflag)
    {
      crc2 (&_cs1, p);
      cflag++;
    }

    if (j<66)
      xcrc = crctab[xcrc>>8] ^ (((xcrc&255U)<<8) | (byte)p[j+1]);

    for (k=0;k<end2;k++)
    {
      if (sw & 3)
        p[j] = code[k];

      if (sw == 4)
      {
        cs1 = 0;
        i   = 66;
      }
      else
      {
        cs1 = xcrc;
        i   = j;
      }

      for (;i>-1;i--)
        cs1 = crctab[cs1>>8] ^ (((cs1&255U)<<8) | (byte)p[i]);

      if (_cs1 == (cs1 & 0x7fffU))
      {
        if (!flag)
        {
          /* Get line number and crc from code line */
          crc_n_lnum (&_cs2, &c_line, p);
          cs2 = 0;
          for (i=0; i<64; i++)
            cs2 = crctab[cs2>>8] ^ (((cs2&255U)<<8) | (byte)p[i]);
          cs2 &= 0x3fff; /* strip calculated CRC to 14 bits */
        }
        else
        {
          if (!mcrc(p, 0))
            continue;
          else
            _cs2 = cs2 = 0;
        }
        if (_cs2 == cs2)
        {
          strcpy (line, buf);
          if (flag)
            code[215] = oldcode;
          return (1);
        }
      }
    }
  }
  if (flag)
    code[215] = oldcode;
  return (0);
}
