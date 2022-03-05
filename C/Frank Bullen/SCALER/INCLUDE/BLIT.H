#ifndef _BLIT_H
#define _BLIT_H

#define BLT_HALFTONE_RAM_W 	0xFF8A00

#define BLT_SRC_X_INC_W    	0xFF8A20
#define BLT_SRC_Y_INC_W    	0xFF8A22
#define BLT_SRC_ADDR_L     	0xFF8A24

#define BLT_ENDMASK1_W     	0xFF8A28
#define BLT_ENDMASK2_W     	0xFF8A2A
#define BLT_ENDMASK3_W     	0xFF8A2C
#define BLT_DST_X_INC_W    	0xFF8A2E
#define BLT_DST_Y_INC_W    	0xFF8A30
#define BLT_DST_ADDR_L     	0xFF8A32
#define BLT_X_COUNT_W      	0xFF8A36
#define BLT_Y_COUNT_W      	0xFF8A38

#define BLT_HOP_B 		 	0xFF8A3A
#define BLT_OP_B  		 	0xFF8A3B

#define BLT_LINE_NUM_B		0xFF8A3C

/* OP bit definitions
  0xFF 8A3C   |ooo-oooo|
            ||| |__|_____________ LINE NUMBER
            |||__________________ SMUDGE
             ||__________________ HOG
             |___________________ BUSY
*/

#define BLT_SKEW_B			0xFF8A3D

/*

  0xFF 8A3D   |oo--oooo|
            ||  |__|_____________ SKEW
            ||___________________ NFSR
             |____________________ FXSR
*/

/* BLiTTER REGISTER FLAGS, bit positions */

#define      FHOP_SOURCE    1
#define      FHOP_HALFTONE  0

#define      FSKEWFXSR      7
#define      FSKEWNFSR      6

#define      FLINEBUSY		7
#define      FLINEHOG       6
#define      FLINESMUDGE    5

/* BLITTER REGISTER MASKS */

#define      MHOP_SOURCE    0X02
#define      MHOP_HALFTONE  0X01

#define      MSKEWFXSR      0X80
#define      MSKEWNFSR      0X40

#define      MLINEBUSY      0X80
#define      MLINEHOG       0X40
#define      MLINESMUDGE    0X20

#endif /* _BLIT_H */