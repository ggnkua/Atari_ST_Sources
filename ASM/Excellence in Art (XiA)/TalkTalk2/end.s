	move.w #0,$ffff8900 ; turn off DMA sound

	move.l startupsp,sp

	move.w sr,-(sp)
	or.w #$0700,sr

	move.l	oldvbl,$70.w		; restore VBL

	if enablehbl
	move.l oldhbl,$120			; restore HBL
	move.b old07,$fffffa07
	move.b old09,$fffffa09
	move.b old13,$fffffa13
	move.b old1b,$fffffa1b
	move.b old21,$fffffa21
	endif

	move.w (sp)+,sr


	move.w	oldrez,-(sp)
	move.l	physbase,-(sp)
	move.l	physbase,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#14,sp

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


oldusp: dc.l 0