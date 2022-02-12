/*	wini.c - choose a winchester driver.		Author: Kees J. Bot
 *								28 May 1994
 * Several different winchester drivers may be compiled
 * into the kernel, but only one may run.  That one is chosen here using
 * the boot variable 'hd'.
 */

#include "kernel.h"
#include "driver.h"

#if ENABLE_WINI

/* Map driver name to task function. */
struct hdmap {
  char		*name;
  task_t	*task;
} hdmap[] = {

#if ENABLE_AT_WINI
  { "at",	at_winchester_task	},
#endif

#if ENABLE_BIOS_WINI
  { "bios",	bios_winchester_task	},
#endif

#if ENABLE_ESDI_WINI
  { "esdi",	esdi_winchester_task	},
#endif

#if ENABLE_XT_WINI
  { "xt",	xt_winchester_task	},
#endif

};


/*===========================================================================*
 *				winchester_task				     *
 *===========================================================================*/
PUBLIC void winchester_task()
{
  /* Call the default or selected winchester task. */
  char *hd;
  struct hdmap *map;

  hd = k_getenv("hd");

  for (map = hdmap; map < hdmap + sizeof(hdmap)/sizeof(hdmap[0]); map++) {
	if (hd == NULL || strcmp(hd, map->name) == 0) {
		/* Run the selected winchester task. */
		(*map->task)();
	}
  }
  panic("no hd driver", NO_NUM);
}
#endif /* ENABLE_WINI */
