/* getpic.c, picture decoding                                               */

/*
 * All modifications (mpeg2decode -> mpeg2play) are
 * Copyright (C) 1994, Stefan Eckart. All Rights Reserved.
 */

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

/* private prototypes*/
static void getMBs _ANSI_ARGS_((int framenum));
static void macroblock_modes _ANSI_ARGS_((int *pmb_type, int *pstwtype,
  int *pstwclass, int *pmotion_type, int *pmv_count, int *pmv_format, int *pdmv,
  int *pmvscale, int *pdct_type));
static void clearblock _ANSI_ARGS_((int comp));
static void sumblock _ANSI_ARGS_((int comp));
static void addblock _ANSI_ARGS_((int comp, int bx, int by,
  int dct_type, int addflag));

/* decode one frame or field picture */

void getpicture(framenum)
int framenum;
{
  int i;
  unsigned char *tmp;

  if (pict_struct==FRAME_PICTURE && secondfield)
  {
    /* recover from illegal number of field pictures */
    printf("odd number of field pictures\n");
    secondfield = 0;
  }

  for (i=0; i<3; i++)
  {
    if (pict_type==B_TYPE)
    {
      newframe[i] = auxframe[i];
    }
    else
    {
      if (!secondfield)
      {
        tmp = oldrefframe[i];
        oldrefframe[i] = refframe[i];
        refframe[i] = tmp;
      }

      newframe[i] = refframe[i];
    }

    if (pict_struct==BOTTOM_FIELD)
      newframe[i]+= (i==0) ? coded_picture_width : chrom_width;
  }

  if (base.pict_scal && !secondfield)
    getspatref();

  getMBs(framenum);

  if (framenum!=0)
  {
    if (pict_struct==FRAME_PICTURE || secondfield)
    {
      if (outtype==T_X11)
        if (pict_type==B_TYPE)
          dither(auxframe);
        else
          dither(oldrefframe);
    }
    else if (outtype==T_X11)
    {
      display_second_field();
    }
  }

  if (pict_struct!=FRAME_PICTURE)
    secondfield = !secondfield;
}


/* store last frame */

void putlast(framenum)
int framenum;
{
  if (secondfield)
    printf("last frame incomplete, not stored\n");
  else if (outtype==T_X11)
    dither(refframe);
}


/* decode all macroblocks of the current picture */

static void getMBs(framenum)
int framenum;
{
  int comp;
  int MBA, MBAmax, MBAinc, mb_type, cbp, motion_type, dct_type;
  int slice_vert_pos_ext;
  int bx, by;
  unsigned int code;
  int dc_dct_pred[3];
  int mv_count, mv_format, mvscale;
  int PMV[2][2][2], mv_field_sel[2][2];
  int dmv, dmvector[2];
  int qs;
  int stwtype, stwclass;
  int SNRMBA, SNRMBAinc, SNRmb_type, SNRcbp, SNRdct_type, dummy; /* SNR scal. */

  /* number of macroblocks per picture */
  MBAmax = mb_width*mb_height;

  if (pict_struct!=FRAME_PICTURE)
    MBAmax>>=1; /* field picture has half as mnay macroblocks as frame */

  MBA = 0; /* macroblock address */
  MBAinc = 0;

  if (twostreams && enhan.scalable_mode==SC_SNR)
  {
    SNRMBA=0;
    SNRMBAinc=0;
  }

  fault=0;

  for (;;)
  {
#ifdef TRACE
    if (trace)
      printf("frame %d, MB %d\n",framenum,MBA);
#endif

    if (!prog_seq && pict_struct==FRAME_PICTURE && MBA==(MBAmax>>1) &&
        framenum!=0 && outtype==T_X11)
      display_second_field();

    ld = &base;
    if (MBAinc==0)
    {
      if (base.scalable_mode==SC_DP && base.pri_brk==1)
          ld = &enhan;

      if (!showbits(23) || fault) /* startcode or fault */
      {
resync: /* if fault: resynchronize to next startcode */
        fault = 0;
        ld = &base;

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

        flushbits32();

        /* decode slice header (may change quant_scale) */
        slice_vert_pos_ext = getslicehdr();

        if (base.scalable_mode==SC_DP)
        {
          ld = &enhan;
          startcode();
          code = showbits(32);

          if (code<SLICE_MIN_START || code>SLICE_MAX_START)
          {
            /* only slice headers are allowed in picture_data */
            if (!quiet)
              printf("Premature end of picture\n");
            return;
          }

          flushbits32();

          /* decode slice header (may change quant_scale) */
          slice_vert_pos_ext = getslicehdr();

          if (base.pri_brk!=1)
            ld = &base;
        }

        /* decode macroblock address increment */
        MBAinc = getMBA();

        if (fault) goto resync;

        /* set current location */
        MBA = ((slice_vert_pos_ext<<7) + (code&255) - 1)*mb_width + MBAinc - 1;
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

        if (base.scalable_mode==SC_DP && base.pri_brk==1)
          ld = &enhan;

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
      if (base.scalable_mode==SC_DP)
      {
        if (base.pri_brk<=2)
          ld = &enhan;
        else
          ld = &base;
      }

      macroblock_modes(&mb_type, &stwtype, &stwclass,
        &motion_type, &mv_count, &mv_format, &dmv, &mvscale,
        &dct_type);

      if (fault) goto resync;

      if (mb_type & MB_QUANT)
      {
        qs = getbits(5);

#ifdef TRACE
        if (trace)
        {
          printf("quantiser_scale_code (");
          printbits(qs,5,5);
          printf("): %d\n",qs);
        }
#endif

        if (ld->mpeg2)
          ld->quant_scale =
            ld->qscale_type ? non_linear_mquant_table[qs] : (qs << 1);
        else
          ld->quant_scale = qs;

        if (base.scalable_mode==SC_DP)
          /* make sure base.quant_scale is valid */
          base.quant_scale = ld->quant_scale;
      }

      /* motion vectors */

      /* decode forward motion vectors */
      if ((mb_type & MB_FORWARD) || ((mb_type & MB_INTRA) && conceal_mv))
      {
        if (ld->mpeg2)
          motion_vectors(PMV,dmvector,mv_field_sel,
            0,mv_count,mv_format,h_forw_r_size,v_forw_r_size,dmv,mvscale);
        else
          motion_vector(PMV[0][0],dmvector,
            forw_r_size,forw_r_size,0,0,full_forw);
      }

      if (fault) goto resync;

      /* decode backward motion vectors */
      if (mb_type & MB_BACKWARD)
      {
        if (ld->mpeg2)
          motion_vectors(PMV,dmvector,mv_field_sel,
            1,mv_count,mv_format,h_back_r_size,v_back_r_size,0,mvscale);
        else
          motion_vector(PMV[0][1],dmvector,
            back_r_size,back_r_size,0,0,full_back);
      }

      if (fault) goto resync;

      if ((mb_type & MB_INTRA) && conceal_mv)
        flushbits(1); /* remove marker_bit */

      if (base.scalable_mode==SC_DP && base.pri_brk==3)
        ld = &enhan;

      /* macroblock_pattern */
      if (mb_type & MB_PATTERN)
      {
        cbp = getCBP();
        if (chroma_format==CHROMA422)
        {
          cbp = (cbp<<2) | getbits(2); /* coded_block_pattern_1 */

#ifdef TRACE
          if (trace)
          {
            printf("coded_block_pattern_1: ");
            printbits(cbp,2,2);
            printf(" (%d)\n",cbp&3);
          }
#endif
        }
        else if (chroma_format==CHROMA444)
        {
          cbp = (cbp<<6) | getbits(6); /* coded_block_pattern_2 */

#ifdef TRACE
          if (trace)
          {
            printf("coded_block_pattern_2: ");
            printbits(cbp,6,6);
            printf(" (%d)\n",cbp&63);
          }
#endif
        }
      }
      else
        cbp = (mb_type & MB_INTRA) ? (1<<blk_cnt)-1 : 0;

      if (fault) goto resync;

      /* decode blocks */
      for (comp=0; comp<blk_cnt; comp++)
      {
        if (base.scalable_mode==SC_DP)
          ld = &base;

        clearblock(comp);

        if (cbp & (1<<(blk_cnt-1-comp)))
        {
          if (mb_type & MB_INTRA)
          {
            if (ld->mpeg2)
              getmpg2intrablock(comp,dc_dct_pred);
            else
              getintrablock(comp,dc_dct_pred);
          }
          else
          {
            if (ld->mpeg2)
              getmpg2interblock(comp);
            else
              getinterblock(comp);
          }

          if (fault) goto resync;
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

        /* derive motion_type */
        if (pict_struct==FRAME_PICTURE)
          motion_type = MC_FRAME;
        else
        {
          motion_type = MC_FIELD;
          /* predict from field of same parity */
          mv_field_sel[0][0] = (pict_struct==BOTTOM_FIELD);
        }
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
      if (base.scalable_mode==SC_DP)
        ld = &base;

      for (comp=0; comp<blk_cnt; comp++)
        clearblock(comp);

      /* reset intra_dc predictors */
      dc_dct_pred[0]=dc_dct_pred[1]=dc_dct_pred[2]=0;

      /* reset motion vector predictors */
      if (pict_type==P_TYPE)
        PMV[0][0][0]=PMV[0][0][1]=PMV[1][0][0]=PMV[1][0][1]=0;

      /* derive motion_type */
      if (pict_struct==FRAME_PICTURE)
        motion_type = MC_FRAME;
      else
      {
        motion_type = MC_FIELD;
        /* predict from field of same parity */
        mv_field_sel[0][0]=mv_field_sel[0][1] = (pict_struct==BOTTOM_FIELD);
      }

      /* skipped I are spatial-only predicted, */
      /* skipped P and B are temporal-only predicted */
      stwtype = (pict_type==I_TYPE) ? 8 : 0;

      /* clear MB_INTRA */
      mb_type&= ~MB_INTRA;

      cbp = 0; /* no block data */
    }

    SNRcbp = 0;

    if (twostreams && enhan.scalable_mode==SC_SNR)
    {
      ld = &enhan;
      if (SNRMBAinc==0)
      {
        if (!showbits(23)) /* startcode */
        {
          startcode();
          code = showbits(32);

          if (code<SLICE_MIN_START || code>SLICE_MAX_START)
          {
            /* only slice headers are allowed in picture_data */
            if (!quiet)
              printf("Premature end of picture\n");
            return;
          }

          flushbits32();

          /* decode slice header (may change quant_scale) */
          slice_vert_pos_ext = getslicehdr();

          /* decode macroblock address increment */
          SNRMBAinc = getMBA();

          /* set current location */
          SNRMBA =
            ((slice_vert_pos_ext<<7) + (code&255) - 1)*mb_width + SNRMBAinc - 1;

          SNRMBAinc = 1; /* first macroblock in slice: not skipped */
        }
        else /* not startcode */
        {
          if (SNRMBA>=MBAmax)
          {
            if (!quiet)
              printf("Too many macroblocks in picture\n");
            return;
          }

          /* decode macroblock address increment */
          SNRMBAinc = getMBA();
        }
      }

      if (SNRMBA!=MBA)
      {
        /* streams out of sync */
        if (!quiet)
          printf("Cant't synchronize streams\n");
        return;
      }

      if (SNRMBAinc==1) /* not skipped */
      {
        macroblock_modes(&SNRmb_type, &dummy, &dummy,
          &dummy, &dummy, &dummy, &dummy, &dummy,
          &SNRdct_type);

        if (SNRmb_type & MB_PATTERN)
          dct_type = SNRdct_type;

        if (SNRmb_type & MB_QUANT)
        {
          qs = getbits(5);
          ld->quant_scale =
            ld->qscale_type ? non_linear_mquant_table[qs] : qs<<1;
        }

        /* macroblock_pattern */
        if (SNRmb_type & MB_PATTERN)
        {
          SNRcbp = getCBP();

          if (chroma_format==CHROMA422)
            SNRcbp = (SNRcbp<<2) | getbits(2); /* coded_block_pattern_1 */
          else if (chroma_format==CHROMA444)
            SNRcbp = (SNRcbp<<6) | getbits(6); /* coded_block_pattern_2 */
        }
        else
          SNRcbp = 0;

        /* decode blocks */
        for (comp=0; comp<blk_cnt; comp++)
        {
          clearblock(comp);

          if (SNRcbp & (1<<(blk_cnt-1-comp)))
            getmpg2interblock(comp);
        }
      }
      else /* SNRMBAinc!=1: skipped macroblock */
      {
        for (comp=0; comp<blk_cnt; comp++)
          clearblock(comp);
      }

      ld = &base;
    }

    /* pixel coordinates of top left corner of current macroblock */
    bx = 16*(MBA%mb_width);
    by = 16*(MBA/mb_width);

    /* motion compensation */
    if (!(mb_type & MB_INTRA))
      reconstruct(bx,by,mb_type,motion_type,PMV,mv_field_sel,dmvector,
        stwtype);

    if (base.scalable_mode==SC_DP)
      ld = &base;

    /* copy or add block data into picture */
    for (comp=0; comp<blk_cnt; comp++)
    {
      if ((cbp|SNRcbp) & (1<<(blk_cnt-1-comp)))
      {
        if (twostreams && enhan.scalable_mode==SC_SNR &&
            SNRcbp & (1<<(blk_cnt-1-comp)))
          sumblock(comp); /* add SNR enhancement layer data to base layer */

        /* inverse DCT */
        idct(ld->block[comp]);

        addblock(comp,bx,by,dct_type,(mb_type & MB_INTRA)==0);
      }
    }

    /* advance to next macroblock */
    MBA++;
    MBAinc--;

    if (twostreams && enhan.scalable_mode==SC_SNR)
    {
      SNRMBA++;
      SNRMBAinc--;
    }
  }
}


static void macroblock_modes(pmb_type,pstwtype,pstwclass,
  pmotion_type,pmv_count,pmv_format,pdmv,pmvscale,pdct_type)
  int *pmb_type, *pstwtype, *pstwclass;
  int *pmotion_type, *pmv_count, *pmv_format, *pdmv, *pmvscale;
  int *pdct_type;
{
  int mb_type;
  int stwtype, stwcode, stwclass;
  int motion_type, mv_count, mv_format, dmv, mvscale;
  int dct_type;
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
    if (pict_struct==FRAME_PICTURE) /* frame_motion_type */
    {
      motion_type = frame_pred_dct ? MC_FRAME : getbits(2);
#ifdef TRACE
      if (!frame_pred_dct && trace)
      {
        printf("frame_motion_type (");
        printbits(motion_type,2,2);
        printf("): %s\n",motion_type==MC_FIELD?"Field":
                         motion_type==MC_FRAME?"Frame":
                         motion_type==MC_DMV?"Dual_Prime":"Invalid");
      }
#endif
    }
    else /* field_motion_type */
    {
      motion_type = getbits(2);
#ifdef TRACE
      if (trace)
      {
        printf("field_motion_type (");
        printbits(motion_type,2,2);
        printf("): %s\n",motion_type==MC_FIELD?"Field":
                         motion_type==MC_16X8?"16x8 MC":
                         motion_type==MC_DMV?"Dual_Prime":"Invalid");
      }
#endif
    }
  }
  else if ((mb_type & MB_INTRA) && conceal_mv)
  {
    /* concealment motion vectors */
    motion_type = (pict_struct==FRAME_PICTURE) ? MC_FRAME : MC_FIELD;
  }

  /* derive mv_count, mv_format and dmv, (table 6-17, 6-18) */
  if (pict_struct==FRAME_PICTURE)
  {
    mv_count = (motion_type==MC_FIELD && stwclass<2) ? 2 : 1;
    mv_format = (motion_type==MC_FRAME) ? MV_FRAME : MV_FIELD;
  }
  else
  {
    mv_count = (motion_type==MC_16X8) ? 2 : 1;
    mv_format = MV_FIELD;
  }

  dmv = (motion_type==MC_DMV); /* dual prime */

  /* field mv predictions in frame pictures have to be scaled */
  mvscale = ((mv_format==MV_FIELD) && (pict_struct==FRAME_PICTURE));

  /* get dct_type (frame DCT / field DCT) */
  dct_type = (pict_struct==FRAME_PICTURE)
             && (!frame_pred_dct)
             && (mb_type & (MB_PATTERN|MB_INTRA))
             ? getbits(1)
             : 0;

#ifdef TRACE
  if (trace  && (pict_struct==FRAME_PICTURE)
             && (!frame_pred_dct)
             && (mb_type & (MB_PATTERN|MB_INTRA)))
    printf("dct_type (%d): %s\n",dct_type,dct_type?"Field":"Frame");
#endif

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


/* set block to zero */

static void clearblock(comp)
int comp;
{
  int *bp;
  int i;

  bp = (int *)ld->block[comp];

  for (i=0; i<8; i++)
  {
    bp[0] = bp[1] = bp[2] = bp[3] = 0;
    bp += 4;
  }
}


/* add SNR enhancement layer block data to base layer */

static void sumblock(comp)
int comp;
{
  short *bp1, *bp2;
  int i;

  bp1 = base.block[comp];
  bp2 = enhan.block[comp];

  for (i=0; i<64; i++)
    *bp1++ += *bp2++;
}


/* limit coefficients to -2048..2047 */

/* move/add 8x8-Block from block[comp] to refframe */

static void addblock(comp,bx,by,dct_type,addflag)
int comp,bx,by,dct_type,addflag;
{
  int cc,i, j, iincr;
  unsigned char *rfp;
  short *bp;
  unsigned char *clp2;

  clp2 = clp;

  if (!addflag)
    clp2 += 128;

  cc = (comp<4) ? 0 : (comp&1)+1; /* color component index */

  if (cc==0)
  {
    /* luminance */

    if (pict_struct==FRAME_PICTURE)
      if (dct_type)
      {
        /* field DCT coding */
        rfp = newframe[0]
              + coded_picture_width*(by+((comp&2)>>1)) + bx + ((comp&1)<<3);
        iincr = (coded_picture_width<<1);
      }
      else
      {
        /* frame DCT coding */
        rfp = newframe[0]
              + coded_picture_width*(by+((comp&2)<<2)) + bx + ((comp&1)<<3);
        iincr = coded_picture_width;
      }
    else
    {
      /* field picture */
      rfp = newframe[0]
            + (coded_picture_width<<1)*(by+((comp&2)<<2)) + bx + ((comp&1)<<3);
      iincr = (coded_picture_width<<1);
    }
  }
  else
  {
    /* chrominance */

    /* scale coordinates */
    if (chroma_format!=CHROMA444)
      bx >>= 1;
    if (chroma_format==CHROMA420)
      by >>= 1;
    if (pict_struct==FRAME_PICTURE)
    {
      if (dct_type && (chroma_format!=CHROMA420))
      {
        /* field DCT coding */
        rfp = newframe[cc]
              + chrom_width*(by+((comp&2)>>1)) + bx + (comp&8);
        iincr = (chrom_width<<1);
      }
      else
      {
        /* frame DCT coding */
        rfp = newframe[cc]
              + chrom_width*(by+((comp&2)<<2)) + bx + (comp&8);
        iincr = chrom_width;
      }
    }
    else
    {
      /* field picture */
      rfp = newframe[cc]
            + (chrom_width<<1)*(by+((comp&2)<<2)) + bx + (comp&8);
      iincr = (chrom_width<<1);
    }
  }

  bp = ld->block[comp];

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
