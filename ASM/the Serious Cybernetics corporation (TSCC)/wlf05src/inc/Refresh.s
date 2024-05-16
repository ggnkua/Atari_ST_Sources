TILESHIFT	=	8
TILEGLOBAL	=	256	; Wall height, width
FRACBITS	=	8
SHORTTOANGLESHIFT =	5	; Angle range to fines


**********************************
*
*	Flags used by Actorat/Tilemap, NOTE: this allows only 64 unique tiles
*	
**********************************

TI_SECRET	=	7	; Secret level switch
TI_BODY		=	6	; Dead body here
TI_BLOCKSIGHT	=	5	; Sight is blocked
TI_GETABLE	=	4	; Getable item here
TI_THING	=	3	; Static or missile here
TI_PUSHWALL	=	2	; Pushwall here
TI_SWITCH	=	1	; Exit switch here
TI_BLOCKMOVE	=	0	; Block motion here

TI_DOOR		=	7	; Door here
TI_DOORSIDE	=	6	; Door slider
TI_NUMMASK	=	63	; Can be an area, door number or pwall number


		opt	m+	; Process macro postfixes

		section text
viewsin		ds.w	1	; sin/cos[viewangle]
viewcos		ds.w	1

		rsreset	1	; Door shape indexes
S_STEELDOOR	rs.b	1
S_G_KEY_DOOR	rs.b	1
S_S_KEY_DOOR	rs.b	1
S_ELEV_DOOR	rs.b	1
S_DOORSIDE	rs.b	1

DoorShapes	ds.b	5	; Indexes to the single wallshapes
		even


**********************************
*
*  void RenderView()
*
* Refresh the entire 3d view
*
**********************************

RenderView	bsr.w	IO_ClearViewBuffer; Erase to ceiling / floor colors

		bsr.w	WallRefresh
		bsr.w	DrawSprites
				
		jsr	IO_DisplayViewBuffer


	****
		movea.l	ScreenAdr2(pc),a1	; Draw my weapon
		lea.l	__myweapon,a0

		move.w	#PHYSX/16,d0		; Justify shape
		sub.w	(a0)+,d0
		lsr.w	d0
		lsl.w	#3,d0

		moveq.l	#80,d1
		move.w	ysize(pc),d2
		tst.b	detail
		beq.s	.low
		lsr.w	d2

.low		add.w	d2,d1
		sub.w	(a0)+,d1
		mulu.w	#PHYSX/2,d1

		adda.w	d0,a1
		adda.w	d1,a1
		
		jsr	(a0)
		

	****
		BlastScreen
		rts
		
		
**********************************
*
*  void HitVertWall(d6.b tilehit, d7.w tileoffset)
*
* tilehit bit 7 is 0, because it's not a door tile
* if bit 6 is 1 and the adjacent tile is a door tile, use door side pic
*
**********************************

HitVertWall	lea.l	Actorat,a1
		adda.w	d7,a1
		btst.b	#TI_PUSHWALL,(a1); Hit a pushwall?
		bne.w	HitVertPWall
		btst.b	#TI_THING,(a1)	; Hit a thing?
		beq.s	.nthing
		
		pea.l	passvert	; Patch returnaddress
		bra.w	AddSprite
		
.nthing		bclr.l	#TI_DOOR,d6	; Tile is a door?
		bne.w	HitVertDoor
		bclr.l	#TI_DOORSIDE,d6	; Doorslider?
		beq.s	.NoVertDoorSide

		asl.w	#6,d0
		sub.w	d0,d7
		btst.b	#TI_DOOR,(a6,d7.w) ; Tilemap[xtile-xstep,yspot] = door ?
		beq.s	.NoVertDoorSide
	
		move.b	DoorShapes+S_DOORSIDE(pc),d6
		
.NoVertDoorSide
SkipVertPWall	moveq.l	#10,d7		; Fractional bits

		move.l	a5,d3
		lsr.l	d7,d3
		andi.w	#63,d3		; texture_x = (yintercept >> 10) & 63

		tst.w	d0		; xtilestep < 0 ?
		bpl.s	.dontmirrorvert ; no, then go on
		eori.b	#63,d3		; otherwise reverse texture
		
		addq.w	#1,d2		; xtile += 1

.dontmirrorvert	swap.w	d2
		clr.w	d2		; xintercept = long(xtile) << 16
		
		sub.l	viewx(a0),d2
		asr.l	#FRACBITS,d2
		muls.w	viewcos(pc),d2
		
		move.l	a5,d4
		sub.l	viewy(a0),d4
		asr.l	#FRACBITS,d4
		muls.w	viewsin(pc),d4

ScaleVert	add.l	d4,d2
		asr.l	d7,d2		; z = (xintercept-viewx)*viewcos+
					;     (yintercept-viewy)*viewsin
			
		IO_ScaleWallColumn d2,d6,d3 ; Scale post

		bra.w	nextpix



**********************************
*
*  void HitHorizWall(d6.b tilehit, d7.w tileoffset)
*
* tilehit bit 7 is 0, because it's not a door tile
* if bit 6 is 1 and the adjacent tile is a door tile, use door side pic
*
**********************************

HitHorizWall	lea.l	Actorat,a1
		adda.w	d7,a1
		btst.b	#TI_PUSHWALL,(a1); Hit a push wall?
		bne.w	HitHorizPWall
		btst.b	#TI_THING,(a1)	; Hit a thing?
		beq.s	.nthing
		
		pea.l	passhoriz	; Patch returnaddress
		bra.w	AddSprite

.nthing		bclr.l	#TI_DOOR,d6	; Tile is a door?
		bne.w	HitHorizDoor
		bclr.l	#TI_DOORSIDE,d6	; Doorslider?
		beq.s	.NoHorDoorSide

		sub.w	d1,d7
		btst.b	#TI_DOOR,(a6,d7.w)	; Tilemap[xspot,ytile-ytilestep] = door ?
		beq.s	.NoHorDoorSide
		
		move.b	DoorShapes+S_DOORSIDE(pc),d6
		
.NoHorDoorSide
SkipHorizPWall	moveq.l	#10,d7
		move.l	a4,d4
		lsr.l	d7,d4
		andi.w	#63,d4		; texture_x = (xintercept >> 10) & 63
		eori.b	#63,d4

		tst.w	d1		; ytilestep = -1 ?
		bpl.s	.dontmirrorhoriz; no, then go on
		eori.b	#63,d4		; otherwise reverse texture
		
		addq.w	#1,d3		; ytile += 1

.dontmirrorhoriz
		swap.w	d3
		clr.w	d3		; yintercept = long(ytile) << 16
		
		move.l  a4,d2
		sub.l	viewx(a0),d2
		asr.l	#FRACBITS,d2
		muls.w	viewcos(pc),d2
		
		sub.l	viewy(a0),d3
		asr.l	#FRACBITS,d3
		muls.w	viewsin(pc),d3

ScaleHoriz	add.l	d3,d2
		asr.l	d7,d2		; z = (xintercept-viewx)*viewcos+
					;     (yintercept-viewy)*viewsin
			
		IO_ScaleWallColumn d2,d6,d4 ; Scale post

		bra.w	nextpix




**********************************
*
*  void HitVertDoor()
*
**********************************

HitVertDoor	move.l	a3,d7
		asr.l	#1,d7
		add.l	a5,d7		; dooryhit = yintercept + ystep/2 (centered)
		
		swap.w	d7
		cmp.w	d5,d7
		bne.w	passvert	; Go on if (dooryhit >> 16) != yspot


		moveq.l	#0,d5		; Point to appropiate door
		move.b	d6,d5
		;mulu.w	#door_t,d5
		lsl.w	#3,d5
	
		lea.l	doors,a1
		adda.w	d5,a1
				
		swap.w	d7		; Test if door is open past this point
		move.w	d7,d5		; continue tracing if so
		lsr.w	#TILESHIFT,d5
		cmp.b	position(a1),d5
		bls.w	passvert


		move.l	d7,d5		; Otherwise draw door tile 
		lsr.l	#TILESHIFT,d5
		sub.b	position(a1),d5
		lsr.b	#2,d5
		ext.w	d5		; texure_x = ((dooryhit-doorposition) >> 10) & 63

		move.W	info(a1),d6
		lea.l	DoorShapes(pc),a1
		move.b	(a1,d6.w),d6
		
		swap.w	d2		; xintercept = long(xtile+32768) << 16
		move.w	#32768,d2
		
		sub.l	viewx(a0),d2
		asr.l	#FRACBITS,d2
		muls.w	viewcos(pc),d2
		
		sub.l	viewy(a0),d7
		asr.l	#FRACBITS,d7
		muls.w	viewsin(pc),d7

		moveq.l	#10,d0
		add.l	d7,d2
		asr.l	d0,d2		; z = (xintercept-viewx)*viewcos+
					;     (yintercept-viewy)*viewsin

		IO_ScaleWallColumn d2,d6,d5 ; Scale post
		
		bra.w	nextpix



**********************************
*
*  void HitHorizDoor()
*
**********************************

HitHorizDoor	move.l	a2,d7
		asr.l	#1,d7
		add.l	a4,d7		; doorxhit = xintercept + xstep/2 (centered)
		
		swap.w	d7
		cmp.w	d4,d7
		bne.w	passhoriz	; just go on if (doorxhit >> 16) != xspot
						
	
		moveq.l	#0,d4		; Point to appropiate door
		move.b	d6,d4
		;mulu.w	#door_t,d4
		lsl.w	#3,d4
	
		lea.l	doors,a1
		adda.w	d4,a1
				
		swap.w	d7		; Test if door is open past this point
		move.w	d7,d4		; continue tracing if so
		lsr.w	#TILESHIFT,d4
		cmp.b	position(a1),d4
		bls.w	passhoriz

	
		move.l	d7,d5		; Otherwise draw door tile 
		lsr.l	#TILESHIFT,d5
		sub.b	position(a1),d5
		lsr.b	#2,d5
		ext.w	d5		; texure_x = ((dooryhit-doorposition) >> 10) & 63
	
		move.W	info(a1),d6
		lea.l	DoorShapes(pc),a1
		move.b	(a1,d6.w),d6

		swap.w	d3		; yintercept = long(ytile+32768) << 16
		move.w	#32768,d3

		sub.l	viewx(a0),d7
		asr.l	#FRACBITS,d7
		muls.w	viewcos(pc),d7
		
		sub.l	viewy(a0),d3
		asr.l	#FRACBITS,d3
		muls.w	viewsin(pc),d3

		moveq.l	#10,d0
		add.l	d7,d3
		asr.l	d0,d3		; z = (xintercept-viewx)*viewcos+
					;     (yintercept-viewy)*viewsin

		IO_ScaleWallColumn d3,d6,d5 ; Scale post
		
		bra.w	nextpix
		

	
**********************************
*
*  void HitVertPWall()
*
* Hit a vertical push wall
*
**********************************
	
HitVertPWall	tst.w	PushWallRec+pwallpos ; Push wall inactive?
		beq.w	SkipVertPWall	     ; Yes, treat as solid wall

		move.l	a3,d7
		asr.l	#8,d7
		muls.w	PushWallRec+pwallpos,d7
		add.l	a5,d7		; dooryhit = yintercept + ystep/2 (centered)
		
		swap.w	d7
		cmp.w	d5,d7
		bne.w	passvert	; Go on if (dooryhit >> 16) != yspot


		swap.w	d7
		move.l	d7,d4
		
		moveq.l	#10,d7

		move.l	d4,d3
		lsr.l	d7,d3
		andi.w	#63,d3		; texture_x = (yintercept >> 10) & 63

		move.w	PushWallRec+pwallpos,a1
		
		tst.w	d0		; xtilestep<0?
		bpl.s	.dontmirrorvert ; No, then go on
		eori.b	#63,d3		; Otherwise reverse texture
		
		addq.w	#1,d2		; xtile += 1

		suba.w	a1,a1
		suba.w	PushWallRec+pwallpos,a1
		
.dontmirrorvert	swap.w	d2
		clr.w	d2		; xintercept = long(xtile) << 16
		
		sub.l	viewx(a0),d2
		asr.l	#FRACBITS,d2
		add.w	a1,d2		; xintercept += pwallpos*sgn(xtilestep)
		muls.w	viewcos(pc),d2
		
		sub.l	viewy(a0),d4
		asr.l	#FRACBITS,d4
		muls.w	viewsin(pc),d4

		bra.w	ScaleVert
	
	

**********************************
*
*  void HitHorizPWall()
*
* Hit a horizontal push wall
*
**********************************
	
HitHorizPWall	tst.w	PushWallRec+pwallpos ; Push wall inactive?
		beq.w	SkipHorizPWall	     ; Yes, treat as solid wall

		move.l	a2,d7
		asr.l	#8,d7
		muls.w	PushWallRec+pwallpos,d7
		add.l	a4,d7		; xintercept = xintercept + xstep*pwallpos
			
		swap.w	d7		; Does the ray pass left or
		cmp.w	d4,d7		; right of the pushed wall?
		bne.w	passhoriz
		
		swap.w	d7
		move.l	d7,d2
		
		moveq.l	#10,d7
		move.l	d2,d4
		lsr.l	d7,d4
		andi.w	#63,d4		; texture_x = (xintercept >> 10) & 63
		eori.b	#63,d4

		movea.w	PushWallRec+pwallpos,a1
		
		tst.w	d1		; ytilestep<0?
		bpl.s	.dontmirrorhoriz; No, then go on
		eori.b	#63,d4		; Otherwise reverse texture
		
		addq.w	#1,d3		; ytile += 1

		suba.w	a1,a1
		suba.w	PushWallRec+pwallpos,a1
		
.dontmirrorhoriz
		swap.w	d3
		clr.w	d3		; yintercept = long(ytile) << 16
		
		sub.l	viewx(a0),d2
		asr.l	#FRACBITS,d2
		muls.w	viewcos(pc),d2
		
		sub.l	viewy(a0),d3
		asr.l	#FRACBITS,d3
		add.w	a1,d3
		muls.w	viewsin(pc),d3

		bra.w	ScaleHoriz




**********************************
*
*  void macro GetQuadrant(u16 Angle,i16 xtilestep,i16 ytilestep)
*
* Returns the xtilestep, ytilestep based on the angle patches the
* opcodes for the raytrace
*
**********************************

OP_BGE		= $6c		; opcodes (bge.s, ble.s)
OP_BLE		= $6f

GetQuadrant	macro
		move.w	\1,d0

.\@first	cmpi.w	#DEG90,d0	; Angle>=90ø?
		bhi.s	.\@second

		moveq.l	#1,\2		; xtilestep = 1
		moveq.l	#1,\3		; ytilestep = 1

		move.b	#OP_BGE,vertpatch  ; patch in a bge.s
		move.b	#OP_BGE,horizpatch ; patch in a bge.s

		move.w	xpartialup(a0),xpartial(a0)
		move.w	ypartialup(a0),ypartial(a0)

		bra.s	.\@break

.\@second	cmpi.w	#DEG180,d0	; Angle>=180ø?
		bhi.s	.\@third

		moveq.l	#-1,\2		; xtilestep = -1
		moveq.l	#1,\3		; ytilestep = 1

		move.b	#OP_BGE,vertpatch  ; patch in a bge.s
		move.b	#OP_BLE,horizpatch ; patch in a ble.s

		move.w	xpartialdown(a0),xpartial(a0)
		move.w	ypartialup(a0),ypartial(a0)
		
		bra.s	.\@break

.\@third	cmpi.w	#DEG270,d0	; Angle>= 270ø?
		bhi.s	.\@fourth

		moveq.l	#-1,\2		; xtilestep = -1
		moveq.l	#-1,\3		; ytilestep = -1

		move.b	#OP_BLE,vertpatch  ; patch in a ble.s
		move.b	#OP_BLE,horizpatch ; patch in a ble.s

		move.w	xpartialdown(a0),xpartial(a0)
		move.w	ypartialdown(a0),ypartial(a0)

		bra.s	.\@break

.\@fourth	moveq.l	#1,\2		; xtilestep = 1
		moveq.l	#-1,\3		; ytilestep = -1

		move.b	#OP_BLE,vertpatch  ; patch in a ble.s
		move.b	#OP_BGE,horizpatch ; patch in a bge.s

		move.w	xpartialup(a0),xpartial(a0)
		move.w	ypartialdown(a0),ypartial(a0)
.\@break
		endm


**********************************
*
*  i32 macro fmul(u16 a,i32 b)
*
* Multiply a signed 16.16 fixed number by a 16bit fractional value
*
**********************************

fmul		macro
		move.\0	\2,d6	; Save 2nd operand
		mulu.w	\1,\2	; Multiply fraction

		lsr.\0	#FRACBITS,\2 ; Adjust
	
		swap.w	d6	; Muliply magnitude
		muls.w	\1,d6
		
		asl.\0	#FRACBITS,d6 ; Normalize
		add.\0	d6,\2
		
*		bvc.s	.\@vc
*		move.l	#$7fffffff,\2; Set b to ß in case of an overflow
.\@vc
		endm


**********************************
*
*  void WallRefresh()
*
* Render visible solid walls, push walls, doors
* Keep track of things currently 
*
**********************************

DEG90		=	$4000		; Angle constants
DEG180		=	$8000
DEG270		=	$C000
DEG360		=	$10000
ANGLES		=	DEG360

		rsreset		
pixx		rs.w	1	; Screen column
xpartial	rs.w	1
ypartial	rs.w	1
xpartialup	rs.w	1
xpartialdown	rs.w	1
ypartialup	rs.w	1
ypartialdown	rs.w	1
viewtx		rs.w	1	; Camera tile
viewty		rs.w	1
viewx		rs.l	1	; Camera x,y in 16.16
viewy		rs.l	1
tracevariables  ds.b   __RS

player.x	ds.w	1	; Camera x,y and angle
player.y	ds.w	1
gamestate.viewangle
		ds.w	1

doorposition	dc.b	128
ddelta		dc.b	1
		even


WallRefresh	lea.l	tracevariables(pc),a0
		pea.l	xscale			; Pixel -> Angle
		lea.l	Tilemap,a6			

		move.b  player.x+1(pc),xpartialdown+1(a0)
		move.w  #256,d0
		move.w  d0,d1
		sub.w	xpartialdown(a0),d0
		move.w  d0,xpartialup(a0)

		move.b  player.y+1(pc),ypartialdown+1(a0)
		sub.w	ypartialdown(a0),d1
		move.w  d1,ypartialup(a0)
		
		move.w	player.x(pc),d0	; Compute camera tile
		move.w	player.y(pc),d1
		move.w	d0,d2
		move.w	d1,d3
		lsr.w	#TILESHIFT,d0
		lsr.w	#TILESHIFT,d1
		move.w  d0,viewtx(a0)
		move.w  d1,viewty(a0)
	
		ext.l	d2		; Camera position -> 16.16
		ext.l	d3
		lsl.l	#FRACBITS,d2 
		lsl.l	#FRACBITS,d3
		movem.l	d2/d3,viewx(a0)


		clr.w	pixx(a0)	; pixx = 0

; Initialise variables for the raytrace
		
pixxloop	movea.l	(sp)+,a4
		move.w	gamestate.viewangle(pc),d2 ; Angle through current pixx
		add.w	(a4)+,d2
		pea.l	(a4)

		GetQuadrant d2,d0,d1 ; Check quadrant

		lsr.w	#SHORTTOANGLESHIFT-3,d2  ; Angle -> fines
		andi.b	#-8,d2
		
		lea.l	finetangens,a4
		movem.l (a4,d2.w),a2/a3	; xstep, ystep

		move.w	viewtx(a0),d2
		move.w	viewty(a0),d3
		add.w	d0,d2		; xtile = viewtx + xtielstep
		add.w	d1,d3		; ytile = viewty + ytielstep

		move.l	a2,d4		; xintercept, yintercept
		move.l	a3,d5
		fmul.l	ypartial(a0),d4
		fmul.l	xpartial(a0),d5
		
		add.l	viewx(a0),d4
		movea.l	d4,a4		; xintercept = viewx+ypartial*xstep[angle]
		add.l	viewy(a0),d5
		movea.l	d5,a5		; yintercept = viewy+xpartial*ystep[angle]

		swap.w	d4		; xspot = xintercept >> 16
		swap.w	d5		; yspot = yintercept >> 16



; Cast for vertical walls

vertcheck	cmp.w	d3,d5		; Compare yspot against ytile
vertpatch	bge.s	horizentry	; Patch opcode here

vertentry  	move.w	d2,d7		; Calculate tileoffset from xtile, yspot
		lsl.w	#6,d7
		or.w	d5,d7

		move.b	(a6,d7.w),d6	; tilehit = Tilemap[xtile, yspot]
		bne.w	HitVertWall	; Hit a vertical wall if !(tilehit = 0)

passvert	add.w	d0,d2		; xtile += xtilestep
		adda.l	a3,a5		; yintercept += ystep
		move.l	a5,d5
		swap.w	d5		; yspot = yintercept >> 16
		bra.s	vertcheck



; Cast for horizontal walls

horizcheck	cmp.w	d2,d4		; Compare xspot against xtile
horizpatch	bge.s	vertentry	; Patch opcode here

horizentry	move.w	d4,d7		; Calculate tileoffset from xspot, ytile
		lsl.w	#6,d7
		or.w	d3,d7

		move.b	(a6,d7.w),d6	; tilehit = Tilemap[xspot, ytile]
		bne.w	HitHorizWall	; Hit a horizontal wall if !(tilehit = 0)

passhoriz  	add.w	d1,d3 		; ytile += ytilestep
		adda.l  a2,a4		; xintercept += xstep
		move.l	a4,d4
		swap.w	d4		; xspot = xintercept >> 16
            	bra.s   horizcheck



nextpix		addq.w	#1,pixx(a0)	; Next pixel over
		move.w	xsize(pc),d0
		cmp.w	pixx(a0),d0
		bne.w	pixxloop

		addq.l	#4,sp		; Adjust stackpointer
		rts


		*!temporary!*
		section	data
sintable	=*+16384
finetangens	incbin	'temp\trig.tbl'	; Trigonometric tables

		section	text
xscale		ds.w	MAXX		; Angle scale factor for width of the screen