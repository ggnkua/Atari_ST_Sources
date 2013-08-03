*
*
* 	JAGUAR GAME
*
*

; Directives par souci de clart‚ des sources :
; 
; - Les registres provenant de JAGUAR.INC doivent être utilisés en majuscule.
; - Les equivalences doivent être aussi mises en majuscule.
; - Les adresses sous ORG sont preced‚es du caractŠre soulign‚. (sauf locaux)
; - Les labels dans la definition de l'object-list sont pr‚cŠd‚s de "l_"
; - Le point-virgule des commentaires doit être mis sur la 2Šme tabulation. 



		include	"includes/jaguar.inc"

		include	"includes/macro_op.s"
		include	"includes/macro_ga.s"





; Constantes


; Screen

SCR_W		= 32
SCR_H		= 20
SCR_BLT		= WID32
SCR_WIDTH	= 32
PWIDTH		= PIXEL8
O_DEPTH		= O_DEPTH8
NB_COLORS	= 256 





; GPU equivalences

ISTACK		= G_ENDRAM-256-4	; Location of interrupt stack
ADR_GPUCODE	= G_RAM+$30		; == GPU Object Processor Interrupt

ISTACKD		= D_ENDRAM-256-4	; Location of interrupt stack
ADR_DPCODE	= D_RAM			; == DSP Object Processor Interrupt


*------------------------------------------------------------------------
		text
*-------------------------------------------------------------------------

		.68000



main:	move.l	#INITSTACK,a7		; Stack location = end of ram-4
		bsr	InitJag

		bra.s 	*

		illegal



*************** Initialize Jaguar video, object list and interrupts

InitJag:	move.l	#$70007,G_END
		move.l	#$70007,D_END
		move.w	#-1,VI
		bsr	vidinit			; Initialize video

		bsr	sndinit

		move.w	#CRY16|VIDEN|CSYNC|BGEN|PWIDTH4,VMODE
		rts
		
sndinit:
		moveq	#0,d0
		move.l	d0,R_I2S
		move.l	d0,L_I2S
		move.w	#$100,JOYSTICK
		
		move.l	d0,D_CTRL
		move.l	d0,D_FLAGS
		
		move.l	#24,SCLK
		move.l	#$15,SMODE
		
		move.w	d0,JPIT2
		move.w	d0,JPIT1
		
		lea	dspcode_start,a0	; address of GPU code in RAM
		lea	D_RAM,a1			
		move.l	#(dspcode_end-dspcode_start)-1,d0
		bsr	gpuload
		
		move.l	#_dspcode,D_PC		; address of GPU code 
		move.l  #DSPGO,D_CTRL		; Start GPU
		rts
		
		
********************************************************************
***       							****
********************************************************************


		dsp
		
		phrase
		
dspcode_start:
		org	D_RAM
		
		movei	#_dspcode,r0
		jump	(r0)
		nop
		nop
		nop
		nop
		
		movei	#_i2s_int,r29
		jump	(r29)
		nop
		nop
		nop
		nop
		
		movei	#_pit1,r29
		jump	(r29)
		nop
		
_dspcode:	
		movei	#ISTACKD,r31

		movei	#D_FLAGS,r1
		load	(r1),r0
		movei	#REGPAGE|D_I2SENA,r2
		or	r2,r0
		store	r0,(r1)
		nop
		nop
		
_run:	movei	#BG,r1		
		movei	#$F8FF,r0
		storew	r0,(r1)

		movei	#_run,r0
		jump	(r0)
		nop
		
_index1:	dc.l	0
_index2:	dc.l	2000

_i2s_int:	
		movei	#BG,r16
		movei	#$F0FF,r17
		storew	r17,(r16)

		movei	#_index2,r16
		movei	#sample2,r17
		load	(r16),r0
		add	r0,r17
		addq	#1,r0
		bclr	#12,r0
		store	r0,(r16)
		loadb	(r17),r0

		shlq	#24,r0
		sharq	#19,r0
		
		move	r0,r1

		movei	#_index1,r16		
		movei	#sample1,r17
		load	(r16),r0
		add	r0,r17
		addq	#1,r0
		bclr	#15,r0
		store	r0,(r16)
		loadb	(r17),r0

		shlq	#24,r0
		sharq	#18,r0
	
		
		add	r0,r1
		
		movei	#L_I2S,r16	
		store	r1,(r16)
		addq	#4,r16
		store	r1,(r16)
		subq	#4,r16
		
		movei	#D_FLAGS,r30
		load	(r31),r28
		load	(r30),r29
		addq	#4,r31
		bclr	#3,r29
		addq	#2,r28
		bset	#10,r29	
		jump	(r28)
		store	r29,(r30)
		nop
		nop

_pit1:
		movei	#D_FLAGS,r30
		load	(r31),r28
		load	(r30),r29
		addq	#4,r31
		bclr	#3,r29
		addq	#2,r28
		bset	#10,r29	
		jump	(r28)
		store	r29,(r30)
		nop
		nop

		
		.68000
dspcode_end:
		



		include "includes/jag_tools.s"


;----------------------------------------------------------------------------------------
		data
;----------------------------------------------------------------------------------------

		phrase

*******************************************************************************
*
*                             EXTERNALS  DATAS 
*
*******************************************************************************


sample2:	dcb.b	600,0
sample1:	dcb.b	600,0

*------------------------------------------------------------------------------		
		bss
*------------------------------------------------------------------------------		
		
		end




