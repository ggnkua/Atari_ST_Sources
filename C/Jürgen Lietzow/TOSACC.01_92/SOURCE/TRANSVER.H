/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 3/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC und AUTOTACC.PRG					*/
/*																		*/
/*		M O D U L E		:	TRANSVER.H									*/
/*																		*/
/*																		*/
/*		Author			:	JÅrgen Lietzow fÅr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	31.01.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#if !defined __TRANSVER

#define	__TRANSVER

#if !defined (__TOS)

	#include <tos.h>
	
#endif

#define		SAVE_FILE			"TOSACC.INF"
#define		VERSION				"TAcc 1.40"

#define	SysGEMDOS	((long	volatile cdecl	(**)(int, ...))		0x84)

#define	hdv_rw		((int cdecl (**)(int, void *,int, int, int))0x476)
#define	hdv_mediach	((int cdecl (**)(int))						0x47E)
#define	hdv_bpb		((long cdecl(**)(int))						0x472)

#define	_resvalid	(*(long *) 0x426)
#define _resvector	(*(void **) 0x42a)
#define RESMAGIC	0x31415926L
#define	_RESMAGIC	0x12123456L

typedef struct
{
		long		dummy;
		long		magic1;
		long		magic2;
		void		*hd_selfe;
		int			hd_size;
		BPB			hd_bpb;
		long		hd_maxsec;
		char		hd_buffer[4];
}	RD_HEAD;

typedef struct
{
		long		resmag;
		void		*selfe;
		int			rts;
		long		magic1;
		long		magic2;
		RD_HEAD		*head;
		int			chksum;
}	RES_HEAD;

		
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
		long			rd_maxsec;
		BPB				*rd_bpb;
		RD_HEAD			*rd_head;
		
		void			*rd_oldtop;
		void			*rd_newscreen;
		long			rd_total;

		void			*rd_vecsav;
		long			rd_valsav;


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