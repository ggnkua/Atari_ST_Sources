* The following is thwe source code for the loader program
* There is nothing special about it, but if I am including
* the source code for the game, I may as well also include
* the loader code.
*
* (c)1991, Philip Rankin

* The cls macro clears 32000 bytes of memory at address \1 
* (relatively slowly)
cls	macro \1
	movem.l d0/d1/a0,-(sp)
	move.l \1,a0
	clr.l d0
	move.w #2000-1,d1	
cloop\@	move.l d0,(a0)+		
	move.l d0,(a0)+			
	move.l d0,(a0)+		
	move.l d0,(a0)+
	dbra d1,cloop\@
	movem.l (sp)+,d0/d1/a0
	endm


print	macro \1	
	movem d0/d1/a0,-(sp)
	move.l \1,-(sp)
	move #$09,-(sp)
	trap #1
	addq.l #6,sp
	movem (sp)+,d0/d1/a0
	endm

printat	macro \1 \2 \3
	movem d0/d1/d2,-(sp)
	move.b \1,d0
	move.b \2,d1
	move.l \3,d2
	add.b #32,d0
	add.b #32,d1
	move.b d0,poscurs+2	; Position cursor using
	move.b d1,poscurs+3	; ESC 'Y',y-coord,x-coord
	print #poscurs
	print d2		; print string
	movem (sp)+,d0/d1/d2
	endm

waitkey macro
	movem d0-d7/a0-a6,-(sp)
	move.w #1,-(sp)
	trap #1
	addq.l #2,sp
	movem (sp)+,d0-d7/a0-a6
	endm

* Mode changes to screen resolution \1
mode 	macro \1
	movem.l d0-d1/a0,-(sp)
	move.w \1,-(sp)
	move.l #-1,-(sp)
	move.l #-1,-(sp)
	move.w #5,-(sp)
	trap #14
	add.l #12,sp
	movem.l (sp)+,d0-d1/a0
	endm 

* This macro opens file \1 and stores its handle in \2, to 
* check a file exists use the macro flen
* \1	: filename
* \2	: place to store handle
open	macro \1 \2
	movem.l d0-d2/a0-a1,-(sp)
	move.w #0,-(sp)		; open file for reading
	pea \1
	move.w #$3d,-(sp)
	trap #1
	addq.l #8,sp
	tst.l d0		; test for error
	bmi open_error
	move.w d0,\2
	movem.l (sp)+,d0-d2/a0-a1
	endm

* This macro will read \2 bytes from the file with handle \3
* storing them in the location pointed to in \1
* \1	: dest address
* \2	: number of bytes
* \3	: file handle
read	macro \1 \2 \3
	movem.l d0-d2/a0-a1,-(sp)
	move.l \1,-(sp)	; read picture
	move.l \2,-(sp)
	move.w \3,-(sp)
	move.w #$3f,-(sp)
	trap #1
	add.l #12,sp
	tst.l d0
	bmi read_error
	cmp.l \2,d0
	bne len_error
	movem.l (sp)+,d0-d2/a0-a1
	endm

* close simply closes the file with handle \1
* \1	: handle
close	macro \1
	movem.l d0-d2/a0-a1,-(sp)
	move.w \1,-(sp)		; close picture file
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
	bmi close_error
	movem.l (sp)+,d0-d2/a0-a1
	endm

* exec chains program \1
exec	macro \1
	pea env
	pea com
	pea \1
	move.w #0,-(sp)
	move.w #$4b,-(sp)
	trap #1
	add.l #16,sp
	cmp.w #-39,d0
	beq no_mem_error
	endm

palette macro \1
	move.l \1,-(sp)		; set palette
	move.w #6,-(sp)
	trap #14
	addq.l #6,sp
	endm


* -----> The following startup sequence is BUDGIE's startup macro

start:	movea.l	a7,a5		save stack pointer
	lea	stack,a7	set up local stack
	movea.l	4(a5),a5	read top long word from stack
	move.l	12(a5),d0	read length of prog area from base page	
	add.l	20(a5),d0	add length of initialized data area
	add.l	28(a5),d0	add length of uninitialized
	addi.l	#256,d0		add length of base page	
	move.l	d0,-(a7)	push total length on stack	
 	move.l	a5,-(a7)	also push start address	
	clr.w	-(a7)		dummy filler		
	move.l	d0,proglength	save	
	move.w	#$4a,-(a7)	gemdos code for SETBLOCK
	trap	#1		
	lea	12(a7),a7
	tst.l	d0		any errors?
	bne	error
	bra	ok
error	move.w	#$700,$ff8240	red warning. if necessary, exit
	bra end
ok	nop	

scr_inf move.w #2,-(sp)		; get and store physic
	trap #14
	addq.l #2,sp
	move.l d0,physic
	move.w #3,-(sp)		; get and store logic
	trap #14
	addq.l #2,sp
	move.l d0,logic
	move.w #4,-(sp)		; get and store resolution
	trap #14
	addq.l #2,sp
	move.w d0,scr_res

	mode #0
	cls physic
	move.l physic,d0
	sub.l #34,d0
	move.l d0,physic
	printat #0,#0,#menu_mess	; display message
	move.w #1,-(sp)
	trap #1
okay	addq.l #2,sp	
	cmp.w #32,d0			; pressed space?
	bne end
	palette #pal			
	open title_screen,handle
	read physic,#32034,handle
	close handle
	move.l physic,a0
	adda.l #2,a0
	palette a0			; set palette to picture
	exec music			; the  menu tune
	exec file520
	bra end
end:	move.w #0,-(sp)
	move.w #$4c,-(sp)
	trap #1 



* The following are the error routines for disk loading etc ...
open_error:
	move.l #mess6,a0	
	bra error_end
read_error:
	move.l #mess7,a0
	bra error_end
close_error:
	move.l #mess8,a0
	bra error_end
not_found:
	move.l #mess9,a0
	bra error_end
len_error:
	move.l #mess10,a0
	bra error_end
no_mem_error:
	move.l #mess15,a0
error_end
	cls physic
	palette #pal1
	printat #0,#0,a0
	printat #2,#0,#mess4
	waitkey
	bra end


menu_mess	dc.b 'Dennis & Denise:',13,10
		dc.b 13,10
		dc.b 'Press space to load program,',13,10
		dc.b 'Any Other key exits to desktop !!!!!!!!',13,10,13,10,13,10
		dc.b 'Quick Note - the program is',13,10
		dc.b 'written in STOS, so don`t complain',13,10
		dc.b 'when the sprites start to move',13,10
		dc.b 'slightly jerkily.',13,10,13,10
		dc.b 'Thanks to Goth of the Shapeshifters for',13,10
		dc.b 'the music.',13,10,13,10
		dc.b 'Next: Dennis in Space - in 68000',13,10,0
mess4		dc.b 'PRESS ANY KEY TO CONTINUE',0
mess6		dc.b 'We have an error in file opening',0
mess7		dc.b 'We appear to have a file read error',0
mess8		dc.b 'We have an error in file closure',0
mess9		dc.b 'Unable to find the file',0
mess10		dc.b 'File length error during read',0
mess12		dc.b 'Done, Done, Done',0
mess15		dc.b 'Error 39 - Not enough Memory',0
poscurs		dc.b 27,'Y',0,0,0
file520		dc.b '\dnd_520.pmr',0
title_screen	dc.b '\dnd_intr.pi1',0
music		dc.b '\love_4de.prg',0
flen 		dc.l 0
handle		dc.w 0
env		dc.w 0
com		dc.b 0
		even
pal 		dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
pal1		dc.w $777,$000,0,0,0,0,0,0,0,0,0,0,0,0,0,0
physic		ds.l 1
logic		ds.l 1
scr_res		ds.w 1
w_screen	ds.l 1
d_screen	ds.l 1
temp	 	ds.l 1
proglength 	ds.l 1 
save_stack 	ds.l 1
		even
		ds.b 256
stack		ds.l 1