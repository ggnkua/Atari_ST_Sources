	move.w #0,$ffff8900 ; turn off DMA sound

	move.l startupsp,sp
	
	move.l $8,-(sp)
	move.l #.ggntrap,$8
	move.b old8e21,$ffff8e21
.ggntrap:
	move.l (sp)+,$8

;	move.w sr,-(sp)
;	or.w #$0700,sr
;	
;	move.l	oldvbl,$70		; restore VBL
;	move.l	old114,$114		; restore Timer C
;
;	ifne HBL_ENABLE
;  	move.l oldhbl,$120			; restore HBL
;  	move.b old07,$fffffa07
;  	move.b old09,$fffffa09
;  	move.b old13,$fffffa13
;  	move.b old1b,$fffffa1b
;  	move.b old21,$fffffa21
;	endif
;
;	move.w (sp)+,sr
;
;	;move.b #$c0,$fffffa23 ; Grazey's trick for making timer C mods work


; From DHS' demosystem
		move.w	#$2700,sr			;Stop interrupts

		move.l	save_usp,a0			;USP
		move.l	a0,usp				;
		move.l	save_hbl,$68.w			;HBL
		move.l	save_vbl,$70.w			;VBL
		move.l	save_timer_a,$134.w		;Timer-A
		move.l	save_timer_b,$120.w		;Timer-B
		move.l	save_timer_c,$114.w		;Timer-C
		move.l	save_timer_d,$110.w		;Timer-D
		move.l	save_acia,$118.w		;ACIA

		lea	save_mfp,a0			;restore vectors and mfp
		move.b	(a0)+,$fffffa01.w		;// datareg
		move.b	(a0)+,$fffffa03.w		;Active edge
		move.b	(a0)+,$fffffa05.w		;Data direction
		move.b	(a0)+,$fffffa07.w		;Interrupt enable A
		move.b	(a0)+,$fffffa13.w		;Interupt Mask A
		move.b	(a0)+,$fffffa09.w		;Interrupt enable B
		move.b	(a0)+,$fffffa15.w		;Interrupt mask B
		move.b	(a0)+,$fffffa17.w		;Automatic/software end of interupt
		move.b	(a0)+,$fffffa19.w		;Timer A control
		move.b	(a0)+,$fffffa1b.w		;Timer B control
		move.b	(a0)+,$fffffa1d.w		;Timer C & D control
		move.b	(a0)+,$fffffa27.w		;Sync character
		move.b	(a0)+,$fffffa29.w		;USART control
		move.b	(a0)+,$fffffa2b.w		;Receiver status
		move.b	(a0)+,$fffffa2d.w		;Transmitter status
		move.b	(a0)+,$fffffa2f.w		;USART data

		move.w	#$2300,sr			;Start interrupts



	move.w	oldrez,-(sp)
	move.l	physbase,-(sp)
	move.l	physbase,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	rept 0
		move.l old820a,$ffff820a			; restore old screen rez
		move.l old8260,$ffff8260
	endr

	move.b old8265,$ffff8265
	move.b old820f,$ffff820f

	rept 0
		move.b old8203,$ffff8203
		move.b old8201,$ffff8201
		move.b old820d,$ffff820d
	endr

	movem.l oldpal,d0-d7		; restore palette
	movem.l d0-d7,$ffff8240

	move.b #$8,$ffffc02 ; restore mouse reading
	dc.w $a009	; restore mouse pointer

	move.b old484,$484 ; restore keyclick

	move.l	oldusp(pc),-(sp)	; user mode
	move.w	#$20,-(sp)		;
	trap	#1			;
	addq.l	#6,sp			;

	clr.w   -(sp)                   ; pterm()
	move.w	#$4c,-(sp)		;
	trap    #1      		;

oldusp:
  dc.l 0
