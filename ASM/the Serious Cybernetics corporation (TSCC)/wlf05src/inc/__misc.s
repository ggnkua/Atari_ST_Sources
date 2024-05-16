		section text
ShowTitle	lea.l	titlescreen,a0	; Decrunch image
		bsr.w	ShowPic
		
		lea.l	titlepal,a0	; Fade in
		bsr.w	FadeTo
		
		move.l  #4*60,$466.w
		
		bsr.w	SetupScalers	; Compile scalers
		bsr.w	IO_SetUpDisplay
		
		
		**** temporary ****
		; Build actorat and door records and load in all wall shapes

		lea.l	Tilemap+64*64,a0

		move.w	#64*64-1,d0

.spawnloop	move.b	-(a0),d1	; Get tile
		bclr.l	#7,d1		; Is it blocking my motion?
		bne.s	.block

		clr.b	(a0)
		bra.s	.next

.block		bclr.l	#6,d1		; Is this a door?
		beq.s	.wall

		clr.b	(a0)
		bra.s	.next

.wall		move.b	d1,(a0)		; Mark as blocking my motion/sight
		ori.b	#(1<<TI_BLOCKMOVE)|(1<<TI_BLOCKSIGHT),64*64(a0)

		movem.l	d0/a0,-(sp)
		bsr.w	LoadWallShape	; Mark the wall shape
		movem.l	(sp)+,d0/a0

.next		dbra	d0,.spawnloop


		; Register the permanent shapes (door tiles)

		moveq.l	#5-1,d7

.permanent	moveq.l	#32,d1
		add.b	d7,d1
		move.w	d7,-(sp)
		bsr.w	LoadWallShape
		move.w	(sp)+,d7
		dbra	d7,.permanent


		lea.l	DoorShapes+5,a0
		lea.l	WallHits,a1

		moveq.l	#5-1,d7

.doorshapes	moveq.l	#32,d0
		add.b	d7,d0
		move.b	-1(a1,d0.w),-(a0)
		dbra	d7,.doorshapes


		; Translate shape indexes

		lea.l	Tilemap+64*64,a0
		moveq.l	#0,d1

		move.w	#64*64-1,d0

.translate	move.b	-(a0),d1
		beq.s	.cont
		move.b	-1(a1,d1.l),(a0); Translate WallHits[]

.cont		dbra	d0,.translate


		lea.l	WallHits,a0
		move.l	#256,d0
		moveq.l	#0,d1
		bsr.w	ClearBlock


		; Convert item records to big endian
		lea.l	tempmap+mnumspawn,a0

		moveq.l	#4-1,d1

.bigendian	move.w	(a0),d0
		ror.w	#8,d0
		move.w	d0,(a0)+
		dbra	d1,.bigendian

		lea.l	tempmap,a0
		bsr.w	SpawnThings	; Spawn all my items


		; Translate static shape indexes

		lea.l	Statics+SprShape,a0
		lea.l	WallHits,a1
		lea.l	StaticArtIndex,a2

		move.w	NumStatics(pc),d0
		bmi.s	.continue

.statics	move.l	(a0),d1		; Get the index
		move.b	(a1,d1.l),d1	; &shape = StaticArtIndex[WallHits[index]]
		lsl.w	#2,d1
		move.l	(a2,d1.l),(a0)

		lea.l	thing_t(a0),a0	; Next record
		dbra	d0,.statics

.continue	*******************
		
		
.wait		tst.l   $466.w		; 5 seconds passed?
		bpl.s  .wait

		bra.w	FadeToBlack	; Fade out



		*** Temporary procedure!!

***********************************
*
*  GetBonus(a0.l &Actorat[tile+1])
*
* Picks up the bonus item from the current tile-1
*		
***********************************

GetBonus	; Remove the item marker
		clr.b	-(a0)		; Actorat[tile-1] = NULL
		clr.b	-64*64(a0)	; Tilemap[tile-1] = NULL

		move.l	a0,-(sp)
		movea.l	SND_BONUS(pc),a0	; Play the door sound
		bsr.w	PlaySound
		movea.l	(sp)+,a0

		rts


		*** Temporary includes
		section data
titlescreen	incbin	'temp\gfx\title.lz'	; Title picture
		even
titlepal	incbin	'temp\gfx\title.rst'
		dc.w	-1
		
		
		section text
ShowPanel	lea.l	panel,a0		; Depack image
		bsr.w	ShowPic
		
		lea.l	panelpal,a0
		bra.w	FadeTo
	

		section	data
panel		incbin	'temp\gfx\panel.lz'	; Game panel
		even
panelpal	incbin	'temp\gfx\panel.rst'
		dc.w	-1

__myweapon	incbin	'temp\gfx\weapon.bin'	; Weapon
tempmap		dcb.b	64*64,0
		incbin	'temp\map.01'		; Spawn list
		even

Tilemap		incbin	'temp\e01m01.map'	; Tile based map (64 x 64)
Actorat		dcb.b	4096,0			; Collision & actor data
