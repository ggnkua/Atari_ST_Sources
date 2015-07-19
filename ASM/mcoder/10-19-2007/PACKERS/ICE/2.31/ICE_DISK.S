	opt	o+,ow-,a+		; Optimierung einschalten
start:	movea.l	#stackend,sp
	move.l	sp,d0
	subi.l	#start-$120,d0
	move.l	d0,-(sp)
	pea	start-$100(pc)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	adda.w	#$c,sp

	bsr.s	super
	move.l	$84.w,old_trap1+2	;store & change TRAP #1 vector
	move.l	#my_trap1,$84.w
	bsr.s	user
	pea	null(pc)
	pea	null(pc)
	pea	file_name(pc)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea.l	16(sp),sp
	bsr.s	super
	move.l	old_trap1+2(pc),$84.w
	bsr.s	user
	clr.w	-(sp)
	trap	#1

null:	dc.l 0,0

file_name:	dc.b 'datafile.del',0	; nachgeladenes Programm (pexec)
	EVEN 


super:	clr.l	-(sp)		;supervisor state
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,d7
	rts	
user:	move.l	d7,-(sp)		;user state
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts	

my_trap1: 
	movea.l	sp,a0
	btst	#$d,(sp)
	bne.s	supervisor
	move.l	usp,a0
	subq.l	#6,a0
supervisor:	
	addq.l	#6,a0
	cmpi.w	#$3f,(a0) 	; read
	beq.s	func_3f
old_trap1:	
	jmp	0.l

func_3f:	
	move.l	8(a0),puffer
	move.l	2(sp),ret_addr5+2	; Returnadresse
	move.l	#read,2(sp)
	bra.s	old_trap1

read:	tst.w	2(sp)
	bmi.s	ret_addr5 	; device handle->do nothing
	movem.l	d1-d7/a0-a6,-(sp)
	movea.l	puffer(pc),a0	; Puffer
	bsr.s	decrunch
	movem.l	(sp)+,d1-d7/a0-a6
ret_addr5:	
	jmp	0.l

;********************************************* Unpackroutine von ICE-PACK
	include	ice_unp2.s
;*************************************************** Ende der Unpackroutine


	section	bss
puffer:		ds.l 1
		ds.b 500
stackend: 	ds.b 20


