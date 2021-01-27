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

*	void *bzero(void *dest, size_t len)

.text
.globl bzero
bzero:
*	move.l	4(a7),a0	; destination
*	move.l	8(a7),d0	; number of bytes
	move.l	a0,a1
	move.l	a0,d1
	btst	#0,d1		; odd alignment?
	beq 	b0
	clr.b	(a0)+		; zero first byte
	subq.l	#1,d0		; and reduce count
b0:
	move.l	d0,d1		; save full count value
	lsr.l	#1,d0		; convert to word count
b1:
	clr.w	(a0)+		; word zero loop
	subq.l	#1,d0
	bne 	b1
	btst	#0,d1		; extra odd byte to copy?
	beq 	b3
	clr.b	(a0)+		; zero last byte
b3:
	move.l	a1,a0		; return destination pointer
	rts
