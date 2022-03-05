#include <stdio.h>
#include <sys/types.h>
#include <osbind.h>
#include <tos.h>

#include "include/system.h"
#include "include/blit.h"

typedef int bool; 

void rotate (gfxCtx *in,System_screen *screen);
void plot (u_short x, u_short y, u_short val, u_short *dst);
void mirror_x (u_short *src, u_short *dst);
void mirror_x_blitter (u_short *src, u_short *dst);
void scale2x_blitter (u_short *src, u_short *dst);
void scale2x2y_blitter (u_short *src, u_short *dst, bool waitKey);

void sleep_frames(int delay);

/* beware hardcoded to 320*200 screen */
void duplicateScreen (u_short *src, u_short *dst);

#define TRUE 1
#define FALSE 0


static const u_short pal[]=
	{0x00,0x01,0x02,0x03,
	 0x04,0x05,0x06,0x07,
	 0x127,0x126,0x125,0x124,
	 0x123,0x122,0x121,0x120};

char fileName[]="C:\\BIN\\KINGTUT.PI1";

int main (void)
{
    System_Restore sys;
    System_screen screen;
    gfxCtx *kingTut=NULL;
	void   *oldStack=NULL;
	memset(&screen,0,sizeof(screen));
    oldStack = Super(NULL);
	if (oldStack == NULL)
	{
		printf("Failed to enter super\n");
		exit(-1);
	}
    system_save(&sys);

	if (SUCCESS == system_screen_init(LOW_REZ,
		                              (u_short *)&pal[0],
		                              &screen))
	{
		memset(screen.front,0,32000);
		memset(screen.back,0xff,32000);
		
		system_screen_show(&screen,ScreenFront);
		
		kingTut = gfx_ctx_init(320, 200);
		(void)gfx_ctx_init_file(fileName, kingTut);

		system_screen_show(&screen,ScreenBack);

		gfx_ctx_to_screen(kingTut, &screen, ScreenBack);
		Cconin();

		rotate(kingTut,&screen);
	}
	else
	{
		printf("system init failed \n");
		sleep_frames(50*4);
	}
	gfx_ctx_destroy(kingTut);

	system_restore(&sys);
	{
		u_char vidHi = *(u_char *)DBASEH;
		u_char vidM =  *(u_char *)DBASEM;
		u_char vidL =  *(u_char *)DBASEL;
		printf("High = %x, Med = %x, low = %x\n",vidHi,vidM,vidL);
	}

	printf("Complete\n");
	Super((void *)oldStack);
	return 0;
}

void sleep_frames(int delay)
{
	int i;
	for (i=0; i< delay; i++)
		Vsync();
}


void rotate (gfxCtx *in,System_screen *screen)
{
	u_short *s= screen->back;
	int i;

  	/* first of all wipe the screen to 0*/
  	/*memset(s,0x00,32000); */

	// plot columns of colours
	/*
	{
		int x,y;
		int val=0;
		for (y=0; y<100 ; y++)
		{
			for (x=0; x<320 ; x++)
			{
				plot (x, y, (val++)&0xf, s);
			}
		}

	}
	/* right... now we have something
	 * which can be used to test the scaler
	 * or inverter algorithm
	 */
#if 0
	for (i=0; i<(50*4); i++)
	{
		u_short c = 0x00f;
		u_short d = 0x000;
		Vsync();
		//memcpy(COLOR0,(u_short *)&c,sizeof(u_short));
		//mirror_x(in->screen,screen->back);
		mirror_x_blitter(in->screen,screen->back);

		//memcpy(COLOR0,(u_short *)&d,sizeof(u_short));
	}
#else
	mirror_x(in->screen,screen->back);
	Cconin();
	
	memcpy(screen->back,in->screen,32000);
	memcpy(screen->front,in->screen,32000); /* I want a back up :) */
	
	Cconin();
	
	mirror_x_blitter(in->screen,screen->back);
	Cconin();
	
	scale2x_blitter(in->screen,screen->back);
	memcpy(in->screen,screen->back,32000); /* copy scaled version to work buffer */
	Cconin();
	
	scale2x_blitter(in->screen,screen->back); /* now we're at 4x scale on x */
	memcpy(in->screen,screen->back,32000); /* copy scaled version again to work buffer */
	Cconin();
	
	scale2x_blitter(in->screen,screen->back); /* now we're at 8x scale on x */
	Cconin();

	/* Now do above with 2x X and 2x y scalng */
	memcpy(in->screen,screen->front,32000); /* unscaled version back again */
	memset(screen->back,0,32000);
	scale2x2y_blitter(in->screen,screen->back,TRUE);
	Cconin();
	
	memcpy(in->screen,screen->back,32000); /* copy scaled version again to work buffer */
	scale2x2y_blitter(in->screen,screen->back,TRUE); /* 4x */
	Cconin();
	
	memcpy(in->screen,screen->back,32000); /* copy scaled version again to work buffer */
	scale2x2y_blitter(in->screen,screen->back,TRUE); /* 8x */
	Cconin();
	
	memcpy(in->screen,screen->back,32000); /* copy scaled version again to work buffer */
	scale2x2y_blitter(in->screen,screen->back,TRUE); /* 16x */
	Cconin();
	
	memcpy(in->screen,screen->back,32000); /* copy scaled version again to work buffer */
	scale2x2y_blitter(in->screen,screen->back,TRUE); /* 32x :) */
	Cconin();
	
	memcpy(in->screen,screen->back,32000); /* copy scaled version again to work buffer */
	scale2x2y_blitter(in->screen,screen->back,TRUE); /* 64x :) */
	Cconin();
	
	/* Now do above with 2x X and 2x y scalng as an anim */
	memcpy(in->screen,screen->front,32000); /* unscaled version back again */
	memset(screen->back,0,32000);
	Vsync();
	scale2x2y_blitter(in->screen,screen->back,FALSE);
	
	duplicateScreen(screen->back,in->screen); /* copy scaled version again to work buffer */
	Vsync();
	scale2x2y_blitter(in->screen,screen->back,FALSE); /* 4x */
	
	
	duplicateScreen(screen->back,in->screen); /* copy scaled version again to work buffer */
	Vsync();
	scale2x2y_blitter(in->screen,screen->back,FALSE); /* 8x */
	
	
	duplicateScreen(screen->back,in->screen); /* copy scaled version again to work buffer */
	Vsync();
	scale2x2y_blitter(in->screen,screen->back,FALSE); /* 16x */
	
	
	duplicateScreen(screen->back,in->screen); /* copy scaled version again to work buffer */
	Vsync();
	scale2x2y_blitter(in->screen,screen->back,FALSE); /* 32x :) */
	
	
	duplicateScreen(screen->back,in->screen); /* copy scaled version again to work buffer */
	Vsync();
	scale2x2y_blitter(in->screen,screen->back,FALSE); /* 64x :) */
	Cconin();
		
#endif	

}

/* nibble masks for inversion

                   column
 src           1   2    3    4
0000 ; 0  -> 0000 0000 0000 0000  ; 0x0000
0001 ; 1  -> 1000 1000 1000 1000  ; 0x8888
0010 ; 2  -> 0100 0100 0100 0100  ; 0x4444
0011 ; 3  -> 1100 1100 1100 1100  ; 0xcccc
0100 ; 4  -> 0010 0010 0010 0010  ; 0x2222
0101 ; 5  -> 1010 1010 1010 1010  ; 0xaaaa
0110 ; 6  -> 0110 0110 0110 0110  ; 0x6666
0111 ; 7  -> 1110 1110 1110 1110  ; 0xeeee
1000 ; 8  -> 0001 0001 0001 0001  ; 0x1111
1001 ; 9  -> 1001 1001 1001 1001  ; 0x9999
1010 ; 10 -> 0101 0101 0101 0101  ; 0x5555
1011 ; 11 -> 1101 1101 1101 1101  ; 0xdddd
1100 ; 12 -> 0011 0011 0011 0011  ; 0x3333
1101 ; 13 -> 1011 1011 1011 1011  ; 0xbbbb
1110 ; 14 -> 0111 0111 0111 0111  ; 0x7777
1111 ; 15 -> 1111 1111 1111 1111  ; 0xffff

*/
static const u_short lookupInv[]=
{
0x0000,
0x8888,
0x4444,
0xcccc,
0x2222,
0xaaaa,
0x6666,
0xeeee,
0x1111,
0x9999,
0x5555,
0xdddd,
0x3333,
0xbbbb,
0x7777,
0xffff}; /* test to make sure smudge is used */




/* nibble masks for 2x scaling

                   column
 src           1   2    3    4
0000 ; 0  -> 0000 0000 0000 0000  ; 0x0000
0001 ; 1  -> 0000 0011 0000 0011  ; 0x0303
0010 ; 2  -> 0000 1100 0000 1100  ; 0x0c0c
0011 ; 3  -> 0000 1111 0000 1111  ; 0x0f0f
0100 ; 4  -> 0011 0000 0011 0000  ; 0x3030
0101 ; 5  -> 0011 0011 0011 0011  ; 0x3333
0110 ; 6  -> 0011 1100 0011 1100  ; 0x3c3c
0111 ; 7  -> 0011 1111 0011 1111  ; 0x3f3f
1000 ; 8  -> 1100 0000 1100 0000  ; 0xc0c0
1001 ; 9  -> 1100 0011 1100 0011  ; 0xc3c3
1010 ; 10 -> 1100 1100 1100 1100  ; 0xcccc
1011 ; 11 -> 1100 1111 1100 1111  ; 0xcfcf
1100 ; 12 -> 1111 0000 1111 0000  ; 0xf0f0
1101 ; 13 -> 1111 0011 1111 0011  ; 0xf3f3
1110 ; 14 -> 1111 1100 1111 1100  ; 0xfcfc
1111 ; 15 -> 1111 1111 1111 1111  ; 0xffff

*/

static const u_short lookupScl2x[]=
{
0x0000,
0x0303,
0x0c0c,
0x0f0f,
0x3030,
0x3333,
0x3c3c,
0x3f3f,
0xc0c0,
0xc3c3,
0xcccc,
0xcfcf,
0xf0f0,
0xf3f3,
0xfcfc,
0xffff
};


/* for masking off src data */
static const u_short columnMask[]=
{0xf000,0x0f00,0x00f0,0x000f};

/* slow as hell pixel plotter */

static const u_short lookupMask[]=
	{~32768,~16384,~8192,~4096,~2048,~1024,~512,~256,~128,~64,~32,~16,~8,~4,~2,~1};


static const u_short lookupSrc[]=
	{32768,16384,8192,4096,2048,1024,512,256,128,64,32,16,8,4,2,1};


void plot (u_short x, u_short y, u_short val, u_short *dst)
{
	u_short mod = x&0xf;

	u_short srcMask = lookupMask[mod];
	u_short srcDat = lookupSrc[mod];

	dst+= (y*160) /2;
	dst+= (x/16)*4;

	*dst     &= srcMask;
	*(dst+1) &= srcMask;
	*(dst+2) &= srcMask;
	*(dst+3) &= srcMask;

	if (val&0x01)
		*dst|=srcDat;

	if (val&0x02)
		*(dst+1)|=srcDat;

	if (val&0x04)
		*(dst+2) |=srcDat;

	if (val&0x08)
		*(dst+3)|=srcDat;

}

void mirror_x (u_short *src, u_short *dst)
{
	u_short dstX =319;
	u_short dstY =0;

	u_short wrkBuf;
	u_short wrkIdx;

	u_short pln0;
	u_short pln1;
	u_short pln2;
	u_short pln3;

	u_short x;
	u_short y;

	/* calc dst address
	 * dst points at last word
	 * src points at first word in the row
	 */

	dst+= (dstY*160) /2;

	dst+= ((dstX/16)*4);/* want to be on the first plane :) */

	for (y=0; y<200; y++)
	{
		/* screen width/ 16 pixels */
		for (x=0; x< (320>>4); x++)
		{
			pln0 = 0;
			pln1 = 0;
			pln2 = 0;
			pln3 = 0;

			/* read 4 bits of src plane 0, 0xf000 */
			wrkBuf = (*src)&0xf000;
			wrkIdx = wrkBuf>>12;
			pln0 = lookupInv[wrkIdx]&0xf; 				/* 0000 0000 0000 xxxx */

			/* read next 4 bits of src plane 0, 0x0f00 */
			wrkBuf = (*src)&0x0f00;
			wrkIdx = (wrkBuf>>8)&0xf;
			pln0 |= ((lookupInv[wrkIdx])&0x00f0); 	/* 0000 0000 xxxx 0000 */

			/* read next 4 bits of src plane 0, 0x00f0 */
			wrkBuf = (*src)&0x00f0;
			wrkIdx = (wrkBuf>>4)&0xf;
			pln0 |= (lookupInv[wrkIdx])&0x0f00; 	/* 0000 xxxx 0000 0000 */

			/* read last 4 bits of src plane 0, 0x000f */
			wrkBuf = (*src++)&0x000f;
			wrkIdx = wrkBuf&0xf;
			pln0 |= (lookupInv[wrkIdx])&0xf000;     /* xxxx 0000 0000 0000 */

			*(dst++) = pln0;


			/* read 4 bits of src plane 1, 0xf000 */
			wrkBuf = (*src)&0xf000;
			wrkIdx = wrkBuf>>12;
			pln1 = lookupInv[wrkIdx]&0xf;

			/* read next 4 bits of src plane 1, 0x0f00 */
			wrkBuf = (*src)&0x0f00;
			wrkIdx = (wrkBuf>>8)&0xf;
			pln1 |= (lookupInv[wrkIdx])&0x00f0;

			// read next 4 bits of src plane 1, 0x00f0
			wrkBuf = (*src)&0x00f0;
			wrkIdx = (wrkBuf>>4)&0xf;
			pln1 |= (lookupInv[wrkIdx])&0x0f00;

			// read last 4 bits of src plane 1, 0x000f
			wrkBuf = (*src++)&0x000f;
			wrkIdx = wrkBuf&0xf;
			pln1 |= (lookupInv[wrkIdx])&0xf000;

			*(dst++) = pln1;


			/* read 4 bits of src plane 2, 0xf000 */
			wrkBuf = (*src)&0xf000;
			wrkIdx = wrkBuf>>12;
			pln2 = lookupInv[wrkIdx]&0xf;

			/* read next 4 bits of src plane 2, 0x0f00 */
			wrkBuf = (*src)&0x0f00;
			wrkIdx = (wrkBuf>>8)&0xf;
			pln2 |= (lookupInv[wrkIdx])&0x00f0;

			/* read next 4 bits of src plane 2, 0x00f0 */
			wrkBuf = (*src)&0x00f0;
			wrkIdx = (wrkBuf>>4)&0xf;
			pln2 |= (lookupInv[wrkIdx])&0x0f00;

			/* read last 4 bits of src plane 2, 0x000f */
			wrkBuf = (*src++)&0x000f;
			wrkIdx = wrkBuf&0xf;
			pln2 |= (lookupInv[wrkIdx])&0xf000;

			*(dst++) = pln2;



			// read 4 bits of src plane 3, 0xf000
			wrkBuf = (*src)&0xf000;
			wrkIdx = wrkBuf>>12;
			pln3 = lookupInv[wrkIdx]&0xf;

			// read next 4 bits of src plane 3, 0x0f00
			wrkBuf = (*src)&0x0f00;
			wrkIdx = (wrkBuf>>8)&0xf;
			pln3 |= (lookupInv[wrkIdx])&0x00f0;

			// read next 4 bits of src plane 3, 0x00f0
			wrkBuf = (*src)&0x00f0;
			wrkIdx = (wrkBuf>>4)&0xf;
			pln3 |= (lookupInv[wrkIdx])&0x0f00;

			// read last 4 bits of src plane 3, 0x000f
			wrkBuf = (*src++)&0x000f;
			wrkIdx = wrkBuf&0xf;
			pln3 |= (lookupInv[wrkIdx])&0xf000;

			*(dst) = pln3; /* back to first plane of the prev 16 pixels */
			dst-=7; /* 6 to the dst address to be on last plane,
			         * subtract 6 to be on the first plane,
			         * subtract 8 to be on first plane prev 16 pixels
			         * in words is 7 :)
					 */
		}
		dst+=80*2; /* next row */
	}

}

/* If you want to printf debug any of these params make sure the
 * OS is not using the blitter.  If you don't then the printf
 * will trash the register setup when it uses the blitter
 * to draw characters on the screen :)
 */
void mirror_x_blitter (u_short *src, u_short *dst)
{
	u_short 		  dstX =319;
	u_short 		  dstY =0;

	volatile u_char  *blt_b;
	int 			  i,j;

	/* calc dst address
	 * dst points at last word (plane 0)
	 * src points at first word in the row (plane 0)
	 */
	dst+= (dstY*160) /2;
	dst+= ((dstX/16)*4);/* want to be on the first plane :) */

	/* kinda similar to the above but with the blitter */
#define OP_MODE 0x03

/* src == halftone lookup */
#define HOP_MODE 1

/* src copy, no halftone
 #define HOP_MODE 2
 */

#define Y_COUNT_VAL 200
	/* move this to a macro */
	blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);

    /* set up params which only need set once */
    
	/*memcpy(BLT_HALFTONE_RAM_W,&lookupInv[0],16*sizeof(u_short)); */
	{
		volatile short *p = (volatile short *)BLT_HALFTONE_RAM_W;  
		for (j=0; j<16; j++)
		{
			*(p++) = lookupInv[j];
		}
	}	


    *(volatile short *)BLT_SRC_X_INC_W = 8;
    *(volatile short *)BLT_DST_X_INC_W = -8;
	*(volatile short *)BLT_SRC_Y_INC_W = 8;
    *(volatile short *)BLT_DST_Y_INC_W = (160*2)-8;
	*(volatile u_char *)BLT_HOP_B = HOP_MODE;
	*(volatile u_char *)BLT_OP_B = OP_MODE;

	for(i=0;i<4;i++)
	{

		blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);

	    /* things below change each blit
	     * first blit does 0x000f pixels */
	    *(volatile u_short *)BLT_ENDMASK1_W = 0x000f;
	    *(volatile u_short *)BLT_ENDMASK2_W = 0x000f;
	    *(volatile u_short *)BLT_ENDMASK3_W = 0x000f;

	    *(volatile u_long *)BLT_SRC_ADDR_L = (u_long *)src;
	    *(volatile u_long *)BLT_DST_ADDR_L = (u_long *)dst;

		*(volatile u_char *)BLT_SKEW_B = 12; /* eg first four bits of src */

	    *(volatile u_short *)BLT_X_COUNT_W = 20;
	    *(volatile u_short *)BLT_Y_COUNT_W = Y_COUNT_VAL;

	    *(volatile u_char *)BLT_LINE_NUM_B = MLINESMUDGE|MLINEBUSY|MLINEHOG; /* eg first four bits of src */

		blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);
 
	    /* things below change each blit
	     * first blit does 0x000f pixels */
	    *(volatile u_short *)BLT_ENDMASK1_W = 0x00f0;
	    *(volatile u_short *)BLT_ENDMASK2_W = 0x00f0;
	    *(volatile u_short *)BLT_ENDMASK3_W = 0x00f0;

	    *(volatile u_long *)BLT_SRC_ADDR_L = (u_long *)src;
	    *(volatile u_long *)BLT_DST_ADDR_L = (u_long *)dst;

		*(volatile u_char *)BLT_SKEW_B = 8;

	    *(volatile u_short *)BLT_X_COUNT_W = 20; 		/* 1 plane for now */
	    *(volatile u_short *)BLT_Y_COUNT_W = Y_COUNT_VAL;//4;//40;       /* lines just to test */

	    *(volatile u_char *)BLT_LINE_NUM_B = MLINESMUDGE|MLINEBUSY|MLINEHOG; /* eg first four bits of src */

		// bits 8-12 plane 1
		/* move this to a macro */
		blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);

	    /* things below change each blit
	     * first blit does 0x000f pixels */
	    *(volatile u_short *)BLT_ENDMASK1_W = 0x0f00;
	    *(volatile u_short *)BLT_ENDMASK2_W = 0x0f00;
	    *(volatile u_short *)BLT_ENDMASK3_W = 0x0f00;

	    *(volatile u_long *)BLT_SRC_ADDR_L = (u_long *)src;
	    *(volatile u_long *)BLT_DST_ADDR_L = (u_long *)dst;

		*(volatile u_char *)BLT_SKEW_B = 4;

	    *(volatile u_short *)BLT_X_COUNT_W = 20; 		
	    *(volatile u_short *)BLT_Y_COUNT_W = Y_COUNT_VAL;

	    *(volatile u_char *)BLT_LINE_NUM_B = MLINESMUDGE|MLINEBUSY|MLINEHOG; /* eg first four bits of src */

		blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);

	    /* things below change each blit
	     * first blit does 0x000f pixels */
	    *(volatile u_short *)BLT_ENDMASK1_W = 0xf000;
	    *(volatile u_short *)BLT_ENDMASK2_W = 0xf000;
	    *(volatile u_short *)BLT_ENDMASK3_W = 0xf000;

	    *(volatile u_long *)BLT_SRC_ADDR_L = (u_long *)src;
	    *(volatile u_long *)BLT_DST_ADDR_L = (u_long *)dst;

		*(volatile u_char *)BLT_SKEW_B = 0;

	    *(volatile u_short *)BLT_X_COUNT_W = 20;
	    *(volatile u_short *)BLT_Y_COUNT_W = Y_COUNT_VAL;

	    *(volatile u_char *)BLT_LINE_NUM_B = MLINESMUDGE|MLINEBUSY|MLINEHOG;

		/* next plane on src and dst */
		src++;
		dst++;
	}

	/* move this to a macro */
	blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);

}


/* This is subtly different from above :) 
 * The source is twice the width of the dest (twice the height too!)
 * There is another blit at the end which doubles all
 * the y lines and steps through the src/dst 2 lines at a time
 */
void scale2x_blitter (u_short *src, u_short *dst)
{
	u_short 		  dstX =0;
	u_short 		  dstY =0;

	volatile u_char  *blt_b;
	int 			  i,j;

	/* calc dst address
	 * dst points at last word (plane 0)
	 * src points at first word in the row (plane 0)
	 */
	dst+= (dstY*160) /2;
	dst+= ((dstX/16)*4);/* want to be on the first plane :) */

	/* move this to a macro */
	blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);

    /* set up params which only need set once */
    /*memcpy(BLT_HALFTONE_RAM_W,&lookupInv[0],16*sizeof(u_short)); */
	{
		volatile short *p = (volatile short *)BLT_HALFTONE_RAM_W;  
		for (j=0; j<16; j++)
		{
			*(p++) = lookupScl2x[j];
		}
	}	

#define SCALE_X_COUNT (20/2)
#define SCALE_Y_COUNT_VAL 200


    *(volatile short *)BLT_SRC_X_INC_W = 8;
    *(volatile short *)BLT_DST_X_INC_W = 16;
	*(volatile short *)BLT_SRC_Y_INC_W = (160/2)+8; /* src half width of dest */
    *(volatile short *)BLT_DST_Y_INC_W = 16;      /* ie full screen */
	*(volatile u_char *)BLT_HOP_B = HOP_MODE;
	*(volatile u_char *)BLT_OP_B = OP_MODE;

	for(i=0;i<4;i++)
	{

		blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);

	    /* things below change each blit */
	    *(volatile u_short *)BLT_ENDMASK1_W = 0xff00;
	    *(volatile u_short *)BLT_ENDMASK2_W = 0xff00;
	    *(volatile u_short *)BLT_ENDMASK3_W = 0xff00;

	    *(volatile u_long *)BLT_SRC_ADDR_L = (u_long *)src;
	    *(volatile u_long *)BLT_DST_ADDR_L = (u_long *)dst;

		*(volatile u_char *)BLT_SKEW_B = 12; /* eg first four bits of src */

	    *(volatile u_short *)BLT_X_COUNT_W = SCALE_X_COUNT;
	    *(volatile u_short *)BLT_Y_COUNT_W = SCALE_Y_COUNT_VAL;

	    *(volatile u_char *)BLT_LINE_NUM_B = MLINESMUDGE|MLINEBUSY|MLINEHOG;

		blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);
 
	    /* things below change each blit
	     * first blit does 0x000f pixels */
	    *(volatile u_short *)BLT_ENDMASK1_W = 0x00ff;
	    *(volatile u_short *)BLT_ENDMASK2_W = 0x00ff;
	    *(volatile u_short *)BLT_ENDMASK3_W = 0x00ff;

	    *(volatile u_long *)BLT_SRC_ADDR_L = (u_long *)src;
	    *(volatile u_long *)BLT_DST_ADDR_L = (u_long *)dst;

		*(volatile u_char *)BLT_SKEW_B = 8;

	    *(volatile u_short *)BLT_X_COUNT_W = SCALE_X_COUNT;
	    *(volatile u_short *)BLT_Y_COUNT_W = SCALE_Y_COUNT_VAL;

	    *(volatile u_char *)BLT_LINE_NUM_B = MLINESMUDGE|MLINEBUSY|MLINEHOG;

		/* move this to a macro */
		blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);

	    /* things below change each blit
	     * first blit does 0x000f pixels */
	    *(volatile u_short *)BLT_ENDMASK1_W = 0xff00;
	    *(volatile u_short *)BLT_ENDMASK2_W = 0xff00;
	    *(volatile u_short *)BLT_ENDMASK3_W = 0xff00;

	    *(volatile u_long *)BLT_SRC_ADDR_L = (u_long *)src;
	    *(volatile u_long *)BLT_DST_ADDR_L = (u_long *)dst+(8/4);

		*(volatile u_char *)BLT_SKEW_B = 4;

	    *(volatile u_short *)BLT_X_COUNT_W = SCALE_X_COUNT; 		
	    *(volatile u_short *)BLT_Y_COUNT_W = SCALE_Y_COUNT_VAL;

	    *(volatile u_char *)BLT_LINE_NUM_B = MLINESMUDGE|MLINEBUSY|MLINEHOG; /* eg first four bits of src */

		blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);

	    /* things below change each blit
	     * first blit does 0x000f pixels */
	    *(volatile u_short *)BLT_ENDMASK1_W = 0x00ff;
	    *(volatile u_short *)BLT_ENDMASK2_W = 0x00ff;
	    *(volatile u_short *)BLT_ENDMASK3_W = 0x00ff;

	    *(volatile u_long *)BLT_SRC_ADDR_L = (u_long *)src;
	    *(volatile u_long *)BLT_DST_ADDR_L = (u_long *)dst+(8/4);

		*(volatile u_char *)BLT_SKEW_B = 0;

	    *(volatile u_short *)BLT_X_COUNT_W = SCALE_X_COUNT;
	    *(volatile u_short *)BLT_Y_COUNT_W = SCALE_Y_COUNT_VAL;

	    *(volatile u_char *)BLT_LINE_NUM_B = MLINESMUDGE|MLINEBUSY|MLINEHOG;

		/* next plane on src and dst */
		src++;
		dst++;
	}

	/* move this to a macro */
	blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);

}


typedef enum
{
	Scale_X_Count     = 20/2,
	Scale_Y_Count	  =	100
};

/* Like above but scales by 2 on x and y */
void scale2x2y_blitter(u_short *src, u_short *dst, bool waitKey)
{
	u_short 		  dstX =0;
	u_short 		  dstY =0;

	volatile u_char  *blt_b;
	int 			  i,j;

	u_short *srcYScale = dst; 
	u_short *dstYScale = dst+(160/2);

	/* calc dst address
	 * dst points at last word (plane 0)
	 * src points at first word in the row (plane 0)
	 */
	dst+= (dstY*160) /2;
	dst+= ((dstX/16)*4);/* want to be on the first plane :) */



	/* move this to a macro */
	blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);

    /* set up params which only need set once */
    /*memcpy(BLT_HALFTONE_RAM_W,&lookupInv[0],16*sizeof(u_short)); */
	{
		volatile short *p = (volatile short *)BLT_HALFTONE_RAM_W;  
		for (j=0; j<16; j++)
		{
			*(p++) = lookupScl2x[j];
		}
	}	

    *(volatile short *)BLT_SRC_X_INC_W = 8;
    *(volatile short *)BLT_DST_X_INC_W = 16;
	*(volatile short *)BLT_SRC_Y_INC_W = ((160/2)+8); /* src half width of dest */
    *(volatile short *)BLT_DST_Y_INC_W = 16+160;
	*(volatile u_char *)BLT_HOP_B = HOP_MODE;
	*(volatile u_char *)BLT_OP_B = OP_MODE;

	for(i=0;i<4;i++)
	{

		blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);

	    /* things below change each blit */
	    *(volatile u_short *)BLT_ENDMASK1_W = 0xff00;
	    *(volatile u_short *)BLT_ENDMASK2_W = 0xff00;
	    *(volatile u_short *)BLT_ENDMASK3_W = 0xff00;

	    *(volatile u_long *)BLT_SRC_ADDR_L = (u_long *)src;
	    *(volatile u_long *)BLT_DST_ADDR_L = (u_long *)dst;

		*(volatile u_char *)BLT_SKEW_B = 12; /* eg first four bits of src */

	    *(volatile u_short *)BLT_X_COUNT_W = Scale_X_Count;
	    *(volatile u_short *)BLT_Y_COUNT_W = Scale_Y_Count;

	    *(volatile u_char *)BLT_LINE_NUM_B = MLINESMUDGE|MLINEBUSY|MLINEHOG;

		blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);
 
	    /* things below change each blit
	     * first blit does 0x000f pixels */
	    *(volatile u_short *)BLT_ENDMASK1_W = 0x00ff;
	    *(volatile u_short *)BLT_ENDMASK2_W = 0x00ff;
	    *(volatile u_short *)BLT_ENDMASK3_W = 0x00ff;

	    *(volatile u_long *)BLT_SRC_ADDR_L = (u_long *)src;
	    *(volatile u_long *)BLT_DST_ADDR_L = (u_long *)dst;

		*(volatile u_char *)BLT_SKEW_B = 8;

	    *(volatile u_short *)BLT_X_COUNT_W = Scale_X_Count;
	    *(volatile u_short *)BLT_Y_COUNT_W = Scale_Y_Count;

	    *(volatile u_char *)BLT_LINE_NUM_B = MLINESMUDGE|MLINEBUSY|MLINEHOG; /* eg first four bits of src */

		blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);

	    /* things below change each blit
	     * first blit does 0x000f pixels */
	    *(volatile u_short *)BLT_ENDMASK1_W = 0xff00;
	    *(volatile u_short *)BLT_ENDMASK2_W = 0xff00;
	    *(volatile u_short *)BLT_ENDMASK3_W = 0xff00;

	    *(volatile u_long *)BLT_SRC_ADDR_L = (u_long *)src;
	    *(volatile u_long *)BLT_DST_ADDR_L = (u_long *)dst+(8/4);

		*(volatile u_char *)BLT_SKEW_B = 4;

	    *(volatile u_short *)BLT_X_COUNT_W = Scale_X_Count; 		
	    *(volatile u_short *)BLT_Y_COUNT_W = Scale_Y_Count;

	    *(volatile u_char *)BLT_LINE_NUM_B = MLINESMUDGE|MLINEBUSY|MLINEHOG; 

		blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);

	    /* things below change each blit
	     * first blit does 0x000f pixels */
	    *(volatile u_short *)BLT_ENDMASK1_W = 0x00ff;
	    *(volatile u_short *)BLT_ENDMASK2_W = 0x00ff;
	    *(volatile u_short *)BLT_ENDMASK3_W = 0x00ff;

	    *(volatile u_long *)BLT_SRC_ADDR_L = (u_long *)src;
	    *(volatile u_long *)BLT_DST_ADDR_L = (u_long *)dst+(8/4);

		*(volatile u_char *)BLT_SKEW_B = 0;

	    *(volatile u_short *)BLT_X_COUNT_W = Scale_X_Count;
	    *(volatile u_short *)BLT_Y_COUNT_W = Scale_Y_Count;

	    *(volatile u_char *)BLT_LINE_NUM_B = MLINESMUDGE|MLINEBUSY|MLINEHOG;

		/* next plane on src and dst */
		src++;
		dst++;
	}

	/* move this to a macro */
	blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);
	if (waitKey == TRUE)
		Cconin();
	else
		Vsync();
		
	/* Now double all the y lines */
    *(volatile short *)BLT_SRC_X_INC_W = 2;
    *(volatile short *)BLT_DST_X_INC_W = 2;
	*(volatile short *)BLT_SRC_Y_INC_W = (160)+2; 
    *(volatile short *)BLT_DST_Y_INC_W = 160+2;
	*(volatile u_char *)BLT_HOP_B = 2;
	*(volatile u_char *)BLT_OP_B = 3; /* Blind copy */

	*(volatile u_short *)BLT_ENDMASK1_W = 0xffff;
	*(volatile u_short *)BLT_ENDMASK2_W = 0xffff;
	*(volatile u_short *)BLT_ENDMASK3_W = 0xffff;

	*(volatile u_long *)BLT_SRC_ADDR_L = (u_long *)srcYScale;
	*(volatile u_long *)BLT_DST_ADDR_L = (u_long *)dstYScale;

	*(volatile u_char *)BLT_SKEW_B = 0;

	*(volatile u_short *)BLT_X_COUNT_W = 80; 		
	*(volatile u_short *)BLT_Y_COUNT_W = Scale_Y_Count;

	*(volatile u_char *)BLT_LINE_NUM_B = MLINEBUSY|MLINEHOG;

	blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);
 
	

}

void duplicateScreen (u_short *src, u_short *dst)
{
	volatile u_char  *blt_b;
	
	/* move this to a macro */
	blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);
	
	/* copy src to dst */
    *(volatile short *)BLT_SRC_X_INC_W = 2;
    *(volatile short *)BLT_DST_X_INC_W = 2;
	*(volatile short *)BLT_SRC_Y_INC_W = 2; 
    *(volatile short *)BLT_DST_Y_INC_W = 2;
	*(volatile u_char *)BLT_HOP_B = 2;
	*(volatile u_char *)BLT_OP_B = 3; /* Blind copy */

	*(volatile u_short *)BLT_ENDMASK1_W = 0xffff;
	*(volatile u_short *)BLT_ENDMASK2_W = 0xffff;
	*(volatile u_short *)BLT_ENDMASK3_W = 0xffff;

	*(volatile u_long *)BLT_SRC_ADDR_L = (u_long *)src;
	*(volatile u_long *)BLT_DST_ADDR_L = (u_long *)dst;

	*(volatile u_char *)BLT_SKEW_B = 0;

	*(volatile u_short *)BLT_X_COUNT_W = 80; 		
	*(volatile u_short *)BLT_Y_COUNT_W = 200;

	*(volatile u_char *)BLT_LINE_NUM_B = MLINEBUSY|MLINEHOG;

	blt_b = (volatile u_char *)BLT_LINE_NUM_B; do{}while((*blt_b)&MLINEBUSY);


}




