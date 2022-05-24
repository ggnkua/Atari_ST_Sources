/* getvlc.c, variable length decoding                                       */

/* Copyright (C) 1994, MPEG Software Simulation Group. All Rights Reserved. */

/*
 * Disclaimer of Warranty
 *
 * These software programs are available to the user without any license fee or
 * royalty on an "as is" basis.  The MPEG Software Simulation Group disclaims
 * any and all warranties, whether express, implied, or statuary, including any
 * implied warranties or merchantability or of fitness for a particular
 * purpose.  In no event shall the copyright-holder be liable for any
 * incidental, punitive, or consequential damages of any kind whatsoever
 * arising from the use of these programs.
 *
 * This disclaimer of warranty extends to the user of these programs and user's
 * customers, employees, agents, transferees, successors, and assigns.
 *
 * The MPEG Software Simulation Group does not represent or warrant that the
 * programs furnished hereunder are free of infringement of any third-party
 * patents.
 *
 * Commercial implementations of MPEG-1 and MPEG-2 video, including shareware,
 * are subject to royalty fees to patent holders.  Many of these patents are
 * general enough such that they are unavoidable regardless of implementation
 * design.
 *
 */

#include <stdio.h>

#include "config.h"
#include "global.h"
#include "getvlc.h"

/* private prototypes */
static int getIMBtype _ANSI_ARGS_((void));
static int getPMBtype _ANSI_ARGS_((void));
static int getBMBtype _ANSI_ARGS_((void));
static int getDMBtype _ANSI_ARGS_((void));
static int getspIMBtype _ANSI_ARGS_((void));
static int getspPMBtype _ANSI_ARGS_((void));
static int getspBMBtype _ANSI_ARGS_((void));
static int getSNRMBtype _ANSI_ARGS_((void));

int getMBtype()
{
  int mb_type;

  if (ld->scalable_mode==SC_SNR)
    mb_type = getSNRMBtype();
  else
  {
    switch (pict_type)
    {
    case I_TYPE:
      mb_type = ld->pict_scal ? getspIMBtype() : getIMBtype();
      break;
    case P_TYPE:
      mb_type = ld->pict_scal ? getspPMBtype() : getPMBtype();
      break;
    case B_TYPE:
      mb_type = ld->pict_scal ? getspBMBtype() : getBMBtype();
      break;
    case D_TYPE:
      /* MPEG-1 only, not implemented */
      mb_type = getDMBtype();
      break;
    }
  }

  return mb_type;
}

static int getIMBtype()
{
#ifdef TRACE
  if (trace)
    printf("mb_type(I) ");
#endif

  if (getbits1())
  {
#ifdef TRACE
    if (trace)
      printf("(1): Intra (1)\n");
#endif
    return 1;
  }

  if (!getbits1())
  {
    if (!quiet)
      fprintf(stderr,"Invalid macroblock_type code\n");
    fault = 1;
  }

#ifdef TRACE
  if (trace)
    printf("(01): Intra, Quant (17)\n");
#endif

  return 17;
}

#ifdef TRACE
static char *MBdescr[]={
  "",                  "Intra",        "No MC, Coded",         "",
  "Bwd, Not Coded",    "",             "Bwd, Coded",           "",
  "Fwd, Not Coded",    "",             "Fwd, Coded",           "",
  "Interp, Not Coded", "",             "Interp, Coded",        "",
  "",                  "Intra, Quant", "No MC, Coded, Quant",  "",
  "",                  "",             "Bwd, Coded, Quant",    "",
  "",                  "",             "Fwd, Coded, Quant",    "",
  "",                  "",             "Interp, Coded, Quant", ""
};
#endif

static int getPMBtype()
{
  int code;

#ifdef TRACE
  if (trace)
    printf("mb_type(P) (");
#endif

  if ((code = showbits(6))>=8)
  {
    code >>= 3;
    flushbits(PMBtab0[code].len);
#ifdef TRACE
    if (trace)
    {
      printbits(code,3,PMBtab0[code].len);
      printf("): %s (%d)\n",MBdescr[PMBtab0[code].val],PMBtab0[code].val);
    }
#endif
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

#ifdef TRACE
  if (trace)
  {
    printbits(code,6,PMBtab1[code].len);
    printf("): %s (%d)\n",MBdescr[PMBtab1[code].val],PMBtab1[code].val);
  }
#endif

  return PMBtab1[code].val;
}

static int getBMBtype()
{
  int code;

#ifdef TRACE
  if (trace)
    printf("mb_type(B) (");
#endif

  if ((code = showbits(6))>=8)
  {
    code >>= 2;
    flushbits(BMBtab0[code].len);

#ifdef TRACE
    if (trace)
    {
      printbits(code,4,BMBtab0[code].len);
      printf("): %s (%d)\n",MBdescr[BMBtab0[code].val],BMBtab0[code].val);
    }
#endif

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

#ifdef TRACE
  if (trace)
  {
    printbits(code,6,BMBtab1[code].len);
    printf("): %s (%d)\n",MBdescr[BMBtab1[code].val],BMBtab1[code].val);
  }
#endif

  return BMBtab1[code].val;
}

static int getDMBtype()
{
  if (!getbits1())
  {
    if (!quiet)
      fprintf(stderr,"Invalid macroblock_type code\n");
    fault=1;
  }

  return 1;
}

/* macroblock_type for pictures with spatial scalability */
static int getspIMBtype()
{
  int code;

#ifdef TRACE
  if (trace)
    printf("mb_type(I,spat) (");
#endif

  code = showbits(4);

  if (code==0)
  {
    if (!quiet)
      fprintf(stderr,"Invalid macroblock_type code\n");
    fault = 1;
    return 0;
  }

#ifdef TRACE
  if (trace)
  {
    printbits(code,4,spIMBtab[code].len);
    printf("): %02x\n",spIMBtab[code].val);
  }
#endif

  flushbits(spIMBtab[code].len);
  return spIMBtab[code].val;
}

static int getspPMBtype()
{
  int code;

#ifdef TRACE
  if (trace)
    printf("mb_type(P,spat) (");
#endif

  code = showbits(7);

  if (code<2)
  {
    if (!quiet)
      fprintf(stderr,"Invalid macroblock_type code\n");
    fault = 1;
    return 0;
  }

  if (code>=16)
  {
    code >>= 3;
    flushbits(spPMBtab0[code].len);

#ifdef TRACE
    if (trace)
    {
      printbits(code,4,spPMBtab0[code].len);
      printf("): %02x\n",spPMBtab0[code].val);
    }
#endif

    return spPMBtab0[code].val;
  }

  flushbits(spPMBtab1[code].len);

#ifdef TRACE
  if (trace)
  {
    printbits(code,7,spPMBtab1[code].len);
    printf("): %02x\n",spPMBtab1[code].val);
  }
#endif

  return spPMBtab1[code].val;
}

static int getspBMBtype()
{
  int code;
  VLCtab *p;

#ifdef TRACE
  if (trace)
    printf("mb_type(B,spat) (");
#endif

  code = showbits(9);

  if (code>=64)
    p = &spBMBtab0[(code>>5)-2];
  else if (code>=16)
    p = &spBMBtab1[(code>>2)-4];
  else if (code>=8)
    p = &spBMBtab2[code-8];
  else
  {
    if (!quiet)
      fprintf(stderr,"Invalid macroblock_type code\n");
    fault = 1;
    return 0;
  }

  flushbits(p->len);

#ifdef TRACE
  if (trace)
  {
    printbits(code,9,p->len);
    printf("): %02x\n",p->val);
  }
#endif

  return p->val;
}

static int getSNRMBtype()
{
  int code;

  code = showbits(3);

  if (code==0)
  {
    if (!quiet)
      fprintf(stderr,"Invalid macroblock_type code\n");
    fault = 1;
    return 0;
  }

  flushbits(SNRMBtab[code].len);
  return SNRMBtab[code].val;
}

int getMV()
{
  int code;

#ifdef TRACE
  if (trace)
    printf("motion_code (");
#endif

  if (getbits1())
  {
#ifdef TRACE
    if (trace)
      printf("0): 0\n");
#endif
    return 0;
  }

  if ((code = showbits(9))>=64)
  {
    code >>= 6;
    flushbits(MVtab0[code].len);

#ifdef TRACE
    if (trace)
    {
      printbits(code,3,MVtab0[code].len);
      printf("%d): %d\n",
        showbits(1),showbits(1)?-MVtab0[code].val:MVtab0[code].val);
    }
#endif

    return getbits1()?-MVtab0[code].val:MVtab0[code].val;
  }

  if (code>=24)
  {
    code >>= 3;
    flushbits(MVtab1[code].len);

#ifdef TRACE
    if (trace)
    {
      printbits(code,6,MVtab1[code].len);
      printf("%d): %d\n",
        showbits(1),showbits(1)?-MVtab1[code].val:MVtab1[code].val);
    }
#endif

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

#ifdef TRACE
  if (trace)
  {
    printbits(code+12,9,MVtab2[code].len);
    printf("%d): %d\n",
      showbits(1),showbits(1)?-MVtab2[code].val:MVtab2[code].val);
  }
#endif

  return getbits1() ? -MVtab2[code].val : MVtab2[code].val;
}

/* get differential motion vector (for dual prime prediction) */
int getDMV()
{
#ifdef TRACE
  if (trace)
    printf("dmvector (");
#endif

  if (getbits(1))
  {
#ifdef TRACE
    if (trace)
      printf(showbits(1) ? "11): -1\n" : "10): 1\n");
#endif
    return getbits(1) ? -1 : 1;
  }
  else
  {
#ifdef TRACE
    if (trace)
      printf("0): 0\n");
#endif
    return 0;
  }
}

int getCBP()
{
  int code;

#ifdef TRACE
  if (trace)
    printf("coded_block_pattern_420 (");
#endif

  if ((code = showbits(9))>=128)
  {
    code >>= 4;
    flushbits(CBPtab0[code].len);

#ifdef TRACE
    if (trace)
    {
      printbits(code,5,CBPtab0[code].len);
      printf("): ");
      printbits(CBPtab0[code].val,6,6);
      printf(" (%d)\n",CBPtab0[code].val);
    }
#endif

    return CBPtab0[code].val;
  }

  if (code>=8)
  {
    code >>= 1;
    flushbits(CBPtab1[code].len);

#ifdef TRACE
    if (trace)
    {
      printbits(code,8,CBPtab1[code].len);
      printf("): ");
      printbits(CBPtab1[code].val,6,6);
      printf(" (%d)\n",CBPtab1[code].val);
    }
#endif

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

#ifdef TRACE
  if (trace)
  {
    printbits(code,9,CBPtab2[code].len);
    printf("): ");
    printbits(CBPtab2[code].val,6,6);
    printf(" (%d)\n",CBPtab2[code].val);
  }
#endif

  return CBPtab2[code].val;
}

int getMBA()
{
  int code, val;

#ifdef TRACE
  if (trace)
    printf("macroblock_address_increment (");
#endif

  val = 0;

  while ((code = showbits(11))<24)
  {
    if (code!=15) /* if not macroblock_stuffing */
    {
      if (code==8) /* if macroblock_escape */
      {
#ifdef TRACE
        if (trace)
          printf("00000001000 ");
#endif

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
#ifdef TRACE
    else if (trace)
      printf("00000001111 ");
#endif

    flushbits(11);
  }

  if (code>=1024)
  {
    flushbits(1);
#ifdef TRACE
    if (trace)
      printf("1): %d\n",val+1);
#endif
    return val + 1;
  }

  if (code>=128)
  {
    code >>= 6;
    flushbits(MBAtab1[code].len);

#ifdef TRACE
    if (trace)
    {
      printbits(code,5,MBAtab1[code].len);
      printf("): %d\n",val+MBAtab1[code].val);
    }
#endif

    return val + MBAtab1[code].val;
  }

  code-= 24;
  flushbits(MBAtab2[code].len);

#ifdef TRACE
  if (trace)
  {
    printbits(code+24,11,MBAtab2[code].len);
    printf("): %d\n",val+MBAtab2[code].val);
  }
#endif

  return val + MBAtab2[code].val;
}

int getDClum()
{
  int code, size, val;

#ifdef TRACE
  if (trace)
    printf("dct_dc_size_luminance: (");
#endif

  /* decode length */
  code = showbits(5);

  if (code<31)
  {
    size = DClumtab0[code].val;
    flushbits(DClumtab0[code].len);

#ifdef TRACE
    if (trace)
    {
      printbits(code,5,DClumtab0[code].len);
      printf("): %d",size);
    }
#endif
  }
  else
  {
    code = showbits(9) - 0x1f0;
    size = DClumtab1[code].val;
    flushbits(DClumtab1[code].len);

#ifdef TRACE
    if (trace)
    {
      printbits(code+0x1f0,9,DClumtab1[code].len);
      printf("): %d",size);
    }
#endif
  }

#ifdef TRACE
  if (trace)
    printf(", dct_dc_differential (");
#endif

  if (size==0)
    val = 0;
  else
  {
    val = getbits(size);
#ifdef TRACE
    if (trace)
      printbits(val,size,size);
#endif
    if ((val & (1<<(size-1)))==0)
      val-= (1<<size) - 1;
  }

#ifdef TRACE
  if (trace)
    printf("): %d\n",val);
#endif

  return val;
}

int getDCchrom()
{
  int code, size, val;

#ifdef TRACE
  if (trace)
    printf("dct_dc_size_chrominance: (");
#endif

  /* decode length */
  code = showbits(5);

  if (code<31)
  {
    size = DCchromtab0[code].val;
    flushbits(DCchromtab0[code].len);

#ifdef TRACE
    if (trace)
    {
      printbits(code,5,DCchromtab0[code].len);
      printf("): %d",size);
    }
#endif
  }
  else
  {
    code = showbits(10) - 0x3e0;
    size = DCchromtab1[code].val;
    flushbits(DCchromtab1[code].len);

#ifdef TRACE
    if (trace)
    {
      printbits(code+0x3e0,10,DCchromtab1[code].len);
      printf("): %d",size);
    }
#endif
  }

#ifdef TRACE
  if (trace)
    printf(", dct_dc_differential (");
#endif

  if (size==0)
    val = 0;
  else
  {
    val = getbits(size);
#ifdef TRACE
    if (trace)
      printbits(val,size,size);
#endif
    if ((val & (1<<(size-1)))==0)
      val-= (1<<size) - 1;
  }

#ifdef TRACE
  if (trace)
    printf("): %d\n",val);
#endif

  return val;
}
