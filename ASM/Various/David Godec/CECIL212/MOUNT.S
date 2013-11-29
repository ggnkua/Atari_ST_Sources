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
		
		; sous routine de montage
		
		; paramŠtres:
		; word: logical device id
		; word: physical device id
		
		; retourne en d0 le logical id du drive
		; suivant le dernier du physical drive.
		
		
		rsset	8
_mo_phys		rs.w	1
_mo_log		rs.w	1
		
		****
MOUNT:		
		link	a5,#-48
		movem.l	d1-a4,-(sp)
		
		moveq	#0,d2
		moveq	#1,d3
		
		move.l	$516.w,a4
		move.w	_mo_log(a5),d4
		move.w	_mo_phys(a5),d5
		
		cmp.w	#MAXUNIT,d4
		bgt	.stop
		
		; v‚rifier coh‚rence phys/log
		; si non initialis‚ nous sommes au boot
		; sinon il s'agit de re-montage.
		
		move.b	(a4,pinfo_pun.w,d4.w),d0
		bmi.s	.new
		cmp.b	d0,d5
		bne	.stop
		
		; s'il s'agit de re-montage il faut reculer
		; jusqu'… la premiŠre occurence du drive physique
		; (sans d‚passer le 0 oeuf corse)
.scaf		
		cmp.b	(a4,pinfo_pun-1.w,d4.w),d5
		bne.s	.new
		subq.w	#1,d4
		bgt.s	.scaf
.new		
		****
		
		; lecture du Root (secteur physique zero)
		
		move.w	d5,-(sp)
		move.l	d2,-(sp)
		move.l	d3,-(sp)
		pea	SectorBuffer(pc)
		bsr	GetSector
		lea	14(sp),sp
		
		; tant que l'erreur est de type 'e_chng'
		; nous devons persister,car c'est l'erreur
		; classique renvoy‚e au boot...
		
		moveq	#E_CHNG,d1
		cmp.l	d1,d0
		beq.s	.new
		
		; s'il ya eu une autre erreur le drive n'est
		; peut-etre pas format‚ ou defectueux ...
		
		tst.l	d0
		bne	.stop
		
		****
		
		; voyons s'il s'agit d'un root
		; de disque type msdos ou gemdos ...
		
		lea	SectorBuffer(pc),a0
		cmp.w	#$55AA,510(a0)
		beq.s	.msdos
		cmp.w	#$AA55,510(a0)
		bne	.gemdos
.msdos_ata
		; ici cas de root pc sur port swapp‚
		; on va marquer le device en swapp‚
		; et relire le root afin de retomber
		; dans le cas PC g‚n‚rique.
		
		moveq	#1,d0
		and.w	d5,d0
		
		lea	(AtaSwap.w,pc,d0.w),a0
		st	(a0)
		
		bra	.new
		
		********
		
		; cas de partitions type PC/MSDOS
.msdos
		lea	SectorBuffer+$1BE(pc),a0
		lea	$40(a0),a1
		
		moveq	#0,d2
		moveq	#0,d3
.pri		
		; lecture de la primary partition
		; gestion des types :
		; $04 primary dos < 32 MB
		; $06 primary dos > 32 MB
		; $05 extended dos
		; $0B primary FAT32
		
		moveq	#0,d0
		move.b	$04(a0),d0
		
		cmp.b	#$04,d0
		beq.s	.ok_ms
		cmp.b	#$06,d0
		beq.s	.ok_ms
		cmp.b	#$0B,d0
		beq.s	.ok_ms
		
		; si aucun type connu,testons les suivantes...
		
		lea	$10(a0),a0
		cmp.l	a1,a0
		blt.s	.pri
		bra	.stop
.ok_ms		
		move.l	d0,(a4,pinfo_ptype.w,d4.w*4)
		move.b	d5,(a4,pinfo_pun.w,d4.w)
		
		move.l	$08(a0),d0
		ror.w	#8,d0
		swap	d0
		ror.w	#8,d0
		add.l	d2,d0
		move.l	d0,(a4,pinfo_pstart.w,d4.w*4)
		
		move.l	$0C(a0),d0
		ror.w	#8,d0
		swap	d0
		ror.w	#8,d0
		move.l	d0,(a4,pinfo_psize.w,d4.w*4)
		
		addq.w	#1,d4
		cmp.w	#MAXUNIT,d4
		bgt	.stop
		
		; ici cas extended dos partition(s)
		
		cmp.b	#$05,$10+$04(a0)
		bne	.stop
		
		; le champ 'start' indique l'offset
		; du prochain root virtuel ou la base
		; s'il s'agit de la premiŠre.
		
		move.l	$10+$08(a0),d2
		ror.w	#8,d2
		swap	d2
		ror.w	#8,d2
		
		tst.l	d3
		bne.s	.basok
		move.l	d2,d3
		bra.s	.offok
.basok		
		add.l	d3,d2
.offok		
		move.w	d5,-(sp)
		move.l	d2,-(sp)
		pea	1.w
		pea	SectorBuffer(pc)
		bsr	GetSector
		lea	14(sp),sp
		
		lea	SectorBuffer(pc),a0
		lea	$40(a0),a1
		bra	.pri
		
		********
		
		; cas de partitions au format atari/gemdos
.gemdos		
		; copie des 4 premieres p?_info en local
		
		lea	SectorBuffer+p0_flg(pc),a0
		lea	-48(a5),a1
		moveq	#(4*3)-1,d0
.pcop		
		move.l	(a0)+,(a1)+
		dbf	d0,.pcop
		
		****
		
		; pour le cas de re-montage d'un media,il
		; s'agit de s'arreter lorsque pun est initialis‚
		; et diff‚rent de mo_phys .
		
		; testons les p?_info du root
		
		lea	-48(a5),a0
		moveq	#3,d7
.nxpart		
		cmp.w	#MAXUNIT,d4
		bgt.s	.stop
		
		tst.b	(a4,pinfo_pun.w,d4.w)
		bmi.s	.goon
		
			cmp.b	(a4,pinfo_pun.w,d4.w),d5
			bne.s	.stop
.goon		
		move.l	(a0),d0		; type ?
		rol.l	#8,d0
		
		tst.b	d0
		beq.s	.nxyop
		
		lsr.l	#8,d0
		
		cmp.l	#"XGM",d0
		beq.s	.is_xgm
		bra.s	.not_xgm
		
		; ici la partoche est d‚sactiv‚e donc,
		; on ne la mounte pas ...
.nxyop		
		lea	12(a0),a0
		dbf	d7,.nxpart
		
		****
		
		; fin pour ce drive
.stop		
		moveq	#0,d0
		move.w	d4,d0
.exit		
		movem.l	(sp)+,d1-a4
		unlk	a5
		rts
		
		****
		
		; toutes les partitions memes inconnues
		; sont mount‚es par contre la fonction GETBPB
		; devra reconnaitre strictement les lecteurs DOS.
.not_xgm
		move.l	d0,(a4,pinfo_ptype.w,d4.w*4)
		move.b	d5,(a4,pinfo_pun.w,d4.w)
		move.l	4(a0),(a4,pinfo_pstart.w,d4.w*4)
		move.l	8(a0),(a4,pinfo_psize.w,d4.w*4)
		
		addq.w	#1,d4
		bra.s	.nxyop
		
		****
		
	; le cas de l'xgm est particulier il s'agit
	; en fait d'une liste chain‚e de disques durs
	; virtuels comportant une et une seule partition
	; (gem,bgm,...) ainsi qu'un lien (xgm) sur la
	; structure suivante ...
	; par cons‚quent il n'y a besoin que d'une xgm dans
	; le root sector, le premier lien.
.is_xgm:		
		movem.l	d7/a0,-(sp)
		
		; comme il s'agit d'un drive virtuel,
		; il ya un root sector virtuel...
		
		move.l	4(a0),d2
		move.l	d2,d6
.xgm_next		
		move.w	d5,-(sp)
		move.l	d6,-(sp)
		move.l	d3,-(sp)
		pea	SectorBuffer(pc)
		bsr	GetSector
		lea	14(sp),sp
		
		tst.l	d0
		bne.s	.xgm_exit
		
		****
		
		lea	SectorBuffer+p0_flg(pc),a0
		moveq	#4,d7
.xgm_yop		
		btst.b	#0,(a0)
		bne.s	.xgm_ok
		lea	12(a0),a0
		subq.w	#1,d7
		bgt.s	.xgm_yop
		
		; si on n'a rien trouv‚ bin on mounte rien....
		
		****
.xgm_exit
		movem.l	(sp)+,d7/a0
		bra.s	.nxyop

		****
.xgm_ok
		; voici la vraie partition...
		
		move.l	(a0),d0
		and.l	#$00FFFFFF,d0
		bne.s	.xgem
		bra.s	.xgm_goon
.xgem		
		; mountons la !
		
		move.l	d0,(a4,pinfo_ptype.w,d4.w*4)
		move.b	d5,(a4,pinfo_pun.w,d4.w)
		add.l	4(a0),d6
		move.l	d6,(a4,pinfo_pstart.w,d4.w*4)
		move.l	8(a0),(a4,pinfo_psize.w,d4.w*4)
		
		****
		
		addq.w	#1,d4
		cmp.w	#MAXUNIT,d4
		bgt.s	.xgm_exit
		
		tst.b	(a4,pinfo_pun.w,d4.w)
		bmi.s	.xgm_goon
		
			cmp.b	(a4,pinfo_pun.w,d4.w),d5
			bne.s	.xgm_exit
		****
		
		; y'en a encore ??
.xgm_goon
		lea	12(a0),a0
		subq.w	#1,d7
		beq.s	.xgm_exit
.xgm_nx		
		btst.b	#0,(a0)
		bne.s	.xgm_okk
		lea	12(a0),a0
		subq.w	#1,d7
		bgt.s	.xgm_nx
		bra.s	.xgm_exit
		
		****
		
		; oui il semblerait...
.xgm_okk
		move.l	(a0),d0
		lsl.l	#8,d0
		cmp.l	#"XGM"<<8,d0
		bne.s	.xgm_exit
		
		move.l	d2,d6
		add.l	4(a0),d6
		bra	.xgm_next
		
		********
		********
		