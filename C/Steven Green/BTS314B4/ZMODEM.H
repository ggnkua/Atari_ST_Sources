#ifndef H_ZMODEM
#define H_ZMODEM
/*--------------------------------------------------------------------------*/
/*                                                                          */
/*                                                                          */
/*      ------------         Bit-Bucket Software, Co.                       */
/*      \ 10001101 /         Writers and Distributors of                    */
/*       \ 011110 /          Freely Available<tm> Software.                 */
/*        \ 1011 /                                                          */
/*         ------                                                           */
/*                                                                          */
/*  (C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*                                                                          */
/*                                                                          */
/*                   Zmodem definitions for BinkleyTerm                     */
/*                                                                          */
/*                                                                          */
/*    For complete  details  of the licensing restrictions, please refer    */
/*    to the License  agreement,  which  is published in its entirety in    */
/*    the MAKEFILE and BT.C, and also contained in the file LICENSE.240.    */
/*                                                                          */
/*    USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE    */
/*    BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF    */
/*    THIS  AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,  OR IF YOU DO    */
/*    NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET    */
/*    SOFTWARE CO.  AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT    */
/*    SHOULD YOU  PROCEED TO USE THIS FILE  WITHOUT HAVING  ACCEPTED THE    */
/*    TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER    */
/*    AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.      */
/*                                                                          */
/*                                                                          */
/* You can contact Bit Bucket Software Co. at any one of the following      */
/* addresses:                                                               */
/*                                                                          */
/* Bit Bucket Software Co.        FidoNet  1:104/501, 1:132/491, 1:141/491  */
/* P.O. Box 460398                AlterNet 7:491/0                          */
/* Aurora, CO 80046               BBS-Net  86:2030/1                        */
/*                                Internet f491.n132.z1.fidonet.org         */
/*                                                                          */
/* Please feel free to contact us at any time to share your comments about  */
/* our software and/or licensing policies.                                  */
/*                                                                          */
/*                                                                          */
/*  This module is based largely on a similar module in OPUS-CBCS V1.03b.   */
/*  The original work is (C) Copyright 1986, Wynn Wagner III. The original  */
/*  authors have graciously allowed us to use their code in this work.      */
/*                                                                          */
/*--------------------------------------------------------------------------*/

#ifdef DEBUG
#define ZDEBUG	/* Loads of debugging info! */
#endif

#define flushmo() wait_for_clear()

#ifndef __PUREC__
	#define Z_UpdateCRC(cp,crc) ( crctab[((crc >> 8) & 255) ^ cp] ^ (crc << 8))
	#define Z_32UpdateCRC(c,crc) (cr3tab[((int) crc ^ c) & 0xff] ^ ((crc >> 8) & 0x00FFFFFF))
#else
	unsigned int	Z_UpdateCRC(unsigned int cp,unsigned long crc);
	unsigned long	Z_32UpdateCRC(unsigned int c,unsigned long crc);
#endif


/*--------------------------------------------------------------------------*/
/* Routines from N_Zmodem.H ...                                             */
/*--------------------------------------------------------------------------*/

#define ZPAD            '*'
#define ZDLE            030
#define ZDLEE           (ZDLE^0100)
#define ZBIN            'A'
#define ZHEX            'B'
#define ZBIN32          'C'

/*--------------------------------------------------------------------------*/
/* Frame types (see array "frametypes" in zm.c)                             */
/*--------------------------------------------------------------------------*/
#define ZRQINIT         0
#define ZRINIT          1
#define ZSINIT          2
#define ZACK            3
#define ZFILE           4
#define ZSKIP           5
#define ZNAK            6
#define ZABORT          7
#define ZFIN            8
#define ZRPOS           9
#define ZDATA           10
#define ZEOF            11
#define ZFERR           12
#define ZCRC            13
#define ZCHALLENGE      14
#define ZCOMPL          15
#define ZCAN            16
#define ZFREECNT        17
#define ZCOMMAND        18
#define ZSTDERR         19

/*--------------------------------------------------------------------------*/
/* ZDLE sequences                                                           */
/*--------------------------------------------------------------------------*/
#define ZCRCE           'h'
#define ZCRCG           'i'
#define ZCRCQ           'j'
#define ZCRCW           'k'
#define ZRUB0           'l'
#define ZRUB1           'm'

/*--------------------------------------------------------------------------*/
/* Z_GetZDL return values (internal)                                        */
/* -1 is general error, -2 is timeout                                       */
/*--------------------------------------------------------------------------*/
#define GOTOR           0400
#define GOTCRCE         (ZCRCE|GOTOR)
#define GOTCRCG         (ZCRCG|GOTOR)
#define GOTCRCQ         (ZCRCQ|GOTOR)
#define GOTCRCW         (ZCRCW|GOTOR)
#define GOTCAN          (GOTOR|030)

/*--------------------------------------------------------------------------*/
/* Byte positions within header array                                       */
/*--------------------------------------------------------------------------*/
#define ZF0             3
#define ZF1             2
#define ZF2             1
#define ZF3             0
#define ZP0             0
#define ZP1             1
#define ZP2             2
#define ZP3             3

/*--------------------------------------------------------------------------*/
/* Bit Masks for ZRINIT flags byte ZF0                                      */
/*--------------------------------------------------------------------------*/
#define CANFDX          01
#define CANOVIO         02
#define CANBRK          04
#define CANCRY          010
#define CANLZW          020
#define CANFC32         040





/*--------------------------------------------------------------------------*/
/* PARAMETERS FOR ZFILE FRAME...                                            */
/*--------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------*/
/* Conversion options one of these in ZF0                                   */
/*--------------------------------------------------------------------------*/
#define ZCBIN           1
#define ZCNL            2
#define ZCRESUM         3

/*--------------------------------------------------------------------------*/
/* Management options, one of these in ZF1                                  */
/*--------------------------------------------------------------------------*/
#define ZMNEW           1
#define ZMCRC           2
#define ZMAPND          3
#define ZMCLOB          4
#define ZMSPARS         5
#define ZMDIFF          6
#define ZMPROT          7

/*--------------------------------------------------------------------------*/
/* Transport options, one of these in ZF2                                   */
/*--------------------------------------------------------------------------*/
#define ZTLZW           1
#define ZTCRYPT         2
#define ZTRLE           3

/*--------------------------------------------------------------------------*/
/* Parameters for ZCOMMAND frame ZF0 (otherwise 0)                          */
/*--------------------------------------------------------------------------*/
#define ZCACK1          1





/*--------------------------------------------------------------------------*/
/* Miscellaneous definitions                                                */
/*--------------------------------------------------------------------------*/
#define OK              0
#define ERROR           (-1)
#define TIMEOUT         (-2)
#define RCDO            (-3)
#define FUBAR           (-4)

#define XON             ('Q'&037)
#define XOFF            ('S'&037)
#define CPMEOF          ('Z'&037)

#define RXBINARY        FALSE
#define RXASCII         FALSE
#define LZCONV          0
#define LZMANAG         0
#define LZTRANS         0
#define PATHLEN         128
#define KSIZE           1024
#define WAZOOMAX        8192
#define SECSPERDAY      (24L*60L*60L)



/*--------------------------------------------------------------------------*/
/* Parameters for calling ZMODEM routines                                   */
/*--------------------------------------------------------------------------*/
#define SPEC_COND       2

#ifndef TRUE
#define TRUE            1
#define FALSE           0
#endif

#define END_BATCH       (-1)
#define NOTHING_TO_DO   (-2)
#ifdef NEW
#define EMPTY_BATCH     (-3)
#endif
#define DELETE_AFTER    '-'
#define SHOW_DELETE_AFTER '^'
#define TRUNC_AFTER     '#'
#define NOTHING_AFTER   '@'
#define DO_WAZOO        TRUE
#define DONT_WAZOO      FALSE


/*--------------------------------------------------------------------------*/
/* ASCII MNEMONICS                                                          */
/*--------------------------------------------------------------------------*/
#define NUL 0x00
#define SOH 0x01
#define STX 0x02
#define ETX 0x03
#define EOT 0x04
#define ENQ 0x05
#define ACK 0x06
#define BEL 0x07
#define BS  0x08
#define HT  0x09
#define LF  0x0a
#define VT  0x0b
#define FF  0x0c
#define CR  0x0d
#define SO  0x0e
#define SI  0x0f
#define DLE 0x10
#define DC1 0x11
#define DC2 0x12
#define DC3 0x13
#define DC4 0x14
#define NAK 0x15
#define SYN 0x16
#define ETB 0x17
#define CAN 0x18
#define EM  0x19
#define SUB 0x1a
#define ESC 0x1b
#define FS  0x1c
#define GS  0x1d
#define RS  0x1e
#define US  0x1f

/*
 * data
 */

extern char Rxhdr[];                             /* Received header                                  */
extern char Txhdr[];                             /* Transmitted header                               */

#ifndef GENERIC
extern long *RXlong;
extern long *TXlong;
#endif

extern long Rxpos;                               /* Received file position                           */
extern int Txfcs32;                              /* TURE means send binary
                                                  * frames with 32 bit FCS    */
extern int Crc32t;                               /* Display flag indicating
                                                  * 32 bit CRC being sent */
extern int Crc32;                                /* Display flag indicating
                                                  * 32 bit CRC being received */
extern int Znulls;                               /* # of nulls to send at
                                                  * beginning of ZDATA hdr     */

extern int Rxtimeout;                            /* Tenths of seconds to wait
                                                  * for something          */
extern int Rxframeind;                           /* ZBIN ZBIN32,ZHEX type of
                                                  * frame received */

extern char *Filename;                           /* Name of the file being
                                                  * up/downloaded             */

extern size_t z_size;

/*
 * Function prototypes
 */
 
int get_ZedZap (char *, FILE *);
int send_ZedZap (char *, char *, int, int);
int get_ZedZip (char *, FILE *);
int send_ZedZip (char *, char *, int, int);

int get_Zmodem (char *, FILE *);
int Send_Zmodem (char *, char *, int, int);

void z_message (byte *);
int Z_GetByte (int);
void Z_PutString (unsigned char *);
void Z_SendHexHeader (unsigned int, unsigned char *);
int Z_GetHeader (unsigned char *);
int Z_GetZDL (void);
void Z_PutLongIntoHeader (long);
void z_log (char *);
void show_loc (unsigned long, unsigned int);
void Z_UncorkTransmitter (void);
void z_log (char *);
#ifndef ATARIST			/* these are in com_st.h */
void BUFFER_BYTE (unsigned char);
void UNBUFFER_BYTES (void);
#endif


#endif /* H_ZMODEM */
/* END OF FILE: zmodem.h */
