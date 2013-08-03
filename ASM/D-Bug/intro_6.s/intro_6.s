;
; D-Bug Intro 6 (Bit-Bender)
;
; Coded by Cyrano Jones of D.Bug
;

ramtop	equ $380000
;vbl_time

	move.l 4(a7),a5			; Gemdos MEM_SHRINK
	lea $2000.w,a7			; Safe Stack on 512!
	move.l #$200,-(a7)
	move.l a5,-(a7)
	move.l #$4a0000,-(a7)
	trap #1
	lea 12(a7),a7

	CLR.W -(A7)
	PEA -1.W
	MOVE.L (A7),-(A7)
	MOVE.W #5,-(A7)
	TRAP #14
	LEA 12(A7),A7

	pea code(pc)
	move.w #$26,-(a7)
	trap #14
	lea $2000.w,a7

	clr.l -(a7)			; $4b program file
	move.l #ct,-(a7)
	move.l filename,-(a7)
	clr.w -(a7)
	move.w #$4b,-(a7)
	trap #1
	lea 14(a7),a7

quit_ld	move.w #$4c,-(a7)		; Back to Desktop
	trap #1

filename	dc.l 0
ct		dc.l 0

game1	dc.b "title1.tos",0
	even
game2	dc.b "title2.tos",0
	even
;game3	dc.b "title3.tos",0
;	even
;game4	dc.b "title4.tos",0
;	even

code	move.w #$2700,sr
	move.b $ffff8201.w,old_scr+1		; save screen
	move.b $ffff8203.w,old_scr+2
	move.b $ffff820a.w,old_frq		; save frequency
	move.b $ffff8260.w,old_rez		; save resolution
	move.l $70.w,old_vbl			; save vbl vector
	move.l $118.w,old_key			; save key vector
	lea $ffff8240.w,a0
	movem.l (a0),d0-7		
	movem.l d0-7,old_pal			; save pallette
	movem.l newfont,d0-7
	movem.l d0-7,(a0)			; black pallette

	move.w #1,d0
	bsr music

	bsr pre_define				; get font gfx positions
	bsr make_roots				; make bit-bender routs
	bsr convert_font			; rotate to v-byte strips
	bsr init_text				; convert ascii to offset

	move.l screen8,a0			; clear the screen
	lea ramtop,a1
.wiper	clr.w (a0)+
	cmp.l a0,a1
	bne.s .wiper

	bsr make_screens			; draw 2-plane backdrop

	lea $ffff8240.w,a0
	move.l #$00010002,block
	move.l #$00040007,block+4
	movem.l block,d0-1
	move.l d0,(a0)+
	move.l d1,(a0)+
	move.l #$0,d0
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l #$07770777,d0
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)				; set hi plane to white

	move.l $120.w,x120		; save hbl (not used!)
	move.b $fffffa07.w,xa07		; save mfp
	move.b $fffffa13.w,xa13
	move.l #hbl1,$120.w
 
	bset.b #0,$fffffa07.w		; M.F.P. set
	bset.b #0,$fffffa13.w		; and again
	bclr.b #5,$fffffa15.w		; disable timer C
	bclr.b #5,$fffffa09.w		; on all four status bits
	bclr.b #5,$fffffa0d.w		
	bclr.b #5,$fffffa11.w		

	move.b #$12,d0
	bsr s_ikbd
	move.b #$1a,d0
	bsr s_ikbd
	move.l #my_key,$118.w

	move.l #vbl,$70.w			; my vbl vector
	move.w #$2300,sr			; system interupts go!

wait
	cmp.b #$2,key
	bne.s .2
	move.l #game1,filename
	bra.s .quit
.2	cmp.b #$3,key
	bne.s wait
	move.l #game2,filename
;	bra.s .quit
;.3	cmp.b #$4,key
;	bne.s .4
;	move.l #game3,filename
;	bra.s .quit
;.4	cmp.b #$5,key
;	bne.s wait
;	move.l #game4,filename
.quit
	move.w #$2700,sr			; all off
	lea $ffff8240.w,a6
	moveq.l #0,d0
	moveq.l #15,d1
.blk	clr.w (a6)+
	dbra d1,.blk
	move.l #$8080000,$ffff8800.w
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w		; soundchip off
	move.b old_scr+1,$ffff8201.w
	move.b old_scr+2,$ffff8203.w		; restore screen
	move.b old_frq,$ffff820a.w		; restore frequency
	move.b old_rez,$ffff8260.w		; restore resolution
	move.l old_vbl,$70.w			; restore vbl
	move.l old_key,$118.w			; restore key
	move.b xa07,$fffffa07.w		; restore mfp
	move.b xa13,$fffffa13.w
	bset.b #5,$fffffa15.w		; enable timer c
	bset.b #5,$fffffa09.w
	bset.b #5,$fffffa0d.w		
	bset.b #5,$fffffa11.w		

	move.b #$80,d0
	bsr s_ikbd
	move.b #$1,d0
	bsr s_ikbd

	lea ramtop-($7d00*8),a0
	lea ramtop,a1
.wiper	clr.w (a0)+
	cmp.l a0,a1
	bne.s .wiper

	movem.l old_pal,d0-7
	move.w #$777,d7
	movem.l d0-7,$ffff8240.w		; restore key
	rts

my_key	move.b $fffffc02.w,key		; keyboard 'scanner'
	bclr.b #6,$fffffa11.W
	rte
key	dc.l 0

s_ikbd	btst #1,$fffffc00.w
	beq.s s_ikbd
	move.b d0,$fffffc02.w
	rts

scrptr	dc.l scrcol
colptr	dc.l colors
clrbase	dc.l colors
colors	incbin back.pal
	dc.l $ffffffff
scrcol	incbin front.pal
	even

hbl1	movem.l d0-1/a0-1,-(a7)
	lea $ffff8248.w,a0
	move.l colptr,a1
	move.w (a1)+,d0
	bpl.s .wrt1
	lea colors(pc),a1
	move.w (a1)+,d0
.wrt1	move.w d0,d1
	swap d0
	move.w d1,d0
	move.l d0,d1
	move.l d0,(a0)+
	move.l d1,(a0)+
	move.l a1,colptr
	move.l scrptr,a1
	move.w (a1)+,d0
	move.l a1,scrptr
	move.w d0,d1
	swap d0
	move.w d1,d0
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)
        bclr #0,$fffffa0f.w  		; interrupt aknowledge 
	movem.l (a7)+,d0-1/a0-1
        rte

tmr	dc.w 1

vbl	movem.l d0-a6,-(a7)			; save all reggies

	move.l #scrcol,scrptr

	subq.w #1,tmr
	bpl.s .skpy1
	move.w #3,tmr

	move.l clrbase,a0
	move.w (a0)+,d0
	bpl.s .wrt1
	lea colors(pc),a0
.wrt1	move.l a0,clrbase
	move.l a0,colptr
	bra.s .skpy2

.skpy1	move.l clrbase,colptr
.skpy2

	move.b #0,$fffffa1b.w
	move.b #5,$fffffa21.w
	move.b #8,$fffffa1b.w

	move.b screen1+1,$ffff8201.w		; set screenbase
	move.b screen1+2,$ffff8203.w
	move.l screen1,d0			; swap screens
	move.l screen2,screen1
	move.l screen3,screen2
	move.l screen4,screen3
	move.l screen5,screen4
	move.l screen6,screen5
	move.l screen7,screen6
	move.l screen8,screen7
	move.l d0,screen8

	bsr bit_bender_call			; guess.....

	bsr music+8

	ifd vbl_time
	move.w #$777,$ffff8240.w
	move.w #$000,$ffff8240.w
	endc

	movem.l (a7)+,d0-a6			; restore reggies
	rte


plot_strip	MACRO
	moveq.l #0,d1				; clear
	move.b (a1)+,d1				; get byte strip
	add.w d1,d1				;
	add.w d1,d1				; x4
	move.l (a0,d1.w),a2			; get jsr address
	jsr (a2)				; call it
		ENDM

get_character	MACRO
	moveq.l #0,d4				; clear
	move.b (a4)+,d4				; bet character
	dc.w $6a08				; wrap?  * bpl.s .okish
	move.b #0,d4				; clear it
	lea scroll_text(pc),a4			; reload pointer
	add.w d4,d4				;        * .okish
	add.w d4,d4				; char x4
	move.l (a3,d4.w),a1			; get address
		ENDM

; Register uses - cor! none left!
;
; d0 - v-byte offset		a0 - pointer to plot routs
; d1 - trashed by plot		a1 - pointer to next char's gfx
; d2 - pointer to screen	a2 - trashed by plot
; d3 - general/loop		a3 - pointer to char table
; d4 - trashed by get_character	a4 - pointer into scrolltext
; d5 - loop			a5 - pointer into wave
; d6 - bits 'till char end	a6 - pointer to workscreen
; d7 - or bit			a7 - stack

bit_bender_call
	move.l screen2,d2		; const *see above
	add.l #326,d2			; to hi-plane
	move.l #160*8,d0		; const	*see above
	move.l waveptr,a5		; const	*see above
	lea jmp_tab,a0			; const	*see above
	lea chtab,a3			; const	*see above
	move.l char_ptr,a4		; const	*see above
	move.w #$8000,d7		; value to or

	move.w get_next,d3		; frames 'till next character
	moveq.l #16,d5			; max frames allowed
	move.w d3,d6			; 
	sub.w d3,d5			; bits left for 1st char
	move.w d5,d3			; xfer to d3
	add.w d3,d3			; x2 for bytes to skip

	get_character			; get address of 1st gfx
	add.w d3,a1			; skip over a few bytes

	moveq.l #19,d5			; 320 pixels = 20 characters
.loop1	move.l d2,a6			; move screen-offset to temp
	lea -160*41(a6),a6		; backtrack up
	moveq.l #0,d3			; used as fast clear
	move.w (a5),d1			; get height
	bpl.s .huh
	move.w wave,d1
.huh	add.w d1,a6			; add to screen-offset
x	set 0
	rept 99			; clear 62 words vertically
	move.w d3,x(a6)
x	set x+160
	endr
	moveq.l #15,d3			; each word contains 16 bits
.loop2	subq.w #1,d6			; 
	bpl.s .ne			; end of character?
	moveq.w #15,d6			; 15 'till next char
	get_character			; get a new one
.ne	move.l d2,a6			; move screen offset
	move.w (a5)+,d1			; pull v-offset
	bpl.s .pos
	lea wave(pc),a5
	move.w (a5)+,d1
.pos	add.w d1,a6			; add to screen offset
	add.w d0,a6			; do lower 1/2 of char
	plot_strip			; plot it
	sub.w d0,a6			; back up for upper 1/2
	plot_strip			; plot it
	ror.w d7			; rotate the 'or word'
	dbra d3,.loop2			; finish this word
	addq.w #8,d2			; next word in screen
	dbra d5,.loop1			; loop for 20 chars

	subq.w #2,get_next		; scroller scrolls at 2 pixels
	bpl.s .okishy
	move.w #15,get_next
	addq.l #1,char_ptr
	tst.b (a4)
	bpl.s .okishy
	lea scroll_text(pc),a4
	move.l a4,char_ptr

.okishy lea waveptr(pc),a5		; wave moves at 1 pixel (bit)
	move.l (a5),a5
	move.l -(a5),d0
	bpl.s .write
	lea waveend-2(pc),a5
.write	move.l a5,waveptr
	rts

waveptr	dc.l waveend			; pointer into wave table
	dc.l $ffffffff			; start of wave
	dc.l $ffffffff			; start of wave
wave	incbin y_point.bin		; wave offset table
waveend	dc.l $ffffffff			; end of wave table (unused)

make_screens
	move.l screen1,a0
	lea -160*4(a0),a0
	moveq.l #14,d3
.loop1	lea block+8(pc),a1
	moveq.l #15,d0
.loop0	move.l (a1)+,d1
;	move.w (a1)+,d2
	move.l a0,a3
	moveq.l #19,d4
.loop3	move.l d1,(a3)
	lea 8(a3),a3
	dbra d4,.loop3
	lea 160(a0),a0
	dbra d0,.loop0
	dbra d3,.loop1

	bsr plot_text

	lea screen1,a6
	move.l (a6)+,a3
	moveq.l #6,d7
	moveq.l #1,d5
.loop_a	move.l (a6)+,a0
	movem.l a3/a0,-(a7)
	move.l #($7d00/4)-1,d6
.copy_a	move.l (a3)+,(a0)+
	dbra d6,.copy_a
	movem.l (a7)+,a3/a0
	moveq.l #0,d6
	move.w d5,d6
.shift	bsr .rotate
	dbra d6,.shift 
	addq.w #2,d5
	dbra d7,.loop_a

	rts

; screen in a0
; shift count in d6

.rotate	lea 2(a0),a4
	move.l #199,d0
.lines	moveq.l #19,d1
.rows	roxr.w (a0)
	lea 8(a0),a0
	dbra d1,.rows
.lines2	moveq.l #19,d1
.rows2	roxr.w (a4)
	lea 8(a4),a4
	dbra d1,.rows2
	dbra d0,.lines
	sub.l #32000,a0
	move.l a0,a4
	move.l #199,d0
.down	move.l 8(a4),(a4)
	lea 160(a4),a4
	dbra d0,.down
	rts	

block	incbin block.bin
	even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;									;
; Routine to build plot routs for the bit-bender			;
;									;
; $8f5e, $offset - ori.b d7,$????(a6)					;
; $8f56 - or.b d7,(a6)							;
;									;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

make_roots
	lea roots_buff(pc),a1		; where to put 'em
	move.l a1,a0			; also points to table end
	move.l #255,d0			; make 256 routs!
.loop1	move.l a1,-(a0)			; save pointer
	bsr.s .make			; make the rout
	dbra d0,.loop1			; do for ALL combinations
	rts
.make	moveq.l #7,d1			; test high 7 bits
	move.l #160*7,d2		; maximum offset if hi-bit set
.loop2	btst d1,d0			; was it?
	beq.s .zero1			; branch if no
	move.w #$8f6e,(a1)+		; opcode - or.w d7,#????(a6)
	move.w d2,(a1)+			; !data! - offset-----^
.zero1	sub.l #160,d2			; up 1 line
	subq.w #1,d1			; 
	bne.s .loop2			; loop 'till zero
	btst d1,d0			; test the final (lo)bit
	beq.s .zero2			; skip if zero
	move.w #$8f56,(a1)+		; opcode - or.w d7,(a6)
.zero2	move.w #$4e75,(a1)+		; opcode - rts
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;									;
; Routine to generate table addresses for gfx positions			;
;									;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
pre_define
	moveq.l #$1f,d0			; start character
	lea chtab(pc),a3
def_1	addq.l #1,d0
	move.l d0,d1
	bsr.s which_line		; calc line on screen
	sub.l #$20,d1		
	asl #4,d1
	add.l offset,d1
	add.l screen2,d1		
	move.l d1,(a3)+			; save in the table
	cmp.l #$5e,d0			; last character? 'Z'+1
	bne.s def_1
	rts
which_line
	cmp.b #'R',d1			; crappy routs
	blt.s gruff1			; slow & inefficient
	move.l #(31*160)*5,offset	; coded ages ago
	rts				; can't be bothered to change em
gruff1	cmp.b #'H',d1
	blt.s gruff2
	move.l #(31*160)*4,offset	
	rts
gruff2	cmp.b #'>',d1
	blt.s gruff3
	move.l #(31*160)*3,offset
	rts
gruff3	cmp.b #'4',d1
	blt.s gruff4
	move.l #(31*160)*2,offset
	rts
gruff4	cmp.b #'*',d1
	blt.s gruff5
	move.l #31*160,offset
	rts
gruff5	clr.l offset
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;									;
; Routine to convert font into vertical bit strips 2 bytes high		;
;									;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

convert_font
	lea font,a0			; copy font to screen
	move.l #($7d00/8)-1,d0
	move.l screen2,a1
loop	move.w (a0)+,(a1)
	lea 8(a1),a1
	dbra d0,loop

	lea newfont,a6			; where to put new font
	moveq.l #0,d0
	move.b #' ',d0
.looper	cmp.b #'Z'+1,d0
	bne.s .rotate

	rts
.rotate	moveq.l #0,d1
	move.b d0,d1		; get current character
	addq.w #1,d0
	sub.b #' ',d1
	add.w d1,d1
	add.w d1,d1
	lea chtab(pc),a0	
	move.l (a0,d1.w),a2	; get value from table
	move.l a6,(a0,d1.w)	; replace with new value
	bsr .check8
	addq.l #1,a2
	bsr .check8
	bra .looper

.check8	moveq.l #7,d7		; horz counter
.loop0	moveq.l #0,d5		; byte 1
	moveq.l #15,d4		; vert counter
	moveq.l #0,d3		; vert offset
	move.w #$1,d2
.loop1	btst.b d7,(a2,d3.w)
	beq.s .nset1
	or.w d2,d5
.nset1	rol.w d2
	add.w #160,d3
	dbra d4,.loop1
	move.w d5,(a6)+
	dbra d7,.loop0

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;									;
; Routine to pre-subtract #' ' from the scrolltext	 		;
;									;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_text
	lea scroll_text(pc),a0
.lower	move.b (a0),d0
	bpl.s .ok
	rts
.ok	sub.b #' ',(a0)+
	bra.s .lower


screen1	dc.l ramtop-($7d00*1)
screen2	dc.l ramtop-($7d00*2)
screen3	dc.l ramtop-($7d00*3)
screen4	dc.l ramtop-($7d00*4)
screen5	dc.l ramtop-($7d00*5)
screen6	dc.l ramtop-($7d00*6)
screen7	dc.l ramtop-($7d00*7)
screen8	dc.l ramtop-($7d00*8)
get_next	dc.w 1

char_ptr
	dc.l scroll_text
scroll_text
	dc.b "                    "	; COMPULSORY!

	DC.B "WELCOME TO D-BUG DISK XXXXX   "

	DC.B "RUBBISH TEXT IN HERE"

	DC.B ".................................................."
	DC.B "WRAP"
	DC.B ".................................................."
	dc.b "                    "	; COMPULSORY!
	dc.b -1
	even

font	incbin armyfont.bin
	even

plot_text
	lea line1(pc),a1
	move.l screen1,a0
	lea 324(a0),a0
	bsr print
	rts

; call with a1 pointing at text
;           a0 pointing at plotting address

next_add	dc.l 0

;	dc.b "0123456789012345678901234567890123456789"

line1	dc.b -2
	DC.B " XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",-2
	DC.B " X                                    X",-2
	DC.B " X           D.BUG CD XXXXXX          X",-2
	DC.B " X                                    X",-2
	DC.B " XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",-2
	DC.B " X                                    X",-2
	DC.B " X  1- XXXXXXXXXXXXXXXXXXXXXX         X",-2
	DC.B " X                                    X",-2
	DC.B " X     BY XXXXXXXXXXXXXXXXX           X",-2
	DC.B " X                                    X",-2
	DC.B " X  2- XXXXXXXXXXXXXXXXXXXXXX         X",-2
	DC.B " X                                    X",-2
	DC.B " X     BY XXXXXXXXXXXXXXXXX           X",-2
	DC.B " X                                    X",-2
	DC.B " XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",-2
	DC.B " X                                    X",-2
	DC.B " X  GAME CRACKED BY:       HOT.KNIFE  X",-2
	DC.B " X  INTRO CODED BY:     CYRANO JONES  X",-2
	DC.B " X                                    X",-2
	DC.B " XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",-1
	EVEN

print	move.l a0,next_add
.loop	moveq.l #0,d0
	move.b (a1)+,d0
	bpl.s .write
	cmp.b #-1,d0
	beq.s .wrap
.nextline
	move.l next_add,a0
	add.l #160*9,a0
	move.l a0,next_add
	move.l #1,next
	bra.s .loop
.wrap	rts
.write	sub.b #' ',d0
	add d0,d0
	add d0,d0
	lea ascii(pc),a2
	move.l (a2,d0),a2
	bsr.s .plotit
	bra. .loop
.plotit	
x	set 0
y	set 0
	rept 8
	move.b x(a2),y(a0)
x	set x+40
y	set y+160
	endr
	add.l next,a0
	moveq.l #8,d0
	sub.l next,d0
	move.l d0,next
	rts

next	dc.l 1

font_x	incbin rawfont.bin
	even

ascii	
xx	set font_x
	rept 40
	dc.l xx
xx	set xx+1
	endr
xx	set font_x+(40*8)
	rept 40
	dc.l xx
xx	set xx+1
	endr

music	incbin sapiens.max
	even

	section bss

jmp_tab		ds.l 256	; table of plot rout addresses 
roots_buff	ds.b 4352	; space to build roots in
offset		ds.l 1		; used to calc font addresses
chtab		ds.l $3f	; holds char star addresses
old_scr		ds.l 1		; old value
old_frq		ds.b 1		; old value
old_rez		ds.b 1		; old value
old_vbl		ds.l 1		; old value
old_key		ds.l 1		; old value
old_pal		ds.l 8		; old value
xa07		ds.b 1
xa13		ds.b 1
x120		ds.l 1
newfont		ds.b 1888	; holds rotated font
	