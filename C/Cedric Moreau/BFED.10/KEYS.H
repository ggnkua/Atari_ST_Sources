#ifndef KEYS_H
#define KEYS_H

#ifdef __PUREC__
#include <tos.h> /* defs for KEYTAB */
#else
#include <osbind.h>
#endif

#include "wind.h"	/* defs for windowptr */

	/* globals vars */
extern int keycode;

	/* functions */
extern void init_keys(void);
extern void do_kbd(int	keycode, int keymods);
extern void check_scroll(windowptr	thewin);
extern int repos(windowptr	thewin);
extern void jump_pos(windowptr	thewin);
extern void ins_rpl(windowptr	thewin);
extern void enter_it(windowptr	thewin,char		*inbuf,	long		lnum);

#endif