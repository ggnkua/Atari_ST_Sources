ExaPlay.OFFSET:		=	$1C		; 30 bytes program header

			RSSET	ExaPlay.OFFSET
ExaPlay.RELOC:		RS.L	1
ExaPlay.INIT_MODULE:	RS.L	1
ExaPlay.INIT_FIRST_TIME:RS.L	1
ExaPlay.INIT_INT:	RS.L	1
ExaPlay.END:		RS.L	1
ExaPlay.LOAD_DSP_PROG:	RS.L	1
ExaPlay.MIX:		RS.L	1
ExaPlay.GET_SYNC:	RS.L	1
ExaPlay.INFO_MODULE:	RS.L	1

ExaPlay.init:
	bsr.s	ExaPlay.bin+ExaPlay.RELOC	;reloge le player
	move.w	#1,ExaPlay.initialized
	moveq	#1,d0				;(1 -> 50 KHz ; 2-> 33 KHz)
	bra.s	ExaPlay.bin+ExaPlay.INIT_FIRST_TIME

; INPUT:
; a0=module
; OUTPUT:
; d0.w=returncode (=0 okay, <0 error)
ExaPlay.play
	bsr.s	ExaPlay.bin+ExaPlay.INIT_MODULE	;initialise le module
						;dans a3 = fin du module (apres precalcule de celui ci)
	tst.w	d0				;-1 header non trouv‚	;-2 mauvaise version
	bmi.s	.end

	bsr.s	ExaPlay.bin+ExaPlay.INIT_INT
	
	movea.l	ExaPlay.bin+ExaPlay.INFO_MODULE,a1

	move.w	#$100,4(a1)			;volume a 0
	move.w	#1,2(a1)			;on fait un pti fade volume en fixant l'increment
	sf	(a1)				;enable playing
	move.w	#$0000,6(a1)			;filter??
	move.l	#$01000100,8(a1)		;regles 8 voies
	move.l	#$01000100,12(a1)

	clr.w	d0
.end:	rts

ExaPlay.stop:
	movea.l	ExaPlay.bin+ExaPlay.INFO_MODULE,a1
	st	(a1)				;disable playing
	bra.s	ExaPlay.bin+ExaPlay.END		;coupe tout et remet le son.

ExaPlay.bin:
	INCBIN 	PLAYER.PRG
	EVEN

; INPUT:
; d0.w= size in dspwords
; a0: p56 program
Dsp.loadProgram:
	tst.w	ExaPlay.initialized
	bne	ExaPlay.bin+ExaPlay.LOAD_DSP_PROG

	move	#$4242,-(sp)
	clr.l	d1
	move.w	d0,d1
	move.l	d1,-(sp)
	move.l	a0,-(sp)
	move	#$6d,-(sp)	; Dsp_ExecProg
	trap	#14
	lea	12(sp),sp
	rts

ExaPlay.initialized:
	DC.W	0

