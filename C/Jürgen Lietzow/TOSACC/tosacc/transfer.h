/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC und AUTOTACC.PRG					*/
/*																		*/
/*		M O D U L E		:	TRANSFER.H									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	27.04.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#if !defined __TRANSVER

#define	__TRANSVER

#if !defined (__TOS)

	#include <tos.h>
	
#endif

#include "allocres.h"

#define		_VERSION			"1.60"
#define		VERSION				"TAcc " _VERSION


/*	defines for the system */

#define	SysGEMDOS	(*(long	volatile cdecl	(**)(int, ...))		0x84)
#define	SysBIOS		(*(long	volatile cdecl	(**)(int, ...))		0xB4)
#define	SysXBIOS	(*(long	volatile cdecl	(**)(int, ...))		0xB8)

#define	hdv_rw		(*(int	volatile cdecl (**)(int, void *,int, int, int))0x476)
#define	hdv_mediach	(*(int	volatile cdecl (**)(int))			0x47E)
#define	hdv_bpb		(*(long volatile cdecl (**)(int))			0x472)
#define _resvector	(*(void volatile cdecl (**)(void))			0x42A)
#define	vsync		(*(void volatile cdecl (**)(void))			0x70)
#define	etv_term	(*(void volatile cdecl (**)(void))			0x408)

#define	_resvalid	(*(long *)				0x426)
#define _hz_200		(*(long *) 				0x4BA)
#define	_flock		(*(int *) 				0x43E)
#define	_sysbase	(*(TOS_HEAD **)			0x4F2)
#define	pinfo		(*(PUN_INFO **)			0x516)
#define	DrvMap		(*(long *) 				0x4c2)

#define RESMAGIC	0x31415926L

typedef struct _osheader
{
		int			os_entry;
		int			os_version;
		void		*os_reseth;
		struct _osheader *os_beg;
		void		*os_end;
		int			(*os_shell)(char *);
		void		*os_magic;
		long		os_gendat;
		int			os_palmode;
		int			os_gendatg;
									/* ab Version 1.2 */
		long		*os_pmifl;
		long		os_kbshift;
		BASPAG		*os_actpd;
}	TOS_HEAD;

typedef	void (*sys_vec)();

/* Return codes by BIOS */

# define	OK					0L
# define	DRIVE_NOT_READY		-2L
# define	SEC_READ_ERR		-4L
# define	UNKNOWN_MEDIA		-7L
# define	SEC_NOT_FOUND		-8L
# define	BAD_SECTORS			-16L
# define	MEDIA_CHANGE		-14L

/*	defines for Spooler */

#define _bcostat0vec	(*(long cdecl (**) (void))	0x55E)
#define _bconout0vec	(*(long cdecl (**) (int))	0x57E)
		
/*	defines for the cache	*/

#define	MAXUNITS		16		/*	number of supported physival drives	*/
#define	MAXDRIVES		16		/*	number of supported logical drives */

/*	hdv_rw	*/

#define	READ			0
#define	WRITE			1

/* Drive types and drive default types */

#define D_OFF           0	/*	drive is not cached at all */

#define D_READ          1	/*	on this drive is a read cache */
#define D_WRITE         2   /*	on this drive is a write cache */
							/*	D_READ has to be set too */
#define D_LOCKED		4	/*	this drive is write locked */
#define D_KNOWN			8	/*	drive known via BPB */
#define D_VALID			16	/*	drive params are valid to cache */


typedef unsigned int 	uint;
typedef char 			*SECTOR;


typedef struct _pun_info
{
		int			puns;
		char		pun[MAXUNITS];
		long		part_start[MAXUNITS];
		long		P_cookie;
		long		*P_cookptr;
		unsigned	P_version;
		int			P_max_sector;
}	PUN_INFO;

/*	parameters how they are on the stack by hdv_rw */

typedef struct
{
		long		rwReturn;
		int			rwFlag;
		char		*rwBuf;
		int			rwCount;
		uint		rwRecno;
		int			rwDrv;
		long		rwLrecno;
}	RWABS;

/*	Sector informations */

typedef struct _recinf
{
		struct _recinf	*riNext;		/* points to next bigger sector */
		long			riRecno;		/* sector number */
		struct _recinf	*riLast;		/* points to next smaller sector */
		int				riDirty;		/* sector type */
		int				riCheckSum;		/* checksum of sector data */
		struct _recinf	*riNewer;		/* next newer sector */
		struct _recinf	*riOlder;		/* next older sector */
		int				riDrv;			/* sector drive */
										/* sizeof (RECINF) == 26 */
}	RECINF;

/*	drive informations */

typedef struct
{
		RECINF		diFirst;		/* sector with lowest sector number */
									/* di_first.ri_next is really the first */
									/* one */
		RECINF		diLast;			/* see above */
		int			diKnown;		/* known via BPB */
		int			diValid;		/* known drive params are valid and */
									/* so supported by cache */
		int			diRead;			/* user set read cache flag */
		int			diWrite;		/* user set write cache flag */
		int			diFirstWrt;		/* set, if some sectors are written */
									/* since last time out */
		int			diDirty;		/* number of write cached sectors */
		int			diLocked;		/* user set write locked flag */
		int			diRecSiz;		/* sector size of this drive in */
									/* terms of 512 Byte blocks */
		long		diRecNum;		/* number of sectors on this drive */
		BPB			*diBpb;			/* point to BPB of the drive */
		char		reserved[128-76];
									/* sizeof (DRIVEINF) == 128 */
}	DRIVEINF;


# define		ChkOk(a)		((a)->chksum == CheckSum((a)->sector))

/*	header of resident user meory block */

typedef struct
{
		int			kbSiz;			/* size of resident memory KBytes */
		int			recSiz;
		
}	RESINF;

/*	structure of start of TOSACC.INF */

typedef struct
{
		char		version[sizeof(VERSION)];
		
/*	Memory */

		int			nxtKbSiz;		/*	size of resident memory (KBytes) */
		int			nxtRecSiz;		/*	size of smallest memory block */
									/*	in terms of 512 bytes */

/*	RAM-Disk */

		int			rdNxtOn;		/*	on flag	*/
		int			rdNxtDrv;		/*	drive number of RAM-disk */
		char		rdFname[128];	/*	auto start file name */
		char		rdParams[40];	/*	parameters for above */
		int			rdExecFlag;		/*	execute programm above */
		
/*	save screen */

		int			scSwitch;		/*	screen saver on flag */
		int			scTime;			/*	time out time (seconds) */

/*	mouse speeder */

		int			smSwitch;		/*	mouse speeder on flag */
		int			smKeep;			/*	keep direction flag */
		char		d1[9];
		char		xList;
		char		d2[9];
		char		d3[9];			/*	speeder offset list */
		char		yList;
		char		d4[9];

/*	printer spooler */

		long		spRate;			/*	system time rate for spooler */
		int			spOn;			/*	spooler on flag */
		int			spQuick;		/*	direkt hardware access flag */

/*	timer	*/

		long		tiTime;			/*	timer	*/
		int			tiFlag; 		/*	timer on flag (0)	*/

/*	disk cache info */

		int			ciOn;
		long		ciDelay;		/*	write delay time */
		int			ciDrvTypes[MAXDRIVES]; /* cache type for each drive */

}	TACC_INF;




typedef struct
{
		TACC_INF	tai;
		
		char		saveFile[16];	/*	path and name of the	*/
									/*	configuration file */
		int			confInstalled;	/*	all installations of a */
									/*	configuration programm are done */
		int			confActiv;		/*	currently a configuration */
									/*	programm is working */

		RES_MEM		*resMem;		/*	points to resident part */
		int			OSVers;			/*	TOS version */
		int			subprFlag;		/*	sub prozess on flag */
		int			secTenth;		/*	counts down from 20 */
		long		tsecCount;		/*	system 1/10 secound counter */

		int			hz200Flag;		/* in HZ200 Flag */
		int			ahdiFlag;		/* AHDI 3.0 installed flag */
		int			kbSiz;			/* current memroy size (in KBytes) */
		int			blkSiz;			/* sector size + sizeof (RECINF)  */
		int			recSiz;			/* sector size / 512 */
		int			absRecSiz;		/* sector size in bytes */

		SECTOR		*copyBlk;		/* space for two blocks */
		SECTOR		*blkArr;		/* SECTOR array */
		int			blkNum;			/* total number of blocks */
		SECTOR		*blkFrees;		/*	points to unused blocks */
									/*	first 4 bytes of each block */
									/*	points to next one */
		int			blkFreeNum;		/*	number of free blocks */
		int			ciBlkNum;		/*	number of blocks in cache */
		int			rdBlkNum;		/*	number of blocks in RAM-Disk*/
		int			spBlkNum;		/*	number of blocks in Spooler */

/*	screen saver */

		int			colsav[16];		/*	temporary buffer */
		long		scOutTime;		/*	time for next screen status switch */
		int			scIsOn;			/*	current screen status */
		int			scFlag;			/*	change screen status on next hz_200 */
		
		void volatile (*_InvertScreen)(void);

/*	mouse speeder */

		int			x;				/*	temp x offset */
		int			y;				/*	temp y offset */
		
/*	RAM-Disk	*/

		int			rdOn;			/* current RAM-Disk Status */
		int			rdDrv;			/* current RAM-Disk drive */
		long		rdMaxRec;		/* number of sectors in RAM-Disk */
		BPB			rdBpb;			/* BPB of RAM-Disk */
		SECTOR		**rdRecPtrs;	/* points to array of sector pointers */
		int			rdDirty;		/* write access since last Clear */
		
/*	printer spooler */

		long		spNChars;		/* number of characters in spooler */
		long		spTChars;		/* total number of characters send */
									/* to printer */
		int			spRun;			/* time out error flag */
		int			spInPos;
		int			spOutPos;
		SECTOR		*spInBlk;
		SECTOR		*spOutBlk;
		
		void 		(*_ResetSpooler)( void );

/*	Cache */

		int			ciDirty;
		int			ciDelayOff;
		long		ciTimeOut;			/*	temp: holds next delay time */
		RECINF		ciNewest;			/*	sector last added */
										/*	in fact ci_newest.ri_older */
										/*	is the first one */
		RECINF		ciOldest;			/*	see ahead */
		PUN_INFO	*ciPuninfo;			/*	points to current oun_info */
										/*	Zero if not valid */
		long		ciLogrd;			/*	number of sectors logically */
										/*	read */
		long		ciPhrd;				/*	sectors physically read  */
		long		ciLogwrt;			/*	sectors logically written */
		long		ciPhwrt;			/*	sectors physically written */

		long		ciFixederr;			/*	number of checksum errors */
										/*	occured and have been fixed */
		long		ciFatalerr;			/*	fatal errors which still are */
										/*	in the cache */
		long		ciRetSav;			/*	internal */
		DRIVEINF	di[MAXDRIVES];		/*	Drive infos for all supported */
										/*	ones */

		void		(*_ciState)(int status);
										/*	1 : suppresses delayed updating */
										/*	2 : call original hdv_rw, but */
										/*		keep cache datas */
										/*	4 : cache off */
										/*	8 : write cache all read */
										/*		cached drives */
										/*	default is 0 */
		void		(*_ciFlush)(void);	/*	updates all write caches sectors */
		void		(*_ciClear)(void);	/*	clears cache buffer */
										/*	!! Does not flush the cache */
		int			(*_ciDrState)(int drv); /* gives cache status of drive */
		int			(*_ciDrSet)(int drv,int state );
										/*	changes cache status of drive */

/*	system vectors	*/

	/*	set in AUTOTACC.PRG */
	
		int  volatile cdecl	(**_OldMediach)	(int);
		int  volatile cdecl	(*_NewMediach)	(int);

		int  volatile cdecl	(**_OldRW)		(int, void *,int, int, int);
		int  volatile cdecl	(*_NewRW)		(int, void *,int, int, int);

		long volatile cdecl	(**_OldBPB)		(int);
		long volatile cdecl	(*_NewBPB)		(int);

		int  volatile cdecl	(**_OldGEMDOS)	(int,...);
		int  volatile cdecl	(*_NewGEMDOS)	(int,...);

		int  volatile cdecl	(**_OldBIOS)	(int,...);
		int  volatile cdecl	(*_NewBIOS)		(int,...);

		int  volatile cdecl	(**_OldXBIOS)	(int,...);
		int  volatile cdecl	(*_NewXBIOS)	(int,...);

		long volatile cdecl	(**_OldBcostat0)(void);
		long volatile cdecl	(*_NewBcostat0)	(void);

		long volatile cdecl	(**_OldBconout0)(void);
		long volatile cdecl	(*_NewBconout0)	(void);

		void volatile		(**_Old200HZ)	(void);
		void volatile		(*_New200HZ)	(void);

	/* set in TOSACC */
	
		void volatile		(**_OldKEYBD)	(void);
		void volatile		(*_NewKEYBD)	(void);

		void volatile		(**_OldMOUSE)	(void);
		void volatile		(*_NewMOUSE)	(void);

}	SYS;

#endif