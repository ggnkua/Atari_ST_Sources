; Hi!     Thought I'd include this source as it's the first program
; I've ever written in 68000. Though it was mostly written by ST Internals!

; Mass Deporter of Serenade

start
	lea	text(pc),a0
	bsr	print_text
	bsr	wait_key
	lea	writ_text(pc),a0
	bsr	print_text
	lea	file1(pc),a4
	bsr.s	open_file
	lea	save_gam(pc),a5
	move.l	#137,d0
	bsr.s	write_file
	lea	file2(pc),a4
	bsr.s	open_file
	lea	mindmelt_obj(pc),a5
	move.l	#8704,d0
	bsr.s	write_file
	lea	file3(pc),a4
	bsr.s	open_file
	lea	map_sav(pc),a5
	move.l	#8192,d0
	bsr.s	write_file
	lea	done_text(pc),a0
	bsr.s	print_text
	bsr.s	wait_key
	clr.l	-(a7)
	trap	#1	
	
	
open_file	clr.w	-(sp)
	pea	(a4)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	tst	d0
	bmi.s	error
	move.w	d0,d7
	rts
	
write_file	pea	(a5)
	move.l	d0,-(sp)
	move.w	d7,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi.s	error
	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	bmi.s	error
	rts
	
print_text	pea	(a0)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

wait_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

error	lea	error_text(pc),a0
	bsr.s	print_text
	bsr.s	wait_key
	bra	start

text	dc.b	$1b,69
	dc.b	"MIND MELT INITIALISER BY MASS DEPORTER",13,10,10,10,10
	DC.B	"Leave the Serenade disk in the drive and",13,10
	dc.b	"make sure it is write enabled.",13,10,10,10,10,10
	dc.b	"Press any key to initiliase Mind Melt."
	dc.b	7,0
	even

writ_text	dc.b 27,'Y',32+14,32+0,	"Writing. Please wait."
	dc.b	7,0
	even

done_text	dc.b 27,'Y',32+14,32+0,	"Done! Any key to exit."
	dc.b	7,0
	even
	
error_text	dc.b 27,'Y',32+14,32+0,	"Error writing files. Any key to retry."
	dc.b	7,0
	even

file1	dc.b	"SAVE.GAM",0
	even
	
file2	dc.b	"MINDMELT.OBJ",0
	even

file3	dc.b	"MAP.SAV",0
	even
			
save_gam
	incbin	save.gam
	even

mindmelt_obj	
	incbin	mindmelt.obj
	even

map_sav
	incbin	map.sav
	even
