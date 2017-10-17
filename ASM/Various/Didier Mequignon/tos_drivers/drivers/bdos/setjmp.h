/*
 * setjmp.h - EmuTOS own copy of an ANSI standard header
 *
 * Copyright (c) 2002 EmuTOS development team
 *
 * Authors:
 *  LVL   Laurent Vogel
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */

#ifndef SETJMP_H
#define SETJMP_H

#include "portab.h"
 
typedef long jmp_buf[13];

short setjmp(jmp_buf state);
void longjmp(jmp_buf state, WORD value) NORETURN;

#endif /* SETJMP_H */
