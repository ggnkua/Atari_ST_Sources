/*
// sprite support heartland
*/

#include "hland.h"

const byte *egg_seq[] =
{ /* init egg animatie */
  /* 0 animatie */
  eggs+0*EGG_SIZE,
  eggs+1*EGG_SIZE,
  eggs+0*EGG_SIZE,
  eggs+1*EGG_SIZE,
  eggs+0*EGG_SIZE,
  eggs+1*EGG_SIZE,
  eggs+0*EGG_SIZE,
  eggs+1*EGG_SIZE,
  /* jump */
  eggs+2*EGG_SIZE,
  eggs+3*EGG_SIZE,
  eggs+4*EGG_SIZE,
  eggs+5*EGG_SIZE,
  eggs+6*EGG_SIZE,
  eggs+7*EGG_SIZE,
  eggs+8*EGG_SIZE,
  eggs+1*EGG_SIZE,
  /* rotation clockwise */
  eggs+32*EGG_SIZE,
  eggs+31*EGG_SIZE,
  eggs+30*EGG_SIZE,
  eggs+29*EGG_SIZE,
  eggs+28*EGG_SIZE,
  eggs+27*EGG_SIZE,
  eggs+26*EGG_SIZE,
  eggs+14*EGG_SIZE,
  /* walk right */
  eggs+14*EGG_SIZE,
  eggs+15*EGG_SIZE,
  eggs+16*EGG_SIZE,
  eggs+15*EGG_SIZE,
  eggs+14*EGG_SIZE,
  eggs+17*EGG_SIZE,
  eggs+18*EGG_SIZE,
  eggs+17*EGG_SIZE,
  /* walk left */
  eggs+9*EGG_SIZE,
  eggs+10*EGG_SIZE,
  eggs+11*EGG_SIZE,
  eggs+10*EGG_SIZE,
  eggs+9*EGG_SIZE,
  eggs+12*EGG_SIZE,
  eggs+13*EGG_SIZE,
  eggs+12*EGG_SIZE,
  /* rotation anti-clockwise */
  eggs+25*EGG_SIZE,
  eggs+24*EGG_SIZE,
  eggs+23*EGG_SIZE,
  eggs+22*EGG_SIZE,
  eggs+21*EGG_SIZE,
  eggs+20*EGG_SIZE,
  eggs+19*EGG_SIZE,
  eggs+9*EGG_SIZE,
};

const int egg_seq_select[16]=                /* egg animatie select */
{
  0,
  1*EGG_ANI_LEN, /*  1 = [JOY_UP] */ 
  1*EGG_ANI_LEN, /*  2 = [JOY_DOWN] */
  0,
  4*EGG_ANI_LEN, /*  4 = [JOY_LEFT] */
  5*EGG_ANI_LEN, /*  5 = [JOY_LEFT|JOY_UP] */
  5*EGG_ANI_LEN, /*  6 = [JOY_DOWN|JOY_LEFT] */
  0,
  3*EGG_ANI_LEN, /*  8 = [JOY_RIGHT] */
  2*EGG_ANI_LEN, /*  9 = [JOY_UP|JOY_RIGHT] */ 
  2*EGG_ANI_LEN, /* 10 = [JOY_RIGHT|JOY_DOWN] */
};

