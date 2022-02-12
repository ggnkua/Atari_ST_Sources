/* The object file of "table.c" contains all the data.  In the *.h files, 
 * declared variables appear with EXTERN in front of them, as in
 *
 *    EXTERN int x;
 *
 * Normally EXTERN is defined as extern, so when they are included in another
 * file, no storage is allocated.  If the EXTERN were not present, but just
 * say,
 *
 *    int x;
 *
 * then including this file in several source files would cause 'x' to be
 * declared several times.  While some linkers accept this, others do not,
 * so they are declared extern when included normally.  However, it must
 * be declared for real somewhere.  That is done here, by redefining
 * EXTERN as the null string, so the inclusion of all the *.h files in
 * table.c actually generates storage for them.  All the initialized
 * variables are also declared here, since
 *
 * extern int x = 4;
 *
 * is not allowed.  If such variables are shared, they must also be declared
 * in one of the *.h files without the initialization.
 */

#define _TABLE

#include "kernel.h"
#include <termios.h>
#include <minix/com.h>
#include "proc.h"
#include "tty.h"

/* The startup routine of each task is given below, from -NR_TASKS upwards.
 * The order of the names here MUST agree with the numerical values assigned to
 * the tasks in <minix/com.h>.
 */
#define SMALL_STACK	(128 * sizeof(char *))

#define	TTY_STACK	(3 * SMALL_STACK)
#define SYN_ALRM_STACK	SMALL_STACK

#define DP8390_STACK	(SMALL_STACK * ENABLE_NETWORKING)

#if (CHIP == INTEL)
#define	IDLE_STACK	((3+3+4) * sizeof(char *))  /* 3 intr, 3 temps, 4 db */
#else
#define IDLE_STACK	SMALL_STACK
#endif

#define	PRINTER_STACK	SMALL_STACK

#if (CHIP == INTEL)
#define	WINCH_STACK	(2 * SMALL_STACK * ENABLE_WINI)
#else
#define	WINCH_STACK	(3 * SMALL_STACK * ENABLE_WINI)
#endif

#if (MACHINE == ATARI)
#define	SCSI_STACK	(3 * SMALL_STACK)
#endif

#if (MACHINE == IBM_PC)
#define	SCSI_STACK	(2 * SMALL_STACK * ENABLE_SCSI)
#endif

#define CDROM_STACK	(4 * SMALL_STACK * ENABLE_CDROM)
#define DOSDSK_STACK	(3 * SMALL_STACK * ENABLE_DOSDSK)
#define AUDIO_STACK	(4 * SMALL_STACK * ENABLE_AUDIO)
#define MIXER_STACK	(4 * SMALL_STACK * ENABLE_AUDIO)

#define	FLOP_STACK	(3 * SMALL_STACK)
#define	MEM_STACK	SMALL_STACK
#define	CLOCK_STACK	SMALL_STACK
#define	SYS_STACK	SMALL_STACK
#define	HARDWARE_STACK	0		/* dummy task, uses kernel stack */


#define	TOT_STACK_SPACE		(TTY_STACK + DP8390_STACK + SCSI_STACK + \
	SYN_ALRM_STACK + IDLE_STACK + HARDWARE_STACK + PRINTER_STACK + \
	WINCH_STACK + FLOP_STACK + MEM_STACK + CLOCK_STACK + SYS_STACK + \
	CDROM_STACK + DOSDSK_STACK + AUDIO_STACK + MIXER_STACK)


/* Default choices for tasks with more than one driver. */
#if ENABLE_AT_WINI
#define winchester_task	at_winchester_task
#elif ENABLE_BIOS_WINI
#define winchester_task	bios_winchester_task
#elif ENABLE_ESDI_WINI
#define winchester_task	esdi_winchester_task
#elif ENABLE_XT_WINI
#define winchester_task	xt_winchester_task
#endif

#if ENABLE_AHA1540_SCSI
#define scsi_task	aha1540_scsi_task
#endif

#if ENABLE_DOSFILE
#define dosdsk_task	dosfile_task
#elif ENABLE_DOSFAT
#define dosdsk_task	dosfat_task
#endif

/* CDROM and AUDIO may in the future have different choices like
 * WINCHESTER, but for now the choice is fixed.
 */
#define cdrom_task	mcd_task
#define audio_task	dsp_task


/*
 * Some notes about the following table:
 *  1) The tty_task should always be first so that other tasks can use printf
 *     if their initialisation has problems.
 *  2) If you add a new kernel task, add it before the printer task.
 *  3) The task name is used for the process name (p_name).
 */

PUBLIC struct tasktab tasktab[] = {
	{ tty_task,		TTY_STACK,	"TTY"		},
#if ENABLE_NETWORKING
	{ dp8390_task,		DP8390_STACK,	"DP8390"	},
#endif
#if ENABLE_DOSDSK
	{ dosdsk_task,		DOSDSK_STACK,	"DOSDSK"	},
#endif
#if ENABLE_CDROM
	{ cdrom_task,		CDROM_STACK,	"CDROM"		},
#endif
#if ENABLE_AUDIO
	{ audio_task,		AUDIO_STACK,	"AUDIO"		},
	{ mixer_task,		MIXER_STACK,	"MIXER"		},
#endif
#if ENABLE_SCSI
	{ scsi_task,		SCSI_STACK,	"SCSI"		},
#endif
#if ENABLE_WINI
	{ winchester_task,	WINCH_STACK,	"WINCH"		},
#endif
	{ syn_alrm_task,	SYN_ALRM_STACK, "SYN_AL"	},
	{ idle_task,		IDLE_STACK,	"IDLE"		},
	{ printer_task,		PRINTER_STACK,	"PRINTER"	},
	{ floppy_task,		FLOP_STACK,	"FLOPPY"	},
	{ mem_task,		MEM_STACK,	"MEMORY"	},
	{ clock_task,		CLOCK_STACK,	"CLOCK"		},
	{ sys_task,		SYS_STACK,	"SYS"		},
	{ 0,			HARDWARE_STACK,	"HARDWAR"	},
	{ 0,			0,		"MM"		},
	{ 0,			0,		"FS"		},
#if ENABLE_NETWORKING
	{ 0,			0,		"INET"		},
#endif
	{ 0,			0,		"INIT"		},
};

/* Mapping from driver names to driver functions, e.g. "bios" -> bios_wini. */
PRIVATE struct drivertab {
	char drivername[6];
	task_t *driver;
} drivertab[] = {

#if ENABLE_AT_WINI
	{ "at",		at_winchester_task	},
#endif

#if ENABLE_BIOS_WINI
	{ "bios",	bios_winchester_task	},
#endif

#if ENABLE_ESDI_WINI
	{ "esdi",	esdi_winchester_task	},
#endif

#if ENABLE_XT_WINI
	{ "xt",		xt_winchester_task	},
#endif

#if ENABLE_AHA1540_SCSI
	{ "a1540",	aha1540_scsi_task	},
#endif

#if ENABLE_DOSFILE
	{ "file",	dosfile_task		},
#endif

#if ENABLE_DOSFAT
	{ "fat",	dosfat_task		},
#endif

};

/* Mapping from environment variables to tasks, e.g. "hd" -> WINCHESTER. */
PRIVATE struct envtab {
	char env[5];
	char taskno;
} envtab[] = {

#if ENABLE_WINI
	{ "hd",		WINCHESTER	},
#endif

#if ENABLE_SCSI
	{ "sd",		SCSI		},
#endif

#if ENABLE_DOSDSK
	{ "dosd",	DOSDSK		},
#endif

};

/*===========================================================================*
 *				mapdrivers				     *
 *===========================================================================*/
PUBLIC void mapdrivers()
{
  /* Select drivers and update the task table to that selection. */
  struct envtab *ep;
  struct drivertab *dp;
  char *drivername;

  for (ep = envtab; ep < envtab + sizeof(envtab)/sizeof(envtab[0]); ep++) {
	if ((drivername = k_getenv(ep->env)) == NULL) continue;
	for (dp = drivertab;
	     dp < drivertab + sizeof(drivertab)/sizeof(drivertab[0]); dp++) {
		if (strcmp(drivername, dp->drivername) == 0) {
			tasktab[ep->taskno + NR_TASKS].initial_pc = dp->driver;
		}
	}
  }
}

/* Stack space for all the task stacks.  (Declared as (char *) to align it.) */
PUBLIC char *t_stack[TOT_STACK_SPACE / sizeof(char *)];

/*
 * The number of kernel tasks must be the same as NR_TASKS.
 * If NR_TASKS is not correct then you will get the compile error:
 *   "array size is negative"
 */

#define NKT (sizeof tasktab / sizeof (struct tasktab) - (INIT_PROC_NR + 1))

extern int dummy_tasktab_check[NR_TASKS == NKT ? 1 : -1];
