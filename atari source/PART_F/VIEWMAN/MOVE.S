*
*	MOVE.S
*
	.include	"equates.s"
*
	.text
*
*
***********************************************
;
; d0 - x mouse position
; d1 - y mouse position
*
DaveButton:
*
	bclr.b	#1,BUT_STATE+1
	bne	lib_sel
	bclr.b	#0,BUT_STATE+1
	bne	wor_sel
nolfbut:
	rts
*
*
*
*   We call this every time we start with a down mouse button..
*
butninit:
	clr.w	keyz
	clr.w	grid		;start out of grid mode
*
	move.w	#MouseOff,d0
	bsr	Graf_Mouse		;turn off the mouse
*
	move.l	mouseptr,a0		;get mouse ptr
	movem.w	(a0),d0-d1		;d0 = xpos, d1 = ypos
	movem.w	d0-d1,mousex		;save when we restore
clipinit:
	lea	wstruct+xoffset,a5
	movem.w	wx(a5),d0-d1
	move.w	d0,d2
	move.w	d1,d3
*
	add.w	wwidth(a5),d2
	subq.w	#1,d2		;check window right-edge beyond screen
	cmp.w	form_width,d2
	ble	butixok
	move.w	form_width,d2
butixok:
	addq.w	#1,d2
*
	add.w	wheight(a5),d3
	subq.w	#1,d3		;check window bottom-edge beyond screen
	cmp.w	form_height,d3
	ble	butiyok
	move.w	form_height,d3
butiyok:
	addq.w	#1,d3
	movem.w	d0-d3,xmin_clp
	movem.w	d0-d3,Mclpxmn	;init motion clip variables to window
*
	movem.w	wwidth(a5),d0-d1
	lsr.w	#1,d0
	lsr.w	#1,d1
	add.w	wx(a5),d0	;mouse relative positioning
	add.w	wy(a5),d1	;needs a safe place--
	movem.w	d0-d1,relcentx	;put it smack in the center of window
	move.l	mouseptr,a0
	move.l	relcentx,(a0)	;put rel mouse at a nice place
*	
	movem.w	mousex,d0-d1
*
	rts
*
*
*
*  Left button has gone down--select an existing item from the world
*
wor_sel:
	movem.l	a0-a6/d0-d7,-(sp)
*
	bsr	butninit
*
*  d0 = mousex, d1 = mousey on screen..
*
	sub.w	wx(a5),d0
	add.w	xoffset(a5),d0	;adjust for world co-ords
	sub.w	wy(a5),d1
	add.w	yoffset(a5),d1
*
*  Search the worldblk for the highest priority object
*   whose rectangle falls within the mouse position
*
	cmp.w	w_wid(a5),d0	;are we right of the world
	bge	wor_selx	;br if so
	cmp.w	w_hite(a5),d1
	bge	wor_selx	;br if below world
*
	move.l	wblkptr,a0		;get pointer to end +1
	move.l	#worldblk,a1		; & ptr to beginning
	lea	bshblock,a2
	bra	findreci
findlp:
	move.w	-(a0),d3	;get vpos
	move.w	-(a0),d2	;hpos
	subq.l	#2,a0		;skip special effects
	move.w	-(a0),d4	;brush #
*
	cmp.w	d0,d2		;are we entirely to left?
	bgt	findreci	;br if so
*
	cmp.w	d1,d3		;are we entirely above?
	bgt	findreci	;br if yes
*
*  we may have found our boy--check width & height
*
	move.w	d4,d5
	swap	d5		;save possible curbrush in upper word
*
	lsl.w	#4,d4		;get offset into bshblock
	move.w	(a2,d4.w),d5	;get width
	move.w	2(a2,d4.w),d6	; & height
	add.w	d2,d5
	add.w	d3,d6
*
	cmp.w	d0,d5
	ble	findreci
*
	cmp.w	d1,d6
	ble	findreci	;br if outside rect
*
*  we're inside a rectangle--check mask for pixel level match
*
	move.l	4(a2,d4.w),a3	;get graphics s_form
	move.l	a3,a5
	adda.w	12(a2,d4.w),a5	;get mono mask s_form
	move.l	a5,a6
	move.w	14(a2,d4.w),d5	;get bytes/line
	beq	hitnail		;br if filled rect
	lsr.w	#2,d5
	move.w	d0,d6
	sub.w	d2,d6		;d6 = horz offset into mask form
	move.w	d1,d7
	sub.w	d3,d7		;d7 = # rows down the form
	mulu	d5,d7
	add.l	d7,a5
	move.w	d6,d7
	asr.w	#3,d7
	adda.w	d7,a5
	not.w	d6
	andi.w	#7,d6		;d6 = dot address	
	btst.b	d6,(a5)		;do we have a hit, or miss
	beq	findreci
*
*
*  we have hit the nail on the head
*
hitnail:
	swap	d5
	move.w	d5,curbrush
	swap	d5
*
*   convert world co-ords to screen ones
*
	lea	wstruct+xoffset,a5	;restore structure ptr
*
	sub.w	xoffset(a5),d2
	add.w	wx(a5),d2
	sub.w	yoffset(a5),d3
	add.w	wy(a5),d3
*
	movem.w	d2-d3,bsh_x	;select this brush
	move.w	d5,bsh_monoln	;save bytes/line in form
	lea	(a2,d4.w),a2
	movem.w	(a2),d5-d6	;get width & height
	movem.w	d5-d6,bsh_wid
*
*   Delete it from worldblk
*
	movem.l	a3/a5-a6,-(sp)
*
	move.l	a0,wblkcur	;save in current
	lea	8(a0),a3
	move.l	wblkptr,a4	;get end +1
	bra	delei
dele:
	move.l	(a3)+,(a0)+
	move.l	(a3)+,(a0)+
delei:
	cmp.l	a4,a3
	bcs	dele
*
	subq.l	#8,a4
	move.l	a4,wblkptr
	bsr	makewld		;rebuild the world
	bsr	makemsk		;  & the mask
*
*  Blit a patch of the world buffer to the screen
*
	bsr	brushpat
*
	movem.l	(sp)+,a3/a5-a6
	move.l	a6,a0
*
*  enter here from cluster code to put up a unit
*
bckdoorm:
	movem.w	bsh_x,d0-d4
	bsr	bdisplay
*
	movem.l	a0/d0,-(sp)
	lea	bshblock,a0
	move.w	curbrush,d0
	bsr	upname			;put up the name
	movem.l	(sp)+,a0/d0
*
	bra	lib_m			;make her animate!
*
findreci:
	cmp.l	a0,a1			;any more items left
	bcs	findlp			;br if so
*
wor_selx:
	movem.l	mousex,d0
	moveq	#0,d1
	movem.l	d0-d1,bsh_x
	bra	but_xit			;exit thru right button stuff
*
*
*
*  Select a stamp from the library
*
lib_sel:
	movem.l	a0-a6/d0-d7,-(sp)
*
	bsr	butninit
*
*
newstamp:
*
	movem.w	mousex,d0-d1		;get xpos, ypos
*
	lea	bshblock,a1		;get brush data block base
	move.w	curbrush,d2		;get desired brush #
	lsl.w	#4,d2
*
	adda.w	d2,a1
	move.w	(a1)+,d2		;get block width
	move.w	d2,bsh_wid		;save for use by move
	beq	lib_sel1		;br if null entry
*
*
	move.w	d2,d5			;copy width
	lsr.w	#1,d5
	sub.w	d5,d0			;adjust xpos by 1/2 width
*
	move.w	d0,bsh_x		;we allow bsh_x < 0
*
*
	move.w	(a1)+,d3		;get block height
	move.w	d3,bsh_hite		;save for use by move
*
	move.w	d3,d6
	lsr.w	#1,d6
	sub.w	d6,d1
*
	move.w	d1,bsh_y
*
	move.l	(a1)+,a3	;a3 -> s_form
	move.l	(a1)+,a2	;object name string
*
*  is this an intrinsic object?
*
	move.w	curbrush,d6
	cmp.w	maxintrins,d6
	bls	strcpyx		;br if intrinsic
	move.l	(a2),a2		;else, derived
strcpyx:
*
	lea	brshfile,a0	;use this to copy brush name
	move.l	a0,-(sp)
strcopy:
	move.b	(a2)+,d6
	move.b	d6,(a0)+
	cmpi.b	#" ",d6
	bhi	strcopy
	clr.b	-(a0)
*
	move.l	(sp)+,a0
	movem.l	a1-a3/d0-d3,-(sp)	
	move.w	#LIBRARY,d0
	bsr	DaveInfo	;put brush name on the info bar
	movem.l	(sp)+,a1-a3/d0-d3
*
	move.w	(a1)+,d4	;get mask_offset
	lea	(a3,d4.w),a0	;get mono mask src_form
*
	move.w	(a1)+,d4	;s_nxln for 4-plane brush
	lsr.w	#2,d4		;d4 = mono scr_nxln
	move.w	d4,bsh_monoln
*
*
*	d0 = DST x
*	d1 = DST y
*	d2 = width
*	d3 = height
*	d4 = mono mask scr_nxln
*
*	a0 -> mono mask s_form
*	a3 -> 4-plane graphics s_form
*
*
	bsr	bdisplay	;display brush, clipped to screen
*
*	This loop is entered when a right button is down--
*		exit loop when button released
*
lib_sel1:
	bsr	getmouse
*
	bsr	CaryKey		;check for user ctrl-keys
*
*  the following code allows function keys to be programmed
*   during right-mouse button brush select mode
*
	tst.w	d4		;any keyboard input?
	beq	lib_sel0	;br if not

	ror.w	#8,d4
	cmpi.b	#FUNC_1,d4
	bcs	lib_sel0
	cmpi.b	#FUNC_10+1,d4
	bcc	lib_sel0x
*
*  we want the brush from the function key
*
	moveq	#0,d0
	move.b	d4,d0
	subi.b	#FUNC_1,d0
	lsl.w	#8,d0
	bsr	Func_Key
	move.w	curbrush,d1
	bra	lib_sel4
lib_sel0x:
	cmpi.b	#SH_FUNC_1,d4
	bcs	lib_sel0
	cmpi.b	#SH_FUNC_10+1,d4
	bcc	lib_sel0
*
	moveq	#0,d0
	move.b	d4,d0
	subi.b	#SH_FUNC_1,d0
	lsl.w	#8,d0
	bsr	Shift_Func_Key
*
lib_sel0:
	move.l	mouseptr,a1
	movem.w	(a1),d0-d1
	and	#1,d3
	bne	lib_sel1x
	tst.w	bsh_wid		;if null brush is selected, exit
	beq	lib_xit
	bra	lib_move	;else, move this guy
lib_sel1x:
	sub.w	relcentx,d0	;how far did mouse travel x-wise?
	move.w	d0,d3
	bpl	lib_sel2
	neg.w	d3
lib_sel2:
	cmpi.w	#4,d3
	bcs	lib_sel1
	move.l	relcentx,(a1)	;restore fake mouse to center position
*
*  We assume there exists at least one good brush..
*
nxt_bsh:
	move.w	curbrush,d1
	tst.w	d0		;check sign
	bmi	lib_sel3
	addq.w	#1,d1
	cmp.w	maxderivd,d1
*
	bls	lib_sel4
	moveq	#0,d1
	bra	lib_sel4	
lib_sel3:
	subq.w	#1,d1
	bpl	lib_sel4
	move.w	maxderivd,d1
lib_sel4:
	move.w	d1,curbrush
*
	lea	bshblock,a1
	lsl.w	#4,d1
	tst.w	(a1,d1.w)	;are we a real brush?
	beq	nxt_bsh		;loop until we get a real one
*
*  the following screens out H & V flipped cache images
*
	move.l	8(a1,d1.w),a1	;get ptr to derived entry
	lsr.w	#4,d1
	cmp.w	maxintrins,d1	;are we intrinsic?
	bls	lib_sel5	;br if so--we'll take it
	tst.w	4(a1)		;are we a primary cluster?
	bne	lib_sel5	;br if so
	move.w	8(a1),d1	;get effects
	andi.w	#Hflip+Vflip,d1	;any flips?
	bne	nxt_bsh		;if so, skip display
lib_sel5:
*
	bsr	pastund
	bra	newstamp
*
lib_move:
	move.l	relcentx,(a1)
*
lib_m:
	clr.w	forceupd

	bsr	fat
*
	bsr	getmouse
*
	bsr	CaryKey
*
	bsr	ctrlkey		;process cntrl keys
*
	tst.w	d4		;any keyboard input?
	beq	lib_m0
	bsr	checkpri	;check keyboard for re-prioritization
lib_m0:
	and.w	#1,d3		;check for no buttons down
	beq	lib_mx
*
	bclr.b	#1,BUT_STATE+1
	bne	lib_xita	;exit if right button down
*
	bclr.b	#0,BUT_STATE+1	;check for left down
	beq	lib_mx		;br if left not down
*
*   A brush is stamped into the world..
*
	bsr	pastund		;erase display brush
	movem.w	xmin_clp,d4-d7	;get window clipping rectangle
	movem.w	d4-d7,-(sp)	;save
*
	lea	wstruct+xoffset,a5
	move.w	d4,d0
	sub.w	xoffset(a5),d0
	add.w	w_wid(a5),d0	;comput world clip rectangle
	cmp.w	d0,d6		;take the smaller of world/window
	ble	xclpok
	move.w	d0,d6
xclpok:
	move.w	d5,d0
	sub.w	yoffset(a5),d0
	add.w	w_hite(a5),d0
	cmp	d0,d7
	ble	yclpok
	move.w	d0,d7
yclpok:
	movem.w	d4-d7,xmin_clp	;save new clip rect
*
	movem.w	bsh_x,d0-d4

	cmp.w	d6,d0		;are we totally right of clip?
	bge	skipstmp
*
	cmp.w	d7,d1
	bge	skipstmp
*
	bsr	bdisplay	;put up a world-clipped brush
*
*  now blit to world buffer as well
*
	movem.l	a0/a3/a5,-(sp)	;save s_forms ptrs
	movem.w	bsh_x,d0-d4	;get screen brush position
*
*  put entry into world object list
*
	move.l	wblkptr,a0	;open up a hole in world object list
	lea	8(a0),a3	;open up a hole in world object list
	move.l	a3,wblkptr
	move.l	wblkcur,a2
	bra	holelpi
holelp:
	move.l	-(a0),-(a3)
	move.l	-(a0),-(a3)
holelpi:
	cmp.l	a0,a2
	bcs	holelp
*
	move.w	curbrush,(a2)+	;save brush #
	clr.w	(a2)+		;special effect (not used yet)
*
	sub.w	wx(a5),d0
	add.w	xoffset(a5),d0	;d0 = world relative x_min
	move.w	d0,(a2)+	;
*	
	sub.w	wy(a5),d1
	add.w	yoffset(a5),d1	;d1 = world relative y_min
	move.w	d1,(a2)+	;
	move.l	a2,wblkcur	;adjust priority ptr
*	
	lea	grafbsh,a3
	lea	grafmsk,a0
	bsr	wldblit		;blit to world buffer too
	movem.l	(sp)+,a0/a3/a5	;restore old brush s_forms	

*
skipstmp:
	lea	bitblock,a6
	bsr	copyund
*
*
	movem.w	(sp)+,d0-d3
	movem.w	d0-d3,xmin_clp	;put back world clip
*  fake a move
*	movem.w	bsh_x,d2-d3
*	addq.w	#1,d2
*	move.w	#$7f,d0
*	move.w	#$80,d1
	moveq	#1,d4
	bra	lib_cheat
*
*
lib_mx:
	move.w	grid,d4
lib_cheat:
	movem.w	bsh_x,d2-d3	;pick up current positions
	move.l	mouseptr,a1
	movem.w	(a1),d0-d1
	move.l	relcentx,(a1)
*
	sub.w	relcentx,d0	;check x move
	beq	lib_mov1	;br if no x move
	moveq	#-1,d4		;indicate a move
	add.w	d2,d0		;get proposed new x position
	cmp.w	Mclpxmx,d0	;does it go beyond our clip?
	blt	clp_mov1	;br if ok on right
	move.w	Mclpxmx,d0
	subq.w	#1,d0		;anchor at right maximum
clp_mov1:
	move.w	d0,d5
	add.w	bsh_wid,d5
	subq.w	#1,d5
	cmp.w	Mclpxmn,d5
	bge	clp_mov2
	move.w	Mclpxmn,d0
	sub.w	bsh_wid,d0
	addq.w	#1,d0
clp_mov2:
	move.w	d0,d2
*
*  Check on vert movement
*
lib_mov1:
	sub.w	relcenty,d1	;check y move
	beq	lib_mov2	;br if no y move
	moveq	#-1,d4		;indicate a move
	add.w	d3,d1		;get proposed new y position
	cmp.w	Mclpymx,d1	;does it go beyond our clip?
	blt	clp_mov3	;br if ok on bottom
	move.w	Mclpymx,d1
	subq.w	#1,d1		;anchor at bottom maximum
clp_mov3:
	move.w	d1,d5
	add.w	bsh_hite,d5
	subq.w	#1,d5
	cmp.w	Mclpymn,d5
	bge	clp_mov4
	move.w	Mclpymn,d1
	sub.w	bsh_hite,d1
	addq.w	#1,d1
clp_mov4:
	move.w	d1,d3
lib_mov2:
	movem.w	bsh_x,d0-d1	;check old position

	cmpi.w	#1,d4
	beq	do_mov		;br if this a grid init
*
	tst.w	forceupd	;is this a forced update?
	bne	lib_mov5	;br if so
*	
	tst.w	d4
	beq	lib_m		;br if no move
*
*
	cmp.w	d2,d0
	bne	do_movx
	cmp.w	d3,d1
	beq	lib_m		;br if new position same as old
lib_mov5:
*
*   Here's some constrain stuff
*
do_movx:
	move.w	constrain,d6	;check contrain status
	beq	do_mov		;0=none,1=horz,2=vert,-1=init
	cmpi.w	#-1,d6		;is it init?
	bne	cstrain4	;br if not
	move.w	d0,d4
	sub.w	d2,d4
	bpl	cstrain1
	neg.w	d4
cstrain1:
	move.w	d1,d5
	sub.w	d3,d5
	bpl	cstrain2
	neg.w	d5
cstrain2:
	moveq	#1,d6
	cmp.w	d4,d5
	beq	lib_m		;no move if both the same
	bls	cstrain3
	moveq	#2,d6
cstrain3:
	move.w	d6,constrain
cstrain4:
	cmp.w	#1,d6		;horz constrain?
	bne	cstrain5
	move.w	d1,d3
	bra	do_mov
cstrain5:
	move.w	d0,d2
*
*	
do_mov:
*
*   check grid
*
	move.w	grid,d4
	beq	nogrid		;skip if grid isn't on
*
	bmi	do_grid		;br if grid-continue
*
*  grid init
*
	movem.w	d2-d3,bsh_x
*
	move.w	#-1,grid
*
	movem.w	bsh_x,d0-d1	;get current brush position
*
	lea	wstruct+xoffset,a5
	sub.w	wx(a5),d0
	add.w	xoffset(a5),d0	;d0= world xpos
*
	sub	wy(a5),d1
	add.w	yoffset(a5),d1
*
*  We're in world co-ords now
*  enforce grid position NOW!
*
	movem.w	d0-d1,-(sp)
	movem.w	Grid,d2-d5	;get grid co-ords
*
	tst.w	d4		;convert 0's to 1's
	bne	grid0
	moveq	#1,d4
grid0:
	tst.w	d5
	bne	grid1
	moveq	#1,d5
grid1:
	sub.w	d2,d0
	sub.w	d3,d1
	ext.l	d0
	ext.l	d1
	divs	d4,d0
	divs	d5,d1
	swap	d0	;get signed remainder for x (dividend has same sign) 
	tst.w	d0
	bpl	grid2
	add.w	d4,d0	;make positive
grid2:
	swap	d1		; & for y
	tst.w	d1
	bpl	grid3
	add.w	d5,d1
grid3:
	movem.w	(sp)+,d2-d3	;get original world x & y
*
	move.w	d4,d6
	lsl.w	#1,d0		;x remainder *2
	cmp.w	d0,d4		;less than 1/2 way to next grid point?
	bhi	grid4		;br if so
*
*  more than 1/2 way--compute amount to add
*
	lsr.w	#1,d0
	sub.w	d0,d6
	add.w	d6,d2
	neg.w	d6		;d6 = offset
	bra	grid5
*
*  less than 1/2 way--use d0 to subtract
*
grid4:	
	lsr.w	#1,d0
	sub.w	d0,d2
	move.w	d0,d6
grid5:
	move.w	d6,xgridoff
*
*
	move.w	d5,d7
	lsl.w	#1,d1		;y remainder *2
	cmp.w	d1,d5		;less than 1/2 way to next grid point?
	bhi	grid6		;br if so
*
*  more than 1/2 way--compute amount to add
*
	lsr.w	#1,d1
	sub.w	d1,d7
	add.w	d7,d3
	neg.w	d7		;d7 = offset
	bra	grid7
*
*  less than 1/2 way--use d1 to subtract
*
grid6:	
	lsr.w	#1,d1
	sub.w	d1,d3
	move.w	d1,d7
grid7:
	move.w	d7,ygridoff
*
*  Restore to screen co-ords..
*
	add.w	wx(a5),d2
	sub.w	xoffset(a5),d2
	add.w	wy(a5),d3
	sub.w	yoffset(a5),d3
*
*  Make sure new position is on window..
*
	moveq	#0,d7
	movem.w	bsh_wid,d0-d1
	add.w	d2,d0		;get brush right edge
	move.w	wx(a5),d6
	cmp.w	d0,d6		;is new brush position too far left?
	blt	ritechk		;br if not
	add.w	d4,d2		;else, just position one notch to right
	addq.w	#1,d7
ritechk:
	add.w	wwidth(a5),d6	;get window xmax (+1)
*
	subq.w	#1,d6
	cmp.w	form_width,d6	;window exceeds screen?
	ble	notxscre
	move.w	form_width,d6
notxscre:
	addq.w	#1,d6
*
	cmp.w	d2,d6
	bgt	topchk
	sub.w	d4,d2
	addq.w	#1,d7
topchk:
	cmpi.w	#2,d7
	beq	cantwind	;br if can't find any anchor point on window
*
	moveq	#0,d6
	add.w	d3,d1		;get brush bottom edge
	move.w	wy(a5),d7
	cmp.w	d1,d7
	blt	botchk
	add.w	d5,d3
	addq.w	#1,d6
botchk:
	add.w	wheight(a5),d7	;get window ymax +1
*
	subq.w	#1,d7
	cmp.w	form_height,d7	;window exceeds screen?
	ble	notyscre
	move.w	form_height,d7
notyscre:
	addq.w	#1,d7
*
	cmp.w	d3,d7
	bgt	owind
	sub.w	d5,d3
	add.w	#1,d6
owind:
	cmpi.w	#2,d6
	bne	goodwin
cantwind:
	movem.w	bsh_x,d2-d3	;just got to use the old values
*
goodwin:
	movem.w	d2-d3,bsh_x
*
offworld:
	bra	nogrid		;skip this grid thang if just entered
*
*  we're griddin'
*
do_grid:
	moveq	#0,d7		;indicate no move
*
*	movem.w	gridw,d4-d5	;get grid width & height
	movem.w	Grid+4,d4-d5
*
	tst.w	d4
	bne	grdx
	moveq	#1,d4
grdx:
	tst.w	d5
	bne	grdy
	moveq	#1,d5
grdy:
	sub.w	d2,d0
	sub.w	d3,d1
*
	neg.w	d0
	neg.w	d1
*
	sub.w	d0,d2		;undo the move for now
*
	add.w	xgridoff,d0	;add xaccum to delta
	move.w	d0,d6
	bpl	grd0
	neg.w	d6
	add.w	d6,d6
	cmp.w	d4,d6		;more than 1/2 way to the goal line?
	bcs	grd1		;br if no grid jump yet
grd0a:
	sub.w	d4,d2		;adjust xpos
	add.w	d4,d0		;adjust new xgridoff till it goes positive
	bmi	grd0a
*
	bra	grd1a
grd0:
	add.w	d6,d6
	cmp.w	d4,d6
	bcs	grd1		;br if no grid jump yet
grd0b:
	add.w	d4,d2		;adjust xpos
	sub.w	d4,d0
	bpl	grd0b		;adjust new xgridoff till it goes negative
grd1a:
	moveq	#-1,d7
grd1:
	move.w	d0,xgridoff
*
*  Now do y
*
	sub.w	d1,d3		;undo the move for now
	add.w	ygridoff,d1	;add yaccum to delta
	move.w	d1,d6
	bpl	grd2
	neg.w	d6
	add.w	d6,d6
	cmp.w	d5,d6		;more than 1/2 way to the goal line?
	bcs	grd3		;br if no grid jump yet
grd2a:
	sub.w	d5,d3		;adjust ypos
	add.w	d5,d1		;adjust new ygridoff till it goes positive
	bmi	grd2a
	bra	grd3a
grd2:
	add.w	d6,d6
	cmp.w	d5,d6
	bcs	grd3		;br if no grid jump yet
grd2b:
	add.w	d5,d3		;adjust ypos
	sub.w	d5,d1
	bpl	grd2b	
grd3a:
	moveq	#-1,d7
grd3:
	move.w	d1,ygridoff
	tst.w	forceupd	;check for forced update
	bne	grd4
	tst.w	d7
	beq	lib_m		;don't flash if we haven't grid-moved
grd4:
*
*  Check for outside window (we don't permit outside window)
*
	bsr	offwind
	beq	nogrid		;br if on window
*
	movem.w	bsh_x,d2-d3	;else, just use previous
*
*  End of grid maddness
*
nogrid:
	movem.w	d2-d3,bsh_x
*
	sub.w	wx(a5),d2
	add.w	xoffset(a5),d2
	move.w	d2,d0
*
	lea	infox,a1
	bsr	decitpad
*
	move.w	bsh_y,d0
	sub.w	wy(a5),d0
	add.w	yoffset(a5),d0
*
	lea	infoy,a1
	bsr	decitpad
*

	move.l	a0,-(sp)
	move.w	#WORLD,d0
	lea	infostrng,a0
	bsr	DaveInfo
	move.l	(sp)+,a0
*
	bsr	pastund
*
*
	movem.w	bsh_x,d0-d4
	bsr	bdisplay
*
*
	bra	lib_m
*
*
lib_xita:
	bsr	wtritup
*
lib_xit:
	bsr	pastund
*
*
but_xit:
	bsr	bsh2curs
but_xit0:
	move.w	#MouseOn,d0
	bsr	Graf_Mouse
*
	bsr	Back2G		;check for curbrush = cluster
*
	lea	world_ID,a0
	move.w	#WORLD,d0
	bsr	DaveName	;put world name back on title bar
*
	bsr	fatquit
	bsr	wtritup
*
*	lea	Mrets,a0
*	bsr	Graf_mkstate	;clean up AES
*
	movem.l	(sp)+,a0-a6/d0-d7

	rts
*
*  Put system cursor at about the center of the brush
*
bsh2curs:
	movem.l	a1/d0-d3,-(sp)
	move.l	mouseptr,a1
	movem.w	bsh_x,d0-d3
	lsr.w	#1,d2
	lsr.w	#1,d3
	add.w	d2,d0
	add.w	d3,d1
*
*  clip new x,y mouse position to the screen
*
	tst.w	d0
	bpl	mxok
	moveq	#0,d0
mxok:
	cmp.w	form_width,d0
	bcs	mxok1
	move.w	form_width,d0
mxok1:
	tst.w	d1
	bpl	myok
	moveq	#0,d1
myok:
	cmp.w	form_height,d1
	bcs	myok1
	move.w	form_height,d1
myok1:
*
	movem.w	d0-d1,(a1)
	movem.l	(sp)+,a1/d0-d3
	rts
*
*
*   Wait for right button to come up
*
wtritup:
	bsr	getmouse
	and.w	#1,d3
	bne	wtritup
*
	bclr.b	#1,BUT_STATE+1
	bne	wtritup
	bclr.b	#0,BUT_STATE+1
	bne	wtritup
	rts
*
*
*   Let Cary call this to display xoffset/yoffset
*
DisplayXY:
	movem.l	a0-a6/d0-d7,-(sp)
	move.w	wstruct+xoffset,d0
	lea	infox,a1
	bsr	decitpad
*
	move.w	wstruct+yoffset,d0
	lea	infoy,a1
	bsr	decitpad
*
	move.w	#WORLD,d0
	lea	infostrng,a0
	bsr	DaveInfo
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*  Check for outside window (we don't permit outside window)
*
*  assume d2-d3 is bsh_x, bsh_y
*  a5 -> wstruct
*
offwind:
	movem.w	bsh_wid,d0-d1
	add.w	d2,d0		;get brush right edge +1
	move.w	wx(a5),d6	;get window x-minimum
	cmp.w	d0,d6
	bge	offwx
*
	add.w	wwidth(a5),d6	;get window x-max +1
*
	subq.w	#1,d6
	cmp.w	form_width,d6	;window exceeds screen?
	ble	nxscre
	move.w	form_width,d6
nxscre:
	addq.w	#1,d6
*
	cmp.w	d2,d6
	ble	offwx
*
	add.w	d3,d1		;get brush bot edge +1
	move.w	wy(a5),d7
	cmp.w	d1,d7
	bge	offwx
*
	add.w	wheight(a5),d7

	subq.w	#1,d7
	cmp.w	form_height,d7	;window exceeds screen?
	ble	nyscre
	move.w	form_height,d7
nyscre:
	addq.w	#1,d7
*
	cmp.w	d3,d7
	bgt	onwind
offwx:
	moveq	#-1,d0		;indicate off window
	rts
onwind:
	moveq	#0,d0		;indicate on window
	rts
*
*
********************************************************
*
*   This comes from Cary when a key is hit
*
*	d0 = shift keys
*	d1 = scan code + ASCII code of a key
*	d2 = topped window (-1 if not one of ours)
*
DaveKey:
	cmpi.w	#WORLD,d2	;is world window topped?
	bne	Dky1		;br if not topped		
	cmpi.b	#"a",d1		;force upper case
	bcs	Dky0
	subi.b	#$20,d1		
Dky0:
	cmpi.b	#"C",d1		;enter "cluster" mode?
	beq	docluster	;br if so
*
	cmpi.b	#"B",d1		;enter "bridge" mode?
	beq	dobridge
*
	cmpi.b	#"R",d1		;enter filled Rectangle mode?
	beq	dorect
Dky1:
	rts			;exit to ignore any other key
*
*
*
docluster:
	movem.l	a0-a6/d0-d7,-(sp)
	move.w	#$8001,aggreg	;indicate a cluster aggregate
	bra	aggregate
*
*
dobridge:
	movem.l	a0-a6/d0-d7,-(sp)
	move.w	#1,aggreg	;indicate bridge aggregate
*
*  Enter CLUSTER/BRIDGE select mode
*
aggregate:
	moveq	#outlnx,d0
	bsr	Graf_Mouse
*
	clr.w	butt		;init button edge shadow
*
	lea	tempbuf,a3	;start cluster list here

	move.w	#$7fff,d0	;largest 16-bit signed
	move.w	d0,d1
	move.w	#$8000,d2	;smallest 16-bit signed
	move.w	d2,d3
	movem.w	d0-d3,xmin_clust	;init min/max stuff
*
aggrcnt:
	lea	bridg_msg,a0
	move.w	aggreg,d0
	cmpi.w	#4,d0		;reached end of a bridge?
	beq	brid_xit	;br if so
*
	bclr.l	#15,d0
	beq	aggr0
	lea	clust_msg,a0
aggr0:
	lea	17(a0),a1
	bsr	decitpad
*
	move.w	#WORLD,d0
	move.l	a3,-(sp)	;save the cluster list ptr
	bsr	DaveInfo	;tell 'em our mode
	move.l	(sp)+,a3
*
aggrlp:
	bsr	getmouse	;let GEM have control for a while
	andi.w	#1,d3		;any mouse buttons?
	beq	aggr3		;br if none
*
	move.w	BUT_STATE,d6	;get left & right
	clr.w	BUT_STATE	
	move.w	butt,d5
	move.w	d3,butt
	eor.w	d3,d5
	bne	aggrbut		;br if positive edge on button
aggr3:
	move.w	d3,butt
*
	tst.w	d4		;any keyboard?
	beq	aggrlp		;br if not
*
*  we got a key
*
	tst.b	d4		;ASCII code?
	beq	aggrlp		;br if not
*
	cmpi.b	#"a",d4
	bcs	aggr1
	subi.b	#$20,d4		;force upper case
aggr1:
	cmpi.b	#esc,d4		;are we escape?
	beq	ag_abort	;br if so
*
	bra	aggrlp		;go for more user input
*
*  Button was pressed--find sprite selected
*
aggrbut:
	btst.l	#1,d6		;check for right button
	bne	aggr_xit	;exit if right button
*
	lea	wstruct,a5
	move.l	mouseptr,a0
	movem.w	(a0),d0-d1	;get mouse screen cursor x/y
*
*   Gotta be on the world window
*
	movem.w	wx(a5),d2-d3
	cmp.w	d2,d0	;
	blt	aggrlp		;exit if off window
	cmp.w	d3,d1
	blt	aggrlp
*
	add.w	wwidth(a5),d2
	cmp.w	d2,d0
	bge	aggrlp
*
	add.w	wheight(a5),d3
	cmp.w	d3,d1
	bge	aggrlp
*
*  mouse is on the world window work area
*
	sub.w	wx(a5),d0
	add.w	xoffset(a5),d0	;adjust for world co-ords
	sub.w	wy(a5),d1
	add.w	yoffset(a5),d1
*
*  Search the worldblk for the highest priority object
*   whose rectangle falls within the mouse position
*
	cmp.w	w_wid(a5),d0	;are we right of the world
	bge	aggrlp		;br if so
	cmp.w	w_hite(a5),d1
	bge	aggrlp		;br if below world
*
	move.l	wblkptr,a0		;get pointer to end +1
	move.l	#worldblk,a1		; & ptr to beginning
	lea	bshblock,a2
	bra	aggrreci
aggreclp:
	move.w	-(a0),d3	;get vpos
	move.w	-(a0),d2	;hpos
	subq.l	#2,a0		;skip special effects
	move.w	-(a0),d4	;brush #
*
	cmp.w	d0,d2		;are we entirely to left?
	bgt	aggrreci	;br if so
*
	cmp.w	d1,d3		;are we entirely above?
	bgt	aggrreci	;br if yes
*
*  we may have found our boy--check width & height
*
	move.w	d4,d5
	swap	d5		;save possible curbrush in upper word
*
	lsl.w	#4,d4		;get offset into bshblock
	move.w	(a2,d4.w),d5	;get width
	move.w	2(a2,d4.w),d6	; & height
	add.w	d2,d5
	add.w	d3,d6
*
	cmp.w	d0,d5
	ble	aggrreci
*
	cmp.w	d1,d6
	ble	aggrreci	;br if outside rect
*
	move.w	d5,a4
	move.w	d6,a6		;save in case we need
*
*  we're inside a rectangle--check mask for pixel level match
*
	move.l	4(a2,d4.w),a5	;get graphics s_form
	adda.w	12(a2,d4.w),a5	;get mono mask s_form
	move.w	14(a2,d4.w),d5	;get bytes/line
	lsr.w	#2,d5
	move.w	d0,d6
	sub.w	d2,d6		;d6 = horz offset into mask form
	move.w	d1,d7
	sub.w	d3,d7		;d7 = # rows down the form
	mulu	d5,d7
	add.l	d7,a5
	move.w	d6,d7
	asr.w	#3,d7
	adda.w	d7,a5
	not.w	d6
	andi.w	#7,d6		;d6 = dot address	
	btst.b	d6,(a5)		;do we have a hit, or miss
	beq	aggrreci
*
*  we have hit the nail on the head
*
	swap	d5
	move.w	d5,d0		;brush # to d0
*
	move.w	a4,d5
	move.w	a6,d6
*
*  d2 - xmin
*  d3 - ymin
*  d5 - xmax +1
*  d6 - ymax +1
*
*  accumulate cluster-wide min/max info
*
	cmp.w	xmin_clust,d2
	bge	aggr5
	move.w	d2,xmin_clust
aggr5:
	cmp.w	ymin_clust,d3
	bge	aggr6
	move.w	d3,ymin_clust
aggr6:
	cmp.w	xmax_clust,d5
	ble	aggr7
	move.w	d5,xmax_clust
aggr7:
	cmp.w	ymax_clust,d6
	ble	aggr8
	move.w	d6,ymax_clust
aggr8:
*
*  we got one--see if we got it already
*
	movem.l	a1/a3,-(sp)	;keep our place on list
	cmp.l	#tempbuf+100,a3	;have we gone beyond capacity here?
	bcc	xistskip
*
	lea	tempbuf,a1
	bra	xistchki
xistchk:
	cmp.l	-(a3),a0
	bne	xistchki
*
*  we've already selected this item--skip it this time
*
xistskip:
	movem.l	(sp)+,a1/a3
	bra	aggrcnt	
xistchki:
	cmp.l	a3,a1		;reached beginning?
	bcs	xistchk		;br if not
*
*  else, our new one hasn't been picked already..
*	
	movem.l	(sp)+,a1/a3	;end exist check
	
	move.l	a0,(a3)+	;save cluster ptr
*
	move.l	a3,-(sp)
	lea	bshblock,a0
	bsr	upname		;put up the name
	move.l	(sp)+,a3
*
	addq.w	#1,aggreg
*
	bra	aggrcnt		;count up next one
*	
aggrreci:
	cmp.l	a0,a1
	bcs	aggreclp	;look for next item in world
*
*  no more items, air-ball click here..
*
	bra	aggrlp		;get next user input
*
*  We finished a bridge (always 3 elements)..
*
brid_xit:
*
*  see if horz or vert bridge..
*
	lea	tempbuf,a0
	lea	bshblock,a5
*
*  see if any of the three are aggregates..
*
	moveq	#2,d1		;check all three
	moveq	#0,d2		;count of aggregates found
aggr3lp:
	move.l	(a0)+,a1	;get next item
aggr3lp0:
	move.w	(a1)+,d0	;check derived
	cmp.w	maxintrins,d0	;are we intrinsic or derived?
	bls	aggrno		;br if intrinsic
*
	lsl.w	#4,d0
	move.l	8(a5,d0.w),a1	;look at derived info block
	addq.l	#4,a1		;skip over string ptr
	tst.w	(a1)+		;multiple elements here?
	beq	aggr3lp0	;br if not--recheck for intrinsic
	move.l	-(a0),d3	;put root of this aggregate in d3
	addq.l	#4,a0
	addq.w	#1,d2		;inc the agg count
aggrno:
	dbra	d1,aggr3lp	;search rest of 'em
*
	lea	tempbuf,a0
	movem.l	(a0),a1-a3	;a1, a2, a3 -> three element entries
	lea	brshfile,a4
*
*
*******temp test
*	bra	aggrnox		;just jump into normal aggregate
*	tst.w	d2
*	bne	ag_abort	;abort if ANY aggregates
*** end test
*
*
	cmpi.w	#1,d2
	bhi	ag_abort	;abort if more than 1 aggregate
	tst.w	d2
	beq	aggrnox		;do normal if no aggregates
*
*  we have 1 aggregate--look at other two for orientation..
*
	cmp.l	d3,a1
	bne	aggrchk
	exg	a3,a1
	bra	aggrx1
aggrchk:
	cmp.l	d3,a2
	bne	aggrx1
	exg	a3,a2
*
*  a1 & a2 are singles, a3 is aggregate
*
aggrx1:

	movem.w	4(a1),d0-d1	;get hpos/vpos of one 
	movem.w	4(a2),d6-d7	; & hpos/vpos of the other
	sub.w	d0,d6
	bpl	aggrx2		;get absolute value of horz delta
	neg.w	d6
aggrx2:
	sub.w	d1,d7
	bpl	aggrx3		;get vert delta
	neg.w	d7
aggrx3:
	cmp.w	d7,d6		;which is greater, horz or vert?
	ble	v2big		;br if vertical
*
*  a1, a2 -> intrinsics
*
	move.w	4(a1),d0
	cmp.w	4(a2),d0
	bcs	aggrx4
	exg	a1,a2		;a1 -> leftmost intrinsic
aggrx4:
*
*  we're horz--which end of compound bridge to bridge to?
*
*  check 1st endbrush and eliminate if:
*
*	Endbrush horizontally between intrinsics
*	Endbrush face needed for new bridge is bridged already
*	Mean intrinsics vpos alignment with endbrush exceeds height
*
*
	move.w	(a3),d0
	lsl.w	#4,d0
	move.l	8(a5,d0.w),a6	
	movem.w	4(a3),d2-d3	;get base hpos/vpos of compound bridge
*
	moveq	#0,d0		;assume both endbrushes OK
*
	movem.w	10(a6),d4-d5	;get relative hpos/vpos of 1st endbrush
	add.w	d2,d4		;form absolute hpos
	add.w	d3,d5		; & vpos
	move.w	d4,d6
	move.w	d4,d1
	sub.w	4(a1),d6
	sub.w	4(a2),d1
	eor.w	d6,d1		;check endbrush between intrinsics
	bmi	must2		;br if must reject 1st
*
	move.w	10(a6),d1	;get relative hpos 1st endbrush
	sub.w	22(a6),d1	;find delta with previous bridge
	beq	vbridg		;br if its a vertical--face is avail
	eor.w	d6,d1		;check for available face
	bpl	must2		;br if face not avail, must select other or none
vbridg:
	move.w	6(a1),d1
	add.w	6(a2),d1
	lsr.w	#1,d1		;d1 = average vpos of intrinsics
	sub.w	d5,d1		;get delta with vpos of this endbrush
	bpl	hcheck
	neg.w	d1		;get positive delta
hcheck:
	move.w	6(a6),d5	;find 1st endbrush height
	lsl.w	#4,d5
	cmp.w	2(a5,d5.w),d1	;1st endbrush height >= delta?
	bhi	must2		;br if vertical alignment not good enough
*
*  we pass the 3 tests for 1st endbrush, now check last
*
	bra	mustchk2
must2:
	ori.w	#1,d0		;indicate 1st endbrush rejected
mustchk2:
	move.w	d4,-(sp)	;save hpos of 1st endbrush
*
*  Last endbrush must pass three tests
*
	move.w	4(a6),d7	;get compound item count
	mulu	#12,d7
	movem.w	10(a6,d7.w),d4-d5 ;get relative hpos/vpos of last endbrush
	add.w	d2,d4		;form absolute hpos
	add.w	d3,d5		; & vpos
	move.w	d4,d6
	move.w	d4,d1
	sub.w	4(a1),d6
	sub.w	4(a2),d1
	eor.w	d6,d1		;check endbrush between intrinsics
	bmi	must1		;br if must select first or none
*
	move.w	10(a6,d7.w),d1	;get relative hpos 1st endbrush
	sub.w	-2(a6,d7.w),d1	;find delta with previous bridge
	beq	vbridg0		;br if its a vertical--face is avail
	eor.w	d6,d1		;check for available face
	bpl	must1		;br if face not avail, must select other or none
vbridg0:
	move.w	6(a1),d1
	add.w	6(a2),d1
	lsr.w	#1,d1		;d1 = average vpos of intrinsics
	sub.w	d5,d1		;get delta with vpos of this endbrush
	bpl	hcheck0
	neg.w	d1		;get positive delta
hcheck0:
	move.w	6(a6,d7.w),d5	;find last endbrush height
	lsl.w	#4,d5
	cmp.w	2(a5,d5.w),d1	;1st endbrush height >= delta?
	bhi	must1		;br if vertical alignment not good enough
*
*  we pass the 3 tests
*
	bra	mustchk
must1:
	ori.w	#2,d0		;reject last brush
mustchk:
	move.w	(sp)+,d5	;reget 1st endbrush hpos
*
	cmpi.w	#3,d0		;rejected both?
	beq	ag_abort	;br if so
*
	cmpi.w	#2,d0		;selected 1st & rejected last?
	beq	dohfirst	;br to do 1st
*
	cmpi.w	#1,d0		;selected last & rejected first?
	beq	dohlast		;br to do last
*
*  both brushes are eligible--choose the one closest
* 
*  d4.w = last endbrush hpos, d5.w = 1st endbrush hpos
*
	move.w	d4,d1
	sub.w	4(a1),d1
	bpl	hcheck1
	neg.w	d1
hcheck1:
	sub.w	4(a2),d4
	bpl	hcheck2
	neg.w	d4
hcheck2:
	cmp.w	d4,d1
	bcc	hcheck3
	move.w	d1,d4
hcheck3:
*
*   d4 = minimum abs horz delta for last endbrush
*
	move.w	d5,d1
	sub.w	4(a1),d1
	bpl	hcheck4
	neg.w	d1
hcheck4:
	sub.w	4(a2),d5
	bpl	hcheck5
	neg.w	d5
hcheck5:
	cmp.w	d5,d1
	bcc	hcheck6
	move.w	d1,d5
hcheck6:
*
*   d5 = minimum abs horz delta for 1st endbrush
*
	cmp.w	d4,d5		;which is closer?
	bcc	dohlast 
*
*  we picked 1st or last endbrush..
*
dohfirst:
	moveq	#0,d1
	bra	comphorz
dohlast:
	moveq	#-1,d1
comphorz:
	move.w	d1,tempbuf+26
*
	move.w	(a3),d0
	lsl.w	#4,d0
	move.l	8(a5,d0.w),a6
	movem.w	4(a3),d2-d3
	tst.w	d1
	beq	cphorz0
	move.w	4(a6),d1	;get last index
cphorz0:
	mulu	#12,d1
	add.w	10(a6,d1.l),d2	;add relative h/v positions to 
	add.w	12(a6,d1.l),d3	;  get absolute hpos/vpos of endbrush
	move.w	6(a6,d1.l),d1	;  & get endbrush #
*
*  check horz position-order amongst the three
*
	cmp.w	4(a1),d2	;is left intrinsic left of endbrush?
	bge	h123		;br if so
*
*  else, we do a3,a1,a2 order
*
	move.l	a0,(a4)+
	move.l	(a3)+,(a0)+	;copy brush & effects
	move.l	(a3)+,(a0)+	;use hpos/vpos
*
*  now a1 & a2 must use vpos in d3, a1 must use xpos at left side of endbrush
*
	move.l	a0,(a4)+
	move.l	(a1)+,(a0)+
	lsl.w	#4,d1
	add.w	(a5,d1.w),d2
	move.w	d2,(a0)+
	move.w	d3,(a0)+
*
	move.l	a0,(a4)+
	move.l	(a2)+,(a0)+
	move.w	(a2)+,(a0)+
	move.w	d3,(a0)+
*	
	move.w	#$8000,(a0)	;indicate stretch destination is intrinsic
	bra	wehclust
*
*  do a1,a2,a3 order
*	
h123:
	move.l	a0,(a4)+
	move.l	(a1)+,(a0)+
	move.w	(a1),(a0)+
	move.w	d3,(a0)+
*
	move.l	a0,(a4)+
	move.w	-8(a0),d1
	lsl.w	#4,d1
	move.w	(a5,d1.w),d1
	add.w	(a1),d1
	move.l	(a2)+,(a0)+
	move.w	d1,(a0)+
	move.w	d3,(a0)+
*
	move.l	a0,(a4)+
	move.l	(a3)+,(a0)+
	move.l	(a3)+,(a0)+
*
	move.w	d2,(a0)	;save stretch destination into complex bridge
	bra	wehclust
*
*
***************************************************
*
*	We're going for the vertical orientation
*
*
v2big:
	move.w	6(a1),d0
	cmp.w	6(a2),d0
	bcs	v2bigx4
	exg	a1,a2		;a1 -> topmost intrinsic
v2bigx4:
*
*  we're vert--which end of compound bridge to bridge to?
*
*  check 1st endbrush and eliminate if:
*
*	Endbrush vertically between intrinsics
*	Endbrush face needed for new bridge is bridged already
*	Mean intrinsics hpos alignment with endbrush exceeds width
*
*
	move.w	(a3),d0
	lsl.w	#4,d0
	move.l	8(a5,d0.w),a6
	movem.w	4(a3),d2-d3	;get base hpos/vpos of compound bridge
*
	moveq	#0,d0		;assume both endbrushes OK
*
	movem.w	10(a6),d4-d5	;get relative hpos/vpos of 1st endbrush
	add.w	d2,d4		;form absolute hpos
	add.w	d3,d5		; & vpos
	move.w	d5,d6
	move.w	d5,d1
	sub.w	6(a1),d6
	sub.w	6(a2),d1
	eor.w	d6,d1		;check endbrush between intrinsics
	bmi	mustv2		;br if must reject 1st
*
	move.w	12(a6),d1	;get relative vpos 1st endbrush
	sub.w	24(a6),d1	;find delta with previous bridge
	beq	hbridg		;br if its a horz--face is avail
	eor.w	d6,d1		;check for available face
	bpl	mustv2		;br if must reject 1st (face unavail)
hbridg:
	move.w	4(a1),d1
	add.w	4(a2),d1
	lsr.w	#1,d1		;d1 = average hpos of intrinsics
	sub.w	d4,d1		;get delta with hpos of this endbrush
	bpl	vcheck
	neg.w	d1		;get positive delta
vcheck:
	move.w	6(a6),d4	;get 1st endbrush #
	lsl.w	#4,d4
	cmp.w	(a5,d4.w),d1	;1st endbrush width >= delta?
	bhi	mustv2		;br if vertical alignment not good enough
*
*  we pass the 3 tests for 1st endbrush, now check last
*
	bra	mustcvk2
mustv2:
	ori.w	#1,d0		;indicate 1st endbrush rejected
mustcvk2:
	move.w	d5,-(sp)	;save vpos of 1st endbrush
*
*  Last endbrush must pass three tests
*
	move.w	4(a6),d7	;get compound item count
	mulu	#12,d7
	movem.w	10(a6,d7.w),d4-d5 ;get relative hpos/vpos of last endbrush
	add.w	d2,d4		;form absolute hpos
	add.w	d3,d5		; & vpos
	move.w	d5,d6
	move.w	d5,d1
	sub.w	6(a1),d6
	sub.w	6(a2),d1
	eor.w	d6,d1		;check endbrush between intrinsics
	bmi	mustv1		;br if must reject last
*
	move.w	12(a6,d7.w),d1	;get relative vpos 1st endbrush
	sub.w	(a6,d7.w),d1	;find delta with previous bridge
	beq	hbridg0		;br if its a vertical--face is avail
	eor.w	d6,d1		;check for available face
	bpl	mustv1		;br if face not avail, must select other or none
hbridg0:
	move.w	4(a1),d1
	add.w	4(a2),d1
	lsr.w	#1,d1		;d1 = average hpos of intrinsics
	sub.w	d4,d1		;get delta with hpos of this endbrush
	bpl	vcheck0
	neg.w	d1		;get positive delta
vcheck0:
	move.w	6(a6,d7.w),d4	;find last endbrush #
	lsl.w	#4,d4
	cmp.w	(a5,d4.w),d1	;1st endbrush width >= delta?
	bhi	mustv1		;br if vertical alignment not good enough
*
*  we pass the 3 tests
*
	bra	mustcvk
mustv1:
	ori.w	#2,d0		;reject last brush
mustcvk:
	move.w	(sp)+,d4	;reget 1st endbrush hpos
*
	cmpi.w	#3,d0		;rejected both?
	beq	ag_abort	;br if so
*
	cmpi.w	#2,d0		;selected 1st & rejected last?
	beq	dovfirst	;br to do 1st
*
	cmpi.w	#1,d0		;selected last & rejected first?
	beq	dovlast		;br to do last
*
*  both brushes are eligible--choose the one closest
* 
*  d4.w = first endbrush vpos, d5.w = last endbrush vpos
*
	move.w	d4,d1
	sub.w	6(a1),d1
	bpl	vcheck1
	neg.w	d1
vcheck1:
	sub.w	6(a2),d4
	bpl	vcheck2
	neg.w	d4
vcheck2:
	cmp.w	d4,d1
	bcc	vcheck3
	move.w	d1,d4
vcheck3:
*
*   d4 = minimum abs vert delta for last endbrush
*
	move.w	d5,d1
	sub.w	6(a1),d1
	bpl	vcheck4
	neg.w	d1
vcheck4:
	sub.w	6(a2),d5
	bpl	vcheck5
	neg.w	d5
vcheck5:
	cmp.w	d5,d1
	bcc	vcheck6
	move.w	d1,d5
vcheck6:
*
*   d5 = minimum abs vert delta for 1st endbrush
*
	cmp.w	d5,d4		;which is closer?
	bcc	dovlast 
*
*  we picked 1st or last endbrush..
*
dovfirst:
	moveq	#0,d1
	bra	compvert
dovlast:
	moveq	#-1,d1
compvert:
	move.w	d1,tempbuf+26
*
	move.w	(a3),d0
	lsl.w	#4,d0
	move.l	8(a5,d0.w),a6
	movem.w	4(a3),d2-d3
	tst.w	d1
	beq	cpvert0
	move.w	4(a6),d1	;get last index
cpvert0:
	mulu	#12,d1
	add.w	10(a6,d1.l),d2	;add relative h/v positions to 
	add.w	12(a6,d1.l),d3	;  get absolute hpos/vpos of endbrush
	move.w	6(a6,d1.l),d1	;  & get endbrush #
*
*  check vert position-order amongst the three
*
	cmp.w	6(a1),d3	;is top intrinsic above endbrush?
	bge	v123		;br if so
*
*  else, we do a3,a1,a2 order
*
	move.l	a0,(a4)+
	move.l	(a3)+,(a0)+	;copy brush & effects
	move.l	(a3)+,(a0)+	;use hpos/vpos
*
*  now a1 & a2 must use hpos in d2, a1 must use ypos at bottom of endbrush
*
	move.l	a0,(a4)+
	move.l	(a1)+,(a0)+
	lsl.w	#4,d1
	add.w	2(a5,d1.w),d3
	move.w	d2,(a0)+
	move.w	d3,(a0)+
*
	move.l	a0,(a4)+
	move.l	(a2)+,(a0)+
	move.w	d2,(a0)+
	addq.l	#2,a2
	move.w	(a2)+,(a0)+
*	
	move.w	#$8000,(a0)	;indicate stretch destination is intrinsic
	bra	wevclust
*
*  do a1,a2,a3 order
*	
v123:
	move.l	a0,(a4)+
	move.l	(a1)+,(a0)+
	move.w	d2,(a0)+
	addq.l	#2,a1
	move.w	(a1),(a0)+
*
	move.l	a0,(a4)+
	move.w	-8(a0),d1
	lsl.w	#4,d1
	move.w	2(a5,d1.w),d1
	add.w	(a1),d1
	move.l	(a2)+,(a0)+
	move.w	d2,(a0)+
	move.w	d1,(a0)+
*
	move.l	a0,(a4)+
	move.l	(a3)+,(a0)+
	move.l	(a3)+,(a0)+
*
	move.w	d3,(a0)	;save stretch destination into complex bridge
	bra	wevclust
*
***************************************************
*
*  All three are intrinsics--either left edge or top edge
*	
aggrnox:
*
	moveq	#4,d5		;check hpos
	bsr	chepsort
*
	movem.l	a1-a3,(a0)	;save horz sort order
	move.w	d3,d0
	sub.w	d1,d0		;d0 = max horz displacement
*
	moveq	#6,d5
	bsr	chepsort
*
	move.w	d3,d4
	sub.w	d1,d4		;d4 = max vert displacement
*
	cmp.w	d4,d0		;vert:horz max?
	ble	vertbrg		;br if this will be vert bridge
*
*  Horz bridge
*
	movem.l	(a0),a1-a3
*
	move.l	a0,(a4)+
	move.l	(a1)+,(a0)+	;copy brush/effects
	move.w	(a1)+,d0	;get xpos
	move.w	d0,(a0)+
	move.w	d0,xmin_clust	;adjust cluster xmin
	move.w	(a1)+,d0	;get ypos
	move.w	d0,(a0)+
	move.w	d0,ymin_clust	;adjust cluster ymin
*
	move.w	-8(a0),d1
	lsl.w	#4,d1
	move.w	2(a5,d1.w),d2	;get brush height
	add.w	d0,d2
	move.w	d2,ymax_clust
	move.w	(a5,d1.w),d2	;get 1st brush width
	add.w	-4(a0),d2
*
*
	move.l	a0,(a4)+
	move.l	(a2)+,(a0)+
	move.w	d2,(a0)+
	move.w	d0,(a0)+
*
	move.w	-8(a0),d1
	lsl.w	#4,d1
	move.w	2(a5,d1.w),d1	;get brush height
	add.w	d0,d1
	cmp.w	ymax_clust,d1
	ble	hbrid0
	move.w	d1,ymax_clust
hbrid0:
*
*
	move.l	a0,(a4)+
	move.l	(a3)+,(a0)+
	move.w	(a3)+,(a0)+
	move.w	d0,(a0)+
*
	move.w	-8(a0),d1
	lsl.w	#4,d1
	move.w	2(a5,d1.w),d1	;get brush height
	add.w	d0,d1
	cmp.w	ymax_clust,d1
	ble	hbrid1
	move.w	d1,ymax_clust
hbrid1:
	move.w	#$8000,(a0)	;indicate stretch destination is intrinsic
wehclust:
	bsr	clustit
*
	bsr	hstretch	;h-stretch the middle elemnt of 3-item cluster
*
	bsr	reclumsk	;rebuild cluster mask	
*
*  unwrap bridge d'bridges here..
*
*   We have three items bridged--expand deriveds
*
brid_unw:
	move.w	curbrush,d0
	lea	bshblock,a2
	lsl.w	#4,d0
	move.l	8(a2,d0.w),a3
	move.w	6(a3),d0	;get first endbrush
	cmp.w	maxintrins,d0	;is it derived
	bls	brid_un0	;br if not
*
*  1st endbrush is derived--check for cluster/bridge
*
	lsl.w	#4,d0
	move.l	8(a2,d0.w),a4
	move.w	4(a4),d1	;is this derived made up of multiples
	beq	brid_un0	;br if not
*
	add.w	d1,4(a3)	;increase cluster count
*
	movem.w	10(a3),d4-d6	;retain hpos/vpos base offset
*
	move.w	d1,d2
	mulu	#12,d2		;here's how much we need to add
*
	move.l	derblkend,a5
	lea	(a5,d2.l),a6
	move.l	a6,derblkend
*
	moveq	#5,d3
dervexp:
	move.l	-(a5),-(a6)	;move 2 intrinsics to end of list
	dbra	d3,dervexp
*
	suba.w	#12,a5		;go to head of (1st) derived entry
	lea	6(a4),a6	; & to head of corresponding cluster list
	moveq	#0,d3		;assume no adjust
	tst.w	tempbuf+26	;check first/last link endbrush
	bmi	dervx		;br if last was connect
	adda.l	d2,a6		;go to tail of cluster list
	move.w	#24,d3		;here's a new decrement value
dervx:
	move.l	(a6)+,(a5)+	;put in brush # & effects
	move.w	(a6)+,d2
	add.w	d4,d2
	move.w	d2,(a5)+
	move.w	(a6)+,d2
	add.w	d5,d2
	move.w	d2,(a5)+
	move.l	(a6)+,(a5)+
	suba.w	d3,a6
	dbra	d1,dervx
*
	bra	brid_unx	;we're all set
*
*   check for derived at last endbrush of this bridge
*
brid_un0:
	move.w	30(a3),d0	;get last endbrush
	cmp.w	maxintrins,d0
	bls	brid_unx	;exit if not derived
*
	lsl.w	#4,d0
	move.l	8(a2,d0.w),a4
	move.w	4(a4),d1	;is this derived made up of multiples
	beq	brid_unx	;br if not
*
	add.w	d1,4(a3)	;increase cluster count
*
	movem.w	34(a3),d4-d6	;retain hpos/vpos base offset
*
	move.w	d1,d2
	mulu	#12,d2		;here's how much we need to add
*
	move.l	derblkend,a5
	lea	(a5,d2.l),a6
	move.l	a6,derblkend
*
	suba.w	#12,a5		;go to head of (1st) derived entry
	lea	6(a4),a6	; & to head of corresponding cluster list
	moveq	#0,d3		;assume no adjust
	tst.w	tempbuf+26	;check first/last link endbrush
	bpl	dervxx		;br if first was connect
	adda.l	d2,a6		;go to tail of cluster list
	move.w	#24,d3		;here's a new decrement value
dervxx:
	move.l	(a6)+,(a5)+	;put in brush # & effects
	move.w	(a6)+,d2
	add.w	d4,d2
	move.w	d2,(a5)+
	move.w	(a6)+,d2
	add.w	d5,d2
	move.w	d2,(a5)+
	move.l	(a6)+,(a5)+
	suba.w	d3,a6
	dbra	d1,dervxx
*
brid_unx:
	bra	aggr_i
*
*
*
********************************************************
*  Horz stretch the middle item of a three item cluster
*
*	a0 -> base of graphics buffer
*
*   curbrush = derived brush of a 3 element cluster
*
hstretch:
	movem.l	a0-a1/d0-d3/d5,-(sp)

	move.w	curbrush,d0
	lea	bshblock,a2
	lsl.w	#4,d0
	move.w	14(a2,d0.w),d7	;cluster s_nxln
	move.l	8(a2,d0.w),a3	;get cluster elements ptr
	adda.w	#18,a3		;go for 2nd (bridging) element
	move.w	(a3),d0		;get bridge brush #
	move.w	#Hbridge,2(a3)	;stuff in a special effect
	lsl.w	#4,d0
	move.w	2(a2,d0.w),d5	;d5 = bridge height
	lsl.w	#2,d5
	move.w	6(a3),d1	;vpos of bridge element
	mulu	d7,d1
	adda.l	d1,a0
	move.w	(a2,d0.w),d0	;d0 = bridge intrinsic width
	move.w	d0,d4		;save in d4

	move.w	tempbuf+24,d1	;check for complex destination
	cmpi.w	#$8000,d1	;should we just use intrinsic?
	beq	hintrz
	sub.w	xmin_clust,d1
	bra	hintrz0
hintrz:	
	move.w	16(a3),d1	;d1 = hpos of last element
hintrz0:
	move.w	4(a3),d3	;d3 = hpos of bridge element
	add.w	d3,d4		;get dot addr +1 of rite bridge column
	move.w	d1,d2
	sub.w	d3,d2		;d2 = desired width
	swap	d0		;intrinsic width * 65536
	clr.w	d0
	divu	d2,d0		;get frac for DDA
	subq.w	#1,d0		;inc value
	move.w	d0,d3
	lsr.w	#1,d3		;d3 = initial DDA value
*
	subq.w	#1,d4		;adjust dot addr to ritemost bridge
	move.w	d4,d6
	lsr.w	#3,d6
	andi.w	#$fffe,d6
	lea	(a0,d6.w),a3	;SRC ptr
	not.w	d4
	andi.w	#$f,d4		;SRC bit # in word
*
	subq.w	#1,d1		;DST dot addr
	move.w	d1,d6
	lsr.w	#3,d6
	andi.w	#$fffe,d6
	lea	(a0,d6.w),a4	;DST ptr
	not.w	d1
	andi.w	#$f,d1		;DST bit # in word
	lsr.w	#2,d7		;get s_nxpl
	move.w	d0,a2
*
*
*	d0 =  <unused> 
*	d1 =  DST bit # in word
*	d2 =  desired (stretched) width
*	d3 =  DDA accum
*	d4 =  SRC bit # in word
*	d5 =  # of plane-lines to expand
*	d6 = <unused>
*	d7 =  s_nxpl
*
*	a2 = DDA inc
*	a3 -> SRC in form
*	a4 -> DST in form
*
	bra	hexpandi
hexpand:
	movem.l	a3-a4/d1-d4,-(sp)
	move.w	(a4),d6		; & DST word
	move.w	(a3),d0		;pick up SRC word
hexp:
	btst.l	d4,d0
	bne	hex2
hex0:
	subq.w	#1,d2
	bmi	hexi
	bclr.l	d1,d6
	addq.w	#1,d1
	andi.w	#$f,d1
	bne	hex1
	move.w	d6,(a4)
	move.w	-(a4),d6
hex1:
	add.w	a2,d3
	bcc	hex0
	addq.w	#1,d4
	andi.w	#$f,d4
	bne	hexp
	move.w	-(a3),d0
	bra	hexp
hex2:
	subq.w	#1,d2
	bmi	hexi
	bset.l	d1,d6
	addq.w	#1,d1
	andi.w	#$f,d1
	bne	hex3
	move.w	d6,(a4)
	move.w	-(a4),d6
hex3:
	add.w	a2,d3
	bcc	hex2
	addq.w	#1,d4
	andi.w	#$f,d4
	bne	hexp
	move.w	-(a3),d0
	bra	hexp
hexi:
	move.w	d6,(a4)
	movem.l	(sp)+,a3-a4/d1-d4
	adda.w	d7,a3
	adda.w	d7,a4
hexpandi:
	dbra	d5,hexpand
*
	movem.l	(sp)+,a0-a1/d0-d3/d5
	rts
*
*
*
*
*
*
*  Vert bridge
*
*    a1,a2 & a3 are the sorted element ptr's
*
vertbrg:
*
	move.l	a0,(a4)+
	move.l	(a1)+,(a0)+
	move.w	(a1)+,d0
	move.w	d0,xmin_clust
	move.w	d0,(a0)+
	move.w	(a1)+,d1
	move.w	d1,(a0)+
	move.w	d1,ymin_clust
*
	move.w	-8(a0),d1
	lsl.w	#4,d1
	move.w	(a5,d1.w),d2	;get brush width
	add.w	d0,d2
	move.w	d2,xmax_clust
	move.w	2(a5,d1.w),d2	;get height
	add.w	-2(a0),d2	;get vpos of next item
*
*
	move.l	a0,(a4)+
	move.l	(a2)+,(a0)+
	move.w	d0,(a0)+
	addq.l	#4,a2
	move.w	d2,(a0)+	;vpos of second just below 1st
*
	move.w	-8(a0),d1
	lsl.w	#4,d1
	move.w	(a5,d1.w),d1	;get brush width
	add.w	d0,d1
	cmp.w	xmax_clust,d1
	ble	vbrid0
	move.w	d1,xmax_clust
vbrid0:
*
*
	move.l	a0,(a4)+
	move.l	(a3)+,(a0)+
	move.w	d0,(a0)+
	addq.l	#2,a3
	move.w	(a3)+,(a0)+
*
	move.w	-8(a0),d1
	lsl.w	#4,d1
	move.w	(a5,d1.w),d1	;get brush width
	add.w	d0,d1
	cmp.w	xmax_clust,d1
	ble	vbrid1
	move.w	d1,xmax_clust
vbrid1:
	move.w	#$8000,(a0)
wevclust:
	bsr	clustit		;build it like any cluster
*
* preserve a0-a1/d0-d3/d5 here
*
	bsr	vstretch	;v-stretch the middle elemnt of 3-item cluster
*
	bsr	reclumsk	;rebuild cluster mask

	bra	brid_unw	;perform the bridge unwrap
*
*
********************************************************
*  Vert stretch the middle item of a three item cluster
*
*
*   curbrush = derived brush of a 3 element cluster
*
*
*  Must be called right after clustit
*
vstretch:
	movem.l	a0-a1/a6/d0-d3/d5,-(sp)
*
	move.w	curbrush,d0
	lea	bshblock,a2
	lsl.w	#4,d0
	move.l	8(a2,d0.w),a3	;get cluster elements ptr
	adda.w	#18,a3		;go for 2nd (bridging) element
	move.w	(a3),d0		;get bridge brush #
	move.w	#Vbridge,2(a3)	;stuff in a special effect
	movem.w	4(a3),d2-d3
	move.w	d3,d5
	lsl.w	#4,d0
	move.w	2(a2,d0.w),d4	;d4 = intrinsic height of bridge
	add.w	d4,d3		;d3 = vpos 1 line below bottom of bridge
	subq.w	#1,d3		;d3 = vpos of last line
	movem.w	d2-d3,d_xmin(a6)
	lea	s_xmin(a6),a0
	lea	d_xmin(a6),a1
	moveq	#6,d2
vstret0:
	move.w	(a1)+,(a0)+
	dbra	d2,vstret0
*
	move.l	#$03030303,op_tab(a6)
*
	move.w	(a2,d0.w),b_width(a6)	;set width of bridge element
	move.w	#1,b_height(a6)	;do 1 line at a time
*
	move.w	tempbuf+24,d1
	cmpi.w	#$8000,d1
	beq	vintrz
	sub.w	ymin_clust,d1
	bra	vintrz0	
vintrz:
	move.w	18(a3),d1	;d1 = vpos of last element, d3 = vpos bridge
vintrz0:
	move.w	d1,d0
	sub.w	d5,d0		;d0 = desired height
	subq.w	#1,d1
	move.w	d1,d_ymin(a6)
*
	swap	d4		;intrinsic height * 65536
	clr.w	d4
	divu	d0,d4		;get frac for DDA
	subq.w	#1,d4		;inc value
	move.w	d4,d3
	lsr.w	#1,d3		;d3 = initial DDA value

	bra	movslini
movslin:
	move.w	#4,plane_ct(a6)
	movem.l	a0-a6/d0-d7,-(sp)	
	.dc.w	bitblt
	movem.l	(sp)+,a0-a6/d0-d7
	subq.w	#1,d_ymin(a6)
	add.w	d4,d3		;check DDA
	bcc	movslini
	subq.w	#1,s_ymin(a6)
movslini:
	dbra	d0,movslin
*
*
	movem.l	(sp)+,a0-a1/a6/d0-d3/d5
	rts
*
********************************************
*
*
chepsort:
	move.w	(a1,d5.w),d1
	move.w	(a2,d5.w),d2
	move.w	(a3,d5.w),d3
*
	cmp.w	d2,d1
	ble	brid0
	exg	d1,d2
	exg	a1,a2
brid0:
	cmp.w	d3,d1
	ble	brid1
	exg	d1,d3
	exg	a1,a3
brid1:
	cmp.w	d3,d2
	ble	brid2
	exg	d3,d2
	exg	a3,a2
brid2:
	rts
*	
*
*  Hit escape key--abort
*
ag_abort:
	lea	cxit_msg,a0	;"Abort"
	bra	agxit
*
*  Close cluster select--& build the sucker
*
aggr_xit:
	move.w	aggreg,d7
	cmpi.b	#2,d7		;check for 1 or less selected
	bls	ag_abort	;abort if so
	cmpi.w	#3,d7		;check for 2 or less selected (bridge)
	bls	ag_abort	;abort if so
*	
	clr.l	brshfile	;tell 'em we need to sort painter's order
*
	bsr	clustit		;build a new cluster entry in derived
*
aggr_i:
	movem.l	a0/a1,-(sp)

	bsr	butninit
*
	bsr	makemsk
*
	moveq	#Arrow,d0
	bsr	Graf_Mouse
*
	movem.l	(sp)+,a0/a1
*
	move.l	a0,a3
	move.l	a1,a0
*
	lea	wstruct,a5
	movem.w	xmin_clust,d0-d1
*
	sub.w	xoffset(a5),d0
	add.w	wx(a5),d0
	sub.w	yoffset(a5),d1
	add.w	wy(a5),d1

	movem.w	d0-d1,bsh_x
*
	bra	bckdoorm	;start a move thru the back door
*
agxit:
	move.w	#WORLD,d0
	bsr	DaveInfo	;put up exit msg
*
	moveq	#Arrow,d0
	bsr	Graf_Mouse

	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*
*******************************************
*
*  Build a cluster
*
*
*  Entry:
*
*   a list of ptr's to the cluster elements is found in the brshfile
*	buffer if cluster file is read in; else the 1st longword
*	in brshfile buffer is zero & it is assumed that tempbuf has
*	the list which needs to be put in painter's order.
*
*	aggreg  = $8000 + (count-1) if cluster
*		=	+ (count-1) if bridge
*				 where "count" is # of elements
*
*	The following inputs define the size of the cluster:
*
*	xmin_clust
*	ymin_clust
*	xmax_clust
*	ymax_clust
*
*
*  Exit:
*		a0-> mono mask form
*		a1-> graphics form of new cluster brush  
clustit:
*
*  find size of form needed for this cluster
*
	movem.w	xmin_clust,d0-d3
	sub.w	d0,d2		;get width
	sub.w	d1,d3		;& height
*
	movem.w	d2-d3,bsh_wid
*
	lea	clustblt,a6	;it should be alright to use this
*
	move.w	d2,d4
	addi.w	#15,d4
	andi.w	#$fff0,d4
	lsr.w	#1,d4		;DST form-width
*
	move.w	#2,d_nxwd(a6)
	move.w	#2,s_nxwd(a6)
	move.w	d4,d_nxln(a6)
	move.w	d4,d5
	lsr.w	#2,d4
	move.w	d4,bsh_monoln
	move.w	d4,d_nxpl(a6)
	move.l	derivdend,a1	;base of DST form
	move.l	a1,d_form(a6)
	moveq	#0,d7
	move.l	d7,p_addr(a6)
	move.l	d7,s_xmin(a6)
*
	move.w	maxderivd,d7
	addq.w	#1,d7
	move.w	d7,maxderivd
	move.w	d7,curbrush
*
	lea	bshblock,a2
	lsl.w	#4,d7
	move.w	d2,(a2,d7.w)	;width
	move.w	d3,2(a2,d7.w)	;height
	move.l	a1,4(a2,d7.w)	;s_form
	move.l	derblkend,a3
	move.l	a3,8(a2,d7.w)	;derive block ptr
	move.w	d5,14(a2,d7.w)	;s_nxln
*	
	mulu	d3,d5		;d5 = grafix form size
	move.w	d5,12(a2,d7.w)	;mask-offset
*
	move.l	d5,d6
	lsr.l	#2,d6
	add.l	d5,d6		;form size (with mask)
	add.l	a1,d6		;add base to get end
	move.l	d6,derivdend	;Malloc for this dude
*
	lsr.l	#2,d5		;# of long words
	moveq	#0,d6
clusclr:
	move.l	d6,(a1)+	;clear out the cluster form
	dbra	d5,clusclr
*
	move.l	dstrngend,a4
	move.l	a4,(a3)+	;put in an id string
*
	lea	clustrng,a1
	move.w	aggreg,d7	;get count
	bclr.l	#15,d7
	bne	cluscp0
	lea	bridstrng,a1
cluscp0:
	sub.w	#2,d7

cluscp:
	move.b	(a1)+,(a4)+
	bne	cluscp
*
	move.l	a4,dstrngend	
*
	addi.b	#1,-2(a1)
*
	move.w	d7,(a3)+	;& a brush count (-1)
*
*  Now put selections in painters order
*
	move.w	d7,d4
	beq	buildc		;br if only one entry
*
	move.l	wblkptr,d3	;address beyond our limit 
	move.l	#worldblk,d2	;get address of lowest entry
*
	lea	brshfile,a1
	tst.l	(a1)		;are we already set in painter's order?
	bne	buildcc		;skip ordering stuff if so
*
blist:
	move.w	d7,d4
	lea	tempbuf,a0
nolist:
	cmp.l	(a0)+,d2
	beq	olist
	dbra	d4,nolist
	bra	nnolist
olist:
	move.l	d2,(a1)+
nnolist:
	addq.l	#8,d2
	cmp	d3,d2
	bcs	blist		
*
	move.l	-(a1),d2
	addq.l	#8,d2
	move.l	d2,wblkcur	;set priority 1 higher than highest
*
buildcc:
	lea	brshfile,a0
*	
buildc:
	move.l	(a0)+,a1	;get world entry ptr
	move.w	(a1)+,d4
	move.w	d4,(a3)+	;put in brush # (may be derived)
	clr.w	(a3)+		;no special effect
	addq.l	#2,a1		;skip special effects
	movem.w	(a1),d2-d3	;x/ypos
	sub.w	d0,d2		;xpos relative to cluster
	sub.w	d1,d3
	movem.w	d2-d3,(a3)
	addq.l	#8,a3		;adjust for next entry
	move.w	d2,d_xmin(a6)
	move.w	d3,d_ymin(a6)
*
	lsl.w	#4,d4		;get brush data
	move.w	(a2,d4.w),b_width(a6)
	move.w	2(a2,d4.w),b_height(a6)
	move.l	4(a2,d4.w),a4
	move.l	a4,-(sp)
	adda.w	12(a2,d4.w),a4	
	move.l	a4,s_form(a6)
	move.l	(sp)+,a4
	move.w	14(a2,d4.w),d2
	lsr.w	#2,d2
	move.w	d2,s_nxln(a6)
	clr.w	s_nxpl(a6)
*
	move.l	#$04040404,op_tab(a6)
	move.w	#4,plane_ct(a6)

	movem.l	a0/a2-a4/a6/d0-d1/d7,-(sp)
	.dc.w	bitblt	
	movem.l	(sp)+,a0/a2-a4/a6/d0-d1/d7

	move.l	a4,s_form(a6)
	move.l	#$07070707,op_tab(a6)
	move.w	#4,plane_ct(a6)
	move.w	s_nxln(a6),d2
	move.w	d2,s_nxpl(a6)
	add.w	d2,d2
	add.w	d2,d2
	move.w	d2,s_nxln(a6)

	movem.l	a0/a2-a4/a6/d0-d1/d7,-(sp)
	.dc.w	bitblt	
	movem.l	(sp)+,a0/a2-a4/a6/d0-d1/d7
	dbra	d7,buildc
*
	move.l	a3,derblkend		;save new derive block end
*
*   Now build mask
*
	move.l	d_form(a6),a0
	move.w	d_nxln(a6),d0
	move.w	d0,d6
	lsr.w	#2,d0
	move.w	d0,d5
	lsr.w	#1,d5
	subq.w	#1,d5			;d5 = # of words in line (-1)
*
	move.w	d0,d1
	add.w	d1,d1			;d1 = offset to plane #2
	move.w	d1,d2
	add.w	d0,d2			;d2 = offset to plane #3
	move.w	ymax_clust,d3
	sub.w	ymin_clust,d3		;get form height
	mulu	d3,d6
	lea	(a0,d6.l),a1
*
*  Enter here if we need to rebuild mask
*
reclumsk:
	movem.l	a0/a1/d3,-(sp)
	bra	clust_8i
clust_81:
	move.w	d5,d6
clust_82:
	move.w	(a0,d2.w),d4
	or.w	(a0,d1.w),d4
	or.w	(a0,d0.w),d4
	or.w	(a0)+,d4
	move.w	d4,(a1)+
	dbra	d6,clust_82	
	adda.w	d2,a0
clust_8i:
	dbra	d3,clust_81
*
	movem.l	(sp)+,a0/a1/d3
	rts
*
***********************************************
*
*
*
*   Build a rectangle fo' the people
*
dorect:
	movem.l	a0-a6/d0-d7,-(sp)
*
	moveq	#thincros,d0
	bsr	Graf_Mouse		;put up a thin cross
*
	clr.w	butt			;init 
*
	move.w	#1,rectwid
	move.w	#1,recthite
*	move.w	#15,rectcol
*
	lea	rectmsg,a0
	move.w	#WORLD,d0
	bsr	DaveInfo
*
rectlp:
	bsr	getmouse
	bsr	rectsel		;check keyboard for color change
	
	and	#1,d3		;any mouse button down yet
	beq	rectlp		;br if none
*
	bclr.b	#1,BUT_STATE+1
	bne	rectx0
*
	bclr.b	#0,BUT_STATE+1
	beq	rectlp
*
*  Qualify left click (must be on world window)
*
	move.l	mouseptr,a0
	movem.w	(a0),d0-d1	;save mouse position
	movem.w	d0-d1,-(sp)
	bsr	clipinit
	movem.w	(sp)+,d0-d1
	movem.w	d0-d1,(a0)	;restore mouse
	cmp.w	Mclpxmn,d0
	blt	rectlp		;mouse off the left side
	cmp.w	Mclpymn,d1
	blt	rectlp
	cmp.w	Mclpxmx,d0
	bge	rectlp
	cmp.w	Mclpymx,d1
	bge	rectlp
*
*  we're on the world window
*
	bsr	butninit
*
	move.w	maxderivd,d7
	addq.w	#1,d7
*
*	Build a brush block entry but don't allocate it yet
*
*	d7 = curbrush
*
rectloop:
	bsr	genarect	;generate a filled rectangle entry
	movem.l	a1/d7,-(sp)
*
	move.w	#LIBRARY,d0
	move.l	a4,a0
	bsr	DaveInfo
*
	movem.w	mousex,d0-d1
	movem.w	rectwid,d2-d3
	move.w	d2,d4
	lsr.w	#1,d4
	sub.w	d4,d0
	move.w	d3,d4
	lsr.w	#1,d4
	sub.w	d4,d1
	moveq	#0,d4
	movem.w	d0-d4,bsh_x
	lea	allones,a3
	move.w	rectcol,d5
	lea	(a3,d5.w),a0	;encode color in mask ptr
*
	bsr	bdisplay
	movem.l	(sp)+,a1/d7
*
momouse:
	bsr	getmouse
	bsr	rectsel		;respond to color select
*
	andi.w	#1,d3		;has button been released?
	beq	gotrect
*
	bclr.b	#1,BUT_STATE+1	;was it a right button
	bne	rectx1		;exit if so
*
	move.l	mouseptr,a2
	movem.w	(a2),d0-d1
	move.l	relcentx,(a2)
*
	move.w	d4,d3		;d4 = 0 if no color change
*
	sub.w	relcentx,d0	;get relative horz motion
	beq	rectlp3a
	addq.w	#1,d3
	add.w	rectwid,d0
	cmpi.w	#1,d0
	bge	rectlp2
	moveq	#1,d0
rectlp2:
	cmpi.w	#maxrectw,d0
	ble	rectlp3
	move.w	#maxrectw,d0
rectlp3:
	move.w	d0,rectwid
*
rectlp3a:
	sub.w	relcenty,d1	;get relative vert motion
	beq	rectlp5a
	addq.w	#1,d3
	add.w	recthite,d1
	cmpi.w	#1,d1
	bge	rectlp4
	moveq	#1,d1
rectlp4:
	cmpi.w	#maxrecth,d1
	ble	rectlp5
	move.w	#maxrecth,d1
rectlp5:
	move.w	d1,recthite
rectlp5a:
	tst.w	d3
	beq	momouse		;br if no move here
*
	bsr	pastund
	bra	rectloop
*
*   d0,d1 is screen hpos,vpos of cursor
*
rectx0:
*	move.l	mouseptr,a0
*	movem.w	(a0),d0-d1
	moveq	#1,d2
	moveq	#1,d3
	movem.w	d0-d3,bsh_x
	move.w	#-1,undhite	;tell pastund not to do anything
*
	move.w	#MouseOff,d0
	bsr	Graf_Mouse
rectx1:
	move.w	#Arrow,d0
	bsr	Graf_Mouse
*
	move.w	#WORLD,d0
	lea	rectabrt,a0
	bsr	DaveInfo
	bra	lib_xita
*
*
gotrect:
	move.l	a1,dstrngend
	add.l	#18,derblkend
	addq.w	#1,maxderivd
	move.w	maxderivd,curbrush
*
	moveq	#Arrow,d0
	bsr	Graf_Mouse
*
	lea	allones,a3
	move.w	rectcol,d5
	lea	(a3,d5.w),a0
	bra	lib_m	
*
*
rectsel:
	tst.w	d4		;check for any keys
	beq	rectselx
	cmpi.b	#"a",d4
	bcs	rectsel0
	subi.b	#$20,d4
rectsel0:
	subi.b	#"0",d4		;check for a color key
	bcs	rectselx	;br if not a 0-F
	cmpi.b	#10,d4		;is it 0-9?
	bcs	rectsel1	;br if so
	subi.b	#7,d4		
	cmpi.b	#10,d4
	bcs	rectselx
	cmpi.b	#16,d4
	bcc	rectselx
*
*  stuff the color
*
rectsel1:
	move.b	d4,rectcol+1
	moveq	#1,d4		;indicate a color change
	rts
rectselx:
	moveq	#0,d4		;no change
	rts
*
*
*  Generate the rect fill string
*
*    Entry:
*	d7 = curbrush
*	rectwid,recthite,rectcol are valid
*
*    Exit:
*	a1 -> end of fill ID string (+1) to save in dstrngend
*	a4 -> start of fill ID string (from dstrngend) 
genarect:
	lea	bshblock,a2
	move.w	d7,d0
	lsl.w	#4,d0
	movem.w	rectwid,d2-d4
	movem.w	d2-d3,(a2,d0.w)
	move.l	#allones,4(a2,d0.w)
	move.l	derblkend,a3
	move.l	a3,8(a2,d0.w)
	move.w	rectcol,12(a2,d0.w)	;save color in offset
	clr.w	14(a2,d0.w)	;s_nxln = 0
	move.l	dstrngend,a4	;we'll build a derived string
	move.l	a4,(a3)+
	clr.w	(a3)+		;object cnt = 0
	clr.w	(a3)+		;bsh # (not relevent)
	move.w	rectcol,d0
	lsl.w	#8,d0
	ori.w	#$8000,d0
	move.w	d0,(a3)+	;indicate effect + color
	clr.l	(a3)+
	move.l	a4,a1
	lea	rectstrg,a0
rectcp:
	move.b	(a0)+,(a1)+
	bne	rectcp
*
	subq.l	#1,a1
	move.w	d2,d0		;put out width
	movem.w	d3-d4,-(sp)
	bsr	decitpad
	movem.w	(sp)+,d3-d4
	move.w	#"0",d0
rectcp0:
	cmp.b	-(a1),d0
	bhi	rectcp0
	addq.l	#1,a1
	move.b	#":",(a1)+
	move.b	#"h",(a1)+
	move.w	d3,d0		;put out height
	move.w	d4,-(sp)
	bsr	decitpad
	move.w	(sp)+,d4
	move.w	#"0",d0
rectcp1:
	cmp.b	-(a1),d0
	bhi	rectcp1
	addq.l	#1,a1
	move.b	#":",(a1)+
	move.b	#"c",(a1)+
	move.w	d4,d0		;put out color
	bsr	decitpad
	move.w	#"0",d0
rectcp2:
	cmp.b	-(a1),d0
	bhi	rectcp2
	addq.l	#1,a1
	clr.b	(a1)+
	rts
*
*
*
*
allones:
	.dc.w	$ffff
*
rectstrg:
	.dc.b	"FILL/w",0,0
*	.dc.b	"FILL/w000:h000:c000  ",0
