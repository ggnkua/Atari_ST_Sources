/*
 *
 *	News AES definitions for version 3.3, 4.0 and 4.1
 *		
 *
 *		FunShip, (c) FRANCE 1994-98 - ATARI Falcon030
 *
 *		Version 1.00 from 5 November.
 *		Turbo-C and Pure-C language
 *
 */

/*	Inclure ce fichier, si MT_AES.H de Magic ne l'est pas (Il d‚fini l'AES 4.1) */ 
#ifndef	__MTAES__
#define __MTAES__

#ifndef	__AES__
#include <AES.h>
#endif

/*
 *	Suivant le compilateur utilis‚, il se peut qu'il ne connaisse pas encore certainnes nouveaut‚s.
 *	Ici, on d‚finit AES 4.0 pour indiquer que le compilo. connait la gestion des menus popups et les nouvelles
 *	fonctions AES.
 */
 
#define		__AES40__	__AES40__

/*
 *	New window's attributes
 */

#define B1			0x1000		/* No used */
#define B2			0x2000		/* No used */
#define ICONIFIER	0x4000
#define	SMALLER		ICONIFIER		/* AES 4.1 */
#define B8			0x8000		/* No used */

/*
 *	New window's messages 
 */
 
#define	WM_UNTOPPED		30		/* AES 4.0 */
#define WM_ONTOP		31		/* AES 4.0 */
#define	WM_BOTTOMED		33		/* AES 4.1 */
#define	WM_ICONIFY		34		/* AES 4.1 */
#define	WM_UNICONIFY		35		/* AES 4.1 */
#define	WM_ALLICONIFY		36		/* AES 4.1 */
#define	WM_TOOLBAR		37		/* AES 4.2 */

/*
 * 	New's command for wind_set and wind_get
 */

#define WF_NEWDESK		14		/* AES 3.3 */
#define WF_SCREEN		17		/* TOS 1.4 */
#define WF_COLOR		18		/* AES 3.3 */
#define WF_DCOLOR		19		/* AES 3.3 */
#define WF_OWNER		20		/* AES 3.3 */
#define WF_BEVENT		24		/* AES 3.3 */
#define WF_BOTTOM		25		/* AES 4.1 */
#define WF_ICONIFY		26		/* AES 4.1 */
#define WF_UNICONIFY		27		/* AES 4.1 */
#define WF_UNICONIFYXYWH	28		/* AES 4.1 */
#define WF_TOOLBAR		30		/* AES 4.1 */
#define WF_FTOOLBAR		31		/* AES 4.1 */
#define WF_NTOOLBAR		32		/* AES 4.1 */

/*
 *	New application messages
 */
 
#define	AP_OPEN			40
#define	AP_CLOSE		41
#define	AP_TERM			50		/* AES 4.0 */
#define	AP_TFAIL		51		/* AES 4.0 */
#define	AP_RESCHG		57		/* AES 4.0 */
#define	SHUT_COMPLETED		60		/* AES 4.0 */
#define	RESCHG_COMPLETED	61		/* AES 4.0 */
#define	AP_DRAGDROP		63		/* AES 4.1 */
#define	CH_EXIT			90		/* AES 4.0 */
#define SH_WDRAW		72			
/*
 *	Xcontrol messages
 */
 
#define	CT_UPDATE		50
#define	CT_MOVE			51
#define	CT_NEWTOP		52
#define	CT_KEY			53

/*
 *	New's Aes structures for Pop-up menu: From AES 4.0
 */

#ifndef	__AES40__ 
typedef struct
{
	OBJECT	*mn_tree;		/* Object's tree address */
	int	mn_menu;		/* Root object's tree options */
	int	mn_item;		/* Selected entry object */
	int	mn_scroll;		/* Flag to allows pop-up scroll */
	int	mn_kstate;		/* Special key state */ 
} MENU;

typedef struct
{
	long	Display;		/* delay before pop-up display */
	long	Drag;			/* drap delay of pop-up */
	long	Delay;			/* delay before scroll */
	long	Speed;			/* delay between both scroll */
	int	Height;			/* size of scroll pop-up */
} MN_SET;

/*
 *	Pop-up menu's functions: From AES 4.0
 */
 
int	menu_popup(MENU *me_menu,int me_xpos,int me_ypos,MENU *me_mdata);
int	menu_attach(int me_flag,OBJECT *me_tree,int me_item,MENU *me_mdata);
int	menu_istart(int me_flag,OBJECT *me_tree,int me_imenu,int me_item);
int	menu_settings(int me_flag,MN_SET *me_values);

/*
 *	Application's functions: From AES 4.0
 */

int	appl_getinfo(int gtype,int *gout1,int *gout2,int *gout3,int *gout4);
int	appl_search(int mode,char *ap_sname,int *op_stype,int *op_sid);

/*
 *	Ressource's functions: From AES 4.0
 */

int	rsrc_rcfix(OBJECT *rc_header);

#endif

/*
 *	Object's functions: From AES 3.3
 */

int	objc_sysvar(int mode,int which,int in1,int in2,int *out1,int *out2);

#endif
