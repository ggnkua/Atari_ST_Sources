*
*   SSS  (Slow & Shitty Scroll)
*

	move	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,logbase

	move.w	#0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

loop	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	jsr	scroll
	move	#$B,-(sp)
	trap	#1
	addq.l	#2,(sp)
	tst.w	d0
	beq	loop
	clr.w	-(sp)
	trap	#1
			
scroll
	sub	#1,counter
	tst	counter
	bne	exit
	
	move.w	#8,counter
	move.l	tpoint,a2
	cmp.l	#endtext,a2
	bne	okey
	move.l	#text-1,tpoint
okey      add.l	#1,tpoint
	clr.l	d2
	move.b	(a2),d2
	sub	#32,d2
	lsl.w	#5,d2
	move.l	#font,a3
	move.l	#buffer,a4
	add.l	d2,a3
	

	move.l	#15,d5
loopx	move.w	(a3)+,(a4)+
	dbra	d5,loopx

exit	jsr	shift
	jsr	shift	

	rts

shift
	move.l	logbase,a0
	add.l	#31198,a0
	move.l	#buffer+32,a1
	move.w	#15,d1
loop2	lsl.w	-(a1)
	move.w	#19,d0
loop1	roxl	(a0)
	sub.l	#8,a0
	dbra	d0,loop1
	dbra	d1,loop2
	rts


logbase	ds.l	1

font	incbin	accfont.bin

buffer	ds.w	16
tpoint	dc.l	text
counter	dc.w	8
text	dc.b	"OH SHIT !!!!!!!!!!!!!!!!!!!!!!!! WHAT THE FUCK IS THIS!!!!!!!!!!!!!! JIPPIKAIEEEEJ ITS AN SCROLLLER!!!!"
endtext