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
		text
		****
		
		; fonction permettant d'obtenir le
		; controle du bus SCSI et de selectionner
		; la cible voulue ...
		
		****
		
		rsset	3*4
_ssel_dev		rs.w	1	; id device … s‚lecter
		
		****
ScSelect:
		movem.l	d1/a1,-(sp)
		
		move.w	#$8604,a0
		move.w	#$8606,a1

		****
		
		; y'a-t-il une interruption pendante ?
		
		btst.b	#5,$fffffa01.w
		bne.s	.okirq
		
			; si oui,il faut se d‚barrasser des
			; requetes d'interruption en cours non-scsi
			
			tst.b	$FFFF860F.w
			
			tst.b	IdeStatus
			
			move.w	#$0080,(a1)
			tst.w	(a0)
.okirq		
		****
		
		; un peu de nettoyage...
		
		bsr	.clear_ncr
		
		****
		
		; mettons notre ID dans le 'data register'
		
		move.w	ScsiHostId(pc),d0
		moveq	#0,d1
		bset	d0,d1
		
		move.w	#NcrScsiData,(a1)
		move.w	d1,(a0)
		
		****
		
		; entrons en phase d'arbitrage
		
		move.w	#NcrMode,(a1)
		move.w	#MR_ARB,(a0)
		
		; time out ~ 250 ms
		
		moveq	#50,d1
		add.l	$4ba.w,d1
.WaitArb
		move.w	#NcrInitiatorCommand,(a1)
		moveq	#ICR_AIP,d0
		and.w	(a0),d0
		bne.s	.OkArb
		
		cmp.l	$4ba.w,d1
		bgt.s	.WaitArb
		
		moveq	#scArbNBErr,d0
		bra	.error
.OkArb		
		****
		moveq	#50,d0
		dbf	d0,*
		****
		
		; testons la victoire ...
		
		move.w	#NcrInitiatorCommand,(a1)
		moveq	#ICR_LOST,d0
		and.w	(a0),d0
		beq.s	.NotLost
		
		moveq	#scArbNBErr,d0
		bra	.error
		
		****
.NotLost		
		move.w	#NcrInitiatorCommand,(a1)
		move.w	#ICR_SEL,(a0)
		
		****
		moveq	#50,d0
		dbf	d0,*
		****
		
		moveq	#0,d0
		move.w	ScsiHostID(pc),d1
		bset	d1,d0
		move.w	_ssel_dev(sp),d1
		bset	d1,d0
		
		move.w	#NcrScsiData,(a1)
		move.w	d0,(a0)
		
		move.w	#NcrInitiatorCommand,(a1)
		move.w	#ICR_DATA+ICR_SEL+ICR_BSY,(a0)
		
		move.w	#NcrMode,(a1)
		clr.w	(a0)
		
		****
		
		; on relache \BSY
		
		move.w	#NcrInitiatorCommand,(a1)
		move.w	#ICR_SEL+ICR_DATA,(a0)
		
		****
		moveq	#50,d0
		dbf	d0,*
		****
		
		; attente de r‚ponse ~ 250 mS
		
		moveq	#50,d1
		add.l	$4ba.w,d1
.wait_busy
		move.w	#NcrBusStatus,(a1)
		move.w	#CBSR_BSY,d0
		and.w	(a0),d0
		bne.s	.ok_3
		
		cmp.l	$4ba.w,d1
		bgt.s	.wait_busy
		
		moveq	#scArbNBErr,d0
		bra.s	.Error
		
		****
.ok_3
		; il faut relacher \SEL (ATTN: deskew!)
		; (\BSY est maintenant monitor‚ par la target)
		
		move.w	#NcrInitiatorCommand,(a1)
		clr.w	(a0)
		move.w	#NcrResetInterrupt,(a1)
		tst.w	(a0)
		
		****
		
		moveq	#noErr,d0
.end		
		movem.l	(sp)+,d1/a1
		rtd	#2
		
		********
.error		
		bsr	.clear_ncr
		
		move.w	#$0080,(a1)
		bra.s	.end
		
		********
.clear_ncr:		
		move.w	#NcrMode,(a1)
		clr.w	(a0)
		move.w	#NcrInitiatorCommand,(a1)
		clr.w	(a0)
		move.w	#NcrTargetCommand,(a1)
		clr.w	(a0)
		move.w	#NcrSelectEnable,(a1)
		clr.w	(a0)
		
		move.w	#NcrResetInterrupt,(a1)
		tst.w	(a0)
		
		rts
		
		********

****************************************************************
