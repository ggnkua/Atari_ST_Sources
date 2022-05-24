/*
 *	PLAYMPEG
 *	Martin Griffiths 1995.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plaympeg.h"

/* private prototypes*/
static void getMBs _ANSI_ARGS_((INT32 framenum));
static void macroblock_modes _ANSI_ARGS_((INT32 *pmb_type, INT32 *pstwtype,
  INT32 *pstwclass, INT32 *pmotion_type, INT32 *pmv_count, INT32 *pmv_format, INT32 *pdmv,
  INT32 *pmvscale, INT32 *pdct_type));
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

  getMBs(framenum);

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

static void getMBs(framenum)
INT32 framenum;
{
  INT32 comp;
  INT32 MBA, MBAmax, MBAinc, mb_type, motion_type, dct_type;
  INT32 bx, by;
  UINT32 code;
  INT32 dc_dct_pred[3];
  INT32 mv_count, mv_format, mvscale;
  INT32 PMV[2][2][2], mv_field_sel[2][2];
  INT32 dmv, dmvector[2];
  INT32 qs;
  INT32 stwtype, stwclass;
  INT16 cbp;
  /* number of macroblocks per picture */
  MBAmax = mb_width*mb_height;

  MBA = 0; /* macroblock address */
  MBAinc = 0;
  fault=0;

  for (;;)
  {

    if (MBAinc==0)
    {
      if (!showbits(23) || fault) /* startcode or fault */
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

        /* decode slice header (may change quant_scale) */
        getslicehdr();

        /* decode macroblock address increment */
        MBAinc = getMBA();

        if (fault) goto resync;

        /* set current location */
        MBA = ((code&255) - 1)*mb_width + MBAinc - 1;
        MBAinc = 1; /* first macroblock in slice: not skipped */
        /* reset all DC coefficient and motion vector predictors */
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

        if (fault) goto resync;
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

      macroblock_modes(&mb_type, &stwtype, &stwclass,
        &motion_type, &mv_count, &mv_format, &dmv, &mvscale,
        &dct_type);

      if (fault) goto resync;

      if (mb_type & MB_QUANT)
      {
        qs = getbits(5);
        ld_quant_scale = qs;

      }

      /* motion vectors */

      /* decode forward motion vectors */
      if ((mb_type & MB_FORWARD) || ((mb_type & MB_INTRA) && conceal_mv))
      {
          motion_vector(PMV[0][0],dmvector,
            forw_r_size,forw_r_size,full_forw);
      }

      if (fault) goto resync;

      /* decode backward motion vectors */
      if (mb_type & MB_BACKWARD)
      {
          motion_vector(PMV[0][1],dmvector,
            back_r_size,back_r_size,full_back);
      }

      if (fault) goto resync;

      if ((mb_type & MB_INTRA) && conceal_mv)
        flushbits(1); /* remove marker_bit */

      /* macroblock_pattern */
      if (mb_type & MB_PATTERN)
        cbp = getCBP();
      else
        cbp = (mb_type & MB_INTRA) ? (1<<6)-1 : 0;

      if (fault) goto resync;

      /* decode blocks */
      memset(ld_block,0,6*sizeof(INT16)*64);
      if (mb_type & MB_INTRA)
      {	extern void getintrablocks(INT32,INT32 *);
        getintrablocks(cbp,dc_dct_pred);
      } else
      { for (comp=0; comp<6; comp++)
      	{
        	if (cbp & (1<<(6-1-comp)))
        	{
                getinterblock(comp);
         	 	if (fault) goto resync;
        	}
        }
      }
      

      /* reset intra_dc predictors */
      if (!(mb_type & MB_INTRA))
        dc_dct_pred[0]=dc_dct_pred[1]=dc_dct_pred[2]=0;

      /* reset motion vector predictors */
      if ((mb_type & MB_INTRA) && !conceal_mv)
      {
        /* intra mb without concealment motion vectors */
        PMV[0][0][0]=PMV[0][0][1]=PMV[1][0][0]=PMV[1][0][1]=0;
        PMV[0][1][0]=PMV[0][1][1]=PMV[1][1][0]=PMV[1][1][1]=0;
      }

      if ((pict_type==P_TYPE) && !(mb_type & (MB_FORWARD|MB_INTRA)))
      {
        /* non-intra mb without forward mv in a P picture */
        PMV[0][0][0]=PMV[0][0][1]=PMV[1][0][0]=PMV[1][0][1]=0;
        motion_type = MC_FRAME;
      }

      if (stwclass==4)
      {
        /* purely spatially predicted macroblock */
        PMV[0][0][0]=PMV[0][0][1]=PMV[1][0][0]=PMV[1][0][1]=0;
        PMV[0][1][0]=PMV[0][1][1]=PMV[1][1][0]=PMV[1][1][1]=0;
      }
      
    }
    else /* MBAinc!=1: skipped macroblock */
    {
      /* reset intra_dc predictors */
      dc_dct_pred[0]=dc_dct_pred[1]=dc_dct_pred[2]=0;

      /* reset motion vector predictors */
      if (pict_type==P_TYPE)
        PMV[0][0][0]=PMV[0][0][1]=PMV[1][0][0]=PMV[1][0][1]=0;

      motion_type = MC_FRAME;

      /* skipped I are spatial-only predicted, */
      /* skipped P and B are temporal-only predicted */
      stwtype = (pict_type==I_TYPE) ? 8 : 0;
	  cbp = 0;
	  mb_type &= ~MB_INTRA;
    }

      bx = 16*(MBA%mb_width);
      by = 16*(MBA/mb_width);

      if (!(mb_type & MB_INTRA))
        reconstruct(bx,by,mb_type,motion_type,PMV,mv_field_sel,dmvector,
          stwtype);

      /* copy or add block data into picture */
      for (comp=0; comp<6; comp++)
      {
        if ((cbp) & (1<<(6-1-comp)))
        {
          idct(ld_block[comp]);
          addblock(comp,bx,by,(mb_type & MB_INTRA)==0);
        }
      }
		
		
    /* advance to next macroblock */
    MBA++;
    MBAinc--;

  }
}


static void macroblock_modes(pmb_type,pstwtype,pstwclass,
  pmotion_type,pmv_count,pmv_format,pdmv,pmvscale,pdct_type)
  INT32 *pmb_type, *pstwtype, *pstwclass;
  INT32 *pmotion_type, *pmv_count, *pmv_format, *pdmv, *pmvscale;
  INT32 *pdct_type;
{
  INT32 mb_type;
  INT32 stwtype, stwcode, stwclass;
  INT32 motion_type, mv_count, mv_format, dmv, mvscale;
  INT32 dct_type;
  static unsigned char stwc_table[3][4]
    = { {6,3,7,4}, {2,1,5,4}, {2,5,7,4} };
  static unsigned char stwclass_table[9]
    = {0, 1, 2, 1, 1, 2, 3, 3, 4};

  /* get macroblock_type */
  mb_type = getMBtype();

  if (fault) return;

  /* get spatial_temporal_weight_code */
  if (mb_type & MB_WEIGHT)
  {
    if (stwc_table_index==0)
      stwtype = 4;
    else
    {
      stwcode = getbits(2);
      stwtype = stwc_table[stwc_table_index-1][stwcode];
    }
  }
  else
    stwtype = (mb_type & MB_CLASS4) ? 8 : 0;

  /* derive spatial_temporal_weight_class (Table 7-18) */
  stwclass = stwclass_table[stwtype];

  /* get frame/field motion type */
  if (mb_type & (MB_FORWARD|MB_BACKWARD))
  {
      motion_type = frame_pred_dct ? MC_FRAME : getbits(2);
  }
  else if ((mb_type & MB_INTRA) && conceal_mv)
  {
    /* concealment motion vectors */
    motion_type = MC_FRAME;
  }

  /* derive mv_count, mv_format and dmv, (table 6-17, 6-18) */
    mv_count = (motion_type==MC_FIELD && stwclass<2) ? 2 : 1;
    mv_format = (motion_type==MC_FRAME) ? MV_FRAME : MV_FIELD;

  dmv = (motion_type==MC_DMV); /* dual prime */

  /* field mv predictions in frame pictures have to be scaled */
  mvscale = ((mv_format==MV_FIELD));

  /* get dct_type (frame DCT / field DCT) */
  dct_type = (!frame_pred_dct)
             && (mb_type & (MB_PATTERN|MB_INTRA))
             ? getbits(1)
             : 0;

  /* return values */
  *pmb_type = mb_type;
  *pstwtype = stwtype;
  *pstwclass = stwclass;
  *pmotion_type = motion_type;
  *pmv_count = mv_count;
  *pmv_format = mv_format;
  *pdmv = dmv;
  *pmvscale = mvscale;
  *pdct_type = dct_type;
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
