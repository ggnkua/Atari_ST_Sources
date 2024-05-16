**********************************
*
*  bool d0.b TryMove()
*
* See if players current position is ok
* returns True (D0.b = -1) if move ok
* All coordinates are stored in 8.8 fractions (8 bits integer, 8 bits fraction)
*
**********************************

PLAYERSIZE	=	98	; radius of player in 8.8 fixed point

xl		equr	d1
xh		equr	d2
yl		equr	d3
yh		equr	d4


		section	text
TryMove		moveq.l	#PLAYERSIZE,d5

		move.w	xl,xh		; Make the rect for the player in tiles
		move.w	yl,yh

		sub.w	d5,xl
		lsr.w	#FRACBITS,xl	; xl = (CheckX - PLAYERSIZE)>>FRACBITS
		add.w	d5,xh
		lsr.w	#FRACBITS,xh	; xh = (CheckX + PLAYERSIZE)>>FRACBITS

		sub.w	d5,yl
		lsr.w	#FRACBITS,yl	; yl = (CheckY - PLAYERSIZE)>>FRACBITS
		add.w	d5,yh
		lsr.w	#FRACBITS,yh	; yh = (CheckY + PLAYERSIZE)>>FRACBITS

	
; Check for solid walls/items and actors

		lea.l	Actorat,a1
		lea.l	Actors,a3
		
		moveq.l	#0,d0		; Return FALSE in case a wall/actor is blocking us

		move.w	xl,d7
		lsl.w	#6,d7
		add.w	yl,d7
		adda.w	d7,a1
		
		add.w	d7,d7
		add.w	d7,d7
		adda.w	d7,a3
		
		move.w	yh,d5
		sub.w	yl,d5
		swap.w	d5

		move.l	#MINACTORDIST<<16|MINACTORDIST,d3
		move.w	#MINACTORDIST*2,d4

		move.w	xh,d5
		sub.w	xl,d5
		
.x_scan		movea.l	a1,a0
		movea.l	a3,a2

		move.l	d5,d6
		swap.w	d6

.y_scan 	move.b	(a0)+,d7	; Test the tile
		btst.l	#TI_GETABLE,d7	; Can I get this
		bne.w	GetBonus	; Get the item

		btst.l	#TI_BLOCKMOVE,d7; Motion blocked?
		bne.s	.return		; Can't go this way!

		move.l	(a2)+,d7	; Actor here?
		beq.s	.next

		movea.l	d7,a4		; Motion blocked?
		btst.b	#TI_BLOCKMOVE,actornum(a4)
		beq.s	.next

		move.l	player.x(pc),d7
		sub.l	SprX(a4),d7
		add.l	d3,d7

		cmp.w	d4,d7
		bcc.s	.return		; I hit the actor!
		swap.w	d7
		cmp.w	d4,d7
		bcc.s	.return
		
.next		dbra	d6,.y_scan	; Scan the y

	
		lea.l	64(a1),a1
		lea.l	64*4(a3),a3
		dbra	d5,.x_scan	; Scan the x

		st.b	d0

.return		rts




**********************************
*
*  void macro ClipMove(xmove.w, ymove.w)
*
* Clip the player's motion
* I will also try to use as much motion as I have
*		
**********************************

ClipMove	macro	xmove, ymove

		move.w	\1,d5		; Save the current motion offset
		move.w	\2,d6
	
		movea.w	d5,a5		; Save old offsets
		movea.w	d6,a6


; Try complete move
	
		add.w	player.x(pc),d5	; Can I move here?
		add.w	player.y(pc),d6
		
		move.w	d5,xl
		move.w	d6,yl
		bsr.w	TryMove

		tst.b	d0
		beq.s	.\@horizontal

		move.w	a5,d5
		move.w	a6,d6
		add.w	d5,player.x	; Save it
		add.w	d6,player.y

		bra.s	.\@return	; Exit now!


; Try horizontal motion 

.\@horizontal	move.w	a5,d5		; Restore
	
		add.w	player.x(pc),d5	; Test move
		
		move.w	d5,xl
		move.w	player.y(pc),yl
		bsr.w	TryMove

		tst.b	d0
		beq.s	.\@vertical

		move.w	a5,d5
		add.w	d5,player.x	; Set new x

		bra.s	.\@return


; Try just vertical

.\@vertical	move.w	a6,d6		; Restore

		add.w	player.y(pc),d6	; Test move
		
		move.w	player.x(pc),xl
		move.w	d6,yl
		bsr.w	TryMove

		tst.b	d0
		beq.s	.\@return

		move.w	a6,d6
		add.w	d6,player.y	; Set new y

.\@return
		endm




**********************************
*
*  void ControlMovement()
*
* Changes the player's angle and position
*		
**********************************

TURNSPEED	=	64	; Turning while moving
FASTTURN	=	96	; Turning in place
WALKSPEED	=	18
RUNSPEED	=	27


bt_run		=	$2a	; left shiftkey
bt_east		=	$4d	; right turn
bt_west		=	$4b	; left turn
bt_north	=	$48	; walk forward
bt_south	=	$50	; walk backwards
bt_strafe	=	$38	; alternate (strafe)
bt_use		=	$39	; use
bt_quit		=	$01	; quit key

playermoving	dc.b	0
		even

xmove		equr	d0	; Register equates
ymove		equr	d1
turn		equr	d2
mov		equr	d3

mlimit		=	250	; Clamp motion on slow computers


ControlMovement	clr.b	playermoving	; No motion (Yet)

		moveq.l	#0,xmove	; Init my deltas
		moveq.l	#0,ymove

	
		lea.l	IO_ButtonState(pc),a0
		lea.l	_Tics(pc),a1

		tst.b	bt_run(a0)
		bne.s	.fast

		movem.w	TicCount.TURNSPEED(a1),turn/mov	; Moderate speed turn	(avoiding mulu.w here)

		bra.s	.moderate

.fast		movem.w	TicCount.FASTTURN(a1),turn/mov	; Really fast turn
		
.moderate	move.l	d0,(a1)+	; clear TicCounters
		move.l	d0,(a1)

		lsr.w	#1,mov

		*cmpi.w	#mlimit,mov	; Do not let motion delta overflow on slow computers
		*bls.s	.keep		; *bugfix 2005*
		*move.w	#mlimit,mov

		
; turning	

.keep		move.w	gamestate.viewangle(pc),d5
	
		tst.b	bt_strafe(a0)	; Strafe key pressed ?
		bne.s	.skip_turn	; Skip turning section if so
		
		tst.b	bt_west(a0)
		beq.s	.not_west

		sub.w	turn,d5		; Turn left
		
.not_west	tst.b	bt_east(a0)
		beq.s	.not_east

		add.w	turn,d5		; Turn right
		
.not_east	move.w	d5,gamestate.viewangle


.skip_turn	lsr.w	#SHORTTOANGLESHIFT-2,d5 ; Convert to fines
		andi.b	#-4,d5

		lea.l	sintable,a1	; get sin,cos[viewangle]
		movem.w	(a1,d5.w),d4/d5
		move.w	d4,viewsin
		move.w	d5,viewcos

	
		
; Handle all strafe motion

		tst.b	bt_strafe(a0)	; Side to side motion (Strafe mode) ?
		beq.s	.dont_strafe_right
		tst.b	bt_east(a0)
		beq.s	.dont_strafe_right

		sub.w	d4,xmove	; Rotate movement triangle by
		move.w	d5,ymove	; 90 degrees

		bra.w	.move_ahead
		
.dont_strafe_right
	
		tst.b	bt_strafe(a0)
		beq.s	.dont_strafe_left
		tst.b	bt_west(a0)
		beq.s	.dont_strafe_left

		move.w	d4,xmove
		sub.w	d5,ymove

		bra.s	.move_ahead
		
.dont_strafe_left
		

		
; Handle all forward motion (mouse movement still needs to be added !)

		tst.b	bt_north(a0)	; Move ahead?
		beq.s	.dontmov_ahead

		move.w	d4,ymove	; Move ahead
		move.w	d5,xmove

.dontmov_ahead

		tst.b	bt_south(a0)	; Reverse direction
		beq.s	.dontmov_back

		sub.w	d4,ymove	; y motion
		sub.w	d5,xmove	; x motion

.dontmov_back
		tst.w	xmove		; Any motion?
		bne.s	.move_ahead
		tst.w	ymove	
		bne.s	.move_ahead

		bra.w	.return

.move_ahead	cmpi.w	#TILEGLOBAL,mov
		blt.s	.dont_force_speed
		
		move.w	#TILEGLOBAL-1,mov ; force maximum speed
		

.dont_force_speed
		muls.w	mov,xmove	; Movement deltas
		muls.w	mov,ymove	
		asr.l	#FRACBITS,xmove
		asr.l	#FRACBITS,ymove

		ClipMove xmove,ymove	; Move ahead (Clipped)	

.return		rts