/****************************************************************************

 Module
  misc.c
  
 Description
  Miscellaneous routines in oAESis.
  
 Author(s)
 	cg (Christer Gustavsson <d2cg@dtek.chalmers.se>)
 	
 Revision history
 
  951225 cg
   Added standard header.
   Added Misc_copy_area.
 
 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include <basepage.h>
#include <ctype.h>
#include <ioctl.h>
#include <mintbind.h>
#include <stdio.h>
#include <stdlib.h>

#include "gemdefs.h"
#include "global.h"
#include "lxgemdos.h"
#include "misc.h"
#include "types.h"
#include "vdi.h"

#include <sysvars.h>

/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

WORD Misc_get_cookie(LONG code,LONG *value) {
	register COOKIE *cookie;
	void            *stack;

	stack = (void*)Super(0L);
	cookie = *(COOKIE **)_p_cookies;
	Super(stack);
	
	while(cookie->cookie) {
		if(cookie->cookie == code) {
			*value = cookie->value;		

			return TRUE;
		};
		
		cookie++;
	};
	
	return FALSE;
}


static void CDECL startup(register BASEPAGE *b) {
  register WORD (*func)(LONG);
  register LONG arg;

  set_stack((void *)(((LONG)b) + 256 + STKSIZE));

  func = (WORD (*)(LONG))b->p_dbase;
  arg = b->p_dlen;
  
  Pterm((*func)(arg));
}


LONG newfork(WORD (*func)(LONG),LONG arg,BYTE *name) {
  register BASEPAGE *b;
  register LONG pid;

  b = (BASEPAGE *)Pexec(PE_CBASEPAGE, 0L, "", 0L);
  (void)Mshrink(b, STKSIZE + 256);
  b->p_tbase = (BYTE *)startup;
  b->p_dbase = (BYTE *)func;
  b->p_dlen = arg;
  b->p_hitpa = ((BYTE *)b) + STKSIZE + 256;
 
  pid = Pexec(106,name,b,0L);

  return pid;
}


WORD	max(WORD a,WORD b) {
	if(a > b) 
		return a;
	else
		return b;
}

WORD	min(WORD a,WORD b) {
	if(a < b) 
		return a;
	else
		return b;
}

/****************************************************************************
 *  Misc_copy_area                                                          *
 *   Copy one area of the screen to another.                                *
 ****************************************************************************/
void              /*                                                        */
Misc_copy_area(   /*                                                        */
WORD vid,         /* VDI workstation id.                                    */
RECT *dst,        /* Where to the area is to be copied.                     */
RECT *src)        /* The original area.                                     */
/****************************************************************************/
{
	MFDB	mfdbd,mfdbs;
	WORD	koordl[8];
	
	mfdbd.fd_addr = 0L;
	mfdbs.fd_addr = 0L;
	
	koordl[0] = src->x;
	koordl[1] = src->y + src->height - 1;
	koordl[2] = src->x + src->width - 1;
	koordl[3] = src->y;
	koordl[4] = dst->x;
	koordl[5] = dst->y + dst->height - 1;
	koordl[6] = dst->x + dst->width - 1;
	koordl[7] = dst->y;
	
	Vdi_vro_cpyfm(vid,S_ONLY,koordl,&mfdbs,&mfdbd);
}


/****************************************************************************
 *  Misc_intersect                                                          *
 *   Get intersection of two rectangles.                                    *
 ****************************************************************************/
WORD              /* 0  Rectangles don't intersect.                         */
                  /* 1  Rectangles intersect but not completely.            */
                  /* 2  r2 is completely covered by r1.                     */
Misc_intersect(   /*                                                        */
RECT *r1,         /* Rectangle r1.                                          */
RECT *r2,         /* Rectangle r2.                                          */
RECT *rinter)     /* Buffer where the intersecting part is returned.        */
/****************************************************************************/
{
	rinter->x = max(r1->x,r2->x);
	rinter->width = min(r1->x + r1->width, r2->x + r2->width) - rinter->x;
	rinter->y = max(r1->y,r2->y);
	rinter->height = min(r1->y + r1->height, r2->y + r2->height) - rinter->y;
	
	if((r2->x == rinter->x) && (r2->y == rinter->y)
		&& (r2->width == rinter->width) && (r2->height == rinter->height))
	{
		return 2;
	}
	else if((rinter->width > 0) && (rinter->height > 0))
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

/****************************************************************************
 * Misc_inside                                                              *
 *  Check if coordinates is within rectangle.                               *
 ****************************************************************************/
WORD              /* 0  Outside of rectangle.                               */
                  /* 1  Inside rectangle.                                   */
Misc_inside(      /*                                                        */
RECT *r,          /* Rectangle.                                             */
WORD x,           /* X coordinate.                                          */
WORD y)           /* Y coordinate.                                          */
/****************************************************************************/
{
	return (((x -= r->x) >= 0) && 
	        (x < r->width) && 
	        ((y -= r->y) >= 0) && 
	        (y < r->height));
}

/****************************************************************************
 * Misc_setpath                                                             *
 *  Set current working directory. This one is stolen from the Mint-libs    *
 *  and modified because of the idiotic functionality of Dsetpath().        *
 ****************************************************************************/
WORD              /* 0 ok, or -1.                                           */
Misc_setpath(     /*                                                        */
BYTE *dir)        /* New directory.                                         */
/****************************************************************************/
{
	WORD drv, old;
	BYTE *d;

	d = dir;
	old = Dgetdrv();
	if(*d && (*(d+1) == ':')) {
		drv = toupper(*d) - 'A';
		d += 2;
		(void)Dsetdrv(drv);
	};

	if(!*d) {		/* empty path means root directory */
		*d = '\\';
		*(d + 1) = '\0';
	};
	
	if(Dsetpath(d) < 0) {
		(void)Dsetdrv(old);
		return -1;
	};
	
	return 0;
}


/****************************************************************************
 * Misc_get_loadinfo                                                        *
 *  Get loading information.                                                *
 ****************************************************************************/
void                /*                                                      */
Misc_get_loadinfo(  /*                                                      */
WORD fnamelen,      /* Length of filename buffer.                           */
BYTE *cmdlin,       /* Command line buffer.                                 */
BYTE *fname)        /* File name buffer.                                    */
/****************************************************************************/
{
	BYTE pname[30];
	_DTA *olddta,newdta;
	
	olddta = Fgetdta();
	Fsetdta(&newdta);
	
	sprintf(pname,"u:\\proc\\*.%03d",Pgetpid());
	if(Fsfirst(pname,0) == 0) {
		LONG fd;
		
		sprintf(pname,"u:\\proc\\%s",newdta.dta_name);
		
		if((fd = Fopen(pname,0)) >= 0) {
			struct __ploadinfo li;
			
			li.fnamelen = fnamelen;
			li.cmdlin = cmdlin;
			li.fname = fname;
			
			Fcntl((WORD)fd,&li,PLOADINFO);
			Fclose((WORD)fd);
		};
	};
	
	Fsetdta(olddta);
}
