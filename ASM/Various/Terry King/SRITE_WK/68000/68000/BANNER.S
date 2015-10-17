;
; Banner scroller, just like the ones you see in demos ...
;
; ~c:set_banner(width,height,L:text,L:font,L:screen)
; ~c:scroll_banner()
;
; ------- Copyright Terry King Ninth Wave Software 1993-95 -------

	bra	set_banner
	bra	scroll_banner
	
scrollcount=0
scroll_speed=2
speed_char=4
scrollpos=6
scrolltext=10
fontpos=14
screenpos=18
height=22
width=24

	opt	o+			; optimising on

set_banner
	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d0		; width
	move	62(a7),d1		; height
	movem.l	64(a7),a1-3		; text/font/screen
	lea	vars(pc),a0
	move.l	a1,scrolltext(a0)
	move.l	a1,scrollpos(a0)
	move.l	a2,fontpos(a0)
	lea	152(a3),a3
	move.l	a3,screenpos(a0)
	subq	#1,d1
	move	d1,height(a0)
	move	d0,width(a0)
	clr	scrollcount(a0)
	clr	scroll_speed(a0)
	clr	speed_char(a0)
	lea	char_buffer(pc),a0
	moveq	#7,d0
clear	clr.l	(a0)+
	dbf	d0,clear
	movem.l	(a7)+,d1-7/a0-6
	rts	

reset_banner
        move.l	scrolltext(a0),scrollpos(a0)
        clr	scrollcount(a0)
        bra.s	scr_nc
set_speed
        move	d0,scroll_speed(a0)
        move	width(a0),d1
	and.l	#$ffff,d0
	and.l	#$ffff,d1
        divu	d0,d1			; divide width by speed
        move	d1,speed_char(a0)
        move.l	a5,scrollpos(a0)
        bra.s	scr_nc

scroll_banner
	movem.l	d1-7/a0-6,-(a7)
	lea	vars(pc),a0
	lea	scrollcount(a0),a3
	subq	#1,(a3)
	bgt.s	scr_nc
	move	speed_char(a0),(a3)
	lea	char_buffer(pc),a4
	move.l	fontpos(a0),a6
	move.l	scrollpos(a0),a5
	moveq	#0,d0
	move.b	(a5)+,d0		; get character
	beq.s	reset_banner		; 0 = reset
        cmp	#32,d0
	blt.s	set_speed
	sub	#32,d0			; space is first character
	lsl	#5,d0			; each char 32 bytes long
	add	d0,a6
	move.l	a5,scrollpos(a0)
	movem.l	(a6),d0-d7		; dump character in buffer
	movem.l d0-d7,(a4)
        
scr_nc	lea	char_buffer(pc),a6
	move.l	screenpos(a0),a4
        
	move	scroll_speed(a0),d2
	move	height(a0),d3		; font height
.ylp	move	(a4),d0		
	move	d0,d1
	swap	d0
	move	(a6),d0			; get word from buffer
	rol.l	d2,d0
	move	d0,(a6)+
	swap	d0
        move	d0,(a4)
        subq.l	#8,a4
	
	rept 19
	move	d1,d0      
	swap	d0
        move	(a4),d0            
	move	d0,d1
        rol.l	d2,d0			; rotate it
        move	d0,(a4)            	; put in on screen
	subq.l	#8,a4
	endr
	lea	320(a4),a4		; next line down
        dbf	d3,.ylp
	movem.l	(a7)+,d1-7/a0-6
	rts

char_buffer     ds.w 32
vars		ds.b 34
