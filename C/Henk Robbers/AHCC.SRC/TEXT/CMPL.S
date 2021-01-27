
* Copyright (c) 1990 - 2008 by H. Robbers Amsterdam.
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

*	int cmpl(const uchar *s1, const uchar *2, int l);
*								              l at least 1
*	-1     s1 < s2
*   +1     s1 > s2

globl cmpl
module cmpl
			subq	#1,d0
l1:			move.b	(a0)+,d1
			cmp.b	(a1)+,d1
			bcs.s	l2
			bhi.s	l3
			dbf 	d0,l1
			move.b	(a1),d0
			beq.s	l4
l2:			moveq	#-1,d0
			rts

l3:			moveq	#1,d0
			rts

l4:			clr 	d0
			rts
endmod

globl cmpli
module cmpli
			subq	#1,d0
l1:			move.b	(a0)+,d1
			move.b	(a1)+,d2
			ori.b	#$20,d1
			ori.b	#$20,d2
			cmp.b	d2,d1
			bcs.s	l2
			bhi.s	l3
			dbf 	d0,l1
			move.b	(a1),d0
			beq.s	l4
l2:			moveq	#-1,d0
			rts

l3:			moveq	#1,d0
			rts

l4:			clr 	d0
			rts
endmod

end