/* zoo.h */

/* 
The contents of this file are hereby released to the public domain.
                                   -- Rahul Dhesi 1987/02/08
*/

#include <stdio.h>

#define SIZ_TEXT  20
#define FNAMESIZE 13
#define MAX_PACK 1
#define LO_TAG (0xa7dc)
#define HI_TAG (0xfdc4)

struct zoo_header {
   char text[SIZ_TEXT];
   unsigned lo_tag;
   unsigned hi_tag;
   long zoo_start;
   long zoo_minus;
   char major_ver;
   char minor_ver;
};

struct direntry {
   unsigned lo_tag;
   unsigned hi_tag;
   char type;
   char packing_method;       /* 0 = no packing, 1 = normal LZW */
   long next;                 /* pos'n of next directory entry */
   long offset;               /* position of this file */
   unsigned int date;         /* DOS format date */
   unsigned int time;         /* DOS format time */
   unsigned int file_crc;     /* CRC of this file */
   long org_size;
   long size_now;
   char major_ver;
   char minor_ver;            /* minimum version needed to extract */
   char deleted;              /* will be 1 if deleted, 0 if not */
   long comment;              /* points to comment;  zero if none */
   unsigned int cmt_size; /* length of comment, 0 if none */
   char fname[FNAMESIZE]; /* filename */
};

/* offsets of items within the canonical zoo archive header */
#define  SIZ_ZOOH 34
#define  TEXT_I   0
#define  ZTAG_I   20
#define  ZST_I    24
#define  ZSTM_I   28
#define  MAJV_I   32
#define  MINV_I   33

/* offsets of items within the canonical directory entry structure */
#define  SIZ_DIR  51
#define  DTAG_I   0
#define  DTYP_I   4
#define  PKM_I    5
#define  NXT_I    6
#define  OFS_I    10 
#define  DAT_I    14 
#define  TIM_I    16 
#define  CRC_I    18 
#define  ORGS_I   20 
#define  SIZNOW_I 24 
#define  DMAJ_I   28 
#define  DMIN_I   29 
#define  DEL_I    30 
#define  SPARE_I  31 
#define  CMT_I    32 
#define  CMTSIZ_I 36 
#define  FNAME_I  38 

#define  FNM_SIZ  13
