;
; Sprite routines written by T.A.King.
;
; If SMALL_VERSION is ON then the output will be 2510 bytes long and
; only contain the first four functions. If it is OFF the output will
; be 6198 bytes long.
;
; The 32x sprites use a unique format, if you use these routines I
; will know, so credit me !
;

ON		equ 1
OFF		equ 0
SMALL_VERSION	equ ON

	bra	print_sprite
	bra	print_sprites
	bra	erase_sprites
	bra	clip_sprites
	IFEQ SMALL_VERSION
	bra	print_mask
	bra	print_invmask
	bra	fast_sprite
	bra	fast_mask
	bra	fast_invmask
	bra	store_sprite
	bra	sprite_width
	ELSEIF
	bra	sprite_width
	ENDC	
	
;
; ~C:clip_sprites%(xmin,ymin,xmax,ymax)
;
clip_sprites
	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d0		; xmin
	move	62(a7),d1		; ymin
	move	64(a7),d2		; xmax
	move	66(a7),d3		; ymax
	addq	#1,d2
	addq	#1,d3
	and	#$fff0,d0		; align to nearest 16 pixels
	and	#$fff0,d2
	lea	clipping(pc),a0
	move	d1,(a0)+
	move	d3,(a0)+
	move	d0,(a0)+
	move	d2,(a0)
	movem.l	(a7)+,d1-7/a0-6
	rts	

;
; Print sprite.
;
; ~C:sprites%(sprite,x,y,width,height,L:graphics,L:screen)

	IFEQ SMALL_VERSION
print_invmask
	cmp	#32,10(a7)
	beq	invmask32
invmask16
	movem.l	d0-7/a0-6,-(a7)
	lea	ret16im(pc),a6
	bra.s	samec1
print_mask
	cmp	#32,10(a7)
	beq	mask32
mask16	movem.l	d0-7/a0-6,-(a7)
	lea	ret16m(pc),a6
	bra.s	samec1
	ENDC
		
print_sprite
	cmp	#32,10(a7)
	beq	sprite_32

sprite_16
	movem.l	d0-7/a0-6,-(a7)
	lea	ret16s(pc),a6
samec1	move	64(a7),d2		; sprite
	move	66(a7),d0		; x
	move	68(a7),d1		; y
	move	72(a7),d3		; height	
	move.l	74(a7),a0		; graphics
	move.l	78(a7),a1		; screen
	move	d3,d4
	move	d3,d5
	add	d4,d4
	lsl	#3,d5
	add	d4,d5
	mulu	d5,d2
	add.l	d2,a0			; graphic start
	bsr.s	draw_16
	movem.l	(a7)+,d0-7/a0-6
	rts

draw_16	lea	clipping(pc),a4
	move	d3,d7
	subq	#1,d7
	subq	#8,d0
	moveq	#0,d6			; d6 clip flag 
	move	(a4),d4
	cmp	d4,d1
	bge.s	amaxy
	move	d4,d5
	sub	d3,d5
	cmp	d5,d1
	ble.s	off_screen16
	sub	d4,d1
	add	d1,d7
	neg	d1
	add	d1,d1			; *2
	move	d1,d2
	add	d2,d2
	add	d2,d2			; *8
	add	d2,d1	
	add	d1,a0			; *10
	move	d4,d1			
	bra.s	aminx
amaxy	move	2(a4),d4
	cmp	d4,d1
	bge.s	off_screen16
	sub	d3,d4
	cmp	d4,d1
	ble.s	aminx
	sub	d1,d4
	add	d4,d7
aminx	move	4(a4),d4
	cmp	d4,d0
	bge.s	amaxx
	sub	#16,d4
	cmp	d4,d0
	ble.s	off_screen16
	moveq	#1,d6
	add	scr_width+2(pc),d0
	sub	scr_width(pc),a1
	bra.s	nclp16
off_screen16
	rts
amaxx	move	6(a4),d4
	cmp	d4,d0
	bge.s	off_screen16
	sub	#16,d4
	cmp	d4,d0
	ble.s	nclp16
	moveq	#2,d6
nclp16	move	d0,d2
	mulu	scr_width(pc),d1
	lsr	#1,d0
	and	#$fff8,d0
	add	d0,a1
	add.l	d1,a1
	jmp	(a6)
ret16s	and	#15,d2
	cmp	#7,d2			; compare x offset 0-15
	ble.s	ror16s			; xoff <= 7, use ror
	bra	rol16s			; xoff  > 7, use rol
	
	IFEQ SMALL_VERSION
ret16m	and	#15,d2
	cmp	#7,d2
	ble	ror16m
	bra	ror16m
ret16im	and	#15,d2
	cmp	#7,d2
	ble	ror16im
	bra	ror16im
	ENDC
	
ror16s	cmp	#1,d6
	blt.s	aror16s
	beq.s	bror16s
	bra	cror16s
aror16s	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	ror.l	d2,d0
	not.l	d0
	move	d0,d4
	swap	d0
	move	d0,d5
	REPT 4
		moveq	#0,d0
		move	(a0)+,d0
		ror.l	d2,d0
		and	d4,(a2)
		or	d0,(a2)+
		swap	d0
		and	d5,(a3)
		or	d0,(a3)+
	ENDR
	add	scr_width(pc),a1
	dbf	d7,aror16s
	rts
bror16s	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	ror.l	d2,d0
	not.l	d0
	swap	d0
	move	d0,d5
	REPT 4
		moveq	#0,d0
		move	(a0)+,d0
		ror.l	d2,d0
		swap	d0
		and	d5,(a3)
		or	d0,(a3)+
	ENDR
	add	scr_width(pc),a1
	dbf	d7,bror16s
	rts
cror16s	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	ror.l	d2,d0
	not.l	d0
	move	d0,d4
	REPT 4
		moveq	#0,d0
		move	(a0)+,d0
		ror.l	d2,d0
		and	d4,(a2)
		or	d0,(a2)+
	ENDR
	add	scr_width(pc),a1
	dbf	d7,cror16s
	rts

rol16s	moveq	#16,d3
	sub	d2,d3
	move	d3,d2
	cmp	#1,d6
	blt.s	arol16s
	beq.s	brol16s
	bra	crol16s
arol16s	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	rol.l	d2,d0
	not.l	d0
	move	d0,d4
	swap	d0
	move	d0,d5
	REPT 4
		moveq	#0,d0
		move	(a0)+,d0
		rol.l	d2,d0
		and	d4,(a3)
		or	d0,(a3)+
		swap	d0
		and	d5,(a2)
		or	d0,(a2)+
	ENDR
	add	scr_width(pc),a1
	dbf	d7,arol16s
	rts
brol16s	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	rol.l	d2,d0
	not.l	d0
	move	d0,d4
	REPT 4
		moveq	#0,d0
		move	(a0)+,d0
		rol.l	d2,d0
		and	d4,(a3)
		or	d0,(a3)+
	ENDR
	add	scr_width(pc),a1
	dbf	d7,brol16s
	rts
crol16s	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	rol.l	d2,d0
	not.l	d0
	swap	d0
	move	d0,d5
	REPT 4
		moveq	#0,d0
		move	(a0)+,d0
		rol.l	d2,d0
		swap	d0
		and	d5,(a2)
		or	d0,(a2)+
	ENDR
	add	scr_width(pc),a1
	dbf	d7,crol16s
	rts

	IFEQ SMALL_VERSION
ror16m	cmp	#1,d6
	blt.s	aror16m
	beq.s	bror16m
	bra.s	cror16m
aror16m	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	ror.l	d2,d0
	or	d0,(a2)+
	or	d0,(a2)+
	or	d0,(a2)+
	or	d0,(a2)
	swap	d0
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)
	addq	#8,a0
	add	scr_width(pc),a1
	dbf	d7,aror16m
	rts
bror16m	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	ror.l	d2,d0
	swap	d0
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)
	addq	#8,a0
	add	scr_width(pc),a1
	dbf	d7,bror16m
	rts
cror16m	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	ror.l	d2,d0
	or	d0,(a2)+
	or	d0,(a2)+
	or	d0,(a2)+
	or	d0,(a2)
	addq	#8,a0
	add	scr_width(pc),a1
	dbf	d7,cror16m
	rts

rol16m	moveq	#16,d3
	sub	d2,d3
	move	d3,d2
	cmp	#1,d6
	blt.s	arol16m
	beq.s	brol16m
	bra.s	crol16m
arol16m	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	rol.l	d2,d0
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)
	swap	d0
	or	d0,(a2)+
	or	d0,(a2)+
	or	d0,(a2)+
	or	d0,(a2)
	addq	#8,a0
	add	scr_width(pc),a1
	dbf	d7,arol16m
	rts
brol16m	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	rol.l	d2,d0
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)
	addq	#8,a0
	add	scr_width(pc),a1
	dbf	d7,brol16m
	rts
crol16m	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	rol.l	d2,d0
	swap	d0
	or	d0,(a2)+
	or	d0,(a2)+
	or	d0,(a2)+
	or	d0,(a2)
	addq	#8,a0
	add	scr_width(pc),a1
	dbf	d7,crol16m
	rts

ror16im	cmp	#1,d6
	blt.s	aror16im
	beq.s	bror16im
	bra.s	cror16im
aror16im
	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	ror.l	d2,d0
	not.l	d0
	and	d0,(a2)+
	and	d0,(a2)+
	and	d0,(a2)+
	and	d0,(a2)
	swap	d0
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)
	addq	#8,a0
	add	scr_width(pc),a1
	dbf	d7,aror16im
	rts
bror16im
	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	ror.l	d2,d0
	swap	d0
	not	d0
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)
	addq	#8,a0
	add	scr_width(pc),a1
	dbf	d7,bror16im
	rts
cror16im
	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	ror.l	d2,d0
	not	d0
	and	d0,(a2)+
	and	d0,(a2)+
	and	d0,(a2)+
	and	d0,(a2)
	addq	#8,a0
	add	scr_width(pc),a1
	dbf	d7,cror16im
	rts

rol16im	moveq	#16,d3
	sub	d2,d3
	move	d3,d2
	cmp	#1,d6
	blt.s	arol16im
	beq.s	brol16im
	bra.s	crol16im
arol16im
	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	rol.l	d2,d0
	not.l	d0
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)
	swap	d0
	and	d0,(a2)+
	and	d0,(a2)+
	and	d0,(a2)+
	and	d0,(a2)
	addq	#8,a0
	add	scr_width(pc),a1
	dbf	d7,arol16im
	rts
brol16im
	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	rol.l	d2,d0
	not	d0
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)
	addq	#8,a0
	add	scr_width(pc),a1
	dbf	d7,brol16im
	rts
crol16im
	lea	(a1),a2
	lea	8(a1),a3
	moveq	#0,d0
	move	(a0)+,d0
	rol.l	d2,d0
	swap	d0
	not	d0
	and	d0,(a2)+
	and	d0,(a2)+
	and	d0,(a2)+
	and	d0,(a2)
	addq	#8,a0
	add	scr_width(pc),a1
	dbf	d7,crol16im
	rts

invmask32
	movem.l	d0-7/a0-6,-(a7)
	lea	ret32im(pc),a6
	bra.s	samec2

mask32	movem.l	d0-7/a0-6,-(a7)
	lea	ret32m(pc),a6
	bra.s	samec2
	ENDC
		
sprite_32
	movem.l	d0-7/a0-6,-(a7)
	lea	ret32s(pc),a6
samec2	move	64(a7),d2	
	move	66(a7),d0	
	move	68(a7),d1	
	move	72(a7),d3	
	move.l	74(a7),a0	
	move.l	78(a7),a1	
	move	d3,d4
	move	d3,d5
	add	d4,d4
	lsl	#3,d5
	add	d4,d5
	add	d5,d5
	mulu	d5,d2
	add.l	d2,a0
	bsr.s	draw_32
	movem.l	(a7)+,d0-7/a0-6
	rts

draw_32	lea	clipping(pc),a4
	move	d3,d7
	subq	#1,d7
	sub	#16,d0
	moveq	#0,d6

	move	(a4),d4
	cmp	d4,d1
	bge.s	bmaxy
	move	d4,d5
	sub	d3,d5
	cmp	d5,d1
	ble.s	off_screen32
	sub	d4,d1
	add	d1,d7
	neg	d1
	add	d1,d1
	add	d1,d1			; *4
	move	d1,d2
	add	d2,d2
	add	d2,d2			; *16
	add	d2,d1	
	add	d1,a0			; *20
	move	d4,d1			
	bra.s	bminx
bmaxy	move	2(a4),d4
	cmp	d4,d1
	bge.s	off_screen32
	sub	d3,d4
	cmp	d4,d1
	ble.s	bminx
	sub	d1,d4
	add	d4,d7
bminx	move	4(a4),d4
	cmp	d4,d0
	bge.s	bmaxx
	sub	#32,d4
	cmp	d4,d0
	ble.s	off_screen32
	move	d0,d5
	add	scr_width+2(pc),d0
	sub	scr_width(pc),a1
	moveq	#1,d6
	add	#16,d4
	cmp	d4,d5
	bge.s	nclp32
	moveq	#2,d6
	bra.s	nclp32
off_screen32
	rts
bmaxx	move	6(a4),d4
	cmp	d4,d0
	bge.s	off_screen32
	sub	#32,d4
	cmp	d4,d0
	ble.s	nclp32
	moveq	#3,d6
	add	#16,d4
	cmp	d4,d0
	blt.s	nclp32
	moveq	#4,d6
nclp32	move	d0,d2
	mulu	scr_width(pc),d1
	lsr	#1,d0
	and	#$fff8,d0
	add	d0,a1
	add.l	d1,a1
	jmp	(a6)
ret32s	and	#15,d2
	cmp	#7,d2			; compare x offset 0-15
	ble	rol32s			; xoff <= 7, use rol
	bra.s	ror32s			; xoff  > 7, use ror
	IFEQ SMALL_VERSION
ret32m	and	#15,d2
	cmp	#7,d2
	ble	rol32m
	bra	ror32m	
ret32im	and	#15,d2
	cmp	#7,d2
	ble	rol32im
	bra	ror32im	
	ENDC
; Mask values for ror
tabler	DC.W	$FF00,$00FF,$FF80,$007F,$FFC0,$003F,$FFE0,$001F
	DC.W	$FFF0,$000F,$FFF8,$0007,$FFFC,$0003,$FFFE,$0001
	
ror32s	subq	#8,d2
	move	d2,d3
	add	d3,d3
	add	d3,d3
	movem	tabler(pc,d3),d4/d5	; get masks
	cmp	#1,d6
	blt.s	aror32s			; no clipping
	beq	bror32s			; left clip 1 word
	cmp	#3,d6			
	blt	cror32s			; left clip 2 words
 	beq	dror32s			; right clip 1 word
	bra	eror32s			; right clip 2 words
aror32s	lea	(a1),a2
	lea	8(a1),a3
	lea	16(a1),a4
	move.l	(a0)+,d0
	ror.l	d2,d0
	move	d0,d1
	and	d4,d0
	and	d5,d1
	not.l	d0
	not	d1
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)
	swap	d0
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)
	subq	#6,a2
	subq	#6,a3
	subq	#6,a4
	REPT 4
		move.l	(a0)+,d0
		ror.l	d2,d0
		move	d0,d1
		and	d4,d0
		and	d5,d1
		or	d0,(a4)+
		swap	d0
		or	d0,(a3)+
		or	d1,(a2)+
	ENDR
	add	scr_width(pc),a1
	dbf	d7,aror32s
	rts
bror32s	lea	8(a1),a3
	lea	16(a1),a4
	move.l	(a0)+,d0
	ror.l	d2,d0
	move	d0,d1
	and	d4,d0
	and	d5,d1
	not.l	d0
	not	d1
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)
	swap	d0
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)
	subq	#6,a3
	subq	#6,a4
	REPT 4
		move.l	(a0)+,d0
		ror.l	d2,d0
		move	d0,d1
		and	d4,d0
		and	d5,d1
		or	d0,(a4)+
		swap	d0
		or	d0,(a3)+
	ENDR
	add	scr_width(pc),a1
	dbf	d7,bror32s
	rts
cror32s	lea	16(a1),a4
	move.l	(a0)+,d0
	ror.l	d2,d0
	and	d4,d0
	not	d0
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)
	subq	#6,a4
	REPT 4
		move.l	(a0)+,d0
		ror.l	d2,d0
		and	d4,d0
		or	d0,(a4)+
	ENDR
	add	scr_width(pc),a1
	dbf	d7,cror32s
	rts
dror32s	lea	(a1),a2
	lea	8(a1),a3
	move.l	(a0)+,d0
	ror.l	d2,d0
	move	d0,d1
	and	d4,d0
	and	d5,d1
	not.l	d0
	not	d1
	swap	d0
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)
	subq	#6,a2
	subq	#6,a3
	REPT 4
		move.l	(a0)+,d0
		ror.l	d2,d0
		move	d0,d1
		and	d4,d0
		and	d5,d1
		swap	d0
		or	d0,(a3)+
		or	d1,(a2)+
	ENDR
	add	scr_width(pc),a1
	dbf	d7,dror32s
	rts
eror32s	lea	(a1),a2
	move.l	(a0)+,d0
	ror.l	d2,d0
	move	d0,d1
	and	d5,d1
	not	d1
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)
	subq	#6,a2
	REPT 4
		move.l	(a0)+,d0
		ror.l	d2,d0
		move	d0,d1
		and	d5,d1
		or	d1,(a2)+
	ENDR
	add	scr_width(pc),a1
	dbf	d7,eror32s
	rts

; Mask values for rol
tablel	DC.W	$0000,$FFFF,$8000,$7FFF,$C000,$3FFF,$E000,$1FFF
	DC.W	$F000,$0FFF,$F800,$07FF,$FC00,$03FF,$FE00,$01FF

rol32s	move	d2,d3
	add	d3,d3
	add	d3,d3
	movem	tablel(pc,d3),d4/d5
	moveq	#8,d3
	sub	d2,d3
	move	d3,d2
	cmp	#1,d6
	blt.s	arol32s
	beq	brol32s
	cmp	#3,d6
	blt	crol32s
	beq	drol32s
	bra	erol32s
	
arol32s	lea	(a1),a2
	lea	8(a1),a3
	lea	16(a1),a4
	move.l	(a0)+,d0
	rol.l	d2,d0
	move	d0,d1
	and	d4,d0
	and	d5,d1
	not.l	d0
	not	d1
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)
	swap	d0
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)
	subq	#6,a2
	subq	#6,a3
	subq	#6,a4
	REPT 4
		move.l	(a0)+,d0
		rol.l	d2,d0
		move	d0,d1
		and	d4,d0
		and	d5,d1
		or	d0,(a4)+
		swap	d0
		or	d0,(a3)+
		or	d1,(a2)+
	ENDR
	add	scr_width(pc),a1
	dbf	d7,arol32s
	rts
brol32s	lea	8(a1),a3
	lea	16(a1),a4
	move.l	(a0)+,d0
	rol.l	d2,d0
	and	d4,d0
	not.l	d0
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)
	swap	d0
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)
	subq	#6,a3
	subq	#6,a4
	REPT 4
		move.l	(a0)+,d0
		rol.l	d2,d0
		and	d4,d0
		or	d0,(a4)+
		swap	d0
		or	d0,(a3)+
	ENDR
	add	scr_width(pc),a1
	dbf	d7,brol32s
	rts
crol32s	lea	16(a1),a4
	move.l	(a0)+,d0
	rol.l	d2,d0
	and	d4,d0
	not	d0
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)
	subq #6,a4
	REPT 4
		move.l	(a0)+,d0
		rol.l	d2,d0
		and	d4,d0
		or	d0,(a4)+
	ENDR
	add	scr_width(pc),a1
	dbf	d7,crol32s
	rts
drol32s	lea	(a1),a2
	lea	8(a1),a3
	move.l	(a0)+,d0
	rol.l	d2,d0
	move	d0,d1
	and	d4,d0
	and	d5,d1
	not.l	d0
	not	d1
	swap	d0
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)
	subq	#6,a2
	subq	#6,a3
	REPT 4
		move.l	(a0)+,d0
		rol.l	d2,d0
		move	d0,d1
		and	d4,d0
		and	d5,d1
		swap	d0
		or	d0,(a3)+
		or	d1,(a2)+
	ENDR
	add	scr_width(pc),a1
	dbf	d7,drol32s
	rts
erol32s	lea	(a1),a2
	move.l	(a0)+,d0
	rol.l	d2,d0
	move	d0,d1
	and	d5,d1
	not	d1
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)
	subq	#6,a2
	REPT 4
		move.l	(a0)+,d0
		rol.l	d2,d0
		move	d0,d1
		and	d5,d1
		or	d1,(a2)+
	ENDR
	add	scr_width(pc),a1
	dbf	d7,erol32s
	rts

	IFEQ SMALL_VERSION
; Mask values for ror
tablerm	DC.W	$FF00,$00FF,$FF80,$007F,$FFC0,$003F,$FFE0,$001F
	DC.W	$FFF0,$000F,$FFF8,$0007,$FFFC,$0003,$FFFE,$0001

ror32m	subq	#8,d2
	move	d2,d3
	add	d3,d3
	add	d3,d3
	movem	tablerm(pc,d3),d4/d5	; get masks
	cmp	#1,d6
	blt.s	aror32m			; no clipping
	beq.s	bror32m			; left clip 1 word
	cmp	#3,d6			
	blt	cror32m			; left clip 2 words
 	beq	dror32m			; right clip 1 word
	bra	eror32m			; right clip 2 words
aror32m	lea	(a1),a2
	lea	8(a1),a3
	lea	16(a1),a4
	move.l	(a0)+,d0
	ror.l	d2,d0
	move	d0,d1
	and	d4,d0
	and	d5,d1
	or	d0,(a4)+
	or	d0,(a4)+
	or	d0,(a4)+
	or	d0,(a4)
	swap	d0
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)
	or	d1,(a2)+
	or	d1,(a2)+
	or	d1,(a2)+
	or	d1,(a2)
	subq	#6,a2
	subq	#6,a3
	subq	#6,a4
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,aror32m
	rts
bror32m	lea	8(a1),a3
	lea	16(a1),a4
	move.l	(a0)+,d0
	ror.l	d2,d0
	move	d0,d1
	and	d4,d0
	and	d5,d1
	or	d0,(a4)+
	or	d0,(a4)+
	or	d0,(a4)+
	or	d0,(a4)
	swap	d0
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)
	subq	#6,a3
	subq	#6,a4
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,bror32m
	rts
cror32m	lea	16(a1),a4
	move.l	(a0)+,d0
	ror.l	d2,d0
	and	d4,d0
	or	d0,(a4)+
	or	d0,(a4)+
	or	d0,(a4)+
	or	d0,(a4)
	subq	#6,a4
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,cror32m
	rts
dror32m	lea	(a1),a2
	lea	8(a1),a3
	move.l	(a0)+,d0
	ror.l	d2,d0
	move	d0,d1
	and	d4,d0
	and	d5,d1
	swap	d0
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)
	or	d1,(a2)+
	or	d1,(a2)+
	or	d1,(a2)+
	or	d1,(a2)
	subq	#6,a2
	subq	#6,a3
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,dror32m
	rts
eror32m	lea	(a1),a2
	move.l	(a0)+,d0
	ror.l	d2,d0
	move	d0,d1
	and	d5,d1
	or	d1,(a2)+
	or	d1,(a2)+
	or	d1,(a2)+
	or	d1,(a2)
	subq	#6,a2
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,eror32m
	rts

; Mask values for rol
tablelm	DC.W	$0000,$FFFF,$8000,$7FFF,$C000,$3FFF,$E000,$1FFF
	DC.W	$F000,$0FFF,$F800,$07FF,$FC00,$03FF,$FE00,$01FF

rol32m	move	d2,d3
	add	d3,d3
	add	d3,d3
	movem	tablelm(pc,d3),d4/d5
	moveq	#8,d3
	sub	d2,d3
	move	d3,d2
	cmp	#1,d6
	blt.s	arol32m
	beq.s	brol32m
	cmp	#3,d6
	blt.s	crol32m
	beq	drol32m
	bra	erol32m
	
arol32m	lea	(a1),a2
	lea	8(a1),a3
	lea	16(a1),a4
	move.l	(a0)+,d0
	rol.l	d2,d0
	move	d0,d1
	and	d4,d0
	and	d5,d1
	or	d0,(a4)+
	or	d0,(a4)+
	or	d0,(a4)+
	or	d0,(a4)
	swap	d0
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)
	or	d1,(a2)+
	or	d1,(a2)+
	or	d1,(a2)+
	or	d1,(a2)
	subq	#6,a2
	subq	#6,a3
	subq	#6,a4
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,arol32m
	rts
brol32m	lea	8(a1),a3
	lea	16(a1),a4
	move.l	(a0)+,d0
	rol.l	d2,d0
	and	d4,d0
	or	d0,(a4)+
	or	d0,(a4)+
	or	d0,(a4)+
	or	d0,(a4)
	swap	d0
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)
	subq	#6,a3
	subq	#6,a4
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,brol32m
	rts
crol32m	lea	16(a1),a4
	move.l	(a0)+,d0
	rol.l	d2,d0
	and	d4,d0
	or	d0,(a4)+
	or	d0,(a4)+
	or	d0,(a4)+
	or	d0,(a4)
	subq	#6,a4
	lea	16(a0),a0
	lea	160(a1),a1
	dbf	d7,crol32m
	rts
drol32m	lea	(a1),a2
	lea	8(a1),a3
	move.l	(a0)+,d0
	rol.l	d2,d0
	move	d0,d1
	and	d4,d0
	and	d5,d1
	swap	d0
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)+
	or	d0,(a3)
	or	d1,(a2)+
	or	d1,(a2)+
	or	d1,(a2)+
	or	d1,(a2)
	subq	#6,a2
	subq	#6,a3
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,drol32m
	rts
erol32m	lea	(a1),a2
	move.l	(a0)+,d0
	rol.l	d2,d0
	move	d0,d1
	and	d5,d1
	or	d1,(a2)+
	or	d1,(a2)+
	or	d1,(a2)+
	or	d1,(a2)
	subq	#6,a2
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,erol32m
	rts

; Mask values for ror
tablerim
	DC.W	$FF00,$00FF,$FF80,$007F,$FFC0,$003F,$FFE0,$001F
	DC.W	$FFF0,$000F,$FFF8,$0007,$FFFC,$0003,$FFFE,$0001

ror32im	subq	#8,d2
	move	d2,d3
	add	d3,d3
	add	d3,d3
	movem	tablerim(pc,d3),d4/d5	; get masks
	cmp	#1,d6
	blt.s	aror32im		; no clipping
	beq.s	bror32im		; left clip 1 word
	cmp	#3,d6			
	blt	cror32im		; left clip 2 words
 	beq	dror32im		; right clip 1 word
	bra	eror32im		; right clip 2 words
aror32im
	lea	(a1),a2
	lea	8(a1),a3
	lea	16(a1),a4
	move.l	(a0)+,d0
	ror.l	d2,d0
	move	d0,d1
	and	d4,d0
	and	d5,d1
	not.l	d0
	not	d1
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)
	swap	d0
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)
	subq	#6,a2
	subq	#6,a3
	subq	#6,a4
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,aror32im
	rts
bror32im
	lea	8(a1),a3
	lea	16(a1),a4
	move.l	(a0)+,d0
	ror.l	d2,d0
	move	d0,d1
	and	d4,d0
	and	d5,d1
	not.l	d0
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)
	swap	d0
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)
	subq	#6,a3
	subq	#6,a4
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,bror32im
	rts
cror32im
	lea	16(a1),a4
	move.l	(a0)+,d0
	ror.l	d2,d0
	and	d4,d0
	not	d0
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)
	subq	#6,a4
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,cror32im
	rts
dror32im
	lea	(a1),a2
	lea	8(a1),a3
	move.l	(a0)+,d0
	ror.l	d2,d0
	move	d0,d1
	and	d4,d0
	and	d5,d1
	not.l	d0
	not	d1
	swap	d0
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)
	subq	#6,a2
	subq	#6,a3
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,dror32im
	rts
eror32im
	lea	(a1),a2
	move.l	(a0)+,d0
	ror.l	d2,d0
	move	d0,d1
	and	d5,d1
	not	d1
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)
	subq	#6,a2
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,eror32im
	rts

; Mask values for rol
tablelim
	DC.W	$0000,$FFFF,$8000,$7FFF,$C000,$3FFF,$E000,$1FFF
	DC.W	$F000,$0FFF,$F800,$07FF,$FC00,$03FF,$FE00,$01FF

rol32im	move	d2,d3
	add	d3,d3
	add	d3,d3
	movem	tablelim(pc,d3),d4/d5
	moveq	#8,d3
	sub	d2,d3
	move	d3,d2
	cmp	#1,d6
	blt.s	arol32im
	beq.s	brol32im
	cmp	#3,d6
	blt	crol32im
	beq	drol32im
	bra	erol32im
	
arol32im
	lea	(a1),a2
	lea	8(a1),a3
	lea	16(a1),a4
	move.l	(a0)+,d0
	rol.l	d2,d0
	move	d0,d1
	and	d4,d0
	and	d5,d1
	not.l	d0
	not	d1
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)
	swap	d0
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)
	subq	#6,a2
	subq	#6,a3
	subq	#6,a4
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,arol32im
	rts
brol32im
	lea	8(a1),a3
	lea	16(a1),a4
	move.l	(a0)+,d0
	rol.l	d2,d0
	and	d4,d0
	not.l	d0
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)
	swap	d0
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)
	subq	#6,a3
	subq	#6,a4
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,brol32im
	rts
crol32im
	lea	16(a1),a4
	move.l	(a0)+,d0
	rol.l	d2,d0
	and	d4,d0
	not	d0
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)+
	and	d0,(a4)
	subq	#6,a4
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,crol32im
	rts
drol32im
	lea	(a1),a2
	lea	8(a1),a3
	move.l	(a0)+,d0
	rol.l	d2,d0
	move	d0,d1
	and	d4,d0
	and	d5,d1
	not.l	d0
	not	d1
	swap	d0
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)+
	and	d0,(a3)
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)
	subq	#6,a2
	subq	#6,a3
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,drol32im
	rts
erol32im
	lea	(a1),a2
	move.l	(a0)+,d0
	rol.l	d2,d0
	move	d0,d1
	and	d5,d1
	not	d1
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)+
	and	d1,(a2)
	subq	#6,a2
	lea	16(a0),a0
	add	scr_width(pc),a1
	dbf	d7,erol32im
	rts
	ENDC
;
; Sprite handler.
;
; Written by T.A.King Copyright 1993 Ninth Wave Software
;
; Note: if your that clever to use this routine then you won't need
; many comments will you !!!
;
;
; Sprite record structure
MODE		= 0
G_START		= 2
FRAME		= 6
X		= 8
Y		= 10
WIDTH		= 12
HEIGHT		= 14
SIZE		= 16
BUF1		= 18
BUF2 		= 22
STRUCT_SIZE	= 26

print_sprites
	movem.l	d0-7/a0-6,-(a7)
	move	64(a7),d0		; number of sprites
	move.l	66(a7),a5		; sprite records
	move.l	70(a7),a1		; screen
	subq	#1,d0
loop	movem.l	d0/a1,-(a7)
	tst	(a5)
	beq.s	nxt
	move	FRAME(a5),d2		; frame
	move	X(a5),d0		; x
	move	Y(a5),d1		; y
	move	HEIGHT(a5),d3		; height
	move.l	G_START(a5),a0		; graphics
	move	SIZE(a5),d4
	mulu	d2,d4
	add	d4,a0			; graphic start
	tst	WIDTH(a5)
	bne.s	.d32
	lea	save_16(pc),a6
	bsr	draw_16
	bra.s	nxt
.d32	lea	save_32(pc),a6
	bsr	draw_32
nxt	lea	STRUCT_SIZE(a5),a5
	movem.l	(a7)+,d0/a1
	dbf	d0,loop
	movem.l	(a7)+,d0-7/a0-6
	rts

erase_sprites
	movem.l	d1-7/a0-6,-(a7)
	move	60(a7),d0
	move.l	62(a7),a5
	subq	#1,d0
	bmi.s	es_end
	move	d0,d1
	move	d0,d2
	mulu	#STRUCT_SIZE,d1
	add	d1,a5

e_lp	move.l	BUF2(a5),a2
	move	(a2),d3
	cmp	#1,d3
	blt.s	e_nxt
	beq.s	erase_16
	bgt.s	erase_32

e_nxt	move.l	BUF1(a5),a2
	move.l	BUF2(a5),BUF1(a5)
	move.l	a2,BUF2(a5)
	lea	-STRUCT_SIZE(a5),a5
	dbf	d2,e_lp
	lea	STRUCT_SIZE(a5),a5
es_end	movem.l	(a7)+,d1-7/a0-6
	rts
erase_16
	clr	(a2)+
	move.l	(a2)+,a3		; location
	move	(a2)+,d7		; height
.res1	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)
	add	scr_width(pc),a3
	lea	-12(a3),a3
	dbf	d7,.res1
	bra.s	e_nxt
erase_32
	clr	(a2)+
	move.l	(a2)+,a3	
	move	(a2)+,d7	
.res2	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)+
	move.l	(a2)+,(a3)
	add	scr_width(pc),a3
	lea	-20(a3),a3
	dbf	d7,.res2
	bra.s	e_nxt

save_16	move.l	BUF1(a5),a2
	move	#1,(a2)+		; 1=16x
	move.l	a1,(a2)+		; save screen graphics
	move	d7,(a2)+		; save height of sprite
	movem.l	a1/d7,-(a7)
.sveply	move.l	(a1)+,(a2)+		; save screen data
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1),(a2)+
	add	scr_width(pc),a1
	lea	-12(a1),a1
	dbf	d7,.sveply
	movem.l	(a7)+,a1/d7
	jmp	ret16s(pc)

save_32	move.l	BUF1(a5),a2
	move	#2,(a2)+		; 2=32x
	move.l	a1,(a2)+		
	move	d7,(a2)+
	movem.l	a1/d7,-(a7)
.sveply	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1),(a2)+
	add	scr_width(pc),a1
	lea	-20(a1),a1
	dbf	d7,.sveply
	movem.l	(a7)+,a1/d7
	jmp	ret32s(pc)

	IFEQ SMALL_VERSION
;
; Print preshifted sprite.
;
; ~C:fast_sprite%(sprite,x,y,width,height,L:graphics,L:screen)

fast_sprite	
	cmp	#32,10(a7)
	beq	fast_32
fast_16	movem.l	d0-7/a0-6,-(a7)
	move	64(a7),d2		; sprite
	move	66(a7),d0		; x
	move	68(a7),d1		; y
	move	72(a7),d3		; height	
	move.l	74(a7),a0		; graphics
	move.l	78(a7),a1		; screen
	subq	#8,d0
	move	d3,d4
	moveq	#24,d5
	mulu	d5,d4			; sprite size
	move	d0,d6
	and	#$f,d6
	mulu	d4,d6			; pixel offset
	lsl.l	#4,d4
	mulu	d4,d2
	add.l	d6,d2
	add.l	d2,a0			; graphic start
	lea	clipping(pc),a4
	lea	tab16s(pc),a5
	bsr	print16s
	movem.l	(a7)+,d0-7/a0-6
	rts

fast_mask
	cmp	#32,10(a7)
	beq	fmask32

fmask16	movem.l	d0-7/a0-6,-(a7)
	move	64(a7),d2
	move	66(a7),d0
	move	68(a7),d1
	move	72(a7),d3
	move.l	74(a7),a0
	move.l	78(a7),a1
	subq	#8,d0
	move	d3,d4
	moveq	#24,d5
	mulu	d5,d4
	move	d0,d6
	and	#$f,d6
	mulu	d4,d6
	lsl.l	#4,d4
	mulu	d4,d2
	add.l	d6,d2
	add.l	d2,a0
	lea	clipping(pc),a4
	lea	tab16m(pc),a5
	bsr.s	print16s
	movem.l	(a7)+,d0-7/a0-6
	rts

fast_invmask
	cmp	#32,10(a7)
	beq	fimask32

fimask16
	movem.l	d0-7/a0-6,-(a7)
	move	64(a7),d2
	move	66(a7),d0
	move	68(a7),d1
	move	72(a7),d3
	move.l	74(a7),a0
	move.l	78(a7),a1
	subq	#8,d0
	move	d3,d4
	moveq	#24,d5
	mulu	d5,d4
	move	d0,d6
	and	#$f,d6
	mulu	d4,d6
	lsl.l	#4,d4
	mulu	d4,d2
	add.l	d6,d2
	add.l	d2,a0
	lea	clipping(pc),a4
	lea	tab16im(pc),a5
	bsr.s	print16s
	movem.l	(a7)+,d0-7/a0-6
	rts

print16s
	move	(a5),d6
	move	d3,d7
	subq	#1,d7
	move	(a4),d4
	cmp	d4,d1
	bge.s	.maxy
	move	d4,d5
	sub	d3,d5
	cmp	d5,d1
	ble.s	.off
	sub	d4,d1
	add	d1,d7
	neg	d1
	mulu	#24,d1
	add	d1,a0
	move	d4,d1
	bra.s	.minx
.maxy	move	2(a4),d4
	cmp	d4,d1
	bge.s	.off
	sub	d3,d4
	cmp	d4,d1
	ble.s	.minx
	sub	d1,d4
	add	d4,d7
.minx	move	4(a4),d4
	cmp	d4,d0
	bge.s	.maxx
	sub	#16,d4
	cmp	d4,d0
	ble.s	.off
	add	scr_width+2(pc),d0
	sub	scr_width(pc),a1
	move	2(a5),d6
	bra.s	.calc
.off	rts
.maxx	move	6(a4),d4
	cmp	d4,d0
	bge.s	.off
	sub	#16,d4
	cmp	d4,d0
	blt.s	.calc
	move	4(a5),d6
.calc	move	d0,d2
	and	#$fff0,d0
	lsr	#1,d0
	add	d0,a1			; add x offset to screen
	mulu	scr_width(pc),d1
	add.l	d1,a1			; add y offset to screen
	lea	here16(pc),a6
	jmp	(a6,d6.w)

here16
tab16s	dc.w	nc16s-here16
	dc.w	lc16s-here16
	dc.w	rc16s-here16
tab16m	dc.w	nc16m-here16
	dc.w	lc16m-here16
	dc.w	rc16m-here16
tab16im	dc.w	nc16im-here16
	dc.w	lc16im-here16
	dc.w	rc16im-here16
	
nc16s	movem.l	(a1),d3-6
	move.l	(a0)+,d0
	and.l	d0,d3
	and.l	d0,d4
	or.l	(a0)+,d3
	or.l	(a0)+,d4
	move.l	(a0)+,d0
	and.l	d0,d5
	and.l	d0,d6
	or.l	(a0)+,d5
	or.l	(a0)+,d6
	movem.l	d3-6,(a1)
	add	scr_width(pc),a1
	dbf	d7,nc16s
	rts
lc16s	lea	12(a0),a0
	addq	#8,a1
	movem.l	(a1),d5-6
	move.l	(a0)+,d0
	and.l	d0,d5
	and.l	d0,d6
	or.l	(a0)+,d5
	or.l	(a0)+,d6
	movem.l	d5-6,(a1)
	add	scr_width(pc),a1
	subq	#8,a1
	dbf	d7,lc16s
	rts
rc16s	move.l	(a0)+,d0
	movem.l	(a1),d3-4
	and.l	d0,d3
	and.l	d0,d4
	or.l	(a0)+,d3
	or.l	(a0)+,d4
	lea	12(a0),a0
	movem.l	d3-4,(a1)
	add	scr_width(pc),a1
	dbf	d7,rc16s
	rts
nc16m	move.l	(a0)+,d0
	not.l	d0
	addq	#8,a0
	or.l	d0,(a1)+
	or.l	d0,(a1)+
	move.l	(a0)+,d0
	not.l	d0
	addq	#8,a0
	or.l	d0,(a1)+
	or.l	d0,(a1)+
	add	scr_width(pc),a1
	lea	-16(a1),a1
	dbf	d7,nc16m
	rts
lc16m	lea	12(a0),a0
	addq	#8,a1
	move.l	(a0)+,d0
	not.l	d0
	addq	#8,a0
	or.l	d0,(a1)+
	or.l	d0,(a1)+
	add	scr_width(pc),a1
	lea	-16(a1),a1
	dbf	d7,lc16m
	rts
rc16m	move.l	(a0)+,d0
	not.l	d0
	addq	#8,a0
	or.l	d0,(a1)+
	or.l	d0,(a1)+
	lea	12(a0),a0
	add	scr_width(pc),a1
	subq	#8,a1
	dbf	d7,rc16m
	rts
nc16im	move.l	(a0)+,d0
	addq	#8,a0
	and.l	d0,(a1)+
	and.l	d0,(a1)+
	move.l	(a0)+,d0
	addq	#8,a0
	and.l	d0,(a1)+
	and.l	d0,(a1)+
	add	scr_width(pc),a1
	lea	-16(a1),a1
	dbf	d7,nc16im
	rts
lc16im	lea	12(a0),a0
	addq	#8,a1
	move.l	(a0)+,d0
	addq	#8,a0
	and.l	d0,(a1)+
	and.l	d0,(a1)+
	add	scr_width(pc),a1
	lea	-16(a1),a1
	dbf	d7,lc16im
	rts
rc16im	move.l	(a0)+,d0
	addq	#8,a0
	and.l	d0,(a1)+
	and.l	d0,(a1)+
	lea	12(a0),a0
	add	scr_width(pc),a1
	subq	#8,a1
	dbf	d7,rc16im
	rts


fast_32	movem.l	d0-7/a0-6,-(a7)
	move	64(a7),d2	
	move	66(a7),d0	
	move	68(a7),d1	
	move	72(a7),d3	
	move.l	74(a7),a0	
	move.l	78(a7),a1	
	sub	#16,d0
	move	d3,d4
	moveq	#36,d5
	mulu	d5,d4			; sprite size
	move	d0,d6
	and	#$f,d6
	mulu	d4,d6			; pixel offset
	lsl.l	#4,d4
	mulu	d4,d2
	add.l	d6,d2
	add.l	d2,a0			; graphic start
	lea	clipping(pc),a4
	lea	tab32s(pc),a5
	bsr	print32s
	movem.l	(a7)+,d0-7/a0-6
	rts

fmask32	movem.l	d0-7/a0-6,-(a7)
	move	64(a7),d2	
	move	66(a7),d0	
	move	68(a7),d1	
	move	72(a7),d3	
	move.l	74(a7),a0	
	move.l	78(a7),a1	
	sub	#16,d0
	move	d3,d4
	moveq	#36,d5
	mulu	d5,d4			; sprite size
	move	d0,d6
	and	#$f,d6
	mulu	d4,d6			; pixel offset
	lsl.l	#4,d4
	mulu	d4,d2
	add.l	d6,d2
	add.l	d2,a0			; graphic start
	lea	clipping(pc),a4
	lea	tab32m(pc),a5
	bsr.s	print32s
	movem.l	(a7)+,d0-7/a0-6
	rts

fimask32
	movem.l	d0-7/a0-6,-(a7)
	move	64(a7),d2	
	move	66(a7),d0	
	move	68(a7),d1	
	move	72(a7),d3	
	move.l	74(a7),a0	
	move.l	78(a7),a1	
	sub	#16,d0
	move	d3,d4
	moveq	#36,d5
	mulu	d5,d4			; sprite size
	move	d0,d6
	and	#$f,d6
	mulu	d4,d6			; pixel offset
	lsl.l	#4,d4
	mulu	d4,d2
	add.l	d6,d2
	add.l	d2,a0			; graphic start
	lea	clipping(pc),a4
	lea	tab32im(pc),a5
	bsr.s	print32s
	movem.l	(a7)+,d0-7/a0-6
	rts

print32s
	move	(a5),d6
	move	d3,d7
	subq	#1,d7
	
	move	(a4),d4
	cmp	d4,d1
	bge.s	.bmaxy
	move	d4,d5
	sub	d3,d5
	cmp	d5,d1
	ble.s	.off
	sub	d4,d1
	add	d1,d7
	neg	d1
	mulu	#36,d1
	add	d1,a0
	move	d4,d1			
	bra.s	.bminx
.bmaxy	move	2(a4),d4
	cmp	d4,d1
	bge.s	.off
	sub	d3,d4
	cmp	d4,d1
	ble.s	.bminx
	sub	d1,d4
	add	d4,d7
.bminx	move	4(a4),d4
	cmp	d4,d0
	bge.s	.bmaxx
	sub	#32,d4
	cmp	d4,d0
	ble.s	.off
	move	d0,d5
	add	scr_width+2(pc),d0
	sub	scr_width(pc),a1
	move	2(a5),d6
	add	#16,d4
	cmp	d4,d5
	bge.s	.calc
	move	4(a5),d6
	bra.s	.calc
.off	rts
.bmaxx	move	6(a4),d4
	cmp	d4,d0
	bge.s	.off
	sub	#32,d4
	cmp	d4,d0
	ble.s	.calc
	move	6(a5),d6
	add	#16,d4
	cmp	d4,d0
	blt.s	.calc
	move	8(a5),d6
.calc	move	d0,d2
	and	#$fff0,d0
	lsr	#1,d0
	add	d0,a1			; add x offset to screen
	mulu	scr_width(pc),d1
	add.l	d1,a1			; add y offset to screen
	lea	here32(pc),a6
	jmp	(a6,d6.w)

here32
tab32s	dc.w	nc32s-here32
	dc.w	lc32s1-here32
	dc.w	lc32s2-here32
	dc.w	rc32s1-here32
	dc.w	rc32s2-here32
tab32m	dc.w	nc32m-here32
	dc.w	lc32m1-here32
	dc.w	lc32m2-here32
	dc.w	rc32m1-here32
	dc.w	rc32m2-here32
tab32im	dc.w	nc32im-here32
	dc.w	lc32im1-here32
	dc.w	lc32im2-here32
	dc.w	rc32im1-here32
	dc.w	rc32im2-here32

nc32s	movem.l	(a1),d1-6
	move.l	(a0)+,d0
	and.l	d0,d1
	and.l	d0,d2
	or.l	(a0)+,d1
	or.l	(a0)+,d2
	move.l	(a0)+,d0
	and.l	d0,d3
	and.l	d0,d4
	or.l	(a0)+,d3
	or.l	(a0)+,d4
	move.l	(a0)+,d0
	and.l	d0,d5
	and.l	d0,d6
	or.l	(a0)+,d5
	or.l	(a0)+,d6
	movem.l	d1-6,(a1)
	add	scr_width(pc),a1
	dbf	d7,nc32s
	rts
lc32s1	addq	#8,a1
	movem.l	(a1),d3-6
	lea	12(a0),a0
	move.l	(a0)+,d0
	and.l	d0,d3
	and.l	d0,d4
	or.l	(a0)+,d3
	or.l	(a0)+,d4
	move.l	(a0)+,d0
	and.l	d0,d5
	and.l	d0,d6
	or.l	(a0)+,d5
	or.l	(a0)+,d6
	movem.l	d3-6,(a1)
	add	scr_width(pc),a1
	subq	#8,a1
	dbf	d7,lc32s1
	rts
lc32s2	lea	16(a1),a1
	movem.l	(a1),d5-6
	lea	24(a0),a0
	move.l	(a0)+,d0
	and.l	d0,d5
	and.l	d0,d6
	or.l	(a0)+,d5
	or.l	(a0)+,d6
	movem.l	d5-6,(a1)
	add	scr_width(pc),a1
	lea	-16(a1),a1
	dbf	d7,lc32s2
	rts
rc32s1	movem.l	(a1),d1-4
	move.l	(a0)+,d0
	and.l	d0,d1
	and.l	d0,d2
	or.l	(a0)+,d1
	or.l	(a0)+,d2
	move.l	(a0)+,d0
	and.l	d0,d3
	and.l	d0,d4
	or.l	(a0)+,d3
	or.l	(a0)+,d4
	lea	12(a0),a0
	movem.l	d1-4,(a1)
	add	scr_width(pc),a1
	dbf	d7,rc32s1
	rts
rc32s2	movem.l	(a1),d1-2
	move.l	(a0)+,d0
	and.l	d0,d1
	and.l	d0,d2
	or.l	(a0)+,d1
	or.l	(a0)+,d2
	lea	24(a0),a0
	movem.l	d1-2,(a1)
	add	scr_width(pc),a1
	dbf	d7,rc32s2
	rts

nc32m	move.l	(a0)+,d0
	not.l	d0
	addq	#8,a0
	or.l	d0,(a1)+
	or.l	d0,(a1)+
	move.l	(a0)+,d0
	not.l	d0
	addq	#8,a0
	or.l	d0,(a1)+
	or.l	d0,(a1)+
	move.l	(a0)+,d0
	not.l	d0
	addq	#8,a0
	or.l	d0,(a1)+
	or.l	d0,(a1)+
	add	scr_width(pc),a1
	lea	-24(a1),a1
	dbf	d7,nc32m
	rts
lc32m1	addq	#8,a1
	lea	12(a0),a0
	move.l	(a0)+,d0
	not.l	d0
	addq	#8,a0
	or.l	d0,(a1)+
	or.l	d0,(a1)+
	move.l	(a0)+,d0
	not.l	d0
	addq	#8,a0
	or.l	d0,(a1)+
	or.l	d0,(a1)+
	add	scr_width(pc),a1
	lea	-24(a1),a1
	dbf	d7,lc32m1
	rts
lc32m2	lea	16(a1),a1
	lea	24(a0),a0
	move.l	(a0)+,d0
	not.l	d0
	addq	#8,a0
	or.l	d0,(a1)+
	or.l	d0,(a1)+
	add	scr_width(pc),a1
	lea	-24(a1),a1
	dbf	d7,lc32m2
	rts
rc32m1	move.l	(a0)+,d0
	not.l	d0
	addq	#8,a0
	or.l	d0,(a1)+
	or.l	d0,(a1)+
	move.l	(a0)+,d0
	not.l	d0
	addq	#8,a0
	or.l	d0,(a1)+
	or.l	d0,(a1)+
	lea	12(a0),a0
	add	scr_width(pc),a1
	lea	-16(a1),a1
	dbf	d7,rc32m1
	rts
rc32m2	move.l	(a0)+,d0
	not.l	d0
	addq	#8,a0
	or.l	d0,(a1)+
	or.l	d0,(a1)+
	lea	24(a0),a0
	add	scr_width(pc),a1
	subq	#8,a1
	dbf	d7,rc32m2
	rts

nc32im	move.l	(a0)+,d0
	addq	#8,a0
	and.l	d0,(a1)+
	and.l	d0,(a1)+
	move.l	(a0)+,d0
	addq	#8,a0
	and.l	d0,(a1)+
	and.l	d0,(a1)+
	move.l	(a0)+,d0
	addq	#8,a0
	and.l	d0,(a1)+
	and.l	d0,(a1)+
	add	scr_width(pc),a1
	lea	-24(a1),a1
	dbf	d7,nc32im
	rts
lc32im1	addq	#8,a1
	lea	12(a0),a0
	move.l	(a0)+,d0
	addq	#8,a0
	and.l	d0,(a1)+
	and.l	d0,(a1)+
	move.l	(a0)+,d0
	addq	#8,a0
	and.l	d0,(a1)+
	and.l	d0,(a1)+
	add	scr_width(pc),a1
	lea	-24(a1),a1
	dbf	d7,lc32im1
	rts
lc32im2	lea	16(a1),a1
	lea	24(a0),a0
	move.l	(a0)+,d0
	addq	#8,a0
	and.l	d0,(a1)+
	and.l	d0,(a1)+
	add	scr_width(pc),a1
	lea	-24(a1),a1
	dbf	d7,lc32im2
	rts
rc32im1	move.l	(a0)+,d0
	addq	#8,a0
	and.l	d0,(a1)+
	and.l	d0,(a1)+
	move.l	(a0)+,d0
	addq	#8,a0
	and.l	d0,(a1)+
	and.l	d0,(a1)+
	lea	12(a0),a0
	add	scr_width(pc),a1
	lea	-16(a1),a1
	dbf	d7,rc32im1
	rts
rc32im2	move.l	(a0)+,d0
	addq	#8,a0
	and.l	d0,(a1)+
	and.l	d0,(a1)+
	lea	24(a0),a0
	add	scr_width(pc),a1
	subq	#8,a1
	dbf	d7,rc32im2
	rts
;
; ~C:store_sprite%(frame,x,y,width,height,l:gfx,l:screen)
;
store_sprite
	movem.l	d1-7/a0-6,-(a7)
	movem	60(a7),d0-4
	movem.l	70(a7),a0-1
	and	#$fff0,d1
	asr	#1,d1
	mulu	scr_width(pc),d2
	add	d1,a1
	add.l	d2,a1
	moveq	#10,d5
	lea	.s16(pc),a2
	cmp	#16,d3
	beq.s	.w16
.w32	lea	.s32(pc),a2
	add	d5,d5
.w16	move	d4,d6
	mulu	d5,d6
	mulu	d6,d0
	add.l	d0,a0
	move	d4,d7
	subq	#1,d7
.lp	jmp	(a2)
.s16	movem	(a1),d0-3
	move	d0,d4
	or	d1,d4
	or	d2,d4
	or	d3,d4
	move	d4,(a0)+
	move	d0,(a0)+
	move	d1,(a0)+
	move	d2,(a0)+
	move	d3,(a0)+
	add	scr_width(pc),a1
	dbf	d7,.lp
	movem.l	(a7)+,d1-7/a0-6
	rts
.s32	movem	(a1),d0-3
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	move	8(a1),d0
	move	10(a1),d1
	move	12(a1),d2
	move	14(a1),d3
	move.l	d0,d4
	or.l	d1,d4
	or.l	d2,d4
	or.l	d3,d4
	rol.l	#8,d0
	rol.l	#8,d1
	rol.l	#8,d2
	rol.l	#8,d3
	rol.l	#8,d4
	move.l	d4,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d2,(a0)+
	move.l	d3,(a0)+
	add	scr_width(pc),a1
	dbf	d7,.lp
	movem.l	(a7)+,d1-7/a0-6
	rts
	ENDC

sprite_width
	movem.l	d0/a0,-(a7)
	move	12(a7),d0
	lea	scr_width(pc),a0
	move	d0,(a0)+
	add	d0,d0
	move	d0,(a0)
	movem.l	(a7)+,d0/a0
	rts
	
clipping
ymin	dc.w	0
ymax	dc.w	200
xmin	dc.w	0
xmax	dc.w	320		

scr_width
	dc.w	160
	dc.w	320
	
; Part of the Sprite Works extension kit Copyright 1994/94 Ninth Wave
