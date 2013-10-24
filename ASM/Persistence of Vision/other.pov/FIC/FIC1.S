*************************************************************************
*			CRC checking program				*
*			~~~~~~~~~~~~~~~~~~~~				*
*									*
* Written by: MAC SYS DATA of PERSISTENCE OF VISION			*
*									*
* Date: Feb 1997							*
*									*
*************************************************************************
* use POV CRC CALC program to use this version
*************************************************************************
* Original pompey file integrity check from PP81
*************************************************************************


	clr.l	-(a7)		;set super
	move.w	#$20,-(a7)
	trap	#1

	lea	cls(pc),a0	;clear screen
	bsr.s	print_string

	lea	filenames(pc),a5
	lea	crc_numbers(pc),a6	;list of CRCs for each file
l0000	movea.l	(a5)+,a4	;put address of filename into A4
	cmpa.l	#0,a4		;end of list?
	beq.s	l0004		;yes

	lea	checking(pc),a0
	bsr.s	print_string

	movea.l	a4,a0		;print_string filename
	bsr.s	print_string

	bsr.s	l0007

	move.l	(a6)+,d6
	cmp.l	d0,d6
	beq.s	l0002
	addq.b	#1,l0035
	cmpi.b	#$3a,l0035
	bne.s	l0001
	addq.b	#1,l0034
	move.b	#$30,l0035
l0001	lea	l0032(pc),a0
	bra.s	l0003

l0002	lea	l0031(pc),a0
l0003	bsr.s	print_string
	bra.s	l0000

l0004	lea	l0036(pc),a0
	cmpi.w	#$3030,l0034
	beq.s	fin

	lea	l0033(pc),a0
fin	bsr.s	print_string

	move.w	#7,-(sp)	;get key
	trap	#1
	addq.l	#2,sp

	move.l	4.w,-(sp)	;reset
	rts

print_string	pea	(a0)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

l0007	clr.w	-(a7)		;select read only
	pea	(a4)		;put filename on stack
	move.w	#$3d,-(a7)	;open file
	trap	#1
	addq.l	#8,a7
	tst.l	d0		;test for good load
	bmi.s	open_err	;bad open! (file not found)

	clr.l	l0009		;clear DEADFACE

	move.w	d0,d7		;put file handle into D7
l0008	pea	loadarea(pc)
	pea	$61a80		;max bytes to load
	move.w	d7,-(a7)	;file handle
	move.w	#$3f,-(a7)	;read file
	trap	#1
	lea	12(a7),a7
	tst.l	d0		;test for good load
	bmi.s	read_err	;Bad load

	lea	loadarea(pc),a0
	move.l	d0,d1		;number of bytes read
	move.l	d0,d2
	move.l	#$deadface,d0	;total
l0009	equ	*-4
l000a	add.b	(a0)+,d0	;add byte from file to total
	rol.l	#1,d0
	subq.l	#1,d1		;sub 1 from file length
	bne.s	l000a		;do loop
	move.l	d0,l0009	;total
	cmp.l	#$61a80,d2
	beq.s	l0008
	move.l	d0,-(a7)	;save D0
	move.w	d7,-(a7)	;handle
	move.w	#$3e,-(a7)	;close file
	trap	#1
	addq.l	#4,a7
	move.l	(a7)+,d0	;restore D0
	rts

open_err
	lea	erroropen(pc),a0
	bra	fin

read_err
	lea	errorread(pc),a0
	bra	fin

	data
filenames
	dc.l	l000f
	dc.l	l0010
	dc.l	l0011
	dc.l	l0012
	dc.l	l0013
	dc.l	l0014
	dc.l	l0015
	dc.l	l0016
	dc.l	l0017
	dc.l	l0018
	dc.l	l0019
	dc.l	l001a
	dc.l	l001b
	dc.l	l001c
	dc.l	l001d
	dc.l	l001e
	dc.l	l001f
	dc.l	l0020
	dc.l	l0021
	dc.l	l0022
	dc.l	l0023
	dc.l	l0024
	dc.l	l0025
	dc.l	l0026
	dc.l	l0027
	dc.l	l0028
	dc.l	l0029
	dc.l	l002a
	dc.l	l002b
	dc.l	l002c
	dc.l	l002d
	dc.l	l002e
	dc.l	l002f
	dc.l	l0030
	dc.l	0

crc_numbers	dc.b	$cc,$a4
	dc.b	6,$b6,'T',$d2,7,$96
	dc.b	$cc,$17,$f2,$b1,$10,'pi',5
	dc.b	$ab,';',$b2,'H',2,$89,'s',$b8
	dc.b	$b8,'_M',$9c,$bd,'Cd',$cb
	dc.b	3,3,'e',$a3,'ZCk',$c3
	dc.b	'e3s[',$8e,$f4,$b4,$9a
	dc.b	$d5,$c7,$eb,$a6,$b7,'1',$d9,$ac
	dc.b	$e1,$f3,'(',$17,$13,$e3,$c2,'.'
	dc.b	$f3,$93,$8b,$df,$c5,$83,'w',$10
	dc.b	']7',$e6,$af,$e6,$c,'p',$c0
	dc.b	'^P',9,'M&-',$85,$14
	dc.b	9,$e2,$a3,$b,'cG',$e0,')'
	dc.b	'5',$90,$86,$ab,$ec,$b4,'4',$b5
	dc.b	$86,$e5,'7&',$e2,'HO',$d
	dc.b	'J',$b1,'CR',$e8,$9f,$9a,$13
	dc.b	$c4,'5S',$98,'1W',$a1,'z'
	dc.b	$b,$ca,'yY',$95,$d0,$dd,'E'

l000f	dc.b	'TITLE',0
l0010	dc.b	'FONTS.BL3',0
l0011	dc.b	'FILES.CRN',0
l0012	dc.b	'DATA.DAT',0
l0013	dc.b	'SAMPLES.DAT',0
l0014	dc.b	'SPRITES.DAT',0
l0015	dc.b	'CORNSEL1.IFF',0
l0016	dc.b	'BUMPY.PIT',0
l0017	dc.b	'ICY.PIT',0
l0018	dc.b	'MUDDY.PIT',0
l0019	dc.b	'WEMBLEY.PIT',0
l001a	dc.b	'FINAL.BIN',0
l001b	dc.b	'FINAL.PRG',0
l001c	dc.b	'AUTO\MENU81.PRG',0
l001d	dc.b	'CHARSET3',0
l001e	dc.b	'CLUBDATA',0
l001f	dc.b	'CREDITS',0
l0020	dc.b	'LOAD-PIC',0
l0021	dc.b	'MENU-PIC',0
l0022	dc.b	'NEWSPAPR',0
l0023	dc.b	'SPRITES1',0
l0024	dc.b	'SPRITES2',0
l0025	dc.b	'STARTUP1',0
l0026	dc.b	'STARTUP2',0
l0027	dc.b	'TEAMS',0
l0028	dc.b	'CHARSET1',0
l0029	dc.b	'WAITPIC',0
l002a	dc.b	'CHARSET2',0
l002b	dc.b	'GAME.EXE',0
l002c	dc.b	'MPSM.PRG',0
l002d	dc.b	'READ_ME.PP',0
l002e	dc.b	'PP57_FIX.PP',0
l002f	dc.b	'PP79_FIX.PP',0
l0030	dc.b	'PLAYDATA',0

l0031	dc.b	' : OK',13,10,10,0

l0032	dc.b	7,' : ',27,'b1BAD!',27,'b',$f,7,13,10,10,0

l0033	dc.b	13,10,10

l0034	dc.b	'0'

l0035	dc.b	'0 file(s) are corrupt - recopy!',7,0

l0036	dc.b	13,10,10,'All files checked out OK!',0

checking	dc.b	'Checking: ',0

cls	dc.b	27,'E',0

erroropen	dc.b	13,10,10,7,'Error opening file!',0

errorread	dc.b	$d,$a,$a,7,'Error reading file!',0,0
	bss
loadarea	ds.b	400000

