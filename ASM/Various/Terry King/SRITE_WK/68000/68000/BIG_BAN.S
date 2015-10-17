;
; Big banner scroll. Scrolls 4 bit plane font up to 48 pixels high.
; No variable speed scroll, default is 8 pixel scrolling.
;
;	~C:set_banner(width,height,L:text,L:font,L:screen)
;	~C:scroll_banner()
;
; ------- Copyright Terry King Ninth Wave Software 1993-95 -------

		bra	set_banner
		bra	scroll_banner
		
textstart	dc.l 0
textpos		dc.l 0
char_width	dc.w 0
char_count	dc.w 0
char_offset	dc.w 0
char_size	dc.w 0
char_wsize	dc.w 0
fontpos		dc.l 0
screen		dc.l 0
end		dc.l 0
offsets		ds.w 40
	
TEXTSTART=0
TEXTPOS=4
CHAR_WIDTH=8
CHAR_COUNT=10
CHAR_OFFSET=12
CHAR_SIZE=14
CHAR_WSIZE=16
FONTPOS=18
SCREEN=22
END=26

	opt	o+
set_banner
	movem.l	d1-7/a0-6,-(a7)
	lea	textstart(pc),a0
	movem	60(a7),d0-1		; width/height
	move.l	64(a7),d2		; text
	move.l	d2,TEXTPOS(a0)
	move.l	d2,TEXTSTART(a0)
	move.l	68(a7),FONTPOS(a0)	; font
.nxt	move.l	72(a7),SCREEN(a0)	; screen
	lsr	#3,d0
	move	d0,CHAR_WIDTH(a0)	; divide into byte width
	move	d1,d2
	mulu	d0,d1			; character width*height
	lsl.l	#2,d1
	move	d1,CHAR_SIZE(a0)	; bytes per character
	divu	d0,d1
	move	d1,CHAR_WSIZE(a0)	; bytes per character strip
	clr	CHAR_COUNT(a0)
	clr	CHAR_OFFSET(a0)
	move	d2,d1
	lsl	#2,d1
	add	d2,d2
	add	d2,d1
	lea	print_strip(pc),a1
	add	d1,a1			; self-modifying code address
	move.l	a1,END(a0)		
	movem.l	(a7)+,d1-7/a0-6
	rts

scroll_banner
	movem.l	d0-7/a0-6,-(a7)
	lea	textstart(pc),a3
	lea	offsets(pc),a5
	move.l	SCREEN(a3),a0
	move.l	FONTPOS(a3),a1
	move.l	TEXTPOS(a3),a2	
	move.l	END(a3),a6		; get self-modifying address
	move	(a6),-(a7)		; save the contents
	move.l	a6,-(a7)		; and the address
	move	#$4e75,(a6)		; insert a rts in the list
	moveq	#0,d0
	move.b	(a2)+,d0
	bne.s	svalid
	move.l	TEXTSTART(a3),a2
	move.l	a2,TEXTPOS(a3)
	moveq	#0,d0
	move.b	(a2)+,d0
svalid	sub	#" ",d0
	mulu	CHAR_SIZE(a3),d0
	lea	(a1,d0.l),a4
	add	CHAR_OFFSET(a3),a4
	
	moveq	#39,d7			; x loop of 40 bytes
	move	CHAR_WIDTH(a3),d5
	sub	CHAR_COUNT(a3),d5
	move.l	#$00070001,d6		; screen increments
	bra.s	charlp
xlp	move	CHAR_WIDTH(a3),d5	; character width
charlp	bsr.s	print_strip		; print 8 pixel strip of character
	subq	#1,d7
	bmi.s	fin
	add	d6,a0			; goto next screen strip
	add	(a5)+,a0
	swap	d6
	subq	#1,d5
	bne.s	charlp
	moveq	#0,d0
	move.b	(a2)+,d0		; get next character
	bne.s	valid
	move.l	TEXTSTART(a3),a2
	move.b	(a2)+,d0
valid	sub	#" ",d0
	mulu	CHAR_SIZE(a3),d0
	lea	(a1,d0.l),a4
	bra.s	xlp
fin	addq	#1,CHAR_COUNT(a3)	; scroll to next strip
	move	CHAR_WSIZE(a3),d0
	add	d0,CHAR_OFFSET(a3)
	move	CHAR_COUNT(a3),d0
	cmp	CHAR_WIDTH(a3),d0
	bne.s	.ok			; scrolled to new character yet ?
	clr	CHAR_COUNT(a3)		; yep, update pointers	
	clr	CHAR_OFFSET(a3)
	addq.l	#1,TEXTPOS(a3)
.ok	move.l	(a7)+,a6		; restore modified code
	move	(a7)+,(a6)
	movem.l	(a7)+,d0-7/a0-6
	rts

print_strip      
offset	set 0
	rept	48
	move.l	(a4)+,d0
	movep.l	d0,offset(a0)		; print 4 bit planes in one go !!
offset	set offset+160
	endr
	rts
 