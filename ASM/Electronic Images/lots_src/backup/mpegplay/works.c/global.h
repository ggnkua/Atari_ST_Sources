/* global.h, global variables                                               */

#include "proto.h"
extern 	ASMIDCT(short *);

#ifndef GLOBAL
#define EXTERN extern
#else
#define EXTERN
#endif

#define ERROR (-1)
#define PICTURE_START_CODE 0x100
#define USER_START_CODE    0x1B2
#define SEQ_START_CODE     0x1B3
#define EXT_START_CODE     0x1B5
#define SEQ_END_CODE       0x1B7
#define GOP_START_CODE     0x1B8

/* macroblock type */
#define MB_INTRA    1
#define MB_PATTERN  2

EXTERN int pict_type,fault;
EXTERN int horizontal_size,vertical_size,mb_width,mb_height;
EXTERN int coded_picture_width, coded_picture_height;
EXTERN unsigned char *lumframe,*chromframe;
EXTERN  int ld_infile;
EXTERN  unsigned char ld_rdbfr[8192];
EXTERN  unsigned char *ld_rdptr;
EXTERN  unsigned long ld_bfr;
EXTERN  unsigned int ld_incnt;
EXTERN  int ld_intra_quantizer_matrix[64];
EXTERN  int ld_quant_scale;
EXTERN  short ld_block[64];

#define showbits(n) (ld_bfr>>(32-(n)))