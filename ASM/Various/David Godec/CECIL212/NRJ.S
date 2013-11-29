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
		
		; timer de (di)gestion d'energie
		
		********
SleepTimer:
		; les compteurs ‚tant en secondes
		; il est inutile de les tester …
		; chaque battement du timer mais
		; seulement une fois par seconde...
		
		move.l	a0,-(sp)
		
		; fuck the debugger
		
		lea	Prescale(pc),a0
		subq.w	#1,(a0)
		bne.s	.skip
		
		move.w	#200,(a0)
		
		****
		
		; y'a-t-il un i/o en cours ?
		
		tst.b	$43e.w
		bne.s	.skip
		
		move.l	d0,-(sp)
		
		moveq	#10-1,d0
		lea	SleepCounters+10*2(pc),a0
.hop		
		subq.w	#1,-(a0)
		bmi.s	.deja
		beq.s	.zzz
.paf		
		dbf	d0,.hop
		
		move.l	(sp)+,d0
		
		****
.skip
		move.l	(sp)+,a0
		jmp	([_OLD_TIMER.w,pc])
		
		********
		
		; ici,le dev dort deja, on corrige
		; le compteur avant de continuer...
.deja		
		addq.w	#1,(a0)
		bra.s	.paf
		
		********
		
		; ici,on doit endormir le device
.zzz		

		cmp.w	#8,d0
		blt.s	.scsi
		
		****
		
		; si c'est un IDE c'est vite fait...
.ide
		move.l	d0,-(sp)
		st	$43e.w
		
		; checkons son existence
		
		lsl.w	#7,d0
		tst.l	(EquipmentData+8*128.w,pc,d0.w)
		beq.s	.okide
		
		; selection du drive
.ya_ide		
		lsr.w	#7,d0
		and.w	#$0001,d0
		lsl.w	#4,d0
		or.w	#$00A0,d0
		
		move.b	d0,IdeDriveHead
		nop
		nop
.bsy		
		btst.b	#7,IdeStatus
		bne.s	.bsy
		
		move.b	#$E0,IdeCommand
		nop
		nop
		
		; si on polle l'irq, cela dure
		; trop longtemps et entraine des
		; problemes ,donc on vectorise l'irq
		; qui se devectorisera elle-meme...
		
		move.l	$11c.w,$300.w
		move.l	#"PIPO",$304.w
		
		pea	SleepIRQ(pc)
		move.l	(sp)+,$11c.w
		
		bset.b	#7,$fffffa09.w
		bset.b	#7,$fffffa15.w
		
		; important: on laisse $43e true !
.okide		
		move.l	(sp)+,d0
		bra.s	.paf
		
		****
		****
		
		; pour le scsi,c'est un peu plus long...
.scsi		
		; checkons son existence
		
		lsl.w	#7,d0
		tst.l	(EquipmentData+8*128.w,pc,d0.w)
		beq.s	.okscsi
		
		movem.l	d0-d1/a0-a1,-(sp)
		
		; envoi commande au dev
		
		lsr.w	#7,d0
		
		move.w	d0,-(sp)
		bsr	ScSelect
		
		pea	_cdb_stopunit(pc)
		move.w	#6,-(sp)
		bsr	ScCmd
		
		pea	_status(pc)
		pea	_message(pc)
		pea	200.w
		bsr	ScComplete
		
		; h‚las,comme nous sommes …
		; l'int‚rieur du timer,s'il
		; y'a un bug, ca bloquera...
		
		movem.l	(sp)+,d0-d1/a0-a1
.okscsi
		lsr.w	#7,d0
		bra	.paf
		
		********
_cdb_stopunit:
		dc.b	$1b,1,0,0,0,0
_cdb_startunit:
		dc.b	$1b,0,0,0,1,0
		
		********
Prescale:
		dc.w	200
_OLD_TIMER:
		dc.l	0

		********
		
		; interruption diff‚r‚e pour standby IDE
SleepIRQ:
		move.w	#$2700,sr
		
		bclr.b	#7,$fffffa11.w
		bclr.b	#7,$fffffa09.w
		bclr.b	#7,$fffffa15.w

		tst.b	IdeStatus
		tst.b	IdeStatus
		
		sf	$43e.w
		rte
		
		********
