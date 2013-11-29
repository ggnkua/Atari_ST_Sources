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

		********
		
		; Ici cas du scsi !
		
		; attention le Dma Falcon ne supporte que
		; des transferts de 0x3fff secteurs (~8Mb)!
		; prudence ‚tant mŠre de suret‚ nous ferons
		; des lots de 0x2000 secteurs (4 Mb)...
		; cependant, par principe, dans le mode asynchrone
		; de tels transferts ne peuvent Štre fragment‚s mais
		; un code d'erreur est renvoy‚ par 'scReadBack'.
		; (normalement 'scBadParmsErr')
		
		********
		DATA
		********
_read_cdb:	
		dc.b	$28,0,0,0,0,0,0,0,0,0
		
		********
		BSS
		********

_status		ds.b	1
_message		ds.b	1
		
		********
		TEXT
		********
GetScsi:
		movem.l	d2-d4/a3-a4,-(sp)
		
		****
		
		move.w	_GS_id(a6),d2
		subq.w	#8,d2
		
		; le dormeur doit se r‚veiller...
		
		tst.w	(SleepCounters.w,pc,d2.w*2)
		bne.s	.notasleep
		
		move.w	d2,-(sp)
		bsr	ScSelect
		
		pea	_cdb_startunit(pc)
		move.w	#6,-(sp)
		bsr	ScCmd
		
		pea	_status(pc)
		pea	_message(pc)
		pea	10*200.w
		bsr	ScComplete
.notasleep
		****
		
		lea	_read_cdb(pc),a4
		
		; i/o mode synchrone...
		; on charge d'abord le modulo
		
		move.l	_GS_addr(a6),a3
		move.l	_GS_count(a6),d3
		move.l	_GS_num(a6),d4
		
		and.l	#$1FFF,d3
		beq.s	.okmo
		
		move.l	d4,2(a4)
		move.w	d3,7(a4)
		
		add.l	d3,d4
		
		; … modifier pour secteurs <> 512
		
		add.l	d3,d3
		lsl.l	#8,d3
		
		****
		
		move.w	d2,-(sp)
		bsr	ScSelect
		
		tst.l	d0
		bne	.e_undev
		
		pea	_read_cdb(pc)
		move.w	#10,-(sp)
		bsr	ScCmd
		
		move.l	d3,-(sp)
		move.l	a3,-(sp)
		bsr	ScReadDMA
		
		pea	_status(pc)
		pea	_message(pc)
		pea	100.w
		bsr	ScComplete
		
		tst.l	d0
		bne	.e_trans
		
		tst.b	_status(pc)
		bne	analyse
		
		add.l	d3,a3
		
		********
.okmo		
		; puis le gros du bloc ...
		
		move.l	_GS_count(a6),d3
		beq	.end
		
		lsr.l	#8,d3
		lsr.l	#5,d3
		
		beq	.end
		
		move.l	d4,2(a4)
		move.w	#$2000,7(a4)
.sy8		
		move.w	d2,-(sp)
		bsr	ScSelect
		
		pea	_read_cdb(pc)
		move.w	#10,-(sp)
		bsr	ScCmd
		
		move.l	#$2000*$200,-(sp)
		move.l	a3,-(sp)
		bsr	ScReadDMA
		
		pea	_status(pc)
		pea	_message(pc)
		pea	100.w
		bsr	ScComplete
		
		tst.l	d0
		bne	.e_trans
		
		tst.b	_status(pc)
		bne	analyse
		
		add.l	#$2000,2(a4)
		add.l	#$2000*$200,a3
		
		subq.l	#1,d3
		bne.s	.sy8
		
		****
		
		; transfert DMA en lecture
		; il faut donc invalider les caches
		; quel que soit le processeur
		
		move	sr,d1
		move.w	#$2700,sr
		
		tst.w	mpu_flag(pc)
		beq.s	.is030
		
		cinva	dc
		bra.s	.okcac
.is030
		movec	cacr,d0
		or.w	#$0808,d0
		movec	d0,cacr
.okcac
		move	d1,sr
		
		moveq	#E_OK,d0
		
		****
.end		
		movem.l	(sp)+,d2-d4/a3-a4
		rts

		****
.e_undev
		moveq	#E_UNDEV,d0	'unknown device'
		bra.s	.end
		
		****
.e_trans:
		bsr	ScReset
		
		moveq	#E_CHNG,d0
		bra.s	.end
		
		****

********************************************************************
		
		****
		
		; analyse sense data
analyse		
		move.w	d2,d0
		jsr	GetSense(pc)
		ror.w	#8,d0
		
		lea	.sens_tab(pc),a0
.srch		
		cmp.b	(a0),d0
		beq.s	.oksens
		
		tst.w	(a0)+
		bpl.s	.srch
		
		moveq	#-1,d0
		bra	.out
.oksens
		move.b	1(a0),d0
		extb.l	d0
		
		****
		
		; attention retour BESTIAL !!
.out		
		movem.l	(sp)+,d2-d4/a3-a4
		rts
		
		****
		
		; table de conversion d'erreurs
.sens_tab:
		dc.b	$04,E_DRVNR
		dc.b	$09,E_SEEK
		dc.b	$11,E_READF
		dc.b	$12,E_SECNF
		dc.b	$13,E_SECNF
		dc.b	$14,E_SECNF
		dc.b	$15,E_SEEK
		dc.b	$17,E_OK
		dc.b	$18,E_OK
		dc.b	$19,E_MEDIA
		dc.b	$1C,E_MEDIA
		dc.b	$20,E_UNCMD
		dc.b	$21,E_RANGE
		dc.b	$24,E_RANGE
		dc.b	$26,E_RANGE
		dc.b	$28,E_CHNG
		dc.b	$29,E_CHNG
		dc.b	$2A,E_CHNG
		dc.b	$30,E_MEDIA
		dc.b	$31,E_MEDIA
		dc.b	$3A,E_OTHER
		dc.b	$3F,E_CHNG
		dc.b	$00,E_OK
		
		dc.w	-1
		
		****

********************************************************************

		****
		
		; Ici cas ‚criture du scsi !
		; on va gentiment appeler le scsi manager...
		
		****
		DATA
		****
_write_cdb:
		dc.b	$2a,0,0,0,0,0,0,0,0,0
		
		****
		BSS
		****
		
_wstatus		ds.b	1
_wmessage		ds.b	1
		
		****
		TEXT
		****
PutScsi:
		movem.l	d2-d4/a3-a4,-(sp)
		
		****
		
		move.w	_GS_id(a6),d2
		subq.w	#8,d2
		
		; le dormeur doit se r‚veiller...
		
		tst.w	(SleepCounters.w,pc,d2.w*2)
		bne.s	.notasleep
		
		move.w	d2,-(sp)
		bsr	ScSelect
		
		pea	_cdb_startunit(pc)
		move.w	#6,-(sp)
		bsr	ScCmd
		
		pea	_wstatus(pc)
		pea	_wmessage(pc)
		pea	10*200.w
		bsr	ScComplete
.notasleep
		****
		
		; transfert DMA en ‚criture
		; il faut donc flusher le cache
		; AVANT si on a un 040 ou 060
		
		tst.w	mpu_flag(pc)
		beq.s	.okcac
		cpusha	dc
.okcac
		****
		
		lea	_write_cdb(pc),a4
		
		; i/o mode synchrone...
		; on charge d'abord le modulo
		
		move.l	_PS_addr(a6),a3
		move.l	_PS_count(a6),d3
		move.l	_PS_num(a6),d4
		
		and.l	#$1FFF,d3
		beq.s	.okmo
		
		move.l	d4,2(a4)
		move.w	d3,7(a4)
		
		add.l	d3,d4
		
		add.l	d3,d3
		lsl.l	#8,d3
		
		****
		
		move.w	d2,-(sp)
		bsr	ScSelect
		
		tst.l	d0
		bne	.e_undev
		
		pea	_write_cdb(pc)
		move.w	#10,-(sp)
		bsr	ScCmd
		
		move.l	d3,-(sp)
		move.l	a3,-(sp)
		bsr	ScWriteDMA
		
		pea	_wstatus(pc)
		pea	_wmessage(pc)
		pea	100.w
		bsr	ScComplete
		
		tst.l	d0
		bne	.e_trans
		
		tst.b	_wstatus(pc)
		bne	analyse
		
		add.l	d3,a3
		
		********
.okmo		
		; puis le gros du bloc ...
		
		move.l	_PS_count(a6),d3
		beq	.end
		
		lsr.l	#8,d3
		lsr.l	#5,d3
		
		beq	.end
		
		move.l	d4,2(a4)
		move.w	#$2000,7(a4)
.sy8		
		move.w	d2,-(sp)
		bsr	ScSelect
		
		pea	_write_cdb(pc)
		move.w	#10,-(sp)
		bsr	ScCmd
		
		move.l	#$2000*$200,-(sp)
		move.l	a3,-(sp)
		bsr	ScWriteDMA
		
		pea	_wstatus(pc)
		pea	_wmessage(pc)
		pea	200.w
		bsr	ScComplete
		
		tst.l	d0
		bne	.e_trans
		
		tst.b	_status(pc)
		bne	analyse
		
		add.l	#$2000,2(a4)
		add.l	#$2000*$200,a3
		
		subq.l	#1,d3
		bne.s	.sy8
		
		****
		
		moveq	#E_OK,d0
		
		****
.end		
		movem.l	(sp)+,d2-d4/a3-a4
		rts

		****
.e_undev
		moveq	#E_UNDEV,d0	'unknown device'
		bra.s	.end
		
		****
.e_trans:
		bsr	ScReset
		
		moveq	#E_CHNG,d0
		bra.s	.end
		
		****

********************************************************************

		****
		DATA
		****

_sense_cdb	dc.b	$03,$00,$00,$00,$0e,$00

_sense_buffer	dcb.b	$10,0
		
		****
		TEXT
		****
		
		; routine de lecture de SENSE DATA
		; prend num‚ro ID en d0.w
		; retourne ASC+ASCQ en d0.w
GetSense:		
		move.w	d0,-(sp)
		Bsr	ScSelect
		
		pea	_sense_cdb(pc)
		move.w	#6,-(sp)
		Bsr	ScCmd
		
		lea	_sense_buffer(pc),a0
		
		pea	14.w
		pea	(a0)
		bsr	ScReadDMA
		
		pea	_status(pc)
		pea	_message(pc)
		pea	100.w
		Bsr	ScComplete
		
		tst.l	d0
		bne.s	.bug
.ok		
		; l'ASC et l'ASCQ sont en $c et $d
		
		moveq	#0,d0
		move.w	_sense_buffer+$c(pc),d0
		rts
		
		****
.bug
		moveq	#-1,d0
		rts
		
		********

********************************************************************
