/*
 *	PLAYMPEG.
 *	Martin Griffiths 1995.
 */

#include <stdio.h>
#include <stdlib.h>
#include "plaympeg.h"

static void calcMV _ANSI_ARGS_((INT32 *pred, INT32 r_size, INT32 motion_code,
  INT32 motion_r, INT32 full_pel_vector));

/* get and decode motion vector and differential motion vector */

void motion_vector(PMV,dmvector, h_r_size,v_r_size,full_pel_vector)
INT32 *PMV;
INT32 *dmvector;
INT32 h_r_size;
INT32 v_r_size;
INT32 full_pel_vector; /* MPEG-1 only */
{
  INT32 motion_code,motion_r;

  motion_code = getMV();
  motion_r = (h_r_size!=0 && motion_code!=0) ? getbits(h_r_size) : 0;

  calcMV(&PMV[0],h_r_size,motion_code,motion_r,full_pel_vector);

  motion_code = getMV();
  motion_r = (v_r_size!=0 && motion_code!=0) ? getbits(v_r_size) : 0;

  calcMV(&PMV[1],v_r_size,motion_code,motion_r,full_pel_vector);

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


