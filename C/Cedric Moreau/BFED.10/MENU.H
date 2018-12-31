#ifndef MENU_H
#define MENU_H

#ifdef __PUREC__
#include <aes.h>	/* defs for OBJECT */
#include <compend.h>
#else
#include <aesbind.h>
#endif

	/* globals vars */
extern OBJECT *menu;
extern char moderp[];
extern char modein[];

	/* functions */
extern void do_menu(int menuid, int itemid);
extern void init_menu(void);
extern void update_menu(void);	

#endif