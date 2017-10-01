#ifndef DESKFPD

#define DESKFPD

/*	DESKFPD.H	06/11/84 - 03/25/85	Lee Lorenzen	*/
/*	for 3.0		11/4/87			mdf		*/
/*
*       Copyright 1999, Caldera Thin Clients, Inc.                      
*       This software is licenced under the GNU Public License.         
*       Please see LICENSE.TXT for further information.                 
*                                                                       
*                  Historical Copyright                                 
*	-------------------------------------------------------------
*	GEM Desktop					  Version 3.0
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1987			Digital Research Inc.
*	-------------------------------------------------------------
*/


#define OP_COUNT 0
#define OP_DELETE 1
#define OP_COPY 2

#define D_PERM 0x0001

#define V_ICON 0
#define V_TEXT 1

#define S_NAME 0
#define S_DATE 1
#define S_SIZE 2
#define S_TYPE 3
#define S_DISK 4

#define E_NOERROR 0
#define E_NOFNODES 100
#define E_NOPNODES 101
#define E_NODNODES 102

#define NUM_FNODES 400
#define NUM_PNODES 3	/* one more than windows for unopen disk copy */

typedef struct filenode {
	struct filenode	*f_next;
	BYTE			f_junk;		/* to align on even boundaries	*/
	BYTE			f_attr;
	UWORD			f_time;
	UWORD			f_date;
	LONG			f_size;
	BYTE			f_name[LEN_ZFNAME];
	WORD			f_obid;
	ANODE			*f_pa;
	WORD			f_isap;
} FNODE;

typedef struct pathnode {
	struct pathnode	*p_next;
	WORD			p_flags;
	WORD			p_attr;
	BYTE			p_spec[LEN_ZPATH];
	FNODE			*p_flist;
	WORD			p_count;
	LONG			p_size;
} PNODE;

EXTERN	VOID fn_init(VOID);
EXTERN	VOID pn_init(VOID);
EXTERN	VOID fpd_start(VOID);
EXTERN	WORD fpd_bldspec(WORD drive, BYTE *ppath, BYTE *pname, BYTE *pext, BYTE *pspec);
EXTERN	VOID fpd_parse(BYTE *pspec, WORD *pdrv, BYTE *ppath, BYTE *pname, BYTE *pext);
EXTERN	FNODE *fpd_ofind(FNODE *pf, WORD obj);
EXTERN	BYTE *fpd_elist(FNODE *pfpd, FNODE *pstop);
EXTERN	VOID fn_free(FNODE *thefile);
EXTERN	VOID fl_free(FNODE *pflist);
EXTERN	FNODE *fn_alloc(VOID);
EXTERN	PNODE *pn_alloc(VOID);
EXTERN	VOID pn_free(PNODE *thepath);
EXTERN	VOID pn_close(PNODE *thepath);
EXTERN	PNODE *pn_open(WORD drive, BYTE *path, BYTE *name, BYTE *ext, WORD attr);
EXTERN	WORD pn_fcomp(FNODE *pf1, FNODE *pf2, WORD which);
EXTERN	WORD pn_comp(FNODE *pf1, FNODE *pf2);
EXTERN	FNODE *pn_sort(WORD lstcnt, FNODE *pflist);
EXTERN	WORD pn_folder(PNODE *thepath);
EXTERN	WORD pn_desktop(PNODE *thepath);
EXTERN	WORD pn_active(PNODE *thepath);

#endif
