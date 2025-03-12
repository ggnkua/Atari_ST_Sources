;Packers Companion - Version 0.1
;Code by ClockWork Orange of the FunHouse
;
;this should be compiled and run from floppy disk, as hard drive forces
;higher addresses, and many pieces of software don't like hard disk!


start:	move.l	sp,a5
	move.l	#stackend,sp
	move.l	4(a5),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	pea	$4a0000
	trap	#1
	add.l	#12,sp

doit:	bsr	super
	move.l	$84.w,old_trap1+2
	move.l	#my_trap1,$84.w	;set our vector
	bsr	user		;back to user mode

	move.l	#start),d0
	sub.l	#$100,d0	;basepage address
	move.l	#stackend,d1
	addq.l	#4,d1
	sub.l	d0,d1

 	clr.w	-(sp)		;terminate stay resident
	move.l	d1,-(sp)
	move.w	#$31,-(sp)
	trap	#1

super:	pea	0		;supervisor state
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save
	rts	

user	move.l	save,-(sp)	;back to user mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

;----------------------------------------------------
; New GemDos vector - all the action is here...
; we can ONLY use d0-d1,a0-a1 in this section of code

my_trap1:
	movea.l	sp,a0
	btst	#$d,(sp)
	bne.s	supervisor
	move.l	usp,a0
	bra.s	cont1
supervisor:
	addq.l	#6,a0
cont1:	cmpi.w	#$3D,(a0)	;Open file
	beq.s	open
	cmpi.w	#$3f,(a0)	;Read file
	beq	read
	cmpi.w	#$4b,(a0)	;exec program
	beq.s	exec
old_trap1:	
	jmp	0.l

;-----------------------------------------
; Vector for Executing files...
;

exec:	move.l	a2,-(sp)	;save a2
	move.l	4(a0),-(sp)	;address of the filename to be exec'd
	lea	ex_text,a2	;a2 points to string
	bsr	printit		;printit out
	move.l	(sp)+,a2
	bsr	printit
	lea	end_text,a2
	bsr	printit
	move.l	(sp)+,a2	;restore a2
	jmp	old_trap1		

ex_text:	dc.b	'Executing file: ',0
	even
end_text:	dc.b	$d,$a,0
	even

;--------------------------------
; Vector for Opening Files
;

open:	move.l	a2,-(sp)	;save a2
	move.l	2(a0),-(sp)
	lea	op_text,a2
	bsr	printit
	move.l	(sp)+,a2
	bsr	printit
	lea	end_text,a2
	bsr	printit
	move.l	(sp)+,a2
	jmp	old_trap1

op_text:	dc.b	'Opening file: ',0

;------------------------------------------
; Vector for Reading Files
;

read:	move.l	a2,-(sp)	;save a2
	move.l	8(a0),-(sp)	;address of the Disk read
	move.l	4(a0),-(sp)	;Number of bytes to read
	lea	re_text,a2
	bsr	printit

	move.l	(sp)+,d0	;# of bytes to read
	bsr	hex_ascii
	lea	0(a0,d1.w),a2
	bsr	printit		;print out the info

address:
	lea	re_text2,a2
	bsr	printit

	move.l	(sp)+,d0	;Address of the disk read
	bsr	hex_ascii
	lea	0(a0,d1.w),a2
	bsr	printit		;print out the info

	lea	end_text,a2
	bsr	printit
	move.l	(sp)+,a2	;restore a2

	jmp	old_trap1	;do the read...


re_text:	dc.b	'Reading ',0
	even
re_text2:	dc.b	' bytes at Address: ',0
	even

;--------------------------------------
; Subroutine printit - output an ascii string to the connected printer
;
;	input - address of string to print in A2
;	altered	- d0 == 0
;		  a2 -> end of string  / (a2) == 0

printit:
printer			;this routine if printer is used
	moveq	#0,d0
	move.b	(a2)+,d0
	tst.b	d0
	beq.s	.done
	move.w	d0,-(sp)
	move.w	#5,-(sp)	;print character
	trap	#1
	addq.l	#4,sp
	bra	printit
.done	rts

;---------------------------------------------------------
;Subroutine Hex-ascii
;converts a hexadecimal # to it's ascii hexadecimal equivalent
;first Character in string is the '$' so it would return '$aaaaa' ...
;
;	input	# in d0
;	output	d0 == 0
;		a0 -> ascii string
;		d1 == offest to first character in the string


hex_ascii:
	lea	abuf(pc),a0		;a0 -> our buffer
	move.l	#$0,d1
	move.l	d1,(a0)
	move.l	d1,4(a0)
	move.l	d1,8(a0)

	moveq	#11,d1

.loop	divu	#16,d0
	swap	d0			;remainder in top word
	cmp.b	#10,d0
	blt	.add_0
	add.b	#'A'-'0'-10,d0
.add_0	add.b	#'0',d0
	move.b	d0,0(a0,d1.w)
	move.w	#0,d0
	swap	d0
	tst.l	d0
 	beq	.fini
	dbf	d1,.loop

.fini:	subq	#1,d1
	move.b	#'$',0(a0,d1.w)
	rts

;----------------------------------------------
;Data Segment follows

	data
abuf:	dc.b	'   $00000000',0
	even
save:	dc.l	0
	bss
	ds.b	$100
stackend: 	ds.l 0

end:		;the end of the code.......................................
