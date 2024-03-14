


*** SCROLL UTILITIES: KORE EXTENSION #1
***
*** OK you bastard, here's the code....

setup_scroll:
;
;Use this to install a scroll into the system.  Before
;calling this for the first time, execute MOVE.L #sxdat,sxptr
;to reset the dataspace pointer and MOVE.L #listdat,listptr to
;reset the list data table.
;
;Call this with a0--> address of a list of the scroll 'tiles'
;d0=height of scroll-1
;a1---> list of block numbers in scroll order
;d1=no. of blocks in the scroll, always (2^x)-1 (ie 15,31,63,127..)
;d2=scroll no (0 to 7)
;d3=Initial scroll position

 move.l sxptr,a2	;PSI data address
 move.l listptr,a3	;Scroll list address
 move.l #sdl,a4		;Sprite info list
 asl #4,d2		;Allow up to 4 longs per entry
 move.l a2,0(a4,d2.w)	;Place start-of-PSI address
 move.l a3,4(a4,d2.w)	;Place scroll-list address
 move d0,8(a4,d2.w)	;Scroll height
 move d1,10(a4,d2.w)	;No. blocks
 move d3,12(a4,d2.w)	;Initial scroll position
 move #0,14(a4,d2.w)	;Fractional part of scroll position

;The next bit expands the sprites in the list pointed to by a0
;and puts their start addresses into a temporary storage list
;at TSDA. These addresses are used to construct the scroll list.

 move.l #tsda,a5	;Temp storage list
 move #0,d4		;Sprite no. initially zero
xl: move.l (a0)+,d6	;Get sprite def address
 beq xle		;Negative terminates
 move.l d6,a6		;Transfer to an address register
 move.l a2,0(a5,d4.w)	;Save address of start of PSI data
 bsr scroll_xpand	;Do sprite expansion
 add.l #4,a5		;Point to next sprite address
 bra xl			;Loop until all sprites are expanded
xle: move.l a2,sxptr	;Update sprite expansion pointer
 move.l #tsda,a5	;Get TSL address back


;This bit uses the temporary address list to generate the actual
;scroll list.

genlist: move (a1)+,d4	;Get tile #
 asl #2,d4		;Multiply x4 for long words
 move.l 0(a5,d4.w),(a3)+	;Place the sprite address in the list
 dbra d1,genlist	;d1 holds total # tiles in list
 move.l a3,listptr	;update the scroll list pointer
 rts

scroll_xpand:
;
;Expand sprite at (a6) to memory at (a2)
;
 movem.l d0-d7/a3-a6,-(a7)	:grab some reggies
 lea 8(a6),a6			;skip sprite header info
sxp0: move #0,d1		;PSI shift counter
sxpa: move.l a6,a5		;use a copy of a5 to address
 move #3,d4			;4 bitplanes
xxo: move.l #0,d2
 move.l #0,d3			;Bitplane info will go here
 move (a5),d2
 move 8(a5),d3			;Fetch bitplane stuff
 tst d1
 beq bo_shft			;No shift if d1=0
 ror.l d1,d2
 ror.l d1,d3			;Shift the data
bo_shft: move d2,(a2)+
 swap d2
 or d2,d3
 move d3,(a2)+
 swap d3
 move d3,(a2)+			;Store 3 words of PSI data
 lea 2(a5),a5			;Step to next b'plane
 dbra d4,xxo			;Do four bitplanes
 add #2,d1			;Gen next shift
 cmp #16,d1
 bne sxpa			;Generate all shift data this scanline
 lea 16(a6),a6			;Skip down one scanline
 dbra d0,sxp0			;Do for all scanlines
 movem.l (a7)+,d0-d7/a3-a6	:ungrab some reggies
 rts				;finish

draw_scroll:
;
;This routine does the business. You pass a screen offset in d0.L
;(eg line 140 = 140*160 = 22400) and the logical scroll no. in d1.
;The routine operates on whatever screen is pointed to by ascreen.

 move.l ascreen,a1
 move.l #sdl,a0
 asl #4,d1
 move.l 4(a0,d1.w),a3	;a3 is scroll-list
 move 8(a0,d1.w),d2	;scroll height
 move 10(a0,d1.w),d3	;add and
 add.l d0,a1		;a1 now points to position on ascreen
 move 12(a0,d1.w),d1	;get current scroll position
 move d1,d0
 and #$0e,d0
 eor #$0e,d0		;d0 has PSI number
 asl #2,d0		;x8
 move d0,d4		;d4=psi no times 8
 asl #1,d0		;d0=psi times 16
 add d4,d0		;d0=psi times 24
 move d1,d4
 asr #4,d4
 and #1,d4		;d4 set if scroll value >15 
 and.l #$ffff,d0	;long for add to raw address
 and #$ffe0,d1
 asr #3,d1		;lose ls pentybble of scroll addr
 asl #2,d3		;align the ander to long bounds
 tst d4
 beq zokay
 add #4,d1		;align if >16
zokay: and d3,d1		;ensure first read dont o'flow

;prelims done. The actual scroll is drawn one scan line at a time
;and occurs in three stages. Stage one: merge leading edge of
;current sprite with trailing edge of previous (held in d6/d7), and
;plot. Stage two: draw centre portion of sprite. Stage three:
;prepare a new trailing edge in d6/d7 but do not plot.  This loop
;iterates 11x to cover one whole screen line, then loops again
;according to the scrollheight counter in d2.
;
;To clip the scroll correctly, the following actions are taken
;according to the lowest 5 bits of the scroll offset:
;
;If the offset is <16, then:
;
;For the FIRST sprite only the merge prep is performed;
;For the LAST sprite the merge prep data is written to the screen.
;
;If the offset is >=16, then:
;
;For the FIRST sprite stages 2 and 3 are performed;
;For the LAST sprite only stages 1 and 2 are performed.
;
;OK, let's do it:

scroller: move #10,d5	;DBRA for slivers across screennnnnnn
 move d2,-(a7)		;save lines counter
 move d1,d2
 swap d1
 move d2,d1		;keep copy of offset in d1
drscrl: move.l #0,d6	;Clear those funky 
 move.l #0,d7		;left-hand-edge merge things
 move.l 0(a3,d1.w),a0	;get address of sprite
 add.l d0,a0			;alighn to PSI

;OK, this is now just before the first sprite, so I can do
;those checks which only need be done on sprite #1:

 tst d4			;d4 is nonzero if scroll pos >15
 bne grt_15		;go and do that stuff
 lea 4(a0),a0		;align a0 with third word of plane 1 data
 bra prep_merge		;and jump to the mergeprep bit

;and this is what happens if its >15...

grt_15: lea 2(a0),a0	;align a0 with centre bit of sprite
 bra do_middle		;jump to the bit which does th' middle

;This is the main loop that's iterated to draw all the bits of
;one scanline of scroll.

scrl_loop: move (a0),d2	;Fetch first bit of plane 1
 swap d6		;Get plane 1 TE of previous
 or d6,d2		;Merge it in
 move d2,(a1)+		;put it onscreen

;the next bit does the same for the next 3 'planes...

 move 6(a0),d2		;plane 2..
 swap d6
 or d6,d2
 move d2,(a1)+

 move 12(a0),d2		;plane 3..
 swap d7		;(TE for 3/4 is in d7)
 or d7,d2
 move d2,(a1)+

 move 18(a0),d2
 swap d7
 or d7,d2
 move d2,(a1)+		;that's the leading edge done.
 lea 2(a0),a0		;point at sprite myddle

;Now it is time for the last-sprite checks.

 tst d5			;will be 0 if last sprite
 bne do_middle		;it aint
 tst d4			;bit 5 of scroll pos...
 bne next_spryte	;don't do it if >15

do_middle: move (a0),(a1)+	;get centre bit o'sprite plane 1
 move 6(a0),(a1)+		;plane 2
 move 12(a0),(a1)+		;plane 3
 move 18(a0),(a1)+		;an' plane 4

;That was easy, yeah? An' quite qwik.
;Now:

 tst d5			;Merge prep never done on last sprite
 beq next_lyne		;fur obvious reasons!
 
;Do prepmerge (put sprite trail edge data in d6/d7)

xnexx: lea 2(a0),a0		;Point to sprite trailedge data
prep_merge: move (a0),d6	;Get plane1
 swap d6			;Save it in hi word
 move 6(a0),d6			;Add plane 2
 move 12(a0),d7			;plane 3
 swap d7			;in hi word..
 move 18(a0),d7			;and that old plane 4.

;Address the next sprite in the scroll list..
 
next_spryte: add #4,d1	;point to next sprite in the scroll list
 and d3,d1		;prevent overflow
 move.l 0(a3,d1.w),a0	;nab address of sprite
 add.l d0,a0		;alighn to PSI

;At this point a1 is already pointing to the next screen loke
;and d6/d7 are loaded with the merge data so all I need to do is

 dbra d5,scrl_loop	;to complete the first scan line of scroll.

;When the code comes out by here, a whole scanline has been
;drawn. By this time a1 has been incremented by 2x8x10, which is happily  
;enough a whole scanline down and it's ready. But the scroll list
;pointer has been incremented 10x, so we need to execute

next_lyne: swap d1	;retrieve old d1 value

;Now, VSKIP is added to allow for groovy special FX like
;expansion and inversion of scroll data:

 add.l vskip,a1

;Now, the PSI-aligner needs to point to sprite data at +1 scanline
;from the base; I happen to know that it's 192 bytes down:

 add.l #192,d0		;point to +1 scan PSI

;okay, all ready, remember that height count was in d2...

 move (a7)+,d2		;retrieve old line ctr
 dbra d2,scroller

; to draw the whole scroll region.

 rts			;You understand that? Nor did I.

vskip: dc.l 0

 
tsda: ds.l 64
sxdat: ds.b 50000		;Space for expanded scroll data
listdat: ds.b 4000
sxptr: dc.l sxdat		;Pointer to free dataspace
listptr: dc.l listdat
;
;SXLIST is a list of the scroll sprites you want expanding
;use Sprite Type III defs 32xn where n=integer >0

sxlist: dc.l sxlist

;SDL is the Scroll Data List; start address of scroll PSI data
;and scroll list, height and stuff stored here

sdl: ds.l 64		;room for up to 16 scrolls


