

	nolist

;***********************************************************************
; Wave simulator routine v1.3
;
; This routine simulates the wave bucket (see wavesdsp.s) completely
; inside the DSP;
;
; The bucket size is fixed at 80*60 to allow everything to fit in
; memory. There are two output routines. One simply passes the CPU
; the grid 'as is', and the other scales it up by a factor of 4,
; using interpolation to ensure smoothness, giving an effective
; grid size of 320*240 (perfect for a VGA monitor).
;
; USAGE:
;	When the program is first run, it expects 5 parameters.
;
;	These are (in order expected) :
;		DAMPEN 		- velocity dampening fraction (24 bit frac)
;		REACT  		- unit reactivity fraction (24 bit frac)
;		MAX		- maximum height allowed (16 bit integer)
;		OUTPUT		- 0 = 80*60 grid, 1 = 320*240 interpolated grid
;		BITS		- The number of crap things moving about.
;		CLEARVELOCITY	- clear velocity when height is bounded
;		COLOURLOOKUP	- get palette from CPU on each frame
;
;	When these have been sent, the CPU should wait for a result, the first
;	word being sent will be the height of the top left point of the grid.
;	The velocities are not returned as they are only needed internally.
;	The CPU will then have to read all 80*60 (or 320*240) points generated
; 	and use them as required, after which the DSP will loop and generate
;	the next frame.
;
; Versions:
;	v0.1 : 68030 test program.
; 	v0.2 : Basic test system, coarse control of REACT and DAMPEN.
;	v1.0 : First real system with fine control.
;	v1.1 : Interpolation output added + test objects.
;	v1.2 : Re-optimised 56001 code.
;	v1.3 : Colour lookup now done by DSP.
;
;***********************************************************************

	include	"dspinc.asm"

;-----------------------------------------------------------------------
; Grid equates
;-----------------------------------------------------------------------

width	equ	64
height	equ	40

;-----------------------------------------------------------------------
; Jump to main on reset
;-----------------------------------------------------------------------

	org		p:00
	jmp		Main

;***********************************************************************
; Main program
;***********************************************************************

	org		p:64

Main:
	bclr		#2,omr			; turn off ROM ($100-$1FF)
	movep		#1,x:PBC		; enable Host port

ResetSystem:

; Get system vars over Host port
; These vars are in internal X memory

	dspread	x:DAMPEN
	dspread	x:REACT
	dspread	x:MAX
	dspread	x:INTERPOLATE
	dspread	x:BITS
	dspread	x:CLEARVELOCITY
	dspread	x:COLOURLOOKUP

	jsr	SetUpPointers		; Set up grid double buffer pointers

	jsr	ClearBuffers		; Clear grid buffers


MainLoop:

	jsr	ReadPalette		; get a palette (if in COLOURLOOKUP mode)

	jsr	SwapPointers		; Swap buffers and init pointers

;	jsr	PlotBits		; Plot crappy things
;
	jsr	ReadPlots		; Plot CPU generated plots

;	jsr	PutSoftEdges

	jsr	Generate		; Generate a new grid

	jsr	OutputGrid		; Send the grid to the CPU

	jmp	MainLoop		; Loop for next generation

;-----------------------------------------------------------------------
; Include main generation routine
;-----------------------------------------------------------------------

	include	"wavegen.asm"

;-----------------------------------------------------------------------
; Include SEND soutines.
; These handle sending the generated grids to the CPU.
;-----------------------------------------------------------------------

	include	"wavesend.asm"

;-----------------------------------------------------------------------
; Include INIT routines
; These routines handle the initialisation of the grid pointers
; and clearing of the grid for use.
;-----------------------------------------------------------------------

	include	"waveinit.asm"

;-----------------------------------------------------------------------
; Include WAVEBITS.
; This is a set of routines that plot some thingys on the grid.
; They will be superceded by decent stuff like line drawing,
; circles and HOST controlled routines.
;-----------------------------------------------------------------------

	include	"wavebits.asm"

;-----------------------------------------------------------------------
; Include input routines.
; These are used for reading commands and data over the host port.
;-----------------------------------------------------------------------

	include	"waveinp.asm"

;-----------------------------------------------------------------------
; Include Variable Space
; This file contains all variable declarations and the organisation
; of DSP memory.
;-----------------------------------------------------------------------

	include	"wavevars.asm"
