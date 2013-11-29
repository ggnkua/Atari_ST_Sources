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
		
		; device SCSI
		
		****
		
		; codes erreurs
		; -1 selection impossible
		; -2 erreur envoi commande
		; -3 erreur transfert donn‚es
		; -4 erreur r‚cup status
		; -5 check condition
		
		****
_sds_scsi		
		; s‚lection du device
		
		subq.w	#8,d0
		
		move.w	d0,-(sp)
		bsr	ScSelect
		
		tst.l	d0
		beq.s	.oksel
		
			moveq	#-1,d0	; selection impossible
			rts
.oksel		
		; envoi du bloc de commande
		
		move.l	_sds_cdb(a6),a1
		
		move.w	(a1),d0
		lsr.w	#8,d0
		lsr.w	#4,d0
		
		move.w	(_sds_cdblen.w,pc,d0.w*2),d0
		
		move.l	a1,-(sp)
		move.w	d0,-(sp)
		bsr	ScCmd
		
		tst.l	d0
		beq.s	.okcmd
		
			moveq	#-2,d0	; erreur envoi commande
			rts
.okcmd		
		; si buffer=0 et/ou size=0
		; alors pas de tranfert de donn‚es
		
		move.l	_sds_buff(a6),d0
		beq.s	.s_noxfr
		move.l	d0,a1
		
		move.l	_sds_size(a6),d0
		beq.s	.s_noxfr
		
		; si size<0 les donn‚es sortent (‚criture)
		; si size>0 les donn‚es rentrent (lecture)
		
		bmi.s	.s_write
.s_read		
		move.l	d0,-(sp)
		move.l	a1,-(sp)
		bsr	ScReadDMA
		
		bra.s	.s_noxfr
.s_write		
		neg.l	d0
		move.l	d0,-(sp)
		move.l	a1,-(sp)
		bsr	ScWriteDMA
.s_noxfr		
		tst.l	d0
		beq	.okxfr
		
			cmp.w	#CBSR_CD+CBSR_IO,d0	; phase status_in ?
			beq.s	.okxfr
			
			moveq	#-3,d0	; grosse erreur transfert donn‚es
			rts
.okxfr		
		; determination du time_out court/long
		
		moveq	#1,d0
		and.w	_sds_flags(a6),d0
		
		moveq	#18,d1
		lsl.l	d1,d0
		add.l	#1000,d0
		
		pea	.status(pc)
		pea	.msg(pc)
		move.l	d0,-(sp)
		bsr	ScComplete
		
		tst.l	d0
		beq	.oksta
		
			moveq	#-4,d0	; erreur r‚cup status
			rts
.oksta		
		tst.b	.status(pc)
		beq.s	.eok
		
			moveq	#-5,d0	; check condition
			rts
.eok		
		moveq	#E_OK,d0
		rts

		****
		DATA
		****
		
.status		dc.b	$00		
.msg		dc.b	$00		
		
		****
		
		; mesure de la longueur r‚elle du CDB
		; groupe  $0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$a,$b,$c,$d,$e,$f
		
_sds_cdblen	dc.w	$6,$6,$a,$a,$a,$a,$0,$0,$0,$0,$c,$c,$c,$c,$0,$0

		****

****************************************************************
