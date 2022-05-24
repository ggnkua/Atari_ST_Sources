/*
 *	PLAYMPEG
 *	Martin Griffiths 1995.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plaympeg.h"
#include "proto.h"

/* decode one frame or field picture */

void getpicture(framenum)
INT32 framenum;
{
  INT32 i;

  for (i=0; i<3; i++)
  {
    if (pict_type==B_TYPE)
      newframe[i] = auxframe[i];
    else
    {
      unsigned char *tmp;
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

void putlast(INT32 framenum)
{	dither(refframe);
}

static INT32 bx, by;
INT32 dc_dct_pred[3];

/* decode all macroblocks of the current picture */

static void getMBs(INT32 framenum)
{	INT32 MBA, MBAmax, MBAinc, mb_type, cbp;
	UINT32 code;
	INT32 PMV[2][2][2];
	INT32 stwtype;

  	MBAmax = mb_width*mb_height; /* number of macroblocks per picture */
	MBA = 0; /* macroblock address */
	MBAinc = 0;
	fault=0;

	for (;;)
	{ 	if (MBAinc==0)
    		{	if (!showbits23() || fault) /* startcode or fault */
      			{
resync: /* if fault: resynchronize to next startcode */
        			fault = 0;
        			if (MBA>=MBAmax)
          				return; /* all macroblocks decoded */

        			startcode();
        			code = showbits32();
        			if (code<SLICE_MIN_START || code>SLICE_MAX_START)
        			{ /* only slice headers are allowed in picture_data */
          				if (!quiet)
            					printf("Premature end of picture\n");
          				return;
        			}
        			flushbits(32);

        			getslicehdr(); /* decode slice header (may change quant_scale) */
        			if (fault) goto resync;
        			MBAinc = getMBA(); /* decode macroblock address increment */
        			if (fault) goto resync;
        			MBA = ((code&255) - 1)*mb_width + MBAinc - 1; /* set current location */
        			MBAinc = 1; /* first macroblock in slice: not skipped */
     				dc_dct_pred[0]=dc_dct_pred[1]=dc_dct_pred[2]=0; /* reset all DC coefficient and motion vector predictors */
        			PMV[0][0][0]=PMV[0][0][1]=PMV[1][0][0]=PMV[1][0][1]=0;
        			PMV[0][1][0]=PMV[0][1][1]=PMV[1][1][0]=PMV[1][1][1]=0;
      			} else /* neither startcode nor fault */
      			{	if (MBA>=MBAmax)
        			{	if (!quiet)
            					printf("Too many macroblocks in picture\n");
          				return;
        			}
       				MBAinc = getMBA(); /* decode macroblock address increment */
        			if (fault) goto resync;
      			}
    		}

    		if (MBA>=MBAmax)
    		{ /* MBAinc points beyond picture dimensions */
      			if (!quiet)
        			printf("Too many macroblocks in picture\n");
      			return;
    		}

    		if (MBAinc==1) /* not skipped */
    		{	mb_type=getMBtype();
      			stwtype =0;
      			if (mb_type & MB_QUANT)
        			ld_quant_scale = getbits(5);
      			if (mb_type & MB_FORWARD)
      			{ 	motion_vector(PMV[0][0],forw_r_size,forw_r_size,full_forw);
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

      			bx = 16*(MBA%mb_width);
 			by = 16*(MBA/mb_width);
			if ((mb_type & MB_INTRA))
      			{	
				getintrablocks(cbp);

	        		PMV[0][0][0]=PMV[0][0][1]=PMV[1][0][0]=PMV[1][0][1]=0;
       				PMV[0][1][0]=PMV[0][1][1]=PMV[1][1][0]=PMV[1][1][1]=0;
				if (fault) goto resync;
			} else
  		   	{	memset(ld_block,0,6*sizeof(INT16)*64);
			 	if (cbp & (1<<(5-0)))
              				getinterblock(0);
        			if (cbp & (1<<(5-1)))
              				getinterblock(1);
        			if (cbp & (1<<(5-2)))
              				getinterblock(2);
        			if (cbp & (1<<(5-3)))
              				getinterblock(3);
        			if (cbp & (1<<(5-4)))
              				getinterblock(4);
       			 	if (cbp & (1<<(5-5)))
              				getinterblock(5);
				
        			dc_dct_pred[0]=dc_dct_pred[1]=dc_dct_pred[2]=0;
     		 		if ((pict_type==P_TYPE) && !(mb_type & (MB_FORWARD|MB_INTRA)))
      				{ /* non-intra mb without forward mv in a P picture */
        				PMV[0][0][0]=PMV[0][0][1]=PMV[1][0][0]=PMV[1][0][1]=0;
				}
				if (fault) goto resync;
        			reconstruct(bx,by,mb_type,PMV,stwtype);
       			 	if (cbp & (1<<(5-0)))
      				{	idct(ld_block[0]); 
       	   				addblock(0);
				}
       			 	if (cbp & (1<<(5-1)))
      				{	idct(ld_block[1]); 
       	   				addblock(1);
				}
       			 	if (cbp & (1<<(5-2)))
      				{	idct(ld_block[2]); 
       	   				addblock(2);
				}
       			 	if (cbp & (1<<(5-3)))
      				{	idct(ld_block[3]); 
       	   				addblock(3);
				}
       			 	if (cbp & (1<<(5-4)))
      				{	idct(ld_block[4]); 
       	   				addblock(4);
				}
       			 	if (cbp & (1<<(5-5)))
      				{	idct(ld_block[5]); 
       	   				addblock(5);
				}
			}

    		} else /* MBAinc!=1: skipped macroblock */
    		{ 	dc_dct_pred[0]=dc_dct_pred[1]=dc_dct_pred[2]=0; /* reset intra_dc predictors */
      			if (pict_type==P_TYPE) /* reset motion vector predictors */
        			PMV[0][0][0]=PMV[0][0][1]=PMV[1][0][0]=PMV[1][0][1]=0;
      			/* skipped I are spatial-only predicted, */
      			/* skipped P and B are temporal-only predicted */
      			stwtype = (pict_type==I_TYPE) ? 8 : 0;
	  		cbp = 0;
	  		mb_type &= ~MB_INTRA;
      			bx = 16*(MBA%mb_width);
 			by = 16*(MBA/mb_width);
        		reconstruct(bx,by,mb_type,PMV,stwtype);
    		}
    		MBA++;
    		MBAinc--; /* advance to next macroblock */
	}
}


/* limit coefficients to -2048..2047 */
/* move/add 8x8-Block from block[comp] to refframe */

static void addblock(INT32 comp)
{
  INT32 i, iincr;
  INT16 *bp=&ld_block[comp][0];
  unsigned char *rfp;
  unsigned char *clp2= clp;

  if (comp<4)
  {
        rfp = newframe[0] + coded_picture_width*(by+((comp&2)<<2)) + bx + ((comp&1)<<3);
        iincr = coded_picture_width;
  }
  else
  {
        rfp = newframe[(comp &1)+1] + coded_picture_width*((by>>1)+((comp&2)<<2)) + (bx>>1) + (comp&8);
        iincr = coded_picture_width;
  }

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
}

void moveblock(INT32 comp)
{ 	INT32 i, iincr;
  	INT16 *bp=&ld_block[comp][0];
  	unsigned char *rfp;
  	unsigned char *clp2= clp+128;
	if (comp<4)
	{ 	rfp = newframe[0] + coded_picture_width*(by+((comp&2)<<2)) + bx + ((comp&1)<<3);
        	iincr = coded_picture_width;
  	} else
  	{ 	rfp = newframe[(comp &1)+1]+(coded_picture_width*(by>>2))+(bx>>1);
        	iincr = coded_picture_width>>1; 
    	}
		for (i=0; i<8; i++)
    		{ 	rfp[0] = clp2[bp[0]];
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
