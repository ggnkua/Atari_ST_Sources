
PWALLSPEED	=	4		; Opening/closing speed in micropixels
					; Used by spawning and wall pushing

CD_NORTH	=	0		; Face north
CD_EAST		=	1		; Face east
CD_SOUTH	=	2
CD_WEST		=	3



*********************************
*
*	Pushwall state struct
*
*********************************

		rsreset
pwallx		rs.b	1		; The tile the pushwall edge is in now
pwally		rs.b	1
pwalldir	rs.b	1
pwallcount	rs.b	1		; Blocks still to move (Distance)
pwallpos	rs.w	1		; Amount a pushable wall has been moved in it's tile
pwallcheckx	rs.b	1		; the tile it will be in next
pwallchecky	rs.b	1
pushwall_t	=	__RS

		section	bss
PushWallRec	ds.b	pushwall_t	; Record for the single pushwall in progress




		section	text

*********************************
*
*  void macro PushWallOne()
*
* Mark the dest tile as blocked and begin a push wall sequence
* uses pwallx,pwally,pwalldir
*
*********************************

PushWallOne	macro
		lea.l	PushWallRec,a0

		move.w	pwallx(a0),pwallcheckx(a0)
		move.b	pwalldir(a0),d7

		;cmpi.b	#CD_NORTH,d7
		bne.s	.\@not_north
		addq.b	#1,pwallchecky(a0)
		bra.s	.\@break

.\@not_north	cmpi.b	#CD_EAST,d7
		bne.s	.\@not_east
		addi.w	#1<<6,pwallcheckx(a0)
		bra.s	.\@break

.\@not_east	cmpi.b	#CD_SOUTH,d7
		bne.s	.\@not_south
		subq.b	#1,pwallchecky(a0)
		bra.s	.\@break

.\@not_south	cmpi.b	#CD_WEST,d7
		bne.s	.\@break
		subi.w	#1<<6,pwallcheckx(a0)
	
.\@break	lea.l	Actorat,a1

		move.w	pwallcheckx(a0),d7
		ori.b 	#(1<<TI_BLOCKMOVE)|(1<<TI_BLOCKSIGHT),(a1,d7.w)
	
		endm


*********************************
*
*  void macro PushWall(u16 tile, u16 direction)
*
* Initiate a pushwall sequence
*
*********************************

PushWall	macro

		movea.l	SND_PWALL(pc),a0
		bsr.w	PlaySound
		
		lea.l	PushWallRec,a6

		move.w	\1,(a6)+	; Save the tile
		move.b	\2,(a6)+	; Save the wall direction

		PushWallOne		; Initiate the animation
		
		move.b	#2,(a6)+	; Move two cells

;		addq.w	#1,gamestate.secretcount ; Secret area found

		move.w	#PWALLSPEED/2,(a6)	 ; Begin the move

		endm



*********************************
*
*  void MovePWalls()
*
* Operate active push wall
*
*********************************

MovePWalls	lea.l	PushWallRec,a2

		tst.b	pwallcount(a2)	; Any walls to push?
		beq.w	.break		; Nope, get out


		move.w	ticcounter(pc),d0	; Move the wall a little
		add.w	d0,pwallpos(a2)

		cmpi.w	#256,pwallpos(a2)	; Crossed a tile yet?
		blt.w	.break			; Exit now

		subi.w	#256,pwallpos(a2)	; Mark as crossed
	

; the tile can now be walked into
	
		lea.l	Actorat,a3	; The movable block is gone
		lea.l	Tilemap,a4

		move.w	pwallx(a2),d0
		andi.b	#~((1<<TI_BLOCKMOVE)|(1<<TI_BLOCKSIGHT)|(1<<TI_PUSHWALL)),(a3,d0.w)

		move.b	(a4,d0.w),d2	; Save and remove
		clr.b	(a4,d0.w)	; the segment


		subq.b	#1,pwallcount(a2)  ; Been pushed 2 blocks?
		bne.s	.push


		move.w	pwallcheckx(a2),d0 ; Push the last record and
		move.b	d2,(a4,d0.w)	   ; mark as static segment
		
		ori.b	#(1<<TI_BLOCKMOVE)|(1<<TI_BLOCKSIGHT),(a3,d0.w)

		move.w	pwallcheckx(a2),pwallx(a2)

		movem.l	d0-a6,-(sp)

		movea.l	SND_PWALL(pc),a0	; Stop the wall sound
		bsr.w	StopSound
		
		movea.l	SND_PWALL2(pc),a0	; Play the wall stop sound
		bsr.w	PlaySound

		movem.l	(sp)+,d0-a6
		
		bra.s	.break		; Don't do this anymore!


	
.push		move.w	pwallcheckx(a2),d0 ; Set the tile to the next cell
				
		move.b	d2,(a4,d0.w)
		ori.b	#(1<<TI_BLOCKMOVE)|(1<<TI_BLOCKSIGHT)|(1<<TI_PUSHWALL),(a3,d0.w)

		move.w	pwallcheckx(a2),pwallx(a2)

		PushWallOne		; Push one more record

.break		rts