#ifndef H_BINK
#define H_BINK
/*--------------------------------------------------------------------------*/
/*																			*/
/*																			*/
/*		------------		 Bit-Bucket Software, Co.						*/
/*		\ 10001101 /		 Writers and Distributors of					*/
/*		 \ 011110 / 		 Freely Available<tm> Software. 				*/
/*		  \ 1011 /															*/
/*		   ------															*/
/*																			*/
/*	(C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*																			*/
/*																			*/
/*				   Major definitions used in BinkleyTerm					*/
/*																			*/
/*																			*/
/*	  For complete	details  of the licensing restrictions, please refer	*/
/*	  to the License  agreement,  which  is published in its entirety in	*/
/*	  the MAKEFILE and BT.C, and also contained in the file LICENSE.240.	*/
/*																			*/
/*	  USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE	*/
/*	  BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF	*/
/*	  THIS	AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,	OR IF YOU DO	*/
/*	  NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET	*/
/*	  SOFTWARE CO.	AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT	*/
/*	  SHOULD YOU  PROCEED TO USE THIS FILE	WITHOUT HAVING	ACCEPTED THE	*/
/*	  TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER	*/
/*	  AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.		*/
/*																			*/
/*																			*/
/* You can contact Bit Bucket Software Co. at any one of the following		*/
/* addresses:																*/
/*																			*/
/* Bit Bucket Software Co.		  FidoNet  1:104/501, 1:132/491, 1:141/491	*/
/* P.O. Box 460398				  AlterNet 7:491/0							*/
/* Aurora, CO 80046 			  BBS-Net  86:2030/1						*/
/*								  Internet f491.n132.z1.fidonet.org 		*/
/*																			*/
/* Please feel free to contact us at any time to share your comments about	*/
/* our software and/or licensing policies.									*/
/*																			*/
/*--------------------------------------------------------------------------*/
/* bink.h
 *
 * General defines and structures used by everything
 *--------------------------------------------------------------------------*/

/*
 * Compilation options
 */

#define NEW				/* Include various updates */
#define MULTIPOINT		/* Include SWG's code for extended address and multipoint operation */
#define EMSI			/* Enable EMSI protocol */
#define IOS				/* Include new code for IOS ?AT packet types */

#ifdef _DEBUG
  #define DEBUG
#endif

#if (defined(M68000) || defined(ATARIST))
#define GENERIC			/* Don't assume byte ordering */
#endif

#ifdef ATARIST
#undef MULTITASK		/* Use M'task display for free memory instead */
#else
#define MULTITASK
#endif

/*
 * Define which language version for the keyboard to use
 * Only these two are recognised at the moment.
 * Update keybd.h to add more versions
 */

#define ENGLISH
/* #define FRENCH */


/*--------------------------------------------------------------------------*/
/* LEGIBLE SECTION.  Definitions to make "C" look like a real language. 	*/
/*--------------------------------------------------------------------------*/

#ifndef max
#define max(a,b)	 ((a)>(b)?(a):(b))
#endif

#ifndef min
#define min(a,b)	 ((a)<=(b)?(a):(b))
#endif


/*
 * updcrc macro derived from article Copyright (C) 1986 Stephen Satchell.
 *	NOTE: First srgument must be in range 0 to 255.
 *		  Second argument is referenced twice.
 *
 * Programmers may incorporate any or all code into their programs,
 * giving proper credit within the source. Publication of the
 * source routines is permitted so long as proper credit is given
 * to Stephen Satchell, Satchell Evaluations and Chuck Forsberg,
 * Omen Technology.
 */

/* #define updcrc(cp, crc) ( crctab[((crc >> 8) & 255) ^ cp] ^ (crc << 8)) */

/* We need it the other way around for BinkleyTerm */
#ifndef __PUREC__
	#define xcrc(crc,cp) ( crctab[((crc >> 8) & 255) ^ cp] ^ (crc << 8))
#else
	unsigned int	xcrc(unsigned int crc,unsigned int cp);
#endif

/*
 * Machine data types
 */

#ifdef ATARIST

#include <portab.h>

#ifdef LATTICE
#include <dos.h>
#endif

#ifndef FMSIZE
#define FMSIZE FILENAME_MAX
#endif


#ifdef __TOS__
#define mkdir(s) Dcreate(s)
#endif

typedef UBYTE byte;	/* This is defined in dos.h */
typedef UWORD word;

#ifndef FALSE
typedef int BOOLEAN;
#define FALSE 0
#define TRUE 1
#endif

#else

typedef unsigned bit;
typedef unsigned int word;
typedef unsigned char byte;
typedef short WORD;
typedef char BYTE;
typedef unsigned short UWORD;
typedef short WORD;
typedef long LONG;
typedef unsigned long ULONG;

#endif

#ifdef LATTICE
#define cdecl __stdargs
#endif

/*
 * fopen() mode parameters
 * since the the PC is using non-ansi "t" mode for ascii files
 */

#if defined(__TOS__)
#define append_ascii 	 "a"
#define read_ascii 	 	 "r"
#define read_ascii_plus  "r+"
#define write_ascii 	 "w"
#define append_binary 	 "a+b"
#define read_binary 	 "rb"
#define read_binary_plus "r+b"
#define write_binary 	 "wb"
#define cputs(str)		 printf("%s", str)
#elif defined(LATTICE)
#define append_ascii 	 "aa"
#define read_ascii 	 	 "ra"
#define read_ascii_plus  "ra+"
#define write_ascii 	 "wa"
#define append_binary 	 "ab"
#define read_binary 	 "rb"
#define read_binary_plus "rb+"
#define write_binary 	 "wb"
#else
/* QuickC */
#define append_ascii  	 "at"
#define read_ascii 		 "rt"
#define read_ascii_plus  "rt+"
#define write_ascii 	 "wt"
#define append_binary 	 "ab"
#define read_binary 	 "rb"
#define read_binary_plus "rb+"
#define write_binary 	 "wb"
#endif

#define rb_plus "rb+"

/*
 * Machine independant structure for a transmitted word in MSDOS format
 *
 * If you are not using an 8086 architecture, then you should define the
 * symbol GENERIC.
 *
 * You can define it on a PC but it will only slow things down a little bit.
 */


typedef struct {
		byte lo;
		byte hi;
} LOHIWORD;

typedef union {
	word w;
	LOHIWORD lohi;
} MWORD;

typedef struct {
	byte lo;
	byte mid1;
	byte mid2;
	byte hi;
} LOHILONG;

typedef union {
	unsigned long l;
	LOHILONG lohi;
} MLONG;


#ifndef LATTICE			/* This is defined in <dos.h> */
 struct FILEINFO
 {
   char rsvd[21];
   char attr;
   long time;
   long size;
   char name[13];
   char nill;
 };
#endif

typedef struct pnums
{
   char prenum[40];
   char sufnum[40];
   char prematch[40];
   char sufmatch[40];
   size_t prelen;
   size_t suflen;
   struct pnums *next;
} PN_TRNS;

typedef struct mnums
{
   byte mdm;
   char pre[50];
   char suf[50];
   struct mnums *next;
} MDM_TRNS;


struct prototable
{
   char first_char;
   int entry;
};

typedef struct j_types
{
   char j_match[30];
   struct j_types *next;
} J_TYPES, *J_TYPESP;

/* mailtypes bit field definitions */
#define MAIL_CRASH	 0x0001
#define MAIL_HOLD	 0x0002
#define MAIL_DIRECT  0x0004
#define MAIL_NORMAL  0x0008
#define MAIL_REQUEST 0x0010
#define MAIL_WILLGO  0x0020
#define MAIL_TRIED	 0x0040
#define MAIL_TOOBAD  0x0080
#define MAIL_UNKNOWN 0x0100
#define MAIL_RES0200 0x0200
#define MAIL_RES0400 0x0400
#define MAIL_RES0800 0x0800
#define MAIL_RES1000 0x1000
#define MAIL_RES2000 0x2000
#define MAIL_RES4000 0x4000
#define MAIL_RES8000 0x8000

typedef struct finfo
{
   int info_size;
   char curr_fossil;
   char curr_rev;
   char *id_string;
   int ibufr;
   int ifree;
   int obufr;
   int ofree;
   byte swidth;
   byte sheight;
   char baud;
} FOSINFO;

typedef int (*PFI3) (int, int, int, int);

typedef struct {
   unsigned char background;
   unsigned char settings;
   unsigned char history;
   unsigned char hold;
   unsigned char call;
   unsigned char file;
   unsigned char calling;
   unsigned char popup;
   unsigned char headers;
   unsigned char borders;
} COLORS;

/*--------------------------------------------------------------------------*/
/* Sealink and Telink header structure										*/
/*--------------------------------------------------------------------------*/
#define HEADER_NAMESIZE  17

struct zero_block
{
   long size;									 /* file length 				   */
   long time;									 /* file date/time stamp		   */
   char name[HEADER_NAMESIZE];					 /* original file name			   */
   char moi[15];								 /* sending program name		   */
   char noacks; 								 /* for SLO 					   */
};


/* File transfer structures */

typedef struct
{
   unsigned char block_num;
   unsigned char block_num_comp;
   unsigned char data_bytes[128];
   unsigned char data_check[2];
} XMDATA, *XMDATAP;

typedef struct
{
   unsigned char block_num;
   unsigned char block_num_comp;
#ifdef GENERIC
   byte filelength[4];			/* Low comes first */
   byte time[2];				/* MSDOS format */
   byte date[2];				/* MSDOS format */
#else
   long filelength;
   union
   {
   struct
	  {
	  unsigned time;
	  unsigned date;
	  } twowords;

   struct
	  {
	  unsigned long timedate;
	  } oneword;
   } filetime;
#endif
   char filename[16];
   char nullbyte;
   char sendingprog[15];
   char noacks;
   unsigned char crcmode;
   char fill[86];
   unsigned char data_check[2];
} TLDATA, *TLDATAP;

typedef struct
{
   unsigned char block_num;
   unsigned char block_num_comp;
#ifdef GENERIC
   byte filelength[4];
   byte time[2];	/* 0..4: seconds/2, 5..10: minutes, 11..15: hours */
   byte date[2];	/* 0..4: days, 5..8: month, 9..15: year-1980	  */
#else
   long filelength;
   unsigned long timedate;
#endif

   char filename[17];
   char sendingprog[15];
   char SLO;
   char Resync;
   char MACFLOW;
   char fill[85];
   unsigned char data_check[2];
} SEADATA, *SEADATAP;

typedef struct {
   unsigned int SEAlink:1; /* Can do SEAlink */
   unsigned int SLO:1;	   /* Can do SEAlink with Overdrive */
   unsigned int Resync:1;  /* Can do SEAlink with Resync */
   unsigned int MacFlow:1; /* Can do SEAlink with Macintosh flow control */
   unsigned int do_CRC:1;  /* Should do CRC instead of checksum */
   unsigned int TeLink:1;  /* We saw a TeLink header */
} TRANS, *TRANSP;

typedef struct {
   const char *state_name;
   int cdecl (*state_func)(void *, ...);
} STATES, *STATEP;

typedef struct {
   TRANS options;	 /* Transfer options */
   int result;		 /* Result from last operation */
   int sub_results;  /* Extra result codes */
   long T1; 		 /* General purpose timer */
   long T2; 		 /* General purpose timer */
   int Window;		 /* SEAlink window size */
   long SendBLK;	 /* Current block to be sent */
   long NextBLK;	 /* Next block we will try to send */
   long ACKBLK; 	 /* Block that was last ACK'd */
   long LastBlk;	 /* Last block in file */
   long ARBLK;		 /* Used in ACK Check calculations */
   long WriteBLK;	 /* Block number to write to file */
   long filelen;	 /* Length of file being sent */
   long curr_byte;	 /* Current byte offset of sending or receiving */
   long prev_bytes;  /* Bytes that we are resyncing over */
   long total_blocks;/* Total number of blocks in file to be received */
   long resync_block;/* Block number we received to resync to */
   int NumNAK;		 /* Number of NAK's received this block */
   int ACKsRcvd;	 /* Number of ACK's received since file start */
   int ACKST;		 /* Current state of the ack/nak state variable */
   int tries;		 /* Number of tries thus far */
   int goodfile;	 /* 0 if file was bad, 1 if file was good */
   size_t datalen;	 /* Length of data in this block */
   int recblock;	 /* Block number received */
   int sent_ACK;	 /* Whether or not we sent an ACK already */
   int tot_errs;	 /* Total number of errors */
   unsigned char ARBLK8;   /* 8 bit value of ARBLK */
   unsigned char blocknum; /* 8 bit value of SendBLK */
   unsigned char check;    /* checksum value */
   unsigned char save_header; /* Received header from first block */
   int CHR; 			   /* General purpose receive character */
   union				   /* File date and time in Telink or SEAlink format */
   {
   struct
	  {
	  unsigned time;
	  unsigned date;
	  } twowords;

   struct
	  {
	  unsigned long timedate;
	  } oneword;
   } save_filetime;
   char received_name[20]; /* Received filename from Telink or SEAlink */
   char m7name[12]; 	   /* Filename in Modem7 format */
   char *filename;		   /* The filename to be sent or received */
   char *path;			   /* Just the path to the file to be sent/received */
   char *fptr;			   /* Pointer into character fields */
   char *temp_name; 	   /* Temporary name for receiving */
   FILE *file_pointer;	   /* The pointer for read/write/seek operations */

   unsigned char header;
   XMDATA datablock;
} XMARGS, *XMARGSP;

#define DID_RESYNC 1

typedef struct {
   int tries;
   size_t barklen;
   int barkok;
   long T1;
   int nfiles;
   char *inbound;
   char *filename;
   char barkpacket[128];
   char *barkpw;
   char *barktime;
} BARKARGS, *BARKARGSP;

/*--------------------------------------------------------------------------*/
/* FIDONET ADDRESS STRUCTURE												*/
/*--------------------------------------------------------------------------*/
typedef struct _ADDRESS
{
   word  Zone;
   word  Net;
   word  Node;
   word  Point;
   char  *Domain;
} ADDR;

#ifdef MULTIPOINT
/* Extended addressing to include fakenet and phone number */

typedef struct {
	/*
	 * Same as address...
	 * I did make it "ADDR Ad"
	 * but it is too much hassle to change all the references
	 */
	ADDR ad;
	/*
	 * Extra stuff
	 */
	word fakenet;		/* Fakenet for this address [points and nodes] */
	char *phone;		/* Phone number of boss (points only) */
	struct {
		BOOLEAN use4d:1;	/* Use 4D addressing with BOSS */
		BOOLEAN usenet:1;	/* Use Fakenet when calling our net */
	} flags;
} ADDRESS;

typedef struct s_addrlist {
	struct s_addrlist *next;		/* Linked list next */
	ADDR ad;
} ADDR_LIST;

/* Key structure */

typedef struct s_adkey {
	struct s_adkey *next;	/* Stored as a singly linked list */
	ADDR ad;				/* Address to take action */
	/*
	 * Bits are set for wild cards
	 * I did consider using special values, e.g. 0 or -1
     * within the address but they may be valid numbers!
     * This also makes it more general, e.g. 2:ALL/0 is all zone gates
     */
	struct {
		BOOLEAN zone:1;
		BOOLEAN net:1;
		BOOLEAN node:1;
		BOOLEAN point:1;
		BOOLEAN domain:1;
	} wild;
	char *password;		/* Session Password... NULL means none */
	char *phone;		/* Phone number... or NULL */
	char *prefix;		/* Calling prefix.. e.g. ATB1&G1DT */
	char call_slot;		/* Character which defines Pollslot */
	ADDRESS *alias;		/* which of our addresses this is... NULL means none */
} ADKEY;

/*
 * Linked list of strings
 *
 * Used for the lists of HoldOnUs and NoEMSI
 */

typedef struct s_strlist {
	struct s_strlist *next;
	char *str;
} STR_LIST;

#endif

typedef struct mail {
   ADDR mail_addr;
   unsigned int mailtypes;
   unsigned int calls;
   unsigned int costcalls;
   unsigned int files;
   unsigned long size;
   unsigned long oldest;
	word realcost;
	word nodeflags;
   struct mail *next;
   struct mail *prev;
} MAIL, *MAILP;

typedef int (*nfunc) (ADDR *, int);

#define  MAX_EXTERN 		8		/* Maximum number of external transfer protocols */
#define  ALIAS_CNT		   30		/* Maximum number of alias's */
#define MAXDOMAIN		   50		/* Maximum number of Domains */

/*--------------------------------------------------------------------------*/
/* Matrix mask																*/
/* Undefined bits are reserved by Opus										*/
/*--------------------------------------------------------------------------*/
#define NO_TRAFFIC 0x0001
#define LOCAL_ONLY 0x0002
#define OPUS_ONLY  0x0004

#define NO_EXITS   0x2000
#define MAIL_ONLY  0x4000
#define TAKE_REQ   0x8000


/*--------------------------------------------------------------------------*/
/* Message packet header													*/
/*--------------------------------------------------------------------------*/

#define PKTVER		 2

 /*--------------------------------------------*/
 /* POSSIBLE VALUES FOR `product' (below)	   */
 /* */
 /* NOTE: These product codes are assigned by  */
 /* the FidoNet<tm> Technical Stardards Com-   */
 /* mittee.  If you are writing a program that */
 /* builds packets, you will need a product    */
 /* code.  Please use ZERO until you get your  */
 /* own.  For more information on codes, write */
 /* to FTSC at 115/333. 					   */
 /* */
 /*--------------------------------------------*/
#define isFIDO		 0
#define isSPARK 	 1
#define isSEA		 2
#define isSlick 	 4
#define isOPUS		 5
#define isHENK		 6
#define isTABBIE	 8
#define isWOLF		 10
#define isQMM		 11
#define isFD		 12
#define isGSPOINT	 19
#define isBGMAIL	 20
#define isCROSSBOW	 21
#define isDBRIDGE	 26
#define isBITBRAIN	 0x1b
#define isDAISY 	 30
#define isPOLAR 	 31
#define isTHEBOX	 32
#define isWARLOCK	 33
#define isTCOMM 	 35
#define isBANANNA	 36
#define isAPPLE 	 38
#define isCHAMELEON  39
#define isMAJIK 	 40
#define isDOMAIN	 47
#define isLESROBOT	 48
#define isROSE		 49
#define isPARAGON	 50
#define isBINKST	 51
#define isSTARNET	 52
#define isQUICKBBS	 54
#define isPBBS		 56
#define isTRAPDOOR	 57
#define isWELMAT	 58
#define isTIMS		 66
#define isISIS		 67


struct _pkthdr
{
		MWORD orig_node;		 /* originating node			   */
		MWORD dest_node;		 /* destination node			   */
		MWORD year;				 /* 0..99  when packet was created */
		MWORD month;			 /* 0..11  when packet was created */
		MWORD day;				 /* 1..31  when packet was created */
		MWORD hour;				 /* 0..23  when packet was created */
		MWORD minute;			 /* 0..59  when packet was created */
		MWORD second;			 /* 0..59  when packet was created */
		MWORD rate;				 /* destination's baud rate 	   */
		MWORD ver;				 /* packet version				   */
		MWORD orig_net;			 /* originating network number	   */
		MWORD dest_net;			 /* destination network number	   */
		char product;			/* product type 				  */
		char serial;			/* serial number (some systems)   */

   /* ------------------------------ */
   /* THE FOLLOWING SECTION IS NOT	 */
   /* THE SAME ACROSS SYSTEM LINES:  */
   /* ------------------------------ */

		byte password[8];		/* session/pickup password		  */
		MWORD  orig_zone;		 /* originating zone			   */
		MWORD  dest_zone;		 /* Destination zone			   */
		byte B_fill2[16];
		LONG B_fill3;
};



/*
 * Other structures (used to be in com.h)
 */

struct CONTROL
	{
	int carrier_mask;
	int handshake_mask;
	};


struct parse_list {
		size_t p_length;
		const char *p_string;
		};

struct secure {
		char *rq_OKFile;
		char *rq_FILES;
		char *rq_About;
		char *rq_Template;
		char *sc_Inbound;
		int rq_Limit;
		long byte_Limit;
		short time_Limit;
		};

struct req_accum {
		int files;
		long bytes;
		long startTime;
		int transferRate;	/* Transfer rate in cps */
		};

struct baud_str {
   unsigned short rate_value;
   unsigned short rate_mask;
};

/*
 * Include these because everything needs them!
 */

#include "externs.h"
#include "prototyp.h"
#include "logfile.h"

#endif	/* H_BINK */
/* END OF FILE: bink.h */
