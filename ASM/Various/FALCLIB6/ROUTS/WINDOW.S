*
* WINDOW.S
*  (vdilib.s & aeslib.s must be included at the end of the program)
*
*	@createwindow
*
*	Creates a simple gem window. It also initialises the application.
*	The size (xwidth,ywidth) is the workarea of the window.
*
* In	wtype equ %info move full close name
*	xstart,ystart,xwidth,ywidth,windowname(string terminated by 0)
* Out	w_handle,ap_id,screenxmax,screenymax
*	(destroys a lot)
*
*	@recalcwindow
*	 Recalculates the window size.
*	(destroys a lot)
*
*	@moveit
*	 Moves the window. May be called at every vm_moved(=28) event.
* In	 a0.l=adr to messagebuffer
*	(destroys a lot)
*
*	@drawrsrc
*	 Draws the rsrc.
*	 This function draw doesn't care about clipping, so you should probably not use it.
* In	 a0.l=adr to rsrc
*	(destroys a lot)
*
*	@updatersrc
*	 Draws the rsrc. Use this when receiving update events(=20).
*	 This function takes care of all clipping.
* In	 a0.l=adr to rsrc
*	(destroys a lot)
*
*	@topwindow
*	 Activates the window. May be called at every vm_topped(=21) event.
* In	 a0.l=adr to messagebuffer
*	(destroys a lot)
*
*	@bottomwindow
*	 Bottoms the window if it's mine. May be called at every vm_bottomed(=33) event.
* In	 a0.l=adr to messagebuffer 
*	(destroys a lot)
*
*	@resizewindow
*	 May be called at every resize(=27) event.
* In	 a0.l=adr. to messagebuffer
*	 (destroys a lot)
*
*	@button
*	 Returns the object number that was clicked on. This function may be called
*	 at every mousebutton event.
* In	 a0.l=adr. to rsrc
*	 (It automatically takes the x and y coordinates from int_out)
* Out	 d0.w=object that was pressed or -1.
*	(destroys a lot)
*
*	@loadrsrc
*	 Loads a resource file and creates a window containg the object in the
*	 file. You don't have to call @createwindow if you use @loadrsrc.
* In	 wtype equ %info move full close name
*	 windowname(string terminated by 0)
* 	 a0.l=address to a nul terminated filename
* Out	 a0.l=address to the resource data
*	 (destroys a lot)
*

	include	gemmacro.i


@createwindow
	appl_init
	move.w	d0,ap_id		store the application id

	graf_handle
	move.w	d0,current_handle	Desktop's VDI handle

* start by opening a virtual workstation
	lea	intin,a0
	moveq	#10-1,d0		-1 for DBF
.fill	move.w	#1,(a0)+		most params are 1
	dbf	d0,.fill
	move.w	#2,(a0)+		use RC system

	v_opnvwk			open it
	
	move.l	intout+0,screenxmax	store max x and y coordinates

* set the mouse to an arrow
	graf_mouse	#0		arrow please

	wind_calc #0,#wtype,xstart,ystart,xwidth,ywidth
	movem.w	int_out+2,d0-d3
	movem.w	d0-d3,xstart

* and create the window
	wind_create	#wtype,xstart,ystart,xwidth,ywidth
	move.w	d0,w_handle		save the handle (error checks?)

* now set its title
	move.l	#windowname,int_in+4
	wind_set	w_handle,#2	title string

* now actually show it by opening
	movem.w	xstart,d0-d3
	wind_open	w_handle,d0,d1,d2,d3

	bsr	@recalcwindow
	
	rts


* calculate the work area of the window
@recalcwindow
	wind_get	w_handle,#4	get work area
	movem.w	int_out+2,d0-d3
	movem.w	d0-d3,xstart
	rts

@resizewindow	move	6(a0),d0
		cmp	w_handle,d0
		bne	.ut
		move.l	8(a0),int_in+4
		move.l	12(a0),int_in+8
		wind_set w_handle,#5
		bsr	@recalcwindow
.ut		rts

@moveit	
	move.w	6(a0),d0
	cmp.w	w_handle,d0
	bne	.ut			not my window!
	move.w	8(a0),int_in+4		new x pos
	move.w	10(a0),int_in+6		new y pos
	move.w	12(a0),int_in+8		width
	move.w	14(a0),int_in+10	heigth
	wind_set	w_handle,#5
	bsr	@recalcwindow
.ut	rts

@drawrsrc	move	xstart,16(a0)
		move	ystart,18(a0)
		objc_draw a0,#0,#10,xstart,ystart,xwidth,ywidth
		rts

@button		move	xstart,16(a0)
		move	ystart,18(a0)
		objc_find a0,#0,#10,int_out+2,int_out+4
		move	int_out,d0
		rts

@updatersrc	move	xstart,16(a0)
		move	ystart,18(a0)
		move.l	a0,a6
		wind_update #1
		wind_get w_handle,#11
		tst.w	int_out+6
		bne	.next
		tst.w	int_out+8
		beq	.out
.next		objc_draw a6,#0,#10,int_out+2,int_out+4,int_out+6,int_out+8
		wind_get w_handle,#12
		tst.w	int_out+6
		bne	.next
		tst.w	int_out+8
		bne	.next
.out		wind_update #0
		rts
		
@topwindow	
		move.w	6(a0),d0
		cmp.w	w_handle,d0
		bne	.ut			not my window!
		wind_set	w_handle,#10
.ut		rts

@bottomwindow
		move.w	6(a0),d0
		cmp.w	w_handle,d0
		bne	.ut			not my window!
		wind_set	w_handle,#25
.ut		rts

@exitwindow	wind_close	w_handle
		wind_delete	w_handle
		rts
		
@loadrsrc	rsrc_load a0			load & fix resource
		rsrc_gaddr #0,#0		get adr.
		move.l	addr_out,a0
		move.l	a0,-(sp)
		cmp	#32,18(a0)
		bge	.yok
		move	#32,18(a0)
.yok		move.l	16(a0),xstart		window start position
		move.l	20(a0),xwidth		window size
		bsr	@createwindow
		move.l	(sp)+,a0
		rts


		


* these have to remain together
screenxmax	ds.w	1
screenymax	ds.w	1
xstart		ds.w	1
ystart		ds.w	1
xwidth		ds.w	1
ywidth		ds.w	1

w_handle	ds.w	1
ws_handle	ds.w	1
ap_id		ds.w	1


