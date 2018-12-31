#ifndef DIALOG_H
#define DIALOG_H

#ifdef __PUREC__
#include <aes.h>	/* defs for OBJECT */
#else
#include <aesbind.h>
#endif

#include "wind.h"		/* defs for windowptr */

#define NB_DIALOG 6+1	/* add menu */

	/* Globals variables */
extern OBJECT *dinfo;
extern OBJECT *dsearch;
extern OBJECT *ddisk;
extern OBJECT *dsearch2;
extern OBJECT *dprint;
extern OBJECT *dpos;

	/* Functions */
extern int do_dialxy(OBJECT *dialog, int x, int y);
extern void open_dialog(int dialog_nb);
extern void init_dialog(void);

extern void dialog_info_exec(void);
extern void dialog_print_exec(void);
extern void dialog_disk_exec(void);
extern void dialog_search_exec(void);
extern void dialog_pos_exec(void);

#endif