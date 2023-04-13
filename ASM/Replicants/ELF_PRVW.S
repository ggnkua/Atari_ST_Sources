; "Elf Preview"
; -------------
; Maartau [2014-12-03]
; --------------------
;	opt	x+
;========================================
	text
;========================================
loadadr	equ	$15eaa
f_size	equ	35840
;========================================
copy	lea	begin(pc),a0
	lea	zuend(pc),a1
	lea	$1000.w,a2
	movea.l	a2,a3
copy_lp	move.w	(a0)+,(a2)+
	cmpa.l	a1,a0
	bne.s	copy_lp
	jmp	(a3)
;========================================
begin	lea	sav_ssp(pc),a6

super	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,(a6)
;
	bsr.s	load
	tst.l	d7
	bmi.s	user
	jmp	loadadr
;
user	move.l	sav_ssp(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

pterm0	clr.w	-(sp)
	trap	#1

sav_ssp	ds.l	1
;========================================
load	lea	handle(pc),a6

fopen	move.w	#2,-(sp)
	pea	f_name(pc)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bmi.s	loaderr
	move.w	d0,(a6)

fread	move.l	#loadadr,-(sp)
	move.l	#f_size,-(sp)
	move.w	handle(pc),-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi.s	loaderr

fclose	move.w	handle(pc),-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.w	d0
	bmi.s	loaderr
	rts

handle	ds.w	1

loaderr	moveq	#-1,d7
	rts

f_name	dc.b	"elf_prvw.dat",0
	even
;========================================
zuend	end
;========================================