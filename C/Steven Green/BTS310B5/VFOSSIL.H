#ifndef H_VFOSSIL
#define H_VFOSSIL
/*--------------------------------------------------------------------------*/
/*                                                                          */
/*                                                                          */
/*      ------------         Bit-Bucket Software, Co.                       */
/*      \ 10001101 /         Writers and Distributors of                    */
/*       \ 011110 /          Freely Available<tm> Software.                 */
/*        \ 1011 /                                                          */
/*         ------                                                           */
/*                                                                          */
/*  (C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*                                                                          */
/*                                                                          */
/*             Video FOSSIL definitions used in BinkleyTerm                 */
/*                                                                          */
/*                                                                          */
/*    For complete  details  of the licensing restrictions, please refer    */
/*    to the License  agreement,  which  is published in its entirety in    */
/*    the MAKEFILE and BT.C, and also contained in the file LICENSE.240.    */
/*                                                                          */
/*    USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE    */
/*    BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF    */
/*    THIS  AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,  OR IF YOU DO    */
/*    NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET    */
/*    SOFTWARE CO.  AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT    */
/*    SHOULD YOU  PROCEED TO USE THIS FILE  WITHOUT HAVING  ACCEPTED THE    */
/*    TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER    */
/*    AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.      */
/*                                                                          */
/*                                                                          */
/* You can contact Bit Bucket Software Co. at any one of the following      */
/* addresses:                                                               */
/*                                                                          */
/* Bit Bucket Software Co.        FidoNet  1:104/501, 1:132/491, 1:141/491  */
/* P.O. Box 460398                AlterNet 7:491/0                          */
/* Aurora, CO 80046               BBS-Net  86:2030/1                        */
/*                                Internet f491.n132.z1.fidonet.org         */
/*                                                                          */
/* Please feel free to contact us at any time to share your comments about  */
/* our software and/or licensing policies.                                  */
/*                                                                          */
/*--------------------------------------------------------------------------*/

#ifndef H_SBUF
#include "sbuf.h"
#endif


#ifndef ATARIST

typedef struct {
   int vfossil_size;
   int vfossil_major;
   int vfossil_revision;
   int vfossil_highest;
} VFOSSIL, *VFOSSILP;

#endif

#ifndef OS_2

typedef struct {
   int   cur_start;
   int   cur_end;
   int   cur_wid;
   int   cur_attr;
} CURSOR, *CURSORP;

typedef CURSOR far *PVIOCURSORINFO;

typedef struct _VIOCONFIGINFO { /* vioin */
	unsigned int  cb     ;
	unsigned int  adapter;
	unsigned int  display;
	unsigned long	cbMemory;
} VIOCONFIGINFO;

typedef VIOCONFIGINFO far *PVIOCONFIGINFO;

typedef struct _VIOMODEINFO {   /* viomi */
	unsigned int cb;
	unsigned char  fbType;
	unsigned char  color;
	unsigned int col;
	unsigned int row;
	unsigned int hres;
	unsigned int vres;
	unsigned char  fmt_ID;
	unsigned char  attrib;
} VIOMODEINFO;

typedef VIOMODEINFO far *PVIOMODEINFO;

#ifdef ATARIST

#include <linea.h>

#ifdef __TOS__

#undef DEFAULT

#define linea_ext Vdiesc
#define linea_data Linea

#define fossil_wherex()  (Vdiesc->v_cur_xy[0])
#define fossil_wherey()  (Vdiesc->v_cur_xy[1])

#endif

#ifdef LATTICE

extern LA_EXT *linea_ext;
extern LA_DATA *linea_data;

#define fossil_wherex()  (linea_ext->ld_cur_xy[0])
#define fossil_wherey()  (linea_ext->ld_cur_xy[1])

#endif

extern BOOLEAN nolinea;
#ifdef BIOSDISPLAY
extern BOOLEAN BIOSdisplay;
#endif
extern BOOLEAN UseColors;

void vfossil_init(void);	/* Intialise Video stuff */
void vfossil_close(void);	/* Stop using the vfossil */
void vfossil_cursor(int);	/* Show or hide the cursor */
#define fossil_gotoxy(x,y) cprintf("\033Y%c%c",(char)y+' ',(char)x+' ')

#ifndef ATARIST
#define fossil_ver()	(old_fossil = 0)
#endif

#define wherex() fossil_wherex()
#define wherey() fossil_wherey()
#define gotoxy(x,y) fossil_gotoxy(x,y)

void blank_screen(void);	/* My own screen blanker */
void unblank_screen(void);

void clear_screen(void);
void clear_eol(void);

/* Only WrtCellStr is actually used */

void VioWrtCellStr(BYTEBUFP s, size_t len, int row, int col, int vhandle);


#else


struct vfossil_hooks {	/* VFossil calls structure */
	unsigned int (pascal far *GetMode)(PVIOMODEINFO, unsigned int);
	unsigned int (pascal far *SetMode)(PVIOMODEINFO, unsigned int);
	unsigned int (pascal far *GetConfig)(unsigned int, PVIOCONFIGINFO, unsigned int);
	unsigned int (pascal far *WrtTTY)(char far *, unsigned int, unsigned int);
	unsigned int (pascal far *GetAnsi)(unsigned int far *, unsigned int);
	unsigned int (pascal far *SetAnsi)(unsigned int, unsigned int);
	unsigned int (pascal far *GetCurPos)(unsigned int far *, unsigned int far *, unsigned int);
	unsigned int (pascal far *SetCurPos)(unsigned int, unsigned int, unsigned int);
	unsigned int (pascal far *GetCurType)(PVIOCURSORINFO, unsigned int);
	unsigned int (pascal far *SetCurType)(PVIOCURSORINFO, unsigned int);
	unsigned int (pascal far *ScrollUp)(unsigned int, unsigned int, unsigned int, unsigned int, unsigned int, unsigned char far *,	unsigned int);
	unsigned int (pascal far *ScrollDn)(unsigned int, unsigned int, unsigned int, unsigned int, unsigned int, unsigned char far *,	unsigned int);
	unsigned int (pascal far *ReadCellStr)(char far *, unsigned int far *, unsigned int, unsigned int, unsigned int);
	unsigned int (pascal far *ReadCharStr)(char far *, unsigned int far *, unsigned int, unsigned int, unsigned int);
	unsigned int (pascal far *WrtCellStr)(unsigned int far *, unsigned int, unsigned int, unsigned int, unsigned int);
	unsigned int (pascal far *WrtCharStr)(char far *, unsigned int, unsigned int, unsigned int, unsigned int);
	unsigned int (pascal far *WrtCharStrAtt)(char far *, unsigned int, unsigned int, unsigned int, unsigned char far *, unsigned int);
	unsigned int (pascal far *WrtNAttr)(unsigned char far *, unsigned int, unsigned int, unsigned int, unsigned int);
	unsigned int (pascal far *WrtNCell)(unsigned int far *, unsigned int, unsigned int, unsigned int, unsigned int);
	unsigned int (pascal far *WrtNChar)(char far *, unsigned int, unsigned int, unsigned int, unsigned int);
};

/* Now for readability (and portability) ... */
#define VioGetMode(a,b)			((*vfossil_funcs.GetMode)(a,b))
#define VioSetMode(a,b)			((*vfossil_funcs.SetMode)(a,b))
#define VioGetConfig(a,b,c)		(*vfossil_funcs.GetConfig)(a,b,c))
#define VioWrtTTY(a,b,c)		((*vfossil_funcs.WrtTTY)(a,b,c))
#define VioGetANSI(a,b)			((*vfossil_funcs.GetANSI)(a,b))
#define VioSetANSI(a,b)			((*vfossil_funcs.SetANSI)(a,b))
#define VioGetCurPos(a,b,c)		((*vfossil_funcs.GetCurPos)(a,b,c))
#define VioSetCurPos(a,b,c)		((*vfossil_funcs.SetCurPos)(a,b,c))
#define VioGetCurType(a,b)		((*vfossil_funcs.GetCurType)(a,b))
#define VioSetCurType(a,b)		((*vfossil_funcs.SetCurType)(a,b))
#define VioScrollUp(a,b,c,d,e,f,g)	((*vfossil_funcs.ScrollUp)(a,b,c,d,e,f,g))
#define VioScrollDn(a,b,c,d,e,f,g)	((*vfossil_funcs.ScrollDn)(a,b,c,d,e,f,g))
#define VioReadCellStr(a,b,c,d,e)	((*vfossil_funcs.ReadCellStr)(a,b,c,d,e))
#define VioReadCharStr(a,b,c,d,e)	((*vfossil_funcs.ReadCharStr)(a,b,c,d,e))
#define VioWrtCellStr(a,b,c,d,e)	((*vfossil_funcs.WrtCellStr)(a,b,c,d,e))
#define VioWrtCharStr(a,b,c,d,e)	((*vfossil_funcs.WrtCharStr)(a,b,c,d,e))
#define VioWrtCharStrAtt(a,b,c,d,e,f)	((*vfossil_funcs.WrtCharStrAtt)(a,b,c,d,e,f))
#define VioWrtNAttr(a,b,c,d,e)		((*vfossil_funcs.WrtNAttr)(a,b,c,d,e))
#define VioWrtNCell(a,b,c,d,e)		((*vfossil_funcs.WrtNCell)(a,b,c,d,e))
#define VioWrtNChar(a,b,c,d,e)		((*vfossil_funcs.WrtNChar)(a,b,c,d,e))

#endif /* ATARIST */

#else /* ifndef OS_2 */

#define INCL_SUB
#define INCL_VIO
#include <os2.h>
#define CURSOR VIOCURSORINFO
#define CURSORP PVIOCURSORINFO

#endif /* ifndef OS_2 */

#endif	/* H_VFOSSIL */
