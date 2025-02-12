 	/* getpic.c, picture decoding                                               */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"

/* decode all macroblocks of the current picture */

void getpicture()
{
  int code,comp,MBA,MBAmax,MBAinc,mb_type,cbp,bx,by,i;
  int dc_dct_pred[3];

  MBAmax = mb_width*mb_height;
  MBA = 0; MBAinc = 0;  fault=0;
  for (;;)
  {
    if (MBAinc==0)
    {
      if ((!showbits(23)) || fault) /* startcode or fault */
      {
resync: fault = 0;
        if (MBA>=MBAmax)
	{  dither();
           return; /* all macroblocks decoded */
        }
        startcode();	
        flushbits(24);
        code = getbits(8)-1;
        getslicehdr();			/* decode slice header (may change quant_scale) */
        MBAinc = getMBA();	        /* decode macroblock address increment */
        MBA = (code*mb_width)+MBAinc-1;
        MBAinc = 1; /* first macroblock in slice: not skipped */
 	dc_dct_pred[0]=0;
	dc_dct_pred[1]=0;
	dc_dct_pred[2]=0;

      }
      else 				/* neither startcode nor fault */
        MBAinc = getMBA();		/* decode macroblock address increment */
    }

    if (MBA>=MBAmax)			/* MBAinc beyond picture dimensions */
      return;

    by = (MBA / mb_width)*16;
    bx = (MBA % mb_width)*16;	       /* pixel coordinates */

    if (MBAinc==1) /* not skipped */
    {
      mb_type = getMBtype();
      if (mb_type & MB_PATTERN)		/* macroblock_pattern */
      	cbp = getCBP();
       else
      	cbp = 0x3f;

      for (comp=0,code=32; comp<6; comp++,code >>= 1)
      {	if (cbp & code)
        {  unsigned char *rfp;
   	   short *bp= (short *) ld_block;
	   getintrablock(comp,dc_dct_pred);
           if (fault) goto resync;
           ASMIDCT(bp);
  	   if (comp < 4)
       	   {	
        	rfp = lumframe+(coded_picture_width*(by+((comp&2)<<2))) + bx+((comp&1)<<3);
                for (i=0; i<8; i++)
	        {	rfp[0] = bp[0];
             		rfp[1] = bp[1];
             		rfp[2] = bp[2];
             		rfp[3] = bp[3];
             		rfp[4] = bp[4];
             		rfp[5] = bp[5];
             		rfp[6] = bp[6];
             		rfp[7] = bp[7];
             		rfp+= coded_picture_width;
             		bp += 8;
           	}

 	   }  else 
  	   {	rfp = chromframe+(coded_picture_width*(by>>1))+6-comp+bx;
           	for (i=0; i<8; i++)
		{	rfp[0] = bp[0];
			rfp[2] = bp[1];
			rfp[4] = bp[2];	
			rfp[6] = bp[3];
			rfp[8] = bp[4];
			rfp[10] =bp[5];
			rfp[12] =bp[6];
			rfp[14] =bp[7];
             		rfp+= coded_picture_width;
	             	bp += 8;
		}
  	   }  
	}
ere:;
      }
    }
    else /* MBAinc!=1: skipped macroblock */
 	{  	dc_dct_pred[0]=0;
		dc_dct_pred[1]=0;
		dc_dct_pred[2]=0;
	}

    MBA++;    MBAinc--;
  }
}
