*********************************
*
*	Rules for door operation
*
* door->position holds the amount the door is open, ranging from 0 to TILEGLOBAL-1
*
* The number of doors is limited to 64 because various fields are only 6 bits
*
* Open doors conect two areas, so sounds will travel between them and sight
* will be checked when the player is in a connected area.
*
* areaconnect has a list of connected area #'s, used to create the table areabyplayer
*
* Every time a door opens or closes the areabyplayer matrix gets recalculated.
* An area is True if it connects with the player's current spor.
*
*********************************



*********************************
*
*	Static door struct
*	
*********************************

MAXDOORS	=	64
OPENTICS 	=	500


DR_OPEN		=	0	; Door is fully open
DR_CLOSED	=	1	; Door is fully closed
DR_OPENING	=	2	; Door is opening
DR_CLOSING	=	3	; Door is closing
DR_WEDGEDOPEN	=	4	; Door is permenantly open

		rsreset
action		rs.b	1	; Action code (See above) for door
position	rs.b	1	; Pixel position of door (0=Closed)
ticcount	rs.w	1	; Time delay before automatic closing
tilespot	rs.w	1	; Tile of the door
info		rs.w	1	; Texture of the door (Steel,Elevator)

door_t		=	__RS	; Length of door type


	ifeq	1
		rsreset
Area1		rs.b	1	; First area
Area2		rs.b	1	; Second area

connect_t	=	__RS
	endc

		section	bss
doors		ds.b	MAXDOORS*door_t

		*temporary*
*		include	'temp\doors.s'

		section	text
numdoors	dc.w	-1


*********************************
*
*  void macro OpenDoor(u32 *Door,u8 Action)
*
* Start a door opening
*	
*********************************

OpenDoor	macro

		;cmpi.b	#DR_OPEN,\2	; Already open?
		tst.b	\2
		bne.s	.\@door_not_open

		clr.w	ticcount(\1)	; Reset open time (Keep open)
		bra.s	.\@exit

.\@door_not_open
		move.b	#DR_OPENING,action(\1)	; start it opening
.\@exit					; The door will be made passable when it is totally open
		endm



*********************************
*
*  void macro CloseDoor(u32 *Door)
*
* Start a door closing
*
*********************************

TilePtr		equr	d7

CloseDoor	macro

; Don't close on anything solid

		lea.l	Actorat,a6	; Get pointer to tile map
		move.w	tilespot(\1),TilePtr
		adda.w	TilePtr,a6
	

		cmpi.b	#DR_OPENING,action(\1) ; In the middle of opening?
		beq.s	.\@opening
			
; Don't close on an actor or bonus item
	ifeq	1
		tile = TilePtr[0];		/* What's the tile? */
		if (tile & TI_BODY) {
			door->action = DR_WEDGEDOPEN;	/* bodies never go away */
			return;
		}
		if (tile & (TI_ACTOR | TI_GETABLE) ) {	/* Removable? */
			door->ticcount = 60;		/* wait a while before trying to close again */
			return;
		}
	endc

		btst.b	#TI_THING,(a6)
		bne.s	.\@return


; Don't close on the player

		move.w	player.x,d6
		move.w	TilePtr,d5
		add.w	d5,d5		; Faster than lsl.w #2,d5
		add.w	d5,d5
		move.b	#$80,d5
		sub.w	d5,d6
		
.\@abs_1	neg.w	d6
		bmi.s	.\@abs_1
		
		cmpi.w	#$82+PLAYERSIZE,d6
		bgt.s	.\@opening
		


		move.w	player.y,d6
		move.w	TilePtr,d5
		andi.b	#63,d5
		lsl.w	#8,d5
		move.b	#$80,d5
		sub.w	d5,d6
		
.\@abs_2	neg.w	d6
		bmi.s	.\@abs_2
		
		cmpi.w	#$82+PLAYERSIZE,d6
		ble.s	.\@return	; It's touching the player!
		



.\@opening	move.b	#DR_CLOSING,action(\1)	; Close the door
		
		; make the door space a solid tile
		ori.b	#(1<<TI_BLOCKMOVE)|(1<<TI_BLOCKSIGHT),(a6)

		move.l	a0,-(sp)
		movea.l	SND_OPENDOOR(pc),a0
		bsr.w	PlaySound
		movea.l	(sp)+,a0
.\@return
		endm



*********************************
*
*  void macro OperateDoor(u16 Dooron)
*
* Open or Close a door (Press space at a door)
*
*********************************

OperateDoor	macro
		lea.l	doors,a0	; Which door?
		adda.w	\1,a0

		
	ifeq	1
	type = door->info>>1;	/* Get the door type */
	
	if ( (type==1 && !(gamestate.keys&1)) || (type==2 && !(gamestate.keys&2)) ) {
		PlaySound(SND_LOCKEDDOOR);		/* The door is locked */
		return;	
	}
	endc


		move.b	action(a0),d1
	
		;cmpi.b	#DR_OPEN,d1
		;tst.b	d1
		beq.s	.\@close_door
	
		cmpi.b	#DR_CLOSED,d1
		beq.s	.\@open_door

		cmpi.b	#DR_CLOSING,d1
		beq.s	.\@open_door

		cmpi.b	#DR_OPENING,d1
		bne.s	.\@break

.\@close_door	CloseDoor a0	; Close the door
		bra.s	.\@break

.\@open_door	OpenDoor a0,d1	; Open the door
.\@break
		endm



*********************************
*
*  void macro DoorOpen(u32 *Door)
*
* Close the door after a few seconds
*
*********************************

DoorOpen	macro
		move.w	ticcounter(pc),d0
		add.w	d0,ticcount(\1)		; Inc the tic value
	
		cmpi.w	#OPENTICS,ticcount(\1)	; Time up?
		blt.s	.\@exit

		move.w	#OPENTICS-1,ticcount(\1) ; So if the door can't close it will keep trying
		CloseDoor \1			 ; Try to close the door

.\@exit
		endm



*********************************
*
*  void macro DoorOpening(u32 *Door)
*
* Step the door animation for open, mark as DR_OPEN if all the way open
*	
*********************************

DoorOpening	macro
		moveq.l	#0,d0	
		move.b	position(\1),d0	; Get the pixel position

		bne.s	.\@not_closed	; Fully closed?

		move.l	a0,-(sp)
		movea.l	SND_OPENDOOR(pc),a0	; Play the door sound
		bsr.w	PlaySound
		movea.l	(sp)+,a0
		
.\@not_closed


; Slide the door open a bit

		add.w	ticcounter(pc),d0	; Move the door a bit

		cmpi.w	#TILEGLOBAL-1,d0	; Fully open?
		blt.s	.\@not_opened


		; Door is all the way open

		moveq.l	#TILEGLOBAL-1,d0	; Set to maximum
		clr.w	ticcount(\1)		; Reset the timer for closing

		;move.b	#DR_OPEN,action(\1)	; Mark as open
		clr.b	action(\1)

		lea.l	Actorat,a6		; Mark as enterable
		adda.w	tilespot(\1),a6
		andi.b	#~(1<<TI_BLOCKMOVE)|(1<<TI_BLOCKSIGHT),(a6)


.\@not_opened	move.b	d0,position(\1)		; Set the new position
		endm



*********************************
*
*  void macro DoorClosing(u32 *Door)
*
* Step the door animation for close,
* mark as DR_CLOSED if all the way closed
*
*********************************

DoorClosing	macro

		moveq.l	#0,d0
		move.b	position(\1),d0
		
		sub.w	ticcounter(pc),d0	; Close a little more

		bgt.s	.\@not_closed		; Will I close now?

		moveq.l	#0,d0			; Mark as closed 
		move.b	#DR_CLOSED,action(\1)	; It's close


.\@not_closed	move.b	d0,position(\1)	; Set the new position
		endm



*********************************
*
*  void MoveDoors()
*
* Process all the doors each game loop
*
*********************************

MoveDoors	move.w	numdoors(pc),d2		; How many doors to scan?
		bmi.w	.exit			; Any doors at all?
	
		lea.l	doors,a1		; Pointer to the first door


.process_doors	move.b	action(a1),d3		; Call the action code


		;cmpi.b	#DR_OPEN,d3		; Check to close the door
		;tst.b	d3
		bne.s	.dont_open

		DoorOpen a1
		bra.s	.break


.dont_open	cmpi.b	#DR_OPENING,d3		; Continue the door opening
		bne.s	.not_opening
		
		DoorOpening a1
		bra.s	.break


.not_opening	cmpi.b	#DR_CLOSING,d3		; Close the door
		bne.s	.break

		DoorClosing a1

.break		addq.l	#door_t,a1		; Next pointer
		;lea	door_t(a1),a1
		
		dbra	d2,.process_doors	; Repeat until all doors are done

.exit		rts