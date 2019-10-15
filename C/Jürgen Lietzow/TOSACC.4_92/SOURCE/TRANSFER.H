/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC und AUTOTACC.PRG					*/
/*																		*/
/*		M O D U L E		:	TRANSFER.H									*/
/*																		*/
/*																		*/
/*		Author			:	JÅrgen Lietzow fÅr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	26.02.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#if !defined __TRANSVER

#define	__TRANSVER

#if !defined (__TOS)

	#include <tos.h>
	
#endif

#define		SAVE_FILE			"TOSACC.INF"
#define		VERSION				"TAcc 1.50"

#define	SysGEMDOS	(*(long	volatile cdecl	(**)(int, ...))		0x84)
#define	SysBIOS		(*(long	volatile cdecl	(**)(int, ...))		0xB4)
#define	SysXBIOS	(*(long	volatile cdecl	(**)(int, ...))		0xB8)

#define	hdv_rw		((int cdecl (**)(int, void *,int, int, int))0x476)
#define	hdv_mediach	((int cdecl (**)(int))						0x47E)
#define	hdv_bpb		((long cdecl(**)(int))						0x472)

#define	_resvalid	(*(long *)			0x426)
#define _resvector	(*(void (**)(void)) 0x42A)
#define _hz_200		(*(long *) 			0x4BA)
#define	_flock		(*(int *) 			0x43E)
#define	_sysbase	(*(TOS_HEAD **)		0x4F2)

#define _bcostat0vec	(*(long cdecl (**) (void))	0x55E)
#define _bconout0vec	(*(long cdecl (**) (int))	0x57E)

#define RESMAGIC	0x31415926L

#define	NOBUF		0
#define	RAMBUF		1
#define	DISKBUF		2
#define	MAX_CHARS	(1024 - 2 - 4)
#define	MAX_DBLOCKS	16384

typedef struct
{
		long		dummy1;
		long		magic;
		int			our_cookie;
		int			drive_on;
		int			drive;
		void		(*resvec)(void);
		long		resmag;
		int			hd_size;
		BPB			hd_bpb;
		long		hd_maxsec;
		long		code_len;
}	PHYS_HEAD;

typedef struct
{
		int			os_entry;
		int			os_version;
		void		*os_start;
		void		*os_base;
		void		*os_membot;
		int			(*os_shell)(char *);
		long		os_magic;
		long		os_gendat;
		int			os_palmode;
		int			os_gendatg;
									/* ab Version 1.2 */
		long		*os_pmifl;
		long		os_kbshift;
		BASPAG		*os_actpd;
}	TOS_HEAD;

struct _ch_block;

typedef union
{
		struct	_ch_block	*ptr;
		long				pos;
}	NEXT;
		
typedef struct _ch_block
{
		int					next_type;
		NEXT				next;
		char				data[1024-4-2];
}	CH_BLOCK;


typedef struct
{
		char	version[10];

/*	fÅr den Bildschirmschoner		*/

		int				scSwitch;
		int				scTime;
		void volatile	(**OldKEYBD)(void);
		void volatile	(**Old200HZ)(void);
		void volatile	(*NewKEYBD)(void);
		void volatile	(*New200HZ)(void);
		void volatile	(*InvertScreen)(void);
		int				colsav[16];
		int				secCount;
		int				scIsOn;
		int				scCount;
		int				scFlag;
		
/*	fÅr den Mausbeschleuniger */

		void volatile	(**OldMOUSE)(void);
		int				smSwitch;
		int				smKeep;
		void volatile	(*NewMOUSE)(void);
		char			d1[9];
		char			xList;
		char			d2[9];
		char			d3[9];
		char			yList;
		char			d4[9];
		int				x;
		int				y;
		
/*	fÅr die RAM-Disk	*/

		int  cdecl		(**OldMediach)(int);
		int  cdecl		(*NewMediach)(int);
		int  cdecl		(**OldRW)(int, void *,int, int, int);
		int  cdecl		(*NewRW)(int, void *,int, int, int);
		long cdecl		(**OldBPB)(int);
		long cdecl		(*NewBPB)(int);
		
		int				rd_installed;
		int				rd_drive;
		int				rd_size;
		int				rd_locked;
		long			rd_maxsec;
		char			*rd_data;
		BPB				*rd_bpb;

		PHYS_HEAD		*ph_head;
		int				OSVers;
		int				secTenth;
		int				in200HZ;

/*	FÅr den Spooler */

		int				inSys_flag;			/* 1 == PC im Betriebssystem */

		int				spStatErr;
		int				spRate;
		int				spOn;
		int				spQuick;
		long			spNChars;
		long			spNBlocks;
		long			spLockTime;
		int				spDemand;

		int				spRun;
		int				spLocked;
		int				spLockCount;
		int				spLastType;
		NEXT			spLast;
		int				spInPos;
		int				spOutPos;
		CH_BLOCK		*spOutFree;
		CH_BLOCK		*spFrees;
		CH_BLOCK		*spInBlk;
		CH_BLOCK		*spOutBlk;
		unsigned int	*spBMap;
		
		char			spFile[40];
		DTA				spDTA;
		
		int				spGEMDOSFlag;
		int				spBcostatFlag;
		int				spGDBufPos;
		char			spGDBuf[512];
				
		int  cdecl		(**OldGEMDOS)(int,...);
		int  cdecl		(**OldBIOS)(int,...);
		int  cdecl		(**OldXBIOS)(int,...);
		long cdecl		(**OldBcostat0)(void);
		long cdecl		(**OldBconout0)(void);
		
		int  cdecl		(*NewGEMDOS)(int,...);
		int  cdecl		(*NewBIOS)(int,...);
		int  cdecl		(*NewXBIOS)(int,...);
		long cdecl		(*NewBcostat0)(void);
		long cdecl		(*NewBconout0)(void);
		
		
		void 			(*ResetSpooler)( void );
		void 			(*DemandBlock)( void );
}	SYS;


typedef struct
{
		char	version[sizeof(VERSION)];
		int		onFlag;
		int		drive;
		int		size;
		char	fname[128];
		char	params[40];
		int		execFlag;
}	TACC_INF;

#endif