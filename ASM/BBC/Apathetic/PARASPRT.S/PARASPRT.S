;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                       ;;
;; 	  The Bad Brew Crew "Total Apathy" Megademo Source Code		 ;;
;;                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;									 ;;
;;   ****    ***   ****    ***    ****  ****   ****   *  *****  *****    ;;
;;   *   *  *   *  *   *  *   *  *      *   *  *   *       *    *	 ;;
;;   ****   *****  ****   *****   ***   ****   ****   *    *    ***	 ;;
;;   *      *   *  *   *  *   *      *  *      *   *  *    *    *	 ;;
;;   *      *   *  *   *  *   *  ****   *      *   *  *    *    *****	 ;;
;;                                                                       ;;
;;  	 Code: The Law    Graphics: Xerud    Music: L.E.D. STORM	 ;;
;;                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ramtop		equ $1ffe00		; 1st un-addressable byte
screen		equ ramtop-$7d00
mak_buf		equ ramtop-(64*160)
text_add	equ (192*160)
;vbl_timer

	lea $2000.w,a7

	clr.w -(a7)
	pea -1.w
	pea -1.w
	move.w #5,-(a7)
	trap #14
	lea 12(a7),a7

	pea code(pc)
	move.w #$26,-(a7)	
	trap #14
	addq.w #6,a7
	clr.l -(a7)
	trap #1

code	move.w #$2700,sr		; all stop!
	movem.l $ffff8240.w,d0-7	; save pallette
	movem.l d0-7,old_pall
	move.b $ffff8260.w,old_res	; save resolution
	move.b $ffff8201.w,old_screen+1	; save screen-base
	move.b $ffff8203.w,old_screen+2
	move.l $70.w,-(a7)

	movem.l logrout+2,d0-7
	movem.l d0-7,-(a7)

	lea $ffff8240.w,a0
	moveq.l #15,d0
.blak	clr.w (a0)+
	dbra d0,.blak

	move.b #$12,d0			; no mouse
	bsr sikbd
	move.b #$1a,d0			; no joysticks
	bsr sikbd

	lea logrout+34+(126*160),a0
	lea eight,a1
	move.l #((49*160)/4)-1,d0
.loop1	move.l (a0)+,(a1)+
	subq.l #1,d0
	bne.s .loop1
	lea logrout+34+(176*160),a0
	lea badrewc,a1
	move.l #((12*160)/4)-1,d0
.loop2	move.l (a0)+,(a1)+
	subq.l #1,d0
	bne.s .loop2

	jsr create_shifts		; shift layers
	jsr pre_define			; make font map

	lea screen,a0
	move.l #($7d00/4)-1,d0
.killgf	clr.l (a0)+
	dbra d0,.killgf

	lea logrout+34,a0		; copy the triangle logo to screen
	lea screen,a1
	move.l #180,d0
.outer	move.l #112,d1
.toscrn	move.b (a0)+,(a1)+
	subq.l #1,d1
	bne.s .toscrn
	lea 48(a0),a0
	lea 48(a1),a1
	subq.l #1,d0
	bne.s .outer

	move.l #(121*160)/8,r_len
	move.l #screen+(121*160),r_len1
	lea logrout,a1			; address to put routine at
	lea log_tab(pc),a2		; address to make table at
	bsr make_routs			; build mega-fast sprite routines!
	bsr sprite_init

	bsr optimise_xy

	moveq.l #1,d0
	jsr music

	bsr cls				; clear screen

	bclr.b #5,$fffffa15.w		; disable timer C
	bclr.b #5,$fffffa09.w		; on all four status bits
	bclr.b #5,$fffffa0d.w		
	bclr.b #5,$fffffa11.w		

	movem.l (a7)+,d0-7
	movem.l d0-7,$ffff8240.w

	move.w #$2300,sr
	stop #$2300
	move.l #vbl,$70.w		; set vertical blank

.spc	cmp.b #$39,$fffffc02.w		; wait for space
	bne.s .spc

	move.w #$2700,sr		; all stop!
	move.l (a7)+,$70.w
	bset.b #5,$fffffa15.w		; enable timer c
	bset.b #5,$fffffa09.w
	bset.b #5,$fffffa0d.w		
	bset.b #5,$fffffa11.w		
	move.w #$2300,sr		; all go!

	move.l #$8080000,$ffff8800.w	; volume to zero on
	move.l #$9090000,$ffff8800.w	; all 3 channels
	move.l #$a0a0000,$ffff8800.w

	bsr cls				; clear screen

	move.b #$80,d0			; restore ikbd
	bsr sikbd
	move.b #$1,d0			; to power up status
	bsr sikbd

	movem.l old_pall,d0-7
	movem.l d0-7,$ffff8240.w	; restore pallette
	move.b old_res,$ffff8260.w	; restore resolution
	move.b old_screen+1,$ffff8201.w	; restore screenbase
	move.b old_screen+2,$ffff8203.w
	rts

sikbd	move.b d0,$fffffc02.w		; send command bytes
	move.l #$3000,d0
.wait	subq.w #1,d0			; wait a while
	bne.s .wait
	rts

cls	lea ramtop-($7d00*2),a0		; wipe the work and display
	move.l #($7d00*2)/4,d0		; screens
.wiper	clr.l (a0)+
	subq.l #1,d0
	bne.s .wiper
	rts	

vbl	move.w #$2700,sr
	movem.l d0-a6,-(a7)		; save reggies
	
	ifd vbl_timer
	clr.w	$ffff8240.w
	endc

	move.b screen2+1,$ffff8201.w	; set screenbase
	move.b screen2+2,$ffff8203.w

	move.l screen1,-(a7)		; toggle screens
	move.l screen2,screen1
	move.l (a7)+,screen2

	bsr para			; parallax
	jsr triangle			; sprite
	jsr sprite_vbl
	jsr text_display
	jsr music+8			; chrispy's stuff

	ifd vbl_timer
	move.w #$777,$ffff8240.w
	endc

	addq.w #1,vbl_count
	movem.l (a7)+,d0-a6
	rte

vbl_count	dc.w 0

para	lea buffer,a5			; screen-base

	move.l xptr1,a0			; get pointer into x-pos (back)
	move.w (a0)+,d0			; pull position
	bpl.s .fetch
	lea xpos1,a0			; reset and reload
	move.w (a0)+,d0
.fetch	move.l a0,xptr1			; save current place

	move.l yptr1,a0			; do the same for the y-pos
	move.w (a0)+,d1
	bpl.s .yetch
	lea ypos1,a0
	move.w (a0)+,d1
.yetch	move.l a0,yptr1

	lea y_table,a0
	add d1,d1
	add d1,d1
	move.w (a0,d1),d3		; grafix offset (vertical)

	lea x_partb,a0		
	add d0,d0
	add d0,d0
	move.l (a0,d0),d0		; grafix offset (horiz)
	
	lea top_tab,a6			; actually the bottom (ooops!)
	move.l (a6,d0),a6		; address of correct block
	swap d0
	add.w d0,a6			; plus 16-pixel offset
	add.w d3,a6			; plus vertical offset

xxx	set 0				; copy it to the top-left
yyy	set 0				; of the screen
	rept 16
	movem.l yyy(a6),d0-3
	movem.l yyy+32(a6),d4-7
	movem.l d0-7,xxx(a5)
yyy	set yyy+64
xxx	set xxx+32
	endr

; ok, now must sprite the other layer on top of this one.

do_top	move.l yptr2,a0			; as before, grab y-position
	move.w (a0)+,d1
	bpl.s .yetch
	lea ypos2,a0
	move.w (a0)+,d1
.yetch	move.l a0,yptr2
	lea y_table,a0
	add d1,d1
	add d1,d1
	move.w (a0,d1),d3		; grafix offset (vert)
	move.w 2(a0,d1),d4		; mask offset (vert)

	move.l xptr2,a0			; and grab x
	move.w (a0)+,d0
	bpl.s .fetch
	lea xpos2,a0
	move.w (a0)+,d0
.fetch	move.l a0,xptr2
	add d0,d0
	add d0,d0
	
	lea x_partb,a0
	move.w (a0,d0),d7		; x-offset (grafix)
	move.w 2(a0,d0),d0		; table offset
	lea back_tab,a6
	move.l (a6,d0),a6		; data pointer
	lea mask_tab,a5
	move.l (a5,d0),a5		; mask pointer
	add.w d7,a6			; add x to pointer

	cmp.w #8,d7			; check for mask overflow
	bne.s .ok
	addq.w #4,a5			; correct mask pointer

.ok	add.w d3,a6			; add vertical to grafix
	add.w d4,a5			; add vertical to mask

	lea buffer,a4			; screenbase
	rept 8*4
	move.l (a5)+,d0
	move.l (a5)+,d1
	and.l d0,(a4)+			; block
	and.l d0,(a4)+
	and.l d1,(a4)+
	and.l d1,(a4)+
	addq.w #8,a5
	endr

	lea buffer,a4			; screenbase
yyy	set 0
	rept 32
	movem.l yyy(a6),d0-3
	or.l d0,(a4)+
	or.l d1,(a4)+
	or.l d2,(a4)+
	or.l d3,(a4)+
yyy	set yyy+32
	endr

blit_line macro offset
	lea	\1+160(a4),a6
	movem.l d0-a3,-(a6)
	movem.l d0-a3,-(a6)
	movem.l d0-7,-(a6)
	movem.l d0-7,-(a6)
	endm

blit_all		
	lea buffer,a5
	move.l screen1,a4		; the screen
xxx	set 0
	rept 32				; make the top line
	movem.l (a5)+,d0-3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d2,d6
	move.l	d3,d7
	move.l	d0,a0
	move.l	d1,a1
	move.l	d2,a2
	move.l	d3,a3
	blit_line xxx
	blit_line xxx+160*32
	blit_line xxx+160*64
	blit_line xxx+160*96
	blit_line xxx+160*128
	blit_line xxx+160*160
xxx	set xxx+160
	endr
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; Init Code for parallax ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

create_shifts			; build a table of pointers
	lea top_tab,a0
	lea back_tab,a1
	lea mask_tab,a2
	lea back_gfx,a3
	lea top_gfx,a4
	lea top_mask,a5
	move.l #16,d0
make_tables
	move.l a3,(a0)+
	move.l a4,(a1)+
	move.l a5,(a2)+
	lea 32*64(a3),a3
	lea 32*64(a4),a4
	lea 32*32(a5),a5
	subq.w #1,d0
	bne.s make_tables

	lea back_tab,a0			; now, copy and shift images
	lea top_tab,a1
	move.l #0,d0
rotate2	move.l (a0)+,a2
	move.l (a1)+,a3
	bsr copy_block
	move.l d0,d1
	tst.w d0
	beq.s next
shifter	movem.l a2-a3,-(a7)
	bsr pre_shifter
	movem.l (a7)+,a2-3
	subq.w #1,d1
	bne.s shifter
next	addq.w #1,d0
	cmp.w #16,d0
	bne.s rotate2

	lea top_gfx,a0			; build the sprite masks
	lea top_mask,a1			; (only for the top layer!)
masking	move.w #2,d0
skipper	move.w (a0)+,d1
	move.w (a0)+,d2
	move.w (a0)+,d3
	move.w (a0)+,d4
	or.w d1,d2
	or.w d3,d2
	or.w d4,d2
	not d2
	move.w d2,d1
	swap d2
	move.w d1,d2
	move.l d2,(a1)+
	subq.w #1,d0
	bne.s skipper
	cmp.l #top_mask,a0
	bne.s masking
	rts

pre_shifter
	move.w #64,d6
nextlin	move.w #4,d7
onepln	sub d5,d5	
	roxl.w 24(a2)
	roxl.w 16(a2)
	roxl.w 8(a2)
	roxl.w (a2)+
	sub d5,d5
	roxl.w 24(a3)
	roxl.w 16(a3)
	roxl.w 8(a3)
	roxl.w (a3)+
	subq.w #1,d7
	bne.s onepln
	lea 24(a2),a2
	lea 24(a3),a3
	subq.w #1,d6
	bne.s nextlin
	rts

copy_block
	lea logrout+34+112,a5
	lea logrout+34+112+(64*160),a6
xxx	set 0
yyy	set 0
	rept 32
	movem.l xxx(a5),d4-7
	movem.l d4-7,yyy(a2)
	movem.l d4-7,yyy+(32*32)(a2)
	movem.l xxx(a6),d4-7
	movem.l d4-7,yyy(a3)
	movem.l d4-7,yyy+(32*32)(a3)
	
	movem.l xxx+16(a5),d4-7
	movem.l d4-7,yyy+16(a2)
	movem.l d4-7,yyy+(32*32)+16(a2)
	movem.l xxx+16(a6),d4-7
	movem.l d4-7,yyy+16(a3)
	movem.l d4-7,yyy+(32*32)+16(a3)

xxx	set xxx+160
yyy	set yyy+32
	endr
	rts

*********************************************************

triangle
	move.l x_ptr,a1			; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	lea x_pos(pc),a1
	move.w (a1)+,d0
.write	move.l a1,x_ptr
	lea x_table,a3
	lea log_tab,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen1,a0		; work screen base
	move.l y_ptr,a1			; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	lea y_pos+2(pc),a1
	move.w (a1)+,d1
.write2	move.l a1,y_ptr		
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	jsr (a2)			; call sprite routine
	rts

***************************************************************************
*************************** The Sprite Routs ******************************
***************************************************************************
*******  Sprite Routines! - Builds the most optimesed rout possible  ******
***************************************************************************
*******     Lawrence Staveley 13.08.91. I am very chuffed indeed     ******
***************************************************************************
*
* D7 is set to 0 (replace clr.l with move.l d7).
* A0 points to screen (increments where possible, lea's gaps).
* A1 points to movem buffer and is incremented (only if used).
* d0-d6/a2-a6 are used in movem's and various moveq combinations.
*
* Only edges of sprites are 'sprited'. middles are blocked.
* Blocks are only used if mask is full, ie, no background colour,
*      this also applies to movem combinations.
* If the mask is 0 but there is data then move.l d7,(a0)+ is substituted. 
* If there is no 'or' data then that long is skipped.
* If ori.l can be replaced with moveq.l #?,d2 or.l d2,(a0)+ then it is.
* An empty long in a block will be replaced by move.l d7,(a0)+.
* If moveq.l #?,d3 move.l d3,(a0)+ can replace a movei.l #?,(a0)+ it does.
* All ori.w opcodes are removed because the lea required would cancel out.
* If no movem's are present then the lea at start of rout is removed.
* If movem list can replace strings of between 4-12 (even) movei's it does.
* If movem used and last was also movem the lea is overwritten and an
*      offset is used (saves 4 cycles/use)
*
* That's about it. Try to beat dis! (dese?)
*
* Future options.....
* (but not today)
* All 'and' data moved into a buffer, then movem'd out and and'd to screen
* All 'or' data moved into a buffer then movem'd out and or'd to screen

make_routs	
	lea screen,a0		; graphics data
	moveq.l #16,d5		; 16 shifts
.makeem	move.l a1,(a2)		; save this address
	move.w #$43f9,(a1)+	; opcode! lea ????????,a1
	move.l a1,blocking	; save this address
	clr.l (a1)+		; increment to next long
	move.w #$7e00,(a1)+	; opcode! moveq.l #0,d7
	bsr.s do_1		; make routine 
	bsr copy_movem_data	; shift the movem data to rout-end
	bsr rotate		; shift right!
	addq.l #4,a2		; next entry
	move.w #-1,do_lea
	move.l #mak_buf,buff	; reset movem buffer
	subq.l #1,d5			
	bne.s .makeem
	rts

blocking	dc.l 0		; address of address in 1st lea

do_1	lea screen,a0		; screen address
	moveq.l #0,d7		; offset init
looper	tst.l (a0)		; and data
	bne.s hit		; branch if yes
	tst.l 4(a0)		; and data
	bne.s hit		; branch if yes
	bsr nothing		; none!
r_len1	equ *+2
	cmp.l #screen+(64*160),a0
	blt.s looper
	move.w #$4e75,(a1)+	; write final RTS instruction
	rts

hit	tst.w do_lea		; any offset changes?
	bmi.s add_lea		; branch if lea is needed
me	move.w (a0),d0
	or.w 2(a0),d0
	or.w 4(a0),d0
	or.w 6(a0),d0
	cmp.w #-1,d0
	bne.s sprite
	bsr movem_test		; check for movem substitute
	tst.w d2		; did we substitute any?
	bpl.s looper		; branch if yes
	bra block		; must do a normal block

add_lea	tst.w d7		; just a checksum. if zero
	beq.s .notme		; then get out.
	move.w #$41e8,(a1)+	; opcode! - lea ????(a0),a0
	move.w d7,(a1)+		; offset
.notme	moveq.l #0,d7		; clear it out
	move.w #1,do_lea	; kill the flag
	bra.s me		; get out

; routine to take screen data in (a0) and 4(a0) and build the
; fastest possible routine to sprite it.

sprite
	move.w (a0),d0		; make mask
	move.w 2(a0),d1
	move.w 4(a0),d2
	move.w 6(a0),d3
	or.w d1,d0
	or.w d2,d0
	or.w d3,d0
	not.w d0
	tst.w d0
	bne.s .fst
	bsr .clr		; if 0 then a clear (move.l d7,) will do!
	bra.s .do_or
.fst	cmp.w #$ffff,d0
	beq block		; if full then move it in!

	move.w #$223c,(a1)+	; move.l #????????,d1
	move.w d0,(a1)+		; quick not possible due to double-word
	move.w d0,(a1)+		; and -1 is is block!
	move.w #$c390,(a1)+	; opcode! and.l d1,(a0)

.do_or	tst.l (a0)		; check for data present
	bne.s .or1		; branch if data
	bsr .conv		; convert last opcode to (a0)+
	addq.l #4,a0		; none, skip to next long
	moveq.l #0,d7		; reset offset counter
	bra.s .sk1		; or's are not needed

.or1	cmp.l #-128,(a0)	; ok, test data for +ve quick validity
	blt.s .lon1		; negative! no quick here
	cmp.l #127,(a0)		
	bgt.s .lon1		; larger than 127. not possible.
	bsr.s .orq		; substitute a moveq #??,d2 or d2,????(a0)
	bra.s .sk1		; process next longword

.lon1	move.w #$0098,(a1)+	; opcode! ori.l #????????,(a0)+
	move.l (a0)+,(a1)+	; data
	moveq.l #0,d7		; reset offset counter

.sk1	tst.w d0		; any mask?
	bne.s .scnd		; branch if yes!
	bsr .clr		; substitute a (clear) move.l d7,(a0)
	bra.s .wib
.scnd	move.w #$c390,(a1)+	; opcode! and.l d1,(a0)

.wib	tst.l (a0)		; check for data present
	bne.s .or2		; branch if yes!
	bsr .conv		; convert last opcode to (a0)+
	addq.l #4,a0		; none - next long please
	moveq.l #0,d7		; reset offset count
	bra.s .sk2		; jump out of routine

.or2	cmp.l #-128,(a0)	; test for quick validity
	blt.s .lon2		; negative! 
	cmp.l #127,(a0)
	bgt.s .lon2		; larger than 127. not possible
	bsr.s .orq		; substiture a moveq #??,d2 or d2,????(a0)
	bra.s .sk2		; get the hell out

.lon2	move.w #$0098,(a1)+	; opcode! ori.l #????????,(a0)+
	move.l (a0)+,(a1)+	; data
	moveq.l #0,d7

.sk2	bra looper		; next 16 pixels, please

.conv	cmp.w #$c390,-2(a1)	; was it an and.l d1,(a0)
	bne.s .notand		; branch if not
	move.w #$c398,-2(a1)	; convert last to opcode! and.l d1,(a0)+	
	rts
.notand	move.w #$20c7,-2(a1)	; convert last to opcode! move.l d7,(a0)+
	rts

; these are called when a clear can be substituted 
; move.l d7,(a0) replaces clr.l ????(a0)

.clr	move.w #$2087,(a1)+	; opcode! move.l d7,(a0)
	moveq.l #0,d7		; reset offset
	rts

; these are called when the or can be done via a moveq

.orq	move.l (a0)+,d0		; get current long in d0 and increment
	move.b #$74,(a1)+	; opcode! moveq #??,d2
	move.b d0,(a1)+		; data
	move.w #$8598,(a1)+	; opcode! or.l d2,(a0)+
	moveq.l #0,d7		; reset offset
	rts

; routine to take screen data in (a0) and 4(a0) and make a routine
; fastest block copy routine possible to 8 bytes (16 pixels)

block	tst.w d2		; did i just do a movem?
	bmi.s .cont		; branch if no!
	bra looper		; yes, this is not needed!

.cont	tst.l (a0)		; any data?
	bne.s .sk1		; branch if yes
	bsr.s .clear		; make a move.l d7,(a0)+
	bra.s .pt2		; next long please!	
.sk1	bsr.s .block		; make a block move

.pt2	tst.l (a0)		; any data?
	bne.s .sk2		; branch if yes
	bsr.s .clear		; make a move.l d7,(a0)+
	bra looper		; loop around
.sk2	bsr.s .block		; make a block move
	bra looper		; loop around

.clear	move.w #$20c7,(a1)+	; opcode! move.l d7,(a0)+
	addq.l #4,a0		; next long
	moveq.l #0,d7		; reset offset counter
	rts

.block	move.l (a0),d0		; get data
	cmp.l #-128,d0		; check to see if it is in the range
	blt.s .long		; -128 --> +127, and if yes then
	cmp.l #127,d0		; substitute:-
	bgt.s .long		; moveq.l #??,d3 / move.l d3,(a0)+

	move.b #$76,(a1)+	; moveq #??,d3
	move.b d0,(a1)+		; data
.mov	move.w #$20c3,(a1)+	; move.l d3,(a0)+
	addq.l #4,a0		; next long
	moveq.l #0,d7		; reset offset counter
	rts

.long	move.w #$20fc,(a1)+	; movei.l #????????,(a0)+
	move.l (a0)+,(a1)+	; data and next long
	moveq.l #0,d7		; reset offset counter
	rts

nothing	addq.l #8,d7		; increment offset
	addq.l #8,a0		; increment source 
	move.w #-1,do_lea	; lea is needed to get to the next pixels
	rts	
do_lea	dc.w -1			; a flag (wow!)

; routine to check for a movem.l substitute for movei.l

movem_test
	moveq.l #12,d2		; 12 free registers (max)
	lea 60(a0),a3		; 48 bytes movem (max) - check 56 ahead
.count	move.l -(a3),d3
	add.l -(a3),d3
	bne.s .possbl		; yes, range reached!
	subq.w #2,d2		; dec. register counter
	bne.s .count		; and loop
	bra.s .found
.possbl	move.l a0,a4		; now, how many zeroes in a row?
	move.l d2,-(a7)
	moveq.l #0,d4
.g1	move.l (a4)+,d6		; find first zero
	add.l (a4)+,d6
	beq.s .g2
	subq.w #2,d2
	bne.s .g1
	move.l (a7)+,d2
	bra.s .found
.g2	move.l (a4)+,d6		; count zeroes in row
	add.l (a4)+,d6
	bne.s .g3
	addq.w #2,d4
	subq.l #2,d2
	bne.s .g2
.g3	move.l (a7)+,d2
	cmp.l #8,d4		; 8+ in a row?
	bge.s .giveup		; if yes then not worth it or line-wrap.
.found	cmp.l #4,d2		; 4+ longs. worth it?
	bge.s .wow		; branch if yes!
.giveup	moveq.w #-1,d2		; set no movem flag
	rts

; if here then number of longs is in d2
.wow	move.l a0,a3
	moveq.l #0,d2
.tst	move.w (a3)+,d4
	or.w (a3)+,d4
	or.w (a3)+,d4
	or.w (a3)+,d4
	cmp.w #$ffff,d4
	bne.s .done
	addq.w #2,d2
	cmp.w #12,d2
	bne.s .tst
.done	tst.w d2
	beq.s .giveup
	cmp.w #4,d2
	blt.s .giveup

	move.w #-1,do_lea
	moveq.l #0,d7		; reset offset
	lea .m_tab,a3		; address of register lists
	move.w d2,d3		; save number of longs
	move.w d2,d4		; and again
	add d2,d2		; correct for word offset
	move.w 0(a3,d2),d2	; get register list for movem instruction
	move.l buff,a3		; movem data storage location
.copy	move.l (a0)+,(a3)+	; copy to storage
	subq.w #1,d3
	bne.s .copy
	move.l a3,buff		; reset pointer
	bsr .which_movem	; which movem WRITE to use?
	add d4,d4
	add d4,d4
	add d4,d7		; add to offset pointer
	moveq #1,d2		; set movem flag
	rts			; call the loop again

; table of register lists for movem instructions (0-12 registers)
.m_tab	dc.w $0,$0,$0,$0	;  inefficient movem's
	dc.w $71,$0		;  4 registers
	dc.w $c71,$0		;  6 registers
	dc.w $3c71,$0		;  8 registers
	dc.w $7c79,$0		; 10 registers
	dc.w $7c7f,$0		; 12 registers


.which_movem
	move.w -4(a1),d3	; previous opcode
	move.w -2(a1),d6	; previous word (possible offset)
	cmp.w #$41e8,d3		; was there an lea before this?
	beq.s .offmov		; yes, so branch!
	move.w #$4cd9,(a1)+	; opcode! movem.l (a1)+,registers
	move.w d2,(a1)+		; register list
	move.w #$48d0,(a1)+	; opcode! movem.l registers,(a0)
	move.w d2,(a1)+		; register list
	rts
.offmov	move.w #$4cd9,-4(a1)	; opcode! movem.l (a1)+,registers
	move.w d2,-2(a1)	; register list
	move.w #$48e8,(a1)+	; opcode! movem.l registers,?(a0)
	move.w d2,(a1)+		; register list
	move.w d6,(a1)+		; offset
	move.w d6,d7		; new offset - this saves 4 cycles/use
	rts
	
copy_movem_data
	move.l blocking,a3	; self modify lea instruction
	move.l a1,(a3)		; write address of movem data into lea
	lea mak_buf,a0		; copy to end of routine
	move.l buff,a3
	cmp.l a0,a3		; any movem data?
	bne.s .loop
	addq.l #6,(a2)		; skip lea at start
	rts
.loop	cmp.l a0,a3		; end of data?
	beq.s .out
	move.l (a0)+,(a1)+	; copy from buffer to rout end
	bra.s .loop
.out	rts

buff	dc.l mak_buf		; address of end of movem data

rotate	lea screen,a4		; address of screen
	moveq.l #4,d1		; number of planes
.inr1	move.l a4,a3		; copy to rotate pointer
r_len	equ *+2
	move.l #(121*160)/8,d0	; words to shift
	move.w sr,_sr
.inr2	move.w _sr,sr
	roxr.w (a3)		; shift right
	move.w sr,_sr
	addq.l #8,a3
	subq.l #1,d0
	bne.s .inr2
	addq.l #2,a4		; next plane
	subq.l #1,d1		; loop
	bne.s .inr1
	rts

_sr	dc.w 0

*********************************
* calc start addresses of chars *
*********************************
* used in fast offset routines. *
*********************************

pre_define
	moveq.l #$1f,d0
	lea ptable(pc),a3
def_1	addq.l #1,d0
	move.l d0,d1
	bsr.s which_line
	sub.l #$20,d1
	asl #4,d1
	add.l offset,d1
	add.l #eight,d1
	move.l d1,(a3)+
	cmp.l #$5e,d0
	bne.s def_1
	rts

which_line
	cmp.b #'R',d1
	blt.s gruff1
	move.l #(7*160)*5,offset
	rts
gruff1	cmp.b #'H',d1
	blt.s gruff2
	move.l #(7*160)*4,offset
	rts
gruff2	cmp.b #'>',d1
	blt.s gruff3
	move.l #(7*160)*3,offset
	rts
gruff3	cmp.b #'4',d1
	blt.s gruff4
	move.l #(7*160)*2,offset
	rts
gruff4	cmp.b #'*',d1
	blt.s gruff5
	move.l #7*160,offset
	rts
gruff5	move.l #0,offset
	rts

offset	dc.l 0 
ptable	ds.l $3f

; table of register lists for movem instructions (0-12 registers)
m_tab	dc.w $0,$0,$0,$0	;  inefficient movem's
	dc.w $71,$0		;  4 registers
	dc.w $c71,$0		;  6 registers
	dc.w $3c71,$0		;  8 registers
	dc.w $7c79,$0		; 10 registers
	dc.w $7c7f,$0		; 12 registers

delay		dc.w 5
delay_old	dc.w 5
text_off	dc.l text_add
text_nxt	dc.l 1
text_nxt1	dc.l 7

rts	rts
text_display
	subq.w #1,delay_old
	bpl.s rts
	move.w delay,delay_old
	move.l tpnt,a0
.getnxt	moveq.l #0,d0
	move.b (a0)+,d0
	bpl.s .char
	cmp.b #-2,d0
	bne.s .2
	move.w #2,delay
	move.l #text_add,text_off
	bra.s .getnxt
.2	cmp.b #-3,d0
	bne.s .3
	move.w #5,delay
	move.l #text_add,text_off
	bra.s .getnxt
.3	lea text(pc),a0
	move.l #text_add,text_off
	bra.s .getnxt
.char	move.l a0,tpnt
	sub.b #$20,d0
	add d0,d0
	add d0,d0
	lea ptable(pc),a0
	move.l (a0,d0),a0
	move.l screen1,a1
	move.l screen2,a2
	add.l text_off,a1
	add.l text_off,a2
x	set 0
	rept 8
	movep.l x(a0),d0
	movep.l d0,x(a1)
	movep.l d0,x(a2)
x	set x+160
	endr
	move.l text_nxt,d0
	add.l d0,text_off
	move.l text_nxt,-(a7)
	move.l text_nxt1,text_nxt
	move.l (a7)+,text_nxt1
	rts 

tpnt	dc.l text
;	dc.b "0123456789012345678901234567890123456789"
text	dc.b -3
	dc.b "        ------ WELCOME TO ------        ",-2
	dc.b "                                        ",-3
	dc.b "     THE PARALLAX BIG SPRITE SCREEN     ",-2
	dc.b "                                        ",-3 
	dc.b " THIS IS THE BEST SPRITE ROUT ON THE ST ",-2
	dc.b "                                        ",-3
	dc.b " ALL THESE PRETTY PIXELS ARE FROM XERUD ",-2
	dc.b "                                        ",-3 
	dc.b " (EXCEPT THIS FONT WHICH I COLOURED IN) ",-2
	dc.b "                                        ",-3 
	dc.b " MUSIC FROM SWITCHBLADE BY BEN DAGLISH. ",-2
	dc.b "                                        ",-3 
	dc.b " AS YOU CAN IMAGINE I'M OUT OF CPU TIME ",-2
	dc.b "                                        ",-3 
	dc.b " BUT I THINK YOU ARE GETTING YOUR VALUE ",-2
	dc.b "                                        ",-3 
	dc.b ' IN THIS "TOTAL APATHY" SCREEN......... ',-2
	dc.b "                                        ",-3 
	dc.b ' ANYONE WHO DOES A "BIG BLOCK" IS LAME! ',-2
	dc.b "                                        ",-3 
	dc.b "  THIS SCREEN IS MADE UP OF TWO OTHERS  ",-2
	dc.b "                                        ",-3 
	dc.b "  WHICH I DECIDED TO JOIN (ONE WAS THE  ",-2
	dc.b "                                        ",-3 
	dc.b "  PARALLAX-DEMO, AND THE OTHER WAS THE  ",-2
	dc.b "                                        ",-3 
	dc.b "  MEGA-SPRITE SCREEN - BOTH ARE HERE!)  ",-2
	dc.b "                                        ",-3 
	dc.b " THIS TEXT FILE LOOKS VERY FUNNY INDEED ",-2
	dc.b "                                        ",-3 
	dc.b " AS ALL LINES ARE EXACTLY 40 CHARS LONG ",-2
	dc.b "                                        ",-3 
	dc.b "   I'LL LEAVE YOU WITH THIS MESSAGE..   ",-2
	dc.b "                                        ",-3 
	dc.b "         TRY TO BEAT DIS ANYONE         ",-2
	dc.b "                                        ",-3 
	dc.b "    ------ THE LAW OF THE BBC ------    ",-2
	dc.b "                                        ",-2
	dc.b " WOW MAN, DEJA VU! ONE MONTH LATER BOTH ",-2
	dc.b "                                        ",-3 
	dc.b " ANDY AND MYSELF DECIDE TO OPTIMISE THE ",-2
	dc.b "                                        ",-3 
	dc.b " PARALLAX (WHICH WAS OVER 3 MONTHS OLD) ",-2
	dc.b "                                        ",-3 
	dc.b "     NOW TRY TO BEAT DIS (AND FAIL)     ",-2
	dc.b "                                        ",-3
	dc.b " (IF YOU DO I WILL ADMIRE YOU GREATLY!) ",-2
	dc.b "                                        ",-3
	dc.b "                                        ",-1 

	even
x_table				; sprite rout offset/screen offset
x	set 0			; for 0-319 (x)
	rept 20
	dc.l 0,x
	dc.l 4,x
	dc.l 8,x
	dc.l 12,x
	dc.l 16,x
	dc.l 20,x
	dc.l 24,x
	dc.l 28,x
	dc.l 32,x
	dc.l 36,x
	dc.l 40,x
	dc.l 44,x
	dc.l 48,x
	dc.l 52,x
	dc.l 56,x
	dc.l 60,x
x	set x+8
	endr

log_tab	ds.l 16				; pointers to actual
bbc_b	ds.l 16				; sprite routines
bbc_a	ds.l 16
bbc_d	ds.l 16
bbc_r	ds.l 16
bbc_e	ds.l 16
bbc_w	ds.l 16
bbc_c	ds.l 16

optimise_xy
	lea x_pos,a0
	lea x_end,a1
.loop3	move.w (a0),d0
	add d0,d0
	add d0,d0
	add d0,d0
	move.w d0,(a0)+
	cmp.l a0,a1
	bne.s .loop3
	lea trk_x,a0
	lea trk_xe,a1
.loop2	move.w (a0),d0
	add d0,d0
	add d0,d0
	add d0,d0
	move.w d0,(a0)+
	cmp.l a0,a1
	bne.s .loop2

	lea trk_y,a0
	lea trk_ye,a1
.loop1	move.w (a0),d0
	mulu #160,d0
	move.w d0,(a0)+
	cmp.l a0,a1
	bne.s .loop1

	lea y_pos,a0
	lea y_end,a1
.loop0	move.w (a0),d0
	mulu #160,d0
	move.w d0,(a0)+
	cmp.l a0,a1
	bne.s .loop0

	rts

sprite_init
	lea badrewc,a3
	lea screen+(160*122),a2
	move.l #((12*160)/4)-1,d0
.toscr	move.l (a3)+,(a2)+
	subq.l #1,d0
	bne.s .toscr

	bsr killtop

	move.l #(16*160)/8,r_len	
	move.l #screen+(16*160),r_len1
	lea screen+(160*122),a0		' B
	lea screen,a2
	bsr copy_it
	lea bbc_b,a2
	bsr make_routs
	bsr killtop

	lea screen+(160*122)+8,a0	' A
	lea screen,a2
	bsr copy_it
	lea bbc_a,a2
	bsr make_routs
	bsr killtop

	lea screen+(160*122)+16,a0	' D
	lea screen,a2
	bsr copy_it
	lea bbc_d,a2
	bsr make_routs
	bsr killtop

	lea screen+(160*122)+24,a0	' R
	lea screen,a2
	bsr copy_it
	lea bbc_r,a2
	bsr make_routs
	bsr killtop

	lea screen+(160*122)+32,a0	' E
	lea screen,a2
	bsr copy_it
	lea bbc_e,a2
	bsr make_routs
	bsr killtop

	lea screen+(160*122)+40,a0	' W
	lea screen,a2
	bsr copy_it
	lea bbc_w,a2
	bsr make_routs
	bsr killtop

	lea screen+(160*122)+48,a0	' C
	lea screen,a2
	bsr copy_it
	lea bbc_c,a2
	bsr make_routs
	bsr killtop

	rts

killtop	lea screen,a0			; erase the to of the screen!
	lea screen+(121*160),a2
.wipeup	clr.l (a0)+
	cmp.l a0,a2
	bne.s .wipeup
	rts

copy_it					; copy 16x13 sprite to screen
xx	set 0
	rept 14
	movem.l xx(a0),d0-1
	movem.l d0-1,xx(a2)
xx	set xx+160
	endr
	rts

sprite_vbl

CreW	move.l trackx+52,a1		; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	lea trk_x(pc),a1
	move.w (a1)+,d0
.write	move.l a1,trackx+52
	lea x_table,a3
	lea bbc_w,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen1,a0		; work screen base
	move.l tracky+52,a1		; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	lea trk_y(pc),a1
	move.w (a1)+,d1
.write2	move.l a1,tracky+52	
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	jsr (a2)			; call sprite routine

crEw	move.l trackx+48,a1		; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	lea trk_x(pc),a1
	move.w (a1)+,d0
.write	move.l a1,trackx+48
	lea x_table,a3
	lea bbc_e,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen1,a0		; work screen base
	move.l tracky+48,a1		; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	lea trk_y(pc),a1
	move.w (a1)+,d1
.write2	move.l a1,tracky+48	
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	jsr (a2)			; call sprite routine


cRew	move.l trackx+44,a1		; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	lea trk_x(pc),a1
	move.w (a1)+,d0
.write	move.l a1,trackx+44
	lea x_table,a3
	lea bbc_r,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen1,a0		; work screen base
	move.l tracky+44,a1		; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	lea trk_y(pc),a1
	move.w (a1)+,d1
.write2	move.l a1,tracky+44	
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	jsr (a2)			; call sprite routine


Crew	move.l trackx+40,a1		; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	lea trk_x(pc),a1
	move.w (a1)+,d0
.write	move.l a1,trackx+40
	lea x_table,a3
	lea bbc_c,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen1,a0		; work screen base
	move.l tracky+40,a1		; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	lea trk_y(pc),a1
	move.w (a1)+,d1
.write2	move.l a1,tracky+40	
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	jsr (a2)			; call sprite routine

breW	move.l trackx+36,a1		; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	lea trk_x(pc),a1
	move.w (a1)+,d0
.write	move.l a1,trackx+36
	lea x_table,a3
	lea bbc_w,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen1,a0		; work screen base
	move.l tracky+36,a1		; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	lea trk_y(pc),a1
	move.w (a1)+,d1
.write2	move.l a1,tracky+36	
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	jsr (a2)			; call sprite routine

brEw	move.l trackx+32,a1		; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	lea trk_x(pc),a1
	move.w (a1)+,d0
.write	move.l a1,trackx+32
	lea x_table,a3
	lea bbc_e,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen1,a0		; work screen base
	move.l tracky+32,a1		; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	lea trk_y(pc),a1
	move.w (a1)+,d1
.write2	move.l a1,tracky+32	
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	jsr (a2)			; call sprite routine

bRew	move.l trackx+28,a1		; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	lea trk_x(pc),a1
	move.w (a1)+,d0
.write	move.l a1,trackx+28
	lea x_table,a3
	lea bbc_r,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen1,a0		; work screen base
	move.l tracky+28,a1		; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	lea trk_y(pc),a1
	move.w (a1)+,d1
.write2	move.l a1,tracky+28
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	jsr (a2)			; call sprite routine

Brew	move.l trackx+24,a1		; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	lea trk_x(pc),a1
	move.w (a1)+,d0
.write	move.l a1,trackx+24
	lea x_table,a3
	lea bbc_b,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen1,a0		; work screen base
	move.l tracky+24,a1		; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	lea trk_y(pc),a1
	move.w (a1)+,d1
.write2	move.l a1,tracky+24	
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	jsr (a2)			; call sprite routine

baD	move.l trackx+20,a1		; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	lea trk_x(pc),a1
	move.w (a1)+,d0
.write	move.l a1,trackx+20
	lea x_table,a3
	lea bbc_d,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen1,a0		; work screen base
	move.l tracky+20,a1		; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	lea trk_y(pc),a1
	move.w (a1)+,d1
.write2	move.l a1,tracky+20
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	jsr (a2)			; call sprite routine

bAd	move.l trackx+16,a1		; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	lea trk_x(pc),a1
	move.w (a1)+,d0
.write	move.l a1,trackx+16
	lea x_table,a3
	lea bbc_a,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen1,a0		; work screen base
	move.l tracky+16,a1		; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	lea trk_y(pc),a1
	move.w (a1)+,d1
.write2	move.l a1,tracky+16	
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	jsr (a2)			; call sprite routine

Bad	move.l trackx+12,a1		; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	lea trk_x(pc),a1
	move.w (a1)+,d0
.write	move.l a1,trackx+12
	lea x_table,a3
	lea bbc_b,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen1,a0		; work screen base
	move.l tracky+12,a1		; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	lea trk_y(pc),a1
	move.w (a1)+,d1
.write2	move.l a1,tracky+12	
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	jsr (a2)			; call sprite routine

	rts

trackx	dc.l trk_x+140,trk_x+132,trk_x+124		; the
	dc.l trk_x+104,trk_x+96,trk_x+88		; bad
	dc.l trk_x+68,trk_x+60,trk_x+52,trk_x+44	; brew
	dc.l trk_x+24,trk_x+16,trk_x+8,trk_x+0		; crew
	 
trk_x	incbin trk_x.bin
trk_xe	dc.l $ffffffff

tracky	dc.l trk_y+140,trk_y+132,trk_y+124		; the
	dc.l trk_y+104,trk_y+96,trk_y+88		; bad
	dc.l trk_y+68,trk_y+60,trk_y+52,trk_y+44	; brew
	dc.l trk_y+24,trk_y+16,trk_y+8,trk_y+0		; crew

trk_y	incbin trk_y.bin
trk_ye	dc.l $ffffffff


x_ptr	dc.l x_pos
x_pos	incbin x_points.bin
x_end	dc.l $ffffffff

y_ptr	dc.l y_pos
y_pos	incbin y_points.bin
y_end	dc.l $ffffffff

*********************************************************

x_partb	rept 10
	dc.w 0,60,0,56,0,52,0,48,0,44,0,40
	dc.w 0,36,0,32,0,28,0,24,0,20,0,16,0,12,0,8,0,4,0,0
	dc.w 8,60,8,56,8,52,8,48,8,44,8,40
	dc.w 8,36,8,32,8,28,8,24,8,20,8,16,8,12,8,8,8,4,8,0
	endr

ytab	macro
xxx 	set 0
	rept 32
	dc.w 32*xxx,16*xxx
xxx	set xxx+1
	endr
	endm
y_table	ytab
	ytab
	ytab
	ytab
	ytab
	ytab
	ytab

xptr1	dc.l xpos1
xpos1	incbin parrx1.bin
xend1	dc.l $ffffffff

xptr2	dc.l xpos2
xpos2	incbin parrx2.bin
xend2	dc.l $ffffffff

yptr1	dc.l ypos1
ypos1	incbin parry1.bin
yend1	dc.l $ffffffff

yptr2	dc.l ypos2
ypos2	incbin parry2.bin
yend2	dc.l $ffffffff

music	incbin ledstorm.str
	even

screen1		dc.l ramtop-($7d00*1)	; working screen-base
screen2		dc.l ramtop-($7d00*2)	; display screen-base

old_res		ds.w 1			; entry resolution
old_screen	ds.l 1			; entry screen address
old_pall	ds.w 16			; entry pallette
back_tab	ds.l 16			; addresses of shifted gfx
top_tab		ds.l 16			; addresses of shifted gfx
mask_tab	ds.l 16			; addresses of shifted masks
back_gfx	ds.b (64*32)*16		; space for backdrop
top_gfx		ds.b (64*32)*16		; space for overlay
top_mask	ds.b (64*16)*16		; space for overlay masks
goes		ds.w 1			; frames till next character
ascii		ds.l 64			; table of addresses
buffer		ds.l 4*64
eight		ds.b 49*160
badrewc		ds.b 12*160
logrout		incbin newblok4.pi1
