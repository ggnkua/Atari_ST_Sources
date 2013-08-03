;
; D-Bug intro #1
;
; Coded by Cyrano Jones
;

ramtop		equ $380000
screen		equ ramtop-$9a00
no_stars	equ 55
mak_buf		equ screen+(160*100)
scr_end		equ (160*202)+152
;vbl_timer

	move.l 4(a7),a5			; Gemdos MEM_SHRINK
	lea $2000.w,a7			; Safe Stack on 512!
	move.l #$200,-(a7)
	move.l a5,-(a7)
	move.l #$4a0000,-(a7)
	trap #1
	lea 12(a7),a7

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

game1	dc.b "a:\title1.tos",0
	even
game2	dc.b "a:\title2.tos",0
	even

code	move.w #$2700,sr
	move.b #0,$ffff8260.w
	move.b $ffff8201.w,old_scr+1
	move.b $ffff8203.w,old_scr+2
	movem.l $ffff8240.w,d0-7
	movem.l d0-7,old_pal
	move.l  $70.w,old_vbl
	move.l $118.w,old_kb
	move.w #$0555,sprites+4
	movem.l sprites+2,d0-7
	movem.l d0-7,sprite_col

	move.l screen2,a0
	lea ramtop,a1
.wipex	clr.w (a0)+
	cmp.l a0,a1
	bne.s .wipex

	move.b screen2+1,$ffff8201.w
	move.b screen2+2,$ffff8203.w
	move.l screen2,a0
	lea waittx,a1
	lea 94*160(a0),a0
	jsr print
	move.l #$00000777,d0
	moveq.l #0,d1
	move.l d1,d2
	move.l d2,d3
	move.l d3,d4
	move.l d4,d5
	move.l d5,d6
	move.l d6,d7
	movem.l d0-7,$ffff8240.w

	jsr pre_define
	jsr init_stars
	bsr init_64x64
	bsr optimise_x
	lea end_tab,a0
	move.l #$454effff,-(a0)

	move.b #$12,d0
	bsr s_ikbd
	move.b #$1a,d0
	bsr s_ikbd
	move.l #my_key,$118.w

	move.b	#2,$484
	bclr	#3,$ffffa17

	move.l screen2,a0
	lea ramtop,a1
.wipe	clr.w (a0)+
	cmp.l a0,a1
	bne.s .wipe

	moveq	#0,d0	; 1-7 is possible
	JSR	MUS

	move.b $fffffa1b.w,xa1b
	move.b $fffffa07.w,xa07
	move.b $fffffa13.w,xa13
	bclr.b #5,$fffffa15.w		; enable timer C
	bclr.b #5,$fffffa09.w		; on all four status bits
	bclr.b #5,$fffffa0d.w		
	bclr.b #5,$fffffa11.w		
	move.l #hbl,$120.w		; HBL vector
	bset #0,$fffffa07.w		; M.F.P. set
	bset #0,$fffffa13.w

	lea titles,a1
	move.l screen1,a0
	add.l #6+(193*160),a0
	jsr print
	lea titles,a1
	move.l screen2,a0
	add.l #6+(193*160),a0
	jsr print

	lea sprite_col+16,a0
	move.l #$07770777,d0
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)+
	move.l d0,(a0)

	move.l #vbl,$70.w
	move.w #$2300,sr

space	cmp.b #$2,key
	bne.s .2
	move.l #game1,filename
	bra.s .quit
.2	cmp.b #$3,key
	bne.s space
	move.l #game2,filename

.quit	move.l old_vbl,$70.w
	movem.l old_pal,d0-7
	movem.l d0-7,$ffff8240.w

	move.b xa1b,$fffffa1b.w
	move.b xa07,$fffffa07.w
	move.b xa13,$fffffa13.w
	bset.b #5,$fffffa15.w		; enable timer C
	bset.b #5,$fffffa09.w		; on all four status bits
	bset.b #5,$fffffa0d.w		
	bset.b #5,$fffffa11.w		

	move.l old_kb,$118.w
	move.b #$80,d0
	bsr s_ikbd
	move.b #$1,d0
	bsr s_ikbd

	move.b #$f0,$fffffa23.w

	lea $ffff8800.w,a0
	move.l #$8080000,(a0)
	move.l #$9090000,(a0)
	move.l #$a0a0000,(a0)

	move.b old_scr+1,$ffff8201.w
	move.b old_scr+2,$ffff8203.w
	move.l old_scr,a0
	move.l #($7d00/4)-1,d0
.wipe	clr.l (a0)+
	dbra d0,.wipe

	rts

my_key	move.b $fffffc02.w,key		; keyboard 'scanner'
	bclr.b #6,$fffffa11.W
	rte
key	dc.l 0

s_ikbd	btst #1,$fffffc00.w
	beq.s s_ikbd
	move.b d0,$fffffc02.w
	rts

old_vbl	dc.l 0
old_pal	ds.w 16
old_kb	ds.l 1
xa07	dc.w 0
xa1b	dc.w 0
xa13	dc.w 0
sprite_col	ds.w 16

hbl	movem.l a0/d0,-(a7)
	move.w #$fa21,a0
	move.b (a0),d0
hangtheraster	cmp.b (a0),d0
	beq.s hangtheraster
        clr.b $ffff820a.w     	; 60 Hz
        moveq #3,d0
.2     	nop                 	; wait a while
        dbf d0,.2
	move.b #2,$ffff820a.w  	; 50 Hz
x	set 0
	rept 8
	move.l font+2+x,$ffff8240+x.w
x	set x+4
	endr		
	move.b #0,$fffffa21.w
	movem.l (a7)+,a0/d0
	bclr #0,$fffffa0f.w  	; end of interrupt 
	rte


vbl	movem.l d0-a6,-(a7)

	movem.l sprite_col,d0-7
	movem.l d0-7,$ffff8240.w

	move.b screen1+1,$ffff8201.w
	move.b screen1+2,$ffff8203.w
	move.l screen1,d0
	move.l screen2,screen1
	move.l d0,screen2

	move.l #hbl,$120.w

	move.b #0,$fffffa1b.w
	move.b #199,$fffffa21.w
	move.b #8,$fffffa1b.w

	moveq.l #0,d0
	move.l d0,d1
	move.l d1,d2
	move.l d2,d3
	move.l d3,d4
	move.l d4,d5
	move.l d5,d6
	move.l d6,d7
	move.l d7,a0
	move.l a0,a1

	move.l save_b,a2
	move.l save_u,a3
	move.l save_g,a4
	move.l save__,a5
	move.l save_d,a6
off	set 0
	rept 50
	movem.l d0-7/a0-1,off(a2)
	movem.l d0-7/a0-1,off(a3)
	movem.l d0-7/a0-1,off(a4)
	movem.l d0-7/a0-1,off(a5)
	movem.l d0-7/a0-1,off(a6)
off	set off+160
	endr

	bsr do_starfield

sprite_g
	move.l g_ptrx,a1		; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	move.w track_x,d0
	lea track_x+2(pc),a1
.write	move.l a1,g_ptrx
	lea x_table,a3
	lea table_g,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen2,a0		; work screen base
	move.l g_ptry,a1		; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	move.w track_y,d1
	lea track_y+2(pc),a1
.write2	move.l a1,g_ptry		
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	move.l save_gb,save_g
	move.l a0,save_gb
	jsr (a2)			; call sprite routine

sprite_u
	move.l u_ptrx,a1		; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	move.w track_x,d0
	lea track_x+2(pc),a1
.write	move.l a1,u_ptrx
	lea x_table,a3
	lea table_u,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen2,a0		; work screen base
	move.l u_ptry,a1		; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	move.w track_y,d1
	lea track_y+2(pc),a1
.write2	move.l a1,u_ptry		
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	move.l save_ub,save_u
	move.l a0,save_ub
	jsr (a2)			; call sprite routine

sprite_b
	move.l b_ptrx,a1		; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	move.w track_x,d0
	lea track_x+2(pc),a1
.write	move.l a1,b_ptrx
	lea x_table,a3
	lea table_b,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen2,a0		; work screen base
	move.l b_ptry,a1		; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	move.w track_y,d1
	lea track_y+2(pc),a1
.write2	move.l a1,b_ptry		
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	move.l save_bb,save_b
	move.l a0,save_bb
	jsr (a2)			; call sprite routine

sprite__
	move.l __ptrx,a1		; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	move.w track_x,d0
	lea track_x+2(pc),a1
.write	move.l a1,__ptrx
	lea x_table,a3
	lea table__,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen2,a0		; work screen base
	move.l __ptry,a1		; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	move.w track_y,d1
	lea track_y+2(pc),a1
.write2	move.l a1,__ptry		
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	move.l save__b,save__
	move.l a0,save__b
	jsr (a2)			; call sprite routine

sprite_d
	move.l d_ptrx,a1		; get sprite x-point
	move.w (a1)+,d0
	bpl.s .write
	move.w track_x,d0
	lea track_x+2(pc),a1
.write	move.l a1,d_ptrx
	lea x_table,a3
	lea table_d,a2
	add.w 2(a3,d0),a2		; pointer into sprite table
	move.l (a2),a2			; address of sprite routine
	move.l screen2,a0		; work screen base
	move.l d_ptry,a1		; get sprite y-point
	move.w (a1)+,d1
	bpl.s .write2
	move.w track_y,d1
	lea track_y+2(pc),a1
.write2	move.l a1,d_ptry		
	add.l 4(a3,d0),d1		; horizontal offset
	add.w d1,a0			; add to screen offset
	move.l save_db,save_d
	move.l a0,save_db
	jsr (a2)			; call sprite routine

	dc.w $4eb9
scroll_rout	dc.l scrpos1

	JSR MUS+4

	ifd vbl_timer
	move.w #$777,$ffff8240.w
	clr.w $ffff8240.w
	endc

	movem.l (a7)+,d0-a6
	rte

save_d	dc.l ramtop-$9a00
save__	dc.l ramtop-$9a00
save_b	dc.l ramtop-$9a00
save_u	dc.l ramtop-$9a00
save_g	dc.l ramtop-$9a00

save_db	dc.l ramtop-$9a00
save__b	dc.l ramtop-$9a00
save_bb	dc.l ramtop-$9a00
save_ub	dc.l ramtop-$9a00
save_gb	dc.l ramtop-$9a00

addr	equ 160*120
init_64x64
	move.l #(50*160)/8,r_len

	lea sprites+34,a0
	move.l screen1,a1
	add.l #addr,a1
	move.l #((50*160)/4)-1,d0
.move	move.l (a0)+,(a1)+
	dbra d0,.move

	move.l screen1,a3
	add.l #addr,a3
	bsr to_screen
	lea logrout,a1			; address to put routine at
	lea table_d(pc),a2		; address to make table at
	bsr make_routs			; build mega-fast sprite routines!

	move.l screen1,a3
	add.l #addr+32,a3
	bsr to_screen
	lea table__(pc),a2		; address to make table at
	bsr make_routs			; build mega-fast sprite routines!

	move.l screen1,a3
	add.l #addr+64,a3
	bsr to_screen
	lea table_b(pc),a2		; address to make table at
	bsr make_routs			; build mega-fast sprite routines!

	move.l screen1,a3
	add.l #addr+96,a3
	bsr to_screen
	lea table_u(pc),a2		; address to make table at
	bsr make_routs			; build mega-fast sprite routines!

	move.l screen1,a3
	add.l #addr+128,a3
	bsr to_screen
	lea table_g(pc),a2		; address to make table at
	bsr make_routs			; build mega-fast sprite routines!

	bsr clear
	rts

to_screen
	bsr clear

	lea screen,a4
	move.l #63,d0
.move	movem.l (a3),d1-7/a6
	movem.l d1-7/a6,(a4)
	lea 160(a4),a4
	lea 160(a3),a3
	dbra d0,.move
	rts

clear	lea screen,a4
	move.l #((120*160)/4)-1,d0
.wipe	clr.l (a4)+
	dbra d0,.wipe
	rts

table_d	ds.l 16
table__	ds.l 16
table_b	ds.l 16
table_u	ds.l 16
table_g	ds.l 16

***************************************************************************
*************************** The Sprite Routs ******************************
***************************************************************************
*******  Sprite Routines! - Builds the most optimesed rout possible  ******
***************************************************************************
******* Law of The Bad Brew Crew, 11.07.91. I am very chuffed indeed ******
***************************************************************************
*
* D7 is set to 0 (replace clr.l with move.l d7).
* A0 points to screen (increments where possible, lea's gaps).
* A1 points to movem buffer and is incremented (only if used).
* d0-d6/a2-a6 are used in movem's and various moveq combinations.
*
* Only edges of sprites are 'sprited'. middles are blocked.
* If the mask is 0 but there is data then move.l d7,?(a0) is substituted. 
* If there is no 'or' data then that long is skipped.
* If ori.l can be replaced with moveq.l #?,d2 or.l d2,?(a0) then it is.
* An empty long in a block will be replaced by move.l d7,????(a0).
* If moveq.l #?,d3 move.l d3,?(a0) can replace a movei.l #?,?(a0) it does.
* All ori.w opcodes are removed because the lea required would cancel out.
* If no movem's are present then the lea at start of rout is removed.
* If movem list can replace strings of between 4-12 (even) movei's it does.
* If movem used and last was also movem the lea is overwritten and an
*      offset is used (saves 4 cycles/use)
*
* That's about it. Try to beat dis! (dese?)

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
	cmp.l #screen+(50*160),a0
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

sprite	move.w (a0),d0		; make mask
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
	cmp.w #14,d2
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

optimise_x
	lea track_x,a0
	lea trackxe,a1
.loop3	move.w (a0),d0
	add d0,d0
	add d0,d0
	add d0,d0
	move.w d0,(a0)+
	cmp.l a0,a1
	bne.s .loop3
	rts

scrpos1	bsr next_char
	bsr multiple_scroller
	bsr end_last_character
	bsr first_eight
	move.l #scrpos2,scroll_rout
	rts

scrpos2	bsr multiple_scroller
	bsr first_sixteen
	move.l #scrpos3,scroll_rout
	rts

scrpos3	bsr multiple_scroller
	bsr middle_sixteen
	move.l #scrpos4,scroll_rout
	rts

scrpos4	bsr multiple_scroller
	bsr end_sixteen
	bsr save_last_eight
	move.l #scrpos1,scroll_rout
	rts

end_last_character
	lea movep_buff(pc),a0
	move.l screen2,a1
	add.l #scr_end,a1
xxx	set 0
	rept 4
	movem.l (a0)+,d0-7
	movep.l d0,xxx(a1)
	movep.l d1,xxx+160(a1)
	movep.l d2,xxx+320(a1)
	movep.l d3,xxx+480(a1)
	movep.l d4,xxx+640(a1)
	movep.l d5,xxx+800(a1)
	movep.l d6,xxx+960(a1)
	movep.l d7,xxx+1120(a1)
xxx	set xxx+1280
	endr
	rts

first_eight
	lea font+34,a0
	add.l offset,a0
	move.l screen2,a1
	add.l #scr_end,a1
xxx	set 0
	rept 32
	movep.l xxx(a0),d0
	movep.l d0,xxx+1(a1)
xxx	set xxx+160
	endr
	rts

first_sixteen
	lea font+34,a0
	add.l offset,a0
	move.l screen2,a1
	add.l #scr_end,a1
xxx	set 0
	rept 32
	move.l xxx(a0),xxx(a1)
	move.l xxx+4(a0),xxx+4(a1)
xxx	set xxx+160
	endr
	rts

middle_sixteen
	lea font+34,a0
	add.l offset,a0
	move.l screen2,a1
	add.l #scr_end,a1
xxx	set 0
	rept 32
	movep.l xxx+1(a0),d0
	movep.l d0,xxx(a1)
	movep.l xxx+8(a0),d0
	movep.l d0,xxx+1(a1)
xxx	set xxx+160
	endr
	rts

end_sixteen
	lea font+42,a0
	add.l offset,a0
	move.l screen2,a1
	add.l #scr_end,a1
xxx	set 0
	rept 32
	move.l xxx(a0),xxx(a1)
	move.l xxx+4(a0),xxx+4(a1)
xxx	set xxx+160
	endr
	rts

save_last_eight
	lea font+42,a0
	add.l offset,a0
	lea movep_buff(pc),a1
xxx	set 0
	rept 32
	movep.l xxx+1(a0),d0
	move.l d0,(a1)+
xxx	set xxx+160
	endr
	rts

movep_buff	ds.l 32

multiple_scroller
	move.l screen2,a6
	add.l #scr_end-144,a6
xxx	set 0				use movem.l to move the
	rept 32				screen 16 pixels at a time.
	movem.l xxx(a6),d0-a5		by using two screens you
	movem.l d0-a5,xxx-8(a6)		get an 8-pixel scroller!
	movem.l xxx+56(a6),d0-a5
	movem.l d0-a5,xxx+48(a6)
	movem.l xxx+112(a6),d0-a1
	movem.l d0-a1,xxx+104(a6)
xxx	set xxx+160
	endr
	rts

next_char
	moveq.l #0,d0			stop the *4 buggering up
	move.l text_pos,a0		get current character address
	move.b (a0)+,d0			pull character
	move.l a0,text_pos		save next character address
	cmp.b #-1,d0			wrap?
	bne.s nowrap			branch if not
	move.b #' ',d0			yes, so restore text
	move.l #text,text_pos		postitions
nowrap	sub.b #' ',d0
	add.l d0,d0			get offset into character grafix
	add.l d0,d0
	lea ptable,a0
	move.l (a0,d0),offset		store in offset
	rts				

text_pos dc.l text
text	DC.B "                 "

	DC.B "D-BUG PRESENT DISK XXX         "

	DC.B "                  "
	dc.b -1
	even

old_scr	dc.l 0

screen1	dc.l ramtop-($9a00*1)
screen2	dc.l ramtop-($9a00*2)
ptable	ds.l $3f
offset	ds.l 1 

d_ptrx	dc.l track_x+64
__ptrx	dc.l track_x+48
b_ptrx	dc.l track_x+32
u_ptrx	dc.l track_x+16
g_ptrx	dc.l track_x
track_x	incbin asl_x.bin
trackxe	dc.l $ffffffff

d_ptry	dc.l track_y+64
__ptry	dc.l track_y+48
b_ptry	dc.l track_y+32
u_ptry	dc.l track_y+16
g_ptry	dc.l track_y
track_y	incbin asl_y.bin
	dc.l $ffffffff
do_starfield
	move.l screen1,a5
	move.l screen2,a6

	lea draw_tab(pc),a0
	lea wipe_tab(pc),a1

	moveq.l #0,d7
	move.w #'EN',d3

	rept no_stars
	move.l (a1),a2
	move.w (a2)+,d0
	move.w (a2)+,d1
	dc.w $6b04		; bmi.s .next1
	move.w d7,(a6,d1.w)
	cmp.w d3,d0
	dc.w $6604		; bne.s .n1
	lea star(pc),a2
	move.l a2,(a1)+		; .next1
	endr

	rept no_stars
	move.l (a0),a2
	move.w (a2)+,d0
	move.w (a2)+,d1
	dc.w $6b04		; bmi.s .next1
	or.w d0,(a5,d1.w)
	cmp.w d3,d0
	dc.w $6604		; bne.s .n1
	lea star(pc),a2
	move.l a2,(a0)+		; .n1
	endr
	rts

draw_tab	ds.l no_stars
wipe_tab	ds.l no_stars

star	incbin stosfld1.dat
end_tab	dc.b 'EN',$ff,$ff
	even

n1		dc.l 1
n2		dc.l 7
next_add	dc.l 0

; call with a1 pointing at text
;           a0 pointing at plotting address

print	move.l a0,next_add
	move.l #1,n1
	move.l #7,n2
.loop	moveq.l #0,d0
	move.b (a1)+,d0
	bpl.s .write
	cmp.b #-1,d0
	beq.s .wrap
.nextline
	move.l #1,n1
	move.l #7,n2
	move.l next_add,a0
	add.l #160*9,a0
	move.l a0,next_add
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
	add.l n1,a0
	move.l n1,-(a7)
	move.l n2,n1
	move.l (a7)+,n2
	rts

;	dc.b "0123456789012345678901234567890123456789"
waittx	dc.b "         PLEASE WAIT . THINKING",-1
	even
titles	dc.b "      1- XXXXXXXXXXXXX  2- XXXXXXX",-1
	even

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

font	incbin font.pi1
	even

MUS	incbin dizzy.mus
	even

logrout	dc.l 0

; ALL DATA / CODE BELOW HERE WILL GET TRASHED BY THE SPRITES

sprites	incbin d_bug.dat
	even
table
x	set 0
	rept 20
	dc.w $8000,x
	dc.w $4000,x
	dc.w $2000,x
	dc.w $1000,x
	dc.w $800,x
	dc.w $400,x
	dc.w $200,x
	dc.w $100,x
	dc.w $80,x
	dc.w $40,x
	dc.w $20,x
	dc.w $10,x
	dc.w $8,x
	dc.w $4,x
	dc.w $2,x
	dc.w $1,x
x	set x+8
	endr

init_stars
; routine to find the star address in table for each star to plot

	lea star,a0		; pointer into table
	lea draw_tab,a1		; points to star plotting buffer
	lea wipe_tab,a2		; points to star erasing buffer
	lea table(pc),a3	; points to conversion table
	move.l #no_stars-1,d7	; stars to init
.loop	move.w (a0)+,d0			; holds x
	move.w (a0)+,d1			; holds y
	cmp.w #-1,d0
	bne.s .loop
	move.l a0,(a2)+
	move.l a0,(a1)
	addq.l #4,(a1)+
	dbra d7,.loop

; routine to convert silly star co-ordinates into something for a shit-hot
; plotting rout to handle.
_pisser_
	lea star-4,a0
	lea end_tab,a1
.loop	addq.l #4,a0
	move.w (a0),d0
	move.w 2(a0),d1
	cmp.l a0,a1
	beq.s .all_done
	cmp.w #-1,d0
	beq.s .loop
	asr #3,d0		; delete this you twat!
	add d0,d0
	add d0,d0
	move.w (a3,d0.w),(a0)
	move.w 2(a3,d0.w),2(a0)
	add.w d1,2(a0)
	bra.s .loop
.all_done
	rts

pre_define		
	moveq.l #$1f,d0		routine to calculate the start
	lea ptable,a3		address of each character as an
def_1	addq.l #1,d0		offset from 0 bytes in a PI1 file
	move.l d0,d1
	bsr.s which_line
	sub.l #$20,d1
	asl #4,d1
	add.l offset,d1
	move.l d1,(a3)+
	cmp.l #$5e,d0
	bne.s def_1
	rts

which_line
	cmp.b #'R',d1
	blt.s gruff1
	move.l #(31*160)*5,offset
	rts
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
gruff5	move.l #0,offset
	rts

