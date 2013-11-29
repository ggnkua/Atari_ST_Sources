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

		OPT O+,OW-,X-
		
		OUTPUT	C:\CECILE.SYS
		
		****
		TEXT
		****

version		=	$0212

		**********
		* HEADER *
		**********
TsrStart:
		JMP	Start(pc)
		
		; signature:
		
		dc.b	"c‚cile"
		
		; version:
		
		dc.w	version
		
Origin		=	TsrStart-28
		
		; tables d'offsets
		; 0) offset des paramŠtres DOS
		; 1) " table d'ordre de scan
		; 2) " des d‚lais ‚conomiseur
		; 3) " des unit‚s reserv‚es amovibles
		; 4) " tables r‚glages sp‚ciaux (vitesse ide...)
		; 5) reserv‚
		; 6) reserv‚
		; 7) reserv‚
OffTable:
		dc.w	FolderNum-Origin
		dc.w	ScanOrder-Origin
		dc.w	SleepDelay-Origin
		dc.w	RmvUnits-Origin
		dc.w	AtaSpd-Origin
		dc.w	0
		dc.w	0
		dc.w	0
		
		;  1) routine d‚tection type cpu
		;  2) " init du cooky
		;  3) " install bios principal
		;  4) " install bios disque
		;  5) " install timer c ‚conomiseur
		;  6) " pr‚-init pun
		;  7) " init xbpb
		;  8) " d‚termination id scsi
		;  9) " calcul fin du driver en ram
		; 10) " init pile interne du bios
		; 11) " scan des devices
		; 12) " cr‚ation des buffers gemdos
		; 13) " folder xxx
		; 14) " cr‚ation d'un buffer fastram
		; 15) " initialisation du pool pam
CodeOffset:	
		dc.w	CpuType-Origin
		dc.w	IniCooky-Origin
		dc.w	VecBios1-Origin
		dc.w	VecBios2-Origin
		dc.w	VecNrj-Origin
		dc.w	IniPun-Origin
		dc.w	IniXbpb-Origin
		dc.w	GetId-Origin
		dc.w	IniLim-Origin
		dc.w	IniStack-Origin
		dc.w	DevScan-Origin
		dc.w	CreateBuffers-Origin
		dc.w	AddFolders-Origin
		dc.w	CreateFRB-Origin
		dc.w	0
		
		****
		
		; table des variables DOS patchables
		; 0) nombre de "folders"
		; 1) " de buffers data
		; 2) " de buffers fat
		; 3) lecteur de d‚marrage

FolderNum		dc.w	300
BufNumData	dc.w	8
BufNumFat		dc.w	8
StartDrive	dc.w	2
		
		****
		
		; table des r‚glages 'sp‚ciaux'
		; relatif au devices ATA/IDE/ATAPI
		
		; m‚thode transfert cpu
		
AtaSpd		dc.b	0,0	master
		dc.b	0,0	slave

		; mode transfert du device
		
AtaXfer		dc.b	1<<3+2
		dc.b	1<<3+2
		
		;  read look ahead
		; ( $AA=on , $55=off )

AtaReadAhead	dc.b	$AA
		dc.b	$AA
		
		;  write cache
		; ( $02=on , $82=off )
		
AtaWriteCache	dc.b	$02
		dc.b	$02
		
		;  auto defect reallocation
		; ( $04=on , $84=off )
		
AtaReassign	dc.b	$04
		dc.b	$04
		
		;  maximum sector pre-fetch

AtaPrefetch	dc.b	4
		dc.b	4
		
		;  cache segment width
		
AtaSegment	dc.b	4
		dc.b	4
		
		; addressing mode determination
		; (0=auto,1=chs,2=lba)
		
AtaAdrMode	dc.b	0	master en auto
		dc.b	0	slave en auto
		
		; flag de swapping du port ata
		
AtaSwap		dc.b	0	master
		dc.b	0	slave
		
		****
		
		; nombre d'unit‚s reserv‚es par device
		; pour media amovibles...
		; (1 valeur pour chacun des devices)
RmvUnits:
		dc.b	2	scsi-0
		dc.b	2
		dc.b	2
		dc.b	2
		dc.b	2
		dc.b	2	(zip 5)
		dc.b	2	(zip 6)
		dc.b	2	scsi-7
		
		dc.b	2	atapi 0
		dc.b	2	atapi 1
		
		****
		
		; latence de mise en sommeil des devices
		; unit‚=1 seconde , max=9999~2h45 ,min=20
SleepDelay:
		dc.w	-1	scsi0
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		dc.w	-1
		
		dc.w	-1	ide0
		dc.w	-1	ide1
		
		****
		
		; ordre de scan des devices au boot
ScanOrder:
		dc.w	16
		dc.w	17
		
		dc.w	8
		dc.w	9
		dc.w	10
		dc.w	11
		dc.w	12
		dc.w	13
		dc.w	14
		dc.w	15
		
		dc.w	-1
		
		********
		
MAXUNIT		=	15	; higher log drive num
		
		********
		
strcopy1		MACRO
		lea	\1,a0
.z\@		move.b	(a0)+,(a1)+
		bne.s	.z\@
		subq.w	#1,a1
		ENDM
		
strcopy2		MACRO
		lea	\1,a0
		move	\2,d0
.x\@		move.b	(a0)+,(a1)+
		dbeq	d0,.x\@
		subq	#1,a1
		ENDM

strend		MACRO
		move.l	#$0d0a0000,(a1)+
		ENDM


sync		macro
.sem\@		tas.b	\1
		bmi.s	.sem\@
		endm

		********
		
		incdir	\work\cecile.drv\
		
		include	bios.equ
		include	xbios.equ
		include	gem.equ
		include	edt.equ
		include	gemerror.equ
		include	disk.rs
		include	gem_bpb.rs
		
		include	RWABS.S
		include	SDS.S
		include	GETBPB.S
		include	MEDIACH.S
		include	MOUNT.S
		include	BUFFERS.S
		include	FOLDERS.S
		include	FRB.S
		include	NRJ.S
		
		include	scsi\scsi.equ
		include	scsi\fscsi_ha.equ
		include	scsi\sc_sub.s
		include	scsi\sc_reset.s
		include	scsi\sc_sel.s
		include	scsi\sc_cmd.s
		include	scsi\sc_compl.s
		include	scsi\sc_dmard.s
		include	scsi\sc_dmawr.s
		include	scsi\rwa_scsi.s
		include	scsi\sds_scsi.s
		
		include	ata4\fata_ha.mac
		include	ata4\fata_ha.equ
		include	ata4\at_reset.s
		include	ata4\phy_ide.s
		include	ata4\sds_ata4.s
		
		********

********************************************************************
		TEXT
********************************************************************
		
		********
Start:		
		; sauvegarde marqueur boot
		; et base m‚moire au boot
		
		movem.l	d7/a4,-(sp)
		
		pea	Message(pc)
		gem	cconws
		
		pea	Install(pc)
		XBIOS	Supexec
		
		; installation en r‚sident,
		; sommes nous appel‚s normalement ou
		; par le boot ? (.sys ou .prg)
		
		movem.l	(sp)+,d7/a4
		
		cmp.l	#"boot",d7
		bne.s	.Normal
		
		********
.Boot
		move.l	TsrEnd(pc),d0
		sub.l	a4,d0
		
		move.l	d0,-(sp)
		move.l	a4,-(sp)
		clr.w	-(sp)
		GEM	MSHRINK
		
		move.w	StartDrive(pc),d7
		rts
		
		********
.Normal		
		
		lea	Origin-256(pc),a0
		move.l	TsrEnd(pc),d0
		sub.l	a0,d0
		
		clr.w	-(sp)
		move.l	d0,-(sp)
		GEM	Ptermres
	
		********
		
********************************************************************

		********
		
		; routine principale d'installation
		; (utilise la table d'offsets...)
Install:
		moveq	#15-1,d7
		lea	Origin(pc),a5
		lea	CodeOffset(pc),a6
.hop		
		move.w	(a6)+,a0
		
		tst.w	a0
		beq.s	.end
		
		add.l	a5,a0
		
		jsr	(a0)
		
		bra.s	.hop
.end		
		rts
		
		********

********************************************************************
		
		****
		DATA
		****

_testunit_cdb	dc.b	$00,$00,$00,$00,$00,$00
_inquire_cdb	dc.b	$12,$00,$00,$00,32,$00

		****
		TEXT
		****
		
	; fonction de scan des devices au boot
	; les informations obtenues sont stock‚es
	; dans une structure de 128 octets aussi bien
	; pour l'ide que le scsi (les informations ne sont
	; bien sur pas les memes !)
	
	; ces informations sont utilis‚es alors pour localiser
	; les devices compatibles avec les partitions gemdos
	; (disques durs) et construire alors les pun_info
	; qui vont bien...
		
		****
DevScan:		
		movem.l	d1-a6,-(sp)
		
		; reset tout le bazar
		
		****
		sync	$43e.w
		****
		
		bsr	ScReset
		
		bsr	AtaReset
		
		****
		sf	$43e.w
		****
		
		lea	pun_info(pc),a6
		clr.w	pinfo_puns(a6)
		
		lea	pinfo_pun(a6),a0
		move.b	#$ff,(a0)+
		move.b	#$ff,(a0)+
		moveq	#2,d4	index pun courant
		
		lea	pinfo_pstart(a6),a0
		lea	pinfo_size(a6),a1
.clrpun		
		clr.l	-(a1)
		
		cmp.l	a0,a1
		bgt.s	.clrpun
		
		****
		
		lea	ScanOrder(pc),a3
DevLoop		
		move.w	(a3)+,d6
		bmi	End
		
		move.w	d6,d5
		lsl.w	#7,d5
		lea	(EquipmentData.w,pc,d5.w),a4
		
		cmp.w	#15,d6
		bgt	IdeLog
		
		****
		****
		
		; Logging d'un device scsi
ScsiLog:
		; affichage du num‚ro id
		
		lea	Text(pc),a1
		strcopy1	.sc_str1(pc)
		
		move.w	d6,d0
		subq.w	#8,d0	id #
		add.w	#"0",d0
		
		move.b	d0,(a1)+
		clr.b	(a1)+
		
		pea	Text(pc)
		GEM	CCONWS
		
		move.w	d6,d5
		subq.w	#8,d5
		
		cmp.w	ScsiHostId(pc),d5
		beq	.scfalcon
		
		****
		sync	$43e.w
		****
		
		move.w	d5,-(sp)
		bsr	ScSelect
		
		tst.l	d0
		bne	.scnf
		
		pea	_inquire_cdb(pc)
		move.w	#6,-(sp)
		bsr	ScCmd
		
		tst.l	d0
		bne	.scnf
		
		pea	32.w
		pea	SectorBuffer(pc)
		bsr	ScReadDMA
		
		tst.l	d0
		bne	.scnf
		
		pea	_status(pc)
		pea	_message(pc)
		pea	200.w
		bsr	ScComplete
		
		****
		sf	$43e.w
		****
		
		lea	SectorBuffer(pc),a0
		
		; conversion des infos scsi
		; en donn‚es format systŠme EDT
		
		moveq	#$1F,d0
		and.b	(a0),d0
		move.b	d0,edt_devtype(a4)
		
		move.b	1(a0),edt_flags(a4)
		move.b	7(a0),edt_private(a4)
		
		lea	8(a0),a0
		lea	edt_name(a4),a1
		moveq	#24-1,d0
.cpyn		
		move.b	(a0)+,(a1)+
		dbf	d0,.cpyn
		
		move.l	#"    ",(a1)+
		move.l	#"    ",(a1)+
		
		****
		
		; affichage du nom du device trouv‚
		
		lea	Text(pc),a1
		strcopy1	.sc_str2(pc)
		strcopy2	edt_name(a4),#24
		strend
		
		pea	Text(pc)
		GEM	CCONWS
		
		****
		
		; montage des partitions
		; attention c'est le scsi, il vaut
		; donc mieux verifier qu'il s'agit
		; d'une unit‚ susceptible d'en comporter...
		
		move.b	edt_devtype(a4),d0
		
		; 0 -> direct access -> ok
		
		bne.s	.scend
		
		; on doit voir si c'est un amovible
		; car dans ce cas,on ne mounte pas
		; vraiment au boot,pour simplifier
		; on r‚serve uniquement le nombre
		; d'unit‚s voulues dans les pun_info...
		
		move.b	edt_flags(a4),d0
		bpl.s	.fixed
		
		moveq	#-1,d1
		move.b	(RmvUnits.w,pc,d5.w),d0
.resnx		
		cmp.w	#MAXUNIT,d4
		bgt.s	.scend
		
		move.b	d6,(a6,pinfo_pun.w,d4.w)
		move.l	d1,(a6,pinfo_pstart.w,d4.w*4)
		clr.l	(a6,pinfo_psize.w,d4.w*4)
		
		addq.w	#1,d4
		subq.b	#1,d0
		bgt.s	.resnx
		
		bra.s	.scend
		
		****
.fixed		
		; nombre d'unit‚s ++
		
		addq.w	#1,pinfo_puns(a6)
		
		move.w	d4,-(sp)
		move.w	d6,-(sp)
		
		bsr	MOUNT
		
		addq.w	#4,sp
		
		move.w	d0,d4
		
		********
.scend		
		bra	Skip
		
		********
.scnf		
		; ici device pas trouv‚
		
		lea	Text(pc),a1
		strcopy1	.sc_str3(pc)
		
		pea	Text(pc)
		GEM	CCONWS
		
		sf	$43e.w
		
		bra	.scend
		
		********
.scfalcon		
		; ici c'est l'id du falcon
		
		lea	Text(pc),a1
		strcopy1	.sc_str4(pc)
		
		pea	Text(pc)
		GEM	CCONWS
		
		bra	.scend
		
		********
		DATA
		********
		
.sc_str1		dc.b	" scsi id ",0
.sc_str2		dc.b	"  : ",0
.sc_str3		dc.b	"  : not responding",cr,lf,0
.sc_str4		dc.b	"  : falcon 030 host",cr,lf,0
		even
		
		********
		TEXT
		********
Skip
		bra	DevLoop
End		
		; remplir pun_info restantes
.pfill		
		move.b	#$ff,pinfo_pun(a6,d4.w)
		clr.l	(a6,pinfo_pstart.w,d4.w*4)
		clr.l	(a6,pinfo_psize.w,d4.w*4)
		clr.l	(a6,pinfo_ptype.w,d4.w*4)
		
		addq.w	#1,d4
		cmp.w	#MAXUNIT,d4
		ble.s	.pfill
		
		****
		
		; mettre les drvbits
		
		moveq	#%11,d0	toujours a&b
		moveq	#2,d4
.drvbit		
		btst.b	#7,pinfo_pun(a6,d4.w)
		bne.s	.drv0
		bset	d4,d0
.drv0		
		addq.w	#1,d4
		cmp.w	#MAXUNIT,d4
		ble.s	.drvbit
		
		move.l	d0,$4c2.w
		
		****
		
		; mettre le 'cooky' AHDI
		
		lea	pinfo_cookie(a6),a0
		move.l	#"AHDI",(a0)
		move.l	a0,4(a0)
		
		move.w	#$0300,pinfo_vernum(a6)
		move.w	#$4000,pinfo_maxsiz(a6)
		
		****
		sf	$43e.w
		****
		
		movem.l	(sp)+,d1-a6
		rts
		
		********
IdeLog:
		; d‚but de l'affichage
		
		lea	Text(pc),a1
		strcopy1	.ide_str1(pc)
		
		btst	#0,d6
		bne.s	.slvid
		
.mstid		lea	.ide_str2(pc),a0
		bra.s	.okdvid

.slvid		lea	.ide_str3(pc),a0

.okdvid		strcopy1	(a0)
		
		clr.b	(a1)+
		
		pea	Text(pc)
		GEM	CCONWS
		
		****
		sync	$43e.w
		****
		
		; tout d'abord,
		; il faut attendre que busy
		; soit annul‚ afin de pouvoir
		; acc‚der dans les registres...
		
		AtaWaitFree #400,.ata_busy
		
		; on s‚lectionne le bon drive
		
		moveq	#1,d5
		and.w	d6,d5
		lsl.w	#4,d5
		or.b	#%10100000,d5
		
		lea	IdeDriveHead,a0
		move.b	d5,(a0)
		nop
		nop
		
		; si le drive/head register
		; n'est pas correct,il n'y a sans
		; doute pas de device connect‚...
		
		cmp.b	(a0),d5
		bne	.ata_none
		
		; pour l'instant ca part bien,
		; faut v‚rifier qu'il y'a connection
		; correcte en ‚crivant un registre et
		; en le relisant...
		
		lea	IdeSectorCount,a0
		
		moveq	#-1,d0
		move.b	d0,(a0)
		nop
		cmp.b	(a0),d0
		bne	.ata_badreg
		
		moveq	#0,d0
		move.b	d0,(a0)
		nop
		cmp.b	(a0),d0
		bne	.ata_badreg
		
		; ici on est sur qu'il y'a un truc de
		; branch‚, par contre il faut attendre
		; qu'il soit ready ,c'est … dire pret
		; … recevoir nos premieres commandes...
		
		AtaWaitReady #200,.atapi
		
		; si le device ne se met pas en ‚tat ready
		; (BSY=0,DRDY=1) c'est probablement un
		; device ATAPI boot‚ … froid (ou un truc bugg‚)
		; sinon c'est un bon vieil ATA
.ata		
		move.b	#$EC,d0
		bra.s	.okcmd
.atapi		
		; essayons une commande identify ATAPI
		
		move.b	#$A1,d0
		
		; s'il n'ya pas de r‚ponse (DRQ=1) c'est qu'il
		; n'y a pas de device du tout (ni ATA ni ATAPI)
.okcmd		
		move.b	d0,IdeCommand
		nop
		nop
		
		AtaWaitDRQ #200,.ata_none
		
		****
		
		; on r‚cupŠre les infos
		
		lea	SectorBuffer(pc),a0
		clr.l	(a0)
		
		move.w	#256-1,d0
		lea	IdeData,a1
.yaread		
		move.w	(a1),(a0)+
		nop
		dbf	d0,.yaread
		
		****
		
		lea	SectorBuffer(pc),a0
		
		; conversion des infos ATA
		; en donn‚es format systŠme EDT
		
		move.w	0*2(a0),edt_ata_word0(a4)
		move.w	1*2(a0),edt_ata_word1(a4)
		move.w	3*2(a0),edt_ata_word3(a4)
		move.w	6*2(a0),edt_ata_word6(a4)
		move.w	47*2(a0),edt_ata_word47(a4)
		move.w	49*2(a0),edt_ata_word49(a4)
		move.w	51*2(a0),edt_ata_word51(a4)
		
		move.w	#1<<7,d0
		and.w	edt_ata_word0(a4),d0
		move.b	d0,edt_flags(a4)
		
		move.b	#0,edt_devtype(a4)
		
		lea	27*2(a0),a0
		lea	edt_name(a4),a1
		moveq	#32-1,d0
.cpyn		
		move.b	(a0)+,(a1)+
		dbf	d0,.cpyn
		
		****
		
		; ne pas utiliser set_features
		; sur les ATAPI !
		
		tst.w	edt_ata_word0(a4)
		bmi	.skip_feat
		
		****
		
		; reglages sp‚ciaux,
		; via la commande SET FEATURES
		
		moveq	#1,d5
		and.w	d6,d5		; # device
		
		; set_features:
		; d0=byte destin‚ au feature register
		; d1=byte destin‚ au sector count register
		
		; 1) set transfer mode
		
		move.b	#$03,d0
		move.b	(AtaXfer.w,pc,d5.w),d1
		
		bsr	set_features
		
		; 2) enable/disable read look ahead
		
		move.b	(AtaReadAhead.w,pc,d5.w),d0
		moveq	#0,d1
		
		bsr	set_features
		
		; 3) enable/disable write cache
		
		move.b	(AtaWriteCache.w,pc,d5.w),d0
		moveq	#0,d1
		
		bsr	set_features
		
		; 4) enable/disable auto defect reassign
		
		move.b	(AtaReassign.w,pc,d5.w),d0
		moveq	#0,d1
		
		bsr	set_features
		
		; 5) set maximum prefetch (in sectors)
		
		move.b	#$AB,d0
		move.b	(AtaPrefetch.w,pc,d5.w),d1
		
		bsr	set_features
		
		; 6) set cache segment size (in sectors)
		
		move.b	#$54,d0
		move.b	(AtaSegment.w,pc,d5.w),d1
		
		bsr	set_features
		
		****
.skip_feat		
		clr.b	IdeFeatures
		
		****
		sf	$43e.w
		****
		
		; s‚curit‚ maximale,
		; v‚rifions que les identify data
		; ne pr‚sentent pas d'anomalies !
		
		; si le premier word est zero, pas bon...
		
		tst.w	(a4)
		beq.s	.ata_badinfo
		
		; words qui se r‚pŠtent...pas bon !
		
		move.l	(a4),d0
		cmp.l	4(a4),d0
		beq.s	.ata_badinfo
		
		****
		
		; affichage nom du device
		
		lea	Text(pc),a1
		strcopy2	edt_name(a4),#32
		strend
		
		pea	Text(pc)
		GEM	CCONWS
		
		****
		
		; on doit voir si c'est un amovible
		; car dans ce cas,on ne mounte pas
		; vraiment au boot,pour simplifier
		; on r‚serve uniquement le nombre
		; d'unit‚s voulues dans les pun_info...
		
		tst.b	edt_flags(a4)
		bpl.s	.ata_fixed
		
		moveq	#-8,d5
		add.w	d6,d5
		
		moveq	#-1,d1
		move.b	(RmvUnits.w,pc,d5.w),d0
.ata_resnx
		cmp.w	#MAXUNIT,d4
		bgt.s	.ide_end
		
		move.b	d6,(a6,pinfo_pun.w,d4.w)
		move.l	d1,(a6,pinfo_pstart.w,d4.w*4)
		clr.l	(a6,pinfo_psize.w,d4.w*4)
		
		addq.w	#1,d4
		subq.b	#1,d0
		bgt.s	.ata_resnx
		
		bra.s	.ide_end
		
		****
.ata_fixed
		; nombre d'unit‚s ++
		
		addq.w	#1,pinfo_puns(a6)
		
		; montage des partitions
		
		move.w	d4,-(sp)
		move.w	d6,-(sp)
		
		bsr	MOUNT
		
		addq.w	#4,sp
		
		move.w	d0,d4
		
		********
.ide_end
		bra	Skip
		
		********
		
		; messages d'erreurs
.ata_badinfo
		lea	.ide_badinfo(pc),a0
		bra.s	.ata_bug
.ata_badreg
		lea	.ide_badreg(pc),a0
		bra.s	.ata_bug
.ata_busy
		lea	.ide_busy(pc),a0
		bra.s	.ata_bug
.ata_none
		lea	.ide_none(pc),a0
		
		****
.ata_bug		
		lea	Text(pc),a1
		strcopy1	(a0)
		strend
		
		pea	Text(pc)
		GEM	CCONWS
		
		move.l	a4,a0
		moveq	#127,d0
.yaclr		clr.l	(a0)+
		dbf	d0,.yaclr
		
		****
		sf	$43e.w
		****
		
		bra.s	.ide_end
		
		********
		DATA
		********
		
.ide_str1		dc.b	" ide ",0
.ide_str2		dc.b	"master : ",0
.ide_str3		dc.b	"slave  : ",0

.ide_none		dc.b	"no device",0
.ide_busy		dc.b	"still busy",0
.ide_badreg	dc.b	"i/o mismatch",0
.ide_badinfo	dc.b	"bad identify data",0
		
		even
		
		********
		TEXT
		********
set_features:
		AtaWaitFree #100,.end
		
		move.b	d0,IdeFeatures
		nop
		move.b	d1,IdeSectorCount
		nop
		move.b	#$EF,IdeCommand
		nop
.end
		rts
		
		********

********************************************************************

		****
		
		; detection type CPU
CpuType:		
		move.w	sr,-(sp)
		move.w	#$2700,sr
		
		move.l	$2c.w,a0
		pea	.nimp(pc)
		move.l	(sp)+,$2c.w
		
		moveq	#-1,d0
		cinva
		bra.s	.okmpu
.nimp		
		moveq	#0,d0
		addq.l	#2,2(sp)
		rte
.okmpu		
		move.l	a0,$2c.w
		
		; d0 true if 040 (or 060)
		
		lea	mpu_flag(pc),a0
		move.w	d0,(a0)
		
		move.w	(sp)+,sr
		rts
		
		****

********************************************************************
		
		****
		
		; cr‚ation des cookies
IniCooky:
		lea	cooky(pc),a0
		
		lea	EquipmentData(pc),a1
		move.l	a1,(a0)+
		
		lea	DevTable(pc),a1
		move.l	a1,(a0)+
		
		lea	SectorBuffer(pc),a1
		move.l	a1,(a0)+
		
		lea	_sense_buffer(pc),a1
		move.l	a1,(a0)+
		
		lea	Origin(pc),a1
		move.l	a1,(a0)+
		
		; XFRB:
		;
		
		; installation des cookies
		
		move.l	$5a0.w,a0
.scoo		
		tst.l	(a0)
		beq.s	.cook
		addq.l	#8,a0
		bra.s	.scoo
.cook		
		move.l	#"ceci",(a0)+
		move.l	(a0),d0
		
		lea	cooky(pc),a1
		move.l	a1,(a0)+
		
		clr.l	(a0)+
		subq.l	#1,d0
		move.l	d0,(a0)+
		
		rts
		
		****

********************************************************************
		
		****
		
		; device manager en trap 13
VecBios1:
		move.w	sr,-(sp)
		move.w	#$2700,sr
		
		;lea	new_trap13(pc),a0
		;lea	old_trap13(pc),a1
		;
		;move.l	$b4.w,(a1)
		;move.l	a0,$b4.w
		
		move.w	(sp)+,sr
		rts
		
		****
		
********************************************************************
		
		****
		
		; vectorisation systŠme
VecBios2		
		move.w	sr,-(sp)
		move.w	#$2700,sr
		
		
		lea	_OLD_MEDIACH(pc),a0
		move.l	$47e.w,(a0)
		lea	_BIOS_MEDIACH(pc),a0
		move.l	a0,$47e.w
		
		lea	_OLD_GETBPB(pc),a0
		move.l	$472.w,(a0)
		lea	_BIOS_GETBPB(pc),a0
		move.l	a0,$472.w
		
		lea	_OLD_RWABS(pc),a0
		move.l	$476.w,(a0)
		lea	_BIOS_RWABS(pc),a0
		move.l	a0,$476.w
		
		
		move.w	(sp)+,sr
		rts
		
		****

********************************************************************
		
		****
		
		; vectorisation du timer pour ‚conomiseur
VecNrj:
		move.w	sr,-(sp)
		move.w	#$2700,sr
		
		lea	_OLD_TIMER(pc),a0
		move.l	$114.w,(a0)
		lea	SleepTimer(pc),a0
		move.l	a0,$114.w
		
		; init des compteurs
		
		lea	SleepDelay(pc),a0
		lea	SleepCounters(pc),a1
		moveq	#10-1,d0
.cotim
		move.w	(a0)+,(a1)+
		dbf	d0,.cotim
		
		
		move.w	(sp)+,sr
		rts
		
		****
		
********************************************************************

		****
IniPun:
		lea	pun_info(pc),a0
		move.l	a0,$516.w
		
		moveq	#MAXUNIT,d0
.inipun
		move.b	#$FF,(pinfo_pun.w,a0,d0.w)
		dbf	d0,.inipun
		
		rts
		
		****

********************************************************************

		****
IniXbpb		
		; initialisation des XBPB's
		; (forc‚s 'media change' au boot)
		
		lea	DevTable(pc),a0
		move.l	a0,a1
		moveq	#32,d0
.bpini		
		rept	8
		clr.l	(a0)+
		endr
		
		move.l	#"XBPB",xb_magic(a1)
		move.b	#$80,xb_flag(a1)
		move.b	#$FF,xb_type(a1)
		
		move.l	a0,a1
		subq.w	#1,d0
		bgt.s	.bpini
		
		; effacement des descripteurs devices
		
		lea	EquipmentData(pc),a0
		move.w	#32*128,d0
.devclr		
		clr.l	(a0)+
		clr.l	(a0)+
		subq.w	#8,d0
		bgt.s	.devclr
		
		rts
		
		****
		
********************************************************************
		
		****
		
		; lecture de l'id scsi en NVraM
GetId:		
		lea	ScsiHostId(pc),a0
		
		move.b	#30,$ffff8961.w
		nop
		move.b	$ffff8963.w,d0
		bne.s	.okid
		
		; si y'a zero dedans,
		; la valeur n'a pas ‚t‚ r‚gl‚e,
		; mettons 7 d'office
		
		moveq	#7,d0
.okid		
		and.w	#7,d0
		move.w	d0,(a0)
		
		rts
		
		****
		
********************************************************************
		
		****
		
		; init limite du driver en RAM
IniLim:		
		lea	TsrEnd+4(pc),a0
		move.l	a0,-4(a0)
		
		rts
		
		****
		
********************************************************************
		
		****
		
		; init pile interne (1 Ko)
IniStack:
		lea	_regSP(pc),a0
		pea	_regStack+256*4(pc)
		move.l	(sp)+,(a0)
		
		rts
		
		****
		
********************************************************************
		DATA
********************************************************************

message		dc.b	27,"E",cr,lf,cr,lf
		dc.b	"    C‚cile ¿ "
		dc.b	(version>>8)+"0"
		dc.b	"."
		dc.b	(version>>4&$F)+"0"
		dc.b	(version&$F)+"0"
		dc.b	cr,lf,cr,lf,0
		even

table_hexa	dc.b	"0123456789abcdef"
		even
		
********************************************************************
		BSS
********************************************************************
		
		********
_regStack:
		ds.l	256
_regSP:
		ds.l	1

		********
ScsiHostId:
		ds.w	1		id scsi falcon

		********
		********
Cooky:
		ds.l	6
_FRB		ds.l	1

		; 1) table de description des devices
		; 2) table interne des BPB ‚tendus
		; 3) sector buffer interne (2 Ko)
		; 4) sense buffer
		; 5) pointeur sur adresse de base
				
		****

pindx		ds.w	1		pun courant
mpu_flag		ds.w	1
		
		****
	
		; table pun_info AHDI 4.0
pun_info:		
		ds.b	pinfo_size
		even
		
		; espace pour 32 XBPB's
DevTable:		
		ds.b	32*32
		even

		; table des compteurs de mise en sommeil
		
SleepCounters:	ds.w	10
		
		; stockage infos constructeur pour 32 devices
EquipmentData:	
		ds.b	32*128
		
		; tampon pour chaines de caractŠres
Text:		
		ds.b	128
		even
		
		; zone temporaire de 1 secteur physique
		; (prevoir 2 Ko pour les cd et les don)
SectorBuffer:	
		ds.b	2048
		even

TsrEnd:		ds.l	1
		
		********

********************************************************************
		