/****************************************************************************

 Module
  mousedev.c
  
 Description
  Mouse device used in oAESis.
  
 Author(s)
 	cg (Christer Gustavsson <d2cg@dtek.chalmers.se>)
 	kkp (Klaus Pedersen) <kkp@gamma.dou.dk>
 	
 Revision history
 
  960105 cg
   Added standard header.
   First version of mouse device implemented.
  
  960129 cg
   Renamed to mousedev.c from evnthndl.c.
   
  960228 kkp
   fixed a bug in the 'was the last package a move?'-code
   fixed word R/W on uneven addresses
   made some optimations eg (byte copy loop -> EVNTREC copy)
   
  960422 cg
   Fixed bug in the skip-mouse-package code => No more slow menus 
   (hopefully).
   
 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include <basepage.h>
#include <errno.h>
#include <fcntl.h>
#include <ioctl.h>
#include <mintbind.h>
#include <signal.h>
#include <stdio.h>
#include <unistd.h>

#include "appl.h"
#include "gemdefs.h"
#include "global.h"
#include "mintdefs.h"
#include "mousedev.h"
#include "lxgemdos.h"
#include "misc.h"
#include "types.h"
#include "vdi.h"

#include <sysvars.h>

/****************************************************************************
 * Macros                                                                   *
 ****************************************************************************/

#define MOUSESIZE 128

/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

void   *oldmvec = (void *)0L,*oldbvec = (void *)0L,*oldtvec = (void *)0L;
static WORD mousehead, mousetail;

LONG newxy = 0L;
LONG oldxy = 0L;
LONG newbut = 0L;
LONG oldbut = 0L;
LONG mousersel = 0L;	/* is someone calling select() on the mouse? */

static _KBDVECS *syskey;
static EVNTREC mousebuf[MOUSESIZE];
static struct kerinfo *kerinf;

static DEVDRV mouse_device;

static WORD mouse_button,mouse_x,mouse_y,minuse;

static WORD ticktime;

/****************************************************************************
 * Local functions (use static!)                                            *
 ****************************************************************************/


static LONG CDECL mouse_open(FILEPTR *f) {	
	NOT_USED(f);

	if(minuse) {
		return -EACCESS;
	};

	mousehead = mousetail = 0;
	minuse = 1;
	return 0;
}

static LONG CDECL mouse_write(FILEPTR *f, const BYTE *buf, LONG nbytes) {
	NOT_USED(f); NOT_USED(buf); NOT_USED(nbytes);
	
	return -EROFS;
}

static LONG CDECL mouse_read(FILEPTR *f, BYTE *buf, LONG nbytes) {
	LONG    count = 0;
	WORD    mhead;
	EVNTREC *foo;

	mhead = mousehead;
	foo = &mousebuf[mhead];

	if(mhead == mousetail) {
		if(f->flags & O_NDELAY) {
			return 0;
		};
		
		do {
			kerinf->sleep(READY_Q,0L);
		}while(mhead == mousetail);
	}

	while((mhead != mousetail) && (nbytes >= sizeof(EVNTREC))) {
		*(((EVNTREC *)buf)++) = *(foo++);
		mhead++;
		
		if(mhead >= MOUSESIZE) {
			mhead = 0;
			foo = mousebuf;
		};
		
		count += sizeof(EVNTREC);
		nbytes -= sizeof(EVNTREC);
	};
	
	mousehead = mhead;

	return count;
}

static LONG CDECL mouse_lseek(FILEPTR *f,LONG where,WORD whence) {
	NOT_USED(f); NOT_USED(where); NOT_USED(whence);
	
	return -EUKCMD;
}

static LONG CDECL mouse_ioctl(FILEPTR *f, WORD mode, void *buf) {
	LONG r;
	
	NOT_USED(f);
	
	if (mode == FIONREAD) {
		r = mousetail - mousehead;
		if (r < 0) r += MOUSESIZE;
		*((LONG *)buf) = r * sizeof(EVNTREC);
	} else if (mode == FIONWRITE)
		*((LONG *)buf) = 0;
/*	else if (mode == FIOEXCEPT)
		*((LONG *)buf) = 0;
*/	else
		return -EINVAL;
	return 0;
}

static LONG CDECL mouse_datime(FILEPTR *f,WORD *timeptr,WORD rwflag) {
	NOT_USED(f); NOT_USED(timeptr); NOT_USED(rwflag);
	return -EUKCMD;
}

static LONG CDECL mouse_close(FILEPTR *f, WORD pid) {
	NOT_USED(pid);

	if (!f) return -EBADF;
	if (f->links <= 0) {
		if (!minuse) {
			return -1;
		}

		minuse = 0;
	}
	return 0;
}

static LONG CDECL mouse_select(FILEPTR *f,LONG p,WORD mode) {
	NOT_USED(f);

	if(mode != O_RDONLY) {
		if (mode == O_WRONLY)
			return 1;
		else
			return 0;
	}

	if(mousetail - mousehead) {
		return 1;
	};

	if(mousersel) {
		return 2;
	};
	
	mousersel = p;
	
	return 0;
}

static void CDECL mouse_unselect(FILEPTR *f, LONG p, WORD mode) {
	NOT_USED(f);

	if ((mode == O_RDONLY) && (mousersel == p)) {
		mousersel = 0L;
	};
}


/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

void Moudev_handler(EVNTREC *er) {
	if(er->ap_event == APPEVNT_TIMER) {
		WORD  chgcoor = (newxy != oldxy);
		WORD  chgbut = (newbut != oldbut);
		EVNTREC *mbuf;
		WORD  newmtail;
		
		globals.time += ticktime;

		if(chgbut || chgcoor) {
			if(chgcoor) {			
				/* if the last package was a move, then simply overwrite it */
				if((mousetail != mousehead) && 
  		   (mousebuf[(mousetail + MOUSESIZE - 1) % MOUSESIZE].ap_event
	  		   		== APPEVNT_MOUSE))
	  		{	
					mousebuf[(mousetail + MOUSESIZE -1) % MOUSESIZE].ap_value
							= newxy;
				}
				else {
					mbuf = &mousebuf[mousetail];
					newmtail = mousetail + 1;
			
					if(newmtail >= MOUSESIZE) {
						newmtail = 0;
					};
			
					if(newmtail != mousehead) {
						mbuf->ap_event = APPEVNT_MOUSE;
						mbuf->ap_value = newxy;
			
						mousetail = newmtail;
					};
				};
				
				oldxy = newxy;
			};
			
			if(chgbut) {			
				mbuf = &mousebuf[mousetail];
				newmtail = mousetail + 1;
			
				if(newmtail >= MOUSESIZE) {
					newmtail = 0;
				};
			
				if(newmtail != mousehead) {
					mbuf->ap_event = APPEVNT_BUTTON;
					mbuf->ap_value = newbut;
			
					mousetail = newmtail;
				};
				
				oldbut = newbut;
			};
			
			if(mousersel) {
				kerinf->wakeselect(mousersel);
			}
		};
	}
	else if(er->ap_event == APPEVNT_MOUSE) {
		newxy = er->ap_value;
	}
	else {
		newbut = er->ap_value;
	};
}

/****************************************************************************
 * Moudev_init_module                                                       *
 *  Initialize mouse device.                                                *
 ****************************************************************************/
void                     /*                                                 */
Moudev_init_module(void) /*                                                 */
/****************************************************************************/
{
	struct dev_descr dd = {
		&mouse_device,
	  0,
		0,
		0L,
		sizeof(DEVDRV),
		{0L,0L,0L}
	};
	
	syskey = Kbdvbase();
	
	mouse_device.open = mouse_open;
	mouse_device.write = mouse_write;
	mouse_device.read = mouse_read;
	mouse_device.lseek = mouse_lseek;
	mouse_device.ioctl = mouse_ioctl;
	mouse_device.datime =	mouse_datime;
	mouse_device.close = mouse_close;
	mouse_device.select = mouse_select;
	mouse_device.unselect = mouse_unselect;
	
	Vdi_vq_mouse(globals.vid,&mouse_button,&mouse_x,&mouse_y);

	(LONG)kerinf = (LONG)Dcntl(DEV_INSTALL,globals.mousename,(LONG)&dd);


	Vdi_vex_butv(globals.vid,newbvec,&oldbvec);
	Vdi_vex_motv(globals.vid,newmvec,&oldmvec);
	Vdi_vex_timv(globals.vid,newtvec ,&oldtvec,&ticktime);
}

/****************************************************************************
 * Moudev_exit_module                                                       *
 *  Shutdown mouse device.                                                  *
 ****************************************************************************/
void                     /*                                                 */
Moudev_exit_module(void) /*                                                 */
/****************************************************************************/
{
	Vdi_vex_butv(globals.vid,oldbvec,&oldbvec);
	Vdi_vex_motv(globals.vid,oldmvec,&oldmvec);
	Vdi_vex_timv(globals.vid,oldtvec,&oldtvec,&ticktime);

	Fdelete(globals.mousename);
}
