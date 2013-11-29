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
		
		; sccmd (cdblen,cdb*)
		
		; Envoyer un bloc de commande … une cible !
		
		; paramŠtres requis:
		; WORD: longueur du command descriptor block
		; LONG: pointeur sur le command descriptor block
		
		; r‚ponse (d0)
		; 0 = ok , etc ...
		
		****
		
		rsset	6*4
_scmd_len		rs.w	1
_scmd_ptr		rs.l	1
		
		****
ScCmd:
		movem.l	d1-d2/a1-a3,-(sp)
		
		move.w	#$8606,a1
		move.w	#$8604,a0

		; testons la phase 'sortie de commande'
		
		move.w	#NcrTargetCommand,(a1)
		move.w	#TCR_CD,(a0)
		
		move.l	#200,d1		* 1000 ms
		add.l	$4ba.w,d1
.WaitPhase
		move.w	#NcrBusStatus2,(a1)
		move.w	#BSR_PMATCH,d0
		and.w	(a0),d0
		bne.s	.PhaseMatch
		
		cmp.l	$4ba.w,d1
		bgt.s	.WaitPhase
		
		moveq	#$F7,d0
		bra	.End
.PhaseMatch
		****
		
		move.l	_scmd_ptr(sp),a3
		move.w	_scmd_len(sp),d1
		moveq	#0,d0
		
		move.w	#NcrInitiatorCommand,(a1)
		move.w	#ICR_DATA,(a0)
.SendByte:
		WaitREQ1	#100,.end		* 500 ms
		
		move.b	(a3)+,d0
		
		move.w	#NcrScsiData,(a1)
		move.w	d0,(a0)
		
		move.w	#NcrInitiatorCommand,(a1)
		move.w	#ICR_DATA+ICR_ACK,(a0)
		
		WaitREQ0	#100,.end
		
		move.w	#NcrInitiatorCommand,(a1)
		move.w	#ICR_DATA,(a0)
		
		subq.w	#1,d1
		bgt	.SendByte
		
		move.w	#NcrInitiatorCommand,(a1)
		clr.w	(a0)
		
		moveq	#noErr,d0
.end		
		movem.l	(sp)+,d1-d2/a1-a3
		rtd	#6
		
		****
