/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/windlib.h,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:31:33 $	$Locker: kbad $
* =======================================================================
*  $Log:	windlib.h,v $
* Revision 2.2  89/04/26  18:31:33  mui
* TT
* 
* Revision 2.1  89/02/22  05:32:42  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:36:37  lozben
* Initial revision
* 
*************************************************************************
*/
/*	WINDLIB.H	05/05/84 - 10/16/84	Lee Lorenzen		*/

#define VF_INUSE 0x0001
#define VF_BROKEN 0x0002

typedef struct window
{
	WORD		w_flags;
	WORD		w_owner;
	WORD		w_kind;
	LONG		w_pname;
	LONG		w_pinfo;
	WORD		w_xfull;
	WORD		w_yfull;
	WORD		w_wfull;
	WORD		w_hfull;
	WORD		w_xwork;
	WORD		w_ywork;
	WORD		w_wwork;
	WORD		w_hwork;
	WORD		w_xprev;
	WORD		w_yprev;
	WORD		w_wprev;
	WORD		w_hprev;
	WORD		w_hslide;
	WORD		w_vslide;
	WORD		w_hslsiz;
	WORD		w_vslsiz;
	ORECT		*w_rlist;	/* owner rect. list	*/
	ORECT		*w_rnext;	/* used for search first*/
					/*   search next	*/
} WINDOW;

#define NUM_WIN 8
#define NUM_ORECT 80			/* is this enough???	*/

#define WS_FULL 0
#define WS_CURR 1
#define WS_PREV 2
#define WS_WORK 3
#define WS_TRUE 4

#define XFULL 0
#define YFULL gl_hbox
#define WFULL gl_width
#define HFULL (gl_height - gl_hbox)

#define NAME 0x0001
#define CLOSER 0x0002
#define FULLER 0x0004
#define MOVER 0x0008
#define INFO 0x0010
#define SIZER 0x0020
#define UPARROW 0x0040
#define DNARROW 0x0080
#define VSLIDE 0x0100
#define LFARROW 0x0200
#define RTARROW 0x0400
#define HSLIDE 0x0800

#define W_BOX 0
#define W_TITLE	1
#define W_CLOSER 2
#define W_NAME	3
#define W_FULLER 4
#define W_INFO 5
#define W_DATA	6
#define W_WORK	7
#define W_SIZER	8
#define W_VBAR 9
#define W_UPARROW 10
#define W_DNARROW 11
#define W_VSLIDE 12
#define W_VELEV	13
#define W_HBAR 14
#define W_LFARROW 15
#define W_RTARROW 16
#define W_HSLIDE 17
#define W_HELEV	18

#define NUM_ELEM 19

#define WC_BORDER 0
#define WC_WORK 1


#define WF_KIND 1
#define WF_NAME 2
#define WF_INFO 3
#define WF_WXYWH 4
#define WF_CXYWH 5
#define WF_PXYWH 6
#define WF_FXYWH 7
#define WF_HSLIDE 8
#define WF_VSLIDE 9
#define WF_TOP 10
#define WF_FIRSTXYWH 11
#define WF_NEXTXYWH 12
#define WF_IGNORE 13
#define WF_NEWDESK 14
#define WF_HSLSIZ 15
#define WF_VSLSIZ 16
						/* arrow message	*/
#define WA_UPPAGE 0
#define WA_DNPAGE 1
#define WA_UPLINE 2
#define WA_DNLINE 3
#define WA_LFPAGE 4
#define WA_RTPAGE 5
#define WA_LFLINE 6
#define WA_RTLINE 7
