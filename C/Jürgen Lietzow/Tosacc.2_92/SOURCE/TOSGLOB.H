/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 1/92  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	TOS ACCESSORY Spezial						*/
/*							TOSACC.ACC									*/
/*																		*/
/*		M O D U L E		:	TOSGLOB.H									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 1.4, Pure C				*/
/*																		*/
/*		Last Update		:	18.10.91 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/


#if !defined __TOSGLOB__

#define __TOSGLOB__

#define		RESOURCE_FILE		"TOSACC.RSC"

#include	"TACCLIB.H"			/* RESOURCE_FILE muž vor TACCLIB.H */
								/* definiert sein */

#define		SAVE_FILE			"TOSACC.INF"

#define		MODE_TIMER			1
#define		MODE_TOPEN			2
#define		MODE_TCLOSE			4
#define		MODE_TACTIV			8
#define		MODE_TOPPED			16
#define		MODE_ACCCLOSE		32


#define WIN_KIND		(NAME|CLOSER|MOVER|UPARROW|DNARROW|VSLIDE)

typedef struct _tool
{
		WINDIA	wd;
		int		winHdl;
		int		(*save)( struct _tool *tool, FILE *fp );
		int		(*mode)( struct _tool *tool, int type );
		int		(*event)( struct _tool *tool, int evtype, EVENT *ev, int top );
}	TOOL;

typedef TOOL	*(TINIT)( FILE *fp, int hdl );

typedef struct
{
		char	version[10];

/*	fr den Bildschirmschoner		*/

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
		
/*	fr den Mausbeschleuniger */

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
}	SYS;

#if !defined(__TOSACC)

extern	SYS		*sys;

#endif		

#endif