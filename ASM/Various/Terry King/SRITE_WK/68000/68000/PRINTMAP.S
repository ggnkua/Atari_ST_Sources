;
; Print map
;
; Written by T.A.King Copyright 1993 Ninth Wave Software
;
; A fairly fast routine for printing a map of 16x16 sprites. Use
; the DESIGN1 program to make your screens.
;
; 	~C:print_map(screen number,L:map,L:graphics,L:screen)
; 	~C:locate(x,y,screen number,L:map)

	bra	print_map

locate	movem.l	d1-5/a0,-(a7)
	move	28(a7),d2	; X
	move	30(a7),d3	; Y
	asr	#4,d2		; X DIV 16
	asr	#4,d3		; Y DIV 16
	move	32(a7),d4	; screen number
	move.l	34(a7),a0	; map
	move	(a0),d0		; width
	add	d0,d0		; line size
	move	d0,d1	
	mulu	2(a0),d1	; screen size
	add	d2,d2		; X*2
	mulu	d3,d0		; Y*line size
	mulu	d4,d1		; screen number*screen size
	moveq	#52,d5		; header offset
	add	d0,d5
	add	d2,d5
	add	d5,a0
	add.l	d1,a0
	move.l	a0,d0
	movem.l	(a7)+,d1-5/a0
	rts
print_map
	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d0	; screen number
	move.l	62(a7),a0	; map
	move.l	66(a7),a1	; graphics
	move.l	70(a7),a2	; screen
	move	(a0),d2		; width
	move	2(a0),d3	; height
	move	d2,d1
	mulu	d3,d1		; height*width
	add	d1,d1		; *2
	mulu	d1,d0		; *screen
	add.l	#52,d0
	add.l	d0,a0		; pointer to map
	subq	#1,d2
	subq	#1,d3
	
height	move.l	a2,-(a7)
	move	d2,-(a7)
width	move	(a0)+,d0	; sprite
	and.l	#$3ff,d0	; cut off mask bits
	asl.l	#7,d0		; *128
	lea	(a1,d0.l),a3	; pointer to sprite graphics
	rept	16
	move.l	(a3)+,(a2)+	; fast copy to screen
	move.l	(a3)+,(a2)	
	lea	156(a2),a2	; next line down
	endr
	lea	-2552(a2),a2	; next block right
	dbf	d2,width
	move	(a7)+,d2
	move.l	(a7)+,a2
	lea	2560(a2),a2	; next block down
	dbf	d3,height
	movem.l	(a7)+,d1-7/a0-6
	rts
	