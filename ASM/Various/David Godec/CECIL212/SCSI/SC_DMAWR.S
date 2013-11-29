;***************************************************************************
;    CECILE Device Driver
;    Copyright (C) 1999-2006  David Godec  (david.godec@online.fr)
;
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program; if not, write to the Free Software
;    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
;
;***************************************************************************
		
		****
		TEXT
		****
		
		; ‚criture au SDMA
		
		; ATTENTION:
		; 1) transfert limit‚ … 8 Mega
		; 2) limit‚ au domaine 24 bits
		; 3) ne rend pas la main (!)

		; r‚ponse (d0)
		; 0=ok ,etc...
		
		****
		
		rsset	6*4
_sdmw_buff	rs.l	1
_sdmw_len		rs.l	1
		
		****
ScWriteDMA:
		movem.l	d1-d2/a1-a3,-(sp)
		
		move.w	#$8604,a0
		move.w	#$8606,a1
		
		; test exclusion zone 32 bits
		
		tst.b	_sdmw_buff(sp)
		bne	.error
		
		move.w	#NcrSelectEnable,(a1)
		clr.w	(a0)
		
		; phase 'sortie de donn‚es'
		; (c'est … dire MSG=0 C/D=0 I/O=0)
		
		move.w	#NcrTargetCommand,(a1)
		move.w	#0,(a0)
		
		; on attends la phase ad‚quate
		; d'abord on va attendre ~100 ms
.w_phase_1		
		move.l	#100,d1
		add.l	$4ba.w,d1
		move.w	#NcrBusStatus2,(a1)
.w_phase_2
		moveq	#BSR_PMATCH,d0
		and.w	(a0),d0
		bne.s	.phase_ok
		
		cmp.l	$4ba.w,d1
		bgt.s	.w_phase_2
		
		; aprŠs ce premier temps
		; il convient de tester si nous
		; sommes deja en phase 'status'
		; ce qui indiquerait une erreur
		; certaine dans la commande...
		
		move.w	#CBSR_IO+CBSR_CD+CBSR_MSG,d0
		
		move.w	#NcrBusStatus,(a1)
		and.w	(a0),d0
		
		cmp.w	#CBSR_IO+CBSR_CD,d0	; phase status_in
		beq	.exit
		
		; s'il n'y a pas d'erreur mais
		; une commande trŠs lente alors
		; on continue d'attendre...
		
		cmp.w	#CBSR_CD,d0	; phase cmd_out
		beq	.w_phase_1
		bra	.exit
		
		****
.phase_ok
		move.w	#NcrResetInterrupt,(a1)
		tst.w	(a0)
		tst.w	(a0)
		
		move.w	#NcrMode,(a1)
		move.w	#MR_DMA,(a0)
		
		; test erreur pointeur vide
		; test erreur taille nulle
		
		move.l	_sdmw_buff(sp),d0
		beq	.error
		move.l	_sdmw_len(sp),d1
		beq	.error
		
		move.w	#NcrInitiatorCommand,(a1)
		move.w	#ICR_DATA,(a0)
		
		****
		
		move.l	d0,a3
		btst	#0,d0	adresse impaire ??
		beq	.Sr1End
		
		; on ‚crit 1 octet au CPU si adresse impaire
		
		WaitREQ1	#1000,.exit
		
		move.b	(a3)+,d0
		
		move.w	#NcrScsiData,(a1)
		move.w	d0,(a0)
		
		move.w	#NcrInitiatorCommand,(a1)
		move.w	#ICR_ACK+ICR_DATA,(a0)
		
		WaitREQ0	#50,.exit
		
		move.w	#NcrInitiatorCommand,(a1)
		move.w	#ICR_DATA,(a0)
		
		subq.l	#1,d1
		
		****
.Sr1End
		; initialisation de l'adresse de base DMA
		
		move.l	a3,-(sp)
		move.b	3(sp),$ffff860d.w	; lo
		move.b	2(sp),$ffff860b.w	; mi
		move.b	1(sp),$ffff8609.w	; hi
		addq.w	#4,sp
		
		; nombre de blocs
		
		move.l	d1,d2
		lsr.l	#1,d2
		lsr.l	#8,d2
		addq.l	#2,d2
		
		move.w	#$190,(a1)
		move.w	#$090,(a1)
		move.w	#$190,(a1)
		move.w	d2,(a0)
.wrdma		
		btst.b	#3,$FFFF860F.w
		bne.s	.wrdma


		; d‚marrage des DMA ...
		
		move.w	#NcrStartDmaSend+$100,(a1)
		nop
		clr.w	(a0)
		nop
		move.w	#$100,(a1)
		nop
		
		; attente de la fin du transfert
		; (transfert mode synchrone)
		
		move.l	#10*60*200,d2
		add.l	$4ba.w,d2
.WaitEOP
		btst.b	#5,$fffffa01.w
		beq.s	.OkEOP
		
		cmp.l	$4ba.w,d2
		bgt.s	.WaitEOP
		
		clr.l	-(sp)
		move.b	$ffff860d.w,3(sp)	; lo
		move.b	$ffff860b.w,2(sp)	; mi
		move.b	$ffff8609.w,1(sp)	; hi
		move.l	(sp)+,d0
		
		move.w	#$090,(a1)
		bra	.exit
.OkEOP
		; appurer IRQ mfp
.hop		
		move.w	#NcrResetInterrupt,(a1)
		tst.w	(a0)
		tst.w	(a0)
		
		moveq	#0,d0
		
		****
.exit
		movem.l	(sp)+,d1-d2/a1-a3
		rtd	#8
.error
		moveq	#scBadParmsErr,d0
		bra.s	.exit
		
		****
