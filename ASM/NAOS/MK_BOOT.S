	move.l	#FinPrg,d0
	sub.l	#Prg,d0
	cmp.w	#452,d0
	bgt	error_boot

; lecture du boot existant 
	move.w	#1,-(sp)		; Read boot-sector
	move.w	#0,-(sp)
	move.w	#0,-(sp)
	move.w	#1,-(sp)
	move.w	#0,-(sp)
	clr.l	-(sp)
	move.l	#filebuf,-(sp)
	move.w	#8,-(sp)
	trap	#14
	lea	20(sp),sp
	
; correction de la premiäre instruction
	lea	filebuf,a0		
	move.w	#$601c,(a0)	; BRA Instruction
	move.w	#'  ',2(a0)
	move.l	#'DEMO',4(a0)	; Message

; copie du programme de boot Ö sa place
	lea	Prg,a1		; Boot Prg
	lea	FinPrg,a2
	lea	30(a0),a3
Bcl	move.b	(a1)+,(a3)+
	cmp.l	a1,a2
	bhi	Bcl

; correction de la somme pour avoir $1234
	clr.w	510(a0)
	lea	filebuf,a1		; Test Checksum
	move.w	#$ff,d7
	moveq.l	#0,d0
Checksum	add.w	(a1)+,d0
	dbf	d7,Checksum
	
	move.w	#$1234,d1		; Correct Checksum
	sub.w	d0,d1
	move.w	d1,510(a0)
