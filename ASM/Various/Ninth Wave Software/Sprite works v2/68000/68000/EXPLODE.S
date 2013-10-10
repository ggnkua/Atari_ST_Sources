;
; Pixel explosions. Uses 12 bytes per solid pixel
;
	
	bra	explode
	bra	plot_explosion
	bra	clip_explosion
	
explode	movem.l	d1-7/a0-6,-(a7)
	movem	60(a7),d0-7
	movem.l	78(a7),a0-1
	lea	screen(pc),a2
	move.l	a1,(a2)+	; screen
	move.l	a0,(a2)		; buffer
	move.l	a0,a1		
	lea	centers(pc),a2
	move	d4,(a2)		; center x
	move	d5,2(a2)	; center y
	lea	speed(pc),a0
	move	d6,(a0)+	; speed
	move	d7,(a0)		; gravity
	move	76(a7),d7	; random factor
	lea	rand(pc),a6
	move	d7,(a6)
	bsr	store		; store all points in rectangle
	move	(a6),d0
	ext.l	d0
	movem.l	(a7)+,d1-7/a0-6
	rts

plot_explosion
	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d7	; time frame
	move.l	62(a7),a3	; screen
	move.l	buffer(pc),a1
	lea	clip_window(pc),a4
	bsr.s	plot_points
	movem.l	(a7)+,d1-7/a0-6
	rts

plot_points
	move	(a1)+,d6	; get number of points
	subq	#1,d6
	bmi.s	.end		; no points to plot
.lp	swap	d6		; save d6 in high word
	move	(a1)+,d0	; get x
	move	(a1)+,d1	; get y
	move	(a1)+,d6	; get colour

	move	speed(pc),d5
	mulu	d7,d5
	lsr	#4,d5		; speed*time/16

	move	d5,d2
	muls	(a1)+,d2	; (speed*time/16)*cos(theta)
	add.l	d2,d2	
	add.l	d2,d2
	swap	d2		; dx, divide by 2^14

	move	d5,d3
	muls	(a1)+,d3	; (speed*time/16)*sin(theta)
	add.l	d3,d3
	add.l	d3,d3
	swap	d3		; dy, divide by 2^14

	move	d7,d4
	mulu	d4,d4
	mulu	(a1)+,d4	; gravity*(time^2)
	asr.l	#8,d4		; gravity*(time^2)/2^8
	sub.l	d4,d3		; subtract gravity from dy
	
	add	d2,d0		; add dx
	sub	d3,d1		; subtract dy
	
	move	d6,d2		; get colour
	bsr.s	plot		; plot it !
	
	swap	d6		; quicker than -(a7)
	dbf	d6,.lp
.end	rts

rand	ds.w	1
speed	ds.w	1
gravity	ds.w	1

plot	move.l	a3,a0
	cmp	(a4),d0		; clipping
	blt.s	off_screen
	cmp	4(a4),d0
	bgt.s	off_screen
	cmp	2(a4),d1
	blt.s	off_screen
	cmp	6(a4),d1
	bgt.s	off_screen
	ext.l	d1
	move	d1,d3		; calc screen offset
	lsl	#2,d1
	add	d3,d1
	lsl.l	#5,d1
	move	d0,d3
	lsr	#1,d3
	and	#$fff8,d3
	add	d3,d1
	add.l	d1,a0		; a0->screen address
	and	#$f,d0
	add	d0,d0
	add	d0,d0
	move.l	pixmask(pc,d0),d0
	move.l	d0,d1
	not.l	d1		; get pixel and mask
	add	d2,d2
	move	here(pc,d2),d2	
	jsr	here(pc,d2)	; jump to plot routine 0-15
off_screen
	rts
	
pixmask	dc.l	$80008000,$40004000,$20002000,$10001000
	dc.l	$08000800,$04000400,$02000200,$01000100
	dc.l	$00800080,$00400040,$00200020,$00100010
	dc.l	$00080008,$00040004,$00020002,$00010001
here	dc.w	colour0-here
	dc.w	colour1-here
	dc.w	colour2-here
	dc.w	colour3-here
	dc.w	colour4-here
	dc.w	colour5-here
	dc.w	colour6-here
	dc.w	colour7-here
	dc.w	colour8-here
	dc.w	colour9-here
	dc.w	colour10-here
	dc.w	colour11-here
	dc.w	colour12-here
	dc.w	colour13-here
	dc.w	colour14-here
	dc.w	colour15-here
	
store	move.l	buffer(pc),a6
	clr	(a6)
	lea	2(a6),a1
.ylp	move	d0,-(a7)
.xlp	bsr	get_pixel
	tst	d5
	beq.s	.nxtpix
	move	d0,(a1)+	; x
	move	d1,(a1)+	; y
	move	d5,(a1)+	; colour
	bsr	arctan
	add	d4,d4
	bsr	random
	move	d6,d7
	move	rand(pc),d5
	lsl	#2,d5
	lea	rand_arc(pc,d5),a3
	and	(a3)+,d6
	sub	(a3),d6
	add	d6,d4
	and	#$fffe,d4
	lea	sintab(pc),a3
	lea	256(a3),a4
	move	(a4,d4),(a1)+	; cos(theta)
	move	(a3,d4),(a1)+	; sin(theta)
	move	rand(pc),d6
	lsl	#3,d6
	lea	rand_gravity(pc,d6),a3
	and	#%111,d7
	move.b	(a3,d7),d7
	ext	d7
	add	gravity(pc),d7
	move	d7,(a1)+
	addq	#1,(a6)		; increase number of points
.nxtpix	addq	#1,d0
	cmp	d2,d0
	ble.s	.xlp
	move	(a7)+,d0
	addq	#1,d1
	cmp	d3,d1
	ble.s	.ylp
	rts

rand_arc
	dc.w	%00000000,0
	dc.w	%00000001,1
	dc.w	%00000011,2
	dc.w	%00000111,4
	dc.w	%00001111,8
	dc.w	%00011111,16
	dc.w	%00111111,32
	dc.w	%01111111,64
	dc.w	%11111111,128
rand_gravity
	dc.b	0,0,0,0,0,0,0,0
	dc.b	0,1,0,1,0,1,0,1
	dc.b	0,1,2,1,0,1,2,1
	dc.b	0,1,2,3,2,1,0,1
	dc.b	0,1,2,3,4,3,2,1
	dc.b	0,1,2,3,4,0,1,2
	dc.b	0,1,2,3,4,2,1,0
	dc.b	0,2,3,3,4,3,2,1
	
; ARCTAN D0=x D1=y D2=center x D3=center y
; Returns : D4=angle (0-511)
; Angle 0 is 3 o'clock and increases anticlockwise

arctan	movem	d2-3,-(a7)
	move	(a2),d2
	move	2(a2),d3
	lea	tantab(pc),a0
	move	d2,d4
	sub	d0,d4		; dx
	bpl.s	.absdx
	neg	d4
.absdx	move	d3,d5
	sub	d1,d5		; dy
	bpl.s	.absdy
	neg	d5
.absdy	ext.l	d4
	ext.l	d5
	cmp	d0,d2
	bgt.s	.left
	cmp	d1,d3
	blt.s	.down
	cmp	d5,d4
	blt.s	.gradb
	lsl.l	#6,d5
	divu	d4,d5
	add	d5,d5
	move	(a0,d5.w),d4
	bra	.end
.gradb	lsl.l	#6,d4
	divu	d5,d4
	add	d4,d4
	move	(a0,d4.w),d5
	move	#128,d4
	sub	d5,d4
	bra.s	.end
.down	cmp	d5,d4
	blt.s	.gradc
	lsl.l	#6,d5
	divu	d4,d5
	add	d5,d5
	move	(a0,d5.w),d5
	move	#512,d4
	sub	d5,d4
	bra.s	.end
.gradc	lsl.l	#6,d4
	divu	d5,d4
	add	d4,d4
	move	(a0,d4.w),d4
	add	#384,d4
	bra.s	.end
	
.left	cmp	d1,d3
	blt.s	.downb
	cmp	d5,d4
	blt.s	.gradd
	lsl.l	#6,d5
	divu	d4,d5
	add	d5,d5
	move	(a0,d5.w),d5
	move	#256,d4
	sub	d5,d4
	bra.s	.end
.gradd	lsl.l	#6,d4
	divu	d5,d4
	add	d4,d4
	move	(a0,d4.w),d4
	add	#128,d4
	bra.s	.end
.downb	cmp	d5,d4
	blt.s	.grade
	lsl.l	#6,d5
	divu	d4,d5
	add	d5,d5
	move	(a0,d5.w),d4
	add	#256,d4
	bra.s	.end
.grade	lsl.l	#6,d4
	divu	d5,d4
	add	d4,d4
	move	(a0,d4.w),d5
	move	#384,d4
	sub	d5,d4
.end	movem	(a7)+,d2-3
	rts
	
tantab	dc.w 0,1,2,3,5,6,7,8
	dc.w 10,11,12,13,15,16,17,18
	dc.w 19,21,22,23,24,25,26,28
	dc.w 29,30,31,32,33,34,35,36
	dc.w 37,38,39,40,41,42,43,44
	dc.w 45,46,47,48,49,49,50,51
	dc.w 52,53,54,54,55,56,57,57
	dc.w 58,59,59,60,61,62,62,63
	dc.w 64

get_pixel
	movem	d0-4,-(a7)
	move.l	screen(pc),a0
	moveq	#0,d3
	move	d1,d3
	lsl	#2,d3
	add	d1,d3
	lsl.l	#5,d3
	add.l	d3,a0
	move	d0,d3
	lsr	#1,d0
	and	#$fff8,d0
	add	d0,a0
	and	#$f,d3
	neg	d3
	add	#15,d3
	clr	d0
	bset	d3,d0
	clr	d5
	movem	(a0),d1-4
	and	d0,d1
	beq.s	.b1
	or	#1,d5
.b1	and	d0,d2
	beq.s	.b2
	or	#2,d5
.b2	and	d0,d3
	beq.s	.b3
	or	#4,d5
.b3	and	d0,d4
	beq.s	.b4
	or	#8,d5
.b4	movem	(a7)+,d0-4
	rts	
	
screen	ds.l	1
buffer	ds.l	1
	
colour0	and.l	d1,(a0)+
	and.l	d1,(a0)
	rts
colour1	or	d0,(a0)+
	and	d1,(a0)+
	and.l	d1,(a0)
	rts
colour2	and	d1,(a0)+
	or	d0,(a0)+
	and.l	d1,(a0)
	rts
colour3	or	d0,(a0)+
	or	d0,(a0)+
	and.l	d1,(a0)
	rts
colour4	and.l	d1,(a0)+
	or	d0,(a0)+
	and	d1,(a0)
	rts
colour5	or	d0,(a0)+
	and	d1,(a0)+
	or	d0,(a0)+
	and	d1,(a0)
	rts
colour6	and	d1,(a0)+
	or.l	d0,(a0)+
	and	d1,(a0)
	rts

colour7	or.l	d0,(a0)+
	or	d0,(a0)+
	and	d1,(a0)
	rts
colour8	and.l	d1,(a0)+
	and	d1,(a0)+
	or	d0,(a0)
	rts
colour9	or	d0,(a0)+
	and.l	d1,(a0)+
	or	d0,(a0)
	rts
colour10 and	d1,(a0)+
	or	d0,(a0)+
	and	d1,(a0)+
	or	d0,(a0)
	rts
colour11 or.l	d0,(a0)+
	and	d1,(a0)+
	or	d0,(a0)
	rts
colour12 and.l	d1,(a0)+
	or.l	d0,(a0)
	rts
colour13 or	d0,(a0)+
	and	d1,(a0)+
	or.l	d0,(a0)
	rts
colour14 and	d1,(a0)+
	or	d0,(a0)+
	or.l	d0,(a0)
	rts
colour15 or.l	d0,(a0)+
	or.l	d0,(a0)
	rts

random	move	d1,-(a7)
	lea	seed(pc),a5
	move	(a5),d6
	addq	#1,d6
	move	d6,d1
	add	d6,d6
	add	d1,d6
	ror	#7,d6
	move	d6,(a5)
	move	(a7)+,d1
	rts
seed	dc.w	31415

clip_explosion
	movem.l	d1-3/a0,-(a7)
	movem	20(a7),d0-3
	lea	clip_window(pc),a0
	movem	d0-3,(a0)
	movem.l	(a7)+,d1-3/a0
	rts
clip_window
	dc.w	0,0,319,199

	dc.w $2D41,$2DCE,$2E5A,$2EE3,$2F6B,$2FF1,$3076,$30F8
	dc.w $3179,$31F7,$3274,$32EE,$3367,$33DE,$3453,$34C6
	dc.w $3536,$35A5,$3612,$367C,$36E5,$374B,$37AF,$3811
	dc.w $3871,$38CF,$392A,$3983,$39DA,$3A2F,$3A82,$3AD2
	dc.w $3B20,$3B6C,$3BB6,$3BFD,$3C42,$3C84,$3CC5,$3D02
	dc.w $3D3E,$3D77,$3DAE,$3DE2,$3E14,$3E44,$3E71,$3E9C
	dc.w $3EC5,$3EEB,$3F0E,$3F2F,$3F4E,$3F6A,$3F84,$3F9C
	dc.w $3FB1,$3FC3,$3FD3,$3FE1,$3FEC,$3FF4,$3FFB,$3FFE
sintab	dc.w $0000,$00C9,$0192,$025B,$0323,$03EC,$04B5,$057D
	dc.w $0645,$070D,$07D5,$089C,$0964,$0A2A,$0AF1,$0BB6
	dc.w $0C7C,$0D41,$0E05,$0EC9,$0F8C,$104F,$1111,$11D3
	dc.w $1294,$1354,$1413,$14D1,$158F,$164C,$1708,$17C3
	dc.w $187D,$1937,$19EF,$1AA6,$1B5D,$1C12,$1CC6,$1D79
	dc.w $1E2B,$1EDC,$1F8B,$2039,$20E7,$2192,$223D,$22E6
	dc.w $238E,$2434,$24DA,$257D,$261F,$26C0,$275F,$27FD
	dc.w $2899,$2934,$29CD,$2A65,$2AFA,$2B8E,$2C21,$2CB2
	dc.w $2D41,$2DCE,$2E5A,$2EE3,$2F6B,$2FF1,$3076,$30F8
	dc.w $3179,$31F7,$3274,$32EE,$3367,$33DE,$3453,$34C6
	dc.w $3536,$35A5,$3612,$367C,$36E5,$374B,$37AF,$3811
	dc.w $3871,$38CF,$392A,$3983,$39DA,$3A2F,$3A82,$3AD2
	dc.w $3B20,$3B6C,$3BB6,$3BFD,$3C42,$3C84,$3CC5,$3D02
	dc.w $3D3E,$3D77,$3DAE,$3DE2,$3E14,$3E44,$3E71,$3E9C
	dc.w $3EC5,$3EEB,$3F0E,$3F2F,$3F4E,$3F6A,$3F84,$3F9C
	dc.w $3FB1,$3FC3,$3FD3,$3FE1,$3FEC,$3FF4,$3FFB,$3FFE
	dc.w $4000,$3FFE,$3FFB,$3FF4,$3FEC,$3FE1,$3FD3,$3FC3
	dc.w $3FB1,$3F9C,$3F84,$3F6A,$3F4E,$3F2F,$3F0E,$3EEB
	dc.w $3EC5,$3E9C,$3E71,$3E44,$3E14,$3DE2,$3DAE,$3D77
	dc.w $3D3E,$3D02,$3CC5,$3C84,$3C42,$3BFD,$3BB6,$3B6C
	dc.w $3B20,$3AD2,$3A82,$3A2F,$39DA,$3983,$392A,$38CF
	dc.w $3871,$3811,$37AF,$374B,$36E5,$367C,$3612,$35A5
	dc.w $3536,$34C6,$3453,$33DE,$3367,$32EE,$3274,$31F7
	dc.w $3179,$30F8,$3076,$2FF1,$2F6B,$2EE3,$2E5A,$2DCE
	dc.w $2D41,$2CB2,$2C21,$2B8E,$2AFA,$2A65,$29CD,$2934
	dc.w $2899,$27FD,$275F,$26C0,$261F,$257D,$24DA,$2434
	dc.w $238E,$22E6,$223D,$2192,$20E7,$2039,$1F8B,$1EDC
	dc.w $1E2B,$1D79,$1CC6,$1C12,$1B5D,$1AA6,$19EF,$1937
	dc.w $187D,$17C3,$1708,$164C,$158F,$14D1,$1413,$1354
	dc.w $1294,$11D3,$1111,$104F,$0F8C,$0EC9,$0E05,$0D41
	dc.w $0C7C,$0BB6,$0AF1,$0A2A,$0964,$089C,$07D5,$070D
	dc.w $0645,$057D,$04B5,$03EC,$0323,$025B,$0192,$00C9
	dc.w $0000,$FF37,$FE6E,$FDA5,$FCDD,$FC14,$FB4B,$FA83
	dc.w $F9BB,$F8F3,$F82B,$F764,$F69C,$F5D6,$F50F,$F44A
	dc.w $F384,$F2BF,$F1FB,$F137,$F074,$EFB1,$EEEF,$EE2D
	dc.w $ED6C,$ECAC,$EBED,$EB2F,$EA71,$E9B4,$E8F8,$E83D
	dc.w $E783,$E6C9,$E611,$E55A,$E4A3,$E3EE,$E33A,$E287
	dc.w $E1D5,$E124,$E075,$DFC7,$DF19,$DE6E,$DDC3,$DD1A
	dc.w $DC72,$DBCC,$DB26,$DA83,$D9E1,$D940,$D8A1,$D803
	dc.w $D767,$D6CC,$D633,$D59B,$D506,$D472,$D3DF,$D34E
	dc.w $D2BF,$D232,$D1A6,$D11D,$D095,$D00F,$CF8A,$CF08
	dc.w $CE87,$CE09,$CD8C,$CD12,$CC99,$CC22,$CBAD,$CB3A
	dc.w $CACA,$CA5B,$C9EE,$C984,$C91B,$C8B5,$C851,$C7EF
	dc.w $C78F,$C731,$C6D6,$C67D,$C626,$C5D1,$C57E,$C52E
	dc.w $C4E0,$C494,$C44A,$C403,$C3BE,$C37C,$C33B,$C2FE
	dc.w $C2C2,$C289,$C252,$C21E,$C1EC,$C1BC,$C18F,$C164
	dc.w $C13B,$C115,$C0F2,$C0D1,$C0B2,$C096,$C07C,$C064
	dc.w $C04F,$C03D,$C02D,$C01F,$C014,$C00C,$C005,$C002
	dc.w $C000,$C002,$C005,$C00C,$C014,$C01F,$C02D,$C03D
	dc.w $C04F,$C064,$C07C,$C096,$C0B2,$C0D1,$C0F2,$C115
	dc.w $C13B,$C164,$C18F,$C1BC,$C1EC,$C21E,$C252,$C289
	dc.w $C2C2,$C2FE,$C33B,$C37C,$C3BE,$C403,$C44A,$C494
	dc.w $C4E0,$C52E,$C57E,$C5D1,$C626,$C67D,$C6D6,$C731
	dc.w $C78F,$C7EF,$C851,$C8B5,$C91B,$C984,$C9EE,$CA5B
	dc.w $CACA,$CB3A,$CBAD,$CC22,$CC99,$CD12,$CD8C,$CE09
	dc.w $CE87,$CF08,$CF8A,$D00F,$D095,$D11D,$D1A6,$D232
	dc.w $D2BF,$D34E,$D3DF,$D472,$D506,$D59B,$D633,$D6CC
	dc.w $D767,$D803,$D8A1,$D940,$D9E1,$DA83,$DB26,$DBCC
	dc.w $DC72,$DD1A,$DDC3,$DE6E,$DF19,$DFC7,$E075,$E124
	dc.w $E1D5,$E287,$E33A,$E3EE,$E4A3,$E55A,$E611,$E6C9
	dc.w $E783,$E83D,$E8F8,$E9B4,$EA71,$EB2F,$EBED,$ECAC
	dc.w $ED6C,$EE2D,$EEEF,$EFB1,$F074,$F137,$F1FB,$F2BF
	dc.w $F384,$F44A,$F50F,$F5D6,$F69C,$F764,$F82B,$F8F3
	dc.w $F9BB,$FA83,$FB4B,$FC14,$FCDD,$FDA5,$FE6E,$FF37
	dc.w $0000,$00C9,$0192,$025B,$0323,$03EC,$04B5,$057D
	dc.w $0645,$070D,$07D5,$089C,$0964,$0A2A,$0AF1,$0BB6
	dc.w $0C7C,$0D41,$0E05,$0EC9,$0F8C,$104F,$1111,$11D3
	dc.w $1294,$1354,$1413,$14D1,$158F,$164C,$1708,$17C3
	dc.w $187D,$1937,$19EF,$1AA6,$1B5D,$1C12,$1CC6,$1D79
	dc.w $1E2B,$1EDC,$1F8B,$2039,$20E7,$2192,$223D,$22E6
	dc.w $238E,$2434,$24DA,$257D,$261F,$26C0,$275F,$27FD
	dc.w $2899,$2934,$29CD,$2A65,$2AFA,$2B8E,$2C21,$2CB2
	dc.w $2D41,$2DCE,$2E5A,$2EE3,$2F6B,$2FF1,$3076,$30F8
	dc.w $3179,$31F7,$3274,$32EE,$3367,$33DE,$3453,$34C6
	dc.w $3536,$35A5,$3612,$367C,$36E5,$374B,$37AF,$3811
	dc.w $3871,$38CF,$392A,$3983,$39DA,$3A2F,$3A82,$3AD2
	dc.w $3B20,$3B6C,$3BB6,$3BFD,$3C42,$3C84,$3CC5,$3D02
	dc.w $3D3E,$3D77,$3DAE,$3DE2,$3E14,$3E44,$3E71,$3E9C
	dc.w $3EC5,$3EEB,$3F0E,$3F2F,$3F4E,$3F6A,$3F84,$3F9C
	dc.w $3FB1,$3FC3,$3FD3,$3FE1,$3FEC,$3FF4,$3FFB,$3FFE
	dc.w $4000
	dc.w $0000,$00C9,$0192,$025B,$0323,$03EC,$04B5,$057D
	dc.w $0645,$070D,$07D5,$089C,$0964,$0A2A,$0AF1,$0BB6
	dc.w $0C7C,$0D41,$0E05,$0EC9,$0F8C,$104F,$1111,$11D3
	dc.w $1294,$1354,$1413,$14D1,$158F,$164C,$1708,$17C3
	dc.w $187D,$1937,$19EF,$1AA6,$1B5D,$1C12,$1CC6,$1D79
	dc.w $1E2B,$1EDC,$1F8B,$2039,$20E7,$2192,$223D,$22E6
	dc.w $238E,$2434,$24DA,$257D,$261F,$26C0,$275F,$27FD
	dc.w $2899,$2934,$29CD,$2A65,$2AFA,$2B8E,$2C21,$2CB2

centers	ds.w	2
maxy	ds.w	1
	
