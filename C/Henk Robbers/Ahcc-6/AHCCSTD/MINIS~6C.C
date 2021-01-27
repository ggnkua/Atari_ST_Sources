/* This file is part of the AHCC C Library.

   The AHCC C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The AHCC C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.
*/


/*	MINISTART.C	Minimal startup module for C programs not using libraries
    that depend on startup preparation */

#ifndef __AHCC__
#error This file can only be compiled by AHCC
#endif

#include <basepage.h>

unsigned long _PgmSize;
// unsigned long program_length;

#define BP BASEPAGE
#define BASEPAGE_SIZE 0x100

void __asm__ __text(void)
{
	move.l	4(sp),a5					; address to basepage
	move.l	BP @ p_tlen(a5),d0			; length of text segment
	add.l	BP @ p_dlen(a5),d0			; length of data segment
	add.l	BP @ p_blen(a5),d0			; length of bss segment
	add.l	#BASEPAGE_SIZE,d0			; length of stackpointer+basepage
//	move.l	d0,program_length			; save program length so _main() can access it
	move.l	d0,_PgmSize
	jsr 	main
	move.w	0,-(sp)
	trap	#1
}

#if REDIRECT
VpV *init_streams = nil;
static VpV split {}
VpV *end_streams  = nil;
#endif
