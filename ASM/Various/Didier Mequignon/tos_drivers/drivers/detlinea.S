/* TOS 4.04 LineA dispatcher for the CT60/CTPCI boards
 * Didier Mequignon 2002-2010, e-mail: aniplay@wanadoo.fr
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

	.global _det_linea,_old_vector_linea,_oldmouse
	.global show_c,hide_c
	.global _os_magic
	.global adr_var_vdi,adr_linea_fonts,adr_linea_atab

#define _sysbase   0x4F2

	.data

_det_linea:

	move.l 2(SP),A1
#ifdef COLDFIRE
	moveq #0,D2
	move.w (A1)+,D2
	and.l #0xFFF,D2          // 0xA00X are MAC instructions on Coldfire
	cmp.l #0x920,D2
	beq.s .l1                // 0xA92X
	cmp.l #0x929,D2
	beq.s .l2                // 0xA929
	cmp.l #0x92A,D2
	beq.s .l3                // 0xA92A
#else
	move.w (A1)+,D2
	and.w #0xFFF,D2
	beq.s .l1                // 0xA000
	cmp.w #0x009,D2
	beq.s .l2                // 0xA009
	cmp.w #0x00A,D2
	beq.s .l3                // 0xA00A
#endif
	move.l A1,2(SP)          // jump opcode
	rte
.l2:
	tst.w _oldmouse
	bne.s .l1
	moveq #0,D0              // reset
	bsr show_c
	move.l A1,2(SP)          // jump opcode
	rte
.l3:
	tst.w _oldmouse
	bne.s .l1
	bsr hide_c
	move.l A1,2(SP)          // jump opcode
	rte	
.l1:
	move.l _old_vector_linea,-(SP)
	rts	
