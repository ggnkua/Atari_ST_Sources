/********************************************************/
/*                                                      */
/*      Stuff to INCLUDE in SID-68K                     */
/*                                                      */
/********************************************************/
 
#define MAXBP    10		/* max breakpoints allowed */
#define ILLEGAL	 0x4AFC		/* ILLEGAL instruction	   */
#define BDOSCALL 0x4E42		/* TRAP #2 instruction	   */
#define BIOSCALL 0x4E43		/* TRAP #3 instruction	   */
#define BUFLEN   85		/* command buffer length   */
 
#define GETSEP   getsep(&cx)
 
struct bytestr { char memb; };
struct wordstr { int  memw; };
struct longstr { long meml; };

/****************************************************************/
/*                                                              */
/*      Define the CPU Status Structure and Related Tables      */
/*                                                              */
/****************************************************************/
 
struct cpustate {
                long  pc;
                long  usp;
                long  ssp;
                 int  status;
                long  dreg[8];
                long  areg[8];
#ifdef MC68010
		long  vbr;
		long  sfc;
		long  dfc;
#endif
};
        
#define TRACE   0x8000
#define SUPER   0x2000
#define INTMSK  0x0700
#define EXTEND  0x0010
#define NEG     0x0008
#define ZERO    0x0004
#define OFLOW   0x0002
#define CARRY   0x0001


/****************************************************************/
/*								*/
/*	Base Page Structure					*/
/*								*/
/****************************************************************/

struct basepage {
/*0x00*/	long lowtpa;	/* low  address of tpa	*/
		long hightpa;	/* high address of tpa	*/
		long csstart;	/* start  of code seg	*/
		long cslen;	/* length of code seg	*/
/*0x10*/	long dsstart;	/* start  of data seg	*/
		long dslen;	/* length of data seg	*/
		long bsstart;	/* start  of bss  seg	*/
		long bslen;	/* length of bss  seg	*/
/*0x20*/	char reserved[96];	/* unused by SID	*/
		/* char * p_xdta;	disk transfer address */
		/* PD *	p_parent;	parent PD			*/
		/* char	p_lddrv;	load drive		*/
		/* char	p_curdrv;	current drive		*/
		/* char	p_uft[NUMSTD]; inx sys file table for std files */
	/*0x30  char	p_curdir[16];	inx sys dir table*/
	/*0x40  long	p_dreg[8];	store for D0-D7*/
	/*0x60  long	p_areg[8];	store for A0-A7*/
/*0x80*/	char comtail[0x80];	/* command line image*/
};



/************************************************************************/
/*									*/
/*	Define a structure for holding information about the most	*/
/*	recently loaded program or file					*/
/*									*/
/************************************************************************/

struct value {
		int  kind;	/* 0 => none, 1 => pgm, 2 => file */
		long textbase;	/* if kind==2 then use textseg for file */
		long textlen;
		long database;
		long datalen;
		long bssbase;
		long bsslen;
		long bpa;
		long initstk;
};	

struct hdr {
		int	signature;
		long	seglen[4];
	} ;


/****************************************************************/
/*								*/
/*	Some Forward Function Definitions			*/
/*								*/
/****************************************************************/
 
     char *readcom();
     char  hexchar();
short int  getform(); 
/*long int   GETSSP();
*/
#ifdef MC68010

long int GETVBR();
long int GETSFC();
long int GETDFC();

#endif
 
/**/
 
