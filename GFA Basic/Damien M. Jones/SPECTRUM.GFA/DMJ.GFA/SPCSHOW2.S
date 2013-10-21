*	Spectrum displayer, 50Hz/60Hz version.
*	Many thanks to Trio for making this PD.
*	Comments by dmj, April 24, 1992.

*	To get this code, I disassembled the Trio routines, then
*	went through and changed all the disassembly labels to
*	more meaningful ones.  I also added the comments, sorted
*	out the variables section, and other dull things like that.

*	I then combined both the 50Hz and 60Hz Spectrum displayers
*	into a single routine.  The routine automatically checks the
*	sync rate of the monitor and uses the appropriate routine.
*	This makes it much easier to program for Spectrum--now
*	you don't have to worry about the 50Hz/60Hz bit!

*	Of course, these routines still prohibit the use of the
*	mouse.  Maybe I'll get around to writing a custom keyboard
*	handler to take care of that one of these days...

*	Please remember that this is not my code.  It's the Trio
*	code.  Any glitches/faults are not my problem.  And I
*	-do- see a few spots where it could be improved.

begin	bra.s main		; Jump to main routine.

vars1   dc.l $286		; Space.  ID string?  Version?
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l 0
	dc.w $FFFF

main    movem.l d3-d7/a3-a6,-(a7) ; Save C registers.
        lea     spcflag(pc),a6	; Address of variable segment.
        st      1(a6)		; Set first-time flag.

        tst.w   $28(a7)		; Turn Spectrum on or off?
        beq     spc_off		; Turn it off.

        tst.b   (a6)		; Check the currently-on flag.
        bne     spc_upd		; Already on, just change addresses.

*	Turn on Spectrum mode.

spc_on  move.w  #2,-(a7)	; Get current screen physbase.
        trap    #14		; XBIOS(2)
        addq.l  #2,a7		; Adjust stack.
        move.l  d0,12(a6)	; Save this address.

        pea     ms_off(pc)	; Address of keyboard control string.
        clr.w   -(a7)		; Write just one byte (code 18, kill mouse).
        move.w  #25,-(a7)	; ikbdws
        trap    #14		; XBIOS(25)
        addq.l  #8,a7		; Adjust stack.

        move.b  $2B(a7),$2(a6)	; Save SPC physbase.
        move.b  $2C(a7),$3(a6)
        move.l  $2E(a7),$4(a6)	; Save SPC palbase.

        pea     spcinit(pc)	; Address of a routine (init).
        move.w  #38,-(a7)	; supexec.
        trap    #14		; XBIOS(38)
        addq.l  #6,a7		; Adjust stack.

        bra.s   waitint		; Just wait for the interrupt now.

*	Update Spectrum addresses, it's already on.

spc_upd	move.b  $2B(a7),2(a6)	; Just update the addresses.
        move.b  $2C(a7),3(a6)
        move.l  $2E(a7),4(a6)

waitint	tst.b   1(a6)		; Address updated yet?
        bne.s   waitint		; No, first-time flag still set, wait.
        bra     done		; Exit routine.

*	Turn off Spectrum mode.

spc_off	tst.b   (a6)		; SPC already off?
        beq     done		; Yes, we're done.

        pea     spckill(pc)	; Address of a routine.
        move.w  #38,-(a7)	; supexec.
        trap    #14		; XBIOS(38)
        addq.l  #6,a7		; Adjust stack.

        move.w  #-1,-(a7)	; Don't change the resolution.
        move.l  12(a6),-(a7)	; Do change the physbase back.
        move.l  #-1,-(a7)	; Don't change the logbase.
        move.w  #5,-(a7)	; setscreen
        trap    #14		; XBIOS(5)
        lea     12(a7),a7	; Adjust stack.

        pea     ms_on(pc)	; Address of keyboard code (mouse on).
        clr.w   -(a7)		; Write one byte.
        move.w  #25,-(a7)	; ikbdws
        trap    #14		; XBIOS(25)
        addq.l  #8,a7		; Adjust stack.
        sf      (a6)		; Clear wait-for-int flag.

done    movem.l (a7)+,d3-d7/a3-a6 ; Restore C registers.
        rts			; And return.

*	SPC Init routine (supervisor mode required).

spcinit	lea     $FF8240,a0	; Address of palette registers
        lea     ospal(pc),a1	; Address of palette save.
        move.w  #15,d7		; Save 16 colors.
psloop	move.w  (a0)+,(a1)+	; Save color.
        dbf     d7,psloop	; Next color.

	move.w #37,-(a7)	; vsync (necessary for 50Hz!)
	trap #14		; XBIOS(37)
	addq.l #2,a7		; Adjust stack.

        lea     $FF8260,a0	; Address of resolution variable.
        lea     osrez(pc),a1	; Address of save space.
        move.b  (a0),(a1)	; Copy over resolution.
        clr.b   (a0)		; And set screen to low res.

        lea     osvbl(pc),a0	; Address of VBL save variable.
        move.l  $4CE,(a0)	; Save OS VBL list entry.
        lea     spc_vbl(pc),a0	; Address of NTSC SPC VBL routine.
	btst	#1,$FFFF820A.w	; Check sync mode.
	beq	spc_ins		; It's clear, NTSC, good to go.
	lea	spcvbl2(pc),a0	; Else use PAL SPC VBL.
spc_ins	move.l  a0,$4CE		; Install it.
        rts			; We're done.

*	SPC De-init routine (supervisor mode required).

spckill	move.w #37,-(a7)	; vsync (necessary for 50Hz!)
	trap #14		; XBIOS(37)
	addq.l #2,a7		; Adjust stack.

	move.l  osvbl(pc),$4CE	; Restore OS VBL.
        move.b  osrez(pc),$FF8260 ; Restore OS resolution.

        lea     $FF8240,a0	; Address of palette registers.
        lea     ospal(pc),a1	; Address of palette save.
        move.w  #15,d7		; Restore 16 colors.
prloop	move.w  (a1)+,(a0)+	; Copy color.
        dbf     d7,prloop	; Next color.
        rts			; Return.

*	Spectrum VBL, 60Hz.

spc_vbl	tst.w   $43E		; Check flock--floppies in use?
        bne     spc_end		; Yes, bail now.

        move    sr,-(a7)	; Save status register.
        ori.w   #$700,sr	; No interruptions.

        lea     spcflag(pc),a0	; Address of spcflag.
        tst.b   (a0)		; SPC already on?
        beq     spc_set		; No, set address and wait till next VBL.

        lea     $FF8240,a4	; Address of palette registers.
        lea     $FF8209,a5	; Video address pointer, low byte.
        lea     timing(pc),a6	; 34 bytes past here (start of nops)
        movea.l spcpab2(pc),a3	; Address of palette variable.
        lea     32(a3),a3	; 32 bytes after, start with palette 2.
        move.w  #196,d7		; 197 lines.
        clr.l   d0		; Make sure all of this is clear.

vwait	tst.b   (a5)		; Check video address.
        beq.s   vwait		; Still zero, picture hasn't started yet.

        move.b  (a5),d0		; Has started, read address.
        cmp.b   #24,d0		; Is it 24?
        bhi     spc_set		; It's higher, we're late, wait for next VBL.
        adda.l  d0,a6		; Else add in the byte (number of nops to skip).
        jmp     (a6)		; And jump to it.

timing	nop			; Variable timing.
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        move.w  #24,d0		; Wait 25 more.
tloop	nop			; More timing.
        dbf     d0,tloop	; Wait for it.

*	Do a Spectrum line.

lloop	nop			; Fractional wait.
        lea     (a4),a0		; Palette register address.
        lea     (a4),a1		; 3 copies.
        lea     (a4),a2

        move.l  (a3)+,(a0)+	; Move over three palettes.
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        dbf     d7,lloop	; Do all 197 lines.

*	Now do the last two lines manually (no nop here).

        lea     (a4),a0		; Address of palette registers.
        lea     (a4),a1
        lea     (a4),a2
        move.l  (a3)+,(a0)+	; Copy over three palettes (line 198)
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+

        lea     (a4),a0		; Reload address of palette registers.
        lea     (a4),a1
        lea     (a4),a2
        lea     -19040(a3),a4	; Address of first palette.
        nop			; Timing.
        nop
        move.l  (a3)+,(a0)+	; Do last two palettes on last line.
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a4)+,(a2)+	; Then copy first palette for next time.
        move.l  (a4)+,(a2)+
        move.l  (a4)+,(a2)+
        move.l  (a4)+,(a2)+
        move.l  (a4)+,(a2)+
        move.l  (a4)+,(a2)+
        move.l  (a4)+,(a2)+
        move.l  (a4)+,(a2)+

*	Make sure the correct screen addresses are set.

spc_set	lea     spcflag(pc),a6	; Address of spcflag.
        st      (a6)		; Set it.
        sf      $1(a6)		; Clear first-time flag.
        move.b  $2(a6),$FF8201	; Copy screen address into Shifter.
        move.b  $3(a6),$FF8203	; High and low parts.
        move.l  $4(a6),$8(a6)	; Make a copy of the palette address.
        move    (a7)+,sr	; Restore the status register.

spc_end	rts			; All done with SPC interrupt.

*	Spectrum VBL, 50Hz.

spcvbl2	tst.w   $43E		; Check flock--floppies in use?
        bne     spc_end		; Yes, bail now.

        move    sr,-(a7)	; Save status register.
        ori.w   #$700,sr	; No interruptions.

        lea     spcflag(pc),a0	; Address of spcflag.
        tst.b   (a0)		; SPC already on?
        beq     spc_set		; No, set address and wait till next VBL.

        lea     $FF8240,a4	; Address of palette registers.
        lea     $FF8209,a5	; Video address pointer, low byte.
        lea     timing2(pc),a6	; 34 bytes past here (start of nops)
        movea.l spcpab2(pc),a3	; Address of palette variable.
        lea     32(a3),a3	; 32 bytes after, start with palette 2.
        move.w  #196,d7		; 197 lines.
        clr.l   d0		; Make sure all of this is clear.

vwait2	tst.b   (a5)		; Check video address.
        beq.s   vwait2		; Still zero, picture hasn't started yet.

        move.b  (a5),d0		; Has started, read address (never late in PAL).
        adda.l  d0,a6		; Add in the byte (number of nops to skip).
        jmp     (a6)		; And jump to it.

timing2	nop			; A whole lotta nothin' goin' on.
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

*	Do a Spectrum line.

lloop2	nop			; Fractional wait.
	nop			; Two for PAL.
        lea     (a4),a0		; Palette register address.
        lea     (a4),a1		; 3 copies.
        lea     (a4),a2

        move.l  (a3)+,(a0)+	; Move over three palettes.
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        dbf     d7,lloop2	; Do all 197 lines.

*	Now do the last two lines manually (only one nop here).

	nop			; Here's the wait.
        lea     (a4),a0		; Address of palette registers.
        lea     (a4),a1
        lea     (a4),a2
        move.l  (a3)+,(a0)+	; Copy over three palettes (line 198)
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+
        move.l  (a3)+,(a2)+

        lea     (a4),a0		; Reload address of palette registers.
        lea     (a4),a1
        lea     (a4),a2
        lea     -19040(a3),a4	; Address of first palette.
        nop			; Timing (three nops for PAL).
        nop
	nop
        move.l  (a3)+,(a0)+	; Do last two palettes on last line.
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a0)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a3)+,(a1)+
        move.l  (a4)+,(a2)+	; Then copy first palette for next time.
        move.l  (a4)+,(a2)+
        move.l  (a4)+,(a2)+
        move.l  (a4)+,(a2)+
        move.l  (a4)+,(a2)+
        move.l  (a4)+,(a2)+
        move.l  (a4)+,(a2)+
        move.l  (a4)+,(a2)+

	bra spc_set		; Finish up.

*	Variables section.

spcflag	dc.b 0			; Spectrum on/off flag.
firstf	dc.b 0			; First-time set flag.

spcphb	dc.w 0			; Spectrum physbase (Shifter format).
spcpab	dc.l 0			; Spectrum palbase.
spcpab2	dc.l 0			; A second copy.

osphb	dc.l 0			; OS physbase.
osvbl	dc.l 0			; OS VBL.

ospal	ds.b 32			; OS palette.

ms_off	dc.b 18			; KBD code for mouse off.
ms_on	dc.b 8			; KBD code for mouse on.

osrez	dc.w 0			; OS resolution.

	dc.w 0			; Who knows?