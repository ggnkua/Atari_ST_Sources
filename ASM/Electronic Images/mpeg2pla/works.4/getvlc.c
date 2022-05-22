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
    }
  }

  return mb_type;
}

static INT32 getIMBtype()
{

  if (getbits(1))
  {
    return 1;
  }

  if (!getbits(1))
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

INT32 getMV()
{
  INT32 code;

  if (getbits(1))
  {
    return 0;
  }

  if ((code = showbits(9))>=64)
  {
    code >>= 6;
    flushbits(MVtab0[code].len);

    return getbits(1)?-MVtab0[code].val:MVtab0[code].val;
  }

  if (code>=24)
  {
    code >>= 3;
    flushbits(MVtab1[code].len);

    return getbits(1)?-MVtab1[code].val:MVtab1[code].val;
  }

  if ((code-=12)<0)
  {
    if (!quiet)
      fprintf(stderr,"Invalid motion_vector code\n");
    fault=1;
    return 0;
  }

  flushbits(MVtab2[code].len);

  return getbits(1) ? -MVtab2[code].val : MVtab2[code].val;
}




