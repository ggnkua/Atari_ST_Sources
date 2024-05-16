; Texturegenerators: envmap and texturemap..

;======= equates

; fake gauss bump pars..
FlareGen.BUMP_D:	=	$00C0		; rel. diam of gauss bump (8:8)

; ring pars..
FlareGen.IN_RING:	=	80<<16		; inner radius of ring (16:16)
FlareGen.OUT_RING:	=	80<<16		; outer radius of ring (16:16)
FlareGen.RING_MID:	=	(FlareGen.IN_RING+FlareGen.OUT_RING)/2	; center of ring (16:16)
FlareGen.RING_W:	=	(FlareGen.OUT_RING-FlareGen.IN_RING)>>9	; width of ring / 256 (16:16)

; sparkle line pars..
FlareGen.LINES_ON:	=	1		; (de)activate lines
FlareGen.LINEAMP:	=	$0280		; line amplitude (frac)
FlareGen.NUMLINES:	=	5		; #lines (int)
FlareGen.LINETHIN:	=	0		; inv log of linewidth
FlareGen.LINEFADESPEED:	=	1		; inv line fade speed (int)
FlareGen.NOISEFREQ:	=	17		; speed of noise (int)
FlareGen.NOISEAMP:	=	$7FFF		; amp of noise (sgn frac)

; Flare dimensions..
FlareGen.WIDTH:		=	64
FlareGen.W1:		=	64
FlareGen.W2:		=	12
FlareGen.W3:		=	20

Texture.CUB_INT:=	1

; Max size: required for bufferdimensions!
Texture.SIZELOG:=	7
Texture.SIZE:	=	1<<Texture.SIZELOG

;======= subroutines

	ifne	0

; Envmap texture generation library!

; OUTPUT:
; d0.l: 0 = All clear, neg = Error! Not initialized!
FlareGen.init:
	move.l	#$27863E14,random

; Generate palettes..
	lea	FlareGen.greenInstTable,a1
	lea	FlareGen.greenPal,a0
	bsr	Pal.makeGradientHc

	lea	FlareGen.copperInstTable,a1
	lea	FlareGen.copperPal,a0
	bsr	Pal.makeGradientHc

	lea	FlareGen.goldInstTable,a1
	lea	FlareGen.goldPal,a0
	bsr	Pal.makeGradientHc

	lea	FlareGen.iceInstTable,a1
	lea	FlareGen.icePal,a0
	bsr	Pal.makeGradientHc

	lea	FlareGen.chromeInstTable,a1
	lea	FlareGen.chromePal,a0
	bsr	Pal.makeGradientHc

	lea	FlareGen.blueInstTable,a1
	lea	FlareGen.bluePal,a0
	bsr	Pal.makeGradientHc

	lea	FlareGen.blue2InstTable,a1
	lea	FlareGen.blue2Pal,a0
	bsr	Pal.makeGradientHc

	lea	FlareGen.fogInstTable,a1
	lea	FlareGen.fogPal,a0
	bsr	Pal.makeGradientHc

	lea	FlareGen.grayInstTable,a1
	lea	FlareGen.grayPal,a0
	bsr	Pal.makeGradientHc

	lea	FlareGen.grInstTable,a1
	lea	FlareGen.grPal,a0
	bsr	Pal.makeGradientHc

	lea	Texture.sandInstTable,a1
	lea	Texture.sandPal,a0
	bsr	Pal.makeGradientHc

	lea	Texture.redInstTable,a1
	lea	Texture.redPal,a0
	bsr	Pal.makeGradientHc

; Zero order hold... or chopscale up by factor 2.
	lea	Texture.redPal,a0
	moveq	#128-1,d7
.hold_loop:
	move.w	(a0)+,(a0)+
	dbf	d7,.hold_loop

; Precalc all greyscale flares and bumps..
	lea	FlareGen.flare1,a0
	move.w	#FlareGen.W1,d0
	bsr	FlareGen.calcFlare

	lea	FlareGen.flare2,a0
	moveq	#FlareGen.W2,d0
	bsr	FlareGen.calcBump

	lea	FlareGen.flare3,a0
	moveq	#FlareGen.W3,d0
	bsr	FlareGen.calcBump

; Now use palettes, flares and bumps to make to envtextures..
	bsr.w	FlareGen.genGoldWithSparks
	bsr.w	FlareGen.genChromeCopper
	bsr.w	FlareGen.genChromeFog
	bsr.w	FlareGen.genRed
	bsr.w	FlareGen.genParelMoer

.success:
	moveq	#0,d0
	rts
.error:	moveq	#-1,d0
	rts

FlareGen.genParelMoer:
	lea	FlareGen.parelMoerBuffer,a0
	move.l	#"Word",(a0)+
	move.l	#"PerP",(a0)+
	move.l	#"ixel",(a0)+
	move.l	#$00400040,(a0)+

	move.w	#%1111101011101011,d0
	move.w	#64*64-1,d7
.loop:	move.w	d0,(a0)+
	dbf	d7,.loop

	lea	FlareGen.parelMoerBuffer+20,a0
	lea	FlareGen.flare1,a1
	lea	FlareGen.grayPal,a2
	move.w	#FlareGen.W1,d0
	move.w	#FlareGen.W1,d1
	move.w	#FlareGen.WIDTH/2,d2
	move.w	#FlareGen.WIDTH/2,d3
	bsr.w	FlareGen.addBlock

	rts

FlareGen.genRed:
	lea	FlareGen.redBuffer,a0
	move.l	#"Word",(a0)+
	move.l	#"PerP",(a0)+
	move.l	#"ixel",(a0)+
	move.l	#$00400040,(a0)+

	lea	FlareGen.redBuffer+20,a0
	lea	FlareGen.flare1,a1
	lea	Texture.redPal,a2
	move.w	#FlareGen.W1,d0
	move.w	#FlareGen.W1,d1
	move.w	#FlareGen.WIDTH/2,d2
	move.w	#FlareGen.WIDTH/2,d3
	bsr	FlareGen.addBlock

	rts

FlareGen.genGoldWithSparks:
	lea	FlareGen.goldBuffer,a0
	move.l	#"Word",(a0)+
	move.l	#"PerP",(a0)+
	move.l	#"ixel",(a0)+
	move.l	#$00400040,(a0)+

	lea	FlareGen.goldBuffer+20,a0
	lea	FlareGen.flare1,a1
	lea	FlareGen.goldPal,a2
	move.w	#FlareGen.W1,d0
	move.w	#FlareGen.W1,d1
	move.w	#FlareGen.WIDTH/2,d2
	move.w	#FlareGen.WIDTH/2,d3
	bsr	FlareGen.addBlock

	lea	FlareGen.goldBuffer+20,a0
	lea	FlareGen.flare2,a1
	lea	FlareGen.grayPal,a2
	move.w	#FlareGen.W2,d0
	move.w	#FlareGen.W2,d1
	move.w	#3*FlareGen.WIDTH/8,d2
	move.w	#1*FlareGen.WIDTH/4,d3
	bsr	FlareGen.addBlock

	lea	FlareGen.goldBuffer+20,a0
	lea	FlareGen.flare3,a1
	lea	FlareGen.grayPal,a2
	move.w	#FlareGen.W3,d0
	move.w	#FlareGen.W3,d1
	move.w	#3*FlareGen.WIDTH/4,d2
	move.w	#3*FlareGen.WIDTH/8,d3
	bsr	FlareGen.addBlock
	rts

FlareGen.genChromeCopper:
	lea	FlareGen.chromeBuffer,a0
	move.l	#"Word",(a0)+
	move.l	#"PerP",(a0)+
	move.l	#"ixel",(a0)+
	move.l	#$00400040,(a0)+

	lea	FlareGen.chromeBuffer+20,a0
	lea	FlareGen.flare1,a1
	lea	FlareGen.chromePal,a2
	move.w	#FlareGen.W1,d0
	move.w	#FlareGen.W1,d1
	move.w	#FlareGen.WIDTH/2,d2
	move.w	#FlareGen.WIDTH/2,d3
	bsr	FlareGen.addBlock

	lea	FlareGen.chromeBuffer+20,a0
	lea	FlareGen.flare2,a1
	lea	FlareGen.copperPal,a2
	move.w	#FlareGen.W2,d0
	move.w	#FlareGen.W2,d1
	move.w	#3*FlareGen.WIDTH/8,d2
	move.w	#3*FlareGen.WIDTH/4,d3
	bsr	FlareGen.addBlock

	lea	FlareGen.chromeBuffer+20,a0
	lea	FlareGen.flare3,a1
	lea	FlareGen.copperPal,a2
	move.w	#FlareGen.W3,d0
	move.w	#FlareGen.W3,d1
	move.w	#1*FlareGen.WIDTH/4,d2
	move.w	#3*FlareGen.WIDTH/8,d3
	bsr	FlareGen.addBlock
	rts

FlareGen.genChromeFog:
	lea	FlareGen.chromeFogBuffer,a0
	move.l	#"Word",(a0)+
	move.l	#"PerP",(a0)+
	move.l	#"ixel",(a0)+
	move.l	#$00400040,(a0)+

	lea	FlareGen.chromeFogBuffer+20,a0
	lea	FlareGen.flare1,a1
	lea	FlareGen.chromePal,a2
	move.w	#FlareGen.W1,d0
	move.w	#FlareGen.W1,d1
	move.w	#FlareGen.WIDTH/2,d2
	move.w	#FlareGen.WIDTH/2,d3
	bsr	FlareGen.addBlock

	lea	FlareGen.chromeFogBuffer+20,a0
	lea	FlareGen.flare2,a1
	lea	FlareGen.bluePal,a2
	move.w	#FlareGen.W2,d0
	move.w	#FlareGen.W2,d1
	move.w	#3*FlareGen.WIDTH/4,d2
	move.w	#11*FlareGen.WIDTH/16,d3
	bsr	FlareGen.addBlock

	lea	FlareGen.chromeFogBuffer+20,a0
	lea	FlareGen.flare3,a1
	lea	FlareGen.bluePal,a2
	move.w	#FlareGen.W3,d0
	move.w	#FlareGen.W3,d1
	move.w	#3*FlareGen.WIDTH/4,d2
	move.w	#13*FlareGen.WIDTH/16,d3
	bsr	FlareGen.addBlock
	rts

	endc

	ifne	0

; INPUT:
; d0.l=x (16:16)
; OUTPUT:
; d0.w=bandlimited noise of (x) [$8000..$7FFF]
FlareGen.calcNoise1d:
	move.l	#$15F345EF,d2

	move.l	d0,d4
	sub.w	d0,d0				; d0.l=i=floor(x) (16:16)
	sub.l	d0,d4				; d4.l=f=x-i (16:16)
	asr.w	#1,d4				; d4.w=f (sgn frac)
	swap	d0				; d0.w=i (int)

	move.w	d0,d1				; d1.w=i (int)
	mulu.w	d0,d0
	rol.l	d0,d0
	eor.l	d2,d0
	swap	d0
	eor.w	d1,d0

	addq.w	#1,d1				; d1.w=i+1 (int)
	move.w	d1,d3				; d3.w=i+1 (int)
	mulu.w	d1,d1
	rol.l	d1,d1
	eor.l	d2,d1
	swap	d1
	eor.w	d3,d1
; d0.w=n0=rand(i), d1.w=n1=rand(i+1)

	sub.w	d0,d1				; d1.w=n1-n0
	muls.w	d1,d4				; d4.l=f(n1-n0)/2 (16:16)
	add.l	d4,d4				; d4.l=f(n1-n0) (16:16)
	swap	d4				; d4.w=f(n1-n0) (sgn frac)
	ext.l	d0
	ext.l	d4
	add.l	d4,d0				; d0.w=n0+f(n1-n0)=n0(1-f)+n1(f)
	rts


; Fuck this floating shit! I do it fixedpoint and with sqrt(x) instead of
; exp(-x).
;
; INPUT:
; d0.w=width=height=r, 0<r<256
; a0: dst heightfield
FlareGen.calcFlare:
	moveq	#1,d7
	move.w	d0,.radius
	sub.w	d0,d7				; d7.w=1-r
	addq.w	#1,d0
	move.w	d0,.one_plus_r
	move.w	d7,.one_min_r

.yloop:	move.w	.one_min_r(pc),d6

.xloop:	move.w	d6,d0
	move.w	d7,d1
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d0,d1				; d1.l=dx^2+dy^2
	bsr	Math.sqrt
; d0.l=d=sqrt(dx^2+dy^2) (16:16)
	movea.l	d0,a2				; a2=d (16:16)

	move.w	.radius(pc),d1
	mulu.w	#FlareGen.BUMP_D,d1
	divu.w	d1,d0
	cmpi.w	#256,d0
	bhs.s	.oki
	not.b	d0
	bra.s	.bump_done
.oki:	clr.b	d0
.bump_done:
	andi.l	#$000000FF,d0
; d0.l=bumph (int)

; if d < rmin or d > rmax, then ringh=0.
	cmpa.l	#FlareGen.IN_RING,a2
	ble.s	.endcalcring 
	cmpa.l	#FlareGen.OUT_RING,a2
	bgt.s	.endcalcring
.calcring:
	move.l	a2,d3
	subi.l	#FlareGen.RING_MID,d3		; d3.l=d-rmid (16:16)
	bpl.s	.abs_done
	neg.l	d3
.abs_done:
; d3.l=|d-rmid| (16:16)
	divu.w	#FlareGen.RING_W,d3
; d3.w=ring=|d-rmid|<<8/rwidth

	move.w	d3,d4
	add.w	d4,d4				; d4.w=2*ring (8:8)
	move.w	#$0300,d5
	sub.w	d4,d5				; d5.w=3-2*ring (8:8)
	mulu.w	d3,d5
	lsr.l	#8,d5				; d5.w=ring(3-2*ring) (8:8)
	mulu.w	d3,d5
	lsr.l	#8,d5				; d5.w=ring^2*(3-2*ring) (8:8)
	move.w	#$0100,d3
	sub.w	d5,d3				; d3.w=1-ring^2*(3-2*ring) (8:8)
	andi.l	#$0000FFFF,d3
	divu.w	#3,d3
	add.w	d3,d0				; d0.w=bumph+ringh
.endcalcring:
; d0.w=bumph+ringh (int)

	IFNE	FlareGen.LINES_ON
; Calculate lines..
	move.w	d6,d1
	ext.l	d1
	lsl.l	#8,d1
	divs.w	d7,d1
	ext.l	d1
	lsl.l	#8,d1

	movem.l	d0/d6/d7,-(sp)

	move.l	d1,d0
	bsr	Frac.arctan
; d0.l=arctan(y/x) (16:16)
	addi.l	#$0003243F,d1			; d1.l=v=arctan(y/x)+pi (16:16)
	move.l	d1,-(sp)
	move.l	d1,d0
	mulu.l	#FlareGen.NOISEFREQ,d0		; d0.l=fr*v, pump up noise frequency
	bsr	FlareGen.calcNoise1d
	muls.w	#FlareGen.NOISEAMP,d0
	add.l	d0,d0
	swap	d0
	ext.l	d0				; d0.l=amp*noise1d(fr*v)
	move.l	(sp)+,d1			; d1.l=v=arctan(y/x)+pi (16:16)
; d0.l=noise1d (16:16) ???
	addi.l	#$00010000,d0			; d0.l=amp*noise1d(fr*v)+1 (16:16)
	mulu.l	#$0000517C*FlareGen.NUMLINES,d2:d1
	move.w	d2,d1
	swap	d1
; d1.l=17v/pi (16:16)
	add.l	d1,d0				; d0.l=17v/pi+amp*noise1d(10v)+1
	clr.l	d1
	move.w	d0,d1
; d1.l=fmod(17v/pi+1+Noise1d[10v], 1)
	subi.l	#$00008000,d1			; d0.l=fmod(17v/pi+1+amp*noise1d[10v], 1)-.5 (16:16)
	add.l	d1,d1				; d1.l=2[fmod(17v/pi+1+amp*noise1d[10v], 1)-.5] (16:16)
	bpl.s	.done_line_abs
	neg.l	d1
.done_line_abs:
; d1.l=2|[fmod(17v/pi+1+amp*noise1d[10v], 1)-.5]| (16:16)
	move.l	d1,d3
	REPT	FlareGen.LINETHIN
	mulu.l	d3,d2:d1
	move.w	d2,d1
	swap	d1
	ENDR
; d1.l=v=|2[fmod(17v/pi+1+amp*noise1d[10v], 1)-.5]|^p (16:16)
	move.l	a2,d2				; d2.l=d (16:16)
	divu.l	#FlareGen.LINEFADESPEED,d2
; d2.l=d/5 (16:16)
	addi.l	#$00010000,d2
; d2.l=1+d/5 (16:16)
	mulu.l	#FlareGen.LINEAMP,d1
	divu.l	d2,d1
; d1.l=lineh=v/(1+d/5) (int)

	movem.l	(sp)+,d0/d6/d7
; d0.w=bumph+ringh (int)

	add.w	d1,d0
; d0.w=h=bumph+ringh+lineh

	ENDC

; if h>1 then h:=1
	cmpi.w	#255,d0
	ble.s	.clip_done
	move.w	#255,d0
.clip_done:
	move.b	d0,(a0)+
	
	addq.w	#2,d6
	cmp.w	.one_plus_r(pc),d6
	bne	.xloop

	addq.w	#2,d7
	cmp.w	.one_plus_r(pc),d7
	bne	.yloop
	rts

.radius:DC.W	0
.one_min_r:
	DC.W	0
.one_plus_r:
	DC.W	0

; Makes a byte heightfield bump..
;
; INPUT:
; d0.w=width=height
; a0: dst buffer
FlareGen.calcBump:
	move.w	d0,d5

	lea	(a0,d0.w),a1
	move.w	d0,d1
	subq.w	#1,d1
	mulu.w	d0,d1
	lea	(a0,d1.l),a2
	lea	(a2,d0.w),a3
	move.w	d0,d7
	subq.w	#1,d7

.yloop:	move.w	d5,d6
	subq.w	#1,d6

.xloop:	move.w	d6,d0
	mulu.w	d0,d0
	move.w	d7,d1
	mulu.w	d1,d1
	add.l	d0,d1
	bsr	Math.sqrt

	move.w	d5,d1
	lsl.w	#8,d1
	divu.w	d1,d0
	cmpi.w	#256,d0
	bhs.s	.oki
	not.b	d0
	bra.s	.store
.oki:	clr.b	d0
.store:	lsr.b	#1,d0
	move.b	d0,(a0)+
	move.b	d0,-(a1)
	move.b	d0,(a2)+
	move.b	d0,-(a3)
	subq.w	#2,d6
	bpl.s	.xloop

	move.w	d5,d1
	lsr.w	#1,d1
	adda.w	d1,a0
	move.w	d1,d2
	mulu.w	#3,d2
	adda.w	d2,a1
	suba.w	d2,a2
	suba.w	d1,a3
	subq.w	#2,d7
	bpl.s	.yloop

	rts

; Adds (rgb saturated) a palette-based block to the current hc buffer!
; No fucking clip (i'm lazy!).
; INPUT:
; d0.w=src width (0<w<=FlareGen.WIDTH)
; d1.w=src height (0<h<=FlareGen.HEIGHT)
; d2.w=center x in dst (0<=x<FlareGen.WIDTH)
; d3.w=center y in dst (0<=y<FlareGen.WIDTH)
; a0: dst texture
; a1: src heightfield
; a2: src hc palette
FlareGen.addBlock:
	move.w	d0,d4
	move.w	d1,d5
	lsr.w	d4
	lsr.w	d5
	sub.w	d4,d2				; d2.w=lx
	sub.w	d5,d3				; d3.w=uy
	ext.l	d2
	mulu.w	#FlareGen.WIDTH,d3
	add.l	d3,d2
	
	lea	(a0,d2.l*2),a0
	movea.w	#FlareGen.WIDTH,a6
	suba.w	d0,a6				; a6=WIDTH-w=y_inc
	adda.l	a6,a6

	subq.w	#1,d0				; d0.w=w-1
	subq.w	#1,d1				; d1.w=h-1
	move.w	d0,d7

.yloop:	move.w	d7,d0

.xloop:	move.w	(a0),d2				; d2.w=dst hc pixel
	clr.l	d3
	move.b	(a1)+,d3
	move.w	(a2,d3.l*2),d3			; d3.w=src hc pixel
	move.w	d2,d4
	andi.w	#$F800,d4
	add.w	d3,d4
	bcc.s	.red_sat_done
	move.w	#$F800,d4
.red_sat_done:
	andi.w	#$F800,d4			; d4.w=red

	move.w	d2,d5
	andi.w	#$07E0,d5
	lsl.w	#5,d5
	move.w	d3,d6
	lsl.w	#5,d6
	add.w	d6,d5
	bcc.s	.green_sat_done
	move.w	#$FFFF,d5
.green_sat_done:
	andi.w	#$FC00,d5			; d5.w=green<<5
	lsr.w	#5,d5				; d5.w=green
	or.w	d5,d4				; d4.w=red|green

	move.w	d2,d5
	andi.w	#$001F,d5
	lsl.w	#3,d5
	move.w	d3,d6
	lsl.w	#3,d6
	add.b	d6,d5
	bcc.s	.blue_sat_done
	move.w	#$00FF,d5
.blue_sat_done:
	andi.w	#$00F8,d5			; d5.w=blue<<5
	lsr.w	#3,d5				; d5.w=blue
	or.w	d5,d4				; d4.w=red|green|blue

	move.w	d4,(a0)+			; Store pixel.
	dbf	d0,.xloop

	adda.l	a6,a0
	dbf	d1,.yloop
	rts

; Turbulence algorithm based texture generator.
; Thanx to tat/avena and Mr Perlin.

; Makes some default textures.
; Just some convenience stuff.
Texture.makeDefaults:
; Generate 8b textures first..
	move.l	#$45217D72,d2
	lea	Texture.8bTexture1,a0
	bsr	Texture.make8bTexture
	move.l	#$142D1271,d2
	lea	Texture.8bTexture2,a0
	bsr	Texture.make8bTexture

; Create sky texture by rgb saturated add shit.
	lea	Texture.16bTexture2,a0
	lea	Texture.8bTexture2,a1
	lea	Texture.8bTexture1,a3
	lea	FlareGen.blue2Pal,a2
	lea	FlareGen.grPal,a4
	clr.w	d0
.conv_loop1:
	clr.l	d1
	move.b	(a1)+,d1
	move.w	(a2,d1.l*2),d3
	clr.l	d2
	move.b	(a3)+,d2
	move.w	(a4,d2.l*2),d2

	move.w	d2,d4
	andi.w	#$F800,d4
	add.w	d3,d4
	bcc.s	.red_sat_done
	move.w	#$F800,d4
.red_sat_done:
	andi.w	#$F800,d4			; d4.w=red

	move.w	d2,d5
	andi.w	#$07E0,d5
	lsl.w	#5,d5
	move.w	d3,d6
	lsl.w	#5,d6
	add.w	d6,d5
	bcc.s	.green_sat_done
	move.w	#$FFFF,d5
.green_sat_done:
	andi.w	#$FC00,d5			; d5.w=green<<5
	lsr.w	#5,d5				; d5.w=green
	or.w	d5,d4				; d4.w=red|green

	move.w	d2,d5
	andi.w	#$001F,d5
	lsl.w	#3,d5
	move.w	d3,d6
	lsl.w	#3,d6
	add.b	d6,d5
	bcc.s	.blue_sat_done
	move.w	#$00FF,d5
.blue_sat_done:
	andi.w	#$00F8,d5			; d5.w=blue<<5
	lsr.w	#3,d5				; d5.w=blue
	or.w	d5,d4				; d4.w=red|green|blue

	move.w	d4,(a0)+
	addq.w	#1,d0
	bne.s	.conv_loop1

; Create chrome texture..
	lea	Texture.16bTexture1,a0
	lea	Texture.8bTexture1,a1
	lea	FlareGen.chromePal,a2
	clr.w	d0
	clr.l	d1
.conv_loop2:
	move.b	(a1)+,d1
	move.w	(a2,d1.l*2),(a0)+
	addq.w	#1,d0
	bne.s	.conv_loop2

; Create psychedelic palette.
	lea	Texture.crapInstTable,a1
	lea	Texture.crapPal,a0
	bsr	Pal.makeGradientHc

; Generate nice blue/black/purple space texture..
	lea	Texture.spaceTexture,a0
	move.l	#"Word",(a0)+
	move.l	#"PerP",(a0)+
	move.l	#"ixel",(a0)+
	move.l	#$00400040,(a0)+
	lea	FlareGen.icePal,a1
	moveq	#6,d0
	moveq	#2,d1
	move.l	#$07013001,d2
	bsr	Texture.createWords2
	rts

; INPUT:
; d2.l=random seed
; a0: texture
Texture.make8bTexture:
; Generate nice turbulence texture 128*128..
	moveq	#7,d0
	moveq	#4,d1
	move.l	a0,-(sp)
	bsr	Texture.createBytes2
	movea.l	(sp),a0

; Tile it to 256*256..
	movea.l	a0,a1
	adda.l	#128*256,a0
	moveq	#128-1,d7

.yloop:	lea	128(a0),a2
	moveq	#128/4-1,d6

.xloop:	move.l	(a1),(a0)+
	move.l	(a1)+,(a2)+
	dbf	d6,.xloop

	movea.l	a2,a0
	dbf	d7,.yloop

	movea.l	(sp)+,a0
	movea.l	a0,a1
	adda.l	#128*256,a1
	move.w	#256*128/4-1,d7

.copy_loop:
	move.l	(a1)+,(a0)+
	dbf	d7,.copy_loop

	rts

; INPUT:
; d2.l=random seed
; a0: texture
; a1: pal
Texture.make16bTexture:
; Generate nice turbulence texture 128*128..
	moveq	#7,d0
	moveq	#4,d1
	move.l	a0,-(sp)
	bsr	Texture.createWords2
	movea.l	(sp),a0

; Tile it to 256*256..
	movea.l	a0,a1
	adda.l	#128*256*2,a0
	moveq	#128-1,d7

.yloop:	lea	128*2(a0),a2
	moveq	#128*2/4-1,d6

.xloop:	move.l	(a1),(a0)+
	move.l	(a1)+,(a2)+
	dbf	d6,.xloop

	movea.l	a2,a0
	dbf	d7,.yloop

	movea.l	(sp)+,a0
	movea.l	a0,a1
	adda.l	#128*256*2,a1
	move.w	#256*128*2/4-1,d7

.copy_loop:
	move.l	(a1)+,(a0)+
	dbf	d7,.copy_loop

	rts

	endc

; INPUT:
; d0.l=random seed
Texture.init:
	move.w	#Texture.SIZE*Texture.SIZE-1,d7
	lea	Texture.xGradGrid,a1
	lea	Texture.yGradGrid,a2
	lea	Texture.heightGrid,a0
	move.l	#$001F1F7F,d2

.loop:	move.l	d0,d1
	rol.l	d0,d0
	mulu.w	d1,d0
	eor.l	d1,d0
	addq.l	#5,d0
	and.l	d2,d1
	move.b	d1,(a0)+
	lsr.l	#8,d1
	subi.b	#$10,d1
	move.b	d1,(a1)+
	lsr.l	#8,d1
	subi.b	#$10,d1
	move.b	d1,(a2)+
	dbra	d7,.loop
	rts

; This gets the values from the grids at specified points. This involves a
; wrapped afair.
; INPUT:
; d0.w=x
; d1.w=y
; d4.w=mask
; OUTPUT:
; d0.b=xgrad
; d1.b=ygrad
; d2.b=height
Texture.getPoint:
	and.w	d4,d0				; Wrap x.
	and.w	d4,d1				; Wrap y.
	clr.l	d3
	move.w	d1,d3
	lsl.l	#Texture.SIZELOG,d3
	add.w	d0,d3
	move.b	(Texture.heightGrid,d3.l),d0
	move.b	(Texture.xGradGrid,d3.l),d1
	move.b	(Texture.yGradGrid,d3.l),d2
	rts

; Take the 4 corners' xgrad,ygrad and values.
; Interpolate [x,y] to [x+1,y], giving new value and ygrad
; Interpolate [x,y+1] to [x+1,y+1], giving same
; Use a and b to calculate final value.
;
; 1:[x,y]   2:[x+1,y]
; *----a----*
; |
; |    *[x+xfrac,y+yfrac]
; |
; *----b----*
; 3:[x,y+1] 4:[x+1,y+1]
;
; INPUT:
; d0.w=x, d1.w=y (8:8)
; OUTPUT:
; d0.w=noise (8:8)
; d4.w=mask
Texture.getNoise:
; Get frac and whole parts.
	clr.w	d2
	clr.w	d3
	move.b	d0,d2				; d2.b=xfrac
	move.b	d1,d3				; d3.b=yfrac
	lsr.w	#8,d0				; d0.b=xint
	lsr.w	#8,d1				; d1.b=yint
	move.w	d0,d6
	move.w	d1,d7
	lea	.h1(pc),a6

	movem.w	d2-d3,-(sp)

	bsr.s	Texture.getPoint
	lsl.w	#8,d0
	lsl.w	#8,d1
	lsl.w	#8,d2
	movem.w	d0-d2,(a6)			; Store h1,xg1,yg1 (8:8).
	move.w	d6,d0
	move.w	d7,d1
	addq.w	#1,d0
	bsr.s	Texture.getPoint
	lsl.w	#8,d0
	lsl.w	#8,d1
	lsl.w	#8,d2
	movem.w	d0-d2,6(a6)			; Store h2,xg2,yg2 (8:8).
	move.w	d6,d0
	move.w	d7,d1
	addq.w	#1,d1
	bsr.s	Texture.getPoint
	lsl.w	#8,d0
	lsl.w	#8,d1
	lsl.w	#8,d2
	movem.w	d0-d2,12(a6)			; Store h3,xg3,yg3 (8:8).
	move.w	d6,d0
	move.w	d7,d1
	addq.w	#1,d0
	addq.w	#1,d1
	bsr	Texture.getPoint
	lsl.w	#8,d0
	lsl.w	#8,d1
	lsl.w	#8,d2
	movem.w	d0-d2,18(a6)			; Store h4,xg4,yg4 (8:8).

	movem.w	(sp)+,d2-d3

; newvalue=Interpolate(value1, value2, xgrad1, xgrad2, xfrac)
	move.w	d2,.xfrac
	move.w	d3,.yfrac
	move.w	d2,d4
	move.w	.h1(pc),d0
	move.w	.h2(pc),d1
	move.w	.xg1(pc),d2
	move.w	.xg2(pc),d3
	IFNE	Texture.CUB_INT
	bsr	Texture.interpolate
	ELSE
	bsr	Texture.interpolateLinear
	ENDC
	move.w	d0,.upper_h
	
; newygrad=Interpolate(yg1, yg2, xg1, yg2, xfrac)
	move.w	.yg1(pc),d0
	move.w	.yg2(pc),d1
	move.w	.xg1(pc),d2
	move.w	.xg2(pc),d3
	move.w	.xfrac(pc),d4
	IFNE	Texture.CUB_INT
	bsr	Texture.interpolate
	ELSE
	bsr	Texture.interpolateLinear
	ENDC
	move.w	d0,.upper_g

; newvalue=Interpolate(h3, h4, xg3, xg4, xfrac)
	move.w	.h3(pc),d0
	move.w	.h4(pc),d1
	move.w	.xg3(pc),d2
	move.w	.xg4(pc),d3
	move.w	.xfrac(pc),d4
	IFNE	Texture.CUB_INT
	bsr	Texture.interpolate
	ELSE
	bsr	Texture.interpolateLinear
	ENDC
	move.w	d0,.lower_h
	
; newygrad=Interpolate(yg3, yg4, xg3, xg4, xfrac)
	move.w	.yg3(pc),d0
	move.w	.yg4(pc),d1
	move.w	.xg3(pc),d2
	move.w	.xg4(pc),d3
	move.w	.xfrac(pc),d4
	IFNE	Texture.CUB_INT
	bsr	Texture.interpolate
	ELSE
	bsr	Texture.interpolateLinear
	ENDC
	move.w	d0,.lower_g

; newvalue=Interpolate(upper_h,lower_h,upper_g,lower_g,yfrac)
	movem.w	.upper_h(pc),d0-d3
	move.w	.yfrac(pc),d4
	IFNE	Texture.CUB_INT
	bsr	Texture.interpolate
	ELSE
	bsr	Texture.interpolateLinear
	ENDC

; d0.w= final interpolated value..
	rts

.xfrac:	DC.W	0
.yfrac:	DC.W	0
.upper_h:
	DC.W	0
.lower_h:
	DC.W	0
.upper_g:
	DC.W	0
.lower_g:
	DC.W	0
.h1:	DC.W	0
.xg1:	DC.W	0
.yg1:	DC.W	0
.h2:	DC.W	0
.xg2:	DC.W	0
.yg2:	DC.W	0
.h3:	DC.W	0
.xg3:	DC.W	0
.yg3:	DC.W	0
.h4:	DC.W	0
.xg4:	DC.W	0
.yg4:	DC.W	0

; Cubic interpolation.
; i = (2v0+g0+g1-2v1)x^3+(3v1-2g0-g1-3v0)x^2+g0x+v0
; INPUT:
; d0.w=v0, d1.w=v1, d2.w=g0, d3.w=g1 (8:8)
; d4.w=x [0..255]
; OUTPUT:
; d0.w=i (8:8)
Texture.interpolate:
; Make long stuff.
	ext.l	d0
	ext.l	d1
	ext.l	d2
	ext.l	d3

; i1=g0x+v0
	move.l	d0,d5
	lsl.l	#8,d5
	move.w	d2,d6
	muls.w	d4,d6
	add.l	d6,d5

	move.w	d4,d7				; d7.w=x (8:8)
	muls.w	d4,d4
	asr.l	#8,d4				; d4.w=x^2 (8:8)

; i2=(-2g0-g1-3v0+3v1)x^2
	move.l	d1,d6
	add.l	d1,d6
	add.l	d1,d6
	sub.l	d3,d6
	sub.l	d2,d6
	sub.l	d2,d6
	sub.l	d0,d6
	sub.l	d0,d6
	sub.l	d0,d6
	muls.l	d4,d6
	add.l	d6,d5

	muls.w	d7,d4
	asr.l	#8,d4				; d4.w=x^3 (8:8)

; i3=(-2v1+2v0+g0+g1)x^3
	move.l	d0,d6
	add.l	d0,d6
	sub.l	d1,d6
	sub.l	d1,d6
	add.l	d2,d6
	add.l	d3,d6
	muls.l	d4,d6
	add.l	d6,d5				; d5.w=i=i1+i2+i3

	move.l	d5,d0
	asr.l	#8,d0
	rts

; Linear interpolation. Looks like garbage.
; i = v0(1-x)+v1x
; INPUT:
; d0.w=v0, d1.w=v1 (8:8)
; d4.w=x [0..255]
; OUTPUT:
; d0.w=i
Texture.interpolateLinear:
; Make long stuff.
	move.w	#$0100,d3
	sub.w	d4,d3
	muls.w	d3,d0
	muls.w	d4,d1
	add.l	d1,d0
	asr.l	#8,d0
	rts

	ifne	0

; Generate a byte per pixel texture with specified dimensions.
; INPUT:
; d0.w=l=2log of dimension (x=y=2^l)
; d1.w=o=#octaves of noise
; d2.l=random seed
; a0: texturebuffer (w*h bytes big!)
Texture.createBytes:
	move.w	d1,.octaves

; Initialize grid..
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	move.l	d2,d0
	bsr	Texture.init
	move.l	(sp)+,a0
	move.w	(sp)+,d2

; Calc x,y..
	moveq	#1,d0
	lsl.l	d2,d0
	subq.w	#1,d0
	move.w	d0,d1

; Calc scale..
	moveq	#9,d3
	sub.w	d2,d3				; d3.w=9-l
	move.w	d3,.scale			; Store scale.

	move.w	d0,d7

.yloop:	move.w	d7,-(sp)

; Create a turbulent pixel.
.xloop:	move.l	a0,-(sp)
	movem.w	d0/d1,-(sp)

	clr.w	d7
	suba.l	a5,a5

.scale_loop:
	movem.w	(sp),d0/d1
	move.w	d7,-(sp)
	move.w	.scale(pc),d2
	add.w	d7,d2
	lsl.w	d2,d0
	lsl.w	d2,d1
	move.l	#$FFFF0001,d4
	rol.l	d7,d4
	bsr	Texture.getNoise
	move.w	(sp)+,d7
	asr.w	d7,d0
	bpl.s	.pos
	neg.w	d0
.pos:	adda.w	d0,a5
	addq.w	#1,d7
	cmp.w	.octaves(pc),d7
	blt.s	.scale_loop

	movem.w	(sp)+,d0/d1
	move.l	(sp)+,a0
	move.l	a5,d2
	lsr.l	#8,d2
	move.b	d2,(a0)+			; Output pixel.
	dbf	d0,.xloop
	
	move.w	(sp)+,d7
	move.w	d7,d0
	dbf	d1,.yloop

.end:	rts

.scale:	DC.W	0
.octaves:
	DC.W	0

	endc

	ifne	0

; Uses the bytes version to create texture and makes it highcolor.
; INPUT:
; d0.w=l=2log of dimension (x=y=2^l)
; d1.w=o=#octaves of noise
; d2.l=random seed
; a0: texturebuffer (w*h*2 bytes big!)
; a1: palette (256 hc words)
Texture.createWords2:
; Create texture..
	move.w	d0,-(sp)
	movem.l	a0/a1,-(sp)
	bsr.s	Texture.createBytes2
	movem.l	(sp)+,a0/a1
	move.w	(sp)+,d0

; Convert..
	moveq	#1,d1
	add.l	d0,d0
	lsl.l	d0,d1
; d1.l=#texels
	lea	(a0,d1.l*2),a2			; a2: end of words (dst)
	add.l	d1,a0				; a0: end of bytes (src)

	subq.w	#1,d1
	clr.l	d0
.loop:	move.b	-(a0),d0
	move.w	(a1,d0.l*2),-(a2)
	dbf	d1,.loop
	rts

	endc

; Faster version, can be even faster though..
; Generate a byte per pixel texture with specified dimensions.
; INPUT:
; d0.w=l=2log of dimension (x=y=2^l)
; d1.w=o=#octaves of noise
; d2.l=random seed
; a0: texturebuffer (w*h bytes big!)
Texture.createBytes2:
	move.w	d0,.lw
	move.w	d1,.octave
	move.l	a0,.texture

; Initialize grid..
	move.w	d0,-(sp)
	move.l	d2,d0
	bsr	Texture.init
	move.w	(sp)+,d2

; Calc w,h..
	moveq	#1,d0
	lsl.l	d2,d0
	subq.w	#1,d0
	move.w	d0,d1				; d0.w=d1.w=x=y
	move.w	d0,.width

; Calc scale..
	moveq	#9,d3
	sub.w	d2,d3				; d3.w=9-l
	move.w	d3,.scale			; Store scale.

.octave_loop:
	lea	Texture.horGrid,a0

	move.w	.octave(pc),d0
	move.l	#$FFFF0001,d4
	rol.l	d0,d4				; d4.w=mask

; Step 1: Interpolate to (v, yg) grid.
	move.w	.width(pc),d7
	move.w	.scale(pc),d2
	add.w	.octave(pc),d2
	lsl.w	d2,d7
	lsr.w	#8,d7

.yloop1:move.w	.width(pc),d6

.xloop1:
; Fetch (v, xg, yg) at x+1.
	move.w	d6,d0
	move.w	d7,d1
	move.w	.scale(pc),d2
	add.w	.octave(pc),d2
	lsl.w	d2,d0
	lsr.w	#8,d0
	bsr	Texture.getPoint
	lsl.w	#8,d0
	lsl.w	#8,d1
	lsl.w	#8,d2
	movem.w	d0-d2,.p1			; Store v1,xg1,yg1 (8:8).

; Fetch (v, xg, yg) at x+1.
	move.w	d6,d0
	move.w	d7,d1
	move.w	.scale(pc),d2
	add.w	.octave(pc),d2
	lsl.w	d2,d0
	lsr.w	#8,d0
	addq.w	#1,d0
	bsr	Texture.getPoint
	lsl.w	#8,d0
	lsl.w	#8,d1
	lsl.w	#8,d2
	movem.w	d0-d2,.p2			; Store v2,xg2,yg2 (8:8).

	movem.w	d4/d6/d7,-(sp)

; Calculate xfrac.
	move.w	.scale(pc),d2
	add.w	.octave(pc),d2
	move.w	d6,d4
	lsl.w	d2,d4
	andi.w	#$00FF,d4			; d4.b=xfrac

; Interpolate value along horizontal.
	movem.w	.p1(pc),d0/d2
	movem.w	.p2(pc),d1/d3
	bsr	Texture.interpolate
	move.w	d0,(a0)+			; Store interpolated value.

; Interpolate y_gradient along horizontal.
	move.w	.p1+4(pc),d0
	move.w	.p2+4(pc),d1
	move.w	.p1+2(pc),d2
	move.w	.p2+2(pc),d3
	bsr	Texture.interpolate
	move.w	d0,(a0)+			; Store interpolated y_gradient.

	movem.w	(sp)+,d4/d6/d7

	dbf	d6,.xloop1

	dbf	d7,.yloop1

; Step 2: Interpolate the (v, yg) grid to an additive octave
	movea.l	.texture(pc),a0
	lea	Texture.horGrid,a1
	move.w	.width(pc),d7

.yloop2:move.w	.width(pc),d6
	move.w	d7,d1
	move.w	.scale(pc),d2
	add.w	.octave(pc),d2
	lsl.w	d2,d1
	lsr.w	#8,d1
	move.w	d1,d2
	addq.w	#1,d2
	and.w	d4,d2
	move.w	.lw(pc),d3
	lsl.w	d3,d1
	lsl.w	d3,d2
	lea	(a1,d1.w*4),a2			; a2: upper horizontal
	lea	(a1,d2.w*4),a3			; a3: lower horizontal

; Calculate yfrac.
	move.w	.scale(pc),d2
	add.w	.octave(pc),d2
	move.w	d7,d5
	lsl.w	d2,d5
	andi.w	#$00FF,d5			; d5.b=yfrac
	move.l	d5,a4				; a4=yfrac
	move.w	d4,-(sp)

; Interpolate an inbetween horizontal.
.xloop2:movem.w	d6/d7,-(sp)
	move.l	a4,d4

	move.w	(a2)+,d0
	move.w	(a3)+,d1
	move.w	(a2)+,d2
	move.w	(a3)+,d3
	bsr	Texture.interpolate

	move.w	.octave(pc),d1
	subq.w	#1,d1
	asr.w	d1,d0
;	bpl.s	.pos
;	neg.w	d0
.pos:	lsr.w	#8,d0
	bcc.s	.rounded
	addq.w	#1,d0
.rounded:
	add.b	d0,(a0)+

	movem.w	(sp)+,d6/d7
	dbf	d6,.xloop2

	move.w	(sp)+,d4
	dbf	d7,.yloop2

	subq.w	#1,.octave
	bgt	.octave_loop

	ifne	0

; marble cracks stuff..
	move.w	.lw(pc),d0
	moveq	#1,d7
	lsl.w	d0,d7
	lsl.w	d0,d7
	subq.w	#1,d7
.mloop:	move.b	-(a0),d0
	bpl.s	.posi
	neg.b	d0
.posi:	move.b	d0,(a0)
	dbf	d7,.mloop

	endc

.end:	rts

.scale:	DC.W	0
.octave:DC.W	0
.width:	DC.W	0
.lw:	DC.W	0

.p1:	DC.W	0,0,0
.p2:	DC.W	0,0,0

.texture:
	DC.L	0

;======== data

	DATA

	ifne	0

FlareGen.greenInstTable:
	DC.W	(.end-.start)/4-1
	DC.W	6
.start:	DC.L	$00000000
	DC.L	$007F0000
	DC.L	$00FF0000
	DC.L	$7FFF007F
	DC.L	$FFFF00FF
.end:

FlareGen.copperInstTable:
	DC.W	(.end-.start)/4-1
	DC.W	6
.start:	DC.L	$00000000
	DC.L	$7F000000
	DC.L	$FF7F0000
	DC.L	$FFFF007F
	DC.L	$FFFF00FF
.end:

FlareGen.goldInstTable:
	DC.W	(.end-.start)/4-1
	DC.W	5
.start:	DC.L	$00000000
	DC.L	$5F1F0000
	DC.L	$9F5F0000
	DC.L	$CF9F0000
	DC.L	$FFFF0000
	DC.L	$FFFF00FF
	DC.L	$FFFF00FF
	DC.L	$FFFF00FF
	DC.L	$FFFF00FF
.end:

FlareGen.iceInstTable:
	DC.W	(.end-.start)/4-1
	DC.W	5
	IFNE	1
.start:	DC.L	$7F00007F
	DC.L	$FF0000FF
	DC.L	$7F0000BF
	DC.L	$0000007F
	DC.L	$0000003F
	DC.L	$00000000
	DC.L	$00000000
	DC.L	$00000000
	DC.L	$00000000
.end:
	ELSE
.start:	DC.L	$0000001F
	DC.L	$0000007F
	DC.L	$3F0000BF
	DC.L	$7F0000FF
	DC.L	$BF0000FF
	DC.L	$FF3f00FF
	DC.L	$FF7f00FF
	DC.L	$FFff00FF
	DC.L	$FFFF00FF
.end:
	ENDC

FlareGen.chromeInstTable:
	DC.W	(.end-.start)/4-1
	DC.W	5
.start:	DC.L	$0F000000
	DC.L	$4F2F002F
	DC.L	$847F007F
	DC.L	$C4BF00BF
	DC.L	$FFFF00FF
	DC.L	$FFFF00FF
	DC.L	$FFFF00FF
	DC.L	$FFFF00FF
	DC.L	$FFFF00FF
.end:

FlareGen.blueInstTable:
	DC.W	(.end-.start)/4-1
	DC.W	5
.start:	DC.L	$0000001F
	DC.L	$1f1f00dF
	DC.L	$7f7f00ff
	DC.L	$afaf00ff
	DC.L	$fFfF00fF
	DC.L	$FFFF00FF
	DC.L	$FFFF00FF
	DC.L	$FFFF00FF
	DC.L	$FFFF00FF
.end:

FlareGen.blue2InstTable:
	DC.W	(.end-.start)/4-1
	DC.W	6
.start:	DC.L	$0000005F
	DC.L	$0000007F
	DC.L	$0000009f
	DC.L	$000000df
	DC.L	$000000fF
.end:

FlareGen.fogInstTable:
	DC.W	(.end-.start)/4-1
	DC.W	5
.start:	DC.L	$0018000f
	DC.L	$3840003c
	DC.L	$7f880084
	DC.L	$bfc800c4
	DC.L	$fFfF00fF
	DC.L	$FFFF00FF
	DC.L	$FFFF00FF
	DC.L	$FFFF00FF
	DC.L	$FFFF00FF
.end:

; todo: log 4 steps..
FlareGen.grayInstTable:
	DC.W	(.end-.start)/4-1
	DC.W	5
.start:	DC.L	$00000000
	DC.L	$3f44003f
	DC.L	$887f007f
	DC.L	$bfb800bf
	DC.L	$fFf800f8
	DC.L	$FFFF00FF
	DC.L	$FFFF00FF
	DC.L	$FFFF00FF
	DC.L	$FFFF00FF
.end:

FlareGen.grInstTable:
	DC.W	(.end-.start)/4-1
	DC.W	6
.start:	DC.L	$00000000
	DC.L	$3f3f003f
	DC.L	$7f7f007f
	DC.L	$dfdf00df
	DC.L	$fFfF00fF
.end:

Texture.crapInstTable:
	DC.W	(.end-.start)/4-1
	DC.W	5
.start:	DC.L	$00000000
	DC.L	$00ff0000
	DC.L	$dfff0000
	DC.L	$ffff007f
	DC.L	$ffff00ff
	DC.L	$ff7f00ff
	DC.L	$ff0000ff
	DC.L	$ff0000ff
	DC.L	$fF000000
.end:

Texture.sandInstTable:
	DC.W	(.end-.start)/4-1
	DC.W	5
.start:	DC.L	$3f1f001f
	DC.L	$3f3f001f
	DC.L	$8f7f001f
	DC.L	$dfdf003f
	DC.L	$ffff007f
.end:

Texture.redInstTable:
	DC.W	(.end-.start)/4-1
	IFNE	1
	DC.W	6
.start:	DC.L	$102f003f
	DC.L	$204f005f
	DC.L	$306f007f
	DC.L	$408f009f
	DC.L	$50Af00Bf
.end:
	ELSE
	DC.W	6
.start:	DC.L	$5f000000
	DC.L	$9f1f0000
	DC.L	$df3f0000
	DC.L	$ff5f0000
	DC.L	$fF7F0000
.end:
	ENDC

	endc

;======== reserves

	BSS

FlareGen.greenPal:
	DS.W	256
FlareGen.copperPal:
	DS.W	256
FlareGen.goldPal:
	DS.W	256
FlareGen.icePal:
	DS.W	256
FlareGen.chromePal:
	DS.W	256
FlareGen.bluePal:
	DS.W	256
FlareGen.blue2Pal:
	DS.W	256
FlareGen.fogPal:
	DS.W	256
FlareGen.grayPal:
	DS.W	256
FlareGen.grPal:
	DS.W	256
Texture.crapPal:
	DS.W	256
Texture.sandPal:
	DS.W	128
Texture.redPal:
	DS.W	256
FlareGen.flare1:
	DS.B	FlareGen.W1*FlareGen.W1
FlareGen.flare2:
	DS.B	FlareGen.W2*FlareGen.W2
FlareGen.flare3:
	DS.B	FlareGen.W3*FlareGen.W3

FlareGen.goldBuffer:
	DS.W	FlareGen.WIDTH*FlareGen.WIDTH+10
FlareGen.chromeBuffer:
	DS.W	FlareGen.WIDTH*FlareGen.WIDTH+10
FlareGen.chromeFogBuffer:
	DS.W	FlareGen.WIDTH*FlareGen.WIDTH+10
FlareGen.redBuffer:
	DS.W	FlareGen.WIDTH*FlareGen.WIDTH+10
FlareGen.parelMoerBuffer:
	DS.W	FlareGen.WIDTH*FlareGen.WIDTH+10

Texture.xGradGrid:
	DS.B	Texture.SIZE*Texture.SIZE
Texture.yGradGrid:
	DS.B	Texture.SIZE*Texture.SIZE
Texture.heightGrid:
	DS.B	Texture.SIZE*Texture.SIZE

Texture.horGrid:
	DS.L	Texture.SIZE*Texture.SIZE			; val, ygrad

Texture.8bTexture1:
	DS.B	256*256
Texture.8bTexture2:
	DS.B	256*256
Texture.16bTexture1:
	DS.W	256*256
Texture.16bTexture2:
	DS.W	256*256
Texture.spaceTexture:
	DS.W	10+64*64
