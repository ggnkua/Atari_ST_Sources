;	IN
;	a0=address to sample
;	d0=length of sample
;	d1=type of sound	1=norm 2=growl 3=ambiend 4=random amb
;	d2=priority
;	d3=Xpos
;	d4=Ypos
;	OUT
;	d0=channel	0->maxchan-1 or -1=not played

	SECTION TEXT
new_sound:
	movem.l	d0-d6/a0-a6,-(sp)

	lea	channellist,a1
	move.w	num_channels,d7
	move.l	a1,a2
	move.w	d7,d6
.check_free:
	tst.w	chanstatus(a2)
	beq.s	.free_found
	add.w	#chansize,a2
	dbra	d6,.check_free
	move.l	a1,a2
	move.w	d7,d6
.check_less:
	move.w	chanprio(a2),d3
	cmp.w	d1,d3
	ble.s	.free_found
	add.w	#chansize,a2
	dbra	d6,.check_less
	moveq.l	#-1,d0
	bra	.end

.free_found:
	sub.w	d6,d7
	move.w	#0,chanstatus(a2)	; Silence on channel

	move.w	d2,chanprio(a2)	; Sound priority
	cmp	#$7FFF,d2	; Super prio?
	beq.s	.sprio
	move.l	d0,d6	
	divu	samdiv,d6
	divu	d6,d2
	move.w	d2,chanpriodec(a2)	; prio decreser
	bra	.skutt
.sprio:
	clr.w	chanpriodec(a2)		; no decrese
.skutt:
	move.w	d3,chanXpos(a2)	; Xpos
	move.w	d4,chanYpos(a2)	; Ypos

* THIS IS TEMPORARY!!!!
	clr.l	chandist(a2)	; clear distanse
	clr.l	chandir(a2)		; clear direction offset
* Should call dist/pan rout here

	cmp.w	#1,d1
	beq.s	.fix
	cmp.w	#3,d1
	beq.s	.fix
	move.w	randfreq,d6
	addq.w	#2,d6
	and.w	#%1110,d6
	move.w	d6,randfreq
	lea	freqtable,a3
	move.w	(a3,d6.w),d6
	bra.s	.pitchdone
.fix:
	move.w	freqtable,d6
.pitchdone:
	move.w	d6,chanpitch(a2)	; set channel pitch

	move.l	a0,chanpos(a2)	; current sample pos
	moveq.l	#0,d1
	move.w	samdiv,d1
	sub.w	d1,d0
	add.l	d0,a0
	move.l	a0,chanend(a2)	; end of sample
	
	move.w	d1,chanstatus(a2)	; set type.

	move.w	d7,d0
.end:
	movem.l	(sp)+,d0-d6/a0-a6
	rts
	