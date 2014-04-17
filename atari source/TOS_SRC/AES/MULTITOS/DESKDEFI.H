/*	DESKDEFI.H			9/22/92		Derek Mui	*/
/*	Change the IDTYPE		7/11/92		D.Mui		*/

/*	Increased MAXMENU to 31		07/07/92  	cjg		*/

#ifndef _DESKDEFI_H_
#define _DESKDEFI_H_

#include "obdefs.h"

#define DOWARNING	0	/* Do we need initial warning box ? 	     */
				/* There is also a flag in Gemjstrt.s:       */
				/* 'dodowarn', which must be set along       */
				/* with the value of DOWARNING               */
				/* !!! ONLY USED BY GEMINIT.C !!!	     */

				/* System switches set version creating to 1.*/
				/* Set all other countries to 0		     */
				/* ! COUNTRY CHANGES ONLY AFFECT DESKINF.C ! */


#define LINKED		1
#define UNLINKED	0

#define ALTER	 	0x0008
#define K_LSHIFT 	0x0002
#define K_RSHIFT 	0x0001

#define CMD_FORMAT  	0
#define CMD_COPY    	1

/* Set Write Allocate mode, clear both caches,
 * and enable them with burst fill.
*/
#define CACHE_ON	0x00003919L
				
#define CACHE_OFF	0x00000808L	/* Clear and disable both caches. */

#define XCA_ON		0x00003111L	/* read back the cache on	*/
#define XCA_OFF		0x00000000L	/* read back cache off		*/

#define READ		0x0001
#define HIDDEN		0x0002
#define SYSTEM		0x0004
#define VOLUME		0x0008
#define SUBDIR		0x0010
#define MODIFIED	0x0020


/*****	APPLICATION FILE TYPE DEFINES	   ******/
/*	-1 means match the type			*/

#define	FOLDER	0		/* file type define	*/
#define PRG	1		/* or icon type		*/
#define TEXT	2
#define	TTP	3
#define TOS	4
#define DISK	5
#define TRASHCAN 6
#define APPS	7
#define XFILE	8
/* #define CARTRIDGE 9	*/
#define PTP	10
#define PRINTER	11
#define XDIR	12
#define ICONS	13
#define ACCESSORY	14

#define S_ICON	0		/* view as icon	*/
#define S_TEXT	1		/* view as text	*/

#define S_NAME	0		/* sort as name	*/
#define S_DATE	1
#define S_SIZE	2
#define S_TYPE	3
#define S_NO	4		/* no sort	*/

#define MAX_LEVEL	8	/* max level of folder	*/

#define MAXMENU		31	/* max number of menus	*/

#define DESKICON	0
#define WINICON		1

#define APP_NODE 48	/* number of user definable file type 	*/
#define APP_DESK 48	/* number of desktop icon should equal to number of */
			/* icons in background dialogue		*/
	
#define OP_DELETE	0	/* file operation definitions	*/
#define OP_COPY		1
#define OP_MOVE		2
#define OP_COUNT	3

#define COPYMAXDEPTH 12

#define L_NOEXIT	0	/* desk loop exit code		*/
#define	L_LAUNCH	1
#define L_CHGRES	2
#define L_READINF	3
#define L_EXIT		4
#define L_WAKEUP	5

#define K_CTRL 	0x0004

#define	INFSIZE	4192		/* inf file size	*/

#define F1	0x3b00
#define F2	0x3c00
#define F3	0x3d00
#define F4	0x3e00
#define F5	0x3f00
#define F6	0x4000
#define F7	0x4100
#define F8	0x4200
#define F9	0x4300
#define F10	0x4400	
#define F11	0x5400
#define F12	0x5500
#define F13	0x5600
#define F14	0x5700
#define F15	0x5800
#define F16	0x5900
#define F17	0x5A00
#define F18	0x5B00
#define F19	0x5C00
#define F20	0x5D00	

#define ARGULEN	12

typedef	struct	app
{
	WORD	a_type;		/* file type	*/
	WORD	a_icon;		/* icon number	*/
	WORD	a_dicon;	/* document icon*/
	BYTE	*a_name;	/* app name	*/
	BYTE	a_doc[14];	/* doc name	*/
	WORD	a_pref;		/* launch pref	set dir etc */	
	UWORD	a_key;		/* key definition	*/
	LONG	a_limit;	/* max. memory to allow */
	BYTE	a_argu[ARGULEN];
	BYTE	*a_next;	/* app pointer	*/
} APP;

typedef struct idtype
{
	WORD	i_type;
	WORD	i_icon;
	CICONBLK i_cicon;	
/*	ICONBLK	i_iblk;	*/
	BYTE	*i_path;
	BYTE	i_name[14];
} IDTYPE;


typedef struct fntlst {
	WORD	fnt_id;
	WORD	fnt_type;
	BYTE	fnt_name[36];
} FNTLST;


#endif

