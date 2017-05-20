;*
;* Teradesk. Copyright (c) 1993, 2002, W. Klaren.
;*
;* This file is part of Teradesk.
;*
;* Teradesk is free software; you can redistribute it and/or modify
;* it under the terms of the GNU General Public License as published by
;* the Free Software Foundation; either version 2 of the License, or
;* (at your option) any later version.
;*
;* Teradesk is distributed in the hope that it will be useful,
;* but WITHOUT ANY WARRANTY; without even the implied warranty of
;* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;* GNU General Public License for more details.
;*
;* You should have received a copy of the GNU General Public License
;* along with Teradesk; if not, write to the Free Software
;* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;*

			TEXT

			XDEF	btst,install_aes,remove_aes
			XREF	own_aes

			MODULE	btst		; routine voor het testen van bits.

			btst.l	d1,d0
			beq		zero
			moveq.l	#1,d0
			rts
zero:		clr.l	d0
			rts

			ENDMOD

			MODULE	aesfunc

install_aes:
			move.l	$88.w,old_aes
			move.l	#new_aes,$88.w
			rts

remove_aes:	move.l	$88.w,a0
			sub.l	a1,a1
.loop:		cmp.l	#'XBRA',-12(a0)
			bne.b	restore
			cmp.l	#'TDSK',-8(a0)
			beq		unlink
			move.l	a0,a1
			move.l	-4(a0),a0
			bra		.loop

unlink:		tst.l	a1
			beq		restore
			move.l	-4(a0),-4(a1)
			rts

restore:	move.l	old_aes,$88.w
			rts

			dc.b	"XBRA"
			dc.b	"TDSK"
old_aes:	ds.l	1

new_aes:	cmp		#200,d0
			beq.b	chk_aes

jmp_old:	move.l	old_aes,a0
			jmp		(a0)

chk_aes:	move.l	d1,a0
			move.l	(a0),a0
			cmp		#110,(a0)	;rsrc_load
			beq.b	jmp_new
			cmp		#120,(a0)	;shel_read
			beq.b	jmp_new
			cmp		#121,(a0)	;shel_write
			beq.b	jmp_new
			cmp		#124,(a0)	;shel_find
			bne.b	jmp_old

jmp_new:	clr		-(a7)
			movem.l	d0-d1/a2-a3,-(a7)

			move	(a0),d0
			move.l	d1,a0
			move.l	a7,a3
			move.l	USP,a7
			jsr		own_aes
			move.l	a3,a7
			move	d0,16(a7)

			movem.l	(a7)+,d0-d1/a2-a3
			tst		(a7)+
			bne.b	jmp_old
			rte

			ENDMOD

			END
