	.extern	DSPRAMTEST
 
*       Ram test
* 06FEB92 : RWS : added (non-existant) DSP RAM test for sparrow.
* 27MAR92 : RWS : DSP SRAM test now exists and works
*       Dec 22, 88: test video RAM during testmid, blink * during testhi
*       Nov 6, 87: Rev. 4.0: moved stack during high mem test to 400-4ff
*               to prevent overflow into variable space.
*       April 13, 87 rev. 3.61: fix dspbadb and print size routines
*       Nov 24, 1986  Fix bug: error stack overflow into system stack
*               and reduce errors saved. Also quit if got max errors.
*       Mask keyboard interrupt while testing low RAM
*          Verify restore of low RAM.
*       Added video RAM test
*       Does rts to get back to calling sequence.
*       Reports data written, data read.
*       Revised from 3.1: 64k address error displays same error info
*          as other failure modes. Correct "save error" portion of 
*          address test.
*       Rev. 3.6: hilo test writes checkerboard; added video ram test

	.text
	
*       Test in 3 stages: 1) low--from 8 to bottom of error stack (wherever)
*                         2) mid--top of error stack to 64k boundary
*                         3) high--64k to top (128k or 520k)
*       Tests to perform are:
*       1. write complemented data to error stack.
*       2. write a word all 1s, verify, write all 0s, verify, next word.
*       3. write address low word to all cells, verify.
*       4. write address low word, but bytes swapped.
*       5. test incrementing pattern while video is displaying this RAM

*       On error: 
*               type 0 test--system ram 
*                       print error code
*                       address, data written, data read
*                       print out suspect chip no.
*               type 1 test--not system RAM, 1s and 0s test 
*                       same as type 1
*               type 2 test--addressing test
*                       print error code
*                       address, data, etc.
*               type 3 test--64k addressing
*                       print error code

*       RAM memory map:
*       C-3ff           System RAM, copy to safe area (1000 or above) and test
*       400-4ff         Stack while testing high memory
*       500-fff         Possible areas for error stack
*       1000-1fff       Possible areas for system memory copy
*       2000-7fff       no special use
*       8000-ffff       Copy of display memory during test of high mem
*       10000-17fff     Normal display area
*       18000-1fc00     no special use
*       1fc00-20000     System stack; copied to 200 during test of high mem
*       20000-80000     no special use

** RWS : NOW FOR BURN-IN : COPY CART CODE TO 1M - 64K ($F0000), SO DON'T RAM TEST IT IF IN BURNIN

botram  equ     $10     ;Don't touch bus error, address error vectors
botrams equ     $400-botram
es_size equ     $100    ;256 bytes in error stack -- 20 lines * 10 bytes = 200
es_max  equ     200     ;256-56=200 

ramtst:
*       ========        
	move.l  (a7)+,d5        ;return address
	move.l  topram.w,d6     ;top of RAM

***     PRESERVE D6 and D5!!!

	movea.l #rammsg,a5
	bsr     dsptst

* RWS	lea.l	DSPrammsg,a5
* RWS	bsr	dspmsg

	clr.b   erflg0

;;RWS.TP 1.18d	move.w	#3,tries
.lp:
	bsr	DSPRAMTEST	; sets erflg0
	bclr    #6,mfp+imrb     ;mask key interrupts
	ori.w   #$700,sr

*	bset.b	#0,SPControl	;RWS.T !! 16MHz

*       ========
*       Test the error stack: $500-5ff,600-6ff,...f00-fff

	movea.l #$500,a6        ;initialize error stack (bottom)
chkes:  move.w  #es_size,d2     ;number of bytes in stack

*	bset.b	#0,SPControl	;RWS.T !! 16MHz

chkslp: move.w  0(a6,d2),d0     ;read data
	eori.w  #$ffff,d0       ;test with complement data
	move.w  d0,0(a6,d2)     ;write
	move.w  0(a6,d2),d1     ;read
	cmp.w   d0,d1           ;verify
	beq.s   nxtcell         ;o.k?

*       Found a bad cell
	adda.l  #es_size,a6     ;try next block
	cmpa.l  #$1000,a6       ;if all blocks bad...
	bge     estkfail        ;...then give up
	bra.s   chkes           ;else test next block
nxtcell:
	subq    #2,d2           ;next word
	bne.s   chkslp

*       Found 1k for the error stack, a6 points to bottom, so add 1k
	movea.l a6,a4           ;save bottom of stack
	adda.l  #es_size,a6     ;point to top of stack
	adda.l  #es_size-es_max,a4      ;add extra bytes

*       there are extra 56 bytes at bottom, so we are sure of no underflow
*       into system stack. (this was bug in 3.5)
*       a6=error stack top, a4=error stack bottom (a6=a4 when full)

*****************************************************************
*       Copy system ram ($10-$400) into 1000-2000 and test it   *

	movea.l #botram,a0
	movea.l #$1000,a1       ;move to $1000
	clr.l   d0
	ori.w   #botrams/2,d0   ;number of words to move
copylow:
	bsr     copyver         ;copy into higher mem
	beq.s   testlow         ;if good copy
	adda.l  #$400,a1        ;try higher
	cmpa.l  #$2000,a1       
	bne.s   copylow
	bra.s   testmid         ;if we can't copy, skip it      

*       Test from start of ram (8) to bottom of erstack (400-1000)

testlow:
	movea.l a1,a5           ;save pointer to system ram copy
	movea.l #botram,a0      ;start
	movea.l a6,a1           ;end=top of stack
	suba.l  #$400,a1        ;-stack depth
	bsr     tstblk          ;test (stack errors)

*       Restore system ram
	movea.l a5,a0           ;where it is saved
	movea.l #botram,a1      ;where it is going
	clr.l   d0
	move    #botrams/2,d0   ;how many
	bsr     copyver         ;restore 
	
*********************************
*       Check for errors        *

	bsr     chkstk          ;display errors         

	bset    #6,imrb+mfp     ;clear mask for key int
	move    #$2400,sr

*************************************************
*       Test from top of erstack to 20000       *
*       400-1000 up to 20000
testmid:
*       Copy display memory and create new stack

	movea.l #$10000,a0      ;this is current display
	movea.l #$20000,a1      ;put it in untested area
	move.l  #$4000,d0       ;       16k words
	bsr     copyram         ;save screen memory
	move.b  #2,v_bas_h    ;direct video shifter to new location

*       now don't try to write to display, 'cause it won't work 

***~     Note: must be at top of stack
	move.l  a7,erflg2       ;save stack pointer 
**~
	movea.l #$500,a7        ;assign new stack

	movea.l a6,a0           ;test from top of error stack up
	movea.l #$20000,a1      ;1st 128k
	bsr     tstblk
**~
;        movea.l #$20000,a7      ;restore stack
	 move.l erflg2,a7        ;restore stack
***~

*       Restore display
	movea.l #$20000,a0      ;this is current display
	movea.l #$10000,a1      ;put it in tested area
	move.l  #$4000,d0       ;       16k words
	bsr     copyram         ;restore screen memory
	move.b  #scrmemh,v_bas_h        ;and point hardware to it

**********************************
*       Check for errors        *
tmchk:  bsr     chkstk          ;display errors

	btst    #7,consol       ;continuous mode?
	beq.s   ramhi

	bsr     constat         ;want to quit?
	tst.b   d0
	bne     ramdone 

*****************************************
*       Perform test of 128k to top     *
*       20000-80000 (100000,400000)
;ramhi: ** OLD TEST BEFORE CARTLESS BURNIN : RWS **               
;	lea     vblkram,a0
;	move.l  a0,$70          ;new vblank routine to blink cursor
;	move    #30,blkcnt
;	clr.b   blkstat
;	move    #$2200,sr       ;allow vblank
;	movea.l #$20000,a0
;	movea.l topram,a1
;	bsr     tstblk          ;test to the end of ram
;	move    #$2400,sr
*****************************************
*       Perform test of 128k to top     *
*       20000-80000 (100000,400000)
ramhi:                
	lea     vblkram,a0
	move.l  a0,$70          ;new vblank routine to blink cursor
	move    #30,blkcnt
	clr.b   blkstat
	move    #$2200,sr       ;allow vblank
	movea.l #$20000,a0
	cmpi.b	#t_BURNIN,ProdTestStat
	bne	.skip
		movea.l	#$f0000,a1	; up to where cart is
		bsr	tstblk
		move	#$2200,sr
		movea.l	#$100000,a0	; 1MB
		cmp.l	#$100000,topram
		beq	.done1		; if only 1MB memory, skip over test
.skip:
	movea.l topram,a1
	bsr     tstblk          ;test to the end of ram
.done1:
	move    #$2400,sr

*********************************************************
*       Check for duplicates at 64k boundaries          *
*       10000, 20000, 30000, ..., topram
*** I THINK THIS WILL BE OK WITH BURNIN CART IF IT DOESN'T NEED $FAFF00-$FAFFFF
	move.w  #4,d7           ;test type      
	movea.l #$0ff00,a0      ;test last 256 bytes of each boundary
	moveq   #0,d0           ;data=0 for 1st block, 1 for 2nd, 2 for 3rd,...
	moveq   #0,d1
bound:  move.w  d0,(a0)+        ;write 256 bytes of this block
	move.w  a0,d1           ;compare word size only
	cmpi.w  #0,d1           ;x0000
	bne.s   bound           
	addq    #1,d0
	adda.l  #$ff00,a0       ;+64k
	cmpa.l  topram,a0
	ble.s   bound           ;until all memory written       

*       Read what was written
	movea.l #$0ff00,a0
	moveq   #0,d0
bound1: cmp.w   (a0)+,d0
	beq.s   boundok

*       Record error
	suba.l  #2,a0           ;back up for error
	move.w  (a0),d1         ;get data read
	bsr     stacker         ;save error
	adda.l  #2,a0

boundok:
	move.w  a0,d1           ;move low word
	cmpi.w  #0,d1           ;x0000
	bne.s   bound1
	addq    #1,d0
	adda.l  #$ff00,a0
	cmpa.l  topram,a0
	ble.s   bound1          ;until at top

*************************
*       Test done       *
ramdone:

*********************************
*       Check for errors        *
	bsr     chkstk          ;print out any errors           

	tst.b   erflg0          ;see if any errors
	beq.s   rampas

	move.w  #red,palette
	movea.l #falmsg,a5      
	bra.s   retram  

*       Ram test passed
rampas: move.l  topram,d0       ;get size
	swap    d0
	andi.l  #$fe,d0
	moveq   #sizemax,d1
	lea     sizetbl,a0
sizmsg: cmp.b   0(a0,d1),d0     ;get offset for size message
	beq     dsprsiz
	dbra    d1,sizmsg
dsprsiz:
	movea.l #model,a0
	lsl     #2,d1
	move.l  0(a0,d1),a5     ;get size message
	moveq   #40,d0
	moveq   #0,d1
	bsr     dsppos          ;display size on line 0, col 40

	movea.l #pasmsg,a5

*       -----------------       
*       Return

retram:	move.b	#t_RAM,d0
	bsr     dsppf           ;pass/fail msg
	move.l  d5,-(a7)        ;push return address
	rts


*       ----------------------------------------
*       Error in error stack, cannot save errors
*       Abort the test
estkfail:
	movea.l a6,a0
	movem.l d0-d1/a0,-(a7)
	movem.l (a7)+,d0-d1/a0
	moveq   #0,d7           ;type 0
	bsr     dsprame         ;display address, data
	move.w  #red,palette
	movea.l #falmsg,a5
	bra.s   retram


*********************************
*                               *       
*       RAM Test subroutines    *
*                               *
*********************************

*--------------------------------
*       Test a block of ram.
*       Note: this routine called from initialization code (tests 1fc00-20000)
*             as well as ram test.
*       Entry:  a0=start
*               a1=end+1
*               a6=top of error stack (on 1k bound. from $400-$800)

*       Exit:   a6^3ff=0 if no error, a6 points to error stack
*               a0=a0
*               a1=a1

tstblk: move.l  a0,-(a7)        ;save start
	bsr     hilo            ;test writing 1's and 0's
	cmp.l   a4,a6           ;limit on errors?
	ble.s   tstblk1
	bsr     addrtst         ;write address
	cmp.l   a4,a6
	ble.s   tstblk1
	move    #$2600,sr
	move.l  #vblank,$70     ;install vblank routine
	bsr     vidtst
tstblk1:
	move.l  (a7)+,a0
	rts

	                        
*-------------------------------------
*       Write checkerboard and test, repeat using complement
*       Entry:  a0=start
*               a1=end+1
*       Exit:   a0,a1 preserved
*       Uses:   a2,d0,d2,d7

hilo:   moveq   #1,d7           ;type 1
	move.w  #$aaaa,d0
	move.w  #$5555,d2
	bsr     chkbd1
	lsr.w   #1,d0           ;=55
	lsl.w   #1,d2           ;=AA
	bsr     chkbd1
	rts

*       Write checkerboard pattern over range a0-a1.
*       Read back, check for same pattern.
*       Entry:  a0=start
*               a1=end+1
*               d0=pattern word 1
*               d2=pattern word 2
*       Exit:   a0=a0,a1=a1
*       Uses:   a2

chkbd1: movea.l a0,a2

*       write
chkbd2: move    d0,(a0)+        ;write low word 
	move    d2,(a0)+        ;write high word
	cmpa.l  a0,a1
	bne.s   chkbd2

*       read
	movea.l a2,a0
chkbd3: move    (a0)+,d1        ;compare low
	cmp     d0,d1
	beq.s   chkbd4          

	suba.l  #2,a0           ;save error in low word
	bsr     stacker
	adda.l  #2,a0

chkbd4: move    (a0)+,d1
	cmp     d1,d2           ;compare high
	beq.s   chkbd5

	suba.l  #2,a0           ;save error in high word
	swap    d0              ;save low pattern in high word
	move    d2,d0           ;put pattern written to d0 for save routine
	bsr     stacker
	swap    d0              ;restore pattern
	adda.l  #2,a0

chkbd5: cmpa.l  a0,a1
	bne.s   chkbd3
	move.l  a2,a0
	rts

*--------------------------------------------------------------------
*       Scan through memory, writing low word of address to each cell
*       Scan again, verifying data.
*       Repeat, swapping high and low order 

*       Entry: a0=start
*              a1=end+1
*       Exit:   a6^3ff=0 if no errors 
*               a0=a0
*               a1=a1
*               d0<>d0, d1<>d1
addrtst:
*       Write low order address word into memory
	move.l  a0,a2           ;save start address
	moveq   #2,d7           ;type 2
wrtaddr:
	move.w  a0,(a0)+        ;write data
	cmpa.l  a0,a1
	bgt.s   wrtaddr

	move.l  a2,a0           ;restore start

rdaddr: move.w  (a0),d1         ;read data
	cmp.w   a0,d1           ;verify data 
	beq.s   rdaddr1

*       Save Error
	move    a0,d0           ;data written
	bsr     stacker         ;save error

rdaddr1:
	adda.l  #2,a0
	cmpa.l  a0,a1
	bgt.s   rdaddr

	move.l  a2,a0           ;restore a0

*       Repeat, using swapped high and low
wrtadrs:
	move.w  a0,d0
	rol.w   #8,d0
	move.w  d0,(a0)+        ;write data
	cmpa.l  a0,a1
	bgt.s   wrtadrs

	move.l  a2,a0           ;restore start

rdadrs: move    a0,d0
	rol.w   #8,d0           ;data written
	move.w  (a0)+,d1        ;read data
	cmp.w   d1,d0           ;verify data
	beq.s   rdadrs1

*       Save Error
	suba.l  #2,a0           ;get correct address
	bsr     stacker         ;save error
	adda.l  #2,a0

rdadrs1:
	cmpa.l  a0,a1
	bgt.s   rdadrs
	move.l  a2,a0           ;restore start
	rts

*--------------------------------
*       Write ascending/descending pattern for 32k blocks, display area tested
*       Does not test 8-400
*       Entry:  a0=start of block
*               a1=end of block+1
*               a6=error stack
*       Uses:   d0,d1,d2,d3,d5,d7
vidtst: cmp.l   #$400,a0        ;don't test 8-$400--not on video boundary
	blt.s   skipv           ;...and we need vblank
	add.l   #$8000,a0       ;check that its at least 32k block
	cmp.l   a0,a1
	bge.s   tstvid
	sub.l   #$8000,a0
skipv:  rts                     ;not 32k, skip test

tstvid: moveq   #3,d7           ;test #
	sub.l   #$8000,a0
	move.l  a0,d3           ;copy start address
	move.l  a1,d4           ;copy end address
	move.l  a0,a1
	add.l   #$8000,a1

	move.w  #$2200,sr       ;allow vblank
	move.b  v_bas_h,d0      ;save current video
	lsl.w   #8,d0
	move.b  v_bas_m,d0
	move.l  d0,templ.w

*       Test a 32k block, move to next 32k until at top
*       Set Display memory=test memory
scanmem:
	move.l  a0,d0
	bsr     newdsp          ;set new display
	bsr     wrtblk          ;write
	bsr     cmpblk          ;test
	tst.l   d7
	bmi.s   tstdone         ;br if error
	add.l   #$8000,a0       ;next 32k block
	add.l   #$8000,a1
	cmp.l   d4,a1           ;is this 32k block within test block bound?
	ble.s   scanmem         ;if yes, test

tstdone:
	move.l  templ.w,d0
	move.b  d0,v_bas_m      ;restore screen
	lsr.l   #8,d0
	move.b  d0,v_bas_h
	move.w  #$2400,sr
	move.l  d4,a1           ;restore boundaries
	move.l  d3,a0
	rts

*----------------------------
*       Write ascending/descending pattern from bottom and top of a 32k block
*       a0=lower bound
*       a1=upper bound
*       Uses:   a2,a3,d0,d1
wrtblk: movea.l a0,a2
	movea.l a1,a3
	moveq   #0,d0
	moveq   #$ff,d1
wrtbk1: move.w  d0,(a2)+        ;write bottom
	move.w  d1,-(a3)        ;write top
	add.w   #1,d0
	sub.w   #1,d1
	cmp.l   a2,a3           ;meet at middle
	bgt.s   wrtbk1
	rts

*-------------------------------
*       Compare block to written pattern, stack errors 
*       Entry:  a0=lower bound
*               a1=upper bound
*       Exit:   eq if no error
*       Alters: d0,d1,d7,a2,a3
cmpblk: move.l  a0,a2           ;a0=lower bound
	move.l  a1,a3
	sub.l   #$4000,a1       ;a1=midpoint

*       Check lower half
	moveq   #0,d0
cmpbk1: move.w  (a0)+,d1        ;check from bottom up
	cmp.w   d0,d1
	bne.s   cmpbk5          ;br if fail
cmpbk2: add.l   #1,d0           
	cmp.l   a0,a1           ;stop at midpoint
	bne.s   cmpbk1

*       Check upper half
	move.l  a3,a0           ;a0=upper bound
	move.l  a2,a1           ;a1=lower bound
	add.l   #$4000,a1       ;a1=midpoint
	moveq   #$ff,d0

cmpbk3: move.w  -(a0),d1        ;check from top down
	cmp.w   d0,d1
	bne.s   cmpbk6
cmpbk4: sub.w   #1,d0
	cmp.l   a0,a1           ;stop at midpoint
	bne.s   cmpbk3

cmpbk8: move.l  a2,a0           ;all done
	move.l  a3,a1
	rts

*       Stack Error
cmpbk5: sub.l   #2,a0
	bsr     stacker
	add.l   #2,a0
	bra.s   cmpbk7
cmpbk6: add.l   #2,a0
	bsr     stacker
	sub.l   #2,a0
cmpbk7: bset    #31,d7
	bra.s   cmpbk8          ;quit

*----------------------------
*       Set new display
*       d0=address
newdsp: move.w  #$2200,sr
	move.b  #1,lcount
newds1: tst.b   lcount
	bne.s   newds1
	move.w  #$2400,sr
	lsr.l   #8,d0
	move.b  d0,v_bas_m
	lsr.l   #8,d0
	move.b  d0,v_bas_h
	rts

*--------------------------------------------------     
*       Copy a block of ram and verify safe arrival
*       Entry:  a0=source
*               a1=destination
*               d0=number of words
*       Exit:   Z=set if success
*               a0,a1 preserved
copyver:
	movem.l a0-a1,-(a7)     ;save a0,a1
	bsr     copyram         ;copy
	subq    #1,d0
copyv1: cmp.w   (a0)+,(a1)+     ;verify
	bne.s   copyer
	dbra    d0,copyv1
	movem.l (a7)+,a0-a1     ;restore
	ori.w   #$0004,sr       ;Z=set
	rts

copyer: move    #red,palette    ;turn red immed. in case we die
	move.w  (a0),d0         ;data written
	move.w  (a1),d1         ;data read
	movea.l a1,a0           ;address 
	moveq   #1,d7           ;type 1
	bsr     dsprame         ;display the error
	movem.l (a7)+,a0-a1
	andi.w  #$fffb,sr       ;Z=reset
	rts

*-------------------------------
*       Copy a block of ram
*       Entry:  a0=source
*               a1=destination
*               d0=number of words
copyram:
	movem.l d0/a0-a1,-(a7)
	subq    #1,d0           ;could have set to one less on call
copyr1: move.w  (a0)+,(a1)+     ;copy word
	dbra    d0,copyr1
	movem.l (a7)+,d0/a0-a1
	rts

*----------------------------------------------------------
*       Stack the error, set error flag and turn screen red
*       Note:   If at bottom, do nothing
*       Entry:  a0=address
*               d0=data written
*               d1=data read
*               d7=test no.
*               a6=top of stack
*               a4=bottom of stack
*       Exit:   a6=a6-10
stacker:
	cmpa.l  a4,a6           ;at bottom?
	ble.s   stackx
	move.w  d7,-(a6)        ;type of test
	move.l  a0,-(a6)        ;address
	move.w  d0,-(a6)        ;data written
	move.w  d1,-(a6)        ;data read
	bset    #0,erflg0       ;flag error
	move.w  #red,palette
stackx: rts

*------------------------------------------------
*       Pull all errors off the stack and display
chkstk:
	move.l  a4,d0           ;a4=bottom 
	add.w   #es_max,d0      ;d0=top   
	cmpa.w  d0,a6           ;current = top?
	bge.s   chkstkx         ;quit if at top
	move.w  (a6)+,d1
	move.w  (a6)+,d0
	move.l  (a6)+,a0
	move.w  (a6)+,d7
	bsr     dsprame         ;display
	bra.s   chkstk
chkstkx:
	rts

*---------------------------------------------------------------
*       Display test type, address, data written, data read
*       Entry:  a0=address
*               a6=error stack
*               d0=data written
*               d1=data read
*               d7=test type
*       Exit:   d0=d0, d1=d1, d7=d7, a0=a0, a6=a6
dsprame:
	movem.l d0-d1/a0,-(a7)
	move.l  a6,-(a7)        ;save error stack

*       Print test type
	cmpi.w  #0,d7
	bne.s   dsprm1
	movea.l #err10,a5       ;system ram error
	bra.s   dsprm5
dsprm1: cmpi.w  #1,d7   
	bne.s   dsprm2
	movea.l #err11,a5       ;chip test error
	bra.s   dsprm5
dsprm2: cmpi.w  #2,d7
	bne.s   dsprm3
	movea.l #err12,a5       ;address test error
	bra.s   dsprm5
dsprm3: cmpi.w  #3,d7
	bne.s   dsprm4
	movea.l #err13,a5       ;video RAM test
	bra.s   dsprm5
dsprm4: movea.l #err14,a5       ;64k address test
dsprm5: bsr     dspmsg          ;display error code

dsprad: move    d0,d7
	eor     d1,d7           ;get xor of data
	move.w  d1,-(a7)        ;save data read
	move.w  d0,-(a7)        ;save data written

*       Display address
	bsr     dspadd
	bsr     dspspc

*       Display data 
	lea     wdatam,a5
	bsr     dspmsg
	move.w  (a7)+,d1        ;get data written
	bsr     dspwrd          ;display hex
	bsr     dspspc
	lea     rdatam,a5
	bsr     dspmsg
	move.w  (a7)+,d1        ;get data read
	bsr     dspwrd
	bsr     dspbadb         ;display xor
	move.l  (a7)+,a6
	movem.l (a7)+,d0-d1/a0
	rts

*-------------------------------
*       Display bad bits (xor of data written and read)
*       Entry:  d7=data

dspbadb:
	lea     badbitm,a5      ;bad bits:
	bsr     dspmsg
	moveq   #0,d1
binlp:  btst    d1,d7           ;bit set?
	beq.s   dbad1
	move    d1,-(sp)
	bsr     dspdec          ;display bit #
	bsr     dspspc
	move    (sp)+,d1
dbad1:  addq    #1,d1
	cmpi    #16,d1
	bne.s   binlp
	bsr     crlf
	rts

*--------------------------------
*       vblank routine
*       blink cursor to let user know we are still alive
vblkram:
	sub     #1,blkcnt
	bne.s   vblkrx
	move    #30,blkcnt
	movem.l d0-d7/a0-a6,-(sp)
	bsr     escp
	eori    #$ff,blkstat
	bne.s   blkon
	bsr     escq    
blkon:  lea     starmsg,a5
	move    #13,d0
	move    #0,d1
	bsr     dsppos
	bsr     escq
	movem.l (sp)+,d0-d7/a0-a6
vblkrx: rte

	.data

rammsg: dc.b    'Testing Ram',cr,lf,eot
;DSPrammsg:
;	dc.b	'DSP RAM NOT TESTED YET',cr,lf,eot
err10:  dc.b    'R0 RAM address=',eot           ;system ram
err11:  dc.b    'R1 RAM address=',eot           ;chip failure
err12:  dc.b    'R2 RAM address=',eot           ;address failure
err13:  dc.b    'R3 RAM address=',eot           ;video test
err14:  dc.b    'R4 RAM address=',eot           ;64k address
wdatam: dc.b    ' W:',eot
rdatam: dc.b    ' R:',eot
badbitm: dc.b   '  bad bits: ',eot      

starmsg: dc.b   '*',eot
