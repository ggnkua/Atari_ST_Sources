	
	include	"m:\include\gemdos.s"
	include	"m:\include\bios.s"

	move.l	4(sp),a6
	move.l	12(a6),d0
	add.l	20(a6),d0
	add.l	28(a6),d0
	add.l	#256,d0
	Mshrink a6,d0
	
	Tgetdate
	move.w	d0,d6
	not.w	d0
	move.w	d0,date
	Fopen2	file_sav(pc),#0
	move.w	d0,d7
	blt.s	ok
	Fread2	d7,#2,date(pc)
	tst.l	d0
	blt.s	ok
	Fclose	d7
ok:	
	cmp.w	date(pc),d6
	beq.s	fin
	
	Cconws2	letsgo(pc)
	Crawcin
	
	move.w	d6,date
	
	
	
	pea.l	file_c(pc)
	move.w	#'c'-'a',-(sp)
	bsr	save_fat
	pea.l	file_d(pc)
	move.w	#'d'-'a',-(sp)
	bsr	save_fat
	pea.l	file_e(pc)
	move.w	#'e'-'a',-(sp)
	bsr	save_fat

	Fcreate2	file_sav(pc),#0
	move.w	d0,d7
	blt.s	fin
	Fwrite2	d7,#2,date(pc)
	tst.l	d0
	blt.s	fin
	Fclose	d7

fin:	
	Term

;Rwabs:	MACRO		#rwflag.W, #buffer.L, #nombre.W, #debut.W, #dev.W

save_fat:			;dev.W,fname.L
	movem.l	d0-a6,-(sp)
n set 60+4
	move.w	n(sp),d7
	move.l	n+2(sp),a6
	lea.l	dd(pc),a4
	move.b	d7,file_test-dd(a4)
	add.b	#'a',file_test-dd(a4)
	Fsfirst2	file_test-dd(a4),#0
	Rwabs	#2,#buff,#1,#0,d7
	move.w	bbps-dd(a4),d0
	rol.w	#8,d0
	move.w	d0,bbps-dd(a4)
	move.w	bres-dd(a4),d0
	rol.w	#8,d0
	move.w	d0,bres-dd(a4)
	move.w	bdir-dd(a4),d0
	rol.w	#8,d0
	move.w	d0,bdir-dd(a4)
	move.w	bsec-dd(a4),d0
	rol.w	#8,d0
	move.w	d0,bsec-dd(a4)
	move.w	bspf-dd(a4),d0
	rol.w	#8,d0
	move.w	d0,bspf-dd(a4)
	
	moveq	#0,d6
	move.b	bfat-dd(a4),d6
	mulu.w	bspf-dd(a4),d6
	add.w	bres-dd(a4),d6
	move.w	d6,d0
	mulu.w	bbps-dd(a4),d0
	move.l	d0,d5
	Malloc	d0
	tst.l	d0
	ble	fin
	move.l	d0,a5
	Rwabs	#2,a5,d6,#0,d7
	tst.w	d0
	blt	fin
	Fcreate	a6,#0
	move.w	d0,d4
	blt	fin
	Fwrite	d4,d5,a5
	tst.l	d0
	blt	fin
	Fclose	d4
	Mfree	a5
	movem.l	(sp)+,d0-a6
	rtd	#6
	
	
	

	DATA


letsgo:	dc.b	7,13,10,"****** Insäre la disquette pour sauver les FATS !!!",13,10,10,0

file_sav:	dc.b	"c:\save_fat.dat",0
file_test:	dc.b	"c:\*.*",0
file_c:	dc.b	"a:\fat_c.dat",0
file_d:	dc.b	"a:\fat_d.dat",0
file_e:	dc.b	"a:\fat_e.dat",0

buff0:	dcb.l	1024,-1
	
	BSS
	
	EVEN
date:	ds.w	1
dd:
buff:	ds.b	11
bbps:	ds.b	2
bspc:	ds.b	1
bres:	ds.b	2
bfat:	ds.b	1
bdir:	ds.b	2
bsec:	ds.b	2
bmedia:	ds.b	1
bspf:	ds.b	2
bspt:	ds.b	2
bside:	ds.b	2
bhid:	ds.b	2
	ds.l	512

	END