	opt	l+,c+

*
* DSP560001 ModPlay Library for HiSoft Basic.
* Written for the Atari Falcon030 only.
*
****************************************************
*Basic interface library by Data Uncertain.        *
*DSP MOD replay routine written by bITmASTER of BSW*
*Additional code by Dusan                          *
****************************************************
*
* See accompanying docs for details.
*
* This library was written using DevpacST, the HiSoft assembly language
* development system.
*
* You will require Devpac 2/3 and LIBRARY.H from the HiSoft Basic2 distribution
* to assemble this, and HiSoft Basic2 to use it.
*
*===========================================================================
* Summary
* -------
* This library provides a new library for HiSoft basic which provides
* support for using the DSP560001 to play mod files under interupt.
* Four commands are provided to support this:
*
*	InitMod dummy%()
*		InitMod initialises the modplay engine.
*		This routine should be called with a dummy integer
*		array parameter (any old integer array, it's not actually used).
*
*	PlayMod modfile%()
*		PlayMod actually starts a mod playing as a background task.
*		Usage:
*			dim a%(70000)
*			bload "mymusic.mod",varptr(a%(0))
*			PlayMod a%()
*
*	StopMod modfile%()
*		StopMod will stop the currently playing mod - you should always
*		call this to stop a mod from playing before exiting a program
*		or before starting another modfile playing.
*
*	GetModName modfile%(),name$
*		GetModName will return the title of the modfile (NOT the filename,
*		the actual mod title) in the string variable name$
*		
*===========================================================================

	include	library.h	the standard library include file

	library	MODPLAY		library name

	xref	get_string	external references
	xref	get_array
	xref	make_string
	xref.l	gl_scratch	this is referenced off global!

	xdef	InitMod
	xdef	GetModName	The routines!!!!
	xdef	PlayMod
	xdef	StopMod

	subdef	aint		InitMod		Initialise the modplay library. Called once at start of
*						program.
	subdef	aint,vstr	GetModName	GetModName takes an array of ints containing the mod,
*						followed by a string variable where the Name is returned.
	subdef	aint		PlayMod		PlayMod takes an array of ints containing the mod.
	subdef	aint		StopMod 	StopMod takes an arrat of ints (actually it isn't used, but
*						I couldn't workout how to make a sub with no params).

	option	'uv'		underlines & variable checks

	libstart		the code follows

                opt D+

iera            equ $fffffa07           ;Interrupt-Enable-Register A
ierb            equ $fffffa09           ;                                                               B
imra            equ $fffffa13
isra            equ $fffffa0f
isrb            equ $fffffa11
tacr            equ $fffffa19
tbcr            equ $fffffa1b
tadr            equ $fffffa1f
tbdr            equ $fffffa21
tccr            equ $fffffa1d
tcdr            equ $fffffa23
aer             equ $fffffa03
STColor         equ $ffff8240
FColor          equ $ffff9800
vbl             equ $70
timer_int       equ $0120
timer_c_int     equ $0114

ym_select       equ $ffff8800
ym_write        equ $ffff8802
ym_read         equ $ffff8800

vbaselow        equ $ffff820d
vbasemid        equ $ffff8203
vbasehigh       equ $ffff8201
vcountlow       equ $ffff8209
vcountmid       equ $ffff8207
vcounthigh      equ $ffff8205
linewid         equ $ffff820f
hscroll         equ $ffff8265

keyctl          equ $fffffc00
keybd           equ $fffffc02

DspHost         equ $ffffa200
HostIntVec      equ $03fc

PCookies        equ $05a0

hop             equ $ffff8a3a
op              equ $ffff8a3b
line_nr         equ $ffff8a3c
mode            equ $ffff8a3c
skew            equ $ffff8a3d
endmask1        equ $ffff8a28
endmask2        equ $ffff8a2a
endmask3        equ $ffff8a2c
x_count         equ $ffff8a36
y_count         equ $ffff8a38
dest_x_inc      equ $ffff8a2e
dest_y_inc      equ $ffff8a30
dest_adr        equ $ffff8a32
src_x_inc       equ $ffff8a20
src_y_inc       equ $ffff8a22
src_adr         equ $ffff8a24

mpx_src         equ $ffff8930
mpx_dst         equ $ffff8932

*************************************
*    GetModName modAddress, name$
*************************************
GetModName:
		move.l	8(sp),a0
		moveq.l	#1,d0
		bsr	get_array
		move.l	a2,a1

		lea	gl_scratch(global),a0
		move.l	a0,a2		save address of copy

		clr.l	d4
loop		move.b	(a1)+,(a0)+
		addq.l	#1,d4
		cmp.b	#0,(a1)
		bne	loop
		move.b	#0,(a0)+

		move.l	a2,a1

		move.l	4(sp),a0	the descriptor is needed
		bra	make_string	return the string to the variable & then
*					back to BASIC

		rts

*************************************
* Initialise the mod player
*  This must be called before using
*  the rest of the mod calls.
*      InitMod dummy%()
*************************************

InitMod:
                lea     player(pc),a0
                bsr     reloziere
		rts

*************************************
* Turn on a mod - play a mod under
*  interupt.
*   usage:
*      PlayMod modfile%()
*************************************

PlayMod:
                moveq   #1,d0
		move.l	4(sp),a0
		moveq.l	#1,d0
		bsr	get_array
		move.l	a2,a0
                bsr     player+28       ;ein
                pea     init(pc)
                move.w  #$26,-(sp)
                trap    #14
                addq.l  #6,sp
		rts

*************************************
* Turn off the currently playing mod
*  usage:
*    StopMod
*************************************
StopMod:
                pea     off(pc)
                move.w  #$26,-(sp)
                trap    #14
                addq.l  #6,sp
                bsr     player+28+4     ;aus
		rts

timer_b:        movem.l d0-a6,-(sp)
                bsr     player+28+8
                movem.l (sp)+,d0-a6
                bclr    #0,$fffffa0f.w
                rte


init:           lea     SaveArea(pc),a0
                move.l  timer_int,(a0)+
                move.b  tbcr,(a0)+
                move.b  tbdr,(a0)+
                move.b  #246,tbdr
                move.b  #7,tbcr
		lea.l	timer_b(pc),a0
                move.l  a0,timer_int
                bset    #0,imra
                bset    #0,iera
                rts

off:            bclr    #0,iera
                bclr    #0,imra
                lea     SaveArea(pc),a0
                move.l  (a0)+,timer_int
                move.b  (a0)+,tbcr
                move.b  (a0)+,tbdr
                rts

reloziere:      
                move.l  2(a0),d0        ;Relozieren
                add.l   6(a0),d0
                add.l   14(a0),d0
                adda.l  #$1c,a0
                move.l  a0,d1
                movea.l a0,a1
                movea.l a1,a2
                adda.l  d0,a1
                move.l  (a1)+,d0
                adda.l  d0,a2
                add.l   d1,(a2)
                clr.l   d0
L000A:          move.b  (a1)+,d0
                beq     L000C
                cmp.b   #1,d0
                beq     L000B
                adda.l  d0,a2
                add.l   d1,(a2)
                bra     L000A
L000B:          adda.l  #$fe,a2
                bra     L000A
L000C:          rts
SaveArea:       ds.b 6
player:         incbin 'DSP.BSW'
 