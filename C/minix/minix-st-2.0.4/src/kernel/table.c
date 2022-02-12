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
#include <stdlib.h>
#include <termios.h>
#include <minix/com.h>
#include "proc.h"
#include "tty.h"
#include <ibm/int86.h>

/* The startup routine of each task is given below, from -NR_TASKS upwards.
 * The order of the names here MUST agree with the numerical values assigned to
 * the tasks in <minix/com.h>.
 */
#define SMALL_STACK	(128 * sizeof(char *))

#define	TTY_STACK	(3 * SMALL_STACK)
#define SYN_ALRM_STACK	SMALL_STACK

#define DP8390_STACK	(2 * SMALL_STACK * ENABLE_DP8390)
#define RTL8139_STACK	(2 * SMALL_STACK * ENABLE_RTL8139)

#if (CHIP == INTEL)
#define	IDLE_STACK	((3+3+4) * sizeof(char *))  /* 3 intr, 3 temps, 4 db */
#else
#define IDLE_STACK	(64)
#endif

#define	PRINTER_STACK	(SMALL_STACK * ENABLE_PRINTER)
#if (CHIP == INTEL)
#define	CTRLR_STACK	(2 * SMALL_STACK)
#else
#define	CTRLR_STACK	(3 * SMALL_STACK)
#endif /* CHIP == INTEL */

#define SB16_STACK	(4 * SMALL_STACK * ENABLE_SB16)
#define SB16MIXER_STACK	(4 * SMALL_STACK * ENABLE_SB16)

#define	FLOP_STACK	(3 * SMALL_STACK)
#define	MEM_STACK	SMALL_STACK
#define	CLOCK_STACK	SMALL_STACK
#define	SYS_STACK	(2*SMALL_STACK)
#define	HARDWARE_STACK	0		/* dummy task, uses kernel stack */


#define	TOT_STACK_SPACE		(TTY_STACK + DP8390_STACK + RTL8139_STACK + \
	SYN_ALRM_STACK + IDLE_STACK + HARDWARE_STACK + PRINTER_STACK + \
	NR_CTRLRS * CTRLR_STACK + FLOP_STACK + MEM_STACK + CLOCK_STACK + \
	SYS_STACK + SB16_STACK + SB16MIXER_STACK)


/*
 * Some notes about the following table:
 *  1) The tty_task should always be first so that other tasks can use printf
 *     if their initialisation has problems.
 *  2) If you add a new kernel task, add it before the printer task.
 *  3) The task name is used for the process name (p_name).
 */

PUBLIC struct tasktab tasktab[] = {
	{ tty_task,		TTY_STACK,	"TTY"		},
#if ENABLE_DP8390
	{ dp8390_task,		DP8390_STACK,	"DP8390"	},
#endif
#if ENABLE_RTL8139
	{ rtl8139_task,		RTL8139_STACK,	"RTL8139"	},
#endif
#if ENABLE_SB16
	{ sb16_task,		SB16_STACK,	"SB16"		},
	{ sb16mixer_task,	SB16MIXER_STACK,"SB16MIX"	},
#endif
#if ENABLE_PRINTER
	{ printer_task,		PRINTER_STACK,	"PRINTER"	},
#endif
#if NR_CTRLRS >= 4
	{ nop_task,		CTRLR_STACK,	"(C3)"		},
#endif
#if NR_CTRLRS >= 3
	{ nop_task,		CTRLR_STACK,	"(C2)"		},
#endif
#if NR_CTRLRS >= 2
	{ nop_task,		CTRLR_STACK,	"(C1)"		},
#endif
#if NR_CTRLRS >= 1
	{ nop_task,		CTRLR_STACK,	"(C0)"		},
#endif
	{ syn_alrm_task,	SYN_ALRM_STACK, "SYN_AL"	},
	{ idle_task,		IDLE_STACK,	"IDLE"		},
	{ floppy_task,		FLOP_STACK,	"FLOPPY"	},
	{ mem_task,		MEM_STACK,	"MEMORY"	},
	{ clock_task,		CLOCK_STACK,	"CLOCK"		},
	{ sys_task,		SYS_STACK,	"SYS"		},
	{ 0,			HARDWARE_STACK,	"HARDWAR"	},
	{ 0,			0,		"MM"		},
	{ 0,			0,		"FS"		},
	{ 0,			0,		"INIT"		},
};

/* Mapping from driver names to driver functions, e.g. "bios" -> bios_wini. */
PRIVATE struct drivertab {
	char drivername[8];
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
	{ "aha1540",	aha1540_scsi_task	},
#endif

#if ENABLE_DOSFILE
	{ "dosfile",	dosfile_task		},
#endif

#if ENABLE_FATFILE
	{ "fatfile",	fatfile_task		},
#endif

#if (MACHINE == ATARI && NR_ACSI_DRIVES > 0)
	{ "ACSI",	acsi_task		},
#endif /* MACHINE == ATARI && NR_ACSI_DRIVES */
};

/*===========================================================================*
 *				mapdrivers				     *
 *===========================================================================*/
PUBLIC void mapdrivers()
{
  /* Map drivers to controllers and update the task table to that selection. */
  static char name[] = "c0";
  int c;
  struct drivertab *dp;
  char *drivername;
  struct tasktab *tp;

  for (c= 0; c < NR_CTRLRS; c++) {
	name[1] = '0' + c;
	if ((drivername = getenv(name)) == NULL) continue;
	for (dp = drivertab;
	     dp < drivertab + sizeof(drivertab)/sizeof(drivertab[0]); dp++) {
		if (strcmp(drivername, dp->drivername) == 0) {
			tp = &tasktab[CTRLR(c) + NR_TASKS];
			tp->initial_pc = dp->driver;
			strcpy(tp->name, drivername);
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
