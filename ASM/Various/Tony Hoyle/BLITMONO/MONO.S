*  BlitMono V1.0 - This version is for the STE only, although it could
*  be made to work on and ST by removing references to $FF820D and aligning
*  the screens properly.  QINDEX gives about 71% on CPU operations with this
*  installed (98% on Divide and Shift operations).

*  This version does not handle the screen colours correctly - I have found
*  that it isn't as easy as just checking bit 0 of $FF8240.W, since the 
*  system does wierd things whilst setting the pallette up.

*  Written on Devpac 2 with tabs 16 characters wide (it looks a mess with 8
*  character tabs).

DaStart:	move.w #-1,-(sp)
	move.w #11,-(sp)
	trap #13		*  Fetch Shift values
	addq #4,sp
	and.b #6,d0		*  Mask off CTRL+Shift
	cmp.b #6,d0		*  Were they pressed?
	bne NoMono		*  Jump if not
	pea.l Install
	move.w #38,-(sp)
	trap #14		*  Install vectors
	addq #6,sp

	clr.w -(sp)
	move.w #64,-(sp)	*  Blitter off
	trap #14
	addq #4,sp
	
	move.w #2,-(sp)		*  Switch to mono mode
	pea.l $ffffffff
	pea.l $ffffffff
	move.w #5,-(sp)		*  Set screen params
	trap #14
	lea.l 12(sp),sp

	pea.l InitMsg		*  'BlitMono Installed'
	move.w #9,-(sp)
	trap #1
	addq #6,sp
	
	clr.w -(sp)		*  Success
	pea.l DaEnd-DaStart+$100	*  Bytes to keep
	move.w #49,-(sp)	*  Terminate+Stay resident
	trap #1		
	
*  If relevant keys not pressed output a message and finish.
	
NoMono:	pea.l NoInitMsg		*  'BlitMono not installed'
	move.w #9,-(sp)
	trap #1
	addq #6,sp
	clr.w -(sp)		*  Back to GEMDOS
	trap #1

*  Revector Level 3 interrupt (Vblank) and TRAP #14 (XBIOS)

Install:	move.l $70,OldVblank	*  Store old vector
	move.l #VBlank,$70	*  ..And new one
	move.l $b8,OldXBIOS	*  Do the same for
	move.l #XBIOS,$b8	*  the XBIOS
	clr.b MonoCounter	*  Reset counter
	rts	

*  Revectored XBIOS routines

OldXBIOS:	ds.l 1
	dc.b 'XBRAMONO'
	
XBIOS:	lea.l 6(sp),a0		*  a0 points SSP data
	btst.b #5,(sp)		*  User mode?
	bne XBIOSSuper		*  Jump if not
	move usp,a0		*  a0 points to USP data
XBIOSSuper:	cmp.w #2,(a0)
	beq PhysBase		*  Physical base addr
	cmp.w #4,(a0)
	beq GetRez		*  Logical base addr
	cmp.w #5,(a0)
	beq SetScreen		*  Set parameters
	cmp.w #64,(a0)
	beq BlitMode		*  Disable Blitter
	bra DoOldXBIOS
	
PhysBase:	move.l MonoBase,d0	*  Physical screen base
	rte
GetRez:	move.l #2,d0		*  Mono Mode
	rte
SetScreen:	move.w #2,10(a0)	*  Switch it
	bra DoOldXBIOS
	
*  It is important that GEM does not attempt to use the blitter whilst
*  BlitMono is running, because an interrupt in the middle of a GEM Blit
*  could be disastrous.

BlitMode:	clr.w 2(a0)		*  Remove blitter
	
DoOldXBIOS:	move.l OldXBIOS,-(sp)
	rts	

*  Vblank routine - keep things in order and do the actual work.

OldVblank:	ds.l 1
	dc.b 'XBRAMONO'

VBlank:	movem.l a0-a1/d0-d1,-(sp)	*  Store regs
	move.w #$BBB,$ff8242	*  Colour 7 =3+8
	move.w #$BBB,$ff8244	*  (b0 b3 b2 b1)
	clr.w $ff8240		*  Black Background
	move.w #$fff,$ff8246	*  White Foreground

	clr.l d0
	move.b $ff8201,d0	*  Hi-Byte
	lsl.w #8,d0
	move.b $ff8203,d0	*  Med-Byte
	lsl.l #8,d0
	move.b $ff820d,d0	*  Lo-Byte  (STE ONLY!)
	cmp.l #MediumScreen,d0	*  At correct pos?
	beq VBlank1		*  If so skip
	move.l d0,MonoBase	*  My Base Addr

VBlank1:	tst.l $45e		*  New screen?
	beq VBlank2		*  If not skip
	move.l $45e,d0		*  Medium-Rez screen
	move.l d0,MonoBase	*  My Base Addr
	clr.l $45e		*  No change
VBlank2:	move.l MonoBase,MonoLocation	*  Loc of Mono Screen
	
	move.b #1,$ff8260	*  Medium Rez
	move.b #2,$44c		*  Shiftmode register
	move.l #MediumScreen,d0	*  Medium rez screen
	move.l d0,MediumLocation	*  Location of screen
	move.b d0,d1		*  Low byte (save)
 	lsr.l #8,d0
	move.b d0,$ff8203	*  Screen Mid
	lsr.w #8,d0
	move.b d0,$ff8201	*  Screen Hi
	move.b d1,$ff820d	*  Screen Low (STE ONLY!)

	move.b MonoCounter,d0	*  Fetch counter
	addq #1,d0		*  Increase counter
	btst.b d0,#$7		*  Believe it or not this
			*  is legal 68000 (although
			*  it is undocumented). If
			*  your assembler doesn't
			*  accept it replace with
			*  other instructions.
	sne d1		*  D1=$FF if D0 <> 3
	and.b d1,d0		*  Wrap at 3
	move.b d0,MonoCounter	*  Back to memory
	btst.l #1,d0		*  Run-Phase?
	bne MonoEnd		*  If not skip to end
	btst.l #0,d0		*  Odd?
	bne Mono2		*  If so do odd lines

Mono1:	lea.l BlitMono1,a0	*  Blitter codes
	bsr DoBlit		*  Blit it
	bra MonoEnd		*  Jump to end

Mono2:	lea.l BlitMono1,a0	*  Blitter codes
	add.l #80,MonoLocation	*  Mono screen
	addq.l #2,MediumLocation	*  Medium screen
	bsr DoBlit		*  Blit it
	
MonoEnd:	movem.l (sp)+,a0-a1/d0-d1	*  Fetch regs
	move.l OldVblank,-(sp)	*  Old vector
	rts		*  Indirect return
	
DoBlit:	btst.b #7,$ff8a3c	*  Blitter busy?
	bne DoNoBlit		*  If so skip this blit
	lea.l $ff8a20,a1	*  Blitter base addr
	move.w #6,d0		*  31 words to transfer
	move.w sr,d1
	or.w #$0700,sr
BlitLoop:	move.l (a0)+,(a1)+	*  Transfer word
	dbra d0,BlitLoop	*  Do all of it
	clr.b $ff8a3d
	move.b #$80,$ff8a3c	*  Blitter now busy
	move.w d1,sr
DoNoBlit:	rts
	
	section data

*  Blitter ops for Mono -> medium

BlitMono1:	dc.w 2	*  Source Increment X
	dc.w 80	*  Source Increment Y
MonoLocation:	dc.l MediumScreen *  Source Address
	dc.w $ffff	*  Endmask 1
	dc.w $ffff	*  Endmask 2
	dc.w $ffff	*  Endmask 3
	dc.w 4	*  Destination Increment X
	dc.w 1	*  Destination Increment Y
MediumLocation:	dc.l MediumScreen *  Destination Address
	dc.w 41	*  Words yet to be written
	dc.w 200	*  Lines yet to be written
	dc.b 2	*  Halftone operation
	dc.b 3	*  Logic operation
	
InitMsg:	dc.b 'BlitMono V1.0 by Tony Hoyle - Installed.',0
	
NoInitMsg:	dc.b 'BlitMono V1.0 by Tony Hoyle january 1990',13,10
	dc.b 'STE version.',13,10
	dc.b 'Hold Down CTRL+Left Shift to use.',0
	
	section bss
	
MonoCounter:	ds.b 1
	
	even

MonoBase:	ds.l 1	
MediumScreen:	ds.b 32000

DaEnd:	equ *