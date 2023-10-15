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

#define		TIMER_ACCOPEN		0
#define		TIMER_ACCCLOSE		1
#define		MODE_TOPEN			2
#define		MODE_TCLOSE			3
#define		MODE_ACCCLOSE		4


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


#if !defined (__TOSACC__)

	extern	int		winHdl;

#endif

#endif