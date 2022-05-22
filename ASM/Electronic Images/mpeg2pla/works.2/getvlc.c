/*
 *	PLAYMPEG
 *	Martin Griffiths 1995.
 */

#include <stdio.h>
#include <stdlib.h>
#include "plaympeg.h"
#include "proto.h"
#include "getvlc.h"

static INT32 getIMBtype _ANSI_ARGS_((void));
static INT32 getPMBtype _ANSI_ARGS_((void));
static INT32 getBMBtype _ANSI_ARGS_((void));
static INT32 getDMBtype _ANSI_ARGS_((void));

INT32 getMBtype()
{
  INT32 mb_type;

  {
    switch (pict_type)
    {
    case I_TYPE:
      mb_type = getIMBtype();
      break;
    case P_TYPE:
      mb_type = getPMBtype();
      break;
    case B_TYPE:
      mb_type = getBMBtype();
      break;
    case D_TYPE:
      /* MPEG-1 only, not implemented */
      mb_type = getDMBtype();
      break;
    }
  }

  return mb_type;
}

static INT32 getIMBtype()
{

  if (getbits1())
  {
    return 1;
  }

  if (!getbits1())
  {
    if (!quiet)
      fprintf(stderr,"Invalid macroblock_type code\n");
    fault = 1;
  }

  return 17;
}

static INT32 getPMBtype()
{
  INT32 code;

  if ((code = showbits(6))>=8)
  {
    code >>= 3;
    flushbits(PMBtab0[code].len);
    return PMBtab0[code].val;
  }

  if (code==0)
  {
    if (!quiet)
      fprintf(stderr,"Invalid macroblock_type code\n");
    fault = 1;
    return 0;
  }

  flushbits(PMBtab1[code].len);

  return PMBtab1[code].val;
}

static INT32 getBMBtype()
{
  INT32 code;

  if ((code = showbits(6))>=8)
  {
    code >>= 2;
    flushbits(BMBtab0[code].len);

    return BMBtab0[code].val;
  }

  if (code==0)
  {
    if (!quiet)
      fprintf(stderr,"Invalid macroblock_type code\n");
    fault = 1;
    return 0;
  }

  flushbits(BMBtab1[code].len);

  return BMBtab1[code].val;
}

static INT32 getDMBtype()
{
  if (!getbits1())
  {
    if (!quiet)
      fprintf(stderr,"Invalid macroblock_type code\n");
    fault=1;
  }

  return 1;
}

int getMV()
{
  int code;

  if (getbits1())
  {
    return 0;
  }

  if ((code = showbits(9))>=64)
  {
    code >>= 6;
    flushbits(MVtab0[code].len);

    return getbits1()?-MVtab0[code].val:MVtab0[code].val;
  }

  if (code>=24)
  {
    code >>= 3;
    flushbits(MVtab1[code].len);

    return getbits1()?-MVtab1[code].val:MVtab1[code].val;
  }

  if ((code-=12)<0)
  {
    if (!quiet)
      fprintf(stderr,"Invalid motion_vector code\n");
    fault=1;
    return 0;
  }

  flushbits(MVtab2[code].len);

  return getbits1() ? -MVtab2[code].val : MVtab2[code].val;
}

/* get differential motion vector (for dual prime prediction) */
int getDMV()
{
  if (getbits(1))
  {
    return getbits(1) ? -1 : 1;
  }
  else
  {
    return 0;
  }
}

int getCBP()
{
  int code;

  if ((code = showbits(9))>=128)
  {
    code >>= 4;
    flushbits(CBPtab0[code].len);
    return CBPtab0[code].val;
  }

  if (code>=8)
  {
    code >>= 1;
    flushbits(CBPtab1[code].len);
    return CBPtab1[code].val;
  }

  if (code<1)
  {
    if (!quiet)
      fprintf(stderr,"Invalid coded_block_pattern code\n");
    fault = 1;
    return 0;
  }

  flushbits(CBPtab2[code].len);
  return CBPtab2[code].val;
}

int getMBA()
{
  int code, val;

  val = 0;

  while ((code = showbits(11))<24)
  {
    if (code!=15) /* if not macroblock_stuffing */
    {
      if (code==8) /* if macroblock_escape */
      {
        val+= 33;
      }
      else
      {
        if (!quiet)
          fprintf(stderr,"Invalid macroblock_address_increment code\n");

        fault = 1;
        return 1;
      }
    }

    flushbits(11);
  }

  if (code>=1024)
  {
    flushbits(1);
    return val + 1;
  }

  if (code>=128)
  {
    code >>= 6;
    flushbits(MBAtab1[code].len);
    return val + MBAtab1[code].val;
  }

  code-= 24;
  flushbits(MBAtab2[code].len);
  return val + MBAtab2[code].val;
}

int getDClum()
{
  int code, size, val;
  /* decode length */
  code = showbits(5);

  if (code<31)
  {
    size = DClumtab0[code].val;
    flushbits(DClumtab0[code].len);
  }
  else
  {
    code = showbits(9) - 0x1f0;
    size = DClumtab1[code].val;
    flushbits(DClumtab1[code].len);
  }

  if (size==0)
    val = 0;
  else
  {
    val = getbits(size);
    if ((val & (1<<(size-1)))==0)
      val-= (1<<size) - 1;
  }
  return val;
}

int getDCchrom()
{
  int code, size, val;
  /* decode length */
  code = showbits(5);

  if (code<31)
  {
    size = DCchromtab0[code].val;
    flushbits(DCchromtab0[code].len);
  }
  else
  {
    code = showbits(10) - 0x3e0;
    size = DCchromtab1[code].val;
    flushbits(DCchromtab1[code].len);
  }

  if (size==0)
    val = 0;
  else
  {
    val = getbits(size);
    if ((val & (1<<(size-1)))==0)
      val-= (1<<size) - 1;
  }

  return val;
}
