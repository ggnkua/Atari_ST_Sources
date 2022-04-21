************************ Disk Boot Flags ******************************
sid	equ	1	;0= 1  Face	1= 2  Faces
sect	equ	1	;0= 9  Secteurs	1= 10 Secteurs	2= 11 Secteurs
pts	equ	0	;0= 79 Pistes	1= 80 Pistes	2= 81 Pistes
************************ Disk Intro Flags *****************************
mem	set	$35000	;Load	Memory	Adress
sd1	equ	0	;0= Face 1	1= Face 2
pt1	equ	79
sd2	equ	0	;0= Face 1	1= Face 2
pt2	equ	78
sd3	equ	0	;0= Face 1	1= Face 2
pt3	equ	77
sd4	equ	0	;0= Face 1	1= Face 2
pt4	equ	76
sd5	equ	0	;0= Face 1	1= Face 2
pt5	equ	75
sd6	equ	0	;0= Face 1	1= Face 2
pt6	equ	74
***********************************************************************
***********************************************************************
	move.l	4(a7),a3
	move.l	$c(a3),d0
	add.l	$14(a3),d0
	add.l	$1c(a3),d0
	add.l	#600,d0
	add.l	#$100,d0
	move.l	#$15000,a7
	move.l	d0,-(a7)
	move.l	d0,-(a7)
	move.l	a3,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7
	dc.w	$a00a
	pea	insdest
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	pea	crunch
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	move.w	#1,-(a7)
	trap	#1
	addq.l	#2,a7
	swap	d0
	cmp.b	#$15,d0
	beq	crunched
	pea	crunchf
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	pea	com_env
	pea	com_env
	pea	file2
	move.w	#3,-(a7)
	move.w	#$4b,-(a7)
	trap	#1
	add.l	#14,a7
	tst.l	d0
	bmi	err
	move.l	d0,-(a7)
	move.l	d0,-(a7)
	move.l	d0,-(a7)
	move.w	#4,-(a7)
	move.w	#$4b,-(a7)
	trap	#1
	add.l	#14,a7
crunched
	pea	read
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	bsr	bl_fich
	pea	calc
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	pea	write
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	bsr	wr_pts
	lea	_start,a0
	move.w	#254,d1
	moveq	#0,d0
bcl	add.w	(a0)+,d0
	dbf	d1,bcl
	move.w	#$1234,d1
	sub.w	d0,d1
	move.w	d1,_start+$1fe
	move.w	#1,-(a7)
	move.w	#0,-(a7)
	move.w	#0,-(a7)
	move.w	#1,-(a7)
	move.w	#0,-(a7)
	clr.l	-(a7)
	pea	_start
	move.w	#9,-(a7)
	trap	#14
	lea	20(a7),a7
	tst.w	d0
	beq.s	ok
err	pea	error
	bra.s	print
ok	pea	done
print
	move.w	#9,-(a7)
	trap	#1
	move.w	#7,-(a7)
	trap	#1
	addq.l	#8,a7
	dc.w	$a009
	clr.w	-(a7)
	trap	#1
	ifeq	sect
sct	equ	9
	endc
	ifeq	sect-1
sct	equ	10
	endc
	ifeq	sect-2
sct	equ	11
	endc
bl_fich
	move.w	#0,-(a7)
	move.l	#file1,-(a7)
	move.w	#$3d,-(a7)
	trap	#1
	adda.l	#8,a7
	move.w	d0,d7
	tst.w	d0
	bmi	err
	pea	file
	move.l	#$2000000,-(a7)
	move.w	d7,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	adda.l	#12,a7
	tst.w	d0
	bmi	err
	move.l	d0,d4
	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	tst.w	d0
	bmi	err
	rts
wr_pts
	lea	file,a4
	lea	inf+2,a3
	move.w	(a3)+,d6
	move.w	d6,d5
	mulu	#$200,d6
	moveq.w	#-1,d7
wr	move.w	d5,-(a7)
	move.w	(a3)+,-(a7)
	move.w	(a3)+,-(a7)
	move.w	#1,-(a7)
	move.w	#0,-(a7)
	clr.l	-(a7)
	move.l	a4,-(a7)
	move.w	#9,-(a7)
	trap	#14
	add.l	#20,a7
	tst.w	d0
	bmi	err
	adda.w	d6,a4
	addq.w	#1,d7
	sub.l	d6,d4
	bpl.s	wr
	move.w	d7,inf
		rts
insdest	dc.b	27,"E  Intro-Boot Installator System",10,13
	dc.b	"  -----------------------------",0
done	dc.b	10,10,10,13,"  Ok! press a key to quit.",0
error	dc.b	10,10,13,"  Error Disk... press a key to quit.",0
crunch	dc.b	10,10,13,"  File ready Crunched (y/n): ",0
crunchf	dc.b	10,10,13,"  Crunching File...",0
calc	dc.b	10,10,13,"  Calculating..."
	dc.b	10,10,13,"  Insert a disk and press a key.",0
write	dc.b	10,10,13,"  Writing Intro & Boot on The Disk...",0
read	dc.b	27,"E  Reading File...",0
file1	dc.b	'a:\work\intro.prg',0
file2	dc.b	'a:\data\disk\pack.exe',0
com_env	dc.b	0
	even
_start
	bra.s	boot
	dc.b	'T','h','e',' ','E','M','P','I','R','E'
	ifeq	sid
	ifeq	sect
	ifeq	pts
	dc.w	$202,$100
	dc.w	$240,$d0
	dc.w	$2f8,$200
	dc.w	$900,$100
	endc
	ifeq	pts-1
	dc.w	$202,$100
	dc.w	$240,$d9
	dc.w	$2f8,$200
	dc.w	$900,$100
	endc
	ifeq	pts-2
	dc.w	$202,$100
	dc.w	$240,$e2
	dc.w	$2f8,$200
	dc.w	$900,$100
	endc
	endc
	ifeq	sect-1
	ifeq	pts
	dc.w	$202,$100
	dc.w	$240,$20
	dc.w	$3f8,$200
	dc.w	$a00,$100
	endc
	ifeq	pts-1
	dc.w	$202,$100
	dc.w	$240,$2a
	dc.w	$3f8,$200
	dc.w	$a00,$100
	endc
	ifeq	pts-2
	dc.w	$202,$100
	dc.w	$240,$34
	dc.w	$3f8,$200
	dc.w	$a00,$100
	endc
	endc
	ifeq	sect-2
	ifeq	pts
	dc.w	$202,$100
	dc.w	$250,$70
	dc.w	$3f8,$200
	dc.w	$b00,$100
	endc
	ifeq	pts-1
	dc.w	$202,$100
	dc.w	$250,$7b
	dc.w	$3f8,$200
	dc.w	$b00,$100
	endc
	ifeq	pts-2
	dc.w	$202,$100
	dc.w	$250,$86
	dc.w	$3f8,$200
	dc.w	$b00,$100
	endc
	endc
	endc
	ifeq	sid-1
	ifeq	sect
	ifeq	pts
	dc.w	$202,$100
	dc.w	$270,$a0
	dc.w	$5f9,$300
	dc.w	$900,$200
	endc
	ifeq	pts-1
	dc.w	$202,$100
	dc.w	$270,$b2
	dc.w	$5f9,$300
	dc.w	$900,$200
	endc
	ifeq	pts-2
	dc.w	$202,$100
	dc.w	$270,$c4
	dc.w	$5f9,$300
	dc.w	$900,$200
	endc
	endc
	ifeq	sect-1
	ifeq	pts
	dc.w	$202,$100
	dc.w	$280,$40
	dc.w	$6f9,$300
	dc.w	$a00,$200
	endc
	ifeq	pts-1
	dc.w	$202,$100
	dc.w	$280,$54
	dc.w	$6f9,$300
	dc.w	$a00,$200
	endc
	ifeq	pts-2
	dc.w	$202,$100
	dc.w	$280,$68
	dc.w	$6f9,$300
	dc.w	$a00,$200
	endc
	endc
	ifeq	sect-2
	ifeq	pts
	dc.w	$202,$100
	dc.w	$290,$e0
	dc.w	$6f9,$300
	dc.w	$b00,$200
	endc
	ifeq	pts-1
	dc.w	$202,$100
	dc.w	$290,$f6
	dc.w	$6f9,$300
	dc.w	$b00,$200
	endc
	ifeq	pts-2
	dc.w	$202,$100
	dc.w	$290,$c
	dc.w	$7f9,$300
	dc.w	$b00,$200
	endc
	endc
	endc
boot
	move.l	a7,d0
	sub.l	#200,d0
	move.l	d0,4(a7)
	lea	mem,a4
	lea	inf(pc),a3
	move.w	(a3)+,d7
	move.w	(a3)+,d6
	move.w	d6,d5
	mulu	#$200,d6
bl	move.w	d5,-(a7)
	move.w	(a3)+,-(a7)
	move.w	(a3)+,-(a7)
	move.w	#1,-(a7)
	move.w	#0,-(a7)
	clr.l	-(a7)
	move.l	a4,-(a7)
	move.w	#8,-(a7)
	trap	#14
	add.l	#20,a7
	adda.w	d6,a4
	dbf	d7,bl
	jmp	mem
inf	dc.w	0,sct,sd1,pt1,sd2,pt2,sd3,pt3,sd4,pt4,sd5,pt5,sd6,pt6
	ds.w	7
	dcb.b	16,'*'
	dc.b	'****Suck me!****'
	dcb.b	16,'*'
	ds.l	200
file: