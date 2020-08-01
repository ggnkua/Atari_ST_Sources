/*---------------------------------------------------------------------------

  vms.h

  Generic VMS header file for Info-ZIP's UnZip; now includes VMSmunch.h (at
  end, except fchdef part deleted).

  ---------------------------------------------------------------------------*/

#include <descrip.h>
#include <starlet.h>
#include <syidef.h>
#include <atrdef.h>
#include <fibdef.h>
#include <iodef.h>
#include <fchdef.h>
/* #include <rms.h>  already included in unzip.h */

#define ERR(s) !((s) & 1)	/* VMS system error */

#ifndef SYI$_VERSION
#define SYI$_VERSION 4096	/* VMS 5.4 definition */
#endif

/*
 *  Under Alpha (DEC C?), the FIB unions are declared as variant_unions.
 *  FIBDEF.H includes the definition of __union, which we check
 *  below to make sure we access the structure correctly.
 */
#define variant_union 1
#if defined(__union) && (__union == variant_union)
#  define FIB$W_DID       fib$w_did
#  define FIB$W_FID       fib$w_fid
#  define FIB$L_ACCTL     fib$l_acctl
#  define FIB$W_EXCTL     fib$w_exctl
#else
#  define FIB$W_DID       fib$r_did_overlay.fib$w_did
#  define FIB$W_FID       fib$r_fid_overlay.fib$w_fid
#  define FIB$L_ACCTL     fib$r_acctl_overlay.fib$l_acctl
#  define FIB$W_EXCTL     fib$r_exctl_overlay.fib$w_exctl
#endif
#undef variant_union


struct EB_header    /* Common header of extra block */
{   ush tag;
    ush size;
    uch data[1];
};

/*------ Old style INFO-ZIP extra field definitions -----*/

#if (!defined(VAXC) && !defined(_RMS_H))

struct XAB {                    /* This definition may be skipped */
    unsigned char xab$b_cod;
    unsigned char xab$b_bln;
    short int xabdef$$_fill_1;
    char *xab$l_nxt;
};

#endif /* !VAXC && !_RMS_H */

#define BC_MASK    07   /* 3 bits for compression type */
#define BC_STORED  0    /* Stored */
#define BC_00      1    /* 0byte -> 0bit compression */
#define BC_DEFL    2    /* Deflated */

/*
 *  Extra record format
 *  ===================
 *  signature       (2 bytes)   = 'I','M'
 *  size            (2 bytes)
 *  block signature (4 bytes)
 *  flags           (2 bytes)
 *  uncomprssed size(2 bytes)
 *  reserved        (4 bytes)
 *  data            ((size-12) bytes)
 *  ....
 */

struct IZ_block
{
    ush sig;			/* Extra field block header structure */
    ush size;
    ulg bid;
    ush flags;
    ush length;
    ulg reserved;
    uch body[1];
};

/*
 *   Extra field signature and block signatures
 */

#define IZ_SIGNATURE "IM"
#define FABL    (cc$rms_fab.fab$b_bln)
#define RABL    (cc$rms_rab.rab$b_bln)
#define XALLL   (cc$rms_xaball.xab$b_bln)
#define XDATL   (cc$rms_xabdat.xab$b_bln)
#define XFHCL   (cc$rms_xabfhc.xab$b_bln)
#define XKEYL   (cc$rms_xabkey.xab$b_bln)
#define XPROL   (cc$rms_xabpro.xab$b_bln)
#define XRDTL   (cc$rms_xabrdt.xab$b_bln)
#define XSUML   (cc$rms_xabsum.xab$b_bln)
#define EXTBSL  4            /* Block signature length */
#define RESL    8            /* Reserved 8 bytes */
#define EXTHL   (4+EXTBSL)
#define FABSIG  "VFAB"
#define XALLSIG "VALL"
#define XFHCSIG "VFHC"
#define XDATSIG "VDAT"
#define XRDTSIG "VRDT"
#define XPROSIG "VPRO"
#define XKEYSIG "VKEY"
#define XNAMSIG "VNAM"
#define VERSIG  "VMSV"

typedef unsigned char byte;

struct iosb
{   ush status;
    ush count;
    ulg spec;
};

/*------------ PKWARE extra block definitions ----------*/

/* Structure of PKWARE extra header */

#ifdef VMS_ZIP

struct PK_info
{
    ush tag_ra; ush len_ra;     byte ra[ATR$S_RECATTR];
    ush tag_uc; ush len_uc;     byte uc[ATR$S_UCHAR];
    ush tag_jr; ush len_jr;     byte jr[ATR$S_JOURNAL];
    ush tag_cd; ush len_cd;     byte cd[ATR$S_CREDATE];
    ush tag_rd; ush len_rd;     byte rd[ATR$S_REVDATE];
    ush tag_ed; ush len_ed;     byte ed[ATR$S_EXPDATE];
    ush tag_bd; ush len_bd;     byte bd[ATR$S_BAKDATE];
    ush tag_rn; ush len_rn;     ush  rn;
    ush tag_ui; ush len_ui;     byte ui[ATR$S_UIC];
    ush tag_fp; ush len_fp;     byte fp[ATR$S_FPRO];
    ush tag_rp; ush len_rp;     byte rp[ATR$S_RPRO];
};

#endif /* ?VMS_ZIP */

/* PKWARE "VMS" tag */
#define PK_SIGNATURE	    0x000C
#define IZ_NEW_SIGNATURE    0x010C  /* New signature, extra record format
				    *  mostly compatible with PKWARE's */

/* Total number of attributes to be saved */
#define VMS_ATTR_COUNT	11
#define VMS_MAX_ATRCNT	20

struct PK_field
{   ush		tag;
    ush		size;
    byte	value[1];
};

#define PK_FLDHDR_SIZE	4

struct PK_header
{   ush	tag;
    ush	size;
    ulg	crc32;
    byte data[1];
};

#define	PK_HEADER_SIZE	8

#ifdef	VMS_ZIP
/* File description structure for Zip low level I/O */
struct ioctx
{   ush			chan;
    int			status;
    struct iosb		iosb;
    long		vbn;
    long		size;
    long		rest;
    struct PK_info	PKi;
    long		acllen;
    uch			aclbuf[ATR$S_READACL];
};
#endif	/* VMS_ZIP */



/*---------------------------------------------------------------------------

  VMSmunch.h

  A few handy #defines, plus the contents of three header files from Joe
  Meadows' FILE program.  Used by VMSmunch and by various routines which
  call VMSmunch (e.g., in Zip and UnZip).

  ---------------------------------------------------------------------------*/

#define GET_TIMES       4
#define SET_TIMES       0
#define GET_RTYPE       1
#define CHANGE_RTYPE    2
#define RESTORE_RTYPE   3

/*---------------------------------------------------------------------------
    fatdef.h
  ---------------------------------------------------------------------------*/

/* This header file was created by Joe Meadows, and is not copyrighted
   in any way. No guarantee is made as to the accuracy of the contents
   of this header file. This header file was last modified on Sep. 22th,
   1987. (Modified to include this statement) */
#define FAT$K_LENGTH 32
#define FAT$C_LENGTH 32
#define FAT$S_FATDEF 32

struct fatdef {
  union  {
    unsigned char fat$b_rtype;
    struct  {
      unsigned fat$v_rtype : 4;
      unsigned fat$v_fileorg : 4;
    } fat$r_rtype_bits;
  } fat$r_rtype_overlay;
# define FAT$S_RTYPE 4
# define FAT$V_RTYPE 0
#   define FAT$C_UNDEFINED 0
#   define FAT$C_FIXED 1
#   define FAT$C_VARIABLE 2
#   define FAT$C_VFC 3
#   define FAT$C_STREAM 4
#   define FAT$C_STREAMLF 5
#   define FAT$C_STREAMCR 6
# define FAT$S_FILEORG 4
# define FAT$V_FILEORG 4
#   define FAT$C_SEQUENTIAL 0
#   define FAT$C_RELATIVE 1
#   define FAT$C_INDEXED 2
#   define FAT$C_DIRECT 3
  union  {
    unsigned char fat$b_rattrib;
    struct  {
      unsigned fat$v_fortrancc : 1;
      unsigned fat$v_impliedcc : 1;
      unsigned fat$v_printcc : 1;
      unsigned fat$v_nospan : 1;
    } fat$r_rattrib_bits;
  } fat$r_rattrib_overlay;
#   define FAT$V_FORTRANCC 0
#   define FAT$M_FORTRANCC 1
#   define FAT$V_IMPLIEDCC 1
#   define FAT$M_IMPLIEDCC 2
#   define FAT$V_PRINTCC 2
#   define FAT$M_PRINTCC 4
#   define FAT$V_NOSPAN 3
#   define FAT$M_NOSPAN 8
  unsigned short int fat$w_rsize;
  union
  {
    unsigned long int fat$l_hiblk;
    struct
    {
      unsigned short int fat$w_hiblkh;
      unsigned short int fat$w_hiblkl;
    } fat$r_hiblk_fields;
  } fat$r_hiblk_overlay;
  union
  {
    unsigned long int fat$l_efblk;
    struct
    {
      unsigned short int fat$w_efblkh;
      unsigned short int fat$w_efblkl;
    } fat$r_efblk_fields;
  } fat$r_efblk_overlay;
  unsigned short int fat$w_ffbyte;
  unsigned char fat$b_bktsize;
  unsigned char fat$b_vfcsize;
  unsigned short int fat$w_maxrec;
  unsigned short int fat$w_defext;
  unsigned short int fat$w_gbc;
  char fat$fill[8];
  unsigned short int fat$w_versions;
};


/*---------------------------------------------------------------------------
    fjndef.h
  ---------------------------------------------------------------------------*/

/* This header file was created by Joe Meadows, and is not copyrighted
   in any way. No guarantee is made as to the accuracy of the contents
   of this header file. This header file was last modified on Sep. 22th,
   1987. (Modified to include this statement) */

#define FJN$M_ONLY_RU 1
#define FJN$M_RUJNL 2
#define FJN$M_BIJNL 4
#define FJN$M_AIJNL 8
#define FJN$M_ATJNL 16
#define FJN$M_NEVER_RU 32
#define FJN$M_JOURNAL_FILE 64
#define FJN$S_FJNDEF 1
struct fjndef  {
  unsigned fjn$v_only_ru : 1;
  unsigned fjn$v_rujnl : 1;
  unsigned fjn$v_bijnl : 1;
  unsigned fjn$v_aijnl : 1;
  unsigned fjn$v_atjnl : 1;
  unsigned fjn$v_never_ru : 1;
  unsigned fjn$v_journal_file:1;
} ;
