;
; Top and bottom border removal. So far works on all ST/STEs.
; Originally based on a top border removal routine by Griff of 
; Inner Circle.
;
;	~C:borders_on()
;	~C:borders_off()
;
; ------- Copyright Terry King Ninth Wave Software 1993-95 -------

	bra	borders_on
	bra	borders_off

herz = $FFFF820A
iera = $FFFFFA07
ierb = $FFFFFA09
isra = $FFFFFA0F
isrb = $FFFFFA11
imra = $FFFFFA13
imrb = $FFFFFA15
tacr = $FFFFFA19
tadr = $FFFFFA1F
tdcr = $FFFFFA1D
tddr = $FFFFFA25
vr   = $FFFFFA17

borders_on
	movem.l	d0-7/a0-6,-(a7)
	lea	setflag(pc),a0
	bset	#0,(a0)
	bne.s	.done
	lea	set_borders(pc),a0
	move.l	a0,-(a7)
	move	#38,-(a7)
	trap	#14			; execute in supervisor
	addq	#6,a7
.done	movem.l	(a7)+,d0-7/a0-6
	rts

set_borders
	move	#$2700,sr		; interrupts off
	lea	old_mfp(pc),a0
	move.b	(iera).w,(a0)+
	move.b	(ierb).w,(a0)+
	move.b	(imra).w,(a0)+
	move.b	(imrb).w,(a0)+
	move.b	(tacr).w,(a0)+
	move.b	(tadr).w,(a0)+
	move.l	$68.w,(a0)+
	move.l	$70.w,(a0)+
	move.l	$134.w,(a0)+
	move.b	#%00100000,(iera).w	; enable timer A
	move.b	#%00100000,(imra).w
	and.b	#%00010000,(ierb).w	; disable all except timer D
	and.b	#%00010000,(imrb).w
	or.b	#%01000000,(ierb).w	; enable keyboard
	or.b	#%01000000,(imrb).w
	clr.b	(tacr).w		; timer A off
	lea	my_hbl(pc),a0
	move.l	a0,$68.w		; horizontal blank
	lea	vbl_patch+2(pc),a0
	move.l	$70.w,(a0)		; insert vbl patch
	lea	my_vbl(pc),a0
	move.l	a0,$70.w		; vertical blank
	lea	topbord(pc),a0
	move.l	a0,$134.w		; timer A vector
	move	#$2300,sr		; interrupts on
	rts

borders_off
	movem.l	d0-7/a0-6,-(a7)
	lea	setflag(pc),a0
	bclr	#0,(a0)
	beq.s	.done
	lea	reset_borders(pc),a0
	move.l	a0,-(a7)
	move	#38,-(a7)
	trap	#14			; execute in supervisor
	addq	#6,a7
.done	movem.l	(a7)+,d0-7/a0-6
	rts

reset_borders
	move	#$2700,sr
	lea	old_mfp(pc),a0
	move.b	(a0)+,(iera).w
	move.b	(a0)+,(ierb).w
	move.b	(a0)+,(imra).w
	move.b	(a0)+,(imrb).w
	move.b	(a0)+,(tacr).w
	move.b	(a0)+,(tadr).w
	move.l	(a0)+,$68.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$134.w
	move	#$2300,sr
	rts

my_hbl	rte

my_vbl	move.l	a0,-(a7)
	clr.b	(tacr).w		; stop timer A
	lea	topbord(pc),a0
	move.l	a0,$134.w		; timer A vector
	move.b	#99,(tadr).w		; countdown value for timer A
	move.b	#4,(tacr).w		; delay mode, clock divided by 50
	move.l	(a7)+,a0
vbl_patch jmp	0.l			; jump to system calls

topbord	move.l	a0,-(a7)
	move	#$2100,sr
	stop	#$2100			; sync with interrupt
	clr.b	(tacr).w		; stop timer A
	dcb.w	78,$4E71		; 78 nops
	clr.b	(herz).w		; 60 Hz
	dcb.w	18,$4E71		; 18 nops
	move.b	#2,(herz).w		; 50 Hz
	lea	botbord(pc),a0
	move.l	a0,$134.w		; timer A vector
	move.b	#178,(tadr).w		; countdown value for timer A
	move.b	#7,(tacr).w		; delay mode, clock divided by 200
	move.l	(a7)+,a0
	bclr.b	#5,(isra).w		; clear end of interrupt flag
	rte

botbord	move	#$2100,sr
	stop	#$2100			; sync with interrupt
	clr.b	(tacr).w		; stop timer A
	dcb.w	78,$4E71		; 78 nops
	clr.b	(herz).w		; 60 Hz
	dcb.w	18,$4E71		; 18 nops
	move.b	#2,(herz).w		; 50 Hz
	bclr.b	#5,(isra).w
	rte

setflag	ds.w 1	
old_mfp	ds.b 18
	
