/*	WINDLIB.H	1991				Minna Lai		*/
/*	Edited 		9/21/92				D.Mui			*/ 

#ifndef _WINDLIB_H_
#define _WINDLIB_H_

#define WINICON_W	72
#define WINICON_H	72

#define WS_FULL 0
#define WS_CURR 1
#define WS_PREV 2
#define WS_WORK 3
#define WS_TRUE 4

#define XFULL 	0
#define YFULL 	gl_hbox
#define WFULL 	gl_width
#define HFULL 	(gl_height - gl_hbox)

/* Bit mask for window components */

#define NAME	0x0001
#define CLOSER	0x0002
#define FULLER	0x0004
#define MOVER	0x0008
#define INFO	0x0010
#define SIZER	0x0020
#define UPARROW 0x0040
#define DNARROW 0x0080
#define VSLIDE	0x0100
#define LFARROW 0x0200
#define RTARROW 0x0400
#define HSLIDE	0x0800

/* added 4/22/93 ERS; */
/* changed from 0x1000 to 0x4000 for PC compatibility, 7/19/93 */
/* (0x1000 is used under PC GEM for repeat fct on Close Box)   */
#define SMALLER	0x4000

#if 0
/* Added Jul 23 91 for new window manager - ml. */
#define MNBAR	0x2000
#endif

#define	TPARTS	(NAME|CLOSER|FULLER|MOVER|SMALLER)
#define	VPARTS	(UPARROW|DNARROW|VSLIDE)
#define	HPARTS	(LFARROW|RTARROW|HSLIDE)

/* Indices into object tree of window */

#define	W_BOX	    0		/* background of window */
#define	W_TITLE	    1		/* parent of closer, name and fuller */
#define	W_CLOSER    2		/* closer */
#define	W_NAME	    3		/* name and mover bar */
#define	W_FULLER    4		/* fuller */
#define	W_INFO	    5		/* info line */
#define	W_DATA	    6		/* holds remaining window elements */
#define	W_WORK	    7		/* application work area */
#define	W_SIZER	    8		/* sizer */
#define	W_VBAR	    9		/* holds vertical slider elements */
#define	W_UPARROW   10		/* vertical slider up arrow */
#define	W_DNARROW   11		/* vertical slider down arrow */
#define	W_VSLIDE    12		/* vertical slider background */
#define	W_VELEV	    13		/* vertical slider thumb/elevator */
#define	W_HBAR	    14		/* holds horizontal slider elements */
#define	W_LFARROW   15		/* horizontal slider left arrow */
#define	W_RTARROW   16		/* horizontal slider right arrow */
#define	W_HSLIDE    17		/* horizontal slider background */
#define	W_HELEV	    18		/* horizontal slider thumb/elevator */
#define W_SMALLER   19		/* iconifier */

#ifdef MNBAR
#define	W_MNBAR	    20		/* menu bar (added Jul 23 91 - ml.) */
#endif

/* Callers of totop() */

#define	WMOPEN	0		/* called from wm_open() */
#define	WMCLOSE	1		/* called from wm_close() */
#define	WMSET	2		/* called from wm_set() */


/* Ob_spec values */

#define	GBOX_OBS    0x00010000	/* ob_spec value for GBOX objects */


#define WC_BORDER   0
#define WC_WORK	    1

/*	Wind Set Field definiton	*/

#define WF_KIND		1
#define WF_NAME		2
#define WF_INFO		3
#define WF_WORKXYWH	4
#define WF_WXYWH	WF_WORKXYWH
#define WF_CURRXYWH	5
#define WF_PREVXYWH	6
#define WF_FULLXYWH	7
#define WF_HSLIDE	8
#define WF_VSLIDE	9
#define WF_TOP      	10
#define WF_FIRSTXYWH 	11
#define WF_NEXTXYWH 	12
#define WF_RESVD   	13
#define WF_NEWDESK 	14
#define WF_HSLSIZE   	15
#define WF_VSLSIZE   	16
#define WF_SCREEN   	17

/* window color settings added 900227 - kbad */
#define WF_COLOR	18	/* set window element by handle */
#define WF_DCOLOR	19	/* set default element */

/* added Jul 23 91 for new window manager - ml. */
#define WF_OWNER	20
#define WF_REDRAW	21

/*added on 3/30/92	D.Mui		*/
#define WF_FHANDLE	22	/* first window handle	*/
#define WF_NHANDLE	23	/* next window handle	*/

#define WF_BEVENT	24	/* button event		*/
#define WF_BOTTOM	25	/* set window to bottom	*/

/* iconify feature added 930429 - hmk */
#define WF_ICONIFY	26
#define WF_UNICONIFY	27
#define WF_UNICONIFYXYWH	28
#define WF_ICONSLOT	29
#define WF_TOOLBAR	30
#define WF_FTOOLBAR	31
#define	WF_NTOOLBAR	32


#ifdef MNBAR
#define	WF_MENUBAR	99
#endif
				/* arrow message	*/
#define WA_UPPAGE 	0
#define WA_DNPAGE 	1
#define WA_UPLINE 	2
#define WA_DNLINE 	3
#define WA_LFPAGE 	4
#define WA_RTPAGE 	5
#define WA_LFLINE 	6
#define WA_RTLINE 	7

#endif

