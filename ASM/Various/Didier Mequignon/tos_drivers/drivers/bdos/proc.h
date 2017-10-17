/*
 * proc.h - processes defines
 *
 * Copyright (c) 2001 EmuTOS Development Team.
 *
 * Authors:
 *  LVL   Laurent Vogel
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */

#ifndef PROC_H
#define PROC_H

#include "pghdr.h"

/*
 *  process management
 */

extern  WORD    supstk[];
extern  PD      *run;

/* 
 * values of Pexec flg
 */

#define PE_LOADGO       0
#define PE_LOAD         3
#define PE_GO           4
#define PE_BASEPAGE     5
#define PE_GOTHENFREE   6
#define PE_BASEPAGEFREE 7

/*
 * in proc.c
 */

long xexec(WORD, char *, char *, char *);
void x0term(void);
void xterm(UWORD rc)  NORETURN ;
WORD xtermres(long blkln, WORD rc);

/*
 * in kpgmld.c
 */

LONG kpgmhdrld(char *s, PGMHDR01 *hd, FH *h);
LONG kpgmld(PD *p, FH h, PGMHDR01 *hd);

/*
 * in rwa.S
 */

void gouser(void)  NORETURN;  
void termuser(void)  NORETURN;  

#endif /* PROC_H */
