/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 6/92  <<<<<<<<<<<<<		*/
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
/*		Last Update		:	27.04.92 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/


#if !defined __TOSGLOB__

#define __TOSGLOB__

#include "transfer.h"

#define		RESOURCE_FILE		"TOSACC.RSC"

#include	"TGEMLIB\TGEMLIB.H"	/* RESOURCE_FILE muž vor TGEMLIB.H */
								/* definiert sein */


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
		int		(*exit)( struct _tool *tool );
}	TOOL;

typedef TOOL	*(TINIT)( FILE *fp, int hdl );


#if !defined(__TOSACC)

extern	SYS		*sys;
extern	char	saveFile[];
extern	TACC_INF taccInf;
extern	WINDIA		mainWD;

#endif		

#endif