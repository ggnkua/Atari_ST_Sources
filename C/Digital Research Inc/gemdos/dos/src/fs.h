/*  fs.h - file system defines						*/
/*  GEMDOS file system (plus some other things) header			*/


/*
** 
** MODIFICATION HISTORY
** 
** 	11 Mar 85	SCC	Added bconostat().
** 
** 	10 Apr 85	SCC	Removed MEDIA_CHANGE.
** 
** 	12 Apr 85	EWF	Added KBBUFSZ.
** 
** 			SCC	Installed EWF's change.
** 
** 	 9 Aug 85	SCC	Added several defines (begining with
** 				"BDOS level character device file handles")
** 
** 	11 Aug 85	SCC	Added B_FIX flag to BPB b_flags field.
** 
** 				Incorporated defines for BIOS level character
** 				device handles and changed HXFORM
** 	
** 	04 Sep 85	KTB	M01.01.01: Modified OFD definition to expand 
**				it to next paragraph boundary.  This is TEMP
**				for debugging.
**
**	14 Oct 85	KTB	deleted items required by bios, moving them
**				into bios.h
**
**	17 Oct 85	KTB	M01.01.02: added extern declarations to
**				facilitate split up of fs modules.
**
**	04 Nov 85	KTB	M01.01.03: new types: RECNO, CLNO.  these
**				are unsigned ints to be used for sector numbers
**				(or sector counts) and cluster numbers (any
**				value in the fat) respectively
**
**	15 Nov 85	KTB	M01.01.04: new type: FH (file handle).  To be
**				added in declarations as they are modified.
**
**	25 Feb 86	KTB	M01.01.05: modified BCB definition.
**
**	21 Mar 86	KTB	M01.01.06: new access method
**	27 May 86	KTB	M01.01.0527.03: removed decl of xcmps since it
**				is only used in one module.
**	29 May 86	KTB	M01.01.0529.01: removed O_COMPLETE flag in DND
**
**	08 Jul 86	KTB	M01.01a.0708.02: moved def of dirscan() to
**				fsdir.c
**
**	19 Sep 86	SCC	M01.01.0919.01: changed definitions of 'time' and
**				'date' to 'unsigned int'.
**
**	31 Oct 86	scc	M01.01.1031.01:  Removed extern definition of ValidDrv()
**
** NAMES
** 
** 	JSL	Jason S. Loveman
** 	SCC	Steve C. Cavender
** 	EWF	Eric W. Fleischman
**	KTB	Karl T. Braun (kral)
*/

/*
**  fix conditionals
*/

#define	M0101052901	1

/*
**  constants
*/

#define SLASH '\\'

#define SUPSIZ 1024	/* common supervisor stack size (in words) */
#define OPNFILES 40	/* max open files in system */
#define NCURDIR 40	/* max current directories in use in system */
#define NUMSTD 6	/* number of standard files */
#define	KBBUFSZ	128	/* size of typeahead buffer -- must be power of 2!! */
#define	KBBUFMASK	(KBBUFSZ-1)

/*
**  code macros
*/

#define swp68(x) s68(&x)
#define swp68l(x) s68l(&x)
#define NULPTR ((char *) 0)
#define MGET(x) ((x *) xmgetblk((sizeof(x) + 15)>>4))
#define bconstat(a) trap13(1,a)
#define bconin(a) trap13(2,a)
#define bconout(a,b) trap13(3,a,b)
/* SCC  11 Mar 85 */
#define bconostat(a) trap13(8,a)
#define getbpb(a) trap13(7,a)
#define getmpb(a) trap13(0,a)
#define rwabs(a,b,c,d,e) if(rwerr=trap13(4,a,b,c,d,e)){errdrv=e;longjmp(errbuf,rwerr);}

#define min(a,b) (((a) < (b)) ? (a) : (b))
#define	xmovs(n,s,d)	bmove(s,d,n)


/*
**  Type declarations
*/

#define	BCB	struct	_bcb
#define	FTAB	struct	_ftab
#define	PD	struct	_pd
#define	OFD	struct	_ofd
#define	FCB	struct	_fcb
#define	DND	struct	_dnd
#define	DMD	struct	_dmd
#define	CLNO	int		/*  cluster number M01.01.03	*/
#define	RECNO	int		/*  record number M01.01.03	*/
				/*** this should be changed to a long!! ***/
#define	FH	unsigned int		/*  file handle M01.01.04	*/

/*
**  PD - Process Descriptor
*/

#define	PDCLSIZE	0x80		/*  size of command line in bytes  */
#define	NUMCURDIR	16		/*  number of entries in curdir array */

PD	/* this is the basepage format */
{
/* 0x00 */
	long	p_lowtpa;
	long	p_hitpa;
	long	p_tbase;
	long	p_tlen;
/* 0x10 */
	long	p_dbase;
	long	p_dlen;
	long	p_bbase;
	long	p_blen;
/* 0x20 */
	char	*p_xdta;
	PD	*p_parent;	/* parent PD */
	long	p_0fill[1];
	char	*p_env;		/* at offset 2ch (eat your heart out, Lee) */
/* 0x30 */
	char	p_uft[NUMSTD];	/* index into sys file table for std files */
	char	p_lddrv;
	char	p_curdrv;
	long	p_1fill[2];
/* 0x40 */
	char	p_curdir[NUMCURDIR];	/* index into sys dir table */
/* 0x50 */
	long	p_2fill[4];
/* 0x60 */
	long	p_3fill[2];
	long	p_dreg[1];	/* dreg[0] */
	long	p_areg[5];	/* areg[3..7] */
/* 0x80 */
	char	p_cmdlin[PDCLSIZE];
} ;


/*
**  OFD - open file descriptor
**	M01.01.03
*/


OFD 
{
	OFD	*o_link;	/*  link to next OFD			*/
	int	o_flag;
	int	o_time;    	/*  the next 4 items must be as in FCB	*/
	int	o_date;		/*  time, date of creation		*/
	CLNO	o_strtcl;	/*  starting cluster number 		*/
	long	o_fileln;	/*  length of file in bytes		*/

	DMD	*o_dmd;		/*  link to media descr			*/
	DND	*o_dnode;	/*  link to dir for this file		*/
	OFD	*o_dirfil;	/*  OFD for dir for this file		*/
	long	o_dirbyt;	/*  pos in dir of this files fcb (dcnt)	*/

	long	o_bytnum;  	/* byte pointer within file		*/
	CLNO	o_curcl;   	/* not used				*/
	RECNO	o_currec;  	/* not used				*/
	int	o_curbyt;  	/* not used				*/
	int	o_usecnt;  	/* use count for inherited files	*/
	OFD	*o_thread; 	/* mulitple open thread list		*/
        int     o_mod;     	/* mode file opened in (r, w, r/w) 	*/
} ;							/*  0x32  */


	/* 
	**  O_DIRTY - Dirty Flag
	**	T: OFD is dirty, because of chg to startcl, length, time, etc. 
	*/

#define O_DIRTY		1

#if	! M0101052901
	/*
	**  O_COMPLETE - 
	**	1: traversal of directory file (to bld dir tree) has completed 
	*/

#define O_COMPLETE	2
#endif



/*
**  FCB - File Control Block
**	M01.01.03
*/


FCB
{
	char	f_name[11];
	char	f_attrib;
	char	f_fill[10];
	int	f_time;
	int	f_date;
	CLNO	f_clust;
	long	f_fileln;
} ;
#define	FA_VOL		0x08
#define FA_SUBDIR	0x10
#define FA_NORM		0x27
#define FA_RO		0x01


/*
**  DND - Directory Node Descriptor
**	M01.01.03
*/


DND /* directory node descriptor */
{
	char	d_name[11];	/*  directory name			*/
	char	d_fill;		/*  attributes?				*/
	int	d_flag;
	CLNO	d_strtcl;	/*  starting cluster number of dir	*/

	int	d_time;		/*  last mod ?				*/
	int	d_date;		/*  ""   ""				*/
	OFD	*d_ofd;		/*  open file descr for this dir	*/
	DND	*d_parent;	/*  parent dir (..)			*/
	DND	*d_left; 	/*  1st child 				*/

	DND	*d_right; 	/*  sibling in same dir			*/
	DMD	*d_drv;		/*  for drive 				*/
	OFD	*d_dirfil;
	long	d_dirpos;	/*  */

	long	d_scan; 	/*  current posn in dir for DND tree	*/
	OFD	*d_files; 	/* open files on this node 		*/
} ;

/* flags:	*/
#define	B_16	1				/* device has 16-bit FATs	*/
#define	B_FIX	2				/* device has fixed media	*/



/*
**  DMD - Drive Media Block
*/

/*  records == sectors  */

DMD /* drive media block */
{
	int	m_recoff[3]; 	/*  record offsets for fat,dir,data 	*/
	int	m_drvnum;	/*  drive number for this media		*/
	RECNO	m_fsiz;		/*  fat size in records M01.01.03	*/
	RECNO	m_clsiz;	/*  cluster size in records M01.01.03	*/
	int	m_clsizb;	/*  cluster size in bytes		*/
	int	m_recsiz;	/*  record size in bytes		*/

	CLNO	m_numcl;	/*  total number of clusters in data	*/
	int	m_clrlog; 	/* clsiz in rec, log2 is shift 		*/
	int	m_clrm;	 	/* clsiz in rec, mask 			*/
	int	m_rblog;  	/* recsiz in bytes, shift		*/
	int	m_rbm;   	/* recsiz in bytes, mask 		*/
	int	m_clblog;	/* log of clus size in bytes		*/
	OFD	*m_fatofd;	/* OFD for 'fat file'			*/

	OFD	*m_ofl;		/*  list of open files			*/
	DND	*m_dtl; 	/* root of directory tree list		*/
	int	m_16; 		/* 16 bit fat ? 			*/
} ;



/*
**  BCB - Buffer Control Block			*  M01.01.05  *
*/

BCB
{
	BCB	*b_link;	/*  next bcb			*/
	int	b_bufdrv;	/*  unit for buffer		*/
	int	b_buftyp;	/*  buffer type			*/
	int	b_bufrec;	/*  record number		*/
	BOOLEAN	b_dirty;	/*  true if buffer dirty	*/
	long	b_dm;		/*  reserved for file system	*/
	BYTE	*b_bufr;	/*  pointer to buffer		*/
} ;

/*
**  FTAB - Open File Table Entry
*/

/* point these at OFDs when needed */
FTAB
{
	OFD	*f_ofd;
	PD	*f_own; /* file owners */
	int	f_use;  /* use count */
} ;


/******************************************
**
** BDOS level character device file handles
**
*******************************************
*/

#define	H_Null		-1		/* not passed through to BIOS	*/
#define	H_Print		-2
#define	H_Aux		-3
#define	H_Console	-4
#define	H_Clock		-5
#define	H_Mouse		-6


/****************************************
**
** Character device handle conversion
** (BDOS-type handle to BIOS-type handle)
**
*****************************************
*/

#define HXFORM(h)	bios_dev[-h-2]

/**********************
**
** BIOS function macros
**
***********************
*/

#define	CIStat(d)	trap13(0x01,d)		/* Character Input Status   */
#define GetBPB(d)	(BPB *)trap13(0x07,d)	/* Get BIOS Parameter Block */
#define	COStat(d)	trap13(0x08,d)		/* Character Output Status  */
#define	GetDM()		trap13(0x0A)		/* Get Drive Map	    */
#define CIOCR(d,l,b)	trap13(0x0C,d,l,b)	/* Char IOCtl Read	    */
#define CIOCW(d,l,b)	trap13(0x0D,d,l,b)	/* Char IOCtl Write	    */
#define DIOCR(d,l,b)	trap13(0x0E,d,l,b)	/* Disk IOCtl Read	    */
#define DIOCW(d,l,b)	trap13(0x0F,d,l,b)	/* Disk IOCtl Write	    */
#define CVE(d,a)	trap13(0x10,d,a)	/* Char Vector Exchange	    */


/**********************
**
** F_IOCtl subfunctions
**
***********************
*/

#define	XCVECTOR	-1			/* Exchange vector	    */
#define	GETINFO		0			/* Get device info	    */
#define	SETINFO		1			/* NOT IMPLEMENTED	    */
#define	CREADC		2			/* Character read control   */
#define	CWRITEC		3			/* Character write control  */
#define	DREADC		4			/* Disk read control	    */
#define	DWRITEC		5			/* Disk write control	    */
#define	INSTAT		6			/* Input status		    */
#define	OUTSTAT		7			/* Output status	    */
#define	REMEDIA		8			/* Removeable indication    */

/*************************
**
** Device information bits
**
**************************
*/

#define	Is_Console	0x0003			/* Both stdin & stdout	    */
#define	Is_NUL		0x0004
#define	Is_Clock	0x0008
#define	Is_Character	0x00C0			/* Character is binary now  */
#define Does_IOCtl	0x4000


/*******************************
**
**  External Declarations
**
********************************
*/

extern	DND	*dirtbl[] ;
extern	DMD	*drvtbl[] ;
extern	char	diruse[] ;
extern	int	drvsel ;
extern	PD	*run ;
extern	int	logmsk[] ;
extern	FTAB	sft[] ;
extern	long	rwerr ;
extern	int	errdrv ;
extern	long	errbuf[] ;		/*  in sup.c			*/
extern	BCB	*bufl[2] ;		/*  in bios main.c		*/
extern	unsigned int	time, date ;
extern	int	bios_dev[] ;		/*  in fsfioctl.c		*/

extern	int	*xmgetblk();
extern	long	trap13();
extern	long	constat();


/********************************
**
**  Forward Declarations
**
*********************************
*/

DND	*dcrack() ;
FCB	*scan() ;
DND	*findit() ;
DMD	*getdmd() ;
OFD	*getofd() ;
FCB	*dirinit() ;
OFD	*makofd() ;
char	*packit() ;
DND	*makdnd() ;
char	*getrec() ;
VOID	movs() ;
VOID	xfr2usr() ;
VOID	usr2xfr() ;
VOID	uc() ;

long xread(), xwrite(), xlseek(), xrw(), ixread(), ixwrite(), ixlseek(), 
	ixforce();
long ixsfirst(), ixcreat(), ixopen(), ixdel(), ixclose(), makopn(), log();
long opnfil() ;

/********************************
**
**  Misc. defines
**
*********************************
*/

#define	CL_DIR	0x0002
#define	CL_FULL	0x0004


/*---------*/

