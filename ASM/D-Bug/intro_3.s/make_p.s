; make movep datafile for a font.
; coded by the law of the bbc, 1991.

	bsr pre_define			; make table positions
	bsr make_movep_data		; make the data
	bsr save_movep_data		; save the data

	illegal

filename	dc.b "a:\xerud5.mvp",0	; movep file name
		even

pallname	dc.b "a:\xer5.pal",0	; font pallette file name
		even

save_movep_data
	move.l a1,d7			; move end
	sub.l #workspace,d7		; and calculate length!

	clr.w -(a7)			; save the movep data
	pea filename(pc)
	move.w #$3c,-(a7)
	trap #1
	addq.w #8,a7
	move.l d0,d2
	pea workspace
	move.l d7,-(a7)
	move.w d2,-(a7)
	move.w #$40,-(a7)
	trap #1
	lea 12(a7),a7
	move.w d2,-(a7)
	move.w #$3e,-(a7)
	trap #1
	addq.w #4,a7

	clr.w -(a7)			; save the font pallette
	pea pallname(pc)
	move.w #$3c,-(a7)
	trap #1
	addq.w #8,a7
	move.l d0,d2
	pea font+2
	pea 32
	move.w d2,-(a7)
	move.w #$40,-(a7)
	trap #1
	lea 12(a7),a7
	move.w d2,-(a7)
	move.w #$3e,-(a7)
	trap #1
	addq.w #4,a7
	rts

make_movep_data
	lea ptable,a0			; table pointer
	lea workspace,a1		; working space pointer
.loop	move.l (a0)+,a2			; pull 1st/next character
	cmp.l #-1,a2			; end?
	beq.s .exit
	bsr do_strip			; convert 32 rows of 8
	addq.l #1,a2			; offset to next 8 pixels
	bsr do_strip			; convert another 32x8
	addq.l #7,a2			; offset to next 8 pixels
	bsr do_strip			; convert another 32x8
	addq.l #1,a2			; offset to next 8
	bsr do_strip			; another 8 makes 32x32 done.
	bra .loop			; loop to next character
.exit	rts

do_strip	
xxx	set 0
	rept 32				; copy 8 pixel chunks to 
	movep.l xxx(a2),d6		; working storage section
	move.l d6,(a1)+
xxx	set xxx+160
	endr
	rts

pre_define				
	moveq.l #$1f,d0			; standard font offset table
	lea ptable(pc),a3		; maker!
def_1	addq.l #1,d0
	move.l d0,d1
	bsr.s which_line
	sub.l #$20,d1
	asl #4,d1
	add.l offset_char,d1
	add.l #font+34,d1
	move.l d1,(a3)+
	cmp.l #$5e,d0
	bne.s def_1
	rts

which_line
	cmp.b #'R',d1
	blt.s gruff1
	move.l #(31*160)*5,offset_char
	rts

gruff1	cmp.b #'H',d1
	blt.s gruff2
	move.l #(31*160)*4,offset_char
	rts

gruff2	cmp.b #'>',d1
	blt.s gruff3
	move.l #(31*160)*3,offset_char
	rts

gruff3	cmp.b #'4',d1
	blt.s gruff4
	move.l #(31*160)*2,offset_char
	rts

gruff4	cmp.b #'*',d1
	blt.s gruff5
	move.l #31*160,offset_char
	rts

gruff5	clr.l offset_char
	rts

offset_char		dc.l 0
ptable			ds.l $3f
			dc.l $ffffffff

font			incbin a:\xerud5.pi1

			section bss

workspace		ds.b 40000