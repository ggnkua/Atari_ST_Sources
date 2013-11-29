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
		
		; device ATAPI
		
		; codes erreurs
		; -1 selection impossible
		; -2 erreur envoi commande
		; -3 erreur transfert donn‚es
		; -5 check condition
		
		****
_sds_atapi		
		; avec l'ata(pi) pas besoin de s‚lecter
		; il suffit de v‚rifier si le device a ‚t‚ d‚tect‚
		
		move.w	d0,d2
		lsl.w	#7,d2
		lea	(EquipmentData.w,pc,d2.w),a1
		
		tst.l	(a1)
		bne.s	.exist
		
			moveq	#E_UNDEV,d0
			rts
.exist		
		; si device atapi, rien de compliqu‚...
		; par contre,si c'est un vieil ide,
		; il va falloir recourir … l'‚mulateur...
		
		tst.w	edt_ata_word0(a1)
		bpl	_sds_emulata
		
		****
		
		AtaWaitFree #200,.exit
		
		and.w	#1,d0
		lsl.w	#4,d0
		or.b	#%10100000,d0
		
		move.b	d0,IdeDriveHead
		nop
		nop
		
		clr.b	IdeFeatures
		move.b	#$10,IdeCylinderHigh
		move.b	#$00,IdeCylinderLow
		
		AtaWaitReady #200,.ertapi
		
		****
		
		; envoyer packet de commande
.retrapi		
		move.b	#$A0,IdeCommand
		nop
		
		AtaWaitDRQ #100,.ertapi
		
		moveq	#6-1,d0
		lea	IdeData,a0
		
		move.l	_sds_cdb(a6),a1
.spk		
		move.w	(a1)+,d1
		ror.w	#8,d1
		move.w	d1,(a0)
		
		dbf	d0,.spk
		
		****
		
		AtaWaitFree #1600,.ertapi
		
		****
		
		; data … transf‚rer ?
		
		move.l	_sds_buff(a6),d0
		beq.s	.oktapi		; buff=0 pas de transfert
		move.l	d0,a1
		
		move.l	_sds_size(a6),d3
		beq.s	.oktapi		; size=0 pas de transfert
		bpl.s	.oksiz
		neg.l	d3
		
		****
		
		; import ou export ?
.oksiz
		lea	.api_in(pc),a3
		
		tst.l	_sds_size(a6)
		bpl.s	.okio
		
		lea	.api_out(pc),a3
		
		****
.okio		
		; s'il y a deja 'check-condition'
		; la commande avait un mauvais paramŠtre,
		; ou le device … ‚t‚ reset‚ en cours de route.
		
		btst.b	#0,IdeStatus
		bne.s	.ertapi
.yotapi		
		AtaWaitDRQ #1600,.ertapi
		
		lea	IdeData,a0
		
		moveq	#0,d0
		move.b	IdeCylinderHigh,d0
		lsl.w	#8,d0
		move.b	IdeCylinderLow,d0
		
		sub.l	d0,d3
		
		addq.l	#3,d0
		lsr.l	#2,d0
		
		jsr	(a3)
		
		tst.l	d3
		bgt.s	.yotapi
		
		****
.oktapi		
		btst.b	#0,IdeStatus	; check condition ??
		bne.s	.ertapi
		
		AtaWaitReady #100,.ertapi
		
		moveq	#E_OK,d0
.exit		
		rts
		
		****
.ertapi		
		moveq	#0,d0
		move.b	IdeStatus,d0
		lsl.w	#8,d0
		move.b	IdeError,d0
		
		neg.l	d0
		bra	.exit
		
		****

****************************************************************
		
		****
.api_in
		move.w	(a0),d1
		ror.w	#8,d1
		swap	d1
		
		move.w	(a0),d1
		ror.w	#8,d1
		swap	d1
		
		move.l	d1,(a1)+
		
		dbf	d0,.api_in
		
		rts

		****
.api_out
		move.w	(a1)+,d1
		ror.w	#8,d1
		move.w	d1,(a0)
		
		move.w	(a1)+,d1
		ror.w	#8,d1
		move.w	d1,(a0)
		
		dbf	d0,.api_out
		
		rts
		
		****

****************************************************************

		****
_sds_emulata:
		; dispatch suivant opcode scsi
		
		move.l	_sds_cdb(a6),a0
		move.b	(a0),d0
		
		cmp.b	#$28,d0
		beq	.ata_read_10
		
		cmp.b	#$2a,d0
		beq	.ata_write_10
		
		cmp.b	#$03,d0
		beq	.ata_req_sense
		
		cmp.b	#$00,d0
		beq	.ata_test_unit

		cmp.b	#$12,d0
		beq	.ata_inquire
		
		; si commande non reconnue,
		; positionner sense … 20:00
		
		move.w	#$2000,edt_ata_sense+$C(a1)	; invalid opcode
		
		****
		****
.error		
		move.w	#$7000,edt_ata_sense+$0(a1)
		
		moveq	#-5,d0	; check condition
		bra	.exit
		
		****
		****
		
		; ‚muler cette commande est trŠs simple
		; car un device ATA est assez rustique...
.ata_test_unit
		; le device est toujours en status good
		; sauf si une commande … positionn‚ une
		; erreur dans le bloc de sense data
		
		tst.w	edt_ata_sense(a1)
		beq	.eok
		
		moveq	#-5,d0
		bra	.exit
		
		****
		****
		
		; va lire simplement le contenu
		; du bloc de sense data
.ata_req_sense		
		; maximum=14 octets
		
		moveq	#0,d0
		move.b	4(a0),d0
		beq	.eok
		
		cmp.w	#14,d0
		bgt.s	.ata_rqs_err
		
		lea	edt_ata_sense(a1),a2
		move.l	_sds_buff(a6),a0
.ata_rqs_ret
		move.b	(a2)+,(a0)+
		subq.w	#1,d0
		bgt.s	.ata_rqs_ret
		
		bra	.eok
.ata_rqs_err		
		move.w	#$2400,edt_ata_sense+$C(a1)	; invalid field in cdb
		bra	.error
		
		****
		****
		
		; ‚mulation de la commande 'inquire'
.ata_inquire	
		lea	SectorBuffer(pc),a2
		
		move.b	edt_devtype(a1),(a2)+
		move.b	edt_flags(a1),(a2)+
		
		clr.l	(a2)+
		clr.w	(a2)+
		
		lea	edt_name(a1),a3
		moveq	#24-1,d0
.inq_nam		
		move.b	(a3)+,(a2)+
		dbf	d0,.inq_nam
		
		; on remplit le reste avec des z‚ro
		
		moveq	#32-1,d0
.inq_pad
		clr.w	(a2)+
		dbf	d0,.inq_pad
		
		; attention il ne faut renvoyer
		; que la quantit‚ de donn‚es demand‚e
		
		lea	SectorBuffer(pc),a2
		move.l	_sds_buff(a6),a3
		
		moveq	#0,d0
		move.b	4(a0),d0
.inq_ret		
		move.b	(a2)+,(a3)+
		subq.w	#1,d0
		bgt.s	.inq_ret
		
		moveq	#E_OK,d0
		bra	.exit
		
		****
		****
		
		; la lecture
.ata_read_10
		bra	.eok
		
		****
		****
		
		; l'‚criture
.ata_write_10
		bra	.eok
		
		****
		****
.eok		
		clr.w	edt_ata_sense+$0(a1)
		clr.w	edt_ata_sense+$C(a1)
		
		moveq	#E_OK,d0
.exit		
		rts
		
		****

****************************************************************
