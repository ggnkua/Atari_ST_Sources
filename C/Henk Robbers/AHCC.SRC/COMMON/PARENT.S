*  Copyright (c) 1990 - present by Henk Robbers Amsterdam.
*
* This file is part of AHCC.
*
* AHCC is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* AHCC is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with AHCC; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*

	text
globl  get_parent
module get_parent
		move 	d3,-(a7)
		move.l	a2,-(a7)
		movea.l	a0,a2
		move 	d0,d3
		tst 	d0
		bgt.s	l2
		moveq	#-1,d0
		bra.s	lx

l1:		move 	d3,d0
		muls	#24,d0
		move 	0(a2,d0.l),d3
l2:		tst 	d3
		beq.s	l3
		move 	d3,d1
		muls	#24,d1
		move 	0(a2,d1.l),d0
		muls	#24,d0
		cmp 	4(a2,d0.l),d3
		bne.s	l1
l3:		move 	d3,d0
		muls	#24,d0
		move 	0(a2,d0.l),d0
lx:		movea.l	(a7)+,a2
		move 	(a7)+,d3
		rts
endmod
