*-------------------------------------*
*	-F-A-Z-E- Screen Saver	      *
*	  by Damien M. Jones	      *
*	     Version 1.00	      *
*-------------------------------------*

*	This screen saver is built around a generic screen saver
*	frame.  The frame hooks into the VBL and KBD/MIDI interrupts,
*	displays a successful installation message, and then terminates
*	with ptermres.
*
*	I've gone through (May 12, 1992) and added extra comments to
*	clear up some confusion.  The separate parts of the program
*	have been more clearly labeled.  If you don't like the way
*	I format my assembly, tough; I write it for me, not for you.

*	Code begins.

*	Generic Screen Saver
*	by Damien M. Jones
*	Copyright 1992 Damien M. Jones, All Rights Reserved.
*
*	Just change the "saver" routine to change the screen saver.
*	Please include a note in your documentation that you used
*	the "Generic Screen Saver Frame by dmj"; I place no other
*	restrictions on the use of this code.  So you could release
*	a Shareware screen saver using this code, and you wouldn't
*	have to send me a penny.  A copy of the screensaver would
*	be nice, but not mandatory.

*	If you leave the "id" string as it is, you can use the BoinkCfg
*	program to set the time delay for the screen saver, as well
*	as disable it.  Otherwise, you'll have to write your own
*	config program.

*	You'll need to change the amount of memory to save, around line
*	182.  Faze uses a 32K screen, plus space for the program.

	jmp install		; Install program.

*	Variables (for the config program).

id	dc.b 'dmjScreenSaver'	; Fourteen-byte ID string.
ssave	dc.w 0			; Old screen address.
screen	dc.w 0			; Address of screen saver screen.
timeout	dc.w 300		; Default is two minutes.
count	dc.w 300		; Number of cycles left to wait.
flag	dc.w 0			; Set if screen saver active.
palsave	dc.w 0,0,0,0,0,0,0,0	; Place to store system palette.
	dc.w 0,0,0,0,0,0,0,0
rezsave	dc.w 0			; Place to store system resolution.
pal	dc.w $000,$722,$631,$540,$450,$361,$272,$163 ; Screensaver palette.
	dc.w $054,$045,$136,$227,$316,$405,$504,$613
rez	dc.w 0			; Resolution of screen saver.
rndseed	dc.l $31415926		; Random number generator seed.

*	The VBL.  Decrements timer, then checks to see if screen saver
*	needs to be activated.  It then jumps to the OS VBL.

vbl	tst.w flag		; Is the screen saver active?
	beq vskip		; No, need to check counter.

	jsr saver		; Call the screen save subroutine.
	bra jmp1		; All done.

vskip	move.l a0,-(a7)		; Save this register.
	move.l #count,a0	; Address of count variable.

	subq.w #1,(a0)		; Decrement counter.
	tst.w (a0)+		; Is it zero?
	bne vblend		; Nope, exit now.

	st (a0)			; Set in-use flag.
	movem.l d0/a1,-(a7)	; Save these register too.
	lea $FFFF8240.w,a1	; Address of palette registers.
	move.l #palsave,a0	; Address to save into.

	move.l (a1)+,(a0)+	; Save palette.
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.w (a1)+,(a0)+	; Resolution.

	lea $FFFF8240.w,a1	; Address of palette registers.

	move.l (a0)+,(a1)+	; Move in saver palette.
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.b (a0),(a1)	; And saver resolution.

	lea $FFFF8201.w,a1	; Screen address vars in Shifter.
	move.l #ssave,a0	; Address of variable.
	movep.w 0(a1),d0	; Read old value.
	move.w d0,(a0)+		; And save it.
	move.w (a0),d0		; Get saver screen address.
	movep.w d0,0(a1)	; Copy over address.

	movem.l (a7)+,d0/a1	; Restore registers.

vblend	move.l (a7)+,a0		; Restore register.
jmp1	jmp $11111111		; Jump to old VBL.

*	The keyboard interrupt.  Resets VBL timer, and shuts off screen
*	saver if it's active.

kbd	move.l a0,-(a7)		; Save this register.

	move.l #timeout,a0	; Address of variable.
	move.w (a0)+,(a0)+	; Copy over word.

	tst.w (a0)+		; Was the screen saver active?
	beq kbdend		; No, exit now.

	movem.l d0/a1,-(a7)	; Save these registers too.
	lea $FFFF8240.w,a1	; Address of palette registers.

	move.l (a0)+,(a1)+	; Restore palette.
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.b (a0),(a1)	; Restore resolution.

	lea $FFFF8201.w,a1	; Screen address vars in Shifter.
	move.l #ssave,a0	; Address of variable.
	move.w (a0),d0		; Get contents.
	movep.w d0,0(a1)	; Copy over address.

	clr.w flag		; Clear this flag.
	movem.l (a7)+,d0/a1	; Restore these registers.

kbdend	move.l (a7)+,a0		; Restore register.
jmp2	jmp $11111111		; Jump to old KBD.

*	The installation routine.  Displays install message, hooks into
*	KBD/MIDI and VBL, and exits with ptermres.

install	pea initmsg		; Address of text.
	move.w #9,-(a7)		; cconws
	trap #1			; GEMDOS(9)
	addq.l #6,a7		; Adjust stack.

	move.w #4,-(a7)		; getrez
	trap #14		; XBIOS(4)
	addq.l #2,a7		; Adjust stack.

	cmp.b #2,d0		; High resolution?
	bne color		; No, install and exit.

	pea errmsg		; Address of text.
	move.w #9,-(a7)		; cconws
	trap #1			; GEMDOS(9)
	addq.l #6,a7		; Adjust stack.

	clr.w -(a7)		; pterm0
	trap #1			; GEMDOS(0) - No return.

color	pea init		; Address of init routine.
	move.w #38,-(a7)	; supexec
	trap #14		; XBIOS(38)
	addq.l #6,-(a7)		; Adjust stack.

	bsr sinit		; Init Screen Saver.

	pea okmsg		; Address of text.
	move.w #9,-(a7)		; cconws
	trap #1			; GEMDOS(9)
	addq.l #6,a7		; Adjust stack.

	move.l #34080,-(a7)	; Save 33K for program & screen.
	move.w #49,-(a7)	; ptermres
	trap #1			; GEMDOS(49) - No return.

*	This actually hooks the interrupts.

init	movem.l d0/a0,-(a7)	; Save this register.
	move.w sr,-(a7)		; Save status register.
	move.w #$2700,sr	; No interruptions.

	move.l #jmp2+2,a0	; Address of jump instruction.
	move.l $118.w,(a0)	; Copy over old keyboard vector.
	move.l #kbd,a0		; Address of KBD routine.
	move.l a0,$118.w	; Store it.

	move.l #jmp1+2,a0	; Address of jump instruction.
	move.l $70.w,(a0)	; Copy over old VBL vector.
	move.l #vbl,a0		; Address of VBL routine.
	move.l a0,$70.w		; Store it.

	move.l #svscrn,d0	; Address of screen area.
	add.l #255,d0		; Round up if necessary.
	lsr.l #8,d0		; Shift that address down.
	move.w d0,screen	; Save screen address.

	move.w (a7)+,sr		; Restore status register.
	movem.l (a7)+,d0/a0	; Restore this register.
	rts			; Return.

*	Init custom to FAZE.  Different screen savers will require
*	different init code here.

sinit	clr.l d0		; Make sure all of this is clear.
	move.w screen,d0	; Get screen address.
	lsl.l #8,d0		; Shift it to get real address.
	move.l d0,a0		; Copy to address register.

	move.w #7679,d1		; Number of words.
	move.l #-1,d2		; Word to move.

siloop	move.l d2,(a0)+		; Store word.
	dbra d1,siloop		; Next long.

	rts			; All done.

*	The actual saver routine; it makes the screen saver what it is.
*	This routine, the one above it, and the amount of memory to
*	save on line 182 are all you need to change to make a different
*	screen saver.

*	-F-A-Z-E- Screen Save Routine
*	by Damien M. Jones
*	Copyright 1992 Damien M. Jones, All Rights Reserved.

*	Basically, this program picks a random point from 0,0 to 31,31.
*	It then checks the adjacent four points.  If any of these are
*	in the next lower color, nothing is done.  Otherwise, if two
*	of the connecting points are of the next higher color, then
*	the point is plotted in that next higher color.  Otherwise it
*	has a 20% chance of being plotted in that next higher color.
*	Colors wrap, so 1 is the next higher color after 15.

*	Only one point is tested per VBL.  This routine takes about
*	11% of processor time.

saver	movem.l d0-d7/a0-a2,-(a7) ; Save registers.

	bsr rnd			; Randomize.

	clr.l d0		; Make sure all of this is clear.
	move.w screen,d0	; Get screen address.
	lsl.l #8,d0		; Shift it to get real address.
	move.l d0,a0		; Copy to address register.

Faze	bsr rnd			; Get a random number.
	move.w d0,d3		; Save it...
	and.w #$1F,d3		; 0-31, please.

	bsr rnd			; Another random number.
	move.w d0,d4		; Save it...
	and.w #$1F,d4		; 0-31, please.

	move.w d4,-(a7)		; Y coordinate.
	move.w d3,-(a7)		; X coordinate.
	bsr A_ptst		; Determine color of point.
	addq.l #4,a7		; Adjust stack.

	move.w d0,d5		; Copy over the color.
	clr.w d6		; Points in lower color (0)
	clr.w d7		; Points in higher color (0)

	move.w d3,-(a7)		; Save this.
	subq.w #1,d3		; Check point to the left.
	tst.w d3		; Less than zero?
	bpl FSkip1		; No.
	beq FSkip1		; No.
	add.w #32,d3		; Wrap.
FSkip1	bsr FPoint		; Check the point.
	move.w (a7)+,d3		; Restore value.

	move.w d4,-(a7)		; Save this.
	subq.w #1,d4		; Check point above.
	tst.w d4		; Less than zero?
	bpl FSkip2		; No.
	beq FSkip2		; No.
	add.w #32,d4		; Wrap.
FSkip2	bsr FPoint		; Check the point.
	move.w (a7)+,d4		; Restore value.

	move.w d3,-(a7)		; Save this.
	addq.w #1,d3		; Check point to the right.
	bsr FPoint		; Check the point.
	move.w (a7)+,d3		; Restore value.

	move.w d4,-(a7)		; Save this.
	addq.w #1,d4		; Check point below.
	bsr FPoint		; Check the point.
	move.w (a7)+,d4		; Restore value.

	tst.w d6		; Any lower color points here?
	beq FSkip5		; Nope, so far, so good.

	bra send		; Else return now.

FSkip5	cmp.w #1,d7		; 2 or more higher points?
	bgt FPlot		; Yes, plot away!

	bsr rnd			; Get a random number.

	and.w #$FF,d0		; Just the low byte.
	cmp.w #204,d0		; In the top 80%?
	bgt FPlot		; Yes, okay to plot the point.

	bra send		; Else return now.

FPlot	move.w d3,d6		; Copy the X coordinate.

	addq.w #1,d5		; Next color up.
	cmp.w #16,d5		; Is it color 16?
	bne FPLoop		; Nope.
	moveq.w #1,d5		; Reset this to 1.

FPLoop	move.w d5,-(a7)		; Point color.
	move.w d4,-(a7)		; Y Coordinate.
	move.w d3,-(a7)		; X Coordinate.
	bsr A_plot		; Plot the point.
	addq.l #6,a7		; Adjust stack.

	add.w #32,d3		; Next column.
	cmp.w #320,d3		; Off the right edge?
	blt FPLoop		; No, do next point.

	move.w d6,d3		; Move back to left edge.
	add.w #32,d4		; Next line.
	cmp.w #192,d4		; Off the bottom?
	blt FPLoop		; No, do the next point.

send	movem.l (a7)+,d0-d7/a0-a2 ; Restore registers.
	rts			; We're done now!

*	Test the color of a neighbor point, tally up.

FPoint	move.w d4,-(a7)		; Y coordinate.
	move.w d3,-(a7)		; X coordinate.
	bsr A_ptst		; Determine color of point.
	addq.l #4,a7		; Adjust stack.

	sub.w d5,d0		; Subtract out the original color.
	cmp.w #14,d0		; The edge.
	bne FSkip3		; Not here.
	move.w #-1,d0
FSkip3	cmp.w #-14,d0		; The other edge.
	bne FSkip4		; Not here.
	move.w #1,d0

FSkip4	tst.w d0		; Show me a sign!
	bpl FHigh		; Next higher color.
	bmi FLow		; Next lower color.
	rts			; Same color.

FHigh	addq.w #1,d7		; One more high point.
	rts

FLow	addq.w #1,d6		; One more low point.
	rts

*	Assembler Line-A Replacement Plotter (low res _only_!)
*	a0 contains address of screen.  ~C:A_plot(X&,Y&,C&)

A_plot	move.l a7,a1		; Copy over stack pointer.
	lea vtable(pc),a2	; Address of vertical table.
	clr.l d1

	move.w 4(a1),d0		; X coordinate.
	move.w 6(a1),d1		; Y coordinate.
	move.w 8(a1),d2		; Color.

	lsl.w #1,d1		; Double Y-coord for lookup.
	move.l a0,a1		; Copy over the address.
	move.w 0(a2,d1.w),d1	; Move in the Y-offset.
	add.l d1,a1		; Add in the vertical offset.

	move.w d0,d1		; Copy the X-coord.
	lsr.w #4,d1		; Shift down.
	lsl.w #3,d1		; Shift up.
	add.l d1,a1		; Add in the horizontal offset.

	and.w #$F,d0		; Take just the low nibble.
	eor.w #$F,d0		; Invert it.
	btst #3,d0		; In the higher byte?
	bne flowb		; Yes.

	addq.l #1,a1		; Increment address.

flowb	btst #0,d2		; Check out the bit.
	beq aclr1		; It's clear, clear the bit.
	bset d0,(a1)		; Set the bit.
	bra askip1		; Next plane.
aclr1	bclr d0,(a1)		; Clear the bit.
askip1	addq.l #2,a1		; Increment address.

	btst #1,d2		; Check out the bit.
	beq aclr2		; It's clear, clear the bit.
	bset d0,(a1)		; Set the bit.
	bra askip2		; Next plane.
aclr2	bclr d0,(a1)		; Clear the bit.
askip2	addq.l #2,a1		; Increment address.

	btst #2,d2		; Check out the bit.
	beq aclr3		; It's clear, clear the bit.
	bset d0,(a1)		; Set the bit.
	bra askip3		; Next plane.
aclr3	bclr d0,(a1)		; Clear the bit.
askip3	addq.l #2,a1		; Increment address.

	btst #3,d2		; Check out the bit.
	beq aclr4		; It's clear, clear the bit.
	bset d0,(a1)		; Set the bit.
	bra askip4		; Next plane.
aclr4	bclr d0,(a1)		; Clear the bit.

askip4	rts			; All done, return.

*	Assembler Line-A Replacement Point Tester (low res _only_!)
*	a0 contains address of screen.  ~C:A_ptst(X&,Y&)

A_ptst	move.l a7,a1		; Copy over stack pointer.
	lea vtable(pc),a2	; Address of vertical table.
	clr.l d0		; Make sure all of this is clear.
	clr.l d1		; Make sure all of this is clear.
	clr.w d2		; This is the return color.

	move.w 4(a1),d0		; X coordinate.
	move.w 6(a1),d1		; Y coordinate.

	lsl.w #1,d1		; Double Y-coord for lookup.
	move.l a0,a1		; Copy over the address.
	move.w 0(a2,d1.w),d1	; Move in the Y-offset.
	add.l d1,a1		; Add in the vertical offset.

	move.w d0,d1		; Copy the X-coord.
	lsr.w #4,d1		; Shift down.
	lsl.w #3,d1		; Shift up.
	add.l d1,a1		; Add in the horizontal offset.

	and.w #$F,d0		; Take just the low nibble.
	eor.w #$F,d0		; Invert it.
	btst #3,d0		; In the higher byte?
	bne flowb2		; Yes.

	addq.l #1,a1		; Increment address.

flowb2	btst d0,(a1)		; Check out the bit.
	beq bclr1		; It's clear, clear the bit.
	bset #0,d2		; Set the bit.
	bra bskip1		; Next plane.
bclr1	bclr #0,d2		; Clear the bit.
bskip1	addq.l #2,a1		; Increment address.

	btst d0,(a1)		; Check out the bit.
	beq bclr2		; It's clear, clear the bit.
	bset #1,d2		; Set the bit.
	bra bskip2		; Next plane.
bclr2	bclr #1,d2		; Clear the bit.
bskip2	addq.l #2,a1		; Increment address.

	btst d0,(a1)		; Check out the bit.
	beq bclr3		; It's clear, clear the bit.
	bset #2,d2		; Set the bit.
	bra bskip3		; Next plane.
bclr3	bclr #2,d2		; Clear the bit.
bskip3	addq.l #2,a1		; Increment address.

	btst d0,(a1)		; Check out the bit.
	beq bclr4		; It's clear, clear the bit.
	bset #3,d2		; Set the bit.
	bra bskip4		; Next plane.
bclr4	bclr #3,d2		; Clear the bit.

bskip4	move.w d2,d0		; Return value.
	rts			; All done.

*	The random number generator.

rnd	move.l rndseed,d1	; Get random number seed.
	move.l d1,d0		; Make a copy.
	lsl.l #4,d0		; Shift this over.
	lsr.l #3,d1		; Shift this the other way.
	eor.l d1,d0		; XOR them together.
	move.l $4BC.w,d1	; Get system timer.
	eor.l d1,d0		; XOR the system timer.
	move.l d0,rndseed	; Save it for next time.
	lsr #8,d0		; Shift this down, please.

	rts			; Done.

*	Other variables.

initmsg	dc.b $1B,'p  -F-A-Z-E-  ',$1B,'q',$D,$A
	dc.b ' v1.0 by dmj',$D,$A,$D,$A,0
errmsg	dc.b 7,'Not usable in high rez!',$D,$A,$D,$A,0
okmsg	dc.b '** Installed **',$D,$A,$D,$A,0

	even

*	The Vertical Offset Table - faster than muls.

vtable	dc.b $00,$00,$00,$A0,$01,'@',$01,$E0,$02,$80,$03,' ',$03,$C0,$04,'`'
	dc.b $05,$00,$05,$A0,$06,'@',$06,$E0,$07,$80,$08,' ',$08,$C0,$09,'`'
	dc.b $0A,$00,$0A,$A0,$0B,'@',$0B,$E0,$0C,$80,$0D,' ',$0D,$C0,$0E,'`'
	dc.b $0F,$00,$0F,$A0,$10,'@',$10,$E0,$11,$80,$12,' ',$12,$C0,$13,'`'
	dc.b $14,$00,$14,$A0,$15,'@',$15,$E0,$16,$80,$17,' ',$17,$C0,$18,'`'
	dc.b $19,$00,$19,$A0,$1A,'@',$1A,$E0,$1B,$80,$1C,' ',$1C,$C0,$1D,'`'
	dc.b $1E,$00,$1E,$A0,$1F,'@',$1F,$E0,' ',$80,'! !',$C0,'"`#',$00,'#'
	dc.b $A0,'$@$',$E0,'%',$80,'& &',$C0,$27,'`(',$00,'(',$A0,')@)',$E0,'*'
	dc.b $80,'+ +',$C0,',`-',$00,'-',$A0,'.@.',$E0,'/',$80,'0 0',$C0,'1`'
	dc.b '2',$00,'2',$A0,'3@3',$E0,'4',$80,'5 5',$C0,'6`7',$00,'7',$A0
	dc.b '8@8',$E0,'9',$80,': :',$C0,';`<',$00,'<',$A0,'=@=',$E0,'>',$80
	dc.b '? ?',$C0,'@`A',$00,'A',$A0,'B@B',$E0,'C',$80,'D D',$C0,'E`F'
	dc.b $00,'F',$A0,'G@G',$E0,'H',$80,'I I',$C0,'J`K',$00,'K',$A0,'L@L'
	dc.b $E0,'M',$80,'N N',$C0,'O`P',$00,'P',$A0,'Q@Q',$E0,'R',$80,'S S'
	dc.b $C0,'T`U',$00,'U',$A0,'V@V',$E0,'W',$80,'X X',$C0,'Y`Z',$00,'Z'
	dc.b $A0,'[@[',$E0,'\',$80,'] ]',$C0,'^`_',$00,'_',$A0,'`@`',$E0,'a'
	dc.b $80,'b b',$C0,'c`d',$00,'d',$A0,'e@e',$E0,'f',$80,'g g',$C0,'h`'
	dc.b 'i',$00,'i',$A0,'j@j',$E0,'k',$80,'l l',$C0,'m`n',$00,'n',$A0
	dc.b 'o@o',$E0,'p',$80,'q q',$C0,'r`s',$00,'s',$A0,'t@t',$E0,'u',$80
	dc.b 'v v',$C0,'w`x',$00,'x',$A0,'y@y',$E0,'z',$80,'{ {',$C0,'|`' 

svscrn

*	Well, you made it to the end.  I realize this probably isn't the
*	most efficient assembly code around, but I don't normally write
*	self-contained assembly programs.  The only reason I started was
*	to write TSRs.  If you have any suggestions for improving the
*	code, I'd be glad to hear it.
*
*		Damien M. Jones
*		PSC 8 Box 657
*		APO AE 09109
*
*	Be sure to check out BoinkSave, available on GEnie; you can
*	probably find it on the other networks as well.
*
*		-dmj
