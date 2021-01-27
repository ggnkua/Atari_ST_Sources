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

****
*
*	alloca()	-- allocate memory from the stack (NOT the heap)
*

*
* entry points
*
.globl	alloca

*
* external references
*
.globl	_break

.text
*
* void * cdecl alloca(size_t size)
*
* Allocate <size> bytes from the stack.  This space is automatically
* free'd when the calling function exits.  DO NOT use other memory
* management function, like free() and realloc(), with this block.
;
alloca:
	clr.l	d0				; set initial return value
	move.l	(sp),a1			; save return address
	move.l	4(sp),d1		; get requested block size
	move.l	sp,a0			; calculate new sp
	sub.l	d1,a0
	cmp.l	_break,a0		; if (new sp < _break)
	blt 	ealloca			;   error, potential stack overflow
	move.l	a0,sp			; set new sp
	move.l	d1,(a0)+		; store dummy longs
	move.l	a1,(a0)+
	move.l	a0,d0			; return pointer to memory block
ealloca:
	jmp	(a1)				; "return" to caller
