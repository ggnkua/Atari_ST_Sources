******** CONSTANTS ********

xsize:		EQU	256
ysize:		EQU	256
inputbytes:	EQU	xsize*ysize

******** LIBRARIES ********

	bra	START

	INCLUDE	IO.S
	TEXT

******** CODE ********

START:	move.l	#inputbytes,d0
	lea	inputfilename_txt,a0
	lea	input_buf,a1
	bsr	load
	move.l	d0,d0
	ble.s	END

	lea	input_buf,a1
	lea	output_buf,a0
	moveq	#0,d0
.yloop:
.xloop:	move.w	d0,d1
	move.w	d0,d2
	move.w	d0,d3
	move.w	d0,d4
	subi.w	#xsize,d1
	subq.b	#1,d2
	addq.b	#1,d3
	addi.w	#xsize,d4
	move.b	(a1,d1.l),d5
	sub.b	(a1,d4.l),d5
	move.b	d5,(a0)+
	move.b	(a1,d2.l),d5
	sub.b	(a1,d3.l),d5
	move.b	d5,(a0)+
	addq.b	#1,d0
	bne.s	.xloop
	addi.w	#xsize,d0
	bne.s	.yloop

	move.l	#inputbytes*2,d0
	lea	outputfilename_txt,a0
	lea	output_buf,a1
	bsr	save

END:	clr.w	-(sp)
	trap	#1

******** SUBROUTINES ********



******** DATA + INCLUDES ********

	DATA

inputfilename_txt:
	DC.B	"D:\CODING\DEMOS1\BUMPTEXT.GRY",0
outputfilename_txt:
	DC.B	"D:\CODING\DEMOS1\BUMPTEXT.RAW",0
	EVEN

******** RESERVES ********

	BSS

input_buf:
	DS.B	inputbytes
output_buf:
	DS.W	inputbytes