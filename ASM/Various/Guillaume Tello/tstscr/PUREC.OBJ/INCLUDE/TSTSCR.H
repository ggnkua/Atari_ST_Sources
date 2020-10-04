/* TEST SCREEN definitions   */
/* Guillaume Tello 2020      */
/* guillaume.tello@orange.fr */

/* SCREENENCODING is the routine in TSTSCR.O to be linked          */
/* - glob is a pointer to the AES global array (_GemParBlk.global) */
/* - Direct Access is a flag that allows direct video memory access*/
/*   when VDI fails in TrueColor 24 or 32 bits. Some computers may */
/*   hang with direct access, be careful                           */

long ScreenEncoding(int *glob, long DirectAccess);

/* here is the long value returned by the function				 */
/* in the high word -> BPP (bits per pixel) = 0xf0bb			 */
/*					first hex digit is a flag                    */
/*                  if f == 0 then OK and bb = bits/pixels       */
/*                  if f == 8 and bb == 0, can't open VDI        */
/*                  if f == 8 and bb != 0, UNKNOWN encoding      */
/*                  (when f == 8, TYPE is undefined)             */       
/*       														 */
/* in the low word -> TYPE = 0xf00t                              */
/*					if f == 8 then direct access was necessary   */
/*                            after a VDI failure                */
/*                  t == subtype as shown below                  */

#define B1_mono		0x00010000	/* monochrome one plane ATARI ST HIGH */
#define B2_inter 	0x00020000  /* 4 colors interlaced ATARI ST MEDIUM */
#define B2_ninter 	0x00020001	/* 4 colors non interlaced */
#define B4_inter	0x00040000  /* 16 colors interlaced ATARI ST Low/TT Med */
#define B4_ninter	0x00040001  /* 16 colors non interlaced */
#define B4_packed	0x00040002	/* 2 pixels/byte */
#define B8_inter	0x00080000  /* 256 col interlaced ATARI TT Low/Falcon */
#define B8_ninter	0x00080001  /* 256 col non interlaced */
#define B8_packed 	0x00080002  /* 256 col 1byte = 1 pixel, NOVA */
#define B8_packedM 	0x00080003  /* 256 col 1byte = 1 pixel MATRIX */
#define B16_motor 	0x00100000  /* rrrrrggg gggbbbbb ATARI Falcon */
#define B16_intel 	0x00100001  /* gggbbbbb rrrrrggg */
#define B15_motor 	0x00100002	/* xrrrrrgg gggbbbbb */
#define B15_intel 	0x00100003	/* gggbbbbb xrrrrrgg NOVA */
#define B24_rgb 	0x00180000  /* RGB */
#define B24_bgr		0x00180001	/* BGR */
#define B32_xrgb 	0x00200000	/* xRGB */
#define B32_xbgr 	0x00200001	/* xBGR */
#define B32_bgrx 	0x00200002	/* BGRx */
#define B32_rgbx 	0x00200003  /* RGBx */

#define errorbit	0x8000
#define errorclear	0x7FFF7FFF

