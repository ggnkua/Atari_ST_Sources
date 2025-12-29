/*
 * lpdev.h: common definitions for lpdev.c and lpflush.c
 */

#include <minimal.h>
#include <string.h>
#include <stdlib.h>
#include <osbind.h>
#include <basepage.h>
#include <mintbind.h>
#include "filesys.h"
#include "atarierr.h"

/*
 * Default settings. DEVNAME is the name of the device,
 * BUFSIZE is the size of the circular buffer,
 * in bytes. It should be an even long-number.
 */

#define  DEVNAME	"u:\\dev\\lp"	/* device name     */
#define  BUFSIZE	(24*1024L)	/* 24 kbyte buffer */

/*
 * kernel functions
 */

#define TGETTIME	(*kernel->dos_tab[0x2c])
#define TGETDATE	(*kernel->dos_tab[0x2a])

#define NAP		(*kernel->nap)
#define SLEEP		(*kernel->sleep)
#define WAKE		(*kernel->wake)
#define WAKESELECT	(*kernel->wakeselect)

/* 
 * Debugging stuff; it can be removed if you want to spare a few bytes
 */

#define DEBUG(x)	(*kernel->debug)x
#define ALERT(x)	(*kernel->alert)x
#define TRACE(x)	(*kernel->trace)x
#define FATAL(x)	(*kernel->fatal)x

/* 
 * different process queues 
 */

#define CURPROC_Q	0
#define READY_Q		1
#define WAIT_Q		2
#define IO_Q		3
#define ZOMBIE_Q	4
#define TSR_Q		5
#define STOP_Q		6
#define SELECT_Q	7

/*
 * Here are prototypes for the functions defined in "centr.s"
 */

void new_centr_vector(void);
void print_byte(int);

#ifdef NO_INLINE
int spl7();
void spl(int);
#else

#define spl7()			\
({  register short retvalue;	\
    __asm__ volatile("		\
	movew sr,%0; 		\
	oriw  #0x0700,sr " 	\
    : "=d"(retvalue) 		\
    ); retvalue; })

#define spl(N)			\
({  				\
    __asm__ volatile("		\
	movew %0,sr " 		\
    :				\
    : "d"(N) ); })

#endif
