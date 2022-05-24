/* idct.c, inverse fast discrete cosine transform                           */
/* this code assumes >> to be a two's-complement arithmetic */
/* right shift: (-2)>>1 == -1 , (-3)>>1 == -2               */

#include "types.h"

#define W1 2841 /* 2048*sqrt(2)*cos(1*pi/16) */
#define W2 2676 /* 2048*sqrt(2)*cos(2*pi/16) */
#define W3 2408 /* 2048*sqrt(2)*cos(3*pi/16) */
#define W5 1609 /* 2048*sqrt(2)*cos(5*pi/16) */
#define W6 1108 /* 2048*sqrt(2)*cos(6*pi/16) */
#define W7 565  /* 2048*sqrt(2)*cos(7*pi/16) */

void idct(block)
INT16 *block;
{
  INT32 x0, x1, x2, x3, x4, x5, x6, x7, x8;
  INT16 i;
  INT16 *blk = block;
  
  for (i=0; i<8; i++)
  {
    if (!((x1 = (INT32) blk[4]<<11) | (x2 = blk[6]) | (x3 = blk[2]) |
        (x4 = blk[1]) | (x5 = blk[7]) | (x6 = blk[5]) | (x7 = blk[3])))
    {
      blk[0]=blk[1]=blk[2]=blk[3]=blk[4]=blk[5]=blk[6]=blk[7]=blk[0]<<3;
    } else
    {
    x0 = ((INT32) blk[0]<<11) + 128; /* for proper rounding in the fourth stage */
    x8 = W7*(x4+x5);
    x4 = x8 + (W1-W7)*x4;
    x5 = x8 - (W1+W7)*x5;
    x8 = W3*(x6+x7);
    x6 = x8 - (W3-W5)*x6;
    x7 = x8 - (W3+W5)*x7;
    x8 = x0 + x1;
    x0 -= x1;
    x1 = W6*(x3+x2);
    x2 = x1 - (W2+W6)*x2;
    x3 = x1 + (W2-W6)*x3;
    x1 = x4 + x6;
    x4 -= x6;
    x6 = x5 + x7;
    x5 -= x7;
    x7 = x8 + x3;
    x8 -= x3;
    x3 = x0 + x2;
    x0 -= x2;
    x2 = (181*(x4+x5)+128)>>8;
    x4 = (181*(x4-x5)+128)>>8;
    blk[0] = (x7+x1)>>8;
    blk[7] = (x7-x1)>>8;
    blk[1] = (x3+x2)>>8;
    blk[6] = (x3-x2)>>8;
    blk[2] = (x0+x4)>>8;
    blk[5] = (x0-x4)>>8;
    blk[3] = (x8+x6)>>8;
    blk[4] = (x8-x6)>>8;
    }
  blk +=8;
  }
  
  blk = block;

  for (i=0; i<8; i++)
  {
   	x1 = (INT32) blk[8*4]<<8;
   	x2 = blk[8*6];
   	x3 = blk[8*2];
    x4 = blk[8*1];
    x5 = blk[8*7];
    x6 = blk[8*5];
    x7 = blk[8*3];
    x0 = ((INT32) blk[8*0]<<8) + 8192;
    x8 = W7*(x4+x5) + 4;
    x4 = (x8+(W1-W7)*x4)>>3;
    x5 = (x8-(W1+W7)*x5)>>3;
    x8 = W3*(x6+x7) + 4;
    x6 = (x8-(W3-W5)*x6)>>3;
    x7 = (x8-(W3+W5)*x7)>>3;
    x8 = x0 + x1;
    x0 -= x1;
    x1 = W6*(x3+x2) + 4;
    x2 = (x1-(W2+W6)*x2)>>3;
    x3 = (x1+(W2-W6)*x3)>>3;
    x1 = x4 + x6;
    x4 -= x6;
    x6 = x5 + x7;
    x5 -= x7;
    x7 = x8 + x3;
    x8 -= x3;
    x3 = x0 + x2;
    x0 -= x2;
    x2 = (181*(x4+x5)+128)>>8;
    x4 = (181*(x4-x5)+128)>>8;
    blk[8*0] = (x7+x1)>>14;
    blk[8*7] = (x7-x1)>>14;
    blk[8*1] = (x3+x2)>>14;
    blk[8*6] = (x3-x2)>>14;
    blk[8*2] = (x0+x4)>>14;
    blk[8*5] = (x0-x4)>>14;
    blk[8*3] = (x8+x6)>>14;
    blk[8*4] = (x8-x6)>>14;
    blk++;
  }

}

