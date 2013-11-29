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
		
		; conclusion de transaction !
		
		; paramŠtres requis:
		; LONG: limite de temps en 200 Hz
		; LONG: pointe sur BYTES qui recevront les octets message ,
		; LONG: pointe sur BYTE qui recevra l'octet d'‚tat ,
		
		; r‚ponse (d0)
		; 0 = ok , etc ...
		
		****
		
		rsset	4*4
_scmp_time	rs.l	1	; time out (200 Hz units)
_scmp_msg		rs.l	1	; ptr for return of message byte(s)
_scmp_status	rs.l	1	; ptr for return of status byte
		
		****
ScComplete:
		movem.l	d1-d2/a1,-(sp)
		
		move.w	#$8604,a0
		move.w	#$8606,a1
		
		move.w	#NcrMode,(a1)
		clr.w	(a0)
		
		move.w	#NcrResetInterrupt,(a1)
		tst.w	(a0)
		tst.w	(a0)
		
		clr.b	([_scmp_msg.w,sp])
		clr.b	([_scmp_status.w,sp])
		
		****
		
		; Cecile va maintenant attendre jusqu'au
		; time-out que la cible passe le bus en phase
		; status pour communiquer l'octet d'etat de fin
		; d'execution de commande ....
.status		
		move.w	#NcrInitiatorCommand,(a1)
		clr.w	(a0)
		
		move.l	_scmp_time(sp),d1
		add.l	$4ba.w,d1
		
		move.w	#NcrTargetCommand,(a1)
		move.w	#TCR_CD+TCR_IO,(a0)
.WaitStatus
		move.w	#NcrBusStatus2,(a1)
		move.w	#BSR_PMATCH,d0
		and.w	(a0),d0
		bne	.OkStatus
		
		cmp.l	$4ba.w,d1
		bgt.s	.WaitStatus
		
		moveq	#scPhaseErr,d0
		bra	.Out
		
		****
.OkStatus
		; lire l'octet de status
		
		WaitREQ1	_scmp_time(sp),.CommError
		
		move.w	#NcrScsiData,(a1)
		move.w	(a0),d0
		move.b	d0,([_scmp_status.w,sp])
		
		move.w	#NcrInitiatorCommand,(a1)
		move.w	#ICR_ACK,(a0)
		
		WaitREQ0	_scmp_time(sp),.CommError
		
		move.w	#NcrInitiatorCommand,(a1)
		clr.w	(a0)
		
		****
		
		; maintenant qu'on a eu le status on va attendre
		; le(s) message(s) ...
		
		move.l	_scmp_time(sp),d1
		add.l	$4ba.w,d1
		
		move.w	#NcrTargetCommand,(a1)
		move.w	#TCR_IO+TCR_CD+TCR_MSG,(a0)
.WaitMessage
		move.w	#NcrBusStatus2,(a1)
		move.w	#BSR_PMATCH,d0
		and.w	(a0),d0
		bne.s	.ok_message
		
		cmp.l	$4ba.w,d1
		bgt.s	.WaitMessage
		
		moveq	#scPhaseErr,d0
		bra.s	.Out
.ok_message
		; lire le message
		
		WaitREQ1	_scmp_time(sp),.CommError
		
		move.w	#NcrScsiData,(a1)
		move.w	(a0),d0
		move.b	d0,([_scmp_msg.w,sp])
		
		move.w	#NcrInitiatorCommand,(a1)
		move.w	#ICR_ACK,(a0)
		
		WaitREQ0	_scmp_time(sp),.CommError
		
		
		move	#NcrInitiatorCommand,(a1)
		clr.w	(a0)
		move	#NcrTargetCommand,(a1)
		clr.w	(a0)
		
		moveq	#noErr,d0
		
		********
.Out		
		; appurer IRQ mfp
.ackirq		
		move.w	#NcrResetInterrupt,(a1)
		tst.w	(a0)
		tst.w	(a0)
		
		btst.b	#5,$fffffa01.w
		beq.s	.ackirq
		
		move.w	#$0080,(a1)
		
		movem.l	(sp)+,d1-d2/a1
		rtd	#12
		
		********
.CommError	
		moveq	#scCommErr,d0
		bra.s	.Out
		
		****************

********************************************************************
