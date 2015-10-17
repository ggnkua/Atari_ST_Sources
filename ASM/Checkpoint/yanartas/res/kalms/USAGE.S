
; Usage example for the line routine


	section	text


; Generate tables for linedrawing routine - takes less than a second

	jsr	SegmentedLineSetup


; Specify x0,y0,x1,y1 for line

	move.w	#10,d0
	move.w	#10,d1
	move.w	#310,d2
	move.w	#205,d3

; Optional: Clip line against screen edges

	jsr	ClipLine
	tst.l	d4			; If line is entirely outside screen, do not attempt to draw it
	beq.s	.skipLine

; Draw line

	lea	screen,a0
	jsr	SegmentedLine
.skipLine:



; Quit program

	clr.w   -(sp)
	move.w	#$4c,-(sp)
	trap    #1


	section	bss

screen	ds.b	32000		; Framebuffer
