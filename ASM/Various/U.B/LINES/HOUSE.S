***********************************
* house.s 19.1.86  Version 3.0
* House with hidden-line algorithm
***********************************

********************
* Compiler options *
********************
	opt	d+	dump debugging info

	SECTION	TEXT
	bra	sstart
*********************
* Library functions *
*********************
* GEMDOS *
call_bdos macro
	move	#\1,-(sp)
	trap	#1
	endm

call_bios macro
	move	#\1,-(sp)
	trap	#13
	endm

call_ebios macro
	move	#\1,-(sp)
	trap	#14
	endm

c_conin	macro
	call_bdos $1
	addq.l	#2,sp
	endm

c_rawcin macro
	call_bdos $7
	addq.l	#2,sp
	endm

c_conws	macro	text_addr
	move.l	\1,-(sp)
	call_bdos $9
	addq.l	#6,sp
	endm

m_shrink macro	reseverved_mem,addr_start
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move	#0,-(sp)
	call_bdos $4a
	add.l	#12,sp
	tst.l	d0
	endm

p_term	macro	value
	move	\1,-(sp)
	call_bdos $4c
	endm

* Trap #13
bconstat macro	device
	move	\1,-(sp)
	call_bios 1
	addq.l	#4,sp
	tst	d0
	endm

* Trap #14
_physbase macro
	call_ebios 2
	addq.l	#2,sp
	endm

_getrez	macro
	call_ebios 4
	addq.l	#2,sp
	endm

_setscreen macro	res,addr_phys,addr_log
	move	\1,-(sp)
	move.l	\2,-(sp)
	move.l	\3,-(sp)
	call_ebios 5
	add.l	#12,sp
	endm

* END OF GEMDOS *
* START OF AES *
apinit	clr.l	d0		* announces an application 
	move.l	d0,ap1resv
	move.l	d0,ap2resv
	move.l	d0,ap3resv
	move.l	d0,ap4resv
	move.w	#10,opcode
	move.w	#0,sintin
	move.w	#1,sintout
	move.w	#0,saddrout
	move.w	#0,saddrin
	jsr	aes
	move	intout,apid
	rts

appl_exit
	move.w	#19,contrl
	move.w	#0,sintin
	move.w	#1,sintout
	move.w	#0,saddrout
	move.w	#0,saddrin
	jsr	aes
	rts

grafhand
	move.w	#77,contrl	* Transfer screen handler 
	move.w	#0,contrl+2
	move.w	#5,contrl+4
	move.w	#0,contrl+6
	move.w	#0,contrl+8
	jsr	aes
	rts

openwork
	move.w	#100,opcode	* opens a workstation
	move.w	#1,d0
	move.w	#0,contrl+2
	move.w	#11,contrl+6
	move.w	g_handle,contrl+12
	move.w	d0,intin
	move.w	d0,intin+2
	move.w	d0,intin+4
	move.w	d0,intin+6
	move.w	d0,intin+8
	move.w	d0,intin+10
	move.w	d0,intin+12
	move.w	d0,intin+14
	move.w	d0,intin+16
	move.w	d0,intin+18
	move.w	#2,intin+20
	jsr	vdi
	rts

clwork	move.w	#3,contrl	* clear screen VDI function
	move.w	#0,contrl+2
	move.w	#1,contrl+6
	move.w	g_handle,contrl+12
	jsr	vdi
	rts

v_clsvwk move.w	#101,contrl
	move.w	#0,contrl+2
	move.w	#0,contrl+6
	move.w	v_handle,contrl+12
	jsr	vdi
	rts

mouse_on move.w	#122,contrl * enable mouse
	move.w	#0,contrl+2 * and control with
	move.w	#1,contrl+6 * operating system
	move.w	g_handle,contrl+12
	move.w	#0,intin
	jsr	vdi
	rts

mouse_off
	move.w	#123,contrl * Disable mouse
	move.w	#0,contrl+2 * and control
	move.w	#0,contrl+6
	move.w	g_handle,contrl+12
	jsr	vdi
	rts
* END OF AES *
****************************
* End of library functions *
****************************
*******************
* Programme start *
*******************
sstart	move.l	a7,a5		* Base page address on the stack
	move.l	4(a5),a5	* basepage address = program start - $100
	move.l	$c(a5),d0	* Program length
	add.l	$14(a5),d0	* Length of initialized data area
	add.l	$1c(a5),d0	* Data area not initialized
	add.l	#$1100,d0	* 4 K-byte user stack
	move.l	a5,d1		* Start address of the program
	add.l	d0,d1		* + No of occupied bytes = space requirement
	and.l	#-2,d1		* Even address for stack
	move.l	d1,a7		* User stack pointer to last 4K- byte

	m_shrink d0,a5
	jsr	apinit		* Announce program
	jsr	grafhand	* Get screen handler
	move.w	intout,g_handle
	jsr	openwork	* Display
	move	contrl+12,v_handle

	jsr	main		* Jump to main program (user-created)

	jsr	v_clsvwk
	jsr	appl_exit
	p_term	#0

main	jsr	start1		* Check on display address
	jsr	inlinea		* Initialize Line-A routines
	jsr	mouse_off	* Turn off mouse
	jsr	getreso		* what resolution ?
	jsr	setcocli	* Prepare clip window

	move.l	#houspla,worldpla * Address of surface array

	jsr	makewrld	* Create world system
	jsr	wrldset		* Pass world parameters

	jsr	setrotdp	* initialize observer ref. point
	jsr	clwork
	jsr	pagedown	* Display logical page
	jsr	clwork
	jsr	inp_chan	* Input and change parameters

mainlop1
	jsr	pointrot	* rotate about observer ref. point
	jsr	pers		* Perspective transformation
	jsr	hideit
	jsr	surfdraw

	jsr	pageup	* Display physical page
	jsr	inp_chan	* Input new parameters
	jsr	clwork
	jsr	pointrot	* Rotate around rotation ref. point
	jsr	pers		* Transform new points
	jsr	hideit
	jsr	surfdraw
	jsr	pagedown	* Display this logical page
	jsr	inp_chan	* Input and change parameters
	jsr	clwork		* erase physical page
	jmp	mainlop1	* to main loop

mainfin	move.l	physbase,logbase
	jsr	pageup		* switch to normal display page
	rts			* back to link file, and end

********************************************************************
* Input and change parameters such as angle increments and	 *
* Z-coordinate of the projection plane			 *
********************************************************************

inp_chan
	jsr	inkey		* Sense keyboard, keyboard code in
	cmp.b	#'D',d0
	bne	inpwait
	jsr	scrdmp		* Make harcopy

inpwait	swap	d0		* Test D0 for
	cmp.b	#$4d,d0		* Cursor-right
	bne	inp1
	addq.w	#1,ywplus	* if yes, then add one to
	bra	inpfin1		* Y-angle increment and continue

inp1	cmp.b	#$4b,d0		* Cursor-left, if yes
	bne	inp2		* then subtract one from
	subq.w	#1,ywplus	* Y-angle increment
	bra	inpfin1

inp2	cmp.b	#$50,d0		* Cursor-down, if yes
	bne	inp3
	addq.w	#1,xwplus	* then add one to X-angle increment
	bra	inpfin1

inp3	cmp.b	#$48,d0		* Cursor-up
	bne	inp3a
	subq.w	#1,xwplus	* subtract one
	bra	inpfin1

inp3a	cmp.b	#$61,d0	 	* Undo key
	bne	inp3b
	subq.w	#1,zwplus
	bra	inpfin1

inp3b	cmp.b	#$62,d0	 	* Help key
	bne	inp4
	addq.w	#1,zwplus
	bra	inpfin1

inp4	cmp.b	#$4e,d0	 	* + key on keypad
	bne	inp5		* if yes then subtract 25 from
	sub.w	#25,dist	* location of projection plane
	bra	inpfin1	 	* (Z-coordinate)
inp5	cmp.b	#$4a,d0		* - key on keypad
	bne	inp6		*
	add.w	#25,dist	* if yes then add 25
	bra	inpfin1

inp6	cmp.b	#$66,d0	 	* * key on keypad
	bne	inp7		* if yes, subtract 15 from the
	sub.w	#15,rotdpz	* rotation point Z-coordinate
	bra	inpfin1	 	* Make change

inp7	cmp.b	#$65,d0	 	* / key of keypad
	bne	uinp1
	add.w	#15,rotdpz	* Add 15
	bra	inpfin1

uinp1	cmp.b	#$6b,d0		* 5 key on keypad
	bne	uinp2		* if yes, subtract 25 from the
	sub.w	#25,proz	* z projection point
	bra	inpfin1		* Make change

uinp2	cmp.b	#$6e,d0		* 2 key of keypad
	bne	inp10
	add.w	#25,proz	* Add 25
	bra	inpfin1

inp10	cmp.b	#$44,d0	 	* F10 pressed ?
	bne	inpfin1
	addq.l	#4,a7	 	* if yes, jump to
	bra	mainfin	 	* program end

inpfin1	move.w	hyangle,d1	* Rotation angle about Y-axis
	add.w	ywplus,d1	* add increment
	cmp.w	#360,d1	 	* if larger than 360, subtract 360
	bge	inpfin2
	cmp.w	#-360,d1	* if smaller than 360
	ble	inpfin3		* add 360
	bra	inpfin4
inpfin2	sub.w	#360,d1
	bra	inpfin4
inpfin3	add.w	#360,d1

inpfin4	move.w	d1,hyangle

	move.w	hxangle,d1	* Treat
	add.w	xwplus,d1	* rotation angle about X-axis
	cmp.w	#360,d1		* in the same manner
	bge	inpfin5
	cmp.w	#-360,d1
	ble	inpfin6
	bra	inpfin7
inpfin5	sub.w	#360,d1
	bra	inpfin7
inpfin6	add.w	#360,d1

inpfin7	move.w	d1,hxangle

	move.w	hzangle,d1
	add.w	zwplus,d1
	cmp.w	#360,d1
	bge	inpfin8
	cmp.w	#-360,d1
	ble	inpfin9
	bra	inpfin10
inpfin8	sub.w	#360,d1
	bra	inpfin10
inpfin9	add.w	#360,d1

inpfin10 move.w	d1,hzangle
	rts

**********************************************************************
*	Initialize the rotation reference point to [0,0,0] and the	*
*	rotation angle also to 0,0,0				*
**********************************************************************

setrotdp move.w	#0,d1	 * set the start rotation-
	move.w	d1,rotdpx	* datum point
	move.w	d1,rotdpy
	move.w	d1,rotdpz
	move.w	#0,hyangle	* Start rotation angle
	move.w	#0,hzangle
	move.w	#0,hxangle
	rts

* Rotate the total world system around one point,
* the rotation reference point.
pointrot move.w	hxangle,xangle * rotate the world around the
	move.w	hyangle,yangle
	move.w	hzangle,zangle
	move.w	rotdpx,d0	* rotation reference point
	move.w	rotdpy,d1
	move.w	rotdpz,d2
	move.w	d0,xoffs	 * add for inverse transformation
	move.w	d1,yoffs
	move.w	d2,zoffs
	neg.w	d0
	neg.w	d1
	neg.w	d2
	move.w	d0,offx	 * subtract for transformation
	move.w	d1,offy
	move.w	d2,offz
	jsr	matinit	 * Matrix initialization
	jsr	zrotate	 * first rotate about Z-axis
	jsr	yrotate	 * rotate 'matrix' about Y-axis
	jsr	xrotate	 * then about X-axis
	jsr	rotate	* Multiply points with matrix
	rts

* Generate world system from object data. All points, lines,
* and surfaces are transferred to the world system
makewrld move.l	#housdatx,a1	* Generate world system by
	move.l	#housdaty,a2
	move.l	#housdatz,a3
	move.l	#wrldx,a4
	move.l	#wrldy,a5
	move.l	#wrldz,a6
	move.w	hnummark,d0
	ext.l	d0
	subq.l	#1,d0
makewl1	move.w	(a1)+,(a4)+	* Copying point coordinates
	move.w	(a2)+,(a5)+	* to world system
	move.w	(a3)+,(a6)+
	dbra	 d0,makewl1
	move.w	hnumline,d0	* Number of house lines
	ext.l	d0
	subq.l	#1,d0
	move.l	#houslin,a1
	move.l	#wlinxy,a2
makewl2	move.l	(a1)+,(a2)+	* Copy all lines into
	dbra	 d0,makewl2	 * world system

	move.l	worldpla,a0
	move.l	#wplane,a1
	move.w	hnumsurf,d0	 * Number of surfaces on house
	ext.l	d0
	subq.l	#1,d0

makewl3	move.w	(a0)+,d1	 * Copy all surface
	move.w	d1,(a1)+	 * definitions into the
	ext.l	d1		* world system
	subq.l	#1,d1

makewl4	move.l	(a0)+,(a1)+	* Copy every line of this
	dbra	 d1,makewl4	 * surface into the world array
	dbra	 d0,makewl3	 * until all surfaces are processed
	rts



***********************************************************************
*	Passing the world parameters to the link file variables	 *
***********************************************************************

wrldset	move.l	#wrldx,datx	* Pass variables for
	move.l	#wrldy,daty	* the rotation routine
	move.l	#wrldz,datz
	move.l	#viewx,pointx
	move.l	#viewy,pointy
	move.l	#viewz,pointz
	move.l	#wlinxy,linxy
	move.w	picturex,x0
	move.w	picturey,y0
	move.w	proz,zobs
	move.w	r1z1,dist
	move.l	#screenx,xplot
	move.l	#screeny,yplot
	move.w	hnumline,numline
	move.w	hnummark,nummark
	move.w	hnumsurf,numsurf
	rts

*****************************************************************
* remove all characters from the keyboard buffer		 *
*****************************************************************

clearbuf move.w	#$b,-(a7)
	trap	 #1
	addq.l	#2,a7
	tst.w	d0
	beq	clearnd
	move.w	#1,-(a7)
	trap	 #1
	addq.l	#2,a7
	bra	clearbuf

clearnd	rts


*********************************************************************
* Sense display resolution and set coordinate origin of screen	*
* to screen center					 *
*********************************************************************

getreso	move.w	#4,-(a7)	 * Sense screen resolution
 	trap	 #14
	addq.l	#2,a7
	cmp.w	#2,d0
	bne	getr1
	move.w	#320,picturex	* Monochrome monitor
	move.w	#200,picturey
	bra	getrfin
getr1	cmp.w	#1,d0
	bne	getr2
	move.w	#320,picturex	* medium resolution (640*200)
	move.w	#100,picturey
	bra	getrfin
getr2	move.w	#160,picturex	* low resolution (320*200)
	move.w	#100,picturey
getrfin	rts

***********************************************************************
*	Hardcopy routine, called by inp_chan			*
***********************************************************************

scrdmp	move.w	#20,-(a7)
	trap	 #14
	addq.l	#2,a7
	jsr	clearbuf
	rts

*********************************************************************
* Sets the limits of the display window for the Cohen-Sutherland
* clip algorithm built into the draw-line algorithm.
* The limits can be freely selected by the user, which makes the
* draw-line algorithm very flexible.
************************************

setcocli move.w	#0,clipxule
	move.w	#0,clipyule
	move.w	picturex,d1
	lsl.w	#1,d1		* times two
	subq.w	#1,d1		* minus one equal
	move.w	d1,clipxlri	* 639 for monochrome
	move.w	picturey,d1
	lsl.w	#1,d1		* times two minus one equal
	subq.w	#1,d1		* 399 for monochrome
	move.w	d1,clipylri
	rts

***********************************************************************
*	Recognition of hidden surfaces and entry of these into the
*	vplane array, the surface information is in the surface array
*	wplane, as well as in view system, viewx, viewy, viewz,
*	also the total number of surfaces must be passed in numsurf
***************************************************************

hideit
	move.w	numsurf,d0	* Number of surfaces as counter
	ext.l	d0
	subq.l	#1,d0
	move.l	#viewx,a1	* Store point coordinates here
	move.l	#viewy,a2
	move.l	#viewz,a3
	move.l	#wplane,a0	* Information for every surface
	move.l	#vplane,a5	* here.
	move.w	#0,surfcount	* counts the known visible surfaces.

visible	move.w	(a0),d1	 * start with first surface, number
	ext.l	d1	 * of points of this surface in D1.
	move.w	2(a0),d2	* Offset of first point of this surf.
	move.w	4(a0),d3	* Offset of second point
	move.w	8(a0),d4	* Offset of third point
	subq.w	#1,d2	 * for access to point arrays subtract
	subq.w	#1,d3	 * one from current point offset
	subq.w	#1,d4	 * multiply by two
	lsl.w	#1,d2
	lsl.w	#1,d3
	lsl.w	#1,d4	 * and finally access current point
	move.w	0(a1,d3.w),d6 * coordinates
	cmp.w	0(a1,d4.w),d6 * comparison recognizes two points
	bne	doit1	 * with same coordinates which can
	move.w	0(a2,d3.w),d6 * result during construction of
	cmp.w	0(a2,d4.w),d6 * rotation bodies. During recognition
	bne	doit1	 * of two points in which all point
	move.w	0(a3,d4.w),d6 * coordinates match (x,y,z) the
	cmp.w	0(a3,d3.w),d6 * program selects a third point for
	bne	doit1	 * determination of the two vectors
	move.w	12(a0),d4
	subq.w	#1,d4
	lsl.w	#1,d4

doit1
	move.w	0(a1,d3.w),d5	* Here the two vectors, which lie
	move.w	d5,kx	* in the surface plane, are
	sub.w	0(a1,d2.w),d5	* determined by subtracting the
	move.w	d5,px	* coordinates of two points 
	move.w	0(a2,d3.w),d5	* from this surface.
	move.w	d5,ky	* The direction coordinates of the
	sub.w	0(a2,d2.w),d5	* vectors are stored in the
	move.w	d5,py	* variables qx,qy,qz and px,py,pz
	move.w	0(a3,d3.w),d5
	move.w	d5,kz
	sub.w	0(a3,d2.w),d5
	move.w	d5,pz

	move.w	0(a1,d4.w),d5	* Calculate vector Q
	sub.w	0(a1,d2.w),d5
	move.w	0(a2,d4.w),d6
	sub.w	0(a2,d2.w),d6
	move.w	0(a3,d4.w),d7
	sub.w	0(a3,d2.w),d7
	move.w	d5,d1	* qx
	move.w	d6,d2	* qy
	move.w	d7,d3	* qz

	muls	 py,d3	* Calculate the cross product
	muls	 pz,d2	* of the vertical vector for the
	sub.w	d2,d3	* current surface.
	move.w	d3,rx
	muls	 pz,d1
	muls	 px,d7
	sub.w	d7,d1	* The direction coordinates of the
	move.w	d1,ry	* vertical vector are stored
	muls	 px,d6	* zobsorarily in rx,ry,rz
	muls	 py,d5
	sub.w	d5,d6
	move.w	d6,rz

	move.w	prox,d1	 * The projection center
	sub.w	kx,d1	* is used as the comparison
	move.w	proy,d2	 * point for the visibility
	sub.w	ky,d2	* of a surface.
	move.w	proz,d3	 * One can also use the
	sub.w	kz,d3	* observation ref. point
	muls	 rx,d1	* as the comparison point. Now comes
	muls	 ry,d2	* the comparison of vector R with
	muls	 rz,d3	* the vector from a point on the
	add.l	d1,d2	* surface to the projection center
	add.l	d2,d3	* for creating the scalar product
	bmi	dosight	 * of the two vectors.

* If the scalar product is negative, the surface is visible

	move.w	(a0),d1	 * Number of lines of the surface
	ext.l	d1
	lsl.l	#2,d1	* Number of lines times 4 = space for
	addq.l	#2,d1	* lines plus 2 bytes for the number of

	add.l	d1,a0	* lines added to surface array, for
sight1	dbra	 d0,visible	* access to next surface. When all
	bra	hidefin	 * surfaces completed then end.

dosight	move.w	(a0),d1	 * Number of lines for this surface,
	ext.l	d1		* gives the number of words to be 
	lsl.l	#1,d1	* transmitted when multiplied by 2.

sight3	move.w	(a0)+,(a5)+	* pass the number of lines and the
	dbra	 d1,sight3	 * the individual lines

	addq.w	#1,surfcount	* the number of surfaces plus one
	bra	sight1		* and process the next

hidefin	rts


********************************************************************
*	Draw visible surfaces passed in vplane			 *
********************************************************************

surfdraw
	move.l	xplot,a4	* draws a number of surfaces (passed
	move.l	yplot,a5	* in surfcount) whose description

	move.l	#vplane,a6	* is in the array at address
	move.w	surfcount,d0	* vplane, and was entered by routine
	ext.l	d0		* hideit
	subq.l	#1,d0	* if no surface is entered in the
	bmi	surffin	 * array, then end.
surflop1 move.w	(a6)+,d1	* Number of lines in this surface as
	ext.l	d1		* counter of lines to be drawn.
	subq.l	#1,d1

surflop2 move.l	(a6)+,d5		* First line of this surface
	subq.w	#1,d5		* Access screen array which contains
	lsl.w	#1,d5		* screen coordinates of the points.
	move.w	0(a4,d5.w),d2
	move.w	0(a5,d5.w),d3	* extract points from routine and
	swap	d5		* pass.
	subq.w	#1,d5
	lsl.w	#1,d5
	move.w	0(a4,d5.w),a2	* second point of line
	move.w	0(a5,d5.w),a3
	jsr	drawl		* Draw line until all lines of this
	dbra	d1,surflop2	* surface have been drawn and repeat
	dbra	d0,surflop1	* until all surfaces are drawn.
surffin	rts			* Return.

***********************************************
*	Pass upper screen page to video controller *
*	while drawing the other		*
***********************************************

pageup	move.w	#-1,-(a7)
	move.l	physbase,-(a7)	* Page displayed 
	move.l	logbase,-(a7)	* Draw on this page 
	move.w	#5,-(a7)
	trap	#14
	adda.l	#12,a7
	rts
*************************************************************
*	Display screen page at lower address, while all drawing	*
*	operations after the call go to the higher display	*
*************************************************************

pagedown move.w	#-1,-(a7)
	move.l	logbase,-(a7)	* display logical page 
	move.l	physbase,-(a7)	* draw in the other one
	move.w	#5,-(a7)
	trap	#14
	adda.l	#12,a7
	rts


************************************************************************
* Perspective, calculated from the transformed points in the arrays	*
* pointx, pointy and pointz the screen coordinates, which		*
* are then stored in the arrays xplot and yplot .			*
************************************************************************

pers	move.l	pointx,a1	* Beginning address of
	move.l	pointy,a2	* Point arrays
	move.l	pointz,a3
	move.l	xplot,a4	* xplot contains start address of the
	move.l	yplot,a5	* display coordinate array
	move.w	nummark,d0	* Number of points to be transformed
	ext.l	d0		* as counter
	subq.l	#1,d0

perlop	move.w	(a3)+,d5	* z-coordinate of object
	move.w	d5,d6
	move.w	dist,d4		* Enlargement factor
	sub.w	d5,d4		* dist minus Z-coordinate of Obj.coord
	ext.l	d4
	lsl.l	#8,d4		* times 256 for value fitting 
	move.w	zobs,d3		* Projection center Z-coordinates
	ext.l	d3

	sub.l	d6,d3		* minus Z-coordinate of object
	bne	pers1

	move.w	#0,d1		* Catch division by zero 
	addq.l	#2,a1		* Not really required since 
	addq.l	#2,a2		* computer catches this
	move.w	d1,(a4)+	* with an interrupt 
	move.w	d1,(a5)+
	bra	perend1

pers1	divs	d3,d4
	move.w	d4,d3
	move.w	(a1)+,d1	* X-coordinate of object
	move.w	d1,d2
	neg.w	d1
	muls	d1,d3		* multiplied by perspective factor 
	lsr.l	#8,d3		* /256 save value range fitting 

	add.w	d3,d2		* add to X-coordinate 
	add.w	x0,d2		* add screen offset (center point)
	move.w	d2,(a4)+	* Display X-coordinate
	move.w	(a2)+,d1	* Y-coordinates of object
	move.w	d1,d2
	neg.w	d1
	muls	d1,d4
	lsr.l	#8,d4		* /256

	add.w	d4,d2
	neg.w	d2		* Display offset, mirror of Y-axis
	add.w	y0,d2		* Source at [X0,Y0]
	move.w	d2,(a5)+	* Display Y-coordinate
perend1	dbra	d0,perlop	* All points transformed ?
	rts			* If yes, return

***********************************************************************
*	This subroutine calls AES functions, the user must	 *
*	save the Registers D0-D2 and A0-A2 before the aes call, *
*	which are used by VDI and AES	*
***********************************************************************

aes	 move.l	#aespb,d1	* call the AES functions
	move.w	#$c8,d0
	trap	 #2
	rts


***********************************************************************
*	call the VDI functions					*
***********************************************************************

vdi	 move.l	#vdipb,d1	* call the VDI functions
	move.w	#$73,d0
	trap	 #2
	rts


***********************************************************************
*	initialize the Line-A functions, pass the address of		*
*	Line-A variable area in A0, which is then stored		*
*	in lineavar						*
***********************************************************************

inlinea	dc.w	$a000
	move.l	a0,lineavar
	move.w	#0,32(a0)
	move.w	#$ffff,34(a0)
	move.w	#0,36(a0)
	move.w	#1,24(a0)
	rts


***********************************************************************
*	write string on screen		*
***********************************************************************

printf	move.l	a0,-(a7)	* write a string
	move.w	#9,-(a7)	* whose starting
	trap	#1		* is in A0, on the
	addq.l	#6,a7		* screen. String
	rts			* must end with a zero.

***********************************************************************
* Determine screen address				*
***********************************************************************

start1	_physbase
*\	move.w	#2,-(a7)	* Determine the screen
*\	trap	 #14		* address of the system
*\	addq.l	#2,a7	 	* which computer ?

	move.l	d0,physbase	* screen start minus 32 K-byte
	sub.l	#$8000,d0
	move.l	d0,logbase	* equals logical display page
	rts

************************************************************************
* Plot	routine	x-coordinate in d2, y-coordinate in d3		 *
************************************************************************

plotpt	movem.l	d0-d2/a0-a2,-(a7)
	tst.w	d2		* X-value less than zero =>
	bmi	 stop2
	tst.w	d3		* Y-value less zero
	bmi	 stop2
	cmp.w	#639,d2	 * X-value greater than 639?
	bhi	 stop2	* Display limit 
	cmp.w	#399,d3	 * Y-value greater than 399?
	bhi	 stop2
	move.w	d2,ptsin
	move.w	d3,ptsin+2
	move.w	#1,intin
	dc.w	$a001
	movem.l	(a7)+,d0-d2/a0-a2
stop2	rts


**********************************************************************
* draw-line routine with Cohen-Sutherland clipping. The points are	*
* passed in d2, d3 (start point) and a2, a3 (end point)		 *
**********************************************************************

drawl	movem.l	d0-d7/a0-a6,-(a7)	* Save registers
	move.w	d2,d6		* Determine position
	move.w	d3,d7		* of start point and
	jsr	rel_pos		* store
	move.w	d1,code1
	move.w	a2,d6		* Position of second 
	move.w	a3,d7		* point and store
	jsr	rel_pos
	move.w	d1,code2
	tst.w	d1		* if points are not in
	bne	testw1		* drawing area continue
	tst.w	code1		* test. Otherwise test
	beq	drawit2		* first point. When visible,
*				 * draw both points

testw1	move.w	d1,d0		* If both points on the same
	and.w	code1,d0	 * 'page' outside the viewing
	bne	drawend		* window, then do not draw,
	move.w	d2,a0		* else store starting points and
	move.w	d3,a1		* calculate intersecting points
	move.w	a2,a4
	move.w	a3,a5

	tst.w	code2		* is point 2 visible ?
	bne	testw2		* if not, find intersection point
	move.w	a2,rightx	* if yes, store
	move.w	a3,righty
	bra	testw3		* find left intersect point

testw2	move.w	code1,p1code	* right intersect point
	move.w	code2,p2code
	jsr	fndpoint	 * find intersect point
	tst.w	p1code		* if 'intersect point'not
	bne	drawend		* visible, then end

	move.w	d2,rightx	* if visible, then store
	move.w	d3,righty

testw3	move.w	a4,d2		* and the left intersect point
	move.w	a5,d3		* with switched points
	move.w	a0,a2		* determine with the same routine
	move.w	a1,a3
	move.w	code2,p1code
	move.w	code1,p2code

	tst.w	p2code		* Point visible?
	bne	testw4		* if not, continue test
	move.w	a2,leftx	 * if yes, store and
	move.w	a3,lefty	 * connect both visible
	bra	drawit1		* points with a line

testw4	jsr	fndpoint	 * Find intersect point
	move.w	d2,leftx	 * and store,
	move.w	d3,lefty

drawit1	move.w	leftx,d2	 * connect both points with
	move.w	lefty,d3	 * a line
	move.l	#0,a2
	move.l	#0,a3
	move.w	rightx,a2
	move.w	righty,a3

drawit2	move.l	lineavar,a0
	move.w	d2,38(a0)	* X1
	move.w	d3,40(a0)	* Y1
	move.w	a2,42(a0)	* X2
	move.w	a3,44(a0)	* Y2
	dc.w	$a003		* Draw line
drawend
endit	movem.l (a7)+,d0-d7/a0-a6	* Restore registers
	rts			 * Return to calling program

**********************************************************************
*	recognizes the position of a point passed in D6 and D7 relative	*
*	to the clip window defined in the variables clipoli and clipure	*
**********************************************************************

rel_pos	clr.l	d1		* determines the position
	move.w	d7,d1	* of the point passed in
	sub.w	clipyule,d1	* d6 and d7 relative to
	lsl.l	#1,d1	* the drawing window
	move.w	d7,d1	* defined by clipure
	sub.w	clipylri,d1	* and clipoli
	neg.w	d1
	lsl.l	#1,d1
	move.w	d6,d1
	sub.w	clipxlri,d1
	neg.w	d1
	lsl.l	#1,d1
	move.w	d6,d1
	sub.w	clipxule,d1
	lsl.l	#1,d1
	swap	 d1
	rts


**********************************************************************
*	Finds the intersect point, if present,			 *
*	of the the connecting line from P1 to P2 with the clip window	*
*	the points are passed in D2, D3 and A2, A3 as in drawl		*
**********************************************************************

fndpoint move.w	d2,d4	* Find the center point of
	move.w	d3,d5	* the line P1 P2
	add.w	a2,d4	* (X1 + X2) / 2
	ext.l	d4

	lsr.l	#1,d4
	add.w	a3,d5	* (Y1 + Y2) / 2
	ext.l	d5	 * = center point of line P1 P2

	lsr.l	#1,d5
	move.w	d4,d6	* Store center point coord. 
	move.w	d5,d7	* Y middle 
	jsr	rel_pos	* where is the intersect point ?

	move.w	p2code,d6 * Code of center pt. to D6
	and.w	d1,d6	* are the points on the same
	bne	fother	* page outside the screen

	cmp.w	d4,d2	* points coincide ?
	bne	findw1
	cmp.w	d5,d3
	beq	fendit	* if yes => stop

findw1	cmp.w	d4,a2	* Do middle point and second
	bne	findw2	* point match ?
	cmp.w	d5,a3
	bne	findw2
	bra	fendit	* if yes = stop

findw2	move.w	d4,d2	* else exchange middle and
	move.w	d5,d3	* first point and start again
	move.w	d1,p1code
	bra	fndpoint

fother	cmp.w	d4,a2	* middle point and P2 match ?
	bne	fother1
	cmp.w	d5,a3
	beq	fendit	* if yes, then end
fother1	cmp.w	d4,d2	* middle point and P1 match ?
	bne	fother2
	cmp.w	d5,d3
	beq	fendit	* if yes, then end

fother2	tst.w	p1code	* is P1 in clip window
	beq	fother3
	move.w	d1,d7	* if not, and P1 and P2 lie
	and.w	p1code,d7 * both on one side of the
	bne	fexit	* Clip-window then none of line is visible
fother3	move.w	d4,a2	* otherwise take middle point
	move.w	d5,a3	* as new P2 and start again
	move.w	d1,p2code * until the intersect point
	bra	fndpoint	* is found

fexit	move.w	#1,p1code * Inform calling prog. of termination.

fendit	rts		 * either in d2,d3 middle point, or
*				* in p1code termination notice


******************************************************************
* sine and cosine Function, angle is passed in D0 and		*
* the sine and cosine are returned in D1 and D2		 *
******************************************************************

sincos	tst.w	d0		* Angle negative, add 360 degrees
		bpl	noaddi
		add.w	#360,d0
noaddi	move.l	#sintab,a1	* Beginning address of sine table
		move.l	d0,d2		* Angle in d0 and d2
		lsl.w	#1,d0		* Angle times two as index for access
		move.w	0(a1,d0.w),d1 * sine to d1
		cmp.w	#270,d2	* Calculate cosine through
		blt	plus9		* displacement of sine values
		sub.w	#270,d2	* by 90 degrees
		bra	sendsin
plus9	add.w	#90,d2
sendsin lsl.w	#1,d2
		move.w	0(a1,d2.w),d2 * cosine to d2

		rts			* and back to calling program


********************************************************************
*	sine	function						*
*	Angle is passed in d0 and the sine returned in d1		*
********************************************************************

sin	move.l	#sintab,a1
		tst.w	d0
		bpl	 sin1
		add.w	#360,d0
sin1	lsl.w	#1,d0
		move.w	0(a1,d0.w),d1
		rts


************************************************************************
* Initialize the main diagnonal of the result matrix with		*
* ones which were multiplied by 2^14.	This subroutine must		*
* be called at least once before the call by rotate, or the		*
* result matrix will only consist of zeros.			 *
************************************************************************

matinit	move.w	#0,d1
	move.w	#16384,d2	* The initial value for
	move.w	d2,matrix11	* the main diagonal of
	move.w	d1,matrix12	* the result matrix 
	move.w	d1,matrix13	* all other elements
	move.w	d1,matrix21	* at zero
	move.w	d2,matrix22
	move.w	d1,matrix23
	move.w	d1,matrix31
	move.w	d1,matrix32
	move.w	d2,matrix33
	rts



************************************************************************
*	Multiplication of the rotation matrix by the rotation		*
*	matrix for rotation about the X-axis				*
************************************************************************

xrotate	move.w	xangle,d0	* multiply matrix11-matrix33
	jsr	sincos		* with the rotation matrix for a
	move.w	d1,sinx		* rotation about the X-axis
	move.w	d2,cosx
	move.w	d1,d3
	move.w	d2,d4
	move.w	matrix11,rotx11	* The first column of the matrix
	move.w	matrix21,rotx21	* does not change with X rotation
	move.w	matrix31,rotx31	
	muls	 matrix12,d2
	muls	 matrix13,d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	 d2
	move.w	d2,rotx12
	move.w	d3,d1
	move.w	d4,d2
	muls	 matrix22,d2
	muls	 matrix23,d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	 d2
	move.w	d2,rotx22
	move.w	d3,d1
	move.w	d4,d2
	muls	 matrix32,d2
	muls	 matrix33,d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	 d2
	move.w	d2,rotx32
	move.w	d3,d1
	move.w	d4,d2
	muls	 matrix12,d1
	muls	 matrix13,d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	 d2
	move.w	d2,rotx13
	move.w	d3,d1
	move.w	d4,d2
	muls	 matrix22,d1
	muls	 matrix23,d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	 d2
	move.w	d2,rotx23
	muls	 matrix32,d3
	muls	 matrix33,d4
	add.l	d3,d4
	lsl.l	#2,d4
	swap	 d4
	move.w	d4,rotx33
	move.l	#rotx11,a1
	move.l	#matrix11,a2
	move.l	#9,d7		* Number of matrix elements
	subq.l	#1,d7

rotxlop1 move.w	(a1)+,(a2)+	 * Copy result matrix, which
	dbra	 d7,rotxlop1	 * is still in ROTXnn, to MATRIXnn
	rts

***********************************************************************
* multiply the general rotation matrix by the Y-axis		 *
* rotation matrix. Results are stored in the general		 *
* rotation matrix						*
***********************************************************************

yrotate	move.w	yangle,d0	 * Angle around which rotation is made
	jsr	sincos
	move.w	d1,siny
	move.w	d2,cosy
	move.w	d1,d3	 * Sine of Y-angle
	move.w	d2,d4	 * Cosine of Y-angle
	muls	 matrix11,d2
	muls	 matrix13,d1
	add.l	d1,d2
	lsl.l	#2,d2
	swap	 d2
	move.w	d2,rotx11
	move.w	d3,d1
	move.w	d4,d2
	muls	 matrix21,d2
	muls	 matrix23,d1
	add.l	d1,d2
	lsl.l	#2,d2
	swap	 d2
	move.w	d2,rotx21
	move.w	d3,d1
	move.w	d4,d2
	muls	 matrix31,d2
	muls	 matrix33,d1
	add.l	d1,d2
	lsl.l	#2,d2
	swap	 d2
	move.w	d2,rotx31
	neg.w	d3
	move.w	d3,d1		* -siny in the rotation matrix
	move.w	d4,d2
	move.w	matrix12,rotx12
	move.w	matrix22,rotx22	* The second column
	move.w	matrix32,rotx32	* of the starting
	muls	 matrix11,d1		* matrix does not
	muls	 matrix13,d2		* change
	add.l	d1,d2
	lsl.l	#2,d2
	swap	 d2
	move.w	d2,rotx13
	move.w	d3,d1
	move.w	d4,d2
	muls	 matrix21,d1
	muls	 matrix23,d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	 d2
	move.w	d2,rotx23
	muls	 matrix31,d3
	muls	 matrix33,d4
	add.l	d3,d4
	lsl.l	#2,d4
	swap	 d4
	move.w	d4,rotx33
	move.l	#8,d7
	move.l	#rotx11,a1	* Address of result matrix
	move.l	#matrix11,a2	 * Address of original matrix
yrotlop1 move.w	(a1)+,(a2)+		* Copy result matrix
	dbra	 d7,yrotlop1		* to the original matrix
	rts

***********************************************************************
* Z-axis - Rotation matrix multiplications			 *
***********************************************************************

zrotate	move.w	zangle,d0
	jsr	sincos
	move.w	d1,sinz
	move.w	d2,cosz
	move.w	d1,d3
	move.w	d2,d4
	muls	 matrix11,d2
	muls	 matrix12,d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	 d2
	move.w	d2,rotx11
	move.w	d3,d1
	move.w	d4,d2
	muls	 matrix21,d2
	muls	 matrix22,d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	 d2
	move.w	d2,rotx21
	move.w	d3,d1
	move.w	d4,d2
	muls	 matrix31,d2
	muls	 matrix32,d1
	sub.l	d1,d2
	lsl.l	#2,d2
	swap	 d2
	move.w	d2,rotx31
	move.w	d3,d1
	move.w	d4,d2
	muls	 matrix11,d1
	muls	 matrix12,d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	 d2
	move.w	d2,rotx12
	move.w	d3,d1
	move.w	d4,d2
	muls	 matrix21,d1
	muls	 matrix22,d2
	add.l	d1,d2
	lsl.l	#2,d2
	swap	 d2
	move.w	d2,rotx22
	muls	 matrix31,d3
	muls	 matrix32,d4
	add.l	d3,d4
	lsl.l	#2,d4
	swap	 d4
	move.w	d4,rotx32
	move.w	matrix13,rotx13	* the third column
	move.w	matrix23,rotx23	* remains
	move.w	matrix33,rotx33	* unchanged
	move.l	#8,d7
	move.l	#rotx11,a1
	move.l	#matrix11,a2

zrotlop1 move.w	(a1)+,(a2)+		* copy to general
	dbra	 d7,zrotlop1		* rotation matrix
	rts

**********************************************************************
* Multiply every point whose Array address is in datx etc.	 *
* by previous translation of the coordinate source to		 *
* point [offx,offy,offz], with the general rotation matrix.	*
* The coordinate source of the result coordinates is then		*
* moved to point [xoffs,yoffs,zoffs]				*
**********************************************************************

rotate	move.w	nummark,d0	* Number of points to be
	ext.l	d0		* transformed as counter
	subq.l	#1,d0 
	move.l	datx,a1
	move.l	daty,a2
	move.l	datz,a3
	move.l	pointx,a4
	move.l	pointy,a5
	move.l	pointz,a6
rotate1	move.w	(a1)+,d1	* X-coordinate
	add.w	offx,d1

	move.w	d1,d4
	move.w	(a2)+,d2	 * Y-coordinate
	add.w	offy,d2	* Translation to point [offx,offy,offz]
	move.w	d2,d5
	move.w	(a3)+,d3	 * Z-coordinate
	add.w	offz,d3

	move.w	d3,d6
	muls	 matrix11,d1
	muls	 matrix21,d2
	muls	 matrix31,d3
	add.l	d1,d2
	add.l	d2,d3
	lsl.l	#2,d3
	swap	 d3
	add.w	xoffs,d3

	move.w	d3,(a4)+	 * rotated X-coordinate
	move.w	d4,d1
	move.w	d5,d2
	move.w	d6,d3
	muls	 matrix12,d1
	muls	 matrix22,d2
	muls	 matrix32,d3
	add.l	d1,d2
	add.l	d2,d3
	lsl.l	#2,d3
	swap	 d3
	add.w	yoffs,d3

	move.w	d3,(a5)+	 * rotated Y-coordinate
	muls	 matrix13,d4
	muls	 matrix23,d5
	muls	 matrix33,d6
	add.l	d4,d5
	add.l	d5,d6
	lsl.l	#2,d6
	swap	 d6
	add.w	zoffs,d6

	move.w	d6,(a6)+	 * rotated Z-coordinate
	dbra	 d0,rotate1
	rts



******************************************************************
* Draw number of lines from array from lines in linxy	 *
******************************************************************

drawn1 move.l	xplot,a4	 * Display X-coordinate
	 move.l	yplot,a5	 *	"	Y-coordinate
	 move.w	numline,d0		* Number of lines	
	 ext.l	d0
	 subq.l	#1,d0		* as counter
	 move.l	linxy,a6	 * Address of line array

drlop	move.l	(a6)+,d1	 * first line ,(P1,P2)
	 subq.w	#1,d1		* fit to list structure
	 lsl.w	#1,d1		* times list element length (2)
	 move.w	0(a4,d1.w),d2	 * X-coordinate of second point
	 move.w	0(a5,d1.w),d3	 * Y-coordinate of second point
	 swap	d1		* same procedure for first point
	 subq.w	#1,d1
	 lsl.w	#1,d1
	 move.w	0(a4,d1.w),a2	 * X-coordinate of	first point
	 move.w	0(a5,d1.w),a3	 * Y-coordinate of first point
	 jsr	drawl		* draw line from P2 to P2
	 dbra	d0,drlop	 * All lines drawn ?
	 rts



*****************************************************************
*	simple counting loop					*
*****************************************************************

wait1	dbra	 d0,wait1	* delay loop, counts d0 register
	rts			* down to -1

*****************************************************************
*	wait for key press, for Test and Error detection	*
*****************************************************************

wait	move.w	#1,-(a7)	* wait for key activation
	trap	 #1		* GEM DOS call
	addq.l	#2,a7
	rts
*************************************************************************
*	Key sensing, ASCII code returned in lower byte word of D0	*
*	Scan code in upper sord lower byte of D0			*
*	Returns zero if no input					*
*************************************************************************

inkey	move.w	#2,-(a7)	* Key sensing, does not
	move.w	#1,-(a7)	* wait for a key
	trap	 #13		* press
	addq.l	#4,a7
	tst.w	d0
	bpl	endkey
	move.w	#7,-(a7)
	trap	 #1
	addq.l	#2,a7
endkey	rts


 ********************************************************
**********************************************************
** The six following subroutines are only required	**
** for the second main program and do not have to be	**
** entered for linking to the first main program	**
**********************************************************
 ********************************************************

filstyle move.w	#23,contrl		* VDI function, set
	move.w	#0,contrl+2		* fill style passed
	move.w	#1,contrl+6		* in D0
	move.w	g_handle,contrl+12
	move.w	d0,intin
	jsr	vdi
	rts

filindex movem.l d0-d2/a0-a2,-(a7)	* set fill pattern

	move.w	#24,contrl		* also passed in D0

	move.w	#0,contrl+2
	move.w	#1,contrl+6
	move.w	g_handle,contrl+12
	move.w	d0,intin
	jsr	vdi
	movem.l	(a7)+,d0-d2/a0-a2
	rts

filcolor move.w	#25,contrl		* set fill color to
	move.w	#0,contrl+2
	move.w	#1,contrl+6
	move.w	g_handle,contrl+12
	move.w	#1,intin		* one
	jsr	vdi
	rts

filmode	move.w	#32,contrl		* set write mode 
	move.w	#0,contrl+2
	move.w	#1,contrl+6
	move.w	g_handle,contrl+12 * passed in D0 
	move.w	d0,intin
	jsr	vdi
	rts

filform	move.w	#104,contrl	 * switch on border
	move.w	#0,contrl+2	 * around area
	move.w	#1,contrl+6
	move.w	g_handle,contrl+12
	move.w	#1,intin
	jsr	vdi
	rts


*********************************************************************
* Rotation of a number of points (nummark) in array datx etc. around*
* angle yangle around Y-axis to array pointx = address of array	*
*********************************************************************

yrot	move.w	yangle,d0	* rotate the definition line
	jsr	sincos		* of a rotation body nummark
	move.w	d1,siny		* times about the Y-axis 
	move.w	d2,cosy		* Rotation is done without 
	move.l	datx,a1		* matrix multiplication, 
	move.l	daty,a2		* but directly, from arrays datx
	move.l	datz,a3		* in which the address of the definition
	move.l	pointx,a4	* line was stored into the array 
	move.l	pointy,a5	* whose address is stored
	move.l	pointz,a6	* in pointx etc.
	move.w	nummark,d0
	ext.l	d0		* the rotation is about
	subq.l	#1,d0		* angle -y, i.e. from direction 
ylop	move.w	(a1)+,d1	* positive Y-axis 
	move.w	d1,d3		* counterclockwise 
	move.w	(a3)+,d2
	move.w	d2,d4		* z' = x*siny + z*cosy
	muls	 cosy,d2
	lsl.l	#2,d2		* retract area extension
	swap	 d2		* sine values
	muls	 siny,d1
	lsl.l	#2,d1
	swap	 d1
	add.w	d1,d2
	move.w	d2,(a6)+	* store z'
	muls	 siny,d4	* calculate x'
	lsl.l	#2,d4		* x' = x*cosy - z*siny
	swap	 d4
	neg.w	d4
	muls	 cosy,d3
	lsl.l	#2,d3
	swap	 d3
	add.w	d3,d4

	move.w	d4,(a4)+	* store x'
	move.w	(a2)+,(a5)+	* y' = y, since rotation is
	dbra	 d0,ylop	* around Y-axis
	rts

	SECTION	DATA
***********************************
* Variables for the basic program *
***********************************

sintab	dc.w	0,286,572,857,1143,1428,1713,1997,2280
	dc.w	2563,2845,3126,3406,3686,3964,4240,4516
	dc.w	4790,5063,5334,5604,5872,6138,6402,6664
	dc.w	6924,7182,7438,7692,7943,8192,8438,8682
	dc.w	8923,9162,9397,9630,9860,10087,10311,10531
	dc.w	10749,10963,11174,11381,11585,11786,11982,12176
	dc.w	12365,12551,12733,12911,13085,13255,13421,13583
	dc.w	13741,13894,14044,14189,14330,14466,14598,14726
	dc.w	14849,14962,15082,15191,15296,15396,15491,15582
	dc.w	15668,15749,15826,15897,15964,16026,16083,16135
	dc.w	16182,16225,16262,16294,16322,16344,16362,16374
	dc.w	16382,16384

	dc.w	16382,16374,16362,16344,16322,16294,16262,16225
	dc.w	16182
	dc.w	16135,16083,16026,15964,15897,15826,15749,15668
	dc.w	15582,15491,15396,15296,15191,15082,14962,14849
	dc.w	14726,14598,14466,14330,14189,14044,13894,13741
	dc.w	13583,13421,13255,13085,12911,12733,12551,12365
	dc.w	12176,11982,11786,11585,11381,11174,10963,10749
	dc.w	10531,10311,10087,9860,9630,9397,9162,8923
	dc.w	8682,8438,8192,7943,7692,7438,7182,6924
	dc.w	6664,6402,6138,5872,5604,5334,5063,4790
	dc.w	4516,4240,3964,3686,3406,3126,2845,2563
	dc.w	2280,1997,1713,1428,1143,857,572,286,0

	dc.w	-286,-572,-857,-1143,-1428,-1713,-1997,-2280
	dc.w	-2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
	dc.w	-4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
	dc.w	-6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682
	dc.w	-8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
	dc.w	-10749,-10963,-11174,-11381,-11585,-11786,-11982
	dc.w	-12176
	dc.w	-12365,-12551,-12733,-12911,-13085,-13255,-13421
	dc.w	-13583
	dc.w	-13741,-13894,-14044,-14189,-14330,-14466,-14598
	dc.w	-14726
	dc.w	-14849,-14962,-15082,-15191,-15296,-15396,-15491
	dc.w	-15582
	dc.w	-15668,-15749,-15826,-15897,-15964,-16026,-16083
	dc.w	-16135
	dc.w	-16182,-16225,-16262,-16294,-16322,-16344,-16362
	dc.w	-16374,-16382,-16384

	dc.w	-16382,-16374,-16362,-16344,-16322,-16294,-16262
	dc.w	-16225,-16182
	dc.w	-16135,-16083,-16026,-15964,-15897,-15826,-15749
	dc.w	-15668
	dc.w	-15582,-15491,-15396,-15296,-15191,-15082,-14962
	dc.w	-14849
	dc.w	-14726,-14598,-14466,-14330,-14189,-14044,-13894
	dc.w	-13741
	dc.w	-13583,-13421,-13255,-13085,-12911,-12733,-12551
	dc.w	-12365
	dc.w	-12176,-11982,-11786,-11585,-11381,-11174,-10963
	dc.w	-10749
	dc.w	-10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
	dc.w	-8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
	dc.w	-6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
	dc.w	-4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
	dc.w	-2280,-1997,-1713,-1428,-1143,-857,-572,-286,0

vdipb	dc.l	contrl,intin,ptsin,intout,ptsout
aespb	dc.l	contrl,global,intin,intout,addrin,addrout

leftx	dc.w	0
lefty	dc.w	0
rightx	dc.w	0
righty	dc.w	0

p1code		dc.w	0
p2code		dc.w	0
code1		dc.w	0
code2		dc.w	0
mid_code	dc.w	0

clipxule	dc.w	0	* Clip window variables
clipyule	dc.w	0
clipxlri	dc.w	639
clipylri	dc.w	399

dist	dc.w	0
zobs	dc.w	1500

rotx11	dc.w	16384	* Space here for the result matrix of 
rotx12	dc.w	0	* matrix multiplication
rotx13	dc.w	0
rotx21	dc.w	0
rotx22	dc.w	16384
rotx23	dc.w	0
rotx31	dc.w	0
rotx32	dc.w	0
rotx33	dc.w	16384

*************************************************************************
*									*
*	Here begins the variable area of the program module		*
*									*
*************************************************************************

*****************************************************************
*								*
*		Definition of the house				*
*								*
*****************************************************************

housdatx
	dc.w	-30,30,30,-30,30,-30,-30,30,0,0,-10,-10,10,10
	dc.w	30,30,30,30,30,30,30,30,30,30,30,30

housdaty
	dc.w	30,30,-30,-30,30,30,-30,-30,70,70,-30,0,0,-30
	dc.w	20,20,0,0,20,20,0,0
	dc.w	-10,-10,-30,-30

housdatz
	dc.w	60,60,60,60,-60,-60,-60,-60,60,-60,60,60,60,60
	dc.w	40,10,10,40,-10,-40,-40,-10
	dc.w	0,-20,-20,0

houslin	dc.w	1,2,2,3,3,4,4,1,2,5,5,8,8,3,8,7,7,6,6,5,6,1,7,4
	dc.w	9,10,1,9,9,2,5,10,6,10,11,12,12,13,13,14
	dc.w	15,16,16,17,17,18,18,15,19,20,20,21,21,22,22,19
	dc.w	23,24,24,25,25,26,26,23

***********************************************************************
* here are the definitions of the surfaces belonging to the house	*
***********************************************************************

houspla	dc.w	4,1,2,2,3,3,4,4,1,4,2,5,5,8,8,3,3,2
	dc.w	4,5,6,6,7,7,8,8,5,4,7,6,6,1,1,4,4,7
	dc.w	4,4,3,3,8,8,7,7,4,4,2,9,9,10,10,5,5,2
	dc.w	4,10,9,9,1,1,6,6,10,3,1,9,9,2,2,1
	dc.w	3,5,10,10,6,6,5,4,11,12,12,13,13,14,14,11
	dc.w	4,15,16,16,17,17,18,18,15,4,19,20,20,21,21,22,22,19
	dc.w	4,23,24,24,25,25,26,26,23

hnummark dc.w	26	* Number of corner points of the house
hnumline dc.w	32	* Number of lines of the house
hnumsurf dc.w	13	* Number of surfaces of the house

hxangle	dc.w	0	* Rotation angle of house about X-axis
hyangle	dc.w	0	*    "	     "	       "	Y-axis
hzangle	dc.w	0	*    "       "	       "	Z-axis

xwplus	dc.w	0	* Angle increment about X-axis
ywplus	dc.w	0	* Angle increment about Y-axis
zwplus	dc.w	0	* Angle increment about Z-axis

picturex dc.w	0	* Definition of zero point of display
picturey dc.w	0	* entered by getreso


rotdpx	dc.w	0
rotdpy	dc.w	0
rotdpz	dc.w	0


r1z1	dc.w	0
normz	dc.w	1500

prox	dc.w	0	* Coordinates of the projection center
proy	dc.w	0	* on the positive Z-axis
proz	dc.w	1500

offx	dc.w	0	* Transformation during rotation
offy	dc.w	0	* to point [offx,offy,offz]
offz	dc.w	0

xoffs	dc.w	0	* Inverse transformation to point
yoffs	dc.w	0	* [xoff,yoffs,zoffs]
zoffs	dc.w	0


plag	dc.b	1
	even

	SECTION	BSS

matrix11	ds.w	1	* Space here for the general 
matrix12	ds.w	1	* rotation matrix
matrix13	ds.w	1
matrix21	ds.w	1
matrix22	ds.w	1
matrix23	ds.w	1
matrix31	ds.w	1
matrix32	ds.w	1
matrix33	ds.w	1


x0	ds.w	1		* Position of the coordinate origin on 
y0	ds.w	1		* the screen 
z0	ds.w	1
z1	ds.w	1

linxy	ds.l	1		* This is the address of the line array

nummark	ds.w	1		* Number of points
numline	ds.w	1		* Number of lines

pointx	ds.l	1		* Variables of point arrays for world,
pointy	ds.l	1		* view, and screen coordinates
pointz	ds.l	1

xplot	ds.l	1
yplot	ds.l	1

datx	ds.l	1
daty	ds.l	1
datz	ds.l	1
sinx	ds.w	1		* Temporary storage for sine and
sinz	ds.w	1		* cosine values
siny	ds.w	1

cosx	ds.w	1
cosz	ds.w	1
cosy	ds.w	1

var1	ds.w	1		* general variables
var2	ds.w	1
var3	ds.w	1

xangle	ds.w	1		* Variables for passing angles
yangle	ds.w	1		* to the rotation subroutine
zangle	ds.w	1

physbase	ds.l	1		* Address of first screen page
logbase		ds.l	1		* Address of second screen page


contrl
opcode		ds.w	1	* Arrays for AES and VDI functions
sintin		ds.w	1	* for passing parameters
sintout		ds.w	1
saddrin		ds.w	1
saddrout	ds.w	1
		ds.w	6

global
apversion	ds.w	1
apcount		ds.w	1
apid		ds.w	1
apprivate	ds.l	1
apptree		ds.l	1
ap1resv		ds.l	1
ap2resv		ds.l	1
ap3resv		ds.l	1
ap4resv		ds.l	1

intin		ds.w	128
ptsin		ds.w	256
intout		ds.w	128
ptsout		ds.w	128
addrin		ds.w	128
addrout		ds.w	128
g_handle	ds.w	1
v_handle	ds.w	1

lineavar	ds.l	1		* Starting address of Line-A var

plusrot		ds.l	1
first		ds.w	1
second		ds.w	1
delta1		ds.w	1

worldpla	ds.l	1	* Address of surface array


diffz		ds.w	1

dx		ds.w	1
dy		ds.w	1
dz		ds.w	1

wrldx		ds.w	1600	* World coordinate array
wrldy		ds.w	1600
wrldz		ds.w	1600

viewx		ds.w	1600	* View coordinate array
viewy		ds.w	1600
viewz		ds.w	1600

screenx		ds.w	1600	* Display coordinate array
screeny		ds.w	1600

wlinxy		ds.l	3200

wplane		ds.l	6600	* Surface array

vplane		ds.l	6600	* Surface array of visible surfaces

surfcount	ds.w	1

numsurf		ds.w	1

zcount	ds.l	1	* Sum of all Z-coordinates
zpla	ds.w	1	* Individual Z-coordinates of surface

sx	ds.w	1
sy	ds.w	1
sz	ds.w	1

px	ds.w	1
py	ds.w	1
pz	ds.w	1

rx	ds.w	1
ry	ds.w	1
rz	ds.w	1

qx	ds.w	1
qy	ds.w	1
qz	ds.w	1

kx	ds.w	1
ky	ds.w	1
kz	ds.w	1

loopc	ds.l	1
	end
