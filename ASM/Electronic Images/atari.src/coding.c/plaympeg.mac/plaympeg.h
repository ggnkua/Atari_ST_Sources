/*
 *	PLAYMPEG, definitions etc.
 *	Martin Griffiths 1995.
 */

typedef int INT16;
typedef unsigned int UINT16;
typedef long INT32;
typedef unsigned long UINT32;

UINT32 getbits(INT32 n);
void initbits(void);
void startcode(void);
UINT32 showbits(INT32 n);
void flushbits(INT32 n);
void idct(INT16*);
void ext_bit_info(void);
void getslicehdr(void);
INT32 getMBA(void);
INT16 getCBP(void);
INT16 getMV(void);
INT16 getMBtype(void);
extern void getinterblocks(INT16);
extern void getintrablocks(INT16,INT32 *);

typedef struct {
  INT16 value;       /* value for macroblock_address_increment */
  INT16 num_bits;             /* length of the Huffman code */
} mb_addr_inc_entry;

typedef struct {
  UINT16 code;       /* value for macroblock_address_increment */
  INT16 num_bits;             /* length of the Huffman code */
} mv_tab;

typedef struct {
  char run, level, len;
} DCTtab;

typedef struct {
  unsigned char level, run;
  short len;
} DCTtab_padded;

typedef struct {
  INT16 val, len;
} VLCtab;

#define __STDC__
#define _ANSI_ARGS_(x) x

#include "proto.h"

#define RB "rb"
#define WB "wb"

#ifndef O_BINARY
#define O_BINARY 0
#endif

#define ERROR (-1)

#define PICTURE_START_CODE 0x100l
#define SLICE_MIN_START    0x101l
#define SLICE_MAX_START    0x1AFl
#define USER_START_CODE    0x1B2l
#define SEQ_START_CODE     0x1B3l
#define EXT_START_CODE     0x1B5l
#define SEQ_END_CODE       0x1B7l
#define GOP_START_CODE     0x1B8l
#define ISO_END_CODE       0x1B9l
#define PACK_START_CODE    0x1BAl
#define SYSTEM_START_CODE  0x1BBl

/* picture coding type */
#define I_TYPE 1
#define P_TYPE 2
#define B_TYPE 3
#define D_TYPE 4

/* macroblock type */
#define MB_INTRA    1
#define MB_PATTERN  2
#define MB_BACKWARD 4
#define MB_FORWARD  8
#define MB_QUANT    16

/* motion_type */
#define MC_FIELD 1
#define MC_FRAME 2

/* mv_format */
#define MV_FIELD 0
#define MV_FRAME 1

#ifndef GLOBAL
#define EXTERN extern
#else
#define EXTERN
#endif

/* global variables */

/* zig-zag scan */
EXTERN INT16 zig_zag_scan[64]
#ifdef GLOBAL
=
{
  0,1,8,16,9,2,3,10,17,24,32,25,18,11,4,5,
  12,19,26,33,40,48,41,34,27,20,13,6,7,14,21,28,
  35,42,49,56,57,50,43,36,29,22,15,23,30,37,44,51,
  58,59,52,45,38,31,39,46,53,60,61,54,47,55,62,63
}
#endif
;

/* default intra quantization matrix */
EXTERN unsigned char default_intra_quantizer_matrix[64]
#ifdef GLOBAL
=
{
  8, 16, 19, 22, 26, 27, 29, 34,
  16, 16, 22, 24, 27, 29, 34, 37,
  19, 22, 26, 27, 29, 34, 34, 38,
  22, 22, 26, 27, 29, 34, 37, 40,
  22, 26, 27, 29, 32, 35, 40, 48,
  26, 27, 29, 32, 35, 40, 48, 58,
  26, 27, 29, 34, 38, 46, 56, 69,
  27, 29, 35, 38, 46, 56, 69, 83
}
#endif
;

/* color space conversion coefficients
 *
 * entries are {crv,cbu,cgu,cgv}
 *
 * crv=(255/224)*65536*(1-cr)/0.5
 * cbu=(255/224)*65536*(1-cb)/0.5
 * cgu=(255/224)*65536*(cb/cg)*(1-cb)/0.5
 * cgv=(255/224)*65536*(cr/cg)*(1-cr)/0.5
 *
 * where Y=cr*R+cg*G+cb*B (cr+cg+cb=1)
 */

EXTERN INT32 convmat[8][4]
#ifdef GLOBAL
=
{
  {117504, 138453, 13954, 34903}, /* no sequence_display_extension */
  {117504, 138453, 13954, 34903}, /* ITU-R Rec. 709 (1990) */
  {104597, 132201, 25675, 53279}, /* unspecified */
  {104597, 132201, 25675, 53279}, /* reserved */
  {104448, 132798, 24759, 53109}, /* FCC */
  {104597, 132201, 25675, 53279}, /* ITU-R Rec. 624-4 System B, G */
  {104597, 132201, 25675, 53279}, /* SMPTE 170M */
  {117579, 136230, 16907, 35559}  /* SMPTE 240M (1987) */
}
#endif
;

EXTERN char errortext[256];
EXTERN unsigned char *refframe[3],*oldrefframe[3],*auxframe[3],*newframe[3];
EXTERN unsigned char *clp;
EXTERN INT32 horizontal_size,vertical_size,mb_width,mb_height;
EXTERN INT32 coded_picture_width, coded_picture_height;
EXTERN INT32 chrom_width,chrom_height;
EXTERN INT32 forw_r_size,back_r_size;
EXTERN INT32 full_forw,full_back;
EXTERN INT32 h_forw_r_size,v_forw_r_size,h_back_r_size,v_back_r_size;
EXTERN INT32 llw,llh,hm,hn,vm,vn;
EXTERN INT32 ld_infile;
EXTERN INT32 ld_quant_scale;
EXTERN INT32 ld_intra_quantizer_matrix[64],ld_non_intra_quantizer_matrix[64];
EXTERN INT16 sysstream,fault,quiet;
EXTERN INT16 pict_type;
EXTERN INT16 ld_block[6][64];
