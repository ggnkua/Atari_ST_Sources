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
		
_OLD_RWABS	dc.l	0		
		
		********
		
		rsset	8
rw_flags		rs.w	1
rw_buff		rs.l	1
rw_recnr		rs.w	1
rw_recno		rs.w	1
rw_dev		rs.w	1
rw_lrecno		rs.l	1

		********
_BIOS_RWABS:
		cmp.w	#1,rw_dev-4(sp)
		bgt.s	.NoFloppy
		
		jmp	([_OLD_RWABS.w,pc])
		
		********
.NoFloppy		
		link	a6,#0
		movem.l	d2-d7/a2,-(sp)
		
		****
		
		; routines de lecture/‚criture de device Bios
		
		move.w	rw_flags(a6),d0
		bpl.s	.normal
		
			; mode SDS
			
			move.w	d0,-(sp)		; flags
			move.l	rw_lrecno(a6),-(sp)	; size
			move.l	rw_buff(a6),-(sp)	; buffer
			move.l	rw_recnr(a6),-(sp)	; cdb address
			move.w	rw_dev(a6),-(sp)	; device number
			
			bsr	_SDS
			
			bra	.out
		
		****
.normal		
		btst	#3,d0
		bne.s	.Phys
		
		****
		
		; avec paramŠtres logiques
.Log
		move.l	$516.w,a0
		lea	DevTable(pc),a1
		
		moveq	#0,d1
		move.w	rw_dev(a6),d1
		
		tst.l	pinfo_pstart(a0,d1.l*4)
		bgt.s	.mntok
		
			moveq	#E_UNDEV,d0
			bra	.Out
.mntok		
		move.l	d1,d2
		lsl.l	#5,d2
		
		moveq	#0,d3
		move.w	recsiz(a1,d2.l),d3
		
		lsr.l	#1,d3	; TBC
		lsr.l	#8,d3
		
		moveq	#$1f,d4
		and.b	pinfo_pun(a0,d1.l),d4
		
		moveq	#0,d5
		move.w	rw_recno(a6),d5
		cmp.w	#-1,d5
		bne.s	.okrno1
		move.l	rw_lrecno(a6),d5
.okrno1
		mulu.l	d3,d5
		add.l	pinfo_pstart(a0,d1.l*4),d5
		
		moveq	#0,d6
		move.w	rw_recnr(a6),d6
		mulu.l	d3,d6
		
		move.l	rw_buff(a6),a2
		
		bra.s	.Go_IO
		
		********
		
		; avec paramŠtres physiques
.Phys:
		moveq	#$1f,d4
		and.w	rw_dev(a6),d4
		subq.l	#2,d4
		
		moveq	#0,d5
		move.w	rw_recno(a6),d5
		cmp.w	#-1,d5
		bne.s	.okrno2
		move.l	rw_lrecno(a6),d5
.okrno2
		moveq	#0,d6
		move.w	rw_recnr(a6),d6
		
		move.l	rw_buff(a6),a2
		
		********
		********
.go_io	
		move.w	rw_flags(a6),d0
		btst	#0,d0
		bne	.go_write
		
		********
.go_read
		cmp.l	#$01000000,a2
		blo.s	.r_wo_frb
		cmp.w	#$000F,d4
		bgt.s	.r_wo_frb
		
		****
		
		; proc‚dure de lecture avec _FRB
		; (device DMA vers RAM 32 bits)
		
		move.l	#128,d7		; TBC
.r_w_frb		
		cmp.l	d7,d6
		bgt.s	.okrd6
		move.l	d6,d7
.okrd6
		move.w	d4,-(sp)
		move.l	d5,-(sp)
		move.l	d7,-(sp)
		move.l	_FRB(pc),-(sp)
		bsr	GetSector
		lea	14(sp),sp
		
		bsr	FRB_to_RAM
		
		add.l	d7,d5
		sub.l	d7,d6
		bgt.s	.r_w_frb
		
		bra.s	.Out
		
		****
		
		; proc‚dure de lecture sans _FRB
		; (adresse destination en STRAM)
		; (et/ou device non DMA)
.r_wo_frb		
		move.w	d4,-(sp)
		move.l	d5,-(sp)
		move.l	d6,-(sp)
		move.l	a2,-(sp)
		bsr	GetSector
		lea	14(sp),sp
		
		bra.s	.Out
		
		********
.Go_Write		
		cmp.l	#$01000000,a2
		blo.s	.w_wo_frb
		cmp.w	#$0f,d4
		bgt.s	.w_wo_frb
		
		; proc‚dure d'‚criture avec _FRB
		; ( RAM 32 bits vers device DMA )
		
		moveq	#127,d7
		addq.l	#1,d7
.w_w_frb		
		cmp.l	d7,d6
		bgt.s	.okwd6
		move.l	d6,d7
.okwd6
		
		bsr	RAM_to_FRB
		
		move.w	d4,-(sp)
		move.l	d5,-(sp)
		move.l	d7,-(sp)
		move.l	_FRB(pc),-(sp)
		
		bsr	PutSector
		lea	14(sp),sp
		
		
		add.l	d7,d5
		sub.l	d7,d6
		bgt.s	.w_w_frb
		
		bra.s	.Out
		
		***
		
		; proc‚dure d'‚criture sans _FRB
		; (adresse source en STRAM)
		; (et/ou device non DMA)
.w_wo_frb		
		move.w	d4,-(sp)
		move.l	d5,-(sp)
		move.l	d6,-(sp)
		move.l	a2,-(sp)
		
		bsr	PutSector
		lea	14(sp),sp
		
		********
.Out		
		movem.l	(sp)+,d2-d7/a2
		unlk	a6
		rts
		
		********
		********

********************************************************************

		********
		
		; copie optimis‚e du _FRB en RAM
		; (pointeur RAM en A2)
		; (nombre blocs en D7)
FRB_to_RAM:

		move.l	_FRB(pc),a0
		move.l	d7,d0
		lsl.l	#5,d0
.ftr		
		rept	4
		move.l	(a0)+,(a2)+
		endr
		
		subq.l	#1,d0
		bgt.s	.ftr
		rts

		********
		
		; copie optimis‚e de la RAM en _FRB
		; (pointeur RAM en A2)
		; (nombre blocs en D7)
RAM_to_FRB:
		move.l	_FRB(pc),a0
		move.l	d7,d0
		lsl.l	#5,d0
.rtf		
		rept	4
		move.l	(a2)+,(a0)+
		endr
		
		subq.l	#1,d0
		bgt.s	.rtf
		rts
		
		********

********************************************************************

		********
		
		; routine g‚n‚rale de lecture de
		; secteur(s) physique(s).
		
		; paramŠtres:
		; WORD: device ID (8-15=scsi/16-17=ide)
		; LONG: num‚ro de secteur
		; LONG: nb de secteurs
		; LONG: pointeur destination
		
		********
		TEXT
		********
		
		rsset	8
_GS_addr		rs.l	1
_GS_count		rs.l	1
_GS_num		rs.l	1
_GS_id		rs.w	1

		********
GetSector:
		link	a6,#0
		
		****
		sync	$43e.w
		****
.retry
		move.w	_GS_id(a6),d0
		subq.w	#8,d0
		bmi.s	.bad
		
		lea	_gsJumpTab(pc),a0
		add.w	(a0,d0.w*2),a0
		jsr	(a0)
		
		move.w	_GS_id(a6),d1
		lea	(SleepCounters-16.w,pc,d1.w*2),a0
		move.w	(SleepDelay-16.w,pc,d1.w*2),(a0)
.end		
		****
		
		cmp.l	#E_CHNG,d0
		bne.s	.out
		
			; gestion bas niveau du changement de media
			; il nous faut revalider le nombre et la taille
			; des blocs logiques du support requis...
			
			
			bra.s	.retry
			*illegal
.out		
		****
		sf	$43e.w
		****
		
		unlk	a6
		rts
.bad
		moveq	#E_UNDEV,d0	'unknown device'
		bra.s	.out
		
		********
_gsJumpTab:
		dc.w	GetScsi-_gsJumpTab
		dc.w	GetScsi-_gsJumpTab
		dc.w	GetScsi-_gsJumpTab
		dc.w	GetScsi-_gsJumpTab
		dc.w	GetScsi-_gsJumpTab
		dc.w	GetScsi-_gsJumpTab
		dc.w	GetScsi-_gsJumpTab
		dc.w	GetScsi-_gsJumpTab
		
		dc.w	GetIde-_gsJumpTab
		dc.w	GetIde-_gsJumpTab
		
		********
		TEXT
		********
		
		; routine g‚n‚rale d'‚criture de
		; secteur(s) physique(s).
		
		; paramŠtres:
		; WORD: device ID (8-15=scsi/16-17=ide)
		; LONG: num‚ro de secteur
		; LONG: nb de secteurs (512 bytes)
		; LONG: pointeur source
		
		********
		
		rsset	8
_PS_addr		rs.l	1
_PS_count		rs.l	1
_PS_num		rs.l	1
_PS_id		rs.w	1

		********
PutSector:
		link	a6,#0
		
		****
		sync	$43e.w
		****
.retry		
		move.w	_PS_id(a6),d0
		subq.w	#8,d0
		bmi.s	.bad
		
		lea	_psJumpTab(pc),a0
		add.w	(a0,d0.w*2),a0
		jsr	(a0)
		
		move.w	_PS_id(a6),d1
		lea	(SleepCounters-16.w,pc,d1.w*2),a0
		move.w	(SleepDelay-16.w,pc,d1.w*2),(a0)
.end		
		cmp.l	#E_CHNG,d0
		beq.s	.retry
.out		
		****
		sf	$43e.w
		****
		
		unlk	a6
		rts
.bad
		moveq	#E_UNDEV,d0	'unknown device'
		bra.s	.out

		********
_psJumpTab:
		dc.w	PutScsi-_psJumpTab
		dc.w	PutScsi-_psJumpTab
		dc.w	PutScsi-_psJumpTab
		dc.w	PutScsi-_psJumpTab
		dc.w	PutScsi-_psJumpTab
		dc.w	PutScsi-_psJumpTab
		dc.w	PutScsi-_psJumpTab
		dc.w	PutScsi-_psJumpTab
		
		dc.w	PutIde-_psJumpTab
		dc.w	PutIde-_psJumpTab
		
		********
		********

********************************************************************
