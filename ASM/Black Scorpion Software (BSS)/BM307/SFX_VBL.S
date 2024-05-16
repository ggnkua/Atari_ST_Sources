sfx_VBL:
	movem.l	d0-7/a0-6,-(sp)
	
	move.w	freq,d0
	asr.w	#1,d0
	add.w	#8+2,d0		; ror index
	move.l	sampos,d1
	sub.l	samstart,d1
	asr.l	d0,d1		; current calc buff
	moveq.l	#0,d2
	move.b	$ffff8909.w,d2
	swap	d2
	move.b	$ffff890b.w,d2
	rol.w	#8,d2
	move.b	$ffff890d.w,d2
	sub.l	samstart,d2
	asr.l	d0,d2		; current play buff
	cmp.w	d1,d2
	beq.s	.no_newsound

	bsr	clear_samplebuffer

	move.w	num_channels,d0
	lea	channellist,a0
.play_all:
	move.w	chanstatus(a0),d1
	beq.s	.no_sound
	cmp.w	#3,d1
	bge.s	.ambient
	bsr	calculate_sound
	bra.s	.sound_done
.ambient:
	bsr	calculate_ambient

.sound_done:
	move.w	chanpriodec(a0),d1
	sub.w	d1,chanprio(a0)
	move.l	chanend(a0),d1
	move.l	chanpos(a0),d2
	cmp.l	d2,d1
	bgt.s	.not_done
	clr.w	chanstatus(a0)
;	move.l	#chansize/4-1,d1
;	move.l	a0,a1
;.clear_loop:
;	clr.l	(a1)+
;	dbra	d1,.clear_loop

.not_done:

.no_sound:
	add.l	#chansize,a0
	dbra	d0,.play_all
	
	move.w	freq,d0
	mulu	#256*4,d0
	add.l	d0,sampos
	move.l	sampos,d0
	move.l	samend,d1
	sub.l	#128,d1	; correction
	cmp.l	d1,d0
	ble.s	.noressambuff
	move.l	samstart,sampos
.noressambuff:	

.no_newsound:
	movem.l	(sp)+,d0-7/a0-6

sfx_VBL2:	
	jmp	$12345678	; do old VBL
