/****************************************************************************

 Module
  rdwrs.c
  
 Description
  Mutual exclusion routines in oAESis.
  
 Author(s)
 	cg (Christer Gustavsson <d2cg@dtek.chalmers.se>)
 	
 Revision history
 
  960110 cg
   Standard header added.

  960114 cg
   Fundamental version of readers/writers device ready.

  960424 cg
   Fixed bug in Rdwrs_rel_sem. The semaphore was released before data
   was written to the count structure which caused freezing bugs.
   
 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include <errno.h>
#include <ioctl.h>
#include <mintbind.h>
#include <signal.h>
#include <stdio.h>

#include "debug.h"
#include "mintdefs.h"
#include "types.h"
#include "rdwrs.h"

/****************************************************************************
 * Macros                                                                   *
 ****************************************************************************/

#define	BUFSIZE	256

#define MOUSESIZ 128*5

#define OK_TO_READ   1
#define OK_TO_WRITE  2
#define OK_TO_BLOCK  3

/****************************************************************************
 * Typedefs of module global interest                                       *
 ****************************************************************************/

typedef struct {
	WORD readers;
	WORD waiting_to_read;
	WORD writing;
	WORD waiting_to_write;
	WORD writers_blocked;
	WORD waiting_to_block;
}RDWR_CTRL; 

/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

static WORD mousehead, mousetail;

static LONG mousersel = 0;	/* is someone calling select() on the mouse? */

static struct kerinfo *kerinf;

static RDWR_CTRL r[3];

static DEVDRV device;

static LONG semaphore_id = 0x6f414553L; /* oAES */

static BYTE mut_dev[30];

/****************************************************************************
 * Local functions (use static!)                                            *
 ****************************************************************************/


static LONG CDECL dev_open(FILEPTR *f) {	
	NOT_USED(f);
	
	return 0;
}

static LONG CDECL dev_write(FILEPTR *f, const BYTE *buf, LONG nbytes) {
	NOT_USED(f); NOT_USED(buf); NOT_USED(nbytes);
	
	return -EROFS;
}

static LONG CDECL dev_read(FILEPTR *f, BYTE *buf, LONG nbytes) {
	WORD which = (WORD)(nbytes >> 16);

	NOT_USED(f); NOT_USED(buf);

	switch((WORD)nbytes) {
	case STARTREAD:
		r[which].waiting_to_read++;

		while(r[which].writing || (r[which].waiting_to_write && (!r[which].writers_blocked))) {
			kerinf->sleep(READY_Q,0);
		};
		
		r[which].waiting_to_read--;
		r[which].readers++;
		break;

	case ENDREAD:
		r[which].readers--;
		break;
	
	case STARTWRITE:
		if((r[which].readers != 0) || r[which].writing || r[which].writers_blocked) {
			r[which].waiting_to_write++;

			do {
				kerinf->sleep(READY_Q,0);
			}while((r[which].readers != 0) || r[which].writing || r[which].writers_blocked);
			r[which].waiting_to_write--;
		};	
		r[which].writing++;
		break;
		
	case ENDWRITE:
		r[which].writing--;
		break;
	};
			
	return 0;
}

static LONG CDECL dev_lseek(FILEPTR *f,LONG where,WORD whence) {
	NOT_USED(f); NOT_USED(where); NOT_USED(whence);
	
	return -EUKCMD;
}

static LONG CDECL dev_ioctl(FILEPTR *f, WORD mode, void *buf) {
	LONG r;
	
	NOT_USED(f);
	
	if (mode == FIONREAD) {
		r = mousetail - mousehead;
		if (r < 0) r += MOUSESIZ;
		*((LONG *)buf) = r;
	} else if (mode == FIONWRITE)
		*((LONG *)buf) = 0;
/*	else if (mode == FIOEXCEPT)
		*((LONG *)buf) = 0;
*/	else
		return -EINVAL;
	return 0;
}

static LONG CDECL dev_datime(FILEPTR *f,WORD *timeptr,WORD rwflag) {
	NOT_USED(f); NOT_USED(timeptr); NOT_USED(rwflag);
	return -EUKCMD;
}

static LONG CDECL dev_close(FILEPTR *f, WORD pid) {
	NOT_USED(pid);

	if (!f) return -EBADF;

	return 0;
}

static LONG CDECL dev_select(FILEPTR *f, LONG p, WORD mode) {
	NOT_USED(f);

	if (mode != O_RDONLY) {
		if (mode == O_WRONLY)
			return 1;	/* we can always take output :-) */
		else
			return 0;	/* but don't care for anything else */
	}

	if (mousetail - mousehead)
		return 1;	/* input waiting already */

	if (mousersel)
		return 2;	/* collision */
	mousersel = p;
	return 0;
}

static void CDECL dev_unselect(FILEPTR *f, LONG p, WORD mode) {
	NOT_USED(f);

	if (mode == O_RDONLY && mousersel == p)
		mousersel = 0;
}

/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

/****************************************************************************
 * Rdwrs_init_module                                                        *
 *  Initialization of the mutual exclusion module in oAESis.                *
 ****************************************************************************/
void                    /*                                                  */
Rdwrs_init_module(void) /*                                                  */
/****************************************************************************/
{
	WORD i;
	
	struct dev_descr dd = {
		&device,
	  0,
		0,
		0L,
		sizeof(DEVDRV),
		{0L,0L,0L}
	};
	
	device.open = dev_open;
	device.write = dev_write;
	device.read = dev_read;
	device.lseek = dev_lseek;
	device.ioctl = dev_ioctl;
	device.datime =	dev_datime;
	device.close = dev_close;
	device.select = dev_select;
	device.unselect = dev_unselect;
	
	for(i = 0; i < 3; i++) {
		r[i].readers = 0;
		r[i].waiting_to_read = 0;
		r[i].writing = 0;
		r[i].waiting_to_write = 0;
		r[i].writers_blocked = 0;
		r[i].waiting_to_block = 0;
	};
	
	sprintf(mut_dev,"u:\\dev\\aesmut.%03d",Pgetpid());
	
	(LONG)kerinf = (LONG)Dcntl(DEV_INSTALL,mut_dev,(LONG)&dd);
}

/****************************************************************************
 * Rdwrs_exit_module                                                        *
 *  Shutdown of the mutual exclusion module in oAESis.                      *
 ****************************************************************************/
void                    /*                                                  */
Rdwrs_exit_module(void) /*                                                  */
/****************************************************************************/
{
	Fdelete(mut_dev);
}

/****************************************************************************
 * Rdwrs_quick                                                              *
 *  Quick try to grab/release monitor.                                      *
 ****************************************************************************/
WORD                    /* 0 if monitor successful, or 1.                   */
Rdwrs_quick(            /*                                                  */
LONG mode)              /* Monitor to grab/release.                         */
/****************************************************************************/
{
	WORD which = (WORD)(mode >> 16);

	switch((WORD)mode) {
	case STARTREAD:
		r[which].readers++;
		
		if(r[which].writing > 0) {
			r[which].readers--;
			return 1;
		}
		else {
			return 0;
		};

	case ENDREAD:
		r[which].readers--;
		return 0;
	
	case STARTWRITE:
		r[which].writing++;
		
		if((r[which].writing > 1) || (r[which].readers > 0)) {
			r[which].writing--;
			
			return 1;
		}
		else {
			return 0;
		};
		
	case ENDWRITE:
		r[which].writing--;
		return 0;
	
	default:
		return 1;
	};
}

/****************************************************************************
 * Rdwrs_operation                                                          *
 *  Grab/release monitor.                                                   *
 ****************************************************************************/
void                    /*                                                  */
Rdwrs_operation(        /*                                                  */
LONG mode)              /* Monitor to grab/release.                         */
/****************************************************************************/
{
	if(Rdwrs_quick(mode)) {
		WORD fd = (WORD)Fopen(mut_dev,0);
		
		Fread(fd,mode,NULL);
		
		Fclose(fd);
	};
}


/****************************************************************************
 * Rdwrs_create_sem                                                         *
 *  Create semaphore and release it.                                        *
 ****************************************************************************/
LONG                    /* Id of semaphore.                                 */
Rdwrs_create_sem(void)  /*                                                  */
/****************************************************************************/
{
	LONG semid = semaphore_id;
	LONG err;

	do {	
		err = Psemaphore(0,semid,-1);
		semid++;
	}while(err == -36);
	
	if(err < 0) {
		return err;
	}
	else {
		semaphore_id = semid;

		Psemaphore(3,semid - 1,-1);
		
		return semid - 1;
	};
}


WORD Rdwrs_get_sem(CSEMA *sem) {
	LONG err = Psemaphore(2,sem->id,-1);

	if(err == 0) {
		sem->count = 1;
		sem->pid = Pgetpid();
	}
	else if((err == -1) && (sem->pid == Pgetpid())) {
		sem->count++;
	}
	else {
		DB_printf("%s: Line %d: Rdwrs_get_sem\r\n"
							"didn't get semaphore %lx! caller=%d owner=%d count=%d err=%ld",
							__FILE__,__LINE__,sem->id,Pgetpid(),sem->pid,sem->count,err);
							
		return 0;
	};
	
	return 1;
}

WORD Rdwrs_rel_sem(CSEMA *sem) {
/* do we own it ? */
	if(Pgetpid() == sem->pid) {
		if(--sem->count == 0) {
			sem->pid = -1;
			Psemaphore(3,sem->id,-1);
		};

		return 1;
	};
	
	return 0;	
}

/****************************************************************************
 * Rdwrs_destroy_sem                                                        *
 *  Get semaphore and destroy it.                                           *
 ****************************************************************************/
void                     /*                                                 */
Rdwrs_destroy_sem(       /*                                                 */
LONG id)                 /* Id of semaphore.                                */
/****************************************************************************/
{
	Psemaphore(2,id,-1);
	Psemaphore(1,id,-1);
}
