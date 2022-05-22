/*
 *	PLAYMPEG
 *	Martin Griffiths 1995.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plaympeg.h"

/* private prototypes*/
static void getMBs _ANSI_ARGS_((void));
static void addblock _ANSI_ARGS_((INT32 comp, INT32 bx, INT32 by, INT32 addflag));

/* decode one frame or field picture */

void getpicture(framenum)
INT32 framenum;
{
  INT32 i;
  unsigned char *tmp;

  for (i=0; i<3; i++)
  {
    if (pict_type==B_TYPE)
      newframe[i] = auxframe[i];
    else
    {
      tmp = oldrefframe[i];
      oldrefframe[i] = refframe[i];
      refframe[i] = tmp;
      newframe[i] = refframe[i];
    }

  }

  getMBs();

  if (framenum!=0)
  {
        if (pict_type==B_TYPE)
          dither(auxframe);
        else
          dither(oldrefframe);
  }

}

/* store last frame */

void putlast(framenum)
INT32 framenum;
{
    dither(refframe);
}


/* decode all macroblocks of the current picture */

static void getMBs(void)
{
  INT32 MBA, MBAmax, MBAinc, bx, by;
  UINT32 code;
  INT32 PMV[2][2][2];
  INT32 stwtype;
  INT16 dc_dct_pred[3];
  INT16 cbp,comp,mb_type;
  if (pict_type == I_TYPE)
  { get_I_frame();
    return;
  }
 
  MBAmax = mb_width*mb_height;

  MBA = 0; /* macroblock address */
  MBAinc = 0;
  fault=0;

  for (;;)
  {

    if (MBAinc==0)
    {
      if (!showbits(23)) /* startcode */
      {
resync: /* if fault: resynchronize to next startcode */
        fault = 0;

        if (MBA>=MBAmax)
          return; /* all macroblocks decoded */

        startcode();
        code = showbits(32);

        if (code<SLICE_MIN_START || code>SLICE_MAX_START)
        {
          /* only slice headers are allowed in picture_data */
          if (!quiet)
            printf("Premature end of picture\n");
          return;
        }

        flushbits(32);

        getslicehdr();
        MBAinc = getMBA();

        MBA = ((code&255) - 1)*mb_width + MBAinc - 1;
        MBAinc = 1; /* first macroblock in slice: not skipped */
        dc_dct_pred[0]=dc_dct_pred[1]=dc_dct_pred[2]=0;
        PMV[0][0][0]=PMV[0][0][1]=PMV[1][0][0]=PMV[1][0][1]=0;
        PMV[0][1][0]=PMV[0][1][1]=PMV[1][1][0]=PMV[1][1][1]=0;
      }
      else /* neither startcode nor fault */
      {
        if (MBA>=MBAmax)
        {
          if (!quiet)
            printf("Too many macroblocks in picture\n");
          return;
        }

        /* decode macroblock address increment */
        MBAinc = getMBA();

      }
    }

    if (MBA>=MBAmax)
    {
      /* MBAinc points beyond picture dimensions */
      if (!quiet)
        printf("Too many macroblocks in picture\n");
      return;
    }

	if (MBAinc==1) /* not skipped */
    {
		mb_type = getMBtype();
   	  	stwtype = 0;
     	if (mb_type & MB_QUANT)
        	ld_quant_scale =  getbits(5);

      	if (mb_type & MB_FORWARD)
      	{   motion_vector(PMV[0][0],forw_r_size,forw_r_size,full_forw);
          	if (fault) goto resync;
      	}

      	if (mb_type & MB_BACKWARD)
      	{	motion_vector(PMV[0][1],back_r_size,back_r_size,full_back);
      	  	if (fault) goto resync;
      	}

     	if (mb_type & MB_PATTERN)
        	cbp = getCBP();
      	else
        	cbp = (mb_type & MB_INTRA) ? (1<<6)-1 : 0;

      	memset(ld_block,0,6*sizeof(INT16)*64);
      
      	if (mb_type & MB_INTRA)
      	{	
        	getintrablocks(cbp,dc_dct_pred);
        	/* intra mb without concealment motion vectors */
        	PMV[0][0][0]=PMV[0][0][1]=PMV[1][0][0]=PMV[1][0][1]=0;
        	PMV[0][1][0]=PMV[0][1][1]=PMV[1][1][0]=PMV[1][1][1]=0;
      	} else
      	{ 
        	getinterblocks(cbp);
        	dc_dct_pred[0]=dc_dct_pred[1]=dc_dct_pred[2]=0;
        
        	if ((pict_type==P_TYPE) && !(mb_type & (MB_FORWARD|MB_INTRA)))
        	{
          		/* non-intra mb without forward mv in a P picture */
          		PMV[0][0][0]=PMV[0][0][1]=PMV[1][0][0]=PMV[1][0][1]=0;
        	}
      	}
    }
    else /* MBAinc!=1: skipped macroblock */
    {
      dc_dct_pred[0]=dc_dct_pred[1]=dc_dct_pred[2]=0;
      if (pict_type==P_TYPE)
        PMV[0][0][0]=PMV[0][0][1]=PMV[1][0][0]=PMV[1][0][1]=0;
      /* skipped I are spatial-only predicted, */
      /* skipped P and B are temporal-only predicted */
      stwtype = (pict_type==I_TYPE) ? 8 : 0;
	  cbp = 0;
	  mb_type &= ~MB_INTRA;
    }

      bx = 16*(MBA%mb_width);
      by = 16*(MBA/mb_width);

      if (!(mb_type & MB_INTRA))
        reconstruct(bx,by,mb_type,PMV,stwtype);

      for (comp=0; comp<6; comp++)
      {
        if ((cbp) & (1<<(6-1-comp)))
        {
          idct(ld_block[comp]);
          addblock(comp,bx,by,(mb_type & MB_INTRA)==0);
        }
      }
		
    MBA++;
    MBAinc--;

  }
}

/* limit coefficients to -2048..2047 */
/* move/add 8x8-Block from block[comp] to refframe */

static void addblock(comp,bx,by,addflag)
INT32 comp,bx,by,addflag;
{
  INT32 cc,i, j, iincr;
  unsigned char *rfp;
  INT16 *bp;
  unsigned char *clp2= clp;

  if (!addflag)
    clp2 += 128;

  cc = (comp<4) ? 0 : (comp&1)+1; /* color component index */

  if (cc==0)
  {
        rfp = newframe[0]
              + coded_picture_width*(by+((comp&2)<<2)) + bx + ((comp&1)<<3);
        iincr = coded_picture_width;
  }
  else
  {
      bx >>= 1;
      by >>= 1;
        rfp = newframe[cc]
              + chrom_width*(by+((comp&2)<<2)) + bx + (comp&8);
        iincr = chrom_width;
  }

  bp = ld_block[comp];

  if (addflag)
    for (i=0; i<8; i++)
    {
      rfp[0] = clp2[bp[0] + rfp[0]];
      rfp[1] = clp2[bp[1] + rfp[1]];
      rfp[2] = clp2[bp[2] + rfp[2]];
      rfp[3] = clp2[bp[3] + rfp[3]];
      rfp[4] = clp2[bp[4] + rfp[4]];
      rfp[5] = clp2[bp[5] + rfp[5]];
      rfp[6] = clp2[bp[6] + rfp[6]];
      rfp[7] = clp2[bp[7] + rfp[7]];
      rfp+= iincr;
      bp += 8;
    }
  else
    for (i=0; i<8; i++)
    {
      rfp[0] = clp2[bp[0]];
      rfp[1] = clp2[bp[1]];
      rfp[2] = clp2[bp[2]];
      rfp[3] = clp2[bp[3]];
      rfp[4] = clp2[bp[4]];
      rfp[5] = clp2[bp[5]];
      rfp[6] = clp2[bp[6]];
      rfp[7] = clp2[bp[7]];
      rfp+= iincr;
      bp += 8;
    }
}
