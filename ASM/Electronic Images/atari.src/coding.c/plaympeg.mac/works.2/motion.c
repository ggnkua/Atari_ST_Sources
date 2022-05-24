/*
 *	PLAYMPEG.
 *	Martin Griffiths 1995.
 */

#include <stdio.h>
#include <stdlib.h>
#include "plaympeg.h"
#include "proto.h"

/* private prototypes */
static void calcMV _ANSI_ARGS_((INT32 *pred, INT32 r_size, INT32 motion_code,
  INT32 motion_r, INT32 full_pel_vector));

void motion_vectors(PMV,dmvector,
  mv_field_sel,s,mv_count,mv_format,h_r_size,v_r_size,dmv,mvscale)
INT32 PMV[2][2][2];
INT32 dmvector[2];
INT32 mv_field_sel[2][2];
INT32 s, mv_count, mv_format, h_r_size, v_r_size, dmv, mvscale;
{
  if (mv_count==1)
  {
    if (mv_format==MV_FIELD && !dmv)
    {
      mv_field_sel[1][s] = mv_field_sel[0][s] = getbits(1);
    }

    motion_vector(PMV[0][s],dmvector,h_r_size,v_r_size,dmv,mvscale,0);

    /* update other motion vector predictors */
    PMV[1][s][0] = PMV[0][s][0];
    PMV[1][s][1] = PMV[0][s][1];
  }
  else
  {
    mv_field_sel[0][s] = getbits(1);
    motion_vector(PMV[0][s],dmvector,h_r_size,v_r_size,dmv,mvscale,0);

    mv_field_sel[1][s] = getbits(1);
    motion_vector(PMV[1][s],dmvector,h_r_size,v_r_size,dmv,mvscale,0);
  }
}

/* get and decode motion vector and differential motion vector */
void motion_vector(PMV,dmvector,
  h_r_size,v_r_size,dmv,mvscale,full_pel_vector)
INT32 *PMV;
INT32 *dmvector;
INT32 h_r_size;
INT32 v_r_size;
INT32 dmv; /* MPEG-2 only: get differential motion vectors */
INT32 mvscale; /* MPEG-2 only: field vector in frame pic */
INT32 full_pel_vector; /* MPEG-1 only */
{
  INT32 motion_code,motion_r;

  motion_code = getMV();
  motion_r = (h_r_size!=0 && motion_code!=0) ? getbits(h_r_size) : 0;

  calcMV(&PMV[0],h_r_size,motion_code,motion_r,full_pel_vector);

  if (dmv)
    dmvector[0] = getDMV();

  motion_code = getMV();
  motion_r = (v_r_size!=0 && motion_code!=0) ? getbits(v_r_size) : 0;

  if (mvscale)
    PMV[1] >>= 1; /* DIV 2 */

  calcMV(&PMV[1],v_r_size,motion_code,motion_r,full_pel_vector);

  if (mvscale)
    PMV[1] <<= 1;

  if (dmv)
    dmvector[1] = getDMV();

}

/* calculate motion vector component */
static void calcMV(pred,r_size,motion_code,motion_r,full_pel_vector)
INT32 *pred;
INT32 r_size, motion_code, motion_r, full_pel_vector;
{
  INT32 lim, vec;

  lim = 16<<r_size;
  vec = full_pel_vector ? (*pred >> 1) : (*pred);

  if (motion_code>0)
  {
    vec+= ((motion_code-1)<<r_size) + motion_r + 1;
    if (vec>=lim)
      vec-= lim + lim;
  }
  else if (motion_code<0)
  {
    vec-= ((-motion_code-1)<<r_size) + motion_r + 1;
    if (vec<-lim)
      vec+= lim + lim;
  }
  *pred = full_pel_vector ? (vec<<1) : vec;
}

void calc_DMV(DMV,dmvector,mvx,mvy)
INT32 DMV[][2];
INT32 *dmvector; /* differential motion vector */
INT32 mvx, mvy;  /* decoded mv components (always in field format) */
{
  if (pict_struct==FRAME_PICTURE)
  {
    if (topfirst)
    {
      /* vector for prediction of top field from bottom field */
      DMV[0][0] = ((mvx  +(mvx>0))>>1) + dmvector[0];
      DMV[0][1] = ((mvy  +(mvy>0))>>1) + dmvector[1] - 1;

      /* vector for prediction of bottom field from top field */
      DMV[1][0] = ((3*mvx+(mvx>0))>>1) + dmvector[0];
      DMV[1][1] = ((3*mvy+(mvy>0))>>1) + dmvector[1] + 1;
    }
    else
    {
      /* vector for prediction of top field from bottom field */
      DMV[0][0] = ((3*mvx+(mvx>0))>>1) + dmvector[0];
      DMV[0][1] = ((3*mvy+(mvy>0))>>1) + dmvector[1] - 1;

      /* vector for prediction of bottom field from top field */
      DMV[1][0] = ((mvx  +(mvx>0))>>1) + dmvector[0];
      DMV[1][1] = ((mvy  +(mvy>0))>>1) + dmvector[1] + 1;
    }
  }
  else
  {
    /* vector for prediction from field of opposite 'parity' */
    DMV[0][0] = ((mvx+(mvx>0))>>1) + dmvector[0];
    DMV[0][1] = ((mvy+(mvy>0))>>1) + dmvector[1];

    /* correct for vertical field shift */
    if (pict_struct==TOP_FIELD)
      DMV[0][1]--;
    else
      DMV[0][1]++;
  }
}

