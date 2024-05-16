; Include version!
; Lightning effect. Uses u-fly. Made for delta demo.
; Attempt to use fading works.. But ofcourse not with asynced bolts at the
; same time. Fading 320*200 hc is just too slow (even with ct2).

;======= OBJECT EQUATES ========

Lightning.BOLTS:	=	5			; max bolts per update
Lightning.RESTORE:	=	1			; Restore background y/n?
Lightning.LEVELS:	=	20			; #boltsegments
Lightning.WIDTH:	=	7			; width of bolt

				RSRESET
Lightning.SEGMENT_TABLE:	RS.L	Lightning.LEVELS*Lightning.BOLTS
Lightning.START_ANGLE:		RS.W	Lightning.BOLTS
Lightning.IN_RADIUS:		RS.W	1
Lightning.NUM_BOLTS:		RS.W	1
Lightning.BOLT_SIZE:		RS.B	0

;======= INIT SUBROUTINE ========

; OUTPUT:
; d0.l: =0 all clear, <0 error, not initialized!
Lightning.init:
	lea	sine_tbl,a1
	bsr.l	Matrix.init

	lea	Lightning.blueInstTable,a1
	lea	Lightning.prePal,a0
	bsr.l	Pal.makeGradientHc

.success:
	moveq	#0,d0
	rts
.error:	moveq	#-1,d0
	rts

Lightning.initRealtime:
	clr.w	Lightning.pulseMode
	rts

;======= OBJECT SUBROUTINES ========

Lightning.toggleMode:
	not.w	Lightning.pulseMode
	clr.w	Lightning.fade_count
	bra.s	Lightning.pulseFast

Lightning.pulseSlow:
	move.l	#32,Lightning.fadeSteps
	bra.s	Lightning.pulse

Lightning.pulseNormal:
	move.l	#64,Lightning.fadeSteps
	bra.s	Lightning.pulse

Lightning.pulseFast:
	move.l	#128,Lightning.fadeSteps
;	bra.s	Lightning.pulse

Lightning.pulse:
	move.l	$04BA.w,Lightning.pulseStart
	move.w	#3,Lightning.refresh
	rts

Lightning.incInRadius:
	addq.w	#1,Lightning.inRadius
	rts

Lightning.decInRadius:
	move.w	Lightning.inRadius,d0
	subq.w	#1,d0
	bmi.s	.end
	move.w	d0,Lightning.inRadius
.end:	rts

Lightning.incSegLength:
	addq.w	#1,Lightning.segLength
	rts

Lightning.decSegLength:
	subq.w	#1,Lightning.segLength
	rts

Lightning.incSegRandom:
	addq.w	#1,Lightning.segRandom
	rts

Lightning.decSegRandom:
	subq.w	#1,Lightning.segRandom
	rts

; Paints normal (continuous) bolts.
Lightning.paintNormal
	bsr.w	Lightning.restoreBack
	moveq	#3-1,d0
	bsr.w	Lightning.calc
	bsr.w	Lightning.paint
	rts

; Paints bolts in pulse-mode (faded)
Lightning.paintPulsed:
	bsr.w	Lightning.count

	tst.w	Lightning.refresh
	beq.s	.end_restore
	bsr.w	Lightning.restoreBack
.end_restore:

	cmpi.w	#3,Lightning.refresh
	blt.s	.copy_old

; 2 pass multinomial chance-experiment.
	moveq	#Lightning.BOLTS,d0
	bsr.w	Lightning.getRandom
	move.w	d2,d7
	moveq	#Lightning.BOLTS,d0
	bsr.w	Lightning.getRandom
	add.w	d2,d7
	lsr.w	#1,d7
	bcc.s	.rounded
	addq.w	#1,d7
.rounded:
; d7.w=avg[rand(7)+rand(7)] (int)
	move.w	d7,d0
	bsr.w	Lightning.calc

	bra.s	.end_calc
.copy_old:
	bsr.w	Lightning.copyOldBolt
.end_calc:

	bsr.w	Lightning.paint

	move.w	Lightning.refresh,d0
	subq.w	#1,d0
	bmi.s	.end_store
	move.w	d0,Lightning.refresh
.end_store:
	rts

; Control pulse timing stuff.
Lightning.count:
	move.l	$04BA.w,d0
	sub.l	Lightning.pulseStart,d0
	cmp.l	Lightning.fadeSteps,d0
	blt.s	.end_count
	move.w	Lightning.fadeSteps+2,d0
.end_count:
	move.w	d0,Lightning.fade_count
	rts

; Restore background..
Lightning.restoreBack:
	IFNE	Lightning.RESTORE
	movea.l	Lightning.boltAddys,a0
	move.w	(Lightning.NUM_BOLTS.l,a0),d7

.restore_loop:
	movea.l	Lightning.boltAddys,a1
	move.w	(Lightning.START_ANGLE.l,a1,d7.w*2),d0
	move.w	(Lightning.IN_RADIUS.l,a1),d1
	move.w	d7,d2
	mulu.w	#Lightning.LEVELS*4,d2
	adda.l	d2,a1
	move.w	d7,-(sp)
	bsr.w	Lightning.restorePolybolt
	move.w	(sp)+,d7
	dbf	d7,.restore_loop
	ENDC
	rts

; Calculate lightning..
; INPUT:
; d0.w=#bolts-1
Lightning.calc:
	movea.l	Lightning.boltAddys,a0
	move.w	d0,d7
	move.w	d7,Lightning.NUM_BOLTS(a0)

.calc_loop:
	movea.l	Lightning.boltAddys,a0
	move.w	#sintbllen,d0
	bsr.w	Lightning.getRandom
	move.w	d2,d0
	move.w	d0,(Lightning.START_ANGLE.l,a0,d7.w*2)
	move.w	Lightning.inRadius,Lightning.IN_RADIUS(a0)
	move.w	d7,d0
	mulu.w	#Lightning.LEVELS*4,d0
	adda.l	d0,a0
	move.w	d7,-(sp)
	bsr.w	Lightning.calcbolt
	move.w	(sp)+,d7
	dbf	d7,.calc_loop
	rts

; Copies previous bolt data to current buffer..
Lightning.copyOldBolt:
	lea	Lightning.boltAddys,a0
	movea.l	8(a0),a1			; a1: src
	movea.l	(a0),a0				; a0: dst
	movea.l	a1,a3				; a3: src
	movea.l	a0,a2				; a2: dst
	move.w	Lightning.NUM_BOLTS(a1),d7	; d7.w=#bolts-1
	move.w	d7,Lightning.NUM_BOLTS(a0)	; Store #bolts-1 to dst.
	move.w	Lightning.IN_RADIUS(a1),Lightning.IN_RADIUS(a0)
	move.w	d7,d5
.copy_bolt_loop:
	moveq	#Lightning.LEVELS-1,d6

.copy_seg_loop:
	move.l	(a1)+,(a0)+
	dbf	d6,.copy_seg_loop

	dbf	d7,.copy_bolt_loop

	adda.w	#Lightning.START_ANGLE,a2
	adda.w	#Lightning.START_ANGLE,a3

.copy_angle_loop:
	move.w	(a3)+,(a2)+
	dbf	d5,.copy_angle_loop

	rts

; Paint new bolts..
Lightning.paint:
	move.l	Lightning.fadeSteps,d3
	sub.w	Lightning.fade_count,d3
	lsl.l	#8,d3
	divu.w	Lightning.fadeSteps+2,d3
	lea	Lightning.pal,a0
	lea	Lightning.prePal,a1
	moveq	#32-1,d7

.shift_loop:
	move.w	(a1)+,d0
	move.w	d0,d1
	move.w	d0,d2
	andi.w	#%1111100000000000,d0
	andi.w	#%0000011111100000,d1
	andi.w	#%0000000000011111,d2
	mulu.w	d3,d0
	mulu.w	d3,d1
	mulu.w	d3,d2
	lsr.l	#8,d0
	lsr.l	#8,d1
	lsr.l	#8,d2
	andi.w	#%1111100000000000,d0
	andi.w	#%0000011111100000,d1
	andi.w	#%0000000000011111,d2
	or.w	d2,d0
	or.w	d1,d0
	move.w	d0,(a0)+
	dbf	d7,.shift_loop
.end_shift:

	movea.l	Lightning.boltAddys,a0
	move.w	Lightning.NUM_BOLTS(a0),d7

.paint_loop:
	movea.l	Lightning.boltAddys,a1
	move.w	(Lightning.START_ANGLE.l,a1,d7.w*2),d0
	move.w	Lightning.IN_RADIUS(a1),d1
	move.w	d7,d2
	mulu.w	#Lightning.LEVELS*4,d2
	adda.l	d2,a1
	move.w	d7,-(sp)
	bsr.w	Lightning.paintPolybolt
	move.w	(sp)+,d7
	dbf	d7,.paint_loop
	rts

; Return random value in range [0,+r)
; INPUT:
; d0.w=r [0,65535]
; OUTPUT:
; d2.w=random value
Lightning.getRandom:
	lea	Lightning.random(pc),a4
	move.l	(a4),d1
	move.l	d1,d2
	rol.l	#5,d1
	addi.l	#$1A77F226,d1
	eor.l	d2,d1
	move.l	d1,(a4)
	clr.l	d2
	move.w	d1,d2
	divu.w	d0,d2
	swap	d2
	rts

; Return random value in range (-r,+r)
; INPUT:
; d0.w=r [0,32767]
; OUTPUT:
; d2.w=random value
Lightning.getSignedRandom:
	lea	Lightning.random(pc),a4
	move.l	(a4),d1
	move.l	d1,d2
	rol.l	#5,d1
	addi.l	#$1A77F226,d1
	eor.l	d2,d1
	move.l	d1,(a4)
	move.w	d0,d3
	add.w	d0,d0
	addq.w	#1,d0
	clr.l	d2
	move.w	d1,d2
	divu.w	d0,d2
	swap	d2
	sub.w	d3,d2
	rts

Lightning.random:
	DC.L	0

; Calcs one lightning bolt. Outputs complex numbers [|c|, arg(c)].
; INPUT:
; a0: bolt buffer
Lightning.calcbolt:
	moveq	#Lightning.LEVELS-1,d7
	move.w	#sintbllen,d0
	mulu.w	#$1C00,d0
	swap	d0
	move.w	d0,d6
	move.w	Lightning.segLength,d4
	move.w	Lightning.segRandom,d5

.loop:
; Get angle..
	move.w	d6,d0
	bsr.w	Lightning.getSignedRandom
	movea.l	d2,a2
; Get amp...
	move.w	d4,d0
	bsr.w	Lightning.getRandom
; d2.w=amp
	add.w	d5,d2

	move.w	a2,(a0)+
	move.w	d2,(a0)+

	dbra	d7,.loop
	rts

; Paints a bolt rotated round an initial angle using polys.
;
;   d.i       c.i=d.(i+1)
;   ^.........^
;   |   l.i   |
;o.i*--------->o.(i+1)
;   |         |
;   v.........v
;   a.i       b.i=a.(i+1)
;
; o.0=(0,0), o.(i+1)=o.i+l.i
;
; l.i.x=cos(angle.i)*amp.i
; l.i.y=sin(angle.i)*amp.i
;
; a.i=o.i+(-l.i.y,+l.i.x)/4
; d.i=o.i+(+l.i.y,-l.i.x)/4
;
; INPUT:
; d0.w=initial angle
; d1.w=inner radius
; d6.w=color
; a6: bolt table
Lightning.paintPolybolt:
	moveq	#Lightning.LEVELS-2,d7
	bpl.s	.okay
	rts

.okay:	move.w	d0,.angle
	movea.l	a1,a6
	movea.w	#160,a0
	movea.w	#100,a1

; Calc rotated inner radius..
	Get_SinCos	sine_tbl,d0,d0,d2
	muls.w	d1,d0
	muls.w	d1,d2
	add.l	d0,d0
	add.l	d2,d2
	swap	d0
	swap	d2
	adda.w	d0,a0
	adda.w	d2,a1

; We calculate l.0...
	move.w	(a6)+,d2
	move.w	(a6)+,d4
	add.w	.angle(pc),d2
; d2.w=angle, d4.w=amp
	Do_SinModulo	d2
	Get_SinCos	sine_tbl,d2,d2,d3
; d2.w=sin(angle), d3.w=cos(angle)
	move.w	d2,d5
	move.w	d3,d6
	muls.w	d4,d5
	muls.w	d4,d6
	add.l	d5,d5
	add.l	d6,d6
	swap	d5
	swap	d6
; d5.w=l.0.x, d6.w=l.0.y

; Now we can calculate a.0, d.0...
	IFNE	0
	move.w	d3,d0
	move.w	d2,d1
	moveq	#Lightning.WIDTH,d4
	muls.w	d4,d0
	muls.w	d4,d1
	swap	d0
	swap	d1
	move.w	d0,d2
	move.w	d1,d3
	neg.w	d0
	neg.w	d3
	add.l	a0,d0
	add.l	a1,d1
	add.l	a0,d2
	add.l	a1,d3
	ELSE
	move.l	a0,d0
	move.l	a1,d1
	move.l	a0,d2
	move.l	a1,d3
	ENDC
; a.0.x=d0.w, a.0.y=d1.w, d.0.x=d2.w, d.0.y=d3.w
; i=0

.loop:	lea	Lightning.gouPoly+4,a5
	movem.w	d0/d1,(a5)				; Output a.i (0)
	movem.w	d2/d3,18(a5)				; Output d.i (3)

; Calculate o.(i+1)=o.i+l.i
	add.w	d5,a0
	add.w	d6,a1

	move.w	.angle(pc),d5
	add.w	(a6)+,d5
	move.w	(a6)+,d4
; d5.w=angle, d4.w=amp

; Now Calculate l.(i+1)...
	Do_SinModulo	d5
	Get_SinCos	sine_tbl,d5,d5,d6
	move.w	d5,d1
	move.w	d6,d0
	muls.w	d4,d5
	muls.w	d4,d6
	add.l	d5,d5
	add.l	d6,d6
	swap	d5
	swap	d6
; d5=l.(i+1).x, d6=l.(i+1).y

; Now calculate a.(i+1), d.(i+1)
	muls.w	#Lightning.WIDTH,d0
	muls.w	#Lightning.WIDTH,d1
	swap	d0
	swap	d1
	move.w	d0,d2
	move.w	d1,d3
	neg.w	d0
	neg.w	d3
	add.l	a0,d0
	add.l	a1,d1
	add.l	a0,d2
	add.l	a1,d3
; a2=a.(i+1).x, a3=a.(i+1).y, a4=d.(i+1).x, a5=d.(i+1).y

	movem.w	d0/d1,6(a5)				; Output b.i (1)
	movem.w	d2/d3,12(a5)				; Output c.i (2)

	move.l	a6,-(sp)
	movem.w	d5/d6/d7/a0/a1,-(sp)
	lea	Lightning.gouPoly,a1
	bsr.l	Polygon.paintClippedGouraudshaded
	movem.w	(sp)+,d5/d6/d7/a0/a1
	movea.l	(sp)+,a6

	lea	Lightning.gouPoly+4,a5
	movem.w	6(a5),d0/d1				; Fetch a.(i+1) (1)
	movem.w	12(a5),d2/d3				; Fetch d.(i+1) (2)

	dbra	d7,.loop

	rts

.angle:	DC.W	0

; Paints a bolt rotated round an initial angle using polys.
;
;   d.i       c.i=d.(i+1)
;   ^.........^
;   |   l.i   |
;o.i*--------->o.(i+1)
;   |         |
;   v.........v
;   a.i       b.i=a.(i+1)
;
; o.0=(0,0), o.(i+1)=o.i+l.i
;
; l.i.x=cos(angle.i)*amp.i
; l.i.y=sin(angle.i)*amp.i
;
; a.i=o.i+(-l.i.y,+l.i.x)/4
; d.i=o.i+(+l.i.y,-l.i.x)/4
;
; INPUT:
; d0.w=initial angle
; d1.w=inner radius
; a1: bolt table
Lightning.restorePolybolt:
	moveq	#Lightning.LEVELS-2,d7
	bpl.s	.okay
	rts

.okay:	move.w	d0,.angle
	movea.l	a1,a6
	movea.w	#160,a0
	movea.w	#100,a1

; Calc rotated inner radius..
	Get_SinCos	sine_tbl,d0,d0,d2
	muls.w	d1,d0
	muls.w	d1,d2
	add.l	d0,d0
	add.l	d2,d2
	swap	d0
	swap	d2
	adda.w	d0,a0
	adda.w	d2,a1

; We calculate l.0...
	move.w	(a6)+,d2
	move.w	(a6)+,d4
	add.w	.angle(pc),d2
; d2.w=angle, d4.w=amp
	Do_SinModulo	d2
	Get_SinCos	sine_tbl,d2,d2,d3
; d2.w=sin(angle), d3.w=cos(angle)
	move.w	d2,d5
	move.w	d3,d6
	muls.w	d4,d5
	muls.w	d4,d6
	add.l	d5,d5
	add.l	d6,d6
	swap	d5
	swap	d6
; d5.w=l.0.x, d6.w=l.0.y

; Now we can calculate a.0, d.0...
	move.w	d3,d0
	move.w	d2,d1
	moveq	#Lightning.WIDTH,d4
	muls.w	d4,d0
	muls.w	d4,d1
	swap	d0
	swap	d1
	move.w	d0,d2
	move.w	d1,d3
	neg.w	d0
	neg.w	d3
	add.l	a0,d0
	add.l	a1,d1
	add.l	a0,d2
	add.l	a1,d3
; a.0.x=d0.w, a.0.y=d1.w, d.0.x=d2.w, d.0.y=d3.w
; i=0

.loop:	lea	Lightning.flatPoly+4,a5
	movem.w	d0/d1,(a5)				; Output a.i
	movem.w	d2/d3,12(a5)				; Output d.i

; Calculate o.(i+1)=o.i+l.i
	add.w	d5,a0
	add.w	d6,a1

	move.w	(a6)+,d5
	move.w	(a6)+,d4
	add.w	.angle(pc),d5
; d5.w=angle, d4.w=amp

; Now Calculate l.(i+1)...
	Do_SinModulo	d5
	Get_SinCos	sine_tbl,d5,d5,d6
	move.w	d5,d1
	move.w	d6,d0
	muls.w	d4,d5
	muls.w	d4,d6
	add.l	d5,d5
	add.l	d6,d6
	swap	d5
	swap	d6
; d5=l.(i+1).x, d6=l.(i+1).y

; Now calculate a.(i+1), d.(i+1)
	muls.w	#Lightning.WIDTH,d0
	muls.w	#Lightning.WIDTH,d1
	swap	d0
	swap	d1
	move.w	d0,d2
	move.w	d1,d3
	neg.w	d0
	neg.w	d3
	add.l	a0,d0
	add.l	a1,d1
	add.l	a0,d2
	add.l	a1,d3
; a2=a.(i+1).x, a3=a.(i+1).y, a4=d.(i+1).x, a5=d.(i+1).y

	movem.w	d0/d1,4(a5)				; Output b.i
	movem.w	d2/d3,8(a5)				; Output c.i

	move.l	a6,-(sp)
	movem.w	d5/d6/d7/a0/a1,-(sp)
	lea	Lightning.flatPoly,a1
	bsr.l	Polygon.paintClippedFlatshaded
	movem.w	(sp)+,d5/d6/d7/a0/a1
	movea.l	(sp)+,a6

	lea	Lightning.flatPoly+4,a5
	movem.w	4(a5),d0/d1				; Fetch a.(i+1)
	movem.w	8(a5),d2/d3				; Fetch d.(i+1)

	dbra	d7,.loop

	rts

.angle:	DC.W	0

;======= OBJECT DATA ========

	DATA

Lightning.gouPoly:
	DC.W	0
	DC.W	4
	DC.W	-32,+16,063
	DC.W	+32,+16,063
	DC.W	+32,-16,000
	DC.W	-32,-16,000

Lightning.flatPoly:
	DC.W	1
	DC.W	4
	DC.W	0,0
	DC.W	0,0
	DC.W	0,0
	DC.W	0,0

Lightning.boltAddys:
	DC.L	Lightning.boltTable
	DC.L	Lightning.boltTable2
	DC.L	Lightning.boltTable3

Lightning.blueInstTable:
	DC.W	(.end-.start)/4-1
	DC.W	2
	IFNE	1
.start:	DC.L	$0000001F
	DC.L	$1f1f00dF
	DC.L	$7f7f00ff
	DC.L	$afaf00ff
	DC.L	$FFFF00FF
	DC.L	$afaf00ff
	DC.L	$7f7f00ff
	DC.L	$1f1f00dF
	DC.L	$0000001F
.end:
	ELSE
.start:	DC.L	$0000001F
	DC.L	$1f1f00dF
	DC.L	$7f7f00ff
	DC.L	$cfcf00ff
	DC.L	$FFFF00FF
	DC.L	$cfcf00ff
	DC.L	$7f7f00ff
	DC.L	$1f1f00dF
	DC.L	$0000001F
.end:
	ENDC

Lightning.segLength:
	DC.W	8
Lightning.segRandom:
	DC.W	8
Lightning.fadeSteps:
	DC.L	32
Lightning.inRadius:
	DC.W	10
Lightning.pulseMode:
	DC.W	0

;======= OBJECT RESERVES ========

	BSS

	DS.W	1000
Lightning.pal:
	DS.W	256
	DS.W	1000
Lightning.prePal:
	DS.W	256
	DS.W	1000

Lightning.boltTable:
	DS.L	Lightning.BOLT_SIZE*Lightning.BOLTS
Lightning.boltTable2:
	DS.L	Lightning.BOLT_SIZE*Lightning.BOLTS
Lightning.boltTable3:
	DS.L	Lightning.BOLT_SIZE*Lightning.BOLTS

Lightning.pulseStart:
	DS.L	1
Lightning.refresh:
	DS.W	1
Lightning.fade_count:
	DS.W	1

;======= END OF DEMO-EFFECT OBJECT ========