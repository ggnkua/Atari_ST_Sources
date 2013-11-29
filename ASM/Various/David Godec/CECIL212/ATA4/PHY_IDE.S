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
		TEXT
		********
		
		; Ici cas d'un drive ide !
		; il faut parfois proc‚der en plusieurs fois
		; car l'ide est limit‚ en transfert … 256 secteurs
		; l'accŠs se fait en mode LBA 28 bits ou en CHS
		; si le mode LBA n'est pas disponible...
		
		********
		; LECTURE IDE
		********
GetIde:
		movem.l	d2-d7/a2-a4,-(sp)
		
		****
		
		tst.l	_GS_num(a6)
		bmi.s	.bug

		moveq	#0,d7
		moveq	#1,d0
		and.w	_GS_id(a6),d0

		tst.b	(AtaSwap.w,pc,d0.w)
		beq.s	.not_pc
.pc_mode
			moveq	#3,d0
			bra.s	.ok_mode
.not_pc		
		move.b	(AtaSpd.w,pc,d0.w*2),d0
.ok_mode		
		lea	AtaRdOff(pc),a4
		add.w	(a4,d0.w*2),a4

		moveq	#AtaReadSectors,d5
		
		; D5=commande ide
		; A4=m‚thode transfert
		
		bsr	IDE_IO
		
		tst.l	d0
		beq.s	.Out
.bug		
		moveq	#E_READF,d0
		
		****
.Out		
		movem.l	(sp)+,d2-d7/a2-a4
		rts
		
		********
		
********************************************************************

		********
		; ECRITURE IDE
		********
PutIde:
		movem.l	d2-d7/a2-a4,-(sp)
		
		****
		
		tst.l	_PS_num(a6)
		bmi.s	.bug
		
		moveq	#0,d7
		moveq	#1,d0
		and.w	_GS_id(a6),d0
		
		tst.b	(AtaSwap.w,pc,d0.w)
		beq.s	.not_pc
.pc_mode
			moveq	#3,d0
			bra.s	.ok_mode
.not_pc		
		move.b	(AtaSpd+1.w,pc,d0.w*2),d0
.ok_mode		
		lea	AtaWrOff(pc),a4
		add.w	(a4,d0.w*2),a4

		moveq	#AtaWriteSectors,d5
		
		; D5=commande ide
		; A4=m‚thode transfert
		
		bsr	IDE_IO
		
		tst.l	d0
		beq.s	.Out
.bug		
		moveq	#E_WRITF,d0
		
		****
.Out		
		movem.l	(sp)+,d2-d7/a2-a4
		rts
		
		********

********************************************************************
		
		********
atapi_cdb:
		ds.w	8
		
		********
		
		; routine g‚n‚rique de transfert IDE
		; (m‚thode adressage point‚e par A3)
		; (m‚thode transfert point‚e par A4)
IDE_IO:		
		****

		bsr	SelectIde
		
		tst.l	d0
		bne	.end
		
		****
		
		; ici on a A2 qui pointe sur les inquiry data
		; on peut donc determiner s'il s'agit d'un ATAPI
		
		tst.w	edt_ata_word0(a2)
		bpl.s	.ata_mode
.atapi_mode
		; construire packet scsi
		
		lea	atapi_cdb(pc),a1
		
		; read ou write ?
		
		move.w	#$2800,d0
		cmp.w	#AtaWriteSectors,d5
		bne.s	.okopc
		move.w	#$2a00,d0
.okopc
		move.w	d0,(a1)+
		
		move.l	_GS_num(a6),(a1)+
		clr.b	(a1)+
		move.w	_GS_count+2(a6),(a1)+
		clr.b	(a1)+
		clr.w	(a1)+
		
		move.l	_GS_count(a6),d0
		add.l	d0,d0
		lsl.l	#8,d0
		
		pea	atapi_cdb(pc)
		move.l	_GS_addr(a6),-(sp)
		move.l	d0,-(sp)
		
		bsr	atapi_command
		
		lea	12(sp),sp
		
		bra	.end
		
		********
		
		********
.ata_mode		
		move.l	_GS_addr(a6),a1
		move.l	_GS_count(a6),d2
		lsr.l	#8,d2
		beq.s	.hop1
.hopla1
		AtaWaitReady #200,.error
		
		jsr	(a3)
		
		move.w	#256,d3
		
		clr.b	IdeSectorCount
		nop
		move.b	d5,IdeCommand
		nop
.hopla2		
		AtaWaitDRQ #8*200,.error
		
		jsr	(a4)
		
		subq.w	#1,d3
		bgt.s	.hopla2
		
		add.l	#256,_GS_num(a6)
		subq.w	#1,d2
		bgt.s	.hopla1
		
		********
.hop1
		move.l	_GS_count(a6),d2
		and.l	#$ff,d2
		beq.s	.eok
		
		AtaWaitReady #200,.error
		
		jsr	(a3)
		
		move.b	d2,IdeSectorCount
		nop
		move.b	d5,IdeCommand
		nop
.hopla3
		AtaWaitDRQ #8*200,.error
		
		jsr	(a4)
		
		subq.w	#1,d2
		bgt.s	.hopla3
		
		****
.eok
		; flusher IRQ ide en ‚criture
		
		cmp.w	#AtaWriteSectors,d5
		bne.s	.okint
.wint		
		btst.b	#5,$fffffa01.w
		bne.s	.wint
.okint		
		AtaWaitReady #100,.error
		
		move.b	IdeStatus,d0
		btst	#0,d0
		bne.s	.error
		
		moveq	#E_OK,d0
.end		
		rts
		
		********
		********
.error		
		*move.l	#$ff000000,$ffff9800.w
		*illegal
		*move.b	IdeStatus,d0
		*move.b	IdeError,d1
		
		clr.b	IdeSectorCount
		clr.b	IdeSectorNumber
		clr.b	IdeCylinderLow
		clr.b	IdeCylinderHigh
		
		and.b	#%10110000,IdeDriveHead	* chs , head 0
.wackerr
		btst.b	#7,IdeStatus
		bne.s	.wackerr
		
		move.b	#$70,IdeCommand	* seek (mandatory command)
		nop
.ackerr
		cmp.b	#$50,IdeStatus
		bne.s	.ackerr
		
		
		moveq	#E_ERR,d0		"generic error"
		bra.s	.end
		
		********

********************************************************************
		
		********
		
		; s‚lection du bon drive
SelectIde:
		move.w	_GS_id(a6),d4
		move.w	d4,d3
		lsl.w	#7,d3
		lea	(EquipmentData.w,pc,d3.w),a2
		
		tst.l	(a2)
		bne.s	.OkDev
		
			moveq	#E_UNDEV,d0	'unknown device'
			rts
.OkDev		
		and.b	#%00000001,d4	DRV
		lsl.b	#4,d4
		
		****
		
		; s‚lection du mode d'adressage
		; soit auto ,soit chs,soit lba
		
		moveq	#1,d0
		and.w	_GS_id(a6),d0
		move.b	(AtaAdrMode.w,pc,d0.w),d0
		beq.s	.adr_auto
		
		subq.b	#1,d0
		beq.s	.adr_chs
		bra.s	.adr_lba
.adr_auto		
		btst.b	#1,98(a2)
		bne.s	.adr_lba
.adr_chs
		or.b	#%10100000,d4
		lea	SetAddrCHS(pc),a3
		bra.s	.ok_adr
.adr_lba		
		or.b	#%11100000,d4	+LBA
		lea	SetAddrLBA(pc),a3
.ok_adr		
		****
		
		AtaWaitFree #200,.Busy
		
		move.b	d4,IdeDriveHead
		nop
		nop
		
		****
.Ok		
		moveq	#E_OK,d0
		rts
.Busy
		moveq	#E_DRVNR,d0	'drive not ready'
		rts
		
		********

********************************************************************

		********
		
		; m‚thode d'adressage 'Cylinder/Head/Sector'
SetAddrCHS
		move.l	_GS_num(a6),d0
		moveq	#0,d1
		
		move.w	edt_ata_word6(a2),d1
		divul.l	d1,d1:d0
		addq.w	#1,d1
		
		move.b	d1,IdeSectorNumber
		
		move.w	edt_ata_word3(a2),d1
		divul.l	d1,d1:d0
		
		move.b	d0,IdeCylinderLow
		
		lsr.l	#8,d0
		move.b	d0,IdeCylinderHigh
		
		or.b	d4,d1
		move.b	d1,IdeDriveHead
		
		rts
		
		********
		
		; m‚thode d'adressage 'Logical Bloc Address'
SetAddrLBA
		move.l	_GS_num(a6),d0
		
		move.b	d0,IdeSectorNumber
		
		lsr.l	#8,d0
		move.b	d0,IdeCylinderLow
		
		lsr.l	#8,d0
		move.b	d0,IdeCylinderHigh
		
		lsr.l	#8,d0
		or.b	d4,d0
		move.b	d0,IdeDriveHead
		
		rts
		
		********

********************************************************************

		********
		
		; table d'offsets pour indexation
		; selon le num‚ro de vitesse r‚gl‚.
		
AtaRdOff:
		dc.w	IdeRead_1-AtaRdOff
		dc.w	IdeRead_2-AtaRdOff
		dc.w	IdeRead_3-AtaRdOff
		dc.w	IdeRead_PC-AtaRdOff
		
		
		; table d'offsets pour indexation
		; selon le num‚ro de vitesse r‚gl‚.
		
AtaWrOff:
		dc.w	IdeWrite_1-AtaWrOff
		dc.w	IdeWrite_2-AtaWrOff
		dc.w	IdeWrite_3-AtaWrOff
		dc.w	IdeWrite_PC-AtaWrOff
		
		********

		; routines de transfert IDE
		; dans le sens LECTURE (512 bytes)
		; (pointeur RAM en A1)

		; vitesse minimale (haute s‚curit‚)
IdeRead_1:
		move.w	#(256)-1,d0
		lea	IdeData,a0
.yip		
		move.w	(a0),(a1)+
		dbf	d0,.yip
		
		rts
		
		********
		
		; vitesse moyenne (s‚curit‚ normale)
IdeRead_2:
		move.w	#(512/4)-1,d0
		lea	IdeData,a0
.yir		
		move.l	(a0),(a1)+
		dbf	d0,.yir
		
		rts
		
		********

		; haute vitesse (s‚curit‚ r‚duite)
IdeRead_3:
		lea	IdeData,a0
		moveq	#(512/32)-1,d0
.yo
		rept	8
		move.l	(a0),(a1)+
		endr
		
		dbf	d0,.yo
		
		rts

		********
		
		; mode swapp‚ PC
IdeRead_PC:
		lea	IdeData,a0
		move.w	#256-1,d0
.yo
		move.w	(a0),d1
		ror.w	#8,d1
		move.w	d1,(a1)+
		
		dbf	d0,.yo
		
		rts

		********
		********
		
		; routines de transfert IDE
		; dans le sens ECRITURE (512 bytes)
		; (pointeur RAM en A1)

		; vitesse minimale (haute s‚curit‚)
IdeWrite_1:
		move.w	#(256)-1,d0
		lea	IdeData,a0
.yip		
		move.w	(a1)+,(a0)
		dbf	d0,.yip
		
		rts
		
		********
		
		; vitesse moyenne (s‚curit‚ normale)
IdeWrite_2:
		move.w	#(512/4)-1,d0
		lea	IdeData,a0
.yir		
		move.l	(a1)+,(a0)
		dbf	d0,.yir
		
		rts
		
		********

		; haute vitesse (s‚curit‚ r‚duite)
IdeWrite_3
		lea	IdeData,a0
		moveq	#(512/32)-1,d0
.yip
		rept	8
		move.l	(a1)+,(a0)
		endr
		
		dbf	d0,.yip
		
		rts

		********
		
		; mode intel
IdeWrite_PC
		lea	IdeData,a0
		move.w	#256-1,d0
.yo
		move.w	(a1)+,d1
		ror.w	#8,d1
		move.w	d1,(a0)
		
		dbf	d0,.yo
		
		rts

		********
		
********************************************************************

		********
		
		rsset	4
_api_count	rs.l	1
_api_addr		rs.l	1
_api_cdb		rs.l	1

		****
atapi_command:
		AtaWaitReady #100,.ertapi
		
		clr.b	IdeSectorCount
		move.b	#$02,IdeCylinderHigh
		move.b	#$00,IdeCylinderLow
		
		; envoyer packet
.retrapi		
		move.b	#$A0,IdeCommand	; ata packet command
		
		AtaWaitDRQ #100,.ertapi
		
		moveq	#6-1,d0
		lea	IdeData,a0
		move.l	_api_cdb(sp),a1
		
		lea	.api_in(pc),a3
		cmp.b	#$28,(a1)
		beq.s	.spk
		lea	.api_out(pc),a3
.spk		
		move.w	(a1)+,d1
		ror.w	#8,d1
		move.w	d1,(a0)
		
		dbf	d0,.spk
		
		; s'il y a deja 'check-condition'
		; la commande avait un mauvais paramŠtre,
		; ou le device … ‚t‚ reset‚ en cours de route.
		
		btst.b	#0,IdeStatus
		bne.s	.retrapi
		
			*bsr	check
		****
.okcmd		
		; transfert des data (ATTN:byte-swap)
		
		move.l	_api_addr(sp),a1
		move.l	_api_count(sp),d3
.yotapi		
		AtaWaitDRQ #100,.ertapi
		
		lea	IdeData,a0
		
		moveq	#0,d0
		move.b	IdeCylinderHigh,d0
		lsl.w	#8,d0
		move.b	IdeCylinderLow,d0
		
		sub.l	d0,d3
		
		addq.w	#1,d0
		lsr.w	#1,d0
		
		jsr	(a3)
		
		tst.l	d3
		bgt.s	.yotapi
		
		****
.oktapi		
		btst.b	#0,IdeStatus	; check condition ??
		bne.s	.ertapi
		
		AtaWaitReady #2*200,.ertapi
		
		moveq	#E_OK,d0
		rts
		
		****
.ertapi		
		tst.b	IdeStatus
		tst.b	IdeError
		bra	.retrapi
		
		********
		********
.api_in
		move.w	(a0),d1
		ror.w	#8,d1
		move.w	d1,(a1)+
		
		subq.w	#1,d0
		bgt.s	.api_in
		rts

		********
.api_out
		move.w	(a1)+,d1
		ror.w	#8,d1
		move.w	d1,(a0)
		
		subq.w	#1,d0
		bgt.s	.api_out
		rts

		********
		********

********************************************************************
