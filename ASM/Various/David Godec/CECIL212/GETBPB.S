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
		
_OLD_GETBPB	dc.l	0
		
		****
_BIOS_GETBPB:
		cmp.w	#1,4(sp)
		bgt.s	.NoFloppy
		
		jmp	([_OLD_GETBPB.w,pc])
		
		****
.NoFloppy		
		link	a6,#0
		movem.l	d2-d5/a2-a4,-(sp)
		
		****
		
		lea	pun_info(pc),a4
		lea	SectorBuffer(pc),a3
		
		move.w	8(a6),d2
		moveq	#0,d3
		move.b	pinfo_pun(a4,d2.w),d3
		bmi	.not_exist
		
		****
		
		; lecture du root,au cas ou le
		; format du medium a chang‚ ...
		
		moveq	#1,d5
.root_retry
		move.w	d3,-(sp)
		clr.l	-(sp)
		pea	1.w
		pea	(a3)
		bsr	GetSector
		lea	14(sp),sp
		
		tst.l	d0
		beq.s	.root_ok
		
		** etv_critic **
		
		movem.l	d2-d3/a2-a4,-(sp)
		
		move.w	8(a6),-(sp)
		move.w	8(a6),-(sp)
		move.w	d0,-(sp)
		
		jsr	([$404.w])
		
		lea	6(sp),sp
		movem.l	(sp)+,d2-d3/a2-a4
		
		dbf	d5,.root_retry
		bra	.not_exist
.root_ok		
		****
		
		; (re)lecture du partitionnement
		
		move.w	d2,-(sp)
		move.w	d3,-(sp)
		
		bsr	MOUNT
		
		addq.w	#4,sp
		
		move.l	d0,d4
		bmi	.not_exist
		
		****
		
		; aprŠs re-mount on recoit
		; d4=index suivant le dernier lecteur mount‚
		; il faut donc remplir avec 0xffffffff,jusqu'…
		; la limite pour ce device afin d'empecher
		; les accŠs aux partitions qui n'existent plus...
.fil		
		cmp.b	(a4,pinfo_pun.w,d4.w),d3
		bne.s	.okfil
		move.l	#$ffffffff,(a4,pinfo_pstart.w,d4.w*4)
		addq.w	#1,d4
		bra.s	.fil
.okfil		
		****
		
		; le lecteur demand‚ existe ?
		
		tst.l	pinfo_pstart(a4,d2.w*4)
		bmi	.not_exist
		
		; chargeons son boot-sector...
		
		move.w	d3,-(sp)
		move.l	pinfo_pstart(a4,d2.w*4),-(sp)
		pea	1.w
		pea	(a3)
		bsr	GetSector
		lea	14(sp),sp
		
		tst.l	d0
		bne	.not_exist
		
		; adresse du bloc xbpb
		
		move.w	8(a6),d0
		lsl.w	#5,d0
		lea	(DevTable.w,pc,d0.w),a2
		
		****
		
		; ATTN:
		; -----
		; types support‚s sous TOS
		; DOS 0x04, DOS 0x06
		; GEM,BGM
		
		move.l	pinfo_ptype(a4,d2.w*4),d0
		
		cmp.l	#$00000004,d0
		beq	.oktos
		cmp.l	#$00000006,d0
		beq	.oktos
		cmp.l	#"GEM",d0
		beq	.oktos
		cmp.l	#"BGM",d0
		beq	.oktos
		
		; support FAT32 ( dos 0x0B )
		
		cmp.l	#$0000000B,d0
		beq.s	.fat32
		
		moveq	#0,d0
		bra	.end
		
		****
		****
		
		; ici gestion du cas FAT32
.fat32
		moveq	#0,d0
		
		; v‚rifions la signature fat32...
		
		cmpi.l	#"FAT3",$52(a3)
		bne	.end
		cmpi.l	#"2   ",$56(a3)
		bne	.end
		
		; octets/secteur
		
		move.w	_b_bps(a3),d0
		ror.w	#8,d0
		move.w	d0,recsiz(a2)
		
		; secteurs/cluster
		
		moveq	#0,d1
		move.b	_b_spc(a3),d1
		move.w	d1,clsiz(a2)
		
		; octets/cluster
		
		mulu.w	d0,d1
		move.w	d1,clsizb(a2)
		
		; secteurs/fat
		
		move.l	_b_lnfat(a3),d0
		ror.w	#8,d0
		swap	d0
		ror.w	#8,d0
		
		move.w	d0,fsiz(a2)
		
		; secteurs reserv‚s
		
		moveq	#0,d1
		move.w	_b_res(a3),d1
		ror.w	#8,d1
		add.l	d0,d1
		move.w	d1,fatrec(a2)	debut fat#2
		
		add.l	d0,d1
		move.w	d1,datrec(a2)	1e secteur data
		
		; trouver nombre total de clusters
		
		move.l	_b_lnsect(a3),d0
		ror.w	#8,d0
		swap	d0
		ror.w	#8,d0
		sub.l	d1,d0
		
		lsr.l	#3,d0		; attention 8 pour test !!!!
		move.l	d0,xb_cnum(a2)
		
		; marquer un xbpb de fat32
		
		move.w	#2,bflags(a2)
		move.b	#$02,xb_type(a2)
		
		; rendre ce bpb inutilisable par le tos
		; (0 root directory et 0 clusters)
		
		clr.w	rdlen(a2)
		clr.w	numcl(a2)
		
		move.l	a2,d0
		bra	.end
		
		****
		****
		
		; ici gestion des cas normaux (FAT12/15/16)
.oktos		
		moveq	#0,d0
		move.w	_b_bps(a3),d0
		ror.w	#8,d0
		move.w	d0,recsiz(a2)	octets/secteur
		
		moveq	#0,d1
		move.b	_b_spc(a3),d1
		move.w	d1,clsiz(a2)	secteurs/cluster
		
		mulu.w	d0,d1
		move.w	d1,clsizb(a2)	octets/cluster
		
		move.w	_b_spf(a3),d1	secteurs/fat
		ror.w	#8,d1
		move.w	d1,fsiz(a2)
		
		moveq	#0,d1
		move.w	_b_ndirs(a3),d1
		ror.w	#8,d1
		lsl.l	#5,d1
		add.l	d0,d1
		subq.l	#1,d1
		divu.w	d0,d1
		move.w	d1,rdlen(a2)	secteurs/rootdir
		
		moveq	#0,d1
		move.w	_b_res(a3),d1
		ror.w	#8,d1
		add.w	fsiz(a2),d1
		move.w	d1,fatrec(a2)	debut 2e fat
		
		add.w	fsiz(a2),d1
		add.w	rdlen(a2),d1
		move.w	d1,datrec(a2)	1e secteur data
		
		; nombre total de secteurs logiques
		
		moveq	#0,d0
		move.w	_b_nsects(a3),d0
		ror.w	#8,d0
		bne.s	.oknsect
		
		; ATTN: si le nombre est nul nous avons
		; affaire … une grosse partition PC et le
		; nombre se trouve en LONG … un nouvel endroit.
		
		move.l	_b_lnsect(a3),d0
		ror.w	#8,d0
		swap	d0
		ror.w	#8,d0
.oknsect		
		; soustraire les secteurs d‚ja occup‚s
		
		sub.l	d1,d0
		bclr	#0,d0	; mieux si pair
		
		; diviser par le nombre de secteurs/cluster
		
		divu.w	clsiz(a2),d0
		moveq	#0,d1
		move.w	d0,d1
		
		; en enlever un au cas ou qq'un d‚borde
		
		subq.l	#1,d1
		
		; et on trouve le total de clusters DATA
		
		move.w	d1,numcl(a2)
		move.l	d1,xb_cnum(a2)	extended
		
		move.w	8(a6),d0
		beq.s	.flop
		subq.w	#1,d0
		beq.s	.flop
		
		move.w	#1,bflags(a2)	fats 16 bits
		move.b	#$01,xb_type(a2)
		bra.s	.ok
.flop
		clr.w	bflags(a2)	fats 12 bits
		move.b	#$00,xb_type(a2)
.ok		
		; validation du drive dans drvmap
		
		move.l	$4c2.w,d0
		move.w	8(a6),d1
		bset	d1,d0
		move.l	d0,$4c2.w
		
		
		move.l	a2,d0
		
		****
.end		
		movem.l	(sp)+,d2-d5/a2-a4
		unlk	a6
		rts
		
		****
.not_exist		
		; d‚-validation du drive dans drvmap
		
		move.l	$4c2.w,d0
		move.w	8(a6),d1
		bclr	d1,d0
		move.l	d0,$4c2.w
		
		moveq	#0,d0
		bra.s	.end
		
		********

********************************************************************
		