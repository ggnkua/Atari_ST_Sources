/*
 * cache.S - cache control functions for USB TOS drivers
 *
 * David Galvez     2019
 * Didier Mequignon 2005-2007, e-mail: aniplay@wanadoo.fr
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

.globl _cpush

_cpush:
	move.l 8(SP),D0          // size
	beq.s .csh1
	move.l D0,D1
	addq.l #1,D1
	beq.s .csh3              // -1 then flush all
	move.l 4(SP),A0          // base
	move.l A0,D1
	and.l #15,D1
	sne.b D1
	and.l #1,D1
	lsr.l #4,D0              // 16
	add.l D1,D0
	cmp.l #256,D0            // cache lines
	bcc.s .csh3              // flush all
	move.l A0,D1             // line alignment
	and.b #0xF0,D1
	move.l D1,A0
	subq.l #1,D0
.csh2:                           // flush lines loop
	cpushl dc,(A0)
	lea 16(A0),A0
	dbf D0,.csh2
	rts
.csh3:
	cpusha dc                // flush all
.csh1:
	rts
