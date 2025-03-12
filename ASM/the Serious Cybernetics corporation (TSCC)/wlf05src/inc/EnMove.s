		rsreset		; Used by actor's motion
north		rs.l	1
northeast	rs.l	1
east		rs.l	1
southeast	rs.l	1
south		rs.l	1
southwest	rs.l	1
west		rs.l	1
northwest	rs.l	1
nodir		=	-1
dirtype		=	__RS+1


***********************************
*
*  void NewState(a0.l *Actor, d0.w state)
*
* Changes actor to a new state, setting ticcount to the max for that state
*
***********************************

		section	text
NewState	lea.l	states,a1	; Get the state record pointer
		adda.w	d0,a1

		move.w	d0,state(a0)	; Set the actor's state
		move.w	stictime(a1),tics(a0)	  ; Set the initial tick value
		move.l	sshapenum(a1),SprShape(a0); Set the current shape number
		rts


	ifeq	1
**********************************
*
*  void SelectDodgeDir(a0.l *Actor)
*	
* Attempts to choose and initiate a movement for actor that sends it towards
* the player while dodging
*		
**********************************

SelectDodgeDir	move.l	player.x(pc),d1	; dx = player.x - Actor->SprX
		sub.l	SprX(a0),d1
		move.l	d1,d2		; dy = player.y - Actor->SprY
		swap.w	d2


		; Arange 5 direction choices in order of preference
		; the four cardinal directions plus the diagonal straight towards
		; the player
		lea.l	.dirtry(pc),a2

		move.w	#east<<8|west,d3
		move.w	#north<<8|south,d4

		tst.w	d1
		bmi.s	.neg_dx		; dx>0?
		ror.w	#8,d3		; Then swap directions

.neg_dx		tst.w	d2		; dy>0?
		bmi.s	.neg_dy
		ror.w	#8,d4

.neg_dy		movep.w	d3,1(a2)	; Store
		movep.w	d4,2(a2)		

		; Randomize a bit for dodging
.rnd		bsr.w	w_rnd		; Swap directions if (w_rnd&1)
		lsr.b	d0
		bcc.s	.keep

		neg.w	d1
		bmi.s	*-2
		neg.w	d2
		bmi.s	*-2

		cmp.w	d2,d1		; abs(dx) > abs(dy)?
		bls.s	.keep

		move.l	1(a2),d0	; Swap directions
		ror.w	#8,d0
		swap.w	d0
		ror.w	#8,d0
		swap.w	d0
		move.l	d0,1(a2)

.keep		moveq.l	#0,d0
		move.b	1(a2),d0
		move.b	2(a2),d1
		add.w	d0,d0		; dirtry[1] * 8
		lsr.b	#2,d1		; += dirtry[2]
		add.b	d1,d0
		move.b	.diagonal(pc,d0.l),(a2)	; dirtry[0] = diagonal[dirtry[1]][dirtry[2]]


		moveq.l	#5-1,d5		; Try the directions until one works

.try_dir	move.b	(a2)+,d4
		bmi.s	.next		; == nodir?

		move.b	d4,dir(a0)

		movem.l	d5/a2,-(sp) **
		*bsr.w	TryWalk
		movem.l	(sp)+,d5/a2 **
		tst.b	d6		; Can I go this way? 
		beq.s	.next
		rts			; Yep! 

.next		dbra	d5,.try_dir	; All tries done? 

		;move.b	#nodir,dir(a0)		
		st.b	dir(a0)			; Stop the motion 
		bset.b	#FL_NOTMOVING,flags(a0)	; Kill the logic! 
		rts


.diagonal	dc.b	nodir,nodir,northeast,nodir,nodir,nodir,southeast,nodir	; East
		dc.b	nodir,nodir,nodir,nodir,nodir,nodir,nodir,nodir
		dc.b	northeast,nodir,nodir,nodir,northwest,nodir,nodir,nodir	; North
		dc.b	nodir,nodir,nodir,nodir,nodir,nodir,nodir,nodir
		dc.b	nodir,nodir,northwest,nodir,nodir,nodir,southwest,nodir	; West
		dc.b	nodir,nodir,nodir,nodir,nodir,nodir,nodir,nodir
	 	dc.b	southeast,nodir,nodir,nodir,southwest,nodir,nodir,nodir	; South
		dc.b	nodir,nodir,nodir,nodir,nodir,nodir,nodir,nodir

		ds.b	1
.dirtry		ds.b	5
	endc


**********************************
*
*  void SelectChaseDir(a0.l *Actor)
*	
* Attempts to choose and initiate a movement for an actor that sends
* it towards the player but doesn't try to dodge
*		
**********************************

SelectChaseDir	lea.l	.findpath+4*(9+4)(pc),a1

		move.l	SprX(a0),d0
		sub.l	player.x(pc),d0	; Which way to travel? 
	
		tst.w	d0		; dy>0?
		beq.s	.dx		; Select nodir if dy = 0
		bmi.s	.dy_mi

		lea.l	-3*4(a1),a1
		bra.s	.dx

.dy_mi		lea.l	+3*4(a1),a1

.dx		swap.w	d0		; dx>0?
		tst.w	d0
		beq.s	.rnd		; Select nodir if dx = 0
		bmi.s	.dx_mi

		addq.l	#4,a1
		bra.s	.rnd

.dx_mi		subq.l	#4,a1

.rnd		moveq.l	#4,d2		; Randomly determine direction of search	
		bsr.w	w_rnd
		lsr.b	d0		; w_rnd&1 ?
		beq.s	.keep
		neg.l	d2

.keep		lea.l	Actorat,a6	; Get actor tile
		move.w	SprX(a0),d0
		clr.b	d0
		lsr.w	#2,d0
		add.b	SprY(a0),d0
		adda.w	d0,a6

		lea.l	Actors,a5
		add.w	d0,d0
		add.w	d0,d0
		adda.w	d0,a5
		

		moveq.l	#9-1,d6		; 9 tiles to test

.search		move.l	(a1),a2		; Tiles to test. Note: i might have 2 diffrent tiles
		jmp	(a2)		; for the diagonal movements

.next		adda.l	d2,a1		; Next record
		dbra	d6,.search

.pause		st.b	dir(a0)		; Can't move, I give up 
		bset.b	#FL_NOTMOVING,flags(a0)
		rts



.findpath	
	rept	3
		dc.l	.northwest
		dc.l	.north
		dc.l	.northeast
		dc.l	.west
		dc.l	.next
		dc.l	.east
		dc.l	.southwest
		dc.l	.south
		dc.l	.southeast
	endr


		; Go N,S,E,W
.north		moveq.l	#-1,d0		; Goal tile (relative)
		moveq.l	#north,d1	; Newdir
		bra.s	.checkside

.east		moveq.l	#-64,d0
		moveq.l	#east,d1
		bra.s	.checkside

.south		moveq.l	#+1,d0
		moveq.l	#south,d1
		bra.s	.checkside

.west		moveq.l	#+64,d0
		moveq.l	#west,d1

.checkside	********
		lea.l	(a6,d0.w),a4
		move.b	-64*64(a4),d5
		bclr.l	#TI_DOOR,d5
		beq.s	.nodoor


		
		lea.l	doors,a4
		ext.w	d5
		andi.w	#63,d5
		lsl.w	#3,d5
		adda.w	d5,a4

		move.b	action(a4),d5	; Has the door fully opened up yet?
		beq.s	.nodoor

		movem.w	d0-d1,-(sp)

		OpenDoor a4,d5		; Open it

		movem.w	(sp)+,d0-d1

		ori.b	#(1<<FL_WAITDOOR)|(1<<FL_NOTMOVING),flags(a0)
		rts
		********

.nodoor		moveq.l	#(1<<TI_BLOCKMOVE)|(1<<TI_THING),d5
		and.b	(a4),d5		; Anything blocking our motion?
		bne.w	.next
		bra.s	.new_dir


		; Diagonal moves
.northwest	moveq.l	#-1+64,d0	; Goal tile (relative)
		moveq.l	#+64,d3		; In-between tile
		moveq.l	#northwest,d1	; Newdir
		bra.s	.checkdiag

.northeast	moveq.l	#-1-64,d0
		moveq.l	#-64,d3
		moveq.l	#northeast,d1
		bra.s	.checkdiag

.southwest	moveq.l	#+1+64,d0
		moveq.l	#+64,d3
		moveq.l	#southwest,d1
		bra.s	.checkdiag

.southeast	moveq.l	#+1-64,d0
		moveq.l	#-64,d3
		moveq.l	#southeast,d1

.checkdiag	moveq.l	#(1<<TI_BLOCKMOVE)|(1<<TI_THING),d5
		and.b	(a6,d0.w),d5
		bne.w	.next
		moveq.l	#(1<<TI_BLOCKMOVE)|(1<<TI_THING),d5
		and.b	(a6,d3.w),d5
		bne.w	.next


.new_dir	andi.b	#~((1<<FL_WAITDOOR)|(1<<FL_NOTMOVING)),flags(a0)	; I'm not waiting and I'm moving 

		move.b	d1,dir(a0)		; Save my new direction
		move.w	#TILEGLOBAL,distance(a0); Move across 1 whole tile

		; Place goal marker
		adda.w	d0,a6
		bset.b	#TI_THING,(a6)

		rts



**********************************
*
*  void MoveActor(a0.l *Actor, d0.w move)
*
* Moves actor <move> global units in Actor->dir direction
* Actors are not allowed to move inside the player
* Does NOT check to see if the move is tile map valid
*		
**********************************

MoveActor	movem.w	SprX(a0),d2/d3	; Get the x and y 

		moveq.l	#0,d1		; Move to the new x,y 
		move.b	dir(a0),d1
		bmi.s	.return

		movea.l	.move_jmp(pc,d1.l),a1
		jmp	(a1)

.move_jmp	dc.l	.north		; Jump table for quick
		dc.l	.northeast	; case selection
		dc.l	.east
		dc.l	.southeast
		dc.l	.south
		dc.l	.southwest
		dc.l	.west
		dc.l	.northwest


.northeast	sub.w	d0,d2		; x -= move
.north		sub.w	d0,d3		; y -= move
		bra.s	.break
		
.southeast	add.w	d0,d3		; y += move
.east		sub.w	d0,d2		; x -= move
		bra.s	.break
	
.southwest	add.w	d0,d2		; x += move
.south		add.w	d0,d3		; y += move
		bra.s	.break;
		
.northwest	sub.w	d0,d3		; y -= move
.west		add.w	d0,d2		; x += move


.break		; Check to make sure it's not moving on top of player
		move.w	#MINACTORDIST*2,d6
		movem.w	player.x(pc),d4/d5

		sub.w	d2,d4		; abs(player.x - x)
		neg.w	d4
		bmi.s	*-2
		cmp.w	d6,d4		; <MINACTORDIST?
		bhi.s	.valid

		sub.w	d3,d5		; abs(player.y - y)
		neg.w	d5
		bmi.s	*-2
		cmp.w	d6,d5		; <MINACTORDIST?
		bhi.s	.valid
.return		rts

.valid		sub.w	d0,distance(a0)	; Remove the distance 

		; Remove the old actormarker
		lea.l	Actors,a5
		lea.l	Tilemap,a6

		move.w	SprX(a0),d0
		clr.b	d0
		lsr.w	#2,d0
		add.b	SprY(a0),d0
		lea.l	(a6,d0.w),a4

		subq.b	#1,(a4)		; Tilemap[tilex][tiley] ~= TI_ACTOR
		bclr.b	#TI_THING,64*64(a4)
		add.w	d0,d0
		add.w	d0,d0
		clr.l	(a5,d0.w)	; Actors[tilex][tiley] = NULL

		movem.w	d2/d3,SprX(a0)	; Save the new x,y

		; Place new actor marker
		lsr.w	#6,d3
		move.b	d3,d2
		lsr.w	#2,d2

		adda.w	d2,a6
		addq.b	#1,(a6)
		bset.b	#TI_THING,64*64(a6)
		add.w	d2,d2
		add.w	d2,d2
		move.l	a0,(a5,d2.w)	; Actors[goalx][goaly] = &Actor
		rts